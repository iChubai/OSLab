
obj/__user_sched_cpu.out:     file format elf64-littleriscv


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

000000000080006c <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80006c:	4549                	li	a0,18
  80006e:	bf4d                	j	800020 <syscall>

0000000000800070 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800070:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800072:	4579                	li	a0,30
  800074:	b775                	j	800020 <syscall>

0000000000800076 <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  800076:	4545                	li	a0,17
  800078:	b765                	j	800020 <syscall>

000000000080007a <sys_lab6_set_priority>:
}

void
sys_lab6_set_priority(uint64_t priority)
{
  80007a:	85aa                	mv	a1,a0
    syscall(SYS_lab6_set_priority, priority);
  80007c:	0ff00513          	li	a0,255
  800080:	b745                	j	800020 <syscall>

0000000000800082 <sys_sched_set_burst>:
}

void
sys_sched_set_burst(uint32_t expected, uint32_t remaining)
{
  800082:	862e                	mv	a2,a1
    syscall(SYS_sched_set_burst, expected, remaining);
  800084:	85aa                	mv	a1,a0
  800086:	0fd00513          	li	a0,253
  80008a:	bf59                	j	800020 <syscall>

000000000080008c <sys_sched_set_nice>:
}

void
sys_sched_set_nice(int nice)
{
  80008c:	85aa                	mv	a1,a0
    syscall(SYS_sched_set_nice, (uint64_t)nice);
  80008e:	0fe00513          	li	a0,254
  800092:	b779                	j	800020 <syscall>

0000000000800094 <sys_sched_get_runtime>:
}

int
sys_sched_get_runtime(void)
{
    return syscall(SYS_sched_get_runtime);
  800094:	0fc00513          	li	a0,252
  800098:	b761                	j	800020 <syscall>

000000000080009a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80009a:	1141                	addi	sp,sp,-16
  80009c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80009e:	fbdff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000a2:	00000517          	auipc	a0,0x0
  8000a6:	67650513          	addi	a0,a0,1654 # 800718 <main+0x20e>
  8000aa:	038000ef          	jal	8000e2 <cprintf>
    while (1);
  8000ae:	a001                	j	8000ae <exit+0x14>

00000000008000b0 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000b0:	bf45                	j	800060 <sys_fork>

00000000008000b2 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000b2:	bf4d                	j	800064 <sys_wait>

00000000008000b4 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000b4:	bf65                	j	80006c <sys_getpid>

00000000008000b6 <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  8000b6:	b7c1                	j	800076 <sys_gettime>

00000000008000b8 <lab6_setpriority>:
}

void
lab6_setpriority(uint32_t priority)
{
    sys_lab6_set_priority(priority);
  8000b8:	1502                	slli	a0,a0,0x20
  8000ba:	9101                	srli	a0,a0,0x20
  8000bc:	bf7d                	j	80007a <sys_lab6_set_priority>

00000000008000be <sched_set_burst>:
}

void
sched_set_burst(uint32_t expected, uint32_t remaining)
{
    sys_sched_set_burst(expected, remaining);
  8000be:	b7d1                	j	800082 <sys_sched_set_burst>

00000000008000c0 <sched_set_nice>:
}

void
sched_set_nice(int nice)
{
    sys_sched_set_nice(nice);
  8000c0:	b7f1                	j	80008c <sys_sched_set_nice>

00000000008000c2 <sched_get_runtime>:
}

int
sched_get_runtime(void)
{
    return sys_sched_get_runtime();
  8000c2:	bfc9                	j	800094 <sys_sched_get_runtime>

00000000008000c4 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000c4:	052000ef          	jal	800116 <umain>
1:  j 1b
  8000c8:	a001                	j	8000c8 <_start+0x4>

00000000008000ca <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000ca:	1101                	addi	sp,sp,-32
  8000cc:	ec06                	sd	ra,24(sp)
  8000ce:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000d0:	fa1ff0ef          	jal	800070 <sys_putc>
    (*cnt) ++;
  8000d4:	65a2                	ld	a1,8(sp)
}
  8000d6:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000d8:	419c                	lw	a5,0(a1)
  8000da:	2785                	addiw	a5,a5,1
  8000dc:	c19c                	sw	a5,0(a1)
}
  8000de:	6105                	addi	sp,sp,32
  8000e0:	8082                	ret

00000000008000e2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000e2:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000e4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000e8:	f42e                	sd	a1,40(sp)
  8000ea:	f832                	sd	a2,48(sp)
  8000ec:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ee:	862a                	mv	a2,a0
  8000f0:	004c                	addi	a1,sp,4
  8000f2:	00000517          	auipc	a0,0x0
  8000f6:	fd850513          	addi	a0,a0,-40 # 8000ca <cputch>
  8000fa:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000fc:	ec06                	sd	ra,24(sp)
  8000fe:	e0ba                	sd	a4,64(sp)
  800100:	e4be                	sd	a5,72(sp)
  800102:	e8c2                	sd	a6,80(sp)
  800104:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800106:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800108:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010a:	09a000ef          	jal	8001a4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80010e:	60e2                	ld	ra,24(sp)
  800110:	4512                	lw	a0,4(sp)
  800112:	6125                	addi	sp,sp,96
  800114:	8082                	ret

0000000000800116 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800116:	1141                	addi	sp,sp,-16
  800118:	e406                	sd	ra,8(sp)
    int ret = main();
  80011a:	3f0000ef          	jal	80050a <main>
    exit(ret);
  80011e:	f7dff0ef          	jal	80009a <exit>

0000000000800122 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800122:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800124:	e589                	bnez	a1,80012e <strnlen+0xc>
  800126:	a811                	j	80013a <strnlen+0x18>
        cnt ++;
  800128:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80012a:	00f58863          	beq	a1,a5,80013a <strnlen+0x18>
  80012e:	00f50733          	add	a4,a0,a5
  800132:	00074703          	lbu	a4,0(a4)
  800136:	fb6d                	bnez	a4,800128 <strnlen+0x6>
  800138:	85be                	mv	a1,a5
    }
    return cnt;
}
  80013a:	852e                	mv	a0,a1
  80013c:	8082                	ret

000000000080013e <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80013e:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800140:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800144:	f022                	sd	s0,32(sp)
  800146:	ec26                	sd	s1,24(sp)
  800148:	e84a                	sd	s2,16(sp)
  80014a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800150:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800152:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800156:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	84aa                	mv	s1,a0
  80015c:	892e                	mv	s2,a1
    if (num >= base) {
  80015e:	03067d63          	bgeu	a2,a6,800198 <printnum+0x5a>
  800162:	e44e                	sd	s3,8(sp)
  800164:	89be                	mv	s3,a5
        while (-- width > 0)
  800166:	4785                	li	a5,1
  800168:	00e7d763          	bge	a5,a4,800176 <printnum+0x38>
            putch(padc, putdat);
  80016c:	85ca                	mv	a1,s2
  80016e:	854e                	mv	a0,s3
        while (-- width > 0)
  800170:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800172:	9482                	jalr	s1
        while (-- width > 0)
  800174:	fc65                	bnez	s0,80016c <printnum+0x2e>
  800176:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800178:	00000797          	auipc	a5,0x0
  80017c:	5b878793          	addi	a5,a5,1464 # 800730 <main+0x226>
  800180:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800182:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800184:	0007c503          	lbu	a0,0(a5)
}
  800188:	70a2                	ld	ra,40(sp)
  80018a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018c:	85ca                	mv	a1,s2
  80018e:	87a6                	mv	a5,s1
}
  800190:	6942                	ld	s2,16(sp)
  800192:	64e2                	ld	s1,24(sp)
  800194:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800196:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800198:	03065633          	divu	a2,a2,a6
  80019c:	8722                	mv	a4,s0
  80019e:	fa1ff0ef          	jal	80013e <printnum>
  8001a2:	bfd9                	j	800178 <printnum+0x3a>

00000000008001a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a4:	7119                	addi	sp,sp,-128
  8001a6:	f4a6                	sd	s1,104(sp)
  8001a8:	f0ca                	sd	s2,96(sp)
  8001aa:	ecce                	sd	s3,88(sp)
  8001ac:	e8d2                	sd	s4,80(sp)
  8001ae:	e4d6                	sd	s5,72(sp)
  8001b0:	e0da                	sd	s6,64(sp)
  8001b2:	f862                	sd	s8,48(sp)
  8001b4:	fc86                	sd	ra,120(sp)
  8001b6:	f8a2                	sd	s0,112(sp)
  8001b8:	fc5e                	sd	s7,56(sp)
  8001ba:	f466                	sd	s9,40(sp)
  8001bc:	f06a                	sd	s10,32(sp)
  8001be:	ec6e                	sd	s11,24(sp)
  8001c0:	84aa                	mv	s1,a0
  8001c2:	8c32                	mv	s8,a2
  8001c4:	8a36                	mv	s4,a3
  8001c6:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001cc:	05500b13          	li	s6,85
  8001d0:	00000a97          	auipc	s5,0x0
  8001d4:	6c4a8a93          	addi	s5,s5,1732 # 800894 <main+0x38a>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d8:	000c4503          	lbu	a0,0(s8)
  8001dc:	001c0413          	addi	s0,s8,1
  8001e0:	01350a63          	beq	a0,s3,8001f4 <vprintfmt+0x50>
            if (ch == '\0') {
  8001e4:	cd0d                	beqz	a0,80021e <vprintfmt+0x7a>
            putch(ch, putdat);
  8001e6:	85ca                	mv	a1,s2
  8001e8:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ea:	00044503          	lbu	a0,0(s0)
  8001ee:	0405                	addi	s0,s0,1
  8001f0:	ff351ae3          	bne	a0,s3,8001e4 <vprintfmt+0x40>
        width = precision = -1;
  8001f4:	5cfd                	li	s9,-1
  8001f6:	8d66                	mv	s10,s9
        char padc = ' ';
  8001f8:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001fc:	4b81                	li	s7,0
  8001fe:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	00044683          	lbu	a3,0(s0)
  800204:	00140c13          	addi	s8,s0,1
  800208:	fdd6859b          	addiw	a1,a3,-35
  80020c:	0ff5f593          	zext.b	a1,a1
  800210:	02bb6663          	bltu	s6,a1,80023c <vprintfmt+0x98>
  800214:	058a                	slli	a1,a1,0x2
  800216:	95d6                	add	a1,a1,s5
  800218:	4198                	lw	a4,0(a1)
  80021a:	9756                	add	a4,a4,s5
  80021c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80021e:	70e6                	ld	ra,120(sp)
  800220:	7446                	ld	s0,112(sp)
  800222:	74a6                	ld	s1,104(sp)
  800224:	7906                	ld	s2,96(sp)
  800226:	69e6                	ld	s3,88(sp)
  800228:	6a46                	ld	s4,80(sp)
  80022a:	6aa6                	ld	s5,72(sp)
  80022c:	6b06                	ld	s6,64(sp)
  80022e:	7be2                	ld	s7,56(sp)
  800230:	7c42                	ld	s8,48(sp)
  800232:	7ca2                	ld	s9,40(sp)
  800234:	7d02                	ld	s10,32(sp)
  800236:	6de2                	ld	s11,24(sp)
  800238:	6109                	addi	sp,sp,128
  80023a:	8082                	ret
            putch('%', putdat);
  80023c:	85ca                	mv	a1,s2
  80023e:	02500513          	li	a0,37
  800242:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800244:	fff44783          	lbu	a5,-1(s0)
  800248:	02500713          	li	a4,37
  80024c:	8c22                	mv	s8,s0
  80024e:	f8e785e3          	beq	a5,a4,8001d8 <vprintfmt+0x34>
  800252:	ffec4783          	lbu	a5,-2(s8)
  800256:	1c7d                	addi	s8,s8,-1
  800258:	fee79de3          	bne	a5,a4,800252 <vprintfmt+0xae>
  80025c:	bfb5                	j	8001d8 <vprintfmt+0x34>
                ch = *fmt;
  80025e:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800262:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800264:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800268:	fd06071b          	addiw	a4,a2,-48
  80026c:	24e56a63          	bltu	a0,a4,8004c0 <vprintfmt+0x31c>
                ch = *fmt;
  800270:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800274:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800278:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80027c:	0197073b          	addw	a4,a4,s9
  800280:	0017171b          	slliw	a4,a4,0x1
  800284:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800286:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80028a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80028c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800290:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800294:	feb570e3          	bgeu	a0,a1,800274 <vprintfmt+0xd0>
            if (width < 0)
  800298:	f60d54e3          	bgez	s10,800200 <vprintfmt+0x5c>
                width = precision, precision = -1;
  80029c:	8d66                	mv	s10,s9
  80029e:	5cfd                	li	s9,-1
  8002a0:	b785                	j	800200 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	8db6                	mv	s11,a3
  8002a4:	8462                	mv	s0,s8
  8002a6:	bfa9                	j	800200 <vprintfmt+0x5c>
  8002a8:	8462                	mv	s0,s8
            altflag = 1;
  8002aa:	4b85                	li	s7,1
            goto reswitch;
  8002ac:	bf91                	j	800200 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002b0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b4:	00f74463          	blt	a4,a5,8002bc <vprintfmt+0x118>
    else if (lflag) {
  8002b8:	1a078763          	beqz	a5,800466 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002bc:	000a3603          	ld	a2,0(s4)
  8002c0:	46c1                	li	a3,16
  8002c2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002c4:	000d879b          	sext.w	a5,s11
  8002c8:	876a                	mv	a4,s10
  8002ca:	85ca                	mv	a1,s2
  8002cc:	8526                	mv	a0,s1
  8002ce:	e71ff0ef          	jal	80013e <printnum>
            break;
  8002d2:	b719                	j	8001d8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002d4:	000a2503          	lw	a0,0(s4)
  8002d8:	85ca                	mv	a1,s2
  8002da:	0a21                	addi	s4,s4,8
  8002dc:	9482                	jalr	s1
            break;
  8002de:	bded                	j	8001d8 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e6:	00f74463          	blt	a4,a5,8002ee <vprintfmt+0x14a>
    else if (lflag) {
  8002ea:	16078963          	beqz	a5,80045c <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ee:	000a3603          	ld	a2,0(s4)
  8002f2:	46a9                	li	a3,10
  8002f4:	8a2e                	mv	s4,a1
  8002f6:	b7f9                	j	8002c4 <vprintfmt+0x120>
            putch('0', putdat);
  8002f8:	85ca                	mv	a1,s2
  8002fa:	03000513          	li	a0,48
  8002fe:	9482                	jalr	s1
            putch('x', putdat);
  800300:	85ca                	mv	a1,s2
  800302:	07800513          	li	a0,120
  800306:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800308:	000a3603          	ld	a2,0(s4)
            goto number;
  80030c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80030e:	0a21                	addi	s4,s4,8
            goto number;
  800310:	bf55                	j	8002c4 <vprintfmt+0x120>
            putch(ch, putdat);
  800312:	85ca                	mv	a1,s2
  800314:	02500513          	li	a0,37
  800318:	9482                	jalr	s1
            break;
  80031a:	bd7d                	j	8001d8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80031c:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800320:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800322:	0a21                	addi	s4,s4,8
            goto process_precision;
  800324:	bf95                	j	800298 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800326:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800328:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032c:	00f74463          	blt	a4,a5,800334 <vprintfmt+0x190>
    else if (lflag) {
  800330:	12078163          	beqz	a5,800452 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800334:	000a3603          	ld	a2,0(s4)
  800338:	46a1                	li	a3,8
  80033a:	8a2e                	mv	s4,a1
  80033c:	b761                	j	8002c4 <vprintfmt+0x120>
            if (width < 0)
  80033e:	876a                	mv	a4,s10
  800340:	000d5363          	bgez	s10,800346 <vprintfmt+0x1a2>
  800344:	4701                	li	a4,0
  800346:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	8462                	mv	s0,s8
            goto reswitch;
  80034c:	bd55                	j	800200 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80034e:	000d841b          	sext.w	s0,s11
  800352:	fd340793          	addi	a5,s0,-45
  800356:	00f037b3          	snez	a5,a5
  80035a:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80035e:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800362:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800364:	008a0793          	addi	a5,s4,8
  800368:	e43e                	sd	a5,8(sp)
  80036a:	100d8c63          	beqz	s11,800482 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80036e:	12071363          	bnez	a4,800494 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	000dc783          	lbu	a5,0(s11)
  800376:	0007851b          	sext.w	a0,a5
  80037a:	c78d                	beqz	a5,8003a4 <vprintfmt+0x200>
  80037c:	0d85                	addi	s11,s11,1
  80037e:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800380:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800384:	000cc563          	bltz	s9,80038e <vprintfmt+0x1ea>
  800388:	3cfd                	addiw	s9,s9,-1
  80038a:	008c8d63          	beq	s9,s0,8003a4 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80038e:	020b9663          	bnez	s7,8003ba <vprintfmt+0x216>
                    putch(ch, putdat);
  800392:	85ca                	mv	a1,s2
  800394:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	000dc783          	lbu	a5,0(s11)
  80039a:	0d85                	addi	s11,s11,1
  80039c:	3d7d                	addiw	s10,s10,-1
  80039e:	0007851b          	sext.w	a0,a5
  8003a2:	f3ed                	bnez	a5,800384 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003a4:	01a05963          	blez	s10,8003b6 <vprintfmt+0x212>
                putch(' ', putdat);
  8003a8:	85ca                	mv	a1,s2
  8003aa:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ae:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003b0:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003b2:	fe0d1be3          	bnez	s10,8003a8 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b6:	6a22                	ld	s4,8(sp)
  8003b8:	b505                	j	8001d8 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ba:	3781                	addiw	a5,a5,-32
  8003bc:	fcfa7be3          	bgeu	s4,a5,800392 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003c0:	03f00513          	li	a0,63
  8003c4:	85ca                	mv	a1,s2
  8003c6:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c8:	000dc783          	lbu	a5,0(s11)
  8003cc:	0d85                	addi	s11,s11,1
  8003ce:	3d7d                	addiw	s10,s10,-1
  8003d0:	0007851b          	sext.w	a0,a5
  8003d4:	dbe1                	beqz	a5,8003a4 <vprintfmt+0x200>
  8003d6:	fa0cd9e3          	bgez	s9,800388 <vprintfmt+0x1e4>
  8003da:	b7c5                	j	8003ba <vprintfmt+0x216>
            if (err < 0) {
  8003dc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e0:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003e2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e4:	41f7d71b          	sraiw	a4,a5,0x1f
  8003e8:	8fb9                	xor	a5,a5,a4
  8003ea:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ee:	02d64563          	blt	a2,a3,800418 <vprintfmt+0x274>
  8003f2:	00000797          	auipc	a5,0x0
  8003f6:	5fe78793          	addi	a5,a5,1534 # 8009f0 <error_string>
  8003fa:	00369713          	slli	a4,a3,0x3
  8003fe:	97ba                	add	a5,a5,a4
  800400:	639c                	ld	a5,0(a5)
  800402:	cb99                	beqz	a5,800418 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800404:	86be                	mv	a3,a5
  800406:	00000617          	auipc	a2,0x0
  80040a:	36260613          	addi	a2,a2,866 # 800768 <main+0x25e>
  80040e:	85ca                	mv	a1,s2
  800410:	8526                	mv	a0,s1
  800412:	0d8000ef          	jal	8004ea <printfmt>
  800416:	b3c9                	j	8001d8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800418:	00000617          	auipc	a2,0x0
  80041c:	34060613          	addi	a2,a2,832 # 800758 <main+0x24e>
  800420:	85ca                	mv	a1,s2
  800422:	8526                	mv	a0,s1
  800424:	0c6000ef          	jal	8004ea <printfmt>
  800428:	bb45                	j	8001d8 <vprintfmt+0x34>
    if (lflag >= 2) {
  80042a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80042c:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800430:	00f74363          	blt	a4,a5,800436 <vprintfmt+0x292>
    else if (lflag) {
  800434:	cf81                	beqz	a5,80044c <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800436:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80043a:	02044b63          	bltz	s0,800470 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80043e:	8622                	mv	a2,s0
  800440:	8a5e                	mv	s4,s7
  800442:	46a9                	li	a3,10
  800444:	b541                	j	8002c4 <vprintfmt+0x120>
            lflag ++;
  800446:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800448:	8462                	mv	s0,s8
            goto reswitch;
  80044a:	bb5d                	j	800200 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80044c:	000a2403          	lw	s0,0(s4)
  800450:	b7ed                	j	80043a <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800452:	000a6603          	lwu	a2,0(s4)
  800456:	46a1                	li	a3,8
  800458:	8a2e                	mv	s4,a1
  80045a:	b5ad                	j	8002c4 <vprintfmt+0x120>
  80045c:	000a6603          	lwu	a2,0(s4)
  800460:	46a9                	li	a3,10
  800462:	8a2e                	mv	s4,a1
  800464:	b585                	j	8002c4 <vprintfmt+0x120>
  800466:	000a6603          	lwu	a2,0(s4)
  80046a:	46c1                	li	a3,16
  80046c:	8a2e                	mv	s4,a1
  80046e:	bd99                	j	8002c4 <vprintfmt+0x120>
                putch('-', putdat);
  800470:	85ca                	mv	a1,s2
  800472:	02d00513          	li	a0,45
  800476:	9482                	jalr	s1
                num = -(long long)num;
  800478:	40800633          	neg	a2,s0
  80047c:	8a5e                	mv	s4,s7
  80047e:	46a9                	li	a3,10
  800480:	b591                	j	8002c4 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800482:	e329                	bnez	a4,8004c4 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	02800793          	li	a5,40
  800488:	853e                	mv	a0,a5
  80048a:	00000d97          	auipc	s11,0x0
  80048e:	2bfd8d93          	addi	s11,s11,703 # 800749 <main+0x23f>
  800492:	b5f5                	j	80037e <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800494:	85e6                	mv	a1,s9
  800496:	856e                	mv	a0,s11
  800498:	c8bff0ef          	jal	800122 <strnlen>
  80049c:	40ad0d3b          	subw	s10,s10,a0
  8004a0:	01a05863          	blez	s10,8004b0 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004a4:	85ca                	mv	a1,s2
  8004a6:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004aa:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ac:	fe0d1ce3          	bnez	s10,8004a4 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b0:	000dc783          	lbu	a5,0(s11)
  8004b4:	0007851b          	sext.w	a0,a5
  8004b8:	ec0792e3          	bnez	a5,80037c <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004bc:	6a22                	ld	s4,8(sp)
  8004be:	bb29                	j	8001d8 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004c0:	8462                	mv	s0,s8
  8004c2:	bbd9                	j	800298 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	85e6                	mv	a1,s9
  8004c6:	00000517          	auipc	a0,0x0
  8004ca:	28250513          	addi	a0,a0,642 # 800748 <main+0x23e>
  8004ce:	c55ff0ef          	jal	800122 <strnlen>
  8004d2:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d6:	02800793          	li	a5,40
                p = "(null)";
  8004da:	00000d97          	auipc	s11,0x0
  8004de:	26ed8d93          	addi	s11,s11,622 # 800748 <main+0x23e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e2:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e4:	fda040e3          	bgtz	s10,8004a4 <vprintfmt+0x300>
  8004e8:	bd51                	j	80037c <vprintfmt+0x1d8>

00000000008004ea <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ea:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ec:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f4:	ec06                	sd	ra,24(sp)
  8004f6:	f83a                	sd	a4,48(sp)
  8004f8:	fc3e                	sd	a5,56(sp)
  8004fa:	e0c2                	sd	a6,64(sp)
  8004fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004fe:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800500:	ca5ff0ef          	jal	8001a4 <vprintfmt>
}
  800504:	60e2                	ld	ra,24(sp)
  800506:	6161                	addi	sp,sp,80
  800508:	8082                	ret

000000000080050a <main>:
    exit(cpu_used);
}

int
main(void)
{
  80050a:	7119                	addi	sp,sp,-128
  80050c:	fc86                	sd	ra,120(sp)
    g_t0 = gettime_msec();
  80050e:	ba9ff0ef          	jal	8000b6 <gettime_msec>
  800512:	00001797          	auipc	a5,0x1
  800516:	aea7a723          	sw	a0,-1298(a5) # 801000 <g_t0>
    int pid = fork();
  80051a:	b97ff0ef          	jal	8000b0 <fork>
    if (pid == 0)
  80051e:	cd11                	beqz	a0,80053a <main+0x30>
    {
        run_long_task();
    }
    waitpid(pid, NULL);
  800520:	4581                	li	a1,0
  800522:	b91ff0ef          	jal	8000b2 <waitpid>
    cprintf("[sched_cpu] done\n");
  800526:	00000517          	auipc	a0,0x0
  80052a:	35a50513          	addi	a0,a0,858 # 800880 <main+0x376>
  80052e:	bb5ff0ef          	jal	8000e2 <cprintf>
    return 0;
}
  800532:	70e6                	ld	ra,120(sp)
  800534:	4501                	li	a0,0
  800536:	6109                	addi	sp,sp,128
  800538:	8082                	ret
    sched_set_burst(long_ticks, long_ticks);
  80053a:	07800593          	li	a1,120
        short_pids[i] = -1;
  80053e:	57fd                	li	a5,-1
    sched_set_burst(long_ticks, long_ticks);
  800540:	852e                	mv	a0,a1
        short_pids[i] = -1;
  800542:	fc3e                	sd	a5,56(sp)
  800544:	f8a2                	sd	s0,112(sp)
  800546:	f4a6                	sd	s1,104(sp)
  800548:	f0ca                	sd	s2,96(sp)
    sched_set_burst(long_ticks, long_ticks);
  80054a:	b75ff0ef          	jal	8000be <sched_set_burst>
    sched_set_nice(long_nice);
  80054e:	4501                	li	a0,0
  800550:	b71ff0ef          	jal	8000c0 <sched_set_nice>
    lab6_setpriority(long_prio);
  800554:	4505                	li	a0,1
  800556:	b63ff0ef          	jal	8000b8 <lab6_setpriority>
    uint32_t first = gettime_msec();
  80055a:	b5dff0ef          	jal	8000b6 <gettime_msec>
  80055e:	892a                	mv	s2,a0
    int cpu_start = sched_get_runtime();
  800560:	b63ff0ef          	jal	8000c2 <sched_get_runtime>
  800564:	84aa                	mv	s1,a0
    while ((cpu_now - cpu_start) < (int)long_ticks)
  800566:	4781                	li	a5,0
    int spawned = 0;
  800568:	4401                	li	s0,0
    for (i = 0; i < 500; i++)
  80056a:	1f400693          	li	a3,500
        if (!spawned && (cpu_now - cpu_start) >= 20)
  80056e:	e469                	bnez	s0,800638 <main+0x12e>
  800570:	474d                	li	a4,19
  800572:	0af74863          	blt	a4,a5,800622 <main+0x118>
    volatile int j = 0;
  800576:	d802                	sw	zero,48(sp)
    for (i = 0; i < 500; i++)
  800578:	4781                	li	a5,0
        j += i;
  80057a:	5742                	lw	a4,48(sp)
  80057c:	9f3d                	addw	a4,a4,a5
  80057e:	d83a                	sw	a4,48(sp)
    for (i = 0; i < 500; i++)
  800580:	2785                	addiw	a5,a5,1
  800582:	fed79ce3          	bne	a5,a3,80057a <main+0x70>
        cpu_now = sched_get_runtime();
  800586:	b3dff0ef          	jal	8000c2 <sched_get_runtime>
    while ((cpu_now - cpu_start) < (int)long_ticks)
  80058a:	409508bb          	subw	a7,a0,s1
  80058e:	07700713          	li	a4,119
  800592:	87c6                	mv	a5,a7
  800594:	1f400693          	li	a3,500
  800598:	fd175be3          	bge	a4,a7,80056e <main+0x64>
    uint32_t end = gettime_msec();
  80059c:	f446                	sd	a7,40(sp)
  80059e:	ecce                	sd	s3,88(sp)
  8005a0:	e8d2                	sd	s4,80(sp)
  8005a2:	e4d6                	sd	s5,72(sp)
  8005a4:	b13ff0ef          	jal	8000b6 <gettime_msec>
    uint32_t resp = (first - g_t0) / 10;
  8005a8:	00001797          	auipc	a5,0x1
  8005ac:	a587a783          	lw	a5,-1448(a5) # 801000 <g_t0>
    uint32_t turn = (end - g_t0) / 10;
  8005b0:	4629                	li	a2,10
  8005b2:	40f5083b          	subw	a6,a0,a5
  8005b6:	02c8583b          	divuw	a6,a6,a2
  8005ba:	f03e                	sd	a5,32(sp)
  8005bc:	ec42                	sd	a6,24(sp)
    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
  8005be:	af7ff0ef          	jal	8000b4 <getpid>
    uint32_t resp = (first - g_t0) / 10;
  8005c2:	7782                	ld	a5,32(sp)
    int wait = (int)turn - cpu_used;
  8005c4:	6862                	ld	a6,24(sp)
  8005c6:	78a2                	ld	a7,40(sp)
    uint32_t resp = (first - g_t0) / 10;
  8005c8:	40f907bb          	subw	a5,s2,a5
  8005cc:	4629                	li	a2,10
    int wait = (int)turn - cpu_used;
  8005ce:	411806bb          	subw	a3,a6,a7
    uint32_t resp = (first - g_t0) / 10;
  8005d2:	02c7d7bb          	divuw	a5,a5,a2
    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
  8005d6:	85aa                	mv	a1,a0
    int wait = (int)turn - cpu_used;
  8005d8:	0006871b          	sext.w	a4,a3
    if (wait < 0)
  8005dc:	0006d363          	bgez	a3,8005e2 <main+0xd8>
  8005e0:	4701                	li	a4,0
    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
  8005e2:	e03a                	sd	a4,0(sp)
  8005e4:	4681                	li	a3,0
  8005e6:	4705                	li	a4,1
  8005e8:	07800613          	li	a2,120
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	24450513          	addi	a0,a0,580 # 800830 <main+0x326>
  8005f4:	ec46                	sd	a7,24(sp)
  8005f6:	aedff0ef          	jal	8000e2 <cprintf>
    if (spawned)
  8005fa:	68e2                	ld	a7,24(sp)
  8005fc:	c005                	beqz	s0,80061c <main+0x112>
            if (short_pids[i] > 0)
  8005fe:	5562                	lw	a0,56(sp)
  800600:	00a05663          	blez	a0,80060c <main+0x102>
                waitpid(short_pids[i], NULL);
  800604:	4581                	li	a1,0
  800606:	aadff0ef          	jal	8000b2 <waitpid>
  80060a:	68e2                	ld	a7,24(sp)
            if (short_pids[i] > 0)
  80060c:	5572                	lw	a0,60(sp)
  80060e:	00a05763          	blez	a0,80061c <main+0x112>
                waitpid(short_pids[i], NULL);
  800612:	4581                	li	a1,0
  800614:	ec46                	sd	a7,24(sp)
  800616:	a9dff0ef          	jal	8000b2 <waitpid>
  80061a:	68e2                	ld	a7,24(sp)
    exit(cpu_used);
  80061c:	8546                	mv	a0,a7
  80061e:	a7dff0ef          	jal	80009a <exit>
                int pid = fork();
  800622:	a8fff0ef          	jal	8000b0 <fork>
  800626:	87aa                	mv	a5,a0
                if (pid == 0)
  800628:	c919                	beqz	a0,80063e <main+0x134>
                short_pids[i] = pid;
  80062a:	dc2a                	sw	a0,56(sp)
                int pid = fork();
  80062c:	a85ff0ef          	jal	8000b0 <fork>
                if (pid == 0)
  800630:	c511                	beqz	a0,80063c <main+0x132>
                short_pids[i] = pid;
  800632:	de2a                	sw	a0,60(sp)
            for (i = 0; i < SHORT_TASKS; i++)
  800634:	1f400693          	li	a3,500
    int wait = (int)turn - cpu_used;
  800638:	4405                	li	s0,1
  80063a:	bf35                	j	800576 <main+0x6c>
            for (i = 0; i < SHORT_TASKS; i++)
  80063c:	4785                	li	a5,1
    sched_set_burst(short_ticks[idx], short_ticks[idx]);
  80063e:	078a                	slli	a5,a5,0x2
  800640:	00000717          	auipc	a4,0x0
  800644:	48870713          	addi	a4,a4,1160 # 800ac8 <short_ticks>
  800648:	973e                	add	a4,a4,a5
  80064a:	ec3e                	sd	a5,24(sp)
  80064c:	431c                	lw	a5,0(a4)
  80064e:	ecce                	sd	s3,88(sp)
  800650:	e8d2                	sd	s4,80(sp)
  800652:	85be                	mv	a1,a5
  800654:	853e                	mv	a0,a5
  800656:	e4d6                	sd	s5,72(sp)
  800658:	84be                	mv	s1,a5
  80065a:	a65ff0ef          	jal	8000be <sched_set_burst>
    sched_set_nice(short_nice[idx]);
  80065e:	67e2                	ld	a5,24(sp)
  800660:	00000717          	auipc	a4,0x0
  800664:	46070713          	addi	a4,a4,1120 # 800ac0 <short_nice>
  800668:	973e                	add	a4,a4,a5
  80066a:	431c                	lw	a5,0(a4)
  80066c:	853e                	mv	a0,a5
  80066e:	89be                	mv	s3,a5
  800670:	a51ff0ef          	jal	8000c0 <sched_set_nice>
    lab6_setpriority(short_prio[idx]);
  800674:	67e2                	ld	a5,24(sp)
  800676:	00000717          	auipc	a4,0x0
  80067a:	44270713          	addi	a4,a4,1090 # 800ab8 <short_prio>
  80067e:	97ba                	add	a5,a5,a4
  800680:	439c                	lw	a5,0(a5)
  800682:	853e                	mv	a0,a5
  800684:	8a3e                	mv	s4,a5
  800686:	a33ff0ef          	jal	8000b8 <lab6_setpriority>
    uint32_t first = gettime_msec();
  80068a:	a2dff0ef          	jal	8000b6 <gettime_msec>
  80068e:	8aaa                	mv	s5,a0
    int cpu_start = sched_get_runtime();
  800690:	a33ff0ef          	jal	8000c2 <sched_get_runtime>
  800694:	862a                	mv	a2,a0
    int cpu_now = cpu_start;
  800696:	87aa                	mv	a5,a0
    for (i = 0; i < 500; i++)
  800698:	1f400693          	li	a3,500
    while ((cpu_now - cpu_start) < (int)short_ticks[idx])
  80069c:	9f91                	subw	a5,a5,a2
  80069e:	893e                	mv	s2,a5
  8006a0:	0297d263          	bge	a5,s1,8006c4 <main+0x1ba>
    volatile int j = 0;
  8006a4:	da02                	sw	zero,52(sp)
    for (i = 0; i < 500; i++)
  8006a6:	4781                	li	a5,0
        j += i;
  8006a8:	5752                	lw	a4,52(sp)
  8006aa:	9f3d                	addw	a4,a4,a5
  8006ac:	da3a                	sw	a4,52(sp)
    for (i = 0; i < 500; i++)
  8006ae:	2785                	addiw	a5,a5,1
  8006b0:	fed79ce3          	bne	a5,a3,8006a8 <main+0x19e>
        cpu_now = sched_get_runtime();
  8006b4:	ec32                	sd	a2,24(sp)
  8006b6:	a0dff0ef          	jal	8000c2 <sched_get_runtime>
  8006ba:	6662                	ld	a2,24(sp)
  8006bc:	87aa                	mv	a5,a0
  8006be:	1f400693          	li	a3,500
  8006c2:	bfe9                	j	80069c <main+0x192>
    uint32_t end = gettime_msec();
  8006c4:	9f3ff0ef          	jal	8000b6 <gettime_msec>
    uint32_t resp = (first - g_t0) / 10;
  8006c8:	00001797          	auipc	a5,0x1
  8006cc:	9387a783          	lw	a5,-1736(a5) # 801000 <g_t0>
  8006d0:	46a9                	li	a3,10
    uint32_t turn = (end - g_t0) / 10;
  8006d2:	40f5083b          	subw	a6,a0,a5
  8006d6:	02d8583b          	divuw	a6,a6,a3
    uint32_t resp = (first - g_t0) / 10;
  8006da:	40fa87bb          	subw	a5,s5,a5
    int wait = (int)turn - cpu_used;
  8006de:	4128073b          	subw	a4,a6,s2
    uint32_t resp = (first - g_t0) / 10;
  8006e2:	02d7d7bb          	divuw	a5,a5,a3
    if (wait < 0)
  8006e6:	00074363          	bltz	a4,8006ec <main+0x1e2>
    int wait = (int)turn - cpu_used;
  8006ea:	843a                	mv	s0,a4
    cprintf("[sched_cpu] pid=%d target=%u nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d\n",
  8006ec:	f042                	sd	a6,32(sp)
  8006ee:	ec3e                	sd	a5,24(sp)
  8006f0:	9c5ff0ef          	jal	8000b4 <getpid>
  8006f4:	7802                	ld	a6,32(sp)
  8006f6:	67e2                	ld	a5,24(sp)
  8006f8:	85aa                	mv	a1,a0
  8006fa:	e022                	sd	s0,0(sp)
  8006fc:	8752                	mv	a4,s4
  8006fe:	86ce                	mv	a3,s3
  800700:	8626                	mv	a2,s1
  800702:	88ca                	mv	a7,s2
  800704:	00000517          	auipc	a0,0x0
  800708:	12c50513          	addi	a0,a0,300 # 800830 <main+0x326>
  80070c:	9d7ff0ef          	jal	8000e2 <cprintf>
    exit(cpu_used);
  800710:	854a                	mv	a0,s2
  800712:	989ff0ef          	jal	80009a <exit>
