
obj/__user_waitkill.out:     file format elf64-littleriscv


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
  800032:	66250513          	addi	a0,a0,1634 # 800690 <main+0xbe>
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
  800044:	0de000ef          	jal	800122 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b6000ef          	jal	800102 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	77850513          	addi	a0,a0,1912 # 8007c8 <main+0x1f6>
  800058:	0ca000ef          	jal	800122 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	066000ef          	jal	8000c4 <exit>

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

00000000008000ba <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000ba:	4549                	li	a0,18
  8000bc:	b75d                	j	800062 <syscall>

00000000008000be <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000be:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c0:	4579                	li	a0,30
  8000c2:	b745                	j	800062 <syscall>

00000000008000c4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c4:	1141                	addi	sp,sp,-16
  8000c6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c8:	fd7ff0ef          	jal	80009e <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000cc:	00000517          	auipc	a0,0x0
  8000d0:	5e450513          	addi	a0,a0,1508 # 8006b0 <main+0xde>
  8000d4:	04e000ef          	jal	800122 <cprintf>
    while (1);
  8000d8:	a001                	j	8000d8 <exit+0x14>

00000000008000da <fork>:
}

int
fork(void) {
    return sys_fork();
  8000da:	b7e9                	j	8000a4 <sys_fork>

00000000008000dc <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000dc:	b7f1                	j	8000a8 <sys_wait>

00000000008000de <yield>:
}

void
yield(void) {
    sys_yield();
  8000de:	bfc9                	j	8000b0 <sys_yield>

00000000008000e0 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000e0:	bfd1                	j	8000b4 <sys_kill>

00000000008000e2 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000e2:	bfe1                	j	8000ba <sys_getpid>

00000000008000e4 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000e4:	072000ef          	jal	800156 <umain>
1:  j 1b
  8000e8:	a001                	j	8000e8 <_start+0x4>

00000000008000ea <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000ea:	1101                	addi	sp,sp,-32
  8000ec:	ec06                	sd	ra,24(sp)
  8000ee:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000f0:	fcfff0ef          	jal	8000be <sys_putc>
    (*cnt) ++;
  8000f4:	65a2                	ld	a1,8(sp)
}
  8000f6:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000f8:	419c                	lw	a5,0(a1)
  8000fa:	2785                	addiw	a5,a5,1
  8000fc:	c19c                	sw	a5,0(a1)
}
  8000fe:	6105                	addi	sp,sp,32
  800100:	8082                	ret

0000000000800102 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800102:	1101                	addi	sp,sp,-32
  800104:	862a                	mv	a2,a0
  800106:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800108:	00000517          	auipc	a0,0x0
  80010c:	fe250513          	addi	a0,a0,-30 # 8000ea <cputch>
  800110:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800112:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800114:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800116:	0ce000ef          	jal	8001e4 <vprintfmt>
    return cnt;
}
  80011a:	60e2                	ld	ra,24(sp)
  80011c:	4532                	lw	a0,12(sp)
  80011e:	6105                	addi	sp,sp,32
  800120:	8082                	ret

0000000000800122 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800122:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800124:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800128:	f42e                	sd	a1,40(sp)
  80012a:	f832                	sd	a2,48(sp)
  80012c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012e:	862a                	mv	a2,a0
  800130:	004c                	addi	a1,sp,4
  800132:	00000517          	auipc	a0,0x0
  800136:	fb850513          	addi	a0,a0,-72 # 8000ea <cputch>
  80013a:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80013c:	ec06                	sd	ra,24(sp)
  80013e:	e0ba                	sd	a4,64(sp)
  800140:	e4be                	sd	a5,72(sp)
  800142:	e8c2                	sd	a6,80(sp)
  800144:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800146:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800148:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80014a:	09a000ef          	jal	8001e4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014e:	60e2                	ld	ra,24(sp)
  800150:	4512                	lw	a0,4(sp)
  800152:	6125                	addi	sp,sp,96
  800154:	8082                	ret

0000000000800156 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800156:	1141                	addi	sp,sp,-16
  800158:	e406                	sd	ra,8(sp)
    int ret = main();
  80015a:	478000ef          	jal	8005d2 <main>
    exit(ret);
  80015e:	f67ff0ef          	jal	8000c4 <exit>

0000000000800162 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800162:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800164:	e589                	bnez	a1,80016e <strnlen+0xc>
  800166:	a811                	j	80017a <strnlen+0x18>
        cnt ++;
  800168:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80016a:	00f58863          	beq	a1,a5,80017a <strnlen+0x18>
  80016e:	00f50733          	add	a4,a0,a5
  800172:	00074703          	lbu	a4,0(a4)
  800176:	fb6d                	bnez	a4,800168 <strnlen+0x6>
  800178:	85be                	mv	a1,a5
    }
    return cnt;
}
  80017a:	852e                	mv	a0,a1
  80017c:	8082                	ret

000000000080017e <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800180:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800184:	f022                	sd	s0,32(sp)
  800186:	ec26                	sd	s1,24(sp)
  800188:	e84a                	sd	s2,16(sp)
  80018a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800190:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800192:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800196:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80019a:	84aa                	mv	s1,a0
  80019c:	892e                	mv	s2,a1
    if (num >= base) {
  80019e:	03067d63          	bgeu	a2,a6,8001d8 <printnum+0x5a>
  8001a2:	e44e                	sd	s3,8(sp)
  8001a4:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a6:	4785                	li	a5,1
  8001a8:	00e7d763          	bge	a5,a4,8001b6 <printnum+0x38>
            putch(padc, putdat);
  8001ac:	85ca                	mv	a1,s2
  8001ae:	854e                	mv	a0,s3
        while (-- width > 0)
  8001b0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b2:	9482                	jalr	s1
        while (-- width > 0)
  8001b4:	fc65                	bnez	s0,8001ac <printnum+0x2e>
  8001b6:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	00000797          	auipc	a5,0x0
  8001bc:	51078793          	addi	a5,a5,1296 # 8006c8 <main+0xf6>
  8001c0:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	0007c503          	lbu	a0,0(a5)
}
  8001c8:	70a2                	ld	ra,40(sp)
  8001ca:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	85ca                	mv	a1,s2
  8001ce:	87a6                	mv	a5,s1
}
  8001d0:	6942                	ld	s2,16(sp)
  8001d2:	64e2                	ld	s1,24(sp)
  8001d4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d8:	03065633          	divu	a2,a2,a6
  8001dc:	8722                	mv	a4,s0
  8001de:	fa1ff0ef          	jal	80017e <printnum>
  8001e2:	bfd9                	j	8001b8 <printnum+0x3a>

00000000008001e4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e4:	7119                	addi	sp,sp,-128
  8001e6:	f4a6                	sd	s1,104(sp)
  8001e8:	f0ca                	sd	s2,96(sp)
  8001ea:	ecce                	sd	s3,88(sp)
  8001ec:	e8d2                	sd	s4,80(sp)
  8001ee:	e4d6                	sd	s5,72(sp)
  8001f0:	e0da                	sd	s6,64(sp)
  8001f2:	f862                	sd	s8,48(sp)
  8001f4:	fc86                	sd	ra,120(sp)
  8001f6:	f8a2                	sd	s0,112(sp)
  8001f8:	fc5e                	sd	s7,56(sp)
  8001fa:	f466                	sd	s9,40(sp)
  8001fc:	f06a                	sd	s10,32(sp)
  8001fe:	ec6e                	sd	s11,24(sp)
  800200:	84aa                	mv	s1,a0
  800202:	8c32                	mv	s8,a2
  800204:	8a36                	mv	s4,a3
  800206:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80020c:	05500b13          	li	s6,85
  800210:	00000a97          	auipc	s5,0x0
  800214:	66ca8a93          	addi	s5,s5,1644 # 80087c <main+0x2aa>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	000c4503          	lbu	a0,0(s8)
  80021c:	001c0413          	addi	s0,s8,1
  800220:	01350a63          	beq	a0,s3,800234 <vprintfmt+0x50>
            if (ch == '\0') {
  800224:	cd0d                	beqz	a0,80025e <vprintfmt+0x7a>
            putch(ch, putdat);
  800226:	85ca                	mv	a1,s2
  800228:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022a:	00044503          	lbu	a0,0(s0)
  80022e:	0405                	addi	s0,s0,1
  800230:	ff351ae3          	bne	a0,s3,800224 <vprintfmt+0x40>
        width = precision = -1;
  800234:	5cfd                	li	s9,-1
  800236:	8d66                	mv	s10,s9
        char padc = ' ';
  800238:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80023c:	4b81                	li	s7,0
  80023e:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	00044683          	lbu	a3,0(s0)
  800244:	00140c13          	addi	s8,s0,1
  800248:	fdd6859b          	addiw	a1,a3,-35
  80024c:	0ff5f593          	zext.b	a1,a1
  800250:	02bb6663          	bltu	s6,a1,80027c <vprintfmt+0x98>
  800254:	058a                	slli	a1,a1,0x2
  800256:	95d6                	add	a1,a1,s5
  800258:	4198                	lw	a4,0(a1)
  80025a:	9756                	add	a4,a4,s5
  80025c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80025e:	70e6                	ld	ra,120(sp)
  800260:	7446                	ld	s0,112(sp)
  800262:	74a6                	ld	s1,104(sp)
  800264:	7906                	ld	s2,96(sp)
  800266:	69e6                	ld	s3,88(sp)
  800268:	6a46                	ld	s4,80(sp)
  80026a:	6aa6                	ld	s5,72(sp)
  80026c:	6b06                	ld	s6,64(sp)
  80026e:	7be2                	ld	s7,56(sp)
  800270:	7c42                	ld	s8,48(sp)
  800272:	7ca2                	ld	s9,40(sp)
  800274:	7d02                	ld	s10,32(sp)
  800276:	6de2                	ld	s11,24(sp)
  800278:	6109                	addi	sp,sp,128
  80027a:	8082                	ret
            putch('%', putdat);
  80027c:	85ca                	mv	a1,s2
  80027e:	02500513          	li	a0,37
  800282:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800284:	fff44783          	lbu	a5,-1(s0)
  800288:	02500713          	li	a4,37
  80028c:	8c22                	mv	s8,s0
  80028e:	f8e785e3          	beq	a5,a4,800218 <vprintfmt+0x34>
  800292:	ffec4783          	lbu	a5,-2(s8)
  800296:	1c7d                	addi	s8,s8,-1
  800298:	fee79de3          	bne	a5,a4,800292 <vprintfmt+0xae>
  80029c:	bfb5                	j	800218 <vprintfmt+0x34>
                ch = *fmt;
  80029e:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  8002a2:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  8002a4:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002a8:	fd06071b          	addiw	a4,a2,-48
  8002ac:	24e56a63          	bltu	a0,a4,800500 <vprintfmt+0x31c>
                ch = *fmt;
  8002b0:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002b2:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002b4:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002b8:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002bc:	0197073b          	addw	a4,a4,s9
  8002c0:	0017171b          	slliw	a4,a4,0x1
  8002c4:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002c6:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002ca:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002cc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002d0:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002d4:	feb570e3          	bgeu	a0,a1,8002b4 <vprintfmt+0xd0>
            if (width < 0)
  8002d8:	f60d54e3          	bgez	s10,800240 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002dc:	8d66                	mv	s10,s9
  8002de:	5cfd                	li	s9,-1
  8002e0:	b785                	j	800240 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002e2:	8db6                	mv	s11,a3
  8002e4:	8462                	mv	s0,s8
  8002e6:	bfa9                	j	800240 <vprintfmt+0x5c>
  8002e8:	8462                	mv	s0,s8
            altflag = 1;
  8002ea:	4b85                	li	s7,1
            goto reswitch;
  8002ec:	bf91                	j	800240 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f4:	00f74463          	blt	a4,a5,8002fc <vprintfmt+0x118>
    else if (lflag) {
  8002f8:	1a078763          	beqz	a5,8004a6 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002fc:	000a3603          	ld	a2,0(s4)
  800300:	46c1                	li	a3,16
  800302:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800304:	000d879b          	sext.w	a5,s11
  800308:	876a                	mv	a4,s10
  80030a:	85ca                	mv	a1,s2
  80030c:	8526                	mv	a0,s1
  80030e:	e71ff0ef          	jal	80017e <printnum>
            break;
  800312:	b719                	j	800218 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800314:	000a2503          	lw	a0,0(s4)
  800318:	85ca                	mv	a1,s2
  80031a:	0a21                	addi	s4,s4,8
  80031c:	9482                	jalr	s1
            break;
  80031e:	bded                	j	800218 <vprintfmt+0x34>
    if (lflag >= 2) {
  800320:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800322:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800326:	00f74463          	blt	a4,a5,80032e <vprintfmt+0x14a>
    else if (lflag) {
  80032a:	16078963          	beqz	a5,80049c <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80032e:	000a3603          	ld	a2,0(s4)
  800332:	46a9                	li	a3,10
  800334:	8a2e                	mv	s4,a1
  800336:	b7f9                	j	800304 <vprintfmt+0x120>
            putch('0', putdat);
  800338:	85ca                	mv	a1,s2
  80033a:	03000513          	li	a0,48
  80033e:	9482                	jalr	s1
            putch('x', putdat);
  800340:	85ca                	mv	a1,s2
  800342:	07800513          	li	a0,120
  800346:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800348:	000a3603          	ld	a2,0(s4)
            goto number;
  80034c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034e:	0a21                	addi	s4,s4,8
            goto number;
  800350:	bf55                	j	800304 <vprintfmt+0x120>
            putch(ch, putdat);
  800352:	85ca                	mv	a1,s2
  800354:	02500513          	li	a0,37
  800358:	9482                	jalr	s1
            break;
  80035a:	bd7d                	j	800218 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80035c:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800360:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800362:	0a21                	addi	s4,s4,8
            goto process_precision;
  800364:	bf95                	j	8002d8 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800366:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800368:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80036c:	00f74463          	blt	a4,a5,800374 <vprintfmt+0x190>
    else if (lflag) {
  800370:	12078163          	beqz	a5,800492 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800374:	000a3603          	ld	a2,0(s4)
  800378:	46a1                	li	a3,8
  80037a:	8a2e                	mv	s4,a1
  80037c:	b761                	j	800304 <vprintfmt+0x120>
            if (width < 0)
  80037e:	876a                	mv	a4,s10
  800380:	000d5363          	bgez	s10,800386 <vprintfmt+0x1a2>
  800384:	4701                	li	a4,0
  800386:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80038a:	8462                	mv	s0,s8
            goto reswitch;
  80038c:	bd55                	j	800240 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80038e:	000d841b          	sext.w	s0,s11
  800392:	fd340793          	addi	a5,s0,-45
  800396:	00f037b3          	snez	a5,a5
  80039a:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80039e:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  8003a2:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a4:	008a0793          	addi	a5,s4,8
  8003a8:	e43e                	sd	a5,8(sp)
  8003aa:	100d8c63          	beqz	s11,8004c2 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003ae:	12071363          	bnez	a4,8004d4 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b2:	000dc783          	lbu	a5,0(s11)
  8003b6:	0007851b          	sext.w	a0,a5
  8003ba:	c78d                	beqz	a5,8003e4 <vprintfmt+0x200>
  8003bc:	0d85                	addi	s11,s11,1
  8003be:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c0:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c4:	000cc563          	bltz	s9,8003ce <vprintfmt+0x1ea>
  8003c8:	3cfd                	addiw	s9,s9,-1
  8003ca:	008c8d63          	beq	s9,s0,8003e4 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ce:	020b9663          	bnez	s7,8003fa <vprintfmt+0x216>
                    putch(ch, putdat);
  8003d2:	85ca                	mv	a1,s2
  8003d4:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d6:	000dc783          	lbu	a5,0(s11)
  8003da:	0d85                	addi	s11,s11,1
  8003dc:	3d7d                	addiw	s10,s10,-1
  8003de:	0007851b          	sext.w	a0,a5
  8003e2:	f3ed                	bnez	a5,8003c4 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003e4:	01a05963          	blez	s10,8003f6 <vprintfmt+0x212>
                putch(' ', putdat);
  8003e8:	85ca                	mv	a1,s2
  8003ea:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ee:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003f0:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003f2:	fe0d1be3          	bnez	s10,8003e8 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003f6:	6a22                	ld	s4,8(sp)
  8003f8:	b505                	j	800218 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003fa:	3781                	addiw	a5,a5,-32
  8003fc:	fcfa7be3          	bgeu	s4,a5,8003d2 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800400:	03f00513          	li	a0,63
  800404:	85ca                	mv	a1,s2
  800406:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800408:	000dc783          	lbu	a5,0(s11)
  80040c:	0d85                	addi	s11,s11,1
  80040e:	3d7d                	addiw	s10,s10,-1
  800410:	0007851b          	sext.w	a0,a5
  800414:	dbe1                	beqz	a5,8003e4 <vprintfmt+0x200>
  800416:	fa0cd9e3          	bgez	s9,8003c8 <vprintfmt+0x1e4>
  80041a:	b7c5                	j	8003fa <vprintfmt+0x216>
            if (err < 0) {
  80041c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800420:	4661                	li	a2,24
            err = va_arg(ap, int);
  800422:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800424:	41f7d71b          	sraiw	a4,a5,0x1f
  800428:	8fb9                	xor	a5,a5,a4
  80042a:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80042e:	02d64563          	blt	a2,a3,800458 <vprintfmt+0x274>
  800432:	00000797          	auipc	a5,0x0
  800436:	5a678793          	addi	a5,a5,1446 # 8009d8 <error_string>
  80043a:	00369713          	slli	a4,a3,0x3
  80043e:	97ba                	add	a5,a5,a4
  800440:	639c                	ld	a5,0(a5)
  800442:	cb99                	beqz	a5,800458 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800444:	86be                	mv	a3,a5
  800446:	00000617          	auipc	a2,0x0
  80044a:	2b260613          	addi	a2,a2,690 # 8006f8 <main+0x126>
  80044e:	85ca                	mv	a1,s2
  800450:	8526                	mv	a0,s1
  800452:	0d8000ef          	jal	80052a <printfmt>
  800456:	b3c9                	j	800218 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800458:	00000617          	auipc	a2,0x0
  80045c:	29060613          	addi	a2,a2,656 # 8006e8 <main+0x116>
  800460:	85ca                	mv	a1,s2
  800462:	8526                	mv	a0,s1
  800464:	0c6000ef          	jal	80052a <printfmt>
  800468:	bb45                	j	800218 <vprintfmt+0x34>
    if (lflag >= 2) {
  80046a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80046c:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800470:	00f74363          	blt	a4,a5,800476 <vprintfmt+0x292>
    else if (lflag) {
  800474:	cf81                	beqz	a5,80048c <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800476:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80047a:	02044b63          	bltz	s0,8004b0 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80047e:	8622                	mv	a2,s0
  800480:	8a5e                	mv	s4,s7
  800482:	46a9                	li	a3,10
  800484:	b541                	j	800304 <vprintfmt+0x120>
            lflag ++;
  800486:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800488:	8462                	mv	s0,s8
            goto reswitch;
  80048a:	bb5d                	j	800240 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80048c:	000a2403          	lw	s0,0(s4)
  800490:	b7ed                	j	80047a <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800492:	000a6603          	lwu	a2,0(s4)
  800496:	46a1                	li	a3,8
  800498:	8a2e                	mv	s4,a1
  80049a:	b5ad                	j	800304 <vprintfmt+0x120>
  80049c:	000a6603          	lwu	a2,0(s4)
  8004a0:	46a9                	li	a3,10
  8004a2:	8a2e                	mv	s4,a1
  8004a4:	b585                	j	800304 <vprintfmt+0x120>
  8004a6:	000a6603          	lwu	a2,0(s4)
  8004aa:	46c1                	li	a3,16
  8004ac:	8a2e                	mv	s4,a1
  8004ae:	bd99                	j	800304 <vprintfmt+0x120>
                putch('-', putdat);
  8004b0:	85ca                	mv	a1,s2
  8004b2:	02d00513          	li	a0,45
  8004b6:	9482                	jalr	s1
                num = -(long long)num;
  8004b8:	40800633          	neg	a2,s0
  8004bc:	8a5e                	mv	s4,s7
  8004be:	46a9                	li	a3,10
  8004c0:	b591                	j	800304 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004c2:	e329                	bnez	a4,800504 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	02800793          	li	a5,40
  8004c8:	853e                	mv	a0,a5
  8004ca:	00000d97          	auipc	s11,0x0
  8004ce:	217d8d93          	addi	s11,s11,535 # 8006e1 <main+0x10f>
  8004d2:	b5f5                	j	8003be <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d4:	85e6                	mv	a1,s9
  8004d6:	856e                	mv	a0,s11
  8004d8:	c8bff0ef          	jal	800162 <strnlen>
  8004dc:	40ad0d3b          	subw	s10,s10,a0
  8004e0:	01a05863          	blez	s10,8004f0 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004e4:	85ca                	mv	a1,s2
  8004e6:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e8:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004ea:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ec:	fe0d1ce3          	bnez	s10,8004e4 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f0:	000dc783          	lbu	a5,0(s11)
  8004f4:	0007851b          	sext.w	a0,a5
  8004f8:	ec0792e3          	bnez	a5,8003bc <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004fc:	6a22                	ld	s4,8(sp)
  8004fe:	bb29                	j	800218 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800500:	8462                	mv	s0,s8
  800502:	bbd9                	j	8002d8 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800504:	85e6                	mv	a1,s9
  800506:	00000517          	auipc	a0,0x0
  80050a:	1da50513          	addi	a0,a0,474 # 8006e0 <main+0x10e>
  80050e:	c55ff0ef          	jal	800162 <strnlen>
  800512:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800516:	02800793          	li	a5,40
                p = "(null)";
  80051a:	00000d97          	auipc	s11,0x0
  80051e:	1c6d8d93          	addi	s11,s11,454 # 8006e0 <main+0x10e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800522:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800524:	fda040e3          	bgtz	s10,8004e4 <vprintfmt+0x300>
  800528:	bd51                	j	8003bc <vprintfmt+0x1d8>

000000000080052a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800530:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800532:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800534:	ec06                	sd	ra,24(sp)
  800536:	f83a                	sd	a4,48(sp)
  800538:	fc3e                	sd	a5,56(sp)
  80053a:	e0c2                	sd	a6,64(sp)
  80053c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80053e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800540:	ca5ff0ef          	jal	8001e4 <vprintfmt>
}
  800544:	60e2                	ld	ra,24(sp)
  800546:	6161                	addi	sp,sp,80
  800548:	8082                	ret

000000000080054a <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  80054a:	1141                	addi	sp,sp,-16
  80054c:	e406                	sd	ra,8(sp)
    yield();
  80054e:	b91ff0ef          	jal	8000de <yield>
    yield();
  800552:	b8dff0ef          	jal	8000de <yield>
    yield();
  800556:	b89ff0ef          	jal	8000de <yield>
    yield();
  80055a:	b85ff0ef          	jal	8000de <yield>
    yield();
  80055e:	b81ff0ef          	jal	8000de <yield>
    yield();
}
  800562:	60a2                	ld	ra,8(sp)
  800564:	0141                	addi	sp,sp,16
    yield();
  800566:	bea5                	j	8000de <yield>

0000000000800568 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800568:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  80056a:	00000517          	auipc	a0,0x0
  80056e:	25650513          	addi	a0,a0,598 # 8007c0 <main+0x1ee>
loop(void) {
  800572:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800574:	bafff0ef          	jal	800122 <cprintf>
    while (1);
  800578:	a001                	j	800578 <loop+0x10>

000000000080057a <work>:
}

void
work(void) {
  80057a:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  80057c:	00000517          	auipc	a0,0x0
  800580:	25450513          	addi	a0,a0,596 # 8007d0 <main+0x1fe>
work(void) {
  800584:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  800586:	b9dff0ef          	jal	800122 <cprintf>
    do_yield();
  80058a:	fc1ff0ef          	jal	80054a <do_yield>
    if (kill(parent) == 0) {
  80058e:	00001517          	auipc	a0,0x1
  800592:	a7a52503          	lw	a0,-1414(a0) # 801008 <parent>
  800596:	b4bff0ef          	jal	8000e0 <kill>
  80059a:	e105                	bnez	a0,8005ba <work+0x40>
        cprintf("kill parent ok.\n");
  80059c:	00000517          	auipc	a0,0x0
  8005a0:	24450513          	addi	a0,a0,580 # 8007e0 <main+0x20e>
  8005a4:	b7fff0ef          	jal	800122 <cprintf>
        do_yield();
  8005a8:	fa3ff0ef          	jal	80054a <do_yield>
        if (kill(pid1) == 0) {
  8005ac:	00001517          	auipc	a0,0x1
  8005b0:	a5852503          	lw	a0,-1448(a0) # 801004 <pid1>
  8005b4:	b2dff0ef          	jal	8000e0 <kill>
  8005b8:	c501                	beqz	a0,8005c0 <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005ba:	557d                	li	a0,-1
  8005bc:	b09ff0ef          	jal	8000c4 <exit>
            cprintf("kill child1 ok.\n");
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	23850513          	addi	a0,a0,568 # 8007f8 <main+0x226>
  8005c8:	b5bff0ef          	jal	800122 <cprintf>
            exit(0);
  8005cc:	4501                	li	a0,0
  8005ce:	af7ff0ef          	jal	8000c4 <exit>

00000000008005d2 <main>:
}

int
main(void) {
  8005d2:	1141                	addi	sp,sp,-16
  8005d4:	e406                	sd	ra,8(sp)
    parent = getpid();
  8005d6:	b0dff0ef          	jal	8000e2 <getpid>
  8005da:	00001797          	auipc	a5,0x1
  8005de:	a2a7a723          	sw	a0,-1490(a5) # 801008 <parent>
    if ((pid1 = fork()) == 0) {
  8005e2:	af9ff0ef          	jal	8000da <fork>
  8005e6:	00001797          	auipc	a5,0x1
  8005ea:	a0a7af23          	sw	a0,-1506(a5) # 801004 <pid1>
  8005ee:	c92d                	beqz	a0,800660 <main+0x8e>
        loop();
    }

    assert(pid1 > 0);
  8005f0:	04a05863          	blez	a0,800640 <main+0x6e>

    if ((pid2 = fork()) == 0) {
  8005f4:	ae7ff0ef          	jal	8000da <fork>
  8005f8:	00001797          	auipc	a5,0x1
  8005fc:	a0a7a423          	sw	a0,-1528(a5) # 801000 <pid2>
  800600:	c541                	beqz	a0,800688 <main+0xb6>
        work();
    }
    if (pid2 > 0) {
  800602:	06a05163          	blez	a0,800664 <main+0x92>
        cprintf("wait child 1.\n");
  800606:	00000517          	auipc	a0,0x0
  80060a:	24250513          	addi	a0,a0,578 # 800848 <main+0x276>
  80060e:	b15ff0ef          	jal	800122 <cprintf>
        waitpid(pid1, NULL);
  800612:	00001517          	auipc	a0,0x1
  800616:	9f252503          	lw	a0,-1550(a0) # 801004 <pid1>
  80061a:	4581                	li	a1,0
  80061c:	ac1ff0ef          	jal	8000dc <waitpid>
        panic("waitpid %d returns\n", pid1);
  800620:	00001697          	auipc	a3,0x1
  800624:	9e46a683          	lw	a3,-1564(a3) # 801004 <pid1>
  800628:	00000617          	auipc	a2,0x0
  80062c:	23060613          	addi	a2,a2,560 # 800858 <main+0x286>
  800630:	03400593          	li	a1,52
  800634:	00000517          	auipc	a0,0x0
  800638:	20450513          	addi	a0,a0,516 # 800838 <main+0x266>
  80063c:	9e5ff0ef          	jal	800020 <__panic>
    assert(pid1 > 0);
  800640:	00000697          	auipc	a3,0x0
  800644:	1d068693          	addi	a3,a3,464 # 800810 <main+0x23e>
  800648:	00000617          	auipc	a2,0x0
  80064c:	1d860613          	addi	a2,a2,472 # 800820 <main+0x24e>
  800650:	02c00593          	li	a1,44
  800654:	00000517          	auipc	a0,0x0
  800658:	1e450513          	addi	a0,a0,484 # 800838 <main+0x266>
  80065c:	9c5ff0ef          	jal	800020 <__panic>
        loop();
  800660:	f09ff0ef          	jal	800568 <loop>
    }
    else {
        kill(pid1);
  800664:	00001517          	auipc	a0,0x1
  800668:	9a052503          	lw	a0,-1632(a0) # 801004 <pid1>
  80066c:	a75ff0ef          	jal	8000e0 <kill>
    }
    panic("FAIL: T.T\n");
  800670:	00000617          	auipc	a2,0x0
  800674:	20060613          	addi	a2,a2,512 # 800870 <main+0x29e>
  800678:	03900593          	li	a1,57
  80067c:	00000517          	auipc	a0,0x0
  800680:	1bc50513          	addi	a0,a0,444 # 800838 <main+0x266>
  800684:	99dff0ef          	jal	800020 <__panic>
        work();
  800688:	ef3ff0ef          	jal	80057a <work>
