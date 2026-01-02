
obj/__user_softint.out:     file format elf64-littleriscv


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

0000000000800062 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800062:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800064:	4579                	li	a0,30
  800066:	bf6d                	j	800020 <syscall>

0000000000800068 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800068:	1141                	addi	sp,sp,-16
  80006a:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80006c:	ff1ff0ef          	jal	80005c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800070:	00000517          	auipc	a0,0x0
  800074:	46050513          	addi	a0,a0,1120 # 8004d0 <main+0xc>
  800078:	024000ef          	jal	80009c <cprintf>
    while (1);
  80007c:	a001                	j	80007c <exit+0x14>

000000000080007e <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80007e:	052000ef          	jal	8000d0 <umain>
1:  j 1b
  800082:	a001                	j	800082 <_start+0x4>

0000000000800084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800084:	1101                	addi	sp,sp,-32
  800086:	ec06                	sd	ra,24(sp)
  800088:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80008a:	fd9ff0ef          	jal	800062 <sys_putc>
    (*cnt) ++;
  80008e:	65a2                	ld	a1,8(sp)
}
  800090:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800092:	419c                	lw	a5,0(a1)
  800094:	2785                	addiw	a5,a5,1
  800096:	c19c                	sw	a5,0(a1)
}
  800098:	6105                	addi	sp,sp,32
  80009a:	8082                	ret

000000000080009c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80009c:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80009e:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a2:	f42e                	sd	a1,40(sp)
  8000a4:	f832                	sd	a2,48(sp)
  8000a6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000a8:	862a                	mv	a2,a0
  8000aa:	004c                	addi	a1,sp,4
  8000ac:	00000517          	auipc	a0,0x0
  8000b0:	fd850513          	addi	a0,a0,-40 # 800084 <cputch>
  8000b4:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000b6:	ec06                	sd	ra,24(sp)
  8000b8:	e0ba                	sd	a4,64(sp)
  8000ba:	e4be                	sd	a5,72(sp)
  8000bc:	e8c2                	sd	a6,80(sp)
  8000be:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c0:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c2:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c4:	09a000ef          	jal	80015e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000c8:	60e2                	ld	ra,24(sp)
  8000ca:	4512                	lw	a0,4(sp)
  8000cc:	6125                	addi	sp,sp,96
  8000ce:	8082                	ret

00000000008000d0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d4:	3f0000ef          	jal	8004c4 <main>
    exit(ret);
  8000d8:	f91ff0ef          	jal	800068 <exit>

00000000008000dc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000dc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000de:	e589                	bnez	a1,8000e8 <strnlen+0xc>
  8000e0:	a811                	j	8000f4 <strnlen+0x18>
        cnt ++;
  8000e2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000e4:	00f58863          	beq	a1,a5,8000f4 <strnlen+0x18>
  8000e8:	00f50733          	add	a4,a0,a5
  8000ec:	00074703          	lbu	a4,0(a4)
  8000f0:	fb6d                	bnez	a4,8000e2 <strnlen+0x6>
  8000f2:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000f4:	852e                	mv	a0,a1
  8000f6:	8082                	ret

00000000008000f8 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	f022                	sd	s0,32(sp)
  800100:	ec26                	sd	s1,24(sp)
  800102:	e84a                	sd	s2,16(sp)
  800104:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800106:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80010c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800110:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800114:	84aa                	mv	s1,a0
  800116:	892e                	mv	s2,a1
    if (num >= base) {
  800118:	03067d63          	bgeu	a2,a6,800152 <printnum+0x5a>
  80011c:	e44e                	sd	s3,8(sp)
  80011e:	89be                	mv	s3,a5
        while (-- width > 0)
  800120:	4785                	li	a5,1
  800122:	00e7d763          	bge	a5,a4,800130 <printnum+0x38>
            putch(padc, putdat);
  800126:	85ca                	mv	a1,s2
  800128:	854e                	mv	a0,s3
        while (-- width > 0)
  80012a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80012c:	9482                	jalr	s1
        while (-- width > 0)
  80012e:	fc65                	bnez	s0,800126 <printnum+0x2e>
  800130:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800132:	00000797          	auipc	a5,0x0
  800136:	3b678793          	addi	a5,a5,950 # 8004e8 <main+0x24>
  80013a:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	0007c503          	lbu	a0,0(a5)
}
  800142:	70a2                	ld	ra,40(sp)
  800144:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800146:	85ca                	mv	a1,s2
  800148:	87a6                	mv	a5,s1
}
  80014a:	6942                	ld	s2,16(sp)
  80014c:	64e2                	ld	s1,24(sp)
  80014e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800150:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800152:	03065633          	divu	a2,a2,a6
  800156:	8722                	mv	a4,s0
  800158:	fa1ff0ef          	jal	8000f8 <printnum>
  80015c:	bfd9                	j	800132 <printnum+0x3a>

000000000080015e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80015e:	7119                	addi	sp,sp,-128
  800160:	f4a6                	sd	s1,104(sp)
  800162:	f0ca                	sd	s2,96(sp)
  800164:	ecce                	sd	s3,88(sp)
  800166:	e8d2                	sd	s4,80(sp)
  800168:	e4d6                	sd	s5,72(sp)
  80016a:	e0da                	sd	s6,64(sp)
  80016c:	f862                	sd	s8,48(sp)
  80016e:	fc86                	sd	ra,120(sp)
  800170:	f8a2                	sd	s0,112(sp)
  800172:	fc5e                	sd	s7,56(sp)
  800174:	f466                	sd	s9,40(sp)
  800176:	f06a                	sd	s10,32(sp)
  800178:	ec6e                	sd	s11,24(sp)
  80017a:	84aa                	mv	s1,a0
  80017c:	8c32                	mv	s8,a2
  80017e:	8a36                	mv	s4,a3
  800180:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800182:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800186:	05500b13          	li	s6,85
  80018a:	00000a97          	auipc	s5,0x0
  80018e:	45ea8a93          	addi	s5,s5,1118 # 8005e8 <main+0x124>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800192:	000c4503          	lbu	a0,0(s8)
  800196:	001c0413          	addi	s0,s8,1
  80019a:	01350a63          	beq	a0,s3,8001ae <vprintfmt+0x50>
            if (ch == '\0') {
  80019e:	cd0d                	beqz	a0,8001d8 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001a0:	85ca                	mv	a1,s2
  8001a2:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a4:	00044503          	lbu	a0,0(s0)
  8001a8:	0405                	addi	s0,s0,1
  8001aa:	ff351ae3          	bne	a0,s3,80019e <vprintfmt+0x40>
        width = precision = -1;
  8001ae:	5cfd                	li	s9,-1
  8001b0:	8d66                	mv	s10,s9
        char padc = ' ';
  8001b2:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001b6:	4b81                	li	s7,0
  8001b8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001ba:	00044683          	lbu	a3,0(s0)
  8001be:	00140c13          	addi	s8,s0,1
  8001c2:	fdd6859b          	addiw	a1,a3,-35
  8001c6:	0ff5f593          	zext.b	a1,a1
  8001ca:	02bb6663          	bltu	s6,a1,8001f6 <vprintfmt+0x98>
  8001ce:	058a                	slli	a1,a1,0x2
  8001d0:	95d6                	add	a1,a1,s5
  8001d2:	4198                	lw	a4,0(a1)
  8001d4:	9756                	add	a4,a4,s5
  8001d6:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d8:	70e6                	ld	ra,120(sp)
  8001da:	7446                	ld	s0,112(sp)
  8001dc:	74a6                	ld	s1,104(sp)
  8001de:	7906                	ld	s2,96(sp)
  8001e0:	69e6                	ld	s3,88(sp)
  8001e2:	6a46                	ld	s4,80(sp)
  8001e4:	6aa6                	ld	s5,72(sp)
  8001e6:	6b06                	ld	s6,64(sp)
  8001e8:	7be2                	ld	s7,56(sp)
  8001ea:	7c42                	ld	s8,48(sp)
  8001ec:	7ca2                	ld	s9,40(sp)
  8001ee:	7d02                	ld	s10,32(sp)
  8001f0:	6de2                	ld	s11,24(sp)
  8001f2:	6109                	addi	sp,sp,128
  8001f4:	8082                	ret
            putch('%', putdat);
  8001f6:	85ca                	mv	a1,s2
  8001f8:	02500513          	li	a0,37
  8001fc:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001fe:	fff44783          	lbu	a5,-1(s0)
  800202:	02500713          	li	a4,37
  800206:	8c22                	mv	s8,s0
  800208:	f8e785e3          	beq	a5,a4,800192 <vprintfmt+0x34>
  80020c:	ffec4783          	lbu	a5,-2(s8)
  800210:	1c7d                	addi	s8,s8,-1
  800212:	fee79de3          	bne	a5,a4,80020c <vprintfmt+0xae>
  800216:	bfb5                	j	800192 <vprintfmt+0x34>
                ch = *fmt;
  800218:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80021c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80021e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800222:	fd06071b          	addiw	a4,a2,-48
  800226:	24e56a63          	bltu	a0,a4,80047a <vprintfmt+0x31c>
                ch = *fmt;
  80022a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80022c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80022e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800232:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800236:	0197073b          	addw	a4,a4,s9
  80023a:	0017171b          	slliw	a4,a4,0x1
  80023e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800240:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800244:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800246:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80024a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80024e:	feb570e3          	bgeu	a0,a1,80022e <vprintfmt+0xd0>
            if (width < 0)
  800252:	f60d54e3          	bgez	s10,8001ba <vprintfmt+0x5c>
                width = precision, precision = -1;
  800256:	8d66                	mv	s10,s9
  800258:	5cfd                	li	s9,-1
  80025a:	b785                	j	8001ba <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	8db6                	mv	s11,a3
  80025e:	8462                	mv	s0,s8
  800260:	bfa9                	j	8001ba <vprintfmt+0x5c>
  800262:	8462                	mv	s0,s8
            altflag = 1;
  800264:	4b85                	li	s7,1
            goto reswitch;
  800266:	bf91                	j	8001ba <vprintfmt+0x5c>
    if (lflag >= 2) {
  800268:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80026a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80026e:	00f74463          	blt	a4,a5,800276 <vprintfmt+0x118>
    else if (lflag) {
  800272:	1a078763          	beqz	a5,800420 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800276:	000a3603          	ld	a2,0(s4)
  80027a:	46c1                	li	a3,16
  80027c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80027e:	000d879b          	sext.w	a5,s11
  800282:	876a                	mv	a4,s10
  800284:	85ca                	mv	a1,s2
  800286:	8526                	mv	a0,s1
  800288:	e71ff0ef          	jal	8000f8 <printnum>
            break;
  80028c:	b719                	j	800192 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80028e:	000a2503          	lw	a0,0(s4)
  800292:	85ca                	mv	a1,s2
  800294:	0a21                	addi	s4,s4,8
  800296:	9482                	jalr	s1
            break;
  800298:	bded                	j	800192 <vprintfmt+0x34>
    if (lflag >= 2) {
  80029a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80029c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002a0:	00f74463          	blt	a4,a5,8002a8 <vprintfmt+0x14a>
    else if (lflag) {
  8002a4:	16078963          	beqz	a5,800416 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002a8:	000a3603          	ld	a2,0(s4)
  8002ac:	46a9                	li	a3,10
  8002ae:	8a2e                	mv	s4,a1
  8002b0:	b7f9                	j	80027e <vprintfmt+0x120>
            putch('0', putdat);
  8002b2:	85ca                	mv	a1,s2
  8002b4:	03000513          	li	a0,48
  8002b8:	9482                	jalr	s1
            putch('x', putdat);
  8002ba:	85ca                	mv	a1,s2
  8002bc:	07800513          	li	a0,120
  8002c0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c2:	000a3603          	ld	a2,0(s4)
            goto number;
  8002c6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c8:	0a21                	addi	s4,s4,8
            goto number;
  8002ca:	bf55                	j	80027e <vprintfmt+0x120>
            putch(ch, putdat);
  8002cc:	85ca                	mv	a1,s2
  8002ce:	02500513          	li	a0,37
  8002d2:	9482                	jalr	s1
            break;
  8002d4:	bd7d                	j	800192 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002d6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002da:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002dc:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002de:	bf95                	j	800252 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e6:	00f74463          	blt	a4,a5,8002ee <vprintfmt+0x190>
    else if (lflag) {
  8002ea:	12078163          	beqz	a5,80040c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002ee:	000a3603          	ld	a2,0(s4)
  8002f2:	46a1                	li	a3,8
  8002f4:	8a2e                	mv	s4,a1
  8002f6:	b761                	j	80027e <vprintfmt+0x120>
            if (width < 0)
  8002f8:	876a                	mv	a4,s10
  8002fa:	000d5363          	bgez	s10,800300 <vprintfmt+0x1a2>
  8002fe:	4701                	li	a4,0
  800300:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	8462                	mv	s0,s8
            goto reswitch;
  800306:	bd55                	j	8001ba <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800308:	000d841b          	sext.w	s0,s11
  80030c:	fd340793          	addi	a5,s0,-45
  800310:	00f037b3          	snez	a5,a5
  800314:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800318:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80031c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80031e:	008a0793          	addi	a5,s4,8
  800322:	e43e                	sd	a5,8(sp)
  800324:	100d8c63          	beqz	s11,80043c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800328:	12071363          	bnez	a4,80044e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032c:	000dc783          	lbu	a5,0(s11)
  800330:	0007851b          	sext.w	a0,a5
  800334:	c78d                	beqz	a5,80035e <vprintfmt+0x200>
  800336:	0d85                	addi	s11,s11,1
  800338:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80033a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033e:	000cc563          	bltz	s9,800348 <vprintfmt+0x1ea>
  800342:	3cfd                	addiw	s9,s9,-1
  800344:	008c8d63          	beq	s9,s0,80035e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800348:	020b9663          	bnez	s7,800374 <vprintfmt+0x216>
                    putch(ch, putdat);
  80034c:	85ca                	mv	a1,s2
  80034e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800350:	000dc783          	lbu	a5,0(s11)
  800354:	0d85                	addi	s11,s11,1
  800356:	3d7d                	addiw	s10,s10,-1
  800358:	0007851b          	sext.w	a0,a5
  80035c:	f3ed                	bnez	a5,80033e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  80035e:	01a05963          	blez	s10,800370 <vprintfmt+0x212>
                putch(' ', putdat);
  800362:	85ca                	mv	a1,s2
  800364:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800368:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80036a:	9482                	jalr	s1
            for (; width > 0; width --) {
  80036c:	fe0d1be3          	bnez	s10,800362 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800370:	6a22                	ld	s4,8(sp)
  800372:	b505                	j	800192 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800374:	3781                	addiw	a5,a5,-32
  800376:	fcfa7be3          	bgeu	s4,a5,80034c <vprintfmt+0x1ee>
                    putch('?', putdat);
  80037a:	03f00513          	li	a0,63
  80037e:	85ca                	mv	a1,s2
  800380:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	000dc783          	lbu	a5,0(s11)
  800386:	0d85                	addi	s11,s11,1
  800388:	3d7d                	addiw	s10,s10,-1
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	dbe1                	beqz	a5,80035e <vprintfmt+0x200>
  800390:	fa0cd9e3          	bgez	s9,800342 <vprintfmt+0x1e4>
  800394:	b7c5                	j	800374 <vprintfmt+0x216>
            if (err < 0) {
  800396:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80039a:	4661                	li	a2,24
            err = va_arg(ap, int);
  80039c:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80039e:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a2:	8fb9                	xor	a5,a5,a4
  8003a4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a8:	02d64563          	blt	a2,a3,8003d2 <vprintfmt+0x274>
  8003ac:	00000797          	auipc	a5,0x0
  8003b0:	39478793          	addi	a5,a5,916 # 800740 <error_string>
  8003b4:	00369713          	slli	a4,a3,0x3
  8003b8:	97ba                	add	a5,a5,a4
  8003ba:	639c                	ld	a5,0(a5)
  8003bc:	cb99                	beqz	a5,8003d2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003be:	86be                	mv	a3,a5
  8003c0:	00000617          	auipc	a2,0x0
  8003c4:	16060613          	addi	a2,a2,352 # 800520 <main+0x5c>
  8003c8:	85ca                	mv	a1,s2
  8003ca:	8526                	mv	a0,s1
  8003cc:	0d8000ef          	jal	8004a4 <printfmt>
  8003d0:	b3c9                	j	800192 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d2:	00000617          	auipc	a2,0x0
  8003d6:	13e60613          	addi	a2,a2,318 # 800510 <main+0x4c>
  8003da:	85ca                	mv	a1,s2
  8003dc:	8526                	mv	a0,s1
  8003de:	0c6000ef          	jal	8004a4 <printfmt>
  8003e2:	bb45                	j	800192 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003e6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ea:	00f74363          	blt	a4,a5,8003f0 <vprintfmt+0x292>
    else if (lflag) {
  8003ee:	cf81                	beqz	a5,800406 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003f0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003f4:	02044b63          	bltz	s0,80042a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003f8:	8622                	mv	a2,s0
  8003fa:	8a5e                	mv	s4,s7
  8003fc:	46a9                	li	a3,10
  8003fe:	b541                	j	80027e <vprintfmt+0x120>
            lflag ++;
  800400:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800402:	8462                	mv	s0,s8
            goto reswitch;
  800404:	bb5d                	j	8001ba <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800406:	000a2403          	lw	s0,0(s4)
  80040a:	b7ed                	j	8003f4 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80040c:	000a6603          	lwu	a2,0(s4)
  800410:	46a1                	li	a3,8
  800412:	8a2e                	mv	s4,a1
  800414:	b5ad                	j	80027e <vprintfmt+0x120>
  800416:	000a6603          	lwu	a2,0(s4)
  80041a:	46a9                	li	a3,10
  80041c:	8a2e                	mv	s4,a1
  80041e:	b585                	j	80027e <vprintfmt+0x120>
  800420:	000a6603          	lwu	a2,0(s4)
  800424:	46c1                	li	a3,16
  800426:	8a2e                	mv	s4,a1
  800428:	bd99                	j	80027e <vprintfmt+0x120>
                putch('-', putdat);
  80042a:	85ca                	mv	a1,s2
  80042c:	02d00513          	li	a0,45
  800430:	9482                	jalr	s1
                num = -(long long)num;
  800432:	40800633          	neg	a2,s0
  800436:	8a5e                	mv	s4,s7
  800438:	46a9                	li	a3,10
  80043a:	b591                	j	80027e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80043c:	e329                	bnez	a4,80047e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043e:	02800793          	li	a5,40
  800442:	853e                	mv	a0,a5
  800444:	00000d97          	auipc	s11,0x0
  800448:	0bdd8d93          	addi	s11,s11,189 # 800501 <main+0x3d>
  80044c:	b5f5                	j	800338 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044e:	85e6                	mv	a1,s9
  800450:	856e                	mv	a0,s11
  800452:	c8bff0ef          	jal	8000dc <strnlen>
  800456:	40ad0d3b          	subw	s10,s10,a0
  80045a:	01a05863          	blez	s10,80046a <vprintfmt+0x30c>
                    putch(padc, putdat);
  80045e:	85ca                	mv	a1,s2
  800460:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800462:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800464:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800466:	fe0d1ce3          	bnez	s10,80045e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80046a:	000dc783          	lbu	a5,0(s11)
  80046e:	0007851b          	sext.w	a0,a5
  800472:	ec0792e3          	bnez	a5,800336 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800476:	6a22                	ld	s4,8(sp)
  800478:	bb29                	j	800192 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80047a:	8462                	mv	s0,s8
  80047c:	bbd9                	j	800252 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	85e6                	mv	a1,s9
  800480:	00000517          	auipc	a0,0x0
  800484:	08050513          	addi	a0,a0,128 # 800500 <main+0x3c>
  800488:	c55ff0ef          	jal	8000dc <strnlen>
  80048c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800490:	02800793          	li	a5,40
                p = "(null)";
  800494:	00000d97          	auipc	s11,0x0
  800498:	06cd8d93          	addi	s11,s11,108 # 800500 <main+0x3c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	fda040e3          	bgtz	s10,80045e <vprintfmt+0x300>
  8004a2:	bd51                	j	800336 <vprintfmt+0x1d8>

00000000008004a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	ec06                	sd	ra,24(sp)
  8004b0:	f83a                	sd	a4,48(sp)
  8004b2:	fc3e                	sd	a5,56(sp)
  8004b4:	e0c2                	sd	a6,64(sp)
  8004b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ba:	ca5ff0ef          	jal	80015e <vprintfmt>
}
  8004be:	60e2                	ld	ra,24(sp)
  8004c0:	6161                	addi	sp,sp,80
  8004c2:	8082                	ret

00000000008004c4 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004c4:	1141                	addi	sp,sp,-16
	// Never mind
    // asm volatile("int $14");
    exit(0);
  8004c6:	4501                	li	a0,0
main(void) {
  8004c8:	e406                	sd	ra,8(sp)
    exit(0);
  8004ca:	b9fff0ef          	jal	800068 <exit>
