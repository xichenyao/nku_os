# lab5:用户程序

## 实验4完成了内核线程，但到目前为止，所有的运行都在内核态执行。实验5将创建用户进程，让用户进程在用户态执行，且在需要ucore支持时，可通过系统调用来让ucore提供服务。

## 实验目的

了解第一个用户进程创建过程

了解系统调用框架的实现机制

了解ucore如何实现系统调用sys_fork/sys_exec/sys_exit/sys_wait来进行进程管理

## 实验内容
实验4完成了内核线程，但到目前为止，所有的运行都在内核态执行。实验5将创建用户进程，让用户进程在用户态执行，且在需要ucore支持时，可通过系统调用来让ucore提供服务。为此需要构造出第一个用户进程，并通过系统调用sys_fork/sys_exec/sys_exit/sys_wait来支持运行不同的应用程序，完成对用户进程的执行过程的基本管理。

## 练习
对实验报告的要求：

基于markdown格式来完成，以文本方式为主
填写各个基本练习中要求完成的报告内容
列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验

本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

修改代码如下图：


## 练习1: 加载应用程序并执行（需要编码）

do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充load_icode的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。
```c
     tf->gpr.sp = USTACKTOP;
     tf->epc = elf->e_entry;
     tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
```
tf->gpr.sp = USTACKTOP;
作用：设置 sp（栈指针）为 USTACKTOP，这是用户栈的顶端。
tf 是一个指向 trapframe 结构体的指针，通常用于保存进程的上下文（例如寄存器的值），这是操作系统进行上下文切换时的重要数据结构。
gpr 是 trapframe 结构体中的通用寄存器集合，sp 是其中的栈指针（Stack Pointer），用于指向当前栈的顶部。
USTACKTOP 是一个宏或常量，代表用户栈的栈顶地址。在某些操作系统中，用户空间和内核空间会共享地址空间，因此栈顶通常被设定为用户栈的起始地址（即栈的最大有效内存地址）。
tf->epc = elf->e_entry;
作用：将程序计数器 epc 设置为可执行文件 ELF 文件的入口点 e_entry。
epc是存储当前执行指令地址的寄存器。在 RISC-V 中，epc 寄存器存储程序计数器的值。
elf->e_entry 是从 ELF 文件头中获取的程序的入口点地址（即程序的起始执行地址）。ELF是可执行文件的标准格式，它包含了程序的各个部分（例如代码段、数据段等）。e_entry 是该文件中程序的起始地址。
tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
作用：设置 status 寄存器，确保进程从用户模式启动，且禁用中断。
sstatus 是当前状态寄存器，用来存储 CPU 的状态信息，如中断启用、当前特权级别等。SSTATUS_SPP 和 SSTATUS_SPIE 是其中的标志位，控制着特权级和中断状态。
SSTATUS_SPP：表示当前操作模式的标志位（即 SPP，Supervisor Previous Privilege）。当 SSTATUS_SPP 为 1 时，表示上一个操作模式是 Supervisor（内核模式），为 0 时表示是 User（用户模式）。
SSTATUS_SPIE：表示中断使能的标志位。SPIE 表示 Supervisor 模式下的中断启用位。通常，SPIE 为 1 表示中断启用，为 0 表示中断禁用。
sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE) 是对 sstatus 的位操作，清除 SSTATUS_SPP 和 SSTATUS_SPIE，即：
设置 SSTATUS_SPP 为 0，表示程序将从用户模式开始执行。
设置 SSTATUS_SPIE 为 0，表示禁用中断（即进入无中断模式，直到中断被显式地重新启用）。
确保当前进程从用户模式开始，并且禁止中断。这样可以确保进程启动时处于干净的状态，避免因中断干扰而影响进程执行。


load_icode()函数解析：
加载 ELF 格式二进制程序（即用户应用程序）的过程，功能是将二进制文件加载到当前进程的虚拟地址空间，并为程序提供必要的资源，包括堆栈、代码段、数据段和 BSS 段等。它是进程创建或用户程序执行的一个重要部分。
current->mm 表示当前进程的内存管理结构体（mm_struct），用于管理该进程的虚拟地址空间。如果已经有映射（即该进程已经有内存空间被分配），则无法加载新程序，因此报错并终止。
创建一个新的内存管理结构体 mm，用于管理该进程的虚拟内存。若创建失败，则跳转至错误处理部分。
设置新进程的页面目录（PDT），即为该进程建立一个虚拟地址空间映射。setup_pgdir 负责分配和初始化页表，并设置页目录。若失败，进行清理操作。
通过 binary 获取 ELF 文件头（elfhdr），然后解析程序头表（proghdr）。检查 ELF 文件是否有效（即 e_magic 字段是否为有效的 ELF 魔术数）。
遍历程序头表，处理每个加载类型为 ELF_PT_LOAD 的段（这些段是可加载到内存中的部分，如代码段和数据段）。如果程序头类型不是加载类型，跳过。
为每个加载的程序段映射内存空间。mm_map 函数会根据程序段的虚拟地址（p_va）和段的内存大小（p_memsz）来分配内存。
```c
mm_count_inc(mm);
current->mm = mm;
current->cr3 = PADDR(mm->pgdir);
lcr3(PADDR(mm->pgdir));
```
将当前进程的 mm 设置为新的内存管理结构，更新页目录地址，并刷新 TLB（转换后备页表）。

**用户态进程从 RUNNING 状态到执行程序的第一条指令的过程**

1. 进程创建与运行

当一个新的用户进程被创建时，操作系统会调用 load_icode 函数来加载 ELF 格式的程序。首先，操作系统为进程分配内存，设置页面目录和堆栈，并将二进制程序加载到内存中。

2. 设置虚拟地址空间

系统为程序分配内存，并设置虚拟地址空间，包括程序的代码段、数据段、堆和栈。系统通过 mm_map 映射内存区域，通过 pgdir_alloc_page 分配物理页面。

3. 初始化上下文（Trapframe）

在加载完程序后，系统会设置 trapframe，这是进程在执行期间保存寄存器值的地方。此时，系统通过修改 trapframe 设置程序计数器 epc 为 ELF 文件中的入口点，并设置栈指针 sp。

4. 切换到用户模式

系统设置完所有的内存和寄存器后，操作系统将进程的状态切换到 RUNNING，并将 CPU 从内核模式切换到用户模式。此时，用户程序从其入口点开始执行。

5. 执行第一条指令

通过修改 epc，进程的控制流跳转到程序的入口地址（即 ELF 文件中 e_entry 字段指定的地址）。此时，用户程序开始执行第一条指令。


## 练习2: 父进程复制自己的内存空间给子进程（需要编码）

创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。

```c
// (1) 获取源页面的内核虚拟地址
                void *src_kvaddr = page2kva(page);
                // (2) 获取目标页面的内核虚拟地址
                void *dst_kvaddr = page2kva(npage);
                // (3) 将源页面的内容复制到目标页面
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                // (4) 将新页面映射到进程 B 的地址空间
                ret = page_insert(to, npage, start, perm);
                if (ret != 0) {
                    return ret; // 如果映射失败，返回错误码
                }
```
copy_range() 的作用是将一个进程 A 的地址空间内的指定内存范围（start 到 end）复制到另一个进程 B 中。
步骤 1：确认 start 和 end 是页对齐的地址，同时确认它们在用户态地址范围内。
步骤 2：遍历指定的内存区域，每次处理一页。
通过 get_pte 获取进程 A 的页表项（pte）。如果页表项不存在，则跳过当前页范围。
确保当前页有效（PTE_V），表示该页存在并被映射。
为进程 B 分配页表项（如果不存在则创建）。
步骤 3：对页面的实际复制：
从进程 A 的页表项中找到页面（page2kva 获得内核虚拟地址）。
分配一个新的页面（alloc_page）供进程 B 使用。
使用 memcpy 将页面内容从进程 A 复制到新页面。
通过 page_insert 将新页面映射到进程 B 的页表中。
步骤 4：遍历下一页，直到遍历完整个范围。
步骤 5：若无错误返回 0。

如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。
Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

Copy-on-Write (COW) 是一种延迟复制技术，主要用于优化内存资源的使用，广泛应用于操作系统的进程创建和内存管理中。例如，在 fork 系统调用中，父子进程通常共享同一块内存，直到其中一个试图修改这块内存时，才会创建副本。

核心思想
共享页面：进程创建时，父子进程共享相同的内存页面，节省内存资源。
延迟复制：只有当某个进程尝试写入共享页面时，操作系统才分配新页面并完成内容复制。
页表标志：通过在页表中设置“只读”标志，控制页面访问权限。
中断处理：当写操作触发页面保护错误（Page Fault）时，操作系统捕获中断并完成复制操作。
优点
减少内存使用：进程只在需要修改时才复制内存页面。
提高性能：延迟复制避免了不必要的内存拷贝。

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

## 扩展练习 Challenge

实现 Copy on Write （COW）机制

给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

这是一个big challenge.

说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？

在实现 COW 的系统中，用户程序的内存页面不需要在一开始就全部加载到内存中。
当父进程创建子进程时：
用户地址空间中的页面不会被直接复制，而是通过将页表项标记为只读，允许父子进程共享相同的物理内存页面。
页面的实际复制发生在首次写入操作时，触发缺页异常，由内核完成页面的分配和数据复制。

```c
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
    pgfault_num++;

    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and cannot find it in vma\n", addr);
        goto failed;
    }

    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= PTE_W; // 标记页面可写
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;
    pte_t *ptep = NULL;

    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    if (*ptep == 0) {
        // 页表项不存在，分配页面并映射
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else if (!(*ptep & PTE_W)) {
        // 页表项存在但不可写，检查是否需要 COW
        struct Page *page = pte2page(*ptep);

        // 如果页面是共享的（引用计数 > 1），执行 COW
        if (page_ref_count(page) > 1) {
            struct Page *new_page = alloc_page();
            if (new_page == NULL) {
                cprintf("alloc_page in do_pgfault failed\n");
                goto failed;
            }

            // 复制原页面内容到新页面
            void *src_kvaddr = page2kva(page);
            void *dst_kvaddr = page2kva(new_page);
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);

            // 更新页表，映射新页面
            if (page_insert(mm->pgdir, new_page, addr, perm) != 0) {
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }

            // 减少原页面的引用计数
            page_ref_dec(page);
        } else {
            // 页面是独占的，直接设置写权限
            *ptep |= PTE_W;
        }
    } else if (swap_init_ok) {
        // 页面交换逻辑
        struct Page *page = NULL;
        if (swap_in(mm, addr, &page) != 0) {
            cprintf("swap_in in do_pgfault failed\n");
            goto failed;
        }
        if (page_insert(mm->pgdir, page, addr, perm) != 0) {
            cprintf("page_insert in do_pgfault failed\n");
            goto failed;
        }
        swap_map_swappable(mm, addr, page, 1);
        page->pra_vaddr = addr;
    } else {
        cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
        goto failed;
    }

    ret = 0;
failed:
    return ret;
}

```
判断共享页面

使用 page_ref_count(page) 检查页面的引用计数，判断是否是共享页面。
如果共享页面被写入，执行 COW 操作。
COW 操作

分配新页面 alloc_page。
复制原页面内容到新页面 memcpy。
更新页表映射到新页面，并设置写权限。
状态变化

共享状态 → 独占状态：减少原页面的引用计数，为当前进程分配新页面。