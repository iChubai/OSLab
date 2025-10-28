/* ======================================================================================
 * trap.h - 中断和异常处理相关的数据结构和函数声明
 *
 * 本头文件定义了RISC-V架构下的trap处理核心数据结构：
 * 1. struct pushregs: 保存所有通用寄存器
 * 2. struct trapframe: 完整的trap上下文信息
 *
 * 以及相关的处理函数声明
 * ====================================================================================== */

#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

/* ======================================================================================
 * struct pushregs - RISC-V通用寄存器保存结构
 *
 * 当发生中断或异常时，需要保存当前执行上下文的所有通用寄存器
 * RISC-V有32个通用寄存器（x0-x31），这个结构体按照ABI定义的顺序保存
 *
 * 寄存器分类和用途：
 * - zero(x0): 硬连线为0，不能修改
 * - ra(x1): 返回地址，用于函数返回
 * - sp(x2): 栈指针，指向当前栈顶
 * - gp(x3): 全局指针，用于访问全局变量
 * - tp(x4): 线程指针，用于线程本地存储
 * - t0-t6(x5-x7,x28-x31): 临时寄存器，函数调用时不需要保存
 * - s0-s11(x8-x9,x18-x27): 保存寄存器，函数调用时必须保存/恢复
 * - a0-a7(x10-x17): 参数和返回值寄存器
 * ====================================================================================== */
struct pushregs {
    /* 硬连线为0的寄存器 */
    uintptr_t zero;  // x0: Hard-wired zero - 总是为0

    /* 函数调用相关寄存器 */
    uintptr_t ra;    // x1: Return address - 保存函数返回地址
    uintptr_t sp;    // x2: Stack pointer - 栈指针
    uintptr_t gp;    // x3: Global pointer - 全局指针
    uintptr_t tp;    // x4: Thread pointer - 线程指针

    /* 临时寄存器 - 不需要跨函数调用保存 */
    uintptr_t t0;    // x5: Temporary register
    uintptr_t t1;    // x6: Temporary register
    uintptr_t t2;    // x7: Temporary register

    /* 保存寄存器 - 必须保存和恢复 */
    uintptr_t s0;    // x8: Saved register / Frame pointer
    uintptr_t s1;    // x9: Saved register

    /* 函数参数和返回值寄存器 */
    uintptr_t a0;    // x10: Function argument 0 / Return value 0
    uintptr_t a1;    // x11: Function argument 1 / Return value 1
    uintptr_t a2;    // x12: Function argument 2
    uintptr_t a3;    // x13: Function argument 3
    uintptr_t a4;    // x14: Function argument 4
    uintptr_t a5;    // x15: Function argument 5
    uintptr_t a6;    // x16: Function argument 6
    uintptr_t a7;    // x17: Function argument 7

    /* 更多保存寄存器 */
    uintptr_t s2;    // x18: Saved register
    uintptr_t s3;    // x19: Saved register
    uintptr_t s4;    // x20: Saved register
    uintptr_t s5;    // x21: Saved register
    uintptr_t s6;    // x22: Saved register
    uintptr_t s7;    // x23: Saved register
    uintptr_t s8;    // x24: Saved register
    uintptr_t s9;    // x25: Saved register
    uintptr_t s10;   // x26: Saved register
    uintptr_t s11;   // x27: Saved register

    /* 更多临时寄存器 */
    uintptr_t t3;    // x28: Temporary register
    uintptr_t t4;    // x29: Temporary register
    uintptr_t t5;    // x30: Temporary register
    uintptr_t t6;    // x31: Temporary register
};

/* ======================================================================================
 * struct trapframe - 完整的trap上下文信息
 *
 * 当发生trap（中断或异常）时，需要保存完整的执行状态以便恢复
 * 这个结构体包含了所有必要的处理器状态信息
 *
 * 保存的内容包括：
 * 1. 所有通用寄存器（通过pushregs结构体）
 * 2. 关键的CSR（控制状态寄存器）值
 * ====================================================================================== */
struct trapframe {
    /* 所有通用寄存器的值 */
    struct pushregs gpr;

    /* 关键的CSR寄存器值 */
    uintptr_t status;    // sstatus: 状态寄存器，包含特权级、中断使能等信息
    uintptr_t epc;       // sepc: Exception Program Counter，异常发生时的PC值
    uintptr_t badvaddr;  // sbadaddr: Bad Virtual Address，有地址相关异常时的地址
    uintptr_t cause;     // scause: Cause register，指示异常/中断的原因和类型
};

/* ======================================================================================
 * 函数声明 - Trap处理相关函数
 * ====================================================================================== */

/* trap - 主trap处理函数，处理所有中断和异常 */
void trap(struct trapframe *tf);

/* idt_init - 初始化中断描述符表和异常向量 */
void idt_init(void);

/* print_trapframe - 打印trap frame的详细信息，用于调试 */
void print_trapframe(struct trapframe *tf);

/* print_regs - 打印所有通用寄存器的值 */
void print_regs(struct pushregs* gpr);

/* trap_in_kernel - 检查trap是否发生在内核模式 */
bool trap_in_kernel(struct trapframe *tf);

#endif /* !__KERN_TRAP_TRAP_H__ */
