
obj/__user_waitkill.out:     file format elf64-littleriscv


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
  800034:	67850513          	addi	a0,a0,1656 # 8006a8 <main+0xb2>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0de000ef          	jal	ra,800122 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b6000ef          	jal	ra,800102 <vcprintf>
    cprintf("\n");
  800050:	00001517          	auipc	a0,0x1
  800054:	9b050513          	addi	a0,a0,-1616 # 800a00 <error_string+0xd0>
  800058:	0ca000ef          	jal	ra,800122 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	064000ef          	jal	ra,8000c2 <exit>

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

00000000008000b8 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b8:	4549                	li	a0,18
  8000ba:	b765                	j	800062 <syscall>

00000000008000bc <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000bc:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000be:	4579                	li	a0,30
  8000c0:	b74d                	j	800062 <syscall>

00000000008000c2 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c6:	fd7ff0ef          	jal	ra,80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	5fe50513          	addi	a0,a0,1534 # 8006c8 <main+0xd2>
  8000d2:	050000ef          	jal	ra,800122 <cprintf>
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d8:	b7e9                	j	8000a2 <sys_fork>

00000000008000da <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000da:	b7f1                	j	8000a6 <sys_wait>

00000000008000dc <yield>:
}

void
yield(void) {
    sys_yield();
  8000dc:	bfc9                	j	8000ae <sys_yield>

00000000008000de <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000de:	bfd1                	j	8000b2 <sys_kill>

00000000008000e0 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000e0:	bfe1                	j	8000b8 <sys_getpid>

00000000008000e2 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000e2:	076000ef          	jal	ra,800158 <umain>
1:  j 1b
  8000e6:	a001                	j	8000e6 <_start+0x4>

00000000008000e8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e8:	1141                	addi	sp,sp,-16
  8000ea:	e022                	sd	s0,0(sp)
  8000ec:	e406                	sd	ra,8(sp)
  8000ee:	842e                	mv	s0,a1
    sys_putc(c);
  8000f0:	fcdff0ef          	jal	ra,8000bc <sys_putc>
    (*cnt) ++;
  8000f4:	401c                	lw	a5,0(s0)
}
  8000f6:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f8:	2785                	addiw	a5,a5,1
  8000fa:	c01c                	sw	a5,0(s0)
}
  8000fc:	6402                	ld	s0,0(sp)
  8000fe:	0141                	addi	sp,sp,16
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
  80010c:	fe050513          	addi	a0,a0,-32 # 8000e8 <cputch>
  800110:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800112:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800114:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800116:	0d6000ef          	jal	ra,8001ec <vprintfmt>
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
  800128:	8e2a                	mv	t3,a0
  80012a:	f42e                	sd	a1,40(sp)
  80012c:	f832                	sd	a2,48(sp)
  80012e:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800130:	00000517          	auipc	a0,0x0
  800134:	fb850513          	addi	a0,a0,-72 # 8000e8 <cputch>
  800138:	004c                	addi	a1,sp,4
  80013a:	869a                	mv	a3,t1
  80013c:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80013e:	ec06                	sd	ra,24(sp)
  800140:	e0ba                	sd	a4,64(sp)
  800142:	e4be                	sd	a5,72(sp)
  800144:	e8c2                	sd	a6,80(sp)
  800146:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800148:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  80014a:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80014c:	0a0000ef          	jal	ra,8001ec <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800150:	60e2                	ld	ra,24(sp)
  800152:	4512                	lw	a0,4(sp)
  800154:	6125                	addi	sp,sp,96
  800156:	8082                	ret

0000000000800158 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800158:	1141                	addi	sp,sp,-16
  80015a:	e406                	sd	ra,8(sp)
    int ret = main();
  80015c:	49a000ef          	jal	ra,8005f6 <main>
    exit(ret);
  800160:	f63ff0ef          	jal	ra,8000c2 <exit>

0000000000800164 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800164:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800166:	e589                	bnez	a1,800170 <strnlen+0xc>
  800168:	a811                	j	80017c <strnlen+0x18>
        cnt ++;
  80016a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80016c:	00f58863          	beq	a1,a5,80017c <strnlen+0x18>
  800170:	00f50733          	add	a4,a0,a5
  800174:	00074703          	lbu	a4,0(a4)
  800178:	fb6d                	bnez	a4,80016a <strnlen+0x6>
  80017a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80017c:	852e                	mv	a0,a1
  80017e:	8082                	ret

0000000000800180 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800180:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800184:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800186:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800190:	f022                	sd	s0,32(sp)
  800192:	ec26                	sd	s1,24(sp)
  800194:	e84a                	sd	s2,16(sp)
  800196:	f406                	sd	ra,40(sp)
  800198:	e44e                	sd	s3,8(sp)
  80019a:	84aa                	mv	s1,a0
  80019c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80019e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a2:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8001a4:	03067e63          	bgeu	a2,a6,8001e0 <printnum+0x60>
  8001a8:	89be                	mv	s3,a5
        while (-- width > 0)
  8001aa:	00805763          	blez	s0,8001b8 <printnum+0x38>
  8001ae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	854e                	mv	a0,s3
  8001b4:	9482                	jalr	s1
        while (-- width > 0)
  8001b6:	fc65                	bnez	s0,8001ae <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	1a02                	slli	s4,s4,0x20
  8001ba:	00000797          	auipc	a5,0x0
  8001be:	52678793          	addi	a5,a5,1318 # 8006e0 <main+0xea>
  8001c2:	020a5a13          	srli	s4,s4,0x20
  8001c6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ca:	000a4503          	lbu	a0,0(s4)
}
  8001ce:	70a2                	ld	ra,40(sp)
  8001d0:	69a2                	ld	s3,8(sp)
  8001d2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d4:	85ca                	mv	a1,s2
  8001d6:	87a6                	mv	a5,s1
}
  8001d8:	6942                	ld	s2,16(sp)
  8001da:	64e2                	ld	s1,24(sp)
  8001dc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001de:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e0:	03065633          	divu	a2,a2,a6
  8001e4:	8722                	mv	a4,s0
  8001e6:	f9bff0ef          	jal	ra,800180 <printnum>
  8001ea:	b7f9                	j	8001b8 <printnum+0x38>

00000000008001ec <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ec:	7119                	addi	sp,sp,-128
  8001ee:	f4a6                	sd	s1,104(sp)
  8001f0:	f0ca                	sd	s2,96(sp)
  8001f2:	ecce                	sd	s3,88(sp)
  8001f4:	e8d2                	sd	s4,80(sp)
  8001f6:	e4d6                	sd	s5,72(sp)
  8001f8:	e0da                	sd	s6,64(sp)
  8001fa:	fc5e                	sd	s7,56(sp)
  8001fc:	f06a                	sd	s10,32(sp)
  8001fe:	fc86                	sd	ra,120(sp)
  800200:	f8a2                	sd	s0,112(sp)
  800202:	f862                	sd	s8,48(sp)
  800204:	f466                	sd	s9,40(sp)
  800206:	ec6e                	sd	s11,24(sp)
  800208:	892a                	mv	s2,a0
  80020a:	84ae                	mv	s1,a1
  80020c:	8d32                	mv	s10,a2
  80020e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800214:	5b7d                	li	s6,-1
  800216:	00000a97          	auipc	s5,0x0
  80021a:	4fea8a93          	addi	s5,s5,1278 # 800714 <main+0x11e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80021e:	00000b97          	auipc	s7,0x0
  800222:	712b8b93          	addi	s7,s7,1810 # 800930 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	000d4503          	lbu	a0,0(s10)
  80022a:	001d0413          	addi	s0,s10,1
  80022e:	01350a63          	beq	a0,s3,800242 <vprintfmt+0x56>
            if (ch == '\0') {
  800232:	c121                	beqz	a0,800272 <vprintfmt+0x86>
            putch(ch, putdat);
  800234:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800238:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	fff44503          	lbu	a0,-1(s0)
  80023e:	ff351ae3          	bne	a0,s3,800232 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800242:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800246:	02000793          	li	a5,32
        lflag = altflag = 0;
  80024a:	4c81                	li	s9,0
  80024c:	4881                	li	a7,0
        width = precision = -1;
  80024e:	5c7d                	li	s8,-1
  800250:	5dfd                	li	s11,-1
  800252:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800256:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800258:	fdd6059b          	addiw	a1,a2,-35
  80025c:	0ff5f593          	zext.b	a1,a1
  800260:	00140d13          	addi	s10,s0,1
  800264:	04b56263          	bltu	a0,a1,8002a8 <vprintfmt+0xbc>
  800268:	058a                	slli	a1,a1,0x2
  80026a:	95d6                	add	a1,a1,s5
  80026c:	4194                	lw	a3,0(a1)
  80026e:	96d6                	add	a3,a3,s5
  800270:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800272:	70e6                	ld	ra,120(sp)
  800274:	7446                	ld	s0,112(sp)
  800276:	74a6                	ld	s1,104(sp)
  800278:	7906                	ld	s2,96(sp)
  80027a:	69e6                	ld	s3,88(sp)
  80027c:	6a46                	ld	s4,80(sp)
  80027e:	6aa6                	ld	s5,72(sp)
  800280:	6b06                	ld	s6,64(sp)
  800282:	7be2                	ld	s7,56(sp)
  800284:	7c42                	ld	s8,48(sp)
  800286:	7ca2                	ld	s9,40(sp)
  800288:	7d02                	ld	s10,32(sp)
  80028a:	6de2                	ld	s11,24(sp)
  80028c:	6109                	addi	sp,sp,128
  80028e:	8082                	ret
            padc = '0';
  800290:	87b2                	mv	a5,a2
            goto reswitch;
  800292:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	846a                	mv	s0,s10
  800298:	00140d13          	addi	s10,s0,1
  80029c:	fdd6059b          	addiw	a1,a2,-35
  8002a0:	0ff5f593          	zext.b	a1,a1
  8002a4:	fcb572e3          	bgeu	a0,a1,800268 <vprintfmt+0x7c>
            putch('%', putdat);
  8002a8:	85a6                	mv	a1,s1
  8002aa:	02500513          	li	a0,37
  8002ae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002b0:	fff44783          	lbu	a5,-1(s0)
  8002b4:	8d22                	mv	s10,s0
  8002b6:	f73788e3          	beq	a5,s3,800226 <vprintfmt+0x3a>
  8002ba:	ffed4783          	lbu	a5,-2(s10)
  8002be:	1d7d                	addi	s10,s10,-1
  8002c0:	ff379de3          	bne	a5,s3,8002ba <vprintfmt+0xce>
  8002c4:	b78d                	j	800226 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002c6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ca:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ce:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002d0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d8:	02d86463          	bltu	a6,a3,800300 <vprintfmt+0x114>
                ch = *fmt;
  8002dc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002e0:	002c169b          	slliw	a3,s8,0x2
  8002e4:	0186873b          	addw	a4,a3,s8
  8002e8:	0017171b          	slliw	a4,a4,0x1
  8002ec:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ee:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002f2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002f4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002fc:	fed870e3          	bgeu	a6,a3,8002dc <vprintfmt+0xf0>
            if (width < 0)
  800300:	f40ddce3          	bgez	s11,800258 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800304:	8de2                	mv	s11,s8
  800306:	5c7d                	li	s8,-1
  800308:	bf81                	j	800258 <vprintfmt+0x6c>
            if (width < 0)
  80030a:	fffdc693          	not	a3,s11
  80030e:	96fd                	srai	a3,a3,0x3f
  800310:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	00144603          	lbu	a2,1(s0)
  800318:	2d81                	sext.w	s11,s11
  80031a:	846a                	mv	s0,s10
            goto reswitch;
  80031c:	bf35                	j	800258 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80031e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800322:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800326:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800328:	846a                	mv	s0,s10
            goto process_precision;
  80032a:	bfd9                	j	800300 <vprintfmt+0x114>
    if (lflag >= 2) {
  80032c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80032e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800332:	01174463          	blt	a4,a7,80033a <vprintfmt+0x14e>
    else if (lflag) {
  800336:	1a088e63          	beqz	a7,8004f2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80033a:	000a3603          	ld	a2,0(s4)
  80033e:	46c1                	li	a3,16
  800340:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800342:	2781                	sext.w	a5,a5
  800344:	876e                	mv	a4,s11
  800346:	85a6                	mv	a1,s1
  800348:	854a                	mv	a0,s2
  80034a:	e37ff0ef          	jal	ra,800180 <printnum>
            break;
  80034e:	bde1                	j	800226 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800350:	000a2503          	lw	a0,0(s4)
  800354:	85a6                	mv	a1,s1
  800356:	0a21                	addi	s4,s4,8
  800358:	9902                	jalr	s2
            break;
  80035a:	b5f1                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80035c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800362:	01174463          	blt	a4,a7,80036a <vprintfmt+0x17e>
    else if (lflag) {
  800366:	18088163          	beqz	a7,8004e8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80036a:	000a3603          	ld	a2,0(s4)
  80036e:	46a9                	li	a3,10
  800370:	8a2e                	mv	s4,a1
  800372:	bfc1                	j	800342 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800374:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800378:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80037a:	846a                	mv	s0,s10
            goto reswitch;
  80037c:	bdf1                	j	800258 <vprintfmt+0x6c>
            putch(ch, putdat);
  80037e:	85a6                	mv	a1,s1
  800380:	02500513          	li	a0,37
  800384:	9902                	jalr	s2
            break;
  800386:	b545                	j	800226 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800388:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80038c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80038e:	846a                	mv	s0,s10
            goto reswitch;
  800390:	b5e1                	j	800258 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800392:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800394:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800398:	01174463          	blt	a4,a7,8003a0 <vprintfmt+0x1b4>
    else if (lflag) {
  80039c:	14088163          	beqz	a7,8004de <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8003a0:	000a3603          	ld	a2,0(s4)
  8003a4:	46a1                	li	a3,8
  8003a6:	8a2e                	mv	s4,a1
  8003a8:	bf69                	j	800342 <vprintfmt+0x156>
            putch('0', putdat);
  8003aa:	03000513          	li	a0,48
  8003ae:	85a6                	mv	a1,s1
  8003b0:	e03e                	sd	a5,0(sp)
  8003b2:	9902                	jalr	s2
            putch('x', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	07800513          	li	a0,120
  8003ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003bc:	0a21                	addi	s4,s4,8
            goto number;
  8003be:	6782                	ld	a5,0(sp)
  8003c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003c2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003c6:	bfb5                	j	800342 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c8:	000a3403          	ld	s0,0(s4)
  8003cc:	008a0713          	addi	a4,s4,8
  8003d0:	e03a                	sd	a4,0(sp)
  8003d2:	14040263          	beqz	s0,800516 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003d6:	0fb05763          	blez	s11,8004c4 <vprintfmt+0x2d8>
  8003da:	02d00693          	li	a3,45
  8003de:	0cd79163          	bne	a5,a3,8004a0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e2:	00044783          	lbu	a5,0(s0)
  8003e6:	0007851b          	sext.w	a0,a5
  8003ea:	cf85                	beqz	a5,800422 <vprintfmt+0x236>
  8003ec:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f4:	000c4563          	bltz	s8,8003fe <vprintfmt+0x212>
  8003f8:	3c7d                	addiw	s8,s8,-1
  8003fa:	036c0263          	beq	s8,s6,80041e <vprintfmt+0x232>
                    putch('?', putdat);
  8003fe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800400:	0e0c8e63          	beqz	s9,8004fc <vprintfmt+0x310>
  800404:	3781                	addiw	a5,a5,-32
  800406:	0ef47b63          	bgeu	s0,a5,8004fc <vprintfmt+0x310>
                    putch('?', putdat);
  80040a:	03f00513          	li	a0,63
  80040e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800410:	000a4783          	lbu	a5,0(s4)
  800414:	3dfd                	addiw	s11,s11,-1
  800416:	0a05                	addi	s4,s4,1
  800418:	0007851b          	sext.w	a0,a5
  80041c:	ffe1                	bnez	a5,8003f4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80041e:	01b05963          	blez	s11,800430 <vprintfmt+0x244>
  800422:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800424:	85a6                	mv	a1,s1
  800426:	02000513          	li	a0,32
  80042a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80042c:	fe0d9be3          	bnez	s11,800422 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800430:	6a02                	ld	s4,0(sp)
  800432:	bbd5                	j	800226 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800434:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800436:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80043a:	01174463          	blt	a4,a7,800442 <vprintfmt+0x256>
    else if (lflag) {
  80043e:	08088d63          	beqz	a7,8004d8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800442:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800446:	0a044d63          	bltz	s0,800500 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80044a:	8622                	mv	a2,s0
  80044c:	8a66                	mv	s4,s9
  80044e:	46a9                	li	a3,10
  800450:	bdcd                	j	800342 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800452:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800456:	4761                	li	a4,24
            err = va_arg(ap, int);
  800458:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80045a:	41f7d69b          	sraiw	a3,a5,0x1f
  80045e:	8fb5                	xor	a5,a5,a3
  800460:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800464:	02d74163          	blt	a4,a3,800486 <vprintfmt+0x29a>
  800468:	00369793          	slli	a5,a3,0x3
  80046c:	97de                	add	a5,a5,s7
  80046e:	639c                	ld	a5,0(a5)
  800470:	cb99                	beqz	a5,800486 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800472:	86be                	mv	a3,a5
  800474:	00000617          	auipc	a2,0x0
  800478:	29c60613          	addi	a2,a2,668 # 800710 <main+0x11a>
  80047c:	85a6                	mv	a1,s1
  80047e:	854a                	mv	a0,s2
  800480:	0ce000ef          	jal	ra,80054e <printfmt>
  800484:	b34d                	j	800226 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800486:	00000617          	auipc	a2,0x0
  80048a:	27a60613          	addi	a2,a2,634 # 800700 <main+0x10a>
  80048e:	85a6                	mv	a1,s1
  800490:	854a                	mv	a0,s2
  800492:	0bc000ef          	jal	ra,80054e <printfmt>
  800496:	bb41                	j	800226 <vprintfmt+0x3a>
                p = "(null)";
  800498:	00000417          	auipc	s0,0x0
  80049c:	26040413          	addi	s0,s0,608 # 8006f8 <main+0x102>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a0:	85e2                	mv	a1,s8
  8004a2:	8522                	mv	a0,s0
  8004a4:	e43e                	sd	a5,8(sp)
  8004a6:	cbfff0ef          	jal	ra,800164 <strnlen>
  8004aa:	40ad8dbb          	subw	s11,s11,a0
  8004ae:	01b05b63          	blez	s11,8004c4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004b2:	67a2                	ld	a5,8(sp)
  8004b4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ba:	85a6                	mv	a1,s1
  8004bc:	8552                	mv	a0,s4
  8004be:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	fe0d9ce3          	bnez	s11,8004b8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	00044783          	lbu	a5,0(s0)
  8004c8:	00140a13          	addi	s4,s0,1
  8004cc:	0007851b          	sext.w	a0,a5
  8004d0:	d3a5                	beqz	a5,800430 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004d2:	05e00413          	li	s0,94
  8004d6:	bf39                	j	8003f4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004d8:	000a2403          	lw	s0,0(s4)
  8004dc:	b7ad                	j	800446 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004de:	000a6603          	lwu	a2,0(s4)
  8004e2:	46a1                	li	a3,8
  8004e4:	8a2e                	mv	s4,a1
  8004e6:	bdb1                	j	800342 <vprintfmt+0x156>
  8004e8:	000a6603          	lwu	a2,0(s4)
  8004ec:	46a9                	li	a3,10
  8004ee:	8a2e                	mv	s4,a1
  8004f0:	bd89                	j	800342 <vprintfmt+0x156>
  8004f2:	000a6603          	lwu	a2,0(s4)
  8004f6:	46c1                	li	a3,16
  8004f8:	8a2e                	mv	s4,a1
  8004fa:	b5a1                	j	800342 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004fc:	9902                	jalr	s2
  8004fe:	bf09                	j	800410 <vprintfmt+0x224>
                putch('-', putdat);
  800500:	85a6                	mv	a1,s1
  800502:	02d00513          	li	a0,45
  800506:	e03e                	sd	a5,0(sp)
  800508:	9902                	jalr	s2
                num = -(long long)num;
  80050a:	6782                	ld	a5,0(sp)
  80050c:	8a66                	mv	s4,s9
  80050e:	40800633          	neg	a2,s0
  800512:	46a9                	li	a3,10
  800514:	b53d                	j	800342 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800516:	03b05163          	blez	s11,800538 <vprintfmt+0x34c>
  80051a:	02d00693          	li	a3,45
  80051e:	f6d79de3          	bne	a5,a3,800498 <vprintfmt+0x2ac>
                p = "(null)";
  800522:	00000417          	auipc	s0,0x0
  800526:	1d640413          	addi	s0,s0,470 # 8006f8 <main+0x102>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052a:	02800793          	li	a5,40
  80052e:	02800513          	li	a0,40
  800532:	00140a13          	addi	s4,s0,1
  800536:	bd6d                	j	8003f0 <vprintfmt+0x204>
  800538:	00000a17          	auipc	s4,0x0
  80053c:	1c1a0a13          	addi	s4,s4,449 # 8006f9 <main+0x103>
  800540:	02800513          	li	a0,40
  800544:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800548:	05e00413          	li	s0,94
  80054c:	b565                	j	8003f4 <vprintfmt+0x208>

000000000080054e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800550:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800554:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800556:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800558:	ec06                	sd	ra,24(sp)
  80055a:	f83a                	sd	a4,48(sp)
  80055c:	fc3e                	sd	a5,56(sp)
  80055e:	e0c2                	sd	a6,64(sp)
  800560:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800562:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800564:	c89ff0ef          	jal	ra,8001ec <vprintfmt>
}
  800568:	60e2                	ld	ra,24(sp)
  80056a:	6161                	addi	sp,sp,80
  80056c:	8082                	ret

000000000080056e <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  80056e:	1141                	addi	sp,sp,-16
  800570:	e406                	sd	ra,8(sp)
    yield();
  800572:	b6bff0ef          	jal	ra,8000dc <yield>
    yield();
  800576:	b67ff0ef          	jal	ra,8000dc <yield>
    yield();
  80057a:	b63ff0ef          	jal	ra,8000dc <yield>
    yield();
  80057e:	b5fff0ef          	jal	ra,8000dc <yield>
    yield();
  800582:	b5bff0ef          	jal	ra,8000dc <yield>
    yield();
}
  800586:	60a2                	ld	ra,8(sp)
  800588:	0141                	addi	sp,sp,16
    yield();
  80058a:	be89                	j	8000dc <yield>

000000000080058c <loop>:

int parent, pid1, pid2;

void
loop(void) {
  80058c:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  80058e:	00000517          	auipc	a0,0x0
  800592:	46a50513          	addi	a0,a0,1130 # 8009f8 <error_string+0xc8>
loop(void) {
  800596:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800598:	b8bff0ef          	jal	ra,800122 <cprintf>
    while (1);
  80059c:	a001                	j	80059c <loop+0x10>

000000000080059e <work>:
}

void
work(void) {
  80059e:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005a0:	00000517          	auipc	a0,0x0
  8005a4:	46850513          	addi	a0,a0,1128 # 800a08 <error_string+0xd8>
work(void) {
  8005a8:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005aa:	b79ff0ef          	jal	ra,800122 <cprintf>
    do_yield();
  8005ae:	fc1ff0ef          	jal	ra,80056e <do_yield>
    if (kill(parent) == 0) {
  8005b2:	00001517          	auipc	a0,0x1
  8005b6:	a4e52503          	lw	a0,-1458(a0) # 801000 <parent>
  8005ba:	b25ff0ef          	jal	ra,8000de <kill>
  8005be:	e105                	bnez	a0,8005de <work+0x40>
        cprintf("kill parent ok.\n");
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	45850513          	addi	a0,a0,1112 # 800a18 <error_string+0xe8>
  8005c8:	b5bff0ef          	jal	ra,800122 <cprintf>
        do_yield();
  8005cc:	fa3ff0ef          	jal	ra,80056e <do_yield>
        if (kill(pid1) == 0) {
  8005d0:	00001517          	auipc	a0,0x1
  8005d4:	a3452503          	lw	a0,-1484(a0) # 801004 <pid1>
  8005d8:	b07ff0ef          	jal	ra,8000de <kill>
  8005dc:	c501                	beqz	a0,8005e4 <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005de:	557d                	li	a0,-1
  8005e0:	ae3ff0ef          	jal	ra,8000c2 <exit>
            cprintf("kill child1 ok.\n");
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	44c50513          	addi	a0,a0,1100 # 800a30 <error_string+0x100>
  8005ec:	b37ff0ef          	jal	ra,800122 <cprintf>
            exit(0);
  8005f0:	4501                	li	a0,0
  8005f2:	ad1ff0ef          	jal	ra,8000c2 <exit>

00000000008005f6 <main>:
}

int
main(void) {
  8005f6:	1141                	addi	sp,sp,-16
  8005f8:	e406                	sd	ra,8(sp)
  8005fa:	e022                	sd	s0,0(sp)
    parent = getpid();
  8005fc:	ae5ff0ef          	jal	ra,8000e0 <getpid>
  800600:	00001797          	auipc	a5,0x1
  800604:	a0a7a023          	sw	a0,-1536(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800608:	00001417          	auipc	s0,0x1
  80060c:	9fc40413          	addi	s0,s0,-1540 # 801004 <pid1>
  800610:	ac9ff0ef          	jal	ra,8000d8 <fork>
  800614:	c008                	sw	a0,0(s0)
  800616:	c13d                	beqz	a0,80067c <main+0x86>
        loop();
    }

    assert(pid1 > 0);
  800618:	04a05263          	blez	a0,80065c <main+0x66>

    if ((pid2 = fork()) == 0) {
  80061c:	abdff0ef          	jal	ra,8000d8 <fork>
  800620:	00001797          	auipc	a5,0x1
  800624:	9ea7a423          	sw	a0,-1560(a5) # 801008 <pid2>
  800628:	c93d                	beqz	a0,80069e <main+0xa8>
        work();
    }
    if (pid2 > 0) {
  80062a:	04a05b63          	blez	a0,800680 <main+0x8a>
        cprintf("wait child 1.\n");
  80062e:	00000517          	auipc	a0,0x0
  800632:	45250513          	addi	a0,a0,1106 # 800a80 <error_string+0x150>
  800636:	aedff0ef          	jal	ra,800122 <cprintf>
        waitpid(pid1, NULL);
  80063a:	4008                	lw	a0,0(s0)
  80063c:	4581                	li	a1,0
  80063e:	a9dff0ef          	jal	ra,8000da <waitpid>
        panic("waitpid %d returns\n", pid1);
  800642:	4014                	lw	a3,0(s0)
  800644:	00000617          	auipc	a2,0x0
  800648:	44c60613          	addi	a2,a2,1100 # 800a90 <error_string+0x160>
  80064c:	03400593          	li	a1,52
  800650:	00000517          	auipc	a0,0x0
  800654:	42050513          	addi	a0,a0,1056 # 800a70 <error_string+0x140>
  800658:	9c9ff0ef          	jal	ra,800020 <__panic>
    assert(pid1 > 0);
  80065c:	00000697          	auipc	a3,0x0
  800660:	3ec68693          	addi	a3,a3,1004 # 800a48 <error_string+0x118>
  800664:	00000617          	auipc	a2,0x0
  800668:	3f460613          	addi	a2,a2,1012 # 800a58 <error_string+0x128>
  80066c:	02c00593          	li	a1,44
  800670:	00000517          	auipc	a0,0x0
  800674:	40050513          	addi	a0,a0,1024 # 800a70 <error_string+0x140>
  800678:	9a9ff0ef          	jal	ra,800020 <__panic>
        loop();
  80067c:	f11ff0ef          	jal	ra,80058c <loop>
    }
    else {
        kill(pid1);
  800680:	4008                	lw	a0,0(s0)
  800682:	a5dff0ef          	jal	ra,8000de <kill>
    }
    panic("FAIL: T.T\n");
  800686:	00000617          	auipc	a2,0x0
  80068a:	42260613          	addi	a2,a2,1058 # 800aa8 <error_string+0x178>
  80068e:	03900593          	li	a1,57
  800692:	00000517          	auipc	a0,0x0
  800696:	3de50513          	addi	a0,a0,990 # 800a70 <error_string+0x140>
  80069a:	987ff0ef          	jal	ra,800020 <__panic>
        work();
  80069e:	f01ff0ef          	jal	ra,80059e <work>
