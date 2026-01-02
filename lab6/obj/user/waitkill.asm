
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
  800032:	66250513          	addi	a0,a0,1634 # 800690 <main+0xc0>
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
  800044:	0dc000ef          	jal	800120 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b4000ef          	jal	800100 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	77850513          	addi	a0,a0,1912 # 8007c8 <main+0x1f8>
  800058:	0c8000ef          	jal	800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	064000ef          	jal	8000c2 <exit>

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
  8000c6:	fd7ff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	5e650513          	addi	a0,a0,1510 # 8006b0 <main+0xe0>
  8000d2:	04e000ef          	jal	800120 <cprintf>
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
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000e2:	072000ef          	jal	800154 <umain>
1:  j 1b
  8000e6:	a001                	j	8000e6 <_start+0x4>

00000000008000e8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e8:	1101                	addi	sp,sp,-32
  8000ea:	ec06                	sd	ra,24(sp)
  8000ec:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000ee:	fcfff0ef          	jal	8000bc <sys_putc>
    (*cnt) ++;
  8000f2:	65a2                	ld	a1,8(sp)
}
  8000f4:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000f6:	419c                	lw	a5,0(a1)
  8000f8:	2785                	addiw	a5,a5,1
  8000fa:	c19c                	sw	a5,0(a1)
}
  8000fc:	6105                	addi	sp,sp,32
  8000fe:	8082                	ret

0000000000800100 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800100:	1101                	addi	sp,sp,-32
  800102:	862a                	mv	a2,a0
  800104:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800106:	00000517          	auipc	a0,0x0
  80010a:	fe250513          	addi	a0,a0,-30 # 8000e8 <cputch>
  80010e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800110:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800112:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800114:	0ce000ef          	jal	8001e2 <vprintfmt>
    return cnt;
}
  800118:	60e2                	ld	ra,24(sp)
  80011a:	4532                	lw	a0,12(sp)
  80011c:	6105                	addi	sp,sp,32
  80011e:	8082                	ret

0000000000800120 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800120:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800122:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800126:	f42e                	sd	a1,40(sp)
  800128:	f832                	sd	a2,48(sp)
  80012a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012c:	862a                	mv	a2,a0
  80012e:	004c                	addi	a1,sp,4
  800130:	00000517          	auipc	a0,0x0
  800134:	fb850513          	addi	a0,a0,-72 # 8000e8 <cputch>
  800138:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80013a:	ec06                	sd	ra,24(sp)
  80013c:	e0ba                	sd	a4,64(sp)
  80013e:	e4be                	sd	a5,72(sp)
  800140:	e8c2                	sd	a6,80(sp)
  800142:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800144:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800146:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800148:	09a000ef          	jal	8001e2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014c:	60e2                	ld	ra,24(sp)
  80014e:	4512                	lw	a0,4(sp)
  800150:	6125                	addi	sp,sp,96
  800152:	8082                	ret

0000000000800154 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800154:	1141                	addi	sp,sp,-16
  800156:	e406                	sd	ra,8(sp)
    int ret = main();
  800158:	478000ef          	jal	8005d0 <main>
    exit(ret);
  80015c:	f67ff0ef          	jal	8000c2 <exit>

0000000000800160 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800160:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800162:	e589                	bnez	a1,80016c <strnlen+0xc>
  800164:	a811                	j	800178 <strnlen+0x18>
        cnt ++;
  800166:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800168:	00f58863          	beq	a1,a5,800178 <strnlen+0x18>
  80016c:	00f50733          	add	a4,a0,a5
  800170:	00074703          	lbu	a4,0(a4)
  800174:	fb6d                	bnez	a4,800166 <strnlen+0x6>
  800176:	85be                	mv	a1,a5
    }
    return cnt;
}
  800178:	852e                	mv	a0,a1
  80017a:	8082                	ret

000000000080017c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	f022                	sd	s0,32(sp)
  800184:	ec26                	sd	s1,24(sp)
  800186:	e84a                	sd	s2,16(sp)
  800188:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018e:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800190:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800194:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800198:	84aa                	mv	s1,a0
  80019a:	892e                	mv	s2,a1
    if (num >= base) {
  80019c:	03067d63          	bgeu	a2,a6,8001d6 <printnum+0x5a>
  8001a0:	e44e                	sd	s3,8(sp)
  8001a2:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a4:	4785                	li	a5,1
  8001a6:	00e7d763          	bge	a5,a4,8001b4 <printnum+0x38>
            putch(padc, putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	854e                	mv	a0,s3
        while (-- width > 0)
  8001ae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b0:	9482                	jalr	s1
        while (-- width > 0)
  8001b2:	fc65                	bnez	s0,8001aa <printnum+0x2e>
  8001b4:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	00000797          	auipc	a5,0x0
  8001ba:	51278793          	addi	a5,a5,1298 # 8006c8 <main+0xf8>
  8001be:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	0007c503          	lbu	a0,0(a5)
}
  8001c6:	70a2                	ld	ra,40(sp)
  8001c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ca:	85ca                	mv	a1,s2
  8001cc:	87a6                	mv	a5,s1
}
  8001ce:	6942                	ld	s2,16(sp)
  8001d0:	64e2                	ld	s1,24(sp)
  8001d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d6:	03065633          	divu	a2,a2,a6
  8001da:	8722                	mv	a4,s0
  8001dc:	fa1ff0ef          	jal	80017c <printnum>
  8001e0:	bfd9                	j	8001b6 <printnum+0x3a>

00000000008001e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e2:	7119                	addi	sp,sp,-128
  8001e4:	f4a6                	sd	s1,104(sp)
  8001e6:	f0ca                	sd	s2,96(sp)
  8001e8:	ecce                	sd	s3,88(sp)
  8001ea:	e8d2                	sd	s4,80(sp)
  8001ec:	e4d6                	sd	s5,72(sp)
  8001ee:	e0da                	sd	s6,64(sp)
  8001f0:	f862                	sd	s8,48(sp)
  8001f2:	fc86                	sd	ra,120(sp)
  8001f4:	f8a2                	sd	s0,112(sp)
  8001f6:	fc5e                	sd	s7,56(sp)
  8001f8:	f466                	sd	s9,40(sp)
  8001fa:	f06a                	sd	s10,32(sp)
  8001fc:	ec6e                	sd	s11,24(sp)
  8001fe:	84aa                	mv	s1,a0
  800200:	8c32                	mv	s8,a2
  800202:	8a36                	mv	s4,a3
  800204:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80020a:	05500b13          	li	s6,85
  80020e:	00000a97          	auipc	s5,0x0
  800212:	66ea8a93          	addi	s5,s5,1646 # 80087c <main+0x2ac>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800216:	000c4503          	lbu	a0,0(s8)
  80021a:	001c0413          	addi	s0,s8,1
  80021e:	01350a63          	beq	a0,s3,800232 <vprintfmt+0x50>
            if (ch == '\0') {
  800222:	cd0d                	beqz	a0,80025c <vprintfmt+0x7a>
            putch(ch, putdat);
  800224:	85ca                	mv	a1,s2
  800226:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	00044503          	lbu	a0,0(s0)
  80022c:	0405                	addi	s0,s0,1
  80022e:	ff351ae3          	bne	a0,s3,800222 <vprintfmt+0x40>
        width = precision = -1;
  800232:	5cfd                	li	s9,-1
  800234:	8d66                	mv	s10,s9
        char padc = ' ';
  800236:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80023a:	4b81                	li	s7,0
  80023c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	00044683          	lbu	a3,0(s0)
  800242:	00140c13          	addi	s8,s0,1
  800246:	fdd6859b          	addiw	a1,a3,-35
  80024a:	0ff5f593          	zext.b	a1,a1
  80024e:	02bb6663          	bltu	s6,a1,80027a <vprintfmt+0x98>
  800252:	058a                	slli	a1,a1,0x2
  800254:	95d6                	add	a1,a1,s5
  800256:	4198                	lw	a4,0(a1)
  800258:	9756                	add	a4,a4,s5
  80025a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80025c:	70e6                	ld	ra,120(sp)
  80025e:	7446                	ld	s0,112(sp)
  800260:	74a6                	ld	s1,104(sp)
  800262:	7906                	ld	s2,96(sp)
  800264:	69e6                	ld	s3,88(sp)
  800266:	6a46                	ld	s4,80(sp)
  800268:	6aa6                	ld	s5,72(sp)
  80026a:	6b06                	ld	s6,64(sp)
  80026c:	7be2                	ld	s7,56(sp)
  80026e:	7c42                	ld	s8,48(sp)
  800270:	7ca2                	ld	s9,40(sp)
  800272:	7d02                	ld	s10,32(sp)
  800274:	6de2                	ld	s11,24(sp)
  800276:	6109                	addi	sp,sp,128
  800278:	8082                	ret
            putch('%', putdat);
  80027a:	85ca                	mv	a1,s2
  80027c:	02500513          	li	a0,37
  800280:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800282:	fff44783          	lbu	a5,-1(s0)
  800286:	02500713          	li	a4,37
  80028a:	8c22                	mv	s8,s0
  80028c:	f8e785e3          	beq	a5,a4,800216 <vprintfmt+0x34>
  800290:	ffec4783          	lbu	a5,-2(s8)
  800294:	1c7d                	addi	s8,s8,-1
  800296:	fee79de3          	bne	a5,a4,800290 <vprintfmt+0xae>
  80029a:	bfb5                	j	800216 <vprintfmt+0x34>
                ch = *fmt;
  80029c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  8002a0:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  8002a2:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002a6:	fd06071b          	addiw	a4,a2,-48
  8002aa:	24e56a63          	bltu	a0,a4,8004fe <vprintfmt+0x31c>
                ch = *fmt;
  8002ae:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002b0:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002b2:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002b6:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002ba:	0197073b          	addw	a4,a4,s9
  8002be:	0017171b          	slliw	a4,a4,0x1
  8002c2:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002c4:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002c8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ca:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ce:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002d2:	feb570e3          	bgeu	a0,a1,8002b2 <vprintfmt+0xd0>
            if (width < 0)
  8002d6:	f60d54e3          	bgez	s10,80023e <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002da:	8d66                	mv	s10,s9
  8002dc:	5cfd                	li	s9,-1
  8002de:	b785                	j	80023e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002e0:	8db6                	mv	s11,a3
  8002e2:	8462                	mv	s0,s8
  8002e4:	bfa9                	j	80023e <vprintfmt+0x5c>
  8002e6:	8462                	mv	s0,s8
            altflag = 1;
  8002e8:	4b85                	li	s7,1
            goto reswitch;
  8002ea:	bf91                	j	80023e <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f2:	00f74463          	blt	a4,a5,8002fa <vprintfmt+0x118>
    else if (lflag) {
  8002f6:	1a078763          	beqz	a5,8004a4 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002fa:	000a3603          	ld	a2,0(s4)
  8002fe:	46c1                	li	a3,16
  800300:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800302:	000d879b          	sext.w	a5,s11
  800306:	876a                	mv	a4,s10
  800308:	85ca                	mv	a1,s2
  80030a:	8526                	mv	a0,s1
  80030c:	e71ff0ef          	jal	80017c <printnum>
            break;
  800310:	b719                	j	800216 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800312:	000a2503          	lw	a0,0(s4)
  800316:	85ca                	mv	a1,s2
  800318:	0a21                	addi	s4,s4,8
  80031a:	9482                	jalr	s1
            break;
  80031c:	bded                	j	800216 <vprintfmt+0x34>
    if (lflag >= 2) {
  80031e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800320:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800324:	00f74463          	blt	a4,a5,80032c <vprintfmt+0x14a>
    else if (lflag) {
  800328:	16078963          	beqz	a5,80049a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80032c:	000a3603          	ld	a2,0(s4)
  800330:	46a9                	li	a3,10
  800332:	8a2e                	mv	s4,a1
  800334:	b7f9                	j	800302 <vprintfmt+0x120>
            putch('0', putdat);
  800336:	85ca                	mv	a1,s2
  800338:	03000513          	li	a0,48
  80033c:	9482                	jalr	s1
            putch('x', putdat);
  80033e:	85ca                	mv	a1,s2
  800340:	07800513          	li	a0,120
  800344:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800346:	000a3603          	ld	a2,0(s4)
            goto number;
  80034a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034c:	0a21                	addi	s4,s4,8
            goto number;
  80034e:	bf55                	j	800302 <vprintfmt+0x120>
            putch(ch, putdat);
  800350:	85ca                	mv	a1,s2
  800352:	02500513          	li	a0,37
  800356:	9482                	jalr	s1
            break;
  800358:	bd7d                	j	800216 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80035a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80035e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800360:	0a21                	addi	s4,s4,8
            goto process_precision;
  800362:	bf95                	j	8002d6 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800364:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800366:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80036a:	00f74463          	blt	a4,a5,800372 <vprintfmt+0x190>
    else if (lflag) {
  80036e:	12078163          	beqz	a5,800490 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800372:	000a3603          	ld	a2,0(s4)
  800376:	46a1                	li	a3,8
  800378:	8a2e                	mv	s4,a1
  80037a:	b761                	j	800302 <vprintfmt+0x120>
            if (width < 0)
  80037c:	876a                	mv	a4,s10
  80037e:	000d5363          	bgez	s10,800384 <vprintfmt+0x1a2>
  800382:	4701                	li	a4,0
  800384:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800388:	8462                	mv	s0,s8
            goto reswitch;
  80038a:	bd55                	j	80023e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80038c:	000d841b          	sext.w	s0,s11
  800390:	fd340793          	addi	a5,s0,-45
  800394:	00f037b3          	snez	a5,a5
  800398:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80039c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  8003a0:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a2:	008a0793          	addi	a5,s4,8
  8003a6:	e43e                	sd	a5,8(sp)
  8003a8:	100d8c63          	beqz	s11,8004c0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003ac:	12071363          	bnez	a4,8004d2 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b0:	000dc783          	lbu	a5,0(s11)
  8003b4:	0007851b          	sext.w	a0,a5
  8003b8:	c78d                	beqz	a5,8003e2 <vprintfmt+0x200>
  8003ba:	0d85                	addi	s11,s11,1
  8003bc:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003be:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c2:	000cc563          	bltz	s9,8003cc <vprintfmt+0x1ea>
  8003c6:	3cfd                	addiw	s9,s9,-1
  8003c8:	008c8d63          	beq	s9,s0,8003e2 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003cc:	020b9663          	bnez	s7,8003f8 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003d0:	85ca                	mv	a1,s2
  8003d2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d4:	000dc783          	lbu	a5,0(s11)
  8003d8:	0d85                	addi	s11,s11,1
  8003da:	3d7d                	addiw	s10,s10,-1
  8003dc:	0007851b          	sext.w	a0,a5
  8003e0:	f3ed                	bnez	a5,8003c2 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003e2:	01a05963          	blez	s10,8003f4 <vprintfmt+0x212>
                putch(' ', putdat);
  8003e6:	85ca                	mv	a1,s2
  8003e8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ec:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ee:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003f0:	fe0d1be3          	bnez	s10,8003e6 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003f4:	6a22                	ld	s4,8(sp)
  8003f6:	b505                	j	800216 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f8:	3781                	addiw	a5,a5,-32
  8003fa:	fcfa7be3          	bgeu	s4,a5,8003d0 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003fe:	03f00513          	li	a0,63
  800402:	85ca                	mv	a1,s2
  800404:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800406:	000dc783          	lbu	a5,0(s11)
  80040a:	0d85                	addi	s11,s11,1
  80040c:	3d7d                	addiw	s10,s10,-1
  80040e:	0007851b          	sext.w	a0,a5
  800412:	dbe1                	beqz	a5,8003e2 <vprintfmt+0x200>
  800414:	fa0cd9e3          	bgez	s9,8003c6 <vprintfmt+0x1e4>
  800418:	b7c5                	j	8003f8 <vprintfmt+0x216>
            if (err < 0) {
  80041a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80041e:	4661                	li	a2,24
            err = va_arg(ap, int);
  800420:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800422:	41f7d71b          	sraiw	a4,a5,0x1f
  800426:	8fb9                	xor	a5,a5,a4
  800428:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80042c:	02d64563          	blt	a2,a3,800456 <vprintfmt+0x274>
  800430:	00000797          	auipc	a5,0x0
  800434:	5a878793          	addi	a5,a5,1448 # 8009d8 <error_string>
  800438:	00369713          	slli	a4,a3,0x3
  80043c:	97ba                	add	a5,a5,a4
  80043e:	639c                	ld	a5,0(a5)
  800440:	cb99                	beqz	a5,800456 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800442:	86be                	mv	a3,a5
  800444:	00000617          	auipc	a2,0x0
  800448:	2b460613          	addi	a2,a2,692 # 8006f8 <main+0x128>
  80044c:	85ca                	mv	a1,s2
  80044e:	8526                	mv	a0,s1
  800450:	0d8000ef          	jal	800528 <printfmt>
  800454:	b3c9                	j	800216 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800456:	00000617          	auipc	a2,0x0
  80045a:	29260613          	addi	a2,a2,658 # 8006e8 <main+0x118>
  80045e:	85ca                	mv	a1,s2
  800460:	8526                	mv	a0,s1
  800462:	0c6000ef          	jal	800528 <printfmt>
  800466:	bb45                	j	800216 <vprintfmt+0x34>
    if (lflag >= 2) {
  800468:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80046a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80046e:	00f74363          	blt	a4,a5,800474 <vprintfmt+0x292>
    else if (lflag) {
  800472:	cf81                	beqz	a5,80048a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800474:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800478:	02044b63          	bltz	s0,8004ae <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80047c:	8622                	mv	a2,s0
  80047e:	8a5e                	mv	s4,s7
  800480:	46a9                	li	a3,10
  800482:	b541                	j	800302 <vprintfmt+0x120>
            lflag ++;
  800484:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800486:	8462                	mv	s0,s8
            goto reswitch;
  800488:	bb5d                	j	80023e <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80048a:	000a2403          	lw	s0,0(s4)
  80048e:	b7ed                	j	800478 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800490:	000a6603          	lwu	a2,0(s4)
  800494:	46a1                	li	a3,8
  800496:	8a2e                	mv	s4,a1
  800498:	b5ad                	j	800302 <vprintfmt+0x120>
  80049a:	000a6603          	lwu	a2,0(s4)
  80049e:	46a9                	li	a3,10
  8004a0:	8a2e                	mv	s4,a1
  8004a2:	b585                	j	800302 <vprintfmt+0x120>
  8004a4:	000a6603          	lwu	a2,0(s4)
  8004a8:	46c1                	li	a3,16
  8004aa:	8a2e                	mv	s4,a1
  8004ac:	bd99                	j	800302 <vprintfmt+0x120>
                putch('-', putdat);
  8004ae:	85ca                	mv	a1,s2
  8004b0:	02d00513          	li	a0,45
  8004b4:	9482                	jalr	s1
                num = -(long long)num;
  8004b6:	40800633          	neg	a2,s0
  8004ba:	8a5e                	mv	s4,s7
  8004bc:	46a9                	li	a3,10
  8004be:	b591                	j	800302 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004c0:	e329                	bnez	a4,800502 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c2:	02800793          	li	a5,40
  8004c6:	853e                	mv	a0,a5
  8004c8:	00000d97          	auipc	s11,0x0
  8004cc:	219d8d93          	addi	s11,s11,537 # 8006e1 <main+0x111>
  8004d0:	b5f5                	j	8003bc <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d2:	85e6                	mv	a1,s9
  8004d4:	856e                	mv	a0,s11
  8004d6:	c8bff0ef          	jal	800160 <strnlen>
  8004da:	40ad0d3b          	subw	s10,s10,a0
  8004de:	01a05863          	blez	s10,8004ee <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004e2:	85ca                	mv	a1,s2
  8004e4:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004e8:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ea:	fe0d1ce3          	bnez	s10,8004e2 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ee:	000dc783          	lbu	a5,0(s11)
  8004f2:	0007851b          	sext.w	a0,a5
  8004f6:	ec0792e3          	bnez	a5,8003ba <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004fa:	6a22                	ld	s4,8(sp)
  8004fc:	bb29                	j	800216 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004fe:	8462                	mv	s0,s8
  800500:	bbd9                	j	8002d6 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800502:	85e6                	mv	a1,s9
  800504:	00000517          	auipc	a0,0x0
  800508:	1dc50513          	addi	a0,a0,476 # 8006e0 <main+0x110>
  80050c:	c55ff0ef          	jal	800160 <strnlen>
  800510:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800514:	02800793          	li	a5,40
                p = "(null)";
  800518:	00000d97          	auipc	s11,0x0
  80051c:	1c8d8d93          	addi	s11,s11,456 # 8006e0 <main+0x110>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800520:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800522:	fda040e3          	bgtz	s10,8004e2 <vprintfmt+0x300>
  800526:	bd51                	j	8003ba <vprintfmt+0x1d8>

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
  80053e:	ca5ff0ef          	jal	8001e2 <vprintfmt>
}
  800542:	60e2                	ld	ra,24(sp)
  800544:	6161                	addi	sp,sp,80
  800546:	8082                	ret

0000000000800548 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800548:	1141                	addi	sp,sp,-16
  80054a:	e406                	sd	ra,8(sp)
    yield();
  80054c:	b91ff0ef          	jal	8000dc <yield>
    yield();
  800550:	b8dff0ef          	jal	8000dc <yield>
    yield();
  800554:	b89ff0ef          	jal	8000dc <yield>
    yield();
  800558:	b85ff0ef          	jal	8000dc <yield>
    yield();
  80055c:	b81ff0ef          	jal	8000dc <yield>
    yield();
}
  800560:	60a2                	ld	ra,8(sp)
  800562:	0141                	addi	sp,sp,16
    yield();
  800564:	bea5                	j	8000dc <yield>

0000000000800566 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800566:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  800568:	00000517          	auipc	a0,0x0
  80056c:	25850513          	addi	a0,a0,600 # 8007c0 <main+0x1f0>
loop(void) {
  800570:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800572:	bafff0ef          	jal	800120 <cprintf>
    while (1);
  800576:	a001                	j	800576 <loop+0x10>

0000000000800578 <work>:
}

void
work(void) {
  800578:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  80057a:	00000517          	auipc	a0,0x0
  80057e:	25650513          	addi	a0,a0,598 # 8007d0 <main+0x200>
work(void) {
  800582:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  800584:	b9dff0ef          	jal	800120 <cprintf>
    do_yield();
  800588:	fc1ff0ef          	jal	800548 <do_yield>
    if (kill(parent) == 0) {
  80058c:	00001517          	auipc	a0,0x1
  800590:	a7c52503          	lw	a0,-1412(a0) # 801008 <parent>
  800594:	b4bff0ef          	jal	8000de <kill>
  800598:	e105                	bnez	a0,8005b8 <work+0x40>
        cprintf("kill parent ok.\n");
  80059a:	00000517          	auipc	a0,0x0
  80059e:	24650513          	addi	a0,a0,582 # 8007e0 <main+0x210>
  8005a2:	b7fff0ef          	jal	800120 <cprintf>
        do_yield();
  8005a6:	fa3ff0ef          	jal	800548 <do_yield>
        if (kill(pid1) == 0) {
  8005aa:	00001517          	auipc	a0,0x1
  8005ae:	a5a52503          	lw	a0,-1446(a0) # 801004 <pid1>
  8005b2:	b2dff0ef          	jal	8000de <kill>
  8005b6:	c501                	beqz	a0,8005be <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005b8:	557d                	li	a0,-1
  8005ba:	b09ff0ef          	jal	8000c2 <exit>
            cprintf("kill child1 ok.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	23a50513          	addi	a0,a0,570 # 8007f8 <main+0x228>
  8005c6:	b5bff0ef          	jal	800120 <cprintf>
            exit(0);
  8005ca:	4501                	li	a0,0
  8005cc:	af7ff0ef          	jal	8000c2 <exit>

00000000008005d0 <main>:
}

int
main(void) {
  8005d0:	1141                	addi	sp,sp,-16
  8005d2:	e406                	sd	ra,8(sp)
    parent = getpid();
  8005d4:	b0dff0ef          	jal	8000e0 <getpid>
  8005d8:	00001797          	auipc	a5,0x1
  8005dc:	a2a7a823          	sw	a0,-1488(a5) # 801008 <parent>
    if ((pid1 = fork()) == 0) {
  8005e0:	af9ff0ef          	jal	8000d8 <fork>
  8005e4:	00001797          	auipc	a5,0x1
  8005e8:	a2a7a023          	sw	a0,-1504(a5) # 801004 <pid1>
  8005ec:	c92d                	beqz	a0,80065e <main+0x8e>
        loop();
    }

    assert(pid1 > 0);
  8005ee:	04a05863          	blez	a0,80063e <main+0x6e>

    if ((pid2 = fork()) == 0) {
  8005f2:	ae7ff0ef          	jal	8000d8 <fork>
  8005f6:	00001797          	auipc	a5,0x1
  8005fa:	a0a7a523          	sw	a0,-1526(a5) # 801000 <pid2>
  8005fe:	c541                	beqz	a0,800686 <main+0xb6>
        work();
    }
    if (pid2 > 0) {
  800600:	06a05163          	blez	a0,800662 <main+0x92>
        cprintf("wait child 1.\n");
  800604:	00000517          	auipc	a0,0x0
  800608:	24450513          	addi	a0,a0,580 # 800848 <main+0x278>
  80060c:	b15ff0ef          	jal	800120 <cprintf>
        waitpid(pid1, NULL);
  800610:	00001517          	auipc	a0,0x1
  800614:	9f452503          	lw	a0,-1548(a0) # 801004 <pid1>
  800618:	4581                	li	a1,0
  80061a:	ac1ff0ef          	jal	8000da <waitpid>
        panic("waitpid %d returns\n", pid1);
  80061e:	00001697          	auipc	a3,0x1
  800622:	9e66a683          	lw	a3,-1562(a3) # 801004 <pid1>
  800626:	00000617          	auipc	a2,0x0
  80062a:	23260613          	addi	a2,a2,562 # 800858 <main+0x288>
  80062e:	03400593          	li	a1,52
  800632:	00000517          	auipc	a0,0x0
  800636:	20650513          	addi	a0,a0,518 # 800838 <main+0x268>
  80063a:	9e7ff0ef          	jal	800020 <__panic>
    assert(pid1 > 0);
  80063e:	00000697          	auipc	a3,0x0
  800642:	1d268693          	addi	a3,a3,466 # 800810 <main+0x240>
  800646:	00000617          	auipc	a2,0x0
  80064a:	1da60613          	addi	a2,a2,474 # 800820 <main+0x250>
  80064e:	02c00593          	li	a1,44
  800652:	00000517          	auipc	a0,0x0
  800656:	1e650513          	addi	a0,a0,486 # 800838 <main+0x268>
  80065a:	9c7ff0ef          	jal	800020 <__panic>
        loop();
  80065e:	f09ff0ef          	jal	800566 <loop>
    }
    else {
        kill(pid1);
  800662:	00001517          	auipc	a0,0x1
  800666:	9a252503          	lw	a0,-1630(a0) # 801004 <pid1>
  80066a:	a75ff0ef          	jal	8000de <kill>
    }
    panic("FAIL: T.T\n");
  80066e:	00000617          	auipc	a2,0x0
  800672:	20260613          	addi	a2,a2,514 # 800870 <main+0x2a0>
  800676:	03900593          	li	a1,57
  80067a:	00000517          	auipc	a0,0x0
  80067e:	1be50513          	addi	a0,a0,446 # 800838 <main+0x268>
  800682:	99fff0ef          	jal	800020 <__panic>
        work();
  800686:	ef3ff0ef          	jal	800578 <work>
