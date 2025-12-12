
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
  800040:	4522                	lw	a0,8(sp)
  800042:	55a2                	lw	a1,40(sp)
  800044:	5642                	lw	a2,48(sp)
  800046:	56e2                	lw	a3,56(sp)
  800048:	4706                	lw	a4,64(sp)
  80004a:	47a6                	lw	a5,72(sp)
  80004c:	00000073          	ecall
  800050:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800052:	4572                	lw	a0,28(sp)
  800054:	6149                	addi	sp,sp,144
  800056:	8082                	ret

0000000000800058 <sys_exit>:

int
sys_exit(int64_t error_code) {
  800058:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80005a:	4505                	li	a0,1
  80005c:	b7d1                	j	800020 <syscall>

000000000080005e <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  80005e:	4509                	li	a0,2
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
  800074:	fe5ff0ef          	jal	ra,800058 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800078:	00000517          	auipc	a0,0x0
  80007c:	5c850513          	addi	a0,a0,1480 # 800640 <main+0x1e>
  800080:	02c000ef          	jal	ra,8000ac <cprintf>
    while (1);
  800084:	a001                	j	800084 <exit+0x14>

0000000000800086 <fork>:
}

int
fork(void) {
    return sys_fork();
  800086:	bfe1                	j	80005e <sys_fork>

0000000000800088 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800088:	bfe9                	j	800062 <sys_yield>

000000000080008a <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80008a:	bff1                	j	800066 <sys_getpid>

000000000080008c <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  80008c:	056000ef          	jal	ra,8000e2 <umain>
1:  j 1b
  800090:	a001                	j	800090 <_start+0x4>

0000000000800092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800092:	1141                	addi	sp,sp,-16
  800094:	e022                	sd	s0,0(sp)
  800096:	e406                	sd	ra,8(sp)
  800098:	842e                	mv	s0,a1
    sys_putc(c);
  80009a:	fd1ff0ef          	jal	ra,80006a <sys_putc>
    (*cnt) ++;
  80009e:	401c                	lw	a5,0(s0)
}
  8000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000a2:	2785                	addiw	a5,a5,1
  8000a4:	c01c                	sw	a5,0(s0)
}
  8000a6:	6402                	ld	s0,0(sp)
  8000a8:	0141                	addi	sp,sp,16
  8000aa:	8082                	ret

00000000008000ac <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000ac:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000ae:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b2:	8e2a                	mv	t3,a0
  8000b4:	f42e                	sd	a1,40(sp)
  8000b6:	f832                	sd	a2,48(sp)
  8000b8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ba:	00000517          	auipc	a0,0x0
  8000be:	fd850513          	addi	a0,a0,-40 # 800092 <cputch>
  8000c2:	004c                	addi	a1,sp,4
  8000c4:	869a                	mv	a3,t1
  8000c6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000c8:	ec06                	sd	ra,24(sp)
  8000ca:	e0ba                	sd	a4,64(sp)
  8000cc:	e4be                	sd	a5,72(sp)
  8000ce:	e8c2                	sd	a6,80(sp)
  8000d0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000d2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d6:	0d4000ef          	jal	ra,8001aa <vprintfmt>
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
  8000e6:	53c000ef          	jal	ra,800622 <main>
    exit(ret);
  8000ea:	f87ff0ef          	jal	ra,800070 <exit>

00000000008000ee <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000ee:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  8000f2:	872a                	mv	a4,a0
    size_t cnt = 0;
  8000f4:	4501                	li	a0,0
    while (*s ++ != '\0') {
  8000f6:	cb81                	beqz	a5,800106 <strlen+0x18>
        cnt ++;
  8000f8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  8000fa:	00a707b3          	add	a5,a4,a0
  8000fe:	0007c783          	lbu	a5,0(a5)
  800102:	fbfd                	bnez	a5,8000f8 <strlen+0xa>
  800104:	8082                	ret
    }
    return cnt;
}
  800106:	8082                	ret

0000000000800108 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800108:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80010a:	e589                	bnez	a1,800114 <strnlen+0xc>
  80010c:	a811                	j	800120 <strnlen+0x18>
        cnt ++;
  80010e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800110:	00f58863          	beq	a1,a5,800120 <strnlen+0x18>
  800114:	00f50733          	add	a4,a0,a5
  800118:	00074703          	lbu	a4,0(a4)
  80011c:	fb6d                	bnez	a4,80010e <strnlen+0x6>
  80011e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800120:	852e                	mv	a0,a1
  800122:	8082                	ret

0000000000800124 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800124:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800128:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80012a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80012e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800130:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800134:	f022                	sd	s0,32(sp)
  800136:	ec26                	sd	s1,24(sp)
  800138:	e84a                	sd	s2,16(sp)
  80013a:	f406                	sd	ra,40(sp)
  80013c:	e44e                	sd	s3,8(sp)
  80013e:	84aa                	mv	s1,a0
  800140:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800142:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800146:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800148:	03067e63          	bgeu	a2,a6,800184 <printnum+0x60>
  80014c:	89be                	mv	s3,a5
        while (-- width > 0)
  80014e:	00805763          	blez	s0,80015c <printnum+0x38>
  800152:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800154:	85ca                	mv	a1,s2
  800156:	854e                	mv	a0,s3
  800158:	9482                	jalr	s1
        while (-- width > 0)
  80015a:	fc65                	bnez	s0,800152 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80015c:	1a02                	slli	s4,s4,0x20
  80015e:	00000797          	auipc	a5,0x0
  800162:	4fa78793          	addi	a5,a5,1274 # 800658 <main+0x36>
  800166:	020a5a13          	srli	s4,s4,0x20
  80016a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80016c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80016e:	000a4503          	lbu	a0,0(s4)
}
  800172:	70a2                	ld	ra,40(sp)
  800174:	69a2                	ld	s3,8(sp)
  800176:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800178:	85ca                	mv	a1,s2
  80017a:	87a6                	mv	a5,s1
}
  80017c:	6942                	ld	s2,16(sp)
  80017e:	64e2                	ld	s1,24(sp)
  800180:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800182:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800184:	03065633          	divu	a2,a2,a6
  800188:	8722                	mv	a4,s0
  80018a:	f9bff0ef          	jal	ra,800124 <printnum>
  80018e:	b7f9                	j	80015c <printnum+0x38>

0000000000800190 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800190:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800192:	6198                	ld	a4,0(a1)
  800194:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800196:	2785                	addiw	a5,a5,1
  800198:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80019a:	00d77763          	bgeu	a4,a3,8001a8 <sprintputch+0x18>
        *b->buf ++ = ch;
  80019e:	00170793          	addi	a5,a4,1
  8001a2:	e19c                	sd	a5,0(a1)
  8001a4:	00a70023          	sb	a0,0(a4)
    }
}
  8001a8:	8082                	ret

00000000008001aa <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001aa:	7119                	addi	sp,sp,-128
  8001ac:	f4a6                	sd	s1,104(sp)
  8001ae:	f0ca                	sd	s2,96(sp)
  8001b0:	ecce                	sd	s3,88(sp)
  8001b2:	e8d2                	sd	s4,80(sp)
  8001b4:	e4d6                	sd	s5,72(sp)
  8001b6:	e0da                	sd	s6,64(sp)
  8001b8:	fc5e                	sd	s7,56(sp)
  8001ba:	f06a                	sd	s10,32(sp)
  8001bc:	fc86                	sd	ra,120(sp)
  8001be:	f8a2                	sd	s0,112(sp)
  8001c0:	f862                	sd	s8,48(sp)
  8001c2:	f466                	sd	s9,40(sp)
  8001c4:	ec6e                	sd	s11,24(sp)
  8001c6:	892a                	mv	s2,a0
  8001c8:	84ae                	mv	s1,a1
  8001ca:	8d32                	mv	s10,a2
  8001cc:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ce:	02500993          	li	s3,37
        width = precision = -1;
  8001d2:	5b7d                	li	s6,-1
  8001d4:	00000a97          	auipc	s5,0x0
  8001d8:	4b8a8a93          	addi	s5,s5,1208 # 80068c <main+0x6a>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001dc:	00000b97          	auipc	s7,0x0
  8001e0:	6ccb8b93          	addi	s7,s7,1740 # 8008a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e4:	000d4503          	lbu	a0,0(s10)
  8001e8:	001d0413          	addi	s0,s10,1
  8001ec:	01350a63          	beq	a0,s3,800200 <vprintfmt+0x56>
            if (ch == '\0') {
  8001f0:	c121                	beqz	a0,800230 <vprintfmt+0x86>
            putch(ch, putdat);
  8001f2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001f6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f8:	fff44503          	lbu	a0,-1(s0)
  8001fc:	ff351ae3          	bne	a0,s3,8001f0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800204:	02000793          	li	a5,32
        lflag = altflag = 0;
  800208:	4c81                	li	s9,0
  80020a:	4881                	li	a7,0
        width = precision = -1;
  80020c:	5c7d                	li	s8,-1
  80020e:	5dfd                	li	s11,-1
  800210:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800214:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800216:	fdd6059b          	addiw	a1,a2,-35
  80021a:	0ff5f593          	zext.b	a1,a1
  80021e:	00140d13          	addi	s10,s0,1
  800222:	04b56263          	bltu	a0,a1,800266 <vprintfmt+0xbc>
  800226:	058a                	slli	a1,a1,0x2
  800228:	95d6                	add	a1,a1,s5
  80022a:	4194                	lw	a3,0(a1)
  80022c:	96d6                	add	a3,a3,s5
  80022e:	8682                	jr	a3
}
  800230:	70e6                	ld	ra,120(sp)
  800232:	7446                	ld	s0,112(sp)
  800234:	74a6                	ld	s1,104(sp)
  800236:	7906                	ld	s2,96(sp)
  800238:	69e6                	ld	s3,88(sp)
  80023a:	6a46                	ld	s4,80(sp)
  80023c:	6aa6                	ld	s5,72(sp)
  80023e:	6b06                	ld	s6,64(sp)
  800240:	7be2                	ld	s7,56(sp)
  800242:	7c42                	ld	s8,48(sp)
  800244:	7ca2                	ld	s9,40(sp)
  800246:	7d02                	ld	s10,32(sp)
  800248:	6de2                	ld	s11,24(sp)
  80024a:	6109                	addi	sp,sp,128
  80024c:	8082                	ret
            padc = '0';
  80024e:	87b2                	mv	a5,a2
            goto reswitch;
  800250:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	846a                	mv	s0,s10
  800256:	00140d13          	addi	s10,s0,1
  80025a:	fdd6059b          	addiw	a1,a2,-35
  80025e:	0ff5f593          	zext.b	a1,a1
  800262:	fcb572e3          	bgeu	a0,a1,800226 <vprintfmt+0x7c>
            putch('%', putdat);
  800266:	85a6                	mv	a1,s1
  800268:	02500513          	li	a0,37
  80026c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80026e:	fff44783          	lbu	a5,-1(s0)
  800272:	8d22                	mv	s10,s0
  800274:	f73788e3          	beq	a5,s3,8001e4 <vprintfmt+0x3a>
  800278:	ffed4783          	lbu	a5,-2(s10)
  80027c:	1d7d                	addi	s10,s10,-1
  80027e:	ff379de3          	bne	a5,s3,800278 <vprintfmt+0xce>
  800282:	b78d                	j	8001e4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800284:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800288:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80028e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800292:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800296:	02d86463          	bltu	a6,a3,8002be <vprintfmt+0x114>
                ch = *fmt;
  80029a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80029e:	002c169b          	slliw	a3,s8,0x2
  8002a2:	0186873b          	addw	a4,a3,s8
  8002a6:	0017171b          	slliw	a4,a4,0x1
  8002aa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ac:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002b0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002b6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ba:	fed870e3          	bgeu	a6,a3,80029a <vprintfmt+0xf0>
            if (width < 0)
  8002be:	f40ddce3          	bgez	s11,800216 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002c2:	8de2                	mv	s11,s8
  8002c4:	5c7d                	li	s8,-1
  8002c6:	bf81                	j	800216 <vprintfmt+0x6c>
            if (width < 0)
  8002c8:	fffdc693          	not	a3,s11
  8002cc:	96fd                	srai	a3,a3,0x3f
  8002ce:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002d2:	00144603          	lbu	a2,1(s0)
  8002d6:	2d81                	sext.w	s11,s11
  8002d8:	846a                	mv	s0,s10
            goto reswitch;
  8002da:	bf35                	j	800216 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002dc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002e4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002e6:	846a                	mv	s0,s10
            goto process_precision;
  8002e8:	bfd9                	j	8002be <vprintfmt+0x114>
    if (lflag >= 2) {
  8002ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ec:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f0:	01174463          	blt	a4,a7,8002f8 <vprintfmt+0x14e>
    else if (lflag) {
  8002f4:	1a088e63          	beqz	a7,8004b0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002f8:	000a3603          	ld	a2,0(s4)
  8002fc:	46c1                	li	a3,16
  8002fe:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800300:	2781                	sext.w	a5,a5
  800302:	876e                	mv	a4,s11
  800304:	85a6                	mv	a1,s1
  800306:	854a                	mv	a0,s2
  800308:	e1dff0ef          	jal	ra,800124 <printnum>
            break;
  80030c:	bde1                	j	8001e4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80030e:	000a2503          	lw	a0,0(s4)
  800312:	85a6                	mv	a1,s1
  800314:	0a21                	addi	s4,s4,8
  800316:	9902                	jalr	s2
            break;
  800318:	b5f1                	j	8001e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80031a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800320:	01174463          	blt	a4,a7,800328 <vprintfmt+0x17e>
    else if (lflag) {
  800324:	18088163          	beqz	a7,8004a6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800328:	000a3603          	ld	a2,0(s4)
  80032c:	46a9                	li	a3,10
  80032e:	8a2e                	mv	s4,a1
  800330:	bfc1                	j	800300 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800332:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800336:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800338:	846a                	mv	s0,s10
            goto reswitch;
  80033a:	bdf1                	j	800216 <vprintfmt+0x6c>
            putch(ch, putdat);
  80033c:	85a6                	mv	a1,s1
  80033e:	02500513          	li	a0,37
  800342:	9902                	jalr	s2
            break;
  800344:	b545                	j	8001e4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800346:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80034a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80034c:	846a                	mv	s0,s10
            goto reswitch;
  80034e:	b5e1                	j	800216 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800350:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800352:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800356:	01174463          	blt	a4,a7,80035e <vprintfmt+0x1b4>
    else if (lflag) {
  80035a:	14088163          	beqz	a7,80049c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80035e:	000a3603          	ld	a2,0(s4)
  800362:	46a1                	li	a3,8
  800364:	8a2e                	mv	s4,a1
  800366:	bf69                	j	800300 <vprintfmt+0x156>
            putch('0', putdat);
  800368:	03000513          	li	a0,48
  80036c:	85a6                	mv	a1,s1
  80036e:	e03e                	sd	a5,0(sp)
  800370:	9902                	jalr	s2
            putch('x', putdat);
  800372:	85a6                	mv	a1,s1
  800374:	07800513          	li	a0,120
  800378:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80037a:	0a21                	addi	s4,s4,8
            goto number;
  80037c:	6782                	ld	a5,0(sp)
  80037e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800380:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800384:	bfb5                	j	800300 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800386:	000a3403          	ld	s0,0(s4)
  80038a:	008a0713          	addi	a4,s4,8
  80038e:	e03a                	sd	a4,0(sp)
  800390:	14040263          	beqz	s0,8004d4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800394:	0fb05763          	blez	s11,800482 <vprintfmt+0x2d8>
  800398:	02d00693          	li	a3,45
  80039c:	0cd79163          	bne	a5,a3,80045e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	00044783          	lbu	a5,0(s0)
  8003a4:	0007851b          	sext.w	a0,a5
  8003a8:	cf85                	beqz	a5,8003e0 <vprintfmt+0x236>
  8003aa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ae:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b2:	000c4563          	bltz	s8,8003bc <vprintfmt+0x212>
  8003b6:	3c7d                	addiw	s8,s8,-1
  8003b8:	036c0263          	beq	s8,s6,8003dc <vprintfmt+0x232>
                    putch('?', putdat);
  8003bc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003be:	0e0c8e63          	beqz	s9,8004ba <vprintfmt+0x310>
  8003c2:	3781                	addiw	a5,a5,-32
  8003c4:	0ef47b63          	bgeu	s0,a5,8004ba <vprintfmt+0x310>
                    putch('?', putdat);
  8003c8:	03f00513          	li	a0,63
  8003cc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ce:	000a4783          	lbu	a5,0(s4)
  8003d2:	3dfd                	addiw	s11,s11,-1
  8003d4:	0a05                	addi	s4,s4,1
  8003d6:	0007851b          	sext.w	a0,a5
  8003da:	ffe1                	bnez	a5,8003b2 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003dc:	01b05963          	blez	s11,8003ee <vprintfmt+0x244>
  8003e0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e2:	85a6                	mv	a1,s1
  8003e4:	02000513          	li	a0,32
  8003e8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ea:	fe0d9be3          	bnez	s11,8003e0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ee:	6a02                	ld	s4,0(sp)
  8003f0:	bbd5                	j	8001e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003f8:	01174463          	blt	a4,a7,800400 <vprintfmt+0x256>
    else if (lflag) {
  8003fc:	08088d63          	beqz	a7,800496 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800400:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800404:	0a044d63          	bltz	s0,8004be <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800408:	8622                	mv	a2,s0
  80040a:	8a66                	mv	s4,s9
  80040c:	46a9                	li	a3,10
  80040e:	bdcd                	j	800300 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800410:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800414:	4761                	li	a4,24
            err = va_arg(ap, int);
  800416:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800418:	41f7d69b          	sraiw	a3,a5,0x1f
  80041c:	8fb5                	xor	a5,a5,a3
  80041e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800422:	02d74163          	blt	a4,a3,800444 <vprintfmt+0x29a>
  800426:	00369793          	slli	a5,a3,0x3
  80042a:	97de                	add	a5,a5,s7
  80042c:	639c                	ld	a5,0(a5)
  80042e:	cb99                	beqz	a5,800444 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800430:	86be                	mv	a3,a5
  800432:	00000617          	auipc	a2,0x0
  800436:	25660613          	addi	a2,a2,598 # 800688 <main+0x66>
  80043a:	85a6                	mv	a1,s1
  80043c:	854a                	mv	a0,s2
  80043e:	0ce000ef          	jal	ra,80050c <printfmt>
  800442:	b34d                	j	8001e4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800444:	00000617          	auipc	a2,0x0
  800448:	23460613          	addi	a2,a2,564 # 800678 <main+0x56>
  80044c:	85a6                	mv	a1,s1
  80044e:	854a                	mv	a0,s2
  800450:	0bc000ef          	jal	ra,80050c <printfmt>
  800454:	bb41                	j	8001e4 <vprintfmt+0x3a>
                p = "(null)";
  800456:	00000417          	auipc	s0,0x0
  80045a:	21a40413          	addi	s0,s0,538 # 800670 <main+0x4e>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045e:	85e2                	mv	a1,s8
  800460:	8522                	mv	a0,s0
  800462:	e43e                	sd	a5,8(sp)
  800464:	ca5ff0ef          	jal	ra,800108 <strnlen>
  800468:	40ad8dbb          	subw	s11,s11,a0
  80046c:	01b05b63          	blez	s11,800482 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800470:	67a2                	ld	a5,8(sp)
  800472:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800476:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800478:	85a6                	mv	a1,s1
  80047a:	8552                	mv	a0,s4
  80047c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	fe0d9ce3          	bnez	s11,800476 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800482:	00044783          	lbu	a5,0(s0)
  800486:	00140a13          	addi	s4,s0,1
  80048a:	0007851b          	sext.w	a0,a5
  80048e:	d3a5                	beqz	a5,8003ee <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800490:	05e00413          	li	s0,94
  800494:	bf39                	j	8003b2 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800496:	000a2403          	lw	s0,0(s4)
  80049a:	b7ad                	j	800404 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80049c:	000a6603          	lwu	a2,0(s4)
  8004a0:	46a1                	li	a3,8
  8004a2:	8a2e                	mv	s4,a1
  8004a4:	bdb1                	j	800300 <vprintfmt+0x156>
  8004a6:	000a6603          	lwu	a2,0(s4)
  8004aa:	46a9                	li	a3,10
  8004ac:	8a2e                	mv	s4,a1
  8004ae:	bd89                	j	800300 <vprintfmt+0x156>
  8004b0:	000a6603          	lwu	a2,0(s4)
  8004b4:	46c1                	li	a3,16
  8004b6:	8a2e                	mv	s4,a1
  8004b8:	b5a1                	j	800300 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004ba:	9902                	jalr	s2
  8004bc:	bf09                	j	8003ce <vprintfmt+0x224>
                putch('-', putdat);
  8004be:	85a6                	mv	a1,s1
  8004c0:	02d00513          	li	a0,45
  8004c4:	e03e                	sd	a5,0(sp)
  8004c6:	9902                	jalr	s2
                num = -(long long)num;
  8004c8:	6782                	ld	a5,0(sp)
  8004ca:	8a66                	mv	s4,s9
  8004cc:	40800633          	neg	a2,s0
  8004d0:	46a9                	li	a3,10
  8004d2:	b53d                	j	800300 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004d4:	03b05163          	blez	s11,8004f6 <vprintfmt+0x34c>
  8004d8:	02d00693          	li	a3,45
  8004dc:	f6d79de3          	bne	a5,a3,800456 <vprintfmt+0x2ac>
                p = "(null)";
  8004e0:	00000417          	auipc	s0,0x0
  8004e4:	19040413          	addi	s0,s0,400 # 800670 <main+0x4e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	02800793          	li	a5,40
  8004ec:	02800513          	li	a0,40
  8004f0:	00140a13          	addi	s4,s0,1
  8004f4:	bd6d                	j	8003ae <vprintfmt+0x204>
  8004f6:	00000a17          	auipc	s4,0x0
  8004fa:	17ba0a13          	addi	s4,s4,379 # 800671 <main+0x4f>
  8004fe:	02800513          	li	a0,40
  800502:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800506:	05e00413          	li	s0,94
  80050a:	b565                	j	8003b2 <vprintfmt+0x208>

000000000080050c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80050e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800512:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800514:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800516:	ec06                	sd	ra,24(sp)
  800518:	f83a                	sd	a4,48(sp)
  80051a:	fc3e                	sd	a5,56(sp)
  80051c:	e0c2                	sd	a6,64(sp)
  80051e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800520:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800522:	c89ff0ef          	jal	ra,8001aa <vprintfmt>
}
  800526:	60e2                	ld	ra,24(sp)
  800528:	6161                	addi	sp,sp,80
  80052a:	8082                	ret

000000000080052c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  80052c:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  80052e:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
  800530:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
  800534:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
  800536:	f406                	sd	ra,40(sp)
  800538:	fc36                	sd	a3,56(sp)
  80053a:	e0ba                	sd	a4,64(sp)
  80053c:	e4be                	sd	a5,72(sp)
  80053e:	e8c2                	sd	a6,80(sp)
  800540:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800542:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800544:	e42a                	sd	a0,8(sp)
  800546:	e82e                	sd	a1,16(sp)
  800548:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80054a:	c115                	beqz	a0,80056e <snprintf+0x42>
  80054c:	02a5e163          	bltu	a1,a0,80056e <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800550:	00000517          	auipc	a0,0x0
  800554:	c4050513          	addi	a0,a0,-960 # 800190 <sprintputch>
  800558:	869a                	mv	a3,t1
  80055a:	002c                	addi	a1,sp,8
  80055c:	c4fff0ef          	jal	ra,8001aa <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800560:	67a2                	ld	a5,8(sp)
  800562:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800566:	4562                	lw	a0,24(sp)
}
  800568:	70a2                	ld	ra,40(sp)
  80056a:	6125                	addi	sp,sp,96
  80056c:	8082                	ret
        return -E_INVAL;
  80056e:	5575                	li	a0,-3
  800570:	bfe5                	j	800568 <snprintf+0x3c>

0000000000800572 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  800572:	1101                	addi	sp,sp,-32
  800574:	ec06                	sd	ra,24(sp)
  800576:	e822                	sd	s0,16(sp)
  800578:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  80057a:	b11ff0ef          	jal	ra,80008a <getpid>
  80057e:	85aa                	mv	a1,a0
  800580:	8622                	mv	a2,s0
  800582:	00000517          	auipc	a0,0x0
  800586:	3ee50513          	addi	a0,a0,1006 # 800970 <error_string+0xc8>
  80058a:	b23ff0ef          	jal	ra,8000ac <cprintf>

    forkchild(cur, '0');
  80058e:	03000593          	li	a1,48
  800592:	8522                	mv	a0,s0
  800594:	044000ef          	jal	ra,8005d8 <forkchild>
    if (strlen(cur) >= DEPTH)
  800598:	8522                	mv	a0,s0
  80059a:	b55ff0ef          	jal	ra,8000ee <strlen>
  80059e:	478d                	li	a5,3
  8005a0:	00a7f663          	bgeu	a5,a0,8005ac <forktree+0x3a>
    forkchild(cur, '1');
}
  8005a4:	60e2                	ld	ra,24(sp)
  8005a6:	6442                	ld	s0,16(sp)
  8005a8:	6105                	addi	sp,sp,32
  8005aa:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005ac:	03100713          	li	a4,49
  8005b0:	86a2                	mv	a3,s0
  8005b2:	00000617          	auipc	a2,0x0
  8005b6:	3d660613          	addi	a2,a2,982 # 800988 <error_string+0xe0>
  8005ba:	4595                	li	a1,5
  8005bc:	0028                	addi	a0,sp,8
  8005be:	f6fff0ef          	jal	ra,80052c <snprintf>
    if (fork() == 0) {
  8005c2:	ac5ff0ef          	jal	ra,800086 <fork>
  8005c6:	fd79                	bnez	a0,8005a4 <forktree+0x32>
        forktree(nxt);
  8005c8:	0028                	addi	a0,sp,8
  8005ca:	fa9ff0ef          	jal	ra,800572 <forktree>
        yield();
  8005ce:	abbff0ef          	jal	ra,800088 <yield>
        exit(0);
  8005d2:	4501                	li	a0,0
  8005d4:	a9dff0ef          	jal	ra,800070 <exit>

00000000008005d8 <forkchild>:
forkchild(const char *cur, char branch) {
  8005d8:	7179                	addi	sp,sp,-48
  8005da:	f022                	sd	s0,32(sp)
  8005dc:	ec26                	sd	s1,24(sp)
  8005de:	f406                	sd	ra,40(sp)
  8005e0:	842a                	mv	s0,a0
  8005e2:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005e4:	b0bff0ef          	jal	ra,8000ee <strlen>
  8005e8:	478d                	li	a5,3
  8005ea:	00a7f763          	bgeu	a5,a0,8005f8 <forkchild+0x20>
}
  8005ee:	70a2                	ld	ra,40(sp)
  8005f0:	7402                	ld	s0,32(sp)
  8005f2:	64e2                	ld	s1,24(sp)
  8005f4:	6145                	addi	sp,sp,48
  8005f6:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005f8:	8726                	mv	a4,s1
  8005fa:	86a2                	mv	a3,s0
  8005fc:	00000617          	auipc	a2,0x0
  800600:	38c60613          	addi	a2,a2,908 # 800988 <error_string+0xe0>
  800604:	4595                	li	a1,5
  800606:	0028                	addi	a0,sp,8
  800608:	f25ff0ef          	jal	ra,80052c <snprintf>
    if (fork() == 0) {
  80060c:	a7bff0ef          	jal	ra,800086 <fork>
  800610:	fd79                	bnez	a0,8005ee <forkchild+0x16>
        forktree(nxt);
  800612:	0028                	addi	a0,sp,8
  800614:	f5fff0ef          	jal	ra,800572 <forktree>
        yield();
  800618:	a71ff0ef          	jal	ra,800088 <yield>
        exit(0);
  80061c:	4501                	li	a0,0
  80061e:	a53ff0ef          	jal	ra,800070 <exit>

0000000000800622 <main>:

int
main(void) {
  800622:	1141                	addi	sp,sp,-16
    forktree("");
  800624:	00000517          	auipc	a0,0x0
  800628:	35c50513          	addi	a0,a0,860 # 800980 <error_string+0xd8>
main(void) {
  80062c:	e406                	sd	ra,8(sp)
    forktree("");
  80062e:	f45ff0ef          	jal	ra,800572 <forktree>
    return 0;
}
  800632:	60a2                	ld	ra,8(sp)
  800634:	4501                	li	a0,0
  800636:	0141                	addi	sp,sp,16
  800638:	8082                	ret
