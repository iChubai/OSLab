
obj/__user_cowtest.out:     file format elf64-littleriscv


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
  80002e:	00001517          	auipc	a0,0x1
  800032:	a8250513          	addi	a0,a0,-1406 # 800ab0 <main+0x486>
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
  800044:	0d0000ef          	jal	800114 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0a8000ef          	jal	8000f4 <vcprintf>
    cprintf("\n");
  800050:	00001517          	auipc	a0,0x1
  800054:	a8050513          	addi	a0,a0,-1408 # 800ad0 <main+0x4a6>
  800058:	0bc000ef          	jal	800114 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	05c000ef          	jal	8000ba <exit>

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

00000000008000b4 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b4:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b6:	4579                	li	a0,30
  8000b8:	b76d                	j	800062 <syscall>

00000000008000ba <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ba:	1141                	addi	sp,sp,-16
  8000bc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000be:	fe1ff0ef          	jal	80009e <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c2:	00001517          	auipc	a0,0x1
  8000c6:	a1650513          	addi	a0,a0,-1514 # 800ad8 <main+0x4ae>
  8000ca:	04a000ef          	jal	800114 <cprintf>
    while (1);
  8000ce:	a001                	j	8000ce <exit+0x14>

00000000008000d0 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d0:	bfd1                	j	8000a4 <sys_fork>

00000000008000d2 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d2:	bfd9                	j	8000a8 <sys_wait>

00000000008000d4 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d4:	bff1                	j	8000b0 <sys_yield>

00000000008000d6 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000d6:	072000ef          	jal	800148 <umain>
1:  j 1b
  8000da:	a001                	j	8000da <_start+0x4>

00000000008000dc <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000dc:	1101                	addi	sp,sp,-32
  8000de:	ec06                	sd	ra,24(sp)
  8000e0:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000e2:	fd3ff0ef          	jal	8000b4 <sys_putc>
    (*cnt) ++;
  8000e6:	65a2                	ld	a1,8(sp)
}
  8000e8:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000ea:	419c                	lw	a5,0(a1)
  8000ec:	2785                	addiw	a5,a5,1
  8000ee:	c19c                	sw	a5,0(a1)
}
  8000f0:	6105                	addi	sp,sp,32
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
  8000fe:	fe250513          	addi	a0,a0,-30 # 8000dc <cputch>
  800102:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800104:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800106:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800108:	0ce000ef          	jal	8001d6 <vprintfmt>
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
  80011a:	f42e                	sd	a1,40(sp)
  80011c:	f832                	sd	a2,48(sp)
  80011e:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800120:	862a                	mv	a2,a0
  800122:	004c                	addi	a1,sp,4
  800124:	00000517          	auipc	a0,0x0
  800128:	fb850513          	addi	a0,a0,-72 # 8000dc <cputch>
  80012c:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80012e:	ec06                	sd	ra,24(sp)
  800130:	e0ba                	sd	a4,64(sp)
  800132:	e4be                	sd	a5,72(sp)
  800134:	e8c2                	sd	a6,80(sp)
  800136:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800138:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  80013a:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013c:	09a000ef          	jal	8001d6 <vprintfmt>
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
  80014c:	4de000ef          	jal	80062a <main>
    exit(ret);
  800150:	f6bff0ef          	jal	8000ba <exit>

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
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800172:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	f022                	sd	s0,32(sp)
  800178:	ec26                	sd	s1,24(sp)
  80017a:	e84a                	sd	s2,16(sp)
  80017c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800184:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800188:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80018c:	84aa                	mv	s1,a0
  80018e:	892e                	mv	s2,a1
    if (num >= base) {
  800190:	03067d63          	bgeu	a2,a6,8001ca <printnum+0x5a>
  800194:	e44e                	sd	s3,8(sp)
  800196:	89be                	mv	s3,a5
        while (-- width > 0)
  800198:	4785                	li	a5,1
  80019a:	00e7d763          	bge	a5,a4,8001a8 <printnum+0x38>
            putch(padc, putdat);
  80019e:	85ca                	mv	a1,s2
  8001a0:	854e                	mv	a0,s3
        while (-- width > 0)
  8001a2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a4:	9482                	jalr	s1
        while (-- width > 0)
  8001a6:	fc65                	bnez	s0,80019e <printnum+0x2e>
  8001a8:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	00001797          	auipc	a5,0x1
  8001ae:	94678793          	addi	a5,a5,-1722 # 800af0 <main+0x4c6>
  8001b2:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	0007c503          	lbu	a0,0(a5)
}
  8001ba:	70a2                	ld	ra,40(sp)
  8001bc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001be:	85ca                	mv	a1,s2
  8001c0:	87a6                	mv	a5,s1
}
  8001c2:	6942                	ld	s2,16(sp)
  8001c4:	64e2                	ld	s1,24(sp)
  8001c6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ca:	03065633          	divu	a2,a2,a6
  8001ce:	8722                	mv	a4,s0
  8001d0:	fa1ff0ef          	jal	800170 <printnum>
  8001d4:	bfd9                	j	8001aa <printnum+0x3a>

00000000008001d6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d6:	7119                	addi	sp,sp,-128
  8001d8:	f4a6                	sd	s1,104(sp)
  8001da:	f0ca                	sd	s2,96(sp)
  8001dc:	ecce                	sd	s3,88(sp)
  8001de:	e8d2                	sd	s4,80(sp)
  8001e0:	e4d6                	sd	s5,72(sp)
  8001e2:	e0da                	sd	s6,64(sp)
  8001e4:	f862                	sd	s8,48(sp)
  8001e6:	fc86                	sd	ra,120(sp)
  8001e8:	f8a2                	sd	s0,112(sp)
  8001ea:	fc5e                	sd	s7,56(sp)
  8001ec:	f466                	sd	s9,40(sp)
  8001ee:	f06a                	sd	s10,32(sp)
  8001f0:	ec6e                	sd	s11,24(sp)
  8001f2:	84aa                	mv	s1,a0
  8001f4:	8c32                	mv	s8,a2
  8001f6:	8a36                	mv	s4,a3
  8001f8:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fe:	05500b13          	li	s6,85
  800202:	00001a97          	auipc	s5,0x1
  800206:	c3ea8a93          	addi	s5,s5,-962 # 800e40 <main+0x816>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	000c4503          	lbu	a0,0(s8)
  80020e:	001c0413          	addi	s0,s8,1
  800212:	01350a63          	beq	a0,s3,800226 <vprintfmt+0x50>
            if (ch == '\0') {
  800216:	cd0d                	beqz	a0,800250 <vprintfmt+0x7a>
            putch(ch, putdat);
  800218:	85ca                	mv	a1,s2
  80021a:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	00044503          	lbu	a0,0(s0)
  800220:	0405                	addi	s0,s0,1
  800222:	ff351ae3          	bne	a0,s3,800216 <vprintfmt+0x40>
        width = precision = -1;
  800226:	5cfd                	li	s9,-1
  800228:	8d66                	mv	s10,s9
        char padc = ' ';
  80022a:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80022e:	4b81                	li	s7,0
  800230:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	00044683          	lbu	a3,0(s0)
  800236:	00140c13          	addi	s8,s0,1
  80023a:	fdd6859b          	addiw	a1,a3,-35
  80023e:	0ff5f593          	zext.b	a1,a1
  800242:	02bb6663          	bltu	s6,a1,80026e <vprintfmt+0x98>
  800246:	058a                	slli	a1,a1,0x2
  800248:	95d6                	add	a1,a1,s5
  80024a:	4198                	lw	a4,0(a1)
  80024c:	9756                	add	a4,a4,s5
  80024e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800250:	70e6                	ld	ra,120(sp)
  800252:	7446                	ld	s0,112(sp)
  800254:	74a6                	ld	s1,104(sp)
  800256:	7906                	ld	s2,96(sp)
  800258:	69e6                	ld	s3,88(sp)
  80025a:	6a46                	ld	s4,80(sp)
  80025c:	6aa6                	ld	s5,72(sp)
  80025e:	6b06                	ld	s6,64(sp)
  800260:	7be2                	ld	s7,56(sp)
  800262:	7c42                	ld	s8,48(sp)
  800264:	7ca2                	ld	s9,40(sp)
  800266:	7d02                	ld	s10,32(sp)
  800268:	6de2                	ld	s11,24(sp)
  80026a:	6109                	addi	sp,sp,128
  80026c:	8082                	ret
            putch('%', putdat);
  80026e:	85ca                	mv	a1,s2
  800270:	02500513          	li	a0,37
  800274:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800276:	fff44783          	lbu	a5,-1(s0)
  80027a:	02500713          	li	a4,37
  80027e:	8c22                	mv	s8,s0
  800280:	f8e785e3          	beq	a5,a4,80020a <vprintfmt+0x34>
  800284:	ffec4783          	lbu	a5,-2(s8)
  800288:	1c7d                	addi	s8,s8,-1
  80028a:	fee79de3          	bne	a5,a4,800284 <vprintfmt+0xae>
  80028e:	bfb5                	j	80020a <vprintfmt+0x34>
                ch = *fmt;
  800290:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800294:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800296:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80029a:	fd06071b          	addiw	a4,a2,-48
  80029e:	24e56a63          	bltu	a0,a4,8004f2 <vprintfmt+0x31c>
                ch = *fmt;
  8002a2:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002a4:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002a6:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002aa:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002ae:	0197073b          	addw	a4,a4,s9
  8002b2:	0017171b          	slliw	a4,a4,0x1
  8002b6:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002b8:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002bc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002be:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002c2:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002c6:	feb570e3          	bgeu	a0,a1,8002a6 <vprintfmt+0xd0>
            if (width < 0)
  8002ca:	f60d54e3          	bgez	s10,800232 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002ce:	8d66                	mv	s10,s9
  8002d0:	5cfd                	li	s9,-1
  8002d2:	b785                	j	800232 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d4:	8db6                	mv	s11,a3
  8002d6:	8462                	mv	s0,s8
  8002d8:	bfa9                	j	800232 <vprintfmt+0x5c>
  8002da:	8462                	mv	s0,s8
            altflag = 1;
  8002dc:	4b85                	li	s7,1
            goto reswitch;
  8002de:	bf91                	j	800232 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e6:	00f74463          	blt	a4,a5,8002ee <vprintfmt+0x118>
    else if (lflag) {
  8002ea:	1a078763          	beqz	a5,800498 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002ee:	000a3603          	ld	a2,0(s4)
  8002f2:	46c1                	li	a3,16
  8002f4:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002f6:	000d879b          	sext.w	a5,s11
  8002fa:	876a                	mv	a4,s10
  8002fc:	85ca                	mv	a1,s2
  8002fe:	8526                	mv	a0,s1
  800300:	e71ff0ef          	jal	800170 <printnum>
            break;
  800304:	b719                	j	80020a <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800306:	000a2503          	lw	a0,0(s4)
  80030a:	85ca                	mv	a1,s2
  80030c:	0a21                	addi	s4,s4,8
  80030e:	9482                	jalr	s1
            break;
  800310:	bded                	j	80020a <vprintfmt+0x34>
    if (lflag >= 2) {
  800312:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800314:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800318:	00f74463          	blt	a4,a5,800320 <vprintfmt+0x14a>
    else if (lflag) {
  80031c:	16078963          	beqz	a5,80048e <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800320:	000a3603          	ld	a2,0(s4)
  800324:	46a9                	li	a3,10
  800326:	8a2e                	mv	s4,a1
  800328:	b7f9                	j	8002f6 <vprintfmt+0x120>
            putch('0', putdat);
  80032a:	85ca                	mv	a1,s2
  80032c:	03000513          	li	a0,48
  800330:	9482                	jalr	s1
            putch('x', putdat);
  800332:	85ca                	mv	a1,s2
  800334:	07800513          	li	a0,120
  800338:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033a:	000a3603          	ld	a2,0(s4)
            goto number;
  80033e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800340:	0a21                	addi	s4,s4,8
            goto number;
  800342:	bf55                	j	8002f6 <vprintfmt+0x120>
            putch(ch, putdat);
  800344:	85ca                	mv	a1,s2
  800346:	02500513          	li	a0,37
  80034a:	9482                	jalr	s1
            break;
  80034c:	bd7d                	j	80020a <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80034e:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800352:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800354:	0a21                	addi	s4,s4,8
            goto process_precision;
  800356:	bf95                	j	8002ca <vprintfmt+0xf4>
    if (lflag >= 2) {
  800358:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80035e:	00f74463          	blt	a4,a5,800366 <vprintfmt+0x190>
    else if (lflag) {
  800362:	12078163          	beqz	a5,800484 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800366:	000a3603          	ld	a2,0(s4)
  80036a:	46a1                	li	a3,8
  80036c:	8a2e                	mv	s4,a1
  80036e:	b761                	j	8002f6 <vprintfmt+0x120>
            if (width < 0)
  800370:	876a                	mv	a4,s10
  800372:	000d5363          	bgez	s10,800378 <vprintfmt+0x1a2>
  800376:	4701                	li	a4,0
  800378:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80037c:	8462                	mv	s0,s8
            goto reswitch;
  80037e:	bd55                	j	800232 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800380:	000d841b          	sext.w	s0,s11
  800384:	fd340793          	addi	a5,s0,-45
  800388:	00f037b3          	snez	a5,a5
  80038c:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800390:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800394:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800396:	008a0793          	addi	a5,s4,8
  80039a:	e43e                	sd	a5,8(sp)
  80039c:	100d8c63          	beqz	s11,8004b4 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003a0:	12071363          	bnez	a4,8004c6 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a4:	000dc783          	lbu	a5,0(s11)
  8003a8:	0007851b          	sext.w	a0,a5
  8003ac:	c78d                	beqz	a5,8003d6 <vprintfmt+0x200>
  8003ae:	0d85                	addi	s11,s11,1
  8003b0:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b2:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b6:	000cc563          	bltz	s9,8003c0 <vprintfmt+0x1ea>
  8003ba:	3cfd                	addiw	s9,s9,-1
  8003bc:	008c8d63          	beq	s9,s0,8003d6 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c0:	020b9663          	bnez	s7,8003ec <vprintfmt+0x216>
                    putch(ch, putdat);
  8003c4:	85ca                	mv	a1,s2
  8003c6:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c8:	000dc783          	lbu	a5,0(s11)
  8003cc:	0d85                	addi	s11,s11,1
  8003ce:	3d7d                	addiw	s10,s10,-1
  8003d0:	0007851b          	sext.w	a0,a5
  8003d4:	f3ed                	bnez	a5,8003b6 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003d6:	01a05963          	blez	s10,8003e8 <vprintfmt+0x212>
                putch(' ', putdat);
  8003da:	85ca                	mv	a1,s2
  8003dc:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003e0:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003e2:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003e4:	fe0d1be3          	bnez	s10,8003da <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003e8:	6a22                	ld	s4,8(sp)
  8003ea:	b505                	j	80020a <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ec:	3781                	addiw	a5,a5,-32
  8003ee:	fcfa7be3          	bgeu	s4,a5,8003c4 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003f2:	03f00513          	li	a0,63
  8003f6:	85ca                	mv	a1,s2
  8003f8:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003fa:	000dc783          	lbu	a5,0(s11)
  8003fe:	0d85                	addi	s11,s11,1
  800400:	3d7d                	addiw	s10,s10,-1
  800402:	0007851b          	sext.w	a0,a5
  800406:	dbe1                	beqz	a5,8003d6 <vprintfmt+0x200>
  800408:	fa0cd9e3          	bgez	s9,8003ba <vprintfmt+0x1e4>
  80040c:	b7c5                	j	8003ec <vprintfmt+0x216>
            if (err < 0) {
  80040e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800412:	4661                	li	a2,24
            err = va_arg(ap, int);
  800414:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800416:	41f7d71b          	sraiw	a4,a5,0x1f
  80041a:	8fb9                	xor	a5,a5,a4
  80041c:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800420:	02d64563          	blt	a2,a3,80044a <vprintfmt+0x274>
  800424:	00001797          	auipc	a5,0x1
  800428:	b7478793          	addi	a5,a5,-1164 # 800f98 <error_string>
  80042c:	00369713          	slli	a4,a3,0x3
  800430:	97ba                	add	a5,a5,a4
  800432:	639c                	ld	a5,0(a5)
  800434:	cb99                	beqz	a5,80044a <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800436:	86be                	mv	a3,a5
  800438:	00000617          	auipc	a2,0x0
  80043c:	6e860613          	addi	a2,a2,1768 # 800b20 <main+0x4f6>
  800440:	85ca                	mv	a1,s2
  800442:	8526                	mv	a0,s1
  800444:	0d8000ef          	jal	80051c <printfmt>
  800448:	b3c9                	j	80020a <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80044a:	00000617          	auipc	a2,0x0
  80044e:	6c660613          	addi	a2,a2,1734 # 800b10 <main+0x4e6>
  800452:	85ca                	mv	a1,s2
  800454:	8526                	mv	a0,s1
  800456:	0c6000ef          	jal	80051c <printfmt>
  80045a:	bb45                	j	80020a <vprintfmt+0x34>
    if (lflag >= 2) {
  80045c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80045e:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800462:	00f74363          	blt	a4,a5,800468 <vprintfmt+0x292>
    else if (lflag) {
  800466:	cf81                	beqz	a5,80047e <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800468:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80046c:	02044b63          	bltz	s0,8004a2 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800470:	8622                	mv	a2,s0
  800472:	8a5e                	mv	s4,s7
  800474:	46a9                	li	a3,10
  800476:	b541                	j	8002f6 <vprintfmt+0x120>
            lflag ++;
  800478:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80047a:	8462                	mv	s0,s8
            goto reswitch;
  80047c:	bb5d                	j	800232 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80047e:	000a2403          	lw	s0,0(s4)
  800482:	b7ed                	j	80046c <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800484:	000a6603          	lwu	a2,0(s4)
  800488:	46a1                	li	a3,8
  80048a:	8a2e                	mv	s4,a1
  80048c:	b5ad                	j	8002f6 <vprintfmt+0x120>
  80048e:	000a6603          	lwu	a2,0(s4)
  800492:	46a9                	li	a3,10
  800494:	8a2e                	mv	s4,a1
  800496:	b585                	j	8002f6 <vprintfmt+0x120>
  800498:	000a6603          	lwu	a2,0(s4)
  80049c:	46c1                	li	a3,16
  80049e:	8a2e                	mv	s4,a1
  8004a0:	bd99                	j	8002f6 <vprintfmt+0x120>
                putch('-', putdat);
  8004a2:	85ca                	mv	a1,s2
  8004a4:	02d00513          	li	a0,45
  8004a8:	9482                	jalr	s1
                num = -(long long)num;
  8004aa:	40800633          	neg	a2,s0
  8004ae:	8a5e                	mv	s4,s7
  8004b0:	46a9                	li	a3,10
  8004b2:	b591                	j	8002f6 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b4:	e329                	bnez	a4,8004f6 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b6:	02800793          	li	a5,40
  8004ba:	853e                	mv	a0,a5
  8004bc:	00000d97          	auipc	s11,0x0
  8004c0:	64dd8d93          	addi	s11,s11,1613 # 800b09 <main+0x4df>
  8004c4:	b5f5                	j	8003b0 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c6:	85e6                	mv	a1,s9
  8004c8:	856e                	mv	a0,s11
  8004ca:	c8bff0ef          	jal	800154 <strnlen>
  8004ce:	40ad0d3b          	subw	s10,s10,a0
  8004d2:	01a05863          	blez	s10,8004e2 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004d6:	85ca                	mv	a1,s2
  8004d8:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004dc:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	fe0d1ce3          	bnez	s10,8004d6 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e2:	000dc783          	lbu	a5,0(s11)
  8004e6:	0007851b          	sext.w	a0,a5
  8004ea:	ec0792e3          	bnez	a5,8003ae <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004ee:	6a22                	ld	s4,8(sp)
  8004f0:	bb29                	j	80020a <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004f2:	8462                	mv	s0,s8
  8004f4:	bbd9                	j	8002ca <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f6:	85e6                	mv	a1,s9
  8004f8:	00000517          	auipc	a0,0x0
  8004fc:	61050513          	addi	a0,a0,1552 # 800b08 <main+0x4de>
  800500:	c55ff0ef          	jal	800154 <strnlen>
  800504:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800508:	02800793          	li	a5,40
                p = "(null)";
  80050c:	00000d97          	auipc	s11,0x0
  800510:	5fcd8d93          	addi	s11,s11,1532 # 800b08 <main+0x4de>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800514:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800516:	fda040e3          	bgtz	s10,8004d6 <vprintfmt+0x300>
  80051a:	bd51                	j	8003ae <vprintfmt+0x1d8>

000000000080051c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800526:	ec06                	sd	ra,24(sp)
  800528:	f83a                	sd	a4,48(sp)
  80052a:	fc3e                	sd	a5,56(sp)
  80052c:	e0c2                	sd	a6,64(sp)
  80052e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800530:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800532:	ca5ff0ef          	jal	8001d6 <vprintfmt>
}
  800536:	60e2                	ld	ra,24(sp)
  800538:	6161                	addi	sp,sp,80
  80053a:	8082                	ret

000000000080053c <check_buf_all>:
    }
}

// 检查整个缓冲区的数据完整性（完整检查，较慢但彻底）
static void check_buf_all(uint32_t seed) {
    for (int i = 0; i < TOTAL_WORDS; i++) {
  80053c:	4781                	li	a5,0
  80053e:	00002617          	auipc	a2,0x2
  800542:	ac260613          	addi	a2,a2,-1342 # 802000 <cowbuf>
  800546:	65a1                	lui	a1,0x8
        // 断言每个位置的值都等于期望值，否则程序崩溃
        assert(cowbuf[i] == expected(seed, i));
  800548:	00279713          	slli	a4,a5,0x2
  80054c:	9732                	add	a4,a4,a2
  80054e:	4314                	lw	a3,0(a4)
  800550:	00a7c733          	xor	a4,a5,a0
  800554:	00e69663          	bne	a3,a4,800560 <check_buf_all+0x24>
    for (int i = 0; i < TOTAL_WORDS; i++) {
  800558:	2785                	addiw	a5,a5,1
  80055a:	feb797e3          	bne	a5,a1,800548 <check_buf_all+0xc>
  80055e:	8082                	ret
static void check_buf_all(uint32_t seed) {
  800560:	1141                	addi	sp,sp,-16
        assert(cowbuf[i] == expected(seed, i));
  800562:	00000697          	auipc	a3,0x0
  800566:	68668693          	addi	a3,a3,1670 # 800be8 <main+0x5be>
  80056a:	00000617          	auipc	a2,0x0
  80056e:	69e60613          	addi	a2,a2,1694 # 800c08 <main+0x5de>
  800572:	02000593          	li	a1,32
  800576:	00000517          	auipc	a0,0x0
  80057a:	6aa50513          	addi	a0,a0,1706 # 800c20 <main+0x5f6>
static void check_buf_all(uint32_t seed) {
  80057e:	e406                	sd	ra,8(sp)
        assert(cowbuf[i] == expected(seed, i));
  800580:	aa1ff0ef          	jal	800020 <__panic>

0000000000800584 <check_buf_sample.constprop.0>:
    }
}

// 采样检查缓冲区数据完整性（只检查每页的第一个和最后一个字，提高性能）
static void check_buf_sample(uint32_t seed) {
  800584:	1141                	addi	sp,sp,-16
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  800586:	1b59c537          	lui	a0,0x1b59c
static void check_buf_sample(uint32_t seed) {
  80058a:	e406                	sd	ra,8(sp)
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  80058c:	abe50513          	addi	a0,a0,-1346 # 1b59babe <cowbuf+0x1ad99abe>
static void check_buf_sample(uint32_t seed) {
  800590:	3ff00793          	li	a5,1023
  800594:	4601                	li	a2,0
    for (int p = 0; p < BUF_PAGES; p++) {  // 遍历每一页
  800596:	4581                	li	a1,0
  800598:	00002817          	auipc	a6,0x2
  80059c:	a6880813          	addi	a6,a6,-1432 # 802000 <cowbuf>
  8005a0:	02000313          	li	t1,32
        int i0 = p * WORDS_PER_PAGE;       // 每页第一个字的索引
        int i1 = p * WORDS_PER_PAGE + (WORDS_PER_PAGE - 1);  // 每页最后一个字的索引
        uint32_t e0 = expected(seed, i0), e1 = expected(seed, i1);  // 计算期望值

        // 检查每页第一个字
        if (cowbuf[i0] != e0) {
  8005a4:	00261693          	slli	a3,a2,0x2
  8005a8:	96c2                	add	a3,a3,a6
  8005aa:	0006a883          	lw	a7,0(a3)
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  8005ae:	00a64733          	xor	a4,a2,a0
        if (cowbuf[i0] != e0) {
  8005b2:	03171563          	bne	a4,a7,8005dc <check_buf_sample.constprop.0+0x58>
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
                    p, i0, cowbuf[i0], e0);
            panic("sample mismatch");  // 数据不匹配，程序崩溃
        }
        // 检查每页最后一个字
        if (cowbuf[i1] != e1) {
  8005b6:	00279693          	slli	a3,a5,0x2
  8005ba:	96c2                	add	a3,a3,a6
  8005bc:	0006a883          	lw	a7,0(a3)
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  8005c0:	00a7c733          	xor	a4,a5,a0
        if (cowbuf[i1] != e1) {
  8005c4:	03171f63          	bne	a4,a7,800602 <check_buf_sample.constprop.0+0x7e>
    for (int p = 0; p < BUF_PAGES; p++) {  // 遍历每一页
  8005c8:	2585                	addiw	a1,a1,1 # 8001 <__panic-0x7f801f>
  8005ca:	4006061b          	addiw	a2,a2,1024
  8005ce:	4007879b          	addiw	a5,a5,1024
  8005d2:	fc6599e3          	bne	a1,t1,8005a4 <check_buf_sample.constprop.0+0x20>
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
                    p, i1, cowbuf[i1], e1);
            panic("sample mismatch");  // 数据不匹配，程序崩溃
        }
    }
}
  8005d6:	60a2                	ld	ra,8(sp)
  8005d8:	0141                	addi	sp,sp,16
  8005da:	8082                	ret
                    p, i0, cowbuf[i0], e0);
  8005dc:	4294                	lw	a3,0(a3)
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
  8005de:	00000517          	auipc	a0,0x0
  8005e2:	65250513          	addi	a0,a0,1618 # 800c30 <main+0x606>
  8005e6:	b2fff0ef          	jal	800114 <cprintf>
            panic("sample mismatch");  // 数据不匹配，程序崩溃
  8005ea:	00000617          	auipc	a2,0x0
  8005ee:	68660613          	addi	a2,a2,1670 # 800c70 <main+0x646>
  8005f2:	02f00593          	li	a1,47
  8005f6:	00000517          	auipc	a0,0x0
  8005fa:	62a50513          	addi	a0,a0,1578 # 800c20 <main+0x5f6>
  8005fe:	a23ff0ef          	jal	800020 <__panic>
                    p, i1, cowbuf[i1], e1);
  800602:	4294                	lw	a3,0(a3)
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
  800604:	863e                	mv	a2,a5
  800606:	00000517          	auipc	a0,0x0
  80060a:	62a50513          	addi	a0,a0,1578 # 800c30 <main+0x606>
  80060e:	b07ff0ef          	jal	800114 <cprintf>
            panic("sample mismatch");  // 数据不匹配，程序崩溃
  800612:	00000617          	auipc	a2,0x0
  800616:	65e60613          	addi	a2,a2,1630 # 800c70 <main+0x646>
  80061a:	03500593          	li	a1,53
  80061e:	00000517          	auipc	a0,0x0
  800622:	60250513          	addi	a0,a0,1538 # 800c20 <main+0x5f6>
  800626:	9fbff0ef          	jal	800020 <__panic>

000000000080062a <main>:
    cowbuf[0] = 0x13572468u;
    assert(cowbuf[0] == 0x13572468u);
}

// 主函数：执行所有测试
int main(void) {
  80062a:	7119                	addi	sp,sp,-128
  80062c:	f8a2                	sd	s0,112(sp)
  80062e:	f0ca                	sd	s2,96(sp)
  800630:	fc86                	sd	ra,120(sp)
  800632:	f4a6                	sd	s1,104(sp)
  800634:	ecce                	sd	s3,88(sp)
  800636:	e8d2                	sd	s4,80(sp)
  800638:	e4d6                	sd	s5,72(sp)
  80063a:	e0da                	sd	s6,64(sp)
  80063c:	fc5e                	sd	s7,56(sp)
  80063e:	f862                	sd	s8,48(sp)
  800640:	0100                	addi	s0,sp,128
    cprintf("cowtest: start\n");           // 输出测试开始信息
  800642:	00000517          	auipc	a0,0x0
  800646:	63e50513          	addi	a0,a0,1598 # 800c80 <main+0x656>
  80064a:	acbff0ef          	jal	800114 <cprintf>
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  80064e:	d2f45637          	lui	a2,0xd2f45
  800652:	67860613          	addi	a2,a2,1656 # ffffffffd2f45678 <cowbuf+0xffffffffd2743678>
    for (int i = 0; i < TOTAL_WORDS; i++) {
  800656:	4781                	li	a5,0
  800658:	00002917          	auipc	s2,0x2
  80065c:	9a890913          	addi	s2,s2,-1624 # 802000 <cowbuf>
  800660:	65a1                	lui	a1,0x8
        cowbuf[i] = expected(seed, i);  // 每个位置填充对应的期望值
  800662:	00279713          	slli	a4,a5,0x2
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  800666:	00c7c6b3          	xor	a3,a5,a2
        cowbuf[i] = expected(seed, i);  // 每个位置填充对应的期望值
  80066a:	974a                	add	a4,a4,s2
  80066c:	c314                	sw	a3,0(a4)
    for (int i = 0; i < TOTAL_WORDS; i++) {
  80066e:	2785                	addiw	a5,a5,1
  800670:	feb799e3          	bne	a5,a1,800662 <main+0x38>
    check_buf_all(seed);      // 验证填充正确性
  800674:	d2f45537          	lui	a0,0xd2f45
  800678:	67850513          	addi	a0,a0,1656 # ffffffffd2f45678 <cowbuf+0xffffffffd2743678>
  80067c:	ec1ff0ef          	jal	80053c <check_buf_all>
    int pid = fork();         // 创建子进程
  800680:	a51ff0ef          	jal	8000d0 <fork>
  800684:	89aa                	mv	s3,a0
    assert(pid >= 0);         // 确保fork成功
  800686:	22054a63          	bltz	a0,8008ba <main+0x290>
    if (pid == 0) {           // 子进程执行分支
  80068a:	0c800493          	li	s1,200
  80068e:	18050c63          	beqz	a0,800826 <main+0x1fc>
    for (int i = 0; i < 200; i++) {
  800692:	34fd                	addiw	s1,s1,-1
        yield();  // 让出CPU时间片
  800694:	a41ff0ef          	jal	8000d4 <yield>
    for (int i = 0; i < 200; i++) {
  800698:	fced                	bnez	s1,800692 <main+0x68>
    int status = -1;
  80069a:	57fd                	li	a5,-1
    assert(waitpid(pid, &status) == 0);  // 等待子进程退出
  80069c:	854e                	mv	a0,s3
  80069e:	f9440593          	addi	a1,s0,-108
    int status = -1;
  8006a2:	f8f42a23          	sw	a5,-108(s0)
    assert(waitpid(pid, &status) == 0);  // 等待子进程退出
  8006a6:	a2dff0ef          	jal	8000d2 <waitpid>
  8006aa:	3e051163          	bnez	a0,800a8c <main+0x462>
    assert(status == 0);                // 确保子进程正常退出
  8006ae:	f9442483          	lw	s1,-108(s0)
  8006b2:	3a049d63          	bnez	s1,800a6c <main+0x442>
    int idxs[] = {
  8006b6:	0087b7b7          	lui	a5,0x87b
  8006ba:	07d2                	slli	a5,a5,0x14
  8006bc:	00001697          	auipc	a3,0x1
  8006c0:	9a46b683          	ld	a3,-1628(a3) # 801060 <error_string+0xc8>
  8006c4:	40078793          	addi	a5,a5,1024 # 87b400 <cowbuf+0x79400>
  8006c8:	faf43023          	sd	a5,-96(s0)
  8006cc:	3ff00793          	li	a5,1023
  8006d0:	1782                	slli	a5,a5,0x20
  8006d2:	f9840713          	addi	a4,s0,-104
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  8006d6:	d2f455b7          	lui	a1,0xd2f45
    int idxs[] = {
  8006da:	fad43423          	sd	a3,-88(s0)
  8006de:	f8f43c23          	sd	a5,-104(s0)
  8006e2:	86ba                	mv	a3,a4
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  8006e4:	67858593          	addi	a1,a1,1656 # ffffffffd2f45678 <cowbuf+0xffffffffd2743678>
        assert(cowbuf[idxs[i]] == expected(seed, idxs[i]));
  8006e8:	429c                	lw	a5,0(a3)
  8006ea:	00279613          	slli	a2,a5,0x2
  8006ee:	964a                	add	a2,a2,s2
  8006f0:	4210                	lw	a2,0(a2)
  8006f2:	8fad                	xor	a5,a5,a1
  8006f4:	34f61c63          	bne	a2,a5,800a4c <main+0x422>
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  8006f8:	0691                	addi	a3,a3,4
  8006fa:	fb040793          	addi	a5,s0,-80
  8006fe:	fef695e3          	bne	a3,a5,8006e8 <main+0xbe>
  800702:	f9840693          	addi	a3,s0,-104
        cowbuf[idxs[i]] = 0x5A5A0000u ^ (uint32_t)idxs[i];
  800706:	5a5a05b7          	lui	a1,0x5a5a0
  80070a:	429c                	lw	a5,0(a3)
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  80070c:	0691                	addi	a3,a3,4
        cowbuf[idxs[i]] = 0x5A5A0000u ^ (uint32_t)idxs[i];
  80070e:	00279613          	slli	a2,a5,0x2
  800712:	964a                	add	a2,a2,s2
  800714:	8fad                	xor	a5,a5,a1
  800716:	c21c                	sw	a5,0(a2)
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  800718:	fb040793          	addi	a5,s0,-80
  80071c:	fef697e3          	bne	a3,a5,80070a <main+0xe0>
        assert(cowbuf[idxs[i]] == (0x5A5A0000u ^ (uint32_t)idxs[i]));
  800720:	5a5a0637          	lui	a2,0x5a5a0
  800724:	431c                	lw	a5,0(a4)
  800726:	00279693          	slli	a3,a5,0x2
  80072a:	96ca                	add	a3,a3,s2
  80072c:	4294                	lw	a3,0(a3)
  80072e:	8fb1                	xor	a5,a5,a2
  800730:	2ef69e63          	bne	a3,a5,800a2c <main+0x402>
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  800734:	0711                	addi	a4,a4,4
  800736:	fb040793          	addi	a5,s0,-80
  80073a:	fef715e3          	bne	a4,a5,800724 <main+0xfa>
    test_basic_isolation();                // 执行基本隔离性测试
    cprintf("cowtest: basic isolation ok\n");  // 输出第一阶段测试通过
  80073e:	00000517          	auipc	a0,0x0
  800742:	63250513          	addi	a0,a0,1586 # 800d70 <main+0x746>
  800746:	9cfff0ef          	jal	800114 <cprintf>
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  80074a:	1b59c637          	lui	a2,0x1b59c
static void test_dirty_cow_attempt(void) {
  80074e:	8c0a                	mv	s8,sp
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  800750:	abe60613          	addi	a2,a2,-1346 # 1b59babe <cowbuf+0x1ad99abe>
    for (int i = 0; i < TOTAL_WORDS; i++) {
  800754:	4781                	li	a5,0
  800756:	65a1                	lui	a1,0x8
        cowbuf[i] = expected(seed, i);  // 每个位置填充对应的期望值
  800758:	00279713          	slli	a4,a5,0x2
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
  80075c:	00c7c6b3          	xor	a3,a5,a2
        cowbuf[i] = expected(seed, i);  // 每个位置填充对应的期望值
  800760:	974a                	add	a4,a4,s2
  800762:	c314                	sw	a3,0(a4)
    for (int i = 0; i < TOTAL_WORDS; i++) {
  800764:	2785                	addiw	a5,a5,1
  800766:	feb799e3          	bne	a5,a1,800758 <main+0x12e>
    check_buf_sample(seed);   // 采样检查初始化正确性
  80076a:	e1bff0ef          	jal	800584 <check_buf_sample.constprop.0>
    int pids[nchild];         // 存储子进程PID数组
  80076e:	1101                	addi	sp,sp,-32
  800770:	8b0a                	mv	s6,sp
    for (int i = 0; i < nchild; i++) {
  800772:	8a0a                	mv	s4,sp
    int pids[nchild];         // 存储子进程PID数组
  800774:	898a                	mv	s3,sp
    for (int i = 0; i < nchild; i++) {
  800776:	4a81                	li	s5,0
  800778:	4ba1                	li	s7,8
        int pid = fork();
  80077a:	957ff0ef          	jal	8000d0 <fork>
        assert(pid >= 0);
  80077e:	20054363          	bltz	a0,800984 <main+0x35a>
            child_dirty_attempt(i + 1, seed);  // 子进程ID从1开始
  800782:	2a85                	addiw	s5,s5,1
        if (pid == 0) {
  800784:	1a050b63          	beqz	a0,80093a <main+0x310>
        pids[i] = pid;  // 记录子进程PID
  800788:	00a9a023          	sw	a0,0(s3)
    for (int i = 0; i < nchild; i++) {
  80078c:	0991                	addi	s3,s3,4
  80078e:	ff7a96e3          	bne	s5,s7,80077a <main+0x150>
    for (int round = 0; round < 500; round++) {
  800792:	1f400993          	li	s3,500
        check_buf_sample(seed);  // 验证父进程缓冲区未被修改
  800796:	defff0ef          	jal	800584 <check_buf_sample.constprop.0>
        if ((round & 3) == 0) {  // 每4轮让出一次CPU
  80079a:	0034f793          	andi	a5,s1,3
  80079e:	c3c1                	beqz	a5,80081e <main+0x1f4>
    for (int round = 0; round < 500; round++) {
  8007a0:	2485                	addiw	s1,s1,1
  8007a2:	ff349ae3          	bne	s1,s3,800796 <main+0x16c>
  8007a6:	020b0b13          	addi	s6,s6,32
        int status = -1;
  8007aa:	59fd                	li	s3,-1
  8007ac:	f9342c23          	sw	s3,-104(s0)
        assert(waitpid(pids[i], &status) == 0);  // 等待子进程
  8007b0:	000a2503          	lw	a0,0(s4)
  8007b4:	f9840593          	addi	a1,s0,-104
  8007b8:	91bff0ef          	jal	8000d2 <waitpid>
  8007bc:	14051f63          	bnez	a0,80091a <main+0x2f0>
        assert(status == 0);                     // 确保正常退出
  8007c0:	f9842783          	lw	a5,-104(s0)
  8007c4:	12079b63          	bnez	a5,8008fa <main+0x2d0>
    for (int i = 0; i < nchild; i++) {
  8007c8:	0a11                	addi	s4,s4,4
  8007ca:	ff6a11e3          	bne	s4,s6,8007ac <main+0x182>
    check_buf_all(seed);  // 完整验证父进程缓冲区未被任何子进程修改
  8007ce:	1b59c537          	lui	a0,0x1b59c
  8007d2:	abe50513          	addi	a0,a0,-1346 # 1b59babe <cowbuf+0x1ad99abe>
  8007d6:	d67ff0ef          	jal	80053c <check_buf_all>
    cowbuf[0] = 0x13572468u;
  8007da:	135727b7          	lui	a5,0x13572
  8007de:	46878793          	addi	a5,a5,1128 # 13572468 <cowbuf+0x12d70468>
  8007e2:	00f92023          	sw	a5,0(s2)
    assert(cowbuf[0] == 0x13572468u);
  8007e6:	00002717          	auipc	a4,0x2
  8007ea:	81a72703          	lw	a4,-2022(a4) # 802000 <cowbuf>
  8007ee:	0ef71663          	bne	a4,a5,8008da <main+0x2b0>
    test_dirty_cow_attempt();              // 执行Dirty COW防护测试
    cprintf("cowtest pass.\n");            // 输出所有测试通过
  8007f2:	00000517          	auipc	a0,0x0
  8007f6:	63e50513          	addi	a0,a0,1598 # 800e30 <main+0x806>
  8007fa:	8162                	mv	sp,s8
  8007fc:	919ff0ef          	jal	800114 <cprintf>
    return 0;                              // 程序正常退出
}
  800800:	f8040113          	addi	sp,s0,-128
  800804:	70e6                	ld	ra,120(sp)
  800806:	7446                	ld	s0,112(sp)
  800808:	74a6                	ld	s1,104(sp)
  80080a:	7906                	ld	s2,96(sp)
  80080c:	69e6                	ld	s3,88(sp)
  80080e:	6a46                	ld	s4,80(sp)
  800810:	6aa6                	ld	s5,72(sp)
  800812:	6b06                	ld	s6,64(sp)
  800814:	7be2                	ld	s7,56(sp)
  800816:	7c42                	ld	s8,48(sp)
  800818:	4501                	li	a0,0
  80081a:	6109                	addi	sp,sp,128
  80081c:	8082                	ret
            yield();
  80081e:	8b7ff0ef          	jal	8000d4 <yield>
    for (int round = 0; round < 500; round++) {
  800822:	2485                	addiw	s1,s1,1
  800824:	bf8d                	j	800796 <main+0x16c>
        check_buf_all(seed);  // 子进程验证继承的数据正确
  800826:	d2f45537          	lui	a0,0xd2f45
  80082a:	67850513          	addi	a0,a0,1656 # ffffffffd2f45678 <cowbuf+0xffffffffd2743678>
  80082e:	d0fff0ef          	jal	80053c <check_buf_all>
        int idxs[] = {
  800832:	00001617          	auipc	a2,0x1
  800836:	82e63603          	ld	a2,-2002(a2) # 801060 <error_string+0xc8>
  80083a:	0087b7b7          	lui	a5,0x87b
  80083e:	3ff00713          	li	a4,1023
  800842:	07d2                	slli	a5,a5,0x14
  800844:	1702                	slli	a4,a4,0x20
  800846:	40078793          	addi	a5,a5,1024 # 87b400 <cowbuf+0x79400>
  80084a:	f9840693          	addi	a3,s0,-104
  80084e:	f8e43c23          	sd	a4,-104(s0)
  800852:	faf43023          	sd	a5,-96(s0)
  800856:	fac43423          	sd	a2,-88(s0)
  80085a:	8736                	mv	a4,a3
            cowbuf[idxs[i]] = 0xA5A50000u ^ (uint32_t)idxs[i];
  80085c:	a5a505b7          	lui	a1,0xa5a50
  800860:	431c                	lw	a5,0(a4)
        for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  800862:	0711                	addi	a4,a4,4
            cowbuf[idxs[i]] = 0xA5A50000u ^ (uint32_t)idxs[i];
  800864:	00279613          	slli	a2,a5,0x2
  800868:	964a                	add	a2,a2,s2
  80086a:	8fad                	xor	a5,a5,a1
  80086c:	c21c                	sw	a5,0(a2)
        for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  80086e:	fb040793          	addi	a5,s0,-80
  800872:	fee797e3          	bne	a5,a4,800860 <main+0x236>
            assert(cowbuf[idxs[i]] == (0xA5A50000u ^ (uint32_t)idxs[i]));
  800876:	a5a50637          	lui	a2,0xa5a50
  80087a:	429c                	lw	a5,0(a3)
  80087c:	00279713          	slli	a4,a5,0x2
  800880:	974a                	add	a4,a4,s2
  800882:	4318                	lw	a4,0(a4)
  800884:	8fb1                	xor	a5,a5,a2
  800886:	00f71a63          	bne	a4,a5,80089a <main+0x270>
        for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
  80088a:	0691                	addi	a3,a3,4
  80088c:	fb040793          	addi	a5,s0,-80
  800890:	fed795e3          	bne	a5,a3,80087a <main+0x250>
        exit(0);  // 子进程退出
  800894:	4501                	li	a0,0
  800896:	825ff0ef          	jal	8000ba <exit>
            assert(cowbuf[idxs[i]] == (0xA5A50000u ^ (uint32_t)idxs[i]));
  80089a:	00000697          	auipc	a3,0x0
  80089e:	40668693          	addi	a3,a3,1030 # 800ca0 <main+0x676>
  8008a2:	00000617          	auipc	a2,0x0
  8008a6:	36660613          	addi	a2,a2,870 # 800c08 <main+0x5de>
  8008aa:	05800593          	li	a1,88
  8008ae:	00000517          	auipc	a0,0x0
  8008b2:	37250513          	addi	a0,a0,882 # 800c20 <main+0x5f6>
  8008b6:	f6aff0ef          	jal	800020 <__panic>
    assert(pid >= 0);         // 确保fork成功
  8008ba:	00000697          	auipc	a3,0x0
  8008be:	3d668693          	addi	a3,a3,982 # 800c90 <main+0x666>
  8008c2:	00000617          	auipc	a2,0x0
  8008c6:	34660613          	addi	a2,a2,838 # 800c08 <main+0x5de>
  8008ca:	04300593          	li	a1,67
  8008ce:	00000517          	auipc	a0,0x0
  8008d2:	35250513          	addi	a0,a0,850 # 800c20 <main+0x5f6>
  8008d6:	f4aff0ef          	jal	800020 <__panic>
    assert(cowbuf[0] == 0x13572468u);
  8008da:	00000697          	auipc	a3,0x0
  8008de:	53668693          	addi	a3,a3,1334 # 800e10 <main+0x7e6>
  8008e2:	00000617          	auipc	a2,0x0
  8008e6:	32660613          	addi	a2,a2,806 # 800c08 <main+0x5de>
  8008ea:	0c800593          	li	a1,200
  8008ee:	00000517          	auipc	a0,0x0
  8008f2:	33250513          	addi	a0,a0,818 # 800c20 <main+0x5f6>
  8008f6:	f2aff0ef          	jal	800020 <__panic>
        assert(status == 0);                     // 确保正常退出
  8008fa:	00000697          	auipc	a3,0x0
  8008fe:	3fe68693          	addi	a3,a3,1022 # 800cf8 <main+0x6ce>
  800902:	00000617          	auipc	a2,0x0
  800906:	30660613          	addi	a2,a2,774 # 800c08 <main+0x5de>
  80090a:	0c100593          	li	a1,193
  80090e:	00000517          	auipc	a0,0x0
  800912:	31250513          	addi	a0,a0,786 # 800c20 <main+0x5f6>
  800916:	f0aff0ef          	jal	800020 <__panic>
        assert(waitpid(pids[i], &status) == 0);  // 等待子进程
  80091a:	00000697          	auipc	a3,0x0
  80091e:	4d668693          	addi	a3,a3,1238 # 800df0 <main+0x7c6>
  800922:	00000617          	auipc	a2,0x0
  800926:	2e660613          	addi	a2,a2,742 # 800c08 <main+0x5de>
  80092a:	0c000593          	li	a1,192
  80092e:	00000517          	auipc	a0,0x0
  800932:	2f250513          	addi	a0,a0,754 # 800c20 <main+0x5f6>
  800936:	eeaff0ef          	jal	800020 <__panic>
        cowbuf[base] = ((uint32_t)id << 24) ^ (uint32_t)p;
  80093a:	018a9a1b          	slliw	s4,s5,0x18
  80093e:	4481                	li	s1,0
    for (int p = 0; p < BUF_PAGES; p++) {
  800940:	02000993          	li	s3,32
  800944:	a021                	j	80094c <main+0x322>
  800946:	0485                	addi	s1,s1,1
  800948:	05348e63          	beq	s1,s3,8009a4 <main+0x37a>
  80094c:	0004879b          	sext.w	a5,s1
        int base = p * WORDS_PER_PAGE;  // 当前页的起始索引
  800950:	00a7969b          	slliw	a3,a5,0xa
        cowbuf[base] = ((uint32_t)id << 24) ^ (uint32_t)p;
  800954:	00a49713          	slli	a4,s1,0xa
  800958:	068a                	slli	a3,a3,0x2
  80095a:	3ff70713          	addi	a4,a4,1023
  80095e:	00fa47b3          	xor	a5,s4,a5
  800962:	96ca                	add	a3,a3,s2
        cowbuf[base + (WORDS_PER_PAGE - 1)] = ((uint32_t)id << 24) ^ (uint32_t)(p ^ 0x55);
  800964:	070a                	slli	a4,a4,0x2
        cowbuf[base] = ((uint32_t)id << 24) ^ (uint32_t)p;
  800966:	c29c                	sw	a5,0(a3)
        cowbuf[base + (WORDS_PER_PAGE - 1)] = ((uint32_t)id << 24) ^ (uint32_t)(p ^ 0x55);
  800968:	974a                	add	a4,a4,s2
  80096a:	0557c793          	xori	a5,a5,85
  80096e:	c31c                	sw	a5,0(a4)
        if ((p & 3) == 0) {
  800970:	0034f793          	andi	a5,s1,3
  800974:	fbe9                	bnez	a5,800946 <main+0x31c>
  800976:	f8a43423          	sd	a0,-120(s0)
            yield();
  80097a:	f5aff0ef          	jal	8000d4 <yield>
  80097e:	f8843503          	ld	a0,-120(s0)
  800982:	b7d1                	j	800946 <main+0x31c>
        assert(pid >= 0);
  800984:	00000697          	auipc	a3,0x0
  800988:	30c68693          	addi	a3,a3,780 # 800c90 <main+0x666>
  80098c:	00000617          	auipc	a2,0x0
  800990:	27c60613          	addi	a2,a2,636 # 800c08 <main+0x5de>
  800994:	0ae00593          	li	a1,174
  800998:	00000517          	auipc	a0,0x0
  80099c:	28850513          	addi	a0,a0,648 # 800c20 <main+0x5f6>
  8009a0:	e80ff0ef          	jal	800020 <__panic>
  8009a4:	44b5                	li	s1,13
  8009a6:	035484bb          	mulw	s1,s1,s5
    for (int i = 0; i < 200; i++) {
  8009aa:	0c800993          	li	s3,200
        cowbuf[idx] ^= (uint32_t)(id + i);  // 使用异或修改值
  8009ae:	00249713          	slli	a4,s1,0x2
  8009b2:	974a                	add	a4,a4,s2
  8009b4:	4310                	lw	a2,0(a4)
  8009b6:	015507bb          	addw	a5,a0,s5
  8009ba:	8fb1                	xor	a5,a5,a2
  8009bc:	c31c                	sw	a5,0(a4)
        if ((i & 7) == 0) {
  8009be:	00757793          	andi	a5,a0,7
  8009c2:	c799                	beqz	a5,8009d0 <main+0x3a6>
    for (int i = 0; i < 200; i++) {
  8009c4:	2505                	addiw	a0,a0,1
  8009c6:	01350f63          	beq	a0,s3,8009e4 <main+0x3ba>
  8009ca:	0614849b          	addiw	s1,s1,97
  8009ce:	b7c5                	j	8009ae <main+0x384>
  8009d0:	f8a43423          	sd	a0,-120(s0)
            yield();
  8009d4:	f00ff0ef          	jal	8000d4 <yield>
    for (int i = 0; i < 200; i++) {
  8009d8:	f8843503          	ld	a0,-120(s0)
  8009dc:	0614849b          	addiw	s1,s1,97
  8009e0:	2505                	addiw	a0,a0,1
  8009e2:	b7f1                	j	8009ae <main+0x384>
    assert(cowbuf[0] != expected(seed, 0) || cowbuf[WORDS_PER_PAGE] != expected(seed, WORDS_PER_PAGE));
  8009e4:	00001717          	auipc	a4,0x1
  8009e8:	61c72703          	lw	a4,1564(a4) # 802000 <cowbuf>
  8009ec:	1b59c7b7          	lui	a5,0x1b59c
  8009f0:	abe78793          	addi	a5,a5,-1346 # 1b59babe <cowbuf+0x1ad99abe>
  8009f4:	eaf710e3          	bne	a4,a5,800894 <main+0x26a>
  8009f8:	00002717          	auipc	a4,0x2
  8009fc:	60872703          	lw	a4,1544(a4) # 803000 <cowbuf+0x1000>
  800a00:	1b59c7b7          	lui	a5,0x1b59c
  800a04:	ebe78793          	addi	a5,a5,-322 # 1b59bebe <cowbuf+0x1ad99ebe>
  800a08:	e8f716e3          	bne	a4,a5,800894 <main+0x26a>
  800a0c:	00000697          	auipc	a3,0x0
  800a10:	38468693          	addi	a3,a3,900 # 800d90 <main+0x766>
  800a14:	00000617          	auipc	a2,0x0
  800a18:	1f460613          	addi	a2,a2,500 # 800c08 <main+0x5de>
  800a1c:	09c00593          	li	a1,156
  800a20:	00000517          	auipc	a0,0x0
  800a24:	20050513          	addi	a0,a0,512 # 800c20 <main+0x5f6>
  800a28:	df8ff0ef          	jal	800020 <__panic>
        assert(cowbuf[idxs[i]] == (0x5A5A0000u ^ (uint32_t)idxs[i]));
  800a2c:	00000697          	auipc	a3,0x0
  800a30:	30c68693          	addi	a3,a3,780 # 800d38 <main+0x70e>
  800a34:	00000617          	auipc	a2,0x0
  800a38:	1d460613          	addi	a2,a2,468 # 800c08 <main+0x5de>
  800a3c:	07a00593          	li	a1,122
  800a40:	00000517          	auipc	a0,0x0
  800a44:	1e050513          	addi	a0,a0,480 # 800c20 <main+0x5f6>
  800a48:	dd8ff0ef          	jal	800020 <__panic>
        assert(cowbuf[idxs[i]] == expected(seed, idxs[i]));
  800a4c:	00000697          	auipc	a3,0x0
  800a50:	2bc68693          	addi	a3,a3,700 # 800d08 <main+0x6de>
  800a54:	00000617          	auipc	a2,0x0
  800a58:	1b460613          	addi	a2,a2,436 # 800c08 <main+0x5de>
  800a5c:	07200593          	li	a1,114
  800a60:	00000517          	auipc	a0,0x0
  800a64:	1c050513          	addi	a0,a0,448 # 800c20 <main+0x5f6>
  800a68:	db8ff0ef          	jal	800020 <__panic>
    assert(status == 0);                // 确保子进程正常退出
  800a6c:	00000697          	auipc	a3,0x0
  800a70:	28c68693          	addi	a3,a3,652 # 800cf8 <main+0x6ce>
  800a74:	00000617          	auipc	a2,0x0
  800a78:	19460613          	addi	a2,a2,404 # 800c08 <main+0x5de>
  800a7c:	06500593          	li	a1,101
  800a80:	00000517          	auipc	a0,0x0
  800a84:	1a050513          	addi	a0,a0,416 # 800c20 <main+0x5f6>
  800a88:	d98ff0ef          	jal	800020 <__panic>
    assert(waitpid(pid, &status) == 0);  // 等待子进程退出
  800a8c:	00000697          	auipc	a3,0x0
  800a90:	24c68693          	addi	a3,a3,588 # 800cd8 <main+0x6ae>
  800a94:	00000617          	auipc	a2,0x0
  800a98:	17460613          	addi	a2,a2,372 # 800c08 <main+0x5de>
  800a9c:	06400593          	li	a1,100
  800aa0:	00000517          	auipc	a0,0x0
  800aa4:	18050513          	addi	a0,a0,384 # 800c20 <main+0x5f6>
  800aa8:	d78ff0ef          	jal	800020 <__panic>
