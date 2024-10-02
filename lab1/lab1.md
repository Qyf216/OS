# lab0.5
## 练习1: 使用GDB验证启动流程
>为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？

在第一个终端中，运行 make debug 命令。这个命令会启动QEMU虚拟机，并加载内核镜像,同时，打开一个GDB监听端口1234，然后暂停执行，等待GDB的连接。

在第二个终端中，运行 make gdb 命令。这个命令会启动GDB，并尝试连接到QEMU监听的端口，一旦连接成功，GDB就会接管QEMU的执行，可以开始调试。

GDB启动之后，观察到：
```
Reading symbols from bin/kernel...
The target architecture is set to "riscv:rv64".
Remote debugging using localhost:1234
0x0000000000001000 in ?? ()
```
当前程序暂停在0x1000处，这与实验指导书中的内容对应：
QEMU模拟的这款riscv处理器的复位地址是0x1000，而不是0x80000000。所谓复位地址，指的是CPU在上电的时候，或者按下复位键的时候，PC被赋的初始值。

使用 `x/10i $pc` 显示即将执行的 10 条汇编令，如下所示：
```
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp
```
使用`si`进行单步调试，
- `0x1000: auipc t0, 0x0`：将当前PC值加上立即数0，然后存入寄存器t0。auipc用于生成32位的常量地址。
- `0x1004: addi a1, t0, 32`：将t0寄存器的值加上32，结果存入寄存器a1。
- `0x1008: csrr a0, mhartid`：从机器硬件线程ID寄存器（mhartid）读取值，存入寄存器a0。csrr用于读取控制和状态寄存器。
- `0x100c: ld t0, 24(t0)`：从t0寄存器指向的地址加上24的地址处加载一个字（32位）的数据，存入寄存器t0。
- `0x1010: jr t0`：跳转到t0寄存器指向的地址执行。

使用 `info r t0 `观察 t0 中的值,跳转指令中t0 中的数据为 0x80000000，这与实验指导书中的内容对应：
作为 bootloader 的 OpenSBI.bin 被加载到物理内存以物理地址 0x80000000 开头的区域上，同时内核镜像 os.bin 被加载到以物理地址 0x80200000 开头的区域上

总结：RISC-V 硬件加电后，将要执行的指令在地址 0x1000 到地址 0x1010 处，在 0x1010 处跳转到 0x80000000 执行 OpenSBI 程序。














# lab1
## 练习1：理解内核启动中的程序入口操作

>阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

根据实验指导书得知：在链接脚本里把程序的入口点定义为kern_entry, 在kern/init/entry.S编写一段汇编代码, 作为整个内核的入口点。现在这个入口点，作用就是分配好内核栈，然后跳转到kern_init, 看来这个kern_init才是我们真正的入口点。

1. `la`：加载地址，用于将某个标签的地址加载到寄存器，这里la加载 bootstacktop 的地址到栈指针（sp），初始化栈顶。这个操作的目的是将OpenSBI模拟出来的物理内存地址赋值给栈指针 ($sp)。这样设置使操作系统内核可以开始使用 bootstack 作为函数调用堆栈的底部，从而支持函数的执行和任务切换等操作。
   在操作系统启动时，栈指针sp被设置为指向内核栈的顶部，这样在执行函数调用时，栈就会从高地址向低地址增长。
2. `tail kern_init`：调用 kern_init 函数，并使用 tail 优化，表示函数调用后不会返回。这里使用了尾调用，指在一个函数的最后一步直接调用另一个函数。使用尾调用的一个主要好处是，可以避免增加新的栈帧，优化栈空间的使用：因为 kern_init 是在 kern_entry 函数的最后一步被调用的，程序可以重用当前的栈帧。
tail 关键字表示一旦 kern_init 被调用，控制权将转移到 kern_init，而不会返回到 kern_entry，也就是说，在入口点之后，直接进入了初始化函数。

## 练习2：完善中断处理 （需要编程）

>请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。
```
case IRQ_S_TIMER:
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   CODE :  */
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
            ticks++;
            if (ticks >= 100) {
		cprintf("100 ticks\n");  
		num++;  
		ticks = 0; 
	    }
	    if (num >= 10) {
		sbi_shutdown(); 
	    }

            break;
```


>要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

当发生 trap 时，CPU 通过中断处理程序来处理中断，中断程序位置由 stvec 指向。idt_init 函数初始化中断处理，将 __alltraps 设置为为中断处理函数。在 __alltraps 中，SAVE_ALL 宏保存所有相关的 CPU 寄存器和 CSR 到栈中，并调用 trap 函数来处理 trap。trap 函数接收 trap 帧指针并调用 trap_dispatch 来确定 trap 类型，对于中断类型的 trap，由 interrupt_handler 处理；对于异常类型的中断，由 exception_handler 处理。不同类型的 trap 有不同的操作。trap 处理完毕后，RESTORE_ALL 宏从堆栈中恢复先前保存的 CPU 状态，执行 sret 指令，恢复 sepc 和 sstatus，继续正常执行。


## Challenge1：描述与理解中断流程

>回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

在宏 SAVE_ALL 中，首先将当前栈指针 sp 保存到 sscratch 寄存器，以便后续追踪栈的状态。接着，栈指针向下移动 36 个寄存器的大小，以为保存寄存器的内容腾出空间。随后，代码依次将 x0 到 x31 的寄存器值存储到栈中，确保在异常处理期间这些寄存器的值不会丢失。同时，代码还获取并保存了状态寄存器 sstatus、异常程序计数器 sepc、导致异常的地址 sbadaddr 和异常原因 scause，以便在异常处理完成后能够恢复之前的状态。

在宏 RESTORE_ALL 中，首先从栈中恢复状态寄存器的值，然后依次恢复 x1 到 x31 的寄存器值，确保 CPU 状态的完整恢复。最后，栈指针被恢复到正确的位置，保证栈的正确性。

异常处理的入口点 __alltraps 被声明为全局符号，允许其他模块访问。在此处，调用 SAVE_ALL 宏以保存当前的 CPU 状态，并将栈指针传递给 trap 函数，以便处理具体的异常。完成异常处理后，代码进入返回处理部分 __trapret，在这里调用 RESTORE_ALL 宏以恢复之前保存的状态，并通过 sret 指令返回到异常发生前的执行状态，确保程序能够继续正常运行。

1. mov,a0,sp的目的：这条指令的意思是把当前的堆栈指针 sp 的值存到 a0 这个寄存器里。寄存器 a0 用于传递函数的第一个参数。这样做的目的是为了在处理异常或中断时，可以把当前的堆栈信息传给后续的处理函数（trap 函数）。当程序运行时，它会在“堆栈”上存储一些信息，比如局部变量和返回地址。如果发生了错误或需要处理中断，系统需要一个地方来保存这些信息，以便后续能恢复。通过将堆栈指针的值放入 a0，异常处理程序就能知道当时的堆栈在哪里，从而访问这些信息。

2. 在SAVE_ALL部分，通过 addi sp, sp, -36 * REGBYTES 分配了足够的栈空间，每个寄存器保存在栈中的位置是由宏内的指令顺序和偏移量决定，如STORE x0, 0*REGBYTES(sp)
   
3. 如果异常处理程序需要切换到一个不同的执行上下文，或者需要在处理完成后恢复到精确的指令继续执行，那么保存所有用户态寄存器是必要的。但是对于某些中断处理，可能只需要修改或使用特定的寄存器，对于这类中断，可以仅保存必要的寄存器，提高中断处理的效率，减少性能开销和资源浪费。
4. 
## Challenge2：理解上下文切换机制
>回答：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

1. csrw sscratch, sp 将当前栈顶指针 sp 写入sscratch中，起到一个传递上下文信息的作用，便于中断处理程序处理相关信息。
   csrrw s0, sscratch, x0 将 sscratch 中的当前值读入到寄存器 s0，同时将 x0（值为0）写入 sscratch，RISCV 不能直接从 CSR 写到内存, 需要 csrr 把 CSR 读取到通用寄存器，再从通用寄存器 STORE 到内存，这里将 sscratch 写入寄存器 s0 ，后续写入内存。在异常处理的上下文中，csrrw s0, sscratch, x0 通常用于在进入异常处理程序之前保存当前的栈指针。这样，如果在异常处理过程中再次发生异常，处理器可以知道它最初是从哪个模式（如用户模式或内核模式）进入异常的，从而正确地选择栈指针


2.  SAVE_ALL 中保存 scause、sbadaddr 等 CSR，是为了将这些相关的信息传递中断处理程序，这些信息在中断处理中使用，所以不需要还原



## Challenge3：完善异常中断
>编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

```
case CAUSE_ILLEGAL_INSTRUCTION:
    // 处理非法指令异常
    cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    cprintf("Exception type: Illegal instruction\n");
    tf->epc += 4;
case CAUSE_BREAKPOINT:
    // 处理中断异常
    cprintf("break caught at 0x%08x\n", tf->epc);
    cprintf("Exception type: breakpoint\n");
    tf->epc += 4;

```


