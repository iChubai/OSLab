/**
 * @file kern/process/entry.S
 * @brief 内核线程入口汇编代码
 *
 * 该文件包含内核线程的入口点代码，负责：
 * - 设置线程函数的参数
 * - 调用线程函数
 * - 线程函数返回后调用do_exit终止线程
 */

.text

/**
 * @brief 内核线程入口函数
 *
 * kernel_thread_entry是所有内核线程的统一入口点。
 * 当kernel_thread创建新线程时，会设置trapframe使得新线程从这里开始执行。
 *
 * 执行流程：
 * 1. 从s1寄存器获取函数参数，放入a0（函数第一个参数）
 * 2. 从s0寄存器获取函数地址，调用该函数
 * 3. 函数返回后调用do_exit终止当前线程
 *
 * 寄存器使用说明：
 * - s0: 保存线程函数地址（由kernel_thread设置）
 * - s1: 保存函数参数（由kernel_thread设置）
 * - a0: RISC-V函数调用约定中的第一个参数寄存器
 */
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

	# ========== 设置函数参数 ==========
	# 将s1寄存器中的参数移动到a0（第一个参数寄存器）
	move a0, s1

	# ========== 调用线程函数 ==========
	# 跳转到s0寄存器中保存的函数地址
	# jalr指令会将返回地址保存到ra寄存器
	jalr s0

	# ========== 线程函数返回，终止线程 ==========
	# 线程函数执行完毕，调用do_exit终止当前线程
	# 传递退出码0表示正常退出
	jal do_exit
