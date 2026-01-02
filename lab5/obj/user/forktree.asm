
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

0000000000800062 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800062:	4509                	li	a0,2
  800064:	bf75                	j	800020 <syscall>

0000000000800066 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800066:	4529                	li	a0,10
  800068:	bf65                	j	800020 <syscall>

000000000080006a <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80006a:	4549                	li	a0,18
  80006c:	bf55                	j	800020 <syscall>

000000000080006e <sys_putc>:
}

int
sys_putc(int64_t c) {
  80006e:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800070:	4579                	li	a0,30
  800072:	b77d                	j	800020 <syscall>

0000000000800074 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800074:	1141                	addi	sp,sp,-16
  800076:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800078:	fe5ff0ef          	jal	80005c <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007c:	00000517          	auipc	a0,0x0
  800080:	59c50513          	addi	a0,a0,1436 # 800618 <main+0x1e>
  800084:	02a000ef          	jal	8000ae <cprintf>
    while (1);
  800088:	a001                	j	800088 <exit+0x14>

000000000080008a <fork>:
}

int
fork(void) {
    return sys_fork();
  80008a:	bfe1                	j	800062 <sys_fork>

000000000080008c <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  80008c:	bfe9                	j	800066 <sys_yield>

000000000080008e <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80008e:	bff1                	j	80006a <sys_getpid>

0000000000800090 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800090:	052000ef          	jal	8000e2 <umain>
1:  j 1b
  800094:	a001                	j	800094 <_start+0x4>

0000000000800096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800096:	1101                	addi	sp,sp,-32
  800098:	ec06                	sd	ra,24(sp)
  80009a:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80009c:	fd3ff0ef          	jal	80006e <sys_putc>
    (*cnt) ++;
  8000a0:	65a2                	ld	a1,8(sp)
}
  8000a2:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000a4:	419c                	lw	a5,0(a1)
  8000a6:	2785                	addiw	a5,a5,1
  8000a8:	c19c                	sw	a5,0(a1)
}
  8000aa:	6105                	addi	sp,sp,32
  8000ac:	8082                	ret

00000000008000ae <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000ae:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000b0:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b4:	f42e                	sd	a1,40(sp)
  8000b6:	f832                	sd	a2,48(sp)
  8000b8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ba:	862a                	mv	a2,a0
  8000bc:	004c                	addi	a1,sp,4
  8000be:	00000517          	auipc	a0,0x0
  8000c2:	fd850513          	addi	a0,a0,-40 # 800096 <cputch>
  8000c6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c8:	ec06                	sd	ra,24(sp)
  8000ca:	e0ba                	sd	a4,64(sp)
  8000cc:	e4be                	sd	a5,72(sp)
  8000ce:	e8c2                	sd	a6,80(sp)
  8000d0:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000d2:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000d4:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d6:	0cc000ef          	jal	8001a2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000da:	60e2                	ld	ra,24(sp)
  8000dc:	4512                	lw	a0,4(sp)
  8000de:	6125                	addi	sp,sp,96
  8000e0:	8082                	ret

00000000008000e2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e6:	514000ef          	jal	8005fa <main>
    exit(ret);
  8000ea:	f8bff0ef          	jal	800074 <exit>

00000000008000ee <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000ee:	00054783          	lbu	a5,0(a0)
  8000f2:	cb81                	beqz	a5,800102 <strlen+0x14>
    size_t cnt = 0;
  8000f4:	4781                	li	a5,0
        cnt ++;
  8000f6:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  8000f8:	00f50733          	add	a4,a0,a5
  8000fc:	00074703          	lbu	a4,0(a4)
  800100:	fb7d                	bnez	a4,8000f6 <strlen+0x8>
    }
    return cnt;
}
  800102:	853e                	mv	a0,a5
  800104:	8082                	ret

0000000000800106 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800106:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800108:	e589                	bnez	a1,800112 <strnlen+0xc>
  80010a:	a811                	j	80011e <strnlen+0x18>
        cnt ++;
  80010c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80010e:	00f58863          	beq	a1,a5,80011e <strnlen+0x18>
  800112:	00f50733          	add	a4,a0,a5
  800116:	00074703          	lbu	a4,0(a4)
  80011a:	fb6d                	bnez	a4,80010c <strnlen+0x6>
  80011c:	85be                	mv	a1,a5
    }
    return cnt;
}
  80011e:	852e                	mv	a0,a1
  800120:	8082                	ret

0000000000800122 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800122:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800124:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800128:	f022                	sd	s0,32(sp)
  80012a:	ec26                	sd	s1,24(sp)
  80012c:	e84a                	sd	s2,16(sp)
  80012e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800130:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800134:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800136:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80013a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80013e:	84aa                	mv	s1,a0
  800140:	892e                	mv	s2,a1
    if (num >= base) {
  800142:	03067d63          	bgeu	a2,a6,80017c <printnum+0x5a>
  800146:	e44e                	sd	s3,8(sp)
  800148:	89be                	mv	s3,a5
        while (-- width > 0)
  80014a:	4785                	li	a5,1
  80014c:	00e7d763          	bge	a5,a4,80015a <printnum+0x38>
            putch(padc, putdat);
  800150:	85ca                	mv	a1,s2
  800152:	854e                	mv	a0,s3
        while (-- width > 0)
  800154:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800156:	9482                	jalr	s1
        while (-- width > 0)
  800158:	fc65                	bnez	s0,800150 <printnum+0x2e>
  80015a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80015c:	00000797          	auipc	a5,0x0
  800160:	4d478793          	addi	a5,a5,1236 # 800630 <main+0x36>
  800164:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800166:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800168:	0007c503          	lbu	a0,0(a5)
}
  80016c:	70a2                	ld	ra,40(sp)
  80016e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800170:	85ca                	mv	a1,s2
  800172:	87a6                	mv	a5,s1
}
  800174:	6942                	ld	s2,16(sp)
  800176:	64e2                	ld	s1,24(sp)
  800178:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80017a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80017c:	03065633          	divu	a2,a2,a6
  800180:	8722                	mv	a4,s0
  800182:	fa1ff0ef          	jal	800122 <printnum>
  800186:	bfd9                	j	80015c <printnum+0x3a>

0000000000800188 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800188:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80018a:	6198                	ld	a4,0(a1)
  80018c:	6594                	ld	a3,8(a1)
    b->cnt ++;
  80018e:	2785                	addiw	a5,a5,1
  800190:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800192:	00d77763          	bgeu	a4,a3,8001a0 <sprintputch+0x18>
        *b->buf ++ = ch;
  800196:	00170793          	addi	a5,a4,1
  80019a:	e19c                	sd	a5,0(a1)
  80019c:	00a70023          	sb	a0,0(a4)
    }
}
  8001a0:	8082                	ret

00000000008001a2 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a2:	7119                	addi	sp,sp,-128
  8001a4:	f4a6                	sd	s1,104(sp)
  8001a6:	f0ca                	sd	s2,96(sp)
  8001a8:	ecce                	sd	s3,88(sp)
  8001aa:	e8d2                	sd	s4,80(sp)
  8001ac:	e4d6                	sd	s5,72(sp)
  8001ae:	e0da                	sd	s6,64(sp)
  8001b0:	f862                	sd	s8,48(sp)
  8001b2:	fc86                	sd	ra,120(sp)
  8001b4:	f8a2                	sd	s0,112(sp)
  8001b6:	fc5e                	sd	s7,56(sp)
  8001b8:	f466                	sd	s9,40(sp)
  8001ba:	f06a                	sd	s10,32(sp)
  8001bc:	ec6e                	sd	s11,24(sp)
  8001be:	84aa                	mv	s1,a0
  8001c0:	8c32                	mv	s8,a2
  8001c2:	8a36                	mv	s4,a3
  8001c4:	892e                	mv	s2,a1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c6:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
  8001ca:	05500b13          	li	s6,85
  8001ce:	00000a97          	auipc	s5,0x0
  8001d2:	57aa8a93          	addi	s5,s5,1402 # 800748 <main+0x14e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d6:	000c4503          	lbu	a0,0(s8)
  8001da:	001c0413          	addi	s0,s8,1
  8001de:	01350a63          	beq	a0,s3,8001f2 <vprintfmt+0x50>
            if (ch == '\0') {
  8001e2:	cd0d                	beqz	a0,80021c <vprintfmt+0x7a>
            putch(ch, putdat);
  8001e4:	85ca                	mv	a1,s2
  8001e6:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e8:	00044503          	lbu	a0,0(s0)
  8001ec:	0405                	addi	s0,s0,1
  8001ee:	ff351ae3          	bne	a0,s3,8001e2 <vprintfmt+0x40>
        width = precision = -1;
  8001f2:	5cfd                	li	s9,-1
  8001f4:	8d66                	mv	s10,s9
        char padc = ' ';
  8001f6:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001fa:	4b81                	li	s7,0
  8001fc:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001fe:	00044683          	lbu	a3,0(s0)
  800202:	00140c13          	addi	s8,s0,1
  800206:	fdd6859b          	addiw	a1,a3,-35
  80020a:	0ff5f593          	zext.b	a1,a1
  80020e:	02bb6663          	bltu	s6,a1,80023a <vprintfmt+0x98>
  800212:	058a                	slli	a1,a1,0x2
  800214:	95d6                	add	a1,a1,s5
  800216:	4198                	lw	a4,0(a1)
  800218:	9756                	add	a4,a4,s5
  80021a:	8702                	jr	a4
}
  80021c:	70e6                	ld	ra,120(sp)
  80021e:	7446                	ld	s0,112(sp)
  800220:	74a6                	ld	s1,104(sp)
  800222:	7906                	ld	s2,96(sp)
  800224:	69e6                	ld	s3,88(sp)
  800226:	6a46                	ld	s4,80(sp)
  800228:	6aa6                	ld	s5,72(sp)
  80022a:	6b06                	ld	s6,64(sp)
  80022c:	7be2                	ld	s7,56(sp)
  80022e:	7c42                	ld	s8,48(sp)
  800230:	7ca2                	ld	s9,40(sp)
  800232:	7d02                	ld	s10,32(sp)
  800234:	6de2                	ld	s11,24(sp)
  800236:	6109                	addi	sp,sp,128
  800238:	8082                	ret
            putch('%', putdat);
  80023a:	85ca                	mv	a1,s2
  80023c:	02500513          	li	a0,37
  800240:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800242:	fff44783          	lbu	a5,-1(s0)
  800246:	02500713          	li	a4,37
  80024a:	8c22                	mv	s8,s0
  80024c:	f8e785e3          	beq	a5,a4,8001d6 <vprintfmt+0x34>
  800250:	ffec4783          	lbu	a5,-2(s8)
  800254:	1c7d                	addi	s8,s8,-1
  800256:	fee79de3          	bne	a5,a4,800250 <vprintfmt+0xae>
  80025a:	bfb5                	j	8001d6 <vprintfmt+0x34>
                ch = *fmt;
  80025c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800260:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800262:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800266:	fd06071b          	addiw	a4,a2,-48
  80026a:	24e56a63          	bltu	a0,a4,8004be <vprintfmt+0x31c>
                ch = *fmt;
  80026e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800270:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800272:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800276:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80027a:	0197073b          	addw	a4,a4,s9
  80027e:	0017171b          	slliw	a4,a4,0x1
  800282:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800284:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800288:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80028a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80028e:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800292:	feb570e3          	bgeu	a0,a1,800272 <vprintfmt+0xd0>
            if (width < 0)
  800296:	f60d54e3          	bgez	s10,8001fe <vprintfmt+0x5c>
                width = precision, precision = -1;
  80029a:	8d66                	mv	s10,s9
  80029c:	5cfd                	li	s9,-1
  80029e:	b785                	j	8001fe <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002a0:	8db6                	mv	s11,a3
  8002a2:	8462                	mv	s0,s8
  8002a4:	bfa9                	j	8001fe <vprintfmt+0x5c>
  8002a6:	8462                	mv	s0,s8
            altflag = 1;
  8002a8:	4b85                	li	s7,1
            goto reswitch;
  8002aa:	bf91                	j	8001fe <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b2:	00f74463          	blt	a4,a5,8002ba <vprintfmt+0x118>
    else if (lflag) {
  8002b6:	1a078763          	beqz	a5,800464 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002ba:	000a3603          	ld	a2,0(s4)
  8002be:	46c1                	li	a3,16
  8002c0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002c2:	000d879b          	sext.w	a5,s11
  8002c6:	876a                	mv	a4,s10
  8002c8:	85ca                	mv	a1,s2
  8002ca:	8526                	mv	a0,s1
  8002cc:	e57ff0ef          	jal	800122 <printnum>
            break;
  8002d0:	b719                	j	8001d6 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002d2:	000a2503          	lw	a0,0(s4)
  8002d6:	85ca                	mv	a1,s2
  8002d8:	0a21                	addi	s4,s4,8
  8002da:	9482                	jalr	s1
            break;
  8002dc:	bded                	j	8001d6 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002de:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e4:	00f74463          	blt	a4,a5,8002ec <vprintfmt+0x14a>
    else if (lflag) {
  8002e8:	16078963          	beqz	a5,80045a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ec:	000a3603          	ld	a2,0(s4)
  8002f0:	46a9                	li	a3,10
  8002f2:	8a2e                	mv	s4,a1
  8002f4:	b7f9                	j	8002c2 <vprintfmt+0x120>
            putch('0', putdat);
  8002f6:	85ca                	mv	a1,s2
  8002f8:	03000513          	li	a0,48
  8002fc:	9482                	jalr	s1
            putch('x', putdat);
  8002fe:	85ca                	mv	a1,s2
  800300:	07800513          	li	a0,120
  800304:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800306:	000a3603          	ld	a2,0(s4)
            goto number;
  80030a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80030c:	0a21                	addi	s4,s4,8
            goto number;
  80030e:	bf55                	j	8002c2 <vprintfmt+0x120>
            putch(ch, putdat);
  800310:	85ca                	mv	a1,s2
  800312:	02500513          	li	a0,37
  800316:	9482                	jalr	s1
            break;
  800318:	bd7d                	j	8001d6 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80031a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80031e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800320:	0a21                	addi	s4,s4,8
            goto process_precision;
  800322:	bf95                	j	800296 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800324:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800326:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032a:	00f74463          	blt	a4,a5,800332 <vprintfmt+0x190>
    else if (lflag) {
  80032e:	12078163          	beqz	a5,800450 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800332:	000a3603          	ld	a2,0(s4)
  800336:	46a1                	li	a3,8
  800338:	8a2e                	mv	s4,a1
  80033a:	b761                	j	8002c2 <vprintfmt+0x120>
            if (width < 0)
  80033c:	876a                	mv	a4,s10
  80033e:	000d5363          	bgez	s10,800344 <vprintfmt+0x1a2>
  800342:	4701                	li	a4,0
  800344:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800348:	8462                	mv	s0,s8
            goto reswitch;
  80034a:	bd55                	j	8001fe <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80034c:	000d841b          	sext.w	s0,s11
  800350:	fd340793          	addi	a5,s0,-45
  800354:	00f037b3          	snez	a5,a5
  800358:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80035c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800360:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800362:	008a0793          	addi	a5,s4,8
  800366:	e43e                	sd	a5,8(sp)
  800368:	100d8c63          	beqz	s11,800480 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80036c:	12071363          	bnez	a4,800492 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800370:	000dc783          	lbu	a5,0(s11)
  800374:	0007851b          	sext.w	a0,a5
  800378:	c78d                	beqz	a5,8003a2 <vprintfmt+0x200>
  80037a:	0d85                	addi	s11,s11,1
  80037c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037e:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	000cc563          	bltz	s9,80038c <vprintfmt+0x1ea>
  800386:	3cfd                	addiw	s9,s9,-1
  800388:	008c8d63          	beq	s9,s0,8003a2 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80038c:	020b9663          	bnez	s7,8003b8 <vprintfmt+0x216>
                    putch(ch, putdat);
  800390:	85ca                	mv	a1,s2
  800392:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800394:	000dc783          	lbu	a5,0(s11)
  800398:	0d85                	addi	s11,s11,1
  80039a:	3d7d                	addiw	s10,s10,-1
  80039c:	0007851b          	sext.w	a0,a5
  8003a0:	f3ed                	bnez	a5,800382 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003a2:	01a05963          	blez	s10,8003b4 <vprintfmt+0x212>
                putch(' ', putdat);
  8003a6:	85ca                	mv	a1,s2
  8003a8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ac:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ae:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003b0:	fe0d1be3          	bnez	s10,8003a6 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b4:	6a22                	ld	s4,8(sp)
  8003b6:	b505                	j	8001d6 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b8:	3781                	addiw	a5,a5,-32
  8003ba:	fcfa7be3          	bgeu	s4,a5,800390 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003be:	03f00513          	li	a0,63
  8003c2:	85ca                	mv	a1,s2
  8003c4:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c6:	000dc783          	lbu	a5,0(s11)
  8003ca:	0d85                	addi	s11,s11,1
  8003cc:	3d7d                	addiw	s10,s10,-1
  8003ce:	0007851b          	sext.w	a0,a5
  8003d2:	dbe1                	beqz	a5,8003a2 <vprintfmt+0x200>
  8003d4:	fa0cd9e3          	bgez	s9,800386 <vprintfmt+0x1e4>
  8003d8:	b7c5                	j	8003b8 <vprintfmt+0x216>
            if (err < 0) {
  8003da:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003de:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003e0:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e2:	41f7d71b          	sraiw	a4,a5,0x1f
  8003e6:	8fb9                	xor	a5,a5,a4
  8003e8:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ec:	02d64563          	blt	a2,a3,800416 <vprintfmt+0x274>
  8003f0:	00000797          	auipc	a5,0x0
  8003f4:	4b078793          	addi	a5,a5,1200 # 8008a0 <error_string>
  8003f8:	00369713          	slli	a4,a3,0x3
  8003fc:	97ba                	add	a5,a5,a4
  8003fe:	639c                	ld	a5,0(a5)
  800400:	cb99                	beqz	a5,800416 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800402:	86be                	mv	a3,a5
  800404:	00000617          	auipc	a2,0x0
  800408:	25c60613          	addi	a2,a2,604 # 800660 <main+0x66>
  80040c:	85ca                	mv	a1,s2
  80040e:	8526                	mv	a0,s1
  800410:	0d8000ef          	jal	8004e8 <printfmt>
  800414:	b3c9                	j	8001d6 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800416:	00000617          	auipc	a2,0x0
  80041a:	23a60613          	addi	a2,a2,570 # 800650 <main+0x56>
  80041e:	85ca                	mv	a1,s2
  800420:	8526                	mv	a0,s1
  800422:	0c6000ef          	jal	8004e8 <printfmt>
  800426:	bb45                	j	8001d6 <vprintfmt+0x34>
    if (lflag >= 2) {
  800428:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80042a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80042e:	00f74363          	blt	a4,a5,800434 <vprintfmt+0x292>
    else if (lflag) {
  800432:	cf81                	beqz	a5,80044a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800434:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800438:	02044b63          	bltz	s0,80046e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80043c:	8622                	mv	a2,s0
  80043e:	8a5e                	mv	s4,s7
  800440:	46a9                	li	a3,10
  800442:	b541                	j	8002c2 <vprintfmt+0x120>
            lflag ++;
  800444:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800446:	8462                	mv	s0,s8
            goto reswitch;
  800448:	bb5d                	j	8001fe <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80044a:	000a2403          	lw	s0,0(s4)
  80044e:	b7ed                	j	800438 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800450:	000a6603          	lwu	a2,0(s4)
  800454:	46a1                	li	a3,8
  800456:	8a2e                	mv	s4,a1
  800458:	b5ad                	j	8002c2 <vprintfmt+0x120>
  80045a:	000a6603          	lwu	a2,0(s4)
  80045e:	46a9                	li	a3,10
  800460:	8a2e                	mv	s4,a1
  800462:	b585                	j	8002c2 <vprintfmt+0x120>
  800464:	000a6603          	lwu	a2,0(s4)
  800468:	46c1                	li	a3,16
  80046a:	8a2e                	mv	s4,a1
  80046c:	bd99                	j	8002c2 <vprintfmt+0x120>
                putch('-', putdat);
  80046e:	85ca                	mv	a1,s2
  800470:	02d00513          	li	a0,45
  800474:	9482                	jalr	s1
                num = -(long long)num;
  800476:	40800633          	neg	a2,s0
  80047a:	8a5e                	mv	s4,s7
  80047c:	46a9                	li	a3,10
  80047e:	b591                	j	8002c2 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800480:	e329                	bnez	a4,8004c2 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800482:	02800793          	li	a5,40
  800486:	853e                	mv	a0,a5
  800488:	00000d97          	auipc	s11,0x0
  80048c:	1c1d8d93          	addi	s11,s11,449 # 800649 <main+0x4f>
  800490:	b5f5                	j	80037c <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800492:	85e6                	mv	a1,s9
  800494:	856e                	mv	a0,s11
  800496:	c71ff0ef          	jal	800106 <strnlen>
  80049a:	40ad0d3b          	subw	s10,s10,a0
  80049e:	01a05863          	blez	s10,8004ae <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004a2:	85ca                	mv	a1,s2
  8004a4:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004a8:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	fe0d1ce3          	bnez	s10,8004a2 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ae:	000dc783          	lbu	a5,0(s11)
  8004b2:	0007851b          	sext.w	a0,a5
  8004b6:	ec0792e3          	bnez	a5,80037a <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004ba:	6a22                	ld	s4,8(sp)
  8004bc:	bb29                	j	8001d6 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004be:	8462                	mv	s0,s8
  8004c0:	bbd9                	j	800296 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	85e6                	mv	a1,s9
  8004c4:	00000517          	auipc	a0,0x0
  8004c8:	18450513          	addi	a0,a0,388 # 800648 <main+0x4e>
  8004cc:	c3bff0ef          	jal	800106 <strnlen>
  8004d0:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d4:	02800793          	li	a5,40
                p = "(null)";
  8004d8:	00000d97          	auipc	s11,0x0
  8004dc:	170d8d93          	addi	s11,s11,368 # 800648 <main+0x4e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e0:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	fda040e3          	bgtz	s10,8004a2 <vprintfmt+0x300>
  8004e6:	bd51                	j	80037a <vprintfmt+0x1d8>

00000000008004e8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f2:	ec06                	sd	ra,24(sp)
  8004f4:	f83a                	sd	a4,48(sp)
  8004f6:	fc3e                	sd	a5,56(sp)
  8004f8:	e0c2                	sd	a6,64(sp)
  8004fa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004fc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004fe:	ca5ff0ef          	jal	8001a2 <vprintfmt>
}
  800502:	60e2                	ld	ra,24(sp)
  800504:	6161                	addi	sp,sp,80
  800506:	8082                	ret

0000000000800508 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800508:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  80050a:	15fd                	addi	a1,a1,-1
  80050c:	95aa                	add	a1,a1,a0
    va_start(ap, fmt);
  80050e:	03810313          	addi	t1,sp,56
snprintf(char *str, size_t size, const char *fmt, ...) {
  800512:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800514:	e82e                	sd	a1,16(sp)
  800516:	e42a                	sd	a0,8(sp)
snprintf(char *str, size_t size, const char *fmt, ...) {
  800518:	fc36                	sd	a3,56(sp)
  80051a:	e0ba                	sd	a4,64(sp)
  80051c:	e4be                	sd	a5,72(sp)
  80051e:	e8c2                	sd	a6,80(sp)
  800520:	ecc6                	sd	a7,88(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800522:	cc02                	sw	zero,24(sp)
    va_start(ap, fmt);
  800524:	e01a                	sd	t1,0(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800526:	c115                	beqz	a0,80054a <snprintf+0x42>
  800528:	02a5e163          	bltu	a1,a0,80054a <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  80052c:	00000517          	auipc	a0,0x0
  800530:	c5c50513          	addi	a0,a0,-932 # 800188 <sprintputch>
  800534:	869a                	mv	a3,t1
  800536:	002c                	addi	a1,sp,8
  800538:	c6bff0ef          	jal	8001a2 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80053c:	67a2                	ld	a5,8(sp)
  80053e:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800542:	4562                	lw	a0,24(sp)
}
  800544:	70a2                	ld	ra,40(sp)
  800546:	6125                	addi	sp,sp,96
  800548:	8082                	ret
        return -E_INVAL;
  80054a:	5575                	li	a0,-3
  80054c:	bfe5                	j	800544 <snprintf+0x3c>

000000000080054e <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80054e:	1101                	addi	sp,sp,-32
  800550:	ec06                	sd	ra,24(sp)
  800552:	e822                	sd	s0,16(sp)
  800554:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800556:	b39ff0ef          	jal	80008e <getpid>
  80055a:	85aa                	mv	a1,a0
  80055c:	8622                	mv	a2,s0
  80055e:	00000517          	auipc	a0,0x0
  800562:	1ca50513          	addi	a0,a0,458 # 800728 <main+0x12e>
  800566:	b49ff0ef          	jal	8000ae <cprintf>
    if (strlen(cur) >= DEPTH)
  80056a:	8522                	mv	a0,s0
  80056c:	b83ff0ef          	jal	8000ee <strlen>
  800570:	478d                	li	a5,3
  800572:	00a7f963          	bgeu	a5,a0,800584 <forktree+0x36>

    forkchild(cur, '0');
    forkchild(cur, '1');
  800576:	8522                	mv	a0,s0
}
  800578:	6442                	ld	s0,16(sp)
  80057a:	60e2                	ld	ra,24(sp)
    forkchild(cur, '1');
  80057c:	03100593          	li	a1,49
}
  800580:	6105                	addi	sp,sp,32
    forkchild(cur, '1');
  800582:	a03d                	j	8005b0 <forkchild>
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800584:	03000713          	li	a4,48
  800588:	86a2                	mv	a3,s0
  80058a:	00000617          	auipc	a2,0x0
  80058e:	1b660613          	addi	a2,a2,438 # 800740 <main+0x146>
  800592:	4595                	li	a1,5
  800594:	0028                	addi	a0,sp,8
  800596:	f73ff0ef          	jal	800508 <snprintf>
    if (fork() == 0) {
  80059a:	af1ff0ef          	jal	80008a <fork>
  80059e:	fd61                	bnez	a0,800576 <forktree+0x28>
        forktree(nxt);
  8005a0:	0028                	addi	a0,sp,8
  8005a2:	fadff0ef          	jal	80054e <forktree>
        yield();
  8005a6:	ae7ff0ef          	jal	80008c <yield>
        exit(0);
  8005aa:	4501                	li	a0,0
  8005ac:	ac9ff0ef          	jal	800074 <exit>

00000000008005b0 <forkchild>:
forkchild(const char *cur, char branch) {
  8005b0:	7179                	addi	sp,sp,-48
  8005b2:	f022                	sd	s0,32(sp)
  8005b4:	ec26                	sd	s1,24(sp)
  8005b6:	f406                	sd	ra,40(sp)
  8005b8:	84ae                	mv	s1,a1
  8005ba:	842a                	mv	s0,a0
    if (strlen(cur) >= DEPTH)
  8005bc:	b33ff0ef          	jal	8000ee <strlen>
  8005c0:	478d                	li	a5,3
  8005c2:	00a7f763          	bgeu	a5,a0,8005d0 <forkchild+0x20>
}
  8005c6:	70a2                	ld	ra,40(sp)
  8005c8:	7402                	ld	s0,32(sp)
  8005ca:	64e2                	ld	s1,24(sp)
  8005cc:	6145                	addi	sp,sp,48
  8005ce:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005d0:	8726                	mv	a4,s1
  8005d2:	86a2                	mv	a3,s0
  8005d4:	00000617          	auipc	a2,0x0
  8005d8:	16c60613          	addi	a2,a2,364 # 800740 <main+0x146>
  8005dc:	4595                	li	a1,5
  8005de:	0028                	addi	a0,sp,8
  8005e0:	f29ff0ef          	jal	800508 <snprintf>
    if (fork() == 0) {
  8005e4:	aa7ff0ef          	jal	80008a <fork>
  8005e8:	fd79                	bnez	a0,8005c6 <forkchild+0x16>
        forktree(nxt);
  8005ea:	0028                	addi	a0,sp,8
  8005ec:	f63ff0ef          	jal	80054e <forktree>
        yield();
  8005f0:	a9dff0ef          	jal	80008c <yield>
        exit(0);
  8005f4:	4501                	li	a0,0
  8005f6:	a7fff0ef          	jal	800074 <exit>

00000000008005fa <main>:

int
main(void) {
  8005fa:	1141                	addi	sp,sp,-16
    forktree("");
  8005fc:	00000517          	auipc	a0,0x0
  800600:	13c50513          	addi	a0,a0,316 # 800738 <main+0x13e>
main(void) {
  800604:	e406                	sd	ra,8(sp)
    forktree("");
  800606:	f49ff0ef          	jal	80054e <forktree>
    return 0;
}
  80060a:	60a2                	ld	ra,8(sp)
  80060c:	4501                	li	a0,0
  80060e:	0141                	addi	sp,sp,16
  800610:	8082                	ret
