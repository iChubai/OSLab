#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

static void
fifo_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
}

static void
fifo_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
    {
        proc->time_slice = rq->max_time_slice;
    }
    proc->sched_wait_start = (uint32_t)ticks;
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
}

static void
fifo_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

static struct proc_struct *
fifo_pick_next(struct run_queue *rq)
{
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list))
    {
        struct proc_struct *p = le2proc(le, run_link);
        p->sched_last_start = (uint32_t)ticks;
        return p;
    }
    return NULL;
}

static void
fifo_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    (void)rq;
    (void)proc;
    // non-preemptive: no tick-based reschedule
}

struct sched_class fifo_sched_class = {
    .name = "FIFO_scheduler",
    .init = fifo_init,
    .enqueue = fifo_enqueue,
    .dequeue = fifo_dequeue,
    .pick_next = fifo_pick_next,
    .proc_tick = fifo_proc_tick,
};
