
obj/__user_forktest.out:     file format elf64-littleriscv


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
  800034:	5d850513          	addi	a0,a0,1496 # 800608 <main+0xaa>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0ce000ef          	jal	ra,800112 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0a6000ef          	jal	ra,8000f2 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	5d850513          	addi	a0,a0,1496 # 800628 <main+0xca>
  800058:	0ba000ef          	jal	ra,800112 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	056000ef          	jal	ra,8000b4 <exit>

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

00000000008000ae <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000ae:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b0:	4579                	li	a0,30
  8000b2:	bf45                	j	800062 <syscall>

00000000008000b4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000b4:	1141                	addi	sp,sp,-16
  8000b6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000b8:	fe5ff0ef          	jal	ra,80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000bc:	00000517          	auipc	a0,0x0
  8000c0:	57450513          	addi	a0,a0,1396 # 800630 <main+0xd2>
  8000c4:	04e000ef          	jal	ra,800112 <cprintf>
    while (1);
  8000c8:	a001                	j	8000c8 <exit+0x14>

00000000008000ca <fork>:
}

int
fork(void) {
    return sys_fork();
  8000ca:	bfe1                	j	8000a2 <sys_fork>

00000000008000cc <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000cc:	4581                	li	a1,0
  8000ce:	4501                	li	a0,0
  8000d0:	bfd9                	j	8000a6 <sys_wait>

00000000008000d2 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000d2:	076000ef          	jal	ra,800148 <umain>
1:  j 1b
  8000d6:	a001                	j	8000d6 <_start+0x4>

00000000008000d8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000d8:	1141                	addi	sp,sp,-16
  8000da:	e022                	sd	s0,0(sp)
  8000dc:	e406                	sd	ra,8(sp)
  8000de:	842e                	mv	s0,a1
    sys_putc(c);
  8000e0:	fcfff0ef          	jal	ra,8000ae <sys_putc>
    (*cnt) ++;
  8000e4:	401c                	lw	a5,0(s0)
}
  8000e6:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000e8:	2785                	addiw	a5,a5,1
  8000ea:	c01c                	sw	a5,0(s0)
}
  8000ec:	6402                	ld	s0,0(sp)
  8000ee:	0141                	addi	sp,sp,16
  8000f0:	8082                	ret

00000000008000f2 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f2:	1101                	addi	sp,sp,-32
  8000f4:	862a                	mv	a2,a0
  8000f6:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f8:	00000517          	auipc	a0,0x0
  8000fc:	fe050513          	addi	a0,a0,-32 # 8000d8 <cputch>
  800100:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800102:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800104:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800106:	0d6000ef          	jal	ra,8001dc <vprintfmt>
    return cnt;
}
  80010a:	60e2                	ld	ra,24(sp)
  80010c:	4532                	lw	a0,12(sp)
  80010e:	6105                	addi	sp,sp,32
  800110:	8082                	ret

0000000000800112 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800112:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800114:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800118:	8e2a                	mv	t3,a0
  80011a:	f42e                	sd	a1,40(sp)
  80011c:	f832                	sd	a2,48(sp)
  80011e:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800120:	00000517          	auipc	a0,0x0
  800124:	fb850513          	addi	a0,a0,-72 # 8000d8 <cputch>
  800128:	004c                	addi	a1,sp,4
  80012a:	869a                	mv	a3,t1
  80012c:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80012e:	ec06                	sd	ra,24(sp)
  800130:	e0ba                	sd	a4,64(sp)
  800132:	e4be                	sd	a5,72(sp)
  800134:	e8c2                	sd	a6,80(sp)
  800136:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800138:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  80013a:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013c:	0a0000ef          	jal	ra,8001dc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800140:	60e2                	ld	ra,24(sp)
  800142:	4512                	lw	a0,4(sp)
  800144:	6125                	addi	sp,sp,96
  800146:	8082                	ret

0000000000800148 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800148:	1141                	addi	sp,sp,-16
  80014a:	e406                	sd	ra,8(sp)
    int ret = main();
  80014c:	412000ef          	jal	ra,80055e <main>
    exit(ret);
  800150:	f65ff0ef          	jal	ra,8000b4 <exit>

0000000000800154 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800154:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800156:	e589                	bnez	a1,800160 <strnlen+0xc>
  800158:	a811                	j	80016c <strnlen+0x18>
        cnt ++;
  80015a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80015c:	00f58863          	beq	a1,a5,80016c <strnlen+0x18>
  800160:	00f50733          	add	a4,a0,a5
  800164:	00074703          	lbu	a4,0(a4)
  800168:	fb6d                	bnez	a4,80015a <strnlen+0x6>
  80016a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80016c:	852e                	mv	a0,a1
  80016e:	8082                	ret

0000000000800170 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800170:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800176:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800180:	f022                	sd	s0,32(sp)
  800182:	ec26                	sd	s1,24(sp)
  800184:	e84a                	sd	s2,16(sp)
  800186:	f406                	sd	ra,40(sp)
  800188:	e44e                	sd	s3,8(sp)
  80018a:	84aa                	mv	s1,a0
  80018c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800192:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800194:	03067e63          	bgeu	a2,a6,8001d0 <printnum+0x60>
  800198:	89be                	mv	s3,a5
        while (-- width > 0)
  80019a:	00805763          	blez	s0,8001a8 <printnum+0x38>
  80019e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a0:	85ca                	mv	a1,s2
  8001a2:	854e                	mv	a0,s3
  8001a4:	9482                	jalr	s1
        while (-- width > 0)
  8001a6:	fc65                	bnez	s0,80019e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	1a02                	slli	s4,s4,0x20
  8001aa:	00000797          	auipc	a5,0x0
  8001ae:	49e78793          	addi	a5,a5,1182 # 800648 <main+0xea>
  8001b2:	020a5a13          	srli	s4,s4,0x20
  8001b6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	000a4503          	lbu	a0,0(s4)
}
  8001be:	70a2                	ld	ra,40(sp)
  8001c0:	69a2                	ld	s3,8(sp)
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
  8001d6:	f9bff0ef          	jal	ra,800170 <printnum>
  8001da:	b7f9                	j	8001a8 <printnum+0x38>

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
  8001ea:	fc5e                	sd	s7,56(sp)
  8001ec:	f06a                	sd	s10,32(sp)
  8001ee:	fc86                	sd	ra,120(sp)
  8001f0:	f8a2                	sd	s0,112(sp)
  8001f2:	f862                	sd	s8,48(sp)
  8001f4:	f466                	sd	s9,40(sp)
  8001f6:	ec6e                	sd	s11,24(sp)
  8001f8:	892a                	mv	s2,a0
  8001fa:	84ae                	mv	s1,a1
  8001fc:	8d32                	mv	s10,a2
  8001fe:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800204:	5b7d                	li	s6,-1
  800206:	00000a97          	auipc	s5,0x0
  80020a:	476a8a93          	addi	s5,s5,1142 # 80067c <main+0x11e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80020e:	00000b97          	auipc	s7,0x0
  800212:	68ab8b93          	addi	s7,s7,1674 # 800898 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800216:	000d4503          	lbu	a0,0(s10)
  80021a:	001d0413          	addi	s0,s10,1
  80021e:	01350a63          	beq	a0,s3,800232 <vprintfmt+0x56>
            if (ch == '\0') {
  800222:	c121                	beqz	a0,800262 <vprintfmt+0x86>
            putch(ch, putdat);
  800224:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800228:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022a:	fff44503          	lbu	a0,-1(s0)
  80022e:	ff351ae3          	bne	a0,s3,800222 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800236:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023a:	4c81                	li	s9,0
  80023c:	4881                	li	a7,0
        width = precision = -1;
  80023e:	5c7d                	li	s8,-1
  800240:	5dfd                	li	s11,-1
  800242:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800246:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800248:	fdd6059b          	addiw	a1,a2,-35
  80024c:	0ff5f593          	zext.b	a1,a1
  800250:	00140d13          	addi	s10,s0,1
  800254:	04b56263          	bltu	a0,a1,800298 <vprintfmt+0xbc>
  800258:	058a                	slli	a1,a1,0x2
  80025a:	95d6                	add	a1,a1,s5
  80025c:	4194                	lw	a3,0(a1)
  80025e:	96d6                	add	a3,a3,s5
  800260:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800262:	70e6                	ld	ra,120(sp)
  800264:	7446                	ld	s0,112(sp)
  800266:	74a6                	ld	s1,104(sp)
  800268:	7906                	ld	s2,96(sp)
  80026a:	69e6                	ld	s3,88(sp)
  80026c:	6a46                	ld	s4,80(sp)
  80026e:	6aa6                	ld	s5,72(sp)
  800270:	6b06                	ld	s6,64(sp)
  800272:	7be2                	ld	s7,56(sp)
  800274:	7c42                	ld	s8,48(sp)
  800276:	7ca2                	ld	s9,40(sp)
  800278:	7d02                	ld	s10,32(sp)
  80027a:	6de2                	ld	s11,24(sp)
  80027c:	6109                	addi	sp,sp,128
  80027e:	8082                	ret
            padc = '0';
  800280:	87b2                	mv	a5,a2
            goto reswitch;
  800282:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	846a                	mv	s0,s10
  800288:	00140d13          	addi	s10,s0,1
  80028c:	fdd6059b          	addiw	a1,a2,-35
  800290:	0ff5f593          	zext.b	a1,a1
  800294:	fcb572e3          	bgeu	a0,a1,800258 <vprintfmt+0x7c>
            putch('%', putdat);
  800298:	85a6                	mv	a1,s1
  80029a:	02500513          	li	a0,37
  80029e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002a0:	fff44783          	lbu	a5,-1(s0)
  8002a4:	8d22                	mv	s10,s0
  8002a6:	f73788e3          	beq	a5,s3,800216 <vprintfmt+0x3a>
  8002aa:	ffed4783          	lbu	a5,-2(s10)
  8002ae:	1d7d                	addi	s10,s10,-1
  8002b0:	ff379de3          	bne	a5,s3,8002aa <vprintfmt+0xce>
  8002b4:	b78d                	j	800216 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002b6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ba:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002be:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002c0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002c4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002c8:	02d86463          	bltu	a6,a3,8002f0 <vprintfmt+0x114>
                ch = *fmt;
  8002cc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002d0:	002c169b          	slliw	a3,s8,0x2
  8002d4:	0186873b          	addw	a4,a3,s8
  8002d8:	0017171b          	slliw	a4,a4,0x1
  8002dc:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002de:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002e2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002e8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ec:	fed870e3          	bgeu	a6,a3,8002cc <vprintfmt+0xf0>
            if (width < 0)
  8002f0:	f40ddce3          	bgez	s11,800248 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002f4:	8de2                	mv	s11,s8
  8002f6:	5c7d                	li	s8,-1
  8002f8:	bf81                	j	800248 <vprintfmt+0x6c>
            if (width < 0)
  8002fa:	fffdc693          	not	a3,s11
  8002fe:	96fd                	srai	a3,a3,0x3f
  800300:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	00144603          	lbu	a2,1(s0)
  800308:	2d81                	sext.w	s11,s11
  80030a:	846a                	mv	s0,s10
            goto reswitch;
  80030c:	bf35                	j	800248 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80030e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800316:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800318:	846a                	mv	s0,s10
            goto process_precision;
  80031a:	bfd9                	j	8002f0 <vprintfmt+0x114>
    if (lflag >= 2) {
  80031c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800322:	01174463          	blt	a4,a7,80032a <vprintfmt+0x14e>
    else if (lflag) {
  800326:	1a088e63          	beqz	a7,8004e2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80032a:	000a3603          	ld	a2,0(s4)
  80032e:	46c1                	li	a3,16
  800330:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800332:	2781                	sext.w	a5,a5
  800334:	876e                	mv	a4,s11
  800336:	85a6                	mv	a1,s1
  800338:	854a                	mv	a0,s2
  80033a:	e37ff0ef          	jal	ra,800170 <printnum>
            break;
  80033e:	bde1                	j	800216 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800340:	000a2503          	lw	a0,0(s4)
  800344:	85a6                	mv	a1,s1
  800346:	0a21                	addi	s4,s4,8
  800348:	9902                	jalr	s2
            break;
  80034a:	b5f1                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80034c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80034e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800352:	01174463          	blt	a4,a7,80035a <vprintfmt+0x17e>
    else if (lflag) {
  800356:	18088163          	beqz	a7,8004d8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80035a:	000a3603          	ld	a2,0(s4)
  80035e:	46a9                	li	a3,10
  800360:	8a2e                	mv	s4,a1
  800362:	bfc1                	j	800332 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800364:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800368:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	846a                	mv	s0,s10
            goto reswitch;
  80036c:	bdf1                	j	800248 <vprintfmt+0x6c>
            putch(ch, putdat);
  80036e:	85a6                	mv	a1,s1
  800370:	02500513          	li	a0,37
  800374:	9902                	jalr	s2
            break;
  800376:	b545                	j	800216 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800378:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80037c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80037e:	846a                	mv	s0,s10
            goto reswitch;
  800380:	b5e1                	j	800248 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800382:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800384:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800388:	01174463          	blt	a4,a7,800390 <vprintfmt+0x1b4>
    else if (lflag) {
  80038c:	14088163          	beqz	a7,8004ce <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800390:	000a3603          	ld	a2,0(s4)
  800394:	46a1                	li	a3,8
  800396:	8a2e                	mv	s4,a1
  800398:	bf69                	j	800332 <vprintfmt+0x156>
            putch('0', putdat);
  80039a:	03000513          	li	a0,48
  80039e:	85a6                	mv	a1,s1
  8003a0:	e03e                	sd	a5,0(sp)
  8003a2:	9902                	jalr	s2
            putch('x', putdat);
  8003a4:	85a6                	mv	a1,s1
  8003a6:	07800513          	li	a0,120
  8003aa:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ac:	0a21                	addi	s4,s4,8
            goto number;
  8003ae:	6782                	ld	a5,0(sp)
  8003b0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003b2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003b6:	bfb5                	j	800332 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b8:	000a3403          	ld	s0,0(s4)
  8003bc:	008a0713          	addi	a4,s4,8
  8003c0:	e03a                	sd	a4,0(sp)
  8003c2:	14040263          	beqz	s0,800506 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003c6:	0fb05763          	blez	s11,8004b4 <vprintfmt+0x2d8>
  8003ca:	02d00693          	li	a3,45
  8003ce:	0cd79163          	bne	a5,a3,800490 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d2:	00044783          	lbu	a5,0(s0)
  8003d6:	0007851b          	sext.w	a0,a5
  8003da:	cf85                	beqz	a5,800412 <vprintfmt+0x236>
  8003dc:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e4:	000c4563          	bltz	s8,8003ee <vprintfmt+0x212>
  8003e8:	3c7d                	addiw	s8,s8,-1
  8003ea:	036c0263          	beq	s8,s6,80040e <vprintfmt+0x232>
                    putch('?', putdat);
  8003ee:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f0:	0e0c8e63          	beqz	s9,8004ec <vprintfmt+0x310>
  8003f4:	3781                	addiw	a5,a5,-32
  8003f6:	0ef47b63          	bgeu	s0,a5,8004ec <vprintfmt+0x310>
                    putch('?', putdat);
  8003fa:	03f00513          	li	a0,63
  8003fe:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800400:	000a4783          	lbu	a5,0(s4)
  800404:	3dfd                	addiw	s11,s11,-1
  800406:	0a05                	addi	s4,s4,1
  800408:	0007851b          	sext.w	a0,a5
  80040c:	ffe1                	bnez	a5,8003e4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80040e:	01b05963          	blez	s11,800420 <vprintfmt+0x244>
  800412:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800414:	85a6                	mv	a1,s1
  800416:	02000513          	li	a0,32
  80041a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80041c:	fe0d9be3          	bnez	s11,800412 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800420:	6a02                	ld	s4,0(sp)
  800422:	bbd5                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800424:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800426:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80042a:	01174463          	blt	a4,a7,800432 <vprintfmt+0x256>
    else if (lflag) {
  80042e:	08088d63          	beqz	a7,8004c8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800432:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800436:	0a044d63          	bltz	s0,8004f0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80043a:	8622                	mv	a2,s0
  80043c:	8a66                	mv	s4,s9
  80043e:	46a9                	li	a3,10
  800440:	bdcd                	j	800332 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800442:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800446:	4761                	li	a4,24
            err = va_arg(ap, int);
  800448:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80044a:	41f7d69b          	sraiw	a3,a5,0x1f
  80044e:	8fb5                	xor	a5,a5,a3
  800450:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800454:	02d74163          	blt	a4,a3,800476 <vprintfmt+0x29a>
  800458:	00369793          	slli	a5,a3,0x3
  80045c:	97de                	add	a5,a5,s7
  80045e:	639c                	ld	a5,0(a5)
  800460:	cb99                	beqz	a5,800476 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800462:	86be                	mv	a3,a5
  800464:	00000617          	auipc	a2,0x0
  800468:	21460613          	addi	a2,a2,532 # 800678 <main+0x11a>
  80046c:	85a6                	mv	a1,s1
  80046e:	854a                	mv	a0,s2
  800470:	0ce000ef          	jal	ra,80053e <printfmt>
  800474:	b34d                	j	800216 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800476:	00000617          	auipc	a2,0x0
  80047a:	1f260613          	addi	a2,a2,498 # 800668 <main+0x10a>
  80047e:	85a6                	mv	a1,s1
  800480:	854a                	mv	a0,s2
  800482:	0bc000ef          	jal	ra,80053e <printfmt>
  800486:	bb41                	j	800216 <vprintfmt+0x3a>
                p = "(null)";
  800488:	00000417          	auipc	s0,0x0
  80048c:	1d840413          	addi	s0,s0,472 # 800660 <main+0x102>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800490:	85e2                	mv	a1,s8
  800492:	8522                	mv	a0,s0
  800494:	e43e                	sd	a5,8(sp)
  800496:	cbfff0ef          	jal	ra,800154 <strnlen>
  80049a:	40ad8dbb          	subw	s11,s11,a0
  80049e:	01b05b63          	blez	s11,8004b4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004a2:	67a2                	ld	a5,8(sp)
  8004a4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004aa:	85a6                	mv	a1,s1
  8004ac:	8552                	mv	a0,s4
  8004ae:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	fe0d9ce3          	bnez	s11,8004a8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b4:	00044783          	lbu	a5,0(s0)
  8004b8:	00140a13          	addi	s4,s0,1
  8004bc:	0007851b          	sext.w	a0,a5
  8004c0:	d3a5                	beqz	a5,800420 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004c2:	05e00413          	li	s0,94
  8004c6:	bf39                	j	8003e4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004c8:	000a2403          	lw	s0,0(s4)
  8004cc:	b7ad                	j	800436 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004ce:	000a6603          	lwu	a2,0(s4)
  8004d2:	46a1                	li	a3,8
  8004d4:	8a2e                	mv	s4,a1
  8004d6:	bdb1                	j	800332 <vprintfmt+0x156>
  8004d8:	000a6603          	lwu	a2,0(s4)
  8004dc:	46a9                	li	a3,10
  8004de:	8a2e                	mv	s4,a1
  8004e0:	bd89                	j	800332 <vprintfmt+0x156>
  8004e2:	000a6603          	lwu	a2,0(s4)
  8004e6:	46c1                	li	a3,16
  8004e8:	8a2e                	mv	s4,a1
  8004ea:	b5a1                	j	800332 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004ec:	9902                	jalr	s2
  8004ee:	bf09                	j	800400 <vprintfmt+0x224>
                putch('-', putdat);
  8004f0:	85a6                	mv	a1,s1
  8004f2:	02d00513          	li	a0,45
  8004f6:	e03e                	sd	a5,0(sp)
  8004f8:	9902                	jalr	s2
                num = -(long long)num;
  8004fa:	6782                	ld	a5,0(sp)
  8004fc:	8a66                	mv	s4,s9
  8004fe:	40800633          	neg	a2,s0
  800502:	46a9                	li	a3,10
  800504:	b53d                	j	800332 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800506:	03b05163          	blez	s11,800528 <vprintfmt+0x34c>
  80050a:	02d00693          	li	a3,45
  80050e:	f6d79de3          	bne	a5,a3,800488 <vprintfmt+0x2ac>
                p = "(null)";
  800512:	00000417          	auipc	s0,0x0
  800516:	14e40413          	addi	s0,s0,334 # 800660 <main+0x102>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051a:	02800793          	li	a5,40
  80051e:	02800513          	li	a0,40
  800522:	00140a13          	addi	s4,s0,1
  800526:	bd6d                	j	8003e0 <vprintfmt+0x204>
  800528:	00000a17          	auipc	s4,0x0
  80052c:	139a0a13          	addi	s4,s4,313 # 800661 <main+0x103>
  800530:	02800513          	li	a0,40
  800534:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800538:	05e00413          	li	s0,94
  80053c:	b565                	j	8003e4 <vprintfmt+0x208>

000000000080053e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800540:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800546:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	ec06                	sd	ra,24(sp)
  80054a:	f83a                	sd	a4,48(sp)
  80054c:	fc3e                	sd	a5,56(sp)
  80054e:	e0c2                	sd	a6,64(sp)
  800550:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800552:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800554:	c89ff0ef          	jal	ra,8001dc <vprintfmt>
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6161                	addi	sp,sp,80
  80055c:	8082                	ret

000000000080055e <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  80055e:	1101                	addi	sp,sp,-32
  800560:	e822                	sd	s0,16(sp)
  800562:	e426                	sd	s1,8(sp)
  800564:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800566:	4401                	li	s0,0
  800568:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  80056c:	b5fff0ef          	jal	ra,8000ca <fork>
  800570:	cd05                	beqz	a0,8005a8 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  800572:	06a05063          	blez	a0,8005d2 <main+0x74>
    for (n = 0; n < max_child; n ++) {
  800576:	2405                	addiw	s0,s0,1
  800578:	fe941ae3          	bne	s0,s1,80056c <main+0xe>
  80057c:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  800580:	b4dff0ef          	jal	ra,8000cc <wait>
  800584:	ed05                	bnez	a0,8005bc <main+0x5e>
    for (; n > 0; n --) {
  800586:	347d                	addiw	s0,s0,-1
  800588:	fc65                	bnez	s0,800580 <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  80058a:	b43ff0ef          	jal	ra,8000cc <wait>
  80058e:	c12d                	beqz	a0,8005f0 <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  800590:	00000517          	auipc	a0,0x0
  800594:	44050513          	addi	a0,a0,1088 # 8009d0 <error_string+0x138>
  800598:	b7bff0ef          	jal	ra,800112 <cprintf>
    return 0;
}
  80059c:	60e2                	ld	ra,24(sp)
  80059e:	6442                	ld	s0,16(sp)
  8005a0:	64a2                	ld	s1,8(sp)
  8005a2:	4501                	li	a0,0
  8005a4:	6105                	addi	sp,sp,32
  8005a6:	8082                	ret
            cprintf("I am child %d\n", n);
  8005a8:	85a2                	mv	a1,s0
  8005aa:	00000517          	auipc	a0,0x0
  8005ae:	3b650513          	addi	a0,a0,950 # 800960 <error_string+0xc8>
  8005b2:	b61ff0ef          	jal	ra,800112 <cprintf>
            exit(0);
  8005b6:	4501                	li	a0,0
  8005b8:	afdff0ef          	jal	ra,8000b4 <exit>
            panic("wait stopped early\n");
  8005bc:	00000617          	auipc	a2,0x0
  8005c0:	3e460613          	addi	a2,a2,996 # 8009a0 <error_string+0x108>
  8005c4:	45dd                	li	a1,23
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	3ca50513          	addi	a0,a0,970 # 800990 <error_string+0xf8>
  8005ce:	a53ff0ef          	jal	ra,800020 <__panic>
        assert(pid > 0);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	39e68693          	addi	a3,a3,926 # 800970 <error_string+0xd8>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	39e60613          	addi	a2,a2,926 # 800978 <error_string+0xe0>
  8005e2:	45b9                	li	a1,14
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	3ac50513          	addi	a0,a0,940 # 800990 <error_string+0xf8>
  8005ec:	a35ff0ef          	jal	ra,800020 <__panic>
        panic("wait got too many\n");
  8005f0:	00000617          	auipc	a2,0x0
  8005f4:	3c860613          	addi	a2,a2,968 # 8009b8 <error_string+0x120>
  8005f8:	45f1                	li	a1,28
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	39650513          	addi	a0,a0,918 # 800990 <error_string+0xf8>
  800602:	a1fff0ef          	jal	ra,800020 <__panic>
