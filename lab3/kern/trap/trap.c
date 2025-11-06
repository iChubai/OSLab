/* ======================================================================================
 * trap.c - 中断和异常处理的核心逻辑
 *
 * 本文件实现了RISC-V架构下的中断和异常处理机制，包括：
 * 1. 中断描述符表的初始化 (idt_init)
 * 2. Trap Frame的打印和调试功能
 * 3. 各种中断和异常的处理函数
 * 4. 主trap分发函数
 *
 * RISC-V中断和异常处理的基本概念：
 * - 中断(Interrupt): 异步事件，由外部硬件触发，CPU可以选择是否响应
 * - 异常(Exception): 同步事件，由CPU执行指令时发生，必须立即处理
 * - Trap: 中断和异常的统称
 * - Trap Frame: 保存被中断程序的上下文信息的数据结构
 * ====================================================================================== */

#include <assert.h>
#include <clock.h>          // 时钟中断相关
#include <console.h>        // 控制台I/O
#include <defs.h>           // 基本类型定义
#include <kdebug.h>         // 内核调试功能
#include <memlayout.h>      // 内存布局定义
#include <mmu.h>            // 内存管理单元定义
#include <riscv.h>          // RISC-V特有定义和CSR操作
#include <stdio.h>          // 标准I/O
#include <trap.h>           // Trap处理相关定义
#include <sbi.h>            // SBI 接口（sbi_shutdown 等）

/* TICK_NUM - 时钟中断计数器的最大值
 * 当ticks达到这个值时，会输出提示信息并在调试模式下终止程序
 * 这个常量的作用是控制系统运行的时间，用于测试和评分 */
#define TICK_NUM 100

/* print_ticks - 打印时钟tick信息
 * 当时钟中断累计达到TICK_NUM次时调用此函数
 * 功能：
 * 1. 输出累计的tick数
 * 2. 在调试模式下输出结束信息
 * 3. 调用panic终止程序（用于测试评分）
 */
static void print_ticks() {
    // 输出累计的时钟tick数
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    // 在评分调试模式下，输出测试结束信息
    cprintf("End of Test.\n");
    // 调用panic终止程序，表示测试成功完成
    panic("EOT: kernel seems ok.");
#endif
}

/* ======================================================================================
 * idt_init - 初始化中断描述符表(IDT)和异常向量
 *
 * 在RISC-V中，没有传统意义上的IDT（中断描述符表），而是通过设置CSR寄存器来处理：
 * - stvec (Supervisor Trap Vector): 设置异常/中断处理程序的入口地址
 * - sscratch: 保存内核栈指针或标记当前执行模式
 *
 * RISC-V异常处理流程：
 * 1. 异常/中断发生时，硬件自动保存当前PC到sepc，设置scause等
 * 2. 跳转到stvec指向的地址开始执行
 * 3. 软件保存上下文（trapentry.S中的__alltraps）
 * 4. 调用C语言的trap处理函数
 * 5. 处理完成后恢复上下文并返回（trapentry.S中的__trapret）
 * ====================================================================================== */
void idt_init(void) {
    /* LAB3 2311671 : STEP 2 */
    /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
     *     All ISR's entry addrs are stored in __vectors. where is uintptr_t
     * __vectors[] ?
     *     __vectors[] is in kern/trap/vector.S which is produced by
     * tools/vector.c
     *     (try "make" command in lab3, then you will find vector.S in kern/trap
     * DIR)
     *     You can use  "extern uintptr_t __vectors[];" to define this extern
     * variable which will be used later.
     * (2) Now you should setup the entries of ISR in Interrupt Description
     * Table (IDT).
     *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE
     * macro to setup each item of IDT
     * (3) After setup the contents of IDT, you will let CPU know where is the
     * IDT by using 'lidt' instruction.
     *     You don't know the meaning of this instruction? just google it! and
     * check the libs/x86.h to know more.
     *     Notice: the argument of lidt is idt_pd. try to find it!
     */
    /* LAB3 任务要求：设置中断处理向量 */

    /* 声明外部符号__alltraps
     * __alltraps是trapentry.S中定义的异常入口点
     * 这个函数负责保存所有通用寄存器和CSR，设置新的栈指针
     */
    extern void __alltraps(void);

    /* 设置sscratch寄存器为0
     * sscratch (Supervisor Scratch Register)的作用：
     * - 在用户态：保存内核栈指针（用于异常时切换到内核栈）
     * - 在内核态：设置为0，表示当前已经在内核模式
     * 这里设置为0告诉异常向量程序当前正在内核态执行
     */
    write_csr(sscratch, 0);

    /* 设置异常向量地址到stvec寄存器
     * stvec (Supervisor Trap Vector)寄存器：
     * - 低位：异常处理函数的地址
     * - 高位：向量模式设置（这里使用直接模式）
     * 当异常发生时，硬件会跳转到stvec指向的地址开始执行
     */
    write_csr(stvec, &__alltraps);
}

/* ======================================================================================
 * trap_in_kernel - 检查trap是否发生在内核模式
 *
 * 通过检查sstatus寄存器的SPP位来判断中断/异常发生时的特权级别
 * SPP (Supervisor Previous Privilege)位：
 * - 0: 上一个模式是用户态
 * - 1: 上一个模式是监管者态（内核态）
 *
 * 返回值：true表示在内核态发生，false表示在用户态发生
 * ====================================================================================== */
bool trap_in_kernel(struct trapframe *tf) {
    /* 检查sstatus的SPP位
     * SSTATUS_SPP是定义在riscv.h中的常量，表示SPP位的掩码
     * 如果SPP位不为0，说明trap发生在内核态
     */
    return (tf->status & SSTATUS_SPP) != 0;
}

/* ======================================================================================
 * print_trapframe - 打印trap frame的详细信息
 *
 * 用于调试目的，显示当前trap发生时的完整状态信息
 * 包括所有通用寄存器、CSR状态和异常相关信息
 * ====================================================================================== */
void print_trapframe(struct trapframe *tf) {
    // 打印trap frame结构体的地址
    cprintf("trapframe at %p\n", tf);

    // 打印所有通用寄存器（通过调用print_regs函数）
    print_regs(&tf->gpr);

    // 打印重要的CSR寄存器值
    cprintf("  status   0x%08x\n", tf->status);    // sstatus: 状态寄存器
    cprintf("  epc      0x%08x\n", tf->epc);       // sepc: 异常程序计数器
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);  // sbadaddr: 坏地址（用于地址异常）
    cprintf("  cause    0x%08x\n", tf->cause);     // scause: 异常原因
}

/* ======================================================================================
 * print_regs - 打印所有RISC-V通用寄存器
 *
 * 按照RISC-V ABI（应用程序二进制接口）定义的寄存器名称打印
 * RISC-V有32个通用寄存器（x0-x31），但x0总是0
 * 寄存器分类：
 * - zero(x0): 硬连线为0
 * - ra(x1): 返回地址
 * - sp(x2): 栈指针
 * - gp(x3): 全局指针
 * - tp(x4): 线程指针
 * - t0-t6(x5-x7,x28-x31): 临时寄存器
 * - s0-s11(x8-x9,x18-x27): 保存寄存器
 * - a0-a7(x10-x17): 函数参数/返回值
 * ====================================================================================== */
void print_regs(struct pushregs *gpr) {
    // x0 (zero) - 硬连线为0，不可修改
    cprintf("  zero     0x%08x\n", gpr->zero);

    // x1 (ra) - 返回地址，保存函数返回位置
    cprintf("  ra       0x%08x\n", gpr->ra);

    // x2 (sp) - 栈指针，指向当前栈顶
    cprintf("  sp       0x%08x\n", gpr->sp);

    // x3 (gp) - 全局指针，用于访问全局变量
    cprintf("  gp       0x%08x\n", gpr->gp);

    // x4 (tp) - 线程指针，用于线程本地存储
    cprintf("  tp       0x%08x\n", gpr->tp);

    // 临时寄存器 t0-t2 (x5-x7) - 不需要跨函数调用保存
    cprintf("  t0       0x%08x\n", gpr->t0);
    cprintf("  t1       0x%08x\n", gpr->t1);
    cprintf("  t2       0x%08x\n", gpr->t2);

    // 保存寄存器 s0-s1 (x8-x9) - 需要保存/恢复的寄存器
    cprintf("  s0       0x%08x\n", gpr->s0);
    cprintf("  s1       0x%08x\n", gpr->s1);

    // 参数/返回值寄存器 a0-a7 (x10-x17)
    cprintf("  a0       0x%08x\n", gpr->a0);
    cprintf("  a1       0x%08x\n", gpr->a1);
    cprintf("  a2       0x%08x\n", gpr->a2);
    cprintf("  a3       0x%08x\n", gpr->a3);
    cprintf("  a4       0x%08x\n", gpr->a4);
    cprintf("  a5       0x%08x\n", gpr->a5);
    cprintf("  a6       0x%08x\n", gpr->a6);
    cprintf("  a7       0x%08x\n", gpr->a7);

    // 保存寄存器 s2-s11 (x18-x27)
    cprintf("  s2       0x%08x\n", gpr->s2);
    cprintf("  s3       0x%08x\n", gpr->s3);
    cprintf("  s4       0x%08x\n", gpr->s4);
    cprintf("  s5       0x%08x\n", gpr->s5);
    cprintf("  s6       0x%08x\n", gpr->s6);
    cprintf("  s7       0x%08x\n", gpr->s7);
    cprintf("  s8       0x%08x\n", gpr->s8);
    cprintf("  s9       0x%08x\n", gpr->s9);
    cprintf("  s10      0x%08x\n", gpr->s10);
    cprintf("  s11      0x%08x\n", gpr->s11);

    // 临时寄存器 t3-t6 (x28-x31)
    cprintf("  t3       0x%08x\n", gpr->t3);
    cprintf("  t4       0x%08x\n", gpr->t4);
    cprintf("  t5       0x%08x\n", gpr->t5);
    cprintf("  t6       0x%08x\n", gpr->t6);
}

/* ======================================================================================
 * interrupt_handler - 中断处理函数
 *
 * 处理各种异步中断事件。在RISC-V中，中断是通过设置scause的最高位来表示的
 * scause最高位为1表示中断，为0表示异常
 *
 * RISC-V中断类型：
 * 1. 软件中断(Software Interrupt): 由软件触发，用于进程间通信
 * 2. 时钟中断(Timer Interrupt): 由定时器触发，用于系统时钟
 * 3. 外部中断(External Interrupt): 由外部设备触发，如键盘、磁盘等
 *
 * 特权级：
 * - U: User mode (用户态)
 * - S: Supervisor mode (监管者态/内核态)
 * - H: Hypervisor mode (虚拟机管理器态)
 * - M: Machine mode (机器态)
 * ====================================================================================== */
void interrupt_handler(struct trapframe *tf) {
    /* 提取中断原因码
     * scause寄存器的格式：
     * - 最高位(bit 63): 1表示中断，0表示异常
     * - 低位(bits 62:0): 具体的中断或异常编号
     *
     * 这里通过左移1位再右移1位来清除最高位，获取具体的中断编号
     * 这是一个常见的技巧来提取低位字段
     */
    intptr_t cause = (tf->cause << 1) >> 1;

    /* 根据中断原因进行分发处理 */
    switch (cause) {
        case IRQ_U_SOFT:
            /* 用户态软件中断
             * 通常由用户程序通过写sip寄存器触发
             * 用于用户态进程间通信或系统调用
             */
            cprintf("User software interrupt\n");
            break;

        case IRQ_S_SOFT:
            /* 监管者态软件中断
             * 由内核通过写sip寄存器触发
             * 用于内核内部的进程调度或同步
             */
            cprintf("Supervisor software interrupt\n");
            break;

        case IRQ_H_SOFT:
            /* 虚拟机管理器软件中断
             * 用于虚拟化环境下的软件中断
             */
            cprintf("Hypervisor software interrupt\n");
            break;

        case IRQ_M_SOFT:
            /* 机器态软件中断
             * 由机器态软件触发，最高特权级别的软件中断
             */
            cprintf("Machine software interrupt\n");
            break;

        case IRQ_U_TIMER:
            /* 用户态时钟中断
             * 用户程序设置的用户态定时器到期
             */
            cprintf("User Timer interrupt\n");
            break;

        case IRQ_S_TIMER:
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // cprintf("Supervisor timer interrupt\n");
         /* LAB3 EXERCISE1   2311671 :  */
            /* 监管者态时钟中断 - 最重要的中断之一
             * 由系统定时器触发，用于：
             * 1. 进程调度（时间片轮转）
             * 2. 系统时钟维护
             * 3. 定期任务执行
             * 4. 超时处理
             *
             * RISC-V规范说明：sip寄存器中除了SSIP和USIP位外都是只读的
             * 因此要清除STIP，需要调用sbi_set_timer设置下次中断时间
             */

            /* LAB3 EXERCISE1 - 时钟中断处理任务 */
            /* (1) 设置下次时钟中断 */
            clock_set_next_event();

            /* (2) 计数器（ticks）加一
             * ticks是全局变量，记录总的时钟中断次数
             * 这个变量定义在clock.c中
             */
            ticks++;

            /* (3) 当计数器达到100时，输出提示信息并增加打印计数 */
            if (ticks % TICK_NUM == 0) {
                print_ticks();
            }

            /* (4) 当ticks达到1000时（即打印了10次），关机
             * 这是为了防止测试程序无限运行
             */
            if (ticks == 10 * TICK_NUM) {
                sbi_shutdown();
            }
            break;

        case IRQ_H_TIMER:
            /* 虚拟机管理器时钟中断 */
            cprintf("Hypervisor software interrupt\n");
            break;

        case IRQ_M_TIMER:
            /* 机器态时钟中断 */
            cprintf("Machine software interrupt\n");
            break;

        case IRQ_U_EXT:
            /* 用户态外部中断
             * 来自外部设备的用户态中断
             */
            cprintf("User software interrupt\n");
            break;

        case IRQ_S_EXT:
            /* 监管者态外部中断
             * 最常见的外部中断，如键盘、鼠标、磁盘、网络等设备
             */
            cprintf("Supervisor external interrupt\n");
            break;

        case IRQ_H_EXT:
            /* 虚拟机管理器外部中断 */
            cprintf("Hypervisor software interrupt\n");
            break;

        case IRQ_M_EXT:
            /* 机器态外部中断 */
            cprintf("Machine software interrupt\n");
            break;

        default:
            /* 未识别的中断类型，打印完整trap frame用于调试 */
            print_trapframe(tf);
            break;
    }
}

/* ======================================================================================
 * exception_handler - 异常处理函数
 *
 * 处理各种同步异常事件。与中断不同，异常必须立即处理，不能被忽略
 * scause最高位为0表示异常，具体异常类型由低位编码表示
 *
 * RISC-V异常类型主要包括：
 * 1. 指令获取异常(Instruction Fetch): 取指时的地址错误
 * 2. 非法指令异常(Illegal Instruction): 执行无效指令
 * 3. 断点异常(Breakpoint): 执行ebreak指令
 * 4. 加载/存储异常(Load/Store Faults): 内存访问错误
 * 5. 系统调用异常(Environment Call): 执行ecall指令
 * 6. 页面错误(Page Fault): 页表映射不存在（MMU相关）
 * ====================================================================================== */
void exception_handler(struct trapframe *tf) {
    /* 根据scause的值分发不同的异常处理 */
    switch (tf->cause) {
        case CAUSE_MISALIGNED_FETCH:
            /* 指令获取地址不对齐异常
             * 当PC值没有按照指令对齐要求对齐时发生
             * RISC-V指令通常要求2字节或4字节对齐
             */
            break;

        case CAUSE_FAULT_FETCH:
            /* 指令获取页面错误
             * 尝试从无效或不可访问的内存地址获取指令
             * 通常由MMU页面映射错误引起
             */
            break;

        case CAUSE_ILLEGAL_INSTRUCTION:
           /* LAB3 CHALLENGE3   2311671 :  */
            /* 非法指令异常 - LAB3 CHALLENGE3
             * CPU遇到无法识别或无效的指令时触发
             * 常见原因：
             * 1. 指令编码错误
             * 2. 特权指令在用户态执行
             * 3. 不支持的扩展指令集
             */

            /* (1) 输出异常类型 */
            cprintf("Exception type:Illegal instruction\n");

            /* (2) 输出异常指令地址
             * sepc指向导致异常的指令地址
             */
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);

            /* (3) 更新tf->epc以跳过非法指令
             * RISC-V指令通常是4字节长（压缩指令除外）
             * 将epc增加4，使CPU跳过这条非法指令继续执行
             */
            tf->epc += 4;
            break;

        case CAUSE_BREAKPOINT:
            /* 断点异常 - LAB3 CHALLENGE3   2311671 : 
             * 执行ebreak指令时触发
             * 通常用于调试目的，允许程序在特定位置停止执行
             * 调试器可以在这里设置断点
             */

            /* (1) 输出异常类型 */
            cprintf("Exception type: breakpoint\n");

            /* (2) 输出断点指令地址 */
            cprintf("ebreak caught at 0x%08x\n", tf->epc);

            /* (3) 更新tf->epc以跳过断点指令
             * ebreak指令也是4字节长
             */
            tf->epc += 4;
            break;

        case CAUSE_MISALIGNED_LOAD:
            /* 加载地址不对齐异常
             * 尝试从不对齐的地址加载数据
             * 某些RISC-V实现要求加载操作地址对齐
             */
            break;

        case CAUSE_FAULT_LOAD:
            /* 加载页面错误
             * 尝试从无效内存地址或没有读权限的地址加载数据
             */
            break;

        case CAUSE_MISALIGNED_STORE:
            /* 存储地址不对齐异常
             * 尝试向不对齐的地址存储数据
             */
            break;

        case CAUSE_FAULT_STORE:
            /* 存储页面错误
             * 尝试向无效内存地址或没有写权限的地址存储数据
             */
            break;

        case CAUSE_USER_ECALL:
            /* 用户态系统调用异常
             * 用户程序执行ecall指令请求内核服务
             * 需要切换到内核态处理系统调用
             */
            break;

        case CAUSE_SUPERVISOR_ECALL:
            /* 监管者态系统调用异常
             * 内核程序执行ecall指令（通常用于调用机器态服务）
             */
            break;

        case CAUSE_HYPERVISOR_ECALL:
            /* 虚拟机管理器系统调用异常 */
            break;

        case CAUSE_MACHINE_ECALL:
            /* 机器态系统调用异常
             * 通常是无效的，因为机器态是最高特权级
             */
            break;

        default:
            /* 未识别的异常类型，打印完整trap frame用于调试 */
            print_trapframe(tf);
            break;
    }
}

/* ======================================================================================
 * trap_dispatch - Trap分发函数
 *
 * 根据scause寄存器的最高位判断是中断还是异常，然后分发到相应的处理函数
 *
 * scause寄存器格式：
 * - 最高位(bit 63) = 1: 中断(Interrupt)
 * - 最高位(bit 63) = 0: 异常(Exception)
 *
 * 在有符号整数中，最高位为1的数是负数，所以可以通过检查tf->cause是否小于0来判断
 * ====================================================================================== */
static inline void trap_dispatch(struct trapframe *tf) {
    /* 检查scause的最高位来区分中断和异常
     * 如果cause < 0，说明最高位为1，是中断
     * 如果cause >= 0，说明最高位为0，是异常
     */
    if ((intptr_t)tf->cause < 0) {
        // 最高位为1，表示中断，调用中断处理函数
        interrupt_handler(tf);
    } else {
        // 最高位为0，表示异常，调用异常处理函数
        exception_handler(tf);
    }
}

/* ======================================================================================
 * trap - 主trap处理函数
 *
 * 这是RISC-V异常处理的入口点函数，当发生中断或异常时，最终都会调用到这里
 *
 * 函数执行流程：
 * 1. 硬件自动保存部分状态（PC->sepc，设置scause等）
 * 2. 跳转到__alltraps（trapentry.S）保存完整上下文
 * 3. 调用trap()函数进行具体处理
 * 4. 处理完成后通过__trapret（trapentry.S）恢复上下文
 * 5. 执行sret指令返回到被中断的代码
 *
 * 注意：这个函数处理完trap后会返回，而不是直接退出程序
 * ====================================================================================== */
void trap(struct trapframe *tf) {
    /* 根据trap类型分发处理
     * trap_dispatch会根据scause区分中断和异常
     * 并调用相应的处理函数
     */
    trap_dispatch(tf);

    /* 处理完成后返回
     * 控制权会回到trapentry.S的__trapret
     * 那里会恢复所有保存的寄存器并执行sret返回
     */
}
