
obj/__user_sched_mix.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800020:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800022:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  800026:	e42a                	sd	a0,8(sp)
  800028:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  80002a:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  80002c:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  80002e:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  800030:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  800032:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  800034:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  800036:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  800038:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  80003a:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  80003c:	e142                	sd	a6,128(sp)
  80003e:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800040:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);
    asm volatile (
  800042:	4522                	lw	a0,8(sp)
  800044:	55a2                	lw	a1,40(sp)
  800046:	5642                	lw	a2,48(sp)
  800048:	56e2                	lw	a3,56(sp)
  80004a:	4706                	lw	a4,64(sp)
  80004c:	47a6                	lw	a5,72(sp)
  80004e:	00000073          	ecall
  800052:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800054:	4572                	lw	a0,28(sp)
  800056:	6149                	addi	sp,sp,144
  800058:	8082                	ret

000000000080005a <sys_exit>:

int
sys_exit(int64_t error_code) {
  80005a:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80005c:	4505                	li	a0,1
  80005e:	b7c9                	j	800020 <syscall>

0000000000800060 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800060:	4509                	li	a0,2
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  800064:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  800066:	85aa                	mv	a1,a0
  800068:	450d                	li	a0,3
  80006a:	bf5d                	j	800020 <syscall>

000000000080006c <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  80006c:	4529                	li	a0,10
  80006e:	bf4d                	j	800020 <syscall>

0000000000800070 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800070:	4549                	li	a0,18
  800072:	b77d                	j	800020 <syscall>

0000000000800074 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800074:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800076:	4579                	li	a0,30
  800078:	b765                	j	800020 <syscall>

000000000080007a <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  80007a:	4545                	li	a0,17
  80007c:	b755                	j	800020 <syscall>

000000000080007e <sys_lab6_set_priority>:
}

void
sys_lab6_set_priority(uint64_t priority)
{
  80007e:	85aa                	mv	a1,a0
    syscall(SYS_lab6_set_priority, priority);
  800080:	0ff00513          	li	a0,255
  800084:	bf71                	j	800020 <syscall>

0000000000800086 <sys_sched_set_burst>:
}

void
sys_sched_set_burst(uint32_t expected, uint32_t remaining)
{
  800086:	862e                	mv	a2,a1
    syscall(SYS_sched_set_burst, expected, remaining);
  800088:	85aa                	mv	a1,a0
  80008a:	0fd00513          	li	a0,253
  80008e:	bf49                	j	800020 <syscall>

0000000000800090 <sys_sched_set_nice>:
}

void
sys_sched_set_nice(int nice)
{
  800090:	85aa                	mv	a1,a0
    syscall(SYS_sched_set_nice, (uint64_t)nice);
  800092:	0fe00513          	li	a0,254
  800096:	b769                	j	800020 <syscall>

0000000000800098 <sys_sched_get_runtime>:
}

int
sys_sched_get_runtime(void)
{
    return syscall(SYS_sched_get_runtime);
  800098:	0fc00513          	li	a0,252
  80009c:	b751                	j	800020 <syscall>

000000000080009e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80009e:	1141                	addi	sp,sp,-16
  8000a0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000a2:	fb9ff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000a6:	00000517          	auipc	a0,0x0
  8000aa:	62250513          	addi	a0,a0,1570 # 8006c8 <main+0x1b8>
  8000ae:	03a000ef          	jal	8000e8 <cprintf>
    while (1);
  8000b2:	a001                	j	8000b2 <exit+0x14>

00000000008000b4 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000b4:	b775                	j	800060 <sys_fork>

00000000008000b6 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000b6:	b77d                	j	800064 <sys_wait>

00000000008000b8 <yield>:
}

void
yield(void) {
    sys_yield();
  8000b8:	bf55                	j	80006c <sys_yield>

00000000008000ba <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000ba:	bf5d                	j	800070 <sys_getpid>

00000000008000bc <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  8000bc:	bf7d                	j	80007a <sys_gettime>

00000000008000be <lab6_setpriority>:
}

void
lab6_setpriority(uint32_t priority)
{
    sys_lab6_set_priority(priority);
  8000be:	1502                	slli	a0,a0,0x20
  8000c0:	9101                	srli	a0,a0,0x20
  8000c2:	bf75                	j	80007e <sys_lab6_set_priority>

00000000008000c4 <sched_set_burst>:
}

void
sched_set_burst(uint32_t expected, uint32_t remaining)
{
    sys_sched_set_burst(expected, remaining);
  8000c4:	b7c9                	j	800086 <sys_sched_set_burst>

00000000008000c6 <sched_set_nice>:
}

void
sched_set_nice(int nice)
{
    sys_sched_set_nice(nice);
  8000c6:	b7e9                	j	800090 <sys_sched_set_nice>

00000000008000c8 <sched_get_runtime>:
}

int
sched_get_runtime(void)
{
    return sys_sched_get_runtime();
  8000c8:	bfc1                	j	800098 <sys_sched_get_runtime>

00000000008000ca <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000ca:	052000ef          	jal	80011c <umain>
1:  j 1b
  8000ce:	a001                	j	8000ce <_start+0x4>

00000000008000d0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000d0:	1101                	addi	sp,sp,-32
  8000d2:	ec06                	sd	ra,24(sp)
  8000d4:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000d6:	f9fff0ef          	jal	800074 <sys_putc>
    (*cnt) ++;
  8000da:	65a2                	ld	a1,8(sp)
}
  8000dc:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000de:	419c                	lw	a5,0(a1)
  8000e0:	2785                	addiw	a5,a5,1
  8000e2:	c19c                	sw	a5,0(a1)
}
  8000e4:	6105                	addi	sp,sp,32
  8000e6:	8082                	ret

00000000008000e8 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000e8:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000ea:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000ee:	f42e                	sd	a1,40(sp)
  8000f0:	f832                	sd	a2,48(sp)
  8000f2:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f4:	862a                	mv	a2,a0
  8000f6:	004c                	addi	a1,sp,4
  8000f8:	00000517          	auipc	a0,0x0
  8000fc:	fd850513          	addi	a0,a0,-40 # 8000d0 <cputch>
  800100:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800102:	ec06                	sd	ra,24(sp)
  800104:	e0ba                	sd	a4,64(sp)
  800106:	e4be                	sd	a5,72(sp)
  800108:	e8c2                	sd	a6,80(sp)
  80010a:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  80010c:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  80010e:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800110:	09a000ef          	jal	8001aa <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800114:	60e2                	ld	ra,24(sp)
  800116:	4512                	lw	a0,4(sp)
  800118:	6125                	addi	sp,sp,96
  80011a:	8082                	ret

000000000080011c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80011c:	1141                	addi	sp,sp,-16
  80011e:	e406                	sd	ra,8(sp)
    int ret = main();
  800120:	3f0000ef          	jal	800510 <main>
    exit(ret);
  800124:	f7bff0ef          	jal	80009e <exit>

0000000000800128 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800128:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80012a:	e589                	bnez	a1,800134 <strnlen+0xc>
  80012c:	a811                	j	800140 <strnlen+0x18>
        cnt ++;
  80012e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800130:	00f58863          	beq	a1,a5,800140 <strnlen+0x18>
  800134:	00f50733          	add	a4,a0,a5
  800138:	00074703          	lbu	a4,0(a4)
  80013c:	fb6d                	bnez	a4,80012e <strnlen+0x6>
  80013e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800140:	852e                	mv	a0,a1
  800142:	8082                	ret

0000000000800144 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800144:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800146:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014a:	f022                	sd	s0,32(sp)
  80014c:	ec26                	sd	s1,24(sp)
  80014e:	e84a                	sd	s2,16(sp)
  800150:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800152:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800156:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800158:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80015c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	84aa                	mv	s1,a0
  800162:	892e                	mv	s2,a1
    if (num >= base) {
  800164:	03067d63          	bgeu	a2,a6,80019e <printnum+0x5a>
  800168:	e44e                	sd	s3,8(sp)
  80016a:	89be                	mv	s3,a5
        while (-- width > 0)
  80016c:	4785                	li	a5,1
  80016e:	00e7d763          	bge	a5,a4,80017c <printnum+0x38>
            putch(padc, putdat);
  800172:	85ca                	mv	a1,s2
  800174:	854e                	mv	a0,s3
        while (-- width > 0)
  800176:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800178:	9482                	jalr	s1
        while (-- width > 0)
  80017a:	fc65                	bnez	s0,800172 <printnum+0x2e>
  80017c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80017e:	00000797          	auipc	a5,0x0
  800182:	56278793          	addi	a5,a5,1378 # 8006e0 <main+0x1d0>
  800186:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800188:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018a:	0007c503          	lbu	a0,0(a5)
}
  80018e:	70a2                	ld	ra,40(sp)
  800190:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800192:	85ca                	mv	a1,s2
  800194:	87a6                	mv	a5,s1
}
  800196:	6942                	ld	s2,16(sp)
  800198:	64e2                	ld	s1,24(sp)
  80019a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80019e:	03065633          	divu	a2,a2,a6
  8001a2:	8722                	mv	a4,s0
  8001a4:	fa1ff0ef          	jal	800144 <printnum>
  8001a8:	bfd9                	j	80017e <printnum+0x3a>

00000000008001aa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001aa:	7119                	addi	sp,sp,-128
  8001ac:	f4a6                	sd	s1,104(sp)
  8001ae:	f0ca                	sd	s2,96(sp)
  8001b0:	ecce                	sd	s3,88(sp)
  8001b2:	e8d2                	sd	s4,80(sp)
  8001b4:	e4d6                	sd	s5,72(sp)
  8001b6:	e0da                	sd	s6,64(sp)
  8001b8:	f862                	sd	s8,48(sp)
  8001ba:	fc86                	sd	ra,120(sp)
  8001bc:	f8a2                	sd	s0,112(sp)
  8001be:	fc5e                	sd	s7,56(sp)
  8001c0:	f466                	sd	s9,40(sp)
  8001c2:	f06a                	sd	s10,32(sp)
  8001c4:	ec6e                	sd	s11,24(sp)
  8001c6:	84aa                	mv	s1,a0
  8001c8:	8c32                	mv	s8,a2
  8001ca:	8a36                	mv	s4,a3
  8001cc:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ce:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	05500b13          	li	s6,85
  8001d6:	00000a97          	auipc	s5,0x0
  8001da:	686a8a93          	addi	s5,s5,1670 # 80085c <main+0x34c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001de:	000c4503          	lbu	a0,0(s8)
  8001e2:	001c0413          	addi	s0,s8,1
  8001e6:	01350a63          	beq	a0,s3,8001fa <vprintfmt+0x50>
            if (ch == '\0') {
  8001ea:	cd0d                	beqz	a0,800224 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001ec:	85ca                	mv	a1,s2
  8001ee:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f0:	00044503          	lbu	a0,0(s0)
  8001f4:	0405                	addi	s0,s0,1
  8001f6:	ff351ae3          	bne	a0,s3,8001ea <vprintfmt+0x40>
        width = precision = -1;
  8001fa:	5cfd                	li	s9,-1
  8001fc:	8d66                	mv	s10,s9
        char padc = ' ';
  8001fe:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800202:	4b81                	li	s7,0
  800204:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800206:	00044683          	lbu	a3,0(s0)
  80020a:	00140c13          	addi	s8,s0,1
  80020e:	fdd6859b          	addiw	a1,a3,-35
  800212:	0ff5f593          	zext.b	a1,a1
  800216:	02bb6663          	bltu	s6,a1,800242 <vprintfmt+0x98>
  80021a:	058a                	slli	a1,a1,0x2
  80021c:	95d6                	add	a1,a1,s5
  80021e:	4198                	lw	a4,0(a1)
  800220:	9756                	add	a4,a4,s5
  800222:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800224:	70e6                	ld	ra,120(sp)
  800226:	7446                	ld	s0,112(sp)
  800228:	74a6                	ld	s1,104(sp)
  80022a:	7906                	ld	s2,96(sp)
  80022c:	69e6                	ld	s3,88(sp)
  80022e:	6a46                	ld	s4,80(sp)
  800230:	6aa6                	ld	s5,72(sp)
  800232:	6b06                	ld	s6,64(sp)
  800234:	7be2                	ld	s7,56(sp)
  800236:	7c42                	ld	s8,48(sp)
  800238:	7ca2                	ld	s9,40(sp)
  80023a:	7d02                	ld	s10,32(sp)
  80023c:	6de2                	ld	s11,24(sp)
  80023e:	6109                	addi	sp,sp,128
  800240:	8082                	ret
            putch('%', putdat);
  800242:	85ca                	mv	a1,s2
  800244:	02500513          	li	a0,37
  800248:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80024a:	fff44783          	lbu	a5,-1(s0)
  80024e:	02500713          	li	a4,37
  800252:	8c22                	mv	s8,s0
  800254:	f8e785e3          	beq	a5,a4,8001de <vprintfmt+0x34>
  800258:	ffec4783          	lbu	a5,-2(s8)
  80025c:	1c7d                	addi	s8,s8,-1
  80025e:	fee79de3          	bne	a5,a4,800258 <vprintfmt+0xae>
  800262:	bfb5                	j	8001de <vprintfmt+0x34>
                ch = *fmt;
  800264:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800268:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80026a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80026e:	fd06071b          	addiw	a4,a2,-48
  800272:	24e56a63          	bltu	a0,a4,8004c6 <vprintfmt+0x31c>
                ch = *fmt;
  800276:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80027a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80027e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800282:	0197073b          	addw	a4,a4,s9
  800286:	0017171b          	slliw	a4,a4,0x1
  80028a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80028c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800290:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800292:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800296:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80029a:	feb570e3          	bgeu	a0,a1,80027a <vprintfmt+0xd0>
            if (width < 0)
  80029e:	f60d54e3          	bgez	s10,800206 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002a2:	8d66                	mv	s10,s9
  8002a4:	5cfd                	li	s9,-1
  8002a6:	b785                	j	800206 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	8db6                	mv	s11,a3
  8002aa:	8462                	mv	s0,s8
  8002ac:	bfa9                	j	800206 <vprintfmt+0x5c>
  8002ae:	8462                	mv	s0,s8
            altflag = 1;
  8002b0:	4b85                	li	s7,1
            goto reswitch;
  8002b2:	bf91                	j	800206 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ba:	00f74463          	blt	a4,a5,8002c2 <vprintfmt+0x118>
    else if (lflag) {
  8002be:	1a078763          	beqz	a5,80046c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002c2:	000a3603          	ld	a2,0(s4)
  8002c6:	46c1                	li	a3,16
  8002c8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002ca:	000d879b          	sext.w	a5,s11
  8002ce:	876a                	mv	a4,s10
  8002d0:	85ca                	mv	a1,s2
  8002d2:	8526                	mv	a0,s1
  8002d4:	e71ff0ef          	jal	800144 <printnum>
            break;
  8002d8:	b719                	j	8001de <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002da:	000a2503          	lw	a0,0(s4)
  8002de:	85ca                	mv	a1,s2
  8002e0:	0a21                	addi	s4,s4,8
  8002e2:	9482                	jalr	s1
            break;
  8002e4:	bded                	j	8001de <vprintfmt+0x34>
    if (lflag >= 2) {
  8002e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ec:	00f74463          	blt	a4,a5,8002f4 <vprintfmt+0x14a>
    else if (lflag) {
  8002f0:	16078963          	beqz	a5,800462 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002f4:	000a3603          	ld	a2,0(s4)
  8002f8:	46a9                	li	a3,10
  8002fa:	8a2e                	mv	s4,a1
  8002fc:	b7f9                	j	8002ca <vprintfmt+0x120>
            putch('0', putdat);
  8002fe:	85ca                	mv	a1,s2
  800300:	03000513          	li	a0,48
  800304:	9482                	jalr	s1
            putch('x', putdat);
  800306:	85ca                	mv	a1,s2
  800308:	07800513          	li	a0,120
  80030c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80030e:	000a3603          	ld	a2,0(s4)
            goto number;
  800312:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800314:	0a21                	addi	s4,s4,8
            goto number;
  800316:	bf55                	j	8002ca <vprintfmt+0x120>
            putch(ch, putdat);
  800318:	85ca                	mv	a1,s2
  80031a:	02500513          	li	a0,37
  80031e:	9482                	jalr	s1
            break;
  800320:	bd7d                	j	8001de <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800322:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800326:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800328:	0a21                	addi	s4,s4,8
            goto process_precision;
  80032a:	bf95                	j	80029e <vprintfmt+0xf4>
    if (lflag >= 2) {
  80032c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80032e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800332:	00f74463          	blt	a4,a5,80033a <vprintfmt+0x190>
    else if (lflag) {
  800336:	12078163          	beqz	a5,800458 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80033a:	000a3603          	ld	a2,0(s4)
  80033e:	46a1                	li	a3,8
  800340:	8a2e                	mv	s4,a1
  800342:	b761                	j	8002ca <vprintfmt+0x120>
            if (width < 0)
  800344:	876a                	mv	a4,s10
  800346:	000d5363          	bgez	s10,80034c <vprintfmt+0x1a2>
  80034a:	4701                	li	a4,0
  80034c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800350:	8462                	mv	s0,s8
            goto reswitch;
  800352:	bd55                	j	800206 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800354:	000d841b          	sext.w	s0,s11
  800358:	fd340793          	addi	a5,s0,-45
  80035c:	00f037b3          	snez	a5,a5
  800360:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800364:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800368:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80036a:	008a0793          	addi	a5,s4,8
  80036e:	e43e                	sd	a5,8(sp)
  800370:	100d8c63          	beqz	s11,800488 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800374:	12071363          	bnez	a4,80049a <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800378:	000dc783          	lbu	a5,0(s11)
  80037c:	0007851b          	sext.w	a0,a5
  800380:	c78d                	beqz	a5,8003aa <vprintfmt+0x200>
  800382:	0d85                	addi	s11,s11,1
  800384:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800386:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	000cc563          	bltz	s9,800394 <vprintfmt+0x1ea>
  80038e:	3cfd                	addiw	s9,s9,-1
  800390:	008c8d63          	beq	s9,s0,8003aa <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800394:	020b9663          	bnez	s7,8003c0 <vprintfmt+0x216>
                    putch(ch, putdat);
  800398:	85ca                	mv	a1,s2
  80039a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039c:	000dc783          	lbu	a5,0(s11)
  8003a0:	0d85                	addi	s11,s11,1
  8003a2:	3d7d                	addiw	s10,s10,-1
  8003a4:	0007851b          	sext.w	a0,a5
  8003a8:	f3ed                	bnez	a5,80038a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003aa:	01a05963          	blez	s10,8003bc <vprintfmt+0x212>
                putch(' ', putdat);
  8003ae:	85ca                	mv	a1,s2
  8003b0:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003b4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003b6:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003b8:	fe0d1be3          	bnez	s10,8003ae <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003bc:	6a22                	ld	s4,8(sp)
  8003be:	b505                	j	8001de <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c0:	3781                	addiw	a5,a5,-32
  8003c2:	fcfa7be3          	bgeu	s4,a5,800398 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003c6:	03f00513          	li	a0,63
  8003ca:	85ca                	mv	a1,s2
  8003cc:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ce:	000dc783          	lbu	a5,0(s11)
  8003d2:	0d85                	addi	s11,s11,1
  8003d4:	3d7d                	addiw	s10,s10,-1
  8003d6:	0007851b          	sext.w	a0,a5
  8003da:	dbe1                	beqz	a5,8003aa <vprintfmt+0x200>
  8003dc:	fa0cd9e3          	bgez	s9,80038e <vprintfmt+0x1e4>
  8003e0:	b7c5                	j	8003c0 <vprintfmt+0x216>
            if (err < 0) {
  8003e2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e6:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003e8:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003ea:	41f7d71b          	sraiw	a4,a5,0x1f
  8003ee:	8fb9                	xor	a5,a5,a4
  8003f0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f4:	02d64563          	blt	a2,a3,80041e <vprintfmt+0x274>
  8003f8:	00000797          	auipc	a5,0x0
  8003fc:	5c078793          	addi	a5,a5,1472 # 8009b8 <error_string>
  800400:	00369713          	slli	a4,a3,0x3
  800404:	97ba                	add	a5,a5,a4
  800406:	639c                	ld	a5,0(a5)
  800408:	cb99                	beqz	a5,80041e <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80040a:	86be                	mv	a3,a5
  80040c:	00000617          	auipc	a2,0x0
  800410:	30c60613          	addi	a2,a2,780 # 800718 <main+0x208>
  800414:	85ca                	mv	a1,s2
  800416:	8526                	mv	a0,s1
  800418:	0d8000ef          	jal	8004f0 <printfmt>
  80041c:	b3c9                	j	8001de <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80041e:	00000617          	auipc	a2,0x0
  800422:	2ea60613          	addi	a2,a2,746 # 800708 <main+0x1f8>
  800426:	85ca                	mv	a1,s2
  800428:	8526                	mv	a0,s1
  80042a:	0c6000ef          	jal	8004f0 <printfmt>
  80042e:	bb45                	j	8001de <vprintfmt+0x34>
    if (lflag >= 2) {
  800430:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800432:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800436:	00f74363          	blt	a4,a5,80043c <vprintfmt+0x292>
    else if (lflag) {
  80043a:	cf81                	beqz	a5,800452 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80043c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800440:	02044b63          	bltz	s0,800476 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800444:	8622                	mv	a2,s0
  800446:	8a5e                	mv	s4,s7
  800448:	46a9                	li	a3,10
  80044a:	b541                	j	8002ca <vprintfmt+0x120>
            lflag ++;
  80044c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80044e:	8462                	mv	s0,s8
            goto reswitch;
  800450:	bb5d                	j	800206 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800452:	000a2403          	lw	s0,0(s4)
  800456:	b7ed                	j	800440 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800458:	000a6603          	lwu	a2,0(s4)
  80045c:	46a1                	li	a3,8
  80045e:	8a2e                	mv	s4,a1
  800460:	b5ad                	j	8002ca <vprintfmt+0x120>
  800462:	000a6603          	lwu	a2,0(s4)
  800466:	46a9                	li	a3,10
  800468:	8a2e                	mv	s4,a1
  80046a:	b585                	j	8002ca <vprintfmt+0x120>
  80046c:	000a6603          	lwu	a2,0(s4)
  800470:	46c1                	li	a3,16
  800472:	8a2e                	mv	s4,a1
  800474:	bd99                	j	8002ca <vprintfmt+0x120>
                putch('-', putdat);
  800476:	85ca                	mv	a1,s2
  800478:	02d00513          	li	a0,45
  80047c:	9482                	jalr	s1
                num = -(long long)num;
  80047e:	40800633          	neg	a2,s0
  800482:	8a5e                	mv	s4,s7
  800484:	46a9                	li	a3,10
  800486:	b591                	j	8002ca <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800488:	e329                	bnez	a4,8004ca <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048a:	02800793          	li	a5,40
  80048e:	853e                	mv	a0,a5
  800490:	00000d97          	auipc	s11,0x0
  800494:	269d8d93          	addi	s11,s11,617 # 8006f9 <main+0x1e9>
  800498:	b5f5                	j	800384 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049a:	85e6                	mv	a1,s9
  80049c:	856e                	mv	a0,s11
  80049e:	c8bff0ef          	jal	800128 <strnlen>
  8004a2:	40ad0d3b          	subw	s10,s10,a0
  8004a6:	01a05863          	blez	s10,8004b6 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004aa:	85ca                	mv	a1,s2
  8004ac:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004b0:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	fe0d1ce3          	bnez	s10,8004aa <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b6:	000dc783          	lbu	a5,0(s11)
  8004ba:	0007851b          	sext.w	a0,a5
  8004be:	ec0792e3          	bnez	a5,800382 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004c2:	6a22                	ld	s4,8(sp)
  8004c4:	bb29                	j	8001de <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004c6:	8462                	mv	s0,s8
  8004c8:	bbd9                	j	80029e <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	85e6                	mv	a1,s9
  8004cc:	00000517          	auipc	a0,0x0
  8004d0:	22c50513          	addi	a0,a0,556 # 8006f8 <main+0x1e8>
  8004d4:	c55ff0ef          	jal	800128 <strnlen>
  8004d8:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004dc:	02800793          	li	a5,40
                p = "(null)";
  8004e0:	00000d97          	auipc	s11,0x0
  8004e4:	218d8d93          	addi	s11,s11,536 # 8006f8 <main+0x1e8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ea:	fda040e3          	bgtz	s10,8004aa <vprintfmt+0x300>
  8004ee:	bd51                	j	800382 <vprintfmt+0x1d8>

00000000008004f0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004f2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004fa:	ec06                	sd	ra,24(sp)
  8004fc:	f83a                	sd	a4,48(sp)
  8004fe:	fc3e                	sd	a5,56(sp)
  800500:	e0c2                	sd	a6,64(sp)
  800502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800504:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800506:	ca5ff0ef          	jal	8001aa <vprintfmt>
}
  80050a:	60e2                	ld	ra,24(sp)
  80050c:	6161                	addi	sp,sp,80
  80050e:	8082                	ret

0000000000800510 <main>:
    }
}

int
main(void)
{
  800510:	7119                	addi	sp,sp,-128
  800512:	f8a2                	sd	s0,112(sp)
  800514:	f4a6                	sd	s1,104(sp)
  800516:	f0ca                	sd	s2,96(sp)
  800518:	ecce                	sd	s3,88(sp)
  80051a:	e8d2                	sd	s4,80(sp)
  80051c:	fc86                	sd	ra,120(sp)
  80051e:	1000                	addi	s0,sp,32
    uint32_t t0 = gettime_msec();
  800520:	b9dff0ef          	jal	8000bc <gettime_msec>
  800524:	8a2a                	mv	s4,a0
  800526:	8922                	mv	s2,s0
    int pids[TASKS];
    int i;

    for (i = 0; i < TASKS; i++)
  800528:	4481                	li	s1,0
  80052a:	4991                	li	s3,4
    {
        int pid = fork();
  80052c:	b89ff0ef          	jal	8000b4 <fork>
        if (pid == 0)
  800530:	cd1d                	beqz	a0,80056e <main+0x5e>

            cprintf("[sched_mix] pid=%d type=%s nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d loops=%d\n",
                    getpid(), is_io[i] ? "IO" : "CPU", nice_vals[i], prio_vals[i], resp, turn, cpu_used, wait, loops);
            exit(cpu_used);
        }
        pids[i] = pid;
  800532:	00a92023          	sw	a0,0(s2)
    for (i = 0; i < TASKS; i++)
  800536:	2485                	addiw	s1,s1,1
  800538:	0911                	addi	s2,s2,4
  80053a:	ff3499e3          	bne	s1,s3,80052c <main+0x1c>
  80053e:	01040493          	addi	s1,s0,16
    }

    for (i = 0; i < TASKS; i++)
    {
        waitpid(pids[i], NULL);
  800542:	4008                	lw	a0,0(s0)
  800544:	4581                	li	a1,0
    for (i = 0; i < TASKS; i++)
  800546:	0411                	addi	s0,s0,4
        waitpid(pids[i], NULL);
  800548:	b6fff0ef          	jal	8000b6 <waitpid>
    for (i = 0; i < TASKS; i++)
  80054c:	fe941be3          	bne	s0,s1,800542 <main+0x32>
    }
    cprintf("[sched_mix] done\n");
  800550:	00000517          	auipc	a0,0x0
  800554:	2f850513          	addi	a0,a0,760 # 800848 <main+0x338>
  800558:	b91ff0ef          	jal	8000e8 <cprintf>
    return 0;
}
  80055c:	70e6                	ld	ra,120(sp)
  80055e:	7446                	ld	s0,112(sp)
  800560:	74a6                	ld	s1,104(sp)
  800562:	7906                	ld	s2,96(sp)
  800564:	69e6                	ld	s3,88(sp)
  800566:	6a46                	ld	s4,80(sp)
  800568:	4501                	li	a0,0
  80056a:	6109                	addi	sp,sp,128
  80056c:	8082                	ret
            sched_set_burst(cpu_ticks[i], cpu_ticks[i]);
  80056e:	048a                	slli	s1,s1,0x2
  800570:	00000797          	auipc	a5,0x0
  800574:	53078793          	addi	a5,a5,1328 # 800aa0 <cpu_ticks>
  800578:	97a6                	add	a5,a5,s1
  80057a:	439c                	lw	a5,0(a5)
  80057c:	e0da                	sd	s6,64(sp)
  80057e:	fc5e                	sd	s7,56(sp)
  800580:	85be                	mv	a1,a5
  800582:	853e                	mv	a0,a5
  800584:	f862                	sd	s8,48(sp)
  800586:	8b3e                	mv	s6,a5
  800588:	e4d6                	sd	s5,72(sp)
  80058a:	b3bff0ef          	jal	8000c4 <sched_set_burst>
            sched_set_nice(nice_vals[i]);
  80058e:	00000797          	auipc	a5,0x0
  800592:	50278793          	addi	a5,a5,1282 # 800a90 <nice_vals>
  800596:	97a6                	add	a5,a5,s1
  800598:	439c                	lw	a5,0(a5)
  80059a:	853e                	mv	a0,a5
  80059c:	8bbe                	mv	s7,a5
  80059e:	b29ff0ef          	jal	8000c6 <sched_set_nice>
            lab6_setpriority(prio_vals[i]);
  8005a2:	00000797          	auipc	a5,0x0
  8005a6:	4de78793          	addi	a5,a5,1246 # 800a80 <prio_vals>
  8005aa:	97a6                	add	a5,a5,s1
  8005ac:	439c                	lw	a5,0(a5)
  8005ae:	853e                	mv	a0,a5
  8005b0:	8c3e                	mv	s8,a5
  8005b2:	b0dff0ef          	jal	8000be <lab6_setpriority>
            uint32_t first = gettime_msec();
  8005b6:	b07ff0ef          	jal	8000bc <gettime_msec>
  8005ba:	892a                	mv	s2,a0
            int cpu_start = sched_get_runtime();
  8005bc:	b0dff0ef          	jal	8000c8 <sched_get_runtime>
            if (is_io[i])
  8005c0:	00000797          	auipc	a5,0x0
  8005c4:	4f078793          	addi	a5,a5,1264 # 800ab0 <is_io>
  8005c8:	97a6                	add	a5,a5,s1
  8005ca:	4384                	lw	s1,0(a5)
            int cpu_start = sched_get_runtime();
  8005cc:	89aa                	mv	s3,a0
            if (is_io[i])
  8005ce:	ecb5                	bnez	s1,80064a <main+0x13a>
                int cpu_now = cpu_start;
  8005d0:	87aa                	mv	a5,a0
    for (i = 0; i < 300; i++)
  8005d2:	12c00413          	li	s0,300
                while ((cpu_now - cpu_start) < (int)cpu_ticks[i])
  8005d6:	413787bb          	subw	a5,a5,s3
  8005da:	8abe                	mv	s5,a5
  8005dc:	0167de63          	bge	a5,s6,8005f8 <main+0xe8>
    volatile int j = 0;
  8005e0:	ce02                	sw	zero,28(sp)
    for (i = 0; i < 300; i++)
  8005e2:	4781                	li	a5,0
        j += i;
  8005e4:	4772                	lw	a4,28(sp)
  8005e6:	9f3d                	addw	a4,a4,a5
  8005e8:	ce3a                	sw	a4,28(sp)
    for (i = 0; i < 300; i++)
  8005ea:	2785                	addiw	a5,a5,1
  8005ec:	fe879ce3          	bne	a5,s0,8005e4 <main+0xd4>
                    cpu_now = sched_get_runtime();
  8005f0:	ad9ff0ef          	jal	8000c8 <sched_get_runtime>
  8005f4:	87aa                	mv	a5,a0
  8005f6:	b7c5                	j	8005d6 <main+0xc6>
            uint32_t end = gettime_msec();
  8005f8:	ac5ff0ef          	jal	8000bc <gettime_msec>
            uint32_t resp = (first - t0) / 10;
  8005fc:	47a9                	li	a5,10
            uint32_t turn = (end - t0) / 10;
  8005fe:	4145043b          	subw	s0,a0,s4
  800602:	02f4543b          	divuw	s0,s0,a5
            uint32_t resp = (first - t0) / 10;
  800606:	4149093b          	subw	s2,s2,s4
  80060a:	02f9593b          	divuw	s2,s2,a5
            int wait = (int)turn - cpu_used;
  80060e:	415407bb          	subw	a5,s0,s5
  800612:	0007899b          	sext.w	s3,a5
            if (wait < 0)
  800616:	0007d363          	bgez	a5,80061c <main+0x10c>
  80061a:	4981                	li	s3,0
            cprintf("[sched_mix] pid=%d type=%s nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d loops=%d\n",
  80061c:	a9fff0ef          	jal	8000ba <getpid>
  800620:	85aa                	mv	a1,a0
  800622:	00000617          	auipc	a2,0x0
  800626:	1c660613          	addi	a2,a2,454 # 8007e8 <main+0x2d8>
  80062a:	e426                	sd	s1,8(sp)
  80062c:	e04e                	sd	s3,0(sp)
  80062e:	8822                	mv	a6,s0
  800630:	87ca                	mv	a5,s2
  800632:	8762                	mv	a4,s8
  800634:	86de                	mv	a3,s7
  800636:	88d6                	mv	a7,s5
  800638:	00000517          	auipc	a0,0x0
  80063c:	1b850513          	addi	a0,a0,440 # 8007f0 <main+0x2e0>
  800640:	aa9ff0ef          	jal	8000e8 <cprintf>
            exit(cpu_used);
  800644:	8556                	mv	a0,s5
  800646:	a59ff0ef          	jal	80009e <exit>
            int loops = 0;
  80064a:	4481                	li	s1,0
    for (i = 0; i < 300; i++)
  80064c:	12c00413          	li	s0,300
                while ((gettime_msec() - t0) < IO_DURATION_MS)
  800650:	a6dff0ef          	jal	8000bc <gettime_msec>
  800654:	414507bb          	subw	a5,a0,s4
  800658:	7cf00713          	li	a4,1999
  80065c:	02f76463          	bltu	a4,a5,800684 <main+0x174>
  800660:	4691                	li	a3,4
    volatile int j = 0;
  800662:	cc02                	sw	zero,24(sp)
    for (i = 0; i < 300; i++)
  800664:	4781                	li	a5,0
        j += i;
  800666:	4762                	lw	a4,24(sp)
  800668:	9f3d                	addw	a4,a4,a5
  80066a:	cc3a                	sw	a4,24(sp)
    for (i = 0; i < 300; i++)
  80066c:	2785                	addiw	a5,a5,1
  80066e:	fe879ce3          	bne	a5,s0,800666 <main+0x156>
                    for (k = 0; k < 4; k++)
  800672:	36fd                	addiw	a3,a3,-1
  800674:	f6fd                	bnez	a3,800662 <main+0x152>
                    loops++;
  800676:	2485                	addiw	s1,s1,1
                    if ((loops & 1) == 0)
  800678:	0014f793          	andi	a5,s1,1
  80067c:	fbf1                	bnez	a5,800650 <main+0x140>
                        yield();
  80067e:	a3bff0ef          	jal	8000b8 <yield>
  800682:	b7f9                	j	800650 <main+0x140>
                cpu_used = sched_get_runtime() - cpu_start;
  800684:	a45ff0ef          	jal	8000c8 <sched_get_runtime>
  800688:	413509bb          	subw	s3,a0,s3
            uint32_t end = gettime_msec();
  80068c:	a31ff0ef          	jal	8000bc <gettime_msec>
            uint32_t resp = (first - t0) / 10;
  800690:	47a9                	li	a5,10
            uint32_t turn = (end - t0) / 10;
  800692:	4145043b          	subw	s0,a0,s4
  800696:	02f4543b          	divuw	s0,s0,a5
            uint32_t resp = (first - t0) / 10;
  80069a:	4149093b          	subw	s2,s2,s4
                cpu_used = sched_get_runtime() - cpu_start;
  80069e:	8ace                	mv	s5,s3
            uint32_t resp = (first - t0) / 10;
  8006a0:	02f9593b          	divuw	s2,s2,a5
            int wait = (int)turn - cpu_used;
  8006a4:	413407bb          	subw	a5,s0,s3
  8006a8:	0007899b          	sext.w	s3,a5
            if (wait < 0)
  8006ac:	0007d363          	bgez	a5,8006b2 <main+0x1a2>
  8006b0:	4981                	li	s3,0
            cprintf("[sched_mix] pid=%d type=%s nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d loops=%d\n",
  8006b2:	a09ff0ef          	jal	8000ba <getpid>
  8006b6:	85aa                	mv	a1,a0
  8006b8:	00000617          	auipc	a2,0x0
  8006bc:	12860613          	addi	a2,a2,296 # 8007e0 <main+0x2d0>
  8006c0:	b7ad                	j	80062a <main+0x11a>
