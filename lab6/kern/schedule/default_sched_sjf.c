#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

static void
sjf_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
}

static void
sjf_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->sched_expected == 0)
    {
        proc->sched_expected = 1;
    }
    if (proc->sched_remaining == 0)
    {
        proc->sched_remaining = proc->sched_expected;
    }
    proc->sched_wait_start = (uint32_t)ticks;
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
}

static void
sjf_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

static struct proc_struct *
sjf_pick_next(struct run_queue *rq)
{
    if (list_empty(&(rq->run_list)))
    {
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    struct proc_struct *best = le2proc(le, run_link);
    uint32_t best_expect = best->sched_expected ? best->sched_expected : 1;
    while ((le = list_next(le)) != &(rq->run_list))
    {
        struct proc_struct *p = le2proc(le, run_link);
        uint32_t expect = p->sched_expected ? p->sched_expected : 1;
        if (expect < best_expect)
        {
            best = p;
            best_expect = expect;
        }
    }
    best->sched_last_start = (uint32_t)ticks;
    return best;
}

static void
sjf_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    (void)rq;
    (void)proc;
    // non-preemptive: no tick-based reschedule
}

struct sched_class sjf_sched_class = {
    .name = "SJF_scheduler",
    .init = sjf_init,
    .enqueue = sjf_enqueue,
    .dequeue = sjf_dequeue,
    .pick_next = sjf_pick_next,
    .proc_tick = sjf_proc_tick,
};
