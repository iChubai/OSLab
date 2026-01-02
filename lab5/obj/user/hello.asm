
obj/__user_hello.out:     file format elf64-littleriscv


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
  800042:	6522                	ld	a0,8(sp)
  800044:	75a2                	ld	a1,40(sp)
  800046:	7642                	ld	a2,48(sp)
  800048:	76e2                	ld	a3,56(sp)
  80004a:	6706                	ld	a4,64(sp)
  80004c:	67a6                	ld	a5,72(sp)
  80004e:	00000073          	ecall
  800052:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800056:	4572                	lw	a0,28(sp)
  800058:	6149                	addi	sp,sp,144
  80005a:	8082                	ret

000000000080005c <sys_exit>:

int
sys_exit(int64_t error_code) {
  80005c:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80005e:	4505                	li	a0,1
  800060:	b7c1                	j	800020 <syscall>

0000000000800062 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800062:	4549                	li	a0,18
  800064:	bf75                	j	800020 <syscall>

0000000000800066 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800066:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800068:	4579                	li	a0,30
  80006a:	bf5d                	j	800020 <syscall>

000000000080006c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80006c:	1141                	addi	sp,sp,-16
  80006e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800070:	fedff0ef          	jal	80005c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800074:	00000517          	auipc	a0,0x0
  800078:	48c50513          	addi	a0,a0,1164 # 800500 <main+0x36>
  80007c:	026000ef          	jal	8000a2 <cprintf>
    while (1);
  800080:	a001                	j	800080 <exit+0x14>

0000000000800082 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800082:	b7c5                	j	800062 <sys_getpid>

0000000000800084 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800084:	052000ef          	jal	8000d6 <umain>
1:  j 1b
  800088:	a001                	j	800088 <_start+0x4>

000000000080008a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80008a:	1101                	addi	sp,sp,-32
  80008c:	ec06                	sd	ra,24(sp)
  80008e:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  800090:	fd7ff0ef          	jal	800066 <sys_putc>
    (*cnt) ++;
  800094:	65a2                	ld	a1,8(sp)
}
  800096:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800098:	419c                	lw	a5,0(a1)
  80009a:	2785                	addiw	a5,a5,1
  80009c:	c19c                	sw	a5,0(a1)
}
  80009e:	6105                	addi	sp,sp,32
  8000a0:	8082                	ret

00000000008000a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a2:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a8:	f42e                	sd	a1,40(sp)
  8000aa:	f832                	sd	a2,48(sp)
  8000ac:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ae:	862a                	mv	a2,a0
  8000b0:	004c                	addi	a1,sp,4
  8000b2:	00000517          	auipc	a0,0x0
  8000b6:	fd850513          	addi	a0,a0,-40 # 80008a <cputch>
  8000ba:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000bc:	ec06                	sd	ra,24(sp)
  8000be:	e0ba                	sd	a4,64(sp)
  8000c0:	e4be                	sd	a5,72(sp)
  8000c2:	e8c2                	sd	a6,80(sp)
  8000c4:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c6:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c8:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ca:	09a000ef          	jal	800164 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000ce:	60e2                	ld	ra,24(sp)
  8000d0:	4512                	lw	a0,4(sp)
  8000d2:	6125                	addi	sp,sp,96
  8000d4:	8082                	ret

00000000008000d6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d6:	1141                	addi	sp,sp,-16
  8000d8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000da:	3f0000ef          	jal	8004ca <main>
    exit(ret);
  8000de:	f8fff0ef          	jal	80006c <exit>

00000000008000e2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000e2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000e4:	e589                	bnez	a1,8000ee <strnlen+0xc>
  8000e6:	a811                	j	8000fa <strnlen+0x18>
        cnt ++;
  8000e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000ea:	00f58863          	beq	a1,a5,8000fa <strnlen+0x18>
  8000ee:	00f50733          	add	a4,a0,a5
  8000f2:	00074703          	lbu	a4,0(a4)
  8000f6:	fb6d                	bnez	a4,8000e8 <strnlen+0x6>
  8000f8:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000fa:	852e                	mv	a0,a1
  8000fc:	8082                	ret

00000000008000fe <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800100:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800104:	f022                	sd	s0,32(sp)
  800106:	ec26                	sd	s1,24(sp)
  800108:	e84a                	sd	s2,16(sp)
  80010a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80010c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800110:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800112:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800116:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80011a:	84aa                	mv	s1,a0
  80011c:	892e                	mv	s2,a1
    if (num >= base) {
  80011e:	03067d63          	bgeu	a2,a6,800158 <printnum+0x5a>
  800122:	e44e                	sd	s3,8(sp)
  800124:	89be                	mv	s3,a5
        while (-- width > 0)
  800126:	4785                	li	a5,1
  800128:	00e7d763          	bge	a5,a4,800136 <printnum+0x38>
            putch(padc, putdat);
  80012c:	85ca                	mv	a1,s2
  80012e:	854e                	mv	a0,s3
        while (-- width > 0)
  800130:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800132:	9482                	jalr	s1
        while (-- width > 0)
  800134:	fc65                	bnez	s0,80012c <printnum+0x2e>
  800136:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800138:	00000797          	auipc	a5,0x0
  80013c:	3e078793          	addi	a5,a5,992 # 800518 <main+0x4e>
  800140:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800142:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800144:	0007c503          	lbu	a0,0(a5)
}
  800148:	70a2                	ld	ra,40(sp)
  80014a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014c:	85ca                	mv	a1,s2
  80014e:	87a6                	mv	a5,s1
}
  800150:	6942                	ld	s2,16(sp)
  800152:	64e2                	ld	s1,24(sp)
  800154:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800156:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800158:	03065633          	divu	a2,a2,a6
  80015c:	8722                	mv	a4,s0
  80015e:	fa1ff0ef          	jal	8000fe <printnum>
  800162:	bfd9                	j	800138 <printnum+0x3a>

0000000000800164 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800164:	7119                	addi	sp,sp,-128
  800166:	f4a6                	sd	s1,104(sp)
  800168:	f0ca                	sd	s2,96(sp)
  80016a:	ecce                	sd	s3,88(sp)
  80016c:	e8d2                	sd	s4,80(sp)
  80016e:	e4d6                	sd	s5,72(sp)
  800170:	e0da                	sd	s6,64(sp)
  800172:	f862                	sd	s8,48(sp)
  800174:	fc86                	sd	ra,120(sp)
  800176:	f8a2                	sd	s0,112(sp)
  800178:	fc5e                	sd	s7,56(sp)
  80017a:	f466                	sd	s9,40(sp)
  80017c:	f06a                	sd	s10,32(sp)
  80017e:	ec6e                	sd	s11,24(sp)
  800180:	84aa                	mv	s1,a0
  800182:	8c32                	mv	s8,a2
  800184:	8a36                	mv	s4,a3
  800186:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800188:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80018c:	05500b13          	li	s6,85
  800190:	00000a97          	auipc	s5,0x0
  800194:	4c0a8a93          	addi	s5,s5,1216 # 800650 <main+0x186>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	000c4503          	lbu	a0,0(s8)
  80019c:	001c0413          	addi	s0,s8,1
  8001a0:	01350a63          	beq	a0,s3,8001b4 <vprintfmt+0x50>
            if (ch == '\0') {
  8001a4:	cd0d                	beqz	a0,8001de <vprintfmt+0x7a>
            putch(ch, putdat);
  8001a6:	85ca                	mv	a1,s2
  8001a8:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001aa:	00044503          	lbu	a0,0(s0)
  8001ae:	0405                	addi	s0,s0,1
  8001b0:	ff351ae3          	bne	a0,s3,8001a4 <vprintfmt+0x40>
        width = precision = -1;
  8001b4:	5cfd                	li	s9,-1
  8001b6:	8d66                	mv	s10,s9
        char padc = ' ';
  8001b8:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001bc:	4b81                	li	s7,0
  8001be:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001c0:	00044683          	lbu	a3,0(s0)
  8001c4:	00140c13          	addi	s8,s0,1
  8001c8:	fdd6859b          	addiw	a1,a3,-35
  8001cc:	0ff5f593          	zext.b	a1,a1
  8001d0:	02bb6663          	bltu	s6,a1,8001fc <vprintfmt+0x98>
  8001d4:	058a                	slli	a1,a1,0x2
  8001d6:	95d6                	add	a1,a1,s5
  8001d8:	4198                	lw	a4,0(a1)
  8001da:	9756                	add	a4,a4,s5
  8001dc:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001de:	70e6                	ld	ra,120(sp)
  8001e0:	7446                	ld	s0,112(sp)
  8001e2:	74a6                	ld	s1,104(sp)
  8001e4:	7906                	ld	s2,96(sp)
  8001e6:	69e6                	ld	s3,88(sp)
  8001e8:	6a46                	ld	s4,80(sp)
  8001ea:	6aa6                	ld	s5,72(sp)
  8001ec:	6b06                	ld	s6,64(sp)
  8001ee:	7be2                	ld	s7,56(sp)
  8001f0:	7c42                	ld	s8,48(sp)
  8001f2:	7ca2                	ld	s9,40(sp)
  8001f4:	7d02                	ld	s10,32(sp)
  8001f6:	6de2                	ld	s11,24(sp)
  8001f8:	6109                	addi	sp,sp,128
  8001fa:	8082                	ret
            putch('%', putdat);
  8001fc:	85ca                	mv	a1,s2
  8001fe:	02500513          	li	a0,37
  800202:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800204:	fff44783          	lbu	a5,-1(s0)
  800208:	02500713          	li	a4,37
  80020c:	8c22                	mv	s8,s0
  80020e:	f8e785e3          	beq	a5,a4,800198 <vprintfmt+0x34>
  800212:	ffec4783          	lbu	a5,-2(s8)
  800216:	1c7d                	addi	s8,s8,-1
  800218:	fee79de3          	bne	a5,a4,800212 <vprintfmt+0xae>
  80021c:	bfb5                	j	800198 <vprintfmt+0x34>
                ch = *fmt;
  80021e:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800222:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800224:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800228:	fd06071b          	addiw	a4,a2,-48
  80022c:	24e56a63          	bltu	a0,a4,800480 <vprintfmt+0x31c>
                ch = *fmt;
  800230:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800234:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800238:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80023c:	0197073b          	addw	a4,a4,s9
  800240:	0017171b          	slliw	a4,a4,0x1
  800244:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800246:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80024a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80024c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800250:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800254:	feb570e3          	bgeu	a0,a1,800234 <vprintfmt+0xd0>
            if (width < 0)
  800258:	f60d54e3          	bgez	s10,8001c0 <vprintfmt+0x5c>
                width = precision, precision = -1;
  80025c:	8d66                	mv	s10,s9
  80025e:	5cfd                	li	s9,-1
  800260:	b785                	j	8001c0 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800262:	8db6                	mv	s11,a3
  800264:	8462                	mv	s0,s8
  800266:	bfa9                	j	8001c0 <vprintfmt+0x5c>
  800268:	8462                	mv	s0,s8
            altflag = 1;
  80026a:	4b85                	li	s7,1
            goto reswitch;
  80026c:	bf91                	j	8001c0 <vprintfmt+0x5c>
    if (lflag >= 2) {
  80026e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800270:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800274:	00f74463          	blt	a4,a5,80027c <vprintfmt+0x118>
    else if (lflag) {
  800278:	1a078763          	beqz	a5,800426 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  80027c:	000a3603          	ld	a2,0(s4)
  800280:	46c1                	li	a3,16
  800282:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800284:	000d879b          	sext.w	a5,s11
  800288:	876a                	mv	a4,s10
  80028a:	85ca                	mv	a1,s2
  80028c:	8526                	mv	a0,s1
  80028e:	e71ff0ef          	jal	8000fe <printnum>
            break;
  800292:	b719                	j	800198 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800294:	000a2503          	lw	a0,0(s4)
  800298:	85ca                	mv	a1,s2
  80029a:	0a21                	addi	s4,s4,8
  80029c:	9482                	jalr	s1
            break;
  80029e:	bded                	j	800198 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002a6:	00f74463          	blt	a4,a5,8002ae <vprintfmt+0x14a>
    else if (lflag) {
  8002aa:	16078963          	beqz	a5,80041c <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ae:	000a3603          	ld	a2,0(s4)
  8002b2:	46a9                	li	a3,10
  8002b4:	8a2e                	mv	s4,a1
  8002b6:	b7f9                	j	800284 <vprintfmt+0x120>
            putch('0', putdat);
  8002b8:	85ca                	mv	a1,s2
  8002ba:	03000513          	li	a0,48
  8002be:	9482                	jalr	s1
            putch('x', putdat);
  8002c0:	85ca                	mv	a1,s2
  8002c2:	07800513          	li	a0,120
  8002c6:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c8:	000a3603          	ld	a2,0(s4)
            goto number;
  8002cc:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ce:	0a21                	addi	s4,s4,8
            goto number;
  8002d0:	bf55                	j	800284 <vprintfmt+0x120>
            putch(ch, putdat);
  8002d2:	85ca                	mv	a1,s2
  8002d4:	02500513          	li	a0,37
  8002d8:	9482                	jalr	s1
            break;
  8002da:	bd7d                	j	800198 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002dc:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e0:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002e2:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002e4:	bf95                	j	800258 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ec:	00f74463          	blt	a4,a5,8002f4 <vprintfmt+0x190>
    else if (lflag) {
  8002f0:	12078163          	beqz	a5,800412 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002f4:	000a3603          	ld	a2,0(s4)
  8002f8:	46a1                	li	a3,8
  8002fa:	8a2e                	mv	s4,a1
  8002fc:	b761                	j	800284 <vprintfmt+0x120>
            if (width < 0)
  8002fe:	876a                	mv	a4,s10
  800300:	000d5363          	bgez	s10,800306 <vprintfmt+0x1a2>
  800304:	4701                	li	a4,0
  800306:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80030a:	8462                	mv	s0,s8
            goto reswitch;
  80030c:	bd55                	j	8001c0 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80030e:	000d841b          	sext.w	s0,s11
  800312:	fd340793          	addi	a5,s0,-45
  800316:	00f037b3          	snez	a5,a5
  80031a:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80031e:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800322:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800324:	008a0793          	addi	a5,s4,8
  800328:	e43e                	sd	a5,8(sp)
  80032a:	100d8c63          	beqz	s11,800442 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80032e:	12071363          	bnez	a4,800454 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800332:	000dc783          	lbu	a5,0(s11)
  800336:	0007851b          	sext.w	a0,a5
  80033a:	c78d                	beqz	a5,800364 <vprintfmt+0x200>
  80033c:	0d85                	addi	s11,s11,1
  80033e:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800340:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800344:	000cc563          	bltz	s9,80034e <vprintfmt+0x1ea>
  800348:	3cfd                	addiw	s9,s9,-1
  80034a:	008c8d63          	beq	s9,s0,800364 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80034e:	020b9663          	bnez	s7,80037a <vprintfmt+0x216>
                    putch(ch, putdat);
  800352:	85ca                	mv	a1,s2
  800354:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800356:	000dc783          	lbu	a5,0(s11)
  80035a:	0d85                	addi	s11,s11,1
  80035c:	3d7d                	addiw	s10,s10,-1
  80035e:	0007851b          	sext.w	a0,a5
  800362:	f3ed                	bnez	a5,800344 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800364:	01a05963          	blez	s10,800376 <vprintfmt+0x212>
                putch(' ', putdat);
  800368:	85ca                	mv	a1,s2
  80036a:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80036e:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800370:	9482                	jalr	s1
            for (; width > 0; width --) {
  800372:	fe0d1be3          	bnez	s10,800368 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800376:	6a22                	ld	s4,8(sp)
  800378:	b505                	j	800198 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  80037a:	3781                	addiw	a5,a5,-32
  80037c:	fcfa7be3          	bgeu	s4,a5,800352 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800380:	03f00513          	li	a0,63
  800384:	85ca                	mv	a1,s2
  800386:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800388:	000dc783          	lbu	a5,0(s11)
  80038c:	0d85                	addi	s11,s11,1
  80038e:	3d7d                	addiw	s10,s10,-1
  800390:	0007851b          	sext.w	a0,a5
  800394:	dbe1                	beqz	a5,800364 <vprintfmt+0x200>
  800396:	fa0cd9e3          	bgez	s9,800348 <vprintfmt+0x1e4>
  80039a:	b7c5                	j	80037a <vprintfmt+0x216>
            if (err < 0) {
  80039c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a0:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003a2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003a4:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a8:	8fb9                	xor	a5,a5,a4
  8003aa:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ae:	02d64563          	blt	a2,a3,8003d8 <vprintfmt+0x274>
  8003b2:	00000797          	auipc	a5,0x0
  8003b6:	3f678793          	addi	a5,a5,1014 # 8007a8 <error_string>
  8003ba:	00369713          	slli	a4,a3,0x3
  8003be:	97ba                	add	a5,a5,a4
  8003c0:	639c                	ld	a5,0(a5)
  8003c2:	cb99                	beqz	a5,8003d8 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003c4:	86be                	mv	a3,a5
  8003c6:	00000617          	auipc	a2,0x0
  8003ca:	18a60613          	addi	a2,a2,394 # 800550 <main+0x86>
  8003ce:	85ca                	mv	a1,s2
  8003d0:	8526                	mv	a0,s1
  8003d2:	0d8000ef          	jal	8004aa <printfmt>
  8003d6:	b3c9                	j	800198 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d8:	00000617          	auipc	a2,0x0
  8003dc:	16860613          	addi	a2,a2,360 # 800540 <main+0x76>
  8003e0:	85ca                	mv	a1,s2
  8003e2:	8526                	mv	a0,s1
  8003e4:	0c6000ef          	jal	8004aa <printfmt>
  8003e8:	bb45                	j	800198 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003ec:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003f0:	00f74363          	blt	a4,a5,8003f6 <vprintfmt+0x292>
    else if (lflag) {
  8003f4:	cf81                	beqz	a5,80040c <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003f6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003fa:	02044b63          	bltz	s0,800430 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003fe:	8622                	mv	a2,s0
  800400:	8a5e                	mv	s4,s7
  800402:	46a9                	li	a3,10
  800404:	b541                	j	800284 <vprintfmt+0x120>
            lflag ++;
  800406:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800408:	8462                	mv	s0,s8
            goto reswitch;
  80040a:	bb5d                	j	8001c0 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80040c:	000a2403          	lw	s0,0(s4)
  800410:	b7ed                	j	8003fa <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800412:	000a6603          	lwu	a2,0(s4)
  800416:	46a1                	li	a3,8
  800418:	8a2e                	mv	s4,a1
  80041a:	b5ad                	j	800284 <vprintfmt+0x120>
  80041c:	000a6603          	lwu	a2,0(s4)
  800420:	46a9                	li	a3,10
  800422:	8a2e                	mv	s4,a1
  800424:	b585                	j	800284 <vprintfmt+0x120>
  800426:	000a6603          	lwu	a2,0(s4)
  80042a:	46c1                	li	a3,16
  80042c:	8a2e                	mv	s4,a1
  80042e:	bd99                	j	800284 <vprintfmt+0x120>
                putch('-', putdat);
  800430:	85ca                	mv	a1,s2
  800432:	02d00513          	li	a0,45
  800436:	9482                	jalr	s1
                num = -(long long)num;
  800438:	40800633          	neg	a2,s0
  80043c:	8a5e                	mv	s4,s7
  80043e:	46a9                	li	a3,10
  800440:	b591                	j	800284 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800442:	e329                	bnez	a4,800484 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800444:	02800793          	li	a5,40
  800448:	853e                	mv	a0,a5
  80044a:	00000d97          	auipc	s11,0x0
  80044e:	0e7d8d93          	addi	s11,s11,231 # 800531 <main+0x67>
  800452:	b5f5                	j	80033e <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800454:	85e6                	mv	a1,s9
  800456:	856e                	mv	a0,s11
  800458:	c8bff0ef          	jal	8000e2 <strnlen>
  80045c:	40ad0d3b          	subw	s10,s10,a0
  800460:	01a05863          	blez	s10,800470 <vprintfmt+0x30c>
                    putch(padc, putdat);
  800464:	85ca                	mv	a1,s2
  800466:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800468:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  80046a:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046c:	fe0d1ce3          	bnez	s10,800464 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800470:	000dc783          	lbu	a5,0(s11)
  800474:	0007851b          	sext.w	a0,a5
  800478:	ec0792e3          	bnez	a5,80033c <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  80047c:	6a22                	ld	s4,8(sp)
  80047e:	bb29                	j	800198 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800480:	8462                	mv	s0,s8
  800482:	bbd9                	j	800258 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800484:	85e6                	mv	a1,s9
  800486:	00000517          	auipc	a0,0x0
  80048a:	0aa50513          	addi	a0,a0,170 # 800530 <main+0x66>
  80048e:	c55ff0ef          	jal	8000e2 <strnlen>
  800492:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800496:	02800793          	li	a5,40
                p = "(null)";
  80049a:	00000d97          	auipc	s11,0x0
  80049e:	096d8d93          	addi	s11,s11,150 # 800530 <main+0x66>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a2:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	fda040e3          	bgtz	s10,800464 <vprintfmt+0x300>
  8004a8:	bd51                	j	80033c <vprintfmt+0x1d8>

00000000008004aa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004aa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	ec06                	sd	ra,24(sp)
  8004b6:	f83a                	sd	a4,48(sp)
  8004b8:	fc3e                	sd	a5,56(sp)
  8004ba:	e0c2                	sd	a6,64(sp)
  8004bc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004be:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c0:	ca5ff0ef          	jal	800164 <vprintfmt>
}
  8004c4:	60e2                	ld	ra,24(sp)
  8004c6:	6161                	addi	sp,sp,80
  8004c8:	8082                	ret

00000000008004ca <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004ca:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004cc:	00000517          	auipc	a0,0x0
  8004d0:	14c50513          	addi	a0,a0,332 # 800618 <main+0x14e>
main(void) {
  8004d4:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004d6:	bcdff0ef          	jal	8000a2 <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004da:	ba9ff0ef          	jal	800082 <getpid>
  8004de:	85aa                	mv	a1,a0
  8004e0:	00000517          	auipc	a0,0x0
  8004e4:	14850513          	addi	a0,a0,328 # 800628 <main+0x15e>
  8004e8:	bbbff0ef          	jal	8000a2 <cprintf>
    cprintf("hello pass.\n");
  8004ec:	00000517          	auipc	a0,0x0
  8004f0:	15450513          	addi	a0,a0,340 # 800640 <main+0x176>
  8004f4:	bafff0ef          	jal	8000a2 <cprintf>
    return 0;
}
  8004f8:	60a2                	ld	ra,8(sp)
  8004fa:	4501                	li	a0,0
  8004fc:	0141                	addi	sp,sp,16
  8004fe:	8082                	ret
