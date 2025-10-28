# ======================================================================================
# trapentry.S - RISC-V异常/中断入口和出口处理汇编代码
#
# 这个文件包含了RISC-V架构下trap处理的汇编代码，主要功能：
# 1. SAVE_ALL宏：保存所有通用寄存器和CSR到trap frame
# 2. RESTORE_ALL宏：从trap frame恢复所有寄存器和CSR
# 3. __alltraps：异常/中断入口点
# 4. __trapret：异常/中断返回点
#
# RISC-V trap处理流程：
# 1. 硬件自动保存PC到sepc，设置scause等CSR
# 2. 跳转到stvec指向的地址（__alltraps）
# 3. 保存完整上下文到栈上
# 4. 调用C语言trap处理函数
# 5. 恢复上下文并返回（sret指令）
# ======================================================================================

#include <riscv.h>

# ======================================================================================
# SAVE_ALL - 保存所有通用寄存器和CSR的宏
#
# 这个宏负责在trap发生时保存完整的执行上下文
# 保存的内容包括：
# - 所有32个通用寄存器（x0-x31）
# - 关键的CSR：sstatus, sepc, sbadaddr, scause
# - sscratch用于保存原来的栈指针
#
# 参数：无
# 返回：无
# ======================================================================================
    .macro SAVE_ALL
    /* =================================================================================
     * 第一步：保存栈指针到sscratch，并设置新的栈
     * ================================================================================= */

    /* 保存当前栈指针到sscratch
     * sscratch在用户态保存内核栈指针，在内核态通常设为0
     * 这里交换sp和sscratch，这样sscratch就保存了原来的sp
     */
    csrw sscratch, sp

    /* 为trap frame分配栈空间
     * trapframe结构体需要36个寄存器位置的空间
     * 每个寄存器占8字节（REGBYTES = 8），所以需要288字节
     * sp向下增长，为结构体预留空间
     */
    addi sp, sp, -36 * REGBYTES

    /* =================================================================================
     * 第二步：保存所有通用寄存器到栈上
     * ================================================================================= */

    /* 注意：这里故意跳过了x2(sp)，因为我们刚刚修改了sp
     * x2(sp)会在后面特殊处理
     * 寄存器按照ABI定义的顺序保存到trapframe结构中
     */

    /* x0 (zero) - 硬连线为0，但仍然保存以保持结构完整性 */
    STORE x0, 0*REGBYTES(sp)

    /* x1 (ra) - 返回地址 */
    STORE x1, 1*REGBYTES(sp)

    /* 跳过x2(sp)，将在后面保存 */

    /* x3 (gp) - 全局指针 */
    STORE x3, 3*REGBYTES(sp)

    /* x4 (tp) - 线程指针 */
    STORE x4, 4*REGBYTES(sp)

    /* 临时寄存器 t0-t2 (x5-x7) */
    STORE x5, 5*REGBYTES(sp)
    STORE x6, 6*REGBYTES(sp)
    STORE x7, 7*REGBYTES(sp)

    /* 保存寄存器 s0-s1 (x8-x9) */
    STORE x8, 8*REGBYTES(sp)
    STORE x9, 9*REGBYTES(sp)

    /* 参数/返回值寄存器 a0-a7 (x10-x17) */
    STORE x10, 10*REGBYTES(sp)
    STORE x11, 11*REGBYTES(sp)
    STORE x12, 12*REGBYTES(sp)
    STORE x13, 13*REGBYTES(sp)
    STORE x14, 14*REGBYTES(sp)
    STORE x15, 15*REGBYTES(sp)
    STORE x16, 16*REGBYTES(sp)
    STORE x17, 17*REGBYTES(sp)

    /* 保存寄存器 s2-s11 (x18-x27) */
    STORE x18, 18*REGBYTES(sp)
    STORE x19, 19*REGBYTES(sp)
    STORE x20, 20*REGBYTES(sp)
    STORE x21, 21*REGBYTES(sp)
    STORE x22, 22*REGBYTES(sp)
    STORE x23, 23*REGBYTES(sp)
    STORE x24, 24*REGBYTES(sp)
    STORE x25, 25*REGBYTES(sp)
    STORE x26, 26*REGBYTES(sp)
    STORE x27, 27*REGBYTES(sp)

    /* 临时寄存器 t3-t6 (x28-x31) */
    STORE x28, 28*REGBYTES(sp)
    STORE x29, 29*REGBYTES(sp)
    STORE x30, 30*REGBYTES(sp)
    STORE x31, 31*REGBYTES(sp)

    /* =================================================================================
     * 第三步：读取并保存关键的CSR寄存器
     * ================================================================================= */

    /* 读取sscratch到s0，现在s0保存了原来的栈指针 */
    csrrw s0, sscratch, x0

    /* 读取其他CSR到临时寄存器 */
    csrr s1, sstatus      /* 状态寄存器 */
    csrr s2, sepc         /* 异常程序计数器 */
    csrr s3, sbadaddr     /* 坏地址（用于地址异常） */
    csrr s4, scause       /* 异常原因 */

    /* 保存CSR值到trap frame
     * 按照trapframe结构体的定义保存
     */
    STORE s0, 2*REGBYTES(sp)   /* 原来的栈指针 */
    STORE s1, 32*REGBYTES(sp)  /* sstatus */
    STORE s2, 33*REGBYTES(sp)  /* sepc */
    STORE s3, 34*REGBYTES(sp)  /* sbadaddr */
    STORE s4, 35*REGBYTES(sp)  /* scause */
    .endm

# ======================================================================================
# RESTORE_ALL - 从trap frame恢复所有通用寄存器和CSR的宏
#
# 这个宏负责在trap处理完成后恢复完整的执行上下文
# 恢复的顺序与保存的顺序相反，以确保正确性
#
# 参数：无
# 返回：无
# ======================================================================================
    .macro RESTORE_ALL
    /* =================================================================================
     * 第一步：恢复关键的CSR寄存器
     * ================================================================================= */

    /* 从trap frame加载sstatus和sepc的值 */
    LOAD s1, 32*REGBYTES(sp)   /* 恢复sstatus */
    LOAD s2, 33*REGBYTES(sp)   /* 恢复sepc */

    /* 将恢复的值写回CSR寄存器
     * 注意：sbadaddr和scause不需要恢复，因为它们是只读的
     */
    csrw sstatus, s1
    csrw sepc, s2

    /* =================================================================================
     * 第二步：恢复所有通用寄存器
     * ================================================================================= */

    /* 按照与保存相反的顺序恢复寄存器
     * 跳过x0（zero），因为它是硬连线为0的
     */

    /* x1 (ra) - 返回地址 */
    LOAD x1, 1*REGBYTES(sp)

    /* x3 (gp) - 全局指针 */
    LOAD x3, 3*REGBYTES(sp)

    /* x4 (tp) - 线程指针 */
    LOAD x4, 4*REGBYTES(sp)

    /* 临时寄存器 t0-t2 (x5-x7) */
    LOAD x5, 5*REGBYTES(sp)
    LOAD x6, 6*REGBYTES(sp)
    LOAD x7, 7*REGBYTES(sp)

    /* 保存寄存器 s0-s1 (x8-x9) */
    LOAD x8, 8*REGBYTES(sp)
    LOAD x9, 9*REGBYTES(sp)

    /* 参数/返回值寄存器 a0-a7 (x10-x17) */
    LOAD x10, 10*REGBYTES(sp)
    LOAD x11, 11*REGBYTES(sp)
    LOAD x12, 12*REGBYTES(sp)
    LOAD x13, 13*REGBYTES(sp)
    LOAD x14, 14*REGBYTES(sp)
    LOAD x15, 15*REGBYTES(sp)
    LOAD x16, 16*REGBYTES(sp)
    LOAD x17, 17*REGBYTES(sp)

    /* 保存寄存器 s2-s11 (x18-x27) */
    LOAD x18, 18*REGBYTES(sp)
    LOAD x19, 19*REGBYTES(sp)
    LOAD x20, 20*REGBYTES(sp)
    LOAD x21, 21*REGBYTES(sp)
    LOAD x22, 22*REGBYTES(sp)
    LOAD x23, 23*REGBYTES(sp)
    LOAD x24, 24*REGBYTES(sp)
    LOAD x25, 25*REGBYTES(sp)
    LOAD x26, 26*REGBYTES(sp)
    LOAD x27, 27*REGBYTES(sp)

    /* 临时寄存器 t3-t6 (x28-x31) */
    LOAD x28, 28*REGBYTES(sp)
    LOAD x29, 29*REGBYTES(sp)
    LOAD x30, 30*REGBYTES(sp)
    LOAD x31, 31*REGBYTES(sp)

    /* 最后恢复栈指针sp
     * sp必须最后恢复，因为在此之前我们还需要用sp来访问trap frame
     */
    LOAD x2, 2*REGBYTES(sp)
    .endm

# ======================================================================================
# __alltraps - 异常/中断处理入口点
#
# 这是RISC-V trap处理的入口函数，当发生任何trap时，硬件都会跳转到这里
#
# 执行流程：
# 1. 保存所有上下文到trap frame（使用SAVE_ALL宏）
# 2. 将trap frame地址作为参数传递给trap()函数
# 3. 调用trap()进行具体处理
# 4. 处理完成后返回，通过__trapret恢复上下文
# ======================================================================================
    .globl __alltraps
    .align(2)           /* 2字节对齐，确保地址正确 */
__alltraps:
    /* 保存完整的执行上下文到栈上 */
    SAVE_ALL

    /* 将当前栈指针（指向trap frame）作为参数传递给trap函数
     * 在RISC-V ABI中，a0是第一个参数寄存器
     */
    move  a0, sp

    /* 调用C语言的trap处理函数
     * jal指令会保存返回地址到ra，并跳转到trap函数
     */
    jal trap

    /* 从trap函数返回后，栈指针应该和调用前一样
     * 现在跳转到__trapret恢复上下文并返回
     */

# ======================================================================================
# __trapret - 异常/中断处理返回点
#
# 从trap处理函数返回后，通过这个函数恢复所有保存的上下文
# 并使用sret指令返回到被中断的代码继续执行
# ======================================================================================
    .globl __trapret
__trapret:
    /* 恢复所有保存的寄存器和CSR */
    RESTORE_ALL

    /* 执行sret指令从异常/中断返回
     * sret会：
     * 1. 将sepc的值恢复到PC
     * 2. 恢复sstatus中的特权级和中断状态
     * 3. 继续执行被中断的代码
     */
    sret
