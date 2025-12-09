
obj/__user_badarg.out:     file format elf64-littleriscv


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
  800034:	62050513          	addi	a0,a0,1568 # 800650 <main+0xf0>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0d0000ef          	jal	ra,800114 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0a8000ef          	jal	ra,8000f4 <vcprintf>
    cprintf("\n");
  800050:	00001517          	auipc	a0,0x1
  800054:	95850513          	addi	a0,a0,-1704 # 8009a8 <error_string+0xd0>
  800058:	0bc000ef          	jal	ra,800114 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	05a000ef          	jal	ra,8000b8 <exit>

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

00000000008000b2 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b2:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b4:	4579                	li	a0,30
  8000b6:	b775                	j	800062 <syscall>

00000000008000b8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000b8:	1141                	addi	sp,sp,-16
  8000ba:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000bc:	fe1ff0ef          	jal	ra,80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c0:	00000517          	auipc	a0,0x0
  8000c4:	5b050513          	addi	a0,a0,1456 # 800670 <main+0x110>
  8000c8:	04c000ef          	jal	ra,800114 <cprintf>
    while (1);
  8000cc:	a001                	j	8000cc <exit+0x14>

00000000008000ce <fork>:
}

int
fork(void) {
    return sys_fork();
  8000ce:	bfd1                	j	8000a2 <sys_fork>

00000000008000d0 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d0:	bfd9                	j	8000a6 <sys_wait>

00000000008000d2 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d2:	bff1                	j	8000ae <sys_yield>

00000000008000d4 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000d4:	076000ef          	jal	ra,80014a <umain>
1:  j 1b
  8000d8:	a001                	j	8000d8 <_start+0x4>

00000000008000da <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000da:	1141                	addi	sp,sp,-16
  8000dc:	e022                	sd	s0,0(sp)
  8000de:	e406                	sd	ra,8(sp)
  8000e0:	842e                	mv	s0,a1
    sys_putc(c);
  8000e2:	fd1ff0ef          	jal	ra,8000b2 <sys_putc>
    (*cnt) ++;
  8000e6:	401c                	lw	a5,0(s0)
}
  8000e8:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000ea:	2785                	addiw	a5,a5,1
  8000ec:	c01c                	sw	a5,0(s0)
}
  8000ee:	6402                	ld	s0,0(sp)
  8000f0:	0141                	addi	sp,sp,16
  8000f2:	8082                	ret

00000000008000f4 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f4:	1101                	addi	sp,sp,-32
  8000f6:	862a                	mv	a2,a0
  8000f8:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000fa:	00000517          	auipc	a0,0x0
  8000fe:	fe050513          	addi	a0,a0,-32 # 8000da <cputch>
  800102:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800104:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800106:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800108:	0d6000ef          	jal	ra,8001de <vprintfmt>
    return cnt;
}
  80010c:	60e2                	ld	ra,24(sp)
  80010e:	4532                	lw	a0,12(sp)
  800110:	6105                	addi	sp,sp,32
  800112:	8082                	ret

0000000000800114 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800114:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800116:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  80011a:	8e2a                	mv	t3,a0
  80011c:	f42e                	sd	a1,40(sp)
  80011e:	f832                	sd	a2,48(sp)
  800120:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800122:	00000517          	auipc	a0,0x0
  800126:	fb850513          	addi	a0,a0,-72 # 8000da <cputch>
  80012a:	004c                	addi	a1,sp,4
  80012c:	869a                	mv	a3,t1
  80012e:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  800130:	ec06                	sd	ra,24(sp)
  800132:	e0ba                	sd	a4,64(sp)
  800134:	e4be                	sd	a5,72(sp)
  800136:	e8c2                	sd	a6,80(sp)
  800138:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80013a:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  80013c:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013e:	0a0000ef          	jal	ra,8001de <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800142:	60e2                	ld	ra,24(sp)
  800144:	4512                	lw	a0,4(sp)
  800146:	6125                	addi	sp,sp,96
  800148:	8082                	ret

000000000080014a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014a:	1141                	addi	sp,sp,-16
  80014c:	e406                	sd	ra,8(sp)
    int ret = main();
  80014e:	412000ef          	jal	ra,800560 <main>
    exit(ret);
  800152:	f67ff0ef          	jal	ra,8000b8 <exit>

0000000000800156 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800156:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800158:	e589                	bnez	a1,800162 <strnlen+0xc>
  80015a:	a811                	j	80016e <strnlen+0x18>
        cnt ++;
  80015c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80015e:	00f58863          	beq	a1,a5,80016e <strnlen+0x18>
  800162:	00f50733          	add	a4,a0,a5
  800166:	00074703          	lbu	a4,0(a4)
  80016a:	fb6d                	bnez	a4,80015c <strnlen+0x6>
  80016c:	85be                	mv	a1,a5
    }
    return cnt;
}
  80016e:	852e                	mv	a0,a1
  800170:	8082                	ret

0000000000800172 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800172:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800178:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	f022                	sd	s0,32(sp)
  800184:	ec26                	sd	s1,24(sp)
  800186:	e84a                	sd	s2,16(sp)
  800188:	f406                	sd	ra,40(sp)
  80018a:	e44e                	sd	s3,8(sp)
  80018c:	84aa                	mv	s1,a0
  80018e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800190:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800194:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800196:	03067e63          	bgeu	a2,a6,8001d2 <printnum+0x60>
  80019a:	89be                	mv	s3,a5
        while (-- width > 0)
  80019c:	00805763          	blez	s0,8001aa <printnum+0x38>
  8001a0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a2:	85ca                	mv	a1,s2
  8001a4:	854e                	mv	a0,s3
  8001a6:	9482                	jalr	s1
        while (-- width > 0)
  8001a8:	fc65                	bnez	s0,8001a0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	1a02                	slli	s4,s4,0x20
  8001ac:	00000797          	auipc	a5,0x0
  8001b0:	4dc78793          	addi	a5,a5,1244 # 800688 <main+0x128>
  8001b4:	020a5a13          	srli	s4,s4,0x20
  8001b8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ba:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001bc:	000a4503          	lbu	a0,0(s4)
}
  8001c0:	70a2                	ld	ra,40(sp)
  8001c2:	69a2                	ld	s3,8(sp)
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
  8001d8:	f9bff0ef          	jal	ra,800172 <printnum>
  8001dc:	b7f9                	j	8001aa <printnum+0x38>

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
  8001ec:	fc5e                	sd	s7,56(sp)
  8001ee:	f06a                	sd	s10,32(sp)
  8001f0:	fc86                	sd	ra,120(sp)
  8001f2:	f8a2                	sd	s0,112(sp)
  8001f4:	f862                	sd	s8,48(sp)
  8001f6:	f466                	sd	s9,40(sp)
  8001f8:	ec6e                	sd	s11,24(sp)
  8001fa:	892a                	mv	s2,a0
  8001fc:	84ae                	mv	s1,a1
  8001fe:	8d32                	mv	s10,a2
  800200:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800206:	5b7d                	li	s6,-1
  800208:	00000a97          	auipc	s5,0x0
  80020c:	4b4a8a93          	addi	s5,s5,1204 # 8006bc <main+0x15c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800210:	00000b97          	auipc	s7,0x0
  800214:	6c8b8b93          	addi	s7,s7,1736 # 8008d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	000d4503          	lbu	a0,0(s10)
  80021c:	001d0413          	addi	s0,s10,1
  800220:	01350a63          	beq	a0,s3,800234 <vprintfmt+0x56>
            if (ch == '\0') {
  800224:	c121                	beqz	a0,800264 <vprintfmt+0x86>
            putch(ch, putdat);
  800226:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80022a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022c:	fff44503          	lbu	a0,-1(s0)
  800230:	ff351ae3          	bne	a0,s3,800224 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800234:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800238:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023c:	4c81                	li	s9,0
  80023e:	4881                	li	a7,0
        width = precision = -1;
  800240:	5c7d                	li	s8,-1
  800242:	5dfd                	li	s11,-1
  800244:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800248:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  80024a:	fdd6059b          	addiw	a1,a2,-35
  80024e:	0ff5f593          	zext.b	a1,a1
  800252:	00140d13          	addi	s10,s0,1
  800256:	04b56263          	bltu	a0,a1,80029a <vprintfmt+0xbc>
  80025a:	058a                	slli	a1,a1,0x2
  80025c:	95d6                	add	a1,a1,s5
  80025e:	4194                	lw	a3,0(a1)
  800260:	96d6                	add	a3,a3,s5
  800262:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800264:	70e6                	ld	ra,120(sp)
  800266:	7446                	ld	s0,112(sp)
  800268:	74a6                	ld	s1,104(sp)
  80026a:	7906                	ld	s2,96(sp)
  80026c:	69e6                	ld	s3,88(sp)
  80026e:	6a46                	ld	s4,80(sp)
  800270:	6aa6                	ld	s5,72(sp)
  800272:	6b06                	ld	s6,64(sp)
  800274:	7be2                	ld	s7,56(sp)
  800276:	7c42                	ld	s8,48(sp)
  800278:	7ca2                	ld	s9,40(sp)
  80027a:	7d02                	ld	s10,32(sp)
  80027c:	6de2                	ld	s11,24(sp)
  80027e:	6109                	addi	sp,sp,128
  800280:	8082                	ret
            padc = '0';
  800282:	87b2                	mv	a5,a2
            goto reswitch;
  800284:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800288:	846a                	mv	s0,s10
  80028a:	00140d13          	addi	s10,s0,1
  80028e:	fdd6059b          	addiw	a1,a2,-35
  800292:	0ff5f593          	zext.b	a1,a1
  800296:	fcb572e3          	bgeu	a0,a1,80025a <vprintfmt+0x7c>
            putch('%', putdat);
  80029a:	85a6                	mv	a1,s1
  80029c:	02500513          	li	a0,37
  8002a0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002a2:	fff44783          	lbu	a5,-1(s0)
  8002a6:	8d22                	mv	s10,s0
  8002a8:	f73788e3          	beq	a5,s3,800218 <vprintfmt+0x3a>
  8002ac:	ffed4783          	lbu	a5,-2(s10)
  8002b0:	1d7d                	addi	s10,s10,-1
  8002b2:	ff379de3          	bne	a5,s3,8002ac <vprintfmt+0xce>
  8002b6:	b78d                	j	800218 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002b8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002bc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002c2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002c6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ca:	02d86463          	bltu	a6,a3,8002f2 <vprintfmt+0x114>
                ch = *fmt;
  8002ce:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002d2:	002c169b          	slliw	a3,s8,0x2
  8002d6:	0186873b          	addw	a4,a3,s8
  8002da:	0017171b          	slliw	a4,a4,0x1
  8002de:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002e0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002e4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002ea:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ee:	fed870e3          	bgeu	a6,a3,8002ce <vprintfmt+0xf0>
            if (width < 0)
  8002f2:	f40ddce3          	bgez	s11,80024a <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002f6:	8de2                	mv	s11,s8
  8002f8:	5c7d                	li	s8,-1
  8002fa:	bf81                	j	80024a <vprintfmt+0x6c>
            if (width < 0)
  8002fc:	fffdc693          	not	a3,s11
  800300:	96fd                	srai	a3,a3,0x3f
  800302:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	00144603          	lbu	a2,1(s0)
  80030a:	2d81                	sext.w	s11,s11
  80030c:	846a                	mv	s0,s10
            goto reswitch;
  80030e:	bf35                	j	80024a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800310:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800318:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80031a:	846a                	mv	s0,s10
            goto process_precision;
  80031c:	bfd9                	j	8002f2 <vprintfmt+0x114>
    if (lflag >= 2) {
  80031e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800320:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800324:	01174463          	blt	a4,a7,80032c <vprintfmt+0x14e>
    else if (lflag) {
  800328:	1a088e63          	beqz	a7,8004e4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80032c:	000a3603          	ld	a2,0(s4)
  800330:	46c1                	li	a3,16
  800332:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800334:	2781                	sext.w	a5,a5
  800336:	876e                	mv	a4,s11
  800338:	85a6                	mv	a1,s1
  80033a:	854a                	mv	a0,s2
  80033c:	e37ff0ef          	jal	ra,800172 <printnum>
            break;
  800340:	bde1                	j	800218 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800342:	000a2503          	lw	a0,0(s4)
  800346:	85a6                	mv	a1,s1
  800348:	0a21                	addi	s4,s4,8
  80034a:	9902                	jalr	s2
            break;
  80034c:	b5f1                	j	800218 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80034e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800350:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800354:	01174463          	blt	a4,a7,80035c <vprintfmt+0x17e>
    else if (lflag) {
  800358:	18088163          	beqz	a7,8004da <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80035c:	000a3603          	ld	a2,0(s4)
  800360:	46a9                	li	a3,10
  800362:	8a2e                	mv	s4,a1
  800364:	bfc1                	j	800334 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800366:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80036a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	846a                	mv	s0,s10
            goto reswitch;
  80036e:	bdf1                	j	80024a <vprintfmt+0x6c>
            putch(ch, putdat);
  800370:	85a6                	mv	a1,s1
  800372:	02500513          	li	a0,37
  800376:	9902                	jalr	s2
            break;
  800378:	b545                	j	800218 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80037a:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80037e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800380:	846a                	mv	s0,s10
            goto reswitch;
  800382:	b5e1                	j	80024a <vprintfmt+0x6c>
    if (lflag >= 2) {
  800384:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800386:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80038a:	01174463          	blt	a4,a7,800392 <vprintfmt+0x1b4>
    else if (lflag) {
  80038e:	14088163          	beqz	a7,8004d0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800392:	000a3603          	ld	a2,0(s4)
  800396:	46a1                	li	a3,8
  800398:	8a2e                	mv	s4,a1
  80039a:	bf69                	j	800334 <vprintfmt+0x156>
            putch('0', putdat);
  80039c:	03000513          	li	a0,48
  8003a0:	85a6                	mv	a1,s1
  8003a2:	e03e                	sd	a5,0(sp)
  8003a4:	9902                	jalr	s2
            putch('x', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	07800513          	li	a0,120
  8003ac:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ae:	0a21                	addi	s4,s4,8
            goto number;
  8003b0:	6782                	ld	a5,0(sp)
  8003b2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003b4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003b8:	bfb5                	j	800334 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ba:	000a3403          	ld	s0,0(s4)
  8003be:	008a0713          	addi	a4,s4,8
  8003c2:	e03a                	sd	a4,0(sp)
  8003c4:	14040263          	beqz	s0,800508 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003c8:	0fb05763          	blez	s11,8004b6 <vprintfmt+0x2d8>
  8003cc:	02d00693          	li	a3,45
  8003d0:	0cd79163          	bne	a5,a3,800492 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d4:	00044783          	lbu	a5,0(s0)
  8003d8:	0007851b          	sext.w	a0,a5
  8003dc:	cf85                	beqz	a5,800414 <vprintfmt+0x236>
  8003de:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e6:	000c4563          	bltz	s8,8003f0 <vprintfmt+0x212>
  8003ea:	3c7d                	addiw	s8,s8,-1
  8003ec:	036c0263          	beq	s8,s6,800410 <vprintfmt+0x232>
                    putch('?', putdat);
  8003f0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f2:	0e0c8e63          	beqz	s9,8004ee <vprintfmt+0x310>
  8003f6:	3781                	addiw	a5,a5,-32
  8003f8:	0ef47b63          	bgeu	s0,a5,8004ee <vprintfmt+0x310>
                    putch('?', putdat);
  8003fc:	03f00513          	li	a0,63
  800400:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800402:	000a4783          	lbu	a5,0(s4)
  800406:	3dfd                	addiw	s11,s11,-1
  800408:	0a05                	addi	s4,s4,1
  80040a:	0007851b          	sext.w	a0,a5
  80040e:	ffe1                	bnez	a5,8003e6 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800410:	01b05963          	blez	s11,800422 <vprintfmt+0x244>
  800414:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800416:	85a6                	mv	a1,s1
  800418:	02000513          	li	a0,32
  80041c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80041e:	fe0d9be3          	bnez	s11,800414 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800422:	6a02                	ld	s4,0(sp)
  800424:	bbd5                	j	800218 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800426:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800428:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80042c:	01174463          	blt	a4,a7,800434 <vprintfmt+0x256>
    else if (lflag) {
  800430:	08088d63          	beqz	a7,8004ca <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800434:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800438:	0a044d63          	bltz	s0,8004f2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80043c:	8622                	mv	a2,s0
  80043e:	8a66                	mv	s4,s9
  800440:	46a9                	li	a3,10
  800442:	bdcd                	j	800334 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800444:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800448:	4761                	li	a4,24
            err = va_arg(ap, int);
  80044a:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80044c:	41f7d69b          	sraiw	a3,a5,0x1f
  800450:	8fb5                	xor	a5,a5,a3
  800452:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800456:	02d74163          	blt	a4,a3,800478 <vprintfmt+0x29a>
  80045a:	00369793          	slli	a5,a3,0x3
  80045e:	97de                	add	a5,a5,s7
  800460:	639c                	ld	a5,0(a5)
  800462:	cb99                	beqz	a5,800478 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800464:	86be                	mv	a3,a5
  800466:	00000617          	auipc	a2,0x0
  80046a:	25260613          	addi	a2,a2,594 # 8006b8 <main+0x158>
  80046e:	85a6                	mv	a1,s1
  800470:	854a                	mv	a0,s2
  800472:	0ce000ef          	jal	ra,800540 <printfmt>
  800476:	b34d                	j	800218 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800478:	00000617          	auipc	a2,0x0
  80047c:	23060613          	addi	a2,a2,560 # 8006a8 <main+0x148>
  800480:	85a6                	mv	a1,s1
  800482:	854a                	mv	a0,s2
  800484:	0bc000ef          	jal	ra,800540 <printfmt>
  800488:	bb41                	j	800218 <vprintfmt+0x3a>
                p = "(null)";
  80048a:	00000417          	auipc	s0,0x0
  80048e:	21640413          	addi	s0,s0,534 # 8006a0 <main+0x140>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800492:	85e2                	mv	a1,s8
  800494:	8522                	mv	a0,s0
  800496:	e43e                	sd	a5,8(sp)
  800498:	cbfff0ef          	jal	ra,800156 <strnlen>
  80049c:	40ad8dbb          	subw	s11,s11,a0
  8004a0:	01b05b63          	blez	s11,8004b6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004a4:	67a2                	ld	a5,8(sp)
  8004a6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ac:	85a6                	mv	a1,s1
  8004ae:	8552                	mv	a0,s4
  8004b0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	fe0d9ce3          	bnez	s11,8004aa <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b6:	00044783          	lbu	a5,0(s0)
  8004ba:	00140a13          	addi	s4,s0,1
  8004be:	0007851b          	sext.w	a0,a5
  8004c2:	d3a5                	beqz	a5,800422 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004c4:	05e00413          	li	s0,94
  8004c8:	bf39                	j	8003e6 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004ca:	000a2403          	lw	s0,0(s4)
  8004ce:	b7ad                	j	800438 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004d0:	000a6603          	lwu	a2,0(s4)
  8004d4:	46a1                	li	a3,8
  8004d6:	8a2e                	mv	s4,a1
  8004d8:	bdb1                	j	800334 <vprintfmt+0x156>
  8004da:	000a6603          	lwu	a2,0(s4)
  8004de:	46a9                	li	a3,10
  8004e0:	8a2e                	mv	s4,a1
  8004e2:	bd89                	j	800334 <vprintfmt+0x156>
  8004e4:	000a6603          	lwu	a2,0(s4)
  8004e8:	46c1                	li	a3,16
  8004ea:	8a2e                	mv	s4,a1
  8004ec:	b5a1                	j	800334 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004ee:	9902                	jalr	s2
  8004f0:	bf09                	j	800402 <vprintfmt+0x224>
                putch('-', putdat);
  8004f2:	85a6                	mv	a1,s1
  8004f4:	02d00513          	li	a0,45
  8004f8:	e03e                	sd	a5,0(sp)
  8004fa:	9902                	jalr	s2
                num = -(long long)num;
  8004fc:	6782                	ld	a5,0(sp)
  8004fe:	8a66                	mv	s4,s9
  800500:	40800633          	neg	a2,s0
  800504:	46a9                	li	a3,10
  800506:	b53d                	j	800334 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800508:	03b05163          	blez	s11,80052a <vprintfmt+0x34c>
  80050c:	02d00693          	li	a3,45
  800510:	f6d79de3          	bne	a5,a3,80048a <vprintfmt+0x2ac>
                p = "(null)";
  800514:	00000417          	auipc	s0,0x0
  800518:	18c40413          	addi	s0,s0,396 # 8006a0 <main+0x140>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051c:	02800793          	li	a5,40
  800520:	02800513          	li	a0,40
  800524:	00140a13          	addi	s4,s0,1
  800528:	bd6d                	j	8003e2 <vprintfmt+0x204>
  80052a:	00000a17          	auipc	s4,0x0
  80052e:	177a0a13          	addi	s4,s4,375 # 8006a1 <main+0x141>
  800532:	02800513          	li	a0,40
  800536:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  80053a:	05e00413          	li	s0,94
  80053e:	b565                	j	8003e6 <vprintfmt+0x208>

0000000000800540 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800540:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800542:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800546:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800548:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054a:	ec06                	sd	ra,24(sp)
  80054c:	f83a                	sd	a4,48(sp)
  80054e:	fc3e                	sd	a5,56(sp)
  800550:	e0c2                	sd	a6,64(sp)
  800552:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800554:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800556:	c89ff0ef          	jal	ra,8001de <vprintfmt>
}
  80055a:	60e2                	ld	ra,24(sp)
  80055c:	6161                	addi	sp,sp,80
  80055e:	8082                	ret

0000000000800560 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800560:	1101                	addi	sp,sp,-32
  800562:	ec06                	sd	ra,24(sp)
  800564:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800566:	b69ff0ef          	jal	ra,8000ce <fork>
  80056a:	c169                	beqz	a0,80062c <main+0xcc>
  80056c:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80056e:	0aa05063          	blez	a0,80060e <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800572:	4581                	li	a1,0
  800574:	557d                	li	a0,-1
  800576:	b5bff0ef          	jal	ra,8000d0 <waitpid>
  80057a:	c93d                	beqz	a0,8005f0 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  80057c:	458d                	li	a1,3
  80057e:	05fa                	slli	a1,a1,0x1e
  800580:	8522                	mv	a0,s0
  800582:	b4fff0ef          	jal	ra,8000d0 <waitpid>
  800586:	c531                	beqz	a0,8005d2 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800588:	006c                	addi	a1,sp,12
  80058a:	8522                	mv	a0,s0
  80058c:	b45ff0ef          	jal	ra,8000d0 <waitpid>
  800590:	e115                	bnez	a0,8005b4 <main+0x54>
  800592:	4732                	lw	a4,12(sp)
  800594:	67b1                	lui	a5,0xc
  800596:	eaf78793          	addi	a5,a5,-337 # beaf <__panic-0x7f4171>
  80059a:	00f71d63          	bne	a4,a5,8005b4 <main+0x54>
    cprintf("badarg pass.\n");
  80059e:	00000517          	auipc	a0,0x0
  8005a2:	4ba50513          	addi	a0,a0,1210 # 800a58 <error_string+0x180>
  8005a6:	b6fff0ef          	jal	ra,800114 <cprintf>
    return 0;
}
  8005aa:	60e2                	ld	ra,24(sp)
  8005ac:	6442                	ld	s0,16(sp)
  8005ae:	4501                	li	a0,0
  8005b0:	6105                	addi	sp,sp,32
  8005b2:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005b4:	00000697          	auipc	a3,0x0
  8005b8:	46c68693          	addi	a3,a3,1132 # 800a20 <error_string+0x148>
  8005bc:	00000617          	auipc	a2,0x0
  8005c0:	3fc60613          	addi	a2,a2,1020 # 8009b8 <error_string+0xe0>
  8005c4:	45c9                	li	a1,18
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	40a50513          	addi	a0,a0,1034 # 8009d0 <error_string+0xf8>
  8005ce:	a53ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	42668693          	addi	a3,a3,1062 # 8009f8 <error_string+0x120>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	3de60613          	addi	a2,a2,990 # 8009b8 <error_string+0xe0>
  8005e2:	45c5                	li	a1,17
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	3ec50513          	addi	a0,a0,1004 # 8009d0 <error_string+0xf8>
  8005ec:	a35ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	3f068693          	addi	a3,a3,1008 # 8009e0 <error_string+0x108>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	3c060613          	addi	a2,a2,960 # 8009b8 <error_string+0xe0>
  800600:	45c1                	li	a1,16
  800602:	00000517          	auipc	a0,0x0
  800606:	3ce50513          	addi	a0,a0,974 # 8009d0 <error_string+0xf8>
  80060a:	a17ff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  80060e:	00000697          	auipc	a3,0x0
  800612:	3a268693          	addi	a3,a3,930 # 8009b0 <error_string+0xd8>
  800616:	00000617          	auipc	a2,0x0
  80061a:	3a260613          	addi	a2,a2,930 # 8009b8 <error_string+0xe0>
  80061e:	45bd                	li	a1,15
  800620:	00000517          	auipc	a0,0x0
  800624:	3b050513          	addi	a0,a0,944 # 8009d0 <error_string+0xf8>
  800628:	9f9ff0ef          	jal	ra,800020 <__panic>
        cprintf("fork ok.\n");
  80062c:	00000517          	auipc	a0,0x0
  800630:	37450513          	addi	a0,a0,884 # 8009a0 <error_string+0xc8>
  800634:	ae1ff0ef          	jal	ra,800114 <cprintf>
  800638:	4429                	li	s0,10
        for (i = 0; i < 10; i ++) {
  80063a:	347d                	addiw	s0,s0,-1
            yield();
  80063c:	a97ff0ef          	jal	ra,8000d2 <yield>
        for (i = 0; i < 10; i ++) {
  800640:	fc6d                	bnez	s0,80063a <main+0xda>
        exit(0xbeaf);
  800642:	6531                	lui	a0,0xc
  800644:	eaf50513          	addi	a0,a0,-337 # beaf <__panic-0x7f4171>
  800648:	a71ff0ef          	jal	ra,8000b8 <exit>
