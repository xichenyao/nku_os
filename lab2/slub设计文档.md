# SLUB 分配器设计文档

## 1. 概述

本设计基于 Linux 内核的 SLUB（Simplified Linux Memory Allocator），实现了一个用于管理内核对象的内存分配器，欲用于 uCore 操作系统。SLUB 主要优化内核对象内存的分配和释放性能，通过减少缓存行争用、使用 `per-CPU` 数据结构以及采用原子操作和锁来实现高效的内存管理。本简化版本在基本功能上参考了 Linux SLUB，但去掉了 NUMA 支持、碎片整理、详细调试等特性。

## 2. 数据结构

该实现使用了以下关键数据结构来管理对象缓存和 slab 页面：

### 2.1 `kmem_cache` 结构

`kmem_cache` 用于描述和管理特定类型的内核对象，包含以下字段：

```c
struct kmem_cache {
    char name[16];                    // 缓存名称
    size_t obj_size;                  // 单个对象大小
    uint32_t flags;                   // 缓存标志
    struct list_head slab_list;       // slab 链表
    struct mutex lock;                // 缓存锁
    atomic_int nr_slabs;              // slab 数量
    atomic_int nr_objs;               // 对象数量
    atomic_int nr_free;               // 空闲对象数量
};
```

- **name**：缓存的名称，用于调试和管理。
- **obj_size**：对象大小，以字节为单位。
- **flags**：标志位，设置缓存的特性。
- **slab_list**：一个链表，链接当前缓存的所有 slab 页面。
- **lock**：互斥锁，用于并发访问控制。
- **nr_slabs, nr_objs, nr_free**：记录缓存的 slab 数量、对象总数及空闲对象数量。

### 2.2 `slab` 结构

`slab` 表示一个分配的物理内存页，包含若干内核对象：

```c
struct slab {
    struct list_head list;            // slab 链表节点
    struct page *page;                // 所属内存页
    struct kmem_cache *cache;         // 指向所属缓存
    uint32_t flags;                   // slab 标志
    atomic_int nr_objs;               // slab 内的对象数
    atomic_int nr_free;               // slab 内的空闲对象数
    void *freelist;                   // 空闲对象链表
};
```

- **list**：链表节点，用于将 slab 添加到 `kmem_cache` 的 `slab_list` 中。
- **page**：指向分配的物理内存页。
- **cache**：指向 `kmem_cache`，表示该 slab 所属的缓存。
- **flags**：slab 标志。
- **nr_objs**：slab 中的对象总数。
- **nr_free**：slab 中的空闲对象数。
- **freelist**：空闲对象链表，用于快速分配和释放对象。

## 3. 内存分配和释放函数

### 3.1 `kmem_cache_create`

```c
struct kmem_cache *kmem_cache_create(const char *name, size_t obj_size, uint32_t flags);
```

- 用于创建一个新的 `kmem_cache`，初始化缓存的各个字段，包括对象大小、缓存标志、slab 列表、对象数等。
- 使用互斥锁 `mutex_init` 初始化锁。
- 返回 `kmem_cache` 的指针。

### 3.2 `kmem_cache_destroy`

```c
void kmem_cache_destroy(struct kmem_cache *cache);
```

- 销毁指定的 `kmem_cache` 缓存，将所有相关的 slab 释放。
- 先将所有 slab 从 `slab_list` 链表中移除，然后释放每个 slab。
- 最后释放 `kmem_cache` 本身所占的内存。

### 3.3 `kmem_cache_alloc`

```c
void *kmem_cache_alloc(struct kmem_cache *cache);
```

- 在缓存中分配一个对象。
- 遍历 `slab_list` 查找空闲对象，如果存在空闲对象则直接返回。
- 如果没有找到空闲对象，则分配新的 `slab` 并初始化 `freelist`。
- 更新 `nr_free`、`nr_objs` 等计数器。

### 3.4 `kmem_cache_free`

```c
void kmem_cache_free(struct kmem_cache *cache, void *obj);
```

- 释放指定对象。
- 获取对象所在的 slab，使用 `freelist` 将其重新加入空闲链表。
- 更新 `nr_free` 计数器。

## 4. 同步与并发控制

该实现中使用了 `mutex` 实现基本的并发控制，主要在以下几个操作中使用锁：
- `kmem_cache_alloc` 和 `kmem_cache_free`：锁定 `kmem_cache` 的 slab 列表，确保线程安全。
- `kmem_cache_create` 和 `kmem_cache_destroy`：锁定整个缓存，避免并发修改结构。

由于本简化版本没有使用更复杂的原子操作和 `per-CPU` 数据结构，因此并未进行多 CPU 性能优化。

## 5. 内存分配流程

1. 调用 `kmem_cache_alloc` 分配对象。
   - 遍历 `slab_list`，查找包含空闲对象的 slab。
   - 如找到空闲对象，返回对象指针。
   - 如未找到空闲对象，分配新 slab，初始化对象并添加到 `slab_list`。
   
2. 使用 `kmem_cache_free` 释放对象。
   - 获取对象所在的 slab。
   - 将对象重新加入 slab 的 `freelist` 中，更新 `nr_free` 计数器。

## 6. 测试用例

在 `slub_test` 中对 `kmem_cache` 的分配和释放功能进行了测试：

```c
void slub_test(void) {
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
```

- 创建 `kmem_cache`。
- 分配两个对象并检测分配是否成功。
- 释放对象并销毁缓存，验证资源回收的正确性。

## 7.头文件
简化版的 SLUB 内存分配器依赖于几个头文件来提供必要的数据结构、宏、同步机制和基础库函数。以下是每个头文件的作用解释：

### 7.1  `list.h`

`list.h` 提供链表相关的定义和操作函数，用于在 SLUB 中组织 `kmem_cache` 和 `slab` 的链表结构。在 SLUB 中，每个缓存（`kmem_cache`）包含一个 slab 的链表，每个 slab 也被链接在一个链表中以便管理。

- **主要作用**：
  - 定义双向链表的数据结构和操作函数，例如 `list_add`、`list_del`、`list_for_each_entry` 等。
  - SLUB 中使用链表管理 `kmem_cache` 内的多个 slab，这样可以方便地进行 slab 的遍历、增删等操作。

### 7.2  `defs.h`

`defs.h` 通常包含了操作系统的通用定义和基本常量。它可以为代码提供基础定义，如数据类型、宏和常量，方便代码的通用性和跨平台移植。

- **主要作用**：
  - 提供基础数据类型的定义，如 `size_t` 和 `uint32_t` 等，确保代码具有可移植性。
  - 定义一些通用常量，如内存分配标志（例如 `GFP_KERNEL`）。
  - 可能还包含其他基础的内核定义，支持内核空间内存管理和通用结构。

### 7.3  `atomic.h`

`atomic.h` 提供原子操作的定义和实现。这些原子操作可以保证在多线程/多核环境下进行无锁并发更新，避免 race condition（竞争条件）。在 SLUB 中，原子操作用于计数器的增加或减少，例如空闲对象数量、对象总数和 slab 数量。

- **主要作用**：
  - 定义原子操作，如 `atomic_inc`、`atomic_dec`、`atomic_set`、`atomic_read` 等函数。
  - 确保多线程环境下的计数器操作是线程安全的，避免频繁加锁带来的性能开销。

### 7.4  `assert.h`

`assert.h` 提供了断言宏 `assert`，用于调试和验证程序运行时的某些假设条件是否成立。断言可以帮助开发者捕捉代码中潜在的逻辑错误。

- **主要作用**：
  - 通过 `assert` 宏检查关键条件，例如内存分配结果是否为空。
  - 在调试模式下，如果条件不满足，`assert` 会直接中断程序运行，方便开发者发现和修复错误。

### 7.5  `sync.h`

`sync.h` 提供同步机制的定义和实现，通常包括互斥锁（`mutex`）和自旋锁等。在 SLUB 中使用了互斥锁来保护共享数据（如 `kmem_cache` 和 `slab` 结构）在并发访问时的安全性。

- **主要作用**：
  - 定义和实现锁的初始化、加锁、解锁等操作函数，例如 `mutex_init`、`mutex_lock` 和 `mutex_unlock`。
  - 在 `kmem_cache_alloc` 和 `kmem_cache_free` 中控制对共享数据的互斥访问，避免并发访问导致的数据不一致。

### 7.6  `stdio.h`

`stdio.h` 提供了标准输入输出函数，例如 `printf`。在 SLUB 中主要用于输出调试信息和测试结果，便于验证分配器的运行状态和正确性。

- **主要作用**：
  - 提供格式化输出功能，例如 `printf`。
  - 在测试函数 `slub_test` 中用于打印分配和释放对象的结果，帮助观察和验证分配器的工作状态。

这些头文件共同为 SLUB 分配器提供了基础的链表、原子操作、同步机制和调试支持等，使其能够在多线程环境中安全地执行对象分配和释放。

## 8. SLUB 运行过程总结

SLUB 在内存分配的实际运行过程如下：

- **创建缓存**：初始化阶段创建特定大小的缓存，准备好对象分配的资源。
- **分配对象**：当需要分配特定大小的对象时，SLUB 查找合适的缓存并在其中寻找空闲对象。
  - 如果有空闲对象，直接返回；没有则创建新的 slab。
- **释放对象**：当对象不再使用时，将其归还到 slab 的空闲链表。
- **销毁缓存**：当缓存不再需要时，释放其所有资源，回收内存。

通过缓存、slab 和空闲链表，SLUB 将小对象的内存管理进行了结构化的组织，使得内存分配过程更加高效，避免了碎片化。