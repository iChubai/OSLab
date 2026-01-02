
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

0000000000800060 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800060:	4529                	li	a0,10
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800064:	4549                	li	a0,18
  800066:	bf6d                	j	800020 <syscall>

0000000000800068 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800068:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80006a:	4579                	li	a0,30
  80006c:	bf55                	j	800020 <syscall>

000000000080006e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80006e:	1141                	addi	sp,sp,-16
  800070:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800072:	fe9ff0ef          	jal	80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800076:	00000517          	auipc	a0,0x0
  80007a:	4c250513          	addi	a0,a0,1218 # 800538 <main+0x6a>
  80007e:	028000ef          	jal	8000a6 <cprintf>
    while (1);
  800082:	a001                	j	800082 <exit+0x14>

0000000000800084 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800084:	bff1                	j	800060 <sys_yield>

0000000000800086 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800086:	bff9                	j	800064 <sys_getpid>

0000000000800088 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800088:	052000ef          	jal	8000da <umain>
1:  j 1b
  80008c:	a001                	j	80008c <_start+0x4>

000000000080008e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80008e:	1101                	addi	sp,sp,-32
  800090:	ec06                	sd	ra,24(sp)
  800092:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  800094:	fd5ff0ef          	jal	800068 <sys_putc>
    (*cnt) ++;
  800098:	65a2                	ld	a1,8(sp)
}
  80009a:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  80009c:	419c                	lw	a5,0(a1)
  80009e:	2785                	addiw	a5,a5,1
  8000a0:	c19c                	sw	a5,0(a1)
}
  8000a2:	6105                	addi	sp,sp,32
  8000a4:	8082                	ret

00000000008000a6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a6:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a8:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000ac:	f42e                	sd	a1,40(sp)
  8000ae:	f832                	sd	a2,48(sp)
  8000b0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b2:	862a                	mv	a2,a0
  8000b4:	004c                	addi	a1,sp,4
  8000b6:	00000517          	auipc	a0,0x0
  8000ba:	fd850513          	addi	a0,a0,-40 # 80008e <cputch>
  8000be:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c0:	ec06                	sd	ra,24(sp)
  8000c2:	e0ba                	sd	a4,64(sp)
  8000c4:	e4be                	sd	a5,72(sp)
  8000c6:	e8c2                	sd	a6,80(sp)
  8000c8:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000ca:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000cc:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ce:	09a000ef          	jal	800168 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d2:	60e2                	ld	ra,24(sp)
  8000d4:	4512                	lw	a0,4(sp)
  8000d6:	6125                	addi	sp,sp,96
  8000d8:	8082                	ret

00000000008000da <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000da:	1141                	addi	sp,sp,-16
  8000dc:	e406                	sd	ra,8(sp)
    int ret = main();
  8000de:	3f0000ef          	jal	8004ce <main>
    exit(ret);
  8000e2:	f8dff0ef          	jal	80006e <exit>

00000000008000e6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000e6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000e8:	e589                	bnez	a1,8000f2 <strnlen+0xc>
  8000ea:	a811                	j	8000fe <strnlen+0x18>
        cnt ++;
  8000ec:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000ee:	00f58863          	beq	a1,a5,8000fe <strnlen+0x18>
  8000f2:	00f50733          	add	a4,a0,a5
  8000f6:	00074703          	lbu	a4,0(a4)
  8000fa:	fb6d                	bnez	a4,8000ec <strnlen+0x6>
  8000fc:	85be                	mv	a1,a5
    }
    return cnt;
}
  8000fe:	852e                	mv	a0,a1
  800100:	8082                	ret

0000000000800102 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800104:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800108:	f022                	sd	s0,32(sp)
  80010a:	ec26                	sd	s1,24(sp)
  80010c:	e84a                	sd	s2,16(sp)
  80010e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800110:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800114:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800116:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80011a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80011e:	84aa                	mv	s1,a0
  800120:	892e                	mv	s2,a1
    if (num >= base) {
  800122:	03067d63          	bgeu	a2,a6,80015c <printnum+0x5a>
  800126:	e44e                	sd	s3,8(sp)
  800128:	89be                	mv	s3,a5
        while (-- width > 0)
  80012a:	4785                	li	a5,1
  80012c:	00e7d763          	bge	a5,a4,80013a <printnum+0x38>
            putch(padc, putdat);
  800130:	85ca                	mv	a1,s2
  800132:	854e                	mv	a0,s3
        while (-- width > 0)
  800134:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800136:	9482                	jalr	s1
        while (-- width > 0)
  800138:	fc65                	bnez	s0,800130 <printnum+0x2e>
  80013a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013c:	00000797          	auipc	a5,0x0
  800140:	41478793          	addi	a5,a5,1044 # 800550 <main+0x82>
  800144:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800146:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800148:	0007c503          	lbu	a0,0(a5)
}
  80014c:	70a2                	ld	ra,40(sp)
  80014e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800150:	85ca                	mv	a1,s2
  800152:	87a6                	mv	a5,s1
}
  800154:	6942                	ld	s2,16(sp)
  800156:	64e2                	ld	s1,24(sp)
  800158:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80015a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80015c:	03065633          	divu	a2,a2,a6
  800160:	8722                	mv	a4,s0
  800162:	fa1ff0ef          	jal	800102 <printnum>
  800166:	bfd9                	j	80013c <printnum+0x3a>

0000000000800168 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800168:	7119                	addi	sp,sp,-128
  80016a:	f4a6                	sd	s1,104(sp)
  80016c:	f0ca                	sd	s2,96(sp)
  80016e:	ecce                	sd	s3,88(sp)
  800170:	e8d2                	sd	s4,80(sp)
  800172:	e4d6                	sd	s5,72(sp)
  800174:	e0da                	sd	s6,64(sp)
  800176:	f862                	sd	s8,48(sp)
  800178:	fc86                	sd	ra,120(sp)
  80017a:	f8a2                	sd	s0,112(sp)
  80017c:	fc5e                	sd	s7,56(sp)
  80017e:	f466                	sd	s9,40(sp)
  800180:	f06a                	sd	s10,32(sp)
  800182:	ec6e                	sd	s11,24(sp)
  800184:	84aa                	mv	s1,a0
  800186:	8c32                	mv	s8,a2
  800188:	8a36                	mv	s4,a3
  80018a:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018c:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800190:	05500b13          	li	s6,85
  800194:	00000a97          	auipc	s5,0x0
  800198:	534a8a93          	addi	s5,s5,1332 # 8006c8 <main+0x1fa>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019c:	000c4503          	lbu	a0,0(s8)
  8001a0:	001c0413          	addi	s0,s8,1
  8001a4:	01350a63          	beq	a0,s3,8001b8 <vprintfmt+0x50>
            if (ch == '\0') {
  8001a8:	cd0d                	beqz	a0,8001e2 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ae:	00044503          	lbu	a0,0(s0)
  8001b2:	0405                	addi	s0,s0,1
  8001b4:	ff351ae3          	bne	a0,s3,8001a8 <vprintfmt+0x40>
        width = precision = -1;
  8001b8:	5cfd                	li	s9,-1
  8001ba:	8d66                	mv	s10,s9
        char padc = ' ';
  8001bc:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001c0:	4b81                	li	s7,0
  8001c2:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001c4:	00044683          	lbu	a3,0(s0)
  8001c8:	00140c13          	addi	s8,s0,1
  8001cc:	fdd6859b          	addiw	a1,a3,-35
  8001d0:	0ff5f593          	zext.b	a1,a1
  8001d4:	02bb6663          	bltu	s6,a1,800200 <vprintfmt+0x98>
  8001d8:	058a                	slli	a1,a1,0x2
  8001da:	95d6                	add	a1,a1,s5
  8001dc:	4198                	lw	a4,0(a1)
  8001de:	9756                	add	a4,a4,s5
  8001e0:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e2:	70e6                	ld	ra,120(sp)
  8001e4:	7446                	ld	s0,112(sp)
  8001e6:	74a6                	ld	s1,104(sp)
  8001e8:	7906                	ld	s2,96(sp)
  8001ea:	69e6                	ld	s3,88(sp)
  8001ec:	6a46                	ld	s4,80(sp)
  8001ee:	6aa6                	ld	s5,72(sp)
  8001f0:	6b06                	ld	s6,64(sp)
  8001f2:	7be2                	ld	s7,56(sp)
  8001f4:	7c42                	ld	s8,48(sp)
  8001f6:	7ca2                	ld	s9,40(sp)
  8001f8:	7d02                	ld	s10,32(sp)
  8001fa:	6de2                	ld	s11,24(sp)
  8001fc:	6109                	addi	sp,sp,128
  8001fe:	8082                	ret
            putch('%', putdat);
  800200:	85ca                	mv	a1,s2
  800202:	02500513          	li	a0,37
  800206:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800208:	fff44783          	lbu	a5,-1(s0)
  80020c:	02500713          	li	a4,37
  800210:	8c22                	mv	s8,s0
  800212:	f8e785e3          	beq	a5,a4,80019c <vprintfmt+0x34>
  800216:	ffec4783          	lbu	a5,-2(s8)
  80021a:	1c7d                	addi	s8,s8,-1
  80021c:	fee79de3          	bne	a5,a4,800216 <vprintfmt+0xae>
  800220:	bfb5                	j	80019c <vprintfmt+0x34>
                ch = *fmt;
  800222:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800226:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800228:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80022c:	fd06071b          	addiw	a4,a2,-48
  800230:	24e56a63          	bltu	a0,a4,800484 <vprintfmt+0x31c>
                ch = *fmt;
  800234:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800236:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800238:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80023c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800240:	0197073b          	addw	a4,a4,s9
  800244:	0017171b          	slliw	a4,a4,0x1
  800248:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80024a:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80024e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800250:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800254:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800258:	feb570e3          	bgeu	a0,a1,800238 <vprintfmt+0xd0>
            if (width < 0)
  80025c:	f60d54e3          	bgez	s10,8001c4 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800260:	8d66                	mv	s10,s9
  800262:	5cfd                	li	s9,-1
  800264:	b785                	j	8001c4 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800266:	8db6                	mv	s11,a3
  800268:	8462                	mv	s0,s8
  80026a:	bfa9                	j	8001c4 <vprintfmt+0x5c>
  80026c:	8462                	mv	s0,s8
            altflag = 1;
  80026e:	4b85                	li	s7,1
            goto reswitch;
  800270:	bf91                	j	8001c4 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800272:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800274:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800278:	00f74463          	blt	a4,a5,800280 <vprintfmt+0x118>
    else if (lflag) {
  80027c:	1a078763          	beqz	a5,80042a <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800280:	000a3603          	ld	a2,0(s4)
  800284:	46c1                	li	a3,16
  800286:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800288:	000d879b          	sext.w	a5,s11
  80028c:	876a                	mv	a4,s10
  80028e:	85ca                	mv	a1,s2
  800290:	8526                	mv	a0,s1
  800292:	e71ff0ef          	jal	800102 <printnum>
            break;
  800296:	b719                	j	80019c <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800298:	000a2503          	lw	a0,0(s4)
  80029c:	85ca                	mv	a1,s2
  80029e:	0a21                	addi	s4,s4,8
  8002a0:	9482                	jalr	s1
            break;
  8002a2:	bded                	j	80019c <vprintfmt+0x34>
    if (lflag >= 2) {
  8002a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002aa:	00f74463          	blt	a4,a5,8002b2 <vprintfmt+0x14a>
    else if (lflag) {
  8002ae:	16078963          	beqz	a5,800420 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002b2:	000a3603          	ld	a2,0(s4)
  8002b6:	46a9                	li	a3,10
  8002b8:	8a2e                	mv	s4,a1
  8002ba:	b7f9                	j	800288 <vprintfmt+0x120>
            putch('0', putdat);
  8002bc:	85ca                	mv	a1,s2
  8002be:	03000513          	li	a0,48
  8002c2:	9482                	jalr	s1
            putch('x', putdat);
  8002c4:	85ca                	mv	a1,s2
  8002c6:	07800513          	li	a0,120
  8002ca:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002cc:	000a3603          	ld	a2,0(s4)
            goto number;
  8002d0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d2:	0a21                	addi	s4,s4,8
            goto number;
  8002d4:	bf55                	j	800288 <vprintfmt+0x120>
            putch(ch, putdat);
  8002d6:	85ca                	mv	a1,s2
  8002d8:	02500513          	li	a0,37
  8002dc:	9482                	jalr	s1
            break;
  8002de:	bd7d                	j	80019c <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002e0:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e4:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002e6:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002e8:	bf95                	j	80025c <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ec:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f0:	00f74463          	blt	a4,a5,8002f8 <vprintfmt+0x190>
    else if (lflag) {
  8002f4:	12078163          	beqz	a5,800416 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002f8:	000a3603          	ld	a2,0(s4)
  8002fc:	46a1                	li	a3,8
  8002fe:	8a2e                	mv	s4,a1
  800300:	b761                	j	800288 <vprintfmt+0x120>
            if (width < 0)
  800302:	876a                	mv	a4,s10
  800304:	000d5363          	bgez	s10,80030a <vprintfmt+0x1a2>
  800308:	4701                	li	a4,0
  80030a:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80030e:	8462                	mv	s0,s8
            goto reswitch;
  800310:	bd55                	j	8001c4 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800312:	000d841b          	sext.w	s0,s11
  800316:	fd340793          	addi	a5,s0,-45
  80031a:	00f037b3          	snez	a5,a5
  80031e:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800322:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800326:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800328:	008a0793          	addi	a5,s4,8
  80032c:	e43e                	sd	a5,8(sp)
  80032e:	100d8c63          	beqz	s11,800446 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800332:	12071363          	bnez	a4,800458 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800336:	000dc783          	lbu	a5,0(s11)
  80033a:	0007851b          	sext.w	a0,a5
  80033e:	c78d                	beqz	a5,800368 <vprintfmt+0x200>
  800340:	0d85                	addi	s11,s11,1
  800342:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800344:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800348:	000cc563          	bltz	s9,800352 <vprintfmt+0x1ea>
  80034c:	3cfd                	addiw	s9,s9,-1
  80034e:	008c8d63          	beq	s9,s0,800368 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800352:	020b9663          	bnez	s7,80037e <vprintfmt+0x216>
                    putch(ch, putdat);
  800356:	85ca                	mv	a1,s2
  800358:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035a:	000dc783          	lbu	a5,0(s11)
  80035e:	0d85                	addi	s11,s11,1
  800360:	3d7d                	addiw	s10,s10,-1
  800362:	0007851b          	sext.w	a0,a5
  800366:	f3ed                	bnez	a5,800348 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800368:	01a05963          	blez	s10,80037a <vprintfmt+0x212>
                putch(' ', putdat);
  80036c:	85ca                	mv	a1,s2
  80036e:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800372:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800374:	9482                	jalr	s1
            for (; width > 0; width --) {
  800376:	fe0d1be3          	bnez	s10,80036c <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037a:	6a22                	ld	s4,8(sp)
  80037c:	b505                	j	80019c <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  80037e:	3781                	addiw	a5,a5,-32
  800380:	fcfa7be3          	bgeu	s4,a5,800356 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800384:	03f00513          	li	a0,63
  800388:	85ca                	mv	a1,s2
  80038a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038c:	000dc783          	lbu	a5,0(s11)
  800390:	0d85                	addi	s11,s11,1
  800392:	3d7d                	addiw	s10,s10,-1
  800394:	0007851b          	sext.w	a0,a5
  800398:	dbe1                	beqz	a5,800368 <vprintfmt+0x200>
  80039a:	fa0cd9e3          	bgez	s9,80034c <vprintfmt+0x1e4>
  80039e:	b7c5                	j	80037e <vprintfmt+0x216>
            if (err < 0) {
  8003a0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a4:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003a6:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003a8:	41f7d71b          	sraiw	a4,a5,0x1f
  8003ac:	8fb9                	xor	a5,a5,a4
  8003ae:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003b2:	02d64563          	blt	a2,a3,8003dc <vprintfmt+0x274>
  8003b6:	00000797          	auipc	a5,0x0
  8003ba:	46a78793          	addi	a5,a5,1130 # 800820 <error_string>
  8003be:	00369713          	slli	a4,a3,0x3
  8003c2:	97ba                	add	a5,a5,a4
  8003c4:	639c                	ld	a5,0(a5)
  8003c6:	cb99                	beqz	a5,8003dc <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003c8:	86be                	mv	a3,a5
  8003ca:	00000617          	auipc	a2,0x0
  8003ce:	1be60613          	addi	a2,a2,446 # 800588 <main+0xba>
  8003d2:	85ca                	mv	a1,s2
  8003d4:	8526                	mv	a0,s1
  8003d6:	0d8000ef          	jal	8004ae <printfmt>
  8003da:	b3c9                	j	80019c <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003dc:	00000617          	auipc	a2,0x0
  8003e0:	19c60613          	addi	a2,a2,412 # 800578 <main+0xaa>
  8003e4:	85ca                	mv	a1,s2
  8003e6:	8526                	mv	a0,s1
  8003e8:	0c6000ef          	jal	8004ae <printfmt>
  8003ec:	bb45                	j	80019c <vprintfmt+0x34>
    if (lflag >= 2) {
  8003ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f0:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003f4:	00f74363          	blt	a4,a5,8003fa <vprintfmt+0x292>
    else if (lflag) {
  8003f8:	cf81                	beqz	a5,800410 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003fa:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003fe:	02044b63          	bltz	s0,800434 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800402:	8622                	mv	a2,s0
  800404:	8a5e                	mv	s4,s7
  800406:	46a9                	li	a3,10
  800408:	b541                	j	800288 <vprintfmt+0x120>
            lflag ++;
  80040a:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	8462                	mv	s0,s8
            goto reswitch;
  80040e:	bb5d                	j	8001c4 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800410:	000a2403          	lw	s0,0(s4)
  800414:	b7ed                	j	8003fe <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800416:	000a6603          	lwu	a2,0(s4)
  80041a:	46a1                	li	a3,8
  80041c:	8a2e                	mv	s4,a1
  80041e:	b5ad                	j	800288 <vprintfmt+0x120>
  800420:	000a6603          	lwu	a2,0(s4)
  800424:	46a9                	li	a3,10
  800426:	8a2e                	mv	s4,a1
  800428:	b585                	j	800288 <vprintfmt+0x120>
  80042a:	000a6603          	lwu	a2,0(s4)
  80042e:	46c1                	li	a3,16
  800430:	8a2e                	mv	s4,a1
  800432:	bd99                	j	800288 <vprintfmt+0x120>
                putch('-', putdat);
  800434:	85ca                	mv	a1,s2
  800436:	02d00513          	li	a0,45
  80043a:	9482                	jalr	s1
                num = -(long long)num;
  80043c:	40800633          	neg	a2,s0
  800440:	8a5e                	mv	s4,s7
  800442:	46a9                	li	a3,10
  800444:	b591                	j	800288 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800446:	e329                	bnez	a4,800488 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800448:	02800793          	li	a5,40
  80044c:	853e                	mv	a0,a5
  80044e:	00000d97          	auipc	s11,0x0
  800452:	11bd8d93          	addi	s11,s11,283 # 800569 <main+0x9b>
  800456:	b5f5                	j	800342 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800458:	85e6                	mv	a1,s9
  80045a:	856e                	mv	a0,s11
  80045c:	c8bff0ef          	jal	8000e6 <strnlen>
  800460:	40ad0d3b          	subw	s10,s10,a0
  800464:	01a05863          	blez	s10,800474 <vprintfmt+0x30c>
                    putch(padc, putdat);
  800468:	85ca                	mv	a1,s2
  80046a:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046c:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  80046e:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800470:	fe0d1ce3          	bnez	s10,800468 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800474:	000dc783          	lbu	a5,0(s11)
  800478:	0007851b          	sext.w	a0,a5
  80047c:	ec0792e3          	bnez	a5,800340 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800480:	6a22                	ld	s4,8(sp)
  800482:	bb29                	j	80019c <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800484:	8462                	mv	s0,s8
  800486:	bbd9                	j	80025c <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800488:	85e6                	mv	a1,s9
  80048a:	00000517          	auipc	a0,0x0
  80048e:	0de50513          	addi	a0,a0,222 # 800568 <main+0x9a>
  800492:	c55ff0ef          	jal	8000e6 <strnlen>
  800496:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049a:	02800793          	li	a5,40
                p = "(null)";
  80049e:	00000d97          	auipc	s11,0x0
  8004a2:	0cad8d93          	addi	s11,s11,202 # 800568 <main+0x9a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a6:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	fda040e3          	bgtz	s10,800468 <vprintfmt+0x300>
  8004ac:	bd51                	j	800340 <vprintfmt+0x1d8>

00000000008004ae <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b8:	ec06                	sd	ra,24(sp)
  8004ba:	f83a                	sd	a4,48(sp)
  8004bc:	fc3e                	sd	a5,56(sp)
  8004be:	e0c2                	sd	a6,64(sp)
  8004c0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c4:	ca5ff0ef          	jal	800168 <vprintfmt>
}
  8004c8:	60e2                	ld	ra,24(sp)
  8004ca:	6161                	addi	sp,sp,80
  8004cc:	8082                	ret

00000000008004ce <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004ce:	1101                	addi	sp,sp,-32
  8004d0:	ec06                	sd	ra,24(sp)
  8004d2:	e822                	sd	s0,16(sp)
  8004d4:	e426                	sd	s1,8(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  8004d6:	bb1ff0ef          	jal	800086 <getpid>
  8004da:	85aa                	mv	a1,a0
  8004dc:	00000517          	auipc	a0,0x0
  8004e0:	17450513          	addi	a0,a0,372 # 800650 <main+0x182>
  8004e4:	bc3ff0ef          	jal	8000a6 <cprintf>
    for (i = 0; i < 5; i ++) {
  8004e8:	4401                	li	s0,0
  8004ea:	4495                	li	s1,5
        yield();
  8004ec:	b99ff0ef          	jal	800084 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  8004f0:	b97ff0ef          	jal	800086 <getpid>
  8004f4:	85aa                	mv	a1,a0
  8004f6:	8622                	mv	a2,s0
  8004f8:	00000517          	auipc	a0,0x0
  8004fc:	17850513          	addi	a0,a0,376 # 800670 <main+0x1a2>
    for (i = 0; i < 5; i ++) {
  800500:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800502:	ba5ff0ef          	jal	8000a6 <cprintf>
    for (i = 0; i < 5; i ++) {
  800506:	fe9413e3          	bne	s0,s1,8004ec <main+0x1e>
    }
    cprintf("All done in process %d.\n", getpid());
  80050a:	b7dff0ef          	jal	800086 <getpid>
  80050e:	85aa                	mv	a1,a0
  800510:	00000517          	auipc	a0,0x0
  800514:	18850513          	addi	a0,a0,392 # 800698 <main+0x1ca>
  800518:	b8fff0ef          	jal	8000a6 <cprintf>
    cprintf("yield pass.\n");
  80051c:	00000517          	auipc	a0,0x0
  800520:	19c50513          	addi	a0,a0,412 # 8006b8 <main+0x1ea>
  800524:	b83ff0ef          	jal	8000a6 <cprintf>
    return 0;
}
  800528:	60e2                	ld	ra,24(sp)
  80052a:	6442                	ld	s0,16(sp)
  80052c:	64a2                	ld	s1,8(sp)
  80052e:	4501                	li	a0,0
  800530:	6105                	addi	sp,sp,32
  800532:	8082                	ret
