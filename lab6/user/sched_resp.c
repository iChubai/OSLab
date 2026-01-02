#include <ulib.h>
#include <stdio.h>

#define TASKS 8
#define CPU_TICKS 10

static void
spin_delay(void)
{
    volatile int j = 0;
    int i;
    for (i = 0; i < 200; i++)
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
            sched_set_burst(CPU_TICKS, CPU_TICKS);
            sched_set_nice(0);
            lab6_setpriority(1);

            uint32_t first = gettime_msec();
            int cpu_start = sched_get_runtime();
            int cpu_now = cpu_start;
            while ((cpu_now - cpu_start) < CPU_TICKS)
            {
                spin_delay();
                cpu_now = sched_get_runtime();
            }
            int cpu_used = cpu_now - cpu_start;
            uint32_t end = gettime_msec();

            uint32_t resp = (first - t0) / 10;
            uint32_t turn = (end - t0) / 10;
            int wait = (int)turn - cpu_used;
            if (wait < 0)
            {
                wait = 0;
            }

            cprintf("[sched_resp] pid=%d resp=%u turn=%u cpu=%d wait=%d\n",
                    getpid(), resp, turn, cpu_used, wait);
            exit(cpu_used);
        }
        pids[i] = pid;
    }

    for (i = 0; i < TASKS; i++)
    {
        waitpid(pids[i], NULL);
    }
    cprintf("[sched_resp] done\n");
    return 0;
}
