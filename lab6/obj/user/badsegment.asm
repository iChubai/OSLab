
obj/__user_badsegment.out:     file format elf64-littleriscv


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
  800034:	53850513          	addi	a0,a0,1336 # 800568 <main+0x20>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0b8000ef          	jal	ra,8000fc <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	090000ef          	jal	ra,8000dc <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	53850513          	addi	a0,a0,1336 # 800588 <main+0x40>
  800058:	0a4000ef          	jal	ra,8000fc <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	048000ef          	jal	ra,8000a6 <exit>

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
  800082:	4522                	lw	a0,8(sp)
  800084:	55a2                	lw	a1,40(sp)
  800086:	5642                	lw	a2,48(sp)
  800088:	56e2                	lw	a3,56(sp)
  80008a:	4706                	lw	a4,64(sp)
  80008c:	47a6                	lw	a5,72(sp)
  80008e:	00000073          	ecall
  800092:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800094:	4572                	lw	a0,28(sp)
  800096:	6149                	addi	sp,sp,144
  800098:	8082                	ret

000000000080009a <sys_exit>:

int
sys_exit(int64_t error_code) {
  80009a:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80009c:	4505                	li	a0,1
  80009e:	b7d1                	j	800062 <syscall>

00000000008000a0 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000a0:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000a2:	4579                	li	a0,30
  8000a4:	bf7d                	j	800062 <syscall>

00000000008000a6 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000a6:	1141                	addi	sp,sp,-16
  8000a8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000aa:	ff1ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ae:	00000517          	auipc	a0,0x0
  8000b2:	4e250513          	addi	a0,a0,1250 # 800590 <main+0x48>
  8000b6:	046000ef          	jal	ra,8000fc <cprintf>
    while (1);
  8000ba:	a001                	j	8000ba <exit+0x14>

00000000008000bc <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000bc:	076000ef          	jal	ra,800132 <umain>
1:  j 1b
  8000c0:	a001                	j	8000c0 <_start+0x4>

00000000008000c2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e022                	sd	s0,0(sp)
  8000c6:	e406                	sd	ra,8(sp)
  8000c8:	842e                	mv	s0,a1
    sys_putc(c);
  8000ca:	fd7ff0ef          	jal	ra,8000a0 <sys_putc>
    (*cnt) ++;
  8000ce:	401c                	lw	a5,0(s0)
}
  8000d0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000d2:	2785                	addiw	a5,a5,1
  8000d4:	c01c                	sw	a5,0(s0)
}
  8000d6:	6402                	ld	s0,0(sp)
  8000d8:	0141                	addi	sp,sp,16
  8000da:	8082                	ret

00000000008000dc <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000dc:	1101                	addi	sp,sp,-32
  8000de:	862a                	mv	a2,a0
  8000e0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000e2:	00000517          	auipc	a0,0x0
  8000e6:	fe050513          	addi	a0,a0,-32 # 8000c2 <cputch>
  8000ea:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  8000ec:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  8000ee:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f0:	0d6000ef          	jal	ra,8001c6 <vprintfmt>
    return cnt;
}
  8000f4:	60e2                	ld	ra,24(sp)
  8000f6:	4532                	lw	a0,12(sp)
  8000f8:	6105                	addi	sp,sp,32
  8000fa:	8082                	ret

00000000008000fc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000fc:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000fe:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800102:	8e2a                	mv	t3,a0
  800104:	f42e                	sd	a1,40(sp)
  800106:	f832                	sd	a2,48(sp)
  800108:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010a:	00000517          	auipc	a0,0x0
  80010e:	fb850513          	addi	a0,a0,-72 # 8000c2 <cputch>
  800112:	004c                	addi	a1,sp,4
  800114:	869a                	mv	a3,t1
  800116:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  800118:	ec06                	sd	ra,24(sp)
  80011a:	e0ba                	sd	a4,64(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800122:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800124:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800126:	0a0000ef          	jal	ra,8001c6 <vprintfmt>
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
  800136:	412000ef          	jal	ra,800548 <main>
    exit(ret);
  80013a:	f6dff0ef          	jal	ra,8000a6 <exit>

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
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800160:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800166:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	f022                	sd	s0,32(sp)
  80016c:	ec26                	sd	s1,24(sp)
  80016e:	e84a                	sd	s2,16(sp)
  800170:	f406                	sd	ra,40(sp)
  800172:	e44e                	sd	s3,8(sp)
  800174:	84aa                	mv	s1,a0
  800176:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800178:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80017e:	03067e63          	bgeu	a2,a6,8001ba <printnum+0x60>
  800182:	89be                	mv	s3,a5
        while (-- width > 0)
  800184:	00805763          	blez	s0,800192 <printnum+0x38>
  800188:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018a:	85ca                	mv	a1,s2
  80018c:	854e                	mv	a0,s3
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800192:	1a02                	slli	s4,s4,0x20
  800194:	00000797          	auipc	a5,0x0
  800198:	41478793          	addi	a5,a5,1044 # 8005a8 <main+0x60>
  80019c:	020a5a13          	srli	s4,s4,0x20
  8001a0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	000a4503          	lbu	a0,0(s4)
}
  8001a8:	70a2                	ld	ra,40(sp)
  8001aa:	69a2                	ld	s3,8(sp)
  8001ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	87a6                	mv	a5,s1
}
  8001b2:	6942                	ld	s2,16(sp)
  8001b4:	64e2                	ld	s1,24(sp)
  8001b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ba:	03065633          	divu	a2,a2,a6
  8001be:	8722                	mv	a4,s0
  8001c0:	f9bff0ef          	jal	ra,80015a <printnum>
  8001c4:	b7f9                	j	800192 <printnum+0x38>

00000000008001c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c6:	7119                	addi	sp,sp,-128
  8001c8:	f4a6                	sd	s1,104(sp)
  8001ca:	f0ca                	sd	s2,96(sp)
  8001cc:	ecce                	sd	s3,88(sp)
  8001ce:	e8d2                	sd	s4,80(sp)
  8001d0:	e4d6                	sd	s5,72(sp)
  8001d2:	e0da                	sd	s6,64(sp)
  8001d4:	fc5e                	sd	s7,56(sp)
  8001d6:	f06a                	sd	s10,32(sp)
  8001d8:	fc86                	sd	ra,120(sp)
  8001da:	f8a2                	sd	s0,112(sp)
  8001dc:	f862                	sd	s8,48(sp)
  8001de:	f466                	sd	s9,40(sp)
  8001e0:	ec6e                	sd	s11,24(sp)
  8001e2:	892a                	mv	s2,a0
  8001e4:	84ae                	mv	s1,a1
  8001e6:	8d32                	mv	s10,a2
  8001e8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ea:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ee:	5b7d                	li	s6,-1
  8001f0:	00000a97          	auipc	s5,0x0
  8001f4:	3eca8a93          	addi	s5,s5,1004 # 8005dc <main+0x94>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f8:	00000b97          	auipc	s7,0x0
  8001fc:	600b8b93          	addi	s7,s7,1536 # 8007f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	000d4503          	lbu	a0,0(s10)
  800204:	001d0413          	addi	s0,s10,1
  800208:	01350a63          	beq	a0,s3,80021c <vprintfmt+0x56>
            if (ch == '\0') {
  80020c:	c121                	beqz	a0,80024c <vprintfmt+0x86>
            putch(ch, putdat);
  80020e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800212:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	fff44503          	lbu	a0,-1(s0)
  800218:	ff351ae3          	bne	a0,s3,80020c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80021c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800220:	02000793          	li	a5,32
        lflag = altflag = 0;
  800224:	4c81                	li	s9,0
  800226:	4881                	li	a7,0
        width = precision = -1;
  800228:	5c7d                	li	s8,-1
  80022a:	5dfd                	li	s11,-1
  80022c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800230:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	fdd6059b          	addiw	a1,a2,-35
  800236:	0ff5f593          	zext.b	a1,a1
  80023a:	00140d13          	addi	s10,s0,1
  80023e:	04b56263          	bltu	a0,a1,800282 <vprintfmt+0xbc>
  800242:	058a                	slli	a1,a1,0x2
  800244:	95d6                	add	a1,a1,s5
  800246:	4194                	lw	a3,0(a1)
  800248:	96d6                	add	a3,a3,s5
  80024a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80024c:	70e6                	ld	ra,120(sp)
  80024e:	7446                	ld	s0,112(sp)
  800250:	74a6                	ld	s1,104(sp)
  800252:	7906                	ld	s2,96(sp)
  800254:	69e6                	ld	s3,88(sp)
  800256:	6a46                	ld	s4,80(sp)
  800258:	6aa6                	ld	s5,72(sp)
  80025a:	6b06                	ld	s6,64(sp)
  80025c:	7be2                	ld	s7,56(sp)
  80025e:	7c42                	ld	s8,48(sp)
  800260:	7ca2                	ld	s9,40(sp)
  800262:	7d02                	ld	s10,32(sp)
  800264:	6de2                	ld	s11,24(sp)
  800266:	6109                	addi	sp,sp,128
  800268:	8082                	ret
            padc = '0';
  80026a:	87b2                	mv	a5,a2
            goto reswitch;
  80026c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800270:	846a                	mv	s0,s10
  800272:	00140d13          	addi	s10,s0,1
  800276:	fdd6059b          	addiw	a1,a2,-35
  80027a:	0ff5f593          	zext.b	a1,a1
  80027e:	fcb572e3          	bgeu	a0,a1,800242 <vprintfmt+0x7c>
            putch('%', putdat);
  800282:	85a6                	mv	a1,s1
  800284:	02500513          	li	a0,37
  800288:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80028a:	fff44783          	lbu	a5,-1(s0)
  80028e:	8d22                	mv	s10,s0
  800290:	f73788e3          	beq	a5,s3,800200 <vprintfmt+0x3a>
  800294:	ffed4783          	lbu	a5,-2(s10)
  800298:	1d7d                	addi	s10,s10,-1
  80029a:	ff379de3          	bne	a5,s3,800294 <vprintfmt+0xce>
  80029e:	b78d                	j	800200 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002a0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002aa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002ae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002b2:	02d86463          	bltu	a6,a3,8002da <vprintfmt+0x114>
                ch = *fmt;
  8002b6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002ba:	002c169b          	slliw	a3,s8,0x2
  8002be:	0186873b          	addw	a4,a3,s8
  8002c2:	0017171b          	slliw	a4,a4,0x1
  8002c6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002c8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ce:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002d2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d6:	fed870e3          	bgeu	a6,a3,8002b6 <vprintfmt+0xf0>
            if (width < 0)
  8002da:	f40ddce3          	bgez	s11,800232 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002de:	8de2                	mv	s11,s8
  8002e0:	5c7d                	li	s8,-1
  8002e2:	bf81                	j	800232 <vprintfmt+0x6c>
            if (width < 0)
  8002e4:	fffdc693          	not	a3,s11
  8002e8:	96fd                	srai	a3,a3,0x3f
  8002ea:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002ee:	00144603          	lbu	a2,1(s0)
  8002f2:	2d81                	sext.w	s11,s11
  8002f4:	846a                	mv	s0,s10
            goto reswitch;
  8002f6:	bf35                	j	800232 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002f8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002fc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800300:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800302:	846a                	mv	s0,s10
            goto process_precision;
  800304:	bfd9                	j	8002da <vprintfmt+0x114>
    if (lflag >= 2) {
  800306:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800308:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80030c:	01174463          	blt	a4,a7,800314 <vprintfmt+0x14e>
    else if (lflag) {
  800310:	1a088e63          	beqz	a7,8004cc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800314:	000a3603          	ld	a2,0(s4)
  800318:	46c1                	li	a3,16
  80031a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80031c:	2781                	sext.w	a5,a5
  80031e:	876e                	mv	a4,s11
  800320:	85a6                	mv	a1,s1
  800322:	854a                	mv	a0,s2
  800324:	e37ff0ef          	jal	ra,80015a <printnum>
            break;
  800328:	bde1                	j	800200 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80032a:	000a2503          	lw	a0,0(s4)
  80032e:	85a6                	mv	a1,s1
  800330:	0a21                	addi	s4,s4,8
  800332:	9902                	jalr	s2
            break;
  800334:	b5f1                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800336:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800338:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80033c:	01174463          	blt	a4,a7,800344 <vprintfmt+0x17e>
    else if (lflag) {
  800340:	18088163          	beqz	a7,8004c2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800344:	000a3603          	ld	a2,0(s4)
  800348:	46a9                	li	a3,10
  80034a:	8a2e                	mv	s4,a1
  80034c:	bfc1                	j	80031c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  80034e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800352:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800354:	846a                	mv	s0,s10
            goto reswitch;
  800356:	bdf1                	j	800232 <vprintfmt+0x6c>
            putch(ch, putdat);
  800358:	85a6                	mv	a1,s1
  80035a:	02500513          	li	a0,37
  80035e:	9902                	jalr	s2
            break;
  800360:	b545                	j	800200 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800362:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800366:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800368:	846a                	mv	s0,s10
            goto reswitch;
  80036a:	b5e1                	j	800232 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80036c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80036e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800372:	01174463          	blt	a4,a7,80037a <vprintfmt+0x1b4>
    else if (lflag) {
  800376:	14088163          	beqz	a7,8004b8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80037a:	000a3603          	ld	a2,0(s4)
  80037e:	46a1                	li	a3,8
  800380:	8a2e                	mv	s4,a1
  800382:	bf69                	j	80031c <vprintfmt+0x156>
            putch('0', putdat);
  800384:	03000513          	li	a0,48
  800388:	85a6                	mv	a1,s1
  80038a:	e03e                	sd	a5,0(sp)
  80038c:	9902                	jalr	s2
            putch('x', putdat);
  80038e:	85a6                	mv	a1,s1
  800390:	07800513          	li	a0,120
  800394:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800396:	0a21                	addi	s4,s4,8
            goto number;
  800398:	6782                	ld	a5,0(sp)
  80039a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80039c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003a0:	bfb5                	j	80031c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a2:	000a3403          	ld	s0,0(s4)
  8003a6:	008a0713          	addi	a4,s4,8
  8003aa:	e03a                	sd	a4,0(sp)
  8003ac:	14040263          	beqz	s0,8004f0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003b0:	0fb05763          	blez	s11,80049e <vprintfmt+0x2d8>
  8003b4:	02d00693          	li	a3,45
  8003b8:	0cd79163          	bne	a5,a3,80047a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003bc:	00044783          	lbu	a5,0(s0)
  8003c0:	0007851b          	sext.w	a0,a5
  8003c4:	cf85                	beqz	a5,8003fc <vprintfmt+0x236>
  8003c6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ca:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ce:	000c4563          	bltz	s8,8003d8 <vprintfmt+0x212>
  8003d2:	3c7d                	addiw	s8,s8,-1
  8003d4:	036c0263          	beq	s8,s6,8003f8 <vprintfmt+0x232>
                    putch('?', putdat);
  8003d8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003da:	0e0c8e63          	beqz	s9,8004d6 <vprintfmt+0x310>
  8003de:	3781                	addiw	a5,a5,-32
  8003e0:	0ef47b63          	bgeu	s0,a5,8004d6 <vprintfmt+0x310>
                    putch('?', putdat);
  8003e4:	03f00513          	li	a0,63
  8003e8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ea:	000a4783          	lbu	a5,0(s4)
  8003ee:	3dfd                	addiw	s11,s11,-1
  8003f0:	0a05                	addi	s4,s4,1
  8003f2:	0007851b          	sext.w	a0,a5
  8003f6:	ffe1                	bnez	a5,8003ce <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003f8:	01b05963          	blez	s11,80040a <vprintfmt+0x244>
  8003fc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003fe:	85a6                	mv	a1,s1
  800400:	02000513          	li	a0,32
  800404:	9902                	jalr	s2
            for (; width > 0; width --) {
  800406:	fe0d9be3          	bnez	s11,8003fc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80040a:	6a02                	ld	s4,0(sp)
  80040c:	bbd5                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80040e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800410:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800414:	01174463          	blt	a4,a7,80041c <vprintfmt+0x256>
    else if (lflag) {
  800418:	08088d63          	beqz	a7,8004b2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80041c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800420:	0a044d63          	bltz	s0,8004da <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800424:	8622                	mv	a2,s0
  800426:	8a66                	mv	s4,s9
  800428:	46a9                	li	a3,10
  80042a:	bdcd                	j	80031c <vprintfmt+0x156>
            err = va_arg(ap, int);
  80042c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800430:	4761                	li	a4,24
            err = va_arg(ap, int);
  800432:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800434:	41f7d69b          	sraiw	a3,a5,0x1f
  800438:	8fb5                	xor	a5,a5,a3
  80043a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80043e:	02d74163          	blt	a4,a3,800460 <vprintfmt+0x29a>
  800442:	00369793          	slli	a5,a3,0x3
  800446:	97de                	add	a5,a5,s7
  800448:	639c                	ld	a5,0(a5)
  80044a:	cb99                	beqz	a5,800460 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80044c:	86be                	mv	a3,a5
  80044e:	00000617          	auipc	a2,0x0
  800452:	18a60613          	addi	a2,a2,394 # 8005d8 <main+0x90>
  800456:	85a6                	mv	a1,s1
  800458:	854a                	mv	a0,s2
  80045a:	0ce000ef          	jal	ra,800528 <printfmt>
  80045e:	b34d                	j	800200 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800460:	00000617          	auipc	a2,0x0
  800464:	16860613          	addi	a2,a2,360 # 8005c8 <main+0x80>
  800468:	85a6                	mv	a1,s1
  80046a:	854a                	mv	a0,s2
  80046c:	0bc000ef          	jal	ra,800528 <printfmt>
  800470:	bb41                	j	800200 <vprintfmt+0x3a>
                p = "(null)";
  800472:	00000417          	auipc	s0,0x0
  800476:	14e40413          	addi	s0,s0,334 # 8005c0 <main+0x78>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047a:	85e2                	mv	a1,s8
  80047c:	8522                	mv	a0,s0
  80047e:	e43e                	sd	a5,8(sp)
  800480:	cbfff0ef          	jal	ra,80013e <strnlen>
  800484:	40ad8dbb          	subw	s11,s11,a0
  800488:	01b05b63          	blez	s11,80049e <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80048c:	67a2                	ld	a5,8(sp)
  80048e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800492:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800494:	85a6                	mv	a1,s1
  800496:	8552                	mv	a0,s4
  800498:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049a:	fe0d9ce3          	bnez	s11,800492 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049e:	00044783          	lbu	a5,0(s0)
  8004a2:	00140a13          	addi	s4,s0,1
  8004a6:	0007851b          	sext.w	a0,a5
  8004aa:	d3a5                	beqz	a5,80040a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ac:	05e00413          	li	s0,94
  8004b0:	bf39                	j	8003ce <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004b2:	000a2403          	lw	s0,0(s4)
  8004b6:	b7ad                	j	800420 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004b8:	000a6603          	lwu	a2,0(s4)
  8004bc:	46a1                	li	a3,8
  8004be:	8a2e                	mv	s4,a1
  8004c0:	bdb1                	j	80031c <vprintfmt+0x156>
  8004c2:	000a6603          	lwu	a2,0(s4)
  8004c6:	46a9                	li	a3,10
  8004c8:	8a2e                	mv	s4,a1
  8004ca:	bd89                	j	80031c <vprintfmt+0x156>
  8004cc:	000a6603          	lwu	a2,0(s4)
  8004d0:	46c1                	li	a3,16
  8004d2:	8a2e                	mv	s4,a1
  8004d4:	b5a1                	j	80031c <vprintfmt+0x156>
                    putch(ch, putdat);
  8004d6:	9902                	jalr	s2
  8004d8:	bf09                	j	8003ea <vprintfmt+0x224>
                putch('-', putdat);
  8004da:	85a6                	mv	a1,s1
  8004dc:	02d00513          	li	a0,45
  8004e0:	e03e                	sd	a5,0(sp)
  8004e2:	9902                	jalr	s2
                num = -(long long)num;
  8004e4:	6782                	ld	a5,0(sp)
  8004e6:	8a66                	mv	s4,s9
  8004e8:	40800633          	neg	a2,s0
  8004ec:	46a9                	li	a3,10
  8004ee:	b53d                	j	80031c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004f0:	03b05163          	blez	s11,800512 <vprintfmt+0x34c>
  8004f4:	02d00693          	li	a3,45
  8004f8:	f6d79de3          	bne	a5,a3,800472 <vprintfmt+0x2ac>
                p = "(null)";
  8004fc:	00000417          	auipc	s0,0x0
  800500:	0c440413          	addi	s0,s0,196 # 8005c0 <main+0x78>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800504:	02800793          	li	a5,40
  800508:	02800513          	li	a0,40
  80050c:	00140a13          	addi	s4,s0,1
  800510:	bd6d                	j	8003ca <vprintfmt+0x204>
  800512:	00000a17          	auipc	s4,0x0
  800516:	0afa0a13          	addi	s4,s4,175 # 8005c1 <main+0x79>
  80051a:	02800513          	li	a0,40
  80051e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800522:	05e00413          	li	s0,94
  800526:	b565                	j	8003ce <vprintfmt+0x208>

0000000000800528 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800528:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800530:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800532:	ec06                	sd	ra,24(sp)
  800534:	f83a                	sd	a4,48(sp)
  800536:	fc3e                	sd	a5,56(sp)
  800538:	e0c2                	sd	a6,64(sp)
  80053a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80053c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053e:	c89ff0ef          	jal	ra,8001c6 <vprintfmt>
}
  800542:	60e2                	ld	ra,24(sp)
  800544:	6161                	addi	sp,sp,80
  800546:	8082                	ret

0000000000800548 <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  800548:	1141                	addi	sp,sp,-16
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  80054a:	00000617          	auipc	a2,0x0
  80054e:	37660613          	addi	a2,a2,886 # 8008c0 <error_string+0xc8>
  800552:	45a5                	li	a1,9
  800554:	00000517          	auipc	a0,0x0
  800558:	37c50513          	addi	a0,a0,892 # 8008d0 <error_string+0xd8>
main(void) {
  80055c:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  80055e:	ac3ff0ef          	jal	ra,800020 <__panic>
