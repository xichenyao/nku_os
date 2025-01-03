# lab6 进程调度

## 实验目的
理解操作系统的调度管理机制
熟悉 ucore 的系统调度器框架，以及缺省的Round-Robin 调度算法
基于调度器框架实现一个(Stride Scheduling)调度算法来替换缺省的调度算法

## 实验内容
在前两章中，我们已经分别实现了内核进程和用户进程，并且让他们正确运行了起来。同时我们也实现了一个简单的调度算法，FIFO调度算法，来对我们的进程进行调度,可通过阅读实验五下的 kern/schedule/sched.c 的 schedule 函数的实现来了解其FIFO调度策略。但是，单单如此就够了吗？显然，我们可以让ucore支持更加丰富的调度算法，从而满足各方面的调度需求。与实验五相比，实验六专门需要针对处理器调度框架和各种算法进行设计与实现，为此对ucore的调度部分进行了适当的修改，使得kern/schedule/sched.c 只实现调度器框架，而不再涉及具体的调度算法实现。而调度算法在单独的文件（default_sched.[ch]）中实现。

在本次实验中，我们在init/init.c中加入了对sched_init函数的调用。这个函数主要完成调度器和特定调度算法的绑定。初始化后，我们在调度函数中就可以使用相应的接口了。这也是在C语言环境下对于面向对象编程模式的一种模仿。这样之后，我们只需要关注于实现调度类的接口即可，操作系统也同样不关心调度类具体的实现，方便了新调度算法的开发。本次实验，主要是熟悉ucore的系统调度器框架，以及基于此框架的Round-Robin（RR） 调度算法。然后参考RR调度算法的实现，完成Stride调度算法。

## 练习
对实验报告的要求：

基于markdown格式来完成，以文本方式为主
填写各个基本练习中要求完成的报告内容
列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验
本实验依赖实验2/3/4/5。请把你做的实验2/3/4/5的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”“LAB5”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab6的测试应用程序，可能需对已完成的实验2/3/4/5的代码进行进一步改进。

## 练习1: 使用 Round Robin 调度算法（不需要编码）
完成练习0后，建议大家比较一下（可用kdiff3等文件比较软件）个人完成的lab5和练习0完成后的刚修改的lab6之间的区别，分析了解lab6采用RR调度算法后的执行过程。执行make grade，测试用例可以通过，但没有得分。

请在实验报告中完成：

时间片轮转（Round Robin，RR）调度算法的核心思想是将 CPU 时间按照固定时间片（time slice）分配给每个进程，进程执行时间片耗尽后，系统会重新调度下一个进程。进程执行结束后，它会被放回队列尾部，直到它的时间片再次到来。

下面分析上述代码中的 **RR 调度算法** 执行过程，包括每个步骤的执行逻辑：

### 1. **`RR_enqueue`**: 将进程添加到队列中
- **输入**: 一个进程 `proc` 和一个运行队列 `rq`。
- **执行过程**:
  - 通过 `assert(list_empty(&(proc->run_link)))` 检查进程 `proc` 是否已经在某个队列中（如果已在其他队列中，则无法重新加入）。
  - 使用 `list_add_before(&(rq->run_list), &(proc->run_link))` 将该进程 `proc` 插入到运行队列 `rq` 的头部。此时，进程进入就绪队列，等待被调度执行。
  - 接下来，算法会检查进程的时间片。如果进程的时间片为 `0` 或超过队列的最大时间片 `rq->max_time_slice`，则会将进程的时间片设置为队列的最大时间片（确保进程的时间片不会超过系统最大允许的时间片）。
  - 设置 `proc->rq = rq`，标记该进程属于哪个运行队列。
  - 最后，增加运行队列中进程的数量 `rq->proc_num++`。

#### **执行效果**:
- 当一个进程到来时，它被加入到调度队列中，排在队列的最前面，等待轮到它时执行。
- 每个进程都拥有固定的时间片 `time_slice`，它会在其时间片耗尽后重新入队，等待下次调度。

### 2. **`RR_dequeue`**: 从队列中移除进程
- **输入**: 一个运行队列 `rq` 和一个进程 `proc`。
- **执行过程**:
  - `assert(!list_empty(&(proc->run_link)) && proc->rq == rq)` 确保进程 `proc` 确实在队列中，并且它属于当前的队列 `rq`。
  - 使用 `list_del_init(&(proc->run_link))` 将进程 `proc` 从队列中删除，并初始化链表节点。
  - 最后，减少队列中的进程数量 `rq->proc_num--`。

#### **执行效果**:
- 当一个进程被调度执行完成后，或者进程被中断，需要退出队列时，就会被移除。
- 队列中的进程数量 `proc_num` 会减少。

### 3. **`RR_pick_next`**: 选择下一个调度的进程
- **输入**: 一个运行队列 `rq`。
- **执行过程**:
  - 通过 `list_next(&(rq->run_list))` 获取队列中的下一个进程（即当前队列头部的下一个元素）。
  - 如果队列非空（即 `le != &(rq->run_list)`），则返回下一个进程的 `proc`。
  - 如果队列为空，则返回 `NULL`，表示没有进程可供调度。

#### **执行效果**:
- 每次需要调度进程时，`RR_pick_next` 会从队列中选择一个进程。
- 如果队列非空，它会选择队列中的第一个进程进行调度。
- 选择的进程被调度执行后，它会消耗时间片。

### 4. **`RR_proc_tick`**: 时间片消耗
- **输入**: 一个运行队列 `rq` 和一个进程 `proc`。
- **执行过程**:
  - 每当时钟滴答（tick）时，`RR_proc_tick` 会被调用，检查进程 `proc` 的时间片 `time_slice` 是否大于 0。
  - 如果时间片大于 0，减少时间片 `proc->time_slice--`，即表示该进程正在消耗时间片。
  - 如果时间片耗尽（`proc->time_slice == 0`），则设置进程的 `need_resched` 标志为 1，表示该进程已用完时间片，调度器需要重新调度该进程。

#### **执行效果**:
- 该函数是一个时钟中断处理函数，确保每个进程的时间片被正确消耗。
- 当进程的时间片用完时，`need_resched` 被设置为 1，表示该进程已经完成本次调度，准备进入下一轮调度。

### 5. **调度器行为总结**
#### 进程加入队列：
- 当进程被加入调度队列时，`RR_enqueue` 会根据队列最大时间片设置其时间片，确保它有足够的时间进行计算。

#### 进程执行：
- 在调度过程中，进程的时间片每次被消耗，`RR_proc_tick` 会逐步减少时间片，当时间片耗尽时，`need_resched` 标志被设置，进程被标记为需要重新调度。

#### 进程重新调度：
- 当进程时间片耗尽时，`RR_pick_next` 会从队列中选择下一个进程进行调度。进程被调度执行时，如果它的时间片用完，将会被放回队列，等待下一次调度。

#### 队列管理：
- 进程的加入和退出通过 `RR_enqueue` 和 `RR_dequeue` 来管理。每次调度时，调度器都会根据队列的顺序来选择下一个进程。


**时间片轮转调度算法** 是一种简单且公平的调度算法，能够保证每个进程均匀地获得 CPU 时间。

在上述代码实现中，进程在时间片耗尽后被标记为 `need_resched = 1`，表示需要重新调度，保持了调度的循环性和公平性。



### 比较一个在lab5和lab6都有, 但是实现不同的函数, 说说为什么要做这个改动, 不做这个改动会出什么问题
提示: 如kern/schedule/sched.c里的函数。你也可以找个其他地方做了改动的函数。
请理解并分析sched_class中各个函数指针的用法，并描述ucore如何通过Round Robin算法来调度两个进程，并解释sched_class里的每个函数（函数指针）是怎么被调用的。

```c
struct sched_class {
      // the name of sched_class
      const char *name;
      // Init the run queue
      void (*init)(struct run_queue *rq);
      // put the proc into runqueue, and this function must be called with rq_lock
      void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
      // get the proc out runqueue, and this function must be called with rq_lock
      void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
      // choose the next runnable task
      struct proc_struct *(*pick_next)(struct run_queue *rq);
      // dealer of the time-tick
      void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
      /* for SMP support in the future
       *  load_balance
       *     void (*load_balance)(struct rq* rq);
       *  get some proc from this rq, used in load_balance,
       *  return value is the num of gotten proc
       *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
       */
  };
```

 `sched_class` 结构体描述了一个调度类的基本组成和接口。

### 1. **`name` 字段** (`const char *name`)
```c
19     const char *name;
```
- **类型**：`const char *`
- **作用**：该字段存储调度类的名字，例如 `"RR_scheduler"` 或 `"FCFS_scheduler"`，用来标识当前调度类的名称。
- **用途**：便于调试、日志记录或者用户查看当前使用的调度算法。

### 2. **`init` 字段** (`void (*init)(struct run_queue *rq)`)
```c
21     void (*init)(struct run_queue *rq);
```
- **类型**：`void (*init)(struct run_queue *rq)`
- **作用**：这是一个函数指针，指向一个函数，用来初始化运行队列（`run_queue`）。
- **用途**：初始化某种调度策略所需的数据结构和状态信息。在不同的调度类中，初始化操作可能会有所不同。
  - 比如，在轮转调度（Round Robin）中，可能需要初始化一个时间片（`time_slice`）。
  - 在优先级调度中，可能需要初始化优先级队列。

### 3. **`enqueue` 字段** (`void (*enqueue)(struct run_queue *rq, struct proc_struct *proc)`)
```c
23     void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
```
- **类型**：`void (*enqueue)(struct run_queue *rq, struct proc_struct *proc)`
- **作用**：这是一个函数指针，指向一个函数，用来将进程 `proc` 加入到运行队列 `rq` 中。
- **用途**：不同的调度类可能有不同的队列管理方式。在轮转调度中，进程可能被添加到队列尾部，而在优先级调度中，进程可能会根据优先级插入到特定的位置。

### 4. **`dequeue` 字段** (`void (*dequeue)(struct run_queue *rq, struct proc_struct *proc)`)
```c
25     void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
```
- **类型**：`void (*dequeue)(struct run_queue *rq, struct proc_struct *proc)`
- **作用**：这是一个函数指针，指向一个函数，用来从运行队列 `rq` 中移除进程 `proc`。
- **用途**：在进程完成执行、被中断、或者被抢占时，需要将其从队列中移除。
  - 在轮转调度中，进程可能会在时间片耗尽时被移出队列并重新加入队列。
  - 在优先级调度中，进程可能会根据优先级变化进行移除和重新排队。

### 5. **`pick_next` 字段** (`struct proc_struct *(*pick_next)(struct run_queue *rq)`)
```c
27     struct proc_struct *(*pick_next)(struct run_queue *rq);
```
- **类型**：`struct proc_struct *(*pick_next)(struct run_queue *rq)`
- **作用**：这是一个函数指针，指向一个函数，用来从运行队列中选择下一个可调度的进程。
- **用途**：调度算法的核心部分，不同的调度类选择下一个进程的方式不同。
  - 在时间片轮转（Round Robin）调度中，选择队列头部的进程进行调度。
  - 在优先级调度中，可能会选择优先级最高的进程进行调度。

### 6. **`proc_tick` 字段** (`void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc)`)
```c
29     void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
```
- **类型**：`void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc)`
- **作用**：这是一个函数指针，指向一个函数，用来处理每个时钟周期（tick）时的进程时间片管理。
- **用途**：每当时钟滴答时，调度器需要检查当前进程的时间片是否用尽，进而决定是否进行调度或者进程的状态转换。
  - 在时间片轮转调度中，每次时钟中断都会减少当前进程的时间片，若时间片耗尽，则将进程重新排队。

### 7. **未来的 SMP 支持**（多处理器支持）
```c
30     /* for SMP support in the future
31      *  load_balance
32      *     void (*load_balance)(struct rq* rq);
33      *  get some proc from this rq, used in load_balance,
34      *  return value is the num of gotten proc
35      *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
36      */
```
- **`load_balance` 字段** (`void (*load_balance)(struct rq* rq);`):
  - **作用**：用于多处理器系统中的负载均衡。通过检查各个 CPU 的负载情况，决定是否将进程从一个 CPU 的队列迁移到另一个 CPU 的队列，以便更均衡地分配负载。
- **`get_proc` 字段** (`int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);`):
  - **作用**：获取当前运行队列中的某些进程，以便在负载均衡时迁移进程。

这两个字段是为未来的 **对称多处理器（SMP）** 支持预留的功能，这意味着在有多个 CPU 或处理器的系统中，可能需要将进程从一个 CPU 迁移到另一个 CPU 来均衡各个处理器的负载。


```c
79 schedule(void) {
80     bool intr_flag;
81     struct proc_struct *next;
82     local_intr_save(intr_flag);
83     {
84         current->need_resched = 0;
85         if (current->state == PROC_RUNNABLE) {
86             sched_class_enqueue(current);
87         }
88         if ((next = sched_class_pick_next()) != NULL) {
89             sched_class_dequeue(next);
90         }
91         if (next == NULL) {
92             next = idleproc;
93         }
94         next->runs ++;
95         if (next != current) {
96             proc_run(next);
97         }
98     }
99     local_intr_restore(intr_flag);
100 }
```


 **第 80 行**：声明一个 `bool` 类型的变量 `intr_flag` 用于保存中断状态。
  
 **第 81 行**：声明一个指向 `struct proc_struct` 的指针 `next`，用于存储下一个将要调度的进程。

 **第 82 行**：调用 `local_intr_save(intr_flag)`，保存当前的中断状态，并禁止中断。这是为了确保调度过程中的一致性，防止中断打断调度操作。

 **第 83-98 行**：是调度的核心逻辑。

 **第 84 行**：清除当前进程的 `need_resched` 标志，表明当前进程不需要立即被抢占。
  
 **第 85-87 行**：如果当前进程的状态是 `PROC_RUNNABLE`（可调度的），调用 `sched_class_enqueue(current)` 将当前进程重新加入调度队列。如果当前进程尚未执行完其时间片（即仍然是可调度状态），它会被放回队列，准备再次执行。

 **第 88 行**：调用 `sched_class_pick_next()` 来选择下一个可调度的进程 `next`。如果返回的 `next` 不是 `NULL`，则说明找到了下一个要调度的进程。

 **第 89 行**：如果找到了下一个进程，则通过 `sched_class_dequeue(next)` 将其从队列中移除。

 **第 91-92 行**：如果没有找到合适的进程（即 `next == NULL`），则将 `next` 设置为 `idleproc`，即空闲进程。

 **第 94 行**：增加 `next` 进程的运行次数 `runs`。

 **第 95-96 行**：如果 `next` 进程不是当前进程 `current`，则通过 `proc_run(next)` 来启动 `next` 进程执行。

 **第 99 行**：恢复之前保存的中断状态，允许中断。

### `sched_class` 中各个函数指针的用法

在更改后的 `schedule` 函数中，调度器通过 `sched_class` 接口来执行调度操作。`sched_class` 是一个结构体，包含了多个函数指针，指向不同调度类（如 **Round Robin**）所需的操作。以下是对这些函数指针的详细解释。

1. **`sched_class_enqueue`** (`void (*enqueue)(struct run_queue *rq, struct proc_struct *proc)`)
   - **作用**：将当前进程 `current` 加入到调度队列中。
   - **解释**：这个函数的作用是在当前进程 `current` 的时间片还未用尽时，将其重新加入队列等待下次调度。在 **Round Robin** 调度算法中，进程执行一个时间片后通常会被放回队列中，等待下次调度。
   
2. **`sched_class_pick_next`** (`struct proc_struct *(*pick_next)(struct run_queue *rq)`)
   - **作用**：选择下一个可运行的进程。
   - **解释**：该函数从调度队列中选择下一个准备好运行的进程。在 **Round Robin** 算法中，这通常是队列中等待时间最短的进程，即排在队列最前面的进程。

3. **`sched_class_dequeue`** (`void (*dequeue)(struct run_queue *rq, struct proc_struct *proc)`)
   - **作用**：将选中的进程从调度队列中移除。
   - **解释**：当某个进程被选中执行时，`sched_class_dequeue` 会将它从调度队列中移除。对于 **Round Robin** 调度，进程会在执行完它的时间片后被从队列中移除。

### ucore 如何通过 Round Robin 调度两个进程

在 **Round Robin** 算法中，所有就绪的进程被放入一个循环队列中，系统按照时间片（`time_slice`）依次执行这些进程，时间片耗尽后进程会被移到队列尾部，等待下次调度。下面分析两个进程的调度过程：

1. **假设有两个进程 P1 和 P2**：
   - **初始化**：P1 和 P2 都进入就绪队列，并且它们的时间片被初始化为系统最大时间片。

2. **调度过程**：
   - **第一次调度**：
     - 调度器调用 `sched_class_pick_next()` 选择队列中第一个进程，假设是 P1。
     - P1 被选中执行，调用 `proc_run(P1)` 启动 P1。
     - P1 执行时，它的时间片开始减少。执行过程中，`sched_class_enqueue(P1)` 将 P1 放回队列，等待下次调度。
   
   - **第二次调度**：
     - P1 执行完时间片后，调度器再次调用 `sched_class_pick_next()`，此时队列中剩下 P2。
     - P2 被选中执行，调用 `proc_run(P2)` 启动 P2。
     - P2 执行时，`sched_class_enqueue(P2)` 将 P2 放回队列。

3. **轮换**：
   - 这个过程持续进行，P1 和 P2 在调度队列中轮流执行，时间片用尽后被移到队列尾部，直到所有进程执行完毕或被抢占。

### 关键函数指针的调用过程

1. **`sched_class_enqueue(current)`**：
   - 这个函数会将当前进程 `current`（如果它仍然是可调度的）放入调度队列中。这确保了 **Round Robin** 中的时间片管理，如果时间片没有用尽，进程会返回队列。

2. **`sched_class_pick_next()`**：
   - 调度器调用这个函数来选择下一个可执行的进程。在 **Round Robin** 算法中，通常是选择队列头部的进程，因为它们已经等待了较长时间。

3. **`sched_class_dequeue(next)`**：
   - 当 `next` 被选中作为下一个进程时，调度器会调用这个函数将 `next` 从队列中移除。



- **更改后的 `schedule` 函数** 通过 `sched_class` 提供的接口将调度过程抽象化，使得调度策略的修改和扩展更加方便。
- 在 **Round Robin** 算法中，进程被按照时间片轮流调度，每个进程完成时间片后被重新加入队列，等待下一次执行。
- `sched_class` 中的函数指针（如 `enqueue`、`pick_next`、`dequeue`）帮助完成调度队列的管理、进程选择和时间片管理等核心功能，保证了调度过程的灵活性和模块化。

在旧的 schedule 函数中，调度过程是硬编码的，具体的调度实现（如选择下一个进程、入队、出队等）都在函数内部完成。这种实现方式紧密耦合，调度算法的修改需要直接修改 schedule 函数的实现。
新函数通过 sched_class 结构体中的函数指针实现了调度策略的模块化。具体的调度操作（如入队、选择进程、出队）被封装成独立的函数指针，这使得调度器可以根据不同的调度算法动态切换调度策略，只需要替换 sched_class 中的函数指针即可。进行这个改动的主要目的是增强调度器的灵活性、扩展性和可维护性。

如果不改动的后果：
代码将继续耦合在一起，函数复杂度增加，维护和调试变得更加困难，开发者必须在庞大的函数体内查找问题，定位困难。
新的调度需求（例如优先级调度或多级队列调度）难以集成，因为修改会波及到 schedule 函数的各个部分。


## 练习2: 实现 Stride Scheduling 调度算法（需要编码）
首先需要换掉RR调度器的实现，即用default_sched_stride_c覆盖default_sched.c。然后根据此文件和后续文档对Stride度器的相关描述，完成Stride调度算法的实现。注意有“LAB6”的注释，主要是修改default_sched_swide_c中的内容。代码中所有需要完成的地方（challenge除外）都有“LAB6”和“YOUR CODE”的注释，请在提交时特别注意保持注释，并将“YOUR CODE”替换为自己的学号，并且将所有标有对应注释的部分填上正确的代码。

后面的实验文档部分给出了Stride调度算法的大体描述。这里给出Stride调度算法的一些相关的资料（目前网上中文的资料比较欠缺）。

strid-shed paper location
也可GOOGLE “Stride Scheduling” 来查找相关资料
执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。执行make qemu大致的显示输出见附录。

请在实验报告中简要说明如何设计实现”多级反馈队列调度算法“，给出概要设计，鼓励给出详细设计
简要证明/说明（不必特别严谨，但应当能够”说服你自己“），为什么Stride算法中，经过足够多的时间片之后，每个进程分配到的时间片数目和优先级成正比。(最后两题二选一做即可)
请在实验报告中简要说明你的设计实现过程。

rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);

`skew_heap_insert` 函数用于将元素插入到 `rq->lab6_run_pool` 中，`proc->lab6_run_pool` 是待插入的元素，而 `proc_stride_comp_f` 是用于比较堆元素的函数。为了更好地理解这行代码，我们可以逐个分析各个部分的功能。

### 1. **`rq->lab6_run_pool`**
   这是一个 **skew heap**（偏斜堆），用于存储与进程调度相关的某些数据结构。具体而言，`lab6_run_pool` 很可能是一个用于实现调度算法（例如 Stride Scheduling）所需要的堆结构。在这个结构中，堆元素将根据一定的优先级进行排列，以便调度器可以高效地选择下一个要运行的进程。

   - **skew heap** 是一种自适应堆数据结构，它具有以下特性：
     - 插入和删除操作的时间复杂度为对数级别（O(log n)）。
     - 它特别适用于需要频繁插入和删除的场景。

### 2. **`skew_heap_insert`**
   这是将元素插入到偏斜堆中的函数。该函数的参数包括：
   - `rq->lab6_run_pool`：表示当前的偏斜堆。
   - `&proc->lab6_run_pool`：待插入的元素（这里是指向进程 `proc` 的指针，特别是 `proc->lab6_run_pool`）。这应该是一个指向进程的特定数据结构，包含了该进程在调度中的相关信息（例如 stride 值等）。
   - `proc_stride_comp_f`：用于比较堆元素的函数，用来决定堆中元素的顺序。在这个上下文中，`proc_stride_comp_f` 可能是一个比较函数，用于比较进程的 **stride** 值，确保堆中的元素按 **stride** 值排序，优先级较高的进程排在前面。

### 3. **`proc->lab6_run_pool`**
   这是进程 `proc` 中与调度相关的一个数据结构，可能包含进程的 **stride** 值（用于 **stride scheduling** 算法），以及堆结构所需的其他信息。将它插入到 `skew_heap` 中后，调度器可以根据这些信息决定下一个要运行的进程。

### 4. **`proc_stride_comp_f`**
   这是一个比较函数，通常是一个返回整数值的函数，它决定了在堆中两个元素的优先级。对于两个进程 `proc1` 和 `proc2`，该函数会比较它们的 **stride** 值，并返回如下结果：
   - 如果 `proc1` 的 **stride** 值小于 `proc2` 的 **stride** 值，则返回一个负值，表示 `proc1` 的优先级更高。
   - 如果 `proc1` 的 **stride** 值大于 `proc2` 的 **stride** 值，则返回一个正值，表示 `proc2` 的优先级更高。
   - 如果两者相等，则返回零。

   该比较函数确保堆中的进程按照其 **stride** 值排序，优先级较高的进程将位于堆的顶部。

这行代码的作用是将当前进程（通过 `proc->lab6_run_pool` 指向的结构体）插入到调度池（`rq->lab6_run_pool`）中的偏斜堆中。插入过程中，使用 `proc_stride_comp_f` 作为比较函数，以保证堆中进程根据 **stride scheduling** 算法的优先级进行排序。

- **`rq->lab6_run_pool`**：调度器的偏斜堆，用于存储待调度的进程。
- **`&proc->lab6_run_pool`**：待插入堆的元素，包含该进程的调度信息。
- **`proc_stride_comp_f`**：用于比较堆元素的函数，确保按照进程的 **stride** 值对堆进行排序。

通过这种方式，调度器能够高效地选择下一个最优先的进程进行执行。

### 为什么Stride算法中，经过足够多的时间片之后，每个进程分配到的时间片数目和优先级成正比。

在 **Stride算法** 中，进程的时间片分配是基于每个进程的“步进值”（stride）和优先级来控制的。其核心思想是让高优先级的进程获得更多的时间片，从而实现公平的资源分配。

### 1. **Stride 算法的工作原理**

在 **Stride调度算法** 中，每个进程有一个“步进值”（stride），这个步进值由进程的优先级决定，通常是根据进程的优先级计算的。具体来说，步进值（`stride`）和进程的优先级成反比，优先级越高，步进值越小。

#### 步进值（`stride`）计算方式：
- 设定一个大常数 `BIG_STRIDE`，通常取值为最大整数值。
- 对于每个进程，步进值（stride）等于 `BIG_STRIDE` 除以该进程的优先级（priority）。即：  
  \[
  \text{stride} = \frac{\text{BIG\_STRIDE}}{\text{priority}}
  \]
  这样，优先级高的进程其步进值会更小，步进值小意味着该进程在调度时能够更快地到达调度条件（即每次分配时间片的间隔更短）。

### 2. **调度过程**

在每次调度时，系统会从当前有等待时间片的进程中，选择步进值最小的进程进行调度，这个进程就是优先级最高的进程。

- 每次调度时，进程的步进值会增加该进程的 `stride`（步进值）。例如，假设进程的步进值为 `stride`，在分配了一个时间片后，该进程的步进值将增加 `stride`。
- 在选择下一个运行的进程时，系统选择步进值最小的进程，即选择步进值增长最慢的进程。

### 3. **时间片分配与优先级的关系**

随着时间的推移，经过多个调度周期，进程的步进值会不断增加，但是步进值的增速是由进程的优先级决定的：

- **优先级高的进程**：优先级较高的进程（即其步进值较小）会更频繁地被选中执行，因为步进值的增长速度较慢。
- **优先级低的进程**：优先级较低的进程（即其步进值较大）则会比较少地被选中执行，因为其步进值的增长速度较快。

随着时间的推移，经过多个调度周期后，优先级高的进程分配到的时间片数就会相对更多，而优先级低的进程则会分配到较少的时间片。具体来说，经过足够多的时间片后，进程分配到的时间片数和其优先级（或步进值的倒数）成正比。这是因为：

- 优先级高的进程（步进值小）其步进值的增加速度较慢，意味着它能够较早地获得新的时间片。
- 优先级低的进程（步进值大）其步进值的增加速度较快，意味着它在调度中获得时间片的间隔更长。

### 4. **步进值与优先级的比例关系**

- 在一定时间后，每个进程获得的时间片数目（执行的次数）与其步进值的大小成反比。也就是说，步进值较小（优先级较高）的进程会获得更多的时间片。
- 因为步进值每次增加的量是固定的，而步进值越小，调度的频率就越高，所以经过足够多的时间片，优先级较高的进程相对于低优先级进程会获得更多的 CPU 时间。






## 扩展练习 Challenge 1 ：实现 Linux 的 CFS 调度算法
在ucore的调度器框架下实现下Linux的CFS调度算法。可阅读相关Linux内核书籍或查询网上资料，可了解CFS的细节，然后大致实现在ucore中。




#### 1. **CFS调度算法概述**
CFS（Completely Fair Scheduler）是一种公平的调度算法，旨在让每个进程获得尽可能公平的CPU时间。其核心概念基于 **虚拟运行时间（Virtual Runtime, vruntime）**，即进程实际执行的时间减去其优先级调整后的时间。

CFS的主要特点：
- **虚拟运行时间（vruntime）**：每个进程都有一个 `vruntime` 字段，它表示进程的相对运行时间。`vruntime` 越小的进程优先调度，意味着它已经运行的时间相对较少。
- **红黑树（Red-Black Tree）**：CFS 使用一个红黑树来维护所有可运行的进程，其中每个进程的节点根据 `vruntime` 排序。进程的调度顺序由 `vruntime` 决定，`vruntime` 最小的进程优先调度。
- **平滑的调度**：为了避免系统中的小进程不断争抢CPU，CFS采用了一种平滑的方式，通过调整 `vruntime` 来保持各进程的公平性。

#### 2. **CFS实现的基本步骤**

##### **步骤 1：为每个进程添加 `vruntime` 字段**
每个进程需要一个 `vruntime` 字段，用来记录该进程的虚拟运行时间。

```c
struct proc_struct {
    ...
    int64_t vruntime;  // 虚拟运行时间
    ...
};
```

##### **步骤 2：创建红黑树（RB Tree）**
使用红黑树（或类似的数据结构）来维护所有待调度的进程。每个进程的 `vruntime` 将作为其在红黑树中的排序依据。

可以定义一个 `runqueue`，其中包含红黑树和一个指向最小 `vruntime` 的指针。

```c
struct run_queue {
    struct rb_root run_list;   // 红黑树
    struct proc_struct *current; // 当前正在运行的进程
    ...
};
```

##### **步骤 3：选择下一个进程（pick_next）**
每次选择进程时，选择红黑树中 `vruntime` 最小的进程。具体实现时可以通过 `rb_first()` 函数选择。

```c
struct proc_struct* cfs_pick_next(struct run_queue *rq) {
    struct rb_node *node = rb_first(&rq->run_list);
    if (node) {
        struct proc_struct *next = container_of(node, struct proc_struct, run_link);
        return next;
    }
    return NULL;
}
```

##### **步骤 4：进程调度时更新 `vruntime`**
每次调度时，应该根据进程的运行时间来更新 `vruntime`。当进程运行时，`vruntime` 增加。对于 CFS，`vruntime` 还需要考虑进程的优先级，优先级高的进程 `vruntime` 增加得慢一些。

```c
void cfs_proc_tick(struct proc_struct *proc) {
    int64_t load_weight = proc->priority;  // 假设优先级越高，权重越大
    proc->vruntime += load_weight;
}
```

##### **步骤 5：插入和移除进程**
CFS 调度器还需要实现进程的插入和删除操作。当进程进入就绪队列时，需要将其插入到红黑树中；当进程退出时，应该从红黑树中移除。

```c
void cfs_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    rb_insert_color(&proc->run_link, &rq->run_list);
}

void cfs_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    rb_erase(&proc->run_link, &rq->run_list);
}
```



## 扩展练习 Challenge 2 ：在ucore上实现尽可能多的各种基本调度算法(FIFO, SJF,...)，并设计各种测试用例，能够定量地分析出各种调度算法在各种指标上的差异，说明调度算法的适用范围。



#### 1. **FIFO（先进先出）调度算法**
FIFO 是最简单的调度算法，按照进程到达的顺序进行调度。

```c
void fifo_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    list_add_before(&(rq->run_list), &(proc->run_link));
}

struct proc_struct* fifo_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);
    }
    return NULL;
}
```

#### 2. **SJF（最短作业优先）调度算法**
SJF 调度算法选择估计运行时间最短的进程。如果能够准确预测每个进程的执行时间，SJF 可以提供最短的平均等待时间。

```c
void sjf_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 插入时按估计的执行时间排序
}

struct proc_struct* sjf_pick_next(struct run_queue *rq) {
    // 选择估计运行时间最短的进程
}
```

#### 3. **其他调度算法**
- **RR（轮询调度）**：按时间片轮转，每个进程轮流获得 CPU 时间片。
- **优先级调度**：根据进程的优先级进行调度，优先级高的进程优先执行。


