
obj/__user_yield.out:     file format elf64-littleriscv


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

0000000000800062 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800062:	4529                	li	a0,10
  800064:	bf75                	j	800020 <syscall>

0000000000800066 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800066:	4549                	li	a0,18
  800068:	bf65                	j	800020 <syscall>

000000000080006a <sys_putc>:
}

int
sys_putc(int64_t c) {
  80006a:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80006c:	4579                	li	a0,30
  80006e:	bf4d                	j	800020 <syscall>

0000000000800070 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800070:	1141                	addi	sp,sp,-16
  800072:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800074:	fe9ff0ef          	jal	80005c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800078:	00000517          	auipc	a0,0x0
  80007c:	4c050513          	addi	a0,a0,1216 # 800538 <main+0x68>
  800080:	028000ef          	jal	8000a8 <cprintf>
    while (1);
  800084:	a001                	j	800084 <exit+0x14>

0000000000800086 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800086:	bff1                	j	800062 <sys_yield>

0000000000800088 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800088:	bff9                	j	800066 <sys_getpid>

000000000080008a <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80008a:	052000ef          	jal	8000dc <umain>
1:  j 1b
  80008e:	a001                	j	80008e <_start+0x4>

0000000000800090 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800090:	1101                	addi	sp,sp,-32
  800092:	ec06                	sd	ra,24(sp)
  800094:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  800096:	fd5ff0ef          	jal	80006a <sys_putc>
    (*cnt) ++;
  80009a:	65a2                	ld	a1,8(sp)
}
  80009c:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  80009e:	419c                	lw	a5,0(a1)
  8000a0:	2785                	addiw	a5,a5,1
  8000a2:	c19c                	sw	a5,0(a1)
}
  8000a4:	6105                	addi	sp,sp,32
  8000a6:	8082                	ret

00000000008000a8 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a8:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000aa:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000ae:	f42e                	sd	a1,40(sp)
  8000b0:	f832                	sd	a2,48(sp)
  8000b2:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b4:	862a                	mv	a2,a0
  8000b6:	004c                	addi	a1,sp,4
  8000b8:	00000517          	auipc	a0,0x0
  8000bc:	fd850513          	addi	a0,a0,-40 # 800090 <cputch>
  8000c0:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c2:	ec06                	sd	ra,24(sp)
  8000c4:	e0ba                	sd	a4,64(sp)
  8000c6:	e4be                	sd	a5,72(sp)
  8000c8:	e8c2                	sd	a6,80(sp)
  8000ca:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000cc:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000ce:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d0:	09a000ef          	jal	80016a <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d4:	60e2                	ld	ra,24(sp)
  8000d6:	4512                	lw	a0,4(sp)
  8000d8:	6125                	addi	sp,sp,96
  8000da:	8082                	ret

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	3f0000ef          	jal	8004d0 <main>
    exit(ret);
  8000e4:	f8dff0ef          	jal	800070 <exit>

00000000008000e8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000e8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000ea:	e589                	bnez	a1,8000f4 <strnlen+0xc>
  8000ec:	a811                	j	800100 <strnlen+0x18>
        cnt ++;
  8000ee:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000f0:	00f58863          	beq	a1,a5,800100 <strnlen+0x18>
  8000f4:	00f50733          	add	a4,a0,a5
  8000f8:	00074703          	lbu	a4,0(a4)
  8000fc:	fb6d                	bnez	a4,8000ee <strnlen+0x6>
  8000fe:	85be                	mv	a1,a5
    }
    return cnt;
}
  800100:	852e                	mv	a0,a1
  800102:	8082                	ret

0000000000800104 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800104:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800106:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	f022                	sd	s0,32(sp)
  80010c:	ec26                	sd	s1,24(sp)
  80010e:	e84a                	sd	s2,16(sp)
  800110:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800112:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800116:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800118:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80011c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800120:	84aa                	mv	s1,a0
  800122:	892e                	mv	s2,a1
    if (num >= base) {
  800124:	03067d63          	bgeu	a2,a6,80015e <printnum+0x5a>
  800128:	e44e                	sd	s3,8(sp)
  80012a:	89be                	mv	s3,a5
        while (-- width > 0)
  80012c:	4785                	li	a5,1
  80012e:	00e7d763          	bge	a5,a4,80013c <printnum+0x38>
            putch(padc, putdat);
  800132:	85ca                	mv	a1,s2
  800134:	854e                	mv	a0,s3
        while (-- width > 0)
  800136:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800138:	9482                	jalr	s1
        while (-- width > 0)
  80013a:	fc65                	bnez	s0,800132 <printnum+0x2e>
  80013c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013e:	00000797          	auipc	a5,0x0
  800142:	41278793          	addi	a5,a5,1042 # 800550 <main+0x80>
  800146:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800148:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014a:	0007c503          	lbu	a0,0(a5)
}
  80014e:	70a2                	ld	ra,40(sp)
  800150:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800152:	85ca                	mv	a1,s2
  800154:	87a6                	mv	a5,s1
}
  800156:	6942                	ld	s2,16(sp)
  800158:	64e2                	ld	s1,24(sp)
  80015a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80015c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80015e:	03065633          	divu	a2,a2,a6
  800162:	8722                	mv	a4,s0
  800164:	fa1ff0ef          	jal	800104 <printnum>
  800168:	bfd9                	j	80013e <printnum+0x3a>

000000000080016a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80016a:	7119                	addi	sp,sp,-128
  80016c:	f4a6                	sd	s1,104(sp)
  80016e:	f0ca                	sd	s2,96(sp)
  800170:	ecce                	sd	s3,88(sp)
  800172:	e8d2                	sd	s4,80(sp)
  800174:	e4d6                	sd	s5,72(sp)
  800176:	e0da                	sd	s6,64(sp)
  800178:	f862                	sd	s8,48(sp)
  80017a:	fc86                	sd	ra,120(sp)
  80017c:	f8a2                	sd	s0,112(sp)
  80017e:	fc5e                	sd	s7,56(sp)
  800180:	f466                	sd	s9,40(sp)
  800182:	f06a                	sd	s10,32(sp)
  800184:	ec6e                	sd	s11,24(sp)
  800186:	84aa                	mv	s1,a0
  800188:	8c32                	mv	s8,a2
  80018a:	8a36                	mv	s4,a3
  80018c:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018e:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800192:	05500b13          	li	s6,85
  800196:	00000a97          	auipc	s5,0x0
  80019a:	532a8a93          	addi	s5,s5,1330 # 8006c8 <main+0x1f8>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019e:	000c4503          	lbu	a0,0(s8)
  8001a2:	001c0413          	addi	s0,s8,1
  8001a6:	01350a63          	beq	a0,s3,8001ba <vprintfmt+0x50>
            if (ch == '\0') {
  8001aa:	cd0d                	beqz	a0,8001e4 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001ac:	85ca                	mv	a1,s2
  8001ae:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b0:	00044503          	lbu	a0,0(s0)
  8001b4:	0405                	addi	s0,s0,1
  8001b6:	ff351ae3          	bne	a0,s3,8001aa <vprintfmt+0x40>
        width = precision = -1;
  8001ba:	5cfd                	li	s9,-1
  8001bc:	8d66                	mv	s10,s9
        char padc = ' ';
  8001be:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001c2:	4b81                	li	s7,0
  8001c4:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001c6:	00044683          	lbu	a3,0(s0)
  8001ca:	00140c13          	addi	s8,s0,1
  8001ce:	fdd6859b          	addiw	a1,a3,-35
  8001d2:	0ff5f593          	zext.b	a1,a1
  8001d6:	02bb6663          	bltu	s6,a1,800202 <vprintfmt+0x98>
  8001da:	058a                	slli	a1,a1,0x2
  8001dc:	95d6                	add	a1,a1,s5
  8001de:	4198                	lw	a4,0(a1)
  8001e0:	9756                	add	a4,a4,s5
  8001e2:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e4:	70e6                	ld	ra,120(sp)
  8001e6:	7446                	ld	s0,112(sp)
  8001e8:	74a6                	ld	s1,104(sp)
  8001ea:	7906                	ld	s2,96(sp)
  8001ec:	69e6                	ld	s3,88(sp)
  8001ee:	6a46                	ld	s4,80(sp)
  8001f0:	6aa6                	ld	s5,72(sp)
  8001f2:	6b06                	ld	s6,64(sp)
  8001f4:	7be2                	ld	s7,56(sp)
  8001f6:	7c42                	ld	s8,48(sp)
  8001f8:	7ca2                	ld	s9,40(sp)
  8001fa:	7d02                	ld	s10,32(sp)
  8001fc:	6de2                	ld	s11,24(sp)
  8001fe:	6109                	addi	sp,sp,128
  800200:	8082                	ret
            putch('%', putdat);
  800202:	85ca                	mv	a1,s2
  800204:	02500513          	li	a0,37
  800208:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80020a:	fff44783          	lbu	a5,-1(s0)
  80020e:	02500713          	li	a4,37
  800212:	8c22                	mv	s8,s0
  800214:	f8e785e3          	beq	a5,a4,80019e <vprintfmt+0x34>
  800218:	ffec4783          	lbu	a5,-2(s8)
  80021c:	1c7d                	addi	s8,s8,-1
  80021e:	fee79de3          	bne	a5,a4,800218 <vprintfmt+0xae>
  800222:	bfb5                	j	80019e <vprintfmt+0x34>
                ch = *fmt;
  800224:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800228:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80022a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80022e:	fd06071b          	addiw	a4,a2,-48
  800232:	24e56a63          	bltu	a0,a4,800486 <vprintfmt+0x31c>
                ch = *fmt;
  800236:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80023a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80023e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800242:	0197073b          	addw	a4,a4,s9
  800246:	0017171b          	slliw	a4,a4,0x1
  80024a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80024c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800250:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800252:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800256:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80025a:	feb570e3          	bgeu	a0,a1,80023a <vprintfmt+0xd0>
            if (width < 0)
  80025e:	f60d54e3          	bgez	s10,8001c6 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800262:	8d66                	mv	s10,s9
  800264:	5cfd                	li	s9,-1
  800266:	b785                	j	8001c6 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800268:	8db6                	mv	s11,a3
  80026a:	8462                	mv	s0,s8
  80026c:	bfa9                	j	8001c6 <vprintfmt+0x5c>
  80026e:	8462                	mv	s0,s8
            altflag = 1;
  800270:	4b85                	li	s7,1
            goto reswitch;
  800272:	bf91                	j	8001c6 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800274:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800276:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80027a:	00f74463          	blt	a4,a5,800282 <vprintfmt+0x118>
    else if (lflag) {
  80027e:	1a078763          	beqz	a5,80042c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800282:	000a3603          	ld	a2,0(s4)
  800286:	46c1                	li	a3,16
  800288:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80028a:	000d879b          	sext.w	a5,s11
  80028e:	876a                	mv	a4,s10
  800290:	85ca                	mv	a1,s2
  800292:	8526                	mv	a0,s1
  800294:	e71ff0ef          	jal	800104 <printnum>
            break;
  800298:	b719                	j	80019e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80029a:	000a2503          	lw	a0,0(s4)
  80029e:	85ca                	mv	a1,s2
  8002a0:	0a21                	addi	s4,s4,8
  8002a2:	9482                	jalr	s1
            break;
  8002a4:	bded                	j	80019e <vprintfmt+0x34>
    if (lflag >= 2) {
  8002a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ac:	00f74463          	blt	a4,a5,8002b4 <vprintfmt+0x14a>
    else if (lflag) {
  8002b0:	16078963          	beqz	a5,800422 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002b4:	000a3603          	ld	a2,0(s4)
  8002b8:	46a9                	li	a3,10
  8002ba:	8a2e                	mv	s4,a1
  8002bc:	b7f9                	j	80028a <vprintfmt+0x120>
            putch('0', putdat);
  8002be:	85ca                	mv	a1,s2
  8002c0:	03000513          	li	a0,48
  8002c4:	9482                	jalr	s1
            putch('x', putdat);
  8002c6:	85ca                	mv	a1,s2
  8002c8:	07800513          	li	a0,120
  8002cc:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ce:	000a3603          	ld	a2,0(s4)
            goto number;
  8002d2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d4:	0a21                	addi	s4,s4,8
            goto number;
  8002d6:	bf55                	j	80028a <vprintfmt+0x120>
            putch(ch, putdat);
  8002d8:	85ca                	mv	a1,s2
  8002da:	02500513          	li	a0,37
  8002de:	9482                	jalr	s1
            break;
  8002e0:	bd7d                	j	80019e <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002e2:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e6:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002e8:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002ea:	bf95                	j	80025e <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f2:	00f74463          	blt	a4,a5,8002fa <vprintfmt+0x190>
    else if (lflag) {
  8002f6:	12078163          	beqz	a5,800418 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002fa:	000a3603          	ld	a2,0(s4)
  8002fe:	46a1                	li	a3,8
  800300:	8a2e                	mv	s4,a1
  800302:	b761                	j	80028a <vprintfmt+0x120>
            if (width < 0)
  800304:	876a                	mv	a4,s10
  800306:	000d5363          	bgez	s10,80030c <vprintfmt+0x1a2>
  80030a:	4701                	li	a4,0
  80030c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800310:	8462                	mv	s0,s8
            goto reswitch;
  800312:	bd55                	j	8001c6 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800314:	000d841b          	sext.w	s0,s11
  800318:	fd340793          	addi	a5,s0,-45
  80031c:	00f037b3          	snez	a5,a5
  800320:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800324:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800328:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80032a:	008a0793          	addi	a5,s4,8
  80032e:	e43e                	sd	a5,8(sp)
  800330:	100d8c63          	beqz	s11,800448 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800334:	12071363          	bnez	a4,80045a <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800338:	000dc783          	lbu	a5,0(s11)
  80033c:	0007851b          	sext.w	a0,a5
  800340:	c78d                	beqz	a5,80036a <vprintfmt+0x200>
  800342:	0d85                	addi	s11,s11,1
  800344:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800346:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034a:	000cc563          	bltz	s9,800354 <vprintfmt+0x1ea>
  80034e:	3cfd                	addiw	s9,s9,-1
  800350:	008c8d63          	beq	s9,s0,80036a <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800354:	020b9663          	bnez	s7,800380 <vprintfmt+0x216>
                    putch(ch, putdat);
  800358:	85ca                	mv	a1,s2
  80035a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035c:	000dc783          	lbu	a5,0(s11)
  800360:	0d85                	addi	s11,s11,1
  800362:	3d7d                	addiw	s10,s10,-1
  800364:	0007851b          	sext.w	a0,a5
  800368:	f3ed                	bnez	a5,80034a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  80036a:	01a05963          	blez	s10,80037c <vprintfmt+0x212>
                putch(' ', putdat);
  80036e:	85ca                	mv	a1,s2
  800370:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800374:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800376:	9482                	jalr	s1
            for (; width > 0; width --) {
  800378:	fe0d1be3          	bnez	s10,80036e <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037c:	6a22                	ld	s4,8(sp)
  80037e:	b505                	j	80019e <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800380:	3781                	addiw	a5,a5,-32
  800382:	fcfa7be3          	bgeu	s4,a5,800358 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800386:	03f00513          	li	a0,63
  80038a:	85ca                	mv	a1,s2
  80038c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038e:	000dc783          	lbu	a5,0(s11)
  800392:	0d85                	addi	s11,s11,1
  800394:	3d7d                	addiw	s10,s10,-1
  800396:	0007851b          	sext.w	a0,a5
  80039a:	dbe1                	beqz	a5,80036a <vprintfmt+0x200>
  80039c:	fa0cd9e3          	bgez	s9,80034e <vprintfmt+0x1e4>
  8003a0:	b7c5                	j	800380 <vprintfmt+0x216>
            if (err < 0) {
  8003a2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a6:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003a8:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003aa:	41f7d71b          	sraiw	a4,a5,0x1f
  8003ae:	8fb9                	xor	a5,a5,a4
  8003b0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003b4:	02d64563          	blt	a2,a3,8003de <vprintfmt+0x274>
  8003b8:	00000797          	auipc	a5,0x0
  8003bc:	46878793          	addi	a5,a5,1128 # 800820 <error_string>
  8003c0:	00369713          	slli	a4,a3,0x3
  8003c4:	97ba                	add	a5,a5,a4
  8003c6:	639c                	ld	a5,0(a5)
  8003c8:	cb99                	beqz	a5,8003de <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003ca:	86be                	mv	a3,a5
  8003cc:	00000617          	auipc	a2,0x0
  8003d0:	1bc60613          	addi	a2,a2,444 # 800588 <main+0xb8>
  8003d4:	85ca                	mv	a1,s2
  8003d6:	8526                	mv	a0,s1
  8003d8:	0d8000ef          	jal	8004b0 <printfmt>
  8003dc:	b3c9                	j	80019e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003de:	00000617          	auipc	a2,0x0
  8003e2:	19a60613          	addi	a2,a2,410 # 800578 <main+0xa8>
  8003e6:	85ca                	mv	a1,s2
  8003e8:	8526                	mv	a0,s1
  8003ea:	0c6000ef          	jal	8004b0 <printfmt>
  8003ee:	bb45                	j	80019e <vprintfmt+0x34>
    if (lflag >= 2) {
  8003f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f2:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003f6:	00f74363          	blt	a4,a5,8003fc <vprintfmt+0x292>
    else if (lflag) {
  8003fa:	cf81                	beqz	a5,800412 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003fc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800400:	02044b63          	bltz	s0,800436 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800404:	8622                	mv	a2,s0
  800406:	8a5e                	mv	s4,s7
  800408:	46a9                	li	a3,10
  80040a:	b541                	j	80028a <vprintfmt+0x120>
            lflag ++;
  80040c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80040e:	8462                	mv	s0,s8
            goto reswitch;
  800410:	bb5d                	j	8001c6 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800412:	000a2403          	lw	s0,0(s4)
  800416:	b7ed                	j	800400 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800418:	000a6603          	lwu	a2,0(s4)
  80041c:	46a1                	li	a3,8
  80041e:	8a2e                	mv	s4,a1
  800420:	b5ad                	j	80028a <vprintfmt+0x120>
  800422:	000a6603          	lwu	a2,0(s4)
  800426:	46a9                	li	a3,10
  800428:	8a2e                	mv	s4,a1
  80042a:	b585                	j	80028a <vprintfmt+0x120>
  80042c:	000a6603          	lwu	a2,0(s4)
  800430:	46c1                	li	a3,16
  800432:	8a2e                	mv	s4,a1
  800434:	bd99                	j	80028a <vprintfmt+0x120>
                putch('-', putdat);
  800436:	85ca                	mv	a1,s2
  800438:	02d00513          	li	a0,45
  80043c:	9482                	jalr	s1
                num = -(long long)num;
  80043e:	40800633          	neg	a2,s0
  800442:	8a5e                	mv	s4,s7
  800444:	46a9                	li	a3,10
  800446:	b591                	j	80028a <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800448:	e329                	bnez	a4,80048a <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044a:	02800793          	li	a5,40
  80044e:	853e                	mv	a0,a5
  800450:	00000d97          	auipc	s11,0x0
  800454:	119d8d93          	addi	s11,s11,281 # 800569 <main+0x99>
  800458:	b5f5                	j	800344 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045a:	85e6                	mv	a1,s9
  80045c:	856e                	mv	a0,s11
  80045e:	c8bff0ef          	jal	8000e8 <strnlen>
  800462:	40ad0d3b          	subw	s10,s10,a0
  800466:	01a05863          	blez	s10,800476 <vprintfmt+0x30c>
                    putch(padc, putdat);
  80046a:	85ca                	mv	a1,s2
  80046c:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046e:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800470:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800472:	fe0d1ce3          	bnez	s10,80046a <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800476:	000dc783          	lbu	a5,0(s11)
  80047a:	0007851b          	sext.w	a0,a5
  80047e:	ec0792e3          	bnez	a5,800342 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800482:	6a22                	ld	s4,8(sp)
  800484:	bb29                	j	80019e <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800486:	8462                	mv	s0,s8
  800488:	bbd9                	j	80025e <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048a:	85e6                	mv	a1,s9
  80048c:	00000517          	auipc	a0,0x0
  800490:	0dc50513          	addi	a0,a0,220 # 800568 <main+0x98>
  800494:	c55ff0ef          	jal	8000e8 <strnlen>
  800498:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049c:	02800793          	li	a5,40
                p = "(null)";
  8004a0:	00000d97          	auipc	s11,0x0
  8004a4:	0c8d8d93          	addi	s11,s11,200 # 800568 <main+0x98>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a8:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	fda040e3          	bgtz	s10,80046a <vprintfmt+0x300>
  8004ae:	bd51                	j	800342 <vprintfmt+0x1d8>

00000000008004b0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ba:	ec06                	sd	ra,24(sp)
  8004bc:	f83a                	sd	a4,48(sp)
  8004be:	fc3e                	sd	a5,56(sp)
  8004c0:	e0c2                	sd	a6,64(sp)
  8004c2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c6:	ca5ff0ef          	jal	80016a <vprintfmt>
}
  8004ca:	60e2                	ld	ra,24(sp)
  8004cc:	6161                	addi	sp,sp,80
  8004ce:	8082                	ret

00000000008004d0 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004d0:	1101                	addi	sp,sp,-32
  8004d2:	ec06                	sd	ra,24(sp)
  8004d4:	e822                	sd	s0,16(sp)
  8004d6:	e426                	sd	s1,8(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  8004d8:	bb1ff0ef          	jal	800088 <getpid>
  8004dc:	85aa                	mv	a1,a0
  8004de:	00000517          	auipc	a0,0x0
  8004e2:	17250513          	addi	a0,a0,370 # 800650 <main+0x180>
  8004e6:	bc3ff0ef          	jal	8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  8004ea:	4401                	li	s0,0
  8004ec:	4495                	li	s1,5
        yield();
  8004ee:	b99ff0ef          	jal	800086 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  8004f2:	b97ff0ef          	jal	800088 <getpid>
  8004f6:	85aa                	mv	a1,a0
  8004f8:	8622                	mv	a2,s0
  8004fa:	00000517          	auipc	a0,0x0
  8004fe:	17650513          	addi	a0,a0,374 # 800670 <main+0x1a0>
    for (i = 0; i < 5; i ++) {
  800502:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800504:	ba5ff0ef          	jal	8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  800508:	fe9413e3          	bne	s0,s1,8004ee <main+0x1e>
    }
    cprintf("All done in process %d.\n", getpid());
  80050c:	b7dff0ef          	jal	800088 <getpid>
  800510:	85aa                	mv	a1,a0
  800512:	00000517          	auipc	a0,0x0
  800516:	18650513          	addi	a0,a0,390 # 800698 <main+0x1c8>
  80051a:	b8fff0ef          	jal	8000a8 <cprintf>
    cprintf("yield pass.\n");
  80051e:	00000517          	auipc	a0,0x0
  800522:	19a50513          	addi	a0,a0,410 # 8006b8 <main+0x1e8>
  800526:	b83ff0ef          	jal	8000a8 <cprintf>
    return 0;
}
  80052a:	60e2                	ld	ra,24(sp)
  80052c:	6442                	ld	s0,16(sp)
  80052e:	64a2                	ld	s1,8(sp)
  800530:	4501                	li	a0,0
  800532:	6105                	addi	sp,sp,32
  800534:	8082                	ret
