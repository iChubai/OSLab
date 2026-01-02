
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	715d                	addi	sp,sp,-80
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800022:	02810313          	addi	t1,sp,40
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	5e250513          	addi	a0,a0,1506 # 800610 <main+0xce>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e41a                	sd	t1,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0d6000ef          	jal	80011a <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0ae000ef          	jal	8000fa <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	5e050513          	addi	a0,a0,1504 # 800630 <main+0xee>
  800058:	0c2000ef          	jal	80011a <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	060000ef          	jal	8000be <exit>

0000000000800062 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800062:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800064:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  800068:	e42a                	sd	a0,8(sp)
  80006a:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  80006c:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  80006e:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  800070:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  800072:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  800074:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  800076:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  800078:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  80007a:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  80007c:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  80007e:	e142                	sd	a6,128(sp)
  800080:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800082:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);
    asm volatile (
  800084:	4522                	lw	a0,8(sp)
  800086:	55a2                	lw	a1,40(sp)
  800088:	5642                	lw	a2,48(sp)
  80008a:	56e2                	lw	a3,56(sp)
  80008c:	4706                	lw	a4,64(sp)
  80008e:	47a6                	lw	a5,72(sp)
  800090:	00000073          	ecall
  800094:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800096:	4572                	lw	a0,28(sp)
  800098:	6149                	addi	sp,sp,144
  80009a:	8082                	ret

000000000080009c <sys_exit>:

int
sys_exit(int64_t error_code) {
  80009c:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80009e:	4505                	li	a0,1
  8000a0:	b7c9                	j	800062 <syscall>

00000000008000a2 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000a2:	4509                	li	a0,2
  8000a4:	bf7d                	j	800062 <syscall>

00000000008000a6 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  8000a6:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  8000a8:	85aa                	mv	a1,a0
  8000aa:	450d                	li	a0,3
  8000ac:	bf5d                	j	800062 <syscall>

00000000008000ae <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ae:	4529                	li	a0,10
  8000b0:	bf4d                	j	800062 <syscall>

00000000008000b2 <sys_kill>:
}

int
sys_kill(int64_t pid) {
  8000b2:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  8000b4:	4531                	li	a0,12
  8000b6:	b775                	j	800062 <syscall>

00000000008000b8 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b8:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000ba:	4579                	li	a0,30
  8000bc:	b75d                	j	800062 <syscall>

00000000008000be <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000be:	1141                	addi	sp,sp,-16
  8000c0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c2:	fdbff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	57250513          	addi	a0,a0,1394 # 800638 <main+0xf6>
  8000ce:	04c000ef          	jal	80011a <cprintf>
    while (1);
  8000d2:	a001                	j	8000d2 <exit+0x14>

00000000008000d4 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d4:	b7f9                	j	8000a2 <sys_fork>

00000000008000d6 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d6:	bfc1                	j	8000a6 <sys_wait>

00000000008000d8 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d8:	bfd9                	j	8000ae <sys_yield>

00000000008000da <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000da:	bfe1                	j	8000b2 <sys_kill>

00000000008000dc <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000dc:	072000ef          	jal	80014e <umain>
1:  j 1b
  8000e0:	a001                	j	8000e0 <_start+0x4>

00000000008000e2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e2:	1101                	addi	sp,sp,-32
  8000e4:	ec06                	sd	ra,24(sp)
  8000e6:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000e8:	fd1ff0ef          	jal	8000b8 <sys_putc>
    (*cnt) ++;
  8000ec:	65a2                	ld	a1,8(sp)
}
  8000ee:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000f0:	419c                	lw	a5,0(a1)
  8000f2:	2785                	addiw	a5,a5,1
  8000f4:	c19c                	sw	a5,0(a1)
}
  8000f6:	6105                	addi	sp,sp,32
  8000f8:	8082                	ret

00000000008000fa <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000fa:	1101                	addi	sp,sp,-32
  8000fc:	862a                	mv	a2,a0
  8000fe:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800100:	00000517          	auipc	a0,0x0
  800104:	fe250513          	addi	a0,a0,-30 # 8000e2 <cputch>
  800108:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  80010a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010e:	0ce000ef          	jal	8001dc <vprintfmt>
    return cnt;
}
  800112:	60e2                	ld	ra,24(sp)
  800114:	4532                	lw	a0,12(sp)
  800116:	6105                	addi	sp,sp,32
  800118:	8082                	ret

000000000080011a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80011a:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800120:	f42e                	sd	a1,40(sp)
  800122:	f832                	sd	a2,48(sp)
  800124:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800126:	862a                	mv	a2,a0
  800128:	004c                	addi	a1,sp,4
  80012a:	00000517          	auipc	a0,0x0
  80012e:	fb850513          	addi	a0,a0,-72 # 8000e2 <cputch>
  800132:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800134:	ec06                	sd	ra,24(sp)
  800136:	e0ba                	sd	a4,64(sp)
  800138:	e4be                	sd	a5,72(sp)
  80013a:	e8c2                	sd	a6,80(sp)
  80013c:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  80013e:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800140:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800142:	09a000ef          	jal	8001dc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800146:	60e2                	ld	ra,24(sp)
  800148:	4512                	lw	a0,4(sp)
  80014a:	6125                	addi	sp,sp,96
  80014c:	8082                	ret

000000000080014e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014e:	1141                	addi	sp,sp,-16
  800150:	e406                	sd	ra,8(sp)
    int ret = main();
  800152:	3f0000ef          	jal	800542 <main>
    exit(ret);
  800156:	f69ff0ef          	jal	8000be <exit>

000000000080015a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80015a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80015c:	e589                	bnez	a1,800166 <strnlen+0xc>
  80015e:	a811                	j	800172 <strnlen+0x18>
        cnt ++;
  800160:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800162:	00f58863          	beq	a1,a5,800172 <strnlen+0x18>
  800166:	00f50733          	add	a4,a0,a5
  80016a:	00074703          	lbu	a4,0(a4)
  80016e:	fb6d                	bnez	a4,800160 <strnlen+0x6>
  800170:	85be                	mv	a1,a5
    }
    return cnt;
}
  800172:	852e                	mv	a0,a1
  800174:	8082                	ret

0000000000800176 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800178:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	f022                	sd	s0,32(sp)
  80017e:	ec26                	sd	s1,24(sp)
  800180:	e84a                	sd	s2,16(sp)
  800182:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800184:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80018a:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018e:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800192:	84aa                	mv	s1,a0
  800194:	892e                	mv	s2,a1
    if (num >= base) {
  800196:	03067d63          	bgeu	a2,a6,8001d0 <printnum+0x5a>
  80019a:	e44e                	sd	s3,8(sp)
  80019c:	89be                	mv	s3,a5
        while (-- width > 0)
  80019e:	4785                	li	a5,1
  8001a0:	00e7d763          	bge	a5,a4,8001ae <printnum+0x38>
            putch(padc, putdat);
  8001a4:	85ca                	mv	a1,s2
  8001a6:	854e                	mv	a0,s3
        while (-- width > 0)
  8001a8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001aa:	9482                	jalr	s1
        while (-- width > 0)
  8001ac:	fc65                	bnez	s0,8001a4 <printnum+0x2e>
  8001ae:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	00000797          	auipc	a5,0x0
  8001b4:	4a078793          	addi	a5,a5,1184 # 800650 <main+0x10e>
  8001b8:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ba:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001bc:	0007c503          	lbu	a0,0(a5)
}
  8001c0:	70a2                	ld	ra,40(sp)
  8001c2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	85ca                	mv	a1,s2
  8001c6:	87a6                	mv	a5,s1
}
  8001c8:	6942                	ld	s2,16(sp)
  8001ca:	64e2                	ld	s1,24(sp)
  8001cc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ce:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d0:	03065633          	divu	a2,a2,a6
  8001d4:	8722                	mv	a4,s0
  8001d6:	fa1ff0ef          	jal	800176 <printnum>
  8001da:	bfd9                	j	8001b0 <printnum+0x3a>

00000000008001dc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001dc:	7119                	addi	sp,sp,-128
  8001de:	f4a6                	sd	s1,104(sp)
  8001e0:	f0ca                	sd	s2,96(sp)
  8001e2:	ecce                	sd	s3,88(sp)
  8001e4:	e8d2                	sd	s4,80(sp)
  8001e6:	e4d6                	sd	s5,72(sp)
  8001e8:	e0da                	sd	s6,64(sp)
  8001ea:	f862                	sd	s8,48(sp)
  8001ec:	fc86                	sd	ra,120(sp)
  8001ee:	f8a2                	sd	s0,112(sp)
  8001f0:	fc5e                	sd	s7,56(sp)
  8001f2:	f466                	sd	s9,40(sp)
  8001f4:	f06a                	sd	s10,32(sp)
  8001f6:	ec6e                	sd	s11,24(sp)
  8001f8:	84aa                	mv	s1,a0
  8001fa:	8c32                	mv	s8,a2
  8001fc:	8a36                	mv	s4,a3
  8001fe:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800204:	05500b13          	li	s6,85
  800208:	00000a97          	auipc	s5,0x0
  80020c:	678a8a93          	addi	s5,s5,1656 # 800880 <main+0x33e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	000c4503          	lbu	a0,0(s8)
  800214:	001c0413          	addi	s0,s8,1
  800218:	01350a63          	beq	a0,s3,80022c <vprintfmt+0x50>
            if (ch == '\0') {
  80021c:	cd0d                	beqz	a0,800256 <vprintfmt+0x7a>
            putch(ch, putdat);
  80021e:	85ca                	mv	a1,s2
  800220:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	00044503          	lbu	a0,0(s0)
  800226:	0405                	addi	s0,s0,1
  800228:	ff351ae3          	bne	a0,s3,80021c <vprintfmt+0x40>
        width = precision = -1;
  80022c:	5cfd                	li	s9,-1
  80022e:	8d66                	mv	s10,s9
        char padc = ' ';
  800230:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800234:	4b81                	li	s7,0
  800236:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	00044683          	lbu	a3,0(s0)
  80023c:	00140c13          	addi	s8,s0,1
  800240:	fdd6859b          	addiw	a1,a3,-35
  800244:	0ff5f593          	zext.b	a1,a1
  800248:	02bb6663          	bltu	s6,a1,800274 <vprintfmt+0x98>
  80024c:	058a                	slli	a1,a1,0x2
  80024e:	95d6                	add	a1,a1,s5
  800250:	4198                	lw	a4,0(a1)
  800252:	9756                	add	a4,a4,s5
  800254:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800256:	70e6                	ld	ra,120(sp)
  800258:	7446                	ld	s0,112(sp)
  80025a:	74a6                	ld	s1,104(sp)
  80025c:	7906                	ld	s2,96(sp)
  80025e:	69e6                	ld	s3,88(sp)
  800260:	6a46                	ld	s4,80(sp)
  800262:	6aa6                	ld	s5,72(sp)
  800264:	6b06                	ld	s6,64(sp)
  800266:	7be2                	ld	s7,56(sp)
  800268:	7c42                	ld	s8,48(sp)
  80026a:	7ca2                	ld	s9,40(sp)
  80026c:	7d02                	ld	s10,32(sp)
  80026e:	6de2                	ld	s11,24(sp)
  800270:	6109                	addi	sp,sp,128
  800272:	8082                	ret
            putch('%', putdat);
  800274:	85ca                	mv	a1,s2
  800276:	02500513          	li	a0,37
  80027a:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80027c:	fff44783          	lbu	a5,-1(s0)
  800280:	02500713          	li	a4,37
  800284:	8c22                	mv	s8,s0
  800286:	f8e785e3          	beq	a5,a4,800210 <vprintfmt+0x34>
  80028a:	ffec4783          	lbu	a5,-2(s8)
  80028e:	1c7d                	addi	s8,s8,-1
  800290:	fee79de3          	bne	a5,a4,80028a <vprintfmt+0xae>
  800294:	bfb5                	j	800210 <vprintfmt+0x34>
                ch = *fmt;
  800296:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80029a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80029c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002a0:	fd06071b          	addiw	a4,a2,-48
  8002a4:	24e56a63          	bltu	a0,a4,8004f8 <vprintfmt+0x31c>
                ch = *fmt;
  8002a8:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002aa:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002ac:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002b0:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002b4:	0197073b          	addw	a4,a4,s9
  8002b8:	0017171b          	slliw	a4,a4,0x1
  8002bc:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002be:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002c2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002c4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002c8:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002cc:	feb570e3          	bgeu	a0,a1,8002ac <vprintfmt+0xd0>
            if (width < 0)
  8002d0:	f60d54e3          	bgez	s10,800238 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002d4:	8d66                	mv	s10,s9
  8002d6:	5cfd                	li	s9,-1
  8002d8:	b785                	j	800238 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002da:	8db6                	mv	s11,a3
  8002dc:	8462                	mv	s0,s8
  8002de:	bfa9                	j	800238 <vprintfmt+0x5c>
  8002e0:	8462                	mv	s0,s8
            altflag = 1;
  8002e2:	4b85                	li	s7,1
            goto reswitch;
  8002e4:	bf91                	j	800238 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ec:	00f74463          	blt	a4,a5,8002f4 <vprintfmt+0x118>
    else if (lflag) {
  8002f0:	1a078763          	beqz	a5,80049e <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002f4:	000a3603          	ld	a2,0(s4)
  8002f8:	46c1                	li	a3,16
  8002fa:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002fc:	000d879b          	sext.w	a5,s11
  800300:	876a                	mv	a4,s10
  800302:	85ca                	mv	a1,s2
  800304:	8526                	mv	a0,s1
  800306:	e71ff0ef          	jal	800176 <printnum>
            break;
  80030a:	b719                	j	800210 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80030c:	000a2503          	lw	a0,0(s4)
  800310:	85ca                	mv	a1,s2
  800312:	0a21                	addi	s4,s4,8
  800314:	9482                	jalr	s1
            break;
  800316:	bded                	j	800210 <vprintfmt+0x34>
    if (lflag >= 2) {
  800318:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80031e:	00f74463          	blt	a4,a5,800326 <vprintfmt+0x14a>
    else if (lflag) {
  800322:	16078963          	beqz	a5,800494 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800326:	000a3603          	ld	a2,0(s4)
  80032a:	46a9                	li	a3,10
  80032c:	8a2e                	mv	s4,a1
  80032e:	b7f9                	j	8002fc <vprintfmt+0x120>
            putch('0', putdat);
  800330:	85ca                	mv	a1,s2
  800332:	03000513          	li	a0,48
  800336:	9482                	jalr	s1
            putch('x', putdat);
  800338:	85ca                	mv	a1,s2
  80033a:	07800513          	li	a0,120
  80033e:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800340:	000a3603          	ld	a2,0(s4)
            goto number;
  800344:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800346:	0a21                	addi	s4,s4,8
            goto number;
  800348:	bf55                	j	8002fc <vprintfmt+0x120>
            putch(ch, putdat);
  80034a:	85ca                	mv	a1,s2
  80034c:	02500513          	li	a0,37
  800350:	9482                	jalr	s1
            break;
  800352:	bd7d                	j	800210 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800354:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800358:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80035a:	0a21                	addi	s4,s4,8
            goto process_precision;
  80035c:	bf95                	j	8002d0 <vprintfmt+0xf4>
    if (lflag >= 2) {
  80035e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800360:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800364:	00f74463          	blt	a4,a5,80036c <vprintfmt+0x190>
    else if (lflag) {
  800368:	12078163          	beqz	a5,80048a <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80036c:	000a3603          	ld	a2,0(s4)
  800370:	46a1                	li	a3,8
  800372:	8a2e                	mv	s4,a1
  800374:	b761                	j	8002fc <vprintfmt+0x120>
            if (width < 0)
  800376:	876a                	mv	a4,s10
  800378:	000d5363          	bgez	s10,80037e <vprintfmt+0x1a2>
  80037c:	4701                	li	a4,0
  80037e:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800382:	8462                	mv	s0,s8
            goto reswitch;
  800384:	bd55                	j	800238 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800386:	000d841b          	sext.w	s0,s11
  80038a:	fd340793          	addi	a5,s0,-45
  80038e:	00f037b3          	snez	a5,a5
  800392:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800396:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80039a:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80039c:	008a0793          	addi	a5,s4,8
  8003a0:	e43e                	sd	a5,8(sp)
  8003a2:	100d8c63          	beqz	s11,8004ba <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003a6:	12071363          	bnez	a4,8004cc <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003aa:	000dc783          	lbu	a5,0(s11)
  8003ae:	0007851b          	sext.w	a0,a5
  8003b2:	c78d                	beqz	a5,8003dc <vprintfmt+0x200>
  8003b4:	0d85                	addi	s11,s11,1
  8003b6:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b8:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003bc:	000cc563          	bltz	s9,8003c6 <vprintfmt+0x1ea>
  8003c0:	3cfd                	addiw	s9,s9,-1
  8003c2:	008c8d63          	beq	s9,s0,8003dc <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c6:	020b9663          	bnez	s7,8003f2 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003ca:	85ca                	mv	a1,s2
  8003cc:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ce:	000dc783          	lbu	a5,0(s11)
  8003d2:	0d85                	addi	s11,s11,1
  8003d4:	3d7d                	addiw	s10,s10,-1
  8003d6:	0007851b          	sext.w	a0,a5
  8003da:	f3ed                	bnez	a5,8003bc <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003dc:	01a05963          	blez	s10,8003ee <vprintfmt+0x212>
                putch(' ', putdat);
  8003e0:	85ca                	mv	a1,s2
  8003e2:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003e6:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003e8:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003ea:	fe0d1be3          	bnez	s10,8003e0 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ee:	6a22                	ld	s4,8(sp)
  8003f0:	b505                	j	800210 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f2:	3781                	addiw	a5,a5,-32
  8003f4:	fcfa7be3          	bgeu	s4,a5,8003ca <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003f8:	03f00513          	li	a0,63
  8003fc:	85ca                	mv	a1,s2
  8003fe:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800400:	000dc783          	lbu	a5,0(s11)
  800404:	0d85                	addi	s11,s11,1
  800406:	3d7d                	addiw	s10,s10,-1
  800408:	0007851b          	sext.w	a0,a5
  80040c:	dbe1                	beqz	a5,8003dc <vprintfmt+0x200>
  80040e:	fa0cd9e3          	bgez	s9,8003c0 <vprintfmt+0x1e4>
  800412:	b7c5                	j	8003f2 <vprintfmt+0x216>
            if (err < 0) {
  800414:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800418:	4661                	li	a2,24
            err = va_arg(ap, int);
  80041a:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80041c:	41f7d71b          	sraiw	a4,a5,0x1f
  800420:	8fb9                	xor	a5,a5,a4
  800422:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800426:	02d64563          	blt	a2,a3,800450 <vprintfmt+0x274>
  80042a:	00000797          	auipc	a5,0x0
  80042e:	5ae78793          	addi	a5,a5,1454 # 8009d8 <error_string>
  800432:	00369713          	slli	a4,a3,0x3
  800436:	97ba                	add	a5,a5,a4
  800438:	639c                	ld	a5,0(a5)
  80043a:	cb99                	beqz	a5,800450 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80043c:	86be                	mv	a3,a5
  80043e:	00000617          	auipc	a2,0x0
  800442:	24260613          	addi	a2,a2,578 # 800680 <main+0x13e>
  800446:	85ca                	mv	a1,s2
  800448:	8526                	mv	a0,s1
  80044a:	0d8000ef          	jal	800522 <printfmt>
  80044e:	b3c9                	j	800210 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800450:	00000617          	auipc	a2,0x0
  800454:	22060613          	addi	a2,a2,544 # 800670 <main+0x12e>
  800458:	85ca                	mv	a1,s2
  80045a:	8526                	mv	a0,s1
  80045c:	0c6000ef          	jal	800522 <printfmt>
  800460:	bb45                	j	800210 <vprintfmt+0x34>
    if (lflag >= 2) {
  800462:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800464:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800468:	00f74363          	blt	a4,a5,80046e <vprintfmt+0x292>
    else if (lflag) {
  80046c:	cf81                	beqz	a5,800484 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80046e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800472:	02044b63          	bltz	s0,8004a8 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800476:	8622                	mv	a2,s0
  800478:	8a5e                	mv	s4,s7
  80047a:	46a9                	li	a3,10
  80047c:	b541                	j	8002fc <vprintfmt+0x120>
            lflag ++;
  80047e:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800480:	8462                	mv	s0,s8
            goto reswitch;
  800482:	bb5d                	j	800238 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800484:	000a2403          	lw	s0,0(s4)
  800488:	b7ed                	j	800472 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80048a:	000a6603          	lwu	a2,0(s4)
  80048e:	46a1                	li	a3,8
  800490:	8a2e                	mv	s4,a1
  800492:	b5ad                	j	8002fc <vprintfmt+0x120>
  800494:	000a6603          	lwu	a2,0(s4)
  800498:	46a9                	li	a3,10
  80049a:	8a2e                	mv	s4,a1
  80049c:	b585                	j	8002fc <vprintfmt+0x120>
  80049e:	000a6603          	lwu	a2,0(s4)
  8004a2:	46c1                	li	a3,16
  8004a4:	8a2e                	mv	s4,a1
  8004a6:	bd99                	j	8002fc <vprintfmt+0x120>
                putch('-', putdat);
  8004a8:	85ca                	mv	a1,s2
  8004aa:	02d00513          	li	a0,45
  8004ae:	9482                	jalr	s1
                num = -(long long)num;
  8004b0:	40800633          	neg	a2,s0
  8004b4:	8a5e                	mv	s4,s7
  8004b6:	46a9                	li	a3,10
  8004b8:	b591                	j	8002fc <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004ba:	e329                	bnez	a4,8004fc <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004bc:	02800793          	li	a5,40
  8004c0:	853e                	mv	a0,a5
  8004c2:	00000d97          	auipc	s11,0x0
  8004c6:	1a7d8d93          	addi	s11,s11,423 # 800669 <main+0x127>
  8004ca:	b5f5                	j	8003b6 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004cc:	85e6                	mv	a1,s9
  8004ce:	856e                	mv	a0,s11
  8004d0:	c8bff0ef          	jal	80015a <strnlen>
  8004d4:	40ad0d3b          	subw	s10,s10,a0
  8004d8:	01a05863          	blez	s10,8004e8 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004dc:	85ca                	mv	a1,s2
  8004de:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004e2:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e4:	fe0d1ce3          	bnez	s10,8004dc <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	000dc783          	lbu	a5,0(s11)
  8004ec:	0007851b          	sext.w	a0,a5
  8004f0:	ec0792e3          	bnez	a5,8003b4 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004f4:	6a22                	ld	s4,8(sp)
  8004f6:	bb29                	j	800210 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004f8:	8462                	mv	s0,s8
  8004fa:	bbd9                	j	8002d0 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fc:	85e6                	mv	a1,s9
  8004fe:	00000517          	auipc	a0,0x0
  800502:	16a50513          	addi	a0,a0,362 # 800668 <main+0x126>
  800506:	c55ff0ef          	jal	80015a <strnlen>
  80050a:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050e:	02800793          	li	a5,40
                p = "(null)";
  800512:	00000d97          	auipc	s11,0x0
  800516:	156d8d93          	addi	s11,s11,342 # 800668 <main+0x126>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051a:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80051c:	fda040e3          	bgtz	s10,8004dc <vprintfmt+0x300>
  800520:	bd51                	j	8003b4 <vprintfmt+0x1d8>

0000000000800522 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800524:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800528:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052c:	ec06                	sd	ra,24(sp)
  80052e:	f83a                	sd	a4,48(sp)
  800530:	fc3e                	sd	a5,56(sp)
  800532:	e0c2                	sd	a6,64(sp)
  800534:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800536:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800538:	ca5ff0ef          	jal	8001dc <vprintfmt>
}
  80053c:	60e2                	ld	ra,24(sp)
  80053e:	6161                	addi	sp,sp,80
  800540:	8082                	ret

0000000000800542 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800542:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  800544:	00000517          	auipc	a0,0x0
  800548:	20450513          	addi	a0,a0,516 # 800748 <main+0x206>
main(void) {
  80054c:	e406                	sd	ra,8(sp)
  80054e:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800550:	bcbff0ef          	jal	80011a <cprintf>
    if ((pid = fork()) == 0) {
  800554:	b81ff0ef          	jal	8000d4 <fork>
  800558:	e901                	bnez	a0,800568 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  80055a:	00000517          	auipc	a0,0x0
  80055e:	21650513          	addi	a0,a0,534 # 800770 <main+0x22e>
  800562:	bb9ff0ef          	jal	80011a <cprintf>
        while (1);
  800566:	a001                	j	800566 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  800568:	842a                	mv	s0,a0
  80056a:	00000517          	auipc	a0,0x0
  80056e:	22650513          	addi	a0,a0,550 # 800790 <main+0x24e>
  800572:	ba9ff0ef          	jal	80011a <cprintf>

    yield();
  800576:	b63ff0ef          	jal	8000d8 <yield>
    yield();
  80057a:	b5fff0ef          	jal	8000d8 <yield>
    yield();
  80057e:	b5bff0ef          	jal	8000d8 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  800582:	00000517          	auipc	a0,0x0
  800586:	23650513          	addi	a0,a0,566 # 8007b8 <main+0x276>
  80058a:	b91ff0ef          	jal	80011a <cprintf>

    assert((ret = kill(pid)) == 0);
  80058e:	8522                	mv	a0,s0
  800590:	b4bff0ef          	jal	8000da <kill>
  800594:	ed31                	bnez	a0,8005f0 <main+0xae>
    cprintf("kill returns %d\n", ret);
  800596:	4581                	li	a1,0
  800598:	00000517          	auipc	a0,0x0
  80059c:	28850513          	addi	a0,a0,648 # 800820 <main+0x2de>
  8005a0:	b7bff0ef          	jal	80011a <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005a4:	8522                	mv	a0,s0
  8005a6:	4581                	li	a1,0
  8005a8:	b2fff0ef          	jal	8000d6 <waitpid>
  8005ac:	e11d                	bnez	a0,8005d2 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005ae:	4581                	li	a1,0
  8005b0:	00000517          	auipc	a0,0x0
  8005b4:	2a850513          	addi	a0,a0,680 # 800858 <main+0x316>
  8005b8:	b63ff0ef          	jal	80011a <cprintf>

    cprintf("spin may pass.\n");
  8005bc:	00000517          	auipc	a0,0x0
  8005c0:	2b450513          	addi	a0,a0,692 # 800870 <main+0x32e>
  8005c4:	b57ff0ef          	jal	80011a <cprintf>
    return 0;
}
  8005c8:	60a2                	ld	ra,8(sp)
  8005ca:	6402                	ld	s0,0(sp)
  8005cc:	4501                	li	a0,0
  8005ce:	0141                	addi	sp,sp,16
  8005d0:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	26668693          	addi	a3,a3,614 # 800838 <main+0x2f6>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	21e60613          	addi	a2,a2,542 # 8007f8 <main+0x2b6>
  8005e2:	45dd                	li	a1,23
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	22c50513          	addi	a0,a0,556 # 800810 <main+0x2ce>
  8005ec:	a35ff0ef          	jal	800020 <__panic>
    assert((ret = kill(pid)) == 0);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	1f068693          	addi	a3,a3,496 # 8007e0 <main+0x29e>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	20060613          	addi	a2,a2,512 # 8007f8 <main+0x2b6>
  800600:	45d1                	li	a1,20
  800602:	00000517          	auipc	a0,0x0
  800606:	20e50513          	addi	a0,a0,526 # 800810 <main+0x2ce>
  80060a:	a17ff0ef          	jal	800020 <__panic>
