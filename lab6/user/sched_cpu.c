#include <ulib.h>
#include <stdio.h>

#define SHORT_TASKS 2

static const uint32_t long_ticks = 120;
static const uint32_t short_ticks[SHORT_TASKS] = {30, 40};
static const int long_nice = 0;
static const int short_nice[SHORT_TASKS] = {5, -5};
static const uint32_t long_prio = 1;
static const uint32_t short_prio[SHORT_TASKS] = {2, 3};

static uint32_t g_t0;

static void
spin_delay(void)
{
    volatile int j = 0;
    int i;
    for (i = 0; i < 500; i++)
    {
        j += i;
    }
}

static void
run_short_task(int idx)
{
    sched_set_burst(short_ticks[idx], short_ticks[idx]);
    sched_set_nice(short_nice[idx]);
    lab6_setpriority(short_prio[idx]);

    uint32_t first = gettime_msec();
    int cpu_start = sched_get_runtime();
    int cpu_now = cpu_start;
    while ((cpu_now - cpu_start) < (int)short_ticks[idx])
    {
        spin_delay();
        cpu_now = sched_get_runtime();
    }
    int cpu_used = cpu_now - cpu_start;
    uint32_t end = gettime_msec();

    uint32_t resp = (first - g_t0) / 10;
    uint32_t turn = (end - g_t0) / 10;
    int wait = (int)turn - cpu_used;
    if (wait < 0)
    {
        wait = 0;
    }

    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
            getpid(), short_ticks[idx], short_nice[idx], short_prio[idx], resp, turn, cpu_used, wait);
    exit(cpu_used);
}

static void
run_long_task(void)
{
    int short_pids[SHORT_TASKS];
    int i;
    int spawned = 0;

    for (i = 0; i < SHORT_TASKS; i++)
    {
        short_pids[i] = -1;
    }

    sched_set_burst(long_ticks, long_ticks);
    sched_set_nice(long_nice);
    lab6_setpriority(long_prio);

    uint32_t first = gettime_msec();
    int cpu_start = sched_get_runtime();
    int cpu_now = cpu_start;

    while ((cpu_now - cpu_start) < (int)long_ticks)
    {
        if (!spawned && (cpu_now - cpu_start) >= 20)
        {
            for (i = 0; i < SHORT_TASKS; i++)
            {
                int pid = fork();
                if (pid == 0)
                {
                    run_short_task(i);
                }
                short_pids[i] = pid;
            }
            spawned = 1;
        }
        spin_delay();
        cpu_now = sched_get_runtime();
    }

    int cpu_used = cpu_now - cpu_start;
    uint32_t end = gettime_msec();

    uint32_t resp = (first - g_t0) / 10;
    uint32_t turn = (end - g_t0) / 10;
    int wait = (int)turn - cpu_used;
    if (wait < 0)
    {
        wait = 0;
    }

    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
            getpid(), long_ticks, long_nice, long_prio, resp, turn, cpu_used, wait);

    if (spawned)
    {
        for (i = 0; i < SHORT_TASKS; i++)
        {
            if (short_pids[i] > 0)
            {
                waitpid(short_pids[i], NULL);
            }
        }
    }
    exit(cpu_used);
}

int
main(void)
{
    g_t0 = gettime_msec();
    int pid = fork();
    if (pid == 0)
    {
        run_long_task();
    }
    waitpid(pid, NULL);
    cprintf("[sched_cpu] done\n");
    return 0;
}
