
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

0000000000800060 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800060:	4549                	li	a0,18
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800064:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800066:	4579                	li	a0,30
  800068:	bf65                	j	800020 <syscall>

000000000080006a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80006a:	1141                	addi	sp,sp,-16
  80006c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80006e:	fedff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800072:	00000517          	auipc	a0,0x0
  800076:	48e50513          	addi	a0,a0,1166 # 800500 <main+0x38>
  80007a:	026000ef          	jal	8000a0 <cprintf>
    while (1);
  80007e:	a001                	j	80007e <exit+0x14>

0000000000800080 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800080:	b7c5                	j	800060 <sys_getpid>

0000000000800082 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800082:	052000ef          	jal	8000d4 <umain>
1:  j 1b
  800086:	a001                	j	800086 <_start+0x4>

0000000000800088 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800088:	1101                	addi	sp,sp,-32
  80008a:	ec06                	sd	ra,24(sp)
  80008c:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80008e:	fd7ff0ef          	jal	800064 <sys_putc>
    (*cnt) ++;
  800092:	65a2                	ld	a1,8(sp)
}
  800094:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800096:	419c                	lw	a5,0(a1)
  800098:	2785                	addiw	a5,a5,1
  80009a:	c19c                	sw	a5,0(a1)
}
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fd850513          	addi	a0,a0,-40 # 800088 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c4:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c6:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	09a000ef          	jal	800162 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d4:	1141                	addi	sp,sp,-16
  8000d6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d8:	3f0000ef          	jal	8004c8 <main>
    exit(ret);
  8000dc:	f8fff0ef          	jal	80006a <exit>

00000000008000e0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000e0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000e2:	e589                	bnez	a1,8000ec <strnlen+0xc>
  8000e4:	a811                	j	8000f8 <strnlen+0x18>
        cnt ++;
  8000e6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000e8:	00f58863          	beq	a1,a5,8000f8 <strnlen+0x18>
  8000ec:	00f50733          	add	a4,a0,a5
  8000f0:	00074703          	lbu	a4,0(a4)
  8000f4:	fb6d                	bnez	a4,8000e6 <strnlen+0x6>
  8000f6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000f8:	852e                	mv	a0,a1
  8000fa:	8082                	ret

00000000008000fc <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000fc:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	f022                	sd	s0,32(sp)
  800104:	ec26                	sd	s1,24(sp)
  800106:	e84a                	sd	s2,16(sp)
  800108:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80010a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010e:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800110:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800114:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800118:	84aa                	mv	s1,a0
  80011a:	892e                	mv	s2,a1
    if (num >= base) {
  80011c:	03067d63          	bgeu	a2,a6,800156 <printnum+0x5a>
  800120:	e44e                	sd	s3,8(sp)
  800122:	89be                	mv	s3,a5
        while (-- width > 0)
  800124:	4785                	li	a5,1
  800126:	00e7d763          	bge	a5,a4,800134 <printnum+0x38>
            putch(padc, putdat);
  80012a:	85ca                	mv	a1,s2
  80012c:	854e                	mv	a0,s3
        while (-- width > 0)
  80012e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800130:	9482                	jalr	s1
        while (-- width > 0)
  800132:	fc65                	bnez	s0,80012a <printnum+0x2e>
  800134:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800136:	00000797          	auipc	a5,0x0
  80013a:	3e278793          	addi	a5,a5,994 # 800518 <main+0x50>
  80013e:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800140:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800142:	0007c503          	lbu	a0,0(a5)
}
  800146:	70a2                	ld	ra,40(sp)
  800148:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014a:	85ca                	mv	a1,s2
  80014c:	87a6                	mv	a5,s1
}
  80014e:	6942                	ld	s2,16(sp)
  800150:	64e2                	ld	s1,24(sp)
  800152:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800154:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800156:	03065633          	divu	a2,a2,a6
  80015a:	8722                	mv	a4,s0
  80015c:	fa1ff0ef          	jal	8000fc <printnum>
  800160:	bfd9                	j	800136 <printnum+0x3a>

0000000000800162 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800162:	7119                	addi	sp,sp,-128
  800164:	f4a6                	sd	s1,104(sp)
  800166:	f0ca                	sd	s2,96(sp)
  800168:	ecce                	sd	s3,88(sp)
  80016a:	e8d2                	sd	s4,80(sp)
  80016c:	e4d6                	sd	s5,72(sp)
  80016e:	e0da                	sd	s6,64(sp)
  800170:	f862                	sd	s8,48(sp)
  800172:	fc86                	sd	ra,120(sp)
  800174:	f8a2                	sd	s0,112(sp)
  800176:	fc5e                	sd	s7,56(sp)
  800178:	f466                	sd	s9,40(sp)
  80017a:	f06a                	sd	s10,32(sp)
  80017c:	ec6e                	sd	s11,24(sp)
  80017e:	84aa                	mv	s1,a0
  800180:	8c32                	mv	s8,a2
  800182:	8a36                	mv	s4,a3
  800184:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800186:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80018a:	05500b13          	li	s6,85
  80018e:	00000a97          	auipc	s5,0x0
  800192:	4c2a8a93          	addi	s5,s5,1218 # 800650 <main+0x188>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800196:	000c4503          	lbu	a0,0(s8)
  80019a:	001c0413          	addi	s0,s8,1
  80019e:	01350a63          	beq	a0,s3,8001b2 <vprintfmt+0x50>
            if (ch == '\0') {
  8001a2:	cd0d                	beqz	a0,8001dc <vprintfmt+0x7a>
            putch(ch, putdat);
  8001a4:	85ca                	mv	a1,s2
  8001a6:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a8:	00044503          	lbu	a0,0(s0)
  8001ac:	0405                	addi	s0,s0,1
  8001ae:	ff351ae3          	bne	a0,s3,8001a2 <vprintfmt+0x40>
        width = precision = -1;
  8001b2:	5cfd                	li	s9,-1
  8001b4:	8d66                	mv	s10,s9
        char padc = ' ';
  8001b6:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001ba:	4b81                	li	s7,0
  8001bc:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001be:	00044683          	lbu	a3,0(s0)
  8001c2:	00140c13          	addi	s8,s0,1
  8001c6:	fdd6859b          	addiw	a1,a3,-35
  8001ca:	0ff5f593          	zext.b	a1,a1
  8001ce:	02bb6663          	bltu	s6,a1,8001fa <vprintfmt+0x98>
  8001d2:	058a                	slli	a1,a1,0x2
  8001d4:	95d6                	add	a1,a1,s5
  8001d6:	4198                	lw	a4,0(a1)
  8001d8:	9756                	add	a4,a4,s5
  8001da:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001dc:	70e6                	ld	ra,120(sp)
  8001de:	7446                	ld	s0,112(sp)
  8001e0:	74a6                	ld	s1,104(sp)
  8001e2:	7906                	ld	s2,96(sp)
  8001e4:	69e6                	ld	s3,88(sp)
  8001e6:	6a46                	ld	s4,80(sp)
  8001e8:	6aa6                	ld	s5,72(sp)
  8001ea:	6b06                	ld	s6,64(sp)
  8001ec:	7be2                	ld	s7,56(sp)
  8001ee:	7c42                	ld	s8,48(sp)
  8001f0:	7ca2                	ld	s9,40(sp)
  8001f2:	7d02                	ld	s10,32(sp)
  8001f4:	6de2                	ld	s11,24(sp)
  8001f6:	6109                	addi	sp,sp,128
  8001f8:	8082                	ret
            putch('%', putdat);
  8001fa:	85ca                	mv	a1,s2
  8001fc:	02500513          	li	a0,37
  800200:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800202:	fff44783          	lbu	a5,-1(s0)
  800206:	02500713          	li	a4,37
  80020a:	8c22                	mv	s8,s0
  80020c:	f8e785e3          	beq	a5,a4,800196 <vprintfmt+0x34>
  800210:	ffec4783          	lbu	a5,-2(s8)
  800214:	1c7d                	addi	s8,s8,-1
  800216:	fee79de3          	bne	a5,a4,800210 <vprintfmt+0xae>
  80021a:	bfb5                	j	800196 <vprintfmt+0x34>
                ch = *fmt;
  80021c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800220:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800222:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800226:	fd06071b          	addiw	a4,a2,-48
  80022a:	24e56a63          	bltu	a0,a4,80047e <vprintfmt+0x31c>
                ch = *fmt;
  80022e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800230:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800232:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800236:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80023a:	0197073b          	addw	a4,a4,s9
  80023e:	0017171b          	slliw	a4,a4,0x1
  800242:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800244:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800248:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80024a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80024e:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800252:	feb570e3          	bgeu	a0,a1,800232 <vprintfmt+0xd0>
            if (width < 0)
  800256:	f60d54e3          	bgez	s10,8001be <vprintfmt+0x5c>
                width = precision, precision = -1;
  80025a:	8d66                	mv	s10,s9
  80025c:	5cfd                	li	s9,-1
  80025e:	b785                	j	8001be <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800260:	8db6                	mv	s11,a3
  800262:	8462                	mv	s0,s8
  800264:	bfa9                	j	8001be <vprintfmt+0x5c>
  800266:	8462                	mv	s0,s8
            altflag = 1;
  800268:	4b85                	li	s7,1
            goto reswitch;
  80026a:	bf91                	j	8001be <vprintfmt+0x5c>
    if (lflag >= 2) {
  80026c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80026e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800272:	00f74463          	blt	a4,a5,80027a <vprintfmt+0x118>
    else if (lflag) {
  800276:	1a078763          	beqz	a5,800424 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  80027a:	000a3603          	ld	a2,0(s4)
  80027e:	46c1                	li	a3,16
  800280:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800282:	000d879b          	sext.w	a5,s11
  800286:	876a                	mv	a4,s10
  800288:	85ca                	mv	a1,s2
  80028a:	8526                	mv	a0,s1
  80028c:	e71ff0ef          	jal	8000fc <printnum>
            break;
  800290:	b719                	j	800196 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800292:	000a2503          	lw	a0,0(s4)
  800296:	85ca                	mv	a1,s2
  800298:	0a21                	addi	s4,s4,8
  80029a:	9482                	jalr	s1
            break;
  80029c:	bded                	j	800196 <vprintfmt+0x34>
    if (lflag >= 2) {
  80029e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002a4:	00f74463          	blt	a4,a5,8002ac <vprintfmt+0x14a>
    else if (lflag) {
  8002a8:	16078963          	beqz	a5,80041a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ac:	000a3603          	ld	a2,0(s4)
  8002b0:	46a9                	li	a3,10
  8002b2:	8a2e                	mv	s4,a1
  8002b4:	b7f9                	j	800282 <vprintfmt+0x120>
            putch('0', putdat);
  8002b6:	85ca                	mv	a1,s2
  8002b8:	03000513          	li	a0,48
  8002bc:	9482                	jalr	s1
            putch('x', putdat);
  8002be:	85ca                	mv	a1,s2
  8002c0:	07800513          	li	a0,120
  8002c4:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c6:	000a3603          	ld	a2,0(s4)
            goto number;
  8002ca:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002cc:	0a21                	addi	s4,s4,8
            goto number;
  8002ce:	bf55                	j	800282 <vprintfmt+0x120>
            putch(ch, putdat);
  8002d0:	85ca                	mv	a1,s2
  8002d2:	02500513          	li	a0,37
  8002d6:	9482                	jalr	s1
            break;
  8002d8:	bd7d                	j	800196 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002da:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002e0:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002e2:	bf95                	j	800256 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ea:	00f74463          	blt	a4,a5,8002f2 <vprintfmt+0x190>
    else if (lflag) {
  8002ee:	12078163          	beqz	a5,800410 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002f2:	000a3603          	ld	a2,0(s4)
  8002f6:	46a1                	li	a3,8
  8002f8:	8a2e                	mv	s4,a1
  8002fa:	b761                	j	800282 <vprintfmt+0x120>
            if (width < 0)
  8002fc:	876a                	mv	a4,s10
  8002fe:	000d5363          	bgez	s10,800304 <vprintfmt+0x1a2>
  800302:	4701                	li	a4,0
  800304:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800308:	8462                	mv	s0,s8
            goto reswitch;
  80030a:	bd55                	j	8001be <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80030c:	000d841b          	sext.w	s0,s11
  800310:	fd340793          	addi	a5,s0,-45
  800314:	00f037b3          	snez	a5,a5
  800318:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80031c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800320:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800322:	008a0793          	addi	a5,s4,8
  800326:	e43e                	sd	a5,8(sp)
  800328:	100d8c63          	beqz	s11,800440 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80032c:	12071363          	bnez	a4,800452 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800330:	000dc783          	lbu	a5,0(s11)
  800334:	0007851b          	sext.w	a0,a5
  800338:	c78d                	beqz	a5,800362 <vprintfmt+0x200>
  80033a:	0d85                	addi	s11,s11,1
  80033c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80033e:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800342:	000cc563          	bltz	s9,80034c <vprintfmt+0x1ea>
  800346:	3cfd                	addiw	s9,s9,-1
  800348:	008c8d63          	beq	s9,s0,800362 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80034c:	020b9663          	bnez	s7,800378 <vprintfmt+0x216>
                    putch(ch, putdat);
  800350:	85ca                	mv	a1,s2
  800352:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800354:	000dc783          	lbu	a5,0(s11)
  800358:	0d85                	addi	s11,s11,1
  80035a:	3d7d                	addiw	s10,s10,-1
  80035c:	0007851b          	sext.w	a0,a5
  800360:	f3ed                	bnez	a5,800342 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800362:	01a05963          	blez	s10,800374 <vprintfmt+0x212>
                putch(' ', putdat);
  800366:	85ca                	mv	a1,s2
  800368:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80036c:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80036e:	9482                	jalr	s1
            for (; width > 0; width --) {
  800370:	fe0d1be3          	bnez	s10,800366 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800374:	6a22                	ld	s4,8(sp)
  800376:	b505                	j	800196 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800378:	3781                	addiw	a5,a5,-32
  80037a:	fcfa7be3          	bgeu	s4,a5,800350 <vprintfmt+0x1ee>
                    putch('?', putdat);
  80037e:	03f00513          	li	a0,63
  800382:	85ca                	mv	a1,s2
  800384:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800386:	000dc783          	lbu	a5,0(s11)
  80038a:	0d85                	addi	s11,s11,1
  80038c:	3d7d                	addiw	s10,s10,-1
  80038e:	0007851b          	sext.w	a0,a5
  800392:	dbe1                	beqz	a5,800362 <vprintfmt+0x200>
  800394:	fa0cd9e3          	bgez	s9,800346 <vprintfmt+0x1e4>
  800398:	b7c5                	j	800378 <vprintfmt+0x216>
            if (err < 0) {
  80039a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80039e:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003a0:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003a2:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a6:	8fb9                	xor	a5,a5,a4
  8003a8:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ac:	02d64563          	blt	a2,a3,8003d6 <vprintfmt+0x274>
  8003b0:	00000797          	auipc	a5,0x0
  8003b4:	3f878793          	addi	a5,a5,1016 # 8007a8 <error_string>
  8003b8:	00369713          	slli	a4,a3,0x3
  8003bc:	97ba                	add	a5,a5,a4
  8003be:	639c                	ld	a5,0(a5)
  8003c0:	cb99                	beqz	a5,8003d6 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003c2:	86be                	mv	a3,a5
  8003c4:	00000617          	auipc	a2,0x0
  8003c8:	18c60613          	addi	a2,a2,396 # 800550 <main+0x88>
  8003cc:	85ca                	mv	a1,s2
  8003ce:	8526                	mv	a0,s1
  8003d0:	0d8000ef          	jal	8004a8 <printfmt>
  8003d4:	b3c9                	j	800196 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d6:	00000617          	auipc	a2,0x0
  8003da:	16a60613          	addi	a2,a2,362 # 800540 <main+0x78>
  8003de:	85ca                	mv	a1,s2
  8003e0:	8526                	mv	a0,s1
  8003e2:	0c6000ef          	jal	8004a8 <printfmt>
  8003e6:	bb45                	j	800196 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003e8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003ea:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ee:	00f74363          	blt	a4,a5,8003f4 <vprintfmt+0x292>
    else if (lflag) {
  8003f2:	cf81                	beqz	a5,80040a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003f4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003f8:	02044b63          	bltz	s0,80042e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003fc:	8622                	mv	a2,s0
  8003fe:	8a5e                	mv	s4,s7
  800400:	46a9                	li	a3,10
  800402:	b541                	j	800282 <vprintfmt+0x120>
            lflag ++;
  800404:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800406:	8462                	mv	s0,s8
            goto reswitch;
  800408:	bb5d                	j	8001be <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80040a:	000a2403          	lw	s0,0(s4)
  80040e:	b7ed                	j	8003f8 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800410:	000a6603          	lwu	a2,0(s4)
  800414:	46a1                	li	a3,8
  800416:	8a2e                	mv	s4,a1
  800418:	b5ad                	j	800282 <vprintfmt+0x120>
  80041a:	000a6603          	lwu	a2,0(s4)
  80041e:	46a9                	li	a3,10
  800420:	8a2e                	mv	s4,a1
  800422:	b585                	j	800282 <vprintfmt+0x120>
  800424:	000a6603          	lwu	a2,0(s4)
  800428:	46c1                	li	a3,16
  80042a:	8a2e                	mv	s4,a1
  80042c:	bd99                	j	800282 <vprintfmt+0x120>
                putch('-', putdat);
  80042e:	85ca                	mv	a1,s2
  800430:	02d00513          	li	a0,45
  800434:	9482                	jalr	s1
                num = -(long long)num;
  800436:	40800633          	neg	a2,s0
  80043a:	8a5e                	mv	s4,s7
  80043c:	46a9                	li	a3,10
  80043e:	b591                	j	800282 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800440:	e329                	bnez	a4,800482 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800442:	02800793          	li	a5,40
  800446:	853e                	mv	a0,a5
  800448:	00000d97          	auipc	s11,0x0
  80044c:	0e9d8d93          	addi	s11,s11,233 # 800531 <main+0x69>
  800450:	b5f5                	j	80033c <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	85e6                	mv	a1,s9
  800454:	856e                	mv	a0,s11
  800456:	c8bff0ef          	jal	8000e0 <strnlen>
  80045a:	40ad0d3b          	subw	s10,s10,a0
  80045e:	01a05863          	blez	s10,80046e <vprintfmt+0x30c>
                    putch(padc, putdat);
  800462:	85ca                	mv	a1,s2
  800464:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800466:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800468:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046a:	fe0d1ce3          	bnez	s10,800462 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80046e:	000dc783          	lbu	a5,0(s11)
  800472:	0007851b          	sext.w	a0,a5
  800476:	ec0792e3          	bnez	a5,80033a <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  80047a:	6a22                	ld	s4,8(sp)
  80047c:	bb29                	j	800196 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80047e:	8462                	mv	s0,s8
  800480:	bbd9                	j	800256 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	85e6                	mv	a1,s9
  800484:	00000517          	auipc	a0,0x0
  800488:	0ac50513          	addi	a0,a0,172 # 800530 <main+0x68>
  80048c:	c55ff0ef          	jal	8000e0 <strnlen>
  800490:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800494:	02800793          	li	a5,40
                p = "(null)";
  800498:	00000d97          	auipc	s11,0x0
  80049c:	098d8d93          	addi	s11,s11,152 # 800530 <main+0x68>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a0:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a2:	fda040e3          	bgtz	s10,800462 <vprintfmt+0x300>
  8004a6:	bd51                	j	80033a <vprintfmt+0x1d8>

00000000008004a8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004aa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b2:	ec06                	sd	ra,24(sp)
  8004b4:	f83a                	sd	a4,48(sp)
  8004b6:	fc3e                	sd	a5,56(sp)
  8004b8:	e0c2                	sd	a6,64(sp)
  8004ba:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004bc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004be:	ca5ff0ef          	jal	800162 <vprintfmt>
}
  8004c2:	60e2                	ld	ra,24(sp)
  8004c4:	6161                	addi	sp,sp,80
  8004c6:	8082                	ret

00000000008004c8 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004c8:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004ca:	00000517          	auipc	a0,0x0
  8004ce:	14e50513          	addi	a0,a0,334 # 800618 <main+0x150>
main(void) {
  8004d2:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004d4:	bcdff0ef          	jal	8000a0 <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004d8:	ba9ff0ef          	jal	800080 <getpid>
  8004dc:	85aa                	mv	a1,a0
  8004de:	00000517          	auipc	a0,0x0
  8004e2:	14a50513          	addi	a0,a0,330 # 800628 <main+0x160>
  8004e6:	bbbff0ef          	jal	8000a0 <cprintf>
    cprintf("hello pass.\n");
  8004ea:	00000517          	auipc	a0,0x0
  8004ee:	15650513          	addi	a0,a0,342 # 800640 <main+0x178>
  8004f2:	bafff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  8004f6:	60a2                	ld	ra,8(sp)
  8004f8:	4501                	li	a0,0
  8004fa:	0141                	addi	sp,sp,16
  8004fc:	8082                	ret
