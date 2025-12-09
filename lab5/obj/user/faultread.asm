
obj/__user_faultread.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800020:	7175                	addi	sp,sp,-144
  800022:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800024:	e0ba                	sd	a4,64(sp)
  800026:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800028:	e42a                	sd	a0,8(sp)
  80002a:	ecae                	sd	a1,88(sp)
  80002c:	f0b2                	sd	a2,96(sp)
  80002e:	f4b6                	sd	a3,104(sp)
  800030:	fcbe                	sd	a5,120(sp)
  800032:	e142                	sd	a6,128(sp)
  800034:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800036:	f42e                	sd	a1,40(sp)
  800038:	f832                	sd	a2,48(sp)
  80003a:	fc36                	sd	a3,56(sp)
  80003c:	f03a                	sd	a4,32(sp)
  80003e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800040:	6522                	ld	a0,8(sp)
  800042:	75a2                	ld	a1,40(sp)
  800044:	7642                	ld	a2,48(sp)
  800046:	76e2                	ld	a3,56(sp)
  800048:	6706                	ld	a4,64(sp)
  80004a:	67a6                	ld	a5,72(sp)
  80004c:	00000073          	ecall
  800050:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
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
  80006a:	ff1ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80006e:	00000517          	auipc	a0,0x0
  800072:	48250513          	addi	a0,a0,1154 # 8004f0 <main+0x8>
  800076:	026000ef          	jal	ra,80009c <cprintf>
    while (1);
  80007a:	a001                	j	80007a <exit+0x14>

000000000080007c <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80007c:	056000ef          	jal	ra,8000d2 <umain>
1:  j 1b
  800080:	a001                	j	800080 <_start+0x4>

0000000000800082 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800082:	1141                	addi	sp,sp,-16
  800084:	e022                	sd	s0,0(sp)
  800086:	e406                	sd	ra,8(sp)
  800088:	842e                	mv	s0,a1
    sys_putc(c);
  80008a:	fd7ff0ef          	jal	ra,800060 <sys_putc>
    (*cnt) ++;
  80008e:	401c                	lw	a5,0(s0)
}
  800090:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800092:	2785                	addiw	a5,a5,1
  800094:	c01c                	sw	a5,0(s0)
}
  800096:	6402                	ld	s0,0(sp)
  800098:	0141                	addi	sp,sp,16
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
  8000a2:	8e2a                	mv	t3,a0
  8000a4:	f42e                	sd	a1,40(sp)
  8000a6:	f832                	sd	a2,48(sp)
  8000a8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000aa:	00000517          	auipc	a0,0x0
  8000ae:	fd850513          	addi	a0,a0,-40 # 800082 <cputch>
  8000b2:	004c                	addi	a1,sp,4
  8000b4:	869a                	mv	a3,t1
  8000b6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000b8:	ec06                	sd	ra,24(sp)
  8000ba:	e0ba                	sd	a4,64(sp)
  8000bc:	e4be                	sd	a5,72(sp)
  8000be:	e8c2                	sd	a6,80(sp)
  8000c0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c6:	0a0000ef          	jal	ra,800166 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000ca:	60e2                	ld	ra,24(sp)
  8000cc:	4512                	lw	a0,4(sp)
  8000ce:	6125                	addi	sp,sp,96
  8000d0:	8082                	ret

00000000008000d2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d2:	1141                	addi	sp,sp,-16
  8000d4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d6:	412000ef          	jal	ra,8004e8 <main>
    exit(ret);
  8000da:	f8dff0ef          	jal	ra,800066 <exit>

00000000008000de <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000de:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000e0:	e589                	bnez	a1,8000ea <strnlen+0xc>
  8000e2:	a811                	j	8000f6 <strnlen+0x18>
        cnt ++;
  8000e4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000e6:	00f58863          	beq	a1,a5,8000f6 <strnlen+0x18>
  8000ea:	00f50733          	add	a4,a0,a5
  8000ee:	00074703          	lbu	a4,0(a4)
  8000f2:	fb6d                	bnez	a4,8000e4 <strnlen+0x6>
  8000f4:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000f6:	852e                	mv	a0,a1
  8000f8:	8082                	ret

00000000008000fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800100:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800104:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800106:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	f022                	sd	s0,32(sp)
  80010c:	ec26                	sd	s1,24(sp)
  80010e:	e84a                	sd	s2,16(sp)
  800110:	f406                	sd	ra,40(sp)
  800112:	e44e                	sd	s3,8(sp)
  800114:	84aa                	mv	s1,a0
  800116:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800118:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80011c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80011e:	03067e63          	bgeu	a2,a6,80015a <printnum+0x60>
  800122:	89be                	mv	s3,a5
        while (-- width > 0)
  800124:	00805763          	blez	s0,800132 <printnum+0x38>
  800128:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80012a:	85ca                	mv	a1,s2
  80012c:	854e                	mv	a0,s3
  80012e:	9482                	jalr	s1
        while (-- width > 0)
  800130:	fc65                	bnez	s0,800128 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800132:	1a02                	slli	s4,s4,0x20
  800134:	00000797          	auipc	a5,0x0
  800138:	3d478793          	addi	a5,a5,980 # 800508 <main+0x20>
  80013c:	020a5a13          	srli	s4,s4,0x20
  800140:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800142:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800144:	000a4503          	lbu	a0,0(s4)
}
  800148:	70a2                	ld	ra,40(sp)
  80014a:	69a2                	ld	s3,8(sp)
  80014c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014e:	85ca                	mv	a1,s2
  800150:	87a6                	mv	a5,s1
}
  800152:	6942                	ld	s2,16(sp)
  800154:	64e2                	ld	s1,24(sp)
  800156:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800158:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80015a:	03065633          	divu	a2,a2,a6
  80015e:	8722                	mv	a4,s0
  800160:	f9bff0ef          	jal	ra,8000fa <printnum>
  800164:	b7f9                	j	800132 <printnum+0x38>

0000000000800166 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800166:	7119                	addi	sp,sp,-128
  800168:	f4a6                	sd	s1,104(sp)
  80016a:	f0ca                	sd	s2,96(sp)
  80016c:	ecce                	sd	s3,88(sp)
  80016e:	e8d2                	sd	s4,80(sp)
  800170:	e4d6                	sd	s5,72(sp)
  800172:	e0da                	sd	s6,64(sp)
  800174:	fc5e                	sd	s7,56(sp)
  800176:	f06a                	sd	s10,32(sp)
  800178:	fc86                	sd	ra,120(sp)
  80017a:	f8a2                	sd	s0,112(sp)
  80017c:	f862                	sd	s8,48(sp)
  80017e:	f466                	sd	s9,40(sp)
  800180:	ec6e                	sd	s11,24(sp)
  800182:	892a                	mv	s2,a0
  800184:	84ae                	mv	s1,a1
  800186:	8d32                	mv	s10,a2
  800188:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80018e:	5b7d                	li	s6,-1
  800190:	00000a97          	auipc	s5,0x0
  800194:	3aca8a93          	addi	s5,s5,940 # 80053c <main+0x54>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800198:	00000b97          	auipc	s7,0x0
  80019c:	5c0b8b93          	addi	s7,s7,1472 # 800758 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	000d4503          	lbu	a0,0(s10)
  8001a4:	001d0413          	addi	s0,s10,1
  8001a8:	01350a63          	beq	a0,s3,8001bc <vprintfmt+0x56>
            if (ch == '\0') {
  8001ac:	c121                	beqz	a0,8001ec <vprintfmt+0x86>
            putch(ch, putdat);
  8001ae:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001b2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b4:	fff44503          	lbu	a0,-1(s0)
  8001b8:	ff351ae3          	bne	a0,s3,8001ac <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001bc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001c0:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001c4:	4c81                	li	s9,0
  8001c6:	4881                	li	a7,0
        width = precision = -1;
  8001c8:	5c7d                	li	s8,-1
  8001ca:	5dfd                	li	s11,-1
  8001cc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001d0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	fdd6059b          	addiw	a1,a2,-35
  8001d6:	0ff5f593          	zext.b	a1,a1
  8001da:	00140d13          	addi	s10,s0,1
  8001de:	04b56263          	bltu	a0,a1,800222 <vprintfmt+0xbc>
  8001e2:	058a                	slli	a1,a1,0x2
  8001e4:	95d6                	add	a1,a1,s5
  8001e6:	4194                	lw	a3,0(a1)
  8001e8:	96d6                	add	a3,a3,s5
  8001ea:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001ec:	70e6                	ld	ra,120(sp)
  8001ee:	7446                	ld	s0,112(sp)
  8001f0:	74a6                	ld	s1,104(sp)
  8001f2:	7906                	ld	s2,96(sp)
  8001f4:	69e6                	ld	s3,88(sp)
  8001f6:	6a46                	ld	s4,80(sp)
  8001f8:	6aa6                	ld	s5,72(sp)
  8001fa:	6b06                	ld	s6,64(sp)
  8001fc:	7be2                	ld	s7,56(sp)
  8001fe:	7c42                	ld	s8,48(sp)
  800200:	7ca2                	ld	s9,40(sp)
  800202:	7d02                	ld	s10,32(sp)
  800204:	6de2                	ld	s11,24(sp)
  800206:	6109                	addi	sp,sp,128
  800208:	8082                	ret
            padc = '0';
  80020a:	87b2                	mv	a5,a2
            goto reswitch;
  80020c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800210:	846a                	mv	s0,s10
  800212:	00140d13          	addi	s10,s0,1
  800216:	fdd6059b          	addiw	a1,a2,-35
  80021a:	0ff5f593          	zext.b	a1,a1
  80021e:	fcb572e3          	bgeu	a0,a1,8001e2 <vprintfmt+0x7c>
            putch('%', putdat);
  800222:	85a6                	mv	a1,s1
  800224:	02500513          	li	a0,37
  800228:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80022a:	fff44783          	lbu	a5,-1(s0)
  80022e:	8d22                	mv	s10,s0
  800230:	f73788e3          	beq	a5,s3,8001a0 <vprintfmt+0x3a>
  800234:	ffed4783          	lbu	a5,-2(s10)
  800238:	1d7d                	addi	s10,s10,-1
  80023a:	ff379de3          	bne	a5,s3,800234 <vprintfmt+0xce>
  80023e:	b78d                	j	8001a0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800240:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800244:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800248:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80024a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80024e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800252:	02d86463          	bltu	a6,a3,80027a <vprintfmt+0x114>
                ch = *fmt;
  800256:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80025a:	002c169b          	slliw	a3,s8,0x2
  80025e:	0186873b          	addw	a4,a3,s8
  800262:	0017171b          	slliw	a4,a4,0x1
  800266:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800268:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  80026c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80026e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800272:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800276:	fed870e3          	bgeu	a6,a3,800256 <vprintfmt+0xf0>
            if (width < 0)
  80027a:	f40ddce3          	bgez	s11,8001d2 <vprintfmt+0x6c>
                width = precision, precision = -1;
  80027e:	8de2                	mv	s11,s8
  800280:	5c7d                	li	s8,-1
  800282:	bf81                	j	8001d2 <vprintfmt+0x6c>
            if (width < 0)
  800284:	fffdc693          	not	a3,s11
  800288:	96fd                	srai	a3,a3,0x3f
  80028a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	00144603          	lbu	a2,1(s0)
  800292:	2d81                	sext.w	s11,s11
  800294:	846a                	mv	s0,s10
            goto reswitch;
  800296:	bf35                	j	8001d2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800298:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80029c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002a0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	846a                	mv	s0,s10
            goto process_precision;
  8002a4:	bfd9                	j	80027a <vprintfmt+0x114>
    if (lflag >= 2) {
  8002a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ac:	01174463          	blt	a4,a7,8002b4 <vprintfmt+0x14e>
    else if (lflag) {
  8002b0:	1a088e63          	beqz	a7,80046c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002b4:	000a3603          	ld	a2,0(s4)
  8002b8:	46c1                	li	a3,16
  8002ba:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002bc:	2781                	sext.w	a5,a5
  8002be:	876e                	mv	a4,s11
  8002c0:	85a6                	mv	a1,s1
  8002c2:	854a                	mv	a0,s2
  8002c4:	e37ff0ef          	jal	ra,8000fa <printnum>
            break;
  8002c8:	bde1                	j	8001a0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002ca:	000a2503          	lw	a0,0(s4)
  8002ce:	85a6                	mv	a1,s1
  8002d0:	0a21                	addi	s4,s4,8
  8002d2:	9902                	jalr	s2
            break;
  8002d4:	b5f1                	j	8001a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002d6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002d8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002dc:	01174463          	blt	a4,a7,8002e4 <vprintfmt+0x17e>
    else if (lflag) {
  8002e0:	18088163          	beqz	a7,800462 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002e4:	000a3603          	ld	a2,0(s4)
  8002e8:	46a9                	li	a3,10
  8002ea:	8a2e                	mv	s4,a1
  8002ec:	bfc1                	j	8002bc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002ee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002f2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002f4:	846a                	mv	s0,s10
            goto reswitch;
  8002f6:	bdf1                	j	8001d2 <vprintfmt+0x6c>
            putch(ch, putdat);
  8002f8:	85a6                	mv	a1,s1
  8002fa:	02500513          	li	a0,37
  8002fe:	9902                	jalr	s2
            break;
  800300:	b545                	j	8001a0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800302:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800306:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800308:	846a                	mv	s0,s10
            goto reswitch;
  80030a:	b5e1                	j	8001d2 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80030c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80030e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800312:	01174463          	blt	a4,a7,80031a <vprintfmt+0x1b4>
    else if (lflag) {
  800316:	14088163          	beqz	a7,800458 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80031a:	000a3603          	ld	a2,0(s4)
  80031e:	46a1                	li	a3,8
  800320:	8a2e                	mv	s4,a1
  800322:	bf69                	j	8002bc <vprintfmt+0x156>
            putch('0', putdat);
  800324:	03000513          	li	a0,48
  800328:	85a6                	mv	a1,s1
  80032a:	e03e                	sd	a5,0(sp)
  80032c:	9902                	jalr	s2
            putch('x', putdat);
  80032e:	85a6                	mv	a1,s1
  800330:	07800513          	li	a0,120
  800334:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800336:	0a21                	addi	s4,s4,8
            goto number;
  800338:	6782                	ld	a5,0(sp)
  80033a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800340:	bfb5                	j	8002bc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800342:	000a3403          	ld	s0,0(s4)
  800346:	008a0713          	addi	a4,s4,8
  80034a:	e03a                	sd	a4,0(sp)
  80034c:	14040263          	beqz	s0,800490 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800350:	0fb05763          	blez	s11,80043e <vprintfmt+0x2d8>
  800354:	02d00693          	li	a3,45
  800358:	0cd79163          	bne	a5,a3,80041a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035c:	00044783          	lbu	a5,0(s0)
  800360:	0007851b          	sext.w	a0,a5
  800364:	cf85                	beqz	a5,80039c <vprintfmt+0x236>
  800366:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80036a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036e:	000c4563          	bltz	s8,800378 <vprintfmt+0x212>
  800372:	3c7d                	addiw	s8,s8,-1
  800374:	036c0263          	beq	s8,s6,800398 <vprintfmt+0x232>
                    putch('?', putdat);
  800378:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037a:	0e0c8e63          	beqz	s9,800476 <vprintfmt+0x310>
  80037e:	3781                	addiw	a5,a5,-32
  800380:	0ef47b63          	bgeu	s0,a5,800476 <vprintfmt+0x310>
                    putch('?', putdat);
  800384:	03f00513          	li	a0,63
  800388:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	000a4783          	lbu	a5,0(s4)
  80038e:	3dfd                	addiw	s11,s11,-1
  800390:	0a05                	addi	s4,s4,1
  800392:	0007851b          	sext.w	a0,a5
  800396:	ffe1                	bnez	a5,80036e <vprintfmt+0x208>
            for (; width > 0; width --) {
  800398:	01b05963          	blez	s11,8003aa <vprintfmt+0x244>
  80039c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80039e:	85a6                	mv	a1,s1
  8003a0:	02000513          	li	a0,32
  8003a4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a6:	fe0d9be3          	bnez	s11,80039c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003aa:	6a02                	ld	s4,0(sp)
  8003ac:	bbd5                	j	8001a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003b0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003b4:	01174463          	blt	a4,a7,8003bc <vprintfmt+0x256>
    else if (lflag) {
  8003b8:	08088d63          	beqz	a7,800452 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003bc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003c0:	0a044d63          	bltz	s0,80047a <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003c4:	8622                	mv	a2,s0
  8003c6:	8a66                	mv	s4,s9
  8003c8:	46a9                	li	a3,10
  8003ca:	bdcd                	j	8002bc <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003cc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003d0:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003d2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003d4:	41f7d69b          	sraiw	a3,a5,0x1f
  8003d8:	8fb5                	xor	a5,a5,a3
  8003da:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003de:	02d74163          	blt	a4,a3,800400 <vprintfmt+0x29a>
  8003e2:	00369793          	slli	a5,a3,0x3
  8003e6:	97de                	add	a5,a5,s7
  8003e8:	639c                	ld	a5,0(a5)
  8003ea:	cb99                	beqz	a5,800400 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003ec:	86be                	mv	a3,a5
  8003ee:	00000617          	auipc	a2,0x0
  8003f2:	14a60613          	addi	a2,a2,330 # 800538 <main+0x50>
  8003f6:	85a6                	mv	a1,s1
  8003f8:	854a                	mv	a0,s2
  8003fa:	0ce000ef          	jal	ra,8004c8 <printfmt>
  8003fe:	b34d                	j	8001a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800400:	00000617          	auipc	a2,0x0
  800404:	12860613          	addi	a2,a2,296 # 800528 <main+0x40>
  800408:	85a6                	mv	a1,s1
  80040a:	854a                	mv	a0,s2
  80040c:	0bc000ef          	jal	ra,8004c8 <printfmt>
  800410:	bb41                	j	8001a0 <vprintfmt+0x3a>
                p = "(null)";
  800412:	00000417          	auipc	s0,0x0
  800416:	10e40413          	addi	s0,s0,270 # 800520 <main+0x38>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80041a:	85e2                	mv	a1,s8
  80041c:	8522                	mv	a0,s0
  80041e:	e43e                	sd	a5,8(sp)
  800420:	cbfff0ef          	jal	ra,8000de <strnlen>
  800424:	40ad8dbb          	subw	s11,s11,a0
  800428:	01b05b63          	blez	s11,80043e <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80042c:	67a2                	ld	a5,8(sp)
  80042e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800432:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800434:	85a6                	mv	a1,s1
  800436:	8552                	mv	a0,s4
  800438:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043a:	fe0d9ce3          	bnez	s11,800432 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043e:	00044783          	lbu	a5,0(s0)
  800442:	00140a13          	addi	s4,s0,1
  800446:	0007851b          	sext.w	a0,a5
  80044a:	d3a5                	beqz	a5,8003aa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80044c:	05e00413          	li	s0,94
  800450:	bf39                	j	80036e <vprintfmt+0x208>
        return va_arg(*ap, int);
  800452:	000a2403          	lw	s0,0(s4)
  800456:	b7ad                	j	8003c0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800458:	000a6603          	lwu	a2,0(s4)
  80045c:	46a1                	li	a3,8
  80045e:	8a2e                	mv	s4,a1
  800460:	bdb1                	j	8002bc <vprintfmt+0x156>
  800462:	000a6603          	lwu	a2,0(s4)
  800466:	46a9                	li	a3,10
  800468:	8a2e                	mv	s4,a1
  80046a:	bd89                	j	8002bc <vprintfmt+0x156>
  80046c:	000a6603          	lwu	a2,0(s4)
  800470:	46c1                	li	a3,16
  800472:	8a2e                	mv	s4,a1
  800474:	b5a1                	j	8002bc <vprintfmt+0x156>
                    putch(ch, putdat);
  800476:	9902                	jalr	s2
  800478:	bf09                	j	80038a <vprintfmt+0x224>
                putch('-', putdat);
  80047a:	85a6                	mv	a1,s1
  80047c:	02d00513          	li	a0,45
  800480:	e03e                	sd	a5,0(sp)
  800482:	9902                	jalr	s2
                num = -(long long)num;
  800484:	6782                	ld	a5,0(sp)
  800486:	8a66                	mv	s4,s9
  800488:	40800633          	neg	a2,s0
  80048c:	46a9                	li	a3,10
  80048e:	b53d                	j	8002bc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800490:	03b05163          	blez	s11,8004b2 <vprintfmt+0x34c>
  800494:	02d00693          	li	a3,45
  800498:	f6d79de3          	bne	a5,a3,800412 <vprintfmt+0x2ac>
                p = "(null)";
  80049c:	00000417          	auipc	s0,0x0
  8004a0:	08440413          	addi	s0,s0,132 # 800520 <main+0x38>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a4:	02800793          	li	a5,40
  8004a8:	02800513          	li	a0,40
  8004ac:	00140a13          	addi	s4,s0,1
  8004b0:	bd6d                	j	80036a <vprintfmt+0x204>
  8004b2:	00000a17          	auipc	s4,0x0
  8004b6:	06fa0a13          	addi	s4,s4,111 # 800521 <main+0x39>
  8004ba:	02800513          	li	a0,40
  8004be:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004c2:	05e00413          	li	s0,94
  8004c6:	b565                	j	80036e <vprintfmt+0x208>

00000000008004c8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ca:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ce:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d2:	ec06                	sd	ra,24(sp)
  8004d4:	f83a                	sd	a4,48(sp)
  8004d6:	fc3e                	sd	a5,56(sp)
  8004d8:	e0c2                	sd	a6,64(sp)
  8004da:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004dc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004de:	c89ff0ef          	jal	ra,800166 <vprintfmt>
}
  8004e2:	60e2                	ld	ra,24(sp)
  8004e4:	6161                	addi	sp,sp,80
  8004e6:	8082                	ret

00000000008004e8 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004e8:	00002783          	lw	a5,0(zero) # 0 <syscall-0x800020>
  8004ec:	9002                	ebreak
