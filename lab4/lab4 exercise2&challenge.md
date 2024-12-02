## exercise3：编写proc_run函数

`proc_run()`函数的作用是保存当前进程`current`的执行现场，恢复新进程的执行现场，完成进程切换。具体流程如下：

1. 将当前运行的进程设置为要切换过去的进程
2. 将页表换成新进程的页表
3. 使用`switch_to()`切换到新进程

### 1. local_intr_save()

首先，要确保在调度函数执行期间，不会被中断打断，可以调用`local_intr_save()`函数，函数原型如下：

```c
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
```

其中调用了一个函数`__intr_save()`，函数原型如下：

```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
```

其中又调用了一个函数`intr_disable()`，函数原型如下：

```c
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
```

从如上代码看出，函数 `intr_disable()` 通过清除 `sstatus` 寄存器中的 `SIE` 位来实现中断的禁用。

于是可以往前推出`__intr_save()`函数的作用是读取并保存当前中断状态，并在读取前将中断禁用。具体实现如下：

1. 通过 `read_csr(sstatus)` 读取控制和状态寄存器 `sstatus` 的值，并使用按位与操作符 `&` 与 `SSTATUS_SIE` 进行位运算
2. 如果 `read_csr(sstatus) & SSTATUS_SIE` 的结果为真，即当前的中断使能位为 1，中断是允许的。于是调用 `intr_disable()` 函数来禁用中断以确保函数运行期间不会被中断。
3. 如果返回为0的话，表示当前中断已经被禁用。
4. 该函数返回值标识了当前中断在被禁用前是否处于使能状态：返回值为1表示禁用前当前中断处于使能状态；为0表示禁用前当前状态处于禁止状态。

再往前推的话可以得出`local_intr_save(x)`的作用是禁用中断。其中`do { ... } while (0)` 结构通常被用作宏的包裹结构，为了确保在使用宏时，不会因为宏的展开而导致语法错误。

于是可以得到如下代码：

```c
local_intr_save(intr_flag);
```

其中`intr_flag`是定义的`bool`值，用于标识当前中断在被禁用前是否处于使能状态。

### 2. 切换当前运行的进程

在禁用中断后，可以开始进程进程的切换了。此时要找两个参数：

- 当前运行的进程
- 要切换的进程

要切换的进程很好找，`proc_run()`函数的参数是`struct proc_struct *proc`，即我们要找的切换过去的进程控制块指针

至于当前运行的进程，`ucore`定义了一个全局变量`current`，存储当前占用CPU且处于“运行”状态进程控制块指针。

至此，两个需要的参数都找到了，将当前运行的进程指向要切换的进程即可，代码如下：

```c
	struct proc_struct *prev = current; 
	struct proc_struct *next = proc;
	current = proc;
```

### 3. 将页表换成新进程的页表

需要将页表换成新进程的页表，该页表信息肯定在进程控制块中可以找到，于是找到进程控制块`proc_struct`的定义如下：

```c
struct proc_struct {
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
```

其中有个成员变量`cr3`表示`CR3`寄存器的值，即页目录表的基地址，标识进程的地址空间。

于是我们只需要将页表指向要切换到的进程的进程控制块的`cr3`即可。

使用函数`lcr3()`，函数原型如下：

```c
static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
}
```

该函数用于设置当前进程的页表基址，传递的参数即为需要设置的页表基址，于是”将页表切换到新进程的页表“这一部分代码如下：

```c
lcr3(next->cr3);
```

### 4. 使用switch_to切换到新进程

目前，已经实现了”当前进程指针指向了要切换的进程指针“和”将页表换成新进程的页表“这两项准备工作，最后调用`switch_to()`函数切换到新进程即可，依旧是先看函数原型：

```asm
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
    STORE sp, 1*REGBYTES(a0)
    STORE s0, 2*REGBYTES(a0)
    STORE s1, 3*REGBYTES(a0)
    STORE s2, 4*REGBYTES(a0)
    STORE s3, 5*REGBYTES(a0)
    STORE s4, 6*REGBYTES(a0)
    STORE s5, 7*REGBYTES(a0)
    STORE s6, 8*REGBYTES(a0)
    STORE s7, 9*REGBYTES(a0)
    STORE s8, 10*REGBYTES(a0)
    STORE s9, 11*REGBYTES(a0)
    STORE s10, 12*REGBYTES(a0)
    STORE s11, 13*REGBYTES(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
    LOAD sp, 1*REGBYTES(a1)
    LOAD s0, 2*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a1)
    LOAD s2, 4*REGBYTES(a1)
    LOAD s3, 5*REGBYTES(a1)
    LOAD s4, 6*REGBYTES(a1)
    LOAD s5, 7*REGBYTES(a1)
    LOAD s6, 8*REGBYTES(a1)
    LOAD s7, 9*REGBYTES(a1)
    LOAD s8, 10*REGBYTES(a1)
    LOAD s9, 11*REGBYTES(a1)
    LOAD s10, 12*REGBYTES(a1)
    LOAD s11, 13*REGBYTES(a1)

    ret
```

它使用汇编语言编写的函数，主要执行两个操作：

- 使用STORE保存当前进程（from）的寄存器状态
- 使用LOAD恢复即将执行的进程（to）的寄存器状态

函数参数是进程控制块指针，于是我们可以得到如下代码：

```c
switch_to(&(prev->context), &(next->context));
```

### 5. local_intr_restore()

最后，在函数结束前，需要调用`local_intr_restore()`函数恢复中断。函数原型如下：

```c
#define local_intr_restore(x) __intr_restore(x);
```

其中调用了一个函数`__intr_restore()`，函数原型如下：

```c
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
```

其中又调用了一个函数`intr_enable()`，函数原型如下：

```c
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
```

从如上代码看出，函数 `intr_enable()` 通过设置 `sstatus` 寄存器中的 `SIE `位来实现中断的恢复。

于是可以往前推出`__intr_restore()`函数的作用是根据传入的参数值来恢复中断状态。具体实现如下：

1. 如果传入的参数值flag为真，则调用 `intr_enable()` 函数启用中断
2. 如果 `flag` 的值为假，则不进行任何操作，即不恢复中断

再往前推的话可以得出`local_intr_save(x)`的作用是根据传入的x的值恢复中断。

于是可以得到如下代码：

```c
local_intr_restore(intr_flag);
```

`intr_flag`为之前在`local_intr_save()`中使用的参数，调用后被赋值，表示当前中断在被禁用前是否处于使能状态，此时作为参数传入`local_intr_restore()`，可以判断是否恢复中断。

### 6. 总结

#### proc_run()函数实现

```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current; 
        //用于标识当前进程的进程控制块
        struct proc_struct *next = proc;
        //用于标识要切换的进程的进程控制块
        local_intr_save(intr_flag);
        //确保在调度函数执行期间，不会被中断打断
        {
            current = proc;
            //将当前运行的进程设置为要切换过去的进程
            lcr3(next->cr3);
            //将页表换成新进程的页表
            switch_to(&(prev->context), &(next->context));
            //使用switch_to切换到新进程
        }
        local_intr_restore(intr_flag);
        //恢复中断
    }
}
```

#### 思考

Q：在本实验的执行过程中，创建且运行了几个内核线程？

A：创建并运行了两个线程。

1. idleproc：第0个内核进程
   - 用于表示空闲进程，主要目的是在系统没有其他任务要执行的时候，占用CPU时间，同时便于进程调度的统一化。
   - 完成内核中各个子系统的初始化，之后立即执行调度`schedule()`，执行其他进程。

2. initproc：第1个内核进程

   - 从`kernel_thread_entry`开始执行

   - 完成其他工作

## challenge

Q：说明语句`local_intr_save(intr_flag);`和`local_intr_restore(intr_flag);` 是如何实现开关中断的？

A：具体分析在exercise3中有提及。

## 相关知识点
* 内核线程是一种特殊的进程，内核线程与用户进程的区别有两个：内核线程只运行在内核态，而用户进程会在在用户态和内核态交替运行；所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间，而用户进程需要维护各自的用户内存空间。  
* 进程与程序的区别
  * 程序是静态的实体，进程是动态的实体。
  * 程序是存储在某种介质上的二进制代码，进程对应了程序的执行过程，系统不需要为一个不执行的程序创建进程，一旦进程被创建，就处于不断变化的动态过程中，对应了一个不断变化的上下文环境。
  * 程序是永久的，进程是暂时存在的。程序的永久性是相对于进程而言的，只要不去删除它，它可以永久的存储在介质当中。
* 进程与程序的联系  
  * 进程是程序的一次执行，进程和程序并不是一一对应的。同一个程序可以在不同的数据集合上运行，因而构成若干个不同的进程。几个进程能并发地执行相同的程序代码，而同一个进程能顺序地执行几个程序。
* 进程的状态
  * 创建状态：进程在创建时需要申请一个空白PCB，向其中填写控制和管理进程的信息，完成资源分配。如果创建工作无法完成，比如资源无法满足，就无法被调度运行，把此时进程所处状态称为创建状态
  * 就绪状态：进程已经准备好，已分配到所需资源，只要分配到CPU就能够立即运行
  * 执行状态：进程处于就绪状态被调度后，进程进入执行状态
  * 阻塞状态：正在执行的进程由于某些事件（I/O请求，申请缓存区失败）而暂时无法运行，进程受到阻塞。在满足请求时进入就绪状态等待系统调用
  * 终止状态：进程结束，或出现错误，或被系统终止，进入终止状态。无法再执行  

  本次实验中进程状态结构体中的状态有：PROC_UNINIT = 0，未初始化状态、PROC_SLEEPING，睡眠（阻塞）状态、PROC_RUNNABLE，运行与就绪态、PROC_ZOMBIE，僵死状态。  
* init_proc线程的整个生命周期  
  1. 通过kernel_thread函数，构造一个临时的trap_frame栈帧，其中设置了cs指向内核代码段选择子、ds/es/ss等指向内核的数据段选择子。令中断栈帧中的tf_regs.ebx、tf_regs.edx保存参数fn和arg，tf_eip指向kernel_thread_entry。
  2. 通过do_fork分配一个未初始化的线程控制块proc_struct，设置并初始化其一系列状态。将init_proc加入ucore的就绪队列，等待CPU调度。
  3. 通过copy_thread中设置用户态线程/内核态进程通用的中断栈帧数据，设置线程上下文struct context中eip、esp的值，令上下文切换switch返回后跳转到forkret处。
  4. idle_proc在cpu_idle中触发schedule，将init_proc线程从就绪队列中取出，执行switch_to进行idle_proc和init_proc的context线程上下文的切换。
  5. switch_to返回时，CPU开始执行init_proc的执行流，跳转至之前构造好的forkret处。
  6. fork_ret中，进行中断返回。将之前存放在内核栈中的中断栈帧中的数据依次弹出，最后跳转至kernel_thread_entry处。
  7. kernel_thread_entry中，利用之前在中断栈中设置好的ebx(fn)，edx(arg)执行真正的init_proc业务逻辑的处理(init_main函数)，在init_main返回后，跳转至do_exit终止退出。

* 一个进程可以对应一个线程，也可以对应很多线程。这些线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体（因为操作系统分配网络等资源时往往是基于进程的），这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能。
* 寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。因为线程切换在一个函数当中，所以编译器会自动帮助我们生成保存和恢复调用者保存寄存器的代码，在实际的进程切换过程中我们只需要保存被调用者保存寄存器。