/**
 * @file kern/trap/trap.c
 * @brief 中断和异常处理核心实现
 *
 * 本文件实现了ucore操作系统中中断和异常处理的完整机制。
 * 中断和异常处理是操作系统最核心的功能之一，负责管理系统与硬件的交互。
 *
 * ============================================================================
 * 中断处理的基本流程
 * ============================================================================
 *
 * 1. 硬件触发中断 -> CPU保存当前状态 -> 跳转到中断向量
 * 2. 汇编代码保存trapframe -> 调用C语言trap()函数
 * 3. trap()函数分发到具体处理函数 -> 处理中断/异常
 * 4. 处理完成后恢复trapframe -> 返回到原执行点
 *
 * ============================================================================
 * RISC-V中断类型
 * ============================================================================
 *
 * 中断（Interrupt）：异步事件，由cause最高位为1标识
 * - IRQ_U_SOFT: 用户态软件中断
 * - IRQ_S_SOFT: 监管态软件中断（通常用于进程间通信）
 * - IRQ_H_SOFT: 管理态软件中断
 * - IRQ_M_SOFT: 机器态软件中断
 * - IRQ_U_TIMER: 用户态定时器中断
 * - IRQ_S_TIMER: 监管态定时器中断（最重要的中断，用于进程调度）
 * - IRQ_H_TIMER: 管理态定时器中断
 * - IRQ_M_TIMER: 机器态定时器中断
 * - IRQ_U_EXT: 用户态外部中断
 * - IRQ_S_EXT: 监管态外部中断（键盘、鼠标等设备）
 * - IRQ_H_EXT: 管理态外部中断
 * - IRQ_M_EXT: 机器态外部中断
 *
 * 异常（Exception）：同步事件，由cause最高位为0标识
 * - CAUSE_MISALIGNED_FETCH: 指令地址未对齐
 * - CAUSE_ILLEGAL_INSTRUCTION: 非法指令
 * - CAUSE_BREAKPOINT: 断点
 * - CAUSE_LOAD_ACCESS: 加载访问错误
 * - CAUSE_STORE_ACCESS: 存储访问错误
 * - CAUSE_USER_ECALL: 用户态系统调用
 * - CAUSE_SUPERVISOR_ECALL: 监管态系统调用
 * - CAUSE_FETCH_PAGE_FAULT: 指令页面错误
 * - CAUSE_LOAD_PAGE_FAULT: 加载页面错误
 * - CAUSE_STORE_PAGE_FAULT: 存储页面错误
 */

#include <assert.h>
#include <clock.h>
#include <console.h>
#include <defs.h>
#include <kdebug.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>
#include <sbi.h>
#include <stdio.h>
#include <trap.h>
#include <vmm.h>

#define TICK_NUM 100  /**< 定时器中断间隔，用于进程调度 */

/**
 * @brief 打印定时器滴答信息
 *
 * 当定时器中断累计到TICK_NUM次时，打印当前滴答计数。
 * 在调试模式下，还会触发测试结束逻辑。
 */
static void print_ticks()
{
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

/**
 * @brief 初始化中断描述符表和中断处理环境
 *
 * 该函数设置RISC-V架构的中断处理基础环境，是系统启动时必须调用的初始化函数。
 *
 * 详细设置说明：
 * 1. sscratch = 0：告诉中断向量代码当前正在内核态执行
 *    - sscratch用于保存用户栈指针，中断时切换到内核栈
 *    - 设置为0表示已经在内核态，无需栈切换
 *
 * 2. stvec = &__alltraps：设置异常向量表地址
 *    - __alltraps是汇编代码中的中断处理入口（在trapentry.S中定义）
 *    - 所有中断和异常都会跳转到这个地址开始处理
 *
 * 3. SSTATUS_SUM = 1：允许监管态访问用户内存
 *    - SUM (Supervisor User Memory) 位控制是否允许内核访问用户空间
 *    - 设置为1使得内核可以访问用户程序的数据
 *
 * @note 这个函数必须在系统启动的早期调用，确保中断处理环境正确设置
 */
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
}

void print_trapframe(struct trapframe *tf)
{
    cprintf("trapframe at %p\n", tf);
    print_regs(&tf->gpr);
    cprintf("  status   0x%08x\n", tf->status);
    cprintf("  epc      0x%08x\n", tf->epc);
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
    cprintf("  ra       0x%08x\n", gpr->ra);
    cprintf("  sp       0x%08x\n", gpr->sp);
    cprintf("  gp       0x%08x\n", gpr->gp);
    cprintf("  tp       0x%08x\n", gpr->tp);
    cprintf("  t0       0x%08x\n", gpr->t0);
    cprintf("  t1       0x%08x\n", gpr->t1);
    cprintf("  t2       0x%08x\n", gpr->t2);
    cprintf("  s0       0x%08x\n", gpr->s0);
    cprintf("  s1       0x%08x\n", gpr->s1);
    cprintf("  a0       0x%08x\n", gpr->a0);
    cprintf("  a1       0x%08x\n", gpr->a1);
    cprintf("  a2       0x%08x\n", gpr->a2);
    cprintf("  a3       0x%08x\n", gpr->a3);
    cprintf("  a4       0x%08x\n", gpr->a4);
    cprintf("  a5       0x%08x\n", gpr->a5);
    cprintf("  a6       0x%08x\n", gpr->a6);
    cprintf("  a7       0x%08x\n", gpr->a7);
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
    cprintf("  t3       0x%08x\n", gpr->t3);
    cprintf("  t4       0x%08x\n", gpr->t4);
    cprintf("  t5       0x%08x\n", gpr->t5);
    cprintf("  t6       0x%08x\n", gpr->t6);
}

extern struct mm_struct *check_mm_struct;

/**
 * @brief 中断处理函数
 *
 * 处理所有类型的硬件中断。中断是异步事件，由外部设备或定时器触发。
 * 在RISC-V中，中断的cause字段最高位为1，通过右移1位清除符号位来获取中断号。
 *
 * @param tf 包含中断发生时CPU状态的trapframe
 */
void interrupt_handler(struct trapframe *tf)
{
    // 清除cause的符号位，获取真实的中断号
    // RISC-V中：中断的cause最高位为1，异常为0
    intptr_t cause = (tf->cause << 1) >> 1;

    switch (cause)
    {
    // ========== 软件中断（通常用于进程间通信）==========
    case IRQ_U_SOFT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_SOFT:
        cprintf("Supervisor software interrupt\n");
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
        break;

    // ========== 定时器中断（最重要的中断）==========
    case IRQ_U_TIMER:
        cprintf("User timer interrupt\n");
        break;
    case IRQ_S_TIMER:
        // 监管态定时器中断 - 这是操作系统中最关键的中断！
        // 用于实现进程调度和时间片轮转

        // 1. 设置下一次定时器中断
        clock_set_next_event();

        // 2. 增加全局时钟滴答计数
        ticks++;

        // 3. 每100个滴答打印一次状态信息
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }

        // 4. 运行1000个滴答后（约10秒）关闭系统
        // 这是一个简单的测试终止条件
        if (ticks == 10 * TICK_NUM) {
            sbi_shutdown();
        }
        break;
    case IRQ_H_TIMER:
        cprintf("Hypervisor timer interrupt\n");
        break;
    case IRQ_M_TIMER:
        cprintf("Machine timer interrupt\n");
        break;

    // ========== 外部中断（来自外部设备）==========
    case IRQ_U_EXT:
        cprintf("User external interrupt\n");
        break;
    case IRQ_S_EXT:
        // 监管态外部中断 - 来自键盘、鼠标、网络等设备
        cprintf("Supervisor external interrupt\n");
        break;
    case IRQ_H_EXT:
        cprintf("Hypervisor external interrupt\n");
        break;
    case IRQ_M_EXT:
        cprintf("Machine external interrupt\n");
        break;

    // ========== 未知中断 ==========
    default:
        // 遇到未知中断类型，打印完整trapframe信息用于调试
        print_trapframe(tf);
        break;
    }
}

/**
 * @brief 异常处理函数
 *
 * 处理所有类型的CPU异常。异常是同步事件，由当前执行的程序触发。
 * 大多数异常在ucore中只是打印信息，实际的错误处理在后续实验中实现。
 *
 * @param tf 包含异常发生时CPU状态的trapframe
 */
void exception_handler(struct trapframe *tf)
{
    int ret;  // 用于可能的返回值（当前未使用）

    switch (tf->cause)
    {
    // ========== 指令相关异常 ==========
    case CAUSE_MISALIGNED_FETCH:
        // 指令地址未对齐：CPU试图从非对齐地址获取指令
        cprintf("Instruction address misaligned\n");
        break;

    case CAUSE_FETCH_ACCESS:
        // 指令访问错误：无法访问指令所在的内存地址
        cprintf("Instruction access fault\n");
        break;

    case CAUSE_ILLEGAL_INSTRUCTION:
        // 非法指令：CPU遇到无法识别的指令
        cprintf("Illegal instruction\n");
        // 跳过这条非法指令，继续执行下一条
        tf->epc += 4;  // RISC-V指令长度为4字节
        break;

    case CAUSE_BREAKPOINT:
        // 断点：程序设置的调试断点（由ebreak指令触发）
        cprintf("Breakpoint\n");
        // 跳过断点指令，继续执行
        tf->epc += 4;
        break;

    // ========== 内存访问异常 ==========
    case CAUSE_MISALIGNED_LOAD:
        // 加载地址未对齐：从非对齐地址读取数据
        cprintf("Load address misaligned\n");
        break;

    case CAUSE_LOAD_ACCESS:
        // 加载访问错误：无法读取指定内存地址
        cprintf("Load access fault\n");
        break;

    case CAUSE_MISALIGNED_STORE:
        // 存储地址未对齐：向非对齐地址写入数据（原子内存操作）
        cprintf("AMO address misaligned\n");
        break;

    case CAUSE_STORE_ACCESS:
        // 存储访问错误：无法写入指定内存地址
        cprintf("Store/AMO access fault\n");
        break;

    // ========== 系统调用 ==========
    case CAUSE_USER_ECALL:
        // 用户态系统调用：用户程序通过ecall指令请求系统服务
        // 在后续实验中会实现完整的系统调用处理
        cprintf("Environment call from U-mode\n");
        break;

    case CAUSE_SUPERVISOR_ECALL:
        // 监管态系统调用：内核代码的系统调用
        cprintf("Environment call from S-mode\n");
        break;

    case CAUSE_HYPERVISOR_ECALL:
        // 管理态系统调用
        cprintf("Environment call from H-mode\n");
        break;

    case CAUSE_MACHINE_ECALL:
        // 机器态系统调用
        cprintf("Environment call from M-mode\n");
        break;

    // ========== 页面错误（内存管理相关）==========
    case CAUSE_FETCH_PAGE_FAULT:
        // 指令页面错误：指令所在的页面未映射或权限不足
        // 这是虚拟内存管理中的核心异常，后续实验会详细处理
        cprintf("Instruction page fault\n");
        break;

    case CAUSE_LOAD_PAGE_FAULT:
        // 加载页面错误：读取数据的页面未映射或权限不足
        cprintf("Load page fault\n");
        break;

    case CAUSE_STORE_PAGE_FAULT:
        // 存储页面错误：写入数据的页面未映射或权限不足
        cprintf("Store/AMO page fault\n");
        break;

    // ========== 未知异常 ==========
    default:
        // 遇到未知异常类型，打印完整trapframe信息用于调试
        print_trapframe(tf);
        break;
    }
}

/**
 * @brief 统一的中断和异常处理入口函数
 *
 * 这是ucore中断处理系统的核心分发函数。所有中断和异常都会通过汇编代码
 * 跳转到这里，然后由这个函数根据异常原因分发到具体的处理函数。
 *
 * 中断和异常的区分方法：
 * - RISC-V架构中，cause字段的最高位用于区分中断和异常
 * - cause < 0（有符号数）：表示中断（最高位为1）
 * - cause >= 0（有符号数）：表示异常（最高位为0）
 *
 * 处理流程：
 * 1. 检查cause字段的符号位
 * 2. 如果是中断，调用interrupt_handler()
 * 3. 如果是异常，调用exception_handler()
 * 4. 处理完成后，通过trapentry.S中的代码恢复trapframe并返回
 *
 * @param tf 指向trapframe结构体的指针，包含完整的CPU状态
 *
 * @note 该函数返回后，系统会自动恢复到中断发生前的执行状态
 */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
    {
        // interrupts - 中断：异步事件，由cause最高位为1标识
        interrupt_handler(tf);
    }
    else
    {
        // exceptions - 异常：同步事件，由cause最高位为0标识
        exception_handler(tf);
    }
}
