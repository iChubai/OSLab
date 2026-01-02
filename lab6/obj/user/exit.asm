
obj/__user_exit.out:     file format elf64-littleriscv


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
  800032:	62a50513          	addi	a0,a0,1578 # 800658 <main+0x118>
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
  800044:	0d4000ef          	jal	800118 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0ac000ef          	jal	8000f8 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	62850513          	addi	a0,a0,1576 # 800678 <main+0x138>
  800058:	0c0000ef          	jal	800118 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	05a000ef          	jal	8000b8 <exit>

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
  8000bc:	fe1ff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c0:	00000517          	auipc	a0,0x0
  8000c4:	5c050513          	addi	a0,a0,1472 # 800680 <main+0x140>
  8000c8:	050000ef          	jal	800118 <cprintf>
    while (1);
  8000cc:	a001                	j	8000cc <exit+0x14>

00000000008000ce <fork>:
}

int
fork(void) {
    return sys_fork();
  8000ce:	bfd1                	j	8000a2 <sys_fork>

00000000008000d0 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000d0:	4581                	li	a1,0
  8000d2:	4501                	li	a0,0
  8000d4:	bfc9                	j	8000a6 <sys_wait>

00000000008000d6 <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d6:	bfc1                	j	8000a6 <sys_wait>

00000000008000d8 <yield>:
}

void
yield(void) {
    sys_yield();
  8000d8:	bfd9                	j	8000ae <sys_yield>

00000000008000da <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000da:	072000ef          	jal	80014c <umain>
1:  j 1b
  8000de:	a001                	j	8000de <_start+0x4>

00000000008000e0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e0:	1101                	addi	sp,sp,-32
  8000e2:	ec06                	sd	ra,24(sp)
  8000e4:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000e6:	fcdff0ef          	jal	8000b2 <sys_putc>
    (*cnt) ++;
  8000ea:	65a2                	ld	a1,8(sp)
}
  8000ec:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000ee:	419c                	lw	a5,0(a1)
  8000f0:	2785                	addiw	a5,a5,1
  8000f2:	c19c                	sw	a5,0(a1)
}
  8000f4:	6105                	addi	sp,sp,32
  8000f6:	8082                	ret

00000000008000f8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f8:	1101                	addi	sp,sp,-32
  8000fa:	862a                	mv	a2,a0
  8000fc:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000fe:	00000517          	auipc	a0,0x0
  800102:	fe250513          	addi	a0,a0,-30 # 8000e0 <cputch>
  800106:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800108:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010c:	0ce000ef          	jal	8001da <vprintfmt>
    return cnt;
}
  800110:	60e2                	ld	ra,24(sp)
  800112:	4532                	lw	a0,12(sp)
  800114:	6105                	addi	sp,sp,32
  800116:	8082                	ret

0000000000800118 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800118:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  80011e:	f42e                	sd	a1,40(sp)
  800120:	f832                	sd	a2,48(sp)
  800122:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800124:	862a                	mv	a2,a0
  800126:	004c                	addi	a1,sp,4
  800128:	00000517          	auipc	a0,0x0
  80012c:	fb850513          	addi	a0,a0,-72 # 8000e0 <cputch>
  800130:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800132:	ec06                	sd	ra,24(sp)
  800134:	e0ba                	sd	a4,64(sp)
  800136:	e4be                	sd	a5,72(sp)
  800138:	e8c2                	sd	a6,80(sp)
  80013a:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  80013c:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  80013e:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800140:	09a000ef          	jal	8001da <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800144:	60e2                	ld	ra,24(sp)
  800146:	4512                	lw	a0,4(sp)
  800148:	6125                	addi	sp,sp,96
  80014a:	8082                	ret

000000000080014c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014c:	1141                	addi	sp,sp,-16
  80014e:	e406                	sd	ra,8(sp)
    int ret = main();
  800150:	3f0000ef          	jal	800540 <main>
    exit(ret);
  800154:	f65ff0ef          	jal	8000b8 <exit>

0000000000800158 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800158:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80015a:	e589                	bnez	a1,800164 <strnlen+0xc>
  80015c:	a811                	j	800170 <strnlen+0x18>
        cnt ++;
  80015e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800160:	00f58863          	beq	a1,a5,800170 <strnlen+0x18>
  800164:	00f50733          	add	a4,a0,a5
  800168:	00074703          	lbu	a4,0(a4)
  80016c:	fb6d                	bnez	a4,80015e <strnlen+0x6>
  80016e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800170:	852e                	mv	a0,a1
  800172:	8082                	ret

0000000000800174 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800176:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	f022                	sd	s0,32(sp)
  80017c:	ec26                	sd	s1,24(sp)
  80017e:	e84a                	sd	s2,16(sp)
  800180:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800182:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800186:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800188:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800190:	84aa                	mv	s1,a0
  800192:	892e                	mv	s2,a1
    if (num >= base) {
  800194:	03067d63          	bgeu	a2,a6,8001ce <printnum+0x5a>
  800198:	e44e                	sd	s3,8(sp)
  80019a:	89be                	mv	s3,a5
        while (-- width > 0)
  80019c:	4785                	li	a5,1
  80019e:	00e7d763          	bge	a5,a4,8001ac <printnum+0x38>
            putch(padc, putdat);
  8001a2:	85ca                	mv	a1,s2
  8001a4:	854e                	mv	a0,s3
        while (-- width > 0)
  8001a6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a8:	9482                	jalr	s1
        while (-- width > 0)
  8001aa:	fc65                	bnez	s0,8001a2 <printnum+0x2e>
  8001ac:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	00000797          	auipc	a5,0x0
  8001b2:	4ea78793          	addi	a5,a5,1258 # 800698 <main+0x158>
  8001b6:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	0007c503          	lbu	a0,0(a5)
}
  8001be:	70a2                	ld	ra,40(sp)
  8001c0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	85ca                	mv	a1,s2
  8001c4:	87a6                	mv	a5,s1
}
  8001c6:	6942                	ld	s2,16(sp)
  8001c8:	64e2                	ld	s1,24(sp)
  8001ca:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ce:	03065633          	divu	a2,a2,a6
  8001d2:	8722                	mv	a4,s0
  8001d4:	fa1ff0ef          	jal	800174 <printnum>
  8001d8:	bfd9                	j	8001ae <printnum+0x3a>

00000000008001da <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001da:	7119                	addi	sp,sp,-128
  8001dc:	f4a6                	sd	s1,104(sp)
  8001de:	f0ca                	sd	s2,96(sp)
  8001e0:	ecce                	sd	s3,88(sp)
  8001e2:	e8d2                	sd	s4,80(sp)
  8001e4:	e4d6                	sd	s5,72(sp)
  8001e6:	e0da                	sd	s6,64(sp)
  8001e8:	f862                	sd	s8,48(sp)
  8001ea:	fc86                	sd	ra,120(sp)
  8001ec:	f8a2                	sd	s0,112(sp)
  8001ee:	fc5e                	sd	s7,56(sp)
  8001f0:	f466                	sd	s9,40(sp)
  8001f2:	f06a                	sd	s10,32(sp)
  8001f4:	ec6e                	sd	s11,24(sp)
  8001f6:	84aa                	mv	s1,a0
  8001f8:	8c32                	mv	s8,a2
  8001fa:	8a36                	mv	s4,a3
  8001fc:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fe:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800202:	05500b13          	li	s6,85
  800206:	00000a97          	auipc	s5,0x0
  80020a:	6b6a8a93          	addi	s5,s5,1718 # 8008bc <main+0x37c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	000c4503          	lbu	a0,0(s8)
  800212:	001c0413          	addi	s0,s8,1
  800216:	01350a63          	beq	a0,s3,80022a <vprintfmt+0x50>
            if (ch == '\0') {
  80021a:	cd0d                	beqz	a0,800254 <vprintfmt+0x7a>
            putch(ch, putdat);
  80021c:	85ca                	mv	a1,s2
  80021e:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	00044503          	lbu	a0,0(s0)
  800224:	0405                	addi	s0,s0,1
  800226:	ff351ae3          	bne	a0,s3,80021a <vprintfmt+0x40>
        width = precision = -1;
  80022a:	5cfd                	li	s9,-1
  80022c:	8d66                	mv	s10,s9
        char padc = ' ';
  80022e:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800232:	4b81                	li	s7,0
  800234:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800236:	00044683          	lbu	a3,0(s0)
  80023a:	00140c13          	addi	s8,s0,1
  80023e:	fdd6859b          	addiw	a1,a3,-35
  800242:	0ff5f593          	zext.b	a1,a1
  800246:	02bb6663          	bltu	s6,a1,800272 <vprintfmt+0x98>
  80024a:	058a                	slli	a1,a1,0x2
  80024c:	95d6                	add	a1,a1,s5
  80024e:	4198                	lw	a4,0(a1)
  800250:	9756                	add	a4,a4,s5
  800252:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800254:	70e6                	ld	ra,120(sp)
  800256:	7446                	ld	s0,112(sp)
  800258:	74a6                	ld	s1,104(sp)
  80025a:	7906                	ld	s2,96(sp)
  80025c:	69e6                	ld	s3,88(sp)
  80025e:	6a46                	ld	s4,80(sp)
  800260:	6aa6                	ld	s5,72(sp)
  800262:	6b06                	ld	s6,64(sp)
  800264:	7be2                	ld	s7,56(sp)
  800266:	7c42                	ld	s8,48(sp)
  800268:	7ca2                	ld	s9,40(sp)
  80026a:	7d02                	ld	s10,32(sp)
  80026c:	6de2                	ld	s11,24(sp)
  80026e:	6109                	addi	sp,sp,128
  800270:	8082                	ret
            putch('%', putdat);
  800272:	85ca                	mv	a1,s2
  800274:	02500513          	li	a0,37
  800278:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80027a:	fff44783          	lbu	a5,-1(s0)
  80027e:	02500713          	li	a4,37
  800282:	8c22                	mv	s8,s0
  800284:	f8e785e3          	beq	a5,a4,80020e <vprintfmt+0x34>
  800288:	ffec4783          	lbu	a5,-2(s8)
  80028c:	1c7d                	addi	s8,s8,-1
  80028e:	fee79de3          	bne	a5,a4,800288 <vprintfmt+0xae>
  800292:	bfb5                	j	80020e <vprintfmt+0x34>
                ch = *fmt;
  800294:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800298:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80029a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80029e:	fd06071b          	addiw	a4,a2,-48
  8002a2:	24e56a63          	bltu	a0,a4,8004f6 <vprintfmt+0x31c>
                ch = *fmt;
  8002a6:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002aa:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002ae:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002b2:	0197073b          	addw	a4,a4,s9
  8002b6:	0017171b          	slliw	a4,a4,0x1
  8002ba:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002bc:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002c2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002c6:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002ca:	feb570e3          	bgeu	a0,a1,8002aa <vprintfmt+0xd0>
            if (width < 0)
  8002ce:	f60d54e3          	bgez	s10,800236 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002d2:	8d66                	mv	s10,s9
  8002d4:	5cfd                	li	s9,-1
  8002d6:	b785                	j	800236 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d8:	8db6                	mv	s11,a3
  8002da:	8462                	mv	s0,s8
  8002dc:	bfa9                	j	800236 <vprintfmt+0x5c>
  8002de:	8462                	mv	s0,s8
            altflag = 1;
  8002e0:	4b85                	li	s7,1
            goto reswitch;
  8002e2:	bf91                	j	800236 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ea:	00f74463          	blt	a4,a5,8002f2 <vprintfmt+0x118>
    else if (lflag) {
  8002ee:	1a078763          	beqz	a5,80049c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002f2:	000a3603          	ld	a2,0(s4)
  8002f6:	46c1                	li	a3,16
  8002f8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002fa:	000d879b          	sext.w	a5,s11
  8002fe:	876a                	mv	a4,s10
  800300:	85ca                	mv	a1,s2
  800302:	8526                	mv	a0,s1
  800304:	e71ff0ef          	jal	800174 <printnum>
            break;
  800308:	b719                	j	80020e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80030a:	000a2503          	lw	a0,0(s4)
  80030e:	85ca                	mv	a1,s2
  800310:	0a21                	addi	s4,s4,8
  800312:	9482                	jalr	s1
            break;
  800314:	bded                	j	80020e <vprintfmt+0x34>
    if (lflag >= 2) {
  800316:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800318:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80031c:	00f74463          	blt	a4,a5,800324 <vprintfmt+0x14a>
    else if (lflag) {
  800320:	16078963          	beqz	a5,800492 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800324:	000a3603          	ld	a2,0(s4)
  800328:	46a9                	li	a3,10
  80032a:	8a2e                	mv	s4,a1
  80032c:	b7f9                	j	8002fa <vprintfmt+0x120>
            putch('0', putdat);
  80032e:	85ca                	mv	a1,s2
  800330:	03000513          	li	a0,48
  800334:	9482                	jalr	s1
            putch('x', putdat);
  800336:	85ca                	mv	a1,s2
  800338:	07800513          	li	a0,120
  80033c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033e:	000a3603          	ld	a2,0(s4)
            goto number;
  800342:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800344:	0a21                	addi	s4,s4,8
            goto number;
  800346:	bf55                	j	8002fa <vprintfmt+0x120>
            putch(ch, putdat);
  800348:	85ca                	mv	a1,s2
  80034a:	02500513          	li	a0,37
  80034e:	9482                	jalr	s1
            break;
  800350:	bd7d                	j	80020e <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800352:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800356:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800358:	0a21                	addi	s4,s4,8
            goto process_precision;
  80035a:	bf95                	j	8002ce <vprintfmt+0xf4>
    if (lflag >= 2) {
  80035c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800362:	00f74463          	blt	a4,a5,80036a <vprintfmt+0x190>
    else if (lflag) {
  800366:	12078163          	beqz	a5,800488 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80036a:	000a3603          	ld	a2,0(s4)
  80036e:	46a1                	li	a3,8
  800370:	8a2e                	mv	s4,a1
  800372:	b761                	j	8002fa <vprintfmt+0x120>
            if (width < 0)
  800374:	876a                	mv	a4,s10
  800376:	000d5363          	bgez	s10,80037c <vprintfmt+0x1a2>
  80037a:	4701                	li	a4,0
  80037c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800380:	8462                	mv	s0,s8
            goto reswitch;
  800382:	bd55                	j	800236 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800384:	000d841b          	sext.w	s0,s11
  800388:	fd340793          	addi	a5,s0,-45
  80038c:	00f037b3          	snez	a5,a5
  800390:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800394:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800398:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80039a:	008a0793          	addi	a5,s4,8
  80039e:	e43e                	sd	a5,8(sp)
  8003a0:	100d8c63          	beqz	s11,8004b8 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  8003a4:	12071363          	bnez	a4,8004ca <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a8:	000dc783          	lbu	a5,0(s11)
  8003ac:	0007851b          	sext.w	a0,a5
  8003b0:	c78d                	beqz	a5,8003da <vprintfmt+0x200>
  8003b2:	0d85                	addi	s11,s11,1
  8003b4:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b6:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ba:	000cc563          	bltz	s9,8003c4 <vprintfmt+0x1ea>
  8003be:	3cfd                	addiw	s9,s9,-1
  8003c0:	008c8d63          	beq	s9,s0,8003da <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c4:	020b9663          	bnez	s7,8003f0 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003c8:	85ca                	mv	a1,s2
  8003ca:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003cc:	000dc783          	lbu	a5,0(s11)
  8003d0:	0d85                	addi	s11,s11,1
  8003d2:	3d7d                	addiw	s10,s10,-1
  8003d4:	0007851b          	sext.w	a0,a5
  8003d8:	f3ed                	bnez	a5,8003ba <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003da:	01a05963          	blez	s10,8003ec <vprintfmt+0x212>
                putch(' ', putdat);
  8003de:	85ca                	mv	a1,s2
  8003e0:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003e4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003e6:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003e8:	fe0d1be3          	bnez	s10,8003de <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ec:	6a22                	ld	s4,8(sp)
  8003ee:	b505                	j	80020e <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f0:	3781                	addiw	a5,a5,-32
  8003f2:	fcfa7be3          	bgeu	s4,a5,8003c8 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003f6:	03f00513          	li	a0,63
  8003fa:	85ca                	mv	a1,s2
  8003fc:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003fe:	000dc783          	lbu	a5,0(s11)
  800402:	0d85                	addi	s11,s11,1
  800404:	3d7d                	addiw	s10,s10,-1
  800406:	0007851b          	sext.w	a0,a5
  80040a:	dbe1                	beqz	a5,8003da <vprintfmt+0x200>
  80040c:	fa0cd9e3          	bgez	s9,8003be <vprintfmt+0x1e4>
  800410:	b7c5                	j	8003f0 <vprintfmt+0x216>
            if (err < 0) {
  800412:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800416:	4661                	li	a2,24
            err = va_arg(ap, int);
  800418:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80041a:	41f7d71b          	sraiw	a4,a5,0x1f
  80041e:	8fb9                	xor	a5,a5,a4
  800420:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800424:	02d64563          	blt	a2,a3,80044e <vprintfmt+0x274>
  800428:	00000797          	auipc	a5,0x0
  80042c:	5f078793          	addi	a5,a5,1520 # 800a18 <error_string>
  800430:	00369713          	slli	a4,a3,0x3
  800434:	97ba                	add	a5,a5,a4
  800436:	639c                	ld	a5,0(a5)
  800438:	cb99                	beqz	a5,80044e <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80043a:	86be                	mv	a3,a5
  80043c:	00000617          	auipc	a2,0x0
  800440:	28c60613          	addi	a2,a2,652 # 8006c8 <main+0x188>
  800444:	85ca                	mv	a1,s2
  800446:	8526                	mv	a0,s1
  800448:	0d8000ef          	jal	800520 <printfmt>
  80044c:	b3c9                	j	80020e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80044e:	00000617          	auipc	a2,0x0
  800452:	26a60613          	addi	a2,a2,618 # 8006b8 <main+0x178>
  800456:	85ca                	mv	a1,s2
  800458:	8526                	mv	a0,s1
  80045a:	0c6000ef          	jal	800520 <printfmt>
  80045e:	bb45                	j	80020e <vprintfmt+0x34>
    if (lflag >= 2) {
  800460:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800462:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800466:	00f74363          	blt	a4,a5,80046c <vprintfmt+0x292>
    else if (lflag) {
  80046a:	cf81                	beqz	a5,800482 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80046c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800470:	02044b63          	bltz	s0,8004a6 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800474:	8622                	mv	a2,s0
  800476:	8a5e                	mv	s4,s7
  800478:	46a9                	li	a3,10
  80047a:	b541                	j	8002fa <vprintfmt+0x120>
            lflag ++;
  80047c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80047e:	8462                	mv	s0,s8
            goto reswitch;
  800480:	bb5d                	j	800236 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800482:	000a2403          	lw	s0,0(s4)
  800486:	b7ed                	j	800470 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800488:	000a6603          	lwu	a2,0(s4)
  80048c:	46a1                	li	a3,8
  80048e:	8a2e                	mv	s4,a1
  800490:	b5ad                	j	8002fa <vprintfmt+0x120>
  800492:	000a6603          	lwu	a2,0(s4)
  800496:	46a9                	li	a3,10
  800498:	8a2e                	mv	s4,a1
  80049a:	b585                	j	8002fa <vprintfmt+0x120>
  80049c:	000a6603          	lwu	a2,0(s4)
  8004a0:	46c1                	li	a3,16
  8004a2:	8a2e                	mv	s4,a1
  8004a4:	bd99                	j	8002fa <vprintfmt+0x120>
                putch('-', putdat);
  8004a6:	85ca                	mv	a1,s2
  8004a8:	02d00513          	li	a0,45
  8004ac:	9482                	jalr	s1
                num = -(long long)num;
  8004ae:	40800633          	neg	a2,s0
  8004b2:	8a5e                	mv	s4,s7
  8004b4:	46a9                	li	a3,10
  8004b6:	b591                	j	8002fa <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b8:	e329                	bnez	a4,8004fa <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ba:	02800793          	li	a5,40
  8004be:	853e                	mv	a0,a5
  8004c0:	00000d97          	auipc	s11,0x0
  8004c4:	1f1d8d93          	addi	s11,s11,497 # 8006b1 <main+0x171>
  8004c8:	b5f5                	j	8003b4 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	85e6                	mv	a1,s9
  8004cc:	856e                	mv	a0,s11
  8004ce:	c8bff0ef          	jal	800158 <strnlen>
  8004d2:	40ad0d3b          	subw	s10,s10,a0
  8004d6:	01a05863          	blez	s10,8004e6 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004da:	85ca                	mv	a1,s2
  8004dc:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004e0:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	fe0d1ce3          	bnez	s10,8004da <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e6:	000dc783          	lbu	a5,0(s11)
  8004ea:	0007851b          	sext.w	a0,a5
  8004ee:	ec0792e3          	bnez	a5,8003b2 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004f2:	6a22                	ld	s4,8(sp)
  8004f4:	bb29                	j	80020e <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004f6:	8462                	mv	s0,s8
  8004f8:	bbd9                	j	8002ce <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fa:	85e6                	mv	a1,s9
  8004fc:	00000517          	auipc	a0,0x0
  800500:	1b450513          	addi	a0,a0,436 # 8006b0 <main+0x170>
  800504:	c55ff0ef          	jal	800158 <strnlen>
  800508:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050c:	02800793          	li	a5,40
                p = "(null)";
  800510:	00000d97          	auipc	s11,0x0
  800514:	1a0d8d93          	addi	s11,s11,416 # 8006b0 <main+0x170>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800518:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80051a:	fda040e3          	bgtz	s10,8004da <vprintfmt+0x300>
  80051e:	bd51                	j	8003b2 <vprintfmt+0x1d8>

0000000000800520 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800520:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800522:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800526:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800528:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	ec06                	sd	ra,24(sp)
  80052c:	f83a                	sd	a4,48(sp)
  80052e:	fc3e                	sd	a5,56(sp)
  800530:	e0c2                	sd	a6,64(sp)
  800532:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800534:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800536:	ca5ff0ef          	jal	8001da <vprintfmt>
}
  80053a:	60e2                	ld	ra,24(sp)
  80053c:	6161                	addi	sp,sp,80
  80053e:	8082                	ret

0000000000800540 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800540:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  800542:	00000517          	auipc	a0,0x0
  800546:	24e50513          	addi	a0,a0,590 # 800790 <main+0x250>
main(void) {
  80054a:	ec06                	sd	ra,24(sp)
  80054c:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  80054e:	bcbff0ef          	jal	800118 <cprintf>
    if ((pid = fork()) == 0) {
  800552:	b7dff0ef          	jal	8000ce <fork>
  800556:	c561                	beqz	a0,80061e <main+0xde>
  800558:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  80055a:	85aa                	mv	a1,a0
  80055c:	00000517          	auipc	a0,0x0
  800560:	27450513          	addi	a0,a0,628 # 8007d0 <main+0x290>
  800564:	bb5ff0ef          	jal	800118 <cprintf>
    }
    assert(pid > 0);
  800568:	08805c63          	blez	s0,800600 <main+0xc0>
    cprintf("I am the parent, waiting now..\n");
  80056c:	00000517          	auipc	a0,0x0
  800570:	2bc50513          	addi	a0,a0,700 # 800828 <main+0x2e8>
  800574:	ba5ff0ef          	jal	800118 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  800578:	006c                	addi	a1,sp,12
  80057a:	8522                	mv	a0,s0
  80057c:	b5bff0ef          	jal	8000d6 <waitpid>
  800580:	e131                	bnez	a0,8005c4 <main+0x84>
  800582:	4732                	lw	a4,12(sp)
  800584:	00001797          	auipc	a5,0x1
  800588:	a7c7a783          	lw	a5,-1412(a5) # 801000 <magic>
  80058c:	02f71c63          	bne	a4,a5,8005c4 <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  800590:	006c                	addi	a1,sp,12
  800592:	8522                	mv	a0,s0
  800594:	b43ff0ef          	jal	8000d6 <waitpid>
  800598:	c529                	beqz	a0,8005e2 <main+0xa2>
  80059a:	b37ff0ef          	jal	8000d0 <wait>
  80059e:	c131                	beqz	a0,8005e2 <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);
  8005a0:	85a2                	mv	a1,s0
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	2fe50513          	addi	a0,a0,766 # 8008a0 <main+0x360>
  8005aa:	b6fff0ef          	jal	800118 <cprintf>

    cprintf("exit pass.\n");
  8005ae:	00000517          	auipc	a0,0x0
  8005b2:	30250513          	addi	a0,a0,770 # 8008b0 <main+0x370>
  8005b6:	b63ff0ef          	jal	800118 <cprintf>
    return 0;
}
  8005ba:	60e2                	ld	ra,24(sp)
  8005bc:	6442                	ld	s0,16(sp)
  8005be:	4501                	li	a0,0
  8005c0:	6105                	addi	sp,sp,32
  8005c2:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005c4:	00000697          	auipc	a3,0x0
  8005c8:	28468693          	addi	a3,a3,644 # 800848 <main+0x308>
  8005cc:	00000617          	auipc	a2,0x0
  8005d0:	23460613          	addi	a2,a2,564 # 800800 <main+0x2c0>
  8005d4:	45ed                	li	a1,27
  8005d6:	00000517          	auipc	a0,0x0
  8005da:	24250513          	addi	a0,a0,578 # 800818 <main+0x2d8>
  8005de:	a43ff0ef          	jal	800020 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005e2:	00000697          	auipc	a3,0x0
  8005e6:	29668693          	addi	a3,a3,662 # 800878 <main+0x338>
  8005ea:	00000617          	auipc	a2,0x0
  8005ee:	21660613          	addi	a2,a2,534 # 800800 <main+0x2c0>
  8005f2:	45f1                	li	a1,28
  8005f4:	00000517          	auipc	a0,0x0
  8005f8:	22450513          	addi	a0,a0,548 # 800818 <main+0x2d8>
  8005fc:	a25ff0ef          	jal	800020 <__panic>
    assert(pid > 0);
  800600:	00000697          	auipc	a3,0x0
  800604:	1f868693          	addi	a3,a3,504 # 8007f8 <main+0x2b8>
  800608:	00000617          	auipc	a2,0x0
  80060c:	1f860613          	addi	a2,a2,504 # 800800 <main+0x2c0>
  800610:	45e1                	li	a1,24
  800612:	00000517          	auipc	a0,0x0
  800616:	20650513          	addi	a0,a0,518 # 800818 <main+0x2d8>
  80061a:	a07ff0ef          	jal	800020 <__panic>
        cprintf("I am the child.\n");
  80061e:	00000517          	auipc	a0,0x0
  800622:	19a50513          	addi	a0,a0,410 # 8007b8 <main+0x278>
  800626:	af3ff0ef          	jal	800118 <cprintf>
        yield();
  80062a:	aafff0ef          	jal	8000d8 <yield>
        yield();
  80062e:	aabff0ef          	jal	8000d8 <yield>
        yield();
  800632:	aa7ff0ef          	jal	8000d8 <yield>
        yield();
  800636:	aa3ff0ef          	jal	8000d8 <yield>
        yield();
  80063a:	a9fff0ef          	jal	8000d8 <yield>
        yield();
  80063e:	a9bff0ef          	jal	8000d8 <yield>
        yield();
  800642:	a97ff0ef          	jal	8000d8 <yield>
        exit(magic);
  800646:	00001517          	auipc	a0,0x1
  80064a:	9ba52503          	lw	a0,-1606(a0) # 801000 <magic>
  80064e:	a6bff0ef          	jal	8000b8 <exit>
