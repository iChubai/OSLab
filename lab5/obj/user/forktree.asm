
obj/__user_forktree.out:     file format elf64-littleriscv


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
  800076:	fe5ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007a:	00000517          	auipc	a0,0x0
  80007e:	5c650513          	addi	a0,a0,1478 # 800640 <main+0x1c>
  800082:	02c000ef          	jal	ra,8000ae <cprintf>
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
.text
.globl _start
_start:
    # call user-program function
    call umain
  80008e:	056000ef          	jal	ra,8000e4 <umain>
1:  j 1b
  800092:	a001                	j	800092 <_start+0x4>

0000000000800094 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800094:	1141                	addi	sp,sp,-16
  800096:	e022                	sd	s0,0(sp)
  800098:	e406                	sd	ra,8(sp)
  80009a:	842e                	mv	s0,a1
    sys_putc(c);
  80009c:	fd1ff0ef          	jal	ra,80006c <sys_putc>
    (*cnt) ++;
  8000a0:	401c                	lw	a5,0(s0)
}
  8000a2:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000a4:	2785                	addiw	a5,a5,1
  8000a6:	c01c                	sw	a5,0(s0)
}
  8000a8:	6402                	ld	s0,0(sp)
  8000aa:	0141                	addi	sp,sp,16
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
  8000b4:	8e2a                	mv	t3,a0
  8000b6:	f42e                	sd	a1,40(sp)
  8000b8:	f832                	sd	a2,48(sp)
  8000ba:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000bc:	00000517          	auipc	a0,0x0
  8000c0:	fd850513          	addi	a0,a0,-40 # 800094 <cputch>
  8000c4:	004c                	addi	a1,sp,4
  8000c6:	869a                	mv	a3,t1
  8000c8:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000ca:	ec06                	sd	ra,24(sp)
  8000cc:	e0ba                	sd	a4,64(sp)
  8000ce:	e4be                	sd	a5,72(sp)
  8000d0:	e8c2                	sd	a6,80(sp)
  8000d2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000d4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d8:	0d4000ef          	jal	ra,8001ac <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000dc:	60e2                	ld	ra,24(sp)
  8000de:	4512                	lw	a0,4(sp)
  8000e0:	6125                	addi	sp,sp,96
  8000e2:	8082                	ret

00000000008000e4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e4:	1141                	addi	sp,sp,-16
  8000e6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e8:	53c000ef          	jal	ra,800624 <main>
    exit(ret);
  8000ec:	f87ff0ef          	jal	ra,800072 <exit>

00000000008000f0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000f0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  8000f4:	872a                	mv	a4,a0
    size_t cnt = 0;
  8000f6:	4501                	li	a0,0
    while (*s ++ != '\0') {
  8000f8:	cb81                	beqz	a5,800108 <strlen+0x18>
        cnt ++;
  8000fa:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  8000fc:	00a707b3          	add	a5,a4,a0
  800100:	0007c783          	lbu	a5,0(a5)
  800104:	fbfd                	bnez	a5,8000fa <strlen+0xa>
  800106:	8082                	ret
    }
    return cnt;
}
  800108:	8082                	ret

000000000080010a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80010a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80010c:	e589                	bnez	a1,800116 <strnlen+0xc>
  80010e:	a811                	j	800122 <strnlen+0x18>
        cnt ++;
  800110:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800112:	00f58863          	beq	a1,a5,800122 <strnlen+0x18>
  800116:	00f50733          	add	a4,a0,a5
  80011a:	00074703          	lbu	a4,0(a4)
  80011e:	fb6d                	bnez	a4,800110 <strnlen+0x6>
  800120:	85be                	mv	a1,a5
    }
    return cnt;
}
  800122:	852e                	mv	a0,a1
  800124:	8082                	ret

0000000000800126 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800126:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80012a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80012c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800130:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800132:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800136:	f022                	sd	s0,32(sp)
  800138:	ec26                	sd	s1,24(sp)
  80013a:	e84a                	sd	s2,16(sp)
  80013c:	f406                	sd	ra,40(sp)
  80013e:	e44e                	sd	s3,8(sp)
  800140:	84aa                	mv	s1,a0
  800142:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800144:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800148:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80014a:	03067e63          	bgeu	a2,a6,800186 <printnum+0x60>
  80014e:	89be                	mv	s3,a5
        while (-- width > 0)
  800150:	00805763          	blez	s0,80015e <printnum+0x38>
  800154:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800156:	85ca                	mv	a1,s2
  800158:	854e                	mv	a0,s3
  80015a:	9482                	jalr	s1
        while (-- width > 0)
  80015c:	fc65                	bnez	s0,800154 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80015e:	1a02                	slli	s4,s4,0x20
  800160:	00000797          	auipc	a5,0x0
  800164:	4f878793          	addi	a5,a5,1272 # 800658 <main+0x34>
  800168:	020a5a13          	srli	s4,s4,0x20
  80016c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80016e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800170:	000a4503          	lbu	a0,0(s4)
}
  800174:	70a2                	ld	ra,40(sp)
  800176:	69a2                	ld	s3,8(sp)
  800178:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80017a:	85ca                	mv	a1,s2
  80017c:	87a6                	mv	a5,s1
}
  80017e:	6942                	ld	s2,16(sp)
  800180:	64e2                	ld	s1,24(sp)
  800182:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800184:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800186:	03065633          	divu	a2,a2,a6
  80018a:	8722                	mv	a4,s0
  80018c:	f9bff0ef          	jal	ra,800126 <printnum>
  800190:	b7f9                	j	80015e <printnum+0x38>

0000000000800192 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800192:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800194:	6198                	ld	a4,0(a1)
  800196:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800198:	2785                	addiw	a5,a5,1
  80019a:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80019c:	00d77763          	bgeu	a4,a3,8001aa <sprintputch+0x18>
        *b->buf ++ = ch;
  8001a0:	00170793          	addi	a5,a4,1
  8001a4:	e19c                	sd	a5,0(a1)
  8001a6:	00a70023          	sb	a0,0(a4)
    }
}
  8001aa:	8082                	ret

00000000008001ac <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ac:	7119                	addi	sp,sp,-128
  8001ae:	f4a6                	sd	s1,104(sp)
  8001b0:	f0ca                	sd	s2,96(sp)
  8001b2:	ecce                	sd	s3,88(sp)
  8001b4:	e8d2                	sd	s4,80(sp)
  8001b6:	e4d6                	sd	s5,72(sp)
  8001b8:	e0da                	sd	s6,64(sp)
  8001ba:	fc5e                	sd	s7,56(sp)
  8001bc:	f06a                	sd	s10,32(sp)
  8001be:	fc86                	sd	ra,120(sp)
  8001c0:	f8a2                	sd	s0,112(sp)
  8001c2:	f862                	sd	s8,48(sp)
  8001c4:	f466                	sd	s9,40(sp)
  8001c6:	ec6e                	sd	s11,24(sp)
  8001c8:	892a                	mv	s2,a0
  8001ca:	84ae                	mv	s1,a1
  8001cc:	8d32                	mv	s10,a2
  8001ce:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d0:	02500993          	li	s3,37
        width = precision = -1;
  8001d4:	5b7d                	li	s6,-1
  8001d6:	00000a97          	auipc	s5,0x0
  8001da:	4b6a8a93          	addi	s5,s5,1206 # 80068c <main+0x68>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001de:	00000b97          	auipc	s7,0x0
  8001e2:	6cab8b93          	addi	s7,s7,1738 # 8008a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	000d4503          	lbu	a0,0(s10)
  8001ea:	001d0413          	addi	s0,s10,1
  8001ee:	01350a63          	beq	a0,s3,800202 <vprintfmt+0x56>
            if (ch == '\0') {
  8001f2:	c121                	beqz	a0,800232 <vprintfmt+0x86>
            putch(ch, putdat);
  8001f4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001f8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	fff44503          	lbu	a0,-1(s0)
  8001fe:	ff351ae3          	bne	a0,s3,8001f2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800202:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800206:	02000793          	li	a5,32
        lflag = altflag = 0;
  80020a:	4c81                	li	s9,0
  80020c:	4881                	li	a7,0
        width = precision = -1;
  80020e:	5c7d                	li	s8,-1
  800210:	5dfd                	li	s11,-1
  800212:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800216:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	fdd6059b          	addiw	a1,a2,-35
  80021c:	0ff5f593          	zext.b	a1,a1
  800220:	00140d13          	addi	s10,s0,1
  800224:	04b56263          	bltu	a0,a1,800268 <vprintfmt+0xbc>
  800228:	058a                	slli	a1,a1,0x2
  80022a:	95d6                	add	a1,a1,s5
  80022c:	4194                	lw	a3,0(a1)
  80022e:	96d6                	add	a3,a3,s5
  800230:	8682                	jr	a3
}
  800232:	70e6                	ld	ra,120(sp)
  800234:	7446                	ld	s0,112(sp)
  800236:	74a6                	ld	s1,104(sp)
  800238:	7906                	ld	s2,96(sp)
  80023a:	69e6                	ld	s3,88(sp)
  80023c:	6a46                	ld	s4,80(sp)
  80023e:	6aa6                	ld	s5,72(sp)
  800240:	6b06                	ld	s6,64(sp)
  800242:	7be2                	ld	s7,56(sp)
  800244:	7c42                	ld	s8,48(sp)
  800246:	7ca2                	ld	s9,40(sp)
  800248:	7d02                	ld	s10,32(sp)
  80024a:	6de2                	ld	s11,24(sp)
  80024c:	6109                	addi	sp,sp,128
  80024e:	8082                	ret
            padc = '0';
  800250:	87b2                	mv	a5,a2
            goto reswitch;
  800252:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	846a                	mv	s0,s10
  800258:	00140d13          	addi	s10,s0,1
  80025c:	fdd6059b          	addiw	a1,a2,-35
  800260:	0ff5f593          	zext.b	a1,a1
  800264:	fcb572e3          	bgeu	a0,a1,800228 <vprintfmt+0x7c>
            putch('%', putdat);
  800268:	85a6                	mv	a1,s1
  80026a:	02500513          	li	a0,37
  80026e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800270:	fff44783          	lbu	a5,-1(s0)
  800274:	8d22                	mv	s10,s0
  800276:	f73788e3          	beq	a5,s3,8001e6 <vprintfmt+0x3a>
  80027a:	ffed4783          	lbu	a5,-2(s10)
  80027e:	1d7d                	addi	s10,s10,-1
  800280:	ff379de3          	bne	a5,s3,80027a <vprintfmt+0xce>
  800284:	b78d                	j	8001e6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800286:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80028a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800290:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800294:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800298:	02d86463          	bltu	a6,a3,8002c0 <vprintfmt+0x114>
                ch = *fmt;
  80029c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002a0:	002c169b          	slliw	a3,s8,0x2
  8002a4:	0186873b          	addw	a4,a3,s8
  8002a8:	0017171b          	slliw	a4,a4,0x1
  8002ac:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ae:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002bc:	fed870e3          	bgeu	a6,a3,80029c <vprintfmt+0xf0>
            if (width < 0)
  8002c0:	f40ddce3          	bgez	s11,800218 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002c4:	8de2                	mv	s11,s8
  8002c6:	5c7d                	li	s8,-1
  8002c8:	bf81                	j	800218 <vprintfmt+0x6c>
            if (width < 0)
  8002ca:	fffdc693          	not	a3,s11
  8002ce:	96fd                	srai	a3,a3,0x3f
  8002d0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002d4:	00144603          	lbu	a2,1(s0)
  8002d8:	2d81                	sext.w	s11,s11
  8002da:	846a                	mv	s0,s10
            goto reswitch;
  8002dc:	bf35                	j	800218 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002de:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002e6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	846a                	mv	s0,s10
            goto process_precision;
  8002ea:	bfd9                	j	8002c0 <vprintfmt+0x114>
    if (lflag >= 2) {
  8002ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f2:	01174463          	blt	a4,a7,8002fa <vprintfmt+0x14e>
    else if (lflag) {
  8002f6:	1a088e63          	beqz	a7,8004b2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002fa:	000a3603          	ld	a2,0(s4)
  8002fe:	46c1                	li	a3,16
  800300:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800302:	2781                	sext.w	a5,a5
  800304:	876e                	mv	a4,s11
  800306:	85a6                	mv	a1,s1
  800308:	854a                	mv	a0,s2
  80030a:	e1dff0ef          	jal	ra,800126 <printnum>
            break;
  80030e:	bde1                	j	8001e6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800310:	000a2503          	lw	a0,0(s4)
  800314:	85a6                	mv	a1,s1
  800316:	0a21                	addi	s4,s4,8
  800318:	9902                	jalr	s2
            break;
  80031a:	b5f1                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80031c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800322:	01174463          	blt	a4,a7,80032a <vprintfmt+0x17e>
    else if (lflag) {
  800326:	18088163          	beqz	a7,8004a8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80032a:	000a3603          	ld	a2,0(s4)
  80032e:	46a9                	li	a3,10
  800330:	8a2e                	mv	s4,a1
  800332:	bfc1                	j	800302 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800334:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800338:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80033a:	846a                	mv	s0,s10
            goto reswitch;
  80033c:	bdf1                	j	800218 <vprintfmt+0x6c>
            putch(ch, putdat);
  80033e:	85a6                	mv	a1,s1
  800340:	02500513          	li	a0,37
  800344:	9902                	jalr	s2
            break;
  800346:	b545                	j	8001e6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800348:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80034c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80034e:	846a                	mv	s0,s10
            goto reswitch;
  800350:	b5e1                	j	800218 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800352:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800354:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800358:	01174463          	blt	a4,a7,800360 <vprintfmt+0x1b4>
    else if (lflag) {
  80035c:	14088163          	beqz	a7,80049e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800360:	000a3603          	ld	a2,0(s4)
  800364:	46a1                	li	a3,8
  800366:	8a2e                	mv	s4,a1
  800368:	bf69                	j	800302 <vprintfmt+0x156>
            putch('0', putdat);
  80036a:	03000513          	li	a0,48
  80036e:	85a6                	mv	a1,s1
  800370:	e03e                	sd	a5,0(sp)
  800372:	9902                	jalr	s2
            putch('x', putdat);
  800374:	85a6                	mv	a1,s1
  800376:	07800513          	li	a0,120
  80037a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80037c:	0a21                	addi	s4,s4,8
            goto number;
  80037e:	6782                	ld	a5,0(sp)
  800380:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800382:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800386:	bfb5                	j	800302 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800388:	000a3403          	ld	s0,0(s4)
  80038c:	008a0713          	addi	a4,s4,8
  800390:	e03a                	sd	a4,0(sp)
  800392:	14040263          	beqz	s0,8004d6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800396:	0fb05763          	blez	s11,800484 <vprintfmt+0x2d8>
  80039a:	02d00693          	li	a3,45
  80039e:	0cd79163          	bne	a5,a3,800460 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a2:	00044783          	lbu	a5,0(s0)
  8003a6:	0007851b          	sext.w	a0,a5
  8003aa:	cf85                	beqz	a5,8003e2 <vprintfmt+0x236>
  8003ac:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b4:	000c4563          	bltz	s8,8003be <vprintfmt+0x212>
  8003b8:	3c7d                	addiw	s8,s8,-1
  8003ba:	036c0263          	beq	s8,s6,8003de <vprintfmt+0x232>
                    putch('?', putdat);
  8003be:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c0:	0e0c8e63          	beqz	s9,8004bc <vprintfmt+0x310>
  8003c4:	3781                	addiw	a5,a5,-32
  8003c6:	0ef47b63          	bgeu	s0,a5,8004bc <vprintfmt+0x310>
                    putch('?', putdat);
  8003ca:	03f00513          	li	a0,63
  8003ce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d0:	000a4783          	lbu	a5,0(s4)
  8003d4:	3dfd                	addiw	s11,s11,-1
  8003d6:	0a05                	addi	s4,s4,1
  8003d8:	0007851b          	sext.w	a0,a5
  8003dc:	ffe1                	bnez	a5,8003b4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003de:	01b05963          	blez	s11,8003f0 <vprintfmt+0x244>
  8003e2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e4:	85a6                	mv	a1,s1
  8003e6:	02000513          	li	a0,32
  8003ea:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ec:	fe0d9be3          	bnez	s11,8003e2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003f0:	6a02                	ld	s4,0(sp)
  8003f2:	bbd5                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003fa:	01174463          	blt	a4,a7,800402 <vprintfmt+0x256>
    else if (lflag) {
  8003fe:	08088d63          	beqz	a7,800498 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800402:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800406:	0a044d63          	bltz	s0,8004c0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80040a:	8622                	mv	a2,s0
  80040c:	8a66                	mv	s4,s9
  80040e:	46a9                	li	a3,10
  800410:	bdcd                	j	800302 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800412:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800416:	4761                	li	a4,24
            err = va_arg(ap, int);
  800418:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80041a:	41f7d69b          	sraiw	a3,a5,0x1f
  80041e:	8fb5                	xor	a5,a5,a3
  800420:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800424:	02d74163          	blt	a4,a3,800446 <vprintfmt+0x29a>
  800428:	00369793          	slli	a5,a3,0x3
  80042c:	97de                	add	a5,a5,s7
  80042e:	639c                	ld	a5,0(a5)
  800430:	cb99                	beqz	a5,800446 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800432:	86be                	mv	a3,a5
  800434:	00000617          	auipc	a2,0x0
  800438:	25460613          	addi	a2,a2,596 # 800688 <main+0x64>
  80043c:	85a6                	mv	a1,s1
  80043e:	854a                	mv	a0,s2
  800440:	0ce000ef          	jal	ra,80050e <printfmt>
  800444:	b34d                	j	8001e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800446:	00000617          	auipc	a2,0x0
  80044a:	23260613          	addi	a2,a2,562 # 800678 <main+0x54>
  80044e:	85a6                	mv	a1,s1
  800450:	854a                	mv	a0,s2
  800452:	0bc000ef          	jal	ra,80050e <printfmt>
  800456:	bb41                	j	8001e6 <vprintfmt+0x3a>
                p = "(null)";
  800458:	00000417          	auipc	s0,0x0
  80045c:	21840413          	addi	s0,s0,536 # 800670 <main+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800460:	85e2                	mv	a1,s8
  800462:	8522                	mv	a0,s0
  800464:	e43e                	sd	a5,8(sp)
  800466:	ca5ff0ef          	jal	ra,80010a <strnlen>
  80046a:	40ad8dbb          	subw	s11,s11,a0
  80046e:	01b05b63          	blez	s11,800484 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800472:	67a2                	ld	a5,8(sp)
  800474:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800478:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80047a:	85a6                	mv	a1,s1
  80047c:	8552                	mv	a0,s4
  80047e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	fe0d9ce3          	bnez	s11,800478 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	00044783          	lbu	a5,0(s0)
  800488:	00140a13          	addi	s4,s0,1
  80048c:	0007851b          	sext.w	a0,a5
  800490:	d3a5                	beqz	a5,8003f0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800492:	05e00413          	li	s0,94
  800496:	bf39                	j	8003b4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800498:	000a2403          	lw	s0,0(s4)
  80049c:	b7ad                	j	800406 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80049e:	000a6603          	lwu	a2,0(s4)
  8004a2:	46a1                	li	a3,8
  8004a4:	8a2e                	mv	s4,a1
  8004a6:	bdb1                	j	800302 <vprintfmt+0x156>
  8004a8:	000a6603          	lwu	a2,0(s4)
  8004ac:	46a9                	li	a3,10
  8004ae:	8a2e                	mv	s4,a1
  8004b0:	bd89                	j	800302 <vprintfmt+0x156>
  8004b2:	000a6603          	lwu	a2,0(s4)
  8004b6:	46c1                	li	a3,16
  8004b8:	8a2e                	mv	s4,a1
  8004ba:	b5a1                	j	800302 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004bc:	9902                	jalr	s2
  8004be:	bf09                	j	8003d0 <vprintfmt+0x224>
                putch('-', putdat);
  8004c0:	85a6                	mv	a1,s1
  8004c2:	02d00513          	li	a0,45
  8004c6:	e03e                	sd	a5,0(sp)
  8004c8:	9902                	jalr	s2
                num = -(long long)num;
  8004ca:	6782                	ld	a5,0(sp)
  8004cc:	8a66                	mv	s4,s9
  8004ce:	40800633          	neg	a2,s0
  8004d2:	46a9                	li	a3,10
  8004d4:	b53d                	j	800302 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004d6:	03b05163          	blez	s11,8004f8 <vprintfmt+0x34c>
  8004da:	02d00693          	li	a3,45
  8004de:	f6d79de3          	bne	a5,a3,800458 <vprintfmt+0x2ac>
                p = "(null)";
  8004e2:	00000417          	auipc	s0,0x0
  8004e6:	18e40413          	addi	s0,s0,398 # 800670 <main+0x4c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ea:	02800793          	li	a5,40
  8004ee:	02800513          	li	a0,40
  8004f2:	00140a13          	addi	s4,s0,1
  8004f6:	bd6d                	j	8003b0 <vprintfmt+0x204>
  8004f8:	00000a17          	auipc	s4,0x0
  8004fc:	179a0a13          	addi	s4,s4,377 # 800671 <main+0x4d>
  800500:	02800513          	li	a0,40
  800504:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800508:	05e00413          	li	s0,94
  80050c:	b565                	j	8003b4 <vprintfmt+0x208>

000000000080050e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800510:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800516:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	ec06                	sd	ra,24(sp)
  80051a:	f83a                	sd	a4,48(sp)
  80051c:	fc3e                	sd	a5,56(sp)
  80051e:	e0c2                	sd	a6,64(sp)
  800520:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800522:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	c89ff0ef          	jal	ra,8001ac <vprintfmt>
}
  800528:	60e2                	ld	ra,24(sp)
  80052a:	6161                	addi	sp,sp,80
  80052c:	8082                	ret

000000000080052e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  80052e:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800530:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
  800532:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
  800536:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
  800538:	f406                	sd	ra,40(sp)
  80053a:	fc36                	sd	a3,56(sp)
  80053c:	e0ba                	sd	a4,64(sp)
  80053e:	e4be                	sd	a5,72(sp)
  800540:	e8c2                	sd	a6,80(sp)
  800542:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800544:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800546:	e42a                	sd	a0,8(sp)
  800548:	e82e                	sd	a1,16(sp)
  80054a:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80054c:	c115                	beqz	a0,800570 <snprintf+0x42>
  80054e:	02a5e163          	bltu	a1,a0,800570 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800552:	00000517          	auipc	a0,0x0
  800556:	c4050513          	addi	a0,a0,-960 # 800192 <sprintputch>
  80055a:	869a                	mv	a3,t1
  80055c:	002c                	addi	a1,sp,8
  80055e:	c4fff0ef          	jal	ra,8001ac <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800562:	67a2                	ld	a5,8(sp)
  800564:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800568:	4562                	lw	a0,24(sp)
}
  80056a:	70a2                	ld	ra,40(sp)
  80056c:	6125                	addi	sp,sp,96
  80056e:	8082                	ret
        return -E_INVAL;
  800570:	5575                	li	a0,-3
  800572:	bfe5                	j	80056a <snprintf+0x3c>

0000000000800574 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  800574:	1101                	addi	sp,sp,-32
  800576:	ec06                	sd	ra,24(sp)
  800578:	e822                	sd	s0,16(sp)
  80057a:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  80057c:	b11ff0ef          	jal	ra,80008c <getpid>
  800580:	85aa                	mv	a1,a0
  800582:	8622                	mv	a2,s0
  800584:	00000517          	auipc	a0,0x0
  800588:	3ec50513          	addi	a0,a0,1004 # 800970 <error_string+0xc8>
  80058c:	b23ff0ef          	jal	ra,8000ae <cprintf>

    forkchild(cur, '0');
  800590:	03000593          	li	a1,48
  800594:	8522                	mv	a0,s0
  800596:	044000ef          	jal	ra,8005da <forkchild>
    if (strlen(cur) >= DEPTH)
  80059a:	8522                	mv	a0,s0
  80059c:	b55ff0ef          	jal	ra,8000f0 <strlen>
  8005a0:	478d                	li	a5,3
  8005a2:	00a7f663          	bgeu	a5,a0,8005ae <forktree+0x3a>
    forkchild(cur, '1');
}
  8005a6:	60e2                	ld	ra,24(sp)
  8005a8:	6442                	ld	s0,16(sp)
  8005aa:	6105                	addi	sp,sp,32
  8005ac:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005ae:	03100713          	li	a4,49
  8005b2:	86a2                	mv	a3,s0
  8005b4:	00000617          	auipc	a2,0x0
  8005b8:	3d460613          	addi	a2,a2,980 # 800988 <error_string+0xe0>
  8005bc:	4595                	li	a1,5
  8005be:	0028                	addi	a0,sp,8
  8005c0:	f6fff0ef          	jal	ra,80052e <snprintf>
    if (fork() == 0) {
  8005c4:	ac5ff0ef          	jal	ra,800088 <fork>
  8005c8:	fd79                	bnez	a0,8005a6 <forktree+0x32>
        forktree(nxt);
  8005ca:	0028                	addi	a0,sp,8
  8005cc:	fa9ff0ef          	jal	ra,800574 <forktree>
        yield();
  8005d0:	abbff0ef          	jal	ra,80008a <yield>
        exit(0);
  8005d4:	4501                	li	a0,0
  8005d6:	a9dff0ef          	jal	ra,800072 <exit>

00000000008005da <forkchild>:
forkchild(const char *cur, char branch) {
  8005da:	7179                	addi	sp,sp,-48
  8005dc:	f022                	sd	s0,32(sp)
  8005de:	ec26                	sd	s1,24(sp)
  8005e0:	f406                	sd	ra,40(sp)
  8005e2:	842a                	mv	s0,a0
  8005e4:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005e6:	b0bff0ef          	jal	ra,8000f0 <strlen>
  8005ea:	478d                	li	a5,3
  8005ec:	00a7f763          	bgeu	a5,a0,8005fa <forkchild+0x20>
}
  8005f0:	70a2                	ld	ra,40(sp)
  8005f2:	7402                	ld	s0,32(sp)
  8005f4:	64e2                	ld	s1,24(sp)
  8005f6:	6145                	addi	sp,sp,48
  8005f8:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005fa:	8726                	mv	a4,s1
  8005fc:	86a2                	mv	a3,s0
  8005fe:	00000617          	auipc	a2,0x0
  800602:	38a60613          	addi	a2,a2,906 # 800988 <error_string+0xe0>
  800606:	4595                	li	a1,5
  800608:	0028                	addi	a0,sp,8
  80060a:	f25ff0ef          	jal	ra,80052e <snprintf>
    if (fork() == 0) {
  80060e:	a7bff0ef          	jal	ra,800088 <fork>
  800612:	fd79                	bnez	a0,8005f0 <forkchild+0x16>
        forktree(nxt);
  800614:	0028                	addi	a0,sp,8
  800616:	f5fff0ef          	jal	ra,800574 <forktree>
        yield();
  80061a:	a71ff0ef          	jal	ra,80008a <yield>
        exit(0);
  80061e:	4501                	li	a0,0
  800620:	a53ff0ef          	jal	ra,800072 <exit>

0000000000800624 <main>:

int
main(void) {
  800624:	1141                	addi	sp,sp,-16
    forktree("");
  800626:	00000517          	auipc	a0,0x0
  80062a:	35a50513          	addi	a0,a0,858 # 800980 <error_string+0xd8>
main(void) {
  80062e:	e406                	sd	ra,8(sp)
    forktree("");
  800630:	f45ff0ef          	jal	ra,800574 <forktree>
    return 0;
}
  800634:	60a2                	ld	ra,8(sp)
  800636:	4501                	li	a0,0
  800638:	0141                	addi	sp,sp,16
  80063a:	8082                	ret
