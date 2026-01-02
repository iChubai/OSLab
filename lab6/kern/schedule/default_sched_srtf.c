#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

static void
srtf_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
}

static void
srtf_enqueue(struct run_queue *rq, struct proc_struct *proc)
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
srtf_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

static struct proc_struct *
srtf_pick_next(struct run_queue *rq)
{
    if (list_empty(&(rq->run_list)))
    {
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    struct proc_struct *best = le2proc(le, run_link);
    uint32_t best_rem = best->sched_remaining ? best->sched_remaining : 1;
    while ((le = list_next(le)) != &(rq->run_list))
    {
        struct proc_struct *p = le2proc(le, run_link);
        uint32_t rem = p->sched_remaining ? p->sched_remaining : 1;
        if (rem < best_rem)
        {
            best = p;
            best_rem = rem;
        }
    }
    best->sched_last_start = (uint32_t)ticks;
    return best;
}

static void
srtf_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->sched_expected == 0)
    {
        proc->sched_expected = 1;
    }
    if (proc->sched_remaining > 0)
    {
        proc->sched_remaining--;
    }
    if (proc->sched_remaining == 0)
    {
        proc->need_resched = 1;
        proc->sched_remaining = proc->sched_expected;
    }

    if (!list_empty(&(rq->run_list)))
    {
        list_entry_t *le = list_next(&(rq->run_list));
        uint32_t cur_rem = proc->sched_remaining ? proc->sched_remaining : 1;
        while (le != &(rq->run_list))
        {
            struct proc_struct *p = le2proc(le, run_link);
            uint32_t rem = p->sched_remaining ? p->sched_remaining : 1;
            if (rem < cur_rem)
            {
                proc->need_resched = 1;
                break;
            }
            le = list_next(le);
        }
    }
}

struct sched_class srtf_sched_class = {
    .name = "SRTF_scheduler",
    .init = srtf_init,
    .enqueue = srtf_enqueue,
    .dequeue = srtf_dequeue,
    .pick_next = srtf_pick_next,
    .proc_tick = srtf_proc_tick,
};
