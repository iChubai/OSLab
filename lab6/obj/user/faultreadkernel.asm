
obj/__user_faultreadkernel.out:     file format elf64-littleriscv


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
  800032:	52a50513          	addi	a0,a0,1322 # 800558 <main+0x34>
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
  800044:	0b8000ef          	jal	8000fc <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	090000ef          	jal	8000dc <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	52850513          	addi	a0,a0,1320 # 800578 <main+0x54>
  800058:	0a4000ef          	jal	8000fc <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	04a000ef          	jal	8000a8 <exit>

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

00000000008000a2 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000a2:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000a4:	4579                	li	a0,30
  8000a6:	bf75                	j	800062 <syscall>

00000000008000a8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000a8:	1141                	addi	sp,sp,-16
  8000aa:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ac:	ff1ff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	4d050513          	addi	a0,a0,1232 # 800580 <main+0x5c>
  8000b8:	044000ef          	jal	8000fc <cprintf>
    while (1);
  8000bc:	a001                	j	8000bc <exit+0x14>

00000000008000be <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000be:	072000ef          	jal	800130 <umain>
1:  j 1b
  8000c2:	a001                	j	8000c2 <_start+0x4>

00000000008000c4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c4:	1101                	addi	sp,sp,-32
  8000c6:	ec06                	sd	ra,24(sp)
  8000c8:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000ca:	fd9ff0ef          	jal	8000a2 <sys_putc>
    (*cnt) ++;
  8000ce:	65a2                	ld	a1,8(sp)
}
  8000d0:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000d2:	419c                	lw	a5,0(a1)
  8000d4:	2785                	addiw	a5,a5,1
  8000d6:	c19c                	sw	a5,0(a1)
}
  8000d8:	6105                	addi	sp,sp,32
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
  8000e6:	fe250513          	addi	a0,a0,-30 # 8000c4 <cputch>
  8000ea:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  8000ec:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  8000ee:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f0:	0ce000ef          	jal	8001be <vprintfmt>
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
  800102:	f42e                	sd	a1,40(sp)
  800104:	f832                	sd	a2,48(sp)
  800106:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800108:	862a                	mv	a2,a0
  80010a:	004c                	addi	a1,sp,4
  80010c:	00000517          	auipc	a0,0x0
  800110:	fb850513          	addi	a0,a0,-72 # 8000c4 <cputch>
  800114:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800116:	ec06                	sd	ra,24(sp)
  800118:	e0ba                	sd	a4,64(sp)
  80011a:	e4be                	sd	a5,72(sp)
  80011c:	e8c2                	sd	a6,80(sp)
  80011e:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800120:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800122:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800124:	09a000ef          	jal	8001be <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800128:	60e2                	ld	ra,24(sp)
  80012a:	4512                	lw	a0,4(sp)
  80012c:	6125                	addi	sp,sp,96
  80012e:	8082                	ret

0000000000800130 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    int ret = main();
  800134:	3f0000ef          	jal	800524 <main>
    exit(ret);
  800138:	f71ff0ef          	jal	8000a8 <exit>

000000000080013c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80013c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80013e:	e589                	bnez	a1,800148 <strnlen+0xc>
  800140:	a811                	j	800154 <strnlen+0x18>
        cnt ++;
  800142:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800144:	00f58863          	beq	a1,a5,800154 <strnlen+0x18>
  800148:	00f50733          	add	a4,a0,a5
  80014c:	00074703          	lbu	a4,0(a4)
  800150:	fb6d                	bnez	a4,800142 <strnlen+0x6>
  800152:	85be                	mv	a1,a5
    }
    return cnt;
}
  800154:	852e                	mv	a0,a1
  800156:	8082                	ret

0000000000800158 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800158:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	f022                	sd	s0,32(sp)
  800160:	ec26                	sd	s1,24(sp)
  800162:	e84a                	sd	s2,16(sp)
  800164:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800166:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80016c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800170:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	84aa                	mv	s1,a0
  800176:	892e                	mv	s2,a1
    if (num >= base) {
  800178:	03067d63          	bgeu	a2,a6,8001b2 <printnum+0x5a>
  80017c:	e44e                	sd	s3,8(sp)
  80017e:	89be                	mv	s3,a5
        while (-- width > 0)
  800180:	4785                	li	a5,1
  800182:	00e7d763          	bge	a5,a4,800190 <printnum+0x38>
            putch(padc, putdat);
  800186:	85ca                	mv	a1,s2
  800188:	854e                	mv	a0,s3
        while (-- width > 0)
  80018a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018c:	9482                	jalr	s1
        while (-- width > 0)
  80018e:	fc65                	bnez	s0,800186 <printnum+0x2e>
  800190:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800192:	00000797          	auipc	a5,0x0
  800196:	40678793          	addi	a5,a5,1030 # 800598 <main+0x74>
  80019a:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019e:	0007c503          	lbu	a0,0(a5)
}
  8001a2:	70a2                	ld	ra,40(sp)
  8001a4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	85ca                	mv	a1,s2
  8001a8:	87a6                	mv	a5,s1
}
  8001aa:	6942                	ld	s2,16(sp)
  8001ac:	64e2                	ld	s1,24(sp)
  8001ae:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b2:	03065633          	divu	a2,a2,a6
  8001b6:	8722                	mv	a4,s0
  8001b8:	fa1ff0ef          	jal	800158 <printnum>
  8001bc:	bfd9                	j	800192 <printnum+0x3a>

00000000008001be <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001be:	7119                	addi	sp,sp,-128
  8001c0:	f4a6                	sd	s1,104(sp)
  8001c2:	f0ca                	sd	s2,96(sp)
  8001c4:	ecce                	sd	s3,88(sp)
  8001c6:	e8d2                	sd	s4,80(sp)
  8001c8:	e4d6                	sd	s5,72(sp)
  8001ca:	e0da                	sd	s6,64(sp)
  8001cc:	f862                	sd	s8,48(sp)
  8001ce:	fc86                	sd	ra,120(sp)
  8001d0:	f8a2                	sd	s0,112(sp)
  8001d2:	fc5e                	sd	s7,56(sp)
  8001d4:	f466                	sd	s9,40(sp)
  8001d6:	f06a                	sd	s10,32(sp)
  8001d8:	ec6e                	sd	s11,24(sp)
  8001da:	84aa                	mv	s1,a0
  8001dc:	8c32                	mv	s8,a2
  8001de:	8a36                	mv	s4,a3
  8001e0:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e2:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e6:	05500b13          	li	s6,85
  8001ea:	00000a97          	auipc	s5,0x0
  8001ee:	4eea8a93          	addi	s5,s5,1262 # 8006d8 <main+0x1b4>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f2:	000c4503          	lbu	a0,0(s8)
  8001f6:	001c0413          	addi	s0,s8,1
  8001fa:	01350a63          	beq	a0,s3,80020e <vprintfmt+0x50>
            if (ch == '\0') {
  8001fe:	cd0d                	beqz	a0,800238 <vprintfmt+0x7a>
            putch(ch, putdat);
  800200:	85ca                	mv	a1,s2
  800202:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800204:	00044503          	lbu	a0,0(s0)
  800208:	0405                	addi	s0,s0,1
  80020a:	ff351ae3          	bne	a0,s3,8001fe <vprintfmt+0x40>
        width = precision = -1;
  80020e:	5cfd                	li	s9,-1
  800210:	8d66                	mv	s10,s9
        char padc = ' ';
  800212:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800216:	4b81                	li	s7,0
  800218:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	00044683          	lbu	a3,0(s0)
  80021e:	00140c13          	addi	s8,s0,1
  800222:	fdd6859b          	addiw	a1,a3,-35
  800226:	0ff5f593          	zext.b	a1,a1
  80022a:	02bb6663          	bltu	s6,a1,800256 <vprintfmt+0x98>
  80022e:	058a                	slli	a1,a1,0x2
  800230:	95d6                	add	a1,a1,s5
  800232:	4198                	lw	a4,0(a1)
  800234:	9756                	add	a4,a4,s5
  800236:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800238:	70e6                	ld	ra,120(sp)
  80023a:	7446                	ld	s0,112(sp)
  80023c:	74a6                	ld	s1,104(sp)
  80023e:	7906                	ld	s2,96(sp)
  800240:	69e6                	ld	s3,88(sp)
  800242:	6a46                	ld	s4,80(sp)
  800244:	6aa6                	ld	s5,72(sp)
  800246:	6b06                	ld	s6,64(sp)
  800248:	7be2                	ld	s7,56(sp)
  80024a:	7c42                	ld	s8,48(sp)
  80024c:	7ca2                	ld	s9,40(sp)
  80024e:	7d02                	ld	s10,32(sp)
  800250:	6de2                	ld	s11,24(sp)
  800252:	6109                	addi	sp,sp,128
  800254:	8082                	ret
            putch('%', putdat);
  800256:	85ca                	mv	a1,s2
  800258:	02500513          	li	a0,37
  80025c:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80025e:	fff44783          	lbu	a5,-1(s0)
  800262:	02500713          	li	a4,37
  800266:	8c22                	mv	s8,s0
  800268:	f8e785e3          	beq	a5,a4,8001f2 <vprintfmt+0x34>
  80026c:	ffec4783          	lbu	a5,-2(s8)
  800270:	1c7d                	addi	s8,s8,-1
  800272:	fee79de3          	bne	a5,a4,80026c <vprintfmt+0xae>
  800276:	bfb5                	j	8001f2 <vprintfmt+0x34>
                ch = *fmt;
  800278:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80027c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80027e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800282:	fd06071b          	addiw	a4,a2,-48
  800286:	24e56a63          	bltu	a0,a4,8004da <vprintfmt+0x31c>
                ch = *fmt;
  80028a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80028e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800292:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800296:	0197073b          	addw	a4,a4,s9
  80029a:	0017171b          	slliw	a4,a4,0x1
  80029e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002a0:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002a4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002a6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002aa:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002ae:	feb570e3          	bgeu	a0,a1,80028e <vprintfmt+0xd0>
            if (width < 0)
  8002b2:	f60d54e3          	bgez	s10,80021a <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002b6:	8d66                	mv	s10,s9
  8002b8:	5cfd                	li	s9,-1
  8002ba:	b785                	j	80021a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002bc:	8db6                	mv	s11,a3
  8002be:	8462                	mv	s0,s8
  8002c0:	bfa9                	j	80021a <vprintfmt+0x5c>
  8002c2:	8462                	mv	s0,s8
            altflag = 1;
  8002c4:	4b85                	li	s7,1
            goto reswitch;
  8002c6:	bf91                	j	80021a <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ca:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ce:	00f74463          	blt	a4,a5,8002d6 <vprintfmt+0x118>
    else if (lflag) {
  8002d2:	1a078763          	beqz	a5,800480 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002d6:	000a3603          	ld	a2,0(s4)
  8002da:	46c1                	li	a3,16
  8002dc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002de:	000d879b          	sext.w	a5,s11
  8002e2:	876a                	mv	a4,s10
  8002e4:	85ca                	mv	a1,s2
  8002e6:	8526                	mv	a0,s1
  8002e8:	e71ff0ef          	jal	800158 <printnum>
            break;
  8002ec:	b719                	j	8001f2 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002ee:	000a2503          	lw	a0,0(s4)
  8002f2:	85ca                	mv	a1,s2
  8002f4:	0a21                	addi	s4,s4,8
  8002f6:	9482                	jalr	s1
            break;
  8002f8:	bded                	j	8001f2 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800300:	00f74463          	blt	a4,a5,800308 <vprintfmt+0x14a>
    else if (lflag) {
  800304:	16078963          	beqz	a5,800476 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800308:	000a3603          	ld	a2,0(s4)
  80030c:	46a9                	li	a3,10
  80030e:	8a2e                	mv	s4,a1
  800310:	b7f9                	j	8002de <vprintfmt+0x120>
            putch('0', putdat);
  800312:	85ca                	mv	a1,s2
  800314:	03000513          	li	a0,48
  800318:	9482                	jalr	s1
            putch('x', putdat);
  80031a:	85ca                	mv	a1,s2
  80031c:	07800513          	li	a0,120
  800320:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800322:	000a3603          	ld	a2,0(s4)
            goto number;
  800326:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800328:	0a21                	addi	s4,s4,8
            goto number;
  80032a:	bf55                	j	8002de <vprintfmt+0x120>
            putch(ch, putdat);
  80032c:	85ca                	mv	a1,s2
  80032e:	02500513          	li	a0,37
  800332:	9482                	jalr	s1
            break;
  800334:	bd7d                	j	8001f2 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800336:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80033a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80033c:	0a21                	addi	s4,s4,8
            goto process_precision;
  80033e:	bf95                	j	8002b2 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800340:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800342:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800346:	00f74463          	blt	a4,a5,80034e <vprintfmt+0x190>
    else if (lflag) {
  80034a:	12078163          	beqz	a5,80046c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80034e:	000a3603          	ld	a2,0(s4)
  800352:	46a1                	li	a3,8
  800354:	8a2e                	mv	s4,a1
  800356:	b761                	j	8002de <vprintfmt+0x120>
            if (width < 0)
  800358:	876a                	mv	a4,s10
  80035a:	000d5363          	bgez	s10,800360 <vprintfmt+0x1a2>
  80035e:	4701                	li	a4,0
  800360:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800364:	8462                	mv	s0,s8
            goto reswitch;
  800366:	bd55                	j	80021a <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800368:	000d841b          	sext.w	s0,s11
  80036c:	fd340793          	addi	a5,s0,-45
  800370:	00f037b3          	snez	a5,a5
  800374:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800378:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80037c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80037e:	008a0793          	addi	a5,s4,8
  800382:	e43e                	sd	a5,8(sp)
  800384:	100d8c63          	beqz	s11,80049c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800388:	12071363          	bnez	a4,8004ae <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038c:	000dc783          	lbu	a5,0(s11)
  800390:	0007851b          	sext.w	a0,a5
  800394:	c78d                	beqz	a5,8003be <vprintfmt+0x200>
  800396:	0d85                	addi	s11,s11,1
  800398:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80039a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	000cc563          	bltz	s9,8003a8 <vprintfmt+0x1ea>
  8003a2:	3cfd                	addiw	s9,s9,-1
  8003a4:	008c8d63          	beq	s9,s0,8003be <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a8:	020b9663          	bnez	s7,8003d4 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003ac:	85ca                	mv	a1,s2
  8003ae:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b0:	000dc783          	lbu	a5,0(s11)
  8003b4:	0d85                	addi	s11,s11,1
  8003b6:	3d7d                	addiw	s10,s10,-1
  8003b8:	0007851b          	sext.w	a0,a5
  8003bc:	f3ed                	bnez	a5,80039e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003be:	01a05963          	blez	s10,8003d0 <vprintfmt+0x212>
                putch(' ', putdat);
  8003c2:	85ca                	mv	a1,s2
  8003c4:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c8:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ca:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003cc:	fe0d1be3          	bnez	s10,8003c2 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d0:	6a22                	ld	s4,8(sp)
  8003d2:	b505                	j	8001f2 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d4:	3781                	addiw	a5,a5,-32
  8003d6:	fcfa7be3          	bgeu	s4,a5,8003ac <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003da:	03f00513          	li	a0,63
  8003de:	85ca                	mv	a1,s2
  8003e0:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e2:	000dc783          	lbu	a5,0(s11)
  8003e6:	0d85                	addi	s11,s11,1
  8003e8:	3d7d                	addiw	s10,s10,-1
  8003ea:	0007851b          	sext.w	a0,a5
  8003ee:	dbe1                	beqz	a5,8003be <vprintfmt+0x200>
  8003f0:	fa0cd9e3          	bgez	s9,8003a2 <vprintfmt+0x1e4>
  8003f4:	b7c5                	j	8003d4 <vprintfmt+0x216>
            if (err < 0) {
  8003f6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003fa:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003fc:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003fe:	41f7d71b          	sraiw	a4,a5,0x1f
  800402:	8fb9                	xor	a5,a5,a4
  800404:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800408:	02d64563          	blt	a2,a3,800432 <vprintfmt+0x274>
  80040c:	00000797          	auipc	a5,0x0
  800410:	42478793          	addi	a5,a5,1060 # 800830 <error_string>
  800414:	00369713          	slli	a4,a3,0x3
  800418:	97ba                	add	a5,a5,a4
  80041a:	639c                	ld	a5,0(a5)
  80041c:	cb99                	beqz	a5,800432 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80041e:	86be                	mv	a3,a5
  800420:	00000617          	auipc	a2,0x0
  800424:	1a860613          	addi	a2,a2,424 # 8005c8 <main+0xa4>
  800428:	85ca                	mv	a1,s2
  80042a:	8526                	mv	a0,s1
  80042c:	0d8000ef          	jal	800504 <printfmt>
  800430:	b3c9                	j	8001f2 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800432:	00000617          	auipc	a2,0x0
  800436:	18660613          	addi	a2,a2,390 # 8005b8 <main+0x94>
  80043a:	85ca                	mv	a1,s2
  80043c:	8526                	mv	a0,s1
  80043e:	0c6000ef          	jal	800504 <printfmt>
  800442:	bb45                	j	8001f2 <vprintfmt+0x34>
    if (lflag >= 2) {
  800444:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800446:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80044a:	00f74363          	blt	a4,a5,800450 <vprintfmt+0x292>
    else if (lflag) {
  80044e:	cf81                	beqz	a5,800466 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800450:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800454:	02044b63          	bltz	s0,80048a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800458:	8622                	mv	a2,s0
  80045a:	8a5e                	mv	s4,s7
  80045c:	46a9                	li	a3,10
  80045e:	b541                	j	8002de <vprintfmt+0x120>
            lflag ++;
  800460:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800462:	8462                	mv	s0,s8
            goto reswitch;
  800464:	bb5d                	j	80021a <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800466:	000a2403          	lw	s0,0(s4)
  80046a:	b7ed                	j	800454 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80046c:	000a6603          	lwu	a2,0(s4)
  800470:	46a1                	li	a3,8
  800472:	8a2e                	mv	s4,a1
  800474:	b5ad                	j	8002de <vprintfmt+0x120>
  800476:	000a6603          	lwu	a2,0(s4)
  80047a:	46a9                	li	a3,10
  80047c:	8a2e                	mv	s4,a1
  80047e:	b585                	j	8002de <vprintfmt+0x120>
  800480:	000a6603          	lwu	a2,0(s4)
  800484:	46c1                	li	a3,16
  800486:	8a2e                	mv	s4,a1
  800488:	bd99                	j	8002de <vprintfmt+0x120>
                putch('-', putdat);
  80048a:	85ca                	mv	a1,s2
  80048c:	02d00513          	li	a0,45
  800490:	9482                	jalr	s1
                num = -(long long)num;
  800492:	40800633          	neg	a2,s0
  800496:	8a5e                	mv	s4,s7
  800498:	46a9                	li	a3,10
  80049a:	b591                	j	8002de <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80049c:	e329                	bnez	a4,8004de <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049e:	02800793          	li	a5,40
  8004a2:	853e                	mv	a0,a5
  8004a4:	00000d97          	auipc	s11,0x0
  8004a8:	10dd8d93          	addi	s11,s11,269 # 8005b1 <main+0x8d>
  8004ac:	b5f5                	j	800398 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	85e6                	mv	a1,s9
  8004b0:	856e                	mv	a0,s11
  8004b2:	c8bff0ef          	jal	80013c <strnlen>
  8004b6:	40ad0d3b          	subw	s10,s10,a0
  8004ba:	01a05863          	blez	s10,8004ca <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004be:	85ca                	mv	a1,s2
  8004c0:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004c4:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c6:	fe0d1ce3          	bnez	s10,8004be <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ca:	000dc783          	lbu	a5,0(s11)
  8004ce:	0007851b          	sext.w	a0,a5
  8004d2:	ec0792e3          	bnez	a5,800396 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d6:	6a22                	ld	s4,8(sp)
  8004d8:	bb29                	j	8001f2 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004da:	8462                	mv	s0,s8
  8004dc:	bbd9                	j	8002b2 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	85e6                	mv	a1,s9
  8004e0:	00000517          	auipc	a0,0x0
  8004e4:	0d050513          	addi	a0,a0,208 # 8005b0 <main+0x8c>
  8004e8:	c55ff0ef          	jal	80013c <strnlen>
  8004ec:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f0:	02800793          	li	a5,40
                p = "(null)";
  8004f4:	00000d97          	auipc	s11,0x0
  8004f8:	0bcd8d93          	addi	s11,s11,188 # 8005b0 <main+0x8c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fc:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fe:	fda040e3          	bgtz	s10,8004be <vprintfmt+0x300>
  800502:	bd51                	j	800396 <vprintfmt+0x1d8>

0000000000800504 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800504:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800506:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80050c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	ec06                	sd	ra,24(sp)
  800510:	f83a                	sd	a4,48(sp)
  800512:	fc3e                	sd	a5,56(sp)
  800514:	e0c2                	sd	a6,64(sp)
  800516:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800518:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051a:	ca5ff0ef          	jal	8001be <vprintfmt>
}
  80051e:	60e2                	ld	ra,24(sp)
  800520:	6161                	addi	sp,sp,80
  800522:	8082                	ret

0000000000800524 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800524:	3eb00793          	li	a5,1003
  800528:	07da                	slli	a5,a5,0x16
  80052a:	438c                	lw	a1,0(a5)
main(void) {
  80052c:	1141                	addi	sp,sp,-16
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  80052e:	00000517          	auipc	a0,0x0
  800532:	16250513          	addi	a0,a0,354 # 800690 <main+0x16c>
main(void) {
  800536:	e406                	sd	ra,8(sp)
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800538:	bc5ff0ef          	jal	8000fc <cprintf>
    panic("FAIL: T.T\n");
  80053c:	00000617          	auipc	a2,0x0
  800540:	17460613          	addi	a2,a2,372 # 8006b0 <main+0x18c>
  800544:	459d                	li	a1,7
  800546:	00000517          	auipc	a0,0x0
  80054a:	17a50513          	addi	a0,a0,378 # 8006c0 <main+0x19c>
  80054e:	ad3ff0ef          	jal	800020 <__panic>
