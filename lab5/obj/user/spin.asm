
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	715d                	addi	sp,sp,-80
  800022:	8e2e                	mv	t3,a1
  800024:	e822                	sd	s0,16(sp)
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("user panic at %s:%d:\n    ", file, line);
  800026:	85aa                	mv	a1,a0
__panic(const char *file, int line, const char *fmt, ...) {
  800028:	8432                	mv	s0,a2
  80002a:	fc3e                	sd	a5,56(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	8672                	mv	a2,t3
    va_start(ap, fmt);
  80002e:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	00000517          	auipc	a0,0x0
  800034:	60850513          	addi	a0,a0,1544 # 800638 <main+0xd0>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0d8000ef          	jal	ra,80011c <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b0000ef          	jal	ra,8000fc <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	60850513          	addi	a0,a0,1544 # 800658 <main+0xf0>
  800058:	0c4000ef          	jal	ra,80011c <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	060000ef          	jal	ra,8000be <exit>

0000000000800062 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800062:	7175                	addi	sp,sp,-144
  800064:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800066:	e0ba                	sd	a4,64(sp)
  800068:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  80006a:	e42a                	sd	a0,8(sp)
  80006c:	ecae                	sd	a1,88(sp)
  80006e:	f0b2                	sd	a2,96(sp)
  800070:	f4b6                	sd	a3,104(sp)
  800072:	fcbe                	sd	a5,120(sp)
  800074:	e142                	sd	a6,128(sp)
  800076:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800078:	f42e                	sd	a1,40(sp)
  80007a:	f832                	sd	a2,48(sp)
  80007c:	fc36                	sd	a3,56(sp)
  80007e:	f03a                	sd	a4,32(sp)
  800080:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800082:	6522                	ld	a0,8(sp)
  800084:	75a2                	ld	a1,40(sp)
  800086:	7642                	ld	a2,48(sp)
  800088:	76e2                	ld	a3,56(sp)
  80008a:	6706                	ld	a4,64(sp)
  80008c:	67a6                	ld	a5,72(sp)
  80008e:	00000073          	ecall
  800092:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
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
  8000c2:	fdbff0ef          	jal	ra,80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	59a50513          	addi	a0,a0,1434 # 800660 <main+0xf8>
  8000ce:	04e000ef          	jal	ra,80011c <cprintf>
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
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000dc:	076000ef          	jal	ra,800152 <umain>
1:  j 1b
  8000e0:	a001                	j	8000e0 <_start+0x4>

00000000008000e2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e022                	sd	s0,0(sp)
  8000e6:	e406                	sd	ra,8(sp)
  8000e8:	842e                	mv	s0,a1
    sys_putc(c);
  8000ea:	fcfff0ef          	jal	ra,8000b8 <sys_putc>
    (*cnt) ++;
  8000ee:	401c                	lw	a5,0(s0)
}
  8000f0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f2:	2785                	addiw	a5,a5,1
  8000f4:	c01c                	sw	a5,0(s0)
}
  8000f6:	6402                	ld	s0,0(sp)
  8000f8:	0141                	addi	sp,sp,16
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
  800106:	fe050513          	addi	a0,a0,-32 # 8000e2 <cputch>
  80010a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  80010c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800110:	0d6000ef          	jal	ra,8001e6 <vprintfmt>
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
  800122:	8e2a                	mv	t3,a0
  800124:	f42e                	sd	a1,40(sp)
  800126:	f832                	sd	a2,48(sp)
  800128:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012a:	00000517          	auipc	a0,0x0
  80012e:	fb850513          	addi	a0,a0,-72 # 8000e2 <cputch>
  800132:	004c                	addi	a1,sp,4
  800134:	869a                	mv	a3,t1
  800136:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  800138:	ec06                	sd	ra,24(sp)
  80013a:	e0ba                	sd	a4,64(sp)
  80013c:	e4be                	sd	a5,72(sp)
  80013e:	e8c2                	sd	a6,80(sp)
  800140:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800142:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800144:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800146:	0a0000ef          	jal	ra,8001e6 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014a:	60e2                	ld	ra,24(sp)
  80014c:	4512                	lw	a0,4(sp)
  80014e:	6125                	addi	sp,sp,96
  800150:	8082                	ret

0000000000800152 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800152:	1141                	addi	sp,sp,-16
  800154:	e406                	sd	ra,8(sp)
    int ret = main();
  800156:	412000ef          	jal	ra,800568 <main>
    exit(ret);
  80015a:	f65ff0ef          	jal	ra,8000be <exit>

000000000080015e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80015e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800160:	e589                	bnez	a1,80016a <strnlen+0xc>
  800162:	a811                	j	800176 <strnlen+0x18>
        cnt ++;
  800164:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800166:	00f58863          	beq	a1,a5,800176 <strnlen+0x18>
  80016a:	00f50733          	add	a4,a0,a5
  80016e:	00074703          	lbu	a4,0(a4)
  800172:	fb6d                	bnez	a4,800164 <strnlen+0x6>
  800174:	85be                	mv	a1,a5
    }
    return cnt;
}
  800176:	852e                	mv	a0,a1
  800178:	8082                	ret

000000000080017a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800180:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800184:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800186:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	f022                	sd	s0,32(sp)
  80018c:	ec26                	sd	s1,24(sp)
  80018e:	e84a                	sd	s2,16(sp)
  800190:	f406                	sd	ra,40(sp)
  800192:	e44e                	sd	s3,8(sp)
  800194:	84aa                	mv	s1,a0
  800196:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800198:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80019c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80019e:	03067e63          	bgeu	a2,a6,8001da <printnum+0x60>
  8001a2:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a4:	00805763          	blez	s0,8001b2 <printnum+0x38>
  8001a8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	854e                	mv	a0,s3
  8001ae:	9482                	jalr	s1
        while (-- width > 0)
  8001b0:	fc65                	bnez	s0,8001a8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	1a02                	slli	s4,s4,0x20
  8001b4:	00000797          	auipc	a5,0x0
  8001b8:	4c478793          	addi	a5,a5,1220 # 800678 <main+0x110>
  8001bc:	020a5a13          	srli	s4,s4,0x20
  8001c0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	000a4503          	lbu	a0,0(s4)
}
  8001c8:	70a2                	ld	ra,40(sp)
  8001ca:	69a2                	ld	s3,8(sp)
  8001cc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ce:	85ca                	mv	a1,s2
  8001d0:	87a6                	mv	a5,s1
}
  8001d2:	6942                	ld	s2,16(sp)
  8001d4:	64e2                	ld	s1,24(sp)
  8001d6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001da:	03065633          	divu	a2,a2,a6
  8001de:	8722                	mv	a4,s0
  8001e0:	f9bff0ef          	jal	ra,80017a <printnum>
  8001e4:	b7f9                	j	8001b2 <printnum+0x38>

00000000008001e6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e6:	7119                	addi	sp,sp,-128
  8001e8:	f4a6                	sd	s1,104(sp)
  8001ea:	f0ca                	sd	s2,96(sp)
  8001ec:	ecce                	sd	s3,88(sp)
  8001ee:	e8d2                	sd	s4,80(sp)
  8001f0:	e4d6                	sd	s5,72(sp)
  8001f2:	e0da                	sd	s6,64(sp)
  8001f4:	fc5e                	sd	s7,56(sp)
  8001f6:	f06a                	sd	s10,32(sp)
  8001f8:	fc86                	sd	ra,120(sp)
  8001fa:	f8a2                	sd	s0,112(sp)
  8001fc:	f862                	sd	s8,48(sp)
  8001fe:	f466                	sd	s9,40(sp)
  800200:	ec6e                	sd	s11,24(sp)
  800202:	892a                	mv	s2,a0
  800204:	84ae                	mv	s1,a1
  800206:	8d32                	mv	s10,a2
  800208:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80020e:	5b7d                	li	s6,-1
  800210:	00000a97          	auipc	s5,0x0
  800214:	49ca8a93          	addi	s5,s5,1180 # 8006ac <main+0x144>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800218:	00000b97          	auipc	s7,0x0
  80021c:	6b0b8b93          	addi	s7,s7,1712 # 8008c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	000d4503          	lbu	a0,0(s10)
  800224:	001d0413          	addi	s0,s10,1
  800228:	01350a63          	beq	a0,s3,80023c <vprintfmt+0x56>
            if (ch == '\0') {
  80022c:	c121                	beqz	a0,80026c <vprintfmt+0x86>
            putch(ch, putdat);
  80022e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800230:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800232:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800234:	fff44503          	lbu	a0,-1(s0)
  800238:	ff351ae3          	bne	a0,s3,80022c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80023c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800240:	02000793          	li	a5,32
        lflag = altflag = 0;
  800244:	4c81                	li	s9,0
  800246:	4881                	li	a7,0
        width = precision = -1;
  800248:	5c7d                	li	s8,-1
  80024a:	5dfd                	li	s11,-1
  80024c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800250:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800252:	fdd6059b          	addiw	a1,a2,-35
  800256:	0ff5f593          	zext.b	a1,a1
  80025a:	00140d13          	addi	s10,s0,1
  80025e:	04b56263          	bltu	a0,a1,8002a2 <vprintfmt+0xbc>
  800262:	058a                	slli	a1,a1,0x2
  800264:	95d6                	add	a1,a1,s5
  800266:	4194                	lw	a3,0(a1)
  800268:	96d6                	add	a3,a3,s5
  80026a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80026c:	70e6                	ld	ra,120(sp)
  80026e:	7446                	ld	s0,112(sp)
  800270:	74a6                	ld	s1,104(sp)
  800272:	7906                	ld	s2,96(sp)
  800274:	69e6                	ld	s3,88(sp)
  800276:	6a46                	ld	s4,80(sp)
  800278:	6aa6                	ld	s5,72(sp)
  80027a:	6b06                	ld	s6,64(sp)
  80027c:	7be2                	ld	s7,56(sp)
  80027e:	7c42                	ld	s8,48(sp)
  800280:	7ca2                	ld	s9,40(sp)
  800282:	7d02                	ld	s10,32(sp)
  800284:	6de2                	ld	s11,24(sp)
  800286:	6109                	addi	sp,sp,128
  800288:	8082                	ret
            padc = '0';
  80028a:	87b2                	mv	a5,a2
            goto reswitch;
  80028c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800290:	846a                	mv	s0,s10
  800292:	00140d13          	addi	s10,s0,1
  800296:	fdd6059b          	addiw	a1,a2,-35
  80029a:	0ff5f593          	zext.b	a1,a1
  80029e:	fcb572e3          	bgeu	a0,a1,800262 <vprintfmt+0x7c>
            putch('%', putdat);
  8002a2:	85a6                	mv	a1,s1
  8002a4:	02500513          	li	a0,37
  8002a8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002aa:	fff44783          	lbu	a5,-1(s0)
  8002ae:	8d22                	mv	s10,s0
  8002b0:	f73788e3          	beq	a5,s3,800220 <vprintfmt+0x3a>
  8002b4:	ffed4783          	lbu	a5,-2(s10)
  8002b8:	1d7d                	addi	s10,s10,-1
  8002ba:	ff379de3          	bne	a5,s3,8002b4 <vprintfmt+0xce>
  8002be:	b78d                	j	800220 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002c0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002c4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ca:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002ce:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d2:	02d86463          	bltu	a6,a3,8002fa <vprintfmt+0x114>
                ch = *fmt;
  8002d6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002da:	002c169b          	slliw	a3,s8,0x2
  8002de:	0186873b          	addw	a4,a3,s8
  8002e2:	0017171b          	slliw	a4,a4,0x1
  8002e6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002e8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002ec:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ee:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002f2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002f6:	fed870e3          	bgeu	a6,a3,8002d6 <vprintfmt+0xf0>
            if (width < 0)
  8002fa:	f40ddce3          	bgez	s11,800252 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002fe:	8de2                	mv	s11,s8
  800300:	5c7d                	li	s8,-1
  800302:	bf81                	j	800252 <vprintfmt+0x6c>
            if (width < 0)
  800304:	fffdc693          	not	a3,s11
  800308:	96fd                	srai	a3,a3,0x3f
  80030a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80030e:	00144603          	lbu	a2,1(s0)
  800312:	2d81                	sext.w	s11,s11
  800314:	846a                	mv	s0,s10
            goto reswitch;
  800316:	bf35                	j	800252 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800318:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80031c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800320:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800322:	846a                	mv	s0,s10
            goto process_precision;
  800324:	bfd9                	j	8002fa <vprintfmt+0x114>
    if (lflag >= 2) {
  800326:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800328:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032c:	01174463          	blt	a4,a7,800334 <vprintfmt+0x14e>
    else if (lflag) {
  800330:	1a088e63          	beqz	a7,8004ec <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800334:	000a3603          	ld	a2,0(s4)
  800338:	46c1                	li	a3,16
  80033a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80033c:	2781                	sext.w	a5,a5
  80033e:	876e                	mv	a4,s11
  800340:	85a6                	mv	a1,s1
  800342:	854a                	mv	a0,s2
  800344:	e37ff0ef          	jal	ra,80017a <printnum>
            break;
  800348:	bde1                	j	800220 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80034a:	000a2503          	lw	a0,0(s4)
  80034e:	85a6                	mv	a1,s1
  800350:	0a21                	addi	s4,s4,8
  800352:	9902                	jalr	s2
            break;
  800354:	b5f1                	j	800220 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800356:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800358:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80035c:	01174463          	blt	a4,a7,800364 <vprintfmt+0x17e>
    else if (lflag) {
  800360:	18088163          	beqz	a7,8004e2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800364:	000a3603          	ld	a2,0(s4)
  800368:	46a9                	li	a3,10
  80036a:	8a2e                	mv	s4,a1
  80036c:	bfc1                	j	80033c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  80036e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800372:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800374:	846a                	mv	s0,s10
            goto reswitch;
  800376:	bdf1                	j	800252 <vprintfmt+0x6c>
            putch(ch, putdat);
  800378:	85a6                	mv	a1,s1
  80037a:	02500513          	li	a0,37
  80037e:	9902                	jalr	s2
            break;
  800380:	b545                	j	800220 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800382:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800386:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800388:	846a                	mv	s0,s10
            goto reswitch;
  80038a:	b5e1                	j	800252 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80038c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80038e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800392:	01174463          	blt	a4,a7,80039a <vprintfmt+0x1b4>
    else if (lflag) {
  800396:	14088163          	beqz	a7,8004d8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80039a:	000a3603          	ld	a2,0(s4)
  80039e:	46a1                	li	a3,8
  8003a0:	8a2e                	mv	s4,a1
  8003a2:	bf69                	j	80033c <vprintfmt+0x156>
            putch('0', putdat);
  8003a4:	03000513          	li	a0,48
  8003a8:	85a6                	mv	a1,s1
  8003aa:	e03e                	sd	a5,0(sp)
  8003ac:	9902                	jalr	s2
            putch('x', putdat);
  8003ae:	85a6                	mv	a1,s1
  8003b0:	07800513          	li	a0,120
  8003b4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003b6:	0a21                	addi	s4,s4,8
            goto number;
  8003b8:	6782                	ld	a5,0(sp)
  8003ba:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003bc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003c0:	bfb5                	j	80033c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c2:	000a3403          	ld	s0,0(s4)
  8003c6:	008a0713          	addi	a4,s4,8
  8003ca:	e03a                	sd	a4,0(sp)
  8003cc:	14040263          	beqz	s0,800510 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003d0:	0fb05763          	blez	s11,8004be <vprintfmt+0x2d8>
  8003d4:	02d00693          	li	a3,45
  8003d8:	0cd79163          	bne	a5,a3,80049a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003dc:	00044783          	lbu	a5,0(s0)
  8003e0:	0007851b          	sext.w	a0,a5
  8003e4:	cf85                	beqz	a5,80041c <vprintfmt+0x236>
  8003e6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ea:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ee:	000c4563          	bltz	s8,8003f8 <vprintfmt+0x212>
  8003f2:	3c7d                	addiw	s8,s8,-1
  8003f4:	036c0263          	beq	s8,s6,800418 <vprintfmt+0x232>
                    putch('?', putdat);
  8003f8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003fa:	0e0c8e63          	beqz	s9,8004f6 <vprintfmt+0x310>
  8003fe:	3781                	addiw	a5,a5,-32
  800400:	0ef47b63          	bgeu	s0,a5,8004f6 <vprintfmt+0x310>
                    putch('?', putdat);
  800404:	03f00513          	li	a0,63
  800408:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80040a:	000a4783          	lbu	a5,0(s4)
  80040e:	3dfd                	addiw	s11,s11,-1
  800410:	0a05                	addi	s4,s4,1
  800412:	0007851b          	sext.w	a0,a5
  800416:	ffe1                	bnez	a5,8003ee <vprintfmt+0x208>
            for (; width > 0; width --) {
  800418:	01b05963          	blez	s11,80042a <vprintfmt+0x244>
  80041c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80041e:	85a6                	mv	a1,s1
  800420:	02000513          	li	a0,32
  800424:	9902                	jalr	s2
            for (; width > 0; width --) {
  800426:	fe0d9be3          	bnez	s11,80041c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80042a:	6a02                	ld	s4,0(sp)
  80042c:	bbd5                	j	800220 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80042e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800430:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800434:	01174463          	blt	a4,a7,80043c <vprintfmt+0x256>
    else if (lflag) {
  800438:	08088d63          	beqz	a7,8004d2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80043c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800440:	0a044d63          	bltz	s0,8004fa <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800444:	8622                	mv	a2,s0
  800446:	8a66                	mv	s4,s9
  800448:	46a9                	li	a3,10
  80044a:	bdcd                	j	80033c <vprintfmt+0x156>
            err = va_arg(ap, int);
  80044c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800450:	4761                	li	a4,24
            err = va_arg(ap, int);
  800452:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800454:	41f7d69b          	sraiw	a3,a5,0x1f
  800458:	8fb5                	xor	a5,a5,a3
  80045a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80045e:	02d74163          	blt	a4,a3,800480 <vprintfmt+0x29a>
  800462:	00369793          	slli	a5,a3,0x3
  800466:	97de                	add	a5,a5,s7
  800468:	639c                	ld	a5,0(a5)
  80046a:	cb99                	beqz	a5,800480 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80046c:	86be                	mv	a3,a5
  80046e:	00000617          	auipc	a2,0x0
  800472:	23a60613          	addi	a2,a2,570 # 8006a8 <main+0x140>
  800476:	85a6                	mv	a1,s1
  800478:	854a                	mv	a0,s2
  80047a:	0ce000ef          	jal	ra,800548 <printfmt>
  80047e:	b34d                	j	800220 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800480:	00000617          	auipc	a2,0x0
  800484:	21860613          	addi	a2,a2,536 # 800698 <main+0x130>
  800488:	85a6                	mv	a1,s1
  80048a:	854a                	mv	a0,s2
  80048c:	0bc000ef          	jal	ra,800548 <printfmt>
  800490:	bb41                	j	800220 <vprintfmt+0x3a>
                p = "(null)";
  800492:	00000417          	auipc	s0,0x0
  800496:	1fe40413          	addi	s0,s0,510 # 800690 <main+0x128>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049a:	85e2                	mv	a1,s8
  80049c:	8522                	mv	a0,s0
  80049e:	e43e                	sd	a5,8(sp)
  8004a0:	cbfff0ef          	jal	ra,80015e <strnlen>
  8004a4:	40ad8dbb          	subw	s11,s11,a0
  8004a8:	01b05b63          	blez	s11,8004be <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004ac:	67a2                	ld	a5,8(sp)
  8004ae:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004b4:	85a6                	mv	a1,s1
  8004b6:	8552                	mv	a0,s4
  8004b8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ba:	fe0d9ce3          	bnez	s11,8004b2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004be:	00044783          	lbu	a5,0(s0)
  8004c2:	00140a13          	addi	s4,s0,1
  8004c6:	0007851b          	sext.w	a0,a5
  8004ca:	d3a5                	beqz	a5,80042a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004cc:	05e00413          	li	s0,94
  8004d0:	bf39                	j	8003ee <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004d2:	000a2403          	lw	s0,0(s4)
  8004d6:	b7ad                	j	800440 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004d8:	000a6603          	lwu	a2,0(s4)
  8004dc:	46a1                	li	a3,8
  8004de:	8a2e                	mv	s4,a1
  8004e0:	bdb1                	j	80033c <vprintfmt+0x156>
  8004e2:	000a6603          	lwu	a2,0(s4)
  8004e6:	46a9                	li	a3,10
  8004e8:	8a2e                	mv	s4,a1
  8004ea:	bd89                	j	80033c <vprintfmt+0x156>
  8004ec:	000a6603          	lwu	a2,0(s4)
  8004f0:	46c1                	li	a3,16
  8004f2:	8a2e                	mv	s4,a1
  8004f4:	b5a1                	j	80033c <vprintfmt+0x156>
                    putch(ch, putdat);
  8004f6:	9902                	jalr	s2
  8004f8:	bf09                	j	80040a <vprintfmt+0x224>
                putch('-', putdat);
  8004fa:	85a6                	mv	a1,s1
  8004fc:	02d00513          	li	a0,45
  800500:	e03e                	sd	a5,0(sp)
  800502:	9902                	jalr	s2
                num = -(long long)num;
  800504:	6782                	ld	a5,0(sp)
  800506:	8a66                	mv	s4,s9
  800508:	40800633          	neg	a2,s0
  80050c:	46a9                	li	a3,10
  80050e:	b53d                	j	80033c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800510:	03b05163          	blez	s11,800532 <vprintfmt+0x34c>
  800514:	02d00693          	li	a3,45
  800518:	f6d79de3          	bne	a5,a3,800492 <vprintfmt+0x2ac>
                p = "(null)";
  80051c:	00000417          	auipc	s0,0x0
  800520:	17440413          	addi	s0,s0,372 # 800690 <main+0x128>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800524:	02800793          	li	a5,40
  800528:	02800513          	li	a0,40
  80052c:	00140a13          	addi	s4,s0,1
  800530:	bd6d                	j	8003ea <vprintfmt+0x204>
  800532:	00000a17          	auipc	s4,0x0
  800536:	15fa0a13          	addi	s4,s4,351 # 800691 <main+0x129>
  80053a:	02800513          	li	a0,40
  80053e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800542:	05e00413          	li	s0,94
  800546:	b565                	j	8003ee <vprintfmt+0x208>

0000000000800548 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80054a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800550:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	ec06                	sd	ra,24(sp)
  800554:	f83a                	sd	a4,48(sp)
  800556:	fc3e                	sd	a5,56(sp)
  800558:	e0c2                	sd	a6,64(sp)
  80055a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80055c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055e:	c89ff0ef          	jal	ra,8001e6 <vprintfmt>
}
  800562:	60e2                	ld	ra,24(sp)
  800564:	6161                	addi	sp,sp,80
  800566:	8082                	ret

0000000000800568 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800568:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80056a:	00000517          	auipc	a0,0x0
  80056e:	42650513          	addi	a0,a0,1062 # 800990 <error_string+0xc8>
main(void) {
  800572:	e406                	sd	ra,8(sp)
  800574:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800576:	ba7ff0ef          	jal	ra,80011c <cprintf>
    if ((pid = fork()) == 0) {
  80057a:	b5bff0ef          	jal	ra,8000d4 <fork>
  80057e:	e901                	bnez	a0,80058e <main+0x26>
        cprintf("I am the child. spinning ...\n");
  800580:	00000517          	auipc	a0,0x0
  800584:	43850513          	addi	a0,a0,1080 # 8009b8 <error_string+0xf0>
  800588:	b95ff0ef          	jal	ra,80011c <cprintf>
        while (1);
  80058c:	a001                	j	80058c <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  80058e:	842a                	mv	s0,a0
  800590:	00000517          	auipc	a0,0x0
  800594:	44850513          	addi	a0,a0,1096 # 8009d8 <error_string+0x110>
  800598:	b85ff0ef          	jal	ra,80011c <cprintf>

    yield();
  80059c:	b3dff0ef          	jal	ra,8000d8 <yield>
    yield();
  8005a0:	b39ff0ef          	jal	ra,8000d8 <yield>
    yield();
  8005a4:	b35ff0ef          	jal	ra,8000d8 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005a8:	00000517          	auipc	a0,0x0
  8005ac:	45850513          	addi	a0,a0,1112 # 800a00 <error_string+0x138>
  8005b0:	b6dff0ef          	jal	ra,80011c <cprintf>

    assert((ret = kill(pid)) == 0);
  8005b4:	8522                	mv	a0,s0
  8005b6:	b25ff0ef          	jal	ra,8000da <kill>
  8005ba:	ed31                	bnez	a0,800616 <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005bc:	4581                	li	a1,0
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	4aa50513          	addi	a0,a0,1194 # 800a68 <error_string+0x1a0>
  8005c6:	b57ff0ef          	jal	ra,80011c <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ca:	4581                	li	a1,0
  8005cc:	8522                	mv	a0,s0
  8005ce:	b09ff0ef          	jal	ra,8000d6 <waitpid>
  8005d2:	e11d                	bnez	a0,8005f8 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005d4:	4581                	li	a1,0
  8005d6:	00000517          	auipc	a0,0x0
  8005da:	4ca50513          	addi	a0,a0,1226 # 800aa0 <error_string+0x1d8>
  8005de:	b3fff0ef          	jal	ra,80011c <cprintf>

    cprintf("spin may pass.\n");
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	4d650513          	addi	a0,a0,1238 # 800ab8 <error_string+0x1f0>
  8005ea:	b33ff0ef          	jal	ra,80011c <cprintf>
    return 0;
}
  8005ee:	60a2                	ld	ra,8(sp)
  8005f0:	6402                	ld	s0,0(sp)
  8005f2:	4501                	li	a0,0
  8005f4:	0141                	addi	sp,sp,16
  8005f6:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005f8:	00000697          	auipc	a3,0x0
  8005fc:	48868693          	addi	a3,a3,1160 # 800a80 <error_string+0x1b8>
  800600:	00000617          	auipc	a2,0x0
  800604:	44060613          	addi	a2,a2,1088 # 800a40 <error_string+0x178>
  800608:	45dd                	li	a1,23
  80060a:	00000517          	auipc	a0,0x0
  80060e:	44e50513          	addi	a0,a0,1102 # 800a58 <error_string+0x190>
  800612:	a0fff0ef          	jal	ra,800020 <__panic>
    assert((ret = kill(pid)) == 0);
  800616:	00000697          	auipc	a3,0x0
  80061a:	41268693          	addi	a3,a3,1042 # 800a28 <error_string+0x160>
  80061e:	00000617          	auipc	a2,0x0
  800622:	42260613          	addi	a2,a2,1058 # 800a40 <error_string+0x178>
  800626:	45d1                	li	a1,20
  800628:	00000517          	auipc	a0,0x0
  80062c:	43050513          	addi	a0,a0,1072 # 800a58 <error_string+0x190>
  800630:	9f1ff0ef          	jal	ra,800020 <__panic>
