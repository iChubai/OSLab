
obj/__user_matrix.out:     file format elf64-littleriscv


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
  800032:	77a50513          	addi	a0,a0,1914 # 8007a8 <main+0xca>
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
  800044:	0e0000ef          	jal	800124 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b8000ef          	jal	800104 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	77850513          	addi	a0,a0,1912 # 8007c8 <main+0xea>
  800058:	0cc000ef          	jal	800124 <cprintf>
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
  8000ce:	70650513          	addi	a0,a0,1798 # 8007d0 <main+0xf2>
  8000d2:	052000ef          	jal	800124 <cprintf>
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d8:	b7e9                	j	8000a2 <sys_fork>

00000000008000da <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000da:	4581                	li	a1,0
  8000dc:	4501                	li	a0,0
  8000de:	b7e1                	j	8000a6 <sys_wait>

00000000008000e0 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000e0:	b7f9                	j	8000ae <sys_yield>

00000000008000e2 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000e2:	bfc1                	j	8000b2 <sys_kill>

00000000008000e4 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000e4:	bfd1                	j	8000b8 <sys_getpid>

00000000008000e6 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000e6:	072000ef          	jal	800158 <umain>
1:  j 1b
  8000ea:	a001                	j	8000ea <_start+0x4>

00000000008000ec <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000ec:	1101                	addi	sp,sp,-32
  8000ee:	ec06                	sd	ra,24(sp)
  8000f0:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000f2:	fcbff0ef          	jal	8000bc <sys_putc>
    (*cnt) ++;
  8000f6:	65a2                	ld	a1,8(sp)
}
  8000f8:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000fa:	419c                	lw	a5,0(a1)
  8000fc:	2785                	addiw	a5,a5,1
  8000fe:	c19c                	sw	a5,0(a1)
}
  800100:	6105                	addi	sp,sp,32
  800102:	8082                	ret

0000000000800104 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800104:	1101                	addi	sp,sp,-32
  800106:	862a                	mv	a2,a0
  800108:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010a:	00000517          	auipc	a0,0x0
  80010e:	fe250513          	addi	a0,a0,-30 # 8000ec <cputch>
  800112:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800114:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800116:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800118:	0e0000ef          	jal	8001f8 <vprintfmt>
    return cnt;
}
  80011c:	60e2                	ld	ra,24(sp)
  80011e:	4532                	lw	a0,12(sp)
  800120:	6105                	addi	sp,sp,32
  800122:	8082                	ret

0000000000800124 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800124:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800126:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  80012a:	f42e                	sd	a1,40(sp)
  80012c:	f832                	sd	a2,48(sp)
  80012e:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800130:	862a                	mv	a2,a0
  800132:	004c                	addi	a1,sp,4
  800134:	00000517          	auipc	a0,0x0
  800138:	fb850513          	addi	a0,a0,-72 # 8000ec <cputch>
  80013c:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80013e:	ec06                	sd	ra,24(sp)
  800140:	e0ba                	sd	a4,64(sp)
  800142:	e4be                	sd	a5,72(sp)
  800144:	e8c2                	sd	a6,80(sp)
  800146:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800148:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  80014a:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80014c:	0ac000ef          	jal	8001f8 <vprintfmt>
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
  80015c:	582000ef          	jal	8006de <main>
    exit(ret);
  800160:	f63ff0ef          	jal	8000c2 <exit>

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

0000000000800180 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
  800180:	ca01                	beqz	a2,800190 <memset+0x10>
  800182:	962a                	add	a2,a2,a0
    char *p = s;
  800184:	87aa                	mv	a5,a0
        *p ++ = c;
  800186:	0785                	addi	a5,a5,1
  800188:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
  80018c:	fef61de3          	bne	a2,a5,800186 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800190:	8082                	ret

0000000000800192 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800192:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800194:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800198:	f022                	sd	s0,32(sp)
  80019a:	ec26                	sd	s1,24(sp)
  80019c:	e84a                	sd	s2,16(sp)
  80019e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001a0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001a4:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  8001a6:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001aa:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  8001ae:	84aa                	mv	s1,a0
  8001b0:	892e                	mv	s2,a1
    if (num >= base) {
  8001b2:	03067d63          	bgeu	a2,a6,8001ec <printnum+0x5a>
  8001b6:	e44e                	sd	s3,8(sp)
  8001b8:	89be                	mv	s3,a5
        while (-- width > 0)
  8001ba:	4785                	li	a5,1
  8001bc:	00e7d763          	bge	a5,a4,8001ca <printnum+0x38>
            putch(padc, putdat);
  8001c0:	85ca                	mv	a1,s2
  8001c2:	854e                	mv	a0,s3
        while (-- width > 0)
  8001c4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001c6:	9482                	jalr	s1
        while (-- width > 0)
  8001c8:	fc65                	bnez	s0,8001c0 <printnum+0x2e>
  8001ca:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	00000797          	auipc	a5,0x0
  8001d0:	61c78793          	addi	a5,a5,1564 # 8007e8 <main+0x10a>
  8001d4:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d8:	0007c503          	lbu	a0,0(a5)
}
  8001dc:	70a2                	ld	ra,40(sp)
  8001de:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001e0:	85ca                	mv	a1,s2
  8001e2:	87a6                	mv	a5,s1
}
  8001e4:	6942                	ld	s2,16(sp)
  8001e6:	64e2                	ld	s1,24(sp)
  8001e8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ea:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ec:	03065633          	divu	a2,a2,a6
  8001f0:	8722                	mv	a4,s0
  8001f2:	fa1ff0ef          	jal	800192 <printnum>
  8001f6:	bfd9                	j	8001cc <printnum+0x3a>

00000000008001f8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001f8:	7119                	addi	sp,sp,-128
  8001fa:	f4a6                	sd	s1,104(sp)
  8001fc:	f0ca                	sd	s2,96(sp)
  8001fe:	ecce                	sd	s3,88(sp)
  800200:	e8d2                	sd	s4,80(sp)
  800202:	e4d6                	sd	s5,72(sp)
  800204:	e0da                	sd	s6,64(sp)
  800206:	f862                	sd	s8,48(sp)
  800208:	fc86                	sd	ra,120(sp)
  80020a:	f8a2                	sd	s0,112(sp)
  80020c:	fc5e                	sd	s7,56(sp)
  80020e:	f466                	sd	s9,40(sp)
  800210:	f06a                	sd	s10,32(sp)
  800212:	ec6e                	sd	s11,24(sp)
  800214:	84aa                	mv	s1,a0
  800216:	8c32                	mv	s8,a2
  800218:	8a36                	mv	s4,a3
  80021a:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	05500b13          	li	s6,85
  800224:	00000a97          	auipc	s5,0x0
  800228:	73ca8a93          	addi	s5,s5,1852 # 800960 <main+0x282>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022c:	000c4503          	lbu	a0,0(s8)
  800230:	001c0413          	addi	s0,s8,1
  800234:	01350a63          	beq	a0,s3,800248 <vprintfmt+0x50>
            if (ch == '\0') {
  800238:	cd0d                	beqz	a0,800272 <vprintfmt+0x7a>
            putch(ch, putdat);
  80023a:	85ca                	mv	a1,s2
  80023c:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023e:	00044503          	lbu	a0,0(s0)
  800242:	0405                	addi	s0,s0,1
  800244:	ff351ae3          	bne	a0,s3,800238 <vprintfmt+0x40>
        width = precision = -1;
  800248:	5cfd                	li	s9,-1
  80024a:	8d66                	mv	s10,s9
        char padc = ' ';
  80024c:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800250:	4b81                	li	s7,0
  800252:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	00044683          	lbu	a3,0(s0)
  800258:	00140c13          	addi	s8,s0,1
  80025c:	fdd6859b          	addiw	a1,a3,-35
  800260:	0ff5f593          	zext.b	a1,a1
  800264:	02bb6663          	bltu	s6,a1,800290 <vprintfmt+0x98>
  800268:	058a                	slli	a1,a1,0x2
  80026a:	95d6                	add	a1,a1,s5
  80026c:	4198                	lw	a4,0(a1)
  80026e:	9756                	add	a4,a4,s5
  800270:	8702                	jr	a4
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
            putch('%', putdat);
  800290:	85ca                	mv	a1,s2
  800292:	02500513          	li	a0,37
  800296:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800298:	fff44783          	lbu	a5,-1(s0)
  80029c:	02500713          	li	a4,37
  8002a0:	8c22                	mv	s8,s0
  8002a2:	f8e785e3          	beq	a5,a4,80022c <vprintfmt+0x34>
  8002a6:	ffec4783          	lbu	a5,-2(s8)
  8002aa:	1c7d                	addi	s8,s8,-1
  8002ac:	fee79de3          	bne	a5,a4,8002a6 <vprintfmt+0xae>
  8002b0:	bfb5                	j	80022c <vprintfmt+0x34>
                ch = *fmt;
  8002b2:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  8002b6:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  8002b8:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002bc:	fd06071b          	addiw	a4,a2,-48
  8002c0:	24e56a63          	bltu	a0,a4,800514 <vprintfmt+0x31c>
                ch = *fmt;
  8002c4:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002c6:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002c8:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002cc:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002d0:	0197073b          	addw	a4,a4,s9
  8002d4:	0017171b          	slliw	a4,a4,0x1
  8002d8:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002da:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002de:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002e4:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002e8:	feb570e3          	bgeu	a0,a1,8002c8 <vprintfmt+0xd0>
            if (width < 0)
  8002ec:	f60d54e3          	bgez	s10,800254 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002f0:	8d66                	mv	s10,s9
  8002f2:	5cfd                	li	s9,-1
  8002f4:	b785                	j	800254 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002f6:	8db6                	mv	s11,a3
  8002f8:	8462                	mv	s0,s8
  8002fa:	bfa9                	j	800254 <vprintfmt+0x5c>
  8002fc:	8462                	mv	s0,s8
            altflag = 1;
  8002fe:	4b85                	li	s7,1
            goto reswitch;
  800300:	bf91                	j	800254 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800302:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800304:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800308:	00f74463          	blt	a4,a5,800310 <vprintfmt+0x118>
    else if (lflag) {
  80030c:	1a078763          	beqz	a5,8004ba <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800310:	000a3603          	ld	a2,0(s4)
  800314:	46c1                	li	a3,16
  800316:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800318:	000d879b          	sext.w	a5,s11
  80031c:	876a                	mv	a4,s10
  80031e:	85ca                	mv	a1,s2
  800320:	8526                	mv	a0,s1
  800322:	e71ff0ef          	jal	800192 <printnum>
            break;
  800326:	b719                	j	80022c <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800328:	000a2503          	lw	a0,0(s4)
  80032c:	85ca                	mv	a1,s2
  80032e:	0a21                	addi	s4,s4,8
  800330:	9482                	jalr	s1
            break;
  800332:	bded                	j	80022c <vprintfmt+0x34>
    if (lflag >= 2) {
  800334:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800336:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80033a:	00f74463          	blt	a4,a5,800342 <vprintfmt+0x14a>
    else if (lflag) {
  80033e:	16078963          	beqz	a5,8004b0 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800342:	000a3603          	ld	a2,0(s4)
  800346:	46a9                	li	a3,10
  800348:	8a2e                	mv	s4,a1
  80034a:	b7f9                	j	800318 <vprintfmt+0x120>
            putch('0', putdat);
  80034c:	85ca                	mv	a1,s2
  80034e:	03000513          	li	a0,48
  800352:	9482                	jalr	s1
            putch('x', putdat);
  800354:	85ca                	mv	a1,s2
  800356:	07800513          	li	a0,120
  80035a:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80035c:	000a3603          	ld	a2,0(s4)
            goto number;
  800360:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800362:	0a21                	addi	s4,s4,8
            goto number;
  800364:	bf55                	j	800318 <vprintfmt+0x120>
            putch(ch, putdat);
  800366:	85ca                	mv	a1,s2
  800368:	02500513          	li	a0,37
  80036c:	9482                	jalr	s1
            break;
  80036e:	bd7d                	j	80022c <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800370:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800374:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800376:	0a21                	addi	s4,s4,8
            goto process_precision;
  800378:	bf95                	j	8002ec <vprintfmt+0xf4>
    if (lflag >= 2) {
  80037a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80037c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800380:	00f74463          	blt	a4,a5,800388 <vprintfmt+0x190>
    else if (lflag) {
  800384:	12078163          	beqz	a5,8004a6 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800388:	000a3603          	ld	a2,0(s4)
  80038c:	46a1                	li	a3,8
  80038e:	8a2e                	mv	s4,a1
  800390:	b761                	j	800318 <vprintfmt+0x120>
            if (width < 0)
  800392:	876a                	mv	a4,s10
  800394:	000d5363          	bgez	s10,80039a <vprintfmt+0x1a2>
  800398:	4701                	li	a4,0
  80039a:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80039e:	8462                	mv	s0,s8
            goto reswitch;
  8003a0:	bd55                	j	800254 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  8003a2:	000d841b          	sext.w	s0,s11
  8003a6:	fd340793          	addi	a5,s0,-45
  8003aa:	00f037b3          	snez	a5,a5
  8003ae:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b2:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  8003b6:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b8:	008a0793          	addi	a5,s4,8
  8003bc:	e43e                	sd	a5,8(sp)
  8003be:	100d8c63          	beqz	s11,8004d6 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003c2:	12071363          	bnez	a4,8004e8 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c6:	000dc783          	lbu	a5,0(s11)
  8003ca:	0007851b          	sext.w	a0,a5
  8003ce:	c78d                	beqz	a5,8003f8 <vprintfmt+0x200>
  8003d0:	0d85                	addi	s11,s11,1
  8003d2:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d4:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d8:	000cc563          	bltz	s9,8003e2 <vprintfmt+0x1ea>
  8003dc:	3cfd                	addiw	s9,s9,-1
  8003de:	008c8d63          	beq	s9,s0,8003f8 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e2:	020b9663          	bnez	s7,80040e <vprintfmt+0x216>
                    putch(ch, putdat);
  8003e6:	85ca                	mv	a1,s2
  8003e8:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ea:	000dc783          	lbu	a5,0(s11)
  8003ee:	0d85                	addi	s11,s11,1
  8003f0:	3d7d                	addiw	s10,s10,-1
  8003f2:	0007851b          	sext.w	a0,a5
  8003f6:	f3ed                	bnez	a5,8003d8 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003f8:	01a05963          	blez	s10,80040a <vprintfmt+0x212>
                putch(' ', putdat);
  8003fc:	85ca                	mv	a1,s2
  8003fe:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800402:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800404:	9482                	jalr	s1
            for (; width > 0; width --) {
  800406:	fe0d1be3          	bnez	s10,8003fc <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  80040a:	6a22                	ld	s4,8(sp)
  80040c:	b505                	j	80022c <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  80040e:	3781                	addiw	a5,a5,-32
  800410:	fcfa7be3          	bgeu	s4,a5,8003e6 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800414:	03f00513          	li	a0,63
  800418:	85ca                	mv	a1,s2
  80041a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80041c:	000dc783          	lbu	a5,0(s11)
  800420:	0d85                	addi	s11,s11,1
  800422:	3d7d                	addiw	s10,s10,-1
  800424:	0007851b          	sext.w	a0,a5
  800428:	dbe1                	beqz	a5,8003f8 <vprintfmt+0x200>
  80042a:	fa0cd9e3          	bgez	s9,8003dc <vprintfmt+0x1e4>
  80042e:	b7c5                	j	80040e <vprintfmt+0x216>
            if (err < 0) {
  800430:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800434:	4661                	li	a2,24
            err = va_arg(ap, int);
  800436:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800438:	41f7d71b          	sraiw	a4,a5,0x1f
  80043c:	8fb9                	xor	a5,a5,a4
  80043e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800442:	02d64563          	blt	a2,a3,80046c <vprintfmt+0x274>
  800446:	00000797          	auipc	a5,0x0
  80044a:	67278793          	addi	a5,a5,1650 # 800ab8 <error_string>
  80044e:	00369713          	slli	a4,a3,0x3
  800452:	97ba                	add	a5,a5,a4
  800454:	639c                	ld	a5,0(a5)
  800456:	cb99                	beqz	a5,80046c <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800458:	86be                	mv	a3,a5
  80045a:	00000617          	auipc	a2,0x0
  80045e:	3be60613          	addi	a2,a2,958 # 800818 <main+0x13a>
  800462:	85ca                	mv	a1,s2
  800464:	8526                	mv	a0,s1
  800466:	0d8000ef          	jal	80053e <printfmt>
  80046a:	b3c9                	j	80022c <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80046c:	00000617          	auipc	a2,0x0
  800470:	39c60613          	addi	a2,a2,924 # 800808 <main+0x12a>
  800474:	85ca                	mv	a1,s2
  800476:	8526                	mv	a0,s1
  800478:	0c6000ef          	jal	80053e <printfmt>
  80047c:	bb45                	j	80022c <vprintfmt+0x34>
    if (lflag >= 2) {
  80047e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800480:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800484:	00f74363          	blt	a4,a5,80048a <vprintfmt+0x292>
    else if (lflag) {
  800488:	cf81                	beqz	a5,8004a0 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80048a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80048e:	02044b63          	bltz	s0,8004c4 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800492:	8622                	mv	a2,s0
  800494:	8a5e                	mv	s4,s7
  800496:	46a9                	li	a3,10
  800498:	b541                	j	800318 <vprintfmt+0x120>
            lflag ++;
  80049a:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80049c:	8462                	mv	s0,s8
            goto reswitch;
  80049e:	bb5d                	j	800254 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8004a0:	000a2403          	lw	s0,0(s4)
  8004a4:	b7ed                	j	80048e <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  8004a6:	000a6603          	lwu	a2,0(s4)
  8004aa:	46a1                	li	a3,8
  8004ac:	8a2e                	mv	s4,a1
  8004ae:	b5ad                	j	800318 <vprintfmt+0x120>
  8004b0:	000a6603          	lwu	a2,0(s4)
  8004b4:	46a9                	li	a3,10
  8004b6:	8a2e                	mv	s4,a1
  8004b8:	b585                	j	800318 <vprintfmt+0x120>
  8004ba:	000a6603          	lwu	a2,0(s4)
  8004be:	46c1                	li	a3,16
  8004c0:	8a2e                	mv	s4,a1
  8004c2:	bd99                	j	800318 <vprintfmt+0x120>
                putch('-', putdat);
  8004c4:	85ca                	mv	a1,s2
  8004c6:	02d00513          	li	a0,45
  8004ca:	9482                	jalr	s1
                num = -(long long)num;
  8004cc:	40800633          	neg	a2,s0
  8004d0:	8a5e                	mv	s4,s7
  8004d2:	46a9                	li	a3,10
  8004d4:	b591                	j	800318 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004d6:	e329                	bnez	a4,800518 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d8:	02800793          	li	a5,40
  8004dc:	853e                	mv	a0,a5
  8004de:	00000d97          	auipc	s11,0x0
  8004e2:	323d8d93          	addi	s11,s11,803 # 800801 <main+0x123>
  8004e6:	b5f5                	j	8003d2 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e8:	85e6                	mv	a1,s9
  8004ea:	856e                	mv	a0,s11
  8004ec:	c79ff0ef          	jal	800164 <strnlen>
  8004f0:	40ad0d3b          	subw	s10,s10,a0
  8004f4:	01a05863          	blez	s10,800504 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004f8:	85ca                	mv	a1,s2
  8004fa:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fc:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004fe:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800500:	fe0d1ce3          	bnez	s10,8004f8 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800504:	000dc783          	lbu	a5,0(s11)
  800508:	0007851b          	sext.w	a0,a5
  80050c:	ec0792e3          	bnez	a5,8003d0 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800510:	6a22                	ld	s4,8(sp)
  800512:	bb29                	j	80022c <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800514:	8462                	mv	s0,s8
  800516:	bbd9                	j	8002ec <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800518:	85e6                	mv	a1,s9
  80051a:	00000517          	auipc	a0,0x0
  80051e:	2e650513          	addi	a0,a0,742 # 800800 <main+0x122>
  800522:	c43ff0ef          	jal	800164 <strnlen>
  800526:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052a:	02800793          	li	a5,40
                p = "(null)";
  80052e:	00000d97          	auipc	s11,0x0
  800532:	2d2d8d93          	addi	s11,s11,722 # 800800 <main+0x122>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800536:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800538:	fda040e3          	bgtz	s10,8004f8 <vprintfmt+0x300>
  80053c:	bd51                	j	8003d0 <vprintfmt+0x1d8>

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
  800554:	ca5ff0ef          	jal	8001f8 <vprintfmt>
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6161                	addi	sp,sp,80
  80055c:	8082                	ret

000000000080055e <rand>:
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  80055e:	002ef7b7          	lui	a5,0x2ef
  800562:	00001717          	auipc	a4,0x1
  800566:	a9e73703          	ld	a4,-1378(a4) # 801000 <next>
  80056a:	76778793          	addi	a5,a5,1895 # 2ef767 <__panic-0x5108b9>
  80056e:	07b6                	slli	a5,a5,0xd
  800570:	66d78793          	addi	a5,a5,1645
  800574:	02f70733          	mul	a4,a4,a5
    unsigned long long result = (next >> 12);
    return (int)do_div(result, RAND_MAX + 1);
  800578:	4785                	li	a5,1
  80057a:	1786                	slli	a5,a5,0x21
  80057c:	0795                	addi	a5,a5,5
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  80057e:	072d                	addi	a4,a4,11
  800580:	0742                	slli	a4,a4,0x10
  800582:	8341                	srli	a4,a4,0x10
    unsigned long long result = (next >> 12);
  800584:	00c75513          	srli	a0,a4,0xc
    return (int)do_div(result, RAND_MAX + 1);
  800588:	02f537b3          	mulhu	a5,a0,a5
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  80058c:	00001697          	auipc	a3,0x1
  800590:	a6e6ba23          	sd	a4,-1420(a3) # 801000 <next>
    return (int)do_div(result, RAND_MAX + 1);
  800594:	40f50733          	sub	a4,a0,a5
  800598:	8305                	srli	a4,a4,0x1
  80059a:	97ba                	add	a5,a5,a4
  80059c:	83f9                	srli	a5,a5,0x1e
  80059e:	01f79713          	slli	a4,a5,0x1f
  8005a2:	40f707b3          	sub	a5,a4,a5
  8005a6:	8d1d                	sub	a0,a0,a5
}
  8005a8:	2505                	addiw	a0,a0,1
  8005aa:	8082                	ret

00000000008005ac <srand>:
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
    next = seed;
  8005ac:	1502                	slli	a0,a0,0x20
  8005ae:	9101                	srli	a0,a0,0x20
  8005b0:	00001797          	auipc	a5,0x1
  8005b4:	a4a7b823          	sd	a0,-1456(a5) # 801000 <next>
}
  8005b8:	8082                	ret

00000000008005ba <work>:
static int mata[MATSIZE][MATSIZE];
static int matb[MATSIZE][MATSIZE];
static int matc[MATSIZE][MATSIZE];

void
work(unsigned int times) {
  8005ba:	1101                	addi	sp,sp,-32
  8005bc:	e822                	sd	s0,16(sp)
  8005be:	e426                	sd	s1,8(sp)
  8005c0:	ec06                	sd	ra,24(sp)
  8005c2:	84aa                	mv	s1,a0
  8005c4:	00001617          	auipc	a2,0x1
  8005c8:	bfc60613          	addi	a2,a2,-1028 # 8011c0 <matb+0x28>
  8005cc:	00001417          	auipc	s0,0x1
  8005d0:	d8440413          	addi	s0,s0,-636 # 801350 <mata+0x28>
  8005d4:	00001597          	auipc	a1,0x1
  8005d8:	d5458593          	addi	a1,a1,-684 # 801328 <mata>
    int i, j, k, size = MATSIZE;
    for (i = 0; i < size; i ++) {
        for (j = 0; j < size; j ++) {
            mata[i][j] = matb[i][j] = 1;
  8005dc:	4685                	li	a3,1
        for (j = 0; j < size; j ++) {
  8005de:	fd860793          	addi	a5,a2,-40
work(unsigned int times) {
  8005e2:	872e                	mv	a4,a1
            mata[i][j] = matb[i][j] = 1;
  8005e4:	c394                	sw	a3,0(a5)
  8005e6:	c314                	sw	a3,0(a4)
        for (j = 0; j < size; j ++) {
  8005e8:	0791                	addi	a5,a5,4
  8005ea:	0711                	addi	a4,a4,4
  8005ec:	fec79ce3          	bne	a5,a2,8005e4 <work+0x2a>
    for (i = 0; i < size; i ++) {
  8005f0:	02878613          	addi	a2,a5,40
  8005f4:	02858593          	addi	a1,a1,40
  8005f8:	fe8613e3          	bne	a2,s0,8005de <work+0x24>
        }
    }

    yield();
  8005fc:	ae5ff0ef          	jal	8000e0 <yield>

    cprintf("pid %d is running (%d times)!.\n", getpid(), times);
  800600:	ae5ff0ef          	jal	8000e4 <getpid>
  800604:	85aa                	mv	a1,a0
  800606:	8626                	mv	a2,s1
  800608:	00000517          	auipc	a0,0x0
  80060c:	2d850513          	addi	a0,a0,728 # 8008e0 <main+0x202>
  800610:	b15ff0ef          	jal	800124 <cprintf>

    while (times -- > 0) {
  800614:	c8cd                	beqz	s1,8006c6 <work+0x10c>
  800616:	34fd                	addiw	s1,s1,-1
  800618:	00001f17          	auipc	t5,0x1
  80061c:	d10f0f13          	addi	t5,t5,-752 # 801328 <mata>
  800620:	00001e97          	auipc	t4,0x1
  800624:	e98e8e93          	addi	t4,t4,-360 # 8014b8 <mata+0x190>
  800628:	5ffd                	li	t6,-1
        for (i = 0; i < size; i ++) {
  80062a:	00001317          	auipc	t1,0x1
  80062e:	9de30313          	addi	t1,t1,-1570 # 801008 <matc>
work(unsigned int times) {
  800632:	8e1a                	mv	t3,t1
  800634:	00001897          	auipc	a7,0x1
  800638:	cf488893          	addi	a7,a7,-780 # 801328 <mata>
  80063c:	00001517          	auipc	a0,0x1
  800640:	cec50513          	addi	a0,a0,-788 # 801328 <mata>
  800644:	8872                	mv	a6,t3
            for (j = 0; j < size; j ++) {
                matc[i][j] = 0;
                for (k = 0; k < size; k ++) {
  800646:	e7050793          	addi	a5,a0,-400
work(unsigned int times) {
  80064a:	86c6                	mv	a3,a7
  80064c:	4601                	li	a2,0
                    matc[i][j] += mata[i][k] * matb[k][j];
  80064e:	428c                	lw	a1,0(a3)
  800650:	4398                	lw	a4,0(a5)
                for (k = 0; k < size; k ++) {
  800652:	02878793          	addi	a5,a5,40
  800656:	0691                	addi	a3,a3,4
                    matc[i][j] += mata[i][k] * matb[k][j];
  800658:	02b7073b          	mulw	a4,a4,a1
  80065c:	9e39                	addw	a2,a2,a4
                for (k = 0; k < size; k ++) {
  80065e:	fea798e3          	bne	a5,a0,80064e <work+0x94>
  800662:	00c82023          	sw	a2,0(a6)
            for (j = 0; j < size; j ++) {
  800666:	00478513          	addi	a0,a5,4
  80066a:	0811                	addi	a6,a6,4
  80066c:	fc851de3          	bne	a0,s0,800646 <work+0x8c>
        for (i = 0; i < size; i ++) {
  800670:	02888893          	addi	a7,a7,40
  800674:	028e0e13          	addi	t3,t3,40
  800678:	fd1e92e3          	bne	t4,a7,80063c <work+0x82>
  80067c:	00001597          	auipc	a1,0x1
  800680:	9b458593          	addi	a1,a1,-1612 # 801030 <matc+0x28>
  800684:	00001817          	auipc	a6,0x1
  800688:	ca480813          	addi	a6,a6,-860 # 801328 <mata>
  80068c:	00001517          	auipc	a0,0x1
  800690:	b0c50513          	addi	a0,a0,-1268 # 801198 <matb>
work(unsigned int times) {
  800694:	86aa                	mv	a3,a0
  800696:	8742                	mv	a4,a6
  800698:	879a                	mv	a5,t1
                }
            }
        }
        for (i = 0; i < size; i ++) {
            for (j = 0; j < size; j ++) {
                mata[i][j] = matb[i][j] = matc[i][j];
  80069a:	6390                	ld	a2,0(a5)
  80069c:	07a1                	addi	a5,a5,8
  80069e:	06a1                	addi	a3,a3,8
  8006a0:	fec6bc23          	sd	a2,-8(a3)
  8006a4:	e310                	sd	a2,0(a4)
            for (j = 0; j < size; j ++) {
  8006a6:	0721                	addi	a4,a4,8
  8006a8:	feb799e3          	bne	a5,a1,80069a <work+0xe0>
        for (i = 0; i < size; i ++) {
  8006ac:	02850513          	addi	a0,a0,40
  8006b0:	02830313          	addi	t1,t1,40
  8006b4:	02880813          	addi	a6,a6,40
  8006b8:	02878593          	addi	a1,a5,40
  8006bc:	fcaf1ce3          	bne	t5,a0,800694 <work+0xda>
    while (times -- > 0) {
  8006c0:	34fd                	addiw	s1,s1,-1
  8006c2:	f7f494e3          	bne	s1,t6,80062a <work+0x70>
            }
        }
    }
    cprintf("pid %d done!.\n", getpid());
  8006c6:	a1fff0ef          	jal	8000e4 <getpid>
  8006ca:	85aa                	mv	a1,a0
  8006cc:	00000517          	auipc	a0,0x0
  8006d0:	23450513          	addi	a0,a0,564 # 800900 <main+0x222>
  8006d4:	a51ff0ef          	jal	800124 <cprintf>
    exit(0);
  8006d8:	4501                	li	a0,0
  8006da:	9e9ff0ef          	jal	8000c2 <exit>

00000000008006de <main>:
}

const int total = 21;

int
main(void) {
  8006de:	7175                	addi	sp,sp,-144
  8006e0:	f4ce                	sd	s3,104(sp)
    int pids[total];
    memset(pids, 0, sizeof(pids));
  8006e2:	0028                	addi	a0,sp,8
  8006e4:	05400613          	li	a2,84
  8006e8:	4581                	li	a1,0
  8006ea:	00810993          	addi	s3,sp,8
main(void) {
  8006ee:	e122                	sd	s0,128(sp)
  8006f0:	fca6                	sd	s1,120(sp)
  8006f2:	f8ca                	sd	s2,112(sp)
  8006f4:	e506                	sd	ra,136(sp)
    memset(pids, 0, sizeof(pids));
  8006f6:	84ce                	mv	s1,s3
  8006f8:	a89ff0ef          	jal	800180 <memset>

    int i;
    for (i = 0; i < total; i ++) {
  8006fc:	4401                	li	s0,0
  8006fe:	4955                	li	s2,21
        if ((pids[i] = fork()) == 0) {
  800700:	9d9ff0ef          	jal	8000d8 <fork>
  800704:	c088                	sw	a0,0(s1)
  800706:	cd25                	beqz	a0,80077e <main+0xa0>
            srand(i * i);
            int times = (((unsigned int)rand()) % total);
            times = (times * times + 10) * 100;
            work(times);
        }
        if (pids[i] < 0) {
  800708:	04054563          	bltz	a0,800752 <main+0x74>
    for (i = 0; i < total; i ++) {
  80070c:	2405                	addiw	s0,s0,1
  80070e:	0491                	addi	s1,s1,4
  800710:	ff2418e3          	bne	s0,s2,800700 <main+0x22>
            goto failed;
        }
    }

    cprintf("fork ok.\n");
  800714:	00000517          	auipc	a0,0x0
  800718:	1fc50513          	addi	a0,a0,508 # 800910 <main+0x232>
  80071c:	a09ff0ef          	jal	800124 <cprintf>

    for (i = 0; i < total; i ++) {
        if (wait() != 0) {
  800720:	9bbff0ef          	jal	8000da <wait>
  800724:	e10d                	bnez	a0,800746 <main+0x68>
    for (i = 0; i < total; i ++) {
  800726:	347d                	addiw	s0,s0,-1
  800728:	fc65                	bnez	s0,800720 <main+0x42>
            cprintf("wait failed.\n");
            goto failed;
        }
    }

    cprintf("matrix pass.\n");
  80072a:	00000517          	auipc	a0,0x0
  80072e:	20650513          	addi	a0,a0,518 # 800930 <main+0x252>
  800732:	9f3ff0ef          	jal	800124 <cprintf>
        if (pids[i] > 0) {
            kill(pids[i]);
        }
    }
    panic("FAIL: T.T\n");
}
  800736:	60aa                	ld	ra,136(sp)
  800738:	640a                	ld	s0,128(sp)
  80073a:	74e6                	ld	s1,120(sp)
  80073c:	7946                	ld	s2,112(sp)
  80073e:	79a6                	ld	s3,104(sp)
  800740:	4501                	li	a0,0
  800742:	6149                	addi	sp,sp,144
  800744:	8082                	ret
            cprintf("wait failed.\n");
  800746:	00000517          	auipc	a0,0x0
  80074a:	1da50513          	addi	a0,a0,474 # 800920 <main+0x242>
  80074e:	9d7ff0ef          	jal	800124 <cprintf>
    for (i = 0; i < total; i ++) {
  800752:	08e0                	addi	s0,sp,92
        if (pids[i] > 0) {
  800754:	0009a503          	lw	a0,0(s3)
  800758:	00a05463          	blez	a0,800760 <main+0x82>
            kill(pids[i]);
  80075c:	987ff0ef          	jal	8000e2 <kill>
    for (i = 0; i < total; i ++) {
  800760:	0991                	addi	s3,s3,4
  800762:	fe8999e3          	bne	s3,s0,800754 <main+0x76>
    panic("FAIL: T.T\n");
  800766:	00000617          	auipc	a2,0x0
  80076a:	1da60613          	addi	a2,a2,474 # 800940 <main+0x262>
  80076e:	05200593          	li	a1,82
  800772:	00000517          	auipc	a0,0x0
  800776:	1de50513          	addi	a0,a0,478 # 800950 <main+0x272>
  80077a:	8a7ff0ef          	jal	800020 <__panic>
            srand(i * i);
  80077e:	0284053b          	mulw	a0,s0,s0
  800782:	e2bff0ef          	jal	8005ac <srand>
            int times = (((unsigned int)rand()) % total);
  800786:	dd9ff0ef          	jal	80055e <rand>
  80078a:	47d5                	li	a5,21
  80078c:	02f577bb          	remuw	a5,a0,a5
            times = (times * times + 10) * 100;
  800790:	06400513          	li	a0,100
  800794:	02f787bb          	mulw	a5,a5,a5
  800798:	27a9                	addiw	a5,a5,10
  80079a:	02f5053b          	mulw	a0,a0,a5
            work(times);
  80079e:	e1dff0ef          	jal	8005ba <work>
