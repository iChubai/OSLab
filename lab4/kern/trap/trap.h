/**
 * @file kern/trap/trap.h
 * @brief 中断和异常处理核心数据结构定义
 *
 * 本头文件定义了ucore操作系统中中断和异常处理的核心数据结构。
 * 中断和异常是操作系统与硬件交互的关键机制，负责处理异步事件和错误情况。
 *
 * ============================================================================
 * 中断和异常的基本概念
 * ============================================================================
 *
 * 中断（Interrupt）：
 * - 由外部硬件设备发起的异步事件
 * - 例如：时钟中断、键盘中断、网络数据到达等
 * - 中断可以随时发生，不受当前程序控制
 *
 * 异常（Exception）：
 * - 由当前执行的程序引起的同步事件
 * - 例如：除零错误、非法指令、页面错误等
 * - 异常必须由当前程序触发
 *
 * trapframe（陷阱帧）：
 * - 保存中断/异常发生时CPU的完整状态
 * - 包括所有通用寄存器、状态寄存器、程序计数器等
 * - 用于中断处理完成后恢复执行现场
 *
 * ============================================================================
 * RISC-V架构的中断处理机制
 * ============================================================================
 *
 * 1. 中断向量表（stvec）：指向中断处理入口
 * 2. 中断栈（sscratch）：内核中断处理时使用的栈
 * 3. 中断状态（sstatus）：控制中断使能和权限级别
 * 4. 中断原因（scause）：标识中断/异常的类型
 * 5. 中断地址（sepc）：中断发生时的程序计数器
 */

#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

/**
 * @brief RISC-V通用寄存器保存结构体
 *
 * 该结构体按照RISC-V规范定义，保存CPU在中断发生时所有通用寄存器的值。
 * 这些寄存器包括：零寄存器、返回地址、栈指针、参数寄存器、临时寄存器等。
 *
 * 字段说明（按照RISC-V规范）：
 * - zero: 硬连线为0的寄存器 (x0)
 * - ra: 返回地址寄存器 (x1)，保存函数返回地址
 * - sp: 栈指针寄存器 (x2)，指向当前栈顶
 * - gp: 全局指针寄存器 (x3)，用于访问全局变量
 * - tp: 线程指针寄存器 (x4)，指向线程本地存储
 * - t0-t6: 临时寄存器 (x5-x7, x28-x31)，编译器临时使用
 * - s0-s11: 保存寄存器 (x8-x9, x18-x27)，用于保存局部变量
 * - a0-a7: 参数/返回值寄存器 (x10-x17)，函数调用时使用
 */
struct pushregs
{
    uintptr_t zero; // Hard-wired zero (x0) - 始终为0
    uintptr_t ra;   // Return address (x1) - 函数返回地址
    uintptr_t sp;   // Stack pointer (x2) - 栈指针
    uintptr_t gp;   // Global pointer (x3) - 全局指针
    uintptr_t tp;   // Thread pointer (x4) - 线程指针
    uintptr_t t0;   // Temporary (x5) - 临时寄存器
    uintptr_t t1;   // Temporary (x6) - 临时寄存器
    uintptr_t t2;   // Temporary (x7) - 临时寄存器
    uintptr_t s0;   // Saved register/frame pointer (x8) - 保存寄存器/帧指针
    uintptr_t s1;   // Saved register (x9) - 保存寄存器
    uintptr_t a0;   // Function argument/return value (x10) - 参数/返回值
    uintptr_t a1;   // Function argument/return value (x11) - 参数/返回值
    uintptr_t a2;   // Function argument (x12) - 函数参数
    uintptr_t a3;   // Function argument (x13) - 函数参数
    uintptr_t a4;   // Function argument (x14) - 函数参数
    uintptr_t a5;   // Function argument (x15) - 函数参数
    uintptr_t a6;   // Function argument (x16) - 函数参数
    uintptr_t a7;   // Function argument (x17) - 函数参数
    uintptr_t s2;   // Saved register (x18) - 保存寄存器
    uintptr_t s3;   // Saved register (x19) - 保存寄存器
    uintptr_t s4;   // Saved register (x20) - 保存寄存器
    uintptr_t s5;   // Saved register (x21) - 保存寄存器
    uintptr_t s6;   // Saved register (x22) - 保存寄存器
    uintptr_t s7;   // Saved register (x23) - 保存寄存器
    uintptr_t s8;   // Saved register (x24) - 保存寄存器
    uintptr_t s9;   // Saved register (x25) - 保存寄存器
    uintptr_t s10;  // Saved register (x26) - 保存寄存器
    uintptr_t s11;  // Saved register (x27) - 保存寄存器
    uintptr_t t3;   // Temporary (x28) - 临时寄存器
    uintptr_t t4;   // Temporary (x29) - 临时寄存器
    uintptr_t t5;   // Temporary (x30) - 临时寄存器
    uintptr_t t6;   // Temporary (x31) - 临时寄存器
};

/**
 * @brief 中断帧结构体 - 保存完整的CPU状态
 *
 * trapframe是中断/异常处理的核心数据结构，保存了中断发生时CPU的完整执行状态。
 * 中断处理函数使用这些信息来处理中断，然后恢复执行。
 *
 * 内存布局（从高地址到低地址）：
 * 高地址 -> trapframe结构体
 *          gpr (pushregs结构体，所有通用寄存器)
 *          status (sstatus寄存器)
 *          epc (sepc寄存器，程序计数器)
 *          badvaddr (stval寄存器，错误地址)
 *          cause (scause寄存器，中断原因)
 * 低地址 -> 栈顶
 */
struct trapframe
{
    struct pushregs gpr;    /**< 所有通用寄存器的值 */
    uintptr_t status;       /**< CPU状态寄存器 (sstatus) - 包含权限级别、中断使能等信息 */
    uintptr_t epc;          /**< 异常程序计数器 (sepc) - 中断发生时的指令地址 */
    uintptr_t badvaddr;     /**< 错误地址 (stval) - 对于页面错误等，保存出错的地址 */
    uintptr_t cause;        /**< 中断原因 (scause) - 标识中断/异常的类型和来源 */
};

// ============================================================================
// 中断处理核心函数声明
// ============================================================================

/**
 * @brief 统一的中断和异常处理入口
 *
 * 该函数是所有中断和异常的统一处理入口，根据trapframe中的cause字段
 * 区分不同的中断类型，并调用相应的处理函数。
 *
 * @param tf 指向trapframe结构体的指针，包含中断时的CPU状态
 */
void trap(struct trapframe *tf);

/**
 * @brief 初始化中断描述符表
 *
 * 设置RISC-V的中断处理环境：
 * - 设置sscratch为0，表示当前在内核态
 * - 设置stvec指向中断向量表入口
 * - 允许内核访问用户内存空间
 */
void idt_init(void);

/**
 * @brief 打印完整的trapframe信息（调试用）
 *
 * 显示trapframe中保存的所有CPU状态信息，用于调试中断处理。
 * @param tf 要打印的trapframe指针
 */
void print_trapframe(struct trapframe *tf);

/**
 * @brief 打印所有通用寄存器的值（调试用）
 *
 * 格式化打印pushregs结构体中的所有寄存器值。
 * @param gpr 要打印的pushregs指针
 */
void print_regs(struct pushregs *gpr);

#endif /* !__KERN_TRAP_TRAP_H__ */
