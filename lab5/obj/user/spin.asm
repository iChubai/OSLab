
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
  800032:	5e250513          	addi	a0,a0,1506 # 800610 <main+0xcc>
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
  800044:	0d8000ef          	jal	80011c <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b0000ef          	jal	8000fc <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	5e050513          	addi	a0,a0,1504 # 800630 <main+0xec>
  800058:	0c4000ef          	jal	80011c <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	062000ef          	jal	8000c0 <exit>

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
  800084:	6522                	ld	a0,8(sp)
  800086:	75a2                	ld	a1,40(sp)
  800088:	7642                	ld	a2,48(sp)
  80008a:	76e2                	ld	a3,56(sp)
  80008c:	6706                	ld	a4,64(sp)
  80008e:	67a6                	ld	a5,72(sp)
  800090:	00000073          	ecall
  800094:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800098:	4572                	lw	a0,28(sp)
  80009a:	6149                	addi	sp,sp,144
  80009c:	8082                	ret

000000000080009e <sys_exit>:

int
sys_exit(int64_t error_code) {
  80009e:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000a0:	4505                	li	a0,1
  8000a2:	b7c1                	j	800062 <syscall>

00000000008000a4 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000a4:	4509                	li	a0,2
  8000a6:	bf75                	j	800062 <syscall>

00000000008000a8 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  8000a8:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  8000aa:	85aa                	mv	a1,a0
  8000ac:	450d                	li	a0,3
  8000ae:	bf55                	j	800062 <syscall>

00000000008000b0 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b0:	4529                	li	a0,10
  8000b2:	bf45                	j	800062 <syscall>

00000000008000b4 <sys_kill>:
}

int
sys_kill(int64_t pid) {
  8000b4:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  8000b6:	4531                	li	a0,12
  8000b8:	b76d                	j	800062 <syscall>

00000000008000ba <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000ba:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000bc:	4579                	li	a0,30
  8000be:	b755                	j	800062 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fdbff0ef          	jal	80009e <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	57050513          	addi	a0,a0,1392 # 800638 <main+0xf4>
  8000d0:	04c000ef          	jal	80011c <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d6:	b7f9                	j	8000a4 <sys_fork>

00000000008000d8 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d8:	bfc1                	j	8000a8 <sys_wait>

00000000008000da <yield>:
}

void
yield(void) {
    sys_yield();
  8000da:	bfd9                	j	8000b0 <sys_yield>

00000000008000dc <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000dc:	bfe1                	j	8000b4 <sys_kill>

00000000008000de <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000de:	072000ef          	jal	800150 <umain>
1:  j 1b
  8000e2:	a001                	j	8000e2 <_start+0x4>

00000000008000e4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e4:	1101                	addi	sp,sp,-32
  8000e6:	ec06                	sd	ra,24(sp)
  8000e8:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000ea:	fd1ff0ef          	jal	8000ba <sys_putc>
    (*cnt) ++;
  8000ee:	65a2                	ld	a1,8(sp)
}
  8000f0:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000f2:	419c                	lw	a5,0(a1)
  8000f4:	2785                	addiw	a5,a5,1
  8000f6:	c19c                	sw	a5,0(a1)
}
  8000f8:	6105                	addi	sp,sp,32
  8000fa:	8082                	ret

00000000008000fc <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000fc:	1101                	addi	sp,sp,-32
  8000fe:	862a                	mv	a2,a0
  800100:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800102:	00000517          	auipc	a0,0x0
  800106:	fe250513          	addi	a0,a0,-30 # 8000e4 <cputch>
  80010a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  80010c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800110:	0ce000ef          	jal	8001de <vprintfmt>
    return cnt;
}
  800114:	60e2                	ld	ra,24(sp)
  800116:	4532                	lw	a0,12(sp)
  800118:	6105                	addi	sp,sp,32
  80011a:	8082                	ret

000000000080011c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80011c:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011e:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800122:	f42e                	sd	a1,40(sp)
  800124:	f832                	sd	a2,48(sp)
  800126:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800128:	862a                	mv	a2,a0
  80012a:	004c                	addi	a1,sp,4
  80012c:	00000517          	auipc	a0,0x0
  800130:	fb850513          	addi	a0,a0,-72 # 8000e4 <cputch>
  800134:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800136:	ec06                	sd	ra,24(sp)
  800138:	e0ba                	sd	a4,64(sp)
  80013a:	e4be                	sd	a5,72(sp)
  80013c:	e8c2                	sd	a6,80(sp)
  80013e:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800140:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800142:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800144:	09a000ef          	jal	8001de <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800148:	60e2                	ld	ra,24(sp)
  80014a:	4512                	lw	a0,4(sp)
  80014c:	6125                	addi	sp,sp,96
  80014e:	8082                	ret

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	3f0000ef          	jal	800544 <main>
    exit(ret);
  800158:	f69ff0ef          	jal	8000c0 <exit>

000000000080015c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80015c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80015e:	e589                	bnez	a1,800168 <strnlen+0xc>
  800160:	a811                	j	800174 <strnlen+0x18>
        cnt ++;
  800162:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800164:	00f58863          	beq	a1,a5,800174 <strnlen+0x18>
  800168:	00f50733          	add	a4,a0,a5
  80016c:	00074703          	lbu	a4,0(a4)
  800170:	fb6d                	bnez	a4,800162 <strnlen+0x6>
  800172:	85be                	mv	a1,a5
    }
    return cnt;
}
  800174:	852e                	mv	a0,a1
  800176:	8082                	ret

0000000000800178 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800178:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	f022                	sd	s0,32(sp)
  800180:	ec26                	sd	s1,24(sp)
  800182:	e84a                	sd	s2,16(sp)
  800184:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800186:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80018c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800190:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800194:	84aa                	mv	s1,a0
  800196:	892e                	mv	s2,a1
    if (num >= base) {
  800198:	03067d63          	bgeu	a2,a6,8001d2 <printnum+0x5a>
  80019c:	e44e                	sd	s3,8(sp)
  80019e:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a0:	4785                	li	a5,1
  8001a2:	00e7d763          	bge	a5,a4,8001b0 <printnum+0x38>
            putch(padc, putdat);
  8001a6:	85ca                	mv	a1,s2
  8001a8:	854e                	mv	a0,s3
        while (-- width > 0)
  8001aa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001ac:	9482                	jalr	s1
        while (-- width > 0)
  8001ae:	fc65                	bnez	s0,8001a6 <printnum+0x2e>
  8001b0:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	00000797          	auipc	a5,0x0
  8001b6:	49e78793          	addi	a5,a5,1182 # 800650 <main+0x10c>
  8001ba:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001bc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001be:	0007c503          	lbu	a0,0(a5)
}
  8001c2:	70a2                	ld	ra,40(sp)
  8001c4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c6:	85ca                	mv	a1,s2
  8001c8:	87a6                	mv	a5,s1
}
  8001ca:	6942                	ld	s2,16(sp)
  8001cc:	64e2                	ld	s1,24(sp)
  8001ce:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d2:	03065633          	divu	a2,a2,a6
  8001d6:	8722                	mv	a4,s0
  8001d8:	fa1ff0ef          	jal	800178 <printnum>
  8001dc:	bfd9                	j	8001b2 <printnum+0x3a>

00000000008001de <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001de:	7119                	addi	sp,sp,-128
  8001e0:	f4a6                	sd	s1,104(sp)
  8001e2:	f0ca                	sd	s2,96(sp)
  8001e4:	ecce                	sd	s3,88(sp)
  8001e6:	e8d2                	sd	s4,80(sp)
  8001e8:	e4d6                	sd	s5,72(sp)
  8001ea:	e0da                	sd	s6,64(sp)
  8001ec:	f862                	sd	s8,48(sp)
  8001ee:	fc86                	sd	ra,120(sp)
  8001f0:	f8a2                	sd	s0,112(sp)
  8001f2:	fc5e                	sd	s7,56(sp)
  8001f4:	f466                	sd	s9,40(sp)
  8001f6:	f06a                	sd	s10,32(sp)
  8001f8:	ec6e                	sd	s11,24(sp)
  8001fa:	84aa                	mv	s1,a0
  8001fc:	8c32                	mv	s8,a2
  8001fe:	8a36                	mv	s4,a3
  800200:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800206:	05500b13          	li	s6,85
  80020a:	00000a97          	auipc	s5,0x0
  80020e:	676a8a93          	addi	s5,s5,1654 # 800880 <main+0x33c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	000c4503          	lbu	a0,0(s8)
  800216:	001c0413          	addi	s0,s8,1
  80021a:	01350a63          	beq	a0,s3,80022e <vprintfmt+0x50>
            if (ch == '\0') {
  80021e:	cd0d                	beqz	a0,800258 <vprintfmt+0x7a>
            putch(ch, putdat);
  800220:	85ca                	mv	a1,s2
  800222:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	00044503          	lbu	a0,0(s0)
  800228:	0405                	addi	s0,s0,1
  80022a:	ff351ae3          	bne	a0,s3,80021e <vprintfmt+0x40>
        width = precision = -1;
  80022e:	5cfd                	li	s9,-1
  800230:	8d66                	mv	s10,s9
        char padc = ' ';
  800232:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800236:	4b81                	li	s7,0
  800238:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80023a:	00044683          	lbu	a3,0(s0)
  80023e:	00140c13          	addi	s8,s0,1
  800242:	fdd6859b          	addiw	a1,a3,-35
  800246:	0ff5f593          	zext.b	a1,a1
  80024a:	02bb6663          	bltu	s6,a1,800276 <vprintfmt+0x98>
  80024e:	058a                	slli	a1,a1,0x2
  800250:	95d6                	add	a1,a1,s5
  800252:	4198                	lw	a4,0(a1)
  800254:	9756                	add	a4,a4,s5
  800256:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800258:	70e6                	ld	ra,120(sp)
  80025a:	7446                	ld	s0,112(sp)
  80025c:	74a6                	ld	s1,104(sp)
  80025e:	7906                	ld	s2,96(sp)
  800260:	69e6                	ld	s3,88(sp)
  800262:	6a46                	ld	s4,80(sp)
  800264:	6aa6                	ld	s5,72(sp)
  800266:	6b06                	ld	s6,64(sp)
  800268:	7be2                	ld	s7,56(sp)
  80026a:	7c42                	ld	s8,48(sp)
  80026c:	7ca2                	ld	s9,40(sp)
  80026e:	7d02                	ld	s10,32(sp)
  800270:	6de2                	ld	s11,24(sp)
  800272:	6109                	addi	sp,sp,128
  800274:	8082                	ret
            putch('%', putdat);
  800276:	85ca                	mv	a1,s2
  800278:	02500513          	li	a0,37
  80027c:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80027e:	fff44783          	lbu	a5,-1(s0)
  800282:	02500713          	li	a4,37
  800286:	8c22                	mv	s8,s0
  800288:	f8e785e3          	beq	a5,a4,800212 <vprintfmt+0x34>
  80028c:	ffec4783          	lbu	a5,-2(s8)
  800290:	1c7d                	addi	s8,s8,-1
  800292:	fee79de3          	bne	a5,a4,80028c <vprintfmt+0xae>
  800296:	bfb5                	j	800212 <vprintfmt+0x34>
                ch = *fmt;
  800298:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80029c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80029e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002a2:	fd06071b          	addiw	a4,a2,-48
  8002a6:	24e56a63          	bltu	a0,a4,8004fa <vprintfmt+0x31c>
                ch = *fmt;
  8002aa:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002ac:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002ae:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002b2:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002b6:	0197073b          	addw	a4,a4,s9
  8002ba:	0017171b          	slliw	a4,a4,0x1
  8002be:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002c0:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002c4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002c6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ca:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002ce:	feb570e3          	bgeu	a0,a1,8002ae <vprintfmt+0xd0>
            if (width < 0)
  8002d2:	f60d54e3          	bgez	s10,80023a <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002d6:	8d66                	mv	s10,s9
  8002d8:	5cfd                	li	s9,-1
  8002da:	b785                	j	80023a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002dc:	8db6                	mv	s11,a3
  8002de:	8462                	mv	s0,s8
  8002e0:	bfa9                	j	80023a <vprintfmt+0x5c>
  8002e2:	8462                	mv	s0,s8
            altflag = 1;
  8002e4:	4b85                	li	s7,1
            goto reswitch;
  8002e6:	bf91                	j	80023a <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002e8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ea:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ee:	00f74463          	blt	a4,a5,8002f6 <vprintfmt+0x118>
    else if (lflag) {
  8002f2:	1a078763          	beqz	a5,8004a0 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002f6:	000a3603          	ld	a2,0(s4)
  8002fa:	46c1                	li	a3,16
  8002fc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002fe:	000d879b          	sext.w	a5,s11
  800302:	876a                	mv	a4,s10
  800304:	85ca                	mv	a1,s2
  800306:	8526                	mv	a0,s1
  800308:	e71ff0ef          	jal	800178 <printnum>
            break;
  80030c:	b719                	j	800212 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80030e:	000a2503          	lw	a0,0(s4)
  800312:	85ca                	mv	a1,s2
  800314:	0a21                	addi	s4,s4,8
  800316:	9482                	jalr	s1
            break;
  800318:	bded                	j	800212 <vprintfmt+0x34>
    if (lflag >= 2) {
  80031a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800320:	00f74463          	blt	a4,a5,800328 <vprintfmt+0x14a>
    else if (lflag) {
  800324:	16078963          	beqz	a5,800496 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800328:	000a3603          	ld	a2,0(s4)
  80032c:	46a9                	li	a3,10
  80032e:	8a2e                	mv	s4,a1
  800330:	b7f9                	j	8002fe <vprintfmt+0x120>
            putch('0', putdat);
  800332:	85ca                	mv	a1,s2
  800334:	03000513          	li	a0,48
  800338:	9482                	jalr	s1
            putch('x', putdat);
  80033a:	85ca                	mv	a1,s2
  80033c:	07800513          	li	a0,120
  800340:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800342:	000a3603          	ld	a2,0(s4)
            goto number;
  800346:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800348:	0a21                	addi	s4,s4,8
            goto number;
  80034a:	bf55                	j	8002fe <vprintfmt+0x120>
            putch(ch, putdat);
  80034c:	85ca                	mv	a1,s2
  80034e:	02500513          	li	a0,37
  800352:	9482                	jalr	s1
            break;
  800354:	bd7d                	j	800212 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800356:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80035a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80035c:	0a21                	addi	s4,s4,8
            goto process_precision;
  80035e:	bf95                	j	8002d2 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800360:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800362:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800366:	00f74463          	blt	a4,a5,80036e <vprintfmt+0x190>
    else if (lflag) {
  80036a:	12078163          	beqz	a5,80048c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80036e:	000a3603          	ld	a2,0(s4)
  800372:	46a1                	li	a3,8
  800374:	8a2e                	mv	s4,a1
  800376:	b761                	j	8002fe <vprintfmt+0x120>
            if (width < 0)
  800378:	876a                	mv	a4,s10
  80037a:	000d5363          	bgez	s10,800380 <vprintfmt+0x1a2>
  80037e:	4701                	li	a4,0
  800380:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800384:	8462                	mv	s0,s8
            goto reswitch;
  800386:	bd55                	j	80023a <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800388:	000d841b          	sext.w	s0,s11
  80038c:	fd340793          	addi	a5,s0,-45
  800390:	00f037b3          	snez	a5,a5
  800394:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800398:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80039c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80039e:	008a0793          	addi	a5,s4,8
  8003a2:	e43e                	sd	a5,8(sp)
  8003a4:	100d8c63          	beqz	s11,8004bc <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003a8:	12071363          	bnez	a4,8004ce <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ac:	000dc783          	lbu	a5,0(s11)
  8003b0:	0007851b          	sext.w	a0,a5
  8003b4:	c78d                	beqz	a5,8003de <vprintfmt+0x200>
  8003b6:	0d85                	addi	s11,s11,1
  8003b8:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ba:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003be:	000cc563          	bltz	s9,8003c8 <vprintfmt+0x1ea>
  8003c2:	3cfd                	addiw	s9,s9,-1
  8003c4:	008c8d63          	beq	s9,s0,8003de <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c8:	020b9663          	bnez	s7,8003f4 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003cc:	85ca                	mv	a1,s2
  8003ce:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d0:	000dc783          	lbu	a5,0(s11)
  8003d4:	0d85                	addi	s11,s11,1
  8003d6:	3d7d                	addiw	s10,s10,-1
  8003d8:	0007851b          	sext.w	a0,a5
  8003dc:	f3ed                	bnez	a5,8003be <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003de:	01a05963          	blez	s10,8003f0 <vprintfmt+0x212>
                putch(' ', putdat);
  8003e2:	85ca                	mv	a1,s2
  8003e4:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003e8:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ea:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003ec:	fe0d1be3          	bnez	s10,8003e2 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003f0:	6a22                	ld	s4,8(sp)
  8003f2:	b505                	j	800212 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f4:	3781                	addiw	a5,a5,-32
  8003f6:	fcfa7be3          	bgeu	s4,a5,8003cc <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003fa:	03f00513          	li	a0,63
  8003fe:	85ca                	mv	a1,s2
  800400:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800402:	000dc783          	lbu	a5,0(s11)
  800406:	0d85                	addi	s11,s11,1
  800408:	3d7d                	addiw	s10,s10,-1
  80040a:	0007851b          	sext.w	a0,a5
  80040e:	dbe1                	beqz	a5,8003de <vprintfmt+0x200>
  800410:	fa0cd9e3          	bgez	s9,8003c2 <vprintfmt+0x1e4>
  800414:	b7c5                	j	8003f4 <vprintfmt+0x216>
            if (err < 0) {
  800416:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80041a:	4661                	li	a2,24
            err = va_arg(ap, int);
  80041c:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80041e:	41f7d71b          	sraiw	a4,a5,0x1f
  800422:	8fb9                	xor	a5,a5,a4
  800424:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800428:	02d64563          	blt	a2,a3,800452 <vprintfmt+0x274>
  80042c:	00000797          	auipc	a5,0x0
  800430:	5ac78793          	addi	a5,a5,1452 # 8009d8 <error_string>
  800434:	00369713          	slli	a4,a3,0x3
  800438:	97ba                	add	a5,a5,a4
  80043a:	639c                	ld	a5,0(a5)
  80043c:	cb99                	beqz	a5,800452 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80043e:	86be                	mv	a3,a5
  800440:	00000617          	auipc	a2,0x0
  800444:	24060613          	addi	a2,a2,576 # 800680 <main+0x13c>
  800448:	85ca                	mv	a1,s2
  80044a:	8526                	mv	a0,s1
  80044c:	0d8000ef          	jal	800524 <printfmt>
  800450:	b3c9                	j	800212 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800452:	00000617          	auipc	a2,0x0
  800456:	21e60613          	addi	a2,a2,542 # 800670 <main+0x12c>
  80045a:	85ca                	mv	a1,s2
  80045c:	8526                	mv	a0,s1
  80045e:	0c6000ef          	jal	800524 <printfmt>
  800462:	bb45                	j	800212 <vprintfmt+0x34>
    if (lflag >= 2) {
  800464:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800466:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80046a:	00f74363          	blt	a4,a5,800470 <vprintfmt+0x292>
    else if (lflag) {
  80046e:	cf81                	beqz	a5,800486 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800470:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800474:	02044b63          	bltz	s0,8004aa <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800478:	8622                	mv	a2,s0
  80047a:	8a5e                	mv	s4,s7
  80047c:	46a9                	li	a3,10
  80047e:	b541                	j	8002fe <vprintfmt+0x120>
            lflag ++;
  800480:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800482:	8462                	mv	s0,s8
            goto reswitch;
  800484:	bb5d                	j	80023a <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800486:	000a2403          	lw	s0,0(s4)
  80048a:	b7ed                	j	800474 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80048c:	000a6603          	lwu	a2,0(s4)
  800490:	46a1                	li	a3,8
  800492:	8a2e                	mv	s4,a1
  800494:	b5ad                	j	8002fe <vprintfmt+0x120>
  800496:	000a6603          	lwu	a2,0(s4)
  80049a:	46a9                	li	a3,10
  80049c:	8a2e                	mv	s4,a1
  80049e:	b585                	j	8002fe <vprintfmt+0x120>
  8004a0:	000a6603          	lwu	a2,0(s4)
  8004a4:	46c1                	li	a3,16
  8004a6:	8a2e                	mv	s4,a1
  8004a8:	bd99                	j	8002fe <vprintfmt+0x120>
                putch('-', putdat);
  8004aa:	85ca                	mv	a1,s2
  8004ac:	02d00513          	li	a0,45
  8004b0:	9482                	jalr	s1
                num = -(long long)num;
  8004b2:	40800633          	neg	a2,s0
  8004b6:	8a5e                	mv	s4,s7
  8004b8:	46a9                	li	a3,10
  8004ba:	b591                	j	8002fe <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004bc:	e329                	bnez	a4,8004fe <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004be:	02800793          	li	a5,40
  8004c2:	853e                	mv	a0,a5
  8004c4:	00000d97          	auipc	s11,0x0
  8004c8:	1a5d8d93          	addi	s11,s11,421 # 800669 <main+0x125>
  8004cc:	b5f5                	j	8003b8 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ce:	85e6                	mv	a1,s9
  8004d0:	856e                	mv	a0,s11
  8004d2:	c8bff0ef          	jal	80015c <strnlen>
  8004d6:	40ad0d3b          	subw	s10,s10,a0
  8004da:	01a05863          	blez	s10,8004ea <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004de:	85ca                	mv	a1,s2
  8004e0:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004e4:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e6:	fe0d1ce3          	bnez	s10,8004de <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ea:	000dc783          	lbu	a5,0(s11)
  8004ee:	0007851b          	sext.w	a0,a5
  8004f2:	ec0792e3          	bnez	a5,8003b6 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004f6:	6a22                	ld	s4,8(sp)
  8004f8:	bb29                	j	800212 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004fa:	8462                	mv	s0,s8
  8004fc:	bbd9                	j	8002d2 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fe:	85e6                	mv	a1,s9
  800500:	00000517          	auipc	a0,0x0
  800504:	16850513          	addi	a0,a0,360 # 800668 <main+0x124>
  800508:	c55ff0ef          	jal	80015c <strnlen>
  80050c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800510:	02800793          	li	a5,40
                p = "(null)";
  800514:	00000d97          	auipc	s11,0x0
  800518:	154d8d93          	addi	s11,s11,340 # 800668 <main+0x124>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80051e:	fda040e3          	bgtz	s10,8004de <vprintfmt+0x300>
  800522:	bd51                	j	8003b6 <vprintfmt+0x1d8>

0000000000800524 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800524:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800526:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052e:	ec06                	sd	ra,24(sp)
  800530:	f83a                	sd	a4,48(sp)
  800532:	fc3e                	sd	a5,56(sp)
  800534:	e0c2                	sd	a6,64(sp)
  800536:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800538:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053a:	ca5ff0ef          	jal	8001de <vprintfmt>
}
  80053e:	60e2                	ld	ra,24(sp)
  800540:	6161                	addi	sp,sp,80
  800542:	8082                	ret

0000000000800544 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800544:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  800546:	00000517          	auipc	a0,0x0
  80054a:	20250513          	addi	a0,a0,514 # 800748 <main+0x204>
main(void) {
  80054e:	e406                	sd	ra,8(sp)
  800550:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800552:	bcbff0ef          	jal	80011c <cprintf>
    if ((pid = fork()) == 0) {
  800556:	b81ff0ef          	jal	8000d6 <fork>
  80055a:	e901                	bnez	a0,80056a <main+0x26>
        cprintf("I am the child. spinning ...\n");
  80055c:	00000517          	auipc	a0,0x0
  800560:	21450513          	addi	a0,a0,532 # 800770 <main+0x22c>
  800564:	bb9ff0ef          	jal	80011c <cprintf>
        while (1);
  800568:	a001                	j	800568 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  80056a:	842a                	mv	s0,a0
  80056c:	00000517          	auipc	a0,0x0
  800570:	22450513          	addi	a0,a0,548 # 800790 <main+0x24c>
  800574:	ba9ff0ef          	jal	80011c <cprintf>

    yield();
  800578:	b63ff0ef          	jal	8000da <yield>
    yield();
  80057c:	b5fff0ef          	jal	8000da <yield>
    yield();
  800580:	b5bff0ef          	jal	8000da <yield>

    cprintf("I am the parent.  Killing the child...\n");
  800584:	00000517          	auipc	a0,0x0
  800588:	23450513          	addi	a0,a0,564 # 8007b8 <main+0x274>
  80058c:	b91ff0ef          	jal	80011c <cprintf>

    assert((ret = kill(pid)) == 0);
  800590:	8522                	mv	a0,s0
  800592:	b4bff0ef          	jal	8000dc <kill>
  800596:	ed31                	bnez	a0,8005f2 <main+0xae>
    cprintf("kill returns %d\n", ret);
  800598:	4581                	li	a1,0
  80059a:	00000517          	auipc	a0,0x0
  80059e:	28650513          	addi	a0,a0,646 # 800820 <main+0x2dc>
  8005a2:	b7bff0ef          	jal	80011c <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005a6:	8522                	mv	a0,s0
  8005a8:	4581                	li	a1,0
  8005aa:	b2fff0ef          	jal	8000d8 <waitpid>
  8005ae:	e11d                	bnez	a0,8005d4 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005b0:	4581                	li	a1,0
  8005b2:	00000517          	auipc	a0,0x0
  8005b6:	2a650513          	addi	a0,a0,678 # 800858 <main+0x314>
  8005ba:	b63ff0ef          	jal	80011c <cprintf>

    cprintf("spin may pass.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	2b250513          	addi	a0,a0,690 # 800870 <main+0x32c>
  8005c6:	b57ff0ef          	jal	80011c <cprintf>
    return 0;
}
  8005ca:	60a2                	ld	ra,8(sp)
  8005cc:	6402                	ld	s0,0(sp)
  8005ce:	4501                	li	a0,0
  8005d0:	0141                	addi	sp,sp,16
  8005d2:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	26468693          	addi	a3,a3,612 # 800838 <main+0x2f4>
  8005dc:	00000617          	auipc	a2,0x0
  8005e0:	21c60613          	addi	a2,a2,540 # 8007f8 <main+0x2b4>
  8005e4:	45dd                	li	a1,23
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	22a50513          	addi	a0,a0,554 # 800810 <main+0x2cc>
  8005ee:	a33ff0ef          	jal	800020 <__panic>
    assert((ret = kill(pid)) == 0);
  8005f2:	00000697          	auipc	a3,0x0
  8005f6:	1ee68693          	addi	a3,a3,494 # 8007e0 <main+0x29c>
  8005fa:	00000617          	auipc	a2,0x0
  8005fe:	1fe60613          	addi	a2,a2,510 # 8007f8 <main+0x2b4>
  800602:	45d1                	li	a1,20
  800604:	00000517          	auipc	a0,0x0
  800608:	20c50513          	addi	a0,a0,524 # 800810 <main+0x2cc>
  80060c:	a15ff0ef          	jal	800020 <__panic>
