#include <stdio.h>
#include <ulib.h>

int main(void) {
    int *p = (int *)0x1000;
    *p = 1;
    int pid = fork();
    if (pid == 0) {
        cprintf("[cow] child before write: %d\n", *p);
        *p = 2;
        cprintf("[cow] child after write: %d\n", *p);
        exit(0);
    }
    assert(pid > 0);
    wait();
    cprintf("[cow] parent after child write: %d\n", *p);
    cprintf("[cow] pass\n");
    return 0;
}
