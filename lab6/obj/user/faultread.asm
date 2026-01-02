
obj/__user_faultread.out:     file format elf64-littleriscv


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

0000000000800060 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800060:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800062:	4579                	li	a0,30
  800064:	bf75                	j	800020 <syscall>

0000000000800066 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800066:	1141                	addi	sp,sp,-16
  800068:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80006a:	ff1ff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80006e:	00000517          	auipc	a0,0x0
  800072:	45a50513          	addi	a0,a0,1114 # 8004c8 <main+0x6>
  800076:	024000ef          	jal	80009a <cprintf>
    while (1);
  80007a:	a001                	j	80007a <exit+0x14>

000000000080007c <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  80007c:	052000ef          	jal	8000ce <umain>
1:  j 1b
  800080:	a001                	j	800080 <_start+0x4>

0000000000800082 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800082:	1101                	addi	sp,sp,-32
  800084:	ec06                	sd	ra,24(sp)
  800086:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  800088:	fd9ff0ef          	jal	800060 <sys_putc>
    (*cnt) ++;
  80008c:	65a2                	ld	a1,8(sp)
}
  80008e:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800090:	419c                	lw	a5,0(a1)
  800092:	2785                	addiw	a5,a5,1
  800094:	c19c                	sw	a5,0(a1)
}
  800096:	6105                	addi	sp,sp,32
  800098:	8082                	ret

000000000080009a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80009a:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80009c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a0:	f42e                	sd	a1,40(sp)
  8000a2:	f832                	sd	a2,48(sp)
  8000a4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000a6:	862a                	mv	a2,a0
  8000a8:	004c                	addi	a1,sp,4
  8000aa:	00000517          	auipc	a0,0x0
  8000ae:	fd850513          	addi	a0,a0,-40 # 800082 <cputch>
  8000b2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000b4:	ec06                	sd	ra,24(sp)
  8000b6:	e0ba                	sd	a4,64(sp)
  8000b8:	e4be                	sd	a5,72(sp)
  8000ba:	e8c2                	sd	a6,80(sp)
  8000bc:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000be:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c0:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c2:	09a000ef          	jal	80015c <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000c6:	60e2                	ld	ra,24(sp)
  8000c8:	4512                	lw	a0,4(sp)
  8000ca:	6125                	addi	sp,sp,96
  8000cc:	8082                	ret

00000000008000ce <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000ce:	1141                	addi	sp,sp,-16
  8000d0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d2:	3f0000ef          	jal	8004c2 <main>
    exit(ret);
  8000d6:	f91ff0ef          	jal	800066 <exit>

00000000008000da <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000da:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000dc:	e589                	bnez	a1,8000e6 <strnlen+0xc>
  8000de:	a811                	j	8000f2 <strnlen+0x18>
        cnt ++;
  8000e0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000e2:	00f58863          	beq	a1,a5,8000f2 <strnlen+0x18>
  8000e6:	00f50733          	add	a4,a0,a5
  8000ea:	00074703          	lbu	a4,0(a4)
  8000ee:	fb6d                	bnez	a4,8000e0 <strnlen+0x6>
  8000f0:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000f2:	852e                	mv	a0,a1
  8000f4:	8082                	ret

00000000008000f6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000f6:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fc:	f022                	sd	s0,32(sp)
  8000fe:	ec26                	sd	s1,24(sp)
  800100:	e84a                	sd	s2,16(sp)
  800102:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800104:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800108:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80010a:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80010e:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800112:	84aa                	mv	s1,a0
  800114:	892e                	mv	s2,a1
    if (num >= base) {
  800116:	03067d63          	bgeu	a2,a6,800150 <printnum+0x5a>
  80011a:	e44e                	sd	s3,8(sp)
  80011c:	89be                	mv	s3,a5
        while (-- width > 0)
  80011e:	4785                	li	a5,1
  800120:	00e7d763          	bge	a5,a4,80012e <printnum+0x38>
            putch(padc, putdat);
  800124:	85ca                	mv	a1,s2
  800126:	854e                	mv	a0,s3
        while (-- width > 0)
  800128:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80012a:	9482                	jalr	s1
        while (-- width > 0)
  80012c:	fc65                	bnez	s0,800124 <printnum+0x2e>
  80012e:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800130:	00000797          	auipc	a5,0x0
  800134:	3b078793          	addi	a5,a5,944 # 8004e0 <main+0x1e>
  800138:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	0007c503          	lbu	a0,0(a5)
}
  800140:	70a2                	ld	ra,40(sp)
  800142:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800144:	85ca                	mv	a1,s2
  800146:	87a6                	mv	a5,s1
}
  800148:	6942                	ld	s2,16(sp)
  80014a:	64e2                	ld	s1,24(sp)
  80014c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80014e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800150:	03065633          	divu	a2,a2,a6
  800154:	8722                	mv	a4,s0
  800156:	fa1ff0ef          	jal	8000f6 <printnum>
  80015a:	bfd9                	j	800130 <printnum+0x3a>

000000000080015c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80015c:	7119                	addi	sp,sp,-128
  80015e:	f4a6                	sd	s1,104(sp)
  800160:	f0ca                	sd	s2,96(sp)
  800162:	ecce                	sd	s3,88(sp)
  800164:	e8d2                	sd	s4,80(sp)
  800166:	e4d6                	sd	s5,72(sp)
  800168:	e0da                	sd	s6,64(sp)
  80016a:	f862                	sd	s8,48(sp)
  80016c:	fc86                	sd	ra,120(sp)
  80016e:	f8a2                	sd	s0,112(sp)
  800170:	fc5e                	sd	s7,56(sp)
  800172:	f466                	sd	s9,40(sp)
  800174:	f06a                	sd	s10,32(sp)
  800176:	ec6e                	sd	s11,24(sp)
  800178:	84aa                	mv	s1,a0
  80017a:	8c32                	mv	s8,a2
  80017c:	8a36                	mv	s4,a3
  80017e:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800180:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800184:	05500b13          	li	s6,85
  800188:	00000a97          	auipc	s5,0x0
  80018c:	458a8a93          	addi	s5,s5,1112 # 8005e0 <main+0x11e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800190:	000c4503          	lbu	a0,0(s8)
  800194:	001c0413          	addi	s0,s8,1
  800198:	01350a63          	beq	a0,s3,8001ac <vprintfmt+0x50>
            if (ch == '\0') {
  80019c:	cd0d                	beqz	a0,8001d6 <vprintfmt+0x7a>
            putch(ch, putdat);
  80019e:	85ca                	mv	a1,s2
  8001a0:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	00044503          	lbu	a0,0(s0)
  8001a6:	0405                	addi	s0,s0,1
  8001a8:	ff351ae3          	bne	a0,s3,80019c <vprintfmt+0x40>
        width = precision = -1;
  8001ac:	5cfd                	li	s9,-1
  8001ae:	8d66                	mv	s10,s9
        char padc = ' ';
  8001b0:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001b4:	4b81                	li	s7,0
  8001b6:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001b8:	00044683          	lbu	a3,0(s0)
  8001bc:	00140c13          	addi	s8,s0,1
  8001c0:	fdd6859b          	addiw	a1,a3,-35
  8001c4:	0ff5f593          	zext.b	a1,a1
  8001c8:	02bb6663          	bltu	s6,a1,8001f4 <vprintfmt+0x98>
  8001cc:	058a                	slli	a1,a1,0x2
  8001ce:	95d6                	add	a1,a1,s5
  8001d0:	4198                	lw	a4,0(a1)
  8001d2:	9756                	add	a4,a4,s5
  8001d4:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d6:	70e6                	ld	ra,120(sp)
  8001d8:	7446                	ld	s0,112(sp)
  8001da:	74a6                	ld	s1,104(sp)
  8001dc:	7906                	ld	s2,96(sp)
  8001de:	69e6                	ld	s3,88(sp)
  8001e0:	6a46                	ld	s4,80(sp)
  8001e2:	6aa6                	ld	s5,72(sp)
  8001e4:	6b06                	ld	s6,64(sp)
  8001e6:	7be2                	ld	s7,56(sp)
  8001e8:	7c42                	ld	s8,48(sp)
  8001ea:	7ca2                	ld	s9,40(sp)
  8001ec:	7d02                	ld	s10,32(sp)
  8001ee:	6de2                	ld	s11,24(sp)
  8001f0:	6109                	addi	sp,sp,128
  8001f2:	8082                	ret
            putch('%', putdat);
  8001f4:	85ca                	mv	a1,s2
  8001f6:	02500513          	li	a0,37
  8001fa:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001fc:	fff44783          	lbu	a5,-1(s0)
  800200:	02500713          	li	a4,37
  800204:	8c22                	mv	s8,s0
  800206:	f8e785e3          	beq	a5,a4,800190 <vprintfmt+0x34>
  80020a:	ffec4783          	lbu	a5,-2(s8)
  80020e:	1c7d                	addi	s8,s8,-1
  800210:	fee79de3          	bne	a5,a4,80020a <vprintfmt+0xae>
  800214:	bfb5                	j	800190 <vprintfmt+0x34>
                ch = *fmt;
  800216:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80021a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80021c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800220:	fd06071b          	addiw	a4,a2,-48
  800224:	24e56a63          	bltu	a0,a4,800478 <vprintfmt+0x31c>
                ch = *fmt;
  800228:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80022a:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80022c:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800230:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800234:	0197073b          	addw	a4,a4,s9
  800238:	0017171b          	slliw	a4,a4,0x1
  80023c:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80023e:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800242:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800244:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800248:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80024c:	feb570e3          	bgeu	a0,a1,80022c <vprintfmt+0xd0>
            if (width < 0)
  800250:	f60d54e3          	bgez	s10,8001b8 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800254:	8d66                	mv	s10,s9
  800256:	5cfd                	li	s9,-1
  800258:	b785                	j	8001b8 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80025a:	8db6                	mv	s11,a3
  80025c:	8462                	mv	s0,s8
  80025e:	bfa9                	j	8001b8 <vprintfmt+0x5c>
  800260:	8462                	mv	s0,s8
            altflag = 1;
  800262:	4b85                	li	s7,1
            goto reswitch;
  800264:	bf91                	j	8001b8 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800266:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800268:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80026c:	00f74463          	blt	a4,a5,800274 <vprintfmt+0x118>
    else if (lflag) {
  800270:	1a078763          	beqz	a5,80041e <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800274:	000a3603          	ld	a2,0(s4)
  800278:	46c1                	li	a3,16
  80027a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80027c:	000d879b          	sext.w	a5,s11
  800280:	876a                	mv	a4,s10
  800282:	85ca                	mv	a1,s2
  800284:	8526                	mv	a0,s1
  800286:	e71ff0ef          	jal	8000f6 <printnum>
            break;
  80028a:	b719                	j	800190 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80028c:	000a2503          	lw	a0,0(s4)
  800290:	85ca                	mv	a1,s2
  800292:	0a21                	addi	s4,s4,8
  800294:	9482                	jalr	s1
            break;
  800296:	bded                	j	800190 <vprintfmt+0x34>
    if (lflag >= 2) {
  800298:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80029a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80029e:	00f74463          	blt	a4,a5,8002a6 <vprintfmt+0x14a>
    else if (lflag) {
  8002a2:	16078963          	beqz	a5,800414 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002a6:	000a3603          	ld	a2,0(s4)
  8002aa:	46a9                	li	a3,10
  8002ac:	8a2e                	mv	s4,a1
  8002ae:	b7f9                	j	80027c <vprintfmt+0x120>
            putch('0', putdat);
  8002b0:	85ca                	mv	a1,s2
  8002b2:	03000513          	li	a0,48
  8002b6:	9482                	jalr	s1
            putch('x', putdat);
  8002b8:	85ca                	mv	a1,s2
  8002ba:	07800513          	li	a0,120
  8002be:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c0:	000a3603          	ld	a2,0(s4)
            goto number;
  8002c4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c6:	0a21                	addi	s4,s4,8
            goto number;
  8002c8:	bf55                	j	80027c <vprintfmt+0x120>
            putch(ch, putdat);
  8002ca:	85ca                	mv	a1,s2
  8002cc:	02500513          	li	a0,37
  8002d0:	9482                	jalr	s1
            break;
  8002d2:	bd7d                	j	800190 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002d4:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002d8:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002da:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002dc:	bf95                	j	800250 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002de:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e4:	00f74463          	blt	a4,a5,8002ec <vprintfmt+0x190>
    else if (lflag) {
  8002e8:	12078163          	beqz	a5,80040a <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002ec:	000a3603          	ld	a2,0(s4)
  8002f0:	46a1                	li	a3,8
  8002f2:	8a2e                	mv	s4,a1
  8002f4:	b761                	j	80027c <vprintfmt+0x120>
            if (width < 0)
  8002f6:	876a                	mv	a4,s10
  8002f8:	000d5363          	bgez	s10,8002fe <vprintfmt+0x1a2>
  8002fc:	4701                	li	a4,0
  8002fe:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800302:	8462                	mv	s0,s8
            goto reswitch;
  800304:	bd55                	j	8001b8 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800306:	000d841b          	sext.w	s0,s11
  80030a:	fd340793          	addi	a5,s0,-45
  80030e:	00f037b3          	snez	a5,a5
  800312:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800316:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80031a:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80031c:	008a0793          	addi	a5,s4,8
  800320:	e43e                	sd	a5,8(sp)
  800322:	100d8c63          	beqz	s11,80043a <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800326:	12071363          	bnez	a4,80044c <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032a:	000dc783          	lbu	a5,0(s11)
  80032e:	0007851b          	sext.w	a0,a5
  800332:	c78d                	beqz	a5,80035c <vprintfmt+0x200>
  800334:	0d85                	addi	s11,s11,1
  800336:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800338:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033c:	000cc563          	bltz	s9,800346 <vprintfmt+0x1ea>
  800340:	3cfd                	addiw	s9,s9,-1
  800342:	008c8d63          	beq	s9,s0,80035c <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800346:	020b9663          	bnez	s7,800372 <vprintfmt+0x216>
                    putch(ch, putdat);
  80034a:	85ca                	mv	a1,s2
  80034c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034e:	000dc783          	lbu	a5,0(s11)
  800352:	0d85                	addi	s11,s11,1
  800354:	3d7d                	addiw	s10,s10,-1
  800356:	0007851b          	sext.w	a0,a5
  80035a:	f3ed                	bnez	a5,80033c <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  80035c:	01a05963          	blez	s10,80036e <vprintfmt+0x212>
                putch(' ', putdat);
  800360:	85ca                	mv	a1,s2
  800362:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800366:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800368:	9482                	jalr	s1
            for (; width > 0; width --) {
  80036a:	fe0d1be3          	bnez	s10,800360 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  80036e:	6a22                	ld	s4,8(sp)
  800370:	b505                	j	800190 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800372:	3781                	addiw	a5,a5,-32
  800374:	fcfa7be3          	bgeu	s4,a5,80034a <vprintfmt+0x1ee>
                    putch('?', putdat);
  800378:	03f00513          	li	a0,63
  80037c:	85ca                	mv	a1,s2
  80037e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800380:	000dc783          	lbu	a5,0(s11)
  800384:	0d85                	addi	s11,s11,1
  800386:	3d7d                	addiw	s10,s10,-1
  800388:	0007851b          	sext.w	a0,a5
  80038c:	dbe1                	beqz	a5,80035c <vprintfmt+0x200>
  80038e:	fa0cd9e3          	bgez	s9,800340 <vprintfmt+0x1e4>
  800392:	b7c5                	j	800372 <vprintfmt+0x216>
            if (err < 0) {
  800394:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800398:	4661                	li	a2,24
            err = va_arg(ap, int);
  80039a:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80039c:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a0:	8fb9                	xor	a5,a5,a4
  8003a2:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a6:	02d64563          	blt	a2,a3,8003d0 <vprintfmt+0x274>
  8003aa:	00000797          	auipc	a5,0x0
  8003ae:	38e78793          	addi	a5,a5,910 # 800738 <error_string>
  8003b2:	00369713          	slli	a4,a3,0x3
  8003b6:	97ba                	add	a5,a5,a4
  8003b8:	639c                	ld	a5,0(a5)
  8003ba:	cb99                	beqz	a5,8003d0 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003bc:	86be                	mv	a3,a5
  8003be:	00000617          	auipc	a2,0x0
  8003c2:	15a60613          	addi	a2,a2,346 # 800518 <main+0x56>
  8003c6:	85ca                	mv	a1,s2
  8003c8:	8526                	mv	a0,s1
  8003ca:	0d8000ef          	jal	8004a2 <printfmt>
  8003ce:	b3c9                	j	800190 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d0:	00000617          	auipc	a2,0x0
  8003d4:	13860613          	addi	a2,a2,312 # 800508 <main+0x46>
  8003d8:	85ca                	mv	a1,s2
  8003da:	8526                	mv	a0,s1
  8003dc:	0c6000ef          	jal	8004a2 <printfmt>
  8003e0:	bb45                	j	800190 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003e4:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003e8:	00f74363          	blt	a4,a5,8003ee <vprintfmt+0x292>
    else if (lflag) {
  8003ec:	cf81                	beqz	a5,800404 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003ee:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003f2:	02044b63          	bltz	s0,800428 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003f6:	8622                	mv	a2,s0
  8003f8:	8a5e                	mv	s4,s7
  8003fa:	46a9                	li	a3,10
  8003fc:	b541                	j	80027c <vprintfmt+0x120>
            lflag ++;
  8003fe:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	8462                	mv	s0,s8
            goto reswitch;
  800402:	bb5d                	j	8001b8 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800404:	000a2403          	lw	s0,0(s4)
  800408:	b7ed                	j	8003f2 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80040a:	000a6603          	lwu	a2,0(s4)
  80040e:	46a1                	li	a3,8
  800410:	8a2e                	mv	s4,a1
  800412:	b5ad                	j	80027c <vprintfmt+0x120>
  800414:	000a6603          	lwu	a2,0(s4)
  800418:	46a9                	li	a3,10
  80041a:	8a2e                	mv	s4,a1
  80041c:	b585                	j	80027c <vprintfmt+0x120>
  80041e:	000a6603          	lwu	a2,0(s4)
  800422:	46c1                	li	a3,16
  800424:	8a2e                	mv	s4,a1
  800426:	bd99                	j	80027c <vprintfmt+0x120>
                putch('-', putdat);
  800428:	85ca                	mv	a1,s2
  80042a:	02d00513          	li	a0,45
  80042e:	9482                	jalr	s1
                num = -(long long)num;
  800430:	40800633          	neg	a2,s0
  800434:	8a5e                	mv	s4,s7
  800436:	46a9                	li	a3,10
  800438:	b591                	j	80027c <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80043a:	e329                	bnez	a4,80047c <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043c:	02800793          	li	a5,40
  800440:	853e                	mv	a0,a5
  800442:	00000d97          	auipc	s11,0x0
  800446:	0b7d8d93          	addi	s11,s11,183 # 8004f9 <main+0x37>
  80044a:	b5f5                	j	800336 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044c:	85e6                	mv	a1,s9
  80044e:	856e                	mv	a0,s11
  800450:	c8bff0ef          	jal	8000da <strnlen>
  800454:	40ad0d3b          	subw	s10,s10,a0
  800458:	01a05863          	blez	s10,800468 <vprintfmt+0x30c>
                    putch(padc, putdat);
  80045c:	85ca                	mv	a1,s2
  80045e:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800460:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800462:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800464:	fe0d1ce3          	bnez	s10,80045c <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800468:	000dc783          	lbu	a5,0(s11)
  80046c:	0007851b          	sext.w	a0,a5
  800470:	ec0792e3          	bnez	a5,800334 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800474:	6a22                	ld	s4,8(sp)
  800476:	bb29                	j	800190 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800478:	8462                	mv	s0,s8
  80047a:	bbd9                	j	800250 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047c:	85e6                	mv	a1,s9
  80047e:	00000517          	auipc	a0,0x0
  800482:	07a50513          	addi	a0,a0,122 # 8004f8 <main+0x36>
  800486:	c55ff0ef          	jal	8000da <strnlen>
  80048a:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048e:	02800793          	li	a5,40
                p = "(null)";
  800492:	00000d97          	auipc	s11,0x0
  800496:	066d8d93          	addi	s11,s11,102 # 8004f8 <main+0x36>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049a:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049c:	fda040e3          	bgtz	s10,80045c <vprintfmt+0x300>
  8004a0:	bd51                	j	800334 <vprintfmt+0x1d8>

00000000008004a2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004a4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004aa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ac:	ec06                	sd	ra,24(sp)
  8004ae:	f83a                	sd	a4,48(sp)
  8004b0:	fc3e                	sd	a5,56(sp)
  8004b2:	e0c2                	sd	a6,64(sp)
  8004b4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004b6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b8:	ca5ff0ef          	jal	80015c <vprintfmt>
}
  8004bc:	60e2                	ld	ra,24(sp)
  8004be:	6161                	addi	sp,sp,80
  8004c0:	8082                	ret

00000000008004c2 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004c2:	4781                	li	a5,0
  8004c4:	439c                	lw	a5,0(a5)
  8004c6:	9002                	ebreak
