#include <stdio.h>
#include <ulib.h>

int zero = 0;

int
main(void) {
    int result;
    cprintf("About to divide by zero.\n");
    asm volatile("div %0, %1, %2" : "=r"(result) : "r"(1), "r"(zero));
    cprintf("value is %d.\n", result);
    cprintf("Program continues after division.\n");
    return 0;
}

