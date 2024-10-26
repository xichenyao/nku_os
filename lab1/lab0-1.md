# Lab0.5
##实验目的：
实验0.5主要讲解最小可执行内核和启动流程。我们的内核主要在 Qemu 模拟器上运行，它可以模拟一台 64 位 RISC-V 计算机。为了让我们的内核能够正确对接到 Qemu 模拟器上，需要了解 Qemu 模拟器的启动流程，还需要一些程序内存布局和编译流程（特别是链接）相关知识。
##实验内容：
实验0.5主要讲解最小可执行内核和启动流程。我们的内核主要在 Qemu 模拟器上运行，它可以模拟一台 64 位 RISC-V 计算机。为了让我们的内核能够正确对接到 Qemu 模拟器上，需要了解 Qemu 模拟器的启动流程，还需要一些程序内存布局和编译流程（特别是链接）相关知识,以及通过opensbi固件来通过服务。
##练习1: 使用GDB验证启动流程
为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

![Alt text](<picture/1.png>)

一些可能用到的 gdb 指令：
x/10i 0x80000000 : 显示 0x80000000 处的10条汇编指令。

![Alt text](<picture/2.png>)

x/10i $pc : 显示即将执行的10条汇编指令。
这段代码是使用RISC-V汇编语言编写的，下面是逐行解释：
0x1000: auipc t0,0x0 将当前PC值的高20位复制到t0。
0x1004: addi a1,t0,32指令将寄存器t0的值与立即数32相加，结果存入寄存器a1=0x1020。
0x1008: csrr a0,mhartid  csrr指令用于从控制和状态寄存器（CSR）读取值到寄存器a0。mhartid是CSR之一，用于获取当前硬件线程的ID。
0x100c: ld t0,24(t0) 从内存地址t0+24处加载一个64位的值到寄存器t0。
0x1010: jr t0 根据寄存器t0中的值跳转到对应的地址执行。这是一个间接跳转。
0x1014: unimp 通常用于指示未实现的功能。如果执行了这个指令，通常会触发异常。
0x1016: unimp 同上。
0x1018: unimp 同上。
0x101a: 0x8000 这是一个字节，通常在汇编代码中表示数据。
0x101c: unimp

![Alt text](<picture/3.png>)

单步调试寄存器信息。
为了分析从加电到执行应用程序的第一条指令，在0x80200000加断点，调试。

![Alt text](<picture/4.png>)

la（Load Address）指令将标签bootstacktop的地址加载到寄存器sp中。sp是栈指针寄存器，用于指向当前栈的顶部。内核镜像os.bin被加载到0x80200000开头的区域。

![Alt text](<picture/5.png>)

Make debug有了opensbi的输出。

#Lab1
##实验目的：
实验1主要讲解的是中断处理机制。操作系统是计算机系统的监管者，必须能对计算机系统状态的突发变化做出反应，这些系统状态可能是程序执行出现异常，或者是突发的外设请求。当计算机系统遇到突发情况时，不得不停止当前的正常工作，应急响应一下，这是需要操作系统来接管，并跳转到对应处理函数进行处理，处理结束后再回到原来的地方继续执行指令。这个过程就是中断处理过程。
##实验内容：
实验1主要讲解的是中断处理机制。通过本章的学习，我们了解了 riscv 的中断处理机制、相关寄存器与指令。我们知道在中断前后需要恢复上下文环境，用 一个名为中断帧（TrapFrame）的结构体存储了要保存的各寄存器，并用了很大篇幅解释如何通过精巧的汇编代码实现上下文环境保存与恢复机制。最终，我们通过处理断点和时钟中断验证了我们正确实现了中断机制。
##练习1：理解内核启动中的程序入口操作
阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

1）初始化栈指针来进行函数调用等操作。

2）tail 用于实现函数的尾部调用优化。尾部调用是指在函数的末尾调用另一个函数，并且不再返回到当前函数。这种调用方式可以避免额外的栈帧分配，从而节省栈空间。
kern_init指向内核初始化函数的入口点。这条指令的目的是跳转到 kern_init函数执行内核初始化。由于 tail 指令的特性，当前函数的返回地址会被替换为 kern_init 的返回地址，这样在 kern_init 执行完毕后，可以直接返回到调用的地方，而不需要额外的栈帧。
为内核的启动做了准备。
##练习2：完善中断处理 （需要编程）
请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

![Alt text](<picture/6.png>)

![Alt text](<picture/7.png>)

![Alt text](<picture/8.png>)

##扩展练习 Challenge1：描述与理解中断流程
回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。
在 uCore OS 中处理中断和异常的流程大致如下：

1）当异常发生时，硬件会自动触发一个中断信号，硬件会响应这个信号，暂停当前程序的执行，保存当前的状态（如程序计数器、寄存器状态等）。根据中断向量查找中断描述符表（IDT），跳转到对应的中断处理函数入口。在 uCore 中，所有中断和异常的处理入口都是_alltraps。在这个入口点，首先通过 SAVE_ALL宏将所有寄存器的值保存到栈中。这一步是为了保证在中断处理过程中能够保存和恢复中断发生时的上下文环境。通过 mov a0, sp 将栈顶地址（即保存所有寄存器值的地址）传递给中断处理函数trap（）。这样做的目的是为了让处理函数能够访问到中断发生时的上下文信息。执行具体的中断处理逻辑。处理完成后，通过 _trapret 标签中的 RESTORE_ALL 宏来恢复之前保存的寄存器值，继续执行被中断的指令。

2）mov a0, sp是为了将当前的栈指针（即包含所有寄存器状态的栈帧的顶部）的地址传递给中断处理函数，以便在处理函数中能够访问和恢复中断前的上下文环境。
SAVE_ALL 中寄存器保存在栈中的位置是由汇编宏 SAVE_ALL 和 RESTORE_ALL 确定的，它们定义了保存和恢复寄存器的顺序和位置。

3）对于任何中断，_alltraps中需要保存所有寄存器，因为在中断处理期间可能会修改这些寄存器的值。为了确保中断处理完成后能够正确地恢复被中断的程序的执行，必须保存和恢复这些寄存器的值。此外，如果中断处理需要调用其他函数，也需要保证这些函数的调用约定不会影响到中断返回后的状态。
##扩增练习 Challenge2：理解上下文切换机制
回答：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

1）csrw sscratch, sp：这条指令将当前栈指针的值写入到 sscratch 寄存器中。sscratch 是一个系统寄存器，在 RISC-V 中用于保存临时数据，这里用于保存中断发生前的栈指针，以便后续恢复。这个操作的目的是为了在中断发生时，保存当前的栈指针，因为在中断处理程序中可能会切换栈，所以需要记住原来栈的位置。
csrrw s0, sscratch, x0：这条指令执行了一个读取-修改-写入操作。首先将sscratch 寄存器的值读取到通用寄存器s0中，然后将x0写入sscratch寄存器。这用于在中断发生时清除sscratch寄存器，确保它不会影响后续操作。

2）SAVE_ALL中保存了 stval 和 scause 这些CSR，而在 RESTORE_ALL 中不恢复的原因是：
stval（它会记录一些中断处理所需要的辅助信息，比如指令获取(instruction fetch)、访存、缺页异常，它会把发生问题的目标地址或者出错的指令记录下来，这样我们在中断处理程序中就知道处理目标了）会从 sepc（它会记录触发中断的那条指令的地址） 寄存器指定的地址继续执行。
scause（它会记录中断发生的原因，还会记录该中断是不是一个外部中断）因为处理器需要知道异常已经处理完毕，并且可以安全地恢复程序的执行。
保存这些 CSR 的意义在于能够提供给中断处理程序足够的信息来正确地处理中断，并在处理完成后恢复处理器的状态。即使某些寄存器的值在RESTORE_ALL中不恢复，它们在中断处理的调试和错误报告仍然有用。
##扩展练习Challenge3：完善异常中断
编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

![Alt text](<picture/11.png>)

![Alt text](<picture/9.png>)

注：断点异常的时候+2个字节是因为breakpoint是个短指令。

输出：

![Alt text](<picture/10.png>)