#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

// wakeup_proc - 唤醒进程，将其状态设置为可运行
// 清除等待状态，确保进程可以被调度器选中
void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，确保操作原子性
    {
        if (proc->state != PROC_RUNNABLE)
        {
            proc->state = PROC_RUNNABLE;  // 设置为可运行状态
            proc->wait_state = 0;         // 清除等待状态
        }
        else
        {
            warn("wakeup runnable process.\n");  // 警告：尝试唤醒已在运行的进程
        }
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
}

// schedule - 进程调度器，选择下一个要运行的进程
// 使用轮转调度算法，从当前进程开始扫描进程列表，寻找可运行进程
void schedule(void)
{
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);  // 关闭中断，保护调度过程
    {
        current->need_resched = 0;  // 清除当前进程的重调度标志
        // 从当前进程开始扫描，如果是idle进程则从列表头开始
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do
        {
            if ((le = list_next(le)) != &proc_list)  // 获取下一个进程
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)   // 找到可运行进程
                {
                    break;
                }
            }
        } while (le != last);  // 扫描完整个列表
        if (next == NULL || next->state != PROC_RUNNABLE)
        {
            next = idleproc;  // 没有可运行进程，使用idle进程
        }
        next->runs++;          // 增加运行次数统计
        if (next != current)   // 如果选择了不同进程
        {
            proc_run(next);   // 执行进程切换
        }
    }
    local_intr_restore(intr_flag);  // 恢复中断
}
