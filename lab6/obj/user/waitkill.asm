
obj/__user_waitkill.out:     file format elf64-littleriscv


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
  800034:	67050513          	addi	a0,a0,1648 # 8006a0 <main+0xac>
__panic(const char *file, int line, const char *fmt, ...) {
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800042:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800044:	0dc000ef          	jal	ra,800120 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b4000ef          	jal	ra,800100 <vcprintf>
    cprintf("\n");
  800050:	00001517          	auipc	a0,0x1
  800054:	9a850513          	addi	a0,a0,-1624 # 8009f8 <error_string+0xd0>
  800058:	0c8000ef          	jal	ra,800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	062000ef          	jal	ra,8000c0 <exit>

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

00000000008000a0 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000a0:	4509                	li	a0,2
  8000a2:	b7c1                	j	800062 <syscall>

00000000008000a4 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  8000a4:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  8000a6:	85aa                	mv	a1,a0
  8000a8:	450d                	li	a0,3
  8000aa:	bf65                	j	800062 <syscall>

00000000008000ac <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ac:	4529                	li	a0,10
  8000ae:	bf55                	j	800062 <syscall>

00000000008000b0 <sys_kill>:
}

int
sys_kill(int64_t pid) {
  8000b0:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  8000b2:	4531                	li	a0,12
  8000b4:	b77d                	j	800062 <syscall>

00000000008000b6 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b6:	4549                	li	a0,18
  8000b8:	b76d                	j	800062 <syscall>

00000000008000ba <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000ba:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000bc:	4579                	li	a0,30
  8000be:	b755                	j	800062 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fd7ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	5f850513          	addi	a0,a0,1528 # 8006c0 <main+0xcc>
  8000d0:	050000ef          	jal	ra,800120 <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d6:	b7e9                	j	8000a0 <sys_fork>

00000000008000d8 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000d8:	b7f1                	j	8000a4 <sys_wait>

00000000008000da <yield>:
}

void
yield(void) {
    sys_yield();
  8000da:	bfc9                	j	8000ac <sys_yield>

00000000008000dc <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000dc:	bfd1                	j	8000b0 <sys_kill>

00000000008000de <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000de:	bfe1                	j	8000b6 <sys_getpid>

00000000008000e0 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000e0:	076000ef          	jal	ra,800156 <umain>
1:  j 1b
  8000e4:	a001                	j	8000e4 <_start+0x4>

00000000008000e6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e6:	1141                	addi	sp,sp,-16
  8000e8:	e022                	sd	s0,0(sp)
  8000ea:	e406                	sd	ra,8(sp)
  8000ec:	842e                	mv	s0,a1
    sys_putc(c);
  8000ee:	fcdff0ef          	jal	ra,8000ba <sys_putc>
    (*cnt) ++;
  8000f2:	401c                	lw	a5,0(s0)
}
  8000f4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f6:	2785                	addiw	a5,a5,1
  8000f8:	c01c                	sw	a5,0(s0)
}
  8000fa:	6402                	ld	s0,0(sp)
  8000fc:	0141                	addi	sp,sp,16
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
  80010a:	fe050513          	addi	a0,a0,-32 # 8000e6 <cputch>
  80010e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800110:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800112:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800114:	0d6000ef          	jal	ra,8001ea <vprintfmt>
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
  800126:	8e2a                	mv	t3,a0
  800128:	f42e                	sd	a1,40(sp)
  80012a:	f832                	sd	a2,48(sp)
  80012c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012e:	00000517          	auipc	a0,0x0
  800132:	fb850513          	addi	a0,a0,-72 # 8000e6 <cputch>
  800136:	004c                	addi	a1,sp,4
  800138:	869a                	mv	a3,t1
  80013a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80013c:	ec06                	sd	ra,24(sp)
  80013e:	e0ba                	sd	a4,64(sp)
  800140:	e4be                	sd	a5,72(sp)
  800142:	e8c2                	sd	a6,80(sp)
  800144:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800146:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800148:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80014a:	0a0000ef          	jal	ra,8001ea <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014e:	60e2                	ld	ra,24(sp)
  800150:	4512                	lw	a0,4(sp)
  800152:	6125                	addi	sp,sp,96
  800154:	8082                	ret

0000000000800156 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800156:	1141                	addi	sp,sp,-16
  800158:	e406                	sd	ra,8(sp)
    int ret = main();
  80015a:	49a000ef          	jal	ra,8005f4 <main>
    exit(ret);
  80015e:	f63ff0ef          	jal	ra,8000c0 <exit>

0000000000800162 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800162:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800164:	e589                	bnez	a1,80016e <strnlen+0xc>
  800166:	a811                	j	80017a <strnlen+0x18>
        cnt ++;
  800168:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80016a:	00f58863          	beq	a1,a5,80017a <strnlen+0x18>
  80016e:	00f50733          	add	a4,a0,a5
  800172:	00074703          	lbu	a4,0(a4)
  800176:	fb6d                	bnez	a4,800168 <strnlen+0x6>
  800178:	85be                	mv	a1,a5
    }
    return cnt;
}
  80017a:	852e                	mv	a0,a1
  80017c:	8082                	ret

000000000080017e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800184:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80018e:	f022                	sd	s0,32(sp)
  800190:	ec26                	sd	s1,24(sp)
  800192:	e84a                	sd	s2,16(sp)
  800194:	f406                	sd	ra,40(sp)
  800196:	e44e                	sd	s3,8(sp)
  800198:	84aa                	mv	s1,a0
  80019a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80019c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a0:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8001a2:	03067e63          	bgeu	a2,a6,8001de <printnum+0x60>
  8001a6:	89be                	mv	s3,a5
        while (-- width > 0)
  8001a8:	00805763          	blez	s0,8001b6 <printnum+0x38>
  8001ac:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	854e                	mv	a0,s3
  8001b2:	9482                	jalr	s1
        while (-- width > 0)
  8001b4:	fc65                	bnez	s0,8001ac <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	1a02                	slli	s4,s4,0x20
  8001b8:	00000797          	auipc	a5,0x0
  8001bc:	52078793          	addi	a5,a5,1312 # 8006d8 <main+0xe4>
  8001c0:	020a5a13          	srli	s4,s4,0x20
  8001c4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c8:	000a4503          	lbu	a0,0(s4)
}
  8001cc:	70a2                	ld	ra,40(sp)
  8001ce:	69a2                	ld	s3,8(sp)
  8001d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d2:	85ca                	mv	a1,s2
  8001d4:	87a6                	mv	a5,s1
}
  8001d6:	6942                	ld	s2,16(sp)
  8001d8:	64e2                	ld	s1,24(sp)
  8001da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001dc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001de:	03065633          	divu	a2,a2,a6
  8001e2:	8722                	mv	a4,s0
  8001e4:	f9bff0ef          	jal	ra,80017e <printnum>
  8001e8:	b7f9                	j	8001b6 <printnum+0x38>

00000000008001ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ea:	7119                	addi	sp,sp,-128
  8001ec:	f4a6                	sd	s1,104(sp)
  8001ee:	f0ca                	sd	s2,96(sp)
  8001f0:	ecce                	sd	s3,88(sp)
  8001f2:	e8d2                	sd	s4,80(sp)
  8001f4:	e4d6                	sd	s5,72(sp)
  8001f6:	e0da                	sd	s6,64(sp)
  8001f8:	fc5e                	sd	s7,56(sp)
  8001fa:	f06a                	sd	s10,32(sp)
  8001fc:	fc86                	sd	ra,120(sp)
  8001fe:	f8a2                	sd	s0,112(sp)
  800200:	f862                	sd	s8,48(sp)
  800202:	f466                	sd	s9,40(sp)
  800204:	ec6e                	sd	s11,24(sp)
  800206:	892a                	mv	s2,a0
  800208:	84ae                	mv	s1,a1
  80020a:	8d32                	mv	s10,a2
  80020c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800212:	5b7d                	li	s6,-1
  800214:	00000a97          	auipc	s5,0x0
  800218:	4f8a8a93          	addi	s5,s5,1272 # 80070c <main+0x118>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80021c:	00000b97          	auipc	s7,0x0
  800220:	70cb8b93          	addi	s7,s7,1804 # 800928 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	000d4503          	lbu	a0,0(s10)
  800228:	001d0413          	addi	s0,s10,1
  80022c:	01350a63          	beq	a0,s3,800240 <vprintfmt+0x56>
            if (ch == '\0') {
  800230:	c121                	beqz	a0,800270 <vprintfmt+0x86>
            putch(ch, putdat);
  800232:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800234:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800236:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800238:	fff44503          	lbu	a0,-1(s0)
  80023c:	ff351ae3          	bne	a0,s3,800230 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800244:	02000793          	li	a5,32
        lflag = altflag = 0;
  800248:	4c81                	li	s9,0
  80024a:	4881                	li	a7,0
        width = precision = -1;
  80024c:	5c7d                	li	s8,-1
  80024e:	5dfd                	li	s11,-1
  800250:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800254:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	fdd6059b          	addiw	a1,a2,-35
  80025a:	0ff5f593          	zext.b	a1,a1
  80025e:	00140d13          	addi	s10,s0,1
  800262:	04b56263          	bltu	a0,a1,8002a6 <vprintfmt+0xbc>
  800266:	058a                	slli	a1,a1,0x2
  800268:	95d6                	add	a1,a1,s5
  80026a:	4194                	lw	a3,0(a1)
  80026c:	96d6                	add	a3,a3,s5
  80026e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800270:	70e6                	ld	ra,120(sp)
  800272:	7446                	ld	s0,112(sp)
  800274:	74a6                	ld	s1,104(sp)
  800276:	7906                	ld	s2,96(sp)
  800278:	69e6                	ld	s3,88(sp)
  80027a:	6a46                	ld	s4,80(sp)
  80027c:	6aa6                	ld	s5,72(sp)
  80027e:	6b06                	ld	s6,64(sp)
  800280:	7be2                	ld	s7,56(sp)
  800282:	7c42                	ld	s8,48(sp)
  800284:	7ca2                	ld	s9,40(sp)
  800286:	7d02                	ld	s10,32(sp)
  800288:	6de2                	ld	s11,24(sp)
  80028a:	6109                	addi	sp,sp,128
  80028c:	8082                	ret
            padc = '0';
  80028e:	87b2                	mv	a5,a2
            goto reswitch;
  800290:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800294:	846a                	mv	s0,s10
  800296:	00140d13          	addi	s10,s0,1
  80029a:	fdd6059b          	addiw	a1,a2,-35
  80029e:	0ff5f593          	zext.b	a1,a1
  8002a2:	fcb572e3          	bgeu	a0,a1,800266 <vprintfmt+0x7c>
            putch('%', putdat);
  8002a6:	85a6                	mv	a1,s1
  8002a8:	02500513          	li	a0,37
  8002ac:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8002ae:	fff44783          	lbu	a5,-1(s0)
  8002b2:	8d22                	mv	s10,s0
  8002b4:	f73788e3          	beq	a5,s3,800224 <vprintfmt+0x3a>
  8002b8:	ffed4783          	lbu	a5,-2(s10)
  8002bc:	1d7d                	addi	s10,s10,-1
  8002be:	ff379de3          	bne	a5,s3,8002b8 <vprintfmt+0xce>
  8002c2:	b78d                	j	800224 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002c4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002c8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002cc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ce:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d6:	02d86463          	bltu	a6,a3,8002fe <vprintfmt+0x114>
                ch = *fmt;
  8002da:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002de:	002c169b          	slliw	a3,s8,0x2
  8002e2:	0186873b          	addw	a4,a3,s8
  8002e6:	0017171b          	slliw	a4,a4,0x1
  8002ea:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ec:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002f0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002f2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002f6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002fa:	fed870e3          	bgeu	a6,a3,8002da <vprintfmt+0xf0>
            if (width < 0)
  8002fe:	f40ddce3          	bgez	s11,800256 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800302:	8de2                	mv	s11,s8
  800304:	5c7d                	li	s8,-1
  800306:	bf81                	j	800256 <vprintfmt+0x6c>
            if (width < 0)
  800308:	fffdc693          	not	a3,s11
  80030c:	96fd                	srai	a3,a3,0x3f
  80030e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	00144603          	lbu	a2,1(s0)
  800316:	2d81                	sext.w	s11,s11
  800318:	846a                	mv	s0,s10
            goto reswitch;
  80031a:	bf35                	j	800256 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80031c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800320:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800324:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800326:	846a                	mv	s0,s10
            goto process_precision;
  800328:	bfd9                	j	8002fe <vprintfmt+0x114>
    if (lflag >= 2) {
  80032a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80032c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800330:	01174463          	blt	a4,a7,800338 <vprintfmt+0x14e>
    else if (lflag) {
  800334:	1a088e63          	beqz	a7,8004f0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800338:	000a3603          	ld	a2,0(s4)
  80033c:	46c1                	li	a3,16
  80033e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800340:	2781                	sext.w	a5,a5
  800342:	876e                	mv	a4,s11
  800344:	85a6                	mv	a1,s1
  800346:	854a                	mv	a0,s2
  800348:	e37ff0ef          	jal	ra,80017e <printnum>
            break;
  80034c:	bde1                	j	800224 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80034e:	000a2503          	lw	a0,0(s4)
  800352:	85a6                	mv	a1,s1
  800354:	0a21                	addi	s4,s4,8
  800356:	9902                	jalr	s2
            break;
  800358:	b5f1                	j	800224 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80035a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80035c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800360:	01174463          	blt	a4,a7,800368 <vprintfmt+0x17e>
    else if (lflag) {
  800364:	18088163          	beqz	a7,8004e6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800368:	000a3603          	ld	a2,0(s4)
  80036c:	46a9                	li	a3,10
  80036e:	8a2e                	mv	s4,a1
  800370:	bfc1                	j	800340 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800372:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800376:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800378:	846a                	mv	s0,s10
            goto reswitch;
  80037a:	bdf1                	j	800256 <vprintfmt+0x6c>
            putch(ch, putdat);
  80037c:	85a6                	mv	a1,s1
  80037e:	02500513          	li	a0,37
  800382:	9902                	jalr	s2
            break;
  800384:	b545                	j	800224 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800386:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80038a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80038c:	846a                	mv	s0,s10
            goto reswitch;
  80038e:	b5e1                	j	800256 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800390:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800392:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800396:	01174463          	blt	a4,a7,80039e <vprintfmt+0x1b4>
    else if (lflag) {
  80039a:	14088163          	beqz	a7,8004dc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80039e:	000a3603          	ld	a2,0(s4)
  8003a2:	46a1                	li	a3,8
  8003a4:	8a2e                	mv	s4,a1
  8003a6:	bf69                	j	800340 <vprintfmt+0x156>
            putch('0', putdat);
  8003a8:	03000513          	li	a0,48
  8003ac:	85a6                	mv	a1,s1
  8003ae:	e03e                	sd	a5,0(sp)
  8003b0:	9902                	jalr	s2
            putch('x', putdat);
  8003b2:	85a6                	mv	a1,s1
  8003b4:	07800513          	li	a0,120
  8003b8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003ba:	0a21                	addi	s4,s4,8
            goto number;
  8003bc:	6782                	ld	a5,0(sp)
  8003be:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003c0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003c4:	bfb5                	j	800340 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c6:	000a3403          	ld	s0,0(s4)
  8003ca:	008a0713          	addi	a4,s4,8
  8003ce:	e03a                	sd	a4,0(sp)
  8003d0:	14040263          	beqz	s0,800514 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003d4:	0fb05763          	blez	s11,8004c2 <vprintfmt+0x2d8>
  8003d8:	02d00693          	li	a3,45
  8003dc:	0cd79163          	bne	a5,a3,80049e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e0:	00044783          	lbu	a5,0(s0)
  8003e4:	0007851b          	sext.w	a0,a5
  8003e8:	cf85                	beqz	a5,800420 <vprintfmt+0x236>
  8003ea:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ee:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f2:	000c4563          	bltz	s8,8003fc <vprintfmt+0x212>
  8003f6:	3c7d                	addiw	s8,s8,-1
  8003f8:	036c0263          	beq	s8,s6,80041c <vprintfmt+0x232>
                    putch('?', putdat);
  8003fc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003fe:	0e0c8e63          	beqz	s9,8004fa <vprintfmt+0x310>
  800402:	3781                	addiw	a5,a5,-32
  800404:	0ef47b63          	bgeu	s0,a5,8004fa <vprintfmt+0x310>
                    putch('?', putdat);
  800408:	03f00513          	li	a0,63
  80040c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80040e:	000a4783          	lbu	a5,0(s4)
  800412:	3dfd                	addiw	s11,s11,-1
  800414:	0a05                	addi	s4,s4,1
  800416:	0007851b          	sext.w	a0,a5
  80041a:	ffe1                	bnez	a5,8003f2 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80041c:	01b05963          	blez	s11,80042e <vprintfmt+0x244>
  800420:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800422:	85a6                	mv	a1,s1
  800424:	02000513          	li	a0,32
  800428:	9902                	jalr	s2
            for (; width > 0; width --) {
  80042a:	fe0d9be3          	bnez	s11,800420 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80042e:	6a02                	ld	s4,0(sp)
  800430:	bbd5                	j	800224 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800432:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800434:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800438:	01174463          	blt	a4,a7,800440 <vprintfmt+0x256>
    else if (lflag) {
  80043c:	08088d63          	beqz	a7,8004d6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800440:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800444:	0a044d63          	bltz	s0,8004fe <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800448:	8622                	mv	a2,s0
  80044a:	8a66                	mv	s4,s9
  80044c:	46a9                	li	a3,10
  80044e:	bdcd                	j	800340 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800450:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800454:	4761                	li	a4,24
            err = va_arg(ap, int);
  800456:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800458:	41f7d69b          	sraiw	a3,a5,0x1f
  80045c:	8fb5                	xor	a5,a5,a3
  80045e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800462:	02d74163          	blt	a4,a3,800484 <vprintfmt+0x29a>
  800466:	00369793          	slli	a5,a3,0x3
  80046a:	97de                	add	a5,a5,s7
  80046c:	639c                	ld	a5,0(a5)
  80046e:	cb99                	beqz	a5,800484 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800470:	86be                	mv	a3,a5
  800472:	00000617          	auipc	a2,0x0
  800476:	29660613          	addi	a2,a2,662 # 800708 <main+0x114>
  80047a:	85a6                	mv	a1,s1
  80047c:	854a                	mv	a0,s2
  80047e:	0ce000ef          	jal	ra,80054c <printfmt>
  800482:	b34d                	j	800224 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800484:	00000617          	auipc	a2,0x0
  800488:	27460613          	addi	a2,a2,628 # 8006f8 <main+0x104>
  80048c:	85a6                	mv	a1,s1
  80048e:	854a                	mv	a0,s2
  800490:	0bc000ef          	jal	ra,80054c <printfmt>
  800494:	bb41                	j	800224 <vprintfmt+0x3a>
                p = "(null)";
  800496:	00000417          	auipc	s0,0x0
  80049a:	25a40413          	addi	s0,s0,602 # 8006f0 <main+0xfc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	85e2                	mv	a1,s8
  8004a0:	8522                	mv	a0,s0
  8004a2:	e43e                	sd	a5,8(sp)
  8004a4:	cbfff0ef          	jal	ra,800162 <strnlen>
  8004a8:	40ad8dbb          	subw	s11,s11,a0
  8004ac:	01b05b63          	blez	s11,8004c2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  8004b0:	67a2                	ld	a5,8(sp)
  8004b2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004b8:	85a6                	mv	a1,s1
  8004ba:	8552                	mv	a0,s4
  8004bc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004be:	fe0d9ce3          	bnez	s11,8004b6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c2:	00044783          	lbu	a5,0(s0)
  8004c6:	00140a13          	addi	s4,s0,1
  8004ca:	0007851b          	sext.w	a0,a5
  8004ce:	d3a5                	beqz	a5,80042e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004d0:	05e00413          	li	s0,94
  8004d4:	bf39                	j	8003f2 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004d6:	000a2403          	lw	s0,0(s4)
  8004da:	b7ad                	j	800444 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004dc:	000a6603          	lwu	a2,0(s4)
  8004e0:	46a1                	li	a3,8
  8004e2:	8a2e                	mv	s4,a1
  8004e4:	bdb1                	j	800340 <vprintfmt+0x156>
  8004e6:	000a6603          	lwu	a2,0(s4)
  8004ea:	46a9                	li	a3,10
  8004ec:	8a2e                	mv	s4,a1
  8004ee:	bd89                	j	800340 <vprintfmt+0x156>
  8004f0:	000a6603          	lwu	a2,0(s4)
  8004f4:	46c1                	li	a3,16
  8004f6:	8a2e                	mv	s4,a1
  8004f8:	b5a1                	j	800340 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004fa:	9902                	jalr	s2
  8004fc:	bf09                	j	80040e <vprintfmt+0x224>
                putch('-', putdat);
  8004fe:	85a6                	mv	a1,s1
  800500:	02d00513          	li	a0,45
  800504:	e03e                	sd	a5,0(sp)
  800506:	9902                	jalr	s2
                num = -(long long)num;
  800508:	6782                	ld	a5,0(sp)
  80050a:	8a66                	mv	s4,s9
  80050c:	40800633          	neg	a2,s0
  800510:	46a9                	li	a3,10
  800512:	b53d                	j	800340 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800514:	03b05163          	blez	s11,800536 <vprintfmt+0x34c>
  800518:	02d00693          	li	a3,45
  80051c:	f6d79de3          	bne	a5,a3,800496 <vprintfmt+0x2ac>
                p = "(null)";
  800520:	00000417          	auipc	s0,0x0
  800524:	1d040413          	addi	s0,s0,464 # 8006f0 <main+0xfc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800528:	02800793          	li	a5,40
  80052c:	02800513          	li	a0,40
  800530:	00140a13          	addi	s4,s0,1
  800534:	bd6d                	j	8003ee <vprintfmt+0x204>
  800536:	00000a17          	auipc	s4,0x0
  80053a:	1bba0a13          	addi	s4,s4,443 # 8006f1 <main+0xfd>
  80053e:	02800513          	li	a0,40
  800542:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800546:	05e00413          	li	s0,94
  80054a:	b565                	j	8003f2 <vprintfmt+0x208>

000000000080054c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80054e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800554:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800556:	ec06                	sd	ra,24(sp)
  800558:	f83a                	sd	a4,48(sp)
  80055a:	fc3e                	sd	a5,56(sp)
  80055c:	e0c2                	sd	a6,64(sp)
  80055e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800560:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800562:	c89ff0ef          	jal	ra,8001ea <vprintfmt>
}
  800566:	60e2                	ld	ra,24(sp)
  800568:	6161                	addi	sp,sp,80
  80056a:	8082                	ret

000000000080056c <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  80056c:	1141                	addi	sp,sp,-16
  80056e:	e406                	sd	ra,8(sp)
    yield();
  800570:	b6bff0ef          	jal	ra,8000da <yield>
    yield();
  800574:	b67ff0ef          	jal	ra,8000da <yield>
    yield();
  800578:	b63ff0ef          	jal	ra,8000da <yield>
    yield();
  80057c:	b5fff0ef          	jal	ra,8000da <yield>
    yield();
  800580:	b5bff0ef          	jal	ra,8000da <yield>
    yield();
}
  800584:	60a2                	ld	ra,8(sp)
  800586:	0141                	addi	sp,sp,16
    yield();
  800588:	be89                	j	8000da <yield>

000000000080058a <loop>:

int parent, pid1, pid2;

void
loop(void) {
  80058a:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  80058c:	00000517          	auipc	a0,0x0
  800590:	46450513          	addi	a0,a0,1124 # 8009f0 <error_string+0xc8>
loop(void) {
  800594:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800596:	b8bff0ef          	jal	ra,800120 <cprintf>
    while (1);
  80059a:	a001                	j	80059a <loop+0x10>

000000000080059c <work>:
}

void
work(void) {
  80059c:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  80059e:	00000517          	auipc	a0,0x0
  8005a2:	46250513          	addi	a0,a0,1122 # 800a00 <error_string+0xd8>
work(void) {
  8005a6:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005a8:	b79ff0ef          	jal	ra,800120 <cprintf>
    do_yield();
  8005ac:	fc1ff0ef          	jal	ra,80056c <do_yield>
    if (kill(parent) == 0) {
  8005b0:	00001517          	auipc	a0,0x1
  8005b4:	a5052503          	lw	a0,-1456(a0) # 801000 <parent>
  8005b8:	b25ff0ef          	jal	ra,8000dc <kill>
  8005bc:	e105                	bnez	a0,8005dc <work+0x40>
        cprintf("kill parent ok.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	45250513          	addi	a0,a0,1106 # 800a10 <error_string+0xe8>
  8005c6:	b5bff0ef          	jal	ra,800120 <cprintf>
        do_yield();
  8005ca:	fa3ff0ef          	jal	ra,80056c <do_yield>
        if (kill(pid1) == 0) {
  8005ce:	00001517          	auipc	a0,0x1
  8005d2:	a3652503          	lw	a0,-1482(a0) # 801004 <pid1>
  8005d6:	b07ff0ef          	jal	ra,8000dc <kill>
  8005da:	c501                	beqz	a0,8005e2 <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005dc:	557d                	li	a0,-1
  8005de:	ae3ff0ef          	jal	ra,8000c0 <exit>
            cprintf("kill child1 ok.\n");
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	44650513          	addi	a0,a0,1094 # 800a28 <error_string+0x100>
  8005ea:	b37ff0ef          	jal	ra,800120 <cprintf>
            exit(0);
  8005ee:	4501                	li	a0,0
  8005f0:	ad1ff0ef          	jal	ra,8000c0 <exit>

00000000008005f4 <main>:
}

int
main(void) {
  8005f4:	1141                	addi	sp,sp,-16
  8005f6:	e406                	sd	ra,8(sp)
  8005f8:	e022                	sd	s0,0(sp)
    parent = getpid();
  8005fa:	ae5ff0ef          	jal	ra,8000de <getpid>
  8005fe:	00001797          	auipc	a5,0x1
  800602:	a0a7a123          	sw	a0,-1534(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800606:	00001417          	auipc	s0,0x1
  80060a:	9fe40413          	addi	s0,s0,-1538 # 801004 <pid1>
  80060e:	ac9ff0ef          	jal	ra,8000d6 <fork>
  800612:	c008                	sw	a0,0(s0)
  800614:	c13d                	beqz	a0,80067a <main+0x86>
        loop();
    }

    assert(pid1 > 0);
  800616:	04a05263          	blez	a0,80065a <main+0x66>

    if ((pid2 = fork()) == 0) {
  80061a:	abdff0ef          	jal	ra,8000d6 <fork>
  80061e:	00001797          	auipc	a5,0x1
  800622:	9ea7a523          	sw	a0,-1558(a5) # 801008 <pid2>
  800626:	c93d                	beqz	a0,80069c <main+0xa8>
        work();
    }
    if (pid2 > 0) {
  800628:	04a05b63          	blez	a0,80067e <main+0x8a>
        cprintf("wait child 1.\n");
  80062c:	00000517          	auipc	a0,0x0
  800630:	44c50513          	addi	a0,a0,1100 # 800a78 <error_string+0x150>
  800634:	aedff0ef          	jal	ra,800120 <cprintf>
        waitpid(pid1, NULL);
  800638:	4008                	lw	a0,0(s0)
  80063a:	4581                	li	a1,0
  80063c:	a9dff0ef          	jal	ra,8000d8 <waitpid>
        panic("waitpid %d returns\n", pid1);
  800640:	4014                	lw	a3,0(s0)
  800642:	00000617          	auipc	a2,0x0
  800646:	44660613          	addi	a2,a2,1094 # 800a88 <error_string+0x160>
  80064a:	03400593          	li	a1,52
  80064e:	00000517          	auipc	a0,0x0
  800652:	41a50513          	addi	a0,a0,1050 # 800a68 <error_string+0x140>
  800656:	9cbff0ef          	jal	ra,800020 <__panic>
    assert(pid1 > 0);
  80065a:	00000697          	auipc	a3,0x0
  80065e:	3e668693          	addi	a3,a3,998 # 800a40 <error_string+0x118>
  800662:	00000617          	auipc	a2,0x0
  800666:	3ee60613          	addi	a2,a2,1006 # 800a50 <error_string+0x128>
  80066a:	02c00593          	li	a1,44
  80066e:	00000517          	auipc	a0,0x0
  800672:	3fa50513          	addi	a0,a0,1018 # 800a68 <error_string+0x140>
  800676:	9abff0ef          	jal	ra,800020 <__panic>
        loop();
  80067a:	f11ff0ef          	jal	ra,80058a <loop>
    }
    else {
        kill(pid1);
  80067e:	4008                	lw	a0,0(s0)
  800680:	a5dff0ef          	jal	ra,8000dc <kill>
    }
    panic("FAIL: T.T\n");
  800684:	00000617          	auipc	a2,0x0
  800688:	41c60613          	addi	a2,a2,1052 # 800aa0 <error_string+0x178>
  80068c:	03900593          	li	a1,57
  800690:	00000517          	auipc	a0,0x0
  800694:	3d850513          	addi	a0,a0,984 # 800a68 <error_string+0x140>
  800698:	989ff0ef          	jal	ra,800020 <__panic>
        work();
  80069c:	f01ff0ef          	jal	ra,80059c <work>
