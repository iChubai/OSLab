#include <ulib.h>
#include <stdio.h>

#define TASKS 4
#define IO_DURATION_MS 2000

static const int is_io[TASKS] = {0, 0, 1, 1};
static const uint32_t cpu_ticks[TASKS] = {80, 80, 5, 5};
static const int nice_vals[TASKS] = {5, 0, -10, -10};
static const uint32_t prio_vals[TASKS] = {1, 2, 3, 3};

static void
spin_delay(void)
{
    volatile int j = 0;
    int i;
    for (i = 0; i < 300; i++)
    {
        j += i;
    }
}

int
main(void)
{
    uint32_t t0 = gettime_msec();
    int pids[TASKS];
    int i;

    for (i = 0; i < TASKS; i++)
    {
        int pid = fork();
        if (pid == 0)
        {
            sched_set_burst(cpu_ticks[i], cpu_ticks[i]);
            sched_set_nice(nice_vals[i]);
            lab6_setpriority(prio_vals[i]);

            uint32_t first = gettime_msec();
            int cpu_start = sched_get_runtime();
            int cpu_used = 0;
            int loops = 0;

            if (is_io[i])
            {
                while ((gettime_msec() - t0) < IO_DURATION_MS)
                {
                    int k;
                    for (k = 0; k < 4; k++)
                    {
                        spin_delay();
                    }
                    loops++;
                    if ((loops & 1) == 0)
                    {
                        yield();
                    }
                }
                cpu_used = sched_get_runtime() - cpu_start;
            }
            else
            {
                int cpu_now = cpu_start;
                while ((cpu_now - cpu_start) < (int)cpu_ticks[i])
                {
                    spin_delay();
                    cpu_now = sched_get_runtime();
                }
                cpu_used = cpu_now - cpu_start;
            }

            uint32_t end = gettime_msec();
            uint32_t resp = (first - t0) / 10;
            uint32_t turn = (end - t0) / 10;
            int wait = (int)turn - cpu_used;
            if (wait < 0)
            {
                wait = 0;
            }

            cprintf("[sched_mix] pid=%d type=%s nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d loops=%d\n",
                    getpid(), is_io[i] ? "IO" : "CPU", nice_vals[i], prio_vals[i], resp, turn, cpu_used, wait, loops);
            exit(cpu_used);
        }
        pids[i] = pid;
    }

    for (i = 0; i < TASKS; i++)
    {
        waitpid(pids[i], NULL);
    }
    cprintf("[sched_mix] done\n");
    return 0;
}
