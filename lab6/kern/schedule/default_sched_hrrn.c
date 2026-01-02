#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

static void
hrrn_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
}

static void
hrrn_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->sched_expected == 0)
    {
        proc->sched_expected = 1;
    }
    proc->sched_wait_start = (uint32_t)ticks;
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
}

static void
hrrn_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

static struct proc_struct *
hrrn_pick_next(struct run_queue *rq)
{
    if (list_empty(&(rq->run_list)))
    {
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    struct proc_struct *best = le2proc(le, run_link);
    uint32_t best_expect = best->sched_expected ? best->sched_expected : 1;
    uint32_t best_wait = (uint32_t)ticks - best->sched_wait_start;
    uint64_t best_score = ((uint64_t)(best_wait + best_expect) * 1000) / best_expect;

    while ((le = list_next(le)) != &(rq->run_list))
    {
        struct proc_struct *p = le2proc(le, run_link);
        uint32_t expect = p->sched_expected ? p->sched_expected : 1;
        uint32_t wait = (uint32_t)ticks - p->sched_wait_start;
        uint64_t score = ((uint64_t)(wait + expect) * 1000) / expect;
        if (score > best_score)
        {
            best = p;
            best_score = score;
        }
    }
    best->sched_last_start = (uint32_t)ticks;
    return best;
}

static void
hrrn_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    (void)rq;
    (void)proc;
    // non-preemptive: no tick-based reschedule
}

struct sched_class hrrn_sched_class = {
    .name = "HRRN_scheduler",
    .init = hrrn_init,
    .enqueue = hrrn_enqueue,
    .dequeue = hrrn_dequeue,
    .pick_next = hrrn_pick_next,
    .proc_tick = hrrn_proc_tick,
};
