
obj/__user_forktree.out:     file format elf64-littleriscv


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

0000000000800064 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800064:	4529                	li	a0,10
  800066:	bf6d                	j	800020 <syscall>

0000000000800068 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800068:	4549                	li	a0,18
  80006a:	bf5d                	j	800020 <syscall>

000000000080006c <sys_putc>:
}

int
sys_putc(int64_t c) {
  80006c:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80006e:	4579                	li	a0,30
  800070:	bf45                	j	800020 <syscall>

0000000000800072 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800072:	1141                	addi	sp,sp,-16
  800074:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800076:	fe5ff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007a:	00000517          	auipc	a0,0x0
  80007e:	59650513          	addi	a0,a0,1430 # 800610 <main+0x18>
  800082:	02a000ef          	jal	8000ac <cprintf>
    while (1);
  800086:	a001                	j	800086 <exit+0x14>

0000000000800088 <fork>:
}

int
fork(void) {
    return sys_fork();
  800088:	bfe1                	j	800060 <sys_fork>

000000000080008a <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  80008a:	bfe9                	j	800064 <sys_yield>

000000000080008c <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80008c:	bff1                	j	800068 <sys_getpid>

000000000080008e <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  80008e:	052000ef          	jal	8000e0 <umain>
1:  j 1b
  800092:	a001                	j	800092 <_start+0x4>

0000000000800094 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800094:	1101                	addi	sp,sp,-32
  800096:	ec06                	sd	ra,24(sp)
  800098:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80009a:	fd3ff0ef          	jal	80006c <sys_putc>
    (*cnt) ++;
  80009e:	65a2                	ld	a1,8(sp)
}
  8000a0:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000a2:	419c                	lw	a5,0(a1)
  8000a4:	2785                	addiw	a5,a5,1
  8000a6:	c19c                	sw	a5,0(a1)
}
  8000a8:	6105                	addi	sp,sp,32
  8000aa:	8082                	ret

00000000008000ac <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000ac:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000ae:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b2:	f42e                	sd	a1,40(sp)
  8000b4:	f832                	sd	a2,48(sp)
  8000b6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b8:	862a                	mv	a2,a0
  8000ba:	004c                	addi	a1,sp,4
  8000bc:	00000517          	auipc	a0,0x0
  8000c0:	fd850513          	addi	a0,a0,-40 # 800094 <cputch>
  8000c4:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c6:	ec06                	sd	ra,24(sp)
  8000c8:	e0ba                	sd	a4,64(sp)
  8000ca:	e4be                	sd	a5,72(sp)
  8000cc:	e8c2                	sd	a6,80(sp)
  8000ce:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000d0:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000d2:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d4:	0cc000ef          	jal	8001a0 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d8:	60e2                	ld	ra,24(sp)
  8000da:	4512                	lw	a0,4(sp)
  8000dc:	6125                	addi	sp,sp,96
  8000de:	8082                	ret

00000000008000e0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e0:	1141                	addi	sp,sp,-16
  8000e2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e4:	514000ef          	jal	8005f8 <main>
    exit(ret);
  8000e8:	f8bff0ef          	jal	800072 <exit>

00000000008000ec <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000ec:	00054783          	lbu	a5,0(a0)
  8000f0:	cb81                	beqz	a5,800100 <strlen+0x14>
    size_t cnt = 0;
  8000f2:	4781                	li	a5,0
        cnt ++;
  8000f4:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  8000f6:	00f50733          	add	a4,a0,a5
  8000fa:	00074703          	lbu	a4,0(a4)
  8000fe:	fb7d                	bnez	a4,8000f4 <strlen+0x8>
    }
    return cnt;
}
  800100:	853e                	mv	a0,a5
  800102:	8082                	ret

0000000000800104 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800104:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800106:	e589                	bnez	a1,800110 <strnlen+0xc>
  800108:	a811                	j	80011c <strnlen+0x18>
        cnt ++;
  80010a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80010c:	00f58863          	beq	a1,a5,80011c <strnlen+0x18>
  800110:	00f50733          	add	a4,a0,a5
  800114:	00074703          	lbu	a4,0(a4)
  800118:	fb6d                	bnez	a4,80010a <strnlen+0x6>
  80011a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80011c:	852e                	mv	a0,a1
  80011e:	8082                	ret

0000000000800120 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800120:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800122:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800126:	f022                	sd	s0,32(sp)
  800128:	ec26                	sd	s1,24(sp)
  80012a:	e84a                	sd	s2,16(sp)
  80012c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80012e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800132:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800134:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800138:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80013c:	84aa                	mv	s1,a0
  80013e:	892e                	mv	s2,a1
    if (num >= base) {
  800140:	03067d63          	bgeu	a2,a6,80017a <printnum+0x5a>
  800144:	e44e                	sd	s3,8(sp)
  800146:	89be                	mv	s3,a5
        while (-- width > 0)
  800148:	4785                	li	a5,1
  80014a:	00e7d763          	bge	a5,a4,800158 <printnum+0x38>
            putch(padc, putdat);
  80014e:	85ca                	mv	a1,s2
  800150:	854e                	mv	a0,s3
        while (-- width > 0)
  800152:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800154:	9482                	jalr	s1
        while (-- width > 0)
  800156:	fc65                	bnez	s0,80014e <printnum+0x2e>
  800158:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80015a:	00000797          	auipc	a5,0x0
  80015e:	4ce78793          	addi	a5,a5,1230 # 800628 <main+0x30>
  800162:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800164:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800166:	0007c503          	lbu	a0,0(a5)
}
  80016a:	70a2                	ld	ra,40(sp)
  80016c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80016e:	85ca                	mv	a1,s2
  800170:	87a6                	mv	a5,s1
}
  800172:	6942                	ld	s2,16(sp)
  800174:	64e2                	ld	s1,24(sp)
  800176:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800178:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80017a:	03065633          	divu	a2,a2,a6
  80017e:	8722                	mv	a4,s0
  800180:	fa1ff0ef          	jal	800120 <printnum>
  800184:	bfd9                	j	80015a <printnum+0x3a>

0000000000800186 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800186:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800188:	6198                	ld	a4,0(a1)
  80018a:	6594                	ld	a3,8(a1)
    b->cnt ++;
  80018c:	2785                	addiw	a5,a5,1
  80018e:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800190:	00d77763          	bgeu	a4,a3,80019e <sprintputch+0x18>
        *b->buf ++ = ch;
  800194:	00170793          	addi	a5,a4,1
  800198:	e19c                	sd	a5,0(a1)
  80019a:	00a70023          	sb	a0,0(a4)
    }
}
  80019e:	8082                	ret

00000000008001a0 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a0:	7119                	addi	sp,sp,-128
  8001a2:	f4a6                	sd	s1,104(sp)
  8001a4:	f0ca                	sd	s2,96(sp)
  8001a6:	ecce                	sd	s3,88(sp)
  8001a8:	e8d2                	sd	s4,80(sp)
  8001aa:	e4d6                	sd	s5,72(sp)
  8001ac:	e0da                	sd	s6,64(sp)
  8001ae:	f862                	sd	s8,48(sp)
  8001b0:	fc86                	sd	ra,120(sp)
  8001b2:	f8a2                	sd	s0,112(sp)
  8001b4:	fc5e                	sd	s7,56(sp)
  8001b6:	f466                	sd	s9,40(sp)
  8001b8:	f06a                	sd	s10,32(sp)
  8001ba:	ec6e                	sd	s11,24(sp)
  8001bc:	84aa                	mv	s1,a0
  8001be:	8c32                	mv	s8,a2
  8001c0:	8a36                	mv	s4,a3
  8001c2:	892e                	mv	s2,a1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c4:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
  8001c8:	05500b13          	li	s6,85
  8001cc:	00000a97          	auipc	s5,0x0
  8001d0:	574a8a93          	addi	s5,s5,1396 # 800740 <main+0x148>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d4:	000c4503          	lbu	a0,0(s8)
  8001d8:	001c0413          	addi	s0,s8,1
  8001dc:	01350a63          	beq	a0,s3,8001f0 <vprintfmt+0x50>
            if (ch == '\0') {
  8001e0:	cd0d                	beqz	a0,80021a <vprintfmt+0x7a>
            putch(ch, putdat);
  8001e2:	85ca                	mv	a1,s2
  8001e4:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	00044503          	lbu	a0,0(s0)
  8001ea:	0405                	addi	s0,s0,1
  8001ec:	ff351ae3          	bne	a0,s3,8001e0 <vprintfmt+0x40>
        width = precision = -1;
  8001f0:	5cfd                	li	s9,-1
  8001f2:	8d66                	mv	s10,s9
        char padc = ' ';
  8001f4:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001f8:	4b81                	li	s7,0
  8001fa:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001fc:	00044683          	lbu	a3,0(s0)
  800200:	00140c13          	addi	s8,s0,1
  800204:	fdd6859b          	addiw	a1,a3,-35
  800208:	0ff5f593          	zext.b	a1,a1
  80020c:	02bb6663          	bltu	s6,a1,800238 <vprintfmt+0x98>
  800210:	058a                	slli	a1,a1,0x2
  800212:	95d6                	add	a1,a1,s5
  800214:	4198                	lw	a4,0(a1)
  800216:	9756                	add	a4,a4,s5
  800218:	8702                	jr	a4
}
  80021a:	70e6                	ld	ra,120(sp)
  80021c:	7446                	ld	s0,112(sp)
  80021e:	74a6                	ld	s1,104(sp)
  800220:	7906                	ld	s2,96(sp)
  800222:	69e6                	ld	s3,88(sp)
  800224:	6a46                	ld	s4,80(sp)
  800226:	6aa6                	ld	s5,72(sp)
  800228:	6b06                	ld	s6,64(sp)
  80022a:	7be2                	ld	s7,56(sp)
  80022c:	7c42                	ld	s8,48(sp)
  80022e:	7ca2                	ld	s9,40(sp)
  800230:	7d02                	ld	s10,32(sp)
  800232:	6de2                	ld	s11,24(sp)
  800234:	6109                	addi	sp,sp,128
  800236:	8082                	ret
            putch('%', putdat);
  800238:	85ca                	mv	a1,s2
  80023a:	02500513          	li	a0,37
  80023e:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800240:	fff44783          	lbu	a5,-1(s0)
  800244:	02500713          	li	a4,37
  800248:	8c22                	mv	s8,s0
  80024a:	f8e785e3          	beq	a5,a4,8001d4 <vprintfmt+0x34>
  80024e:	ffec4783          	lbu	a5,-2(s8)
  800252:	1c7d                	addi	s8,s8,-1
  800254:	fee79de3          	bne	a5,a4,80024e <vprintfmt+0xae>
  800258:	bfb5                	j	8001d4 <vprintfmt+0x34>
                ch = *fmt;
  80025a:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80025e:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800260:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800264:	fd06071b          	addiw	a4,a2,-48
  800268:	24e56a63          	bltu	a0,a4,8004bc <vprintfmt+0x31c>
                ch = *fmt;
  80026c:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80026e:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800270:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800274:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800278:	0197073b          	addw	a4,a4,s9
  80027c:	0017171b          	slliw	a4,a4,0x1
  800280:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800282:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800286:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800288:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80028c:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800290:	feb570e3          	bgeu	a0,a1,800270 <vprintfmt+0xd0>
            if (width < 0)
  800294:	f60d54e3          	bgez	s10,8001fc <vprintfmt+0x5c>
                width = precision, precision = -1;
  800298:	8d66                	mv	s10,s9
  80029a:	5cfd                	li	s9,-1
  80029c:	b785                	j	8001fc <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80029e:	8db6                	mv	s11,a3
  8002a0:	8462                	mv	s0,s8
  8002a2:	bfa9                	j	8001fc <vprintfmt+0x5c>
  8002a4:	8462                	mv	s0,s8
            altflag = 1;
  8002a6:	4b85                	li	s7,1
            goto reswitch;
  8002a8:	bf91                	j	8001fc <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b0:	00f74463          	blt	a4,a5,8002b8 <vprintfmt+0x118>
    else if (lflag) {
  8002b4:	1a078763          	beqz	a5,800462 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002b8:	000a3603          	ld	a2,0(s4)
  8002bc:	46c1                	li	a3,16
  8002be:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002c0:	000d879b          	sext.w	a5,s11
  8002c4:	876a                	mv	a4,s10
  8002c6:	85ca                	mv	a1,s2
  8002c8:	8526                	mv	a0,s1
  8002ca:	e57ff0ef          	jal	800120 <printnum>
            break;
  8002ce:	b719                	j	8001d4 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002d0:	000a2503          	lw	a0,0(s4)
  8002d4:	85ca                	mv	a1,s2
  8002d6:	0a21                	addi	s4,s4,8
  8002d8:	9482                	jalr	s1
            break;
  8002da:	bded                	j	8001d4 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002de:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e2:	00f74463          	blt	a4,a5,8002ea <vprintfmt+0x14a>
    else if (lflag) {
  8002e6:	16078963          	beqz	a5,800458 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ea:	000a3603          	ld	a2,0(s4)
  8002ee:	46a9                	li	a3,10
  8002f0:	8a2e                	mv	s4,a1
  8002f2:	b7f9                	j	8002c0 <vprintfmt+0x120>
            putch('0', putdat);
  8002f4:	85ca                	mv	a1,s2
  8002f6:	03000513          	li	a0,48
  8002fa:	9482                	jalr	s1
            putch('x', putdat);
  8002fc:	85ca                	mv	a1,s2
  8002fe:	07800513          	li	a0,120
  800302:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800304:	000a3603          	ld	a2,0(s4)
            goto number;
  800308:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80030a:	0a21                	addi	s4,s4,8
            goto number;
  80030c:	bf55                	j	8002c0 <vprintfmt+0x120>
            putch(ch, putdat);
  80030e:	85ca                	mv	a1,s2
  800310:	02500513          	li	a0,37
  800314:	9482                	jalr	s1
            break;
  800316:	bd7d                	j	8001d4 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800318:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80031c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80031e:	0a21                	addi	s4,s4,8
            goto process_precision;
  800320:	bf95                	j	800294 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800322:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800324:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800328:	00f74463          	blt	a4,a5,800330 <vprintfmt+0x190>
    else if (lflag) {
  80032c:	12078163          	beqz	a5,80044e <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800330:	000a3603          	ld	a2,0(s4)
  800334:	46a1                	li	a3,8
  800336:	8a2e                	mv	s4,a1
  800338:	b761                	j	8002c0 <vprintfmt+0x120>
            if (width < 0)
  80033a:	876a                	mv	a4,s10
  80033c:	000d5363          	bgez	s10,800342 <vprintfmt+0x1a2>
  800340:	4701                	li	a4,0
  800342:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800346:	8462                	mv	s0,s8
            goto reswitch;
  800348:	bd55                	j	8001fc <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80034a:	000d841b          	sext.w	s0,s11
  80034e:	fd340793          	addi	a5,s0,-45
  800352:	00f037b3          	snez	a5,a5
  800356:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80035a:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80035e:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800360:	008a0793          	addi	a5,s4,8
  800364:	e43e                	sd	a5,8(sp)
  800366:	100d8c63          	beqz	s11,80047e <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80036a:	12071363          	bnez	a4,800490 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036e:	000dc783          	lbu	a5,0(s11)
  800372:	0007851b          	sext.w	a0,a5
  800376:	c78d                	beqz	a5,8003a0 <vprintfmt+0x200>
  800378:	0d85                	addi	s11,s11,1
  80037a:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037c:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800380:	000cc563          	bltz	s9,80038a <vprintfmt+0x1ea>
  800384:	3cfd                	addiw	s9,s9,-1
  800386:	008c8d63          	beq	s9,s0,8003a0 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80038a:	020b9663          	bnez	s7,8003b6 <vprintfmt+0x216>
                    putch(ch, putdat);
  80038e:	85ca                	mv	a1,s2
  800390:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800392:	000dc783          	lbu	a5,0(s11)
  800396:	0d85                	addi	s11,s11,1
  800398:	3d7d                	addiw	s10,s10,-1
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	f3ed                	bnez	a5,800380 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003a0:	01a05963          	blez	s10,8003b2 <vprintfmt+0x212>
                putch(' ', putdat);
  8003a4:	85ca                	mv	a1,s2
  8003a6:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003aa:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ac:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003ae:	fe0d1be3          	bnez	s10,8003a4 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b2:	6a22                	ld	s4,8(sp)
  8003b4:	b505                	j	8001d4 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b6:	3781                	addiw	a5,a5,-32
  8003b8:	fcfa7be3          	bgeu	s4,a5,80038e <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003bc:	03f00513          	li	a0,63
  8003c0:	85ca                	mv	a1,s2
  8003c2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c4:	000dc783          	lbu	a5,0(s11)
  8003c8:	0d85                	addi	s11,s11,1
  8003ca:	3d7d                	addiw	s10,s10,-1
  8003cc:	0007851b          	sext.w	a0,a5
  8003d0:	dbe1                	beqz	a5,8003a0 <vprintfmt+0x200>
  8003d2:	fa0cd9e3          	bgez	s9,800384 <vprintfmt+0x1e4>
  8003d6:	b7c5                	j	8003b6 <vprintfmt+0x216>
            if (err < 0) {
  8003d8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003dc:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003de:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e0:	41f7d71b          	sraiw	a4,a5,0x1f
  8003e4:	8fb9                	xor	a5,a5,a4
  8003e6:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ea:	02d64563          	blt	a2,a3,800414 <vprintfmt+0x274>
  8003ee:	00000797          	auipc	a5,0x0
  8003f2:	4aa78793          	addi	a5,a5,1194 # 800898 <error_string>
  8003f6:	00369713          	slli	a4,a3,0x3
  8003fa:	97ba                	add	a5,a5,a4
  8003fc:	639c                	ld	a5,0(a5)
  8003fe:	cb99                	beqz	a5,800414 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800400:	86be                	mv	a3,a5
  800402:	00000617          	auipc	a2,0x0
  800406:	25660613          	addi	a2,a2,598 # 800658 <main+0x60>
  80040a:	85ca                	mv	a1,s2
  80040c:	8526                	mv	a0,s1
  80040e:	0d8000ef          	jal	8004e6 <printfmt>
  800412:	b3c9                	j	8001d4 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800414:	00000617          	auipc	a2,0x0
  800418:	23460613          	addi	a2,a2,564 # 800648 <main+0x50>
  80041c:	85ca                	mv	a1,s2
  80041e:	8526                	mv	a0,s1
  800420:	0c6000ef          	jal	8004e6 <printfmt>
  800424:	bb45                	j	8001d4 <vprintfmt+0x34>
    if (lflag >= 2) {
  800426:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800428:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80042c:	00f74363          	blt	a4,a5,800432 <vprintfmt+0x292>
    else if (lflag) {
  800430:	cf81                	beqz	a5,800448 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800432:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800436:	02044b63          	bltz	s0,80046c <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80043a:	8622                	mv	a2,s0
  80043c:	8a5e                	mv	s4,s7
  80043e:	46a9                	li	a3,10
  800440:	b541                	j	8002c0 <vprintfmt+0x120>
            lflag ++;
  800442:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800444:	8462                	mv	s0,s8
            goto reswitch;
  800446:	bb5d                	j	8001fc <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800448:	000a2403          	lw	s0,0(s4)
  80044c:	b7ed                	j	800436 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80044e:	000a6603          	lwu	a2,0(s4)
  800452:	46a1                	li	a3,8
  800454:	8a2e                	mv	s4,a1
  800456:	b5ad                	j	8002c0 <vprintfmt+0x120>
  800458:	000a6603          	lwu	a2,0(s4)
  80045c:	46a9                	li	a3,10
  80045e:	8a2e                	mv	s4,a1
  800460:	b585                	j	8002c0 <vprintfmt+0x120>
  800462:	000a6603          	lwu	a2,0(s4)
  800466:	46c1                	li	a3,16
  800468:	8a2e                	mv	s4,a1
  80046a:	bd99                	j	8002c0 <vprintfmt+0x120>
                putch('-', putdat);
  80046c:	85ca                	mv	a1,s2
  80046e:	02d00513          	li	a0,45
  800472:	9482                	jalr	s1
                num = -(long long)num;
  800474:	40800633          	neg	a2,s0
  800478:	8a5e                	mv	s4,s7
  80047a:	46a9                	li	a3,10
  80047c:	b591                	j	8002c0 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80047e:	e329                	bnez	a4,8004c0 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800480:	02800793          	li	a5,40
  800484:	853e                	mv	a0,a5
  800486:	00000d97          	auipc	s11,0x0
  80048a:	1bbd8d93          	addi	s11,s11,443 # 800641 <main+0x49>
  80048e:	b5f5                	j	80037a <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800490:	85e6                	mv	a1,s9
  800492:	856e                	mv	a0,s11
  800494:	c71ff0ef          	jal	800104 <strnlen>
  800498:	40ad0d3b          	subw	s10,s10,a0
  80049c:	01a05863          	blez	s10,8004ac <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004a0:	85ca                	mv	a1,s2
  8004a2:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004a6:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	fe0d1ce3          	bnez	s10,8004a0 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ac:	000dc783          	lbu	a5,0(s11)
  8004b0:	0007851b          	sext.w	a0,a5
  8004b4:	ec0792e3          	bnez	a5,800378 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004b8:	6a22                	ld	s4,8(sp)
  8004ba:	bb29                	j	8001d4 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004bc:	8462                	mv	s0,s8
  8004be:	bbd9                	j	800294 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	85e6                	mv	a1,s9
  8004c2:	00000517          	auipc	a0,0x0
  8004c6:	17e50513          	addi	a0,a0,382 # 800640 <main+0x48>
  8004ca:	c3bff0ef          	jal	800104 <strnlen>
  8004ce:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d2:	02800793          	li	a5,40
                p = "(null)";
  8004d6:	00000d97          	auipc	s11,0x0
  8004da:	16ad8d93          	addi	s11,s11,362 # 800640 <main+0x48>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004de:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	fda040e3          	bgtz	s10,8004a0 <vprintfmt+0x300>
  8004e4:	bd51                	j	800378 <vprintfmt+0x1d8>

00000000008004e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f0:	ec06                	sd	ra,24(sp)
  8004f2:	f83a                	sd	a4,48(sp)
  8004f4:	fc3e                	sd	a5,56(sp)
  8004f6:	e0c2                	sd	a6,64(sp)
  8004f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004fc:	ca5ff0ef          	jal	8001a0 <vprintfmt>
}
  800500:	60e2                	ld	ra,24(sp)
  800502:	6161                	addi	sp,sp,80
  800504:	8082                	ret

0000000000800506 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800506:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800508:	15fd                	addi	a1,a1,-1
  80050a:	95aa                	add	a1,a1,a0
    va_start(ap, fmt);
  80050c:	03810313          	addi	t1,sp,56
snprintf(char *str, size_t size, const char *fmt, ...) {
  800510:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800512:	e82e                	sd	a1,16(sp)
  800514:	e42a                	sd	a0,8(sp)
snprintf(char *str, size_t size, const char *fmt, ...) {
  800516:	fc36                	sd	a3,56(sp)
  800518:	e0ba                	sd	a4,64(sp)
  80051a:	e4be                	sd	a5,72(sp)
  80051c:	e8c2                	sd	a6,80(sp)
  80051e:	ecc6                	sd	a7,88(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800520:	cc02                	sw	zero,24(sp)
    va_start(ap, fmt);
  800522:	e01a                	sd	t1,0(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800524:	c115                	beqz	a0,800548 <snprintf+0x42>
  800526:	02a5e163          	bltu	a1,a0,800548 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  80052a:	00000517          	auipc	a0,0x0
  80052e:	c5c50513          	addi	a0,a0,-932 # 800186 <sprintputch>
  800532:	869a                	mv	a3,t1
  800534:	002c                	addi	a1,sp,8
  800536:	c6bff0ef          	jal	8001a0 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80053a:	67a2                	ld	a5,8(sp)
  80053c:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800540:	4562                	lw	a0,24(sp)
}
  800542:	70a2                	ld	ra,40(sp)
  800544:	6125                	addi	sp,sp,96
  800546:	8082                	ret
        return -E_INVAL;
  800548:	5575                	li	a0,-3
  80054a:	bfe5                	j	800542 <snprintf+0x3c>

000000000080054c <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80054c:	1101                	addi	sp,sp,-32
  80054e:	ec06                	sd	ra,24(sp)
  800550:	e822                	sd	s0,16(sp)
  800552:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800554:	b39ff0ef          	jal	80008c <getpid>
  800558:	85aa                	mv	a1,a0
  80055a:	8622                	mv	a2,s0
  80055c:	00000517          	auipc	a0,0x0
  800560:	1c450513          	addi	a0,a0,452 # 800720 <main+0x128>
  800564:	b49ff0ef          	jal	8000ac <cprintf>
    if (strlen(cur) >= DEPTH)
  800568:	8522                	mv	a0,s0
  80056a:	b83ff0ef          	jal	8000ec <strlen>
  80056e:	478d                	li	a5,3
  800570:	00a7f963          	bgeu	a5,a0,800582 <forktree+0x36>

    forkchild(cur, '0');
    forkchild(cur, '1');
  800574:	8522                	mv	a0,s0
}
  800576:	6442                	ld	s0,16(sp)
  800578:	60e2                	ld	ra,24(sp)
    forkchild(cur, '1');
  80057a:	03100593          	li	a1,49
}
  80057e:	6105                	addi	sp,sp,32
    forkchild(cur, '1');
  800580:	a03d                	j	8005ae <forkchild>
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800582:	03000713          	li	a4,48
  800586:	86a2                	mv	a3,s0
  800588:	00000617          	auipc	a2,0x0
  80058c:	1b060613          	addi	a2,a2,432 # 800738 <main+0x140>
  800590:	4595                	li	a1,5
  800592:	0028                	addi	a0,sp,8
  800594:	f73ff0ef          	jal	800506 <snprintf>
    if (fork() == 0) {
  800598:	af1ff0ef          	jal	800088 <fork>
  80059c:	fd61                	bnez	a0,800574 <forktree+0x28>
        forktree(nxt);
  80059e:	0028                	addi	a0,sp,8
  8005a0:	fadff0ef          	jal	80054c <forktree>
        yield();
  8005a4:	ae7ff0ef          	jal	80008a <yield>
        exit(0);
  8005a8:	4501                	li	a0,0
  8005aa:	ac9ff0ef          	jal	800072 <exit>

00000000008005ae <forkchild>:
forkchild(const char *cur, char branch) {
  8005ae:	7179                	addi	sp,sp,-48
  8005b0:	f022                	sd	s0,32(sp)
  8005b2:	ec26                	sd	s1,24(sp)
  8005b4:	f406                	sd	ra,40(sp)
  8005b6:	84ae                	mv	s1,a1
  8005b8:	842a                	mv	s0,a0
    if (strlen(cur) >= DEPTH)
  8005ba:	b33ff0ef          	jal	8000ec <strlen>
  8005be:	478d                	li	a5,3
  8005c0:	00a7f763          	bgeu	a5,a0,8005ce <forkchild+0x20>
}
  8005c4:	70a2                	ld	ra,40(sp)
  8005c6:	7402                	ld	s0,32(sp)
  8005c8:	64e2                	ld	s1,24(sp)
  8005ca:	6145                	addi	sp,sp,48
  8005cc:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005ce:	8726                	mv	a4,s1
  8005d0:	86a2                	mv	a3,s0
  8005d2:	00000617          	auipc	a2,0x0
  8005d6:	16660613          	addi	a2,a2,358 # 800738 <main+0x140>
  8005da:	4595                	li	a1,5
  8005dc:	0028                	addi	a0,sp,8
  8005de:	f29ff0ef          	jal	800506 <snprintf>
    if (fork() == 0) {
  8005e2:	aa7ff0ef          	jal	800088 <fork>
  8005e6:	fd79                	bnez	a0,8005c4 <forkchild+0x16>
        forktree(nxt);
  8005e8:	0028                	addi	a0,sp,8
  8005ea:	f63ff0ef          	jal	80054c <forktree>
        yield();
  8005ee:	a9dff0ef          	jal	80008a <yield>
        exit(0);
  8005f2:	4501                	li	a0,0
  8005f4:	a7fff0ef          	jal	800072 <exit>

00000000008005f8 <main>:

int
main(void) {
  8005f8:	1141                	addi	sp,sp,-16
    forktree("");
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	13650513          	addi	a0,a0,310 # 800730 <main+0x138>
main(void) {
  800602:	e406                	sd	ra,8(sp)
    forktree("");
  800604:	f49ff0ef          	jal	80054c <forktree>
    return 0;
}
  800608:	60a2                	ld	ra,8(sp)
  80060a:	4501                	li	a0,0
  80060c:	0141                	addi	sp,sp,16
  80060e:	8082                	ret
