#include <list.h>
#include <defs.h>
#include <atomic.h>
#include <assert.h>
#include <sync.h>
#include <stdio.h>

// 定义 SLUB 的一些基本参数
#define SLUB_MIN_OBJSIZE     32      // 最小对象大小
#define SLUB_MAX_OBJSIZE     1024    // 最大对象大小
#define SLUB_MIN_ORDER        0       // 最小内存页顺序
#define SLUB_MAX_ORDER        2       // 最大内存页顺序

// 定义 slab 状态
#define SLAB_OBJ_EMPTY       0x0     // 对象未使用
#define SLAB_OBJ_ALLOCATED   0x1     // 对象已分配
#define SLAB_OBJ_FREE        0x2     // 对象已释放

// Slab 缓存结构
struct kmem_cache {
    char name[16];                     // 缓存名称
    size_t obj_size;                   // 单个对象大小
    uint32_t flags;                    // 缓存标志
    struct list_head slab_list;         // 包含的 slab 列表
    struct mutex lock;                 // 缓存锁
    atomic_int nr_slabs;                // slab 数量
    atomic_int nr_objs;                 // 对象数量
    atomic_int nr_free;                 // 空闲对象数量
};

// Slab 页面结构
struct slab {
    struct list_head list;              // slab 链表
    struct page *page;                  // 所属内存页
    struct kmem_cache *cache;           // 所属缓存
    uint32_t flags;                     // slab 标志
    atomic_int nr_objs;                  // 页面中对象数量
    atomic_int nr_free;                  // 页面中空闲对象数量
    void *freelist;                      // 空闲对象链表
};

// 函数声明
struct kmem_cache *kmem_cache_create(const char *name, size_t obj_size, uint32_t flags);
void kmem_cache_destroy(struct kmem_cache *cache);
void *kmem_cache_alloc(struct kmem_cache *cache);
void kmem_cache_free(struct kmem_cache *cache, void *obj);

// 函数定义
struct kmem_cache *
kmem_cache_create(const char *name, size_t obj_size, uint32_t flags)
{
    struct kmem_cache *cache;
    int ret;

    cache = kmalloc(sizeof(*cache), GFP_KERNEL);
    if (!cache)
        return NULL;

    ret = snprintf(cache->name, sizeof(cache->name), "%s", name);
    assert(ret < sizeof(cache->name));

    cache->obj_size = obj_size;
    cache->flags = flags;
    INIT_LIST_HEAD(&cache->slab_list);
    mutex_init(&cache->lock);
    atomic_set(&cache->nr_slabs, 0);
    atomic_set(&cache->nr_objs, 0);
    atomic_set(&cache->nr_free, 0);

    return cache;
}

void
kmem_cache_destroy(struct kmem_cache *cache)
{
    struct slab *slab, *tmp;

    list_for_each_entry_safe(slab, tmp, &cache->slab_list, list) {
        list_del(&slab->list);
        kfree(slab);
    }

    kfree(cache);
}

void *
kmem_cache_alloc(struct kmem_cache *cache)
{
    struct slab *slab;
    void *obj;

    mutex_lock(&cache->lock);
    list_for_each_entry(slab, &cache->slab_list, list) {
        if (slab->freelist) {
            obj = slab->freelist;
            slab->freelist = *(void **)obj;
            atomic_dec(&slab->nr_free);
            atomic_dec(&cache->nr_free);
            mutex_unlock(&cache->lock);
            return obj;
        }
    }
    mutex_unlock(&cache->lock);

    // 如果没有找到空闲对象，尝试分配新的 slab
    slab = kmalloc(sizeof(*slab), GFP_KERNEL);
    if (!slab)
        return NULL;

    slab->page = alloc_pages(SLUB_MIN_ORDER);
    if (!slab->page) {
        kfree(slab);
        return NULL;
    }

    slab->cache = cache;
    slab->flags = 0;
    atomic_set(&slab->nr_objs, cache->obj_size);
    atomic_set(&slab->nr_free, cache->obj_size);
    slab->freelist = page_address(slab->page);

    // 初始化空闲对象链表
    char *p = (char *)slab->freelist;
    for (int i = 0; i < cache->obj_size - sizeof(void *); i += cache->obj_size) {
        *(void **)p = (void *)(p + cache->obj_size);
        p += cache->obj_size;
    }
    *(void **)p = NULL;

    mutex_lock(&cache->lock);
    list_add(&slab->list, &cache->slab_list);
    atomic_inc(&cache->nr_slabs);
    atomic_inc(&cache->nr_objs);
    atomic_inc(&cache->nr_free);
    mutex_unlock(&cache->lock);

    return slab->freelist;
}

void
kmem_cache_free(struct kmem_cache *cache, void *obj)
{
    struct slab *slab;
    slab = virt_to_slab(obj);

    mutex_lock(&cache->lock);
    slab->freelist = obj;
    *(void **)obj = slab->freelist;
    atomic_inc(&slab->nr_free);
    atomic_inc(&cache->nr_free);
    mutex_unlock(&cache->lock);
}

// 测试代码
void
slub_test(void)
{
    struct kmem_cache *cache;
    void *obj1, *obj2;

    cache = kmem_cache_create("test_cache", 128, 0);
    if (!cache) {
        printf("Failed to create slab cache\n");
        return;
    }

    obj1 = kmem_cache_alloc(cache);
    obj2 = kmem_cache_alloc(cache);
    if (!obj1 || !obj2) {
        printf("Failed to allocate objects\n");
        kmem_cache_destroy(cache);
        return;
    }

    kmem_cache_free(cache, obj1);
    kmem_cache_free(cache, obj2);

    kmem_cache_destroy(cache);
}
