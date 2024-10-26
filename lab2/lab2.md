#lab2
##实验目的
理解页表的建立和使用方法

理解物理内存的管理方法

理解页面分配算法
##实验内容
实验一过后大家做出来了一个可以启动的系统，实验二主要涉及操作系统的物理内存管理。操作系统为了使用内存，还需高效地管理内存资源。本次实验我们会了解如何发现系统中的物理内存，然后学习如何建立对物理内存的初步管理，即了解连续物理内存管理，最后掌握页表相关的操作，即如何建立页表来实现虚拟内存到物理内存之间的映射，帮助我们对段页式内存管理机制有一个比较全面的了解。本次的实验主要是在实验一的基础上完成物理内存管理，并建立一个最简单的页表映射。
##练习
##练习1：理解first-fit 连续物理内存分配算法（思考题）
first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合kern/mm/default_pmm.c中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

你的first fit算法是否有进一步的改进空间？

**default_init:**

初始化自由内存链表，并将自由块数量设置为0。

**default_init_memmap:**

初始化给定范围的内存页面，初始化一个内存页块，将一定数量的页面标记为未使用，设置每个页面的状态，并将第一个页面的属性设为总页数，并更新操作系统的内存管理系统，如果自由列表为空，将新的内存块添加到列表中；如果不为空，遍历列表并在适当的位置插入新块，以反映可用内存的增加。

p->flags = p->property = 0;

这行代码将当前 Page 结构体的 flags 和 property 成员都设置为0。清除任何先前的状态，确保这些字段在初始化时都是干净的。

nr_free += n;

将全局变量 nr_free（可用页面的数量）增加 n，以反映新初始化的内存页块中的页面现在是可用的。

**default_alloc_pages:**

尝试分配n个页面。如果自由页面数量不足，返回NULL。遍历自由列表，寻找第一个满足请求的块。找到合适的页面后，删除它从自由列表，并更新其属性。如果剩余空间大于0，更新剩余空间的属性并将其重新插入自由列表。最后，减少自由块计数并返回分配的页面。

**default_free_pages:**


释放n个页面，重置页面的状态，并增加自由块数量。将释放的页面插入自由列表，确保按地址顺序插入。检查释放的块是否与前一个或后一个块相邻。如果相邻，则合并这些块并更新属性。

**可能的改进：**

内存碎片管理:
First Fit可能导致内存碎片问题，即虽然有足够的总内存，但可能没有足够的连续内存来满足请求。可以考虑实现更复杂的算法，如Best Fit或Buddy System，以更有效地管理碎片。

搜索效率:
在链表中线性搜索可能导致性能瓶颈。可以考虑使用更高效的数据结构（如平衡树或哈希表）来加速空闲块的查找。

合并策略:
当前的合并策略仅在释放时合并相邻块。可以在分配时检查并合并相邻的空闲块，以减少碎片。

动态调整:
可以根据实际使用情况动态调整分配策略，例如在高内存使用期间优先选择大块空闲页以减少碎片。






##练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

你的 Best-Fit 算法是否有进一步的改进空间？

与First Fit不同，Best Fit需要遍历整个自由链表，以找到最小且足够的块。


```

static void
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));

        /*LAB2 EXERCISE 2: 2211287*/ 
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
   		p->flags = 0; // 清空标志
        p->property = 0; // 清空属性
        p->ref = 0; // 设置引用计数为0
	}
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
             /*LAB2 EXERCISE 2: 2211287*/ 
            // 编写代码
            // 1、当base < page时，找到第一个大于base的页，将base插入到它前面，并退出循环
            // 2、当list_next(le) == &free_list时，若已经到达链表结尾，将base插入到链表尾部
       		if (base < page) {
                list_add_before(le, &(base->page_link));
                return;
            }
        }
        list_add(le, &(base->page_link)); // 添加到链表尾部
    }
}


```

内存初始化过程，主要目的是在一个空闲链表中根据大小排序插入一个新的内存块。这是内存管理中的一部分，用于将多个空闲页整合进链表 free_list 中，以便后续的最佳适配算法可以快速找到合适的内存块。


```
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *best_page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: YOUR 2211287*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
  



    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            // 如果当前块满足请求并且是目前找到的最小块
            if (p->property < min_size) {
                min_size = p->property;  // 更新最小块大小
                best_page = p;           // 记录当前最佳块
            }
        }
    }

    if (best_page != NULL) {
        list_entry_t* prev = list_prev(&(best_page->page_link));
        list_del(&(best_page->page_link));
        
        if (best_page->property > n) {
            struct Page *remaining_page = best_page + n;
            remaining_page->property = best_page->property - n; // 更新剩余页面的属性
            SetPageProperty(remaining_page);
            list_add(prev, &(remaining_page->page_link)); // 将剩余页面添加回空闲链表
        }
        
        nr_free -= n;                // 更新空闲页面总数
        ClearPageProperty(best_page); // 清除已分配页面的属性
    }
    
    return best_page; // 返回找到的最佳页面
}

```

页面分配功能。其核心逻辑是在一个空闲链表中查找满足特定大小需求的最佳内存块，并进行分配。

```
static void
best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
	// 1. 清除当前页块的标记，设置为释放状态
	
    /*LAB2 EXERCISE 2: 2211287*/ 
    // 编写代码
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值

	// 2. 将当前页块插入到空闲链表中
	base->property = n;
	// 设置当前页块的属性为释放的页块数
    SetPageProperty(base);    
	// 标记当前页块为已分配状态
    nr_free += n;  
	// 增加空闲页块总数
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                // 在找到的空闲页块之前插入
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
           		// 在链表末尾插入
			}
        }
    }

	 // 3. 合并前面的连续空闲页块
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        /*LAB2 EXERCISE 2: 2211287*/ 
         // 编写代码
        // 1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        // 4、从链表中删除当前页块
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
   		if (p + p->property == base) { // 如果前一个页块与当前页块连续
            p->property += base->property; // 更新前一个空闲页块的大小
            ClearPageProperty(base); // 清除当前页块的属性标记
            list_del(&(base->page_link)); // 从链表中删除当前页块
            base = p; // 指向前一个空闲页块以便继续合并
        }
    }

    // 4. 合并后面的连续空闲页块
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) { // 如果当前页块与下一个页块连续
            base->property += p->property; // 更新当前页块的大小
            ClearPageProperty(p); // 清除下一个页块的属性标记
            list_del(&(p->page_link)); // 从链表中删除下一个页块
        }
    }
	} 
```

页面释放功能，具体来说是将已分配的页面块释放回空闲链表，并尝试合并相邻的空闲页面块以减少内存碎片。

**可能的改进：**

合并优化：合并相邻块时，当前实现是简单的前后合并。可以考虑合并所有相邻块，以减少内存碎片。

缓存机制：使用缓存机制存储最近的分配和释放情况，以提高分配效率。

改进选择策略：可以采用其他算法（如循环使用）来避免频繁选择最佳适配的性能损失。

内存碎片管理：增加内存碎片的监控和清理机制，以提高整体内存利用率。

并行处理：对于多线程环境，可以实现锁机制以保护自由列表，防止竞争条件。





##扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）
Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

参考伙伴分配器的一个极简实现， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。
##扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）
slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

参考linux的slub分配算法/，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。
##扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

1. 使用引导加载程序（Bootloader）
在系统启动时，引导加载程序可以查询硬件信息，包括可用的物理内存范围。引导加载程序通常会通过 BIOS 中断或 EFI 接口获取内存映射信息，然后将这些信息传递给操作系统。在 Linux 中，通常会使用 e820 方案来获取内存的布局。

2. 查询系统固件接口
现代计算机常使用 UEFI（统一可扩展固件接口）作为固件接口，操作系统可以通过 UEFI 提供的 API 查询可用的内存范围。UEFI 提供了更丰富的内存管理功能，操作系统可以直接从 UEFI 中获取系统的内存图谱。

3. 读取系统设备树（Device Tree）
在某些嵌入式系统或特定平台上，操作系统可以从设备树（Device Tree）中获取可用内存信息。设备树是一个数据结构，用于描述硬件的各种信息，包括内存的布局。

4. 使用中断或特殊寄存器
某些硬件平台提供特殊的 CPU 寄存器或中断，用于报告可用内存的信息。操作系统可以在启动时读取这些寄存器，以获取物理内存的范围。

5. 通过自检程序（Self-test）
在系统启动期间，可以运行自检程序来检查可用的物理内存。该程序可以通过分配和释放内存块，检测内存是否可用，从而确定可用的内存范围。这种方法可能较慢，但可以作为补充手段。

6. 使用操作系统的初始化阶段
在操作系统的初始化过程中，可以通过不同的方式（例如，调用硬件抽象层的函数）来获取可用的内存范围。这种方法依赖于底层硬件的实现和操作系统的设计。