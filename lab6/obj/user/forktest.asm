
obj/__user_forktest.out:     file format elf64-littleriscv


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
  800032:	5b250513          	addi	a0,a0,1458 # 8005e0 <main+0xa8>
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
  800044:	0cc000ef          	jal	800110 <cprintf>
    vcprintf(fmt, ap);
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0a4000ef          	jal	8000f0 <vcprintf>
    cprintf("\n");
  800050:	00000517          	auipc	a0,0x0
  800054:	5b050513          	addi	a0,a0,1456 # 800600 <main+0xc8>
  800058:	0b8000ef          	jal	800110 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005c:	5559                	li	a0,-10
  80005e:	056000ef          	jal	8000b4 <exit>

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

00000000008000ae <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000ae:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b0:	4579                	li	a0,30
  8000b2:	bf45                	j	800062 <syscall>

00000000008000b4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000b4:	1141                	addi	sp,sp,-16
  8000b6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000b8:	fe5ff0ef          	jal	80009c <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000bc:	00000517          	auipc	a0,0x0
  8000c0:	54c50513          	addi	a0,a0,1356 # 800608 <main+0xd0>
  8000c4:	04c000ef          	jal	800110 <cprintf>
    while (1);
  8000c8:	a001                	j	8000c8 <exit+0x14>

00000000008000ca <fork>:
}

int
fork(void) {
    return sys_fork();
  8000ca:	bfe1                	j	8000a2 <sys_fork>

00000000008000cc <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000cc:	4581                	li	a1,0
  8000ce:	4501                	li	a0,0
  8000d0:	bfd9                	j	8000a6 <sys_wait>

00000000008000d2 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  8000d2:	072000ef          	jal	800144 <umain>
1:  j 1b
  8000d6:	a001                	j	8000d6 <_start+0x4>

00000000008000d8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000d8:	1101                	addi	sp,sp,-32
  8000da:	ec06                	sd	ra,24(sp)
  8000dc:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  8000de:	fd1ff0ef          	jal	8000ae <sys_putc>
    (*cnt) ++;
  8000e2:	65a2                	ld	a1,8(sp)
}
  8000e4:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  8000e6:	419c                	lw	a5,0(a1)
  8000e8:	2785                	addiw	a5,a5,1
  8000ea:	c19c                	sw	a5,0(a1)
}
  8000ec:	6105                	addi	sp,sp,32
  8000ee:	8082                	ret

00000000008000f0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000f0:	1101                	addi	sp,sp,-32
  8000f2:	862a                	mv	a2,a0
  8000f4:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f6:	00000517          	auipc	a0,0x0
  8000fa:	fe250513          	addi	a0,a0,-30 # 8000d8 <cputch>
  8000fe:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800100:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800102:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800104:	0ce000ef          	jal	8001d2 <vprintfmt>
    return cnt;
}
  800108:	60e2                	ld	ra,24(sp)
  80010a:	4532                	lw	a0,12(sp)
  80010c:	6105                	addi	sp,sp,32
  80010e:	8082                	ret

0000000000800110 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800110:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800112:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800116:	f42e                	sd	a1,40(sp)
  800118:	f832                	sd	a2,48(sp)
  80011a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80011c:	862a                	mv	a2,a0
  80011e:	004c                	addi	a1,sp,4
  800120:	00000517          	auipc	a0,0x0
  800124:	fb850513          	addi	a0,a0,-72 # 8000d8 <cputch>
  800128:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80012a:	ec06                	sd	ra,24(sp)
  80012c:	e0ba                	sd	a4,64(sp)
  80012e:	e4be                	sd	a5,72(sp)
  800130:	e8c2                	sd	a6,80(sp)
  800132:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800134:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800136:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800138:	09a000ef          	jal	8001d2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80013c:	60e2                	ld	ra,24(sp)
  80013e:	4512                	lw	a0,4(sp)
  800140:	6125                	addi	sp,sp,96
  800142:	8082                	ret

0000000000800144 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800144:	1141                	addi	sp,sp,-16
  800146:	e406                	sd	ra,8(sp)
    int ret = main();
  800148:	3f0000ef          	jal	800538 <main>
    exit(ret);
  80014c:	f69ff0ef          	jal	8000b4 <exit>

0000000000800150 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800150:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800152:	e589                	bnez	a1,80015c <strnlen+0xc>
  800154:	a811                	j	800168 <strnlen+0x18>
        cnt ++;
  800156:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800158:	00f58863          	beq	a1,a5,800168 <strnlen+0x18>
  80015c:	00f50733          	add	a4,a0,a5
  800160:	00074703          	lbu	a4,0(a4)
  800164:	fb6d                	bnez	a4,800156 <strnlen+0x6>
  800166:	85be                	mv	a1,a5
    }
    return cnt;
}
  800168:	852e                	mv	a0,a1
  80016a:	8082                	ret

000000000080016c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80016e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	f022                	sd	s0,32(sp)
  800174:	ec26                	sd	s1,24(sp)
  800176:	e84a                	sd	s2,16(sp)
  800178:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800180:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800184:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	84aa                	mv	s1,a0
  80018a:	892e                	mv	s2,a1
    if (num >= base) {
  80018c:	03067d63          	bgeu	a2,a6,8001c6 <printnum+0x5a>
  800190:	e44e                	sd	s3,8(sp)
  800192:	89be                	mv	s3,a5
        while (-- width > 0)
  800194:	4785                	li	a5,1
  800196:	00e7d763          	bge	a5,a4,8001a4 <printnum+0x38>
            putch(padc, putdat);
  80019a:	85ca                	mv	a1,s2
  80019c:	854e                	mv	a0,s3
        while (-- width > 0)
  80019e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a0:	9482                	jalr	s1
        while (-- width > 0)
  8001a2:	fc65                	bnez	s0,80019a <printnum+0x2e>
  8001a4:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	00000797          	auipc	a5,0x0
  8001aa:	47a78793          	addi	a5,a5,1146 # 800620 <main+0xe8>
  8001ae:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	0007c503          	lbu	a0,0(a5)
}
  8001b6:	70a2                	ld	ra,40(sp)
  8001b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	85ca                	mv	a1,s2
  8001bc:	87a6                	mv	a5,s1
}
  8001be:	6942                	ld	s2,16(sp)
  8001c0:	64e2                	ld	s1,24(sp)
  8001c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c6:	03065633          	divu	a2,a2,a6
  8001ca:	8722                	mv	a4,s0
  8001cc:	fa1ff0ef          	jal	80016c <printnum>
  8001d0:	bfd9                	j	8001a6 <printnum+0x3a>

00000000008001d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d2:	7119                	addi	sp,sp,-128
  8001d4:	f4a6                	sd	s1,104(sp)
  8001d6:	f0ca                	sd	s2,96(sp)
  8001d8:	ecce                	sd	s3,88(sp)
  8001da:	e8d2                	sd	s4,80(sp)
  8001dc:	e4d6                	sd	s5,72(sp)
  8001de:	e0da                	sd	s6,64(sp)
  8001e0:	f862                	sd	s8,48(sp)
  8001e2:	fc86                	sd	ra,120(sp)
  8001e4:	f8a2                	sd	s0,112(sp)
  8001e6:	fc5e                	sd	s7,56(sp)
  8001e8:	f466                	sd	s9,40(sp)
  8001ea:	f06a                	sd	s10,32(sp)
  8001ec:	ec6e                	sd	s11,24(sp)
  8001ee:	84aa                	mv	s1,a0
  8001f0:	8c32                	mv	s8,a2
  8001f2:	8a36                	mv	s4,a3
  8001f4:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fa:	05500b13          	li	s6,85
  8001fe:	00000a97          	auipc	s5,0x0
  800202:	59aa8a93          	addi	s5,s5,1434 # 800798 <main+0x260>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	000c4503          	lbu	a0,0(s8)
  80020a:	001c0413          	addi	s0,s8,1
  80020e:	01350a63          	beq	a0,s3,800222 <vprintfmt+0x50>
            if (ch == '\0') {
  800212:	cd0d                	beqz	a0,80024c <vprintfmt+0x7a>
            putch(ch, putdat);
  800214:	85ca                	mv	a1,s2
  800216:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	00044503          	lbu	a0,0(s0)
  80021c:	0405                	addi	s0,s0,1
  80021e:	ff351ae3          	bne	a0,s3,800212 <vprintfmt+0x40>
        width = precision = -1;
  800222:	5cfd                	li	s9,-1
  800224:	8d66                	mv	s10,s9
        char padc = ' ';
  800226:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80022a:	4b81                	li	s7,0
  80022c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80022e:	00044683          	lbu	a3,0(s0)
  800232:	00140c13          	addi	s8,s0,1
  800236:	fdd6859b          	addiw	a1,a3,-35
  80023a:	0ff5f593          	zext.b	a1,a1
  80023e:	02bb6663          	bltu	s6,a1,80026a <vprintfmt+0x98>
  800242:	058a                	slli	a1,a1,0x2
  800244:	95d6                	add	a1,a1,s5
  800246:	4198                	lw	a4,0(a1)
  800248:	9756                	add	a4,a4,s5
  80024a:	8702                	jr	a4
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
            putch('%', putdat);
  80026a:	85ca                	mv	a1,s2
  80026c:	02500513          	li	a0,37
  800270:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800272:	fff44783          	lbu	a5,-1(s0)
  800276:	02500713          	li	a4,37
  80027a:	8c22                	mv	s8,s0
  80027c:	f8e785e3          	beq	a5,a4,800206 <vprintfmt+0x34>
  800280:	ffec4783          	lbu	a5,-2(s8)
  800284:	1c7d                	addi	s8,s8,-1
  800286:	fee79de3          	bne	a5,a4,800280 <vprintfmt+0xae>
  80028a:	bfb5                	j	800206 <vprintfmt+0x34>
                ch = *fmt;
  80028c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800290:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800292:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800296:	fd06071b          	addiw	a4,a2,-48
  80029a:	24e56a63          	bltu	a0,a4,8004ee <vprintfmt+0x31c>
                ch = *fmt;
  80029e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8002a0:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  8002a2:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002a6:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002aa:	0197073b          	addw	a4,a4,s9
  8002ae:	0017171b          	slliw	a4,a4,0x1
  8002b2:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002b4:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002b8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ba:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002be:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002c2:	feb570e3          	bgeu	a0,a1,8002a2 <vprintfmt+0xd0>
            if (width < 0)
  8002c6:	f60d54e3          	bgez	s10,80022e <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002ca:	8d66                	mv	s10,s9
  8002cc:	5cfd                	li	s9,-1
  8002ce:	b785                	j	80022e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d0:	8db6                	mv	s11,a3
  8002d2:	8462                	mv	s0,s8
  8002d4:	bfa9                	j	80022e <vprintfmt+0x5c>
  8002d6:	8462                	mv	s0,s8
            altflag = 1;
  8002d8:	4b85                	li	s7,1
            goto reswitch;
  8002da:	bf91                	j	80022e <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002de:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e2:	00f74463          	blt	a4,a5,8002ea <vprintfmt+0x118>
    else if (lflag) {
  8002e6:	1a078763          	beqz	a5,800494 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002ea:	000a3603          	ld	a2,0(s4)
  8002ee:	46c1                	li	a3,16
  8002f0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002f2:	000d879b          	sext.w	a5,s11
  8002f6:	876a                	mv	a4,s10
  8002f8:	85ca                	mv	a1,s2
  8002fa:	8526                	mv	a0,s1
  8002fc:	e71ff0ef          	jal	80016c <printnum>
            break;
  800300:	b719                	j	800206 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800302:	000a2503          	lw	a0,0(s4)
  800306:	85ca                	mv	a1,s2
  800308:	0a21                	addi	s4,s4,8
  80030a:	9482                	jalr	s1
            break;
  80030c:	bded                	j	800206 <vprintfmt+0x34>
    if (lflag >= 2) {
  80030e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800310:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800314:	00f74463          	blt	a4,a5,80031c <vprintfmt+0x14a>
    else if (lflag) {
  800318:	16078963          	beqz	a5,80048a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80031c:	000a3603          	ld	a2,0(s4)
  800320:	46a9                	li	a3,10
  800322:	8a2e                	mv	s4,a1
  800324:	b7f9                	j	8002f2 <vprintfmt+0x120>
            putch('0', putdat);
  800326:	85ca                	mv	a1,s2
  800328:	03000513          	li	a0,48
  80032c:	9482                	jalr	s1
            putch('x', putdat);
  80032e:	85ca                	mv	a1,s2
  800330:	07800513          	li	a0,120
  800334:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800336:	000a3603          	ld	a2,0(s4)
            goto number;
  80033a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033c:	0a21                	addi	s4,s4,8
            goto number;
  80033e:	bf55                	j	8002f2 <vprintfmt+0x120>
            putch(ch, putdat);
  800340:	85ca                	mv	a1,s2
  800342:	02500513          	li	a0,37
  800346:	9482                	jalr	s1
            break;
  800348:	bd7d                	j	800206 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80034a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80034e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800350:	0a21                	addi	s4,s4,8
            goto process_precision;
  800352:	bf95                	j	8002c6 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800354:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800356:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80035a:	00f74463          	blt	a4,a5,800362 <vprintfmt+0x190>
    else if (lflag) {
  80035e:	12078163          	beqz	a5,800480 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800362:	000a3603          	ld	a2,0(s4)
  800366:	46a1                	li	a3,8
  800368:	8a2e                	mv	s4,a1
  80036a:	b761                	j	8002f2 <vprintfmt+0x120>
            if (width < 0)
  80036c:	876a                	mv	a4,s10
  80036e:	000d5363          	bgez	s10,800374 <vprintfmt+0x1a2>
  800372:	4701                	li	a4,0
  800374:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800378:	8462                	mv	s0,s8
            goto reswitch;
  80037a:	bd55                	j	80022e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80037c:	000d841b          	sext.w	s0,s11
  800380:	fd340793          	addi	a5,s0,-45
  800384:	00f037b3          	snez	a5,a5
  800388:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80038c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800390:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800392:	008a0793          	addi	a5,s4,8
  800396:	e43e                	sd	a5,8(sp)
  800398:	100d8c63          	beqz	s11,8004b0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80039c:	12071363          	bnez	a4,8004c2 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	000dc783          	lbu	a5,0(s11)
  8003a4:	0007851b          	sext.w	a0,a5
  8003a8:	c78d                	beqz	a5,8003d2 <vprintfmt+0x200>
  8003aa:	0d85                	addi	s11,s11,1
  8003ac:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ae:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b2:	000cc563          	bltz	s9,8003bc <vprintfmt+0x1ea>
  8003b6:	3cfd                	addiw	s9,s9,-1
  8003b8:	008c8d63          	beq	s9,s0,8003d2 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003bc:	020b9663          	bnez	s7,8003e8 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003c0:	85ca                	mv	a1,s2
  8003c2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c4:	000dc783          	lbu	a5,0(s11)
  8003c8:	0d85                	addi	s11,s11,1
  8003ca:	3d7d                	addiw	s10,s10,-1
  8003cc:	0007851b          	sext.w	a0,a5
  8003d0:	f3ed                	bnez	a5,8003b2 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003d2:	01a05963          	blez	s10,8003e4 <vprintfmt+0x212>
                putch(' ', putdat);
  8003d6:	85ca                	mv	a1,s2
  8003d8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003dc:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003de:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003e0:	fe0d1be3          	bnez	s10,8003d6 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003e4:	6a22                	ld	s4,8(sp)
  8003e6:	b505                	j	800206 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e8:	3781                	addiw	a5,a5,-32
  8003ea:	fcfa7be3          	bgeu	s4,a5,8003c0 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003ee:	03f00513          	li	a0,63
  8003f2:	85ca                	mv	a1,s2
  8003f4:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f6:	000dc783          	lbu	a5,0(s11)
  8003fa:	0d85                	addi	s11,s11,1
  8003fc:	3d7d                	addiw	s10,s10,-1
  8003fe:	0007851b          	sext.w	a0,a5
  800402:	dbe1                	beqz	a5,8003d2 <vprintfmt+0x200>
  800404:	fa0cd9e3          	bgez	s9,8003b6 <vprintfmt+0x1e4>
  800408:	b7c5                	j	8003e8 <vprintfmt+0x216>
            if (err < 0) {
  80040a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80040e:	4661                	li	a2,24
            err = va_arg(ap, int);
  800410:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800412:	41f7d71b          	sraiw	a4,a5,0x1f
  800416:	8fb9                	xor	a5,a5,a4
  800418:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80041c:	02d64563          	blt	a2,a3,800446 <vprintfmt+0x274>
  800420:	00000797          	auipc	a5,0x0
  800424:	4d078793          	addi	a5,a5,1232 # 8008f0 <error_string>
  800428:	00369713          	slli	a4,a3,0x3
  80042c:	97ba                	add	a5,a5,a4
  80042e:	639c                	ld	a5,0(a5)
  800430:	cb99                	beqz	a5,800446 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800432:	86be                	mv	a3,a5
  800434:	00000617          	auipc	a2,0x0
  800438:	21c60613          	addi	a2,a2,540 # 800650 <main+0x118>
  80043c:	85ca                	mv	a1,s2
  80043e:	8526                	mv	a0,s1
  800440:	0d8000ef          	jal	800518 <printfmt>
  800444:	b3c9                	j	800206 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800446:	00000617          	auipc	a2,0x0
  80044a:	1fa60613          	addi	a2,a2,506 # 800640 <main+0x108>
  80044e:	85ca                	mv	a1,s2
  800450:	8526                	mv	a0,s1
  800452:	0c6000ef          	jal	800518 <printfmt>
  800456:	bb45                	j	800206 <vprintfmt+0x34>
    if (lflag >= 2) {
  800458:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80045a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80045e:	00f74363          	blt	a4,a5,800464 <vprintfmt+0x292>
    else if (lflag) {
  800462:	cf81                	beqz	a5,80047a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800464:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800468:	02044b63          	bltz	s0,80049e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80046c:	8622                	mv	a2,s0
  80046e:	8a5e                	mv	s4,s7
  800470:	46a9                	li	a3,10
  800472:	b541                	j	8002f2 <vprintfmt+0x120>
            lflag ++;
  800474:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800476:	8462                	mv	s0,s8
            goto reswitch;
  800478:	bb5d                	j	80022e <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80047a:	000a2403          	lw	s0,0(s4)
  80047e:	b7ed                	j	800468 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800480:	000a6603          	lwu	a2,0(s4)
  800484:	46a1                	li	a3,8
  800486:	8a2e                	mv	s4,a1
  800488:	b5ad                	j	8002f2 <vprintfmt+0x120>
  80048a:	000a6603          	lwu	a2,0(s4)
  80048e:	46a9                	li	a3,10
  800490:	8a2e                	mv	s4,a1
  800492:	b585                	j	8002f2 <vprintfmt+0x120>
  800494:	000a6603          	lwu	a2,0(s4)
  800498:	46c1                	li	a3,16
  80049a:	8a2e                	mv	s4,a1
  80049c:	bd99                	j	8002f2 <vprintfmt+0x120>
                putch('-', putdat);
  80049e:	85ca                	mv	a1,s2
  8004a0:	02d00513          	li	a0,45
  8004a4:	9482                	jalr	s1
                num = -(long long)num;
  8004a6:	40800633          	neg	a2,s0
  8004aa:	8a5e                	mv	s4,s7
  8004ac:	46a9                	li	a3,10
  8004ae:	b591                	j	8002f2 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b0:	e329                	bnez	a4,8004f2 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b2:	02800793          	li	a5,40
  8004b6:	853e                	mv	a0,a5
  8004b8:	00000d97          	auipc	s11,0x0
  8004bc:	181d8d93          	addi	s11,s11,385 # 800639 <main+0x101>
  8004c0:	b5f5                	j	8003ac <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	85e6                	mv	a1,s9
  8004c4:	856e                	mv	a0,s11
  8004c6:	c8bff0ef          	jal	800150 <strnlen>
  8004ca:	40ad0d3b          	subw	s10,s10,a0
  8004ce:	01a05863          	blez	s10,8004de <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004d2:	85ca                	mv	a1,s2
  8004d4:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004d8:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	fe0d1ce3          	bnez	s10,8004d2 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004de:	000dc783          	lbu	a5,0(s11)
  8004e2:	0007851b          	sext.w	a0,a5
  8004e6:	ec0792e3          	bnez	a5,8003aa <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004ea:	6a22                	ld	s4,8(sp)
  8004ec:	bb29                	j	800206 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004ee:	8462                	mv	s0,s8
  8004f0:	bbd9                	j	8002c6 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f2:	85e6                	mv	a1,s9
  8004f4:	00000517          	auipc	a0,0x0
  8004f8:	14450513          	addi	a0,a0,324 # 800638 <main+0x100>
  8004fc:	c55ff0ef          	jal	800150 <strnlen>
  800500:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800504:	02800793          	li	a5,40
                p = "(null)";
  800508:	00000d97          	auipc	s11,0x0
  80050c:	130d8d93          	addi	s11,s11,304 # 800638 <main+0x100>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800510:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800512:	fda040e3          	bgtz	s10,8004d2 <vprintfmt+0x300>
  800516:	bd51                	j	8003aa <vprintfmt+0x1d8>

0000000000800518 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800520:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	ec06                	sd	ra,24(sp)
  800524:	f83a                	sd	a4,48(sp)
  800526:	fc3e                	sd	a5,56(sp)
  800528:	e0c2                	sd	a6,64(sp)
  80052a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052e:	ca5ff0ef          	jal	8001d2 <vprintfmt>
}
  800532:	60e2                	ld	ra,24(sp)
  800534:	6161                	addi	sp,sp,80
  800536:	8082                	ret

0000000000800538 <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  800538:	1101                	addi	sp,sp,-32
  80053a:	e822                	sd	s0,16(sp)
  80053c:	e426                	sd	s1,8(sp)
  80053e:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800540:	4401                	li	s0,0
  800542:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800546:	b85ff0ef          	jal	8000ca <fork>
  80054a:	c915                	beqz	a0,80057e <main+0x46>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80054c:	04a05e63          	blez	a0,8005a8 <main+0x70>
    for (n = 0; n < max_child; n ++) {
  800550:	2405                	addiw	s0,s0,1
  800552:	fe941ae3          	bne	s0,s1,800546 <main+0xe>
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  800556:	b77ff0ef          	jal	8000cc <wait>
  80055a:	ed05                	bnez	a0,800592 <main+0x5a>
    for (; n > 0; n --) {
  80055c:	347d                	addiw	s0,s0,-1
  80055e:	fc65                	bnez	s0,800556 <main+0x1e>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  800560:	b6dff0ef          	jal	8000cc <wait>
  800564:	c12d                	beqz	a0,8005c6 <main+0x8e>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  800566:	00000517          	auipc	a0,0x0
  80056a:	22250513          	addi	a0,a0,546 # 800788 <main+0x250>
  80056e:	ba3ff0ef          	jal	800110 <cprintf>
    return 0;
}
  800572:	60e2                	ld	ra,24(sp)
  800574:	6442                	ld	s0,16(sp)
  800576:	64a2                	ld	s1,8(sp)
  800578:	4501                	li	a0,0
  80057a:	6105                	addi	sp,sp,32
  80057c:	8082                	ret
            cprintf("I am child %d\n", n);
  80057e:	85a2                	mv	a1,s0
  800580:	00000517          	auipc	a0,0x0
  800584:	19850513          	addi	a0,a0,408 # 800718 <main+0x1e0>
  800588:	b89ff0ef          	jal	800110 <cprintf>
            exit(0);
  80058c:	4501                	li	a0,0
  80058e:	b27ff0ef          	jal	8000b4 <exit>
            panic("wait stopped early\n");
  800592:	00000617          	auipc	a2,0x0
  800596:	1c660613          	addi	a2,a2,454 # 800758 <main+0x220>
  80059a:	45dd                	li	a1,23
  80059c:	00000517          	auipc	a0,0x0
  8005a0:	1ac50513          	addi	a0,a0,428 # 800748 <main+0x210>
  8005a4:	a7dff0ef          	jal	800020 <__panic>
        assert(pid > 0);
  8005a8:	00000697          	auipc	a3,0x0
  8005ac:	18068693          	addi	a3,a3,384 # 800728 <main+0x1f0>
  8005b0:	00000617          	auipc	a2,0x0
  8005b4:	18060613          	addi	a2,a2,384 # 800730 <main+0x1f8>
  8005b8:	45b9                	li	a1,14
  8005ba:	00000517          	auipc	a0,0x0
  8005be:	18e50513          	addi	a0,a0,398 # 800748 <main+0x210>
  8005c2:	a5fff0ef          	jal	800020 <__panic>
        panic("wait got too many\n");
  8005c6:	00000617          	auipc	a2,0x0
  8005ca:	1aa60613          	addi	a2,a2,426 # 800770 <main+0x238>
  8005ce:	45f1                	li	a1,28
  8005d0:	00000517          	auipc	a0,0x0
  8005d4:	17850513          	addi	a0,a0,376 # 800748 <main+0x210>
  8005d8:	a49ff0ef          	jal	800020 <__panic>
