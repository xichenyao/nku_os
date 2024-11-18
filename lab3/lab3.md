#lab3
##实验目的
了解虚拟内存的Page Fault异常处理实现

了解页替换算法在操作系统中的实现

学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。

##实验内容
本次实验是在实验二的基础上，借助于页表机制和实验一中涉及的中断异常处理机制，完成Page Fault异常处理和部分页面替换算法的实现，结合磁盘提供的缓存空间，从而能够支持虚存管理，提供一个比实际物理内存空间“更大”的虚拟内存空间给系统使用。这个实验与实际操作系统中的实现比较起来要简单，不过需要了解实验一和实验二的具体实现。实际操作系统系统中的虚拟内存管理设计与实现是相当复杂的，涉及到与进程管理系统、文件系统等的交叉访问。如果大家有余力，可以尝试完成扩展练习，实现LRU页替换算法。

##练习
对实验报告的要求：

基于markdown格式来完成，以文本方式为主

填写各个基本练习中要求完成的报告内容

列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）

列出你认为OS原理中很重要，但在实验中没有对应上的知识点
##练习0：填写已有实验
本实验依赖实验2。请把你做的实验2的代码填入本实验中代码中有“LAB2”的注释相应部分。（建议手动补充，不要直接使用merge）

##练习1：理解基于FIFO的页面替换算法（思考题）
###描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了kern/mm/swap_fifo.c文件中，这点请同学们注意）

至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数。

1)在处理页面缺页异常（Page Fault）时使用，它接收三个参数：mm 是当前的内存管理结构体指针，error_code 是错误代码，addr 是引发缺页异常的地址。该函数的目的是为触发缺页的地址找到合适的虚拟内存区域（VMA），并在需要时为该地址分配物理页面或从交换空间加载页面。
首先找到对应的 VMA，判断 addr 是否有效。如果是第一次访问该页面，就分配一个新的页面；如果页面已经在交换空间中，就从磁盘加载页面到内存，并重新建立映射。


```c
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 2212030
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            if(swap_in(mm, addr, &page) != 0 ){
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            if(page_insert(mm->pgdir, page, addr, perm) != 0){
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);

            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}


```




2)在给定的内存管理结构体 mm 中查找包含指定地址 addr 的虚拟内存区域（VMA）。如果 addr 在缓存的 mmap_cache VMA 内，它直接返回该 VMA。否则，它遍历 mm->mmap_list 链表查找包含 addr 的 VMA。如果找到，更新 mmap_cache 并返回该 VMA；如果未找到，返回 NULL。

```c
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}


```


3)用于在页目录 pgdir 中查找与给定线性地址 la 对应的页表项（PTE）。如果页目录或页表中对应的页表项不存在，并且 create 标志为真，该函数会分配新的页面来创建缺失的页表。分配的页面会被初始化并标记为已存在。该函数返回 PTE 的内核虚拟地址，以便后续对 PTE 进行操作。


```c
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /*
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding
     * kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct
     * Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the
     * memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

```

4）用于移除指定虚拟地址的页表项，并处理相关的物理页面。它首先检查页表项是否有效，若有效，则通过页表项获取对应的物理页面，减少该页面的引用计数，并在引用计数为 0 时释放该页面。最后，清空页表项并刷新 TLB，确保映射关系的正确更新和缓存的清除。

```c
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    if (*ptep & PTE_V) {  //(1) check if this page table entry is valid
        struct Page *page = pte2page(*ptep);  //(2) find corresponding page to pte
        page_ref_dec(page);   //(3) decrease page reference
        if (page_ref(page) == 0) {  
            //(4) and free this page when page reference reachs 0
            free_page(page);
        }
        *ptep = 0;                  //(5) clear page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}
```

5)用于分配 n 个连续的物理内存页。如果分配失败且 n 为 1 并且交换系统已经初始化（swap_init_ok），则调用 swap_out 释放内存，试图进行页面交换来腾出空间，直到成功分配到内存页或条件不满足。


```c
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

```
6)释放从 base 开始的 n 个连续物理内存页。调用了 pmm_manager->free_pages 来执行实际的内存释放操作，并确保在释放时禁用中断以保证线程安全。


```c
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
```
7)返回当前系统中可用的空闲物理内存页数。调用 pmm_manager->nr_free_pages() 获取该信息，并在调用时禁用中断以避免数据不一致。

```c
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
    local_intr_restore(intr_flag);
    return ret;
}

```

8)为给定的页目录 pgdir 和逻辑地址 la 分配一个物理内存页，并将其映射到逻辑地址，同时设置适当的访问权限 perm。

```c
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
    struct Page *page = alloc_page();
    if (page != NULL) {
        if (page_insert(pgdir, page, la, perm) != 0) {
            free_page(page);
            return NULL;
        }
        if (swap_init_ok) {
            swap_map_swappable(check_mm_struct, la, page, 0);
            page->pra_vaddr = la;
            assert(page_ref(page) == 1);
            // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
            // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
            // page->pra_vaddr,page->pra_page_link.prev,
            // page->pra_page_link.next);
        }
    }

    return page;
}
```


9)将内存中的若干页面交换到磁盘,该函数通过循环 n 次（即需要交换的页面数量），依次处理每个页面,然后选择一个页面（牺牲页面）进行交换。如果选择失败，输出错误信息并停止处理，根据页面的虚拟地址 v，通过 get_pte() 获取对应的页表项 ptep，并检查该页面是否有效（即 PTE_V 标志是否设置），调用 swapfs_write() 将页面的数据写入磁盘的交换空间。如果写入失败，则调用 sm->map_swappable() 标记该页面为不可交换，并继续下一次循环。如果写入成功，将页表项 ptep 更新为指向交换空间的地址（用磁盘上的页号替代原来的物理页号）。调用 free_page() 释放已交换的页面。调用 tlb_invalidate() 无效化 TLB 中对应的条目，确保地址翻译正确。函数的返回值是成功交换的页面数量 i。如果在交换过程中出现问题（如写入失败），函数会提前终止并返回已成功交换的页面数量。


```c
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
          if (r != 0) {
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
                  break;
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
          assert((*ptep & PTE_V) != 0);

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
}

```

10）从磁盘的交换空间读取指定页面，并将其加载到内存中。通过 alloc_page() 分配一个新的内存页 result 用于存放从磁盘加载的数据，根据虚拟地址 addr 使用 get_pte() 获取对应的页表项 ptep。调用 swapfs_read() 使用 ptep 中的交换条目从磁盘读取数据到 result 页面。如果读取失败，会触发断言（assert(r != 0)）。将加载的页面 result 通过 ptr_result 返回。输出加载日志，记录磁盘交换条目和虚拟地址的信息。

```c
int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();
     assert(result!=NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
     *ptr_result=result;
     return 0;
}

```

11)页面故障（Page Fault）处理中断的处理函数。它首先调用 print_pgfault 打印页面故障信息，然后检查是否有有效的地址空间（check_mm_struct）。如果有效，它会调用 do_pgfault 函数处理页面故障，传入相关的地址空间、错误码和故障地址。如果没有有效的地址空间，则触发 panic，表示未处理的页面故障。

```c
static int pgfault_handler(struct trapframe *tf) {
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
    }
    panic("unhandled page fault.\n");
}

```

##练习2：深入理解不同分页模式的工作原理（思考题）
###get_pte()函数（位于kern/mm/pmm.c）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。






###get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

答:

首先我们要了解sv32，sv39，sv48在不同方面的异同，才能够对get_pte()函数中两段代码形式类似的现象更好的做出解释。 sv32、sv39 和 sv48 是 RISC-V 架构中的三种页表模式，分别适用于不同位宽和地址空间需求。以下从不同方面介绍它们的异同。

###地址空间

sv32：支持 32 位虚拟地址，适用于 32 位系统，虚拟地址空间为 4 GB。
sv39：支持 39 位虚拟地址，适用于 64 位系统，虚拟地址空间为 512 GB。
sv48：支持 48 位虚拟地址，适用于 64 位系统，虚拟地址空间为 256 TB。
32、39、48代表虚拟地址位宽，位宽越大，虚拟地址空间也随之越大。

###页表层数

sv32：使用 2 级页表结构，需要 2 级页表查找。
sv39：使用 3 级页表结构，需要 3 级页表查找。
sv48：使用 4 级页表结构，需要 4 级页表查找。
页表层数随着虚拟地址位宽的增加而增加，以支持更大的虚拟地址空间。

###页表项大小

在所有三种模式中，每个页表项（PTE）的大小都是8 字节（64 位）。

###每级页表项数量

sv32：每级页表包含 1024 个页表项（10 位用于索引）。
sv39：每级页表包含 512 个页表项（9 位用于索引）。
sv48：每级页表包含 512 个页表项（9 位用于索引）。
页表项大小一致，但每级页表项数量不同，sv32 有更多页表项，而 sv39 和 sv48 的页表项数量相同。


get_pte()函数主要执行的是根据给定的虚拟地址la和是否创建新页表项(create)的标志，找到或创建对应的页表项PTE。虽然不同的页表模式在页表层级上有所不同，但由于分页机制就是通过多级页表逐步将虚拟地址映射到物理地址，而每一级页表的处理逻辑是类似的，因此作为执行分页机制中每一级页表的处理函数可以设计较为相似，从而适应不同级别的页表。



###目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

答:

在 get_pte() 函数中，将页表项的查找和分配逻辑合并在一起，有以下几点好处：

1.简化调用：在多级页表结构中，如果将查找和分配逻辑分开，代码会变得非常复杂,但若是get_pte() 合并查找与分配后，操作系统只需一次调用就能完成查找和必要的分配，避免编写重复代码。

2.减少开销：合并查找和分配使 get_pte() 可以在一次函数调用中完成所有操作，避免分开查找和分配带来的函数调用开销，这对具有三级页表层级的sv39 非常重要。

但如果拆分成独立的函数也可以使得这两个逻辑上相对独立的操作能够更加灵活的应用，如果发生错误时可以更好地进行测试和处理。

两种写法各有优点，但为了提高执行效率，还是更推荐将两个功能写在一起。











##练习3：给未被映射的地址映射上物理页（需要编程）
###补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：


|这是图片

这段代码是在处理缺页异常时，找到虚拟地址对应的vma且存在一个页表项的情况。
首先将一个磁盘页换入到内存中，调用swap_in函数，根据页表基地址和虚拟地址从磁盘对应位置读取，写入内存。
建立页表项的映射关系，page_insert函数将虚拟地址与内存中的物理页进行映射，更新页表项，并刷新TLB。
最后调用swap_map_swappable，设置页面可交换。


###请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

在页替换算法的过程中，主要依赖与操作的是mm结构体，该结构体把一个页表对应的信息组合起来，而对于PDE和PTE，在kern/mm/mmu.h中有一些宏定义。


·  页面状态管理：

 有效位（PTE_V）和脏位（PTE_D）结合访问位（PTE_A），帮助页替换算法判断页面是否需要被换出或更新。

·  权限控制：

读写执行权限（PTE_R, PTE_W, PTE_X）防止访问违规。
用户位（PTE_U）用于保护内核页面，优先替换不重要的用户页面。

·  性能优化：

全局位（PTE_G）可以减少多进程环境下 TLB 刷新次数，避免频繁替换全局页面。

·  页替换策略：

访问位（PTE_A）和软件位（PTE_SOFT）结合，可以实现 LRU、Clock 等页面替换算法。
软件位用于存储替换策略的辅助数据，例如访问时间戳或页面优先级。

·  与磁盘交互：

在页面换出时，通过 PPN 或软件位记录磁盘地址。
页表项的重新加载时，可利用软件位调用 swap_in 等函数将数据调回内存。

###如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

保存当前cpu状态，切换到内核态准备处理异常，将异常信息打包成tf结构体

根据stvec 寄存器指向的地址跳转到中断处理程序。

根据tf->cause判断是中断还是异常，这里是异常，调用exception_handler函数进行处理。

根据tf->cause判断异常类型，确定为缺页异常后调用pgfault_handler函数，最后到do_pgfault进行具体的异常处理。

处理成功则回到异常位置继续执行，否则输出报错信息unhandled page fault。

###数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

·  Page 数组项与页表项（PTE）：

PTE 中的物理地址字段指向的数据页框由 Page 数组管理；Page 记录了该页框的状态和使用情况。

·  Page 数组项与页目录项（PDE）：

PDE 中的物理地址字段指向页表页框，由 Page 数组管理；Page 同样记录页表页框的状态。

·  维护机制：

操作系统在页框分配时，通过 Page 数组找到空闲页框；在回收页表项或页目录项时，更新 Page 的引用计数。






##练习4：补充完成Clock页替换算法（需要编程）
###通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

比较Clock页替换算法和FIFO算法的不同。

* `swap_clock`的实现思路：

    * `init_mm` 初始化函数实现思路与 swap_fifo 的实现思路基本一致，首先初始化 pra_list_head 为空链表，然后初始化当前指针 curr_ptr 指向 pra_list_head ，表示当前页面替换位置为链表头，之后将 mm 的私有成员指针指向pra_list_head ，用于后续的页面替换算法操作。
        ```c
        list_init(&pra_list_head);
        curr_ptr = &pra_list_head;
        mm->sm_priv = &pra_list_head;
        ```
    * `map_swappable` 实现思路与 fifo 的实现思路中，将页面 page 插入到页面链表 pra_list_head 的末尾的操作都一样，只是需要将页面的 visited 标志置为 1，表示该页面已被访问。采用反向插法，即每次均插到链表头(head 指向的链表项的下一个)，之后遍历则从链表尾向前遍历即可。
        ```c
        list_entry_t *head=(list_entry_t*) mm->sm_priv;
        list_add(head, entry);
        page->visited = 1;
        ```
    * `swap_out_victim`实现思路为，遍历页面链表 pra_list_head ，查找最早未被访问页面，为了打印出该页面的地址信息我们使用 curr_ptr 去遍历页面链表。头节点没有意义，需要跳过。获取当前页面对应的 Page 结构指针，如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给 ptr_page 作为换出页面，如果当前页面已被访问，则将 visited 标志置为 0，表示该页面已被重新访问。以下代码中，由于 head 指针无法利用 le2page 宏转成 Page 结构体指针，因此先进行判断。之后从链表尾部(即 head 指向链表项的前一个项，环形链表)依次向前遍历，直到找到第一个 visited=0 的项，它便是 CLOCK算法找到的换出页面，将其移除可交换页链表。中途遇到的 Page 有 visited=1，将其置为 0 即可。
        ```c
        while (1) {
         if(curr_ptr == head){
            curr_ptr = list_prev(curr_ptr);
            continue;
        }
        struct Page* curr_page = le2page(curr_ptr,pra_page_link);
        if(curr_page->visited == 0){
            cprintf("curr_ptr %p\n", curr_ptr);
            curr_ptr = list_prev(curr_ptr);
            list_del(list_next(curr_ptr));
            *ptr_page = curr_page;
            return 0;
        }
        curr_page->visited = 0;
        curr_ptr = list_prev(curr_ptr);
        }
        ```
        

* Q:比较Clock页替换算法和FIFO算法的不同

    

    1.工作原理：
    * FIFO算法：根据页面进入内存的顺序，选择最先进入内存的页面进行置换。因此，该算法具有先进先出的特点。
    * Clock算法：将所有页面组成一个环形链表，每次需要置换页面时，从当前指针位置开始，扫描链表，选择最早不被访问的页面进行置换。当然，如果第一遍扫描没有找到可以被置换的页面，那么第二遍就会回到指针之前的位置再次扫描，直到找到为止。


    2.算法复杂度：
    * 相对于FIFO算法而言，Clock算法的实现复杂度要稍微高一些，因为涉及到了指针的移动以及对页面访问情况的维护和更新。

    3.页面置换效率：
    * 在缓存命中率低的情况下，FIFO算法的效率可能会很差，因为它只依赖于页面进入内存的顺序，而忽略了页面的访问频率和重要性。
    * 相比之下，Clock算法在考虑页面的使用情况的基础上，更具有实际应用的价值。


先进先出 (First In First Out, FIFO) 页替换算法：该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。只需把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个队列，队列头指向内存中驻留时间最久的页，队列尾指向最近被调入内存的页。这样需要淘汰页时，从队列头很容易查找到需要淘汰的页。FIFO 算法只是在应用程序按线性顺序访问地址空间时效果才好，否则效率不高。因为那些常被访问的页，往往在内存中也停留得最久，结果它们因变“老”而不得不被置换出去。FIFO 算法的另一个缺点是，它有一种异常现象（Belady 现象），即在增加放置页的物理页帧的情况下，反而使页访问异常次数增多。

时钟（Clock）页替换算法：是 LRU 算法的一种近似实现。时钟页替换算法把各个页面组织成环形链表的形式，类似于一个钟的表面。然后把一个指针（简称当前指针）指向最老的那个页面，即最先进来的那个页面。另外，时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当操作系统需要淘汰页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，如果该页被写过，则还要把它换出到硬盘上；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。该算法近似地体现了 LRU 的思想，且易于实现，开销少，需要硬件支持来设置访问位。时钟页替换算法在本质上与 FIFO 算法是类似的，不同之处是在时钟页替换算法中跳过了访问位为 1 的页。

总而言之，CLOCK算法考虑了页表项表示的页是否被访问过，而FIFO不考虑这点。

## 练习5：阅读代码和实现手册，理解页表映射方式相关知识

###如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？


页表是一个存储物理页地址的表。CPU在取指令或者取数据的时候使用的是虚拟地址，为了能够从内存中取得数据，需要将虚拟地址转换为物理地址，虚拟地址和物理地址之间的映射关系就保存在页表中。每个进程都有自己的页表。页表的映射方式主要有两种：单级页表和多级页表。  
单级页表就是用一个页表完成所有物理地址的映射。由于只有一个页表，所以在进程创建时需要为可能用到的所有的页表项分配空间，无论事实上有没有使用这块物理内存。  
而多级页表可以在使用时根据内存的占用为进程分配页表空间，可以实现按需分配而不是预先全部分配。 

##### 单级页表  
* 缺点  
1. 操作系统为每个进程分配固定大小的空间作为页表，这个固定大小的空间必须能覆盖所有页表项，因为操作系统事先并不知道进程到底需要访问多大的主存，不能实现按需分配页表空间。当虚拟内存非常大的时候，页表需要的物理内存也会变得非常大。  
2. 如果使用了快表，由于TLB缓存有限，虚拟内存很大，导致TLB无法缓存最近使用的所有页表项，查询转换速率降低。  
* 优点  
1. 单级页表的实现方式简单，仅需要维护一个页表即可。
2. 访问物理地址时只需要查询一级页表，无需其他查找操作，查询效率高。
##### 多级页表
* 优点
1. 可以使得页表在内存中离散存储。多级页表实际上是增加了索引，有了索引就可以定位到具体的项。使用一页来存放页目录项，页表项存放在内存中的其他位置，不用保证页目录项和页表项连续。
2. 适用于大内存空间，多级页表通过只为进程实际使用的那些虚拟地址内存区请求页表来减少内存使用量，提高内存利用率。
3. 灵活，可以通过调整页表级别和页表大小满足不同内存空间需求。
* 缺点
1. 实现方式复杂，需要维护多个页表。并且还要实现页表之间的查找功能。
2. 由于需要在多个级别的页表间查找，访问次数多，耗时。
3. 当进程使用的物理内存接近物理内存大小时，由于需要维护多个页表，占用内存较多。



- 好处：当操作系统启动时，boot_page_table_sv39 就采用了一个大页的映射方式，这一方式的好处是能够简便地将操作，系统从物理地址的模式切换到虚拟地址模式而不用进行多级映射关系的处理。同时也减少了页表项的数量，节省了内存空间。由于页表项数量减少，“一个大页”的页表映射方式可以提高访问效率，在分级页表中，访问一个虚拟页需要多次查找页表项，而使用“一个大页”的页表映射方式只需要一次查找即可。还可以减少 TLBmiss，当一个大页被加载到 TLB 中，可以覆盖更多的虚拟地址范围，减少了 TLB 缺失的次数，提高了内存访问的效率。
- 坏处：然而，如果在多个进程的情况下，使用一个大页进行映射意味看在发生缺页异常和需要页面置换时需要把整个大页的内容，（在Sv39下即为1GiB）全部交换到硬盘上，在换回时也需要将所有的内容一起写回。在物理内存大小不够、进程数量较多而必须要进行置换时，这会造成程序运行速度的降低。还可能会导致内存碎片的问题，内存利用率较低。最后，安全隐患也值得考虑，一个大页泄露更易导致更多信息泄露。综上，采用"一个大页"的页表映射方式可以减少页表项数量、提高访问效率和减少TLB缺失。然而，它也面临内存碎片、大页分配开销和内存利用效率等问题。

## 知识点

* 按需分页：虚拟地址可以使得软件在没有访问某虚拟内存地址时不分配具体的物理内存，只有在实际访问某虚拟内存地址时，操作系统再动态地分配物理内存，建立虚拟内存到物理内存的页映射关系。
* 页面的换入换出：把不经常访问的数据所占的内存空间临时写到硬盘上，这样可以腾出更多的空闲内存空间给经常访问的数据；当CPU访问到不经常访问的数据时，再把这些数据从硬盘读入到内存中。这种内存管理技术给了程序员更大的内存“空间”，从而可以让更多的程序在内存中并发运行。
* 传输数据时只允许以磁盘扇区为数据传输的基本单位，也就是一次传输的数据必须是512字节的倍数，并且必须对齐。
* 在 sv39中，定义物理地址(Physical Address)有56位，而虚拟地址(Virtual Address)有39位。不论是物理地址还是虚拟地址，最后12位表示的是页内偏移，也就是这个地址在它所在页帧的什么位置（同一个位置的物理地址和虚拟地址的页内偏移相同）。除了最后12位，前面的部分表示的是物理页号或者虚拟页号。
* 缺页异常：CPU访问的虚拟地址时， MMU没有办法找到对应的物理地址映射关系，或者与该物理页的访问权不一致而发生的异常。
* ucore 对于页面置换机制目前大致有两种策略，即积极换出策略和消极换出策略。  
积极换出策略是指操作系统周期性地（或在系统不忙的时候）主动把某些认为“不常用”的页换出到硬盘上，从而确保系统中总有一定数量的空闲页存在，这样当需要空闲页时，基本上能够及时满足需求；  
消极换出策略是指只有当试图得到空闲页时，发现当前没有空闲的物理页可供分配，这时才开始查找“不常用”页面，并把一个或多个这样的页换出到硬盘上。
* 页面替换算法：
  1. 先进先出(First In First Out, FIFO)页替换算法：该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。
  2. 最久未使用(least recently used, LRU)算法：利用局部性，通过过去的访问情况预测未来的访问情况，比较当前内存里的页面最近一次被访问的时间，把上一次访问时间离现在最久的页面置换出去。
  3. 时钟（Clock）页替换算法：是 LRU 算法的一种近似实现。时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。时钟页替换算法在本质上与 FIFO 算法是类似的，不同之处是在时钟页替换算法中跳过了访问位为 1 的页。




##扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）
challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。
