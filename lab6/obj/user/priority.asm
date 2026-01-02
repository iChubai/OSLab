
obj/__user_priority.out:     file format elf64-littleriscv


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
  800032:	6ea50513          	addi	a0,a0,1770 # 800718 <main+0x1b0>
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
  800044:	0ea000ef          	jal	80012e <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0c2000ef          	jal	80010e <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	6e850513          	addi	a0,a0,1768 # 800738 <main+0x1d0>
  800058:	0d6000ef          	jal	80012e <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	06c000ef          	jal	8000ca <exit>

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

00000000008000ae <sys_kill>:
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
  8000ae:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  8000b0:	4531                	li	a0,12
  8000b2:	bf45                	j	800062 <syscall>

00000000008000b4 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b4:	4549                	li	a0,18
  8000b6:	b775                	j	800062 <syscall>

00000000008000b8 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000b8:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000ba:	4579                	li	a0,30
  8000bc:	b75d                	j	800062 <syscall>

00000000008000be <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  8000be:	4545                	li	a0,17
  8000c0:	b74d                	j	800062 <syscall>

00000000008000c2 <sys_lab6_set_priority>:
}

void
sys_lab6_set_priority(uint64_t priority)
{
  8000c2:	85aa                	mv	a1,a0
    syscall(SYS_lab6_set_priority, priority);
  8000c4:	0ff00513          	li	a0,255
  8000c8:	bf69                	j	800062 <syscall>

00000000008000ca <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ca:	1141                	addi	sp,sp,-16
  8000cc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ce:	fcfff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d2:	00000517          	auipc	a0,0x0
  8000d6:	66e50513          	addi	a0,a0,1646 # 800740 <main+0x1d8>
  8000da:	054000ef          	jal	80012e <cprintf>
    while (1);
  8000de:	a001                	j	8000de <exit+0x14>

00000000008000e0 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000e0:	b7c9                	j	8000a2 <sys_fork>

00000000008000e2 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000e2:	b7d1                	j	8000a6 <sys_wait>

00000000008000e4 <kill>:
    sys_yield();
}

int
kill(int pid) {
    return sys_kill(pid);
  8000e4:	b7e9                	j	8000ae <sys_kill>

00000000008000e6 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000e6:	b7f9                	j	8000b4 <sys_getpid>

00000000008000e8 <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  8000e8:	bfd9                	j	8000be <sys_gettime>

00000000008000ea <lab6_setpriority>:
}

void
lab6_setpriority(uint32_t priority)
{
    sys_lab6_set_priority(priority);
  8000ea:	1502                	slli	a0,a0,0x20
  8000ec:	9101                	srli	a0,a0,0x20
  8000ee:	bfd1                	j	8000c2 <sys_lab6_set_priority>

00000000008000f0 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000f0:	072000ef          	jal	800162 <umain>
1:  j 1b
  8000f4:	a001                	j	8000f4 <_start+0x4>

00000000008000f6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000f6:	1101                	addi	sp,sp,-32
  8000f8:	ec06                	sd	ra,24(sp)
  8000fa:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000fc:	fbdff0ef          	jal	8000b8 <sys_putc>
    (*cnt) ++;
  800100:	65a2                	ld	a1,8(sp)
}
  800102:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800104:	419c                	lw	a5,0(a1)
  800106:	2785                	addiw	a5,a5,1
  800108:	c19c                	sw	a5,0(a1)
}
  80010a:	6105                	addi	sp,sp,32
  80010c:	8082                	ret

000000000080010e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  80010e:	1101                	addi	sp,sp,-32
  800110:	862a                	mv	a2,a0
  800112:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800114:	00000517          	auipc	a0,0x0
  800118:	fe250513          	addi	a0,a0,-30 # 8000f6 <cputch>
  80011c:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  80011e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800120:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800122:	0e0000ef          	jal	800202 <vprintfmt>
    return cnt;
}
  800126:	60e2                	ld	ra,24(sp)
  800128:	4532                	lw	a0,12(sp)
  80012a:	6105                	addi	sp,sp,32
  80012c:	8082                	ret

000000000080012e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80012e:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800130:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800134:	f42e                	sd	a1,40(sp)
  800136:	f832                	sd	a2,48(sp)
  800138:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013a:	862a                	mv	a2,a0
  80013c:	004c                	addi	a1,sp,4
  80013e:	00000517          	auipc	a0,0x0
  800142:	fb850513          	addi	a0,a0,-72 # 8000f6 <cputch>
  800146:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800148:	ec06                	sd	ra,24(sp)
  80014a:	e0ba                	sd	a4,64(sp)
  80014c:	e4be                	sd	a5,72(sp)
  80014e:	e8c2                	sd	a6,80(sp)
  800150:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800152:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800154:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800156:	0ac000ef          	jal	800202 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80015a:	60e2                	ld	ra,24(sp)
  80015c:	4512                	lw	a0,4(sp)
  80015e:	6125                	addi	sp,sp,96
  800160:	8082                	ret

0000000000800162 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800162:	1141                	addi	sp,sp,-16
  800164:	e406                	sd	ra,8(sp)
    int ret = main();
  800166:	402000ef          	jal	800568 <main>
    exit(ret);
  80016a:	f61ff0ef          	jal	8000ca <exit>

000000000080016e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80016e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800170:	e589                	bnez	a1,80017a <strnlen+0xc>
  800172:	a811                	j	800186 <strnlen+0x18>
        cnt ++;
  800174:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800176:	00f58863          	beq	a1,a5,800186 <strnlen+0x18>
  80017a:	00f50733          	add	a4,a0,a5
  80017e:	00074703          	lbu	a4,0(a4)
  800182:	fb6d                	bnez	a4,800174 <strnlen+0x6>
  800184:	85be                	mv	a1,a5
    }
    return cnt;
}
  800186:	852e                	mv	a0,a1
  800188:	8082                	ret

000000000080018a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
  80018a:	ca01                	beqz	a2,80019a <memset+0x10>
  80018c:	962a                	add	a2,a2,a0
    char *p = s;
  80018e:	87aa                	mv	a5,a0
        *p ++ = c;
  800190:	0785                	addi	a5,a5,1
  800192:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
  800196:	fef61de3          	bne	a2,a5,800190 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  80019a:	8082                	ret

000000000080019c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80019c:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80019e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001a2:	f022                	sd	s0,32(sp)
  8001a4:	ec26                	sd	s1,24(sp)
  8001a6:	e84a                	sd	s2,16(sp)
  8001a8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001aa:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001ae:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  8001b0:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001b4:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  8001b8:	84aa                	mv	s1,a0
  8001ba:	892e                	mv	s2,a1
    if (num >= base) {
  8001bc:	03067d63          	bgeu	a2,a6,8001f6 <printnum+0x5a>
  8001c0:	e44e                	sd	s3,8(sp)
  8001c2:	89be                	mv	s3,a5
        while (-- width > 0)
  8001c4:	4785                	li	a5,1
  8001c6:	00e7d763          	bge	a5,a4,8001d4 <printnum+0x38>
            putch(padc, putdat);
  8001ca:	85ca                	mv	a1,s2
  8001cc:	854e                	mv	a0,s3
        while (-- width > 0)
  8001ce:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001d0:	9482                	jalr	s1
        while (-- width > 0)
  8001d2:	fc65                	bnez	s0,8001ca <printnum+0x2e>
  8001d4:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	00000797          	auipc	a5,0x0
  8001da:	58278793          	addi	a5,a5,1410 # 800758 <main+0x1f0>
  8001de:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001e0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001e2:	0007c503          	lbu	a0,0(a5)
}
  8001e6:	70a2                	ld	ra,40(sp)
  8001e8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ea:	85ca                	mv	a1,s2
  8001ec:	87a6                	mv	a5,s1
}
  8001ee:	6942                	ld	s2,16(sp)
  8001f0:	64e2                	ld	s1,24(sp)
  8001f2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001f4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001f6:	03065633          	divu	a2,a2,a6
  8001fa:	8722                	mv	a4,s0
  8001fc:	fa1ff0ef          	jal	80019c <printnum>
  800200:	bfd9                	j	8001d6 <printnum+0x3a>

0000000000800202 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800202:	7119                	addi	sp,sp,-128
  800204:	f4a6                	sd	s1,104(sp)
  800206:	f0ca                	sd	s2,96(sp)
  800208:	ecce                	sd	s3,88(sp)
  80020a:	e8d2                	sd	s4,80(sp)
  80020c:	e4d6                	sd	s5,72(sp)
  80020e:	e0da                	sd	s6,64(sp)
  800210:	f862                	sd	s8,48(sp)
  800212:	fc86                	sd	ra,120(sp)
  800214:	f8a2                	sd	s0,112(sp)
  800216:	fc5e                	sd	s7,56(sp)
  800218:	f466                	sd	s9,40(sp)
  80021a:	f06a                	sd	s10,32(sp)
  80021c:	ec6e                	sd	s11,24(sp)
  80021e:	84aa                	mv	s1,a0
  800220:	8c32                	mv	s8,a2
  800222:	8a36                	mv	s4,a3
  800224:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80022a:	05500b13          	li	s6,85
  80022e:	00000a97          	auipc	s5,0x0
  800232:	6daa8a93          	addi	s5,s5,1754 # 800908 <main+0x3a0>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	000c4503          	lbu	a0,0(s8)
  80023a:	001c0413          	addi	s0,s8,1
  80023e:	01350a63          	beq	a0,s3,800252 <vprintfmt+0x50>
            if (ch == '\0') {
  800242:	cd0d                	beqz	a0,80027c <vprintfmt+0x7a>
            putch(ch, putdat);
  800244:	85ca                	mv	a1,s2
  800246:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800248:	00044503          	lbu	a0,0(s0)
  80024c:	0405                	addi	s0,s0,1
  80024e:	ff351ae3          	bne	a0,s3,800242 <vprintfmt+0x40>
        width = precision = -1;
  800252:	5cfd                	li	s9,-1
  800254:	8d66                	mv	s10,s9
        char padc = ' ';
  800256:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80025a:	4b81                	li	s7,0
  80025c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80025e:	00044683          	lbu	a3,0(s0)
  800262:	00140c13          	addi	s8,s0,1
  800266:	fdd6859b          	addiw	a1,a3,-35
  80026a:	0ff5f593          	zext.b	a1,a1
  80026e:	02bb6663          	bltu	s6,a1,80029a <vprintfmt+0x98>
  800272:	058a                	slli	a1,a1,0x2
  800274:	95d6                	add	a1,a1,s5
  800276:	4198                	lw	a4,0(a1)
  800278:	9756                	add	a4,a4,s5
  80027a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80027c:	70e6                	ld	ra,120(sp)
  80027e:	7446                	ld	s0,112(sp)
  800280:	74a6                	ld	s1,104(sp)
  800282:	7906                	ld	s2,96(sp)
  800284:	69e6                	ld	s3,88(sp)
  800286:	6a46                	ld	s4,80(sp)
  800288:	6aa6                	ld	s5,72(sp)
  80028a:	6b06                	ld	s6,64(sp)
  80028c:	7be2                	ld	s7,56(sp)
  80028e:	7c42                	ld	s8,48(sp)
  800290:	7ca2                	ld	s9,40(sp)
  800292:	7d02                	ld	s10,32(sp)
  800294:	6de2                	ld	s11,24(sp)
  800296:	6109                	addi	sp,sp,128
  800298:	8082                	ret
            putch('%', putdat);
  80029a:	85ca                	mv	a1,s2
  80029c:	02500513          	li	a0,37
  8002a0:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002a2:	fff44783          	lbu	a5,-1(s0)
  8002a6:	02500713          	li	a4,37
  8002aa:	8c22                	mv	s8,s0
  8002ac:	f8e785e3          	beq	a5,a4,800236 <vprintfmt+0x34>
  8002b0:	ffec4783          	lbu	a5,-2(s8)
  8002b4:	1c7d                	addi	s8,s8,-1
  8002b6:	fee79de3          	bne	a5,a4,8002b0 <vprintfmt+0xae>
  8002ba:	bfb5                	j	800236 <vprintfmt+0x34>
                ch = *fmt;
  8002bc:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  8002c0:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  8002c2:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  8002c6:	fd06071b          	addiw	a4,a2,-48
  8002ca:	24e56a63          	bltu	a0,a4,80051e <vprintfmt+0x31c>
                ch = *fmt;
  8002ce:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002d0:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002d2:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002d6:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002da:	0197073b          	addw	a4,a4,s9
  8002de:	0017171b          	slliw	a4,a4,0x1
  8002e2:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002e4:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002e8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ea:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ee:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002f2:	feb570e3          	bgeu	a0,a1,8002d2 <vprintfmt+0xd0>
            if (width < 0)
  8002f6:	f60d54e3          	bgez	s10,80025e <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002fa:	8d66                	mv	s10,s9
  8002fc:	5cfd                	li	s9,-1
  8002fe:	b785                	j	80025e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	8db6                	mv	s11,a3
  800302:	8462                	mv	s0,s8
  800304:	bfa9                	j	80025e <vprintfmt+0x5c>
  800306:	8462                	mv	s0,s8
            altflag = 1;
  800308:	4b85                	li	s7,1
            goto reswitch;
  80030a:	bf91                	j	80025e <vprintfmt+0x5c>
    if (lflag >= 2) {
  80030c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80030e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800312:	00f74463          	blt	a4,a5,80031a <vprintfmt+0x118>
    else if (lflag) {
  800316:	1a078763          	beqz	a5,8004c4 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  80031a:	000a3603          	ld	a2,0(s4)
  80031e:	46c1                	li	a3,16
  800320:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800322:	000d879b          	sext.w	a5,s11
  800326:	876a                	mv	a4,s10
  800328:	85ca                	mv	a1,s2
  80032a:	8526                	mv	a0,s1
  80032c:	e71ff0ef          	jal	80019c <printnum>
            break;
  800330:	b719                	j	800236 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800332:	000a2503          	lw	a0,0(s4)
  800336:	85ca                	mv	a1,s2
  800338:	0a21                	addi	s4,s4,8
  80033a:	9482                	jalr	s1
            break;
  80033c:	bded                	j	800236 <vprintfmt+0x34>
    if (lflag >= 2) {
  80033e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800340:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800344:	00f74463          	blt	a4,a5,80034c <vprintfmt+0x14a>
    else if (lflag) {
  800348:	16078963          	beqz	a5,8004ba <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80034c:	000a3603          	ld	a2,0(s4)
  800350:	46a9                	li	a3,10
  800352:	8a2e                	mv	s4,a1
  800354:	b7f9                	j	800322 <vprintfmt+0x120>
            putch('0', putdat);
  800356:	85ca                	mv	a1,s2
  800358:	03000513          	li	a0,48
  80035c:	9482                	jalr	s1
            putch('x', putdat);
  80035e:	85ca                	mv	a1,s2
  800360:	07800513          	li	a0,120
  800364:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800366:	000a3603          	ld	a2,0(s4)
            goto number;
  80036a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80036c:	0a21                	addi	s4,s4,8
            goto number;
  80036e:	bf55                	j	800322 <vprintfmt+0x120>
            putch(ch, putdat);
  800370:	85ca                	mv	a1,s2
  800372:	02500513          	li	a0,37
  800376:	9482                	jalr	s1
            break;
  800378:	bd7d                	j	800236 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80037a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80037e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800380:	0a21                	addi	s4,s4,8
            goto process_precision;
  800382:	bf95                	j	8002f6 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800384:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800386:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80038a:	00f74463          	blt	a4,a5,800392 <vprintfmt+0x190>
    else if (lflag) {
  80038e:	12078163          	beqz	a5,8004b0 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800392:	000a3603          	ld	a2,0(s4)
  800396:	46a1                	li	a3,8
  800398:	8a2e                	mv	s4,a1
  80039a:	b761                	j	800322 <vprintfmt+0x120>
            if (width < 0)
  80039c:	876a                	mv	a4,s10
  80039e:	000d5363          	bgez	s10,8003a4 <vprintfmt+0x1a2>
  8003a2:	4701                	li	a4,0
  8003a4:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  8003a8:	8462                	mv	s0,s8
            goto reswitch;
  8003aa:	bd55                	j	80025e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  8003ac:	000d841b          	sext.w	s0,s11
  8003b0:	fd340793          	addi	a5,s0,-45
  8003b4:	00f037b3          	snez	a5,a5
  8003b8:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  8003bc:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  8003c0:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c2:	008a0793          	addi	a5,s4,8
  8003c6:	e43e                	sd	a5,8(sp)
  8003c8:	100d8c63          	beqz	s11,8004e0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003cc:	12071363          	bnez	a4,8004f2 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d0:	000dc783          	lbu	a5,0(s11)
  8003d4:	0007851b          	sext.w	a0,a5
  8003d8:	c78d                	beqz	a5,800402 <vprintfmt+0x200>
  8003da:	0d85                	addi	s11,s11,1
  8003dc:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003de:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e2:	000cc563          	bltz	s9,8003ec <vprintfmt+0x1ea>
  8003e6:	3cfd                	addiw	s9,s9,-1
  8003e8:	008c8d63          	beq	s9,s0,800402 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ec:	020b9663          	bnez	s7,800418 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003f0:	85ca                	mv	a1,s2
  8003f2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f4:	000dc783          	lbu	a5,0(s11)
  8003f8:	0d85                	addi	s11,s11,1
  8003fa:	3d7d                	addiw	s10,s10,-1
  8003fc:	0007851b          	sext.w	a0,a5
  800400:	f3ed                	bnez	a5,8003e2 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800402:	01a05963          	blez	s10,800414 <vprintfmt+0x212>
                putch(' ', putdat);
  800406:	85ca                	mv	a1,s2
  800408:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80040c:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80040e:	9482                	jalr	s1
            for (; width > 0; width --) {
  800410:	fe0d1be3          	bnez	s10,800406 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800414:	6a22                	ld	s4,8(sp)
  800416:	b505                	j	800236 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800418:	3781                	addiw	a5,a5,-32
  80041a:	fcfa7be3          	bgeu	s4,a5,8003f0 <vprintfmt+0x1ee>
                    putch('?', putdat);
  80041e:	03f00513          	li	a0,63
  800422:	85ca                	mv	a1,s2
  800424:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800426:	000dc783          	lbu	a5,0(s11)
  80042a:	0d85                	addi	s11,s11,1
  80042c:	3d7d                	addiw	s10,s10,-1
  80042e:	0007851b          	sext.w	a0,a5
  800432:	dbe1                	beqz	a5,800402 <vprintfmt+0x200>
  800434:	fa0cd9e3          	bgez	s9,8003e6 <vprintfmt+0x1e4>
  800438:	b7c5                	j	800418 <vprintfmt+0x216>
            if (err < 0) {
  80043a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80043e:	4661                	li	a2,24
            err = va_arg(ap, int);
  800440:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800442:	41f7d71b          	sraiw	a4,a5,0x1f
  800446:	8fb9                	xor	a5,a5,a4
  800448:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80044c:	02d64563          	blt	a2,a3,800476 <vprintfmt+0x274>
  800450:	00000797          	auipc	a5,0x0
  800454:	61078793          	addi	a5,a5,1552 # 800a60 <error_string>
  800458:	00369713          	slli	a4,a3,0x3
  80045c:	97ba                	add	a5,a5,a4
  80045e:	639c                	ld	a5,0(a5)
  800460:	cb99                	beqz	a5,800476 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800462:	86be                	mv	a3,a5
  800464:	00000617          	auipc	a2,0x0
  800468:	32460613          	addi	a2,a2,804 # 800788 <main+0x220>
  80046c:	85ca                	mv	a1,s2
  80046e:	8526                	mv	a0,s1
  800470:	0d8000ef          	jal	800548 <printfmt>
  800474:	b3c9                	j	800236 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800476:	00000617          	auipc	a2,0x0
  80047a:	30260613          	addi	a2,a2,770 # 800778 <main+0x210>
  80047e:	85ca                	mv	a1,s2
  800480:	8526                	mv	a0,s1
  800482:	0c6000ef          	jal	800548 <printfmt>
  800486:	bb45                	j	800236 <vprintfmt+0x34>
    if (lflag >= 2) {
  800488:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80048a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80048e:	00f74363          	blt	a4,a5,800494 <vprintfmt+0x292>
    else if (lflag) {
  800492:	cf81                	beqz	a5,8004aa <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800494:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800498:	02044b63          	bltz	s0,8004ce <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80049c:	8622                	mv	a2,s0
  80049e:	8a5e                	mv	s4,s7
  8004a0:	46a9                	li	a3,10
  8004a2:	b541                	j	800322 <vprintfmt+0x120>
            lflag ++;
  8004a4:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  8004a6:	8462                	mv	s0,s8
            goto reswitch;
  8004a8:	bb5d                	j	80025e <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8004aa:	000a2403          	lw	s0,0(s4)
  8004ae:	b7ed                	j	800498 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  8004b0:	000a6603          	lwu	a2,0(s4)
  8004b4:	46a1                	li	a3,8
  8004b6:	8a2e                	mv	s4,a1
  8004b8:	b5ad                	j	800322 <vprintfmt+0x120>
  8004ba:	000a6603          	lwu	a2,0(s4)
  8004be:	46a9                	li	a3,10
  8004c0:	8a2e                	mv	s4,a1
  8004c2:	b585                	j	800322 <vprintfmt+0x120>
  8004c4:	000a6603          	lwu	a2,0(s4)
  8004c8:	46c1                	li	a3,16
  8004ca:	8a2e                	mv	s4,a1
  8004cc:	bd99                	j	800322 <vprintfmt+0x120>
                putch('-', putdat);
  8004ce:	85ca                	mv	a1,s2
  8004d0:	02d00513          	li	a0,45
  8004d4:	9482                	jalr	s1
                num = -(long long)num;
  8004d6:	40800633          	neg	a2,s0
  8004da:	8a5e                	mv	s4,s7
  8004dc:	46a9                	li	a3,10
  8004de:	b591                	j	800322 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004e0:	e329                	bnez	a4,800522 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e2:	02800793          	li	a5,40
  8004e6:	853e                	mv	a0,a5
  8004e8:	00000d97          	auipc	s11,0x0
  8004ec:	289d8d93          	addi	s11,s11,649 # 800771 <main+0x209>
  8004f0:	b5f5                	j	8003dc <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f2:	85e6                	mv	a1,s9
  8004f4:	856e                	mv	a0,s11
  8004f6:	c79ff0ef          	jal	80016e <strnlen>
  8004fa:	40ad0d3b          	subw	s10,s10,a0
  8004fe:	01a05863          	blez	s10,80050e <vprintfmt+0x30c>
                    putch(padc, putdat);
  800502:	85ca                	mv	a1,s2
  800504:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800506:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800508:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  80050a:	fe0d1ce3          	bnez	s10,800502 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050e:	000dc783          	lbu	a5,0(s11)
  800512:	0007851b          	sext.w	a0,a5
  800516:	ec0792e3          	bnez	a5,8003da <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  80051a:	6a22                	ld	s4,8(sp)
  80051c:	bb29                	j	800236 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80051e:	8462                	mv	s0,s8
  800520:	bbd9                	j	8002f6 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800522:	85e6                	mv	a1,s9
  800524:	00000517          	auipc	a0,0x0
  800528:	24c50513          	addi	a0,a0,588 # 800770 <main+0x208>
  80052c:	c43ff0ef          	jal	80016e <strnlen>
  800530:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800534:	02800793          	li	a5,40
                p = "(null)";
  800538:	00000d97          	auipc	s11,0x0
  80053c:	238d8d93          	addi	s11,s11,568 # 800770 <main+0x208>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800540:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800542:	fda040e3          	bgtz	s10,800502 <vprintfmt+0x300>
  800546:	bd51                	j	8003da <vprintfmt+0x1d8>

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
  80055e:	ca5ff0ef          	jal	800202 <vprintfmt>
}
  800562:	60e2                	ld	ra,24(sp)
  800564:	6161                	addi	sp,sp,80
  800566:	8082                	ret

0000000000800568 <main>:
          j = !j;
     }
}

int
main(void) {
  800568:	715d                	addi	sp,sp,-80
     int i,time;
     memset(pids, 0, sizeof(pids));
  80056a:	4651                	li	a2,20
  80056c:	4581                	li	a1,0
  80056e:	00001517          	auipc	a0,0x1
  800572:	a9250513          	addi	a0,a0,-1390 # 801000 <pids>
main(void) {
  800576:	e486                	sd	ra,72(sp)
  800578:	e0a2                	sd	s0,64(sp)
  80057a:	fc26                	sd	s1,56(sp)
  80057c:	f84a                	sd	s2,48(sp)
  80057e:	f44e                	sd	s3,40(sp)
  800580:	f052                	sd	s4,32(sp)
  800582:	ec56                	sd	s5,24(sp)
     memset(pids, 0, sizeof(pids));
  800584:	c07ff0ef          	jal	80018a <memset>
     lab6_setpriority(TOTAL + 1);
  800588:	4519                	li	a0,6
  80058a:	00001a97          	auipc	s5,0x1
  80058e:	aa6a8a93          	addi	s5,s5,-1370 # 801030 <acc>
  800592:	00001497          	auipc	s1,0x1
  800596:	a6e48493          	addi	s1,s1,-1426 # 801000 <pids>
  80059a:	b51ff0ef          	jal	8000ea <lab6_setpriority>

     for (i = 0; i < TOTAL; i ++) {
  80059e:	89d6                	mv	s3,s5
     lab6_setpriority(TOTAL + 1);
  8005a0:	8926                	mv	s2,s1
     for (i = 0; i < TOTAL; i ++) {
  8005a2:	4401                	li	s0,0
  8005a4:	4a15                	li	s4,5
          acc[i]=0;
  8005a6:	0009a023          	sw	zero,0(s3)
          if ((pids[i] = fork()) == 0) {
  8005aa:	b37ff0ef          	jal	8000e0 <fork>
  8005ae:	00a92023          	sw	a0,0(s2)
  8005b2:	c561                	beqz	a0,80067a <main+0x112>
                        }
                    }
               }
               
          }
          if (pids[i] < 0) {
  8005b4:	12054763          	bltz	a0,8006e2 <main+0x17a>
     for (i = 0; i < TOTAL; i ++) {
  8005b8:	2405                	addiw	s0,s0,1
  8005ba:	0991                	addi	s3,s3,4
  8005bc:	0911                	addi	s2,s2,4
  8005be:	ff4414e3          	bne	s0,s4,8005a6 <main+0x3e>
               goto failed;
          }
     }

     cprintf("main: fork ok,now need to wait pids.\n");
  8005c2:	00000517          	auipc	a0,0x0
  8005c6:	2ae50513          	addi	a0,a0,686 # 800870 <main+0x308>
  8005ca:	00001917          	auipc	s2,0x1
  8005ce:	a4e90913          	addi	s2,s2,-1458 # 801018 <status>
  8005d2:	b5dff0ef          	jal	80012e <cprintf>
  8005d6:	844a                	mv	s0,s2
  8005d8:	00001997          	auipc	s3,0x1
  8005dc:	a5498993          	addi	s3,s3,-1452 # 80102c <status+0x14>

     for (i = 0; i < TOTAL; i ++) {
         status[i]=0;
         waitpid(pids[i],&status[i]);
  8005e0:	4088                	lw	a0,0(s1)
  8005e2:	85a2                	mv	a1,s0
         status[i]=0;
  8005e4:	00042023          	sw	zero,0(s0)
         waitpid(pids[i],&status[i]);
  8005e8:	afbff0ef          	jal	8000e2 <waitpid>
         cprintf("main: pid %d, acc %d, time %d\n",pids[i],status[i],gettime_msec()); 
  8005ec:	0004aa03          	lw	s4,0(s1)
  8005f0:	00042a83          	lw	s5,0(s0)
  8005f4:	af5ff0ef          	jal	8000e8 <gettime_msec>
  8005f8:	86aa                	mv	a3,a0
  8005fa:	8656                	mv	a2,s5
  8005fc:	85d2                	mv	a1,s4
  8005fe:	00000517          	auipc	a0,0x0
  800602:	29a50513          	addi	a0,a0,666 # 800898 <main+0x330>
     for (i = 0; i < TOTAL; i ++) {
  800606:	0411                	addi	s0,s0,4
         cprintf("main: pid %d, acc %d, time %d\n",pids[i],status[i],gettime_msec()); 
  800608:	b27ff0ef          	jal	80012e <cprintf>
     for (i = 0; i < TOTAL; i ++) {
  80060c:	0491                	addi	s1,s1,4
  80060e:	fd3419e3          	bne	s0,s3,8005e0 <main+0x78>
     }
     cprintf("main: wait pids over\n");
  800612:	00000517          	auipc	a0,0x0
  800616:	2a650513          	addi	a0,a0,678 # 8008b8 <main+0x350>
  80061a:	b15ff0ef          	jal	80012e <cprintf>
     cprintf("sched result:");
  80061e:	00000517          	auipc	a0,0x0
  800622:	2b250513          	addi	a0,a0,690 # 8008d0 <main+0x368>
  800626:	b09ff0ef          	jal	80012e <cprintf>
     for (i = 0; i < TOTAL; i ++)
     {
         cprintf(" %d", (status[i] * 2 / status[0] + 1) / 2);
  80062a:	00092783          	lw	a5,0(s2)
  80062e:	00001717          	auipc	a4,0x1
  800632:	9ea72703          	lw	a4,-1558(a4) # 801018 <status>
  800636:	00000517          	auipc	a0,0x0
  80063a:	2aa50513          	addi	a0,a0,682 # 8008e0 <main+0x378>
  80063e:	0017979b          	slliw	a5,a5,0x1
  800642:	02e7c7bb          	divw	a5,a5,a4
     for (i = 0; i < TOTAL; i ++)
  800646:	0911                	addi	s2,s2,4
         cprintf(" %d", (status[i] * 2 / status[0] + 1) / 2);
  800648:	2785                	addiw	a5,a5,1
  80064a:	01f7d59b          	srliw	a1,a5,0x1f
  80064e:	9dbd                	addw	a1,a1,a5
  800650:	8585                	srai	a1,a1,0x1
  800652:	addff0ef          	jal	80012e <cprintf>
     for (i = 0; i < TOTAL; i ++)
  800656:	fd391ae3          	bne	s2,s3,80062a <main+0xc2>
     }
     cprintf("\n");
  80065a:	00000517          	auipc	a0,0x0
  80065e:	0de50513          	addi	a0,a0,222 # 800738 <main+0x1d0>
  800662:	acdff0ef          	jal	80012e <cprintf>
          if (pids[i] > 0) {
               kill(pids[i]);
          }
     }
     panic("FAIL: T.T\n");
}
  800666:	60a6                	ld	ra,72(sp)
  800668:	6406                	ld	s0,64(sp)
  80066a:	74e2                	ld	s1,56(sp)
  80066c:	7942                	ld	s2,48(sp)
  80066e:	79a2                	ld	s3,40(sp)
  800670:	7a02                	ld	s4,32(sp)
  800672:	6ae2                	ld	s5,24(sp)
  800674:	4501                	li	a0,0
  800676:	6161                	addi	sp,sp,80
  800678:	8082                	ret
               lab6_setpriority(i + 1);
  80067a:	0014051b          	addiw	a0,s0,1
               acc[i] = 0;
  80067e:	040a                	slli	s0,s0,0x2
  800680:	9aa2                	add	s5,s5,s0
                    if(acc[i]%4000==0) {
  800682:	6405                	lui	s0,0x1
               lab6_setpriority(i + 1);
  800684:	a67ff0ef          	jal	8000ea <lab6_setpriority>
                    if(acc[i]%4000==0) {
  800688:	fa04041b          	addiw	s0,s0,-96 # fa0 <__panic-0x7ff080>
               acc[i] = 0;
  80068c:	000aa023          	sw	zero,0(s5)
                        if((time=gettime_msec())>MAX_TIME) {
  800690:	7d000913          	li	s2,2000
  800694:	000aa683          	lw	a3,0(s5)
  800698:	2685                	addiw	a3,a3,1
     for (i = 0; i != 200; ++ i)
  80069a:	0c800713          	li	a4,200
          j = !j;
  80069e:	47b2                	lw	a5,12(sp)
     for (i = 0; i != 200; ++ i)
  8006a0:	377d                	addiw	a4,a4,-1
          j = !j;
  8006a2:	0017b793          	seqz	a5,a5
  8006a6:	c63e                	sw	a5,12(sp)
     for (i = 0; i != 200; ++ i)
  8006a8:	fb7d                	bnez	a4,80069e <main+0x136>
                    if(acc[i]%4000==0) {
  8006aa:	0286f7bb          	remuw	a5,a3,s0
  8006ae:	c399                	beqz	a5,8006b4 <main+0x14c>
  8006b0:	2685                	addiw	a3,a3,1
  8006b2:	b7e5                	j	80069a <main+0x132>
  8006b4:	00daa023          	sw	a3,0(s5)
                        if((time=gettime_msec())>MAX_TIME) {
  8006b8:	a31ff0ef          	jal	8000e8 <gettime_msec>
  8006bc:	84aa                	mv	s1,a0
  8006be:	fca95be3          	bge	s2,a0,800694 <main+0x12c>
                            cprintf("child pid %d, acc %d, time %d\n",getpid(),acc[i],time);
  8006c2:	a25ff0ef          	jal	8000e6 <getpid>
  8006c6:	000aa603          	lw	a2,0(s5)
  8006ca:	85aa                	mv	a1,a0
  8006cc:	86a6                	mv	a3,s1
  8006ce:	00000517          	auipc	a0,0x0
  8006d2:	18250513          	addi	a0,a0,386 # 800850 <main+0x2e8>
  8006d6:	a59ff0ef          	jal	80012e <cprintf>
                            exit(acc[i]);
  8006da:	000aa503          	lw	a0,0(s5)
  8006de:	9edff0ef          	jal	8000ca <exit>
  8006e2:	00001417          	auipc	s0,0x1
  8006e6:	93240413          	addi	s0,s0,-1742 # 801014 <pids+0x14>
          if (pids[i] > 0) {
  8006ea:	4088                	lw	a0,0(s1)
  8006ec:	00a05463          	blez	a0,8006f4 <main+0x18c>
               kill(pids[i]);
  8006f0:	9f5ff0ef          	jal	8000e4 <kill>
     for (i = 0; i < TOTAL; i ++) {
  8006f4:	0491                	addi	s1,s1,4
  8006f6:	fe849ae3          	bne	s1,s0,8006ea <main+0x182>
     panic("FAIL: T.T\n");
  8006fa:	00000617          	auipc	a2,0x0
  8006fe:	1ee60613          	addi	a2,a2,494 # 8008e8 <main+0x380>
  800702:	04b00593          	li	a1,75
  800706:	00000517          	auipc	a0,0x0
  80070a:	1f250513          	addi	a0,a0,498 # 8008f8 <main+0x390>
  80070e:	913ff0ef          	jal	800020 <__panic>
