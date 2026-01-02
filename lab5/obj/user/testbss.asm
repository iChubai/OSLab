
obj/__user_testbss.out:     file format elf64-littleriscv


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
  800032:	5aa50513          	addi	a0,a0,1450 # 8005d8 <main+0xb2>
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
  800044:	0ba000ef          	jal	8000fe <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	092000ef          	jal	8000de <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	5a850513          	addi	a0,a0,1448 # 8005f8 <main+0xd2>
  800058:	0a6000ef          	jal	8000fe <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	04c000ef          	jal	8000aa <exit>

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

00000000008000a4 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000a4:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000a6:	4579                	li	a0,30
  8000a8:	bf6d                	j	800062 <syscall>

00000000008000aa <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000aa:	1141                	addi	sp,sp,-16
  8000ac:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ae:	ff1ff0ef          	jal	80009e <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000b2:	00000517          	auipc	a0,0x0
  8000b6:	54e50513          	addi	a0,a0,1358 # 800600 <main+0xda>
  8000ba:	044000ef          	jal	8000fe <cprintf>
    while (1);
  8000be:	a001                	j	8000be <exit+0x14>

00000000008000c0 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000c0:	072000ef          	jal	800132 <umain>
1:  j 1b
  8000c4:	a001                	j	8000c4 <_start+0x4>

00000000008000c6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c6:	1101                	addi	sp,sp,-32
  8000c8:	ec06                	sd	ra,24(sp)
  8000ca:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000cc:	fd9ff0ef          	jal	8000a4 <sys_putc>
    (*cnt) ++;
  8000d0:	65a2                	ld	a1,8(sp)
}
  8000d2:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000d4:	419c                	lw	a5,0(a1)
  8000d6:	2785                	addiw	a5,a5,1
  8000d8:	c19c                	sw	a5,0(a1)
}
  8000da:	6105                	addi	sp,sp,32
  8000dc:	8082                	ret

00000000008000de <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000de:	1101                	addi	sp,sp,-32
  8000e0:	862a                	mv	a2,a0
  8000e2:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000e4:	00000517          	auipc	a0,0x0
  8000e8:	fe250513          	addi	a0,a0,-30 # 8000c6 <cputch>
  8000ec:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  8000ee:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  8000f0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f2:	0ce000ef          	jal	8001c0 <vprintfmt>
    return cnt;
}
  8000f6:	60e2                	ld	ra,24(sp)
  8000f8:	4532                	lw	a0,12(sp)
  8000fa:	6105                	addi	sp,sp,32
  8000fc:	8082                	ret

00000000008000fe <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000fe:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800100:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800104:	f42e                	sd	a1,40(sp)
  800106:	f832                	sd	a2,48(sp)
  800108:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010a:	862a                	mv	a2,a0
  80010c:	004c                	addi	a1,sp,4
  80010e:	00000517          	auipc	a0,0x0
  800112:	fb850513          	addi	a0,a0,-72 # 8000c6 <cputch>
  800116:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800118:	ec06                	sd	ra,24(sp)
  80011a:	e0ba                	sd	a4,64(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800122:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800124:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800126:	09a000ef          	jal	8001c0 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80012a:	60e2                	ld	ra,24(sp)
  80012c:	4512                	lw	a0,4(sp)
  80012e:	6125                	addi	sp,sp,96
  800130:	8082                	ret

0000000000800132 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800132:	1141                	addi	sp,sp,-16
  800134:	e406                	sd	ra,8(sp)
    int ret = main();
  800136:	3f0000ef          	jal	800526 <main>
    exit(ret);
  80013a:	f71ff0ef          	jal	8000aa <exit>

000000000080013e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80013e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800140:	e589                	bnez	a1,80014a <strnlen+0xc>
  800142:	a811                	j	800156 <strnlen+0x18>
        cnt ++;
  800144:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800146:	00f58863          	beq	a1,a5,800156 <strnlen+0x18>
  80014a:	00f50733          	add	a4,a0,a5
  80014e:	00074703          	lbu	a4,0(a4)
  800152:	fb6d                	bnez	a4,800144 <strnlen+0x6>
  800154:	85be                	mv	a1,a5
    }
    return cnt;
}
  800156:	852e                	mv	a0,a1
  800158:	8082                	ret

000000000080015a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	f022                	sd	s0,32(sp)
  800162:	ec26                	sd	s1,24(sp)
  800164:	e84a                	sd	s2,16(sp)
  800166:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800168:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80016e:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800172:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	84aa                	mv	s1,a0
  800178:	892e                	mv	s2,a1
    if (num >= base) {
  80017a:	03067d63          	bgeu	a2,a6,8001b4 <printnum+0x5a>
  80017e:	e44e                	sd	s3,8(sp)
  800180:	89be                	mv	s3,a5
        while (-- width > 0)
  800182:	4785                	li	a5,1
  800184:	00e7d763          	bge	a5,a4,800192 <printnum+0x38>
            putch(padc, putdat);
  800188:	85ca                	mv	a1,s2
  80018a:	854e                	mv	a0,s3
        while (-- width > 0)
  80018c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x2e>
  800192:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800194:	00000797          	auipc	a5,0x0
  800198:	48478793          	addi	a5,a5,1156 # 800618 <main+0xf2>
  80019c:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a0:	0007c503          	lbu	a0,0(a5)
}
  8001a4:	70a2                	ld	ra,40(sp)
  8001a6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	85ca                	mv	a1,s2
  8001aa:	87a6                	mv	a5,s1
}
  8001ac:	6942                	ld	s2,16(sp)
  8001ae:	64e2                	ld	s1,24(sp)
  8001b0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b4:	03065633          	divu	a2,a2,a6
  8001b8:	8722                	mv	a4,s0
  8001ba:	fa1ff0ef          	jal	80015a <printnum>
  8001be:	bfd9                	j	800194 <printnum+0x3a>

00000000008001c0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c0:	7119                	addi	sp,sp,-128
  8001c2:	f4a6                	sd	s1,104(sp)
  8001c4:	f0ca                	sd	s2,96(sp)
  8001c6:	ecce                	sd	s3,88(sp)
  8001c8:	e8d2                	sd	s4,80(sp)
  8001ca:	e4d6                	sd	s5,72(sp)
  8001cc:	e0da                	sd	s6,64(sp)
  8001ce:	f862                	sd	s8,48(sp)
  8001d0:	fc86                	sd	ra,120(sp)
  8001d2:	f8a2                	sd	s0,112(sp)
  8001d4:	fc5e                	sd	s7,56(sp)
  8001d6:	f466                	sd	s9,40(sp)
  8001d8:	f06a                	sd	s10,32(sp)
  8001da:	ec6e                	sd	s11,24(sp)
  8001dc:	84aa                	mv	s1,a0
  8001de:	8c32                	mv	s8,a2
  8001e0:	8a36                	mv	s4,a3
  8001e2:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e4:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e8:	05500b13          	li	s6,85
  8001ec:	00000a97          	auipc	s5,0x0
  8001f0:	5e8a8a93          	addi	s5,s5,1512 # 8007d4 <main+0x2ae>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f4:	000c4503          	lbu	a0,0(s8)
  8001f8:	001c0413          	addi	s0,s8,1
  8001fc:	01350a63          	beq	a0,s3,800210 <vprintfmt+0x50>
            if (ch == '\0') {
  800200:	cd0d                	beqz	a0,80023a <vprintfmt+0x7a>
            putch(ch, putdat);
  800202:	85ca                	mv	a1,s2
  800204:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	00044503          	lbu	a0,0(s0)
  80020a:	0405                	addi	s0,s0,1
  80020c:	ff351ae3          	bne	a0,s3,800200 <vprintfmt+0x40>
        width = precision = -1;
  800210:	5cfd                	li	s9,-1
  800212:	8d66                	mv	s10,s9
        char padc = ' ';
  800214:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800218:	4b81                	li	s7,0
  80021a:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80021c:	00044683          	lbu	a3,0(s0)
  800220:	00140c13          	addi	s8,s0,1
  800224:	fdd6859b          	addiw	a1,a3,-35
  800228:	0ff5f593          	zext.b	a1,a1
  80022c:	02bb6663          	bltu	s6,a1,800258 <vprintfmt+0x98>
  800230:	058a                	slli	a1,a1,0x2
  800232:	95d6                	add	a1,a1,s5
  800234:	4198                	lw	a4,0(a1)
  800236:	9756                	add	a4,a4,s5
  800238:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023a:	70e6                	ld	ra,120(sp)
  80023c:	7446                	ld	s0,112(sp)
  80023e:	74a6                	ld	s1,104(sp)
  800240:	7906                	ld	s2,96(sp)
  800242:	69e6                	ld	s3,88(sp)
  800244:	6a46                	ld	s4,80(sp)
  800246:	6aa6                	ld	s5,72(sp)
  800248:	6b06                	ld	s6,64(sp)
  80024a:	7be2                	ld	s7,56(sp)
  80024c:	7c42                	ld	s8,48(sp)
  80024e:	7ca2                	ld	s9,40(sp)
  800250:	7d02                	ld	s10,32(sp)
  800252:	6de2                	ld	s11,24(sp)
  800254:	6109                	addi	sp,sp,128
  800256:	8082                	ret
            putch('%', putdat);
  800258:	85ca                	mv	a1,s2
  80025a:	02500513          	li	a0,37
  80025e:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800260:	fff44783          	lbu	a5,-1(s0)
  800264:	02500713          	li	a4,37
  800268:	8c22                	mv	s8,s0
  80026a:	f8e785e3          	beq	a5,a4,8001f4 <vprintfmt+0x34>
  80026e:	ffec4783          	lbu	a5,-2(s8)
  800272:	1c7d                	addi	s8,s8,-1
  800274:	fee79de3          	bne	a5,a4,80026e <vprintfmt+0xae>
  800278:	bfb5                	j	8001f4 <vprintfmt+0x34>
                ch = *fmt;
  80027a:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80027e:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800280:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800284:	fd06071b          	addiw	a4,a2,-48
  800288:	24e56a63          	bltu	a0,a4,8004dc <vprintfmt+0x31c>
                ch = *fmt;
  80028c:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800290:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800294:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800298:	0197073b          	addw	a4,a4,s9
  80029c:	0017171b          	slliw	a4,a4,0x1
  8002a0:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002a2:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002a6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002a8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ac:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002b0:	feb570e3          	bgeu	a0,a1,800290 <vprintfmt+0xd0>
            if (width < 0)
  8002b4:	f60d54e3          	bgez	s10,80021c <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002b8:	8d66                	mv	s10,s9
  8002ba:	5cfd                	li	s9,-1
  8002bc:	b785                	j	80021c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002be:	8db6                	mv	s11,a3
  8002c0:	8462                	mv	s0,s8
  8002c2:	bfa9                	j	80021c <vprintfmt+0x5c>
  8002c4:	8462                	mv	s0,s8
            altflag = 1;
  8002c6:	4b85                	li	s7,1
            goto reswitch;
  8002c8:	bf91                	j	80021c <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002cc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d0:	00f74463          	blt	a4,a5,8002d8 <vprintfmt+0x118>
    else if (lflag) {
  8002d4:	1a078763          	beqz	a5,800482 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002d8:	000a3603          	ld	a2,0(s4)
  8002dc:	46c1                	li	a3,16
  8002de:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002e0:	000d879b          	sext.w	a5,s11
  8002e4:	876a                	mv	a4,s10
  8002e6:	85ca                	mv	a1,s2
  8002e8:	8526                	mv	a0,s1
  8002ea:	e71ff0ef          	jal	80015a <printnum>
            break;
  8002ee:	b719                	j	8001f4 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002f0:	000a2503          	lw	a0,0(s4)
  8002f4:	85ca                	mv	a1,s2
  8002f6:	0a21                	addi	s4,s4,8
  8002f8:	9482                	jalr	s1
            break;
  8002fa:	bded                	j	8001f4 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002fc:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002fe:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800302:	00f74463          	blt	a4,a5,80030a <vprintfmt+0x14a>
    else if (lflag) {
  800306:	16078963          	beqz	a5,800478 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80030a:	000a3603          	ld	a2,0(s4)
  80030e:	46a9                	li	a3,10
  800310:	8a2e                	mv	s4,a1
  800312:	b7f9                	j	8002e0 <vprintfmt+0x120>
            putch('0', putdat);
  800314:	85ca                	mv	a1,s2
  800316:	03000513          	li	a0,48
  80031a:	9482                	jalr	s1
            putch('x', putdat);
  80031c:	85ca                	mv	a1,s2
  80031e:	07800513          	li	a0,120
  800322:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800324:	000a3603          	ld	a2,0(s4)
            goto number;
  800328:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032a:	0a21                	addi	s4,s4,8
            goto number;
  80032c:	bf55                	j	8002e0 <vprintfmt+0x120>
            putch(ch, putdat);
  80032e:	85ca                	mv	a1,s2
  800330:	02500513          	li	a0,37
  800334:	9482                	jalr	s1
            break;
  800336:	bd7d                	j	8001f4 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800338:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80033c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80033e:	0a21                	addi	s4,s4,8
            goto process_precision;
  800340:	bf95                	j	8002b4 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800342:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800344:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800348:	00f74463          	blt	a4,a5,800350 <vprintfmt+0x190>
    else if (lflag) {
  80034c:	12078163          	beqz	a5,80046e <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800350:	000a3603          	ld	a2,0(s4)
  800354:	46a1                	li	a3,8
  800356:	8a2e                	mv	s4,a1
  800358:	b761                	j	8002e0 <vprintfmt+0x120>
            if (width < 0)
  80035a:	876a                	mv	a4,s10
  80035c:	000d5363          	bgez	s10,800362 <vprintfmt+0x1a2>
  800360:	4701                	li	a4,0
  800362:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800366:	8462                	mv	s0,s8
            goto reswitch;
  800368:	bd55                	j	80021c <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80036a:	000d841b          	sext.w	s0,s11
  80036e:	fd340793          	addi	a5,s0,-45
  800372:	00f037b3          	snez	a5,a5
  800376:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80037a:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80037e:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800380:	008a0793          	addi	a5,s4,8
  800384:	e43e                	sd	a5,8(sp)
  800386:	100d8c63          	beqz	s11,80049e <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80038a:	12071363          	bnez	a4,8004b0 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038e:	000dc783          	lbu	a5,0(s11)
  800392:	0007851b          	sext.w	a0,a5
  800396:	c78d                	beqz	a5,8003c0 <vprintfmt+0x200>
  800398:	0d85                	addi	s11,s11,1
  80039a:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80039c:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	000cc563          	bltz	s9,8003aa <vprintfmt+0x1ea>
  8003a4:	3cfd                	addiw	s9,s9,-1
  8003a6:	008c8d63          	beq	s9,s0,8003c0 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003aa:	020b9663          	bnez	s7,8003d6 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003ae:	85ca                	mv	a1,s2
  8003b0:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b2:	000dc783          	lbu	a5,0(s11)
  8003b6:	0d85                	addi	s11,s11,1
  8003b8:	3d7d                	addiw	s10,s10,-1
  8003ba:	0007851b          	sext.w	a0,a5
  8003be:	f3ed                	bnez	a5,8003a0 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003c0:	01a05963          	blez	s10,8003d2 <vprintfmt+0x212>
                putch(' ', putdat);
  8003c4:	85ca                	mv	a1,s2
  8003c6:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ca:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003cc:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003ce:	fe0d1be3          	bnez	s10,8003c4 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d2:	6a22                	ld	s4,8(sp)
  8003d4:	b505                	j	8001f4 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d6:	3781                	addiw	a5,a5,-32
  8003d8:	fcfa7be3          	bgeu	s4,a5,8003ae <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003dc:	03f00513          	li	a0,63
  8003e0:	85ca                	mv	a1,s2
  8003e2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e4:	000dc783          	lbu	a5,0(s11)
  8003e8:	0d85                	addi	s11,s11,1
  8003ea:	3d7d                	addiw	s10,s10,-1
  8003ec:	0007851b          	sext.w	a0,a5
  8003f0:	dbe1                	beqz	a5,8003c0 <vprintfmt+0x200>
  8003f2:	fa0cd9e3          	bgez	s9,8003a4 <vprintfmt+0x1e4>
  8003f6:	b7c5                	j	8003d6 <vprintfmt+0x216>
            if (err < 0) {
  8003f8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003fc:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003fe:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800400:	41f7d71b          	sraiw	a4,a5,0x1f
  800404:	8fb9                	xor	a5,a5,a4
  800406:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80040a:	02d64563          	blt	a2,a3,800434 <vprintfmt+0x274>
  80040e:	00000797          	auipc	a5,0x0
  800412:	52278793          	addi	a5,a5,1314 # 800930 <error_string>
  800416:	00369713          	slli	a4,a3,0x3
  80041a:	97ba                	add	a5,a5,a4
  80041c:	639c                	ld	a5,0(a5)
  80041e:	cb99                	beqz	a5,800434 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800420:	86be                	mv	a3,a5
  800422:	00000617          	auipc	a2,0x0
  800426:	22660613          	addi	a2,a2,550 # 800648 <main+0x122>
  80042a:	85ca                	mv	a1,s2
  80042c:	8526                	mv	a0,s1
  80042e:	0d8000ef          	jal	800506 <printfmt>
  800432:	b3c9                	j	8001f4 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800434:	00000617          	auipc	a2,0x0
  800438:	20460613          	addi	a2,a2,516 # 800638 <main+0x112>
  80043c:	85ca                	mv	a1,s2
  80043e:	8526                	mv	a0,s1
  800440:	0c6000ef          	jal	800506 <printfmt>
  800444:	bb45                	j	8001f4 <vprintfmt+0x34>
    if (lflag >= 2) {
  800446:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800448:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80044c:	00f74363          	blt	a4,a5,800452 <vprintfmt+0x292>
    else if (lflag) {
  800450:	cf81                	beqz	a5,800468 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800452:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800456:	02044b63          	bltz	s0,80048c <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80045a:	8622                	mv	a2,s0
  80045c:	8a5e                	mv	s4,s7
  80045e:	46a9                	li	a3,10
  800460:	b541                	j	8002e0 <vprintfmt+0x120>
            lflag ++;
  800462:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800464:	8462                	mv	s0,s8
            goto reswitch;
  800466:	bb5d                	j	80021c <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800468:	000a2403          	lw	s0,0(s4)
  80046c:	b7ed                	j	800456 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80046e:	000a6603          	lwu	a2,0(s4)
  800472:	46a1                	li	a3,8
  800474:	8a2e                	mv	s4,a1
  800476:	b5ad                	j	8002e0 <vprintfmt+0x120>
  800478:	000a6603          	lwu	a2,0(s4)
  80047c:	46a9                	li	a3,10
  80047e:	8a2e                	mv	s4,a1
  800480:	b585                	j	8002e0 <vprintfmt+0x120>
  800482:	000a6603          	lwu	a2,0(s4)
  800486:	46c1                	li	a3,16
  800488:	8a2e                	mv	s4,a1
  80048a:	bd99                	j	8002e0 <vprintfmt+0x120>
                putch('-', putdat);
  80048c:	85ca                	mv	a1,s2
  80048e:	02d00513          	li	a0,45
  800492:	9482                	jalr	s1
                num = -(long long)num;
  800494:	40800633          	neg	a2,s0
  800498:	8a5e                	mv	s4,s7
  80049a:	46a9                	li	a3,10
  80049c:	b591                	j	8002e0 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80049e:	e329                	bnez	a4,8004e0 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a0:	02800793          	li	a5,40
  8004a4:	853e                	mv	a0,a5
  8004a6:	00000d97          	auipc	s11,0x0
  8004aa:	18bd8d93          	addi	s11,s11,395 # 800631 <main+0x10b>
  8004ae:	b5f5                	j	80039a <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	85e6                	mv	a1,s9
  8004b2:	856e                	mv	a0,s11
  8004b4:	c8bff0ef          	jal	80013e <strnlen>
  8004b8:	40ad0d3b          	subw	s10,s10,a0
  8004bc:	01a05863          	blez	s10,8004cc <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004c0:	85ca                	mv	a1,s2
  8004c2:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004c6:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c8:	fe0d1ce3          	bnez	s10,8004c0 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004cc:	000dc783          	lbu	a5,0(s11)
  8004d0:	0007851b          	sext.w	a0,a5
  8004d4:	ec0792e3          	bnez	a5,800398 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d8:	6a22                	ld	s4,8(sp)
  8004da:	bb29                	j	8001f4 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004dc:	8462                	mv	s0,s8
  8004de:	bbd9                	j	8002b4 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	85e6                	mv	a1,s9
  8004e2:	00000517          	auipc	a0,0x0
  8004e6:	14e50513          	addi	a0,a0,334 # 800630 <main+0x10a>
  8004ea:	c55ff0ef          	jal	80013e <strnlen>
  8004ee:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f2:	02800793          	li	a5,40
                p = "(null)";
  8004f6:	00000d97          	auipc	s11,0x0
  8004fa:	13ad8d93          	addi	s11,s11,314 # 800630 <main+0x10a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fe:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800500:	fda040e3          	bgtz	s10,8004c0 <vprintfmt+0x300>
  800504:	bd51                	j	800398 <vprintfmt+0x1d8>

0000000000800506 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800506:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800508:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80050e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800510:	ec06                	sd	ra,24(sp)
  800512:	f83a                	sd	a4,48(sp)
  800514:	fc3e                	sd	a5,56(sp)
  800516:	e0c2                	sd	a6,64(sp)
  800518:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80051a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051c:	ca5ff0ef          	jal	8001c0 <vprintfmt>
}
  800520:	60e2                	ld	ra,24(sp)
  800522:	6161                	addi	sp,sp,80
  800524:	8082                	ret

0000000000800526 <main>:
#define ARRAYSIZE (1024*1024)

uint32_t bigarray[ARRAYSIZE];

int
main(void) {
  800526:	1141                	addi	sp,sp,-16
    cprintf("Making sure bss works right...\n");
  800528:	00000517          	auipc	a0,0x0
  80052c:	1e850513          	addi	a0,a0,488 # 800710 <main+0x1ea>
main(void) {
  800530:	e406                	sd	ra,8(sp)
    cprintf("Making sure bss works right...\n");
  800532:	bcdff0ef          	jal	8000fe <cprintf>
    int i;
    for (i = 0; i < ARRAYSIZE; i ++) {
  800536:	00001597          	auipc	a1,0x1
  80053a:	aca58593          	addi	a1,a1,-1334 # 801000 <bigarray>
    cprintf("Making sure bss works right...\n");
  80053e:	87ae                	mv	a5,a1
    for (i = 0; i < ARRAYSIZE; i ++) {
  800540:	4681                	li	a3,0
  800542:	00100637          	lui	a2,0x100
  800546:	a029                	j	800550 <main+0x2a>
  800548:	2685                	addiw	a3,a3,1
  80054a:	0791                	addi	a5,a5,4
  80054c:	00c68f63          	beq	a3,a2,80056a <main+0x44>
        if (bigarray[i] != 0) {
  800550:	4398                	lw	a4,0(a5)
  800552:	db7d                	beqz	a4,800548 <main+0x22>
            panic("bigarray[%d] isn't cleared!\n", i);
  800554:	00000617          	auipc	a2,0x0
  800558:	1dc60613          	addi	a2,a2,476 # 800730 <main+0x20a>
  80055c:	45b9                	li	a1,14
  80055e:	00000517          	auipc	a0,0x0
  800562:	1f250513          	addi	a0,a0,498 # 800750 <main+0x22a>
  800566:	abbff0ef          	jal	800020 <__panic>
  80056a:	00001717          	auipc	a4,0x1
  80056e:	a9670713          	addi	a4,a4,-1386 # 801000 <bigarray>
        }
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  800572:	4781                	li	a5,0
  800574:	001006b7          	lui	a3,0x100
        bigarray[i] = i;
  800578:	c31c                	sw	a5,0(a4)
    for (i = 0; i < ARRAYSIZE; i ++) {
  80057a:	2785                	addiw	a5,a5,1
  80057c:	0711                	addi	a4,a4,4
  80057e:	fed79de3          	bne	a5,a3,800578 <main+0x52>
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  800582:	4681                	li	a3,0
  800584:	00100737          	lui	a4,0x100
  800588:	a029                	j	800592 <main+0x6c>
  80058a:	2685                	addiw	a3,a3,1 # 100001 <__panic-0x70001f>
  80058c:	0591                	addi	a1,a1,4
  80058e:	02e68063          	beq	a3,a4,8005ae <main+0x88>
        if (bigarray[i] != i) {
  800592:	419c                	lw	a5,0(a1)
  800594:	fed78be3          	beq	a5,a3,80058a <main+0x64>
            panic("bigarray[%d] didn't hold its value!\n", i);
  800598:	00000617          	auipc	a2,0x0
  80059c:	1c860613          	addi	a2,a2,456 # 800760 <main+0x23a>
  8005a0:	45d9                	li	a1,22
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	1ae50513          	addi	a0,a0,430 # 800750 <main+0x22a>
  8005aa:	a77ff0ef          	jal	800020 <__panic>
        }
    }

    cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8005ae:	00000517          	auipc	a0,0x0
  8005b2:	1da50513          	addi	a0,a0,474 # 800788 <main+0x262>
  8005b6:	b49ff0ef          	jal	8000fe <cprintf>
    cprintf("testbss may pass.\n");
  8005ba:	00000517          	auipc	a0,0x0
  8005be:	20650513          	addi	a0,a0,518 # 8007c0 <main+0x29a>
  8005c2:	b3dff0ef          	jal	8000fe <cprintf>

    bigarray[ARRAYSIZE + 1024] = 0;
    // asm volatile ("int $0x14");
    exit(0);
  8005c6:	4501                	li	a0,0
    bigarray[ARRAYSIZE + 1024] = 0;
  8005c8:	00402797          	auipc	a5,0x402
  8005cc:	a207ac23          	sw	zero,-1480(a5) # c02000 <bigarray+0x401000>
    exit(0);
  8005d0:	adbff0ef          	jal	8000aa <exit>
