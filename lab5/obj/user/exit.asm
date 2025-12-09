
obj/__user_exit.out:     file format elf64-littleriscv


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
  800034:	64850513          	addi	a0,a0,1608 # 800678 <main+0x112>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0d6000ef          	jal	ra,80011a <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0ae000ef          	jal	ra,8000fa <vcprintf>
    cprintf("\n");
  800050:	00001517          	auipc	a0,0x1
  800054:	9d850513          	addi	a0,a0,-1576 # 800a28 <error_string+0x128>
  800058:	0c2000ef          	jal	ra,80011a <cprintf>
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
  8000c4:	5d850513          	addi	a0,a0,1496 # 800698 <main+0x132>
  8000c8:	052000ef          	jal	ra,80011a <cprintf>
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
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000da:	076000ef          	jal	ra,800150 <umain>
1:  j 1b
  8000de:	a001                	j	8000de <_start+0x4>

00000000008000e0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e0:	1141                	addi	sp,sp,-16
  8000e2:	e022                	sd	s0,0(sp)
  8000e4:	e406                	sd	ra,8(sp)
  8000e6:	842e                	mv	s0,a1
    sys_putc(c);
  8000e8:	fcbff0ef          	jal	ra,8000b2 <sys_putc>
    (*cnt) ++;
  8000ec:	401c                	lw	a5,0(s0)
}
  8000ee:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f0:	2785                	addiw	a5,a5,1
  8000f2:	c01c                	sw	a5,0(s0)
}
  8000f4:	6402                	ld	s0,0(sp)
  8000f6:	0141                	addi	sp,sp,16
  8000f8:	8082                	ret

00000000008000fa <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000fa:	1101                	addi	sp,sp,-32
  8000fc:	862a                	mv	a2,a0
  8000fe:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800100:	00000517          	auipc	a0,0x0
  800104:	fe050513          	addi	a0,a0,-32 # 8000e0 <cputch>
  800108:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  80010a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010e:	0d6000ef          	jal	ra,8001e4 <vprintfmt>
    return cnt;
}
  800112:	60e2                	ld	ra,24(sp)
  800114:	4532                	lw	a0,12(sp)
  800116:	6105                	addi	sp,sp,32
  800118:	8082                	ret

000000000080011a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80011a:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800120:	8e2a                	mv	t3,a0
  800122:	f42e                	sd	a1,40(sp)
  800124:	f832                	sd	a2,48(sp)
  800126:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800128:	00000517          	auipc	a0,0x0
  80012c:	fb850513          	addi	a0,a0,-72 # 8000e0 <cputch>
  800130:	004c                	addi	a1,sp,4
  800132:	869a                	mv	a3,t1
  800134:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  800136:	ec06                	sd	ra,24(sp)
  800138:	e0ba                	sd	a4,64(sp)
  80013a:	e4be                	sd	a5,72(sp)
  80013c:	e8c2                	sd	a6,80(sp)
  80013e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800140:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800142:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800144:	0a0000ef          	jal	ra,8001e4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800148:	60e2                	ld	ra,24(sp)
  80014a:	4512                	lw	a0,4(sp)
  80014c:	6125                	addi	sp,sp,96
  80014e:	8082                	ret

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	412000ef          	jal	ra,800566 <main>
    exit(ret);
  800158:	f61ff0ef          	jal	ra,8000b8 <exit>

000000000080015c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80015c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80015e:	e589                	bnez	a1,800168 <strnlen+0xc>
  800160:	a811                	j	800174 <strnlen+0x18>
        cnt ++;
  800162:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800164:	00f58863          	beq	a1,a5,800174 <strnlen+0x18>
  800168:	00f50733          	add	a4,a0,a5
  80016c:	00074703          	lbu	a4,0(a4)
  800170:	fb6d                	bnez	a4,800162 <strnlen+0x6>
  800172:	85be                	mv	a1,a5
    }
    return cnt;
}
  800174:	852e                	mv	a0,a1
  800176:	8082                	ret

0000000000800178 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800178:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80017e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800184:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	f022                	sd	s0,32(sp)
  80018a:	ec26                	sd	s1,24(sp)
  80018c:	e84a                	sd	s2,16(sp)
  80018e:	f406                	sd	ra,40(sp)
  800190:	e44e                	sd	s3,8(sp)
  800192:	84aa                	mv	s1,a0
  800194:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800196:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80019a:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80019c:	03067e63          	bgeu	a2,a6,8001d8 <printnum+0x60>
  8001a0:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a2:	00805763          	blez	s0,8001b0 <printnum+0x38>
  8001a6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a8:	85ca                	mv	a1,s2
  8001aa:	854e                	mv	a0,s3
  8001ac:	9482                	jalr	s1
        while (-- width > 0)
  8001ae:	fc65                	bnez	s0,8001a6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	1a02                	slli	s4,s4,0x20
  8001b2:	00000797          	auipc	a5,0x0
  8001b6:	4fe78793          	addi	a5,a5,1278 # 8006b0 <main+0x14a>
  8001ba:	020a5a13          	srli	s4,s4,0x20
  8001be:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	000a4503          	lbu	a0,0(s4)
}
  8001c6:	70a2                	ld	ra,40(sp)
  8001c8:	69a2                	ld	s3,8(sp)
  8001ca:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	85ca                	mv	a1,s2
  8001ce:	87a6                	mv	a5,s1
}
  8001d0:	6942                	ld	s2,16(sp)
  8001d2:	64e2                	ld	s1,24(sp)
  8001d4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d8:	03065633          	divu	a2,a2,a6
  8001dc:	8722                	mv	a4,s0
  8001de:	f9bff0ef          	jal	ra,800178 <printnum>
  8001e2:	b7f9                	j	8001b0 <printnum+0x38>

00000000008001e4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e4:	7119                	addi	sp,sp,-128
  8001e6:	f4a6                	sd	s1,104(sp)
  8001e8:	f0ca                	sd	s2,96(sp)
  8001ea:	ecce                	sd	s3,88(sp)
  8001ec:	e8d2                	sd	s4,80(sp)
  8001ee:	e4d6                	sd	s5,72(sp)
  8001f0:	e0da                	sd	s6,64(sp)
  8001f2:	fc5e                	sd	s7,56(sp)
  8001f4:	f06a                	sd	s10,32(sp)
  8001f6:	fc86                	sd	ra,120(sp)
  8001f8:	f8a2                	sd	s0,112(sp)
  8001fa:	f862                	sd	s8,48(sp)
  8001fc:	f466                	sd	s9,40(sp)
  8001fe:	ec6e                	sd	s11,24(sp)
  800200:	892a                	mv	s2,a0
  800202:	84ae                	mv	s1,a1
  800204:	8d32                	mv	s10,a2
  800206:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80020c:	5b7d                	li	s6,-1
  80020e:	00000a97          	auipc	s5,0x0
  800212:	4d6a8a93          	addi	s5,s5,1238 # 8006e4 <main+0x17e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800216:	00000b97          	auipc	s7,0x0
  80021a:	6eab8b93          	addi	s7,s7,1770 # 800900 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	000d4503          	lbu	a0,0(s10)
  800222:	001d0413          	addi	s0,s10,1
  800226:	01350a63          	beq	a0,s3,80023a <vprintfmt+0x56>
            if (ch == '\0') {
  80022a:	c121                	beqz	a0,80026a <vprintfmt+0x86>
            putch(ch, putdat);
  80022c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800230:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800232:	fff44503          	lbu	a0,-1(s0)
  800236:	ff351ae3          	bne	a0,s3,80022a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80023a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80023e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800242:	4c81                	li	s9,0
  800244:	4881                	li	a7,0
        width = precision = -1;
  800246:	5c7d                	li	s8,-1
  800248:	5dfd                	li	s11,-1
  80024a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  80024e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800250:	fdd6059b          	addiw	a1,a2,-35
  800254:	0ff5f593          	zext.b	a1,a1
  800258:	00140d13          	addi	s10,s0,1
  80025c:	04b56263          	bltu	a0,a1,8002a0 <vprintfmt+0xbc>
  800260:	058a                	slli	a1,a1,0x2
  800262:	95d6                	add	a1,a1,s5
  800264:	4194                	lw	a3,0(a1)
  800266:	96d6                	add	a3,a3,s5
  800268:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80026a:	70e6                	ld	ra,120(sp)
  80026c:	7446                	ld	s0,112(sp)
  80026e:	74a6                	ld	s1,104(sp)
  800270:	7906                	ld	s2,96(sp)
  800272:	69e6                	ld	s3,88(sp)
  800274:	6a46                	ld	s4,80(sp)
  800276:	6aa6                	ld	s5,72(sp)
  800278:	6b06                	ld	s6,64(sp)
  80027a:	7be2                	ld	s7,56(sp)
  80027c:	7c42                	ld	s8,48(sp)
  80027e:	7ca2                	ld	s9,40(sp)
  800280:	7d02                	ld	s10,32(sp)
  800282:	6de2                	ld	s11,24(sp)
  800284:	6109                	addi	sp,sp,128
  800286:	8082                	ret
            padc = '0';
  800288:	87b2                	mv	a5,a2
            goto reswitch;
  80028a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	846a                	mv	s0,s10
  800290:	00140d13          	addi	s10,s0,1
  800294:	fdd6059b          	addiw	a1,a2,-35
  800298:	0ff5f593          	zext.b	a1,a1
  80029c:	fcb572e3          	bgeu	a0,a1,800260 <vprintfmt+0x7c>
            putch('%', putdat);
  8002a0:	85a6                	mv	a1,s1
  8002a2:	02500513          	li	a0,37
  8002a6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002a8:	fff44783          	lbu	a5,-1(s0)
  8002ac:	8d22                	mv	s10,s0
  8002ae:	f73788e3          	beq	a5,s3,80021e <vprintfmt+0x3a>
  8002b2:	ffed4783          	lbu	a5,-2(s10)
  8002b6:	1d7d                	addi	s10,s10,-1
  8002b8:	ff379de3          	bne	a5,s3,8002b2 <vprintfmt+0xce>
  8002bc:	b78d                	j	80021e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002be:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002c2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002c8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002cc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d0:	02d86463          	bltu	a6,a3,8002f8 <vprintfmt+0x114>
                ch = *fmt;
  8002d4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002d8:	002c169b          	slliw	a3,s8,0x2
  8002dc:	0186873b          	addw	a4,a3,s8
  8002e0:	0017171b          	slliw	a4,a4,0x1
  8002e4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002e6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002ea:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ec:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002f0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002f4:	fed870e3          	bgeu	a6,a3,8002d4 <vprintfmt+0xf0>
            if (width < 0)
  8002f8:	f40ddce3          	bgez	s11,800250 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002fc:	8de2                	mv	s11,s8
  8002fe:	5c7d                	li	s8,-1
  800300:	bf81                	j	800250 <vprintfmt+0x6c>
            if (width < 0)
  800302:	fffdc693          	not	a3,s11
  800306:	96fd                	srai	a3,a3,0x3f
  800308:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80030c:	00144603          	lbu	a2,1(s0)
  800310:	2d81                	sext.w	s11,s11
  800312:	846a                	mv	s0,s10
            goto reswitch;
  800314:	bf35                	j	800250 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800316:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80031a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80031e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800320:	846a                	mv	s0,s10
            goto process_precision;
  800322:	bfd9                	j	8002f8 <vprintfmt+0x114>
    if (lflag >= 2) {
  800324:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800326:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032a:	01174463          	blt	a4,a7,800332 <vprintfmt+0x14e>
    else if (lflag) {
  80032e:	1a088e63          	beqz	a7,8004ea <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800332:	000a3603          	ld	a2,0(s4)
  800336:	46c1                	li	a3,16
  800338:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80033a:	2781                	sext.w	a5,a5
  80033c:	876e                	mv	a4,s11
  80033e:	85a6                	mv	a1,s1
  800340:	854a                	mv	a0,s2
  800342:	e37ff0ef          	jal	ra,800178 <printnum>
            break;
  800346:	bde1                	j	80021e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800348:	000a2503          	lw	a0,0(s4)
  80034c:	85a6                	mv	a1,s1
  80034e:	0a21                	addi	s4,s4,8
  800350:	9902                	jalr	s2
            break;
  800352:	b5f1                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  800354:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800356:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80035a:	01174463          	blt	a4,a7,800362 <vprintfmt+0x17e>
    else if (lflag) {
  80035e:	18088163          	beqz	a7,8004e0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800362:	000a3603          	ld	a2,0(s4)
  800366:	46a9                	li	a3,10
  800368:	8a2e                	mv	s4,a1
  80036a:	bfc1                	j	80033a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800370:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800372:	846a                	mv	s0,s10
            goto reswitch;
  800374:	bdf1                	j	800250 <vprintfmt+0x6c>
            putch(ch, putdat);
  800376:	85a6                	mv	a1,s1
  800378:	02500513          	li	a0,37
  80037c:	9902                	jalr	s2
            break;
  80037e:	b545                	j	80021e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800380:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800384:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800386:	846a                	mv	s0,s10
            goto reswitch;
  800388:	b5e1                	j	800250 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80038a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80038c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800390:	01174463          	blt	a4,a7,800398 <vprintfmt+0x1b4>
    else if (lflag) {
  800394:	14088163          	beqz	a7,8004d6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800398:	000a3603          	ld	a2,0(s4)
  80039c:	46a1                	li	a3,8
  80039e:	8a2e                	mv	s4,a1
  8003a0:	bf69                	j	80033a <vprintfmt+0x156>
            putch('0', putdat);
  8003a2:	03000513          	li	a0,48
  8003a6:	85a6                	mv	a1,s1
  8003a8:	e03e                	sd	a5,0(sp)
  8003aa:	9902                	jalr	s2
            putch('x', putdat);
  8003ac:	85a6                	mv	a1,s1
  8003ae:	07800513          	li	a0,120
  8003b2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003b4:	0a21                	addi	s4,s4,8
            goto number;
  8003b6:	6782                	ld	a5,0(sp)
  8003b8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ba:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003be:	bfb5                	j	80033a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c0:	000a3403          	ld	s0,0(s4)
  8003c4:	008a0713          	addi	a4,s4,8
  8003c8:	e03a                	sd	a4,0(sp)
  8003ca:	14040263          	beqz	s0,80050e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003ce:	0fb05763          	blez	s11,8004bc <vprintfmt+0x2d8>
  8003d2:	02d00693          	li	a3,45
  8003d6:	0cd79163          	bne	a5,a3,800498 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003da:	00044783          	lbu	a5,0(s0)
  8003de:	0007851b          	sext.w	a0,a5
  8003e2:	cf85                	beqz	a5,80041a <vprintfmt+0x236>
  8003e4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ec:	000c4563          	bltz	s8,8003f6 <vprintfmt+0x212>
  8003f0:	3c7d                	addiw	s8,s8,-1
  8003f2:	036c0263          	beq	s8,s6,800416 <vprintfmt+0x232>
                    putch('?', putdat);
  8003f6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f8:	0e0c8e63          	beqz	s9,8004f4 <vprintfmt+0x310>
  8003fc:	3781                	addiw	a5,a5,-32
  8003fe:	0ef47b63          	bgeu	s0,a5,8004f4 <vprintfmt+0x310>
                    putch('?', putdat);
  800402:	03f00513          	li	a0,63
  800406:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800408:	000a4783          	lbu	a5,0(s4)
  80040c:	3dfd                	addiw	s11,s11,-1
  80040e:	0a05                	addi	s4,s4,1
  800410:	0007851b          	sext.w	a0,a5
  800414:	ffe1                	bnez	a5,8003ec <vprintfmt+0x208>
            for (; width > 0; width --) {
  800416:	01b05963          	blez	s11,800428 <vprintfmt+0x244>
  80041a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80041c:	85a6                	mv	a1,s1
  80041e:	02000513          	li	a0,32
  800422:	9902                	jalr	s2
            for (; width > 0; width --) {
  800424:	fe0d9be3          	bnez	s11,80041a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800428:	6a02                	ld	s4,0(sp)
  80042a:	bbd5                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80042c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80042e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800432:	01174463          	blt	a4,a7,80043a <vprintfmt+0x256>
    else if (lflag) {
  800436:	08088d63          	beqz	a7,8004d0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80043a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80043e:	0a044d63          	bltz	s0,8004f8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800442:	8622                	mv	a2,s0
  800444:	8a66                	mv	s4,s9
  800446:	46a9                	li	a3,10
  800448:	bdcd                	j	80033a <vprintfmt+0x156>
            err = va_arg(ap, int);
  80044a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80044e:	4761                	li	a4,24
            err = va_arg(ap, int);
  800450:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800452:	41f7d69b          	sraiw	a3,a5,0x1f
  800456:	8fb5                	xor	a5,a5,a3
  800458:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80045c:	02d74163          	blt	a4,a3,80047e <vprintfmt+0x29a>
  800460:	00369793          	slli	a5,a3,0x3
  800464:	97de                	add	a5,a5,s7
  800466:	639c                	ld	a5,0(a5)
  800468:	cb99                	beqz	a5,80047e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80046a:	86be                	mv	a3,a5
  80046c:	00000617          	auipc	a2,0x0
  800470:	27460613          	addi	a2,a2,628 # 8006e0 <main+0x17a>
  800474:	85a6                	mv	a1,s1
  800476:	854a                	mv	a0,s2
  800478:	0ce000ef          	jal	ra,800546 <printfmt>
  80047c:	b34d                	j	80021e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80047e:	00000617          	auipc	a2,0x0
  800482:	25260613          	addi	a2,a2,594 # 8006d0 <main+0x16a>
  800486:	85a6                	mv	a1,s1
  800488:	854a                	mv	a0,s2
  80048a:	0bc000ef          	jal	ra,800546 <printfmt>
  80048e:	bb41                	j	80021e <vprintfmt+0x3a>
                p = "(null)";
  800490:	00000417          	auipc	s0,0x0
  800494:	23840413          	addi	s0,s0,568 # 8006c8 <main+0x162>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800498:	85e2                	mv	a1,s8
  80049a:	8522                	mv	a0,s0
  80049c:	e43e                	sd	a5,8(sp)
  80049e:	cbfff0ef          	jal	ra,80015c <strnlen>
  8004a2:	40ad8dbb          	subw	s11,s11,a0
  8004a6:	01b05b63          	blez	s11,8004bc <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004aa:	67a2                	ld	a5,8(sp)
  8004ac:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004b2:	85a6                	mv	a1,s1
  8004b4:	8552                	mv	a0,s4
  8004b6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	fe0d9ce3          	bnez	s11,8004b0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004bc:	00044783          	lbu	a5,0(s0)
  8004c0:	00140a13          	addi	s4,s0,1
  8004c4:	0007851b          	sext.w	a0,a5
  8004c8:	d3a5                	beqz	a5,800428 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ca:	05e00413          	li	s0,94
  8004ce:	bf39                	j	8003ec <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004d0:	000a2403          	lw	s0,0(s4)
  8004d4:	b7ad                	j	80043e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004d6:	000a6603          	lwu	a2,0(s4)
  8004da:	46a1                	li	a3,8
  8004dc:	8a2e                	mv	s4,a1
  8004de:	bdb1                	j	80033a <vprintfmt+0x156>
  8004e0:	000a6603          	lwu	a2,0(s4)
  8004e4:	46a9                	li	a3,10
  8004e6:	8a2e                	mv	s4,a1
  8004e8:	bd89                	j	80033a <vprintfmt+0x156>
  8004ea:	000a6603          	lwu	a2,0(s4)
  8004ee:	46c1                	li	a3,16
  8004f0:	8a2e                	mv	s4,a1
  8004f2:	b5a1                	j	80033a <vprintfmt+0x156>
                    putch(ch, putdat);
  8004f4:	9902                	jalr	s2
  8004f6:	bf09                	j	800408 <vprintfmt+0x224>
                putch('-', putdat);
  8004f8:	85a6                	mv	a1,s1
  8004fa:	02d00513          	li	a0,45
  8004fe:	e03e                	sd	a5,0(sp)
  800500:	9902                	jalr	s2
                num = -(long long)num;
  800502:	6782                	ld	a5,0(sp)
  800504:	8a66                	mv	s4,s9
  800506:	40800633          	neg	a2,s0
  80050a:	46a9                	li	a3,10
  80050c:	b53d                	j	80033a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  80050e:	03b05163          	blez	s11,800530 <vprintfmt+0x34c>
  800512:	02d00693          	li	a3,45
  800516:	f6d79de3          	bne	a5,a3,800490 <vprintfmt+0x2ac>
                p = "(null)";
  80051a:	00000417          	auipc	s0,0x0
  80051e:	1ae40413          	addi	s0,s0,430 # 8006c8 <main+0x162>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800522:	02800793          	li	a5,40
  800526:	02800513          	li	a0,40
  80052a:	00140a13          	addi	s4,s0,1
  80052e:	bd6d                	j	8003e8 <vprintfmt+0x204>
  800530:	00000a17          	auipc	s4,0x0
  800534:	199a0a13          	addi	s4,s4,409 # 8006c9 <main+0x163>
  800538:	02800513          	li	a0,40
  80053c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800540:	05e00413          	li	s0,94
  800544:	b565                	j	8003ec <vprintfmt+0x208>

0000000000800546 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800546:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800548:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800550:	ec06                	sd	ra,24(sp)
  800552:	f83a                	sd	a4,48(sp)
  800554:	fc3e                	sd	a5,56(sp)
  800556:	e0c2                	sd	a6,64(sp)
  800558:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80055a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055c:	c89ff0ef          	jal	ra,8001e4 <vprintfmt>
}
  800560:	60e2                	ld	ra,24(sp)
  800562:	6161                	addi	sp,sp,80
  800564:	8082                	ret

0000000000800566 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800566:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  800568:	00000517          	auipc	a0,0x0
  80056c:	46050513          	addi	a0,a0,1120 # 8009c8 <error_string+0xc8>
main(void) {
  800570:	ec06                	sd	ra,24(sp)
  800572:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800574:	ba7ff0ef          	jal	ra,80011a <cprintf>
    if ((pid = fork()) == 0) {
  800578:	b57ff0ef          	jal	ra,8000ce <fork>
  80057c:	c561                	beqz	a0,800644 <main+0xde>
  80057e:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  800580:	85aa                	mv	a1,a0
  800582:	00000517          	auipc	a0,0x0
  800586:	48650513          	addi	a0,a0,1158 # 800a08 <error_string+0x108>
  80058a:	b91ff0ef          	jal	ra,80011a <cprintf>
    }
    assert(pid > 0);
  80058e:	08805c63          	blez	s0,800626 <main+0xc0>
    cprintf("I am the parent, waiting now..\n");
  800592:	00000517          	auipc	a0,0x0
  800596:	4ce50513          	addi	a0,a0,1230 # 800a60 <error_string+0x160>
  80059a:	b81ff0ef          	jal	ra,80011a <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  80059e:	006c                	addi	a1,sp,12
  8005a0:	8522                	mv	a0,s0
  8005a2:	b35ff0ef          	jal	ra,8000d6 <waitpid>
  8005a6:	e131                	bnez	a0,8005ea <main+0x84>
  8005a8:	4732                	lw	a4,12(sp)
  8005aa:	00001797          	auipc	a5,0x1
  8005ae:	a567a783          	lw	a5,-1450(a5) # 801000 <magic>
  8005b2:	02f71c63          	bne	a4,a5,8005ea <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005b6:	006c                	addi	a1,sp,12
  8005b8:	8522                	mv	a0,s0
  8005ba:	b1dff0ef          	jal	ra,8000d6 <waitpid>
  8005be:	c529                	beqz	a0,800608 <main+0xa2>
  8005c0:	b11ff0ef          	jal	ra,8000d0 <wait>
  8005c4:	c131                	beqz	a0,800608 <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);
  8005c6:	85a2                	mv	a1,s0
  8005c8:	00000517          	auipc	a0,0x0
  8005cc:	51050513          	addi	a0,a0,1296 # 800ad8 <error_string+0x1d8>
  8005d0:	b4bff0ef          	jal	ra,80011a <cprintf>

    cprintf("exit pass.\n");
  8005d4:	00000517          	auipc	a0,0x0
  8005d8:	51450513          	addi	a0,a0,1300 # 800ae8 <error_string+0x1e8>
  8005dc:	b3fff0ef          	jal	ra,80011a <cprintf>
    return 0;
}
  8005e0:	60e2                	ld	ra,24(sp)
  8005e2:	6442                	ld	s0,16(sp)
  8005e4:	4501                	li	a0,0
  8005e6:	6105                	addi	sp,sp,32
  8005e8:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005ea:	00000697          	auipc	a3,0x0
  8005ee:	49668693          	addi	a3,a3,1174 # 800a80 <error_string+0x180>
  8005f2:	00000617          	auipc	a2,0x0
  8005f6:	44660613          	addi	a2,a2,1094 # 800a38 <error_string+0x138>
  8005fa:	45ed                	li	a1,27
  8005fc:	00000517          	auipc	a0,0x0
  800600:	45450513          	addi	a0,a0,1108 # 800a50 <error_string+0x150>
  800604:	a1dff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  800608:	00000697          	auipc	a3,0x0
  80060c:	4a868693          	addi	a3,a3,1192 # 800ab0 <error_string+0x1b0>
  800610:	00000617          	auipc	a2,0x0
  800614:	42860613          	addi	a2,a2,1064 # 800a38 <error_string+0x138>
  800618:	45f1                	li	a1,28
  80061a:	00000517          	auipc	a0,0x0
  80061e:	43650513          	addi	a0,a0,1078 # 800a50 <error_string+0x150>
  800622:	9ffff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  800626:	00000697          	auipc	a3,0x0
  80062a:	40a68693          	addi	a3,a3,1034 # 800a30 <error_string+0x130>
  80062e:	00000617          	auipc	a2,0x0
  800632:	40a60613          	addi	a2,a2,1034 # 800a38 <error_string+0x138>
  800636:	45e1                	li	a1,24
  800638:	00000517          	auipc	a0,0x0
  80063c:	41850513          	addi	a0,a0,1048 # 800a50 <error_string+0x150>
  800640:	9e1ff0ef          	jal	ra,800020 <__panic>
        cprintf("I am the child.\n");
  800644:	00000517          	auipc	a0,0x0
  800648:	3ac50513          	addi	a0,a0,940 # 8009f0 <error_string+0xf0>
  80064c:	acfff0ef          	jal	ra,80011a <cprintf>
        yield();
  800650:	a89ff0ef          	jal	ra,8000d8 <yield>
        yield();
  800654:	a85ff0ef          	jal	ra,8000d8 <yield>
        yield();
  800658:	a81ff0ef          	jal	ra,8000d8 <yield>
        yield();
  80065c:	a7dff0ef          	jal	ra,8000d8 <yield>
        yield();
  800660:	a79ff0ef          	jal	ra,8000d8 <yield>
        yield();
  800664:	a75ff0ef          	jal	ra,8000d8 <yield>
        yield();
  800668:	a71ff0ef          	jal	ra,8000d8 <yield>
        exit(magic);
  80066c:	00001517          	auipc	a0,0x1
  800670:	99452503          	lw	a0,-1644(a0) # 801000 <magic>
  800674:	a45ff0ef          	jal	ra,8000b8 <exit>
