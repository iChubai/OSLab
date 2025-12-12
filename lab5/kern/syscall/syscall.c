#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}

static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}

static int
sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}

// sys_exec - SYS_exec系统调用处理：加载并执行新程序
// arg[0]: 程序名字符串指针
// arg[1]: 程序名长度
// arg[2]: 二进制数据指针
// arg[3]: 二进制数据大小
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}

// sys_yield - SYS_yield系统调用处理：让出CPU
static int
sys_yield(uint64_t arg[]) {
    return do_yield();
}

// sys_kill - SYS_kill系统调用处理：终止指定进程
// arg[0]: 目标进程PID
static int
sys_kill(uint64_t arg[]) {
    int pid = (int)arg[0];
    return do_kill(pid);
}

// sys_getpid - SYS_getpid系统调用处理：获取当前进程PID
static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
}

static int
sys_putc(uint64_t arg[]) {
    int c = (int)arg[0];
    cputchar(c);
    return 0;
}

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}

static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

// syscall - 系统调用分发器，从trapframe提取参数并调用相应处理函数
void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];              // 系统调用参数数组
    int num = tf->gpr.a0;         // 系统调用号从a0获取

    if (num >= 0 && num < NUM_SYSCALLS) {  // 检查系统调用号有效性
        if (syscalls[num] != NULL) {        // 检查处理函数是否存在
            // 从trapframe提取参数到arg数组
            arg[0] = tf->gpr.a1;  // 第一个参数
            arg[1] = tf->gpr.a2;  // 第二个参数
            arg[2] = tf->gpr.a3;  // 第三个参数
            arg[3] = tf->gpr.a4;  // 第四个参数
            arg[4] = tf->gpr.a5;  // 第五个参数

            tf->gpr.a0 = syscalls[num](arg);  // 调用处理函数，返回值写入a0
            return ;
        }
    }
    // 无效系统调用，打印调试信息并panic
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}

