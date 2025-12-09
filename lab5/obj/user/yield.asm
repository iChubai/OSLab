
obj/__user_yield.out:     file format elf64-littleriscv


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
  800072:	fe9ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800076:	00000517          	auipc	a0,0x0
  80007a:	4ea50513          	addi	a0,a0,1258 # 800560 <main+0x6c>
  80007e:	02a000ef          	jal	ra,8000a8 <cprintf>
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
.text
.globl _start
_start:
    # call user-program function
    call umain
  800088:	056000ef          	jal	ra,8000de <umain>
1:  j 1b
  80008c:	a001                	j	80008c <_start+0x4>

000000000080008e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80008e:	1141                	addi	sp,sp,-16
  800090:	e022                	sd	s0,0(sp)
  800092:	e406                	sd	ra,8(sp)
  800094:	842e                	mv	s0,a1
    sys_putc(c);
  800096:	fd3ff0ef          	jal	ra,800068 <sys_putc>
    (*cnt) ++;
  80009a:	401c                	lw	a5,0(s0)
}
  80009c:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  80009e:	2785                	addiw	a5,a5,1
  8000a0:	c01c                	sw	a5,0(s0)
}
  8000a2:	6402                	ld	s0,0(sp)
  8000a4:	0141                	addi	sp,sp,16
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
  8000ae:	8e2a                	mv	t3,a0
  8000b0:	f42e                	sd	a1,40(sp)
  8000b2:	f832                	sd	a2,48(sp)
  8000b4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b6:	00000517          	auipc	a0,0x0
  8000ba:	fd850513          	addi	a0,a0,-40 # 80008e <cputch>
  8000be:	004c                	addi	a1,sp,4
  8000c0:	869a                	mv	a3,t1
  8000c2:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000c4:	ec06                	sd	ra,24(sp)
  8000c6:	e0ba                	sd	a4,64(sp)
  8000c8:	e4be                	sd	a5,72(sp)
  8000ca:	e8c2                	sd	a6,80(sp)
  8000cc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000ce:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d2:	0a0000ef          	jal	ra,800172 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d6:	60e2                	ld	ra,24(sp)
  8000d8:	4512                	lw	a0,4(sp)
  8000da:	6125                	addi	sp,sp,96
  8000dc:	8082                	ret

00000000008000de <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e2:	412000ef          	jal	ra,8004f4 <main>
    exit(ret);
  8000e6:	f89ff0ef          	jal	ra,80006e <exit>

00000000008000ea <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000ea:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000ec:	e589                	bnez	a1,8000f6 <strnlen+0xc>
  8000ee:	a811                	j	800102 <strnlen+0x18>
        cnt ++;
  8000f0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000f2:	00f58863          	beq	a1,a5,800102 <strnlen+0x18>
  8000f6:	00f50733          	add	a4,a0,a5
  8000fa:	00074703          	lbu	a4,0(a4)
  8000fe:	fb6d                	bnez	a4,8000f0 <strnlen+0x6>
  800100:	85be                	mv	a1,a5
    }
    return cnt;
}
  800102:	852e                	mv	a0,a1
  800104:	8082                	ret

0000000000800106 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800106:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80010c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800110:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800112:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800116:	f022                	sd	s0,32(sp)
  800118:	ec26                	sd	s1,24(sp)
  80011a:	e84a                	sd	s2,16(sp)
  80011c:	f406                	sd	ra,40(sp)
  80011e:	e44e                	sd	s3,8(sp)
  800120:	84aa                	mv	s1,a0
  800122:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800124:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800128:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80012a:	03067e63          	bgeu	a2,a6,800166 <printnum+0x60>
  80012e:	89be                	mv	s3,a5
        while (-- width > 0)
  800130:	00805763          	blez	s0,80013e <printnum+0x38>
  800134:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800136:	85ca                	mv	a1,s2
  800138:	854e                	mv	a0,s3
  80013a:	9482                	jalr	s1
        while (-- width > 0)
  80013c:	fc65                	bnez	s0,800134 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013e:	1a02                	slli	s4,s4,0x20
  800140:	00000797          	auipc	a5,0x0
  800144:	43878793          	addi	a5,a5,1080 # 800578 <main+0x84>
  800148:	020a5a13          	srli	s4,s4,0x20
  80014c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80014e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800150:	000a4503          	lbu	a0,0(s4)
}
  800154:	70a2                	ld	ra,40(sp)
  800156:	69a2                	ld	s3,8(sp)
  800158:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80015a:	85ca                	mv	a1,s2
  80015c:	87a6                	mv	a5,s1
}
  80015e:	6942                	ld	s2,16(sp)
  800160:	64e2                	ld	s1,24(sp)
  800162:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800164:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800166:	03065633          	divu	a2,a2,a6
  80016a:	8722                	mv	a4,s0
  80016c:	f9bff0ef          	jal	ra,800106 <printnum>
  800170:	b7f9                	j	80013e <printnum+0x38>

0000000000800172 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800172:	7119                	addi	sp,sp,-128
  800174:	f4a6                	sd	s1,104(sp)
  800176:	f0ca                	sd	s2,96(sp)
  800178:	ecce                	sd	s3,88(sp)
  80017a:	e8d2                	sd	s4,80(sp)
  80017c:	e4d6                	sd	s5,72(sp)
  80017e:	e0da                	sd	s6,64(sp)
  800180:	fc5e                	sd	s7,56(sp)
  800182:	f06a                	sd	s10,32(sp)
  800184:	fc86                	sd	ra,120(sp)
  800186:	f8a2                	sd	s0,112(sp)
  800188:	f862                	sd	s8,48(sp)
  80018a:	f466                	sd	s9,40(sp)
  80018c:	ec6e                	sd	s11,24(sp)
  80018e:	892a                	mv	s2,a0
  800190:	84ae                	mv	s1,a1
  800192:	8d32                	mv	s10,a2
  800194:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800196:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80019a:	5b7d                	li	s6,-1
  80019c:	00000a97          	auipc	s5,0x0
  8001a0:	410a8a93          	addi	s5,s5,1040 # 8005ac <main+0xb8>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001a4:	00000b97          	auipc	s7,0x0
  8001a8:	624b8b93          	addi	s7,s7,1572 # 8007c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	000d4503          	lbu	a0,0(s10)
  8001b0:	001d0413          	addi	s0,s10,1
  8001b4:	01350a63          	beq	a0,s3,8001c8 <vprintfmt+0x56>
            if (ch == '\0') {
  8001b8:	c121                	beqz	a0,8001f8 <vprintfmt+0x86>
            putch(ch, putdat);
  8001ba:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001bc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001be:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c0:	fff44503          	lbu	a0,-1(s0)
  8001c4:	ff351ae3          	bne	a0,s3,8001b8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001c8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001cc:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001d0:	4c81                	li	s9,0
  8001d2:	4881                	li	a7,0
        width = precision = -1;
  8001d4:	5c7d                	li	s8,-1
  8001d6:	5dfd                	li	s11,-1
  8001d8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001dc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001de:	fdd6059b          	addiw	a1,a2,-35
  8001e2:	0ff5f593          	zext.b	a1,a1
  8001e6:	00140d13          	addi	s10,s0,1
  8001ea:	04b56263          	bltu	a0,a1,80022e <vprintfmt+0xbc>
  8001ee:	058a                	slli	a1,a1,0x2
  8001f0:	95d6                	add	a1,a1,s5
  8001f2:	4194                	lw	a3,0(a1)
  8001f4:	96d6                	add	a3,a3,s5
  8001f6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001f8:	70e6                	ld	ra,120(sp)
  8001fa:	7446                	ld	s0,112(sp)
  8001fc:	74a6                	ld	s1,104(sp)
  8001fe:	7906                	ld	s2,96(sp)
  800200:	69e6                	ld	s3,88(sp)
  800202:	6a46                	ld	s4,80(sp)
  800204:	6aa6                	ld	s5,72(sp)
  800206:	6b06                	ld	s6,64(sp)
  800208:	7be2                	ld	s7,56(sp)
  80020a:	7c42                	ld	s8,48(sp)
  80020c:	7ca2                	ld	s9,40(sp)
  80020e:	7d02                	ld	s10,32(sp)
  800210:	6de2                	ld	s11,24(sp)
  800212:	6109                	addi	sp,sp,128
  800214:	8082                	ret
            padc = '0';
  800216:	87b2                	mv	a5,a2
            goto reswitch;
  800218:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80021c:	846a                	mv	s0,s10
  80021e:	00140d13          	addi	s10,s0,1
  800222:	fdd6059b          	addiw	a1,a2,-35
  800226:	0ff5f593          	zext.b	a1,a1
  80022a:	fcb572e3          	bgeu	a0,a1,8001ee <vprintfmt+0x7c>
            putch('%', putdat);
  80022e:	85a6                	mv	a1,s1
  800230:	02500513          	li	a0,37
  800234:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800236:	fff44783          	lbu	a5,-1(s0)
  80023a:	8d22                	mv	s10,s0
  80023c:	f73788e3          	beq	a5,s3,8001ac <vprintfmt+0x3a>
  800240:	ffed4783          	lbu	a5,-2(s10)
  800244:	1d7d                	addi	s10,s10,-1
  800246:	ff379de3          	bne	a5,s3,800240 <vprintfmt+0xce>
  80024a:	b78d                	j	8001ac <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  80024c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800250:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800256:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80025a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80025e:	02d86463          	bltu	a6,a3,800286 <vprintfmt+0x114>
                ch = *fmt;
  800262:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800266:	002c169b          	slliw	a3,s8,0x2
  80026a:	0186873b          	addw	a4,a3,s8
  80026e:	0017171b          	slliw	a4,a4,0x1
  800272:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800274:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800278:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80027a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80027e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800282:	fed870e3          	bgeu	a6,a3,800262 <vprintfmt+0xf0>
            if (width < 0)
  800286:	f40ddce3          	bgez	s11,8001de <vprintfmt+0x6c>
                width = precision, precision = -1;
  80028a:	8de2                	mv	s11,s8
  80028c:	5c7d                	li	s8,-1
  80028e:	bf81                	j	8001de <vprintfmt+0x6c>
            if (width < 0)
  800290:	fffdc693          	not	a3,s11
  800294:	96fd                	srai	a3,a3,0x3f
  800296:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80029a:	00144603          	lbu	a2,1(s0)
  80029e:	2d81                	sext.w	s11,s11
  8002a0:	846a                	mv	s0,s10
            goto reswitch;
  8002a2:	bf35                	j	8001de <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002a4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002ac:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002ae:	846a                	mv	s0,s10
            goto process_precision;
  8002b0:	bfd9                	j	800286 <vprintfmt+0x114>
    if (lflag >= 2) {
  8002b2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002b4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b8:	01174463          	blt	a4,a7,8002c0 <vprintfmt+0x14e>
    else if (lflag) {
  8002bc:	1a088e63          	beqz	a7,800478 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002c0:	000a3603          	ld	a2,0(s4)
  8002c4:	46c1                	li	a3,16
  8002c6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002c8:	2781                	sext.w	a5,a5
  8002ca:	876e                	mv	a4,s11
  8002cc:	85a6                	mv	a1,s1
  8002ce:	854a                	mv	a0,s2
  8002d0:	e37ff0ef          	jal	ra,800106 <printnum>
            break;
  8002d4:	bde1                	j	8001ac <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002d6:	000a2503          	lw	a0,0(s4)
  8002da:	85a6                	mv	a1,s1
  8002dc:	0a21                	addi	s4,s4,8
  8002de:	9902                	jalr	s2
            break;
  8002e0:	b5f1                	j	8001ac <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e8:	01174463          	blt	a4,a7,8002f0 <vprintfmt+0x17e>
    else if (lflag) {
  8002ec:	18088163          	beqz	a7,80046e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002f0:	000a3603          	ld	a2,0(s4)
  8002f4:	46a9                	li	a3,10
  8002f6:	8a2e                	mv	s4,a1
  8002f8:	bfc1                	j	8002c8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002fa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002fe:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	846a                	mv	s0,s10
            goto reswitch;
  800302:	bdf1                	j	8001de <vprintfmt+0x6c>
            putch(ch, putdat);
  800304:	85a6                	mv	a1,s1
  800306:	02500513          	li	a0,37
  80030a:	9902                	jalr	s2
            break;
  80030c:	b545                	j	8001ac <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80030e:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800312:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	846a                	mv	s0,s10
            goto reswitch;
  800316:	b5e1                	j	8001de <vprintfmt+0x6c>
    if (lflag >= 2) {
  800318:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80031e:	01174463          	blt	a4,a7,800326 <vprintfmt+0x1b4>
    else if (lflag) {
  800322:	14088163          	beqz	a7,800464 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800326:	000a3603          	ld	a2,0(s4)
  80032a:	46a1                	li	a3,8
  80032c:	8a2e                	mv	s4,a1
  80032e:	bf69                	j	8002c8 <vprintfmt+0x156>
            putch('0', putdat);
  800330:	03000513          	li	a0,48
  800334:	85a6                	mv	a1,s1
  800336:	e03e                	sd	a5,0(sp)
  800338:	9902                	jalr	s2
            putch('x', putdat);
  80033a:	85a6                	mv	a1,s1
  80033c:	07800513          	li	a0,120
  800340:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800342:	0a21                	addi	s4,s4,8
            goto number;
  800344:	6782                	ld	a5,0(sp)
  800346:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800348:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  80034c:	bfb5                	j	8002c8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80034e:	000a3403          	ld	s0,0(s4)
  800352:	008a0713          	addi	a4,s4,8
  800356:	e03a                	sd	a4,0(sp)
  800358:	14040263          	beqz	s0,80049c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  80035c:	0fb05763          	blez	s11,80044a <vprintfmt+0x2d8>
  800360:	02d00693          	li	a3,45
  800364:	0cd79163          	bne	a5,a3,800426 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800368:	00044783          	lbu	a5,0(s0)
  80036c:	0007851b          	sext.w	a0,a5
  800370:	cf85                	beqz	a5,8003a8 <vprintfmt+0x236>
  800372:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800376:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037a:	000c4563          	bltz	s8,800384 <vprintfmt+0x212>
  80037e:	3c7d                	addiw	s8,s8,-1
  800380:	036c0263          	beq	s8,s6,8003a4 <vprintfmt+0x232>
                    putch('?', putdat);
  800384:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800386:	0e0c8e63          	beqz	s9,800482 <vprintfmt+0x310>
  80038a:	3781                	addiw	a5,a5,-32
  80038c:	0ef47b63          	bgeu	s0,a5,800482 <vprintfmt+0x310>
                    putch('?', putdat);
  800390:	03f00513          	li	a0,63
  800394:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	000a4783          	lbu	a5,0(s4)
  80039a:	3dfd                	addiw	s11,s11,-1
  80039c:	0a05                	addi	s4,s4,1
  80039e:	0007851b          	sext.w	a0,a5
  8003a2:	ffe1                	bnez	a5,80037a <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003a4:	01b05963          	blez	s11,8003b6 <vprintfmt+0x244>
  8003a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003aa:	85a6                	mv	a1,s1
  8003ac:	02000513          	li	a0,32
  8003b0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b2:	fe0d9be3          	bnez	s11,8003a8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b6:	6a02                	ld	s4,0(sp)
  8003b8:	bbd5                	j	8001ac <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003bc:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003c0:	01174463          	blt	a4,a7,8003c8 <vprintfmt+0x256>
    else if (lflag) {
  8003c4:	08088d63          	beqz	a7,80045e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003c8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003cc:	0a044d63          	bltz	s0,800486 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003d0:	8622                	mv	a2,s0
  8003d2:	8a66                	mv	s4,s9
  8003d4:	46a9                	li	a3,10
  8003d6:	bdcd                	j	8002c8 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003d8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003dc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003de:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e0:	41f7d69b          	sraiw	a3,a5,0x1f
  8003e4:	8fb5                	xor	a5,a5,a3
  8003e6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ea:	02d74163          	blt	a4,a3,80040c <vprintfmt+0x29a>
  8003ee:	00369793          	slli	a5,a3,0x3
  8003f2:	97de                	add	a5,a5,s7
  8003f4:	639c                	ld	a5,0(a5)
  8003f6:	cb99                	beqz	a5,80040c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003f8:	86be                	mv	a3,a5
  8003fa:	00000617          	auipc	a2,0x0
  8003fe:	1ae60613          	addi	a2,a2,430 # 8005a8 <main+0xb4>
  800402:	85a6                	mv	a1,s1
  800404:	854a                	mv	a0,s2
  800406:	0ce000ef          	jal	ra,8004d4 <printfmt>
  80040a:	b34d                	j	8001ac <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80040c:	00000617          	auipc	a2,0x0
  800410:	18c60613          	addi	a2,a2,396 # 800598 <main+0xa4>
  800414:	85a6                	mv	a1,s1
  800416:	854a                	mv	a0,s2
  800418:	0bc000ef          	jal	ra,8004d4 <printfmt>
  80041c:	bb41                	j	8001ac <vprintfmt+0x3a>
                p = "(null)";
  80041e:	00000417          	auipc	s0,0x0
  800422:	17240413          	addi	s0,s0,370 # 800590 <main+0x9c>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800426:	85e2                	mv	a1,s8
  800428:	8522                	mv	a0,s0
  80042a:	e43e                	sd	a5,8(sp)
  80042c:	cbfff0ef          	jal	ra,8000ea <strnlen>
  800430:	40ad8dbb          	subw	s11,s11,a0
  800434:	01b05b63          	blez	s11,80044a <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800438:	67a2                	ld	a5,8(sp)
  80043a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800440:	85a6                	mv	a1,s1
  800442:	8552                	mv	a0,s4
  800444:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800446:	fe0d9ce3          	bnez	s11,80043e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044a:	00044783          	lbu	a5,0(s0)
  80044e:	00140a13          	addi	s4,s0,1
  800452:	0007851b          	sext.w	a0,a5
  800456:	d3a5                	beqz	a5,8003b6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800458:	05e00413          	li	s0,94
  80045c:	bf39                	j	80037a <vprintfmt+0x208>
        return va_arg(*ap, int);
  80045e:	000a2403          	lw	s0,0(s4)
  800462:	b7ad                	j	8003cc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800464:	000a6603          	lwu	a2,0(s4)
  800468:	46a1                	li	a3,8
  80046a:	8a2e                	mv	s4,a1
  80046c:	bdb1                	j	8002c8 <vprintfmt+0x156>
  80046e:	000a6603          	lwu	a2,0(s4)
  800472:	46a9                	li	a3,10
  800474:	8a2e                	mv	s4,a1
  800476:	bd89                	j	8002c8 <vprintfmt+0x156>
  800478:	000a6603          	lwu	a2,0(s4)
  80047c:	46c1                	li	a3,16
  80047e:	8a2e                	mv	s4,a1
  800480:	b5a1                	j	8002c8 <vprintfmt+0x156>
                    putch(ch, putdat);
  800482:	9902                	jalr	s2
  800484:	bf09                	j	800396 <vprintfmt+0x224>
                putch('-', putdat);
  800486:	85a6                	mv	a1,s1
  800488:	02d00513          	li	a0,45
  80048c:	e03e                	sd	a5,0(sp)
  80048e:	9902                	jalr	s2
                num = -(long long)num;
  800490:	6782                	ld	a5,0(sp)
  800492:	8a66                	mv	s4,s9
  800494:	40800633          	neg	a2,s0
  800498:	46a9                	li	a3,10
  80049a:	b53d                	j	8002c8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  80049c:	03b05163          	blez	s11,8004be <vprintfmt+0x34c>
  8004a0:	02d00693          	li	a3,45
  8004a4:	f6d79de3          	bne	a5,a3,80041e <vprintfmt+0x2ac>
                p = "(null)";
  8004a8:	00000417          	auipc	s0,0x0
  8004ac:	0e840413          	addi	s0,s0,232 # 800590 <main+0x9c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b0:	02800793          	li	a5,40
  8004b4:	02800513          	li	a0,40
  8004b8:	00140a13          	addi	s4,s0,1
  8004bc:	bd6d                	j	800376 <vprintfmt+0x204>
  8004be:	00000a17          	auipc	s4,0x0
  8004c2:	0d3a0a13          	addi	s4,s4,211 # 800591 <main+0x9d>
  8004c6:	02800513          	li	a0,40
  8004ca:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ce:	05e00413          	li	s0,94
  8004d2:	b565                	j	80037a <vprintfmt+0x208>

00000000008004d4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004d6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004da:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004dc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004de:	ec06                	sd	ra,24(sp)
  8004e0:	f83a                	sd	a4,48(sp)
  8004e2:	fc3e                	sd	a5,56(sp)
  8004e4:	e0c2                	sd	a6,64(sp)
  8004e6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004e8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ea:	c89ff0ef          	jal	ra,800172 <vprintfmt>
}
  8004ee:	60e2                	ld	ra,24(sp)
  8004f0:	6161                	addi	sp,sp,80
  8004f2:	8082                	ret

00000000008004f4 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004f4:	1101                	addi	sp,sp,-32
  8004f6:	ec06                	sd	ra,24(sp)
  8004f8:	e822                	sd	s0,16(sp)
  8004fa:	e426                	sd	s1,8(sp)
  8004fc:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  8004fe:	b89ff0ef          	jal	ra,800086 <getpid>
  800502:	85aa                	mv	a1,a0
  800504:	00000517          	auipc	a0,0x0
  800508:	38c50513          	addi	a0,a0,908 # 800890 <error_string+0xc8>
  80050c:	b9dff0ef          	jal	ra,8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  800510:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800512:	00000917          	auipc	s2,0x0
  800516:	39e90913          	addi	s2,s2,926 # 8008b0 <error_string+0xe8>
    for (i = 0; i < 5; i ++) {
  80051a:	4495                	li	s1,5
        yield();
  80051c:	b69ff0ef          	jal	ra,800084 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800520:	b67ff0ef          	jal	ra,800086 <getpid>
  800524:	85aa                	mv	a1,a0
  800526:	8622                	mv	a2,s0
  800528:	854a                	mv	a0,s2
    for (i = 0; i < 5; i ++) {
  80052a:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80052c:	b7dff0ef          	jal	ra,8000a8 <cprintf>
    for (i = 0; i < 5; i ++) {
  800530:	fe9416e3          	bne	s0,s1,80051c <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800534:	b53ff0ef          	jal	ra,800086 <getpid>
  800538:	85aa                	mv	a1,a0
  80053a:	00000517          	auipc	a0,0x0
  80053e:	39e50513          	addi	a0,a0,926 # 8008d8 <error_string+0x110>
  800542:	b67ff0ef          	jal	ra,8000a8 <cprintf>
    cprintf("yield pass.\n");
  800546:	00000517          	auipc	a0,0x0
  80054a:	3b250513          	addi	a0,a0,946 # 8008f8 <error_string+0x130>
  80054e:	b5bff0ef          	jal	ra,8000a8 <cprintf>
    return 0;
}
  800552:	60e2                	ld	ra,24(sp)
  800554:	6442                	ld	s0,16(sp)
  800556:	64a2                	ld	s1,8(sp)
  800558:	6902                	ld	s2,0(sp)
  80055a:	4501                	li	a0,0
  80055c:	6105                	addi	sp,sp,32
  80055e:	8082                	ret
