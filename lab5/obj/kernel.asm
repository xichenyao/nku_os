
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	28650513          	addi	a0,a0,646 # ffffffffc02a72b8 <buf>
ffffffffc020003a:	000b2617          	auipc	a2,0xb2
ffffffffc020003e:	7da60613          	addi	a2,a2,2010 # ffffffffc02b2814 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	192060ef          	jal	ra,ffffffffc02061dc <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	5be58593          	addi	a1,a1,1470 # ffffffffc0206610 <etext+0x6>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	5d650513          	addi	a0,a0,1494 # ffffffffc0206630 <etext+0x26>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	68c010ef          	jal	ra,ffffffffc02016f6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4a9020ef          	jal	ra,ffffffffc0202d1e <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	549050ef          	jal	ra,ffffffffc0205dc2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	76c030ef          	jal	ra,ffffffffc02037ee <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	6cd050ef          	jal	ra,ffffffffc0205f5a <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	1b2060ef          	jal	ra,ffffffffc0206272 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	17c060ef          	jal	ra,ffffffffc0206272 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206638 <etext+0x2e>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	138b8b93          	addi	s7,s7,312 # ffffffffc02a72b8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	0dc50513          	addi	a0,a0,220 # ffffffffc02a72b8 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	57830313          	addi	t1,t1,1400 # ffffffffc02b2780 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	40a50513          	addi	a0,a0,1034 # ffffffffc0206640 <etext+0x36>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00007517          	auipc	a0,0x7
ffffffffc0200250:	1dc50513          	addi	a0,a0,476 # ffffffffc0207428 <commands+0xb70>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	3e050513          	addi	a0,a0,992 # ffffffffc0206660 <etext+0x56>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00007517          	auipc	a0,0x7
ffffffffc02002a4:	18850513          	addi	a0,a0,392 # ffffffffc0207428 <commands+0xb70>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	3ca50513          	addi	a0,a0,970 # ffffffffc0206680 <etext+0x76>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	3d450513          	addi	a0,a0,980 # ffffffffc02066a0 <etext+0x96>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	33258593          	addi	a1,a1,818 # ffffffffc020660a <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	3e050513          	addi	a0,a0,992 # ffffffffc02066c0 <etext+0xb6>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	fcc58593          	addi	a1,a1,-52 # ffffffffc02a72b8 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	3ec50513          	addi	a0,a0,1004 # ffffffffc02066e0 <etext+0xd6>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	51458593          	addi	a1,a1,1300 # ffffffffc02b2814 <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	3f850513          	addi	a0,a0,1016 # ffffffffc0206700 <etext+0xf6>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	8ff58593          	addi	a1,a1,-1793 # ffffffffc02b2c13 <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206720 <etext+0x116>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	40c60613          	addi	a2,a2,1036 # ffffffffc0206750 <etext+0x146>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	41850513          	addi	a0,a0,1048 # ffffffffc0206768 <etext+0x15e>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	42060613          	addi	a2,a2,1056 # ffffffffc0206780 <etext+0x176>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	43858593          	addi	a1,a1,1080 # ffffffffc02067a0 <etext+0x196>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	43850513          	addi	a0,a0,1080 # ffffffffc02067a8 <etext+0x19e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	43a60613          	addi	a2,a2,1082 # ffffffffc02067b8 <etext+0x1ae>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	45a58593          	addi	a1,a1,1114 # ffffffffc02067e0 <etext+0x1d6>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	41a50513          	addi	a0,a0,1050 # ffffffffc02067a8 <etext+0x19e>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	45660613          	addi	a2,a2,1110 # ffffffffc02067f0 <etext+0x1e6>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	46e58593          	addi	a1,a1,1134 # ffffffffc0206810 <etext+0x206>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	3fe50513          	addi	a0,a0,1022 # ffffffffc02067a8 <etext+0x19e>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	43c50513          	addi	a0,a0,1084 # ffffffffc0206820 <etext+0x216>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	44250513          	addi	a0,a0,1090 # ffffffffc0206848 <etext+0x23e>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	49cc0c13          	addi	s8,s8,1180 # ffffffffc02068b8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	44c90913          	addi	s2,s2,1100 # ffffffffc0206870 <etext+0x266>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	44c48493          	addi	s1,s1,1100 # ffffffffc0206878 <etext+0x26e>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	44ab0b13          	addi	s6,s6,1098 # ffffffffc0206880 <etext+0x276>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	362a0a13          	addi	s4,s4,866 # ffffffffc02067a0 <etext+0x196>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	458d0d13          	addi	s10,s10,1112 # ffffffffc02068b8 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	53b050ef          	jal	ra,ffffffffc02061a8 <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	527050ef          	jal	ra,ffffffffc02061a8 <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	507050ef          	jal	ra,ffffffffc02061c6 <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	4c9050ef          	jal	ra,ffffffffc02061c6 <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	38850513          	addi	a0,a0,904 # ffffffffc02068a0 <etext+0x296>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	18478793          	addi	a5,a5,388 # ffffffffc02a76b8 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	4a3050ef          	jal	ra,ffffffffc02061ee <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	15c50513          	addi	a0,a0,348 # ffffffffc02a76b8 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	47f050ef          	jal	ra,ffffffffc02061ee <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd580>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	20f73723          	sd	a5,526(a4) # ffffffffc02b2790 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	35e50513          	addi	a0,a0,862 # ffffffffc0206900 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	1c07bf23          	sd	zero,478(a5) # ffffffffc02b2788 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	1d87b783          	ld	a5,472(a5) # ffffffffc02b2790 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	2b050513          	addi	a0,a0,688 # ffffffffc0206920 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	2b850513          	addi	a0,a0,696 # ffffffffc0206938 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	2c250513          	addi	a0,a0,706 # ffffffffc0206950 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	2cc50513          	addi	a0,a0,716 # ffffffffc0206968 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	2d650513          	addi	a0,a0,726 # ffffffffc0206980 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	2e050513          	addi	a0,a0,736 # ffffffffc0206998 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	2ea50513          	addi	a0,a0,746 # ffffffffc02069b0 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	2f450513          	addi	a0,a0,756 # ffffffffc02069c8 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	2fe50513          	addi	a0,a0,766 # ffffffffc02069e0 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	30850513          	addi	a0,a0,776 # ffffffffc02069f8 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	31250513          	addi	a0,a0,786 # ffffffffc0206a10 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	31c50513          	addi	a0,a0,796 # ffffffffc0206a28 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	32650513          	addi	a0,a0,806 # ffffffffc0206a40 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	33050513          	addi	a0,a0,816 # ffffffffc0206a58 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	33a50513          	addi	a0,a0,826 # ffffffffc0206a70 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	34450513          	addi	a0,a0,836 # ffffffffc0206a88 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	34e50513          	addi	a0,a0,846 # ffffffffc0206aa0 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	35850513          	addi	a0,a0,856 # ffffffffc0206ab8 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	36250513          	addi	a0,a0,866 # ffffffffc0206ad0 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	36c50513          	addi	a0,a0,876 # ffffffffc0206ae8 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	37650513          	addi	a0,a0,886 # ffffffffc0206b00 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	38050513          	addi	a0,a0,896 # ffffffffc0206b18 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	38a50513          	addi	a0,a0,906 # ffffffffc0206b30 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	39450513          	addi	a0,a0,916 # ffffffffc0206b48 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	39e50513          	addi	a0,a0,926 # ffffffffc0206b60 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	3a850513          	addi	a0,a0,936 # ffffffffc0206b78 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	3b250513          	addi	a0,a0,946 # ffffffffc0206b90 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	3bc50513          	addi	a0,a0,956 # ffffffffc0206ba8 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	3c650513          	addi	a0,a0,966 # ffffffffc0206bc0 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	3d050513          	addi	a0,a0,976 # ffffffffc0206bd8 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	3da50513          	addi	a0,a0,986 # ffffffffc0206bf0 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	3e050513          	addi	a0,a0,992 # ffffffffc0206c08 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	3e250513          	addi	a0,a0,994 # ffffffffc0206c20 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	3e250513          	addi	a0,a0,994 # ffffffffc0206c38 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206c50 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	3f250513          	addi	a0,a0,1010 # ffffffffc0206c68 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0206c78 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	f2c48493          	addi	s1,s1,-212 # ffffffffc02b27c8 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	3be50513          	addi	a0,a0,958 # ffffffffc0206c90 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	f1673703          	ld	a4,-234(a4) # ffffffffc02b27f8 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	f167b783          	ld	a5,-234(a5) # ffffffffc02b2800 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	1590206f          	j	ffffffffc020325e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	eda7b783          	ld	a5,-294(a5) # ffffffffc02b27f8 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	1250206f          	j	ffffffffc020325e <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	37268693          	addi	a3,a3,882 # ffffffffc0206cb0 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	38260613          	addi	a2,a2,898 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	38e50513          	addi	a0,a0,910 # ffffffffc0206ce0 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	30850513          	addi	a0,a0,776 # ffffffffc0206c90 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	36460613          	addi	a2,a2,868 # ffffffffc0206cf8 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	34050513          	addi	a0,a0,832 # ffffffffc0206ce0 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	3f070713          	addi	a4,a4,1008 # ffffffffc0206db0 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	39e50513          	addi	a0,a0,926 # ffffffffc0206d70 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	37250513          	addi	a0,a0,882 # ffffffffc0206d50 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	32650513          	addi	a0,a0,806 # ffffffffc0206d10 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	33a50513          	addi	a0,a0,826 # ffffffffc0206d30 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	d7e68693          	addi	a3,a3,-642 # ffffffffc02b2788 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	dd67b783          	ld	a5,-554(a5) # ffffffffc02b27f8 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	35a50513          	addi	a0,a0,858 # ffffffffc0206d90 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	18f76563          	bltu	a4,a5,ffffffffc0200bde <exception_handler+0x19a>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	52070713          	addi	a4,a4,1312 # ffffffffc0206f78 <commands+0x6c0>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	46650513          	addi	a0,a0,1126 # ffffffffc0206ed0 <commands+0x618>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	6580506f          	j	ffffffffc02060e0 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	46450513          	addi	a0,a0,1124 # ffffffffc0206ef0 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	47050513          	addi	a0,a0,1136 # ffffffffc0206f10 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	48650513          	addi	a0,a0,1158 # ffffffffc0206f30 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	49450513          	addi	a0,a0,1172 # ffffffffc0206f48 <commands+0x690>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	12051d63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1be>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	48a50513          	addi	a0,a0,1162 # ffffffffc0206f60 <commands+0x6a8>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	38c60613          	addi	a2,a2,908 # ffffffffc0206e80 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	1e050513          	addi	a0,a0,480 # ffffffffc0206ce0 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	2d450513          	addi	a0,a0,724 # ffffffffc0206de0 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	2ea50513          	addi	a0,a0,746 # ffffffffc0206e00 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	30050513          	addi	a0,a0,768 # ffffffffc0206e20 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	30e50513          	addi	a0,a0,782 # ffffffffc0206e38 <commands+0x580>
ffffffffc0200b32:	d9aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b36:	6458                	ld	a4,136(s0)
ffffffffc0200b38:	47a9                	li	a5,10
ffffffffc0200b3a:	f8f719e3          	bne	a4,a5,ffffffffc0200acc <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3e:	10843783          	ld	a5,264(s0)
ffffffffc0200b42:	0791                	addi	a5,a5,4
ffffffffc0200b44:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b48:	598050ef          	jal	ra,ffffffffc02060e0 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	cac7b783          	ld	a5,-852(a5) # ffffffffc02b27f8 <current>
ffffffffc0200b54:	6b9c                	ld	a5,16(a5)
ffffffffc0200b56:	8522                	mv	a0,s0
}
ffffffffc0200b58:	6442                	ld	s0,16(sp)
ffffffffc0200b5a:	60e2                	ld	ra,24(sp)
ffffffffc0200b5c:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5e:	6589                	lui	a1,0x2
ffffffffc0200b60:	95be                	add	a1,a1,a5
}
ffffffffc0200b62:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	ac19                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	2e250513          	addi	a0,a0,738 # ffffffffc0206e48 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	2f850513          	addi	a0,a0,760 # ffffffffc0206e68 <commands+0x5b0>
ffffffffc0200b78:	d54ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	d1bff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200b82:	84aa                	mv	s1,a0
ffffffffc0200b84:	d521                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	cafff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8c:	86a6                	mv	a3,s1
ffffffffc0200b8e:	00006617          	auipc	a2,0x6
ffffffffc0200b92:	2f260613          	addi	a2,a2,754 # ffffffffc0206e80 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	14650513          	addi	a0,a0,326 # ffffffffc0206ce0 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	31250513          	addi	a0,a0,786 # ffffffffc0206eb8 <commands+0x600>
ffffffffc0200bae:	d1eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	ce5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c77ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	2ba60613          	addi	a2,a2,698 # ffffffffc0206e80 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	10e50513          	addi	a0,a0,270 # ffffffffc0206ce0 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1b9                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	2b660613          	addi	a2,a2,694 # ffffffffc0206ea0 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	0ea50513          	addi	a0,a0,234 # ffffffffc0206ce0 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	27660613          	addi	a2,a2,630 # ffffffffc0206e80 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	0ca50513          	addi	a0,a0,202 # ffffffffc0206ce0 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c22 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c26:	000b2417          	auipc	s0,0xb2
ffffffffc0200c2a:	bd240413          	addi	s0,s0,-1070 # ffffffffc02b27f8 <current>
ffffffffc0200c2e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
ffffffffc0200c34:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c36:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c3a:	cf1d                	beqz	a4,ffffffffc0200c78 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c40:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c44:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4a:	0206c463          	bltz	a3,ffffffffc0200c72 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4e:	df7ff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c52:	601c                	ld	a5,0(s0)
ffffffffc0200c54:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c58:	e499                	bnez	s1,ffffffffc0200c66 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5e:	8b05                	andi	a4,a4,1
ffffffffc0200c60:	e329                	bnez	a4,ffffffffc0200ca2 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c62:	6f9c                	ld	a5,24(a5)
ffffffffc0200c64:	eb85                	bnez	a5,ffffffffc0200c94 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	64a2                	ld	s1,8(sp)
ffffffffc0200c6c:	6902                	ld	s2,0(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
ffffffffc0200c70:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c72:	d41ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200c76:	bff1                	j	ffffffffc0200c52 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0006c863          	bltz	a3,ffffffffc0200c88 <trap+0x66>
}
ffffffffc0200c7c:	6442                	ld	s0,16(sp)
ffffffffc0200c7e:	60e2                	ld	ra,24(sp)
ffffffffc0200c80:	64a2                	ld	s1,8(sp)
ffffffffc0200c82:	6902                	ld	s2,0(sp)
ffffffffc0200c84:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c86:	bb7d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	60e2                	ld	ra,24(sp)
ffffffffc0200c8c:	64a2                	ld	s1,8(sp)
ffffffffc0200c8e:	6902                	ld	s2,0(sp)
ffffffffc0200c90:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c92:	b305                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9e:	3560506f          	j	ffffffffc0205ff4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	704040ef          	jal	ra,ffffffffc02053a8 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca8:	601c                	ld	a5,0(s0)
ffffffffc0200caa:	bf65                	j	ffffffffc0200c62 <trap+0x40>

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f0bff0ef          	jal	ra,ffffffffc0200c22 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e24:	00006617          	auipc	a2,0x6
ffffffffc0200e28:	19460613          	addi	a2,a2,404 # ffffffffc0206fb8 <commands+0x700>
ffffffffc0200e2c:	06200593          	li	a1,98
ffffffffc0200e30:	00006517          	auipc	a0,0x6
ffffffffc0200e34:	1a850513          	addi	a0,a0,424 # ffffffffc0206fd8 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc0200e38:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e3a:	bceff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e3e <pte2page.part.0>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
ffffffffc0200e3e:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200e40:	00006617          	auipc	a2,0x6
ffffffffc0200e44:	1a860613          	addi	a2,a2,424 # ffffffffc0206fe8 <commands+0x730>
ffffffffc0200e48:	07400593          	li	a1,116
ffffffffc0200e4c:	00006517          	auipc	a0,0x6
ffffffffc0200e50:	18c50513          	addi	a0,a0,396 # ffffffffc0206fd8 <commands+0x720>
pte2page(pte_t pte) {
ffffffffc0200e54:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200e56:	bb2ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e5a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e5a:	7139                	addi	sp,sp,-64
ffffffffc0200e5c:	f426                	sd	s1,40(sp)
ffffffffc0200e5e:	f04a                	sd	s2,32(sp)
ffffffffc0200e60:	ec4e                	sd	s3,24(sp)
ffffffffc0200e62:	e852                	sd	s4,16(sp)
ffffffffc0200e64:	e456                	sd	s5,8(sp)
ffffffffc0200e66:	e05a                	sd	s6,0(sp)
ffffffffc0200e68:	fc06                	sd	ra,56(sp)
ffffffffc0200e6a:	f822                	sd	s0,48(sp)
ffffffffc0200e6c:	84aa                	mv	s1,a0
ffffffffc0200e6e:	000b2917          	auipc	s2,0xb2
ffffffffc0200e72:	94a90913          	addi	s2,s2,-1718 # ffffffffc02b27b8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e76:	4a05                	li	s4,1
ffffffffc0200e78:	000b2a97          	auipc	s5,0xb2
ffffffffc0200e7c:	978a8a93          	addi	s5,s5,-1672 # ffffffffc02b27f0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e80:	0005099b          	sext.w	s3,a0
ffffffffc0200e84:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e88:	944b0b13          	addi	s6,s6,-1724 # ffffffffc02b27c8 <check_mm_struct>
ffffffffc0200e8c:	a01d                	j	ffffffffc0200eb2 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e8e:	00093783          	ld	a5,0(s2)
ffffffffc0200e92:	6f9c                	ld	a5,24(a5)
ffffffffc0200e94:	9782                	jalr	a5
ffffffffc0200e96:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e98:	4601                	li	a2,0
ffffffffc0200e9a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e9c:	ec0d                	bnez	s0,ffffffffc0200ed6 <alloc_pages+0x7c>
ffffffffc0200e9e:	029a6c63          	bltu	s4,s1,ffffffffc0200ed6 <alloc_pages+0x7c>
ffffffffc0200ea2:	000aa783          	lw	a5,0(s5)
ffffffffc0200ea6:	2781                	sext.w	a5,a5
ffffffffc0200ea8:	c79d                	beqz	a5,ffffffffc0200ed6 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eaa:	000b3503          	ld	a0,0(s6)
ffffffffc0200eae:	09e030ef          	jal	ra,ffffffffc0203f4c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eb2:	100027f3          	csrr	a5,sstatus
ffffffffc0200eb6:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eb8:	8526                	mv	a0,s1
ffffffffc0200eba:	dbf1                	beqz	a5,ffffffffc0200e8e <alloc_pages+0x34>
        intr_disable();
ffffffffc0200ebc:	f8cff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200ec0:	00093783          	ld	a5,0(s2)
ffffffffc0200ec4:	8526                	mv	a0,s1
ffffffffc0200ec6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ec8:	9782                	jalr	a5
ffffffffc0200eca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ecc:	f76ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ed0:	4601                	li	a2,0
ffffffffc0200ed2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ed4:	d469                	beqz	s0,ffffffffc0200e9e <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ed6:	70e2                	ld	ra,56(sp)
ffffffffc0200ed8:	8522                	mv	a0,s0
ffffffffc0200eda:	7442                	ld	s0,48(sp)
ffffffffc0200edc:	74a2                	ld	s1,40(sp)
ffffffffc0200ede:	7902                	ld	s2,32(sp)
ffffffffc0200ee0:	69e2                	ld	s3,24(sp)
ffffffffc0200ee2:	6a42                	ld	s4,16(sp)
ffffffffc0200ee4:	6aa2                	ld	s5,8(sp)
ffffffffc0200ee6:	6b02                	ld	s6,0(sp)
ffffffffc0200ee8:	6121                	addi	sp,sp,64
ffffffffc0200eea:	8082                	ret

ffffffffc0200eec <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eec:	100027f3          	csrr	a5,sstatus
ffffffffc0200ef0:	8b89                	andi	a5,a5,2
ffffffffc0200ef2:	e799                	bnez	a5,ffffffffc0200f00 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ef4:	000b2797          	auipc	a5,0xb2
ffffffffc0200ef8:	8c47b783          	ld	a5,-1852(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc0200efc:	739c                	ld	a5,32(a5)
ffffffffc0200efe:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f00:	1101                	addi	sp,sp,-32
ffffffffc0200f02:	ec06                	sd	ra,24(sp)
ffffffffc0200f04:	e822                	sd	s0,16(sp)
ffffffffc0200f06:	e426                	sd	s1,8(sp)
ffffffffc0200f08:	842a                	mv	s0,a0
ffffffffc0200f0a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f0c:	f3cff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f10:	000b2797          	auipc	a5,0xb2
ffffffffc0200f14:	8a87b783          	ld	a5,-1880(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc0200f18:	739c                	ld	a5,32(a5)
ffffffffc0200f1a:	85a6                	mv	a1,s1
ffffffffc0200f1c:	8522                	mv	a0,s0
ffffffffc0200f1e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f20:	6442                	ld	s0,16(sp)
ffffffffc0200f22:	60e2                	ld	ra,24(sp)
ffffffffc0200f24:	64a2                	ld	s1,8(sp)
ffffffffc0200f26:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f28:	f1aff06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0200f2c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f2c:	100027f3          	csrr	a5,sstatus
ffffffffc0200f30:	8b89                	andi	a5,a5,2
ffffffffc0200f32:	e799                	bnez	a5,ffffffffc0200f40 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f34:	000b2797          	auipc	a5,0xb2
ffffffffc0200f38:	8847b783          	ld	a5,-1916(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc0200f3c:	779c                	ld	a5,40(a5)
ffffffffc0200f3e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f40:	1141                	addi	sp,sp,-16
ffffffffc0200f42:	e406                	sd	ra,8(sp)
ffffffffc0200f44:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f46:	f02ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f4a:	000b2797          	auipc	a5,0xb2
ffffffffc0200f4e:	86e7b783          	ld	a5,-1938(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc0200f52:	779c                	ld	a5,40(a5)
ffffffffc0200f54:	9782                	jalr	a5
ffffffffc0200f56:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f58:	eeaff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f5c:	60a2                	ld	ra,8(sp)
ffffffffc0200f5e:	8522                	mv	a0,s0
ffffffffc0200f60:	6402                	ld	s0,0(sp)
ffffffffc0200f62:	0141                	addi	sp,sp,16
ffffffffc0200f64:	8082                	ret

ffffffffc0200f66 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f66:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200f6a:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f6e:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f70:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f72:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f74:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f78:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f7a:	f04a                	sd	s2,32(sp)
ffffffffc0200f7c:	ec4e                	sd	s3,24(sp)
ffffffffc0200f7e:	e852                	sd	s4,16(sp)
ffffffffc0200f80:	fc06                	sd	ra,56(sp)
ffffffffc0200f82:	f822                	sd	s0,48(sp)
ffffffffc0200f84:	e456                	sd	s5,8(sp)
ffffffffc0200f86:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f88:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f8c:	892e                	mv	s2,a1
ffffffffc0200f8e:	89b2                	mv	s3,a2
ffffffffc0200f90:	000b2a17          	auipc	s4,0xb2
ffffffffc0200f94:	818a0a13          	addi	s4,s4,-2024 # ffffffffc02b27a8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f98:	e7b5                	bnez	a5,ffffffffc0201004 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f9a:	12060b63          	beqz	a2,ffffffffc02010d0 <get_pte+0x16a>
ffffffffc0200f9e:	4505                	li	a0,1
ffffffffc0200fa0:	ebbff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200fa4:	842a                	mv	s0,a0
ffffffffc0200fa6:	12050563          	beqz	a0,ffffffffc02010d0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200faa:	000b2b17          	auipc	s6,0xb2
ffffffffc0200fae:	806b0b13          	addi	s6,s6,-2042 # ffffffffc02b27b0 <pages>
ffffffffc0200fb2:	000b3503          	ld	a0,0(s6)
ffffffffc0200fb6:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fba:	000b1a17          	auipc	s4,0xb1
ffffffffc0200fbe:	7eea0a13          	addi	s4,s4,2030 # ffffffffc02b27a8 <npage>
ffffffffc0200fc2:	40a40533          	sub	a0,s0,a0
ffffffffc0200fc6:	8519                	srai	a0,a0,0x6
ffffffffc0200fc8:	9556                	add	a0,a0,s5
ffffffffc0200fca:	000a3703          	ld	a4,0(s4)
ffffffffc0200fce:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fd2:	4685                	li	a3,1
ffffffffc0200fd4:	c014                	sw	a3,0(s0)
ffffffffc0200fd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd8:	0532                	slli	a0,a0,0xc
ffffffffc0200fda:	14e7f263          	bgeu	a5,a4,ffffffffc020111e <get_pte+0x1b8>
ffffffffc0200fde:	000b1797          	auipc	a5,0xb1
ffffffffc0200fe2:	7e27b783          	ld	a5,2018(a5) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0200fe6:	6605                	lui	a2,0x1
ffffffffc0200fe8:	4581                	li	a1,0
ffffffffc0200fea:	953e                	add	a0,a0,a5
ffffffffc0200fec:	1f0050ef          	jal	ra,ffffffffc02061dc <memset>
    return page - pages + nbase;
ffffffffc0200ff0:	000b3683          	ld	a3,0(s6)
ffffffffc0200ff4:	40d406b3          	sub	a3,s0,a3
ffffffffc0200ff8:	8699                	srai	a3,a3,0x6
ffffffffc0200ffa:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ffc:	06aa                	slli	a3,a3,0xa
ffffffffc0200ffe:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201002:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201004:	77fd                	lui	a5,0xfffff
ffffffffc0201006:	068a                	slli	a3,a3,0x2
ffffffffc0201008:	000a3703          	ld	a4,0(s4)
ffffffffc020100c:	8efd                	and	a3,a3,a5
ffffffffc020100e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201012:	0ce7f163          	bgeu	a5,a4,ffffffffc02010d4 <get_pte+0x16e>
ffffffffc0201016:	000b1a97          	auipc	s5,0xb1
ffffffffc020101a:	7aaa8a93          	addi	s5,s5,1962 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc020101e:	000ab403          	ld	s0,0(s5)
ffffffffc0201022:	01595793          	srli	a5,s2,0x15
ffffffffc0201026:	1ff7f793          	andi	a5,a5,511
ffffffffc020102a:	96a2                	add	a3,a3,s0
ffffffffc020102c:	00379413          	slli	s0,a5,0x3
ffffffffc0201030:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201032:	6014                	ld	a3,0(s0)
ffffffffc0201034:	0016f793          	andi	a5,a3,1
ffffffffc0201038:	e3ad                	bnez	a5,ffffffffc020109a <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020103a:	08098b63          	beqz	s3,ffffffffc02010d0 <get_pte+0x16a>
ffffffffc020103e:	4505                	li	a0,1
ffffffffc0201040:	e1bff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201044:	84aa                	mv	s1,a0
ffffffffc0201046:	c549                	beqz	a0,ffffffffc02010d0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201048:	000b1b17          	auipc	s6,0xb1
ffffffffc020104c:	768b0b13          	addi	s6,s6,1896 # ffffffffc02b27b0 <pages>
ffffffffc0201050:	000b3503          	ld	a0,0(s6)
ffffffffc0201054:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201058:	000a3703          	ld	a4,0(s4)
ffffffffc020105c:	40a48533          	sub	a0,s1,a0
ffffffffc0201060:	8519                	srai	a0,a0,0x6
ffffffffc0201062:	954e                	add	a0,a0,s3
ffffffffc0201064:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201068:	4685                	li	a3,1
ffffffffc020106a:	c094                	sw	a3,0(s1)
ffffffffc020106c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020106e:	0532                	slli	a0,a0,0xc
ffffffffc0201070:	08e7fa63          	bgeu	a5,a4,ffffffffc0201104 <get_pte+0x19e>
ffffffffc0201074:	000ab783          	ld	a5,0(s5)
ffffffffc0201078:	6605                	lui	a2,0x1
ffffffffc020107a:	4581                	li	a1,0
ffffffffc020107c:	953e                	add	a0,a0,a5
ffffffffc020107e:	15e050ef          	jal	ra,ffffffffc02061dc <memset>
    return page - pages + nbase;
ffffffffc0201082:	000b3683          	ld	a3,0(s6)
ffffffffc0201086:	40d486b3          	sub	a3,s1,a3
ffffffffc020108a:	8699                	srai	a3,a3,0x6
ffffffffc020108c:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020108e:	06aa                	slli	a3,a3,0xa
ffffffffc0201090:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201094:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201096:	000a3703          	ld	a4,0(s4)
ffffffffc020109a:	068a                	slli	a3,a3,0x2
ffffffffc020109c:	757d                	lui	a0,0xfffff
ffffffffc020109e:	8ee9                	and	a3,a3,a0
ffffffffc02010a0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010a4:	04e7f463          	bgeu	a5,a4,ffffffffc02010ec <get_pte+0x186>
ffffffffc02010a8:	000ab503          	ld	a0,0(s5)
ffffffffc02010ac:	00c95913          	srli	s2,s2,0xc
ffffffffc02010b0:	1ff97913          	andi	s2,s2,511
ffffffffc02010b4:	96aa                	add	a3,a3,a0
ffffffffc02010b6:	00391513          	slli	a0,s2,0x3
ffffffffc02010ba:	9536                	add	a0,a0,a3
}
ffffffffc02010bc:	70e2                	ld	ra,56(sp)
ffffffffc02010be:	7442                	ld	s0,48(sp)
ffffffffc02010c0:	74a2                	ld	s1,40(sp)
ffffffffc02010c2:	7902                	ld	s2,32(sp)
ffffffffc02010c4:	69e2                	ld	s3,24(sp)
ffffffffc02010c6:	6a42                	ld	s4,16(sp)
ffffffffc02010c8:	6aa2                	ld	s5,8(sp)
ffffffffc02010ca:	6b02                	ld	s6,0(sp)
ffffffffc02010cc:	6121                	addi	sp,sp,64
ffffffffc02010ce:	8082                	ret
            return NULL;
ffffffffc02010d0:	4501                	li	a0,0
ffffffffc02010d2:	b7ed                	j	ffffffffc02010bc <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010d4:	00006617          	auipc	a2,0x6
ffffffffc02010d8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0207010 <commands+0x758>
ffffffffc02010dc:	0e300593          	li	a1,227
ffffffffc02010e0:	00006517          	auipc	a0,0x6
ffffffffc02010e4:	f5850513          	addi	a0,a0,-168 # ffffffffc0207038 <commands+0x780>
ffffffffc02010e8:	920ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ec:	00006617          	auipc	a2,0x6
ffffffffc02010f0:	f2460613          	addi	a2,a2,-220 # ffffffffc0207010 <commands+0x758>
ffffffffc02010f4:	0ee00593          	li	a1,238
ffffffffc02010f8:	00006517          	auipc	a0,0x6
ffffffffc02010fc:	f4050513          	addi	a0,a0,-192 # ffffffffc0207038 <commands+0x780>
ffffffffc0201100:	908ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201104:	86aa                	mv	a3,a0
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0207010 <commands+0x758>
ffffffffc020110e:	0eb00593          	li	a1,235
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	f2650513          	addi	a0,a0,-218 # ffffffffc0207038 <commands+0x780>
ffffffffc020111a:	8eeff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020111e:	86aa                	mv	a3,a0
ffffffffc0201120:	00006617          	auipc	a2,0x6
ffffffffc0201124:	ef060613          	addi	a2,a2,-272 # ffffffffc0207010 <commands+0x758>
ffffffffc0201128:	0df00593          	li	a1,223
ffffffffc020112c:	00006517          	auipc	a0,0x6
ffffffffc0201130:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207038 <commands+0x780>
ffffffffc0201134:	8d4ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201138 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201138:	1141                	addi	sp,sp,-16
ffffffffc020113a:	e022                	sd	s0,0(sp)
ffffffffc020113c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020113e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201140:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201142:	e25ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201146:	c011                	beqz	s0,ffffffffc020114a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201148:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020114a:	c511                	beqz	a0,ffffffffc0201156 <get_page+0x1e>
ffffffffc020114c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020114e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201150:	0017f713          	andi	a4,a5,1
ffffffffc0201154:	e709                	bnez	a4,ffffffffc020115e <get_page+0x26>
}
ffffffffc0201156:	60a2                	ld	ra,8(sp)
ffffffffc0201158:	6402                	ld	s0,0(sp)
ffffffffc020115a:	0141                	addi	sp,sp,16
ffffffffc020115c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020115e:	078a                	slli	a5,a5,0x2
ffffffffc0201160:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201162:	000b1717          	auipc	a4,0xb1
ffffffffc0201166:	64673703          	ld	a4,1606(a4) # ffffffffc02b27a8 <npage>
ffffffffc020116a:	00e7ff63          	bgeu	a5,a4,ffffffffc0201188 <get_page+0x50>
ffffffffc020116e:	60a2                	ld	ra,8(sp)
ffffffffc0201170:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201172:	fff80537          	lui	a0,0xfff80
ffffffffc0201176:	97aa                	add	a5,a5,a0
ffffffffc0201178:	079a                	slli	a5,a5,0x6
ffffffffc020117a:	000b1517          	auipc	a0,0xb1
ffffffffc020117e:	63653503          	ld	a0,1590(a0) # ffffffffc02b27b0 <pages>
ffffffffc0201182:	953e                	add	a0,a0,a5
ffffffffc0201184:	0141                	addi	sp,sp,16
ffffffffc0201186:	8082                	ret
ffffffffc0201188:	c9bff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc020118c <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020118c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020118e:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201192:	f486                	sd	ra,104(sp)
ffffffffc0201194:	f0a2                	sd	s0,96(sp)
ffffffffc0201196:	eca6                	sd	s1,88(sp)
ffffffffc0201198:	e8ca                	sd	s2,80(sp)
ffffffffc020119a:	e4ce                	sd	s3,72(sp)
ffffffffc020119c:	e0d2                	sd	s4,64(sp)
ffffffffc020119e:	fc56                	sd	s5,56(sp)
ffffffffc02011a0:	f85a                	sd	s6,48(sp)
ffffffffc02011a2:	f45e                	sd	s7,40(sp)
ffffffffc02011a4:	f062                	sd	s8,32(sp)
ffffffffc02011a6:	ec66                	sd	s9,24(sp)
ffffffffc02011a8:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011aa:	17d2                	slli	a5,a5,0x34
ffffffffc02011ac:	e3ed                	bnez	a5,ffffffffc020128e <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02011ae:	002007b7          	lui	a5,0x200
ffffffffc02011b2:	842e                	mv	s0,a1
ffffffffc02011b4:	0ef5ed63          	bltu	a1,a5,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011b8:	8932                	mv	s2,a2
ffffffffc02011ba:	0ec5fa63          	bgeu	a1,a2,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011be:	4785                	li	a5,1
ffffffffc02011c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02011c2:	0ec7e663          	bltu	a5,a2,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011c6:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011c8:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011ca:	000b1c97          	auipc	s9,0xb1
ffffffffc02011ce:	5dec8c93          	addi	s9,s9,1502 # ffffffffc02b27a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d2:	000b1c17          	auipc	s8,0xb1
ffffffffc02011d6:	5dec0c13          	addi	s8,s8,1502 # ffffffffc02b27b0 <pages>
ffffffffc02011da:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02011de:	000b1d17          	auipc	s10,0xb1
ffffffffc02011e2:	5dad0d13          	addi	s10,s10,1498 # ffffffffc02b27b8 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011e6:	00200b37          	lui	s6,0x200
ffffffffc02011ea:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ee:	4601                	li	a2,0
ffffffffc02011f0:	85a2                	mv	a1,s0
ffffffffc02011f2:	854e                	mv	a0,s3
ffffffffc02011f4:	d73ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02011f8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011fa:	cd29                	beqz	a0,ffffffffc0201254 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02011fc:	611c                	ld	a5,0(a0)
ffffffffc02011fe:	e395                	bnez	a5,ffffffffc0201222 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0201200:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201202:	ff2466e3          	bltu	s0,s2,ffffffffc02011ee <unmap_range+0x62>
}
ffffffffc0201206:	70a6                	ld	ra,104(sp)
ffffffffc0201208:	7406                	ld	s0,96(sp)
ffffffffc020120a:	64e6                	ld	s1,88(sp)
ffffffffc020120c:	6946                	ld	s2,80(sp)
ffffffffc020120e:	69a6                	ld	s3,72(sp)
ffffffffc0201210:	6a06                	ld	s4,64(sp)
ffffffffc0201212:	7ae2                	ld	s5,56(sp)
ffffffffc0201214:	7b42                	ld	s6,48(sp)
ffffffffc0201216:	7ba2                	ld	s7,40(sp)
ffffffffc0201218:	7c02                	ld	s8,32(sp)
ffffffffc020121a:	6ce2                	ld	s9,24(sp)
ffffffffc020121c:	6d42                	ld	s10,16(sp)
ffffffffc020121e:	6165                	addi	sp,sp,112
ffffffffc0201220:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201222:	0017f713          	andi	a4,a5,1
ffffffffc0201226:	df69                	beqz	a4,ffffffffc0201200 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0201228:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020122c:	078a                	slli	a5,a5,0x2
ffffffffc020122e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201230:	08e7ff63          	bgeu	a5,a4,ffffffffc02012ce <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0201234:	000c3503          	ld	a0,0(s8)
ffffffffc0201238:	97de                	add	a5,a5,s7
ffffffffc020123a:	079a                	slli	a5,a5,0x6
ffffffffc020123c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020123e:	411c                	lw	a5,0(a0)
ffffffffc0201240:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201244:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201246:	cf11                	beqz	a4,ffffffffc0201262 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201248:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020124c:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201250:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201252:	bf45                	j	ffffffffc0201202 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201254:	945a                	add	s0,s0,s6
ffffffffc0201256:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020125a:	d455                	beqz	s0,ffffffffc0201206 <unmap_range+0x7a>
ffffffffc020125c:	f92469e3          	bltu	s0,s2,ffffffffc02011ee <unmap_range+0x62>
ffffffffc0201260:	b75d                	j	ffffffffc0201206 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201262:	100027f3          	csrr	a5,sstatus
ffffffffc0201266:	8b89                	andi	a5,a5,2
ffffffffc0201268:	e799                	bnez	a5,ffffffffc0201276 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020126a:	000d3783          	ld	a5,0(s10)
ffffffffc020126e:	4585                	li	a1,1
ffffffffc0201270:	739c                	ld	a5,32(a5)
ffffffffc0201272:	9782                	jalr	a5
    if (flag) {
ffffffffc0201274:	bfd1                	j	ffffffffc0201248 <unmap_range+0xbc>
ffffffffc0201276:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201278:	bd0ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020127c:	000d3783          	ld	a5,0(s10)
ffffffffc0201280:	6522                	ld	a0,8(sp)
ffffffffc0201282:	4585                	li	a1,1
ffffffffc0201284:	739c                	ld	a5,32(a5)
ffffffffc0201286:	9782                	jalr	a5
        intr_enable();
ffffffffc0201288:	bbaff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020128c:	bf75                	j	ffffffffc0201248 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020128e:	00006697          	auipc	a3,0x6
ffffffffc0201292:	dba68693          	addi	a3,a3,-582 # ffffffffc0207048 <commands+0x790>
ffffffffc0201296:	00006617          	auipc	a2,0x6
ffffffffc020129a:	a3260613          	addi	a2,a2,-1486 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020129e:	10f00593          	li	a1,271
ffffffffc02012a2:	00006517          	auipc	a0,0x6
ffffffffc02012a6:	d9650513          	addi	a0,a0,-618 # ffffffffc0207038 <commands+0x780>
ffffffffc02012aa:	f5ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02012ae:	00006697          	auipc	a3,0x6
ffffffffc02012b2:	dca68693          	addi	a3,a3,-566 # ffffffffc0207078 <commands+0x7c0>
ffffffffc02012b6:	00006617          	auipc	a2,0x6
ffffffffc02012ba:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02012be:	11000593          	li	a1,272
ffffffffc02012c2:	00006517          	auipc	a0,0x6
ffffffffc02012c6:	d7650513          	addi	a0,a0,-650 # ffffffffc0207038 <commands+0x780>
ffffffffc02012ca:	f3ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02012ce:	b55ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc02012d2 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012d2:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012d4:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012d8:	fc86                	sd	ra,120(sp)
ffffffffc02012da:	f8a2                	sd	s0,112(sp)
ffffffffc02012dc:	f4a6                	sd	s1,104(sp)
ffffffffc02012de:	f0ca                	sd	s2,96(sp)
ffffffffc02012e0:	ecce                	sd	s3,88(sp)
ffffffffc02012e2:	e8d2                	sd	s4,80(sp)
ffffffffc02012e4:	e4d6                	sd	s5,72(sp)
ffffffffc02012e6:	e0da                	sd	s6,64(sp)
ffffffffc02012e8:	fc5e                	sd	s7,56(sp)
ffffffffc02012ea:	f862                	sd	s8,48(sp)
ffffffffc02012ec:	f466                	sd	s9,40(sp)
ffffffffc02012ee:	f06a                	sd	s10,32(sp)
ffffffffc02012f0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012f2:	17d2                	slli	a5,a5,0x34
ffffffffc02012f4:	20079a63          	bnez	a5,ffffffffc0201508 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02012f8:	002007b7          	lui	a5,0x200
ffffffffc02012fc:	24f5e463          	bltu	a1,a5,ffffffffc0201544 <exit_range+0x272>
ffffffffc0201300:	8ab2                	mv	s5,a2
ffffffffc0201302:	24c5f163          	bgeu	a1,a2,ffffffffc0201544 <exit_range+0x272>
ffffffffc0201306:	4785                	li	a5,1
ffffffffc0201308:	07fe                	slli	a5,a5,0x1f
ffffffffc020130a:	22c7ed63          	bltu	a5,a2,ffffffffc0201544 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020130e:	c00009b7          	lui	s3,0xc0000
ffffffffc0201312:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201316:	ffe00937          	lui	s2,0xffe00
ffffffffc020131a:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020131e:	5cfd                	li	s9,-1
ffffffffc0201320:	8c2a                	mv	s8,a0
ffffffffc0201322:	0125f933          	and	s2,a1,s2
ffffffffc0201326:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0201328:	000b1d17          	auipc	s10,0xb1
ffffffffc020132c:	480d0d13          	addi	s10,s10,1152 # ffffffffc02b27a8 <npage>
    return KADDR(page2pa(page));
ffffffffc0201330:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201334:	000b1717          	auipc	a4,0xb1
ffffffffc0201338:	47c70713          	addi	a4,a4,1148 # ffffffffc02b27b0 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020133c:	000b1d97          	auipc	s11,0xb1
ffffffffc0201340:	47cd8d93          	addi	s11,s11,1148 # ffffffffc02b27b8 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201344:	c0000437          	lui	s0,0xc0000
ffffffffc0201348:	944e                	add	s0,s0,s3
ffffffffc020134a:	8079                	srli	s0,s0,0x1e
ffffffffc020134c:	1ff47413          	andi	s0,s0,511
ffffffffc0201350:	040e                	slli	s0,s0,0x3
ffffffffc0201352:	9462                	add	s0,s0,s8
ffffffffc0201354:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc0201358:	001a7793          	andi	a5,s4,1
ffffffffc020135c:	eb99                	bnez	a5,ffffffffc0201372 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020135e:	12098463          	beqz	s3,ffffffffc0201486 <exit_range+0x1b4>
ffffffffc0201362:	400007b7          	lui	a5,0x40000
ffffffffc0201366:	97ce                	add	a5,a5,s3
ffffffffc0201368:	894e                	mv	s2,s3
ffffffffc020136a:	1159fe63          	bgeu	s3,s5,ffffffffc0201486 <exit_range+0x1b4>
ffffffffc020136e:	89be                	mv	s3,a5
ffffffffc0201370:	bfd1                	j	ffffffffc0201344 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0201372:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201376:	0a0a                	slli	s4,s4,0x2
ffffffffc0201378:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020137c:	1cfa7263          	bgeu	s4,a5,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201380:	fff80637          	lui	a2,0xfff80
ffffffffc0201384:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0201386:	000806b7          	lui	a3,0x80
ffffffffc020138a:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020138c:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0201390:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201392:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201394:	18f5fa63          	bgeu	a1,a5,ffffffffc0201528 <exit_range+0x256>
ffffffffc0201398:	000b1817          	auipc	a6,0xb1
ffffffffc020139c:	42880813          	addi	a6,a6,1064 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc02013a0:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02013a4:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013a6:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013aa:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02013ac:	00080337          	lui	t1,0x80
ffffffffc02013b0:	6885                	lui	a7,0x1
ffffffffc02013b2:	a819                	j	ffffffffc02013c8 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02013b4:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02013b6:	002007b7          	lui	a5,0x200
ffffffffc02013ba:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013bc:	08090c63          	beqz	s2,ffffffffc0201454 <exit_range+0x182>
ffffffffc02013c0:	09397a63          	bgeu	s2,s3,ffffffffc0201454 <exit_range+0x182>
ffffffffc02013c4:	0f597063          	bgeu	s2,s5,ffffffffc02014a4 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013c8:	01595493          	srli	s1,s2,0x15
ffffffffc02013cc:	1ff4f493          	andi	s1,s1,511
ffffffffc02013d0:	048e                	slli	s1,s1,0x3
ffffffffc02013d2:	94da                	add	s1,s1,s6
ffffffffc02013d4:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02013d6:	0017f693          	andi	a3,a5,1
ffffffffc02013da:	dee9                	beqz	a3,ffffffffc02013b4 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02013dc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013e0:	078a                	slli	a5,a5,0x2
ffffffffc02013e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013e4:	14b7fe63          	bgeu	a5,a1,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013e8:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02013ea:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02013ee:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02013f2:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013f8:	12bef863          	bgeu	t4,a1,ffffffffc0201528 <exit_range+0x256>
ffffffffc02013fc:	00083783          	ld	a5,0(a6)
ffffffffc0201400:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201402:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0201406:	629c                	ld	a5,0(a3)
ffffffffc0201408:	8b85                	andi	a5,a5,1
ffffffffc020140a:	f7d5                	bnez	a5,ffffffffc02013b6 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020140c:	06a1                	addi	a3,a3,8
ffffffffc020140e:	fed59ce3          	bne	a1,a3,ffffffffc0201406 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0201412:	631c                	ld	a5,0(a4)
ffffffffc0201414:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201416:	100027f3          	csrr	a5,sstatus
ffffffffc020141a:	8b89                	andi	a5,a5,2
ffffffffc020141c:	e7d9                	bnez	a5,ffffffffc02014aa <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020141e:	000db783          	ld	a5,0(s11)
ffffffffc0201422:	4585                	li	a1,1
ffffffffc0201424:	e032                	sd	a2,0(sp)
ffffffffc0201426:	739c                	ld	a5,32(a5)
ffffffffc0201428:	9782                	jalr	a5
    if (flag) {
ffffffffc020142a:	6602                	ld	a2,0(sp)
ffffffffc020142c:	000b1817          	auipc	a6,0xb1
ffffffffc0201430:	39480813          	addi	a6,a6,916 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0201434:	fff80e37          	lui	t3,0xfff80
ffffffffc0201438:	00080337          	lui	t1,0x80
ffffffffc020143c:	6885                	lui	a7,0x1
ffffffffc020143e:	000b1717          	auipc	a4,0xb1
ffffffffc0201442:	37270713          	addi	a4,a4,882 # ffffffffc02b27b0 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201446:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc020144a:	002007b7          	lui	a5,0x200
ffffffffc020144e:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201450:	f60918e3          	bnez	s2,ffffffffc02013c0 <exit_range+0xee>
            if (free_pd0) {
ffffffffc0201454:	f00b85e3          	beqz	s7,ffffffffc020135e <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0201458:	000d3783          	ld	a5,0(s10)
ffffffffc020145c:	0efa7263          	bgeu	s4,a5,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201460:	6308                	ld	a0,0(a4)
ffffffffc0201462:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201464:	100027f3          	csrr	a5,sstatus
ffffffffc0201468:	8b89                	andi	a5,a5,2
ffffffffc020146a:	efad                	bnez	a5,ffffffffc02014e4 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc020146c:	000db783          	ld	a5,0(s11)
ffffffffc0201470:	4585                	li	a1,1
ffffffffc0201472:	739c                	ld	a5,32(a5)
ffffffffc0201474:	9782                	jalr	a5
ffffffffc0201476:	000b1717          	auipc	a4,0xb1
ffffffffc020147a:	33a70713          	addi	a4,a4,826 # ffffffffc02b27b0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020147e:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0201482:	ee0990e3          	bnez	s3,ffffffffc0201362 <exit_range+0x90>
}
ffffffffc0201486:	70e6                	ld	ra,120(sp)
ffffffffc0201488:	7446                	ld	s0,112(sp)
ffffffffc020148a:	74a6                	ld	s1,104(sp)
ffffffffc020148c:	7906                	ld	s2,96(sp)
ffffffffc020148e:	69e6                	ld	s3,88(sp)
ffffffffc0201490:	6a46                	ld	s4,80(sp)
ffffffffc0201492:	6aa6                	ld	s5,72(sp)
ffffffffc0201494:	6b06                	ld	s6,64(sp)
ffffffffc0201496:	7be2                	ld	s7,56(sp)
ffffffffc0201498:	7c42                	ld	s8,48(sp)
ffffffffc020149a:	7ca2                	ld	s9,40(sp)
ffffffffc020149c:	7d02                	ld	s10,32(sp)
ffffffffc020149e:	6de2                	ld	s11,24(sp)
ffffffffc02014a0:	6109                	addi	sp,sp,128
ffffffffc02014a2:	8082                	ret
            if (free_pd0) {
ffffffffc02014a4:	ea0b8fe3          	beqz	s7,ffffffffc0201362 <exit_range+0x90>
ffffffffc02014a8:	bf45                	j	ffffffffc0201458 <exit_range+0x186>
ffffffffc02014aa:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02014ac:	e42a                	sd	a0,8(sp)
ffffffffc02014ae:	99aff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014b2:	000db783          	ld	a5,0(s11)
ffffffffc02014b6:	6522                	ld	a0,8(sp)
ffffffffc02014b8:	4585                	li	a1,1
ffffffffc02014ba:	739c                	ld	a5,32(a5)
ffffffffc02014bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02014be:	984ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02014c2:	6602                	ld	a2,0(sp)
ffffffffc02014c4:	000b1717          	auipc	a4,0xb1
ffffffffc02014c8:	2ec70713          	addi	a4,a4,748 # ffffffffc02b27b0 <pages>
ffffffffc02014cc:	6885                	lui	a7,0x1
ffffffffc02014ce:	00080337          	lui	t1,0x80
ffffffffc02014d2:	fff80e37          	lui	t3,0xfff80
ffffffffc02014d6:	000b1817          	auipc	a6,0xb1
ffffffffc02014da:	2ea80813          	addi	a6,a6,746 # ffffffffc02b27c0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02014de:	0004b023          	sd	zero,0(s1)
ffffffffc02014e2:	b7a5                	j	ffffffffc020144a <exit_range+0x178>
ffffffffc02014e4:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02014e6:	962ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014ea:	000db783          	ld	a5,0(s11)
ffffffffc02014ee:	6502                	ld	a0,0(sp)
ffffffffc02014f0:	4585                	li	a1,1
ffffffffc02014f2:	739c                	ld	a5,32(a5)
ffffffffc02014f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02014f6:	94cff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02014fa:	000b1717          	auipc	a4,0xb1
ffffffffc02014fe:	2b670713          	addi	a4,a4,694 # ffffffffc02b27b0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201502:	00043023          	sd	zero,0(s0)
ffffffffc0201506:	bfb5                	j	ffffffffc0201482 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201508:	00006697          	auipc	a3,0x6
ffffffffc020150c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0207048 <commands+0x790>
ffffffffc0201510:	00005617          	auipc	a2,0x5
ffffffffc0201514:	7b860613          	addi	a2,a2,1976 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201518:	12000593          	li	a1,288
ffffffffc020151c:	00006517          	auipc	a0,0x6
ffffffffc0201520:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0207038 <commands+0x780>
ffffffffc0201524:	ce5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201528:	00006617          	auipc	a2,0x6
ffffffffc020152c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0207010 <commands+0x758>
ffffffffc0201530:	06900593          	li	a1,105
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206fd8 <commands+0x720>
ffffffffc020153c:	ccdfe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201540:	8e3ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	b3468693          	addi	a3,a3,-1228 # ffffffffc0207078 <commands+0x7c0>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	77c60613          	addi	a2,a2,1916 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201554:	12100593          	li	a1,289
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0207038 <commands+0x780>
ffffffffc0201560:	ca9fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201564 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201564:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201566:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201568:	ec26                	sd	s1,24(sp)
ffffffffc020156a:	f406                	sd	ra,40(sp)
ffffffffc020156c:	f022                	sd	s0,32(sp)
ffffffffc020156e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201570:	9f7ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep != NULL) {
ffffffffc0201574:	c511                	beqz	a0,ffffffffc0201580 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201576:	611c                	ld	a5,0(a0)
ffffffffc0201578:	842a                	mv	s0,a0
ffffffffc020157a:	0017f713          	andi	a4,a5,1
ffffffffc020157e:	e711                	bnez	a4,ffffffffc020158a <page_remove+0x26>
}
ffffffffc0201580:	70a2                	ld	ra,40(sp)
ffffffffc0201582:	7402                	ld	s0,32(sp)
ffffffffc0201584:	64e2                	ld	s1,24(sp)
ffffffffc0201586:	6145                	addi	sp,sp,48
ffffffffc0201588:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020158a:	078a                	slli	a5,a5,0x2
ffffffffc020158c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020158e:	000b1717          	auipc	a4,0xb1
ffffffffc0201592:	21a73703          	ld	a4,538(a4) # ffffffffc02b27a8 <npage>
ffffffffc0201596:	06e7f363          	bgeu	a5,a4,ffffffffc02015fc <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020159a:	fff80537          	lui	a0,0xfff80
ffffffffc020159e:	97aa                	add	a5,a5,a0
ffffffffc02015a0:	079a                	slli	a5,a5,0x6
ffffffffc02015a2:	000b1517          	auipc	a0,0xb1
ffffffffc02015a6:	20e53503          	ld	a0,526(a0) # ffffffffc02b27b0 <pages>
ffffffffc02015aa:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02015ac:	411c                	lw	a5,0(a0)
ffffffffc02015ae:	fff7871b          	addiw	a4,a5,-1
ffffffffc02015b2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02015b4:	cb11                	beqz	a4,ffffffffc02015c8 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02015b6:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015ba:	12048073          	sfence.vma	s1
}
ffffffffc02015be:	70a2                	ld	ra,40(sp)
ffffffffc02015c0:	7402                	ld	s0,32(sp)
ffffffffc02015c2:	64e2                	ld	s1,24(sp)
ffffffffc02015c4:	6145                	addi	sp,sp,48
ffffffffc02015c6:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015c8:	100027f3          	csrr	a5,sstatus
ffffffffc02015cc:	8b89                	andi	a5,a5,2
ffffffffc02015ce:	eb89                	bnez	a5,ffffffffc02015e0 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02015d0:	000b1797          	auipc	a5,0xb1
ffffffffc02015d4:	1e87b783          	ld	a5,488(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc02015d8:	739c                	ld	a5,32(a5)
ffffffffc02015da:	4585                	li	a1,1
ffffffffc02015dc:	9782                	jalr	a5
    if (flag) {
ffffffffc02015de:	bfe1                	j	ffffffffc02015b6 <page_remove+0x52>
        intr_disable();
ffffffffc02015e0:	e42a                	sd	a0,8(sp)
ffffffffc02015e2:	866ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02015e6:	000b1797          	auipc	a5,0xb1
ffffffffc02015ea:	1d27b783          	ld	a5,466(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc02015ee:	739c                	ld	a5,32(a5)
ffffffffc02015f0:	6522                	ld	a0,8(sp)
ffffffffc02015f2:	4585                	li	a1,1
ffffffffc02015f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02015f6:	84cff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02015fa:	bf75                	j	ffffffffc02015b6 <page_remove+0x52>
ffffffffc02015fc:	827ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc0201600 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201600:	7139                	addi	sp,sp,-64
ffffffffc0201602:	e852                	sd	s4,16(sp)
ffffffffc0201604:	8a32                	mv	s4,a2
ffffffffc0201606:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201608:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020160a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020160c:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020160e:	f426                	sd	s1,40(sp)
ffffffffc0201610:	fc06                	sd	ra,56(sp)
ffffffffc0201612:	f04a                	sd	s2,32(sp)
ffffffffc0201614:	ec4e                	sd	s3,24(sp)
ffffffffc0201616:	e456                	sd	s5,8(sp)
ffffffffc0201618:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020161a:	94dff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep == NULL) {
ffffffffc020161e:	c961                	beqz	a0,ffffffffc02016ee <page_insert+0xee>
    page->ref += 1;
ffffffffc0201620:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201622:	611c                	ld	a5,0(a0)
ffffffffc0201624:	89aa                	mv	s3,a0
ffffffffc0201626:	0016871b          	addiw	a4,a3,1
ffffffffc020162a:	c018                	sw	a4,0(s0)
ffffffffc020162c:	0017f713          	andi	a4,a5,1
ffffffffc0201630:	ef05                	bnez	a4,ffffffffc0201668 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201632:	000b1717          	auipc	a4,0xb1
ffffffffc0201636:	17e73703          	ld	a4,382(a4) # ffffffffc02b27b0 <pages>
ffffffffc020163a:	8c19                	sub	s0,s0,a4
ffffffffc020163c:	000807b7          	lui	a5,0x80
ffffffffc0201640:	8419                	srai	s0,s0,0x6
ffffffffc0201642:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201644:	042a                	slli	s0,s0,0xa
ffffffffc0201646:	8cc1                	or	s1,s1,s0
ffffffffc0201648:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020164c:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201650:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201654:	4501                	li	a0,0
}
ffffffffc0201656:	70e2                	ld	ra,56(sp)
ffffffffc0201658:	7442                	ld	s0,48(sp)
ffffffffc020165a:	74a2                	ld	s1,40(sp)
ffffffffc020165c:	7902                	ld	s2,32(sp)
ffffffffc020165e:	69e2                	ld	s3,24(sp)
ffffffffc0201660:	6a42                	ld	s4,16(sp)
ffffffffc0201662:	6aa2                	ld	s5,8(sp)
ffffffffc0201664:	6121                	addi	sp,sp,64
ffffffffc0201666:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201668:	078a                	slli	a5,a5,0x2
ffffffffc020166a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020166c:	000b1717          	auipc	a4,0xb1
ffffffffc0201670:	13c73703          	ld	a4,316(a4) # ffffffffc02b27a8 <npage>
ffffffffc0201674:	06e7ff63          	bgeu	a5,a4,ffffffffc02016f2 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201678:	000b1a97          	auipc	s5,0xb1
ffffffffc020167c:	138a8a93          	addi	s5,s5,312 # ffffffffc02b27b0 <pages>
ffffffffc0201680:	000ab703          	ld	a4,0(s5)
ffffffffc0201684:	fff80937          	lui	s2,0xfff80
ffffffffc0201688:	993e                	add	s2,s2,a5
ffffffffc020168a:	091a                	slli	s2,s2,0x6
ffffffffc020168c:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020168e:	01240c63          	beq	s0,s2,ffffffffc02016a6 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0201692:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd7ec>
ffffffffc0201696:	fff7869b          	addiw	a3,a5,-1
ffffffffc020169a:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020169e:	c691                	beqz	a3,ffffffffc02016aa <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016a0:	120a0073          	sfence.vma	s4
}
ffffffffc02016a4:	bf59                	j	ffffffffc020163a <page_insert+0x3a>
ffffffffc02016a6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02016a8:	bf49                	j	ffffffffc020163a <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016aa:	100027f3          	csrr	a5,sstatus
ffffffffc02016ae:	8b89                	andi	a5,a5,2
ffffffffc02016b0:	ef91                	bnez	a5,ffffffffc02016cc <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02016b2:	000b1797          	auipc	a5,0xb1
ffffffffc02016b6:	1067b783          	ld	a5,262(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc02016ba:	739c                	ld	a5,32(a5)
ffffffffc02016bc:	4585                	li	a1,1
ffffffffc02016be:	854a                	mv	a0,s2
ffffffffc02016c0:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02016c2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016c6:	120a0073          	sfence.vma	s4
ffffffffc02016ca:	bf85                	j	ffffffffc020163a <page_insert+0x3a>
        intr_disable();
ffffffffc02016cc:	f7dfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016d0:	000b1797          	auipc	a5,0xb1
ffffffffc02016d4:	0e87b783          	ld	a5,232(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc02016d8:	739c                	ld	a5,32(a5)
ffffffffc02016da:	4585                	li	a1,1
ffffffffc02016dc:	854a                	mv	a0,s2
ffffffffc02016de:	9782                	jalr	a5
        intr_enable();
ffffffffc02016e0:	f63fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02016e4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016e8:	120a0073          	sfence.vma	s4
ffffffffc02016ec:	b7b9                	j	ffffffffc020163a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02016ee:	5571                	li	a0,-4
ffffffffc02016f0:	b79d                	j	ffffffffc0201656 <page_insert+0x56>
ffffffffc02016f2:	f30ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc02016f6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02016f6:	00007797          	auipc	a5,0x7
ffffffffc02016fa:	c7a78793          	addi	a5,a5,-902 # ffffffffc0208370 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02016fe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201700:	711d                	addi	sp,sp,-96
ffffffffc0201702:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201704:	00006517          	auipc	a0,0x6
ffffffffc0201708:	98c50513          	addi	a0,a0,-1652 # ffffffffc0207090 <commands+0x7d8>
    pmm_manager = &default_pmm_manager;
ffffffffc020170c:	000b1b97          	auipc	s7,0xb1
ffffffffc0201710:	0acb8b93          	addi	s7,s7,172 # ffffffffc02b27b8 <pmm_manager>
void pmm_init(void) {
ffffffffc0201714:	ec86                	sd	ra,88(sp)
ffffffffc0201716:	e4a6                	sd	s1,72(sp)
ffffffffc0201718:	fc4e                	sd	s3,56(sp)
ffffffffc020171a:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020171c:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201720:	e8a2                	sd	s0,80(sp)
ffffffffc0201722:	e0ca                	sd	s2,64(sp)
ffffffffc0201724:	f852                	sd	s4,48(sp)
ffffffffc0201726:	f456                	sd	s5,40(sp)
ffffffffc0201728:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020172a:	9a3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc020172e:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201732:	000b1997          	auipc	s3,0xb1
ffffffffc0201736:	08e98993          	addi	s3,s3,142 # ffffffffc02b27c0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020173a:	000b1497          	auipc	s1,0xb1
ffffffffc020173e:	06e48493          	addi	s1,s1,110 # ffffffffc02b27a8 <npage>
    pmm_manager->init();
ffffffffc0201742:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201744:	000b1b17          	auipc	s6,0xb1
ffffffffc0201748:	06cb0b13          	addi	s6,s6,108 # ffffffffc02b27b0 <pages>
    pmm_manager->init();
ffffffffc020174c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020174e:	57f5                	li	a5,-3
ffffffffc0201750:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201752:	00006517          	auipc	a0,0x6
ffffffffc0201756:	95650513          	addi	a0,a0,-1706 # ffffffffc02070a8 <commands+0x7f0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020175a:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc020175e:	96ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201762:	46c5                	li	a3,17
ffffffffc0201764:	06ee                	slli	a3,a3,0x1b
ffffffffc0201766:	40100613          	li	a2,1025
ffffffffc020176a:	07e005b7          	lui	a1,0x7e00
ffffffffc020176e:	16fd                	addi	a3,a3,-1
ffffffffc0201770:	0656                	slli	a2,a2,0x15
ffffffffc0201772:	00006517          	auipc	a0,0x6
ffffffffc0201776:	94e50513          	addi	a0,a0,-1714 # ffffffffc02070c0 <commands+0x808>
ffffffffc020177a:	953fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020177e:	777d                	lui	a4,0xfffff
ffffffffc0201780:	000b2797          	auipc	a5,0xb2
ffffffffc0201784:	09378793          	addi	a5,a5,147 # ffffffffc02b3813 <end+0xfff>
ffffffffc0201788:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020178a:	00088737          	lui	a4,0x88
ffffffffc020178e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201790:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201794:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201796:	4585                	li	a1,1
ffffffffc0201798:	fff80837          	lui	a6,0xfff80
ffffffffc020179c:	a019                	j	ffffffffc02017a2 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020179e:	000b3783          	ld	a5,0(s6)
ffffffffc02017a2:	00671693          	slli	a3,a4,0x6
ffffffffc02017a6:	97b6                	add	a5,a5,a3
ffffffffc02017a8:	07a1                	addi	a5,a5,8
ffffffffc02017aa:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017ae:	6090                	ld	a2,0(s1)
ffffffffc02017b0:	0705                	addi	a4,a4,1
ffffffffc02017b2:	010607b3          	add	a5,a2,a6
ffffffffc02017b6:	fef764e3          	bltu	a4,a5,ffffffffc020179e <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017ba:	000b3503          	ld	a0,0(s6)
ffffffffc02017be:	079a                	slli	a5,a5,0x6
ffffffffc02017c0:	c0200737          	lui	a4,0xc0200
ffffffffc02017c4:	00f506b3          	add	a3,a0,a5
ffffffffc02017c8:	60e6e563          	bltu	a3,a4,ffffffffc0201dd2 <pmm_init+0x6dc>
ffffffffc02017cc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02017d0:	4745                	li	a4,17
ffffffffc02017d2:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017d4:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02017d6:	4ae6e563          	bltu	a3,a4,ffffffffc0201c80 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02017da:	00006517          	auipc	a0,0x6
ffffffffc02017de:	93650513          	addi	a0,a0,-1738 # ffffffffc0207110 <commands+0x858>
ffffffffc02017e2:	8ebfe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02017e6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017ea:	000b1917          	auipc	s2,0xb1
ffffffffc02017ee:	fb690913          	addi	s2,s2,-74 # ffffffffc02b27a0 <boot_pgdir>
    pmm_manager->check();
ffffffffc02017f2:	7b9c                	ld	a5,48(a5)
ffffffffc02017f4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02017f6:	00006517          	auipc	a0,0x6
ffffffffc02017fa:	93250513          	addi	a0,a0,-1742 # ffffffffc0207128 <commands+0x870>
ffffffffc02017fe:	8cffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201802:	00009697          	auipc	a3,0x9
ffffffffc0201806:	7fe68693          	addi	a3,a3,2046 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020180a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020180e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201812:	5cf6ec63          	bltu	a3,a5,ffffffffc0201dea <pmm_init+0x6f4>
ffffffffc0201816:	0009b783          	ld	a5,0(s3)
ffffffffc020181a:	8e9d                	sub	a3,a3,a5
ffffffffc020181c:	000b1797          	auipc	a5,0xb1
ffffffffc0201820:	f6d7be23          	sd	a3,-132(a5) # ffffffffc02b2798 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201824:	100027f3          	csrr	a5,sstatus
ffffffffc0201828:	8b89                	andi	a5,a5,2
ffffffffc020182a:	48079263          	bnez	a5,ffffffffc0201cae <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020182e:	000bb783          	ld	a5,0(s7)
ffffffffc0201832:	779c                	ld	a5,40(a5)
ffffffffc0201834:	9782                	jalr	a5
ffffffffc0201836:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201838:	6098                	ld	a4,0(s1)
ffffffffc020183a:	c80007b7          	lui	a5,0xc8000
ffffffffc020183e:	83b1                	srli	a5,a5,0xc
ffffffffc0201840:	5ee7e163          	bltu	a5,a4,ffffffffc0201e22 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201844:	00093503          	ld	a0,0(s2)
ffffffffc0201848:	5a050d63          	beqz	a0,ffffffffc0201e02 <pmm_init+0x70c>
ffffffffc020184c:	03451793          	slli	a5,a0,0x34
ffffffffc0201850:	5a079963          	bnez	a5,ffffffffc0201e02 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201854:	4601                	li	a2,0
ffffffffc0201856:	4581                	li	a1,0
ffffffffc0201858:	8e1ff0ef          	jal	ra,ffffffffc0201138 <get_page>
ffffffffc020185c:	62051563          	bnez	a0,ffffffffc0201e86 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201860:	4505                	li	a0,1
ffffffffc0201862:	df8ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201866:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201868:	00093503          	ld	a0,0(s2)
ffffffffc020186c:	4681                	li	a3,0
ffffffffc020186e:	4601                	li	a2,0
ffffffffc0201870:	85d2                	mv	a1,s4
ffffffffc0201872:	d8fff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201876:	5e051863          	bnez	a0,ffffffffc0201e66 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020187a:	00093503          	ld	a0,0(s2)
ffffffffc020187e:	4601                	li	a2,0
ffffffffc0201880:	4581                	li	a1,0
ffffffffc0201882:	ee4ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201886:	5c050063          	beqz	a0,ffffffffc0201e46 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc020188a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020188c:	0017f713          	andi	a4,a5,1
ffffffffc0201890:	5a070963          	beqz	a4,ffffffffc0201e42 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0201894:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201896:	078a                	slli	a5,a5,0x2
ffffffffc0201898:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020189a:	52e7fa63          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020189e:	000b3683          	ld	a3,0(s6)
ffffffffc02018a2:	fff80637          	lui	a2,0xfff80
ffffffffc02018a6:	97b2                	add	a5,a5,a2
ffffffffc02018a8:	079a                	slli	a5,a5,0x6
ffffffffc02018aa:	97b6                	add	a5,a5,a3
ffffffffc02018ac:	10fa16e3          	bne	s4,a5,ffffffffc02021b8 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02018b0:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02018b4:	4785                	li	a5,1
ffffffffc02018b6:	12f69de3          	bne	a3,a5,ffffffffc02021f0 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02018ba:	00093503          	ld	a0,0(s2)
ffffffffc02018be:	77fd                	lui	a5,0xfffff
ffffffffc02018c0:	6114                	ld	a3,0(a0)
ffffffffc02018c2:	068a                	slli	a3,a3,0x2
ffffffffc02018c4:	8efd                	and	a3,a3,a5
ffffffffc02018c6:	00c6d613          	srli	a2,a3,0xc
ffffffffc02018ca:	10e677e3          	bgeu	a2,a4,ffffffffc02021d8 <pmm_init+0xae2>
ffffffffc02018ce:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018d2:	96e2                	add	a3,a3,s8
ffffffffc02018d4:	0006ba83          	ld	s5,0(a3)
ffffffffc02018d8:	0a8a                	slli	s5,s5,0x2
ffffffffc02018da:	00fafab3          	and	s5,s5,a5
ffffffffc02018de:	00cad793          	srli	a5,s5,0xc
ffffffffc02018e2:	62e7f263          	bgeu	a5,a4,ffffffffc0201f06 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018e6:	4601                	li	a2,0
ffffffffc02018e8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018ea:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018ec:	e7aff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018f0:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018f2:	5f551a63          	bne	a0,s5,ffffffffc0201ee6 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02018f6:	4505                	li	a0,1
ffffffffc02018f8:	d62ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02018fc:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02018fe:	00093503          	ld	a0,0(s2)
ffffffffc0201902:	46d1                	li	a3,20
ffffffffc0201904:	6605                	lui	a2,0x1
ffffffffc0201906:	85d6                	mv	a1,s5
ffffffffc0201908:	cf9ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc020190c:	58051d63          	bnez	a0,ffffffffc0201ea6 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201910:	00093503          	ld	a0,0(s2)
ffffffffc0201914:	4601                	li	a2,0
ffffffffc0201916:	6585                	lui	a1,0x1
ffffffffc0201918:	e4eff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc020191c:	0e050ae3          	beqz	a0,ffffffffc0202210 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0201920:	611c                	ld	a5,0(a0)
ffffffffc0201922:	0107f713          	andi	a4,a5,16
ffffffffc0201926:	6e070d63          	beqz	a4,ffffffffc0202020 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc020192a:	8b91                	andi	a5,a5,4
ffffffffc020192c:	6a078a63          	beqz	a5,ffffffffc0201fe0 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201930:	00093503          	ld	a0,0(s2)
ffffffffc0201934:	611c                	ld	a5,0(a0)
ffffffffc0201936:	8bc1                	andi	a5,a5,16
ffffffffc0201938:	68078463          	beqz	a5,ffffffffc0201fc0 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020193c:	000aa703          	lw	a4,0(s5)
ffffffffc0201940:	4785                	li	a5,1
ffffffffc0201942:	58f71263          	bne	a4,a5,ffffffffc0201ec6 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201946:	4681                	li	a3,0
ffffffffc0201948:	6605                	lui	a2,0x1
ffffffffc020194a:	85d2                	mv	a1,s4
ffffffffc020194c:	cb5ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201950:	62051863          	bnez	a0,ffffffffc0201f80 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0201954:	000a2703          	lw	a4,0(s4)
ffffffffc0201958:	4789                	li	a5,2
ffffffffc020195a:	60f71363          	bne	a4,a5,ffffffffc0201f60 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020195e:	000aa783          	lw	a5,0(s5)
ffffffffc0201962:	5c079f63          	bnez	a5,ffffffffc0201f40 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201966:	00093503          	ld	a0,0(s2)
ffffffffc020196a:	4601                	li	a2,0
ffffffffc020196c:	6585                	lui	a1,0x1
ffffffffc020196e:	df8ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201972:	5a050763          	beqz	a0,ffffffffc0201f20 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0201976:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201978:	00177793          	andi	a5,a4,1
ffffffffc020197c:	4c078363          	beqz	a5,ffffffffc0201e42 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0201980:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201982:	00271793          	slli	a5,a4,0x2
ffffffffc0201986:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201988:	44d7f363          	bgeu	a5,a3,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020198c:	000b3683          	ld	a3,0(s6)
ffffffffc0201990:	fff80637          	lui	a2,0xfff80
ffffffffc0201994:	97b2                	add	a5,a5,a2
ffffffffc0201996:	079a                	slli	a5,a5,0x6
ffffffffc0201998:	97b6                	add	a5,a5,a3
ffffffffc020199a:	6efa1363          	bne	s4,a5,ffffffffc0202080 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020199e:	8b41                	andi	a4,a4,16
ffffffffc02019a0:	6c071063          	bnez	a4,ffffffffc0202060 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02019a4:	00093503          	ld	a0,0(s2)
ffffffffc02019a8:	4581                	li	a1,0
ffffffffc02019aa:	bbbff0ef          	jal	ra,ffffffffc0201564 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02019ae:	000a2703          	lw	a4,0(s4)
ffffffffc02019b2:	4785                	li	a5,1
ffffffffc02019b4:	68f71663          	bne	a4,a5,ffffffffc0202040 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02019b8:	000aa783          	lw	a5,0(s5)
ffffffffc02019bc:	74079e63          	bnez	a5,ffffffffc0202118 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02019c0:	00093503          	ld	a0,0(s2)
ffffffffc02019c4:	6585                	lui	a1,0x1
ffffffffc02019c6:	b9fff0ef          	jal	ra,ffffffffc0201564 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02019ca:	000a2783          	lw	a5,0(s4)
ffffffffc02019ce:	72079563          	bnez	a5,ffffffffc02020f8 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02019d2:	000aa783          	lw	a5,0(s5)
ffffffffc02019d6:	70079163          	bnez	a5,ffffffffc02020d8 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02019da:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02019de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019e0:	000a3683          	ld	a3,0(s4)
ffffffffc02019e4:	068a                	slli	a3,a3,0x2
ffffffffc02019e6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019e8:	3ee6f363          	bgeu	a3,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02019ec:	fff807b7          	lui	a5,0xfff80
ffffffffc02019f0:	000b3503          	ld	a0,0(s6)
ffffffffc02019f4:	96be                	add	a3,a3,a5
ffffffffc02019f6:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02019f8:	00d507b3          	add	a5,a0,a3
ffffffffc02019fc:	4390                	lw	a2,0(a5)
ffffffffc02019fe:	4785                	li	a5,1
ffffffffc0201a00:	6af61c63          	bne	a2,a5,ffffffffc02020b8 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0201a04:	8699                	srai	a3,a3,0x6
ffffffffc0201a06:	000805b7          	lui	a1,0x80
ffffffffc0201a0a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0201a0c:	00c69613          	slli	a2,a3,0xc
ffffffffc0201a10:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a12:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201a14:	68e67663          	bgeu	a2,a4,ffffffffc02020a0 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201a18:	0009b603          	ld	a2,0(s3)
ffffffffc0201a1c:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a1e:	629c                	ld	a5,0(a3)
ffffffffc0201a20:	078a                	slli	a5,a5,0x2
ffffffffc0201a22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a24:	3ae7f563          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a28:	8f8d                	sub	a5,a5,a1
ffffffffc0201a2a:	079a                	slli	a5,a5,0x6
ffffffffc0201a2c:	953e                	add	a0,a0,a5
ffffffffc0201a2e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a32:	8b89                	andi	a5,a5,2
ffffffffc0201a34:	2c079763          	bnez	a5,ffffffffc0201d02 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0201a38:	000bb783          	ld	a5,0(s7)
ffffffffc0201a3c:	4585                	li	a1,1
ffffffffc0201a3e:	739c                	ld	a5,32(a5)
ffffffffc0201a40:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a42:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201a46:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a48:	078a                	slli	a5,a5,0x2
ffffffffc0201a4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a4c:	38e7f163          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a50:	000b3503          	ld	a0,0(s6)
ffffffffc0201a54:	fff80737          	lui	a4,0xfff80
ffffffffc0201a58:	97ba                	add	a5,a5,a4
ffffffffc0201a5a:	079a                	slli	a5,a5,0x6
ffffffffc0201a5c:	953e                	add	a0,a0,a5
ffffffffc0201a5e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a62:	8b89                	andi	a5,a5,2
ffffffffc0201a64:	28079363          	bnez	a5,ffffffffc0201cea <pmm_init+0x5f4>
ffffffffc0201a68:	000bb783          	ld	a5,0(s7)
ffffffffc0201a6c:	4585                	li	a1,1
ffffffffc0201a6e:	739c                	ld	a5,32(a5)
ffffffffc0201a70:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201a72:	00093783          	ld	a5,0(s2)
ffffffffc0201a76:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd7ec>
  asm volatile("sfence.vma");
ffffffffc0201a7a:	12000073          	sfence.vma
ffffffffc0201a7e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a82:	8b89                	andi	a5,a5,2
ffffffffc0201a84:	24079963          	bnez	a5,ffffffffc0201cd6 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201a88:	000bb783          	ld	a5,0(s7)
ffffffffc0201a8c:	779c                	ld	a5,40(a5)
ffffffffc0201a8e:	9782                	jalr	a5
ffffffffc0201a90:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201a92:	71441363          	bne	s0,s4,ffffffffc0202198 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201a96:	00006517          	auipc	a0,0x6
ffffffffc0201a9a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0207410 <commands+0xb58>
ffffffffc0201a9e:	e2efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201aa2:	100027f3          	csrr	a5,sstatus
ffffffffc0201aa6:	8b89                	andi	a5,a5,2
ffffffffc0201aa8:	20079d63          	bnez	a5,ffffffffc0201cc2 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201aac:	000bb783          	ld	a5,0(s7)
ffffffffc0201ab0:	779c                	ld	a5,40(a5)
ffffffffc0201ab2:	9782                	jalr	a5
ffffffffc0201ab4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ab6:	6098                	ld	a4,0(s1)
ffffffffc0201ab8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201abc:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201abe:	00c71793          	slli	a5,a4,0xc
ffffffffc0201ac2:	6a05                	lui	s4,0x1
ffffffffc0201ac4:	02f47c63          	bgeu	s0,a5,ffffffffc0201afc <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ac8:	00c45793          	srli	a5,s0,0xc
ffffffffc0201acc:	00093503          	ld	a0,0(s2)
ffffffffc0201ad0:	2ee7f263          	bgeu	a5,a4,ffffffffc0201db4 <pmm_init+0x6be>
ffffffffc0201ad4:	0009b583          	ld	a1,0(s3)
ffffffffc0201ad8:	4601                	li	a2,0
ffffffffc0201ada:	95a2                	add	a1,a1,s0
ffffffffc0201adc:	c8aff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201ae0:	2a050a63          	beqz	a0,ffffffffc0201d94 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ae4:	611c                	ld	a5,0(a0)
ffffffffc0201ae6:	078a                	slli	a5,a5,0x2
ffffffffc0201ae8:	0157f7b3          	and	a5,a5,s5
ffffffffc0201aec:	28879463          	bne	a5,s0,ffffffffc0201d74 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201af0:	6098                	ld	a4,0(s1)
ffffffffc0201af2:	9452                	add	s0,s0,s4
ffffffffc0201af4:	00c71793          	slli	a5,a4,0xc
ffffffffc0201af8:	fcf468e3          	bltu	s0,a5,ffffffffc0201ac8 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201afc:	00093783          	ld	a5,0(s2)
ffffffffc0201b00:	639c                	ld	a5,0(a5)
ffffffffc0201b02:	66079b63          	bnez	a5,ffffffffc0202178 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0201b06:	4505                	li	a0,1
ffffffffc0201b08:	b52ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201b0c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201b0e:	00093503          	ld	a0,0(s2)
ffffffffc0201b12:	4699                	li	a3,6
ffffffffc0201b14:	10000613          	li	a2,256
ffffffffc0201b18:	85d6                	mv	a1,s5
ffffffffc0201b1a:	ae7ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201b1e:	62051d63          	bnez	a0,ffffffffc0202158 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0201b22:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c7ec>
ffffffffc0201b26:	4785                	li	a5,1
ffffffffc0201b28:	60f71863          	bne	a4,a5,ffffffffc0202138 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201b2c:	00093503          	ld	a0,0(s2)
ffffffffc0201b30:	6405                	lui	s0,0x1
ffffffffc0201b32:	4699                	li	a3,6
ffffffffc0201b34:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc0201b38:	85d6                	mv	a1,s5
ffffffffc0201b3a:	ac7ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201b3e:	46051163          	bnez	a0,ffffffffc0201fa0 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0201b42:	000aa703          	lw	a4,0(s5)
ffffffffc0201b46:	4789                	li	a5,2
ffffffffc0201b48:	72f71463          	bne	a4,a5,ffffffffc0202270 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201b4c:	00006597          	auipc	a1,0x6
ffffffffc0201b50:	9fc58593          	addi	a1,a1,-1540 # ffffffffc0207548 <commands+0xc90>
ffffffffc0201b54:	10000513          	li	a0,256
ffffffffc0201b58:	63e040ef          	jal	ra,ffffffffc0206196 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201b5c:	10040593          	addi	a1,s0,256
ffffffffc0201b60:	10000513          	li	a0,256
ffffffffc0201b64:	644040ef          	jal	ra,ffffffffc02061a8 <strcmp>
ffffffffc0201b68:	6e051463          	bnez	a0,ffffffffc0202250 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0201b6c:	000b3683          	ld	a3,0(s6)
ffffffffc0201b70:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201b74:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0201b76:	40da86b3          	sub	a3,s5,a3
ffffffffc0201b7a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201b7c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201b7e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201b80:	8031                	srli	s0,s0,0xc
ffffffffc0201b82:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b88:	50f77c63          	bgeu	a4,a5,ffffffffc02020a0 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b8c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b90:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b94:	96be                	add	a3,a3,a5
ffffffffc0201b96:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b9a:	5c6040ef          	jal	ra,ffffffffc0206160 <strlen>
ffffffffc0201b9e:	68051963          	bnez	a0,ffffffffc0202230 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ba2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201ba6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ba8:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0201bac:	068a                	slli	a3,a3,0x2
ffffffffc0201bae:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bb0:	20f6ff63          	bgeu	a3,a5,ffffffffc0201dce <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0201bb4:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bb6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201bb8:	4ef47463          	bgeu	s0,a5,ffffffffc02020a0 <pmm_init+0x9aa>
ffffffffc0201bbc:	0009b403          	ld	s0,0(s3)
ffffffffc0201bc0:	9436                	add	s0,s0,a3
ffffffffc0201bc2:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc6:	8b89                	andi	a5,a5,2
ffffffffc0201bc8:	18079b63          	bnez	a5,ffffffffc0201d5e <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0201bcc:	000bb783          	ld	a5,0(s7)
ffffffffc0201bd0:	4585                	li	a1,1
ffffffffc0201bd2:	8556                	mv	a0,s5
ffffffffc0201bd4:	739c                	ld	a5,32(a5)
ffffffffc0201bd6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bd8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201bda:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bdc:	078a                	slli	a5,a5,0x2
ffffffffc0201bde:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201be0:	1ee7f763          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201be4:	000b3503          	ld	a0,0(s6)
ffffffffc0201be8:	fff80737          	lui	a4,0xfff80
ffffffffc0201bec:	97ba                	add	a5,a5,a4
ffffffffc0201bee:	079a                	slli	a5,a5,0x6
ffffffffc0201bf0:	953e                	add	a0,a0,a5
ffffffffc0201bf2:	100027f3          	csrr	a5,sstatus
ffffffffc0201bf6:	8b89                	andi	a5,a5,2
ffffffffc0201bf8:	14079763          	bnez	a5,ffffffffc0201d46 <pmm_init+0x650>
ffffffffc0201bfc:	000bb783          	ld	a5,0(s7)
ffffffffc0201c00:	4585                	li	a1,1
ffffffffc0201c02:	739c                	ld	a5,32(a5)
ffffffffc0201c04:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c06:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201c0a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c0c:	078a                	slli	a5,a5,0x2
ffffffffc0201c0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c10:	1ae7ff63          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c14:	000b3503          	ld	a0,0(s6)
ffffffffc0201c18:	fff80737          	lui	a4,0xfff80
ffffffffc0201c1c:	97ba                	add	a5,a5,a4
ffffffffc0201c1e:	079a                	slli	a5,a5,0x6
ffffffffc0201c20:	953e                	add	a0,a0,a5
ffffffffc0201c22:	100027f3          	csrr	a5,sstatus
ffffffffc0201c26:	8b89                	andi	a5,a5,2
ffffffffc0201c28:	10079363          	bnez	a5,ffffffffc0201d2e <pmm_init+0x638>
ffffffffc0201c2c:	000bb783          	ld	a5,0(s7)
ffffffffc0201c30:	4585                	li	a1,1
ffffffffc0201c32:	739c                	ld	a5,32(a5)
ffffffffc0201c34:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201c36:	00093783          	ld	a5,0(s2)
ffffffffc0201c3a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201c3e:	12000073          	sfence.vma
ffffffffc0201c42:	100027f3          	csrr	a5,sstatus
ffffffffc0201c46:	8b89                	andi	a5,a5,2
ffffffffc0201c48:	0c079963          	bnez	a5,ffffffffc0201d1a <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c4c:	000bb783          	ld	a5,0(s7)
ffffffffc0201c50:	779c                	ld	a5,40(a5)
ffffffffc0201c52:	9782                	jalr	a5
ffffffffc0201c54:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201c56:	3a8c1563          	bne	s8,s0,ffffffffc0202000 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201c5a:	00006517          	auipc	a0,0x6
ffffffffc0201c5e:	96650513          	addi	a0,a0,-1690 # ffffffffc02075c0 <commands+0xd08>
ffffffffc0201c62:	c6afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201c66:	6446                	ld	s0,80(sp)
ffffffffc0201c68:	60e6                	ld	ra,88(sp)
ffffffffc0201c6a:	64a6                	ld	s1,72(sp)
ffffffffc0201c6c:	6906                	ld	s2,64(sp)
ffffffffc0201c6e:	79e2                	ld	s3,56(sp)
ffffffffc0201c70:	7a42                	ld	s4,48(sp)
ffffffffc0201c72:	7aa2                	ld	s5,40(sp)
ffffffffc0201c74:	7b02                	ld	s6,32(sp)
ffffffffc0201c76:	6be2                	ld	s7,24(sp)
ffffffffc0201c78:	6c42                	ld	s8,16(sp)
ffffffffc0201c7a:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0201c7c:	1890106f          	j	ffffffffc0203604 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201c80:	6785                	lui	a5,0x1
ffffffffc0201c82:	17fd                	addi	a5,a5,-1
ffffffffc0201c84:	96be                	add	a3,a3,a5
ffffffffc0201c86:	77fd                	lui	a5,0xfffff
ffffffffc0201c88:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c8a:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201c8e:	14c6f063          	bgeu	a3,a2,ffffffffc0201dce <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0201c92:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0201c96:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201c98:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201c9c:	6a10                	ld	a2,16(a2)
ffffffffc0201c9e:	069a                	slli	a3,a3,0x6
ffffffffc0201ca0:	00c7d593          	srli	a1,a5,0xc
ffffffffc0201ca4:	9536                	add	a0,a0,a3
ffffffffc0201ca6:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201ca8:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201cac:	b63d                	j	ffffffffc02017da <pmm_init+0xe4>
        intr_disable();
ffffffffc0201cae:	99bfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cb2:	000bb783          	ld	a5,0(s7)
ffffffffc0201cb6:	779c                	ld	a5,40(a5)
ffffffffc0201cb8:	9782                	jalr	a5
ffffffffc0201cba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cbc:	987fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201cc0:	bea5                	j	ffffffffc0201838 <pmm_init+0x142>
        intr_disable();
ffffffffc0201cc2:	987fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201cc6:	000bb783          	ld	a5,0(s7)
ffffffffc0201cca:	779c                	ld	a5,40(a5)
ffffffffc0201ccc:	9782                	jalr	a5
ffffffffc0201cce:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201cd0:	973fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201cd4:	b3cd                	j	ffffffffc0201ab6 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0201cd6:	973fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201cda:	000bb783          	ld	a5,0(s7)
ffffffffc0201cde:	779c                	ld	a5,40(a5)
ffffffffc0201ce0:	9782                	jalr	a5
ffffffffc0201ce2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201ce4:	95ffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201ce8:	b36d                	j	ffffffffc0201a92 <pmm_init+0x39c>
ffffffffc0201cea:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201cec:	95dfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201cf0:	000bb783          	ld	a5,0(s7)
ffffffffc0201cf4:	6522                	ld	a0,8(sp)
ffffffffc0201cf6:	4585                	li	a1,1
ffffffffc0201cf8:	739c                	ld	a5,32(a5)
ffffffffc0201cfa:	9782                	jalr	a5
        intr_enable();
ffffffffc0201cfc:	947fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d00:	bb8d                	j	ffffffffc0201a72 <pmm_init+0x37c>
ffffffffc0201d02:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d04:	945fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d08:	000bb783          	ld	a5,0(s7)
ffffffffc0201d0c:	6522                	ld	a0,8(sp)
ffffffffc0201d0e:	4585                	li	a1,1
ffffffffc0201d10:	739c                	ld	a5,32(a5)
ffffffffc0201d12:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d14:	92ffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d18:	b32d                	j	ffffffffc0201a42 <pmm_init+0x34c>
        intr_disable();
ffffffffc0201d1a:	92ffe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d1e:	000bb783          	ld	a5,0(s7)
ffffffffc0201d22:	779c                	ld	a5,40(a5)
ffffffffc0201d24:	9782                	jalr	a5
ffffffffc0201d26:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d28:	91bfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d2c:	b72d                	j	ffffffffc0201c56 <pmm_init+0x560>
ffffffffc0201d2e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d30:	919fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d34:	000bb783          	ld	a5,0(s7)
ffffffffc0201d38:	6522                	ld	a0,8(sp)
ffffffffc0201d3a:	4585                	li	a1,1
ffffffffc0201d3c:	739c                	ld	a5,32(a5)
ffffffffc0201d3e:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d40:	903fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d44:	bdcd                	j	ffffffffc0201c36 <pmm_init+0x540>
ffffffffc0201d46:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d48:	901fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d4c:	000bb783          	ld	a5,0(s7)
ffffffffc0201d50:	6522                	ld	a0,8(sp)
ffffffffc0201d52:	4585                	li	a1,1
ffffffffc0201d54:	739c                	ld	a5,32(a5)
ffffffffc0201d56:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d58:	8ebfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d5c:	b56d                	j	ffffffffc0201c06 <pmm_init+0x510>
        intr_disable();
ffffffffc0201d5e:	8ebfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d62:	000bb783          	ld	a5,0(s7)
ffffffffc0201d66:	4585                	li	a1,1
ffffffffc0201d68:	8556                	mv	a0,s5
ffffffffc0201d6a:	739c                	ld	a5,32(a5)
ffffffffc0201d6c:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d6e:	8d5fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d72:	b59d                	j	ffffffffc0201bd8 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d74:	00005697          	auipc	a3,0x5
ffffffffc0201d78:	6fc68693          	addi	a3,a3,1788 # ffffffffc0207470 <commands+0xbb8>
ffffffffc0201d7c:	00005617          	auipc	a2,0x5
ffffffffc0201d80:	f4c60613          	addi	a2,a2,-180 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201d84:	22f00593          	li	a1,559
ffffffffc0201d88:	00005517          	auipc	a0,0x5
ffffffffc0201d8c:	2b050513          	addi	a0,a0,688 # ffffffffc0207038 <commands+0x780>
ffffffffc0201d90:	c78fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201d94:	00005697          	auipc	a3,0x5
ffffffffc0201d98:	69c68693          	addi	a3,a3,1692 # ffffffffc0207430 <commands+0xb78>
ffffffffc0201d9c:	00005617          	auipc	a2,0x5
ffffffffc0201da0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201da4:	22e00593          	li	a1,558
ffffffffc0201da8:	00005517          	auipc	a0,0x5
ffffffffc0201dac:	29050513          	addi	a0,a0,656 # ffffffffc0207038 <commands+0x780>
ffffffffc0201db0:	c58fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201db4:	86a2                	mv	a3,s0
ffffffffc0201db6:	00005617          	auipc	a2,0x5
ffffffffc0201dba:	25a60613          	addi	a2,a2,602 # ffffffffc0207010 <commands+0x758>
ffffffffc0201dbe:	22e00593          	li	a1,558
ffffffffc0201dc2:	00005517          	auipc	a0,0x5
ffffffffc0201dc6:	27650513          	addi	a0,a0,630 # ffffffffc0207038 <commands+0x780>
ffffffffc0201dca:	c3efe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201dce:	854ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201dd2:	00005617          	auipc	a2,0x5
ffffffffc0201dd6:	31660613          	addi	a2,a2,790 # ffffffffc02070e8 <commands+0x830>
ffffffffc0201dda:	07f00593          	li	a1,127
ffffffffc0201dde:	00005517          	auipc	a0,0x5
ffffffffc0201de2:	25a50513          	addi	a0,a0,602 # ffffffffc0207038 <commands+0x780>
ffffffffc0201de6:	c22fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201dea:	00005617          	auipc	a2,0x5
ffffffffc0201dee:	2fe60613          	addi	a2,a2,766 # ffffffffc02070e8 <commands+0x830>
ffffffffc0201df2:	0c100593          	li	a1,193
ffffffffc0201df6:	00005517          	auipc	a0,0x5
ffffffffc0201dfa:	24250513          	addi	a0,a0,578 # ffffffffc0207038 <commands+0x780>
ffffffffc0201dfe:	c0afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201e02:	00005697          	auipc	a3,0x5
ffffffffc0201e06:	36668693          	addi	a3,a3,870 # ffffffffc0207168 <commands+0x8b0>
ffffffffc0201e0a:	00005617          	auipc	a2,0x5
ffffffffc0201e0e:	ebe60613          	addi	a2,a2,-322 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201e12:	1f200593          	li	a1,498
ffffffffc0201e16:	00005517          	auipc	a0,0x5
ffffffffc0201e1a:	22250513          	addi	a0,a0,546 # ffffffffc0207038 <commands+0x780>
ffffffffc0201e1e:	beafe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201e22:	00005697          	auipc	a3,0x5
ffffffffc0201e26:	32668693          	addi	a3,a3,806 # ffffffffc0207148 <commands+0x890>
ffffffffc0201e2a:	00005617          	auipc	a2,0x5
ffffffffc0201e2e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201e32:	1f100593          	li	a1,497
ffffffffc0201e36:	00005517          	auipc	a0,0x5
ffffffffc0201e3a:	20250513          	addi	a0,a0,514 # ffffffffc0207038 <commands+0x780>
ffffffffc0201e3e:	bcafe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201e42:	ffdfe0ef          	jal	ra,ffffffffc0200e3e <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201e46:	00005697          	auipc	a3,0x5
ffffffffc0201e4a:	3b268693          	addi	a3,a3,946 # ffffffffc02071f8 <commands+0x940>
ffffffffc0201e4e:	00005617          	auipc	a2,0x5
ffffffffc0201e52:	e7a60613          	addi	a2,a2,-390 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201e56:	1fa00593          	li	a1,506
ffffffffc0201e5a:	00005517          	auipc	a0,0x5
ffffffffc0201e5e:	1de50513          	addi	a0,a0,478 # ffffffffc0207038 <commands+0x780>
ffffffffc0201e62:	ba6fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201e66:	00005697          	auipc	a3,0x5
ffffffffc0201e6a:	36268693          	addi	a3,a3,866 # ffffffffc02071c8 <commands+0x910>
ffffffffc0201e6e:	00005617          	auipc	a2,0x5
ffffffffc0201e72:	e5a60613          	addi	a2,a2,-422 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201e76:	1f700593          	li	a1,503
ffffffffc0201e7a:	00005517          	auipc	a0,0x5
ffffffffc0201e7e:	1be50513          	addi	a0,a0,446 # ffffffffc0207038 <commands+0x780>
ffffffffc0201e82:	b86fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201e86:	00005697          	auipc	a3,0x5
ffffffffc0201e8a:	31a68693          	addi	a3,a3,794 # ffffffffc02071a0 <commands+0x8e8>
ffffffffc0201e8e:	00005617          	auipc	a2,0x5
ffffffffc0201e92:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201e96:	1f300593          	li	a1,499
ffffffffc0201e9a:	00005517          	auipc	a0,0x5
ffffffffc0201e9e:	19e50513          	addi	a0,a0,414 # ffffffffc0207038 <commands+0x780>
ffffffffc0201ea2:	b66fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201ea6:	00005697          	auipc	a3,0x5
ffffffffc0201eaa:	3da68693          	addi	a3,a3,986 # ffffffffc0207280 <commands+0x9c8>
ffffffffc0201eae:	00005617          	auipc	a2,0x5
ffffffffc0201eb2:	e1a60613          	addi	a2,a2,-486 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201eb6:	20300593          	li	a1,515
ffffffffc0201eba:	00005517          	auipc	a0,0x5
ffffffffc0201ebe:	17e50513          	addi	a0,a0,382 # ffffffffc0207038 <commands+0x780>
ffffffffc0201ec2:	b46fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201ec6:	00005697          	auipc	a3,0x5
ffffffffc0201eca:	45a68693          	addi	a3,a3,1114 # ffffffffc0207320 <commands+0xa68>
ffffffffc0201ece:	00005617          	auipc	a2,0x5
ffffffffc0201ed2:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201ed6:	20800593          	li	a1,520
ffffffffc0201eda:	00005517          	auipc	a0,0x5
ffffffffc0201ede:	15e50513          	addi	a0,a0,350 # ffffffffc0207038 <commands+0x780>
ffffffffc0201ee2:	b26fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ee6:	00005697          	auipc	a3,0x5
ffffffffc0201eea:	37268693          	addi	a3,a3,882 # ffffffffc0207258 <commands+0x9a0>
ffffffffc0201eee:	00005617          	auipc	a2,0x5
ffffffffc0201ef2:	dda60613          	addi	a2,a2,-550 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201ef6:	20000593          	li	a1,512
ffffffffc0201efa:	00005517          	auipc	a0,0x5
ffffffffc0201efe:	13e50513          	addi	a0,a0,318 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f02:	b06fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201f06:	86d6                	mv	a3,s5
ffffffffc0201f08:	00005617          	auipc	a2,0x5
ffffffffc0201f0c:	10860613          	addi	a2,a2,264 # ffffffffc0207010 <commands+0x758>
ffffffffc0201f10:	1ff00593          	li	a1,511
ffffffffc0201f14:	00005517          	auipc	a0,0x5
ffffffffc0201f18:	12450513          	addi	a0,a0,292 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f1c:	aecfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201f20:	00005697          	auipc	a3,0x5
ffffffffc0201f24:	39868693          	addi	a3,a3,920 # ffffffffc02072b8 <commands+0xa00>
ffffffffc0201f28:	00005617          	auipc	a2,0x5
ffffffffc0201f2c:	da060613          	addi	a2,a2,-608 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201f30:	20d00593          	li	a1,525
ffffffffc0201f34:	00005517          	auipc	a0,0x5
ffffffffc0201f38:	10450513          	addi	a0,a0,260 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f3c:	accfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201f40:	00005697          	auipc	a3,0x5
ffffffffc0201f44:	44068693          	addi	a3,a3,1088 # ffffffffc0207380 <commands+0xac8>
ffffffffc0201f48:	00005617          	auipc	a2,0x5
ffffffffc0201f4c:	d8060613          	addi	a2,a2,-640 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201f50:	20c00593          	li	a1,524
ffffffffc0201f54:	00005517          	auipc	a0,0x5
ffffffffc0201f58:	0e450513          	addi	a0,a0,228 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f5c:	aacfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	40868693          	addi	a3,a3,1032 # ffffffffc0207368 <commands+0xab0>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	d6060613          	addi	a2,a2,-672 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201f70:	20b00593          	li	a1,523
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	0c450513          	addi	a0,a0,196 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f7c:	a8cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	3b868693          	addi	a3,a3,952 # ffffffffc0207338 <commands+0xa80>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201f90:	20a00593          	li	a1,522
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	0a450513          	addi	a0,a0,164 # ffffffffc0207038 <commands+0x780>
ffffffffc0201f9c:	a6cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fa0:	00005697          	auipc	a3,0x5
ffffffffc0201fa4:	55068693          	addi	a3,a3,1360 # ffffffffc02074f0 <commands+0xc38>
ffffffffc0201fa8:	00005617          	auipc	a2,0x5
ffffffffc0201fac:	d2060613          	addi	a2,a2,-736 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201fb0:	23900593          	li	a1,569
ffffffffc0201fb4:	00005517          	auipc	a0,0x5
ffffffffc0201fb8:	08450513          	addi	a0,a0,132 # ffffffffc0207038 <commands+0x780>
ffffffffc0201fbc:	a4cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201fc0:	00005697          	auipc	a3,0x5
ffffffffc0201fc4:	34868693          	addi	a3,a3,840 # ffffffffc0207308 <commands+0xa50>
ffffffffc0201fc8:	00005617          	auipc	a2,0x5
ffffffffc0201fcc:	d0060613          	addi	a2,a2,-768 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201fd0:	20700593          	li	a1,519
ffffffffc0201fd4:	00005517          	auipc	a0,0x5
ffffffffc0201fd8:	06450513          	addi	a0,a0,100 # ffffffffc0207038 <commands+0x780>
ffffffffc0201fdc:	a2cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201fe0:	00005697          	auipc	a3,0x5
ffffffffc0201fe4:	31868693          	addi	a3,a3,792 # ffffffffc02072f8 <commands+0xa40>
ffffffffc0201fe8:	00005617          	auipc	a2,0x5
ffffffffc0201fec:	ce060613          	addi	a2,a2,-800 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0201ff0:	20600593          	li	a1,518
ffffffffc0201ff4:	00005517          	auipc	a0,0x5
ffffffffc0201ff8:	04450513          	addi	a0,a0,68 # ffffffffc0207038 <commands+0x780>
ffffffffc0201ffc:	a0cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202000:	00005697          	auipc	a3,0x5
ffffffffc0202004:	3f068693          	addi	a3,a3,1008 # ffffffffc02073f0 <commands+0xb38>
ffffffffc0202008:	00005617          	auipc	a2,0x5
ffffffffc020200c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202010:	24a00593          	li	a1,586
ffffffffc0202014:	00005517          	auipc	a0,0x5
ffffffffc0202018:	02450513          	addi	a0,a0,36 # ffffffffc0207038 <commands+0x780>
ffffffffc020201c:	9ecfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202020:	00005697          	auipc	a3,0x5
ffffffffc0202024:	2c868693          	addi	a3,a3,712 # ffffffffc02072e8 <commands+0xa30>
ffffffffc0202028:	00005617          	auipc	a2,0x5
ffffffffc020202c:	ca060613          	addi	a2,a2,-864 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202030:	20500593          	li	a1,517
ffffffffc0202034:	00005517          	auipc	a0,0x5
ffffffffc0202038:	00450513          	addi	a0,a0,4 # ffffffffc0207038 <commands+0x780>
ffffffffc020203c:	9ccfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202040:	00005697          	auipc	a3,0x5
ffffffffc0202044:	20068693          	addi	a3,a3,512 # ffffffffc0207240 <commands+0x988>
ffffffffc0202048:	00005617          	auipc	a2,0x5
ffffffffc020204c:	c8060613          	addi	a2,a2,-896 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202050:	21200593          	li	a1,530
ffffffffc0202054:	00005517          	auipc	a0,0x5
ffffffffc0202058:	fe450513          	addi	a0,a0,-28 # ffffffffc0207038 <commands+0x780>
ffffffffc020205c:	9acfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202060:	00005697          	auipc	a3,0x5
ffffffffc0202064:	33868693          	addi	a3,a3,824 # ffffffffc0207398 <commands+0xae0>
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	c6060613          	addi	a2,a2,-928 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202070:	20f00593          	li	a1,527
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	fc450513          	addi	a0,a0,-60 # ffffffffc0207038 <commands+0x780>
ffffffffc020207c:	98cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202080:	00005697          	auipc	a3,0x5
ffffffffc0202084:	1a868693          	addi	a3,a3,424 # ffffffffc0207228 <commands+0x970>
ffffffffc0202088:	00005617          	auipc	a2,0x5
ffffffffc020208c:	c4060613          	addi	a2,a2,-960 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202090:	20e00593          	li	a1,526
ffffffffc0202094:	00005517          	auipc	a0,0x5
ffffffffc0202098:	fa450513          	addi	a0,a0,-92 # ffffffffc0207038 <commands+0x780>
ffffffffc020209c:	96cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	f7060613          	addi	a2,a2,-144 # ffffffffc0207010 <commands+0x758>
ffffffffc02020a8:	06900593          	li	a1,105
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02020b4:	954fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02020b8:	00005697          	auipc	a3,0x5
ffffffffc02020bc:	31068693          	addi	a3,a3,784 # ffffffffc02073c8 <commands+0xb10>
ffffffffc02020c0:	00005617          	auipc	a2,0x5
ffffffffc02020c4:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02020c8:	21900593          	li	a1,537
ffffffffc02020cc:	00005517          	auipc	a0,0x5
ffffffffc02020d0:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207038 <commands+0x780>
ffffffffc02020d4:	934fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02020d8:	00005697          	auipc	a3,0x5
ffffffffc02020dc:	2a868693          	addi	a3,a3,680 # ffffffffc0207380 <commands+0xac8>
ffffffffc02020e0:	00005617          	auipc	a2,0x5
ffffffffc02020e4:	be860613          	addi	a2,a2,-1048 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02020e8:	21700593          	li	a1,535
ffffffffc02020ec:	00005517          	auipc	a0,0x5
ffffffffc02020f0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207038 <commands+0x780>
ffffffffc02020f4:	914fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02020f8:	00005697          	auipc	a3,0x5
ffffffffc02020fc:	2b868693          	addi	a3,a3,696 # ffffffffc02073b0 <commands+0xaf8>
ffffffffc0202100:	00005617          	auipc	a2,0x5
ffffffffc0202104:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202108:	21600593          	li	a1,534
ffffffffc020210c:	00005517          	auipc	a0,0x5
ffffffffc0202110:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207038 <commands+0x780>
ffffffffc0202114:	8f4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202118:	00005697          	auipc	a3,0x5
ffffffffc020211c:	26868693          	addi	a3,a3,616 # ffffffffc0207380 <commands+0xac8>
ffffffffc0202120:	00005617          	auipc	a2,0x5
ffffffffc0202124:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202128:	21300593          	li	a1,531
ffffffffc020212c:	00005517          	auipc	a0,0x5
ffffffffc0202130:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207038 <commands+0x780>
ffffffffc0202134:	8d4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202138:	00005697          	auipc	a3,0x5
ffffffffc020213c:	3a068693          	addi	a3,a3,928 # ffffffffc02074d8 <commands+0xc20>
ffffffffc0202140:	00005617          	auipc	a2,0x5
ffffffffc0202144:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202148:	23800593          	li	a1,568
ffffffffc020214c:	00005517          	auipc	a0,0x5
ffffffffc0202150:	eec50513          	addi	a0,a0,-276 # ffffffffc0207038 <commands+0x780>
ffffffffc0202154:	8b4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202158:	00005697          	auipc	a3,0x5
ffffffffc020215c:	34868693          	addi	a3,a3,840 # ffffffffc02074a0 <commands+0xbe8>
ffffffffc0202160:	00005617          	auipc	a2,0x5
ffffffffc0202164:	b6860613          	addi	a2,a2,-1176 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202168:	23700593          	li	a1,567
ffffffffc020216c:	00005517          	auipc	a0,0x5
ffffffffc0202170:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207038 <commands+0x780>
ffffffffc0202174:	894fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202178:	00005697          	auipc	a3,0x5
ffffffffc020217c:	31068693          	addi	a3,a3,784 # ffffffffc0207488 <commands+0xbd0>
ffffffffc0202180:	00005617          	auipc	a2,0x5
ffffffffc0202184:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202188:	23300593          	li	a1,563
ffffffffc020218c:	00005517          	auipc	a0,0x5
ffffffffc0202190:	eac50513          	addi	a0,a0,-340 # ffffffffc0207038 <commands+0x780>
ffffffffc0202194:	874fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202198:	00005697          	auipc	a3,0x5
ffffffffc020219c:	25868693          	addi	a3,a3,600 # ffffffffc02073f0 <commands+0xb38>
ffffffffc02021a0:	00005617          	auipc	a2,0x5
ffffffffc02021a4:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02021a8:	22100593          	li	a1,545
ffffffffc02021ac:	00005517          	auipc	a0,0x5
ffffffffc02021b0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207038 <commands+0x780>
ffffffffc02021b4:	854fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02021b8:	00005697          	auipc	a3,0x5
ffffffffc02021bc:	07068693          	addi	a3,a3,112 # ffffffffc0207228 <commands+0x970>
ffffffffc02021c0:	00005617          	auipc	a2,0x5
ffffffffc02021c4:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02021c8:	1fb00593          	li	a1,507
ffffffffc02021cc:	00005517          	auipc	a0,0x5
ffffffffc02021d0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207038 <commands+0x780>
ffffffffc02021d4:	834fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021d8:	00005617          	auipc	a2,0x5
ffffffffc02021dc:	e3860613          	addi	a2,a2,-456 # ffffffffc0207010 <commands+0x758>
ffffffffc02021e0:	1fe00593          	li	a1,510
ffffffffc02021e4:	00005517          	auipc	a0,0x5
ffffffffc02021e8:	e5450513          	addi	a0,a0,-428 # ffffffffc0207038 <commands+0x780>
ffffffffc02021ec:	81cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02021f0:	00005697          	auipc	a3,0x5
ffffffffc02021f4:	05068693          	addi	a3,a3,80 # ffffffffc0207240 <commands+0x988>
ffffffffc02021f8:	00005617          	auipc	a2,0x5
ffffffffc02021fc:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202200:	1fc00593          	li	a1,508
ffffffffc0202204:	00005517          	auipc	a0,0x5
ffffffffc0202208:	e3450513          	addi	a0,a0,-460 # ffffffffc0207038 <commands+0x780>
ffffffffc020220c:	ffdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202210:	00005697          	auipc	a3,0x5
ffffffffc0202214:	0a868693          	addi	a3,a3,168 # ffffffffc02072b8 <commands+0xa00>
ffffffffc0202218:	00005617          	auipc	a2,0x5
ffffffffc020221c:	ab060613          	addi	a2,a2,-1360 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202220:	20400593          	li	a1,516
ffffffffc0202224:	00005517          	auipc	a0,0x5
ffffffffc0202228:	e1450513          	addi	a0,a0,-492 # ffffffffc0207038 <commands+0x780>
ffffffffc020222c:	fddfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202230:	00005697          	auipc	a3,0x5
ffffffffc0202234:	36868693          	addi	a3,a3,872 # ffffffffc0207598 <commands+0xce0>
ffffffffc0202238:	00005617          	auipc	a2,0x5
ffffffffc020223c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202240:	24100593          	li	a1,577
ffffffffc0202244:	00005517          	auipc	a0,0x5
ffffffffc0202248:	df450513          	addi	a0,a0,-524 # ffffffffc0207038 <commands+0x780>
ffffffffc020224c:	fbdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202250:	00005697          	auipc	a3,0x5
ffffffffc0202254:	31068693          	addi	a3,a3,784 # ffffffffc0207560 <commands+0xca8>
ffffffffc0202258:	00005617          	auipc	a2,0x5
ffffffffc020225c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202260:	23e00593          	li	a1,574
ffffffffc0202264:	00005517          	auipc	a0,0x5
ffffffffc0202268:	dd450513          	addi	a0,a0,-556 # ffffffffc0207038 <commands+0x780>
ffffffffc020226c:	f9dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202270:	00005697          	auipc	a3,0x5
ffffffffc0202274:	2c068693          	addi	a3,a3,704 # ffffffffc0207530 <commands+0xc78>
ffffffffc0202278:	00005617          	auipc	a2,0x5
ffffffffc020227c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202280:	23a00593          	li	a1,570
ffffffffc0202284:	00005517          	auipc	a0,0x5
ffffffffc0202288:	db450513          	addi	a0,a0,-588 # ffffffffc0207038 <commands+0x780>
ffffffffc020228c:	f7dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202290 <copy_range>:
               bool share) {
ffffffffc0202290:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202292:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0202296:	f486                	sd	ra,104(sp)
ffffffffc0202298:	f0a2                	sd	s0,96(sp)
ffffffffc020229a:	eca6                	sd	s1,88(sp)
ffffffffc020229c:	e8ca                	sd	s2,80(sp)
ffffffffc020229e:	e4ce                	sd	s3,72(sp)
ffffffffc02022a0:	e0d2                	sd	s4,64(sp)
ffffffffc02022a2:	fc56                	sd	s5,56(sp)
ffffffffc02022a4:	f85a                	sd	s6,48(sp)
ffffffffc02022a6:	f45e                	sd	s7,40(sp)
ffffffffc02022a8:	f062                	sd	s8,32(sp)
ffffffffc02022aa:	ec66                	sd	s9,24(sp)
ffffffffc02022ac:	e86a                	sd	s10,16(sp)
ffffffffc02022ae:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022b0:	17d2                	slli	a5,a5,0x34
ffffffffc02022b2:	1c079963          	bnez	a5,ffffffffc0202484 <copy_range+0x1f4>
    assert(USER_ACCESS(start, end));
ffffffffc02022b6:	002007b7          	lui	a5,0x200
ffffffffc02022ba:	8432                	mv	s0,a2
ffffffffc02022bc:	18f66463          	bltu	a2,a5,ffffffffc0202444 <copy_range+0x1b4>
ffffffffc02022c0:	8936                	mv	s2,a3
ffffffffc02022c2:	18d67163          	bgeu	a2,a3,ffffffffc0202444 <copy_range+0x1b4>
ffffffffc02022c6:	4785                	li	a5,1
ffffffffc02022c8:	07fe                	slli	a5,a5,0x1f
ffffffffc02022ca:	16d7ed63          	bltu	a5,a3,ffffffffc0202444 <copy_range+0x1b4>
ffffffffc02022ce:	5afd                	li	s5,-1
ffffffffc02022d0:	8a2a                	mv	s4,a0
ffffffffc02022d2:	89ae                	mv	s3,a1
    if (PPN(pa) >= npage) {
ffffffffc02022d4:	000b0c17          	auipc	s8,0xb0
ffffffffc02022d8:	4d4c0c13          	addi	s8,s8,1236 # ffffffffc02b27a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022dc:	000b0b97          	auipc	s7,0xb0
ffffffffc02022e0:	4d4b8b93          	addi	s7,s7,1236 # ffffffffc02b27b0 <pages>
ffffffffc02022e4:	fff80d37          	lui	s10,0xfff80
    return page - pages + nbase;
ffffffffc02022e8:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02022ec:	00cada93          	srli	s5,s5,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02022f0:	4601                	li	a2,0
ffffffffc02022f2:	85a2                	mv	a1,s0
ffffffffc02022f4:	854e                	mv	a0,s3
ffffffffc02022f6:	c71fe0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02022fa:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02022fc:	c179                	beqz	a0,ffffffffc02023c2 <copy_range+0x132>
        if (*ptep & PTE_V) {
ffffffffc02022fe:	611c                	ld	a5,0(a0)
ffffffffc0202300:	8b85                	andi	a5,a5,1
ffffffffc0202302:	e78d                	bnez	a5,ffffffffc020232c <copy_range+0x9c>
        start += PGSIZE;
ffffffffc0202304:	6785                	lui	a5,0x1
ffffffffc0202306:	943e                	add	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0202308:	ff2464e3          	bltu	s0,s2,ffffffffc02022f0 <copy_range+0x60>
    return 0;
ffffffffc020230c:	4501                	li	a0,0
}
ffffffffc020230e:	70a6                	ld	ra,104(sp)
ffffffffc0202310:	7406                	ld	s0,96(sp)
ffffffffc0202312:	64e6                	ld	s1,88(sp)
ffffffffc0202314:	6946                	ld	s2,80(sp)
ffffffffc0202316:	69a6                	ld	s3,72(sp)
ffffffffc0202318:	6a06                	ld	s4,64(sp)
ffffffffc020231a:	7ae2                	ld	s5,56(sp)
ffffffffc020231c:	7b42                	ld	s6,48(sp)
ffffffffc020231e:	7ba2                	ld	s7,40(sp)
ffffffffc0202320:	7c02                	ld	s8,32(sp)
ffffffffc0202322:	6ce2                	ld	s9,24(sp)
ffffffffc0202324:	6d42                	ld	s10,16(sp)
ffffffffc0202326:	6da2                	ld	s11,8(sp)
ffffffffc0202328:	6165                	addi	sp,sp,112
ffffffffc020232a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020232c:	4605                	li	a2,1
ffffffffc020232e:	85a2                	mv	a1,s0
ffffffffc0202330:	8552                	mv	a0,s4
ffffffffc0202332:	c35fe0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0202336:	c145                	beqz	a0,ffffffffc02023d6 <copy_range+0x146>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202338:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc020233a:	0017f713          	andi	a4,a5,1
ffffffffc020233e:	01f7f493          	andi	s1,a5,31
ffffffffc0202342:	0e070563          	beqz	a4,ffffffffc020242c <copy_range+0x19c>
    if (PPN(pa) >= npage) {
ffffffffc0202346:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020234a:	078a                	slli	a5,a5,0x2
ffffffffc020234c:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202350:	0cd77263          	bgeu	a4,a3,ffffffffc0202414 <copy_range+0x184>
    return &pages[PPN(pa) - nbase];
ffffffffc0202354:	000bb783          	ld	a5,0(s7)
ffffffffc0202358:	976a                	add	a4,a4,s10
ffffffffc020235a:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020235c:	4505                	li	a0,1
ffffffffc020235e:	00e78cb3          	add	s9,a5,a4
ffffffffc0202362:	af9fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202366:	8daa                	mv	s11,a0
            assert(page != NULL);
ffffffffc0202368:	080c8663          	beqz	s9,ffffffffc02023f4 <copy_range+0x164>
            assert(npage != NULL);
ffffffffc020236c:	0e050c63          	beqz	a0,ffffffffc0202464 <copy_range+0x1d4>
    return page - pages + nbase;
ffffffffc0202370:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0202374:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0202378:	40ec86b3          	sub	a3,s9,a4
ffffffffc020237c:	8699                	srai	a3,a3,0x6
ffffffffc020237e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0202380:	0156f7b3          	and	a5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202384:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202386:	04c7fb63          	bgeu	a5,a2,ffffffffc02023dc <copy_range+0x14c>
    return page - pages + nbase;
ffffffffc020238a:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc020238e:	000b0717          	auipc	a4,0xb0
ffffffffc0202392:	43270713          	addi	a4,a4,1074 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0202396:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0202398:	8799                	srai	a5,a5,0x6
ffffffffc020239a:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020239c:	0157f733          	and	a4,a5,s5
ffffffffc02023a0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02023a4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02023a6:	02c77a63          	bgeu	a4,a2,ffffffffc02023da <copy_range+0x14a>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02023aa:	6605                	lui	a2,0x1
ffffffffc02023ac:	953e                	add	a0,a0,a5
ffffffffc02023ae:	641030ef          	jal	ra,ffffffffc02061ee <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02023b2:	86a6                	mv	a3,s1
ffffffffc02023b4:	8622                	mv	a2,s0
ffffffffc02023b6:	85ee                	mv	a1,s11
ffffffffc02023b8:	8552                	mv	a0,s4
ffffffffc02023ba:	a46ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
                if (ret != 0) {
ffffffffc02023be:	d139                	beqz	a0,ffffffffc0202304 <copy_range+0x74>
ffffffffc02023c0:	b7b9                	j	ffffffffc020230e <copy_range+0x7e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02023c2:	002007b7          	lui	a5,0x200
ffffffffc02023c6:	943e                	add	s0,s0,a5
ffffffffc02023c8:	ffe007b7          	lui	a5,0xffe00
ffffffffc02023cc:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc02023ce:	dc1d                	beqz	s0,ffffffffc020230c <copy_range+0x7c>
ffffffffc02023d0:	f32460e3          	bltu	s0,s2,ffffffffc02022f0 <copy_range+0x60>
ffffffffc02023d4:	bf25                	j	ffffffffc020230c <copy_range+0x7c>
                return -E_NO_MEM;
ffffffffc02023d6:	5571                	li	a0,-4
ffffffffc02023d8:	bf1d                	j	ffffffffc020230e <copy_range+0x7e>
ffffffffc02023da:	86be                	mv	a3,a5
ffffffffc02023dc:	00005617          	auipc	a2,0x5
ffffffffc02023e0:	c3460613          	addi	a2,a2,-972 # ffffffffc0207010 <commands+0x758>
ffffffffc02023e4:	06900593          	li	a1,105
ffffffffc02023e8:	00005517          	auipc	a0,0x5
ffffffffc02023ec:	bf050513          	addi	a0,a0,-1040 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02023f0:	e19fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc02023f4:	00005697          	auipc	a3,0x5
ffffffffc02023f8:	1ec68693          	addi	a3,a3,492 # ffffffffc02075e0 <commands+0xd28>
ffffffffc02023fc:	00005617          	auipc	a2,0x5
ffffffffc0202400:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202404:	17200593          	li	a1,370
ffffffffc0202408:	00005517          	auipc	a0,0x5
ffffffffc020240c:	c3050513          	addi	a0,a0,-976 # ffffffffc0207038 <commands+0x780>
ffffffffc0202410:	df9fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202414:	00005617          	auipc	a2,0x5
ffffffffc0202418:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206fb8 <commands+0x700>
ffffffffc020241c:	06200593          	li	a1,98
ffffffffc0202420:	00005517          	auipc	a0,0x5
ffffffffc0202424:	bb850513          	addi	a0,a0,-1096 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0202428:	de1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020242c:	00005617          	auipc	a2,0x5
ffffffffc0202430:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0206fe8 <commands+0x730>
ffffffffc0202434:	07400593          	li	a1,116
ffffffffc0202438:	00005517          	auipc	a0,0x5
ffffffffc020243c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0202440:	dc9fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202444:	00005697          	auipc	a3,0x5
ffffffffc0202448:	c3468693          	addi	a3,a3,-972 # ffffffffc0207078 <commands+0x7c0>
ffffffffc020244c:	00005617          	auipc	a2,0x5
ffffffffc0202450:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202454:	15e00593          	li	a1,350
ffffffffc0202458:	00005517          	auipc	a0,0x5
ffffffffc020245c:	be050513          	addi	a0,a0,-1056 # ffffffffc0207038 <commands+0x780>
ffffffffc0202460:	da9fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc0202464:	00005697          	auipc	a3,0x5
ffffffffc0202468:	18c68693          	addi	a3,a3,396 # ffffffffc02075f0 <commands+0xd38>
ffffffffc020246c:	00005617          	auipc	a2,0x5
ffffffffc0202470:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202474:	17300593          	li	a1,371
ffffffffc0202478:	00005517          	auipc	a0,0x5
ffffffffc020247c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0207038 <commands+0x780>
ffffffffc0202480:	d89fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202484:	00005697          	auipc	a3,0x5
ffffffffc0202488:	bc468693          	addi	a3,a3,-1084 # ffffffffc0207048 <commands+0x790>
ffffffffc020248c:	00005617          	auipc	a2,0x5
ffffffffc0202490:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202494:	15d00593          	li	a1,349
ffffffffc0202498:	00005517          	auipc	a0,0x5
ffffffffc020249c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0207038 <commands+0x780>
ffffffffc02024a0:	d69fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02024a4 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024a4:	12058073          	sfence.vma	a1
}
ffffffffc02024a8:	8082                	ret

ffffffffc02024aa <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024aa:	7179                	addi	sp,sp,-48
ffffffffc02024ac:	e84a                	sd	s2,16(sp)
ffffffffc02024ae:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02024b0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024b2:	f022                	sd	s0,32(sp)
ffffffffc02024b4:	ec26                	sd	s1,24(sp)
ffffffffc02024b6:	e44e                	sd	s3,8(sp)
ffffffffc02024b8:	f406                	sd	ra,40(sp)
ffffffffc02024ba:	84ae                	mv	s1,a1
ffffffffc02024bc:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02024be:	99dfe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02024c2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02024c4:	cd05                	beqz	a0,ffffffffc02024fc <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02024c6:	85aa                	mv	a1,a0
ffffffffc02024c8:	86ce                	mv	a3,s3
ffffffffc02024ca:	8626                	mv	a2,s1
ffffffffc02024cc:	854a                	mv	a0,s2
ffffffffc02024ce:	932ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc02024d2:	ed0d                	bnez	a0,ffffffffc020250c <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02024d4:	000b0797          	auipc	a5,0xb0
ffffffffc02024d8:	31c7a783          	lw	a5,796(a5) # ffffffffc02b27f0 <swap_init_ok>
ffffffffc02024dc:	c385                	beqz	a5,ffffffffc02024fc <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02024de:	000b0517          	auipc	a0,0xb0
ffffffffc02024e2:	2ea53503          	ld	a0,746(a0) # ffffffffc02b27c8 <check_mm_struct>
ffffffffc02024e6:	c919                	beqz	a0,ffffffffc02024fc <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02024e8:	4681                	li	a3,0
ffffffffc02024ea:	8622                	mv	a2,s0
ffffffffc02024ec:	85a6                	mv	a1,s1
ffffffffc02024ee:	253010ef          	jal	ra,ffffffffc0203f40 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02024f2:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02024f4:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02024f6:	4785                	li	a5,1
ffffffffc02024f8:	04f71663          	bne	a4,a5,ffffffffc0202544 <pgdir_alloc_page+0x9a>
}
ffffffffc02024fc:	70a2                	ld	ra,40(sp)
ffffffffc02024fe:	8522                	mv	a0,s0
ffffffffc0202500:	7402                	ld	s0,32(sp)
ffffffffc0202502:	64e2                	ld	s1,24(sp)
ffffffffc0202504:	6942                	ld	s2,16(sp)
ffffffffc0202506:	69a2                	ld	s3,8(sp)
ffffffffc0202508:	6145                	addi	sp,sp,48
ffffffffc020250a:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020250c:	100027f3          	csrr	a5,sstatus
ffffffffc0202510:	8b89                	andi	a5,a5,2
ffffffffc0202512:	eb99                	bnez	a5,ffffffffc0202528 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0202514:	000b0797          	auipc	a5,0xb0
ffffffffc0202518:	2a47b783          	ld	a5,676(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc020251c:	739c                	ld	a5,32(a5)
ffffffffc020251e:	8522                	mv	a0,s0
ffffffffc0202520:	4585                	li	a1,1
ffffffffc0202522:	9782                	jalr	a5
            return NULL;
ffffffffc0202524:	4401                	li	s0,0
ffffffffc0202526:	bfd9                	j	ffffffffc02024fc <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0202528:	920fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020252c:	000b0797          	auipc	a5,0xb0
ffffffffc0202530:	28c7b783          	ld	a5,652(a5) # ffffffffc02b27b8 <pmm_manager>
ffffffffc0202534:	739c                	ld	a5,32(a5)
ffffffffc0202536:	8522                	mv	a0,s0
ffffffffc0202538:	4585                	li	a1,1
ffffffffc020253a:	9782                	jalr	a5
            return NULL;
ffffffffc020253c:	4401                	li	s0,0
        intr_enable();
ffffffffc020253e:	904fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202542:	bf6d                	j	ffffffffc02024fc <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0202544:	00005697          	auipc	a3,0x5
ffffffffc0202548:	0bc68693          	addi	a3,a3,188 # ffffffffc0207600 <commands+0xd48>
ffffffffc020254c:	00004617          	auipc	a2,0x4
ffffffffc0202550:	77c60613          	addi	a2,a2,1916 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202554:	1d200593          	li	a1,466
ffffffffc0202558:	00005517          	auipc	a0,0x5
ffffffffc020255c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0207038 <commands+0x780>
ffffffffc0202560:	ca9fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202564 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0202564:	000ac797          	auipc	a5,0xac
ffffffffc0202568:	15478793          	addi	a5,a5,340 # ffffffffc02ae6b8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020256c:	f51c                	sd	a5,40(a0)
ffffffffc020256e:	e79c                	sd	a5,8(a5)
ffffffffc0202570:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202572:	4501                	li	a0,0
ffffffffc0202574:	8082                	ret

ffffffffc0202576 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0202576:	4501                	li	a0,0
ffffffffc0202578:	8082                	ret

ffffffffc020257a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020257a:	4501                	li	a0,0
ffffffffc020257c:	8082                	ret

ffffffffc020257e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020257e:	4501                	li	a0,0
ffffffffc0202580:	8082                	ret

ffffffffc0202582 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0202582:	711d                	addi	sp,sp,-96
ffffffffc0202584:	fc4e                	sd	s3,56(sp)
ffffffffc0202586:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202588:	00005517          	auipc	a0,0x5
ffffffffc020258c:	09050513          	addi	a0,a0,144 # ffffffffc0207618 <commands+0xd60>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202590:	698d                	lui	s3,0x3
ffffffffc0202592:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0202594:	e0ca                	sd	s2,64(sp)
ffffffffc0202596:	ec86                	sd	ra,88(sp)
ffffffffc0202598:	e8a2                	sd	s0,80(sp)
ffffffffc020259a:	e4a6                	sd	s1,72(sp)
ffffffffc020259c:	f456                	sd	s5,40(sp)
ffffffffc020259e:	f05a                	sd	s6,32(sp)
ffffffffc02025a0:	ec5e                	sd	s7,24(sp)
ffffffffc02025a2:	e862                	sd	s8,16(sp)
ffffffffc02025a4:	e466                	sd	s9,8(sp)
ffffffffc02025a6:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025a8:	b25fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025ac:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc02025b0:	000b0917          	auipc	s2,0xb0
ffffffffc02025b4:	22092903          	lw	s2,544(s2) # ffffffffc02b27d0 <pgfault_num>
ffffffffc02025b8:	4791                	li	a5,4
ffffffffc02025ba:	14f91e63          	bne	s2,a5,ffffffffc0202716 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025be:	00005517          	auipc	a0,0x5
ffffffffc02025c2:	0aa50513          	addi	a0,a0,170 # ffffffffc0207668 <commands+0xdb0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025c6:	6a85                	lui	s5,0x1
ffffffffc02025c8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025ca:	b03fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02025ce:	000b0417          	auipc	s0,0xb0
ffffffffc02025d2:	20240413          	addi	s0,s0,514 # ffffffffc02b27d0 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025d6:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc02025da:	4004                	lw	s1,0(s0)
ffffffffc02025dc:	2481                	sext.w	s1,s1
ffffffffc02025de:	2b249c63          	bne	s1,s2,ffffffffc0202896 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025e2:	00005517          	auipc	a0,0x5
ffffffffc02025e6:	0ae50513          	addi	a0,a0,174 # ffffffffc0207690 <commands+0xdd8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025ea:	6b91                	lui	s7,0x4
ffffffffc02025ec:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025ee:	adffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025f2:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc02025f6:	00042903          	lw	s2,0(s0)
ffffffffc02025fa:	2901                	sext.w	s2,s2
ffffffffc02025fc:	26991d63          	bne	s2,s1,ffffffffc0202876 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202600:	00005517          	auipc	a0,0x5
ffffffffc0202604:	0b850513          	addi	a0,a0,184 # ffffffffc02076b8 <commands+0xe00>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202608:	6c89                	lui	s9,0x2
ffffffffc020260a:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020260c:	ac1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202610:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0202614:	401c                	lw	a5,0(s0)
ffffffffc0202616:	2781                	sext.w	a5,a5
ffffffffc0202618:	23279f63          	bne	a5,s2,ffffffffc0202856 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020261c:	00005517          	auipc	a0,0x5
ffffffffc0202620:	0c450513          	addi	a0,a0,196 # ffffffffc02076e0 <commands+0xe28>
ffffffffc0202624:	aa9fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202628:	6795                	lui	a5,0x5
ffffffffc020262a:	4739                	li	a4,14
ffffffffc020262c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0202630:	4004                	lw	s1,0(s0)
ffffffffc0202632:	4795                	li	a5,5
ffffffffc0202634:	2481                	sext.w	s1,s1
ffffffffc0202636:	20f49063          	bne	s1,a5,ffffffffc0202836 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020263a:	00005517          	auipc	a0,0x5
ffffffffc020263e:	07e50513          	addi	a0,a0,126 # ffffffffc02076b8 <commands+0xe00>
ffffffffc0202642:	a8bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202646:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020264a:	401c                	lw	a5,0(s0)
ffffffffc020264c:	2781                	sext.w	a5,a5
ffffffffc020264e:	1c979463          	bne	a5,s1,ffffffffc0202816 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	01650513          	addi	a0,a0,22 # ffffffffc0207668 <commands+0xdb0>
ffffffffc020265a:	a73fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020265e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0202662:	401c                	lw	a5,0(s0)
ffffffffc0202664:	4719                	li	a4,6
ffffffffc0202666:	2781                	sext.w	a5,a5
ffffffffc0202668:	18e79763          	bne	a5,a4,ffffffffc02027f6 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020266c:	00005517          	auipc	a0,0x5
ffffffffc0202670:	04c50513          	addi	a0,a0,76 # ffffffffc02076b8 <commands+0xe00>
ffffffffc0202674:	a59fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202678:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020267c:	401c                	lw	a5,0(s0)
ffffffffc020267e:	471d                	li	a4,7
ffffffffc0202680:	2781                	sext.w	a5,a5
ffffffffc0202682:	14e79a63          	bne	a5,a4,ffffffffc02027d6 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202686:	00005517          	auipc	a0,0x5
ffffffffc020268a:	f9250513          	addi	a0,a0,-110 # ffffffffc0207618 <commands+0xd60>
ffffffffc020268e:	a3ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202692:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0202696:	401c                	lw	a5,0(s0)
ffffffffc0202698:	4721                	li	a4,8
ffffffffc020269a:	2781                	sext.w	a5,a5
ffffffffc020269c:	10e79d63          	bne	a5,a4,ffffffffc02027b6 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02026a0:	00005517          	auipc	a0,0x5
ffffffffc02026a4:	ff050513          	addi	a0,a0,-16 # ffffffffc0207690 <commands+0xdd8>
ffffffffc02026a8:	a25fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026ac:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02026b0:	401c                	lw	a5,0(s0)
ffffffffc02026b2:	4725                	li	a4,9
ffffffffc02026b4:	2781                	sext.w	a5,a5
ffffffffc02026b6:	0ee79063          	bne	a5,a4,ffffffffc0202796 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02026ba:	00005517          	auipc	a0,0x5
ffffffffc02026be:	02650513          	addi	a0,a0,38 # ffffffffc02076e0 <commands+0xe28>
ffffffffc02026c2:	a0bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026c6:	6795                	lui	a5,0x5
ffffffffc02026c8:	4739                	li	a4,14
ffffffffc02026ca:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc02026ce:	4004                	lw	s1,0(s0)
ffffffffc02026d0:	47a9                	li	a5,10
ffffffffc02026d2:	2481                	sext.w	s1,s1
ffffffffc02026d4:	0af49163          	bne	s1,a5,ffffffffc0202776 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026d8:	00005517          	auipc	a0,0x5
ffffffffc02026dc:	f9050513          	addi	a0,a0,-112 # ffffffffc0207668 <commands+0xdb0>
ffffffffc02026e0:	9edfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026e4:	6785                	lui	a5,0x1
ffffffffc02026e6:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02026ea:	06979663          	bne	a5,s1,ffffffffc0202756 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02026ee:	401c                	lw	a5,0(s0)
ffffffffc02026f0:	472d                	li	a4,11
ffffffffc02026f2:	2781                	sext.w	a5,a5
ffffffffc02026f4:	04e79163          	bne	a5,a4,ffffffffc0202736 <_fifo_check_swap+0x1b4>
}
ffffffffc02026f8:	60e6                	ld	ra,88(sp)
ffffffffc02026fa:	6446                	ld	s0,80(sp)
ffffffffc02026fc:	64a6                	ld	s1,72(sp)
ffffffffc02026fe:	6906                	ld	s2,64(sp)
ffffffffc0202700:	79e2                	ld	s3,56(sp)
ffffffffc0202702:	7a42                	ld	s4,48(sp)
ffffffffc0202704:	7aa2                	ld	s5,40(sp)
ffffffffc0202706:	7b02                	ld	s6,32(sp)
ffffffffc0202708:	6be2                	ld	s7,24(sp)
ffffffffc020270a:	6c42                	ld	s8,16(sp)
ffffffffc020270c:	6ca2                	ld	s9,8(sp)
ffffffffc020270e:	6d02                	ld	s10,0(sp)
ffffffffc0202710:	4501                	li	a0,0
ffffffffc0202712:	6125                	addi	sp,sp,96
ffffffffc0202714:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202716:	00005697          	auipc	a3,0x5
ffffffffc020271a:	f2a68693          	addi	a3,a3,-214 # ffffffffc0207640 <commands+0xd88>
ffffffffc020271e:	00004617          	auipc	a2,0x4
ffffffffc0202722:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202726:	05500593          	li	a1,85
ffffffffc020272a:	00005517          	auipc	a0,0x5
ffffffffc020272e:	f2650513          	addi	a0,a0,-218 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202732:	ad7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0202736:	00005697          	auipc	a3,0x5
ffffffffc020273a:	05a68693          	addi	a3,a3,90 # ffffffffc0207790 <commands+0xed8>
ffffffffc020273e:	00004617          	auipc	a2,0x4
ffffffffc0202742:	58a60613          	addi	a2,a2,1418 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202746:	07700593          	li	a1,119
ffffffffc020274a:	00005517          	auipc	a0,0x5
ffffffffc020274e:	f0650513          	addi	a0,a0,-250 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202752:	ab7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202756:	00005697          	auipc	a3,0x5
ffffffffc020275a:	01268693          	addi	a3,a3,18 # ffffffffc0207768 <commands+0xeb0>
ffffffffc020275e:	00004617          	auipc	a2,0x4
ffffffffc0202762:	56a60613          	addi	a2,a2,1386 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202766:	07500593          	li	a1,117
ffffffffc020276a:	00005517          	auipc	a0,0x5
ffffffffc020276e:	ee650513          	addi	a0,a0,-282 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202772:	a97fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0202776:	00005697          	auipc	a3,0x5
ffffffffc020277a:	fe268693          	addi	a3,a3,-30 # ffffffffc0207758 <commands+0xea0>
ffffffffc020277e:	00004617          	auipc	a2,0x4
ffffffffc0202782:	54a60613          	addi	a2,a2,1354 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202786:	07300593          	li	a1,115
ffffffffc020278a:	00005517          	auipc	a0,0x5
ffffffffc020278e:	ec650513          	addi	a0,a0,-314 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202792:	a77fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc0202796:	00005697          	auipc	a3,0x5
ffffffffc020279a:	fb268693          	addi	a3,a3,-78 # ffffffffc0207748 <commands+0xe90>
ffffffffc020279e:	00004617          	auipc	a2,0x4
ffffffffc02027a2:	52a60613          	addi	a2,a2,1322 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02027a6:	07000593          	li	a1,112
ffffffffc02027aa:	00005517          	auipc	a0,0x5
ffffffffc02027ae:	ea650513          	addi	a0,a0,-346 # ffffffffc0207650 <commands+0xd98>
ffffffffc02027b2:	a57fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc02027b6:	00005697          	auipc	a3,0x5
ffffffffc02027ba:	f8268693          	addi	a3,a3,-126 # ffffffffc0207738 <commands+0xe80>
ffffffffc02027be:	00004617          	auipc	a2,0x4
ffffffffc02027c2:	50a60613          	addi	a2,a2,1290 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02027c6:	06d00593          	li	a1,109
ffffffffc02027ca:	00005517          	auipc	a0,0x5
ffffffffc02027ce:	e8650513          	addi	a0,a0,-378 # ffffffffc0207650 <commands+0xd98>
ffffffffc02027d2:	a37fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc02027d6:	00005697          	auipc	a3,0x5
ffffffffc02027da:	f5268693          	addi	a3,a3,-174 # ffffffffc0207728 <commands+0xe70>
ffffffffc02027de:	00004617          	auipc	a2,0x4
ffffffffc02027e2:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02027e6:	06a00593          	li	a1,106
ffffffffc02027ea:	00005517          	auipc	a0,0x5
ffffffffc02027ee:	e6650513          	addi	a0,a0,-410 # ffffffffc0207650 <commands+0xd98>
ffffffffc02027f2:	a17fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc02027f6:	00005697          	auipc	a3,0x5
ffffffffc02027fa:	f2268693          	addi	a3,a3,-222 # ffffffffc0207718 <commands+0xe60>
ffffffffc02027fe:	00004617          	auipc	a2,0x4
ffffffffc0202802:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202806:	06700593          	li	a1,103
ffffffffc020280a:	00005517          	auipc	a0,0x5
ffffffffc020280e:	e4650513          	addi	a0,a0,-442 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202812:	9f7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202816:	00005697          	auipc	a3,0x5
ffffffffc020281a:	ef268693          	addi	a3,a3,-270 # ffffffffc0207708 <commands+0xe50>
ffffffffc020281e:	00004617          	auipc	a2,0x4
ffffffffc0202822:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202826:	06400593          	li	a1,100
ffffffffc020282a:	00005517          	auipc	a0,0x5
ffffffffc020282e:	e2650513          	addi	a0,a0,-474 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202832:	9d7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202836:	00005697          	auipc	a3,0x5
ffffffffc020283a:	ed268693          	addi	a3,a3,-302 # ffffffffc0207708 <commands+0xe50>
ffffffffc020283e:	00004617          	auipc	a2,0x4
ffffffffc0202842:	48a60613          	addi	a2,a2,1162 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202846:	06100593          	li	a1,97
ffffffffc020284a:	00005517          	auipc	a0,0x5
ffffffffc020284e:	e0650513          	addi	a0,a0,-506 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202852:	9b7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202856:	00005697          	auipc	a3,0x5
ffffffffc020285a:	dea68693          	addi	a3,a3,-534 # ffffffffc0207640 <commands+0xd88>
ffffffffc020285e:	00004617          	auipc	a2,0x4
ffffffffc0202862:	46a60613          	addi	a2,a2,1130 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202866:	05e00593          	li	a1,94
ffffffffc020286a:	00005517          	auipc	a0,0x5
ffffffffc020286e:	de650513          	addi	a0,a0,-538 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202872:	997fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202876:	00005697          	auipc	a3,0x5
ffffffffc020287a:	dca68693          	addi	a3,a3,-566 # ffffffffc0207640 <commands+0xd88>
ffffffffc020287e:	00004617          	auipc	a2,0x4
ffffffffc0202882:	44a60613          	addi	a2,a2,1098 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202886:	05b00593          	li	a1,91
ffffffffc020288a:	00005517          	auipc	a0,0x5
ffffffffc020288e:	dc650513          	addi	a0,a0,-570 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202892:	977fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202896:	00005697          	auipc	a3,0x5
ffffffffc020289a:	daa68693          	addi	a3,a3,-598 # ffffffffc0207640 <commands+0xd88>
ffffffffc020289e:	00004617          	auipc	a2,0x4
ffffffffc02028a2:	42a60613          	addi	a2,a2,1066 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02028a6:	05800593          	li	a1,88
ffffffffc02028aa:	00005517          	auipc	a0,0x5
ffffffffc02028ae:	da650513          	addi	a0,a0,-602 # ffffffffc0207650 <commands+0xd98>
ffffffffc02028b2:	957fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028b6 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028b6:	7518                	ld	a4,40(a0)
{
ffffffffc02028b8:	1141                	addi	sp,sp,-16
ffffffffc02028ba:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02028bc:	c731                	beqz	a4,ffffffffc0202908 <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc02028be:	e60d                	bnez	a2,ffffffffc02028e8 <_fifo_swap_out_victim+0x32>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02028c0:	671c                	ld	a5,8(a4)
	if (entry != head) {
ffffffffc02028c2:	00f70d63          	beq	a4,a5,ffffffffc02028dc <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02028c6:	6394                	ld	a3,0(a5)
ffffffffc02028c8:	6798                	ld	a4,8(a5)
}
ffffffffc02028ca:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02028cc:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02028d0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02028d2:	e314                	sd	a3,0(a4)
ffffffffc02028d4:	e19c                	sd	a5,0(a1)
}
ffffffffc02028d6:	4501                	li	a0,0
ffffffffc02028d8:	0141                	addi	sp,sp,16
ffffffffc02028da:	8082                	ret
ffffffffc02028dc:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02028de:	0005b023          	sd	zero,0(a1)
}
ffffffffc02028e2:	4501                	li	a0,0
ffffffffc02028e4:	0141                	addi	sp,sp,16
ffffffffc02028e6:	8082                	ret
     assert(in_tick==0);
ffffffffc02028e8:	00005697          	auipc	a3,0x5
ffffffffc02028ec:	ec868693          	addi	a3,a3,-312 # ffffffffc02077b0 <commands+0xef8>
ffffffffc02028f0:	00004617          	auipc	a2,0x4
ffffffffc02028f4:	3d860613          	addi	a2,a2,984 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02028f8:	04200593          	li	a1,66
ffffffffc02028fc:	00005517          	auipc	a0,0x5
ffffffffc0202900:	d5450513          	addi	a0,a0,-684 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202904:	905fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(head != NULL);
ffffffffc0202908:	00005697          	auipc	a3,0x5
ffffffffc020290c:	e9868693          	addi	a3,a3,-360 # ffffffffc02077a0 <commands+0xee8>
ffffffffc0202910:	00004617          	auipc	a2,0x4
ffffffffc0202914:	3b860613          	addi	a2,a2,952 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202918:	04100593          	li	a1,65
ffffffffc020291c:	00005517          	auipc	a0,0x5
ffffffffc0202920:	d3450513          	addi	a0,a0,-716 # ffffffffc0207650 <commands+0xd98>
ffffffffc0202924:	8e5fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202928 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202928:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020292a:	cb91                	beqz	a5,ffffffffc020293e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020292c:	6394                	ld	a3,0(a5)
ffffffffc020292e:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0202932:	e398                	sd	a4,0(a5)
ffffffffc0202934:	e698                	sd	a4,8(a3)
}
ffffffffc0202936:	4501                	li	a0,0
    elm->next = next;
ffffffffc0202938:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020293a:	f614                	sd	a3,40(a2)
ffffffffc020293c:	8082                	ret
{
ffffffffc020293e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202940:	00005697          	auipc	a3,0x5
ffffffffc0202944:	e8068693          	addi	a3,a3,-384 # ffffffffc02077c0 <commands+0xf08>
ffffffffc0202948:	00004617          	auipc	a2,0x4
ffffffffc020294c:	38060613          	addi	a2,a2,896 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202950:	03200593          	li	a1,50
ffffffffc0202954:	00005517          	auipc	a0,0x5
ffffffffc0202958:	cfc50513          	addi	a0,a0,-772 # ffffffffc0207650 <commands+0xd98>
{
ffffffffc020295c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020295e:	8abfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202962 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202962:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202964:	00005697          	auipc	a3,0x5
ffffffffc0202968:	e9468693          	addi	a3,a3,-364 # ffffffffc02077f8 <commands+0xf40>
ffffffffc020296c:	00004617          	auipc	a2,0x4
ffffffffc0202970:	35c60613          	addi	a2,a2,860 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202974:	06d00593          	li	a1,109
ffffffffc0202978:	00005517          	auipc	a0,0x5
ffffffffc020297c:	ea050513          	addi	a0,a0,-352 # ffffffffc0207818 <commands+0xf60>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202980:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202982:	887fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202986 <mm_create>:
mm_create(void) {
ffffffffc0202986:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202988:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020298c:	e022                	sd	s0,0(sp)
ffffffffc020298e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202990:	499000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202994:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202996:	c505                	beqz	a0,ffffffffc02029be <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0202998:	e408                	sd	a0,8(s0)
ffffffffc020299a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020299c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02029a0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02029a4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029a8:	000b0797          	auipc	a5,0xb0
ffffffffc02029ac:	e487a783          	lw	a5,-440(a5) # ffffffffc02b27f0 <swap_init_ok>
ffffffffc02029b0:	ef81                	bnez	a5,ffffffffc02029c8 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc02029b2:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02029b6:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02029ba:	02043c23          	sd	zero,56(s0)
}
ffffffffc02029be:	60a2                	ld	ra,8(sp)
ffffffffc02029c0:	8522                	mv	a0,s0
ffffffffc02029c2:	6402                	ld	s0,0(sp)
ffffffffc02029c4:	0141                	addi	sp,sp,16
ffffffffc02029c6:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029c8:	56c010ef          	jal	ra,ffffffffc0203f34 <swap_init_mm>
ffffffffc02029cc:	b7ed                	j	ffffffffc02029b6 <mm_create+0x30>

ffffffffc02029ce <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029ce:	1101                	addi	sp,sp,-32
ffffffffc02029d0:	e04a                	sd	s2,0(sp)
ffffffffc02029d2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029d4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029d8:	e822                	sd	s0,16(sp)
ffffffffc02029da:	e426                	sd	s1,8(sp)
ffffffffc02029dc:	ec06                	sd	ra,24(sp)
ffffffffc02029de:	84ae                	mv	s1,a1
ffffffffc02029e0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029e2:	447000ef          	jal	ra,ffffffffc0203628 <kmalloc>
    if (vma != NULL) {
ffffffffc02029e6:	c509                	beqz	a0,ffffffffc02029f0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02029e8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02029ec:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02029ee:	cd00                	sw	s0,24(a0)
}
ffffffffc02029f0:	60e2                	ld	ra,24(sp)
ffffffffc02029f2:	6442                	ld	s0,16(sp)
ffffffffc02029f4:	64a2                	ld	s1,8(sp)
ffffffffc02029f6:	6902                	ld	s2,0(sp)
ffffffffc02029f8:	6105                	addi	sp,sp,32
ffffffffc02029fa:	8082                	ret

ffffffffc02029fc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02029fc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02029fe:	c505                	beqz	a0,ffffffffc0202a26 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202a00:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a02:	c501                	beqz	a0,ffffffffc0202a0a <find_vma+0xe>
ffffffffc0202a04:	651c                	ld	a5,8(a0)
ffffffffc0202a06:	02f5f263          	bgeu	a1,a5,ffffffffc0202a2a <find_vma+0x2e>
    return listelm->next;
ffffffffc0202a0a:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0202a0c:	00f68d63          	beq	a3,a5,ffffffffc0202a26 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202a10:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a14:	00e5e663          	bltu	a1,a4,ffffffffc0202a20 <find_vma+0x24>
ffffffffc0202a18:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202a1c:	00e5ec63          	bltu	a1,a4,ffffffffc0202a34 <find_vma+0x38>
ffffffffc0202a20:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202a22:	fef697e3          	bne	a3,a5,ffffffffc0202a10 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202a26:	4501                	li	a0,0
}
ffffffffc0202a28:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a2a:	691c                	ld	a5,16(a0)
ffffffffc0202a2c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202a0a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202a30:	ea88                	sd	a0,16(a3)
ffffffffc0202a32:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0202a34:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202a38:	ea88                	sd	a0,16(a3)
ffffffffc0202a3a:	8082                	ret

ffffffffc0202a3c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a3c:	6590                	ld	a2,8(a1)
ffffffffc0202a3e:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202a42:	1141                	addi	sp,sp,-16
ffffffffc0202a44:	e406                	sd	ra,8(sp)
ffffffffc0202a46:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a48:	01066763          	bltu	a2,a6,ffffffffc0202a56 <insert_vma_struct+0x1a>
ffffffffc0202a4c:	a085                	j	ffffffffc0202aac <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a4e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a52:	04e66863          	bltu	a2,a4,ffffffffc0202aa2 <insert_vma_struct+0x66>
ffffffffc0202a56:	86be                	mv	a3,a5
ffffffffc0202a58:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0202a5a:	fef51ae3          	bne	a0,a5,ffffffffc0202a4e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202a5e:	02a68463          	beq	a3,a0,ffffffffc0202a86 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202a62:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202a66:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202a6a:	08e8f163          	bgeu	a7,a4,ffffffffc0202aec <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a6e:	04e66f63          	bltu	a2,a4,ffffffffc0202acc <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0202a72:	00f50a63          	beq	a0,a5,ffffffffc0202a86 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a76:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a7a:	05076963          	bltu	a4,a6,ffffffffc0202acc <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202a7e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202a82:	02c77363          	bgeu	a4,a2,ffffffffc0202aa8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202a86:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202a88:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202a8a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202a8e:	e390                	sd	a2,0(a5)
ffffffffc0202a90:	e690                	sd	a2,8(a3)
}
ffffffffc0202a92:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202a94:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202a96:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0202a98:	0017079b          	addiw	a5,a4,1
ffffffffc0202a9c:	d11c                	sw	a5,32(a0)
}
ffffffffc0202a9e:	0141                	addi	sp,sp,16
ffffffffc0202aa0:	8082                	ret
    if (le_prev != list) {
ffffffffc0202aa2:	fca690e3          	bne	a3,a0,ffffffffc0202a62 <insert_vma_struct+0x26>
ffffffffc0202aa6:	bfd1                	j	ffffffffc0202a7a <insert_vma_struct+0x3e>
ffffffffc0202aa8:	ebbff0ef          	jal	ra,ffffffffc0202962 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202aac:	00005697          	auipc	a3,0x5
ffffffffc0202ab0:	d7c68693          	addi	a3,a3,-644 # ffffffffc0207828 <commands+0xf70>
ffffffffc0202ab4:	00004617          	auipc	a2,0x4
ffffffffc0202ab8:	21460613          	addi	a2,a2,532 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202abc:	07400593          	li	a1,116
ffffffffc0202ac0:	00005517          	auipc	a0,0x5
ffffffffc0202ac4:	d5850513          	addi	a0,a0,-680 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202ac8:	f40fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202acc:	00005697          	auipc	a3,0x5
ffffffffc0202ad0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207868 <commands+0xfb0>
ffffffffc0202ad4:	00004617          	auipc	a2,0x4
ffffffffc0202ad8:	1f460613          	addi	a2,a2,500 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202adc:	06c00593          	li	a1,108
ffffffffc0202ae0:	00005517          	auipc	a0,0x5
ffffffffc0202ae4:	d3850513          	addi	a0,a0,-712 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202ae8:	f20fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202aec:	00005697          	auipc	a3,0x5
ffffffffc0202af0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207848 <commands+0xf90>
ffffffffc0202af4:	00004617          	auipc	a2,0x4
ffffffffc0202af8:	1d460613          	addi	a2,a2,468 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202afc:	06b00593          	li	a1,107
ffffffffc0202b00:	00005517          	auipc	a0,0x5
ffffffffc0202b04:	d1850513          	addi	a0,a0,-744 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202b08:	f00fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b0c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202b0c:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202b0e:	1141                	addi	sp,sp,-16
ffffffffc0202b10:	e406                	sd	ra,8(sp)
ffffffffc0202b12:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202b14:	e78d                	bnez	a5,ffffffffc0202b3e <mm_destroy+0x32>
ffffffffc0202b16:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202b18:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202b1a:	00a40c63          	beq	s0,a0,ffffffffc0202b32 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202b1e:	6118                	ld	a4,0(a0)
ffffffffc0202b20:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202b22:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202b24:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202b26:	e398                	sd	a4,0(a5)
ffffffffc0202b28:	3b1000ef          	jal	ra,ffffffffc02036d8 <kfree>
    return listelm->next;
ffffffffc0202b2c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202b2e:	fea418e3          	bne	s0,a0,ffffffffc0202b1e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202b32:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202b34:	6402                	ld	s0,0(sp)
ffffffffc0202b36:	60a2                	ld	ra,8(sp)
ffffffffc0202b38:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202b3a:	39f0006f          	j	ffffffffc02036d8 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202b3e:	00005697          	auipc	a3,0x5
ffffffffc0202b42:	d4a68693          	addi	a3,a3,-694 # ffffffffc0207888 <commands+0xfd0>
ffffffffc0202b46:	00004617          	auipc	a2,0x4
ffffffffc0202b4a:	18260613          	addi	a2,a2,386 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202b4e:	09400593          	li	a1,148
ffffffffc0202b52:	00005517          	auipc	a0,0x5
ffffffffc0202b56:	cc650513          	addi	a0,a0,-826 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202b5a:	eaefd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b5e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0202b5e:	7139                	addi	sp,sp,-64
ffffffffc0202b60:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b62:	6405                	lui	s0,0x1
ffffffffc0202b64:	147d                	addi	s0,s0,-1
ffffffffc0202b66:	77fd                	lui	a5,0xfffff
ffffffffc0202b68:	9622                	add	a2,a2,s0
ffffffffc0202b6a:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0202b6c:	f426                	sd	s1,40(sp)
ffffffffc0202b6e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b70:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0202b74:	f04a                	sd	s2,32(sp)
ffffffffc0202b76:	ec4e                	sd	s3,24(sp)
ffffffffc0202b78:	e852                	sd	s4,16(sp)
ffffffffc0202b7a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0202b7c:	002005b7          	lui	a1,0x200
ffffffffc0202b80:	00f67433          	and	s0,a2,a5
ffffffffc0202b84:	06b4e363          	bltu	s1,a1,ffffffffc0202bea <mm_map+0x8c>
ffffffffc0202b88:	0684f163          	bgeu	s1,s0,ffffffffc0202bea <mm_map+0x8c>
ffffffffc0202b8c:	4785                	li	a5,1
ffffffffc0202b8e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b90:	0487ed63          	bltu	a5,s0,ffffffffc0202bea <mm_map+0x8c>
ffffffffc0202b94:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202b96:	cd21                	beqz	a0,ffffffffc0202bee <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0202b98:	85a6                	mv	a1,s1
ffffffffc0202b9a:	8ab6                	mv	s5,a3
ffffffffc0202b9c:	8a3a                	mv	s4,a4
ffffffffc0202b9e:	e5fff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc0202ba2:	c501                	beqz	a0,ffffffffc0202baa <mm_map+0x4c>
ffffffffc0202ba4:	651c                	ld	a5,8(a0)
ffffffffc0202ba6:	0487e263          	bltu	a5,s0,ffffffffc0202bea <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202baa:	03000513          	li	a0,48
ffffffffc0202bae:	27b000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202bb2:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202bb4:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202bb6:	02090163          	beqz	s2,ffffffffc0202bd8 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202bba:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202bbc:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202bc0:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202bc4:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202bc8:	85ca                	mv	a1,s2
ffffffffc0202bca:	e73ff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202bce:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0202bd0:	000a0463          	beqz	s4,ffffffffc0202bd8 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202bd4:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0202bd8:	70e2                	ld	ra,56(sp)
ffffffffc0202bda:	7442                	ld	s0,48(sp)
ffffffffc0202bdc:	74a2                	ld	s1,40(sp)
ffffffffc0202bde:	7902                	ld	s2,32(sp)
ffffffffc0202be0:	69e2                	ld	s3,24(sp)
ffffffffc0202be2:	6a42                	ld	s4,16(sp)
ffffffffc0202be4:	6aa2                	ld	s5,8(sp)
ffffffffc0202be6:	6121                	addi	sp,sp,64
ffffffffc0202be8:	8082                	ret
        return -E_INVAL;
ffffffffc0202bea:	5575                	li	a0,-3
ffffffffc0202bec:	b7f5                	j	ffffffffc0202bd8 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202bee:	00005697          	auipc	a3,0x5
ffffffffc0202bf2:	cb268693          	addi	a3,a3,-846 # ffffffffc02078a0 <commands+0xfe8>
ffffffffc0202bf6:	00004617          	auipc	a2,0x4
ffffffffc0202bfa:	0d260613          	addi	a2,a2,210 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202bfe:	0a700593          	li	a1,167
ffffffffc0202c02:	00005517          	auipc	a0,0x5
ffffffffc0202c06:	c1650513          	addi	a0,a0,-1002 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202c0a:	dfefd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202c0e <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202c0e:	7139                	addi	sp,sp,-64
ffffffffc0202c10:	fc06                	sd	ra,56(sp)
ffffffffc0202c12:	f822                	sd	s0,48(sp)
ffffffffc0202c14:	f426                	sd	s1,40(sp)
ffffffffc0202c16:	f04a                	sd	s2,32(sp)
ffffffffc0202c18:	ec4e                	sd	s3,24(sp)
ffffffffc0202c1a:	e852                	sd	s4,16(sp)
ffffffffc0202c1c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202c1e:	c52d                	beqz	a0,ffffffffc0202c88 <dup_mmap+0x7a>
ffffffffc0202c20:	892a                	mv	s2,a0
ffffffffc0202c22:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202c24:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202c26:	e595                	bnez	a1,ffffffffc0202c52 <dup_mmap+0x44>
ffffffffc0202c28:	a085                	j	ffffffffc0202c88 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202c2a:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202c2c:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc0202c30:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202c34:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202c38:	e05ff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202c3c:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202c40:	fe843603          	ld	a2,-24(s0)
ffffffffc0202c44:	6c8c                	ld	a1,24(s1)
ffffffffc0202c46:	01893503          	ld	a0,24(s2)
ffffffffc0202c4a:	4701                	li	a4,0
ffffffffc0202c4c:	e44ff0ef          	jal	ra,ffffffffc0202290 <copy_range>
ffffffffc0202c50:	e105                	bnez	a0,ffffffffc0202c70 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202c52:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0202c54:	02848863          	beq	s1,s0,ffffffffc0202c84 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c58:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202c5c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202c60:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202c64:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c68:	1c1000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202c6c:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0202c6e:	fd55                	bnez	a0,ffffffffc0202c2a <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202c70:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202c72:	70e2                	ld	ra,56(sp)
ffffffffc0202c74:	7442                	ld	s0,48(sp)
ffffffffc0202c76:	74a2                	ld	s1,40(sp)
ffffffffc0202c78:	7902                	ld	s2,32(sp)
ffffffffc0202c7a:	69e2                	ld	s3,24(sp)
ffffffffc0202c7c:	6a42                	ld	s4,16(sp)
ffffffffc0202c7e:	6aa2                	ld	s5,8(sp)
ffffffffc0202c80:	6121                	addi	sp,sp,64
ffffffffc0202c82:	8082                	ret
    return 0;
ffffffffc0202c84:	4501                	li	a0,0
ffffffffc0202c86:	b7f5                	j	ffffffffc0202c72 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202c88:	00005697          	auipc	a3,0x5
ffffffffc0202c8c:	c2868693          	addi	a3,a3,-984 # ffffffffc02078b0 <commands+0xff8>
ffffffffc0202c90:	00004617          	auipc	a2,0x4
ffffffffc0202c94:	03860613          	addi	a2,a2,56 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202c98:	0c000593          	li	a1,192
ffffffffc0202c9c:	00005517          	auipc	a0,0x5
ffffffffc0202ca0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202ca4:	d64fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202ca8 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202ca8:	1101                	addi	sp,sp,-32
ffffffffc0202caa:	ec06                	sd	ra,24(sp)
ffffffffc0202cac:	e822                	sd	s0,16(sp)
ffffffffc0202cae:	e426                	sd	s1,8(sp)
ffffffffc0202cb0:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202cb2:	c531                	beqz	a0,ffffffffc0202cfe <exit_mmap+0x56>
ffffffffc0202cb4:	591c                	lw	a5,48(a0)
ffffffffc0202cb6:	84aa                	mv	s1,a0
ffffffffc0202cb8:	e3b9                	bnez	a5,ffffffffc0202cfe <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202cba:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202cbc:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202cc0:	02850663          	beq	a0,s0,ffffffffc0202cec <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202cc4:	ff043603          	ld	a2,-16(s0)
ffffffffc0202cc8:	fe843583          	ld	a1,-24(s0)
ffffffffc0202ccc:	854a                	mv	a0,s2
ffffffffc0202cce:	cbefe0ef          	jal	ra,ffffffffc020118c <unmap_range>
ffffffffc0202cd2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202cd4:	fe8498e3          	bne	s1,s0,ffffffffc0202cc4 <exit_mmap+0x1c>
ffffffffc0202cd8:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202cda:	00848c63          	beq	s1,s0,ffffffffc0202cf2 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202cde:	ff043603          	ld	a2,-16(s0)
ffffffffc0202ce2:	fe843583          	ld	a1,-24(s0)
ffffffffc0202ce6:	854a                	mv	a0,s2
ffffffffc0202ce8:	deafe0ef          	jal	ra,ffffffffc02012d2 <exit_range>
ffffffffc0202cec:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202cee:	fe8498e3          	bne	s1,s0,ffffffffc0202cde <exit_mmap+0x36>
    }
}
ffffffffc0202cf2:	60e2                	ld	ra,24(sp)
ffffffffc0202cf4:	6442                	ld	s0,16(sp)
ffffffffc0202cf6:	64a2                	ld	s1,8(sp)
ffffffffc0202cf8:	6902                	ld	s2,0(sp)
ffffffffc0202cfa:	6105                	addi	sp,sp,32
ffffffffc0202cfc:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202cfe:	00005697          	auipc	a3,0x5
ffffffffc0202d02:	bd268693          	addi	a3,a3,-1070 # ffffffffc02078d0 <commands+0x1018>
ffffffffc0202d06:	00004617          	auipc	a2,0x4
ffffffffc0202d0a:	fc260613          	addi	a2,a2,-62 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202d0e:	0d600593          	li	a1,214
ffffffffc0202d12:	00005517          	auipc	a0,0x5
ffffffffc0202d16:	b0650513          	addi	a0,a0,-1274 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202d1a:	ceefd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202d1e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202d1e:	7139                	addi	sp,sp,-64
ffffffffc0202d20:	f822                	sd	s0,48(sp)
ffffffffc0202d22:	f426                	sd	s1,40(sp)
ffffffffc0202d24:	fc06                	sd	ra,56(sp)
ffffffffc0202d26:	f04a                	sd	s2,32(sp)
ffffffffc0202d28:	ec4e                	sd	s3,24(sp)
ffffffffc0202d2a:	e852                	sd	s4,16(sp)
ffffffffc0202d2c:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202d2e:	c59ff0ef          	jal	ra,ffffffffc0202986 <mm_create>
    assert(mm != NULL);
ffffffffc0202d32:	84aa                	mv	s1,a0
ffffffffc0202d34:	03200413          	li	s0,50
ffffffffc0202d38:	e919                	bnez	a0,ffffffffc0202d4e <vmm_init+0x30>
ffffffffc0202d3a:	a991                	j	ffffffffc020318e <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0202d3c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d3e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d40:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0202d44:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d46:	8526                	mv	a0,s1
ffffffffc0202d48:	cf5ff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202d4c:	c80d                	beqz	s0,ffffffffc0202d7e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d4e:	03000513          	li	a0,48
ffffffffc0202d52:	0d7000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202d56:	85aa                	mv	a1,a0
ffffffffc0202d58:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202d5c:	f165                	bnez	a0,ffffffffc0202d3c <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202d5e:	00005697          	auipc	a3,0x5
ffffffffc0202d62:	daa68693          	addi	a3,a3,-598 # ffffffffc0207b08 <commands+0x1250>
ffffffffc0202d66:	00004617          	auipc	a2,0x4
ffffffffc0202d6a:	f6260613          	addi	a2,a2,-158 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202d6e:	11300593          	li	a1,275
ffffffffc0202d72:	00005517          	auipc	a0,0x5
ffffffffc0202d76:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202d7a:	c8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202d7e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d82:	1f900913          	li	s2,505
ffffffffc0202d86:	a819                	j	ffffffffc0202d9c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202d88:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d8a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d8c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d90:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d92:	8526                	mv	a0,s1
ffffffffc0202d94:	ca9ff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d98:	03240a63          	beq	s0,s2,ffffffffc0202dcc <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d9c:	03000513          	li	a0,48
ffffffffc0202da0:	089000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202da4:	85aa                	mv	a1,a0
ffffffffc0202da6:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202daa:	fd79                	bnez	a0,ffffffffc0202d88 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202dac:	00005697          	auipc	a3,0x5
ffffffffc0202db0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207b08 <commands+0x1250>
ffffffffc0202db4:	00004617          	auipc	a2,0x4
ffffffffc0202db8:	f1460613          	addi	a2,a2,-236 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202dbc:	11900593          	li	a1,281
ffffffffc0202dc0:	00005517          	auipc	a0,0x5
ffffffffc0202dc4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202dc8:	c40fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202dcc:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0202dce:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0202dd0:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202dd4:	2cf48d63          	beq	s1,a5,ffffffffc02030ae <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202dd8:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c7d4>
ffffffffc0202ddc:	ffe70613          	addi	a2,a4,-2
ffffffffc0202de0:	24d61763          	bne	a2,a3,ffffffffc020302e <vmm_init+0x310>
ffffffffc0202de4:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202de8:	24e69363          	bne	a3,a4,ffffffffc020302e <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202dec:	0715                	addi	a4,a4,5
ffffffffc0202dee:	679c                	ld	a5,8(a5)
ffffffffc0202df0:	feb712e3          	bne	a4,a1,ffffffffc0202dd4 <vmm_init+0xb6>
ffffffffc0202df4:	4a1d                	li	s4,7
ffffffffc0202df6:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202df8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202dfc:	85a2                	mv	a1,s0
ffffffffc0202dfe:	8526                	mv	a0,s1
ffffffffc0202e00:	bfdff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc0202e04:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202e06:	30050463          	beqz	a0,ffffffffc020310e <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202e0a:	00140593          	addi	a1,s0,1
ffffffffc0202e0e:	8526                	mv	a0,s1
ffffffffc0202e10:	bedff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc0202e14:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202e16:	2c050c63          	beqz	a0,ffffffffc02030ee <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202e1a:	85d2                	mv	a1,s4
ffffffffc0202e1c:	8526                	mv	a0,s1
ffffffffc0202e1e:	bdfff0ef          	jal	ra,ffffffffc02029fc <find_vma>
        assert(vma3 == NULL);
ffffffffc0202e22:	2a051663          	bnez	a0,ffffffffc02030ce <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202e26:	00340593          	addi	a1,s0,3
ffffffffc0202e2a:	8526                	mv	a0,s1
ffffffffc0202e2c:	bd1ff0ef          	jal	ra,ffffffffc02029fc <find_vma>
        assert(vma4 == NULL);
ffffffffc0202e30:	30051f63          	bnez	a0,ffffffffc020314e <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202e34:	00440593          	addi	a1,s0,4
ffffffffc0202e38:	8526                	mv	a0,s1
ffffffffc0202e3a:	bc3ff0ef          	jal	ra,ffffffffc02029fc <find_vma>
        assert(vma5 == NULL);
ffffffffc0202e3e:	2e051863          	bnez	a0,ffffffffc020312e <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202e42:	00893783          	ld	a5,8(s2)
ffffffffc0202e46:	20879463          	bne	a5,s0,ffffffffc020304e <vmm_init+0x330>
ffffffffc0202e4a:	01093783          	ld	a5,16(s2)
ffffffffc0202e4e:	20fa1063          	bne	s4,a5,ffffffffc020304e <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202e52:	0089b783          	ld	a5,8(s3)
ffffffffc0202e56:	20879c63          	bne	a5,s0,ffffffffc020306e <vmm_init+0x350>
ffffffffc0202e5a:	0109b783          	ld	a5,16(s3)
ffffffffc0202e5e:	20fa1863          	bne	s4,a5,ffffffffc020306e <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202e62:	0415                	addi	s0,s0,5
ffffffffc0202e64:	0a15                	addi	s4,s4,5
ffffffffc0202e66:	f9541be3          	bne	s0,s5,ffffffffc0202dfc <vmm_init+0xde>
ffffffffc0202e6a:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202e6c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202e6e:	85a2                	mv	a1,s0
ffffffffc0202e70:	8526                	mv	a0,s1
ffffffffc0202e72:	b8bff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc0202e76:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202e7a:	c90d                	beqz	a0,ffffffffc0202eac <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202e7c:	6914                	ld	a3,16(a0)
ffffffffc0202e7e:	6510                	ld	a2,8(a0)
ffffffffc0202e80:	00005517          	auipc	a0,0x5
ffffffffc0202e84:	b7050513          	addi	a0,a0,-1168 # ffffffffc02079f0 <commands+0x1138>
ffffffffc0202e88:	a44fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202e8c:	00005697          	auipc	a3,0x5
ffffffffc0202e90:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207a18 <commands+0x1160>
ffffffffc0202e94:	00004617          	auipc	a2,0x4
ffffffffc0202e98:	e3460613          	addi	a2,a2,-460 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0202e9c:	13b00593          	li	a1,315
ffffffffc0202ea0:	00005517          	auipc	a0,0x5
ffffffffc0202ea4:	97850513          	addi	a0,a0,-1672 # ffffffffc0207818 <commands+0xf60>
ffffffffc0202ea8:	b60fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0202eac:	147d                	addi	s0,s0,-1
ffffffffc0202eae:	fd2410e3          	bne	s0,s2,ffffffffc0202e6e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202eb2:	8526                	mv	a0,s1
ffffffffc0202eb4:	c59ff0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202eb8:	00005517          	auipc	a0,0x5
ffffffffc0202ebc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0207a30 <commands+0x1178>
ffffffffc0202ec0:	a0cfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202ec4:	868fe0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc0202ec8:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0202eca:	abdff0ef          	jal	ra,ffffffffc0202986 <mm_create>
ffffffffc0202ece:	000b0797          	auipc	a5,0xb0
ffffffffc0202ed2:	8ea7bd23          	sd	a0,-1798(a5) # ffffffffc02b27c8 <check_mm_struct>
ffffffffc0202ed6:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0202ed8:	28050b63          	beqz	a0,ffffffffc020316e <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202edc:	000b0497          	auipc	s1,0xb0
ffffffffc0202ee0:	8c44b483          	ld	s1,-1852(s1) # ffffffffc02b27a0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202ee4:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202ee6:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202ee8:	2e079f63          	bnez	a5,ffffffffc02031e6 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202eec:	03000513          	li	a0,48
ffffffffc0202ef0:	738000ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0202ef4:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0202ef6:	18050c63          	beqz	a0,ffffffffc020308e <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0202efa:	002007b7          	lui	a5,0x200
ffffffffc0202efe:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0202f02:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202f04:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202f06:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f0a:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202f0c:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f10:	b2dff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f14:	10000593          	li	a1,256
ffffffffc0202f18:	8522                	mv	a0,s0
ffffffffc0202f1a:	ae3ff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc0202f1e:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202f22:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f26:	2ea99063          	bne	s3,a0,ffffffffc0203206 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0202f2a:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc0202f2e:	0785                	addi	a5,a5,1
ffffffffc0202f30:	fee79de3          	bne	a5,a4,ffffffffc0202f2a <vmm_init+0x20c>
        sum += i;
ffffffffc0202f34:	6705                	lui	a4,0x1
ffffffffc0202f36:	10000793          	li	a5,256
ffffffffc0202f3a:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202f3e:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202f42:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0202f46:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0202f48:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202f4a:	fec79ce3          	bne	a5,a2,ffffffffc0202f42 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0202f4e:	2e071863          	bnez	a4,ffffffffc020323e <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f52:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202f54:	000b0a97          	auipc	s5,0xb0
ffffffffc0202f58:	854a8a93          	addi	s5,s5,-1964 # ffffffffc02b27a8 <npage>
ffffffffc0202f5c:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f60:	078a                	slli	a5,a5,0x2
ffffffffc0202f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f64:	2cc7f163          	bgeu	a5,a2,ffffffffc0203226 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f68:	00006a17          	auipc	s4,0x6
ffffffffc0202f6c:	db8a3a03          	ld	s4,-584(s4) # ffffffffc0208d20 <nbase>
ffffffffc0202f70:	414787b3          	sub	a5,a5,s4
ffffffffc0202f74:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0202f76:	8799                	srai	a5,a5,0x6
ffffffffc0202f78:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0202f7a:	00c79713          	slli	a4,a5,0xc
ffffffffc0202f7e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f80:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202f84:	24c77563          	bgeu	a4,a2,ffffffffc02031ce <vmm_init+0x4b0>
ffffffffc0202f88:	000b0997          	auipc	s3,0xb0
ffffffffc0202f8c:	8389b983          	ld	s3,-1992(s3) # ffffffffc02b27c0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202f90:	4581                	li	a1,0
ffffffffc0202f92:	8526                	mv	a0,s1
ffffffffc0202f94:	99b6                	add	s3,s3,a3
ffffffffc0202f96:	dcefe0ef          	jal	ra,ffffffffc0201564 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f9a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202f9e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fa2:	078a                	slli	a5,a5,0x2
ffffffffc0202fa4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fa6:	28e7f063          	bgeu	a5,a4,ffffffffc0203226 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202faa:	000b0997          	auipc	s3,0xb0
ffffffffc0202fae:	80698993          	addi	s3,s3,-2042 # ffffffffc02b27b0 <pages>
ffffffffc0202fb2:	0009b503          	ld	a0,0(s3)
ffffffffc0202fb6:	414787b3          	sub	a5,a5,s4
ffffffffc0202fba:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202fbc:	953e                	add	a0,a0,a5
ffffffffc0202fbe:	4585                	li	a1,1
ffffffffc0202fc0:	f2dfd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fc4:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202fc6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fca:	078a                	slli	a5,a5,0x2
ffffffffc0202fcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fce:	24e7fc63          	bgeu	a5,a4,ffffffffc0203226 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fd2:	0009b503          	ld	a0,0(s3)
ffffffffc0202fd6:	414787b3          	sub	a5,a5,s4
ffffffffc0202fda:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202fdc:	4585                	li	a1,1
ffffffffc0202fde:	953e                	add	a0,a0,a5
ffffffffc0202fe0:	f0dfd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    pgdir[0] = 0;
ffffffffc0202fe4:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0202fe8:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0202fec:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202fee:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202ff2:	b1bff0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202ff6:	000af797          	auipc	a5,0xaf
ffffffffc0202ffa:	7c07b923          	sd	zero,2002(a5) # ffffffffc02b27c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202ffe:	f2ffd0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc0203002:	1aa91663          	bne	s2,a0,ffffffffc02031ae <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203006:	00005517          	auipc	a0,0x5
ffffffffc020300a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0207ad0 <commands+0x1218>
ffffffffc020300e:	8befd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203012:	7442                	ld	s0,48(sp)
ffffffffc0203014:	70e2                	ld	ra,56(sp)
ffffffffc0203016:	74a2                	ld	s1,40(sp)
ffffffffc0203018:	7902                	ld	s2,32(sp)
ffffffffc020301a:	69e2                	ld	s3,24(sp)
ffffffffc020301c:	6a42                	ld	s4,16(sp)
ffffffffc020301e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203020:	00005517          	auipc	a0,0x5
ffffffffc0203024:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207af0 <commands+0x1238>
}
ffffffffc0203028:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020302a:	8a2fd06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020302e:	00005697          	auipc	a3,0x5
ffffffffc0203032:	8da68693          	addi	a3,a3,-1830 # ffffffffc0207908 <commands+0x1050>
ffffffffc0203036:	00004617          	auipc	a2,0x4
ffffffffc020303a:	c9260613          	addi	a2,a2,-878 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020303e:	12200593          	li	a1,290
ffffffffc0203042:	00004517          	auipc	a0,0x4
ffffffffc0203046:	7d650513          	addi	a0,a0,2006 # ffffffffc0207818 <commands+0xf60>
ffffffffc020304a:	9befd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020304e:	00005697          	auipc	a3,0x5
ffffffffc0203052:	94268693          	addi	a3,a3,-1726 # ffffffffc0207990 <commands+0x10d8>
ffffffffc0203056:	00004617          	auipc	a2,0x4
ffffffffc020305a:	c7260613          	addi	a2,a2,-910 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020305e:	13200593          	li	a1,306
ffffffffc0203062:	00004517          	auipc	a0,0x4
ffffffffc0203066:	7b650513          	addi	a0,a0,1974 # ffffffffc0207818 <commands+0xf60>
ffffffffc020306a:	99efd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020306e:	00005697          	auipc	a3,0x5
ffffffffc0203072:	95268693          	addi	a3,a3,-1710 # ffffffffc02079c0 <commands+0x1108>
ffffffffc0203076:	00004617          	auipc	a2,0x4
ffffffffc020307a:	c5260613          	addi	a2,a2,-942 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020307e:	13300593          	li	a1,307
ffffffffc0203082:	00004517          	auipc	a0,0x4
ffffffffc0203086:	79650513          	addi	a0,a0,1942 # ffffffffc0207818 <commands+0xf60>
ffffffffc020308a:	97efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020308e:	00005697          	auipc	a3,0x5
ffffffffc0203092:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0207b08 <commands+0x1250>
ffffffffc0203096:	00004617          	auipc	a2,0x4
ffffffffc020309a:	c3260613          	addi	a2,a2,-974 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020309e:	15200593          	li	a1,338
ffffffffc02030a2:	00004517          	auipc	a0,0x4
ffffffffc02030a6:	77650513          	addi	a0,a0,1910 # ffffffffc0207818 <commands+0xf60>
ffffffffc02030aa:	95efd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02030ae:	00005697          	auipc	a3,0x5
ffffffffc02030b2:	84268693          	addi	a3,a3,-1982 # ffffffffc02078f0 <commands+0x1038>
ffffffffc02030b6:	00004617          	auipc	a2,0x4
ffffffffc02030ba:	c1260613          	addi	a2,a2,-1006 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02030be:	12000593          	li	a1,288
ffffffffc02030c2:	00004517          	auipc	a0,0x4
ffffffffc02030c6:	75650513          	addi	a0,a0,1878 # ffffffffc0207818 <commands+0xf60>
ffffffffc02030ca:	93efd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc02030ce:	00005697          	auipc	a3,0x5
ffffffffc02030d2:	89268693          	addi	a3,a3,-1902 # ffffffffc0207960 <commands+0x10a8>
ffffffffc02030d6:	00004617          	auipc	a2,0x4
ffffffffc02030da:	bf260613          	addi	a2,a2,-1038 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02030de:	12c00593          	li	a1,300
ffffffffc02030e2:	00004517          	auipc	a0,0x4
ffffffffc02030e6:	73650513          	addi	a0,a0,1846 # ffffffffc0207818 <commands+0xf60>
ffffffffc02030ea:	91efd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02030ee:	00005697          	auipc	a3,0x5
ffffffffc02030f2:	86268693          	addi	a3,a3,-1950 # ffffffffc0207950 <commands+0x1098>
ffffffffc02030f6:	00004617          	auipc	a2,0x4
ffffffffc02030fa:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02030fe:	12a00593          	li	a1,298
ffffffffc0203102:	00004517          	auipc	a0,0x4
ffffffffc0203106:	71650513          	addi	a0,a0,1814 # ffffffffc0207818 <commands+0xf60>
ffffffffc020310a:	8fefd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc020310e:	00005697          	auipc	a3,0x5
ffffffffc0203112:	83268693          	addi	a3,a3,-1998 # ffffffffc0207940 <commands+0x1088>
ffffffffc0203116:	00004617          	auipc	a2,0x4
ffffffffc020311a:	bb260613          	addi	a2,a2,-1102 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020311e:	12800593          	li	a1,296
ffffffffc0203122:	00004517          	auipc	a0,0x4
ffffffffc0203126:	6f650513          	addi	a0,a0,1782 # ffffffffc0207818 <commands+0xf60>
ffffffffc020312a:	8defd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc020312e:	00005697          	auipc	a3,0x5
ffffffffc0203132:	85268693          	addi	a3,a3,-1966 # ffffffffc0207980 <commands+0x10c8>
ffffffffc0203136:	00004617          	auipc	a2,0x4
ffffffffc020313a:	b9260613          	addi	a2,a2,-1134 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020313e:	13000593          	li	a1,304
ffffffffc0203142:	00004517          	auipc	a0,0x4
ffffffffc0203146:	6d650513          	addi	a0,a0,1750 # ffffffffc0207818 <commands+0xf60>
ffffffffc020314a:	8befd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020314e:	00005697          	auipc	a3,0x5
ffffffffc0203152:	82268693          	addi	a3,a3,-2014 # ffffffffc0207970 <commands+0x10b8>
ffffffffc0203156:	00004617          	auipc	a2,0x4
ffffffffc020315a:	b7260613          	addi	a2,a2,-1166 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020315e:	12e00593          	li	a1,302
ffffffffc0203162:	00004517          	auipc	a0,0x4
ffffffffc0203166:	6b650513          	addi	a0,a0,1718 # ffffffffc0207818 <commands+0xf60>
ffffffffc020316a:	89efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020316e:	00005697          	auipc	a3,0x5
ffffffffc0203172:	8e268693          	addi	a3,a3,-1822 # ffffffffc0207a50 <commands+0x1198>
ffffffffc0203176:	00004617          	auipc	a2,0x4
ffffffffc020317a:	b5260613          	addi	a2,a2,-1198 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020317e:	14b00593          	li	a1,331
ffffffffc0203182:	00004517          	auipc	a0,0x4
ffffffffc0203186:	69650513          	addi	a0,a0,1686 # ffffffffc0207818 <commands+0xf60>
ffffffffc020318a:	87efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020318e:	00004697          	auipc	a3,0x4
ffffffffc0203192:	71268693          	addi	a3,a3,1810 # ffffffffc02078a0 <commands+0xfe8>
ffffffffc0203196:	00004617          	auipc	a2,0x4
ffffffffc020319a:	b3260613          	addi	a2,a2,-1230 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020319e:	10c00593          	li	a1,268
ffffffffc02031a2:	00004517          	auipc	a0,0x4
ffffffffc02031a6:	67650513          	addi	a0,a0,1654 # ffffffffc0207818 <commands+0xf60>
ffffffffc02031aa:	85efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02031ae:	00005697          	auipc	a3,0x5
ffffffffc02031b2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0207aa8 <commands+0x11f0>
ffffffffc02031b6:	00004617          	auipc	a2,0x4
ffffffffc02031ba:	b1260613          	addi	a2,a2,-1262 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02031be:	17000593          	li	a1,368
ffffffffc02031c2:	00004517          	auipc	a0,0x4
ffffffffc02031c6:	65650513          	addi	a0,a0,1622 # ffffffffc0207818 <commands+0xf60>
ffffffffc02031ca:	83efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031ce:	00004617          	auipc	a2,0x4
ffffffffc02031d2:	e4260613          	addi	a2,a2,-446 # ffffffffc0207010 <commands+0x758>
ffffffffc02031d6:	06900593          	li	a1,105
ffffffffc02031da:	00004517          	auipc	a0,0x4
ffffffffc02031de:	dfe50513          	addi	a0,a0,-514 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02031e2:	826fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02031e6:	00005697          	auipc	a3,0x5
ffffffffc02031ea:	88268693          	addi	a3,a3,-1918 # ffffffffc0207a68 <commands+0x11b0>
ffffffffc02031ee:	00004617          	auipc	a2,0x4
ffffffffc02031f2:	ada60613          	addi	a2,a2,-1318 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02031f6:	14f00593          	li	a1,335
ffffffffc02031fa:	00004517          	auipc	a0,0x4
ffffffffc02031fe:	61e50513          	addi	a0,a0,1566 # ffffffffc0207818 <commands+0xf60>
ffffffffc0203202:	806fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203206:	00005697          	auipc	a3,0x5
ffffffffc020320a:	87268693          	addi	a3,a3,-1934 # ffffffffc0207a78 <commands+0x11c0>
ffffffffc020320e:	00004617          	auipc	a2,0x4
ffffffffc0203212:	aba60613          	addi	a2,a2,-1350 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203216:	15700593          	li	a1,343
ffffffffc020321a:	00004517          	auipc	a0,0x4
ffffffffc020321e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207818 <commands+0xf60>
ffffffffc0203222:	fe7fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203226:	00004617          	auipc	a2,0x4
ffffffffc020322a:	d9260613          	addi	a2,a2,-622 # ffffffffc0206fb8 <commands+0x700>
ffffffffc020322e:	06200593          	li	a1,98
ffffffffc0203232:	00004517          	auipc	a0,0x4
ffffffffc0203236:	da650513          	addi	a0,a0,-602 # ffffffffc0206fd8 <commands+0x720>
ffffffffc020323a:	fcffc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc020323e:	00005697          	auipc	a3,0x5
ffffffffc0203242:	85a68693          	addi	a3,a3,-1958 # ffffffffc0207a98 <commands+0x11e0>
ffffffffc0203246:	00004617          	auipc	a2,0x4
ffffffffc020324a:	a8260613          	addi	a2,a2,-1406 # ffffffffc0206cc8 <commands+0x410>
ffffffffc020324e:	16300593          	li	a1,355
ffffffffc0203252:	00004517          	auipc	a0,0x4
ffffffffc0203256:	5c650513          	addi	a0,a0,1478 # ffffffffc0207818 <commands+0xf60>
ffffffffc020325a:	faffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020325e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020325e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203260:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203262:	f022                	sd	s0,32(sp)
ffffffffc0203264:	ec26                	sd	s1,24(sp)
ffffffffc0203266:	f406                	sd	ra,40(sp)
ffffffffc0203268:	e84a                	sd	s2,16(sp)
ffffffffc020326a:	8432                	mv	s0,a2
ffffffffc020326c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020326e:	f8eff0ef          	jal	ra,ffffffffc02029fc <find_vma>

    pgfault_num++;
ffffffffc0203272:	000af797          	auipc	a5,0xaf
ffffffffc0203276:	55e7a783          	lw	a5,1374(a5) # ffffffffc02b27d0 <pgfault_num>
ffffffffc020327a:	2785                	addiw	a5,a5,1
ffffffffc020327c:	000af717          	auipc	a4,0xaf
ffffffffc0203280:	54f72a23          	sw	a5,1364(a4) # ffffffffc02b27d0 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203284:	c551                	beqz	a0,ffffffffc0203310 <do_pgfault+0xb2>
ffffffffc0203286:	651c                	ld	a5,8(a0)
ffffffffc0203288:	08f46463          	bltu	s0,a5,ffffffffc0203310 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020328c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020328e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203290:	8b89                	andi	a5,a5,2
ffffffffc0203292:	efb1                	bnez	a5,ffffffffc02032ee <do_pgfault+0x90>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203294:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203296:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203298:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020329a:	4605                	li	a2,1
ffffffffc020329c:	85a2                	mv	a1,s0
ffffffffc020329e:	cc9fd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02032a2:	c945                	beqz	a0,ffffffffc0203352 <do_pgfault+0xf4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02032a4:	610c                	ld	a1,0(a0)
ffffffffc02032a6:	c5b1                	beqz	a1,ffffffffc02032f2 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02032a8:	000af797          	auipc	a5,0xaf
ffffffffc02032ac:	5487a783          	lw	a5,1352(a5) # ffffffffc02b27f0 <swap_init_ok>
ffffffffc02032b0:	cbad                	beqz	a5,ffffffffc0203322 <do_pgfault+0xc4>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
        	             if(swap_in(mm, addr, &page) != 0 ){
ffffffffc02032b2:	0030                	addi	a2,sp,8
ffffffffc02032b4:	85a2                	mv	a1,s0
ffffffffc02032b6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02032b8:	e402                	sd	zero,8(sp)
        	             if(swap_in(mm, addr, &page) != 0 ){
ffffffffc02032ba:	5a7000ef          	jal	ra,ffffffffc0204060 <swap_in>
ffffffffc02032be:	e935                	bnez	a0,ffffffffc0203332 <do_pgfault+0xd4>
            }
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            if(page_insert(mm->pgdir, page, addr, perm) != 0){
ffffffffc02032c0:	65a2                	ld	a1,8(sp)
ffffffffc02032c2:	6c88                	ld	a0,24(s1)
ffffffffc02032c4:	86ca                	mv	a3,s2
ffffffffc02032c6:	8622                	mv	a2,s0
ffffffffc02032c8:	b38fe0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc02032cc:	892a                	mv	s2,a0
ffffffffc02032ce:	e935                	bnez	a0,ffffffffc0203342 <do_pgfault+0xe4>
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc02032d0:	6622                	ld	a2,8(sp)
ffffffffc02032d2:	4685                	li	a3,1
ffffffffc02032d4:	85a2                	mv	a1,s0
ffffffffc02032d6:	8526                	mv	a0,s1
ffffffffc02032d8:	469000ef          	jal	ra,ffffffffc0203f40 <swap_map_swappable>
			page->pra_vaddr = addr;
ffffffffc02032dc:	67a2                	ld	a5,8(sp)
ffffffffc02032de:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc02032e0:	70a2                	ld	ra,40(sp)
ffffffffc02032e2:	7402                	ld	s0,32(sp)
ffffffffc02032e4:	64e2                	ld	s1,24(sp)
ffffffffc02032e6:	854a                	mv	a0,s2
ffffffffc02032e8:	6942                	ld	s2,16(sp)
ffffffffc02032ea:	6145                	addi	sp,sp,48
ffffffffc02032ec:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02032ee:	495d                	li	s2,23
ffffffffc02032f0:	b755                	j	ffffffffc0203294 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02032f2:	6c88                	ld	a0,24(s1)
ffffffffc02032f4:	864a                	mv	a2,s2
ffffffffc02032f6:	85a2                	mv	a1,s0
ffffffffc02032f8:	9b2ff0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
   ret = 0;
ffffffffc02032fc:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02032fe:	f16d                	bnez	a0,ffffffffc02032e0 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203300:	00005517          	auipc	a0,0x5
ffffffffc0203304:	86850513          	addi	a0,a0,-1944 # ffffffffc0207b68 <commands+0x12b0>
ffffffffc0203308:	dc5fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020330c:	5971                	li	s2,-4
            goto failed;
ffffffffc020330e:	bfc9                	j	ffffffffc02032e0 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203310:	85a2                	mv	a1,s0
ffffffffc0203312:	00005517          	auipc	a0,0x5
ffffffffc0203316:	80650513          	addi	a0,a0,-2042 # ffffffffc0207b18 <commands+0x1260>
ffffffffc020331a:	db3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc020331e:	5975                	li	s2,-3
        goto failed;
ffffffffc0203320:	b7c1                	j	ffffffffc02032e0 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203322:	00005517          	auipc	a0,0x5
ffffffffc0203326:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207bd8 <commands+0x1320>
ffffffffc020332a:	da3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020332e:	5971                	li	s2,-4
            goto failed;
ffffffffc0203330:	bf45                	j	ffffffffc02032e0 <do_pgfault+0x82>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0203332:	00005517          	auipc	a0,0x5
ffffffffc0203336:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207b90 <commands+0x12d8>
ffffffffc020333a:	d93fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020333e:	5971                	li	s2,-4
ffffffffc0203340:	b745                	j	ffffffffc02032e0 <do_pgfault+0x82>
                cprintf("page_insert in do_pgfault failed\n");
ffffffffc0203342:	00005517          	auipc	a0,0x5
ffffffffc0203346:	86e50513          	addi	a0,a0,-1938 # ffffffffc0207bb0 <commands+0x12f8>
ffffffffc020334a:	d83fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020334e:	5971                	li	s2,-4
ffffffffc0203350:	bf41                	j	ffffffffc02032e0 <do_pgfault+0x82>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203352:	00004517          	auipc	a0,0x4
ffffffffc0203356:	7f650513          	addi	a0,a0,2038 # ffffffffc0207b48 <commands+0x1290>
ffffffffc020335a:	d73fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020335e:	5971                	li	s2,-4
        goto failed;
ffffffffc0203360:	b741                	j	ffffffffc02032e0 <do_pgfault+0x82>

ffffffffc0203362 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0203362:	7179                	addi	sp,sp,-48
ffffffffc0203364:	f022                	sd	s0,32(sp)
ffffffffc0203366:	f406                	sd	ra,40(sp)
ffffffffc0203368:	ec26                	sd	s1,24(sp)
ffffffffc020336a:	e84a                	sd	s2,16(sp)
ffffffffc020336c:	e44e                	sd	s3,8(sp)
ffffffffc020336e:	e052                	sd	s4,0(sp)
ffffffffc0203370:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0203372:	c135                	beqz	a0,ffffffffc02033d6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0203374:	002007b7          	lui	a5,0x200
ffffffffc0203378:	04f5e663          	bltu	a1,a5,ffffffffc02033c4 <user_mem_check+0x62>
ffffffffc020337c:	00c584b3          	add	s1,a1,a2
ffffffffc0203380:	0495f263          	bgeu	a1,s1,ffffffffc02033c4 <user_mem_check+0x62>
ffffffffc0203384:	4785                	li	a5,1
ffffffffc0203386:	07fe                	slli	a5,a5,0x1f
ffffffffc0203388:	0297ee63          	bltu	a5,s1,ffffffffc02033c4 <user_mem_check+0x62>
ffffffffc020338c:	892a                	mv	s2,a0
ffffffffc020338e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203390:	6a05                	lui	s4,0x1
ffffffffc0203392:	a821                	j	ffffffffc02033aa <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0203394:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203398:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020339a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020339c:	c685                	beqz	a3,ffffffffc02033c4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020339e:	c399                	beqz	a5,ffffffffc02033a4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02033a0:	02e46263          	bltu	s0,a4,ffffffffc02033c4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02033a4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02033a6:	04947663          	bgeu	s0,s1,ffffffffc02033f2 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02033aa:	85a2                	mv	a1,s0
ffffffffc02033ac:	854a                	mv	a0,s2
ffffffffc02033ae:	e4eff0ef          	jal	ra,ffffffffc02029fc <find_vma>
ffffffffc02033b2:	c909                	beqz	a0,ffffffffc02033c4 <user_mem_check+0x62>
ffffffffc02033b4:	6518                	ld	a4,8(a0)
ffffffffc02033b6:	00e46763          	bltu	s0,a4,ffffffffc02033c4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02033ba:	4d1c                	lw	a5,24(a0)
ffffffffc02033bc:	fc099ce3          	bnez	s3,ffffffffc0203394 <user_mem_check+0x32>
ffffffffc02033c0:	8b85                	andi	a5,a5,1
ffffffffc02033c2:	f3ed                	bnez	a5,ffffffffc02033a4 <user_mem_check+0x42>
            return 0;
ffffffffc02033c4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02033c6:	70a2                	ld	ra,40(sp)
ffffffffc02033c8:	7402                	ld	s0,32(sp)
ffffffffc02033ca:	64e2                	ld	s1,24(sp)
ffffffffc02033cc:	6942                	ld	s2,16(sp)
ffffffffc02033ce:	69a2                	ld	s3,8(sp)
ffffffffc02033d0:	6a02                	ld	s4,0(sp)
ffffffffc02033d2:	6145                	addi	sp,sp,48
ffffffffc02033d4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02033d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02033da:	4501                	li	a0,0
ffffffffc02033dc:	fef5e5e3          	bltu	a1,a5,ffffffffc02033c6 <user_mem_check+0x64>
ffffffffc02033e0:	962e                	add	a2,a2,a1
ffffffffc02033e2:	fec5f2e3          	bgeu	a1,a2,ffffffffc02033c6 <user_mem_check+0x64>
ffffffffc02033e6:	c8000537          	lui	a0,0xc8000
ffffffffc02033ea:	0505                	addi	a0,a0,1
ffffffffc02033ec:	00a63533          	sltu	a0,a2,a0
ffffffffc02033f0:	bfd9                	j	ffffffffc02033c6 <user_mem_check+0x64>
        return 1;
ffffffffc02033f2:	4505                	li	a0,1
ffffffffc02033f4:	bfc9                	j	ffffffffc02033c6 <user_mem_check+0x64>

ffffffffc02033f6 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02033f6:	c94d                	beqz	a0,ffffffffc02034a8 <slob_free+0xb2>
{
ffffffffc02033f8:	1141                	addi	sp,sp,-16
ffffffffc02033fa:	e022                	sd	s0,0(sp)
ffffffffc02033fc:	e406                	sd	ra,8(sp)
ffffffffc02033fe:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0203400:	e9c1                	bnez	a1,ffffffffc0203490 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203402:	100027f3          	csrr	a5,sstatus
ffffffffc0203406:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203408:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020340a:	ebd9                	bnez	a5,ffffffffc02034a0 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020340c:	000a4617          	auipc	a2,0xa4
ffffffffc0203410:	e9c60613          	addi	a2,a2,-356 # ffffffffc02a72a8 <slobfree>
ffffffffc0203414:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203416:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203418:	679c                	ld	a5,8(a5)
ffffffffc020341a:	02877a63          	bgeu	a4,s0,ffffffffc020344e <slob_free+0x58>
ffffffffc020341e:	00f46463          	bltu	s0,a5,ffffffffc0203426 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203422:	fef76ae3          	bltu	a4,a5,ffffffffc0203416 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0203426:	400c                	lw	a1,0(s0)
ffffffffc0203428:	00459693          	slli	a3,a1,0x4
ffffffffc020342c:	96a2                	add	a3,a3,s0
ffffffffc020342e:	02d78a63          	beq	a5,a3,ffffffffc0203462 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0203432:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0203434:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0203436:	00469793          	slli	a5,a3,0x4
ffffffffc020343a:	97ba                	add	a5,a5,a4
ffffffffc020343c:	02f40e63          	beq	s0,a5,ffffffffc0203478 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0203440:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0203442:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0203444:	e129                	bnez	a0,ffffffffc0203486 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203446:	60a2                	ld	ra,8(sp)
ffffffffc0203448:	6402                	ld	s0,0(sp)
ffffffffc020344a:	0141                	addi	sp,sp,16
ffffffffc020344c:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020344e:	fcf764e3          	bltu	a4,a5,ffffffffc0203416 <slob_free+0x20>
ffffffffc0203452:	fcf472e3          	bgeu	s0,a5,ffffffffc0203416 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0203456:	400c                	lw	a1,0(s0)
ffffffffc0203458:	00459693          	slli	a3,a1,0x4
ffffffffc020345c:	96a2                	add	a3,a3,s0
ffffffffc020345e:	fcd79ae3          	bne	a5,a3,ffffffffc0203432 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0203462:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203464:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0203466:	9db5                	addw	a1,a1,a3
ffffffffc0203468:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020346a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020346c:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020346e:	00469793          	slli	a5,a3,0x4
ffffffffc0203472:	97ba                	add	a5,a5,a4
ffffffffc0203474:	fcf416e3          	bne	s0,a5,ffffffffc0203440 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0203478:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020347a:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020347c:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc020347e:	9ebd                	addw	a3,a3,a5
ffffffffc0203480:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0203482:	e70c                	sd	a1,8(a4)
ffffffffc0203484:	d169                	beqz	a0,ffffffffc0203446 <slob_free+0x50>
}
ffffffffc0203486:	6402                	ld	s0,0(sp)
ffffffffc0203488:	60a2                	ld	ra,8(sp)
ffffffffc020348a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020348c:	9b6fd06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0203490:	25bd                	addiw	a1,a1,15
ffffffffc0203492:	8191                	srli	a1,a1,0x4
ffffffffc0203494:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203496:	100027f3          	csrr	a5,sstatus
ffffffffc020349a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020349c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020349e:	d7bd                	beqz	a5,ffffffffc020340c <slob_free+0x16>
        intr_disable();
ffffffffc02034a0:	9a8fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02034a4:	4505                	li	a0,1
ffffffffc02034a6:	b79d                	j	ffffffffc020340c <slob_free+0x16>
ffffffffc02034a8:	8082                	ret

ffffffffc02034aa <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034aa:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034ac:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034ae:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034b2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034b4:	9a7fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
  if(!page)
ffffffffc02034b8:	c91d                	beqz	a0,ffffffffc02034ee <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02034ba:	000af697          	auipc	a3,0xaf
ffffffffc02034be:	2f66b683          	ld	a3,758(a3) # ffffffffc02b27b0 <pages>
ffffffffc02034c2:	8d15                	sub	a0,a0,a3
ffffffffc02034c4:	8519                	srai	a0,a0,0x6
ffffffffc02034c6:	00006697          	auipc	a3,0x6
ffffffffc02034ca:	85a6b683          	ld	a3,-1958(a3) # ffffffffc0208d20 <nbase>
ffffffffc02034ce:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02034d0:	00c51793          	slli	a5,a0,0xc
ffffffffc02034d4:	83b1                	srli	a5,a5,0xc
ffffffffc02034d6:	000af717          	auipc	a4,0xaf
ffffffffc02034da:	2d273703          	ld	a4,722(a4) # ffffffffc02b27a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02034de:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02034e0:	00e7fa63          	bgeu	a5,a4,ffffffffc02034f4 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02034e4:	000af697          	auipc	a3,0xaf
ffffffffc02034e8:	2dc6b683          	ld	a3,732(a3) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc02034ec:	9536                	add	a0,a0,a3
}
ffffffffc02034ee:	60a2                	ld	ra,8(sp)
ffffffffc02034f0:	0141                	addi	sp,sp,16
ffffffffc02034f2:	8082                	ret
ffffffffc02034f4:	86aa                	mv	a3,a0
ffffffffc02034f6:	00004617          	auipc	a2,0x4
ffffffffc02034fa:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0207010 <commands+0x758>
ffffffffc02034fe:	06900593          	li	a1,105
ffffffffc0203502:	00004517          	auipc	a0,0x4
ffffffffc0203506:	ad650513          	addi	a0,a0,-1322 # ffffffffc0206fd8 <commands+0x720>
ffffffffc020350a:	cfffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020350e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020350e:	1101                	addi	sp,sp,-32
ffffffffc0203510:	ec06                	sd	ra,24(sp)
ffffffffc0203512:	e822                	sd	s0,16(sp)
ffffffffc0203514:	e426                	sd	s1,8(sp)
ffffffffc0203516:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203518:	01050713          	addi	a4,a0,16
ffffffffc020351c:	6785                	lui	a5,0x1
ffffffffc020351e:	0cf77363          	bgeu	a4,a5,ffffffffc02035e4 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0203522:	00f50493          	addi	s1,a0,15
ffffffffc0203526:	8091                	srli	s1,s1,0x4
ffffffffc0203528:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020352a:	10002673          	csrr	a2,sstatus
ffffffffc020352e:	8a09                	andi	a2,a2,2
ffffffffc0203530:	e25d                	bnez	a2,ffffffffc02035d6 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0203532:	000a4917          	auipc	s2,0xa4
ffffffffc0203536:	d7690913          	addi	s2,s2,-650 # ffffffffc02a72a8 <slobfree>
ffffffffc020353a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020353e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203540:	4398                	lw	a4,0(a5)
ffffffffc0203542:	08975e63          	bge	a4,s1,ffffffffc02035de <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0203546:	00f68b63          	beq	a3,a5,ffffffffc020355c <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020354a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020354c:	4018                	lw	a4,0(s0)
ffffffffc020354e:	02975a63          	bge	a4,s1,ffffffffc0203582 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0203552:	00093683          	ld	a3,0(s2)
ffffffffc0203556:	87a2                	mv	a5,s0
ffffffffc0203558:	fef699e3          	bne	a3,a5,ffffffffc020354a <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020355c:	ee31                	bnez	a2,ffffffffc02035b8 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020355e:	4501                	li	a0,0
ffffffffc0203560:	f4bff0ef          	jal	ra,ffffffffc02034aa <__slob_get_free_pages.constprop.0>
ffffffffc0203564:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0203566:	cd05                	beqz	a0,ffffffffc020359e <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203568:	6585                	lui	a1,0x1
ffffffffc020356a:	e8dff0ef          	jal	ra,ffffffffc02033f6 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020356e:	10002673          	csrr	a2,sstatus
ffffffffc0203572:	8a09                	andi	a2,a2,2
ffffffffc0203574:	ee05                	bnez	a2,ffffffffc02035ac <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0203576:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020357a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020357c:	4018                	lw	a4,0(s0)
ffffffffc020357e:	fc974ae3          	blt	a4,s1,ffffffffc0203552 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0203582:	04e48763          	beq	s1,a4,ffffffffc02035d0 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0203586:	00449693          	slli	a3,s1,0x4
ffffffffc020358a:	96a2                	add	a3,a3,s0
ffffffffc020358c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020358e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0203590:	9f05                	subw	a4,a4,s1
ffffffffc0203592:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203594:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203596:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203598:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020359c:	e20d                	bnez	a2,ffffffffc02035be <slob_alloc.constprop.0+0xb0>
}
ffffffffc020359e:	60e2                	ld	ra,24(sp)
ffffffffc02035a0:	8522                	mv	a0,s0
ffffffffc02035a2:	6442                	ld	s0,16(sp)
ffffffffc02035a4:	64a2                	ld	s1,8(sp)
ffffffffc02035a6:	6902                	ld	s2,0(sp)
ffffffffc02035a8:	6105                	addi	sp,sp,32
ffffffffc02035aa:	8082                	ret
        intr_disable();
ffffffffc02035ac:	89cfd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc02035b0:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02035b4:	4605                	li	a2,1
ffffffffc02035b6:	b7d1                	j	ffffffffc020357a <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02035b8:	88afd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02035bc:	b74d                	j	ffffffffc020355e <slob_alloc.constprop.0+0x50>
ffffffffc02035be:	884fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc02035c2:	60e2                	ld	ra,24(sp)
ffffffffc02035c4:	8522                	mv	a0,s0
ffffffffc02035c6:	6442                	ld	s0,16(sp)
ffffffffc02035c8:	64a2                	ld	s1,8(sp)
ffffffffc02035ca:	6902                	ld	s2,0(sp)
ffffffffc02035cc:	6105                	addi	sp,sp,32
ffffffffc02035ce:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02035d0:	6418                	ld	a4,8(s0)
ffffffffc02035d2:	e798                	sd	a4,8(a5)
ffffffffc02035d4:	b7d1                	j	ffffffffc0203598 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02035d6:	872fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02035da:	4605                	li	a2,1
ffffffffc02035dc:	bf99                	j	ffffffffc0203532 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02035de:	843e                	mv	s0,a5
ffffffffc02035e0:	87b6                	mv	a5,a3
ffffffffc02035e2:	b745                	j	ffffffffc0203582 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02035e4:	00004697          	auipc	a3,0x4
ffffffffc02035e8:	61c68693          	addi	a3,a3,1564 # ffffffffc0207c00 <commands+0x1348>
ffffffffc02035ec:	00003617          	auipc	a2,0x3
ffffffffc02035f0:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02035f4:	06400593          	li	a1,100
ffffffffc02035f8:	00004517          	auipc	a0,0x4
ffffffffc02035fc:	62850513          	addi	a0,a0,1576 # ffffffffc0207c20 <commands+0x1368>
ffffffffc0203600:	c09fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203604 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203604:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203606:	00004517          	auipc	a0,0x4
ffffffffc020360a:	63250513          	addi	a0,a0,1586 # ffffffffc0207c38 <commands+0x1380>
kmalloc_init(void) {
ffffffffc020360e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203610:	abdfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203614:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203616:	00004517          	auipc	a0,0x4
ffffffffc020361a:	63a50513          	addi	a0,a0,1594 # ffffffffc0207c50 <commands+0x1398>
}
ffffffffc020361e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203620:	aadfc06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0203624 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0203624:	4501                	li	a0,0
ffffffffc0203626:	8082                	ret

ffffffffc0203628 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203628:	1101                	addi	sp,sp,-32
ffffffffc020362a:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020362c:	6905                	lui	s2,0x1
{
ffffffffc020362e:	e822                	sd	s0,16(sp)
ffffffffc0203630:	ec06                	sd	ra,24(sp)
ffffffffc0203632:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203634:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0203638:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020363a:	04a7f963          	bgeu	a5,a0,ffffffffc020368c <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020363e:	4561                	li	a0,24
ffffffffc0203640:	ecfff0ef          	jal	ra,ffffffffc020350e <slob_alloc.constprop.0>
ffffffffc0203644:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203646:	c929                	beqz	a0,ffffffffc0203698 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0203648:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020364c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020364e:	00f95763          	bge	s2,a5,ffffffffc020365c <kmalloc+0x34>
ffffffffc0203652:	6705                	lui	a4,0x1
ffffffffc0203654:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203656:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203658:	fef74ee3          	blt	a4,a5,ffffffffc0203654 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020365c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020365e:	e4dff0ef          	jal	ra,ffffffffc02034aa <__slob_get_free_pages.constprop.0>
ffffffffc0203662:	e488                	sd	a0,8(s1)
ffffffffc0203664:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203666:	c525                	beqz	a0,ffffffffc02036ce <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203668:	100027f3          	csrr	a5,sstatus
ffffffffc020366c:	8b89                	andi	a5,a5,2
ffffffffc020366e:	ef8d                	bnez	a5,ffffffffc02036a8 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0203670:	000af797          	auipc	a5,0xaf
ffffffffc0203674:	16878793          	addi	a5,a5,360 # ffffffffc02b27d8 <bigblocks>
ffffffffc0203678:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020367a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020367c:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc020367e:	60e2                	ld	ra,24(sp)
ffffffffc0203680:	8522                	mv	a0,s0
ffffffffc0203682:	6442                	ld	s0,16(sp)
ffffffffc0203684:	64a2                	ld	s1,8(sp)
ffffffffc0203686:	6902                	ld	s2,0(sp)
ffffffffc0203688:	6105                	addi	sp,sp,32
ffffffffc020368a:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020368c:	0541                	addi	a0,a0,16
ffffffffc020368e:	e81ff0ef          	jal	ra,ffffffffc020350e <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203692:	01050413          	addi	s0,a0,16
ffffffffc0203696:	f565                	bnez	a0,ffffffffc020367e <kmalloc+0x56>
ffffffffc0203698:	4401                	li	s0,0
}
ffffffffc020369a:	60e2                	ld	ra,24(sp)
ffffffffc020369c:	8522                	mv	a0,s0
ffffffffc020369e:	6442                	ld	s0,16(sp)
ffffffffc02036a0:	64a2                	ld	s1,8(sp)
ffffffffc02036a2:	6902                	ld	s2,0(sp)
ffffffffc02036a4:	6105                	addi	sp,sp,32
ffffffffc02036a6:	8082                	ret
        intr_disable();
ffffffffc02036a8:	fa1fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc02036ac:	000af797          	auipc	a5,0xaf
ffffffffc02036b0:	12c78793          	addi	a5,a5,300 # ffffffffc02b27d8 <bigblocks>
ffffffffc02036b4:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02036b6:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02036b8:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02036ba:	f89fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc02036be:	6480                	ld	s0,8(s1)
}
ffffffffc02036c0:	60e2                	ld	ra,24(sp)
ffffffffc02036c2:	64a2                	ld	s1,8(sp)
ffffffffc02036c4:	8522                	mv	a0,s0
ffffffffc02036c6:	6442                	ld	s0,16(sp)
ffffffffc02036c8:	6902                	ld	s2,0(sp)
ffffffffc02036ca:	6105                	addi	sp,sp,32
ffffffffc02036cc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02036ce:	45e1                	li	a1,24
ffffffffc02036d0:	8526                	mv	a0,s1
ffffffffc02036d2:	d25ff0ef          	jal	ra,ffffffffc02033f6 <slob_free>
  return __kmalloc(size, 0);
ffffffffc02036d6:	b765                	j	ffffffffc020367e <kmalloc+0x56>

ffffffffc02036d8 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02036d8:	c179                	beqz	a0,ffffffffc020379e <kfree+0xc6>
{
ffffffffc02036da:	1101                	addi	sp,sp,-32
ffffffffc02036dc:	e822                	sd	s0,16(sp)
ffffffffc02036de:	ec06                	sd	ra,24(sp)
ffffffffc02036e0:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02036e2:	03451793          	slli	a5,a0,0x34
ffffffffc02036e6:	842a                	mv	s0,a0
ffffffffc02036e8:	e7c1                	bnez	a5,ffffffffc0203770 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036ea:	100027f3          	csrr	a5,sstatus
ffffffffc02036ee:	8b89                	andi	a5,a5,2
ffffffffc02036f0:	ebc9                	bnez	a5,ffffffffc0203782 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02036f2:	000af797          	auipc	a5,0xaf
ffffffffc02036f6:	0e67b783          	ld	a5,230(a5) # ffffffffc02b27d8 <bigblocks>
    return 0;
ffffffffc02036fa:	4601                	li	a2,0
ffffffffc02036fc:	cbb5                	beqz	a5,ffffffffc0203770 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02036fe:	000af697          	auipc	a3,0xaf
ffffffffc0203702:	0da68693          	addi	a3,a3,218 # ffffffffc02b27d8 <bigblocks>
ffffffffc0203706:	a021                	j	ffffffffc020370e <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203708:	01048693          	addi	a3,s1,16
ffffffffc020370c:	c3ad                	beqz	a5,ffffffffc020376e <kfree+0x96>
			if (bb->pages == block) {
ffffffffc020370e:	6798                	ld	a4,8(a5)
ffffffffc0203710:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0203712:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0203714:	fe871ae3          	bne	a4,s0,ffffffffc0203708 <kfree+0x30>
				*last = bb->next;
ffffffffc0203718:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc020371a:	ee3d                	bnez	a2,ffffffffc0203798 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc020371c:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203720:	4098                	lw	a4,0(s1)
ffffffffc0203722:	08f46b63          	bltu	s0,a5,ffffffffc02037b8 <kfree+0xe0>
ffffffffc0203726:	000af697          	auipc	a3,0xaf
ffffffffc020372a:	09a6b683          	ld	a3,154(a3) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc020372e:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203730:	8031                	srli	s0,s0,0xc
ffffffffc0203732:	000af797          	auipc	a5,0xaf
ffffffffc0203736:	0767b783          	ld	a5,118(a5) # ffffffffc02b27a8 <npage>
ffffffffc020373a:	06f47363          	bgeu	s0,a5,ffffffffc02037a0 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc020373e:	00005517          	auipc	a0,0x5
ffffffffc0203742:	5e253503          	ld	a0,1506(a0) # ffffffffc0208d20 <nbase>
ffffffffc0203746:	8c09                	sub	s0,s0,a0
ffffffffc0203748:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020374a:	000af517          	auipc	a0,0xaf
ffffffffc020374e:	06653503          	ld	a0,102(a0) # ffffffffc02b27b0 <pages>
ffffffffc0203752:	4585                	li	a1,1
ffffffffc0203754:	9522                	add	a0,a0,s0
ffffffffc0203756:	00e595bb          	sllw	a1,a1,a4
ffffffffc020375a:	f92fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020375e:	6442                	ld	s0,16(sp)
ffffffffc0203760:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203762:	8526                	mv	a0,s1
}
ffffffffc0203764:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203766:	45e1                	li	a1,24
}
ffffffffc0203768:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020376a:	c8dff06f          	j	ffffffffc02033f6 <slob_free>
ffffffffc020376e:	e215                	bnez	a2,ffffffffc0203792 <kfree+0xba>
ffffffffc0203770:	ff040513          	addi	a0,s0,-16
}
ffffffffc0203774:	6442                	ld	s0,16(sp)
ffffffffc0203776:	60e2                	ld	ra,24(sp)
ffffffffc0203778:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020377a:	4581                	li	a1,0
}
ffffffffc020377c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020377e:	c79ff06f          	j	ffffffffc02033f6 <slob_free>
        intr_disable();
ffffffffc0203782:	ec7fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203786:	000af797          	auipc	a5,0xaf
ffffffffc020378a:	0527b783          	ld	a5,82(a5) # ffffffffc02b27d8 <bigblocks>
        return 1;
ffffffffc020378e:	4605                	li	a2,1
ffffffffc0203790:	f7bd                	bnez	a5,ffffffffc02036fe <kfree+0x26>
        intr_enable();
ffffffffc0203792:	eb1fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203796:	bfe9                	j	ffffffffc0203770 <kfree+0x98>
ffffffffc0203798:	eabfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020379c:	b741                	j	ffffffffc020371c <kfree+0x44>
ffffffffc020379e:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02037a0:	00004617          	auipc	a2,0x4
ffffffffc02037a4:	81860613          	addi	a2,a2,-2024 # ffffffffc0206fb8 <commands+0x700>
ffffffffc02037a8:	06200593          	li	a1,98
ffffffffc02037ac:	00004517          	auipc	a0,0x4
ffffffffc02037b0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02037b4:	a55fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02037b8:	86a2                	mv	a3,s0
ffffffffc02037ba:	00004617          	auipc	a2,0x4
ffffffffc02037be:	92e60613          	addi	a2,a2,-1746 # ffffffffc02070e8 <commands+0x830>
ffffffffc02037c2:	06e00593          	li	a1,110
ffffffffc02037c6:	00004517          	auipc	a0,0x4
ffffffffc02037ca:	81250513          	addi	a0,a0,-2030 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02037ce:	a3bfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02037d2 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02037d2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02037d4:	00003617          	auipc	a2,0x3
ffffffffc02037d8:	7e460613          	addi	a2,a2,2020 # ffffffffc0206fb8 <commands+0x700>
ffffffffc02037dc:	06200593          	li	a1,98
ffffffffc02037e0:	00003517          	auipc	a0,0x3
ffffffffc02037e4:	7f850513          	addi	a0,a0,2040 # ffffffffc0206fd8 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc02037e8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02037ea:	a1ffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02037ee <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02037ee:	7135                	addi	sp,sp,-160
ffffffffc02037f0:	ed06                	sd	ra,152(sp)
ffffffffc02037f2:	e922                	sd	s0,144(sp)
ffffffffc02037f4:	e526                	sd	s1,136(sp)
ffffffffc02037f6:	e14a                	sd	s2,128(sp)
ffffffffc02037f8:	fcce                	sd	s3,120(sp)
ffffffffc02037fa:	f8d2                	sd	s4,112(sp)
ffffffffc02037fc:	f4d6                	sd	s5,104(sp)
ffffffffc02037fe:	f0da                	sd	s6,96(sp)
ffffffffc0203800:	ecde                	sd	s7,88(sp)
ffffffffc0203802:	e8e2                	sd	s8,80(sp)
ffffffffc0203804:	e4e6                	sd	s9,72(sp)
ffffffffc0203806:	e0ea                	sd	s10,64(sp)
ffffffffc0203808:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020380a:	37e010ef          	jal	ra,ffffffffc0204b88 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020380e:	000af697          	auipc	a3,0xaf
ffffffffc0203812:	fd26b683          	ld	a3,-46(a3) # ffffffffc02b27e0 <max_swap_offset>
ffffffffc0203816:	010007b7          	lui	a5,0x1000
ffffffffc020381a:	ff968713          	addi	a4,a3,-7
ffffffffc020381e:	17e1                	addi	a5,a5,-8
ffffffffc0203820:	42e7e663          	bltu	a5,a4,ffffffffc0203c4c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203824:	000a4797          	auipc	a5,0xa4
ffffffffc0203828:	a3478793          	addi	a5,a5,-1484 # ffffffffc02a7258 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020382c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020382e:	000afb97          	auipc	s7,0xaf
ffffffffc0203832:	fbab8b93          	addi	s7,s7,-70 # ffffffffc02b27e8 <sm>
ffffffffc0203836:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020383a:	9702                	jalr	a4
ffffffffc020383c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020383e:	c10d                	beqz	a0,ffffffffc0203860 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203840:	60ea                	ld	ra,152(sp)
ffffffffc0203842:	644a                	ld	s0,144(sp)
ffffffffc0203844:	64aa                	ld	s1,136(sp)
ffffffffc0203846:	79e6                	ld	s3,120(sp)
ffffffffc0203848:	7a46                	ld	s4,112(sp)
ffffffffc020384a:	7aa6                	ld	s5,104(sp)
ffffffffc020384c:	7b06                	ld	s6,96(sp)
ffffffffc020384e:	6be6                	ld	s7,88(sp)
ffffffffc0203850:	6c46                	ld	s8,80(sp)
ffffffffc0203852:	6ca6                	ld	s9,72(sp)
ffffffffc0203854:	6d06                	ld	s10,64(sp)
ffffffffc0203856:	7de2                	ld	s11,56(sp)
ffffffffc0203858:	854a                	mv	a0,s2
ffffffffc020385a:	690a                	ld	s2,128(sp)
ffffffffc020385c:	610d                	addi	sp,sp,160
ffffffffc020385e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203860:	000bb783          	ld	a5,0(s7)
ffffffffc0203864:	00004517          	auipc	a0,0x4
ffffffffc0203868:	43c50513          	addi	a0,a0,1084 # ffffffffc0207ca0 <commands+0x13e8>
ffffffffc020386c:	000ab417          	auipc	s0,0xab
ffffffffc0203870:	eec40413          	addi	s0,s0,-276 # ffffffffc02ae758 <free_area>
ffffffffc0203874:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203876:	4785                	li	a5,1
ffffffffc0203878:	000af717          	auipc	a4,0xaf
ffffffffc020387c:	f6f72c23          	sw	a5,-136(a4) # ffffffffc02b27f0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203880:	84dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203884:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203886:	4d01                	li	s10,0
ffffffffc0203888:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020388a:	34878163          	beq	a5,s0,ffffffffc0203bcc <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020388e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203892:	8b09                	andi	a4,a4,2
ffffffffc0203894:	32070e63          	beqz	a4,ffffffffc0203bd0 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203898:	ff87a703          	lw	a4,-8(a5)
ffffffffc020389c:	679c                	ld	a5,8(a5)
ffffffffc020389e:	2d85                	addiw	s11,s11,1
ffffffffc02038a0:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038a4:	fe8795e3          	bne	a5,s0,ffffffffc020388e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02038a8:	84ea                	mv	s1,s10
ffffffffc02038aa:	e82fd0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc02038ae:	42951763          	bne	a0,s1,ffffffffc0203cdc <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02038b2:	866a                	mv	a2,s10
ffffffffc02038b4:	85ee                	mv	a1,s11
ffffffffc02038b6:	00004517          	auipc	a0,0x4
ffffffffc02038ba:	43250513          	addi	a0,a0,1074 # ffffffffc0207ce8 <commands+0x1430>
ffffffffc02038be:	80ffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02038c2:	8c4ff0ef          	jal	ra,ffffffffc0202986 <mm_create>
ffffffffc02038c6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02038c8:	46050a63          	beqz	a0,ffffffffc0203d3c <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02038cc:	000af797          	auipc	a5,0xaf
ffffffffc02038d0:	efc78793          	addi	a5,a5,-260 # ffffffffc02b27c8 <check_mm_struct>
ffffffffc02038d4:	6398                	ld	a4,0(a5)
ffffffffc02038d6:	3e071363          	bnez	a4,ffffffffc0203cbc <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038da:	000af717          	auipc	a4,0xaf
ffffffffc02038de:	ec670713          	addi	a4,a4,-314 # ffffffffc02b27a0 <boot_pgdir>
ffffffffc02038e2:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02038e6:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02038e8:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x74ee0>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038ec:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02038f0:	42079663          	bnez	a5,ffffffffc0203d1c <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02038f4:	6599                	lui	a1,0x6
ffffffffc02038f6:	460d                	li	a2,3
ffffffffc02038f8:	6505                	lui	a0,0x1
ffffffffc02038fa:	8d4ff0ef          	jal	ra,ffffffffc02029ce <vma_create>
ffffffffc02038fe:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203900:	52050a63          	beqz	a0,ffffffffc0203e34 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0203904:	8556                	mv	a0,s5
ffffffffc0203906:	936ff0ef          	jal	ra,ffffffffc0202a3c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020390a:	00004517          	auipc	a0,0x4
ffffffffc020390e:	41e50513          	addi	a0,a0,1054 # ffffffffc0207d28 <commands+0x1470>
ffffffffc0203912:	fbafc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203916:	018ab503          	ld	a0,24(s5)
ffffffffc020391a:	4605                	li	a2,1
ffffffffc020391c:	6585                	lui	a1,0x1
ffffffffc020391e:	e48fd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203922:	4c050963          	beqz	a0,ffffffffc0203df4 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203926:	00004517          	auipc	a0,0x4
ffffffffc020392a:	45250513          	addi	a0,a0,1106 # ffffffffc0207d78 <commands+0x14c0>
ffffffffc020392e:	000ab497          	auipc	s1,0xab
ffffffffc0203932:	dba48493          	addi	s1,s1,-582 # ffffffffc02ae6e8 <check_rp>
ffffffffc0203936:	f96fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020393a:	000ab997          	auipc	s3,0xab
ffffffffc020393e:	dce98993          	addi	s3,s3,-562 # ffffffffc02ae708 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203942:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203944:	4505                	li	a0,1
ffffffffc0203946:	d14fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020394a:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
          assert(check_rp[i] != NULL );
ffffffffc020394e:	2c050f63          	beqz	a0,ffffffffc0203c2c <swap_init+0x43e>
ffffffffc0203952:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203954:	8b89                	andi	a5,a5,2
ffffffffc0203956:	34079363          	bnez	a5,ffffffffc0203c9c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020395a:	0a21                	addi	s4,s4,8
ffffffffc020395c:	ff3a14e3          	bne	s4,s3,ffffffffc0203944 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203960:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203962:	000aba17          	auipc	s4,0xab
ffffffffc0203966:	d86a0a13          	addi	s4,s4,-634 # ffffffffc02ae6e8 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020396a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020396c:	ec3e                	sd	a5,24(sp)
ffffffffc020396e:	641c                	ld	a5,8(s0)
ffffffffc0203970:	e400                	sd	s0,8(s0)
ffffffffc0203972:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203974:	481c                	lw	a5,16(s0)
ffffffffc0203976:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203978:	000ab797          	auipc	a5,0xab
ffffffffc020397c:	de07a823          	sw	zero,-528(a5) # ffffffffc02ae768 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203980:	000a3503          	ld	a0,0(s4)
ffffffffc0203984:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203986:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203988:	d64fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020398c:	ff3a1ae3          	bne	s4,s3,ffffffffc0203980 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203990:	01042a03          	lw	s4,16(s0)
ffffffffc0203994:	4791                	li	a5,4
ffffffffc0203996:	42fa1f63          	bne	s4,a5,ffffffffc0203dd4 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020399a:	00004517          	auipc	a0,0x4
ffffffffc020399e:	46650513          	addi	a0,a0,1126 # ffffffffc0207e00 <commands+0x1548>
ffffffffc02039a2:	f2afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02039a6:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02039a8:	000af797          	auipc	a5,0xaf
ffffffffc02039ac:	e207a423          	sw	zero,-472(a5) # ffffffffc02b27d0 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02039b0:	4629                	li	a2,10
ffffffffc02039b2:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc02039b6:	000af697          	auipc	a3,0xaf
ffffffffc02039ba:	e1a6a683          	lw	a3,-486(a3) # ffffffffc02b27d0 <pgfault_num>
ffffffffc02039be:	4585                	li	a1,1
ffffffffc02039c0:	000af797          	auipc	a5,0xaf
ffffffffc02039c4:	e1078793          	addi	a5,a5,-496 # ffffffffc02b27d0 <pgfault_num>
ffffffffc02039c8:	54b69663          	bne	a3,a1,ffffffffc0203f14 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02039cc:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02039d0:	4398                	lw	a4,0(a5)
ffffffffc02039d2:	2701                	sext.w	a4,a4
ffffffffc02039d4:	3ed71063          	bne	a4,a3,ffffffffc0203db4 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02039d8:	6689                	lui	a3,0x2
ffffffffc02039da:	462d                	li	a2,11
ffffffffc02039dc:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc02039e0:	4398                	lw	a4,0(a5)
ffffffffc02039e2:	4589                	li	a1,2
ffffffffc02039e4:	2701                	sext.w	a4,a4
ffffffffc02039e6:	4ab71763          	bne	a4,a1,ffffffffc0203e94 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02039ea:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02039ee:	4394                	lw	a3,0(a5)
ffffffffc02039f0:	2681                	sext.w	a3,a3
ffffffffc02039f2:	4ce69163          	bne	a3,a4,ffffffffc0203eb4 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02039f6:	668d                	lui	a3,0x3
ffffffffc02039f8:	4631                	li	a2,12
ffffffffc02039fa:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc02039fe:	4398                	lw	a4,0(a5)
ffffffffc0203a00:	458d                	li	a1,3
ffffffffc0203a02:	2701                	sext.w	a4,a4
ffffffffc0203a04:	4cb71863          	bne	a4,a1,ffffffffc0203ed4 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203a08:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203a0c:	4394                	lw	a3,0(a5)
ffffffffc0203a0e:	2681                	sext.w	a3,a3
ffffffffc0203a10:	4ee69263          	bne	a3,a4,ffffffffc0203ef4 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203a14:	6691                	lui	a3,0x4
ffffffffc0203a16:	4635                	li	a2,13
ffffffffc0203a18:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc0203a1c:	4398                	lw	a4,0(a5)
ffffffffc0203a1e:	2701                	sext.w	a4,a4
ffffffffc0203a20:	43471a63          	bne	a4,s4,ffffffffc0203e54 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203a24:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203a28:	439c                	lw	a5,0(a5)
ffffffffc0203a2a:	2781                	sext.w	a5,a5
ffffffffc0203a2c:	44e79463          	bne	a5,a4,ffffffffc0203e74 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203a30:	481c                	lw	a5,16(s0)
ffffffffc0203a32:	2c079563          	bnez	a5,ffffffffc0203cfc <swap_init+0x50e>
ffffffffc0203a36:	000ab797          	auipc	a5,0xab
ffffffffc0203a3a:	cd278793          	addi	a5,a5,-814 # ffffffffc02ae708 <swap_in_seq_no>
ffffffffc0203a3e:	000ab717          	auipc	a4,0xab
ffffffffc0203a42:	cf270713          	addi	a4,a4,-782 # ffffffffc02ae730 <swap_out_seq_no>
ffffffffc0203a46:	000ab617          	auipc	a2,0xab
ffffffffc0203a4a:	cea60613          	addi	a2,a2,-790 # ffffffffc02ae730 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203a4e:	56fd                	li	a3,-1
ffffffffc0203a50:	c394                	sw	a3,0(a5)
ffffffffc0203a52:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203a54:	0791                	addi	a5,a5,4
ffffffffc0203a56:	0711                	addi	a4,a4,4
ffffffffc0203a58:	fec79ce3          	bne	a5,a2,ffffffffc0203a50 <swap_init+0x262>
ffffffffc0203a5c:	000ab717          	auipc	a4,0xab
ffffffffc0203a60:	c6c70713          	addi	a4,a4,-916 # ffffffffc02ae6c8 <check_ptep>
ffffffffc0203a64:	000ab697          	auipc	a3,0xab
ffffffffc0203a68:	c8468693          	addi	a3,a3,-892 # ffffffffc02ae6e8 <check_rp>
ffffffffc0203a6c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203a6e:	000afc17          	auipc	s8,0xaf
ffffffffc0203a72:	d3ac0c13          	addi	s8,s8,-710 # ffffffffc02b27a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a76:	000afc97          	auipc	s9,0xaf
ffffffffc0203a7a:	d3ac8c93          	addi	s9,s9,-710 # ffffffffc02b27b0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203a7e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a82:	4601                	li	a2,0
ffffffffc0203a84:	855a                	mv	a0,s6
ffffffffc0203a86:	e836                	sd	a3,16(sp)
ffffffffc0203a88:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203a8a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a8c:	cdafd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0203a90:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203a92:	65a2                	ld	a1,8(sp)
ffffffffc0203a94:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a96:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203a98:	1c050663          	beqz	a0,ffffffffc0203c64 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203a9c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203a9e:	0017f613          	andi	a2,a5,1
ffffffffc0203aa2:	1e060163          	beqz	a2,ffffffffc0203c84 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203aa6:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203aaa:	078a                	slli	a5,a5,0x2
ffffffffc0203aac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203aae:	14c7f363          	bgeu	a5,a2,ffffffffc0203bf4 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ab2:	00005617          	auipc	a2,0x5
ffffffffc0203ab6:	26e60613          	addi	a2,a2,622 # ffffffffc0208d20 <nbase>
ffffffffc0203aba:	00063a03          	ld	s4,0(a2)
ffffffffc0203abe:	000cb603          	ld	a2,0(s9)
ffffffffc0203ac2:	6288                	ld	a0,0(a3)
ffffffffc0203ac4:	414787b3          	sub	a5,a5,s4
ffffffffc0203ac8:	079a                	slli	a5,a5,0x6
ffffffffc0203aca:	97b2                	add	a5,a5,a2
ffffffffc0203acc:	14f51063          	bne	a0,a5,ffffffffc0203c0c <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203ad0:	6785                	lui	a5,0x1
ffffffffc0203ad2:	95be                	add	a1,a1,a5
ffffffffc0203ad4:	6795                	lui	a5,0x5
ffffffffc0203ad6:	0721                	addi	a4,a4,8
ffffffffc0203ad8:	06a1                	addi	a3,a3,8
ffffffffc0203ada:	faf592e3          	bne	a1,a5,ffffffffc0203a7e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203ade:	00004517          	auipc	a0,0x4
ffffffffc0203ae2:	3ca50513          	addi	a0,a0,970 # ffffffffc0207ea8 <commands+0x15f0>
ffffffffc0203ae6:	de6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0203aea:	000bb783          	ld	a5,0(s7)
ffffffffc0203aee:	7f9c                	ld	a5,56(a5)
ffffffffc0203af0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203af2:	32051163          	bnez	a0,ffffffffc0203e14 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203af6:	77a2                	ld	a5,40(sp)
ffffffffc0203af8:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203afa:	67e2                	ld	a5,24(sp)
ffffffffc0203afc:	e01c                	sd	a5,0(s0)
ffffffffc0203afe:	7782                	ld	a5,32(sp)
ffffffffc0203b00:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203b02:	6088                	ld	a0,0(s1)
ffffffffc0203b04:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b06:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203b08:	be4fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b0c:	ff349be3          	bne	s1,s3,ffffffffc0203b02 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203b10:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203b14:	8556                	mv	a0,s5
ffffffffc0203b16:	ff7fe0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203b1a:	000af797          	auipc	a5,0xaf
ffffffffc0203b1e:	c8678793          	addi	a5,a5,-890 # ffffffffc02b27a0 <boot_pgdir>
ffffffffc0203b22:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b24:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203b28:	000af697          	auipc	a3,0xaf
ffffffffc0203b2c:	ca06b023          	sd	zero,-864(a3) # ffffffffc02b27c8 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b30:	639c                	ld	a5,0(a5)
ffffffffc0203b32:	078a                	slli	a5,a5,0x2
ffffffffc0203b34:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b36:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203bf0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b3a:	414786b3          	sub	a3,a5,s4
ffffffffc0203b3e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203b40:	8699                	srai	a3,a3,0x6
ffffffffc0203b42:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203b44:	00c69793          	slli	a5,a3,0xc
ffffffffc0203b48:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203b4a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b4e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b50:	22e7f663          	bgeu	a5,a4,ffffffffc0203d7c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203b54:	000af797          	auipc	a5,0xaf
ffffffffc0203b58:	c6c7b783          	ld	a5,-916(a5) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0203b5c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b5e:	629c                	ld	a5,0(a3)
ffffffffc0203b60:	078a                	slli	a5,a5,0x2
ffffffffc0203b62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b64:	08e7f663          	bgeu	a5,a4,ffffffffc0203bf0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b68:	414787b3          	sub	a5,a5,s4
ffffffffc0203b6c:	079a                	slli	a5,a5,0x6
ffffffffc0203b6e:	953e                	add	a0,a0,a5
ffffffffc0203b70:	4585                	li	a1,1
ffffffffc0203b72:	b7afd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b76:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203b7a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b7e:	078a                	slli	a5,a5,0x2
ffffffffc0203b80:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b82:	06e7f763          	bgeu	a5,a4,ffffffffc0203bf0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b86:	000cb503          	ld	a0,0(s9)
ffffffffc0203b8a:	414787b3          	sub	a5,a5,s4
ffffffffc0203b8e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203b90:	4585                	li	a1,1
ffffffffc0203b92:	953e                	add	a0,a0,a5
ffffffffc0203b94:	b58fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     pgdir[0] = 0;
ffffffffc0203b98:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203b9c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203ba0:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203ba2:	00878a63          	beq	a5,s0,ffffffffc0203bb6 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203ba6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203baa:	679c                	ld	a5,8(a5)
ffffffffc0203bac:	3dfd                	addiw	s11,s11,-1
ffffffffc0203bae:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203bb2:	fe879ae3          	bne	a5,s0,ffffffffc0203ba6 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203bb6:	1c0d9f63          	bnez	s11,ffffffffc0203d94 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203bba:	1a0d1163          	bnez	s10,ffffffffc0203d5c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203bbe:	00004517          	auipc	a0,0x4
ffffffffc0203bc2:	33a50513          	addi	a0,a0,826 # ffffffffc0207ef8 <commands+0x1640>
ffffffffc0203bc6:	d06fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203bca:	b99d                	j	ffffffffc0203840 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203bcc:	4481                	li	s1,0
ffffffffc0203bce:	b9f1                	j	ffffffffc02038aa <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203bd0:	00004697          	auipc	a3,0x4
ffffffffc0203bd4:	0e868693          	addi	a3,a3,232 # ffffffffc0207cb8 <commands+0x1400>
ffffffffc0203bd8:	00003617          	auipc	a2,0x3
ffffffffc0203bdc:	0f060613          	addi	a2,a2,240 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203be0:	0bc00593          	li	a1,188
ffffffffc0203be4:	00004517          	auipc	a0,0x4
ffffffffc0203be8:	0ac50513          	addi	a0,a0,172 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203bec:	e1cfc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203bf0:	be3ff0ef          	jal	ra,ffffffffc02037d2 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203bf4:	00003617          	auipc	a2,0x3
ffffffffc0203bf8:	3c460613          	addi	a2,a2,964 # ffffffffc0206fb8 <commands+0x700>
ffffffffc0203bfc:	06200593          	li	a1,98
ffffffffc0203c00:	00003517          	auipc	a0,0x3
ffffffffc0203c04:	3d850513          	addi	a0,a0,984 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0203c08:	e00fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203c0c:	00004697          	auipc	a3,0x4
ffffffffc0203c10:	27468693          	addi	a3,a3,628 # ffffffffc0207e80 <commands+0x15c8>
ffffffffc0203c14:	00003617          	auipc	a2,0x3
ffffffffc0203c18:	0b460613          	addi	a2,a2,180 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203c1c:	0fc00593          	li	a1,252
ffffffffc0203c20:	00004517          	auipc	a0,0x4
ffffffffc0203c24:	07050513          	addi	a0,a0,112 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203c28:	de0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203c2c:	00004697          	auipc	a3,0x4
ffffffffc0203c30:	17468693          	addi	a3,a3,372 # ffffffffc0207da0 <commands+0x14e8>
ffffffffc0203c34:	00003617          	auipc	a2,0x3
ffffffffc0203c38:	09460613          	addi	a2,a2,148 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203c3c:	0dc00593          	li	a1,220
ffffffffc0203c40:	00004517          	auipc	a0,0x4
ffffffffc0203c44:	05050513          	addi	a0,a0,80 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203c48:	dc0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203c4c:	00004617          	auipc	a2,0x4
ffffffffc0203c50:	02460613          	addi	a2,a2,36 # ffffffffc0207c70 <commands+0x13b8>
ffffffffc0203c54:	02800593          	li	a1,40
ffffffffc0203c58:	00004517          	auipc	a0,0x4
ffffffffc0203c5c:	03850513          	addi	a0,a0,56 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203c60:	da8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203c64:	00004697          	auipc	a3,0x4
ffffffffc0203c68:	20468693          	addi	a3,a3,516 # ffffffffc0207e68 <commands+0x15b0>
ffffffffc0203c6c:	00003617          	auipc	a2,0x3
ffffffffc0203c70:	05c60613          	addi	a2,a2,92 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203c74:	0fb00593          	li	a1,251
ffffffffc0203c78:	00004517          	auipc	a0,0x4
ffffffffc0203c7c:	01850513          	addi	a0,a0,24 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203c80:	d88fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203c84:	00003617          	auipc	a2,0x3
ffffffffc0203c88:	36460613          	addi	a2,a2,868 # ffffffffc0206fe8 <commands+0x730>
ffffffffc0203c8c:	07400593          	li	a1,116
ffffffffc0203c90:	00003517          	auipc	a0,0x3
ffffffffc0203c94:	34850513          	addi	a0,a0,840 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0203c98:	d70fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203c9c:	00004697          	auipc	a3,0x4
ffffffffc0203ca0:	11c68693          	addi	a3,a3,284 # ffffffffc0207db8 <commands+0x1500>
ffffffffc0203ca4:	00003617          	auipc	a2,0x3
ffffffffc0203ca8:	02460613          	addi	a2,a2,36 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203cac:	0dd00593          	li	a1,221
ffffffffc0203cb0:	00004517          	auipc	a0,0x4
ffffffffc0203cb4:	fe050513          	addi	a0,a0,-32 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203cb8:	d50fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203cbc:	00004697          	auipc	a3,0x4
ffffffffc0203cc0:	05468693          	addi	a3,a3,84 # ffffffffc0207d10 <commands+0x1458>
ffffffffc0203cc4:	00003617          	auipc	a2,0x3
ffffffffc0203cc8:	00460613          	addi	a2,a2,4 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203ccc:	0c700593          	li	a1,199
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	fc050513          	addi	a0,a0,-64 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203cd8:	d30fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203cdc:	00004697          	auipc	a3,0x4
ffffffffc0203ce0:	fec68693          	addi	a3,a3,-20 # ffffffffc0207cc8 <commands+0x1410>
ffffffffc0203ce4:	00003617          	auipc	a2,0x3
ffffffffc0203ce8:	fe460613          	addi	a2,a2,-28 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203cec:	0bf00593          	li	a1,191
ffffffffc0203cf0:	00004517          	auipc	a0,0x4
ffffffffc0203cf4:	fa050513          	addi	a0,a0,-96 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203cf8:	d10fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0203cfc:	00004697          	auipc	a3,0x4
ffffffffc0203d00:	15c68693          	addi	a3,a3,348 # ffffffffc0207e58 <commands+0x15a0>
ffffffffc0203d04:	00003617          	auipc	a2,0x3
ffffffffc0203d08:	fc460613          	addi	a2,a2,-60 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203d0c:	0f300593          	li	a1,243
ffffffffc0203d10:	00004517          	auipc	a0,0x4
ffffffffc0203d14:	f8050513          	addi	a0,a0,-128 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203d18:	cf0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203d1c:	00004697          	auipc	a3,0x4
ffffffffc0203d20:	d4c68693          	addi	a3,a3,-692 # ffffffffc0207a68 <commands+0x11b0>
ffffffffc0203d24:	00003617          	auipc	a2,0x3
ffffffffc0203d28:	fa460613          	addi	a2,a2,-92 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203d2c:	0cc00593          	li	a1,204
ffffffffc0203d30:	00004517          	auipc	a0,0x4
ffffffffc0203d34:	f6050513          	addi	a0,a0,-160 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203d38:	cd0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0203d3c:	00004697          	auipc	a3,0x4
ffffffffc0203d40:	b6468693          	addi	a3,a3,-1180 # ffffffffc02078a0 <commands+0xfe8>
ffffffffc0203d44:	00003617          	auipc	a2,0x3
ffffffffc0203d48:	f8460613          	addi	a2,a2,-124 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203d4c:	0c400593          	li	a1,196
ffffffffc0203d50:	00004517          	auipc	a0,0x4
ffffffffc0203d54:	f4050513          	addi	a0,a0,-192 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203d58:	cb0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0203d5c:	00004697          	auipc	a3,0x4
ffffffffc0203d60:	18c68693          	addi	a3,a3,396 # ffffffffc0207ee8 <commands+0x1630>
ffffffffc0203d64:	00003617          	auipc	a2,0x3
ffffffffc0203d68:	f6460613          	addi	a2,a2,-156 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203d6c:	11e00593          	li	a1,286
ffffffffc0203d70:	00004517          	auipc	a0,0x4
ffffffffc0203d74:	f2050513          	addi	a0,a0,-224 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203d78:	c90fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d7c:	00003617          	auipc	a2,0x3
ffffffffc0203d80:	29460613          	addi	a2,a2,660 # ffffffffc0207010 <commands+0x758>
ffffffffc0203d84:	06900593          	li	a1,105
ffffffffc0203d88:	00003517          	auipc	a0,0x3
ffffffffc0203d8c:	25050513          	addi	a0,a0,592 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0203d90:	c78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0203d94:	00004697          	auipc	a3,0x4
ffffffffc0203d98:	14468693          	addi	a3,a3,324 # ffffffffc0207ed8 <commands+0x1620>
ffffffffc0203d9c:	00003617          	auipc	a2,0x3
ffffffffc0203da0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203da4:	11d00593          	li	a1,285
ffffffffc0203da8:	00004517          	auipc	a0,0x4
ffffffffc0203dac:	ee850513          	addi	a0,a0,-280 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203db0:	c58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203db4:	00004697          	auipc	a3,0x4
ffffffffc0203db8:	07468693          	addi	a3,a3,116 # ffffffffc0207e28 <commands+0x1570>
ffffffffc0203dbc:	00003617          	auipc	a2,0x3
ffffffffc0203dc0:	f0c60613          	addi	a2,a2,-244 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203dc4:	09500593          	li	a1,149
ffffffffc0203dc8:	00004517          	auipc	a0,0x4
ffffffffc0203dcc:	ec850513          	addi	a0,a0,-312 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203dd0:	c38fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203dd4:	00004697          	auipc	a3,0x4
ffffffffc0203dd8:	00468693          	addi	a3,a3,4 # ffffffffc0207dd8 <commands+0x1520>
ffffffffc0203ddc:	00003617          	auipc	a2,0x3
ffffffffc0203de0:	eec60613          	addi	a2,a2,-276 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203de4:	0ea00593          	li	a1,234
ffffffffc0203de8:	00004517          	auipc	a0,0x4
ffffffffc0203dec:	ea850513          	addi	a0,a0,-344 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203df0:	c18fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203df4:	00004697          	auipc	a3,0x4
ffffffffc0203df8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207d60 <commands+0x14a8>
ffffffffc0203dfc:	00003617          	auipc	a2,0x3
ffffffffc0203e00:	ecc60613          	addi	a2,a2,-308 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203e04:	0d700593          	li	a1,215
ffffffffc0203e08:	00004517          	auipc	a0,0x4
ffffffffc0203e0c:	e8850513          	addi	a0,a0,-376 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203e10:	bf8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0203e14:	00004697          	auipc	a3,0x4
ffffffffc0203e18:	0bc68693          	addi	a3,a3,188 # ffffffffc0207ed0 <commands+0x1618>
ffffffffc0203e1c:	00003617          	auipc	a2,0x3
ffffffffc0203e20:	eac60613          	addi	a2,a2,-340 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203e24:	10200593          	li	a1,258
ffffffffc0203e28:	00004517          	auipc	a0,0x4
ffffffffc0203e2c:	e6850513          	addi	a0,a0,-408 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203e30:	bd8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0203e34:	00004697          	auipc	a3,0x4
ffffffffc0203e38:	cd468693          	addi	a3,a3,-812 # ffffffffc0207b08 <commands+0x1250>
ffffffffc0203e3c:	00003617          	auipc	a2,0x3
ffffffffc0203e40:	e8c60613          	addi	a2,a2,-372 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203e44:	0cf00593          	li	a1,207
ffffffffc0203e48:	00004517          	auipc	a0,0x4
ffffffffc0203e4c:	e4850513          	addi	a0,a0,-440 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203e50:	bb8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e54:	00003697          	auipc	a3,0x3
ffffffffc0203e58:	7ec68693          	addi	a3,a3,2028 # ffffffffc0207640 <commands+0xd88>
ffffffffc0203e5c:	00003617          	auipc	a2,0x3
ffffffffc0203e60:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203e64:	09f00593          	li	a1,159
ffffffffc0203e68:	00004517          	auipc	a0,0x4
ffffffffc0203e6c:	e2850513          	addi	a0,a0,-472 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203e70:	b98fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e74:	00003697          	auipc	a3,0x3
ffffffffc0203e78:	7cc68693          	addi	a3,a3,1996 # ffffffffc0207640 <commands+0xd88>
ffffffffc0203e7c:	00003617          	auipc	a2,0x3
ffffffffc0203e80:	e4c60613          	addi	a2,a2,-436 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203e84:	0a100593          	li	a1,161
ffffffffc0203e88:	00004517          	auipc	a0,0x4
ffffffffc0203e8c:	e0850513          	addi	a0,a0,-504 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203e90:	b78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e94:	00004697          	auipc	a3,0x4
ffffffffc0203e98:	fa468693          	addi	a3,a3,-92 # ffffffffc0207e38 <commands+0x1580>
ffffffffc0203e9c:	00003617          	auipc	a2,0x3
ffffffffc0203ea0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203ea4:	09700593          	li	a1,151
ffffffffc0203ea8:	00004517          	auipc	a0,0x4
ffffffffc0203eac:	de850513          	addi	a0,a0,-536 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203eb0:	b58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203eb4:	00004697          	auipc	a3,0x4
ffffffffc0203eb8:	f8468693          	addi	a3,a3,-124 # ffffffffc0207e38 <commands+0x1580>
ffffffffc0203ebc:	00003617          	auipc	a2,0x3
ffffffffc0203ec0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203ec4:	09900593          	li	a1,153
ffffffffc0203ec8:	00004517          	auipc	a0,0x4
ffffffffc0203ecc:	dc850513          	addi	a0,a0,-568 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203ed0:	b38fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203ed4:	00004697          	auipc	a3,0x4
ffffffffc0203ed8:	f7468693          	addi	a3,a3,-140 # ffffffffc0207e48 <commands+0x1590>
ffffffffc0203edc:	00003617          	auipc	a2,0x3
ffffffffc0203ee0:	dec60613          	addi	a2,a2,-532 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203ee4:	09b00593          	li	a1,155
ffffffffc0203ee8:	00004517          	auipc	a0,0x4
ffffffffc0203eec:	da850513          	addi	a0,a0,-600 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203ef0:	b18fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203ef4:	00004697          	auipc	a3,0x4
ffffffffc0203ef8:	f5468693          	addi	a3,a3,-172 # ffffffffc0207e48 <commands+0x1590>
ffffffffc0203efc:	00003617          	auipc	a2,0x3
ffffffffc0203f00:	dcc60613          	addi	a2,a2,-564 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203f04:	09d00593          	li	a1,157
ffffffffc0203f08:	00004517          	auipc	a0,0x4
ffffffffc0203f0c:	d8850513          	addi	a0,a0,-632 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203f10:	af8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203f14:	00004697          	auipc	a3,0x4
ffffffffc0203f18:	f1468693          	addi	a3,a3,-236 # ffffffffc0207e28 <commands+0x1570>
ffffffffc0203f1c:	00003617          	auipc	a2,0x3
ffffffffc0203f20:	dac60613          	addi	a2,a2,-596 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0203f24:	09300593          	li	a1,147
ffffffffc0203f28:	00004517          	auipc	a0,0x4
ffffffffc0203f2c:	d6850513          	addi	a0,a0,-664 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc0203f30:	ad8fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203f34 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203f34:	000af797          	auipc	a5,0xaf
ffffffffc0203f38:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02b27e8 <sm>
ffffffffc0203f3c:	6b9c                	ld	a5,16(a5)
ffffffffc0203f3e:	8782                	jr	a5

ffffffffc0203f40 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203f40:	000af797          	auipc	a5,0xaf
ffffffffc0203f44:	8a87b783          	ld	a5,-1880(a5) # ffffffffc02b27e8 <sm>
ffffffffc0203f48:	739c                	ld	a5,32(a5)
ffffffffc0203f4a:	8782                	jr	a5

ffffffffc0203f4c <swap_out>:
{
ffffffffc0203f4c:	711d                	addi	sp,sp,-96
ffffffffc0203f4e:	ec86                	sd	ra,88(sp)
ffffffffc0203f50:	e8a2                	sd	s0,80(sp)
ffffffffc0203f52:	e4a6                	sd	s1,72(sp)
ffffffffc0203f54:	e0ca                	sd	s2,64(sp)
ffffffffc0203f56:	fc4e                	sd	s3,56(sp)
ffffffffc0203f58:	f852                	sd	s4,48(sp)
ffffffffc0203f5a:	f456                	sd	s5,40(sp)
ffffffffc0203f5c:	f05a                	sd	s6,32(sp)
ffffffffc0203f5e:	ec5e                	sd	s7,24(sp)
ffffffffc0203f60:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203f62:	cde9                	beqz	a1,ffffffffc020403c <swap_out+0xf0>
ffffffffc0203f64:	8a2e                	mv	s4,a1
ffffffffc0203f66:	892a                	mv	s2,a0
ffffffffc0203f68:	8ab2                	mv	s5,a2
ffffffffc0203f6a:	4401                	li	s0,0
ffffffffc0203f6c:	000af997          	auipc	s3,0xaf
ffffffffc0203f70:	87c98993          	addi	s3,s3,-1924 # ffffffffc02b27e8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f74:	00004b17          	auipc	s6,0x4
ffffffffc0203f78:	004b0b13          	addi	s6,s6,4 # ffffffffc0207f78 <commands+0x16c0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203f7c:	00004b97          	auipc	s7,0x4
ffffffffc0203f80:	fe4b8b93          	addi	s7,s7,-28 # ffffffffc0207f60 <commands+0x16a8>
ffffffffc0203f84:	a825                	j	ffffffffc0203fbc <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f86:	67a2                	ld	a5,8(sp)
ffffffffc0203f88:	8626                	mv	a2,s1
ffffffffc0203f8a:	85a2                	mv	a1,s0
ffffffffc0203f8c:	7f94                	ld	a3,56(a5)
ffffffffc0203f8e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203f90:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f92:	82b1                	srli	a3,a3,0xc
ffffffffc0203f94:	0685                	addi	a3,a3,1
ffffffffc0203f96:	936fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f9a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203f9c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f9e:	7d1c                	ld	a5,56(a0)
ffffffffc0203fa0:	83b1                	srli	a5,a5,0xc
ffffffffc0203fa2:	0785                	addi	a5,a5,1
ffffffffc0203fa4:	07a2                	slli	a5,a5,0x8
ffffffffc0203fa6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203faa:	f43fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203fae:	01893503          	ld	a0,24(s2)
ffffffffc0203fb2:	85a6                	mv	a1,s1
ffffffffc0203fb4:	cf0fe0ef          	jal	ra,ffffffffc02024a4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203fb8:	048a0d63          	beq	s4,s0,ffffffffc0204012 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203fbc:	0009b783          	ld	a5,0(s3)
ffffffffc0203fc0:	8656                	mv	a2,s5
ffffffffc0203fc2:	002c                	addi	a1,sp,8
ffffffffc0203fc4:	7b9c                	ld	a5,48(a5)
ffffffffc0203fc6:	854a                	mv	a0,s2
ffffffffc0203fc8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203fca:	e12d                	bnez	a0,ffffffffc020402c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203fcc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fce:	01893503          	ld	a0,24(s2)
ffffffffc0203fd2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203fd4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fd6:	85a6                	mv	a1,s1
ffffffffc0203fd8:	f8ffc0ef          	jal	ra,ffffffffc0200f66 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fdc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fde:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fe0:	8b85                	andi	a5,a5,1
ffffffffc0203fe2:	cfb9                	beqz	a5,ffffffffc0204040 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203fe4:	65a2                	ld	a1,8(sp)
ffffffffc0203fe6:	7d9c                	ld	a5,56(a1)
ffffffffc0203fe8:	83b1                	srli	a5,a5,0xc
ffffffffc0203fea:	0785                	addi	a5,a5,1
ffffffffc0203fec:	00879513          	slli	a0,a5,0x8
ffffffffc0203ff0:	45f000ef          	jal	ra,ffffffffc0204c4e <swapfs_write>
ffffffffc0203ff4:	d949                	beqz	a0,ffffffffc0203f86 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ff6:	855e                	mv	a0,s7
ffffffffc0203ff8:	8d4fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ffc:	0009b783          	ld	a5,0(s3)
ffffffffc0204000:	6622                	ld	a2,8(sp)
ffffffffc0204002:	4681                	li	a3,0
ffffffffc0204004:	739c                	ld	a5,32(a5)
ffffffffc0204006:	85a6                	mv	a1,s1
ffffffffc0204008:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020400a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020400c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020400e:	fa8a17e3          	bne	s4,s0,ffffffffc0203fbc <swap_out+0x70>
}
ffffffffc0204012:	60e6                	ld	ra,88(sp)
ffffffffc0204014:	8522                	mv	a0,s0
ffffffffc0204016:	6446                	ld	s0,80(sp)
ffffffffc0204018:	64a6                	ld	s1,72(sp)
ffffffffc020401a:	6906                	ld	s2,64(sp)
ffffffffc020401c:	79e2                	ld	s3,56(sp)
ffffffffc020401e:	7a42                	ld	s4,48(sp)
ffffffffc0204020:	7aa2                	ld	s5,40(sp)
ffffffffc0204022:	7b02                	ld	s6,32(sp)
ffffffffc0204024:	6be2                	ld	s7,24(sp)
ffffffffc0204026:	6c42                	ld	s8,16(sp)
ffffffffc0204028:	6125                	addi	sp,sp,96
ffffffffc020402a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020402c:	85a2                	mv	a1,s0
ffffffffc020402e:	00004517          	auipc	a0,0x4
ffffffffc0204032:	eea50513          	addi	a0,a0,-278 # ffffffffc0207f18 <commands+0x1660>
ffffffffc0204036:	896fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc020403a:	bfe1                	j	ffffffffc0204012 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020403c:	4401                	li	s0,0
ffffffffc020403e:	bfd1                	j	ffffffffc0204012 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0204040:	00004697          	auipc	a3,0x4
ffffffffc0204044:	f0868693          	addi	a3,a3,-248 # ffffffffc0207f48 <commands+0x1690>
ffffffffc0204048:	00003617          	auipc	a2,0x3
ffffffffc020404c:	c8060613          	addi	a2,a2,-896 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204050:	06800593          	li	a1,104
ffffffffc0204054:	00004517          	auipc	a0,0x4
ffffffffc0204058:	c3c50513          	addi	a0,a0,-964 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc020405c:	9acfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204060 <swap_in>:
{
ffffffffc0204060:	7179                	addi	sp,sp,-48
ffffffffc0204062:	e84a                	sd	s2,16(sp)
ffffffffc0204064:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0204066:	4505                	li	a0,1
{
ffffffffc0204068:	ec26                	sd	s1,24(sp)
ffffffffc020406a:	e44e                	sd	s3,8(sp)
ffffffffc020406c:	f406                	sd	ra,40(sp)
ffffffffc020406e:	f022                	sd	s0,32(sp)
ffffffffc0204070:	84ae                	mv	s1,a1
ffffffffc0204072:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0204074:	de7fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
     assert(result!=NULL);
ffffffffc0204078:	c129                	beqz	a0,ffffffffc02040ba <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020407a:	842a                	mv	s0,a0
ffffffffc020407c:	01893503          	ld	a0,24(s2)
ffffffffc0204080:	4601                	li	a2,0
ffffffffc0204082:	85a6                	mv	a1,s1
ffffffffc0204084:	ee3fc0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0204088:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020408a:	6108                	ld	a0,0(a0)
ffffffffc020408c:	85a2                	mv	a1,s0
ffffffffc020408e:	333000ef          	jal	ra,ffffffffc0204bc0 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0204092:	00093583          	ld	a1,0(s2)
ffffffffc0204096:	8626                	mv	a2,s1
ffffffffc0204098:	00004517          	auipc	a0,0x4
ffffffffc020409c:	f3050513          	addi	a0,a0,-208 # ffffffffc0207fc8 <commands+0x1710>
ffffffffc02040a0:	81a1                	srli	a1,a1,0x8
ffffffffc02040a2:	82afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02040a6:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02040a8:	0089b023          	sd	s0,0(s3)
}
ffffffffc02040ac:	7402                	ld	s0,32(sp)
ffffffffc02040ae:	64e2                	ld	s1,24(sp)
ffffffffc02040b0:	6942                	ld	s2,16(sp)
ffffffffc02040b2:	69a2                	ld	s3,8(sp)
ffffffffc02040b4:	4501                	li	a0,0
ffffffffc02040b6:	6145                	addi	sp,sp,48
ffffffffc02040b8:	8082                	ret
     assert(result!=NULL);
ffffffffc02040ba:	00004697          	auipc	a3,0x4
ffffffffc02040be:	efe68693          	addi	a3,a3,-258 # ffffffffc0207fb8 <commands+0x1700>
ffffffffc02040c2:	00003617          	auipc	a2,0x3
ffffffffc02040c6:	c0660613          	addi	a2,a2,-1018 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02040ca:	07e00593          	li	a1,126
ffffffffc02040ce:	00004517          	auipc	a0,0x4
ffffffffc02040d2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0207c90 <commands+0x13d8>
ffffffffc02040d6:	932fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02040da <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02040da:	000aa797          	auipc	a5,0xaa
ffffffffc02040de:	67e78793          	addi	a5,a5,1662 # ffffffffc02ae758 <free_area>
ffffffffc02040e2:	e79c                	sd	a5,8(a5)
ffffffffc02040e4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02040e6:	0007a823          	sw	zero,16(a5)
}
ffffffffc02040ea:	8082                	ret

ffffffffc02040ec <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02040ec:	000aa517          	auipc	a0,0xaa
ffffffffc02040f0:	67c56503          	lwu	a0,1660(a0) # ffffffffc02ae768 <free_area+0x10>
ffffffffc02040f4:	8082                	ret

ffffffffc02040f6 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02040f6:	715d                	addi	sp,sp,-80
ffffffffc02040f8:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02040fa:	000aa417          	auipc	s0,0xaa
ffffffffc02040fe:	65e40413          	addi	s0,s0,1630 # ffffffffc02ae758 <free_area>
ffffffffc0204102:	641c                	ld	a5,8(s0)
ffffffffc0204104:	e486                	sd	ra,72(sp)
ffffffffc0204106:	fc26                	sd	s1,56(sp)
ffffffffc0204108:	f84a                	sd	s2,48(sp)
ffffffffc020410a:	f44e                	sd	s3,40(sp)
ffffffffc020410c:	f052                	sd	s4,32(sp)
ffffffffc020410e:	ec56                	sd	s5,24(sp)
ffffffffc0204110:	e85a                	sd	s6,16(sp)
ffffffffc0204112:	e45e                	sd	s7,8(sp)
ffffffffc0204114:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204116:	2a878d63          	beq	a5,s0,ffffffffc02043d0 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020411a:	4481                	li	s1,0
ffffffffc020411c:	4901                	li	s2,0
ffffffffc020411e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204122:	8b09                	andi	a4,a4,2
ffffffffc0204124:	2a070a63          	beqz	a4,ffffffffc02043d8 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0204128:	ff87a703          	lw	a4,-8(a5)
ffffffffc020412c:	679c                	ld	a5,8(a5)
ffffffffc020412e:	2905                	addiw	s2,s2,1
ffffffffc0204130:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204132:	fe8796e3          	bne	a5,s0,ffffffffc020411e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0204136:	89a6                	mv	s3,s1
ffffffffc0204138:	df5fc0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc020413c:	6f351e63          	bne	a0,s3,ffffffffc0204838 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204140:	4505                	li	a0,1
ffffffffc0204142:	d19fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204146:	8aaa                	mv	s5,a0
ffffffffc0204148:	42050863          	beqz	a0,ffffffffc0204578 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020414c:	4505                	li	a0,1
ffffffffc020414e:	d0dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204152:	89aa                	mv	s3,a0
ffffffffc0204154:	70050263          	beqz	a0,ffffffffc0204858 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204158:	4505                	li	a0,1
ffffffffc020415a:	d01fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020415e:	8a2a                	mv	s4,a0
ffffffffc0204160:	48050c63          	beqz	a0,ffffffffc02045f8 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204164:	293a8a63          	beq	s5,s3,ffffffffc02043f8 <default_check+0x302>
ffffffffc0204168:	28aa8863          	beq	s5,a0,ffffffffc02043f8 <default_check+0x302>
ffffffffc020416c:	28a98663          	beq	s3,a0,ffffffffc02043f8 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204170:	000aa783          	lw	a5,0(s5)
ffffffffc0204174:	2a079263          	bnez	a5,ffffffffc0204418 <default_check+0x322>
ffffffffc0204178:	0009a783          	lw	a5,0(s3)
ffffffffc020417c:	28079e63          	bnez	a5,ffffffffc0204418 <default_check+0x322>
ffffffffc0204180:	411c                	lw	a5,0(a0)
ffffffffc0204182:	28079b63          	bnez	a5,ffffffffc0204418 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0204186:	000ae797          	auipc	a5,0xae
ffffffffc020418a:	62a7b783          	ld	a5,1578(a5) # ffffffffc02b27b0 <pages>
ffffffffc020418e:	40fa8733          	sub	a4,s5,a5
ffffffffc0204192:	00005617          	auipc	a2,0x5
ffffffffc0204196:	b8e63603          	ld	a2,-1138(a2) # ffffffffc0208d20 <nbase>
ffffffffc020419a:	8719                	srai	a4,a4,0x6
ffffffffc020419c:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020419e:	000ae697          	auipc	a3,0xae
ffffffffc02041a2:	60a6b683          	ld	a3,1546(a3) # ffffffffc02b27a8 <npage>
ffffffffc02041a6:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02041a8:	0732                	slli	a4,a4,0xc
ffffffffc02041aa:	28d77763          	bgeu	a4,a3,ffffffffc0204438 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02041ae:	40f98733          	sub	a4,s3,a5
ffffffffc02041b2:	8719                	srai	a4,a4,0x6
ffffffffc02041b4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041b6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02041b8:	4cd77063          	bgeu	a4,a3,ffffffffc0204678 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02041bc:	40f507b3          	sub	a5,a0,a5
ffffffffc02041c0:	8799                	srai	a5,a5,0x6
ffffffffc02041c2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041c4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02041c6:	30d7f963          	bgeu	a5,a3,ffffffffc02044d8 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02041ca:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041cc:	00043c03          	ld	s8,0(s0)
ffffffffc02041d0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02041d4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02041d8:	e400                	sd	s0,8(s0)
ffffffffc02041da:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02041dc:	000aa797          	auipc	a5,0xaa
ffffffffc02041e0:	5807a623          	sw	zero,1420(a5) # ffffffffc02ae768 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02041e4:	c77fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02041e8:	2c051863          	bnez	a0,ffffffffc02044b8 <default_check+0x3c2>
    free_page(p0);
ffffffffc02041ec:	4585                	li	a1,1
ffffffffc02041ee:	8556                	mv	a0,s5
ffffffffc02041f0:	cfdfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p1);
ffffffffc02041f4:	4585                	li	a1,1
ffffffffc02041f6:	854e                	mv	a0,s3
ffffffffc02041f8:	cf5fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc02041fc:	4585                	li	a1,1
ffffffffc02041fe:	8552                	mv	a0,s4
ffffffffc0204200:	cedfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(nr_free == 3);
ffffffffc0204204:	4818                	lw	a4,16(s0)
ffffffffc0204206:	478d                	li	a5,3
ffffffffc0204208:	28f71863          	bne	a4,a5,ffffffffc0204498 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020420c:	4505                	li	a0,1
ffffffffc020420e:	c4dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204212:	89aa                	mv	s3,a0
ffffffffc0204214:	26050263          	beqz	a0,ffffffffc0204478 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204218:	4505                	li	a0,1
ffffffffc020421a:	c41fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020421e:	8aaa                	mv	s5,a0
ffffffffc0204220:	3a050c63          	beqz	a0,ffffffffc02045d8 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204224:	4505                	li	a0,1
ffffffffc0204226:	c35fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020422a:	8a2a                	mv	s4,a0
ffffffffc020422c:	38050663          	beqz	a0,ffffffffc02045b8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0204230:	4505                	li	a0,1
ffffffffc0204232:	c29fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204236:	36051163          	bnez	a0,ffffffffc0204598 <default_check+0x4a2>
    free_page(p0);
ffffffffc020423a:	4585                	li	a1,1
ffffffffc020423c:	854e                	mv	a0,s3
ffffffffc020423e:	caffc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204242:	641c                	ld	a5,8(s0)
ffffffffc0204244:	20878a63          	beq	a5,s0,ffffffffc0204458 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0204248:	4505                	li	a0,1
ffffffffc020424a:	c11fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020424e:	30a99563          	bne	s3,a0,ffffffffc0204558 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0204252:	4505                	li	a0,1
ffffffffc0204254:	c07fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204258:	2e051063          	bnez	a0,ffffffffc0204538 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020425c:	481c                	lw	a5,16(s0)
ffffffffc020425e:	2a079d63          	bnez	a5,ffffffffc0204518 <default_check+0x422>
    free_page(p);
ffffffffc0204262:	854e                	mv	a0,s3
ffffffffc0204264:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0204266:	01843023          	sd	s8,0(s0)
ffffffffc020426a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020426e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0204272:	c7bfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p1);
ffffffffc0204276:	4585                	li	a1,1
ffffffffc0204278:	8556                	mv	a0,s5
ffffffffc020427a:	c73fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc020427e:	4585                	li	a1,1
ffffffffc0204280:	8552                	mv	a0,s4
ffffffffc0204282:	c6bfc0ef          	jal	ra,ffffffffc0200eec <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0204286:	4515                	li	a0,5
ffffffffc0204288:	bd3fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020428c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020428e:	26050563          	beqz	a0,ffffffffc02044f8 <default_check+0x402>
ffffffffc0204292:	651c                	ld	a5,8(a0)
ffffffffc0204294:	8385                	srli	a5,a5,0x1
ffffffffc0204296:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0204298:	54079063          	bnez	a5,ffffffffc02047d8 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020429c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020429e:	00043b03          	ld	s6,0(s0)
ffffffffc02042a2:	00843a83          	ld	s5,8(s0)
ffffffffc02042a6:	e000                	sd	s0,0(s0)
ffffffffc02042a8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02042aa:	bb1fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042ae:	50051563          	bnez	a0,ffffffffc02047b8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02042b2:	08098a13          	addi	s4,s3,128
ffffffffc02042b6:	8552                	mv	a0,s4
ffffffffc02042b8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02042ba:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02042be:	000aa797          	auipc	a5,0xaa
ffffffffc02042c2:	4a07a523          	sw	zero,1194(a5) # ffffffffc02ae768 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02042c6:	c27fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02042ca:	4511                	li	a0,4
ffffffffc02042cc:	b8ffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042d0:	4c051463          	bnez	a0,ffffffffc0204798 <default_check+0x6a2>
ffffffffc02042d4:	0889b783          	ld	a5,136(s3)
ffffffffc02042d8:	8385                	srli	a5,a5,0x1
ffffffffc02042da:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02042dc:	48078e63          	beqz	a5,ffffffffc0204778 <default_check+0x682>
ffffffffc02042e0:	0909a703          	lw	a4,144(s3)
ffffffffc02042e4:	478d                	li	a5,3
ffffffffc02042e6:	48f71963          	bne	a4,a5,ffffffffc0204778 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02042ea:	450d                	li	a0,3
ffffffffc02042ec:	b6ffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042f0:	8c2a                	mv	s8,a0
ffffffffc02042f2:	46050363          	beqz	a0,ffffffffc0204758 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02042f6:	4505                	li	a0,1
ffffffffc02042f8:	b63fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042fc:	42051e63          	bnez	a0,ffffffffc0204738 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0204300:	418a1c63          	bne	s4,s8,ffffffffc0204718 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204304:	4585                	li	a1,1
ffffffffc0204306:	854e                	mv	a0,s3
ffffffffc0204308:	be5fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_pages(p1, 3);
ffffffffc020430c:	458d                	li	a1,3
ffffffffc020430e:	8552                	mv	a0,s4
ffffffffc0204310:	bddfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
ffffffffc0204314:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204318:	04098c13          	addi	s8,s3,64
ffffffffc020431c:	8385                	srli	a5,a5,0x1
ffffffffc020431e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204320:	3c078c63          	beqz	a5,ffffffffc02046f8 <default_check+0x602>
ffffffffc0204324:	0109a703          	lw	a4,16(s3)
ffffffffc0204328:	4785                	li	a5,1
ffffffffc020432a:	3cf71763          	bne	a4,a5,ffffffffc02046f8 <default_check+0x602>
ffffffffc020432e:	008a3783          	ld	a5,8(s4)
ffffffffc0204332:	8385                	srli	a5,a5,0x1
ffffffffc0204334:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204336:	3a078163          	beqz	a5,ffffffffc02046d8 <default_check+0x5e2>
ffffffffc020433a:	010a2703          	lw	a4,16(s4)
ffffffffc020433e:	478d                	li	a5,3
ffffffffc0204340:	38f71c63          	bne	a4,a5,ffffffffc02046d8 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204344:	4505                	li	a0,1
ffffffffc0204346:	b15fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020434a:	36a99763          	bne	s3,a0,ffffffffc02046b8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020434e:	4585                	li	a1,1
ffffffffc0204350:	b9dfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204354:	4509                	li	a0,2
ffffffffc0204356:	b05fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020435a:	32aa1f63          	bne	s4,a0,ffffffffc0204698 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020435e:	4589                	li	a1,2
ffffffffc0204360:	b8dfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc0204364:	4585                	li	a1,1
ffffffffc0204366:	8562                	mv	a0,s8
ffffffffc0204368:	b85fc0ef          	jal	ra,ffffffffc0200eec <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020436c:	4515                	li	a0,5
ffffffffc020436e:	aedfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204372:	89aa                	mv	s3,a0
ffffffffc0204374:	48050263          	beqz	a0,ffffffffc02047f8 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0204378:	4505                	li	a0,1
ffffffffc020437a:	ae1fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020437e:	2c051d63          	bnez	a0,ffffffffc0204658 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0204382:	481c                	lw	a5,16(s0)
ffffffffc0204384:	2a079a63          	bnez	a5,ffffffffc0204638 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0204388:	4595                	li	a1,5
ffffffffc020438a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020438c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0204390:	01643023          	sd	s6,0(s0)
ffffffffc0204394:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0204398:	b55fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return listelm->next;
ffffffffc020439c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020439e:	00878963          	beq	a5,s0,ffffffffc02043b0 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02043a2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02043a6:	679c                	ld	a5,8(a5)
ffffffffc02043a8:	397d                	addiw	s2,s2,-1
ffffffffc02043aa:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043ac:	fe879be3          	bne	a5,s0,ffffffffc02043a2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02043b0:	26091463          	bnez	s2,ffffffffc0204618 <default_check+0x522>
    assert(total == 0);
ffffffffc02043b4:	46049263          	bnez	s1,ffffffffc0204818 <default_check+0x722>
}
ffffffffc02043b8:	60a6                	ld	ra,72(sp)
ffffffffc02043ba:	6406                	ld	s0,64(sp)
ffffffffc02043bc:	74e2                	ld	s1,56(sp)
ffffffffc02043be:	7942                	ld	s2,48(sp)
ffffffffc02043c0:	79a2                	ld	s3,40(sp)
ffffffffc02043c2:	7a02                	ld	s4,32(sp)
ffffffffc02043c4:	6ae2                	ld	s5,24(sp)
ffffffffc02043c6:	6b42                	ld	s6,16(sp)
ffffffffc02043c8:	6ba2                	ld	s7,8(sp)
ffffffffc02043ca:	6c02                	ld	s8,0(sp)
ffffffffc02043cc:	6161                	addi	sp,sp,80
ffffffffc02043ce:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043d0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02043d2:	4481                	li	s1,0
ffffffffc02043d4:	4901                	li	s2,0
ffffffffc02043d6:	b38d                	j	ffffffffc0204138 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02043d8:	00004697          	auipc	a3,0x4
ffffffffc02043dc:	8e068693          	addi	a3,a3,-1824 # ffffffffc0207cb8 <commands+0x1400>
ffffffffc02043e0:	00003617          	auipc	a2,0x3
ffffffffc02043e4:	8e860613          	addi	a2,a2,-1816 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02043e8:	0f000593          	li	a1,240
ffffffffc02043ec:	00004517          	auipc	a0,0x4
ffffffffc02043f0:	c1c50513          	addi	a0,a0,-996 # ffffffffc0208008 <commands+0x1750>
ffffffffc02043f4:	e15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02043f8:	00004697          	auipc	a3,0x4
ffffffffc02043fc:	c8868693          	addi	a3,a3,-888 # ffffffffc0208080 <commands+0x17c8>
ffffffffc0204400:	00003617          	auipc	a2,0x3
ffffffffc0204404:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204408:	0bd00593          	li	a1,189
ffffffffc020440c:	00004517          	auipc	a0,0x4
ffffffffc0204410:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204414:	df5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204418:	00004697          	auipc	a3,0x4
ffffffffc020441c:	c9068693          	addi	a3,a3,-880 # ffffffffc02080a8 <commands+0x17f0>
ffffffffc0204420:	00003617          	auipc	a2,0x3
ffffffffc0204424:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204428:	0be00593          	li	a1,190
ffffffffc020442c:	00004517          	auipc	a0,0x4
ffffffffc0204430:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204434:	dd5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204438:	00004697          	auipc	a3,0x4
ffffffffc020443c:	cb068693          	addi	a3,a3,-848 # ffffffffc02080e8 <commands+0x1830>
ffffffffc0204440:	00003617          	auipc	a2,0x3
ffffffffc0204444:	88860613          	addi	a2,a2,-1912 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204448:	0c000593          	li	a1,192
ffffffffc020444c:	00004517          	auipc	a0,0x4
ffffffffc0204450:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204454:	db5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0204458:	00004697          	auipc	a3,0x4
ffffffffc020445c:	d1868693          	addi	a3,a3,-744 # ffffffffc0208170 <commands+0x18b8>
ffffffffc0204460:	00003617          	auipc	a2,0x3
ffffffffc0204464:	86860613          	addi	a2,a2,-1944 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204468:	0d900593          	li	a1,217
ffffffffc020446c:	00004517          	auipc	a0,0x4
ffffffffc0204470:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204474:	d95fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204478:	00004697          	auipc	a3,0x4
ffffffffc020447c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0208020 <commands+0x1768>
ffffffffc0204480:	00003617          	auipc	a2,0x3
ffffffffc0204484:	84860613          	addi	a2,a2,-1976 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204488:	0d200593          	li	a1,210
ffffffffc020448c:	00004517          	auipc	a0,0x4
ffffffffc0204490:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204494:	d75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0204498:	00004697          	auipc	a3,0x4
ffffffffc020449c:	cc868693          	addi	a3,a3,-824 # ffffffffc0208160 <commands+0x18a8>
ffffffffc02044a0:	00003617          	auipc	a2,0x3
ffffffffc02044a4:	82860613          	addi	a2,a2,-2008 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02044a8:	0d000593          	li	a1,208
ffffffffc02044ac:	00004517          	auipc	a0,0x4
ffffffffc02044b0:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0208008 <commands+0x1750>
ffffffffc02044b4:	d55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044b8:	00004697          	auipc	a3,0x4
ffffffffc02044bc:	c9068693          	addi	a3,a3,-880 # ffffffffc0208148 <commands+0x1890>
ffffffffc02044c0:	00003617          	auipc	a2,0x3
ffffffffc02044c4:	80860613          	addi	a2,a2,-2040 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02044c8:	0cb00593          	li	a1,203
ffffffffc02044cc:	00004517          	auipc	a0,0x4
ffffffffc02044d0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0208008 <commands+0x1750>
ffffffffc02044d4:	d35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02044d8:	00004697          	auipc	a3,0x4
ffffffffc02044dc:	c5068693          	addi	a3,a3,-944 # ffffffffc0208128 <commands+0x1870>
ffffffffc02044e0:	00002617          	auipc	a2,0x2
ffffffffc02044e4:	7e860613          	addi	a2,a2,2024 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02044e8:	0c200593          	li	a1,194
ffffffffc02044ec:	00004517          	auipc	a0,0x4
ffffffffc02044f0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0208008 <commands+0x1750>
ffffffffc02044f4:	d15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc02044f8:	00004697          	auipc	a3,0x4
ffffffffc02044fc:	cb068693          	addi	a3,a3,-848 # ffffffffc02081a8 <commands+0x18f0>
ffffffffc0204500:	00002617          	auipc	a2,0x2
ffffffffc0204504:	7c860613          	addi	a2,a2,1992 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204508:	0f800593          	li	a1,248
ffffffffc020450c:	00004517          	auipc	a0,0x4
ffffffffc0204510:	afc50513          	addi	a0,a0,-1284 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204514:	cf5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204518:	00004697          	auipc	a3,0x4
ffffffffc020451c:	94068693          	addi	a3,a3,-1728 # ffffffffc0207e58 <commands+0x15a0>
ffffffffc0204520:	00002617          	auipc	a2,0x2
ffffffffc0204524:	7a860613          	addi	a2,a2,1960 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204528:	0df00593          	li	a1,223
ffffffffc020452c:	00004517          	auipc	a0,0x4
ffffffffc0204530:	adc50513          	addi	a0,a0,-1316 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204534:	cd5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204538:	00004697          	auipc	a3,0x4
ffffffffc020453c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0208148 <commands+0x1890>
ffffffffc0204540:	00002617          	auipc	a2,0x2
ffffffffc0204544:	78860613          	addi	a2,a2,1928 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204548:	0dd00593          	li	a1,221
ffffffffc020454c:	00004517          	auipc	a0,0x4
ffffffffc0204550:	abc50513          	addi	a0,a0,-1348 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204554:	cb5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0204558:	00004697          	auipc	a3,0x4
ffffffffc020455c:	c3068693          	addi	a3,a3,-976 # ffffffffc0208188 <commands+0x18d0>
ffffffffc0204560:	00002617          	auipc	a2,0x2
ffffffffc0204564:	76860613          	addi	a2,a2,1896 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204568:	0dc00593          	li	a1,220
ffffffffc020456c:	00004517          	auipc	a0,0x4
ffffffffc0204570:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204574:	c95fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204578:	00004697          	auipc	a3,0x4
ffffffffc020457c:	aa868693          	addi	a3,a3,-1368 # ffffffffc0208020 <commands+0x1768>
ffffffffc0204580:	00002617          	auipc	a2,0x2
ffffffffc0204584:	74860613          	addi	a2,a2,1864 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204588:	0b900593          	li	a1,185
ffffffffc020458c:	00004517          	auipc	a0,0x4
ffffffffc0204590:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204594:	c75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204598:	00004697          	auipc	a3,0x4
ffffffffc020459c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0208148 <commands+0x1890>
ffffffffc02045a0:	00002617          	auipc	a2,0x2
ffffffffc02045a4:	72860613          	addi	a2,a2,1832 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02045a8:	0d600593          	li	a1,214
ffffffffc02045ac:	00004517          	auipc	a0,0x4
ffffffffc02045b0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0208008 <commands+0x1750>
ffffffffc02045b4:	c55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02045b8:	00004697          	auipc	a3,0x4
ffffffffc02045bc:	aa868693          	addi	a3,a3,-1368 # ffffffffc0208060 <commands+0x17a8>
ffffffffc02045c0:	00002617          	auipc	a2,0x2
ffffffffc02045c4:	70860613          	addi	a2,a2,1800 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02045c8:	0d400593          	li	a1,212
ffffffffc02045cc:	00004517          	auipc	a0,0x4
ffffffffc02045d0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0208008 <commands+0x1750>
ffffffffc02045d4:	c35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02045d8:	00004697          	auipc	a3,0x4
ffffffffc02045dc:	a6868693          	addi	a3,a3,-1432 # ffffffffc0208040 <commands+0x1788>
ffffffffc02045e0:	00002617          	auipc	a2,0x2
ffffffffc02045e4:	6e860613          	addi	a2,a2,1768 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02045e8:	0d300593          	li	a1,211
ffffffffc02045ec:	00004517          	auipc	a0,0x4
ffffffffc02045f0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0208008 <commands+0x1750>
ffffffffc02045f4:	c15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02045f8:	00004697          	auipc	a3,0x4
ffffffffc02045fc:	a6868693          	addi	a3,a3,-1432 # ffffffffc0208060 <commands+0x17a8>
ffffffffc0204600:	00002617          	auipc	a2,0x2
ffffffffc0204604:	6c860613          	addi	a2,a2,1736 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204608:	0bb00593          	li	a1,187
ffffffffc020460c:	00004517          	auipc	a0,0x4
ffffffffc0204610:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204614:	bf5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0204618:	00004697          	auipc	a3,0x4
ffffffffc020461c:	ce068693          	addi	a3,a3,-800 # ffffffffc02082f8 <commands+0x1a40>
ffffffffc0204620:	00002617          	auipc	a2,0x2
ffffffffc0204624:	6a860613          	addi	a2,a2,1704 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204628:	12500593          	li	a1,293
ffffffffc020462c:	00004517          	auipc	a0,0x4
ffffffffc0204630:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204634:	bd5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204638:	00004697          	auipc	a3,0x4
ffffffffc020463c:	82068693          	addi	a3,a3,-2016 # ffffffffc0207e58 <commands+0x15a0>
ffffffffc0204640:	00002617          	auipc	a2,0x2
ffffffffc0204644:	68860613          	addi	a2,a2,1672 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204648:	11a00593          	li	a1,282
ffffffffc020464c:	00004517          	auipc	a0,0x4
ffffffffc0204650:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204654:	bb5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204658:	00004697          	auipc	a3,0x4
ffffffffc020465c:	af068693          	addi	a3,a3,-1296 # ffffffffc0208148 <commands+0x1890>
ffffffffc0204660:	00002617          	auipc	a2,0x2
ffffffffc0204664:	66860613          	addi	a2,a2,1640 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204668:	11800593          	li	a1,280
ffffffffc020466c:	00004517          	auipc	a0,0x4
ffffffffc0204670:	99c50513          	addi	a0,a0,-1636 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204674:	b95fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0204678:	00004697          	auipc	a3,0x4
ffffffffc020467c:	a9068693          	addi	a3,a3,-1392 # ffffffffc0208108 <commands+0x1850>
ffffffffc0204680:	00002617          	auipc	a2,0x2
ffffffffc0204684:	64860613          	addi	a2,a2,1608 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204688:	0c100593          	li	a1,193
ffffffffc020468c:	00004517          	auipc	a0,0x4
ffffffffc0204690:	97c50513          	addi	a0,a0,-1668 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204694:	b75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204698:	00004697          	auipc	a3,0x4
ffffffffc020469c:	c2068693          	addi	a3,a3,-992 # ffffffffc02082b8 <commands+0x1a00>
ffffffffc02046a0:	00002617          	auipc	a2,0x2
ffffffffc02046a4:	62860613          	addi	a2,a2,1576 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02046a8:	11200593          	li	a1,274
ffffffffc02046ac:	00004517          	auipc	a0,0x4
ffffffffc02046b0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0208008 <commands+0x1750>
ffffffffc02046b4:	b55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02046b8:	00004697          	auipc	a3,0x4
ffffffffc02046bc:	be068693          	addi	a3,a3,-1056 # ffffffffc0208298 <commands+0x19e0>
ffffffffc02046c0:	00002617          	auipc	a2,0x2
ffffffffc02046c4:	60860613          	addi	a2,a2,1544 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02046c8:	11000593          	li	a1,272
ffffffffc02046cc:	00004517          	auipc	a0,0x4
ffffffffc02046d0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0208008 <commands+0x1750>
ffffffffc02046d4:	b35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02046d8:	00004697          	auipc	a3,0x4
ffffffffc02046dc:	b9868693          	addi	a3,a3,-1128 # ffffffffc0208270 <commands+0x19b8>
ffffffffc02046e0:	00002617          	auipc	a2,0x2
ffffffffc02046e4:	5e860613          	addi	a2,a2,1512 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02046e8:	10e00593          	li	a1,270
ffffffffc02046ec:	00004517          	auipc	a0,0x4
ffffffffc02046f0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0208008 <commands+0x1750>
ffffffffc02046f4:	b15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02046f8:	00004697          	auipc	a3,0x4
ffffffffc02046fc:	b5068693          	addi	a3,a3,-1200 # ffffffffc0208248 <commands+0x1990>
ffffffffc0204700:	00002617          	auipc	a2,0x2
ffffffffc0204704:	5c860613          	addi	a2,a2,1480 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204708:	10d00593          	li	a1,269
ffffffffc020470c:	00004517          	auipc	a0,0x4
ffffffffc0204710:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204714:	af5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204718:	00004697          	auipc	a3,0x4
ffffffffc020471c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0208238 <commands+0x1980>
ffffffffc0204720:	00002617          	auipc	a2,0x2
ffffffffc0204724:	5a860613          	addi	a2,a2,1448 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204728:	10800593          	li	a1,264
ffffffffc020472c:	00004517          	auipc	a0,0x4
ffffffffc0204730:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204734:	ad5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204738:	00004697          	auipc	a3,0x4
ffffffffc020473c:	a1068693          	addi	a3,a3,-1520 # ffffffffc0208148 <commands+0x1890>
ffffffffc0204740:	00002617          	auipc	a2,0x2
ffffffffc0204744:	58860613          	addi	a2,a2,1416 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204748:	10700593          	li	a1,263
ffffffffc020474c:	00004517          	auipc	a0,0x4
ffffffffc0204750:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204754:	ab5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204758:	00004697          	auipc	a3,0x4
ffffffffc020475c:	ac068693          	addi	a3,a3,-1344 # ffffffffc0208218 <commands+0x1960>
ffffffffc0204760:	00002617          	auipc	a2,0x2
ffffffffc0204764:	56860613          	addi	a2,a2,1384 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204768:	10600593          	li	a1,262
ffffffffc020476c:	00004517          	auipc	a0,0x4
ffffffffc0204770:	89c50513          	addi	a0,a0,-1892 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204774:	a95fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204778:	00004697          	auipc	a3,0x4
ffffffffc020477c:	a7068693          	addi	a3,a3,-1424 # ffffffffc02081e8 <commands+0x1930>
ffffffffc0204780:	00002617          	auipc	a2,0x2
ffffffffc0204784:	54860613          	addi	a2,a2,1352 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204788:	10500593          	li	a1,261
ffffffffc020478c:	00004517          	auipc	a0,0x4
ffffffffc0204790:	87c50513          	addi	a0,a0,-1924 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204794:	a75fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0204798:	00004697          	auipc	a3,0x4
ffffffffc020479c:	a3868693          	addi	a3,a3,-1480 # ffffffffc02081d0 <commands+0x1918>
ffffffffc02047a0:	00002617          	auipc	a2,0x2
ffffffffc02047a4:	52860613          	addi	a2,a2,1320 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02047a8:	10400593          	li	a1,260
ffffffffc02047ac:	00004517          	auipc	a0,0x4
ffffffffc02047b0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0208008 <commands+0x1750>
ffffffffc02047b4:	a55fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02047b8:	00004697          	auipc	a3,0x4
ffffffffc02047bc:	99068693          	addi	a3,a3,-1648 # ffffffffc0208148 <commands+0x1890>
ffffffffc02047c0:	00002617          	auipc	a2,0x2
ffffffffc02047c4:	50860613          	addi	a2,a2,1288 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02047c8:	0fe00593          	li	a1,254
ffffffffc02047cc:	00004517          	auipc	a0,0x4
ffffffffc02047d0:	83c50513          	addi	a0,a0,-1988 # ffffffffc0208008 <commands+0x1750>
ffffffffc02047d4:	a35fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc02047d8:	00004697          	auipc	a3,0x4
ffffffffc02047dc:	9e068693          	addi	a3,a3,-1568 # ffffffffc02081b8 <commands+0x1900>
ffffffffc02047e0:	00002617          	auipc	a2,0x2
ffffffffc02047e4:	4e860613          	addi	a2,a2,1256 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02047e8:	0f900593          	li	a1,249
ffffffffc02047ec:	00004517          	auipc	a0,0x4
ffffffffc02047f0:	81c50513          	addi	a0,a0,-2020 # ffffffffc0208008 <commands+0x1750>
ffffffffc02047f4:	a15fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02047f8:	00004697          	auipc	a3,0x4
ffffffffc02047fc:	ae068693          	addi	a3,a3,-1312 # ffffffffc02082d8 <commands+0x1a20>
ffffffffc0204800:	00002617          	auipc	a2,0x2
ffffffffc0204804:	4c860613          	addi	a2,a2,1224 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204808:	11700593          	li	a1,279
ffffffffc020480c:	00003517          	auipc	a0,0x3
ffffffffc0204810:	7fc50513          	addi	a0,a0,2044 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204814:	9f5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc0204818:	00004697          	auipc	a3,0x4
ffffffffc020481c:	af068693          	addi	a3,a3,-1296 # ffffffffc0208308 <commands+0x1a50>
ffffffffc0204820:	00002617          	auipc	a2,0x2
ffffffffc0204824:	4a860613          	addi	a2,a2,1192 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204828:	12600593          	li	a1,294
ffffffffc020482c:	00003517          	auipc	a0,0x3
ffffffffc0204830:	7dc50513          	addi	a0,a0,2012 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204834:	9d5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc0204838:	00003697          	auipc	a3,0x3
ffffffffc020483c:	49068693          	addi	a3,a3,1168 # ffffffffc0207cc8 <commands+0x1410>
ffffffffc0204840:	00002617          	auipc	a2,0x2
ffffffffc0204844:	48860613          	addi	a2,a2,1160 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204848:	0f300593          	li	a1,243
ffffffffc020484c:	00003517          	auipc	a0,0x3
ffffffffc0204850:	7bc50513          	addi	a0,a0,1980 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204854:	9b5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204858:	00003697          	auipc	a3,0x3
ffffffffc020485c:	7e868693          	addi	a3,a3,2024 # ffffffffc0208040 <commands+0x1788>
ffffffffc0204860:	00002617          	auipc	a2,0x2
ffffffffc0204864:	46860613          	addi	a2,a2,1128 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204868:	0ba00593          	li	a1,186
ffffffffc020486c:	00003517          	auipc	a0,0x3
ffffffffc0204870:	79c50513          	addi	a0,a0,1948 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204874:	995fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204878 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0204878:	1141                	addi	sp,sp,-16
ffffffffc020487a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020487c:	14058463          	beqz	a1,ffffffffc02049c4 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0204880:	00659693          	slli	a3,a1,0x6
ffffffffc0204884:	96aa                	add	a3,a3,a0
ffffffffc0204886:	87aa                	mv	a5,a0
ffffffffc0204888:	02d50263          	beq	a0,a3,ffffffffc02048ac <default_free_pages+0x34>
ffffffffc020488c:	6798                	ld	a4,8(a5)
ffffffffc020488e:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204890:	10071a63          	bnez	a4,ffffffffc02049a4 <default_free_pages+0x12c>
ffffffffc0204894:	6798                	ld	a4,8(a5)
ffffffffc0204896:	8b09                	andi	a4,a4,2
ffffffffc0204898:	10071663          	bnez	a4,ffffffffc02049a4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc020489c:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02048a0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02048a4:	04078793          	addi	a5,a5,64
ffffffffc02048a8:	fed792e3          	bne	a5,a3,ffffffffc020488c <default_free_pages+0x14>
    base->property = n;
ffffffffc02048ac:	2581                	sext.w	a1,a1
ffffffffc02048ae:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02048b0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02048b4:	4789                	li	a5,2
ffffffffc02048b6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02048ba:	000aa697          	auipc	a3,0xaa
ffffffffc02048be:	e9e68693          	addi	a3,a3,-354 # ffffffffc02ae758 <free_area>
ffffffffc02048c2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02048c4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02048c6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02048ca:	9db9                	addw	a1,a1,a4
ffffffffc02048cc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02048ce:	0ad78463          	beq	a5,a3,ffffffffc0204976 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02048d2:	fe878713          	addi	a4,a5,-24
ffffffffc02048d6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02048da:	4581                	li	a1,0
            if (base < page) {
ffffffffc02048dc:	00e56a63          	bltu	a0,a4,ffffffffc02048f0 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02048e0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02048e2:	04d70c63          	beq	a4,a3,ffffffffc020493a <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02048e6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02048e8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02048ec:	fee57ae3          	bgeu	a0,a4,ffffffffc02048e0 <default_free_pages+0x68>
ffffffffc02048f0:	c199                	beqz	a1,ffffffffc02048f6 <default_free_pages+0x7e>
ffffffffc02048f2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02048f6:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02048f8:	e390                	sd	a2,0(a5)
ffffffffc02048fa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02048fc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048fe:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0204900:	00d70d63          	beq	a4,a3,ffffffffc020491a <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0204904:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0204908:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc020490c:	02059813          	slli	a6,a1,0x20
ffffffffc0204910:	01a85793          	srli	a5,a6,0x1a
ffffffffc0204914:	97b2                	add	a5,a5,a2
ffffffffc0204916:	02f50c63          	beq	a0,a5,ffffffffc020494e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020491a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020491c:	00d78c63          	beq	a5,a3,ffffffffc0204934 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0204920:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0204922:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0204926:	02061593          	slli	a1,a2,0x20
ffffffffc020492a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020492e:	972a                	add	a4,a4,a0
ffffffffc0204930:	04e68a63          	beq	a3,a4,ffffffffc0204984 <default_free_pages+0x10c>
}
ffffffffc0204934:	60a2                	ld	ra,8(sp)
ffffffffc0204936:	0141                	addi	sp,sp,16
ffffffffc0204938:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020493a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020493c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020493e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204940:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204942:	02d70763          	beq	a4,a3,ffffffffc0204970 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0204946:	8832                	mv	a6,a2
ffffffffc0204948:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020494a:	87ba                	mv	a5,a4
ffffffffc020494c:	bf71                	j	ffffffffc02048e8 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020494e:	491c                	lw	a5,16(a0)
ffffffffc0204950:	9dbd                	addw	a1,a1,a5
ffffffffc0204952:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204956:	57f5                	li	a5,-3
ffffffffc0204958:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020495c:	01853803          	ld	a6,24(a0)
ffffffffc0204960:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0204962:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0204964:	00b83423          	sd	a1,8(a6) # fffffffffff80008 <end+0x3fccd7f4>
    return listelm->next;
ffffffffc0204968:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020496a:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc020496e:	b77d                	j	ffffffffc020491c <default_free_pages+0xa4>
ffffffffc0204970:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204972:	873e                	mv	a4,a5
ffffffffc0204974:	bf41                	j	ffffffffc0204904 <default_free_pages+0x8c>
}
ffffffffc0204976:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204978:	e390                	sd	a2,0(a5)
ffffffffc020497a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020497c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020497e:	ed1c                	sd	a5,24(a0)
ffffffffc0204980:	0141                	addi	sp,sp,16
ffffffffc0204982:	8082                	ret
            base->property += p->property;
ffffffffc0204984:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204988:	ff078693          	addi	a3,a5,-16
ffffffffc020498c:	9e39                	addw	a2,a2,a4
ffffffffc020498e:	c910                	sw	a2,16(a0)
ffffffffc0204990:	5775                	li	a4,-3
ffffffffc0204992:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204996:	6398                	ld	a4,0(a5)
ffffffffc0204998:	679c                	ld	a5,8(a5)
}
ffffffffc020499a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020499c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020499e:	e398                	sd	a4,0(a5)
ffffffffc02049a0:	0141                	addi	sp,sp,16
ffffffffc02049a2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02049a4:	00004697          	auipc	a3,0x4
ffffffffc02049a8:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208320 <commands+0x1a68>
ffffffffc02049ac:	00002617          	auipc	a2,0x2
ffffffffc02049b0:	31c60613          	addi	a2,a2,796 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02049b4:	08300593          	li	a1,131
ffffffffc02049b8:	00003517          	auipc	a0,0x3
ffffffffc02049bc:	65050513          	addi	a0,a0,1616 # ffffffffc0208008 <commands+0x1750>
ffffffffc02049c0:	849fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02049c4:	00004697          	auipc	a3,0x4
ffffffffc02049c8:	95468693          	addi	a3,a3,-1708 # ffffffffc0208318 <commands+0x1a60>
ffffffffc02049cc:	00002617          	auipc	a2,0x2
ffffffffc02049d0:	2fc60613          	addi	a2,a2,764 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02049d4:	08000593          	li	a1,128
ffffffffc02049d8:	00003517          	auipc	a0,0x3
ffffffffc02049dc:	63050513          	addi	a0,a0,1584 # ffffffffc0208008 <commands+0x1750>
ffffffffc02049e0:	829fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02049e4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02049e4:	c941                	beqz	a0,ffffffffc0204a74 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02049e6:	000aa597          	auipc	a1,0xaa
ffffffffc02049ea:	d7258593          	addi	a1,a1,-654 # ffffffffc02ae758 <free_area>
ffffffffc02049ee:	0105a803          	lw	a6,16(a1)
ffffffffc02049f2:	872a                	mv	a4,a0
ffffffffc02049f4:	02081793          	slli	a5,a6,0x20
ffffffffc02049f8:	9381                	srli	a5,a5,0x20
ffffffffc02049fa:	00a7ee63          	bltu	a5,a0,ffffffffc0204a16 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02049fe:	87ae                	mv	a5,a1
ffffffffc0204a00:	a801                	j	ffffffffc0204a10 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204a02:	ff87a683          	lw	a3,-8(a5)
ffffffffc0204a06:	02069613          	slli	a2,a3,0x20
ffffffffc0204a0a:	9201                	srli	a2,a2,0x20
ffffffffc0204a0c:	00e67763          	bgeu	a2,a4,ffffffffc0204a1a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204a10:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204a12:	feb798e3          	bne	a5,a1,ffffffffc0204a02 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204a16:	4501                	li	a0,0
}
ffffffffc0204a18:	8082                	ret
    return listelm->prev;
ffffffffc0204a1a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204a1e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0204a22:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0204a26:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0204a2a:	0068b423          	sd	t1,8(a7) # 1008 <_binary_obj___user_faultread_out_size-0x8ba8>
    next->prev = prev;
ffffffffc0204a2e:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ee0>
        if (page->property > n) {
ffffffffc0204a32:	02c77863          	bgeu	a4,a2,ffffffffc0204a62 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0204a36:	071a                	slli	a4,a4,0x6
ffffffffc0204a38:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0204a3a:	41c686bb          	subw	a3,a3,t3
ffffffffc0204a3e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a40:	00870613          	addi	a2,a4,8
ffffffffc0204a44:	4689                	li	a3,2
ffffffffc0204a46:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204a4a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204a4e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0204a52:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0204a56:	e290                	sd	a2,0(a3)
ffffffffc0204a58:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0204a5c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0204a5e:	01173c23          	sd	a7,24(a4)
ffffffffc0204a62:	41c8083b          	subw	a6,a6,t3
ffffffffc0204a66:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204a6a:	5775                	li	a4,-3
ffffffffc0204a6c:	17c1                	addi	a5,a5,-16
ffffffffc0204a6e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0204a72:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204a74:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204a76:	00004697          	auipc	a3,0x4
ffffffffc0204a7a:	8a268693          	addi	a3,a3,-1886 # ffffffffc0208318 <commands+0x1a60>
ffffffffc0204a7e:	00002617          	auipc	a2,0x2
ffffffffc0204a82:	24a60613          	addi	a2,a2,586 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204a86:	06200593          	li	a1,98
ffffffffc0204a8a:	00003517          	auipc	a0,0x3
ffffffffc0204a8e:	57e50513          	addi	a0,a0,1406 # ffffffffc0208008 <commands+0x1750>
default_alloc_pages(size_t n) {
ffffffffc0204a92:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a94:	f74fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204a98 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a98:	1141                	addi	sp,sp,-16
ffffffffc0204a9a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a9c:	c5f1                	beqz	a1,ffffffffc0204b68 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0204a9e:	00659693          	slli	a3,a1,0x6
ffffffffc0204aa2:	96aa                	add	a3,a3,a0
ffffffffc0204aa4:	87aa                	mv	a5,a0
ffffffffc0204aa6:	00d50f63          	beq	a0,a3,ffffffffc0204ac4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204aaa:	6798                	ld	a4,8(a5)
ffffffffc0204aac:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0204aae:	cf49                	beqz	a4,ffffffffc0204b48 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0204ab0:	0007a823          	sw	zero,16(a5)
ffffffffc0204ab4:	0007b423          	sd	zero,8(a5)
ffffffffc0204ab8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204abc:	04078793          	addi	a5,a5,64
ffffffffc0204ac0:	fed795e3          	bne	a5,a3,ffffffffc0204aaa <default_init_memmap+0x12>
    base->property = n;
ffffffffc0204ac4:	2581                	sext.w	a1,a1
ffffffffc0204ac6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204ac8:	4789                	li	a5,2
ffffffffc0204aca:	00850713          	addi	a4,a0,8
ffffffffc0204ace:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204ad2:	000aa697          	auipc	a3,0xaa
ffffffffc0204ad6:	c8668693          	addi	a3,a3,-890 # ffffffffc02ae758 <free_area>
ffffffffc0204ada:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204adc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204ade:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0204ae2:	9db9                	addw	a1,a1,a4
ffffffffc0204ae4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0204ae6:	04d78a63          	beq	a5,a3,ffffffffc0204b3a <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0204aea:	fe878713          	addi	a4,a5,-24
ffffffffc0204aee:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204af2:	4581                	li	a1,0
            if (base < page) {
ffffffffc0204af4:	00e56a63          	bltu	a0,a4,ffffffffc0204b08 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204af8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204afa:	02d70263          	beq	a4,a3,ffffffffc0204b1e <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0204afe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204b00:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204b04:	fee57ae3          	bgeu	a0,a4,ffffffffc0204af8 <default_init_memmap+0x60>
ffffffffc0204b08:	c199                	beqz	a1,ffffffffc0204b0e <default_init_memmap+0x76>
ffffffffc0204b0a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204b0e:	6398                	ld	a4,0(a5)
}
ffffffffc0204b10:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204b12:	e390                	sd	a2,0(a5)
ffffffffc0204b14:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204b16:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b18:	ed18                	sd	a4,24(a0)
ffffffffc0204b1a:	0141                	addi	sp,sp,16
ffffffffc0204b1c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204b1e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b20:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204b22:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204b24:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204b26:	00d70663          	beq	a4,a3,ffffffffc0204b32 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0204b2a:	8832                	mv	a6,a2
ffffffffc0204b2c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204b2e:	87ba                	mv	a5,a4
ffffffffc0204b30:	bfc1                	j	ffffffffc0204b00 <default_init_memmap+0x68>
}
ffffffffc0204b32:	60a2                	ld	ra,8(sp)
ffffffffc0204b34:	e290                	sd	a2,0(a3)
ffffffffc0204b36:	0141                	addi	sp,sp,16
ffffffffc0204b38:	8082                	ret
ffffffffc0204b3a:	60a2                	ld	ra,8(sp)
ffffffffc0204b3c:	e390                	sd	a2,0(a5)
ffffffffc0204b3e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b40:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b42:	ed1c                	sd	a5,24(a0)
ffffffffc0204b44:	0141                	addi	sp,sp,16
ffffffffc0204b46:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204b48:	00004697          	auipc	a3,0x4
ffffffffc0204b4c:	80068693          	addi	a3,a3,-2048 # ffffffffc0208348 <commands+0x1a90>
ffffffffc0204b50:	00002617          	auipc	a2,0x2
ffffffffc0204b54:	17860613          	addi	a2,a2,376 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204b58:	04900593          	li	a1,73
ffffffffc0204b5c:	00003517          	auipc	a0,0x3
ffffffffc0204b60:	4ac50513          	addi	a0,a0,1196 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204b64:	ea4fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0204b68:	00003697          	auipc	a3,0x3
ffffffffc0204b6c:	7b068693          	addi	a3,a3,1968 # ffffffffc0208318 <commands+0x1a60>
ffffffffc0204b70:	00002617          	auipc	a2,0x2
ffffffffc0204b74:	15860613          	addi	a2,a2,344 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0204b78:	04600593          	li	a1,70
ffffffffc0204b7c:	00003517          	auipc	a0,0x3
ffffffffc0204b80:	48c50513          	addi	a0,a0,1164 # ffffffffc0208008 <commands+0x1750>
ffffffffc0204b84:	e84fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b88 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b88:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b8a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b8c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b8e:	99bfb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204b92:	cd01                	beqz	a0,ffffffffc0204baa <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b94:	4505                	li	a0,1
ffffffffc0204b96:	999fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204b9a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b9c:	810d                	srli	a0,a0,0x3
ffffffffc0204b9e:	000ae797          	auipc	a5,0xae
ffffffffc0204ba2:	c4a7b123          	sd	a0,-958(a5) # ffffffffc02b27e0 <max_swap_offset>
}
ffffffffc0204ba6:	0141                	addi	sp,sp,16
ffffffffc0204ba8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204baa:	00003617          	auipc	a2,0x3
ffffffffc0204bae:	7fe60613          	addi	a2,a2,2046 # ffffffffc02083a8 <default_pmm_manager+0x38>
ffffffffc0204bb2:	45b5                	li	a1,13
ffffffffc0204bb4:	00004517          	auipc	a0,0x4
ffffffffc0204bb8:	81450513          	addi	a0,a0,-2028 # ffffffffc02083c8 <default_pmm_manager+0x58>
ffffffffc0204bbc:	e4cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204bc0 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204bc0:	1141                	addi	sp,sp,-16
ffffffffc0204bc2:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bc4:	00855793          	srli	a5,a0,0x8
ffffffffc0204bc8:	cbb1                	beqz	a5,ffffffffc0204c1c <swapfs_read+0x5c>
ffffffffc0204bca:	000ae717          	auipc	a4,0xae
ffffffffc0204bce:	c1673703          	ld	a4,-1002(a4) # ffffffffc02b27e0 <max_swap_offset>
ffffffffc0204bd2:	04e7f563          	bgeu	a5,a4,ffffffffc0204c1c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204bd6:	000ae617          	auipc	a2,0xae
ffffffffc0204bda:	bda63603          	ld	a2,-1062(a2) # ffffffffc02b27b0 <pages>
ffffffffc0204bde:	8d91                	sub	a1,a1,a2
ffffffffc0204be0:	4065d613          	srai	a2,a1,0x6
ffffffffc0204be4:	00004717          	auipc	a4,0x4
ffffffffc0204be8:	13c73703          	ld	a4,316(a4) # ffffffffc0208d20 <nbase>
ffffffffc0204bec:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204bee:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bf2:	8331                	srli	a4,a4,0xc
ffffffffc0204bf4:	000ae697          	auipc	a3,0xae
ffffffffc0204bf8:	bb46b683          	ld	a3,-1100(a3) # ffffffffc02b27a8 <npage>
ffffffffc0204bfc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c00:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c02:	02d77963          	bgeu	a4,a3,ffffffffc0204c34 <swapfs_read+0x74>
}
ffffffffc0204c06:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c08:	000ae797          	auipc	a5,0xae
ffffffffc0204c0c:	bb87b783          	ld	a5,-1096(a5) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0204c10:	46a1                	li	a3,8
ffffffffc0204c12:	963e                	add	a2,a2,a5
ffffffffc0204c14:	4505                	li	a0,1
}
ffffffffc0204c16:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c18:	91dfb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204c1c:	86aa                	mv	a3,a0
ffffffffc0204c1e:	00003617          	auipc	a2,0x3
ffffffffc0204c22:	7c260613          	addi	a2,a2,1986 # ffffffffc02083e0 <default_pmm_manager+0x70>
ffffffffc0204c26:	45d1                	li	a1,20
ffffffffc0204c28:	00003517          	auipc	a0,0x3
ffffffffc0204c2c:	7a050513          	addi	a0,a0,1952 # ffffffffc02083c8 <default_pmm_manager+0x58>
ffffffffc0204c30:	dd8fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c34:	86b2                	mv	a3,a2
ffffffffc0204c36:	06900593          	li	a1,105
ffffffffc0204c3a:	00002617          	auipc	a2,0x2
ffffffffc0204c3e:	3d660613          	addi	a2,a2,982 # ffffffffc0207010 <commands+0x758>
ffffffffc0204c42:	00002517          	auipc	a0,0x2
ffffffffc0204c46:	39650513          	addi	a0,a0,918 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0204c4a:	dbefb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c4e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c4e:	1141                	addi	sp,sp,-16
ffffffffc0204c50:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c52:	00855793          	srli	a5,a0,0x8
ffffffffc0204c56:	cbb1                	beqz	a5,ffffffffc0204caa <swapfs_write+0x5c>
ffffffffc0204c58:	000ae717          	auipc	a4,0xae
ffffffffc0204c5c:	b8873703          	ld	a4,-1144(a4) # ffffffffc02b27e0 <max_swap_offset>
ffffffffc0204c60:	04e7f563          	bgeu	a5,a4,ffffffffc0204caa <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c64:	000ae617          	auipc	a2,0xae
ffffffffc0204c68:	b4c63603          	ld	a2,-1204(a2) # ffffffffc02b27b0 <pages>
ffffffffc0204c6c:	8d91                	sub	a1,a1,a2
ffffffffc0204c6e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c72:	00004717          	auipc	a4,0x4
ffffffffc0204c76:	0ae73703          	ld	a4,174(a4) # ffffffffc0208d20 <nbase>
ffffffffc0204c7a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c7c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c80:	8331                	srli	a4,a4,0xc
ffffffffc0204c82:	000ae697          	auipc	a3,0xae
ffffffffc0204c86:	b266b683          	ld	a3,-1242(a3) # ffffffffc02b27a8 <npage>
ffffffffc0204c8a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c8e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c90:	02d77963          	bgeu	a4,a3,ffffffffc0204cc2 <swapfs_write+0x74>
}
ffffffffc0204c94:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c96:	000ae797          	auipc	a5,0xae
ffffffffc0204c9a:	b2a7b783          	ld	a5,-1238(a5) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0204c9e:	46a1                	li	a3,8
ffffffffc0204ca0:	963e                	add	a2,a2,a5
ffffffffc0204ca2:	4505                	li	a0,1
}
ffffffffc0204ca4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ca6:	8b3fb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204caa:	86aa                	mv	a3,a0
ffffffffc0204cac:	00003617          	auipc	a2,0x3
ffffffffc0204cb0:	73460613          	addi	a2,a2,1844 # ffffffffc02083e0 <default_pmm_manager+0x70>
ffffffffc0204cb4:	45e5                	li	a1,25
ffffffffc0204cb6:	00003517          	auipc	a0,0x3
ffffffffc0204cba:	71250513          	addi	a0,a0,1810 # ffffffffc02083c8 <default_pmm_manager+0x58>
ffffffffc0204cbe:	d4afb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204cc2:	86b2                	mv	a3,a2
ffffffffc0204cc4:	06900593          	li	a1,105
ffffffffc0204cc8:	00002617          	auipc	a2,0x2
ffffffffc0204ccc:	34860613          	addi	a2,a2,840 # ffffffffc0207010 <commands+0x758>
ffffffffc0204cd0:	00002517          	auipc	a0,0x2
ffffffffc0204cd4:	30850513          	addi	a0,a0,776 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0204cd8:	d30fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cdc <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cdc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204ce0:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204ce4:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204ce6:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ce8:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cec:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cf0:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204cf4:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204cf8:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204cfc:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204d00:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204d04:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204d08:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204d0c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204d10:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204d14:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204d18:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204d1a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d1c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d20:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d24:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d28:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d2c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d30:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d34:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d38:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d3c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d40:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d44:	8082                	ret

ffffffffc0204d46 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204d46:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204d48:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d4a:	65e000ef          	jal	ra,ffffffffc02053a8 <do_exit>

ffffffffc0204d4e <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d4e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d50:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d54:	e022                	sd	s0,0(sp)
ffffffffc0204d56:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d58:	8d1fe0ef          	jal	ra,ffffffffc0203628 <kmalloc>
ffffffffc0204d5c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d5e:	cd21                	beqz	a0,ffffffffc0204db6 <alloc_proc+0x68>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204d60:	57fd                	li	a5,-1
ffffffffc0204d62:	1782                	slli	a5,a5,0x20
ffffffffc0204d64:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d66:	07000613          	li	a2,112
ffffffffc0204d6a:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204d6c:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204d70:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204d74:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204d78:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204d7c:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d80:	03050513          	addi	a0,a0,48
ffffffffc0204d84:	458010ef          	jal	ra,ffffffffc02061dc <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204d88:	000ae797          	auipc	a5,0xae
ffffffffc0204d8c:	a107b783          	ld	a5,-1520(a5) # ffffffffc02b2798 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204d90:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204d94:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0204d96:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204d9a:	4641                	li	a2,16
ffffffffc0204d9c:	4581                	li	a1,0
ffffffffc0204d9e:	0b440513          	addi	a0,s0,180
ffffffffc0204da2:	43a010ef          	jal	ra,ffffffffc02061dc <memset>

        proc->wait_state = 0;
ffffffffc0204da6:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204daa:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc0204dae:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc0204db2:	0e043c23          	sd	zero,248(s0)
	}
    return proc;
}
ffffffffc0204db6:	60a2                	ld	ra,8(sp)
ffffffffc0204db8:	8522                	mv	a0,s0
ffffffffc0204dba:	6402                	ld	s0,0(sp)
ffffffffc0204dbc:	0141                	addi	sp,sp,16
ffffffffc0204dbe:	8082                	ret

ffffffffc0204dc0 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204dc0:	000ae797          	auipc	a5,0xae
ffffffffc0204dc4:	a387b783          	ld	a5,-1480(a5) # ffffffffc02b27f8 <current>
ffffffffc0204dc8:	73c8                	ld	a0,160(a5)
ffffffffc0204dca:	fadfb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204dce <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dce:	000ae797          	auipc	a5,0xae
ffffffffc0204dd2:	a2a7b783          	ld	a5,-1494(a5) # ffffffffc02b27f8 <current>
ffffffffc0204dd6:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204dd8:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dda:	00003617          	auipc	a2,0x3
ffffffffc0204dde:	62660613          	addi	a2,a2,1574 # ffffffffc0208400 <default_pmm_manager+0x90>
ffffffffc0204de2:	00003517          	auipc	a0,0x3
ffffffffc0204de6:	62e50513          	addi	a0,a0,1582 # ffffffffc0208410 <default_pmm_manager+0xa0>
user_main(void *arg) {
ffffffffc0204dea:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dec:	ae0fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204df0:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204df4:	b7878793          	addi	a5,a5,-1160 # a968 <_binary_obj___user_forktest_out_size>
ffffffffc0204df8:	e43e                	sd	a5,8(sp)
ffffffffc0204dfa:	00003517          	auipc	a0,0x3
ffffffffc0204dfe:	60650513          	addi	a0,a0,1542 # ffffffffc0208400 <default_pmm_manager+0x90>
ffffffffc0204e02:	00098797          	auipc	a5,0x98
ffffffffc0204e06:	aee78793          	addi	a5,a5,-1298 # ffffffffc029c8f0 <_binary_obj___user_forktest_out_start>
ffffffffc0204e0a:	f03e                	sd	a5,32(sp)
ffffffffc0204e0c:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204e0e:	e802                	sd	zero,16(sp)
ffffffffc0204e10:	350010ef          	jal	ra,ffffffffc0206160 <strlen>
ffffffffc0204e14:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e16:	4511                	li	a0,4
ffffffffc0204e18:	55a2                	lw	a1,40(sp)
ffffffffc0204e1a:	4662                	lw	a2,24(sp)
ffffffffc0204e1c:	5682                	lw	a3,32(sp)
ffffffffc0204e1e:	4722                	lw	a4,8(sp)
ffffffffc0204e20:	48a9                	li	a7,10
ffffffffc0204e22:	9002                	ebreak
ffffffffc0204e24:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e26:	65c2                	ld	a1,16(sp)
ffffffffc0204e28:	00003517          	auipc	a0,0x3
ffffffffc0204e2c:	61050513          	addi	a0,a0,1552 # ffffffffc0208438 <default_pmm_manager+0xc8>
ffffffffc0204e30:	a9cfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e34:	00003617          	auipc	a2,0x3
ffffffffc0204e38:	61460613          	addi	a2,a2,1556 # ffffffffc0208448 <default_pmm_manager+0xd8>
ffffffffc0204e3c:	35400593          	li	a1,852
ffffffffc0204e40:	00003517          	auipc	a0,0x3
ffffffffc0204e44:	62850513          	addi	a0,a0,1576 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0204e48:	bc0fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e4c <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e4c:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e4e:	1141                	addi	sp,sp,-16
ffffffffc0204e50:	e406                	sd	ra,8(sp)
ffffffffc0204e52:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e56:	02f6ee63          	bltu	a3,a5,ffffffffc0204e92 <put_pgdir+0x46>
ffffffffc0204e5a:	000ae517          	auipc	a0,0xae
ffffffffc0204e5e:	96653503          	ld	a0,-1690(a0) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0204e62:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e64:	82b1                	srli	a3,a3,0xc
ffffffffc0204e66:	000ae797          	auipc	a5,0xae
ffffffffc0204e6a:	9427b783          	ld	a5,-1726(a5) # ffffffffc02b27a8 <npage>
ffffffffc0204e6e:	02f6fe63          	bgeu	a3,a5,ffffffffc0204eaa <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e72:	00004517          	auipc	a0,0x4
ffffffffc0204e76:	eae53503          	ld	a0,-338(a0) # ffffffffc0208d20 <nbase>
}
ffffffffc0204e7a:	60a2                	ld	ra,8(sp)
ffffffffc0204e7c:	8e89                	sub	a3,a3,a0
ffffffffc0204e7e:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e80:	000ae517          	auipc	a0,0xae
ffffffffc0204e84:	93053503          	ld	a0,-1744(a0) # ffffffffc02b27b0 <pages>
ffffffffc0204e88:	4585                	li	a1,1
ffffffffc0204e8a:	9536                	add	a0,a0,a3
}
ffffffffc0204e8c:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e8e:	85efc06f          	j	ffffffffc0200eec <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e92:	00002617          	auipc	a2,0x2
ffffffffc0204e96:	25660613          	addi	a2,a2,598 # ffffffffc02070e8 <commands+0x830>
ffffffffc0204e9a:	06e00593          	li	a1,110
ffffffffc0204e9e:	00002517          	auipc	a0,0x2
ffffffffc0204ea2:	13a50513          	addi	a0,a0,314 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0204ea6:	b62fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204eaa:	00002617          	auipc	a2,0x2
ffffffffc0204eae:	10e60613          	addi	a2,a2,270 # ffffffffc0206fb8 <commands+0x700>
ffffffffc0204eb2:	06200593          	li	a1,98
ffffffffc0204eb6:	00002517          	auipc	a0,0x2
ffffffffc0204eba:	12250513          	addi	a0,a0,290 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0204ebe:	b4afb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ec2 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204ec2:	7179                	addi	sp,sp,-48
ffffffffc0204ec4:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204ec6:	000ae917          	auipc	s2,0xae
ffffffffc0204eca:	93290913          	addi	s2,s2,-1742 # ffffffffc02b27f8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204ece:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204ed0:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204ed4:	f406                	sd	ra,40(sp)
ffffffffc0204ed6:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204ed8:	02a48863          	beq	s1,a0,ffffffffc0204f08 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204edc:	100027f3          	csrr	a5,sstatus
ffffffffc0204ee0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ee2:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ee4:	ef9d                	bnez	a5,ffffffffc0204f22 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ee6:	755c                	ld	a5,168(a0)
ffffffffc0204ee8:	577d                	li	a4,-1
ffffffffc0204eea:	177e                	slli	a4,a4,0x3f
ffffffffc0204eec:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204eee:	00a93023          	sd	a0,0(s2)
ffffffffc0204ef2:	8fd9                	or	a5,a5,a4
ffffffffc0204ef4:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204ef8:	03050593          	addi	a1,a0,48
ffffffffc0204efc:	03048513          	addi	a0,s1,48
ffffffffc0204f00:	dddff0ef          	jal	ra,ffffffffc0204cdc <switch_to>
    if (flag) {
ffffffffc0204f04:	00099863          	bnez	s3,ffffffffc0204f14 <proc_run+0x52>
}
ffffffffc0204f08:	70a2                	ld	ra,40(sp)
ffffffffc0204f0a:	7482                	ld	s1,32(sp)
ffffffffc0204f0c:	6962                	ld	s2,24(sp)
ffffffffc0204f0e:	69c2                	ld	s3,16(sp)
ffffffffc0204f10:	6145                	addi	sp,sp,48
ffffffffc0204f12:	8082                	ret
ffffffffc0204f14:	70a2                	ld	ra,40(sp)
ffffffffc0204f16:	7482                	ld	s1,32(sp)
ffffffffc0204f18:	6962                	ld	s2,24(sp)
ffffffffc0204f1a:	69c2                	ld	s3,16(sp)
ffffffffc0204f1c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f1e:	f24fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204f22:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f24:	f24fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0204f28:	6522                	ld	a0,8(sp)
ffffffffc0204f2a:	4985                	li	s3,1
ffffffffc0204f2c:	bf6d                	j	ffffffffc0204ee6 <proc_run+0x24>

ffffffffc0204f2e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f2e:	7119                	addi	sp,sp,-128
ffffffffc0204f30:	f4a6                	sd	s1,104(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f32:	000ae497          	auipc	s1,0xae
ffffffffc0204f36:	8de48493          	addi	s1,s1,-1826 # ffffffffc02b2810 <nr_process>
ffffffffc0204f3a:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f3c:	fc86                	sd	ra,120(sp)
ffffffffc0204f3e:	f8a2                	sd	s0,112(sp)
ffffffffc0204f40:	f0ca                	sd	s2,96(sp)
ffffffffc0204f42:	ecce                	sd	s3,88(sp)
ffffffffc0204f44:	e8d2                	sd	s4,80(sp)
ffffffffc0204f46:	e4d6                	sd	s5,72(sp)
ffffffffc0204f48:	e0da                	sd	s6,64(sp)
ffffffffc0204f4a:	fc5e                	sd	s7,56(sp)
ffffffffc0204f4c:	f862                	sd	s8,48(sp)
ffffffffc0204f4e:	f466                	sd	s9,40(sp)
ffffffffc0204f50:	f06a                	sd	s10,32(sp)
ffffffffc0204f52:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f54:	6785                	lui	a5,0x1
ffffffffc0204f56:	34f75c63          	bge	a4,a5,ffffffffc02052ae <do_fork+0x380>
      if ((proc = alloc_proc()) == NULL) {
ffffffffc0204f5a:	89aa                	mv	s3,a0
ffffffffc0204f5c:	892e                	mv	s2,a1
ffffffffc0204f5e:	8432                	mv	s0,a2
ffffffffc0204f60:	defff0ef          	jal	ra,ffffffffc0204d4e <alloc_proc>
ffffffffc0204f64:	3e050763          	beqz	a0,ffffffffc0205352 <do_fork+0x424>
	   proc = alloc_proc();
ffffffffc0204f68:	de7ff0ef          	jal	ra,ffffffffc0204d4e <alloc_proc>
    proc->parent = current;
ffffffffc0204f6c:	000aea17          	auipc	s4,0xae
ffffffffc0204f70:	88ca0a13          	addi	s4,s4,-1908 # ffffffffc02b27f8 <current>
ffffffffc0204f74:	000a3783          	ld	a5,0(s4)
	   proc = alloc_proc();
ffffffffc0204f78:	8c2a                	mv	s8,a0
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204f7a:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc0204f7e:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204f80:	36071563          	bnez	a4,ffffffffc02052ea <do_fork+0x3bc>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f84:	4509                	li	a0,2
ffffffffc0204f86:	ed5fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
    if (page != NULL) {
ffffffffc0204f8a:	30050063          	beqz	a0,ffffffffc020528a <do_fork+0x35c>
    return page - pages + nbase;
ffffffffc0204f8e:	000aea97          	auipc	s5,0xae
ffffffffc0204f92:	822a8a93          	addi	s5,s5,-2014 # ffffffffc02b27b0 <pages>
ffffffffc0204f96:	000ab683          	ld	a3,0(s5)
ffffffffc0204f9a:	00004b17          	auipc	s6,0x4
ffffffffc0204f9e:	d86b0b13          	addi	s6,s6,-634 # ffffffffc0208d20 <nbase>
ffffffffc0204fa2:	000b3703          	ld	a4,0(s6)
ffffffffc0204fa6:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204faa:	000adb97          	auipc	s7,0xad
ffffffffc0204fae:	7feb8b93          	addi	s7,s7,2046 # ffffffffc02b27a8 <npage>
    return page - pages + nbase;
ffffffffc0204fb2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204fb4:	5dfd                	li	s11,-1
ffffffffc0204fb6:	000bb783          	ld	a5,0(s7)
    return page - pages + nbase;
ffffffffc0204fba:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204fbc:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204fc0:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fc6:	34f67e63          	bgeu	a2,a5,ffffffffc0205322 <do_fork+0x3f4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204fca:	000a3603          	ld	a2,0(s4)
ffffffffc0204fce:	000ada17          	auipc	s4,0xad
ffffffffc0204fd2:	7f2a0a13          	addi	s4,s4,2034 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc0204fd6:	000a3783          	ld	a5,0(s4)
ffffffffc0204fda:	02863d03          	ld	s10,40(a2)
ffffffffc0204fde:	e43a                	sd	a4,8(sp)
ffffffffc0204fe0:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fe2:	00dc3823          	sd	a3,16(s8)
    if (oldmm == NULL) {
ffffffffc0204fe6:	020d0a63          	beqz	s10,ffffffffc020501a <do_fork+0xec>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fea:	1009f993          	andi	s3,s3,256
ffffffffc0204fee:	1c098f63          	beqz	s3,ffffffffc02051cc <do_fork+0x29e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204ff2:	030d2703          	lw	a4,48(s10) # fffffffffff80030 <end+0x3fccd81c>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ff6:	018d3783          	ld	a5,24(s10)
ffffffffc0204ffa:	c02006b7          	lui	a3,0xc0200
ffffffffc0204ffe:	2705                	addiw	a4,a4,1
ffffffffc0205000:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0205004:	03ac3423          	sd	s10,40(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205008:	2cd7e463          	bltu	a5,a3,ffffffffc02052d0 <do_fork+0x3a2>
ffffffffc020500c:	000a3703          	ld	a4,0(s4)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205010:	010c3683          	ld	a3,16(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205014:	8f99                	sub	a5,a5,a4
ffffffffc0205016:	0afc3423          	sd	a5,168(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020501a:	6789                	lui	a5,0x2
ffffffffc020501c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc0205020:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205022:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205024:	0adc3023          	sd	a3,160(s8)
    *(proc->tf) = *tf;
ffffffffc0205028:	87b6                	mv	a5,a3
ffffffffc020502a:	12040893          	addi	a7,s0,288
ffffffffc020502e:	00063803          	ld	a6,0(a2)
ffffffffc0205032:	6608                	ld	a0,8(a2)
ffffffffc0205034:	6a0c                	ld	a1,16(a2)
ffffffffc0205036:	6e18                	ld	a4,24(a2)
ffffffffc0205038:	0107b023          	sd	a6,0(a5)
ffffffffc020503c:	e788                	sd	a0,8(a5)
ffffffffc020503e:	eb8c                	sd	a1,16(a5)
ffffffffc0205040:	ef98                	sd	a4,24(a5)
ffffffffc0205042:	02060613          	addi	a2,a2,32
ffffffffc0205046:	02078793          	addi	a5,a5,32
ffffffffc020504a:	ff1612e3          	bne	a2,a7,ffffffffc020502e <do_fork+0x100>
    proc->tf->gpr.a0 = 0;
ffffffffc020504e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205052:	14090863          	beqz	s2,ffffffffc02051a2 <do_fork+0x274>
ffffffffc0205056:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020505a:	00000797          	auipc	a5,0x0
ffffffffc020505e:	d6678793          	addi	a5,a5,-666 # ffffffffc0204dc0 <forkret>
ffffffffc0205062:	02fc3823          	sd	a5,48(s8)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205066:	02dc3c23          	sd	a3,56(s8)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020506a:	100027f3          	csrr	a5,sstatus
ffffffffc020506e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205070:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205072:	14079963          	bnez	a5,ffffffffc02051c4 <do_fork+0x296>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205076:	000a2817          	auipc	a6,0xa2
ffffffffc020507a:	23a80813          	addi	a6,a6,570 # ffffffffc02a72b0 <last_pid.1>
ffffffffc020507e:	00082783          	lw	a5,0(a6)
ffffffffc0205082:	6709                	lui	a4,0x2
ffffffffc0205084:	0017851b          	addiw	a0,a5,1
ffffffffc0205088:	00a82023          	sw	a0,0(a6)
ffffffffc020508c:	0ae55463          	bge	a0,a4,ffffffffc0205134 <do_fork+0x206>
    if (last_pid >= next_safe) {
ffffffffc0205090:	000a2317          	auipc	t1,0xa2
ffffffffc0205094:	22430313          	addi	t1,t1,548 # ffffffffc02a72b4 <next_safe.0>
ffffffffc0205098:	00032783          	lw	a5,0(t1)
ffffffffc020509c:	000ad417          	auipc	s0,0xad
ffffffffc02050a0:	6d440413          	addi	s0,s0,1748 # ffffffffc02b2770 <proc_list>
ffffffffc02050a4:	0af55063          	bge	a0,a5,ffffffffc0205144 <do_fork+0x216>
        proc->pid = get_pid();
ffffffffc02050a8:	00ac2223          	sw	a0,4(s8)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050ac:	45a9                	li	a1,10
ffffffffc02050ae:	2501                	sext.w	a0,a0
ffffffffc02050b0:	544010ef          	jal	ra,ffffffffc02065f4 <hash32>
ffffffffc02050b4:	02051793          	slli	a5,a0,0x20
ffffffffc02050b8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02050bc:	000a9797          	auipc	a5,0xa9
ffffffffc02050c0:	6b478793          	addi	a5,a5,1716 # ffffffffc02ae770 <hash_list>
ffffffffc02050c4:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02050c6:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050c8:	020c3683          	ld	a3,32(s8)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050cc:	0d8c0793          	addi	a5,s8,216
    prev->next = next->prev = elm;
ffffffffc02050d0:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02050d2:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02050d4:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050d6:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02050d8:	0c8c0793          	addi	a5,s8,200
    elm->next = next;
ffffffffc02050dc:	0ebc3023          	sd	a1,224(s8)
    elm->prev = prev;
ffffffffc02050e0:	0cac3c23          	sd	a0,216(s8)
    prev->next = next->prev = elm;
ffffffffc02050e4:	e21c                	sd	a5,0(a2)
ffffffffc02050e6:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02050e8:	0ccc3823          	sd	a2,208(s8)
    elm->prev = prev;
ffffffffc02050ec:	0c8c3423          	sd	s0,200(s8)
    proc->yptr = NULL;
ffffffffc02050f0:	0e0c3c23          	sd	zero,248(s8)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050f4:	10ec3023          	sd	a4,256(s8)
ffffffffc02050f8:	c319                	beqz	a4,ffffffffc02050fe <do_fork+0x1d0>
        proc->optr->yptr = proc;
ffffffffc02050fa:	0f873c23          	sd	s8,248(a4) # 20f8 <_binary_obj___user_faultread_out_size-0x7ab8>
    nr_process ++;
ffffffffc02050fe:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0205100:	0f86b823          	sd	s8,240(a3)
    nr_process ++;
ffffffffc0205104:	2785                	addiw	a5,a5,1
ffffffffc0205106:	c09c                	sw	a5,0(s1)
    if (flag) {
ffffffffc0205108:	18091663          	bnez	s2,ffffffffc0205294 <do_fork+0x366>
		wakeup_proc(proc);
ffffffffc020510c:	8562                	mv	a0,s8
ffffffffc020510e:	667000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
    	ret = proc->pid;
ffffffffc0205112:	004c2503          	lw	a0,4(s8)
}
ffffffffc0205116:	70e6                	ld	ra,120(sp)
ffffffffc0205118:	7446                	ld	s0,112(sp)
ffffffffc020511a:	74a6                	ld	s1,104(sp)
ffffffffc020511c:	7906                	ld	s2,96(sp)
ffffffffc020511e:	69e6                	ld	s3,88(sp)
ffffffffc0205120:	6a46                	ld	s4,80(sp)
ffffffffc0205122:	6aa6                	ld	s5,72(sp)
ffffffffc0205124:	6b06                	ld	s6,64(sp)
ffffffffc0205126:	7be2                	ld	s7,56(sp)
ffffffffc0205128:	7c42                	ld	s8,48(sp)
ffffffffc020512a:	7ca2                	ld	s9,40(sp)
ffffffffc020512c:	7d02                	ld	s10,32(sp)
ffffffffc020512e:	6de2                	ld	s11,24(sp)
ffffffffc0205130:	6109                	addi	sp,sp,128
ffffffffc0205132:	8082                	ret
        last_pid = 1;
ffffffffc0205134:	4785                	li	a5,1
ffffffffc0205136:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020513a:	4505                	li	a0,1
ffffffffc020513c:	000a2317          	auipc	t1,0xa2
ffffffffc0205140:	17830313          	addi	t1,t1,376 # ffffffffc02a72b4 <next_safe.0>
    return listelm->next;
ffffffffc0205144:	000ad417          	auipc	s0,0xad
ffffffffc0205148:	62c40413          	addi	s0,s0,1580 # ffffffffc02b2770 <proc_list>
ffffffffc020514c:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205150:	6789                	lui	a5,0x2
ffffffffc0205152:	00f32023          	sw	a5,0(t1)
ffffffffc0205156:	86aa                	mv	a3,a0
ffffffffc0205158:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020515a:	6e89                	lui	t4,0x2
ffffffffc020515c:	148e0463          	beq	t3,s0,ffffffffc02052a4 <do_fork+0x376>
ffffffffc0205160:	88ae                	mv	a7,a1
ffffffffc0205162:	87f2                	mv	a5,t3
ffffffffc0205164:	6609                	lui	a2,0x2
ffffffffc0205166:	a811                	j	ffffffffc020517a <do_fork+0x24c>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205168:	00e6d663          	bge	a3,a4,ffffffffc0205174 <do_fork+0x246>
ffffffffc020516c:	00c75463          	bge	a4,a2,ffffffffc0205174 <do_fork+0x246>
ffffffffc0205170:	863a                	mv	a2,a4
ffffffffc0205172:	4885                	li	a7,1
ffffffffc0205174:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205176:	00878d63          	beq	a5,s0,ffffffffc0205190 <do_fork+0x262>
            if (proc->pid == last_pid) {
ffffffffc020517a:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc020517e:	fee695e3          	bne	a3,a4,ffffffffc0205168 <do_fork+0x23a>
                if (++ last_pid >= next_safe) {
ffffffffc0205182:	2685                	addiw	a3,a3,1
ffffffffc0205184:	10c6db63          	bge	a3,a2,ffffffffc020529a <do_fork+0x36c>
ffffffffc0205188:	679c                	ld	a5,8(a5)
ffffffffc020518a:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020518c:	fe8797e3          	bne	a5,s0,ffffffffc020517a <do_fork+0x24c>
ffffffffc0205190:	c581                	beqz	a1,ffffffffc0205198 <do_fork+0x26a>
ffffffffc0205192:	00d82023          	sw	a3,0(a6)
ffffffffc0205196:	8536                	mv	a0,a3
ffffffffc0205198:	f00888e3          	beqz	a7,ffffffffc02050a8 <do_fork+0x17a>
ffffffffc020519c:	00c32023          	sw	a2,0(t1)
ffffffffc02051a0:	b721                	j	ffffffffc02050a8 <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051a2:	8936                	mv	s2,a3
ffffffffc02051a4:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051a8:	00000797          	auipc	a5,0x0
ffffffffc02051ac:	c1878793          	addi	a5,a5,-1000 # ffffffffc0204dc0 <forkret>
ffffffffc02051b0:	02fc3823          	sd	a5,48(s8)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051b4:	02dc3c23          	sd	a3,56(s8)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051b8:	100027f3          	csrr	a5,sstatus
ffffffffc02051bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051be:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051c0:	ea078be3          	beqz	a5,ffffffffc0205076 <do_fork+0x148>
        intr_disable();
ffffffffc02051c4:	c84fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02051c8:	4905                	li	s2,1
ffffffffc02051ca:	b575                	j	ffffffffc0205076 <do_fork+0x148>
    if ((mm = mm_create()) == NULL) {
ffffffffc02051cc:	fbafd0ef          	jal	ra,ffffffffc0202986 <mm_create>
ffffffffc02051d0:	8caa                	mv	s9,a0
ffffffffc02051d2:	c159                	beqz	a0,ffffffffc0205258 <do_fork+0x32a>
    if ((page = alloc_page()) == NULL) {
ffffffffc02051d4:	4505                	li	a0,1
ffffffffc02051d6:	c85fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02051da:	cd25                	beqz	a0,ffffffffc0205252 <do_fork+0x324>
    return page - pages + nbase;
ffffffffc02051dc:	000ab683          	ld	a3,0(s5)
ffffffffc02051e0:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02051e2:	000bb783          	ld	a5,0(s7)
    return page - pages + nbase;
ffffffffc02051e6:	40d506b3          	sub	a3,a0,a3
ffffffffc02051ea:	8699                	srai	a3,a3,0x6
ffffffffc02051ec:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02051ee:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02051f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051f4:	12fdf763          	bgeu	s11,a5,ffffffffc0205322 <do_fork+0x3f4>
ffffffffc02051f8:	000a3983          	ld	s3,0(s4)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02051fc:	6605                	lui	a2,0x1
ffffffffc02051fe:	000ad597          	auipc	a1,0xad
ffffffffc0205202:	5a25b583          	ld	a1,1442(a1) # ffffffffc02b27a0 <boot_pgdir>
ffffffffc0205206:	99b6                	add	s3,s3,a3
ffffffffc0205208:	854e                	mv	a0,s3
ffffffffc020520a:	7e5000ef          	jal	ra,ffffffffc02061ee <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020520e:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0205212:	013cbc23          	sd	s3,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205216:	4785                	li	a5,1
ffffffffc0205218:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020521c:	8b85                	andi	a5,a5,1
ffffffffc020521e:	4985                	li	s3,1
ffffffffc0205220:	c799                	beqz	a5,ffffffffc020522e <do_fork+0x300>
        schedule();
ffffffffc0205222:	5d3000ef          	jal	ra,ffffffffc0205ff4 <schedule>
ffffffffc0205226:	413db7af          	amoor.d	a5,s3,(s11)
    while (!try_lock(lock)) {
ffffffffc020522a:	8b85                	andi	a5,a5,1
ffffffffc020522c:	fbfd                	bnez	a5,ffffffffc0205222 <do_fork+0x2f4>
        ret = dup_mmap(mm, oldmm);
ffffffffc020522e:	85ea                	mv	a1,s10
ffffffffc0205230:	8566                	mv	a0,s9
ffffffffc0205232:	9ddfd0ef          	jal	ra,ffffffffc0202c0e <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205236:	57f9                	li	a5,-2
ffffffffc0205238:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020523c:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020523e:	c7f1                	beqz	a5,ffffffffc020530a <do_fork+0x3dc>
good_mm:
ffffffffc0205240:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc0205242:	da0508e3          	beqz	a0,ffffffffc0204ff2 <do_fork+0xc4>
    exit_mmap(mm);
ffffffffc0205246:	8566                	mv	a0,s9
ffffffffc0205248:	a61fd0ef          	jal	ra,ffffffffc0202ca8 <exit_mmap>
    put_pgdir(mm);
ffffffffc020524c:	8566                	mv	a0,s9
ffffffffc020524e:	bffff0ef          	jal	ra,ffffffffc0204e4c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205252:	8566                	mv	a0,s9
ffffffffc0205254:	8b9fd0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205258:	010c3683          	ld	a3,16(s8)
    return pa2page(PADDR(kva));
ffffffffc020525c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205260:	0cf6ed63          	bltu	a3,a5,ffffffffc020533a <do_fork+0x40c>
ffffffffc0205264:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0205268:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020526c:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205270:	83b1                	srli	a5,a5,0xc
ffffffffc0205272:	04e7f363          	bgeu	a5,a4,ffffffffc02052b8 <do_fork+0x38a>
    return &pages[PPN(pa) - nbase];
ffffffffc0205276:	000b3703          	ld	a4,0(s6)
ffffffffc020527a:	000ab503          	ld	a0,0(s5)
ffffffffc020527e:	4589                	li	a1,2
ffffffffc0205280:	8f99                	sub	a5,a5,a4
ffffffffc0205282:	079a                	slli	a5,a5,0x6
ffffffffc0205284:	953e                	add	a0,a0,a5
ffffffffc0205286:	c67fb0ef          	jal	ra,ffffffffc0200eec <free_pages>
    kfree(proc);
ffffffffc020528a:	8562                	mv	a0,s8
ffffffffc020528c:	c4cfe0ef          	jal	ra,ffffffffc02036d8 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205290:	5571                	li	a0,-4
    return ret;
ffffffffc0205292:	b551                	j	ffffffffc0205116 <do_fork+0x1e8>
        intr_enable();
ffffffffc0205294:	baefb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205298:	bd95                	j	ffffffffc020510c <do_fork+0x1de>
                    if (last_pid >= MAX_PID) {
ffffffffc020529a:	01d6c363          	blt	a3,t4,ffffffffc02052a0 <do_fork+0x372>
                        last_pid = 1;
ffffffffc020529e:	4685                	li	a3,1
                    goto repeat;
ffffffffc02052a0:	4585                	li	a1,1
ffffffffc02052a2:	bd6d                	j	ffffffffc020515c <do_fork+0x22e>
ffffffffc02052a4:	c599                	beqz	a1,ffffffffc02052b2 <do_fork+0x384>
ffffffffc02052a6:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02052aa:	8536                	mv	a0,a3
ffffffffc02052ac:	bbf5                	j	ffffffffc02050a8 <do_fork+0x17a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052ae:	556d                	li	a0,-5
ffffffffc02052b0:	b59d                	j	ffffffffc0205116 <do_fork+0x1e8>
    return last_pid;
ffffffffc02052b2:	00082503          	lw	a0,0(a6)
ffffffffc02052b6:	bbcd                	j	ffffffffc02050a8 <do_fork+0x17a>
        panic("pa2page called with invalid pa");
ffffffffc02052b8:	00002617          	auipc	a2,0x2
ffffffffc02052bc:	d0060613          	addi	a2,a2,-768 # ffffffffc0206fb8 <commands+0x700>
ffffffffc02052c0:	06200593          	li	a1,98
ffffffffc02052c4:	00002517          	auipc	a0,0x2
ffffffffc02052c8:	d1450513          	addi	a0,a0,-748 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02052cc:	f3dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052d0:	86be                	mv	a3,a5
ffffffffc02052d2:	00002617          	auipc	a2,0x2
ffffffffc02052d6:	e1660613          	addi	a2,a2,-490 # ffffffffc02070e8 <commands+0x830>
ffffffffc02052da:	16e00593          	li	a1,366
ffffffffc02052de:	00003517          	auipc	a0,0x3
ffffffffc02052e2:	18a50513          	addi	a0,a0,394 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02052e6:	f23fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc02052ea:	00003697          	auipc	a3,0x3
ffffffffc02052ee:	19668693          	addi	a3,a3,406 # ffffffffc0208480 <default_pmm_manager+0x110>
ffffffffc02052f2:	00002617          	auipc	a2,0x2
ffffffffc02052f6:	9d660613          	addi	a2,a2,-1578 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02052fa:	1bc00593          	li	a1,444
ffffffffc02052fe:	00003517          	auipc	a0,0x3
ffffffffc0205302:	16a50513          	addi	a0,a0,362 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205306:	f03fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc020530a:	00003617          	auipc	a2,0x3
ffffffffc020530e:	19660613          	addi	a2,a2,406 # ffffffffc02084a0 <default_pmm_manager+0x130>
ffffffffc0205312:	03100593          	li	a1,49
ffffffffc0205316:	00003517          	auipc	a0,0x3
ffffffffc020531a:	19a50513          	addi	a0,a0,410 # ffffffffc02084b0 <default_pmm_manager+0x140>
ffffffffc020531e:	eebfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0205322:	00002617          	auipc	a2,0x2
ffffffffc0205326:	cee60613          	addi	a2,a2,-786 # ffffffffc0207010 <commands+0x758>
ffffffffc020532a:	06900593          	li	a1,105
ffffffffc020532e:	00002517          	auipc	a0,0x2
ffffffffc0205332:	caa50513          	addi	a0,a0,-854 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0205336:	ed3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020533a:	00002617          	auipc	a2,0x2
ffffffffc020533e:	dae60613          	addi	a2,a2,-594 # ffffffffc02070e8 <commands+0x830>
ffffffffc0205342:	06e00593          	li	a1,110
ffffffffc0205346:	00002517          	auipc	a0,0x2
ffffffffc020534a:	c9250513          	addi	a0,a0,-878 # ffffffffc0206fd8 <commands+0x720>
ffffffffc020534e:	ebbfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205352:	01003783          	ld	a5,16(zero) # 10 <_binary_obj___user_faultread_out_size-0x9ba0>
ffffffffc0205356:	9002                	ebreak

ffffffffc0205358 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205358:	7129                	addi	sp,sp,-320
ffffffffc020535a:	fa22                	sd	s0,304(sp)
ffffffffc020535c:	f626                	sd	s1,296(sp)
ffffffffc020535e:	f24a                	sd	s2,288(sp)
ffffffffc0205360:	84ae                	mv	s1,a1
ffffffffc0205362:	892a                	mv	s2,a0
ffffffffc0205364:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205366:	4581                	li	a1,0
ffffffffc0205368:	12000613          	li	a2,288
ffffffffc020536c:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020536e:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205370:	66d000ef          	jal	ra,ffffffffc02061dc <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205374:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205376:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205378:	100027f3          	csrr	a5,sstatus
ffffffffc020537c:	edd7f793          	andi	a5,a5,-291
ffffffffc0205380:	1207e793          	ori	a5,a5,288
ffffffffc0205384:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205386:	860a                	mv	a2,sp
ffffffffc0205388:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020538c:	00000797          	auipc	a5,0x0
ffffffffc0205390:	9ba78793          	addi	a5,a5,-1606 # ffffffffc0204d46 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205394:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205396:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205398:	b97ff0ef          	jal	ra,ffffffffc0204f2e <do_fork>
}
ffffffffc020539c:	70f2                	ld	ra,312(sp)
ffffffffc020539e:	7452                	ld	s0,304(sp)
ffffffffc02053a0:	74b2                	ld	s1,296(sp)
ffffffffc02053a2:	7912                	ld	s2,288(sp)
ffffffffc02053a4:	6131                	addi	sp,sp,320
ffffffffc02053a6:	8082                	ret

ffffffffc02053a8 <do_exit>:
do_exit(int error_code) {
ffffffffc02053a8:	7179                	addi	sp,sp,-48
ffffffffc02053aa:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02053ac:	000ad417          	auipc	s0,0xad
ffffffffc02053b0:	44c40413          	addi	s0,s0,1100 # ffffffffc02b27f8 <current>
ffffffffc02053b4:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02053b6:	f406                	sd	ra,40(sp)
ffffffffc02053b8:	ec26                	sd	s1,24(sp)
ffffffffc02053ba:	e84a                	sd	s2,16(sp)
ffffffffc02053bc:	e44e                	sd	s3,8(sp)
ffffffffc02053be:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02053c0:	000ad717          	auipc	a4,0xad
ffffffffc02053c4:	44073703          	ld	a4,1088(a4) # ffffffffc02b2800 <idleproc>
ffffffffc02053c8:	0ce78c63          	beq	a5,a4,ffffffffc02054a0 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02053cc:	000ad497          	auipc	s1,0xad
ffffffffc02053d0:	43c48493          	addi	s1,s1,1084 # ffffffffc02b2808 <initproc>
ffffffffc02053d4:	6098                	ld	a4,0(s1)
ffffffffc02053d6:	0ee78b63          	beq	a5,a4,ffffffffc02054cc <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02053da:	0287b983          	ld	s3,40(a5)
ffffffffc02053de:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02053e0:	02098663          	beqz	s3,ffffffffc020540c <do_exit+0x64>
ffffffffc02053e4:	000ad797          	auipc	a5,0xad
ffffffffc02053e8:	3b47b783          	ld	a5,948(a5) # ffffffffc02b2798 <boot_cr3>
ffffffffc02053ec:	577d                	li	a4,-1
ffffffffc02053ee:	177e                	slli	a4,a4,0x3f
ffffffffc02053f0:	83b1                	srli	a5,a5,0xc
ffffffffc02053f2:	8fd9                	or	a5,a5,a4
ffffffffc02053f4:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02053f8:	0309a783          	lw	a5,48(s3)
ffffffffc02053fc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205400:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205404:	cb55                	beqz	a4,ffffffffc02054b8 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205406:	601c                	ld	a5,0(s0)
ffffffffc0205408:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020540c:	601c                	ld	a5,0(s0)
ffffffffc020540e:	470d                	li	a4,3
ffffffffc0205410:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205412:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205416:	100027f3          	csrr	a5,sstatus
ffffffffc020541a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020541c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020541e:	e3f9                	bnez	a5,ffffffffc02054e4 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205420:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205422:	800007b7          	lui	a5,0x80000
ffffffffc0205426:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205428:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020542a:	0ec52703          	lw	a4,236(a0)
ffffffffc020542e:	0af70f63          	beq	a4,a5,ffffffffc02054ec <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205432:	6018                	ld	a4,0(s0)
ffffffffc0205434:	7b7c                	ld	a5,240(a4)
ffffffffc0205436:	c3a1                	beqz	a5,ffffffffc0205476 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205438:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020543c:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020543e:	0985                	addi	s3,s3,1
ffffffffc0205440:	a021                	j	ffffffffc0205448 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205442:	6018                	ld	a4,0(s0)
ffffffffc0205444:	7b7c                	ld	a5,240(a4)
ffffffffc0205446:	cb85                	beqz	a5,ffffffffc0205476 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205448:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020544c:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020544e:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205450:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205452:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205456:	10e7b023          	sd	a4,256(a5)
ffffffffc020545a:	c311                	beqz	a4,ffffffffc020545e <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020545c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020545e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205460:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205462:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205464:	fd271fe3          	bne	a4,s2,ffffffffc0205442 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205468:	0ec52783          	lw	a5,236(a0)
ffffffffc020546c:	fd379be3          	bne	a5,s3,ffffffffc0205442 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205470:	305000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc0205474:	b7f9                	j	ffffffffc0205442 <do_exit+0x9a>
    if (flag) {
ffffffffc0205476:	020a1263          	bnez	s4,ffffffffc020549a <do_exit+0xf2>
    schedule();
ffffffffc020547a:	37b000ef          	jal	ra,ffffffffc0205ff4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020547e:	601c                	ld	a5,0(s0)
ffffffffc0205480:	00003617          	auipc	a2,0x3
ffffffffc0205484:	06860613          	addi	a2,a2,104 # ffffffffc02084e8 <default_pmm_manager+0x178>
ffffffffc0205488:	20b00593          	li	a1,523
ffffffffc020548c:	43d4                	lw	a3,4(a5)
ffffffffc020548e:	00003517          	auipc	a0,0x3
ffffffffc0205492:	fda50513          	addi	a0,a0,-38 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205496:	d73fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc020549a:	9a8fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020549e:	bff1                	j	ffffffffc020547a <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02054a0:	00003617          	auipc	a2,0x3
ffffffffc02054a4:	02860613          	addi	a2,a2,40 # ffffffffc02084c8 <default_pmm_manager+0x158>
ffffffffc02054a8:	1df00593          	li	a1,479
ffffffffc02054ac:	00003517          	auipc	a0,0x3
ffffffffc02054b0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02054b4:	d55fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc02054b8:	854e                	mv	a0,s3
ffffffffc02054ba:	feefd0ef          	jal	ra,ffffffffc0202ca8 <exit_mmap>
            put_pgdir(mm);
ffffffffc02054be:	854e                	mv	a0,s3
ffffffffc02054c0:	98dff0ef          	jal	ra,ffffffffc0204e4c <put_pgdir>
            mm_destroy(mm);
ffffffffc02054c4:	854e                	mv	a0,s3
ffffffffc02054c6:	e46fd0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
ffffffffc02054ca:	bf35                	j	ffffffffc0205406 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02054cc:	00003617          	auipc	a2,0x3
ffffffffc02054d0:	00c60613          	addi	a2,a2,12 # ffffffffc02084d8 <default_pmm_manager+0x168>
ffffffffc02054d4:	1e200593          	li	a1,482
ffffffffc02054d8:	00003517          	auipc	a0,0x3
ffffffffc02054dc:	f9050513          	addi	a0,a0,-112 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02054e0:	d29fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02054e4:	964fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02054e8:	4a05                	li	s4,1
ffffffffc02054ea:	bf1d                	j	ffffffffc0205420 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02054ec:	289000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc02054f0:	b789                	j	ffffffffc0205432 <do_exit+0x8a>

ffffffffc02054f2 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02054f2:	715d                	addi	sp,sp,-80
ffffffffc02054f4:	f84a                	sd	s2,48(sp)
ffffffffc02054f6:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02054f8:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054fc:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02054fe:	fc26                	sd	s1,56(sp)
ffffffffc0205500:	f052                	sd	s4,32(sp)
ffffffffc0205502:	ec56                	sd	s5,24(sp)
ffffffffc0205504:	e85a                	sd	s6,16(sp)
ffffffffc0205506:	e45e                	sd	s7,8(sp)
ffffffffc0205508:	e486                	sd	ra,72(sp)
ffffffffc020550a:	e0a2                	sd	s0,64(sp)
ffffffffc020550c:	84aa                	mv	s1,a0
ffffffffc020550e:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205510:	000adb97          	auipc	s7,0xad
ffffffffc0205514:	2e8b8b93          	addi	s7,s7,744 # ffffffffc02b27f8 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205518:	00050b1b          	sext.w	s6,a0
ffffffffc020551c:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205520:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205522:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205524:	ccbd                	beqz	s1,ffffffffc02055a2 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205526:	0359e863          	bltu	s3,s5,ffffffffc0205556 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020552a:	45a9                	li	a1,10
ffffffffc020552c:	855a                	mv	a0,s6
ffffffffc020552e:	0c6010ef          	jal	ra,ffffffffc02065f4 <hash32>
ffffffffc0205532:	02051793          	slli	a5,a0,0x20
ffffffffc0205536:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020553a:	000a9797          	auipc	a5,0xa9
ffffffffc020553e:	23678793          	addi	a5,a5,566 # ffffffffc02ae770 <hash_list>
ffffffffc0205542:	953e                	add	a0,a0,a5
ffffffffc0205544:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205546:	a029                	j	ffffffffc0205550 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0205548:	f2c42783          	lw	a5,-212(s0)
ffffffffc020554c:	02978163          	beq	a5,s1,ffffffffc020556e <do_wait.part.0+0x7c>
ffffffffc0205550:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205552:	fe851be3          	bne	a0,s0,ffffffffc0205548 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205556:	5579                	li	a0,-2
}
ffffffffc0205558:	60a6                	ld	ra,72(sp)
ffffffffc020555a:	6406                	ld	s0,64(sp)
ffffffffc020555c:	74e2                	ld	s1,56(sp)
ffffffffc020555e:	7942                	ld	s2,48(sp)
ffffffffc0205560:	79a2                	ld	s3,40(sp)
ffffffffc0205562:	7a02                	ld	s4,32(sp)
ffffffffc0205564:	6ae2                	ld	s5,24(sp)
ffffffffc0205566:	6b42                	ld	s6,16(sp)
ffffffffc0205568:	6ba2                	ld	s7,8(sp)
ffffffffc020556a:	6161                	addi	sp,sp,80
ffffffffc020556c:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc020556e:	000bb683          	ld	a3,0(s7)
ffffffffc0205572:	f4843783          	ld	a5,-184(s0)
ffffffffc0205576:	fed790e3          	bne	a5,a3,ffffffffc0205556 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020557a:	f2842703          	lw	a4,-216(s0)
ffffffffc020557e:	478d                	li	a5,3
ffffffffc0205580:	0ef70b63          	beq	a4,a5,ffffffffc0205676 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205584:	4785                	li	a5,1
ffffffffc0205586:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205588:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020558c:	269000ef          	jal	ra,ffffffffc0205ff4 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205590:	000bb783          	ld	a5,0(s7)
ffffffffc0205594:	0b07a783          	lw	a5,176(a5)
ffffffffc0205598:	8b85                	andi	a5,a5,1
ffffffffc020559a:	d7c9                	beqz	a5,ffffffffc0205524 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020559c:	555d                	li	a0,-9
ffffffffc020559e:	e0bff0ef          	jal	ra,ffffffffc02053a8 <do_exit>
        proc = current->cptr;
ffffffffc02055a2:	000bb683          	ld	a3,0(s7)
ffffffffc02055a6:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055a8:	d45d                	beqz	s0,ffffffffc0205556 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055aa:	470d                	li	a4,3
ffffffffc02055ac:	a021                	j	ffffffffc02055b4 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055ae:	10043403          	ld	s0,256(s0)
ffffffffc02055b2:	d869                	beqz	s0,ffffffffc0205584 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055b4:	401c                	lw	a5,0(s0)
ffffffffc02055b6:	fee79ce3          	bne	a5,a4,ffffffffc02055ae <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055ba:	000ad797          	auipc	a5,0xad
ffffffffc02055be:	2467b783          	ld	a5,582(a5) # ffffffffc02b2800 <idleproc>
ffffffffc02055c2:	0c878963          	beq	a5,s0,ffffffffc0205694 <do_wait.part.0+0x1a2>
ffffffffc02055c6:	000ad797          	auipc	a5,0xad
ffffffffc02055ca:	2427b783          	ld	a5,578(a5) # ffffffffc02b2808 <initproc>
ffffffffc02055ce:	0cf40363          	beq	s0,a5,ffffffffc0205694 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc02055d2:	000a0663          	beqz	s4,ffffffffc02055de <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02055d6:	0e842783          	lw	a5,232(s0)
ffffffffc02055da:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055de:	100027f3          	csrr	a5,sstatus
ffffffffc02055e2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055e4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e6:	e7c1                	bnez	a5,ffffffffc020566e <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055e8:	6c70                	ld	a2,216(s0)
ffffffffc02055ea:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055ec:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02055f0:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055f2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055f4:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055f6:	6470                	ld	a2,200(s0)
ffffffffc02055f8:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055fa:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055fc:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02055fe:	c319                	beqz	a4,ffffffffc0205604 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205600:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205602:	7c7c                	ld	a5,248(s0)
ffffffffc0205604:	c3b5                	beqz	a5,ffffffffc0205668 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205606:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020560a:	000ad717          	auipc	a4,0xad
ffffffffc020560e:	20670713          	addi	a4,a4,518 # ffffffffc02b2810 <nr_process>
ffffffffc0205612:	431c                	lw	a5,0(a4)
ffffffffc0205614:	37fd                	addiw	a5,a5,-1
ffffffffc0205616:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205618:	e5a9                	bnez	a1,ffffffffc0205662 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020561a:	6814                	ld	a3,16(s0)
ffffffffc020561c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205620:	04f6ee63          	bltu	a3,a5,ffffffffc020567c <do_wait.part.0+0x18a>
ffffffffc0205624:	000ad797          	auipc	a5,0xad
ffffffffc0205628:	19c7b783          	ld	a5,412(a5) # ffffffffc02b27c0 <va_pa_offset>
ffffffffc020562c:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020562e:	82b1                	srli	a3,a3,0xc
ffffffffc0205630:	000ad797          	auipc	a5,0xad
ffffffffc0205634:	1787b783          	ld	a5,376(a5) # ffffffffc02b27a8 <npage>
ffffffffc0205638:	06f6fa63          	bgeu	a3,a5,ffffffffc02056ac <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020563c:	00003517          	auipc	a0,0x3
ffffffffc0205640:	6e453503          	ld	a0,1764(a0) # ffffffffc0208d20 <nbase>
ffffffffc0205644:	8e89                	sub	a3,a3,a0
ffffffffc0205646:	069a                	slli	a3,a3,0x6
ffffffffc0205648:	000ad517          	auipc	a0,0xad
ffffffffc020564c:	16853503          	ld	a0,360(a0) # ffffffffc02b27b0 <pages>
ffffffffc0205650:	9536                	add	a0,a0,a3
ffffffffc0205652:	4589                	li	a1,2
ffffffffc0205654:	899fb0ef          	jal	ra,ffffffffc0200eec <free_pages>
    kfree(proc);
ffffffffc0205658:	8522                	mv	a0,s0
ffffffffc020565a:	87efe0ef          	jal	ra,ffffffffc02036d8 <kfree>
    return 0;
ffffffffc020565e:	4501                	li	a0,0
ffffffffc0205660:	bde5                	j	ffffffffc0205558 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205662:	fe1fa0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205666:	bf55                	j	ffffffffc020561a <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205668:	701c                	ld	a5,32(s0)
ffffffffc020566a:	fbf8                	sd	a4,240(a5)
ffffffffc020566c:	bf79                	j	ffffffffc020560a <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020566e:	fdbfa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205672:	4585                	li	a1,1
ffffffffc0205674:	bf95                	j	ffffffffc02055e8 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205676:	f2840413          	addi	s0,s0,-216
ffffffffc020567a:	b781                	j	ffffffffc02055ba <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc020567c:	00002617          	auipc	a2,0x2
ffffffffc0205680:	a6c60613          	addi	a2,a2,-1428 # ffffffffc02070e8 <commands+0x830>
ffffffffc0205684:	06e00593          	li	a1,110
ffffffffc0205688:	00002517          	auipc	a0,0x2
ffffffffc020568c:	95050513          	addi	a0,a0,-1712 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0205690:	b79fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205694:	00003617          	auipc	a2,0x3
ffffffffc0205698:	e7460613          	addi	a2,a2,-396 # ffffffffc0208508 <default_pmm_manager+0x198>
ffffffffc020569c:	30200593          	li	a1,770
ffffffffc02056a0:	00003517          	auipc	a0,0x3
ffffffffc02056a4:	dc850513          	addi	a0,a0,-568 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02056a8:	b61fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056ac:	00002617          	auipc	a2,0x2
ffffffffc02056b0:	90c60613          	addi	a2,a2,-1780 # ffffffffc0206fb8 <commands+0x700>
ffffffffc02056b4:	06200593          	li	a1,98
ffffffffc02056b8:	00002517          	auipc	a0,0x2
ffffffffc02056bc:	92050513          	addi	a0,a0,-1760 # ffffffffc0206fd8 <commands+0x720>
ffffffffc02056c0:	b49fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02056c4 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056c4:	1141                	addi	sp,sp,-16
ffffffffc02056c6:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056c8:	865fb0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056cc:	f59fd0ef          	jal	ra,ffffffffc0203624 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056d0:	4601                	li	a2,0
ffffffffc02056d2:	4581                	li	a1,0
ffffffffc02056d4:	fffff517          	auipc	a0,0xfffff
ffffffffc02056d8:	6fa50513          	addi	a0,a0,1786 # ffffffffc0204dce <user_main>
ffffffffc02056dc:	c7dff0ef          	jal	ra,ffffffffc0205358 <kernel_thread>
    if (pid <= 0) {
ffffffffc02056e0:	00a04563          	bgtz	a0,ffffffffc02056ea <init_main+0x26>
ffffffffc02056e4:	a071                	j	ffffffffc0205770 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056e6:	10f000ef          	jal	ra,ffffffffc0205ff4 <schedule>
    if (code_store != NULL) {
ffffffffc02056ea:	4581                	li	a1,0
ffffffffc02056ec:	4501                	li	a0,0
ffffffffc02056ee:	e05ff0ef          	jal	ra,ffffffffc02054f2 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056f2:	d975                	beqz	a0,ffffffffc02056e6 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056f4:	00003517          	auipc	a0,0x3
ffffffffc02056f8:	e5450513          	addi	a0,a0,-428 # ffffffffc0208548 <default_pmm_manager+0x1d8>
ffffffffc02056fc:	9d1fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205700:	000ad797          	auipc	a5,0xad
ffffffffc0205704:	1087b783          	ld	a5,264(a5) # ffffffffc02b2808 <initproc>
ffffffffc0205708:	7bf8                	ld	a4,240(a5)
ffffffffc020570a:	e339                	bnez	a4,ffffffffc0205750 <init_main+0x8c>
ffffffffc020570c:	7ff8                	ld	a4,248(a5)
ffffffffc020570e:	e329                	bnez	a4,ffffffffc0205750 <init_main+0x8c>
ffffffffc0205710:	1007b703          	ld	a4,256(a5)
ffffffffc0205714:	ef15                	bnez	a4,ffffffffc0205750 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205716:	000ad697          	auipc	a3,0xad
ffffffffc020571a:	0fa6a683          	lw	a3,250(a3) # ffffffffc02b2810 <nr_process>
ffffffffc020571e:	4709                	li	a4,2
ffffffffc0205720:	0ae69463          	bne	a3,a4,ffffffffc02057c8 <init_main+0x104>
    return listelm->next;
ffffffffc0205724:	000ad697          	auipc	a3,0xad
ffffffffc0205728:	04c68693          	addi	a3,a3,76 # ffffffffc02b2770 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020572c:	6698                	ld	a4,8(a3)
ffffffffc020572e:	0c878793          	addi	a5,a5,200
ffffffffc0205732:	06f71b63          	bne	a4,a5,ffffffffc02057a8 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205736:	629c                	ld	a5,0(a3)
ffffffffc0205738:	04f71863          	bne	a4,a5,ffffffffc0205788 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020573c:	00003517          	auipc	a0,0x3
ffffffffc0205740:	ef450513          	addi	a0,a0,-268 # ffffffffc0208630 <default_pmm_manager+0x2c0>
ffffffffc0205744:	989fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0205748:	60a2                	ld	ra,8(sp)
ffffffffc020574a:	4501                	li	a0,0
ffffffffc020574c:	0141                	addi	sp,sp,16
ffffffffc020574e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205750:	00003697          	auipc	a3,0x3
ffffffffc0205754:	e2068693          	addi	a3,a3,-480 # ffffffffc0208570 <default_pmm_manager+0x200>
ffffffffc0205758:	00001617          	auipc	a2,0x1
ffffffffc020575c:	57060613          	addi	a2,a2,1392 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205760:	36700593          	li	a1,871
ffffffffc0205764:	00003517          	auipc	a0,0x3
ffffffffc0205768:	d0450513          	addi	a0,a0,-764 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc020576c:	a9dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205770:	00003617          	auipc	a2,0x3
ffffffffc0205774:	db860613          	addi	a2,a2,-584 # ffffffffc0208528 <default_pmm_manager+0x1b8>
ffffffffc0205778:	35f00593          	li	a1,863
ffffffffc020577c:	00003517          	auipc	a0,0x3
ffffffffc0205780:	cec50513          	addi	a0,a0,-788 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205784:	a85fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205788:	00003697          	auipc	a3,0x3
ffffffffc020578c:	e7868693          	addi	a3,a3,-392 # ffffffffc0208600 <default_pmm_manager+0x290>
ffffffffc0205790:	00001617          	auipc	a2,0x1
ffffffffc0205794:	53860613          	addi	a2,a2,1336 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205798:	36a00593          	li	a1,874
ffffffffc020579c:	00003517          	auipc	a0,0x3
ffffffffc02057a0:	ccc50513          	addi	a0,a0,-820 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02057a4:	a65fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057a8:	00003697          	auipc	a3,0x3
ffffffffc02057ac:	e2868693          	addi	a3,a3,-472 # ffffffffc02085d0 <default_pmm_manager+0x260>
ffffffffc02057b0:	00001617          	auipc	a2,0x1
ffffffffc02057b4:	51860613          	addi	a2,a2,1304 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02057b8:	36900593          	li	a1,873
ffffffffc02057bc:	00003517          	auipc	a0,0x3
ffffffffc02057c0:	cac50513          	addi	a0,a0,-852 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02057c4:	a45fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc02057c8:	00003697          	auipc	a3,0x3
ffffffffc02057cc:	df868693          	addi	a3,a3,-520 # ffffffffc02085c0 <default_pmm_manager+0x250>
ffffffffc02057d0:	00001617          	auipc	a2,0x1
ffffffffc02057d4:	4f860613          	addi	a2,a2,1272 # ffffffffc0206cc8 <commands+0x410>
ffffffffc02057d8:	36800593          	li	a1,872
ffffffffc02057dc:	00003517          	auipc	a0,0x3
ffffffffc02057e0:	c8c50513          	addi	a0,a0,-884 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc02057e4:	a25fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02057e8 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057e8:	7171                	addi	sp,sp,-176
ffffffffc02057ea:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057ec:	000add97          	auipc	s11,0xad
ffffffffc02057f0:	00cd8d93          	addi	s11,s11,12 # ffffffffc02b27f8 <current>
ffffffffc02057f4:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057f8:	e54e                	sd	s3,136(sp)
ffffffffc02057fa:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057fc:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205800:	e94a                	sd	s2,144(sp)
ffffffffc0205802:	f4de                	sd	s7,104(sp)
ffffffffc0205804:	892a                	mv	s2,a0
ffffffffc0205806:	8bb2                	mv	s7,a2
ffffffffc0205808:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020580a:	862e                	mv	a2,a1
ffffffffc020580c:	4681                	li	a3,0
ffffffffc020580e:	85aa                	mv	a1,a0
ffffffffc0205810:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205812:	f506                	sd	ra,168(sp)
ffffffffc0205814:	f122                	sd	s0,160(sp)
ffffffffc0205816:	e152                	sd	s4,128(sp)
ffffffffc0205818:	fcd6                	sd	s5,120(sp)
ffffffffc020581a:	f8da                	sd	s6,112(sp)
ffffffffc020581c:	f0e2                	sd	s8,96(sp)
ffffffffc020581e:	ece6                	sd	s9,88(sp)
ffffffffc0205820:	e8ea                	sd	s10,80(sp)
ffffffffc0205822:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205824:	b3ffd0ef          	jal	ra,ffffffffc0203362 <user_mem_check>
ffffffffc0205828:	40050863          	beqz	a0,ffffffffc0205c38 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020582c:	4641                	li	a2,16
ffffffffc020582e:	4581                	li	a1,0
ffffffffc0205830:	1808                	addi	a0,sp,48
ffffffffc0205832:	1ab000ef          	jal	ra,ffffffffc02061dc <memset>
    memcpy(local_name, name, len);
ffffffffc0205836:	47bd                	li	a5,15
ffffffffc0205838:	8626                	mv	a2,s1
ffffffffc020583a:	1e97e063          	bltu	a5,s1,ffffffffc0205a1a <do_execve+0x232>
ffffffffc020583e:	85ca                	mv	a1,s2
ffffffffc0205840:	1808                	addi	a0,sp,48
ffffffffc0205842:	1ad000ef          	jal	ra,ffffffffc02061ee <memcpy>
    if (mm != NULL) {
ffffffffc0205846:	1e098163          	beqz	s3,ffffffffc0205a28 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc020584a:	00002517          	auipc	a0,0x2
ffffffffc020584e:	05650513          	addi	a0,a0,86 # ffffffffc02078a0 <commands+0xfe8>
ffffffffc0205852:	8b3fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc0205856:	000ad797          	auipc	a5,0xad
ffffffffc020585a:	f427b783          	ld	a5,-190(a5) # ffffffffc02b2798 <boot_cr3>
ffffffffc020585e:	577d                	li	a4,-1
ffffffffc0205860:	177e                	slli	a4,a4,0x3f
ffffffffc0205862:	83b1                	srli	a5,a5,0xc
ffffffffc0205864:	8fd9                	or	a5,a5,a4
ffffffffc0205866:	18079073          	csrw	satp,a5
ffffffffc020586a:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc020586e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205872:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205876:	2c070263          	beqz	a4,ffffffffc0205b3a <do_execve+0x352>
        current->mm = NULL;
ffffffffc020587a:	000db783          	ld	a5,0(s11)
ffffffffc020587e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205882:	904fd0ef          	jal	ra,ffffffffc0202986 <mm_create>
ffffffffc0205886:	84aa                	mv	s1,a0
ffffffffc0205888:	1c050b63          	beqz	a0,ffffffffc0205a5e <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020588c:	4505                	li	a0,1
ffffffffc020588e:	dccfb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0205892:	3a050763          	beqz	a0,ffffffffc0205c40 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205896:	000adc97          	auipc	s9,0xad
ffffffffc020589a:	f1ac8c93          	addi	s9,s9,-230 # ffffffffc02b27b0 <pages>
ffffffffc020589e:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02058a2:	000adc17          	auipc	s8,0xad
ffffffffc02058a6:	f06c0c13          	addi	s8,s8,-250 # ffffffffc02b27a8 <npage>
    return page - pages + nbase;
ffffffffc02058aa:	00003717          	auipc	a4,0x3
ffffffffc02058ae:	47673703          	ld	a4,1142(a4) # ffffffffc0208d20 <nbase>
ffffffffc02058b2:	40d506b3          	sub	a3,a0,a3
ffffffffc02058b6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058b8:	5afd                	li	s5,-1
ffffffffc02058ba:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02058be:	96ba                	add	a3,a3,a4
ffffffffc02058c0:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02058c2:	00cad713          	srli	a4,s5,0xc
ffffffffc02058c6:	ec3a                	sd	a4,24(sp)
ffffffffc02058c8:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02058ca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058cc:	36f77e63          	bgeu	a4,a5,ffffffffc0205c48 <do_execve+0x460>
ffffffffc02058d0:	000adb17          	auipc	s6,0xad
ffffffffc02058d4:	ef0b0b13          	addi	s6,s6,-272 # ffffffffc02b27c0 <va_pa_offset>
ffffffffc02058d8:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02058dc:	6605                	lui	a2,0x1
ffffffffc02058de:	000ad597          	auipc	a1,0xad
ffffffffc02058e2:	ec25b583          	ld	a1,-318(a1) # ffffffffc02b27a0 <boot_pgdir>
ffffffffc02058e6:	9936                	add	s2,s2,a3
ffffffffc02058e8:	854a                	mv	a0,s2
ffffffffc02058ea:	105000ef          	jal	ra,ffffffffc02061ee <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058ee:	7782                	ld	a5,32(sp)
ffffffffc02058f0:	4398                	lw	a4,0(a5)
ffffffffc02058f2:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02058f6:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058fa:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc02058fe:	14f71663          	bne	a4,a5,ffffffffc0205a4a <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205902:	7682                	ld	a3,32(sp)
ffffffffc0205904:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205908:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020590c:	00371793          	slli	a5,a4,0x3
ffffffffc0205910:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205912:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205914:	078e                	slli	a5,a5,0x3
ffffffffc0205916:	97ce                	add	a5,a5,s3
ffffffffc0205918:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020591a:	00f9fc63          	bgeu	s3,a5,ffffffffc0205932 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020591e:	0009a783          	lw	a5,0(s3)
ffffffffc0205922:	4705                	li	a4,1
ffffffffc0205924:	12e78f63          	beq	a5,a4,ffffffffc0205a62 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc0205928:	77a2                	ld	a5,40(sp)
ffffffffc020592a:	03898993          	addi	s3,s3,56
ffffffffc020592e:	fef9e8e3          	bltu	s3,a5,ffffffffc020591e <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205932:	4701                	li	a4,0
ffffffffc0205934:	46ad                	li	a3,11
ffffffffc0205936:	00100637          	lui	a2,0x100
ffffffffc020593a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020593e:	8526                	mv	a0,s1
ffffffffc0205940:	a1efd0ef          	jal	ra,ffffffffc0202b5e <mm_map>
ffffffffc0205944:	8a2a                	mv	s4,a0
ffffffffc0205946:	1e051063          	bnez	a0,ffffffffc0205b26 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020594a:	6c88                	ld	a0,24(s1)
ffffffffc020594c:	467d                	li	a2,31
ffffffffc020594e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205952:	b59fc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205956:	38050163          	beqz	a0,ffffffffc0205cd8 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020595a:	6c88                	ld	a0,24(s1)
ffffffffc020595c:	467d                	li	a2,31
ffffffffc020595e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205962:	b49fc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205966:	34050963          	beqz	a0,ffffffffc0205cb8 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020596a:	6c88                	ld	a0,24(s1)
ffffffffc020596c:	467d                	li	a2,31
ffffffffc020596e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205972:	b39fc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205976:	32050163          	beqz	a0,ffffffffc0205c98 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020597a:	6c88                	ld	a0,24(s1)
ffffffffc020597c:	467d                	li	a2,31
ffffffffc020597e:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205982:	b29fc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205986:	2e050963          	beqz	a0,ffffffffc0205c78 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc020598a:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020598c:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205990:	6c94                	ld	a3,24(s1)
ffffffffc0205992:	2785                	addiw	a5,a5,1
ffffffffc0205994:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205996:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205998:	c02007b7          	lui	a5,0xc0200
ffffffffc020599c:	2cf6e263          	bltu	a3,a5,ffffffffc0205c60 <do_execve+0x478>
ffffffffc02059a0:	000b3783          	ld	a5,0(s6)
ffffffffc02059a4:	577d                	li	a4,-1
ffffffffc02059a6:	177e                	slli	a4,a4,0x3f
ffffffffc02059a8:	8e9d                	sub	a3,a3,a5
ffffffffc02059aa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059ae:	f654                	sd	a3,168(a2)
ffffffffc02059b0:	8fd9                	or	a5,a5,a4
ffffffffc02059b2:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059b6:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059b8:	4581                	li	a1,0
ffffffffc02059ba:	12000613          	li	a2,288
ffffffffc02059be:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02059c0:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059c4:	019000ef          	jal	ra,ffffffffc02061dc <memset>
     tf->epc = elf->e_entry;
ffffffffc02059c8:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059ca:	000db483          	ld	s1,0(s11)
     tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059ce:	edf97913          	andi	s2,s2,-289
     tf->epc = elf->e_entry;
ffffffffc02059d2:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02059d4:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059d6:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc02059da:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059dc:	4641                	li	a2,16
ffffffffc02059de:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc02059e0:	e81c                	sd	a5,16(s0)
     tf->epc = elf->e_entry;
ffffffffc02059e2:	10e43423          	sd	a4,264(s0)
     tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059e6:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059ea:	8526                	mv	a0,s1
ffffffffc02059ec:	7f0000ef          	jal	ra,ffffffffc02061dc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02059f0:	463d                	li	a2,15
ffffffffc02059f2:	180c                	addi	a1,sp,48
ffffffffc02059f4:	8526                	mv	a0,s1
ffffffffc02059f6:	7f8000ef          	jal	ra,ffffffffc02061ee <memcpy>
}
ffffffffc02059fa:	70aa                	ld	ra,168(sp)
ffffffffc02059fc:	740a                	ld	s0,160(sp)
ffffffffc02059fe:	64ea                	ld	s1,152(sp)
ffffffffc0205a00:	694a                	ld	s2,144(sp)
ffffffffc0205a02:	69aa                	ld	s3,136(sp)
ffffffffc0205a04:	7ae6                	ld	s5,120(sp)
ffffffffc0205a06:	7b46                	ld	s6,112(sp)
ffffffffc0205a08:	7ba6                	ld	s7,104(sp)
ffffffffc0205a0a:	7c06                	ld	s8,96(sp)
ffffffffc0205a0c:	6ce6                	ld	s9,88(sp)
ffffffffc0205a0e:	6d46                	ld	s10,80(sp)
ffffffffc0205a10:	6da6                	ld	s11,72(sp)
ffffffffc0205a12:	8552                	mv	a0,s4
ffffffffc0205a14:	6a0a                	ld	s4,128(sp)
ffffffffc0205a16:	614d                	addi	sp,sp,176
ffffffffc0205a18:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205a1a:	463d                	li	a2,15
ffffffffc0205a1c:	85ca                	mv	a1,s2
ffffffffc0205a1e:	1808                	addi	a0,sp,48
ffffffffc0205a20:	7ce000ef          	jal	ra,ffffffffc02061ee <memcpy>
    if (mm != NULL) {
ffffffffc0205a24:	e20993e3          	bnez	s3,ffffffffc020584a <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205a28:	000db783          	ld	a5,0(s11)
ffffffffc0205a2c:	779c                	ld	a5,40(a5)
ffffffffc0205a2e:	e4078ae3          	beqz	a5,ffffffffc0205882 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a32:	00003617          	auipc	a2,0x3
ffffffffc0205a36:	c1e60613          	addi	a2,a2,-994 # ffffffffc0208650 <default_pmm_manager+0x2e0>
ffffffffc0205a3a:	21500593          	li	a1,533
ffffffffc0205a3e:	00003517          	auipc	a0,0x3
ffffffffc0205a42:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205a46:	fc2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205a4a:	8526                	mv	a0,s1
ffffffffc0205a4c:	c00ff0ef          	jal	ra,ffffffffc0204e4c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a50:	8526                	mv	a0,s1
ffffffffc0205a52:	8bafd0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a56:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205a58:	8552                	mv	a0,s4
ffffffffc0205a5a:	94fff0ef          	jal	ra,ffffffffc02053a8 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205a5e:	5a71                	li	s4,-4
ffffffffc0205a60:	bfe5                	j	ffffffffc0205a58 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a62:	0289b603          	ld	a2,40(s3)
ffffffffc0205a66:	0209b783          	ld	a5,32(s3)
ffffffffc0205a6a:	1cf66d63          	bltu	a2,a5,ffffffffc0205c44 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a6e:	0049a783          	lw	a5,4(s3)
ffffffffc0205a72:	0017f693          	andi	a3,a5,1
ffffffffc0205a76:	c291                	beqz	a3,ffffffffc0205a7a <do_execve+0x292>
ffffffffc0205a78:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a7a:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a7e:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a80:	e779                	bnez	a4,ffffffffc0205b4e <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a82:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a84:	c781                	beqz	a5,ffffffffc0205a8c <do_execve+0x2a4>
ffffffffc0205a86:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a8a:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a8c:	0026f793          	andi	a5,a3,2
ffffffffc0205a90:	e3f1                	bnez	a5,ffffffffc0205b54 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a92:	0046f793          	andi	a5,a3,4
ffffffffc0205a96:	c399                	beqz	a5,ffffffffc0205a9c <do_execve+0x2b4>
ffffffffc0205a98:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a9c:	0109b583          	ld	a1,16(s3)
ffffffffc0205aa0:	4701                	li	a4,0
ffffffffc0205aa2:	8526                	mv	a0,s1
ffffffffc0205aa4:	8bafd0ef          	jal	ra,ffffffffc0202b5e <mm_map>
ffffffffc0205aa8:	8a2a                	mv	s4,a0
ffffffffc0205aaa:	ed35                	bnez	a0,ffffffffc0205b26 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aac:	0109bb83          	ld	s7,16(s3)
ffffffffc0205ab0:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ab2:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ab6:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aba:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205abe:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ac0:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ac2:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205ac4:	054be963          	bltu	s7,s4,ffffffffc0205b16 <do_execve+0x32e>
ffffffffc0205ac8:	aa95                	j	ffffffffc0205c3c <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205aca:	6785                	lui	a5,0x1
ffffffffc0205acc:	415b8533          	sub	a0,s7,s5
ffffffffc0205ad0:	9abe                	add	s5,s5,a5
ffffffffc0205ad2:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205ad6:	015a7463          	bgeu	s4,s5,ffffffffc0205ade <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205ada:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205ade:	000cb683          	ld	a3,0(s9)
ffffffffc0205ae2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205ae4:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205ae8:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aec:	8699                	srai	a3,a3,0x6
ffffffffc0205aee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205af0:	67e2                	ld	a5,24(sp)
ffffffffc0205af2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205af6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205af8:	14b87863          	bgeu	a6,a1,ffffffffc0205c48 <do_execve+0x460>
ffffffffc0205afc:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b00:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205b02:	9bb2                	add	s7,s7,a2
ffffffffc0205b04:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b06:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b08:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b0a:	6e4000ef          	jal	ra,ffffffffc02061ee <memcpy>
            start += size, from += size;
ffffffffc0205b0e:	6622                	ld	a2,8(sp)
ffffffffc0205b10:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205b12:	054bf363          	bgeu	s7,s4,ffffffffc0205b58 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b16:	6c88                	ld	a0,24(s1)
ffffffffc0205b18:	866a                	mv	a2,s10
ffffffffc0205b1a:	85d6                	mv	a1,s5
ffffffffc0205b1c:	98ffc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205b20:	842a                	mv	s0,a0
ffffffffc0205b22:	f545                	bnez	a0,ffffffffc0205aca <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205b24:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205b26:	8526                	mv	a0,s1
ffffffffc0205b28:	980fd0ef          	jal	ra,ffffffffc0202ca8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b2c:	8526                	mv	a0,s1
ffffffffc0205b2e:	b1eff0ef          	jal	ra,ffffffffc0204e4c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b32:	8526                	mv	a0,s1
ffffffffc0205b34:	fd9fc0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
    return ret;
ffffffffc0205b38:	b705                	j	ffffffffc0205a58 <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205b3a:	854e                	mv	a0,s3
ffffffffc0205b3c:	96cfd0ef          	jal	ra,ffffffffc0202ca8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b40:	854e                	mv	a0,s3
ffffffffc0205b42:	b0aff0ef          	jal	ra,ffffffffc0204e4c <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b46:	854e                	mv	a0,s3
ffffffffc0205b48:	fc5fc0ef          	jal	ra,ffffffffc0202b0c <mm_destroy>
ffffffffc0205b4c:	b33d                	j	ffffffffc020587a <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b4e:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b52:	fb95                	bnez	a5,ffffffffc0205a86 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b54:	4d5d                	li	s10,23
ffffffffc0205b56:	bf35                	j	ffffffffc0205a92 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b58:	0109b683          	ld	a3,16(s3)
ffffffffc0205b5c:	0289b903          	ld	s2,40(s3)
ffffffffc0205b60:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205b62:	075bfd63          	bgeu	s7,s5,ffffffffc0205bdc <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205b66:	dd7901e3          	beq	s2,s7,ffffffffc0205928 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b6a:	6785                	lui	a5,0x1
ffffffffc0205b6c:	00fb8533          	add	a0,s7,a5
ffffffffc0205b70:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205b74:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205b78:	0b597d63          	bgeu	s2,s5,ffffffffc0205c32 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205b7c:	000cb683          	ld	a3,0(s9)
ffffffffc0205b80:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b82:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205b86:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b8a:	8699                	srai	a3,a3,0x6
ffffffffc0205b8c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b8e:	67e2                	ld	a5,24(sp)
ffffffffc0205b90:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b96:	0ac5f963          	bgeu	a1,a2,ffffffffc0205c48 <do_execve+0x460>
ffffffffc0205b9a:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b9e:	8652                	mv	a2,s4
ffffffffc0205ba0:	4581                	li	a1,0
ffffffffc0205ba2:	96c2                	add	a3,a3,a6
ffffffffc0205ba4:	9536                	add	a0,a0,a3
ffffffffc0205ba6:	636000ef          	jal	ra,ffffffffc02061dc <memset>
            start += size;
ffffffffc0205baa:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bae:	03597463          	bgeu	s2,s5,ffffffffc0205bd6 <do_execve+0x3ee>
ffffffffc0205bb2:	d6e90be3          	beq	s2,a4,ffffffffc0205928 <do_execve+0x140>
ffffffffc0205bb6:	00003697          	auipc	a3,0x3
ffffffffc0205bba:	ac268693          	addi	a3,a3,-1342 # ffffffffc0208678 <default_pmm_manager+0x308>
ffffffffc0205bbe:	00001617          	auipc	a2,0x1
ffffffffc0205bc2:	10a60613          	addi	a2,a2,266 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205bc6:	26a00593          	li	a1,618
ffffffffc0205bca:	00003517          	auipc	a0,0x3
ffffffffc0205bce:	89e50513          	addi	a0,a0,-1890 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205bd2:	e36fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205bd6:	ff5710e3          	bne	a4,s5,ffffffffc0205bb6 <do_execve+0x3ce>
ffffffffc0205bda:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205bdc:	d52bf6e3          	bgeu	s7,s2,ffffffffc0205928 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205be0:	6c88                	ld	a0,24(s1)
ffffffffc0205be2:	866a                	mv	a2,s10
ffffffffc0205be4:	85d6                	mv	a1,s5
ffffffffc0205be6:	8c5fc0ef          	jal	ra,ffffffffc02024aa <pgdir_alloc_page>
ffffffffc0205bea:	842a                	mv	s0,a0
ffffffffc0205bec:	dd05                	beqz	a0,ffffffffc0205b24 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bee:	6785                	lui	a5,0x1
ffffffffc0205bf0:	415b8533          	sub	a0,s7,s5
ffffffffc0205bf4:	9abe                	add	s5,s5,a5
ffffffffc0205bf6:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205bfa:	01597463          	bgeu	s2,s5,ffffffffc0205c02 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205bfe:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205c02:	000cb683          	ld	a3,0(s9)
ffffffffc0205c06:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c08:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c0c:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c10:	8699                	srai	a3,a3,0x6
ffffffffc0205c12:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c14:	67e2                	ld	a5,24(sp)
ffffffffc0205c16:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c1a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c1c:	02b87663          	bgeu	a6,a1,ffffffffc0205c48 <do_execve+0x460>
ffffffffc0205c20:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c24:	4581                	li	a1,0
            start += size;
ffffffffc0205c26:	9bb2                	add	s7,s7,a2
ffffffffc0205c28:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c2a:	9536                	add	a0,a0,a3
ffffffffc0205c2c:	5b0000ef          	jal	ra,ffffffffc02061dc <memset>
ffffffffc0205c30:	b775                	j	ffffffffc0205bdc <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c32:	417a8a33          	sub	s4,s5,s7
ffffffffc0205c36:	b799                	j	ffffffffc0205b7c <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205c38:	5a75                	li	s4,-3
ffffffffc0205c3a:	b3c1                	j	ffffffffc02059fa <do_execve+0x212>
        while (start < end) {
ffffffffc0205c3c:	86de                	mv	a3,s7
ffffffffc0205c3e:	bf39                	j	ffffffffc0205b5c <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205c40:	5a71                	li	s4,-4
ffffffffc0205c42:	bdc5                	j	ffffffffc0205b32 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205c44:	5a61                	li	s4,-8
ffffffffc0205c46:	b5c5                	j	ffffffffc0205b26 <do_execve+0x33e>
ffffffffc0205c48:	00001617          	auipc	a2,0x1
ffffffffc0205c4c:	3c860613          	addi	a2,a2,968 # ffffffffc0207010 <commands+0x758>
ffffffffc0205c50:	06900593          	li	a1,105
ffffffffc0205c54:	00001517          	auipc	a0,0x1
ffffffffc0205c58:	38450513          	addi	a0,a0,900 # ffffffffc0206fd8 <commands+0x720>
ffffffffc0205c5c:	dacfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c60:	00001617          	auipc	a2,0x1
ffffffffc0205c64:	48860613          	addi	a2,a2,1160 # ffffffffc02070e8 <commands+0x830>
ffffffffc0205c68:	28500593          	li	a1,645
ffffffffc0205c6c:	00002517          	auipc	a0,0x2
ffffffffc0205c70:	7fc50513          	addi	a0,a0,2044 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205c74:	d94fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c78:	00003697          	auipc	a3,0x3
ffffffffc0205c7c:	b1868693          	addi	a3,a3,-1256 # ffffffffc0208790 <default_pmm_manager+0x420>
ffffffffc0205c80:	00001617          	auipc	a2,0x1
ffffffffc0205c84:	04860613          	addi	a2,a2,72 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205c88:	28000593          	li	a1,640
ffffffffc0205c8c:	00002517          	auipc	a0,0x2
ffffffffc0205c90:	7dc50513          	addi	a0,a0,2012 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205c94:	d74fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c98:	00003697          	auipc	a3,0x3
ffffffffc0205c9c:	ab068693          	addi	a3,a3,-1360 # ffffffffc0208748 <default_pmm_manager+0x3d8>
ffffffffc0205ca0:	00001617          	auipc	a2,0x1
ffffffffc0205ca4:	02860613          	addi	a2,a2,40 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205ca8:	27f00593          	li	a1,639
ffffffffc0205cac:	00002517          	auipc	a0,0x2
ffffffffc0205cb0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205cb4:	d54fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cb8:	00003697          	auipc	a3,0x3
ffffffffc0205cbc:	a4868693          	addi	a3,a3,-1464 # ffffffffc0208700 <default_pmm_manager+0x390>
ffffffffc0205cc0:	00001617          	auipc	a2,0x1
ffffffffc0205cc4:	00860613          	addi	a2,a2,8 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205cc8:	27e00593          	li	a1,638
ffffffffc0205ccc:	00002517          	auipc	a0,0x2
ffffffffc0205cd0:	79c50513          	addi	a0,a0,1948 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205cd4:	d34fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cd8:	00003697          	auipc	a3,0x3
ffffffffc0205cdc:	9e068693          	addi	a3,a3,-1568 # ffffffffc02086b8 <default_pmm_manager+0x348>
ffffffffc0205ce0:	00001617          	auipc	a2,0x1
ffffffffc0205ce4:	fe860613          	addi	a2,a2,-24 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205ce8:	27d00593          	li	a1,637
ffffffffc0205cec:	00002517          	auipc	a0,0x2
ffffffffc0205cf0:	77c50513          	addi	a0,a0,1916 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205cf4:	d14fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205cf8 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cf8:	000ad797          	auipc	a5,0xad
ffffffffc0205cfc:	b007b783          	ld	a5,-1280(a5) # ffffffffc02b27f8 <current>
ffffffffc0205d00:	4705                	li	a4,1
ffffffffc0205d02:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d04:	4501                	li	a0,0
ffffffffc0205d06:	8082                	ret

ffffffffc0205d08 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d08:	1101                	addi	sp,sp,-32
ffffffffc0205d0a:	e822                	sd	s0,16(sp)
ffffffffc0205d0c:	e426                	sd	s1,8(sp)
ffffffffc0205d0e:	ec06                	sd	ra,24(sp)
ffffffffc0205d10:	842e                	mv	s0,a1
ffffffffc0205d12:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d14:	c999                	beqz	a1,ffffffffc0205d2a <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205d16:	000ad797          	auipc	a5,0xad
ffffffffc0205d1a:	ae27b783          	ld	a5,-1310(a5) # ffffffffc02b27f8 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d1e:	7788                	ld	a0,40(a5)
ffffffffc0205d20:	4685                	li	a3,1
ffffffffc0205d22:	4611                	li	a2,4
ffffffffc0205d24:	e3efd0ef          	jal	ra,ffffffffc0203362 <user_mem_check>
ffffffffc0205d28:	c909                	beqz	a0,ffffffffc0205d3a <do_wait+0x32>
ffffffffc0205d2a:	85a2                	mv	a1,s0
}
ffffffffc0205d2c:	6442                	ld	s0,16(sp)
ffffffffc0205d2e:	60e2                	ld	ra,24(sp)
ffffffffc0205d30:	8526                	mv	a0,s1
ffffffffc0205d32:	64a2                	ld	s1,8(sp)
ffffffffc0205d34:	6105                	addi	sp,sp,32
ffffffffc0205d36:	fbcff06f          	j	ffffffffc02054f2 <do_wait.part.0>
ffffffffc0205d3a:	60e2                	ld	ra,24(sp)
ffffffffc0205d3c:	6442                	ld	s0,16(sp)
ffffffffc0205d3e:	64a2                	ld	s1,8(sp)
ffffffffc0205d40:	5575                	li	a0,-3
ffffffffc0205d42:	6105                	addi	sp,sp,32
ffffffffc0205d44:	8082                	ret

ffffffffc0205d46 <do_kill>:
do_kill(int pid) {
ffffffffc0205d46:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d48:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205d4a:	e406                	sd	ra,8(sp)
ffffffffc0205d4c:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d4e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d52:	17f9                	addi	a5,a5,-2
ffffffffc0205d54:	02e7e963          	bltu	a5,a4,ffffffffc0205d86 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d58:	842a                	mv	s0,a0
ffffffffc0205d5a:	45a9                	li	a1,10
ffffffffc0205d5c:	2501                	sext.w	a0,a0
ffffffffc0205d5e:	097000ef          	jal	ra,ffffffffc02065f4 <hash32>
ffffffffc0205d62:	02051793          	slli	a5,a0,0x20
ffffffffc0205d66:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205d6a:	000a9797          	auipc	a5,0xa9
ffffffffc0205d6e:	a0678793          	addi	a5,a5,-1530 # ffffffffc02ae770 <hash_list>
ffffffffc0205d72:	953e                	add	a0,a0,a5
ffffffffc0205d74:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205d76:	a029                	j	ffffffffc0205d80 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205d78:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205d7c:	00870b63          	beq	a4,s0,ffffffffc0205d92 <do_kill+0x4c>
ffffffffc0205d80:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d82:	fef51be3          	bne	a0,a5,ffffffffc0205d78 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205d86:	5475                	li	s0,-3
}
ffffffffc0205d88:	60a2                	ld	ra,8(sp)
ffffffffc0205d8a:	8522                	mv	a0,s0
ffffffffc0205d8c:	6402                	ld	s0,0(sp)
ffffffffc0205d8e:	0141                	addi	sp,sp,16
ffffffffc0205d90:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d92:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205d96:	00177693          	andi	a3,a4,1
ffffffffc0205d9a:	e295                	bnez	a3,ffffffffc0205dbe <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d9c:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205d9e:	00176713          	ori	a4,a4,1
ffffffffc0205da2:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205da6:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205da8:	fe06d0e3          	bgez	a3,ffffffffc0205d88 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205dac:	f2878513          	addi	a0,a5,-216
ffffffffc0205db0:	1c4000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
}
ffffffffc0205db4:	60a2                	ld	ra,8(sp)
ffffffffc0205db6:	8522                	mv	a0,s0
ffffffffc0205db8:	6402                	ld	s0,0(sp)
ffffffffc0205dba:	0141                	addi	sp,sp,16
ffffffffc0205dbc:	8082                	ret
        return -E_KILLED;
ffffffffc0205dbe:	545d                	li	s0,-9
ffffffffc0205dc0:	b7e1                	j	ffffffffc0205d88 <do_kill+0x42>

ffffffffc0205dc2 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dc2:	1101                	addi	sp,sp,-32
ffffffffc0205dc4:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205dc6:	000ad797          	auipc	a5,0xad
ffffffffc0205dca:	9aa78793          	addi	a5,a5,-1622 # ffffffffc02b2770 <proc_list>
ffffffffc0205dce:	ec06                	sd	ra,24(sp)
ffffffffc0205dd0:	e822                	sd	s0,16(sp)
ffffffffc0205dd2:	e04a                	sd	s2,0(sp)
ffffffffc0205dd4:	000a9497          	auipc	s1,0xa9
ffffffffc0205dd8:	99c48493          	addi	s1,s1,-1636 # ffffffffc02ae770 <hash_list>
ffffffffc0205ddc:	e79c                	sd	a5,8(a5)
ffffffffc0205dde:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205de0:	000ad717          	auipc	a4,0xad
ffffffffc0205de4:	99070713          	addi	a4,a4,-1648 # ffffffffc02b2770 <proc_list>
ffffffffc0205de8:	87a6                	mv	a5,s1
ffffffffc0205dea:	e79c                	sd	a5,8(a5)
ffffffffc0205dec:	e39c                	sd	a5,0(a5)
ffffffffc0205dee:	07c1                	addi	a5,a5,16
ffffffffc0205df0:	fef71de3          	bne	a4,a5,ffffffffc0205dea <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205df4:	f5bfe0ef          	jal	ra,ffffffffc0204d4e <alloc_proc>
ffffffffc0205df8:	000ad917          	auipc	s2,0xad
ffffffffc0205dfc:	a0890913          	addi	s2,s2,-1528 # ffffffffc02b2800 <idleproc>
ffffffffc0205e00:	00a93023          	sd	a0,0(s2)
ffffffffc0205e04:	0e050f63          	beqz	a0,ffffffffc0205f02 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e08:	4789                	li	a5,2
ffffffffc0205e0a:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e0c:	00003797          	auipc	a5,0x3
ffffffffc0205e10:	1f478793          	addi	a5,a5,500 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e14:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e18:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e1a:	4785                	li	a5,1
ffffffffc0205e1c:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e1e:	4641                	li	a2,16
ffffffffc0205e20:	4581                	li	a1,0
ffffffffc0205e22:	8522                	mv	a0,s0
ffffffffc0205e24:	3b8000ef          	jal	ra,ffffffffc02061dc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e28:	463d                	li	a2,15
ffffffffc0205e2a:	00003597          	auipc	a1,0x3
ffffffffc0205e2e:	9c658593          	addi	a1,a1,-1594 # ffffffffc02087f0 <default_pmm_manager+0x480>
ffffffffc0205e32:	8522                	mv	a0,s0
ffffffffc0205e34:	3ba000ef          	jal	ra,ffffffffc02061ee <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205e38:	000ad717          	auipc	a4,0xad
ffffffffc0205e3c:	9d870713          	addi	a4,a4,-1576 # ffffffffc02b2810 <nr_process>
ffffffffc0205e40:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205e42:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e46:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e48:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e4a:	4581                	li	a1,0
ffffffffc0205e4c:	00000517          	auipc	a0,0x0
ffffffffc0205e50:	87850513          	addi	a0,a0,-1928 # ffffffffc02056c4 <init_main>
    nr_process ++;
ffffffffc0205e54:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205e56:	000ad797          	auipc	a5,0xad
ffffffffc0205e5a:	9ad7b123          	sd	a3,-1630(a5) # ffffffffc02b27f8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e5e:	cfaff0ef          	jal	ra,ffffffffc0205358 <kernel_thread>
ffffffffc0205e62:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205e64:	08a05363          	blez	a0,ffffffffc0205eea <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e68:	6789                	lui	a5,0x2
ffffffffc0205e6a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e6e:	17f9                	addi	a5,a5,-2
ffffffffc0205e70:	2501                	sext.w	a0,a0
ffffffffc0205e72:	02e7e363          	bltu	a5,a4,ffffffffc0205e98 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e76:	45a9                	li	a1,10
ffffffffc0205e78:	77c000ef          	jal	ra,ffffffffc02065f4 <hash32>
ffffffffc0205e7c:	02051793          	slli	a5,a0,0x20
ffffffffc0205e80:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205e84:	96a6                	add	a3,a3,s1
ffffffffc0205e86:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205e88:	a029                	j	ffffffffc0205e92 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205e8a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205e8e:	04870b63          	beq	a4,s0,ffffffffc0205ee4 <proc_init+0x122>
    return listelm->next;
ffffffffc0205e92:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e94:	fef69be3          	bne	a3,a5,ffffffffc0205e8a <proc_init+0xc8>
    return NULL;
ffffffffc0205e98:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e9a:	0b478493          	addi	s1,a5,180
ffffffffc0205e9e:	4641                	li	a2,16
ffffffffc0205ea0:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ea2:	000ad417          	auipc	s0,0xad
ffffffffc0205ea6:	96640413          	addi	s0,s0,-1690 # ffffffffc02b2808 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205eaa:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205eac:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205eae:	32e000ef          	jal	ra,ffffffffc02061dc <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205eb2:	463d                	li	a2,15
ffffffffc0205eb4:	00003597          	auipc	a1,0x3
ffffffffc0205eb8:	96458593          	addi	a1,a1,-1692 # ffffffffc0208818 <default_pmm_manager+0x4a8>
ffffffffc0205ebc:	8526                	mv	a0,s1
ffffffffc0205ebe:	330000ef          	jal	ra,ffffffffc02061ee <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ec2:	00093783          	ld	a5,0(s2)
ffffffffc0205ec6:	cbb5                	beqz	a5,ffffffffc0205f3a <proc_init+0x178>
ffffffffc0205ec8:	43dc                	lw	a5,4(a5)
ffffffffc0205eca:	eba5                	bnez	a5,ffffffffc0205f3a <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ecc:	601c                	ld	a5,0(s0)
ffffffffc0205ece:	c7b1                	beqz	a5,ffffffffc0205f1a <proc_init+0x158>
ffffffffc0205ed0:	43d8                	lw	a4,4(a5)
ffffffffc0205ed2:	4785                	li	a5,1
ffffffffc0205ed4:	04f71363          	bne	a4,a5,ffffffffc0205f1a <proc_init+0x158>
}
ffffffffc0205ed8:	60e2                	ld	ra,24(sp)
ffffffffc0205eda:	6442                	ld	s0,16(sp)
ffffffffc0205edc:	64a2                	ld	s1,8(sp)
ffffffffc0205ede:	6902                	ld	s2,0(sp)
ffffffffc0205ee0:	6105                	addi	sp,sp,32
ffffffffc0205ee2:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205ee4:	f2878793          	addi	a5,a5,-216
ffffffffc0205ee8:	bf4d                	j	ffffffffc0205e9a <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205eea:	00003617          	auipc	a2,0x3
ffffffffc0205eee:	90e60613          	addi	a2,a2,-1778 # ffffffffc02087f8 <default_pmm_manager+0x488>
ffffffffc0205ef2:	38a00593          	li	a1,906
ffffffffc0205ef6:	00002517          	auipc	a0,0x2
ffffffffc0205efa:	57250513          	addi	a0,a0,1394 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205efe:	b0afa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205f02:	00003617          	auipc	a2,0x3
ffffffffc0205f06:	8d660613          	addi	a2,a2,-1834 # ffffffffc02087d8 <default_pmm_manager+0x468>
ffffffffc0205f0a:	37c00593          	li	a1,892
ffffffffc0205f0e:	00002517          	auipc	a0,0x2
ffffffffc0205f12:	55a50513          	addi	a0,a0,1370 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205f16:	af2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f1a:	00003697          	auipc	a3,0x3
ffffffffc0205f1e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0208848 <default_pmm_manager+0x4d8>
ffffffffc0205f22:	00001617          	auipc	a2,0x1
ffffffffc0205f26:	da660613          	addi	a2,a2,-602 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205f2a:	39100593          	li	a1,913
ffffffffc0205f2e:	00002517          	auipc	a0,0x2
ffffffffc0205f32:	53a50513          	addi	a0,a0,1338 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205f36:	ad2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f3a:	00003697          	auipc	a3,0x3
ffffffffc0205f3e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0208820 <default_pmm_manager+0x4b0>
ffffffffc0205f42:	00001617          	auipc	a2,0x1
ffffffffc0205f46:	d8660613          	addi	a2,a2,-634 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205f4a:	39000593          	li	a1,912
ffffffffc0205f4e:	00002517          	auipc	a0,0x2
ffffffffc0205f52:	51a50513          	addi	a0,a0,1306 # ffffffffc0208468 <default_pmm_manager+0xf8>
ffffffffc0205f56:	ab2fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f5a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f5a:	1141                	addi	sp,sp,-16
ffffffffc0205f5c:	e022                	sd	s0,0(sp)
ffffffffc0205f5e:	e406                	sd	ra,8(sp)
ffffffffc0205f60:	000ad417          	auipc	s0,0xad
ffffffffc0205f64:	89840413          	addi	s0,s0,-1896 # ffffffffc02b27f8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f68:	6018                	ld	a4,0(s0)
ffffffffc0205f6a:	6f1c                	ld	a5,24(a4)
ffffffffc0205f6c:	dffd                	beqz	a5,ffffffffc0205f6a <cpu_idle+0x10>
            schedule();
ffffffffc0205f6e:	086000ef          	jal	ra,ffffffffc0205ff4 <schedule>
ffffffffc0205f72:	bfdd                	j	ffffffffc0205f68 <cpu_idle+0xe>

ffffffffc0205f74 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f74:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f76:	1101                	addi	sp,sp,-32
ffffffffc0205f78:	ec06                	sd	ra,24(sp)
ffffffffc0205f7a:	e822                	sd	s0,16(sp)
ffffffffc0205f7c:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f7e:	478d                	li	a5,3
ffffffffc0205f80:	04f70b63          	beq	a4,a5,ffffffffc0205fd6 <wakeup_proc+0x62>
ffffffffc0205f84:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f86:	100027f3          	csrr	a5,sstatus
ffffffffc0205f8a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f8c:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f8e:	ef9d                	bnez	a5,ffffffffc0205fcc <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f90:	4789                	li	a5,2
ffffffffc0205f92:	02f70163          	beq	a4,a5,ffffffffc0205fb4 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f96:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205f98:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205f9c:	e491                	bnez	s1,ffffffffc0205fa8 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f9e:	60e2                	ld	ra,24(sp)
ffffffffc0205fa0:	6442                	ld	s0,16(sp)
ffffffffc0205fa2:	64a2                	ld	s1,8(sp)
ffffffffc0205fa4:	6105                	addi	sp,sp,32
ffffffffc0205fa6:	8082                	ret
ffffffffc0205fa8:	6442                	ld	s0,16(sp)
ffffffffc0205faa:	60e2                	ld	ra,24(sp)
ffffffffc0205fac:	64a2                	ld	s1,8(sp)
ffffffffc0205fae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205fb0:	e92fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fb4:	00003617          	auipc	a2,0x3
ffffffffc0205fb8:	8f460613          	addi	a2,a2,-1804 # ffffffffc02088a8 <default_pmm_manager+0x538>
ffffffffc0205fbc:	45c9                	li	a1,18
ffffffffc0205fbe:	00003517          	auipc	a0,0x3
ffffffffc0205fc2:	8d250513          	addi	a0,a0,-1838 # ffffffffc0208890 <default_pmm_manager+0x520>
ffffffffc0205fc6:	aaafa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205fca:	bfc9                	j	ffffffffc0205f9c <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205fcc:	e7cfa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205fd0:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205fd2:	4485                	li	s1,1
ffffffffc0205fd4:	bf75                	j	ffffffffc0205f90 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fd6:	00003697          	auipc	a3,0x3
ffffffffc0205fda:	89a68693          	addi	a3,a3,-1894 # ffffffffc0208870 <default_pmm_manager+0x500>
ffffffffc0205fde:	00001617          	auipc	a2,0x1
ffffffffc0205fe2:	cea60613          	addi	a2,a2,-790 # ffffffffc0206cc8 <commands+0x410>
ffffffffc0205fe6:	45a5                	li	a1,9
ffffffffc0205fe8:	00003517          	auipc	a0,0x3
ffffffffc0205fec:	8a850513          	addi	a0,a0,-1880 # ffffffffc0208890 <default_pmm_manager+0x520>
ffffffffc0205ff0:	a18fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205ff4 <schedule>:

void
schedule(void) {
ffffffffc0205ff4:	1141                	addi	sp,sp,-16
ffffffffc0205ff6:	e406                	sd	ra,8(sp)
ffffffffc0205ff8:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0205ffe:	8b89                	andi	a5,a5,2
ffffffffc0206000:	4401                	li	s0,0
ffffffffc0206002:	efbd                	bnez	a5,ffffffffc0206080 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206004:	000ac897          	auipc	a7,0xac
ffffffffc0206008:	7f48b883          	ld	a7,2036(a7) # ffffffffc02b27f8 <current>
ffffffffc020600c:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206010:	000ac517          	auipc	a0,0xac
ffffffffc0206014:	7f053503          	ld	a0,2032(a0) # ffffffffc02b2800 <idleproc>
ffffffffc0206018:	04a88e63          	beq	a7,a0,ffffffffc0206074 <schedule+0x80>
ffffffffc020601c:	0c888693          	addi	a3,a7,200
ffffffffc0206020:	000ac617          	auipc	a2,0xac
ffffffffc0206024:	75060613          	addi	a2,a2,1872 # ffffffffc02b2770 <proc_list>
        le = last;
ffffffffc0206028:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020602a:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020602c:	4809                	li	a6,2
ffffffffc020602e:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206030:	00c78863          	beq	a5,a2,ffffffffc0206040 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206034:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206038:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020603c:	03070163          	beq	a4,a6,ffffffffc020605e <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206040:	fef697e3          	bne	a3,a5,ffffffffc020602e <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206044:	ed89                	bnez	a1,ffffffffc020605e <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206046:	451c                	lw	a5,8(a0)
ffffffffc0206048:	2785                	addiw	a5,a5,1
ffffffffc020604a:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020604c:	00a88463          	beq	a7,a0,ffffffffc0206054 <schedule+0x60>
            proc_run(next);
ffffffffc0206050:	e73fe0ef          	jal	ra,ffffffffc0204ec2 <proc_run>
    if (flag) {
ffffffffc0206054:	e819                	bnez	s0,ffffffffc020606a <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206056:	60a2                	ld	ra,8(sp)
ffffffffc0206058:	6402                	ld	s0,0(sp)
ffffffffc020605a:	0141                	addi	sp,sp,16
ffffffffc020605c:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020605e:	4198                	lw	a4,0(a1)
ffffffffc0206060:	4789                	li	a5,2
ffffffffc0206062:	fef712e3          	bne	a4,a5,ffffffffc0206046 <schedule+0x52>
ffffffffc0206066:	852e                	mv	a0,a1
ffffffffc0206068:	bff9                	j	ffffffffc0206046 <schedule+0x52>
}
ffffffffc020606a:	6402                	ld	s0,0(sp)
ffffffffc020606c:	60a2                	ld	ra,8(sp)
ffffffffc020606e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206070:	dd2fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206074:	000ac617          	auipc	a2,0xac
ffffffffc0206078:	6fc60613          	addi	a2,a2,1788 # ffffffffc02b2770 <proc_list>
ffffffffc020607c:	86b2                	mv	a3,a2
ffffffffc020607e:	b76d                	j	ffffffffc0206028 <schedule+0x34>
        intr_disable();
ffffffffc0206080:	dc8fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0206084:	4405                	li	s0,1
ffffffffc0206086:	bfbd                	j	ffffffffc0206004 <schedule+0x10>

ffffffffc0206088 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206088:	000ac797          	auipc	a5,0xac
ffffffffc020608c:	7707b783          	ld	a5,1904(a5) # ffffffffc02b27f8 <current>
}
ffffffffc0206090:	43c8                	lw	a0,4(a5)
ffffffffc0206092:	8082                	ret

ffffffffc0206094 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206094:	4501                	li	a0,0
ffffffffc0206096:	8082                	ret

ffffffffc0206098 <sys_putc>:
    cputchar(c);
ffffffffc0206098:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020609a:	1141                	addi	sp,sp,-16
ffffffffc020609c:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020609e:	864fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc02060a2:	60a2                	ld	ra,8(sp)
ffffffffc02060a4:	4501                	li	a0,0
ffffffffc02060a6:	0141                	addi	sp,sp,16
ffffffffc02060a8:	8082                	ret

ffffffffc02060aa <sys_kill>:
    return do_kill(pid);
ffffffffc02060aa:	4108                	lw	a0,0(a0)
ffffffffc02060ac:	c9bff06f          	j	ffffffffc0205d46 <do_kill>

ffffffffc02060b0 <sys_yield>:
    return do_yield();
ffffffffc02060b0:	c49ff06f          	j	ffffffffc0205cf8 <do_yield>

ffffffffc02060b4 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060b4:	6d14                	ld	a3,24(a0)
ffffffffc02060b6:	6910                	ld	a2,16(a0)
ffffffffc02060b8:	650c                	ld	a1,8(a0)
ffffffffc02060ba:	6108                	ld	a0,0(a0)
ffffffffc02060bc:	f2cff06f          	j	ffffffffc02057e8 <do_execve>

ffffffffc02060c0 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060c0:	650c                	ld	a1,8(a0)
ffffffffc02060c2:	4108                	lw	a0,0(a0)
ffffffffc02060c4:	c45ff06f          	j	ffffffffc0205d08 <do_wait>

ffffffffc02060c8 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060c8:	000ac797          	auipc	a5,0xac
ffffffffc02060cc:	7307b783          	ld	a5,1840(a5) # ffffffffc02b27f8 <current>
ffffffffc02060d0:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060d2:	4501                	li	a0,0
ffffffffc02060d4:	6a0c                	ld	a1,16(a2)
ffffffffc02060d6:	e59fe06f          	j	ffffffffc0204f2e <do_fork>

ffffffffc02060da <sys_exit>:
    return do_exit(error_code);
ffffffffc02060da:	4108                	lw	a0,0(a0)
ffffffffc02060dc:	accff06f          	j	ffffffffc02053a8 <do_exit>

ffffffffc02060e0 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060e0:	715d                	addi	sp,sp,-80
ffffffffc02060e2:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060e4:	000ac497          	auipc	s1,0xac
ffffffffc02060e8:	71448493          	addi	s1,s1,1812 # ffffffffc02b27f8 <current>
ffffffffc02060ec:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060ee:	e0a2                	sd	s0,64(sp)
ffffffffc02060f0:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060f2:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060f4:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060f6:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060f8:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060fc:	0327ee63          	bltu	a5,s2,ffffffffc0206138 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206100:	00391713          	slli	a4,s2,0x3
ffffffffc0206104:	00003797          	auipc	a5,0x3
ffffffffc0206108:	80c78793          	addi	a5,a5,-2036 # ffffffffc0208910 <syscalls>
ffffffffc020610c:	97ba                	add	a5,a5,a4
ffffffffc020610e:	639c                	ld	a5,0(a5)
ffffffffc0206110:	c785                	beqz	a5,ffffffffc0206138 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206112:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206114:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206116:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206118:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020611a:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020611c:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020611e:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206120:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206122:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206124:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206126:	0028                	addi	a0,sp,8
ffffffffc0206128:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020612a:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020612c:	e828                	sd	a0,80(s0)
}
ffffffffc020612e:	6406                	ld	s0,64(sp)
ffffffffc0206130:	74e2                	ld	s1,56(sp)
ffffffffc0206132:	7942                	ld	s2,48(sp)
ffffffffc0206134:	6161                	addi	sp,sp,80
ffffffffc0206136:	8082                	ret
    print_trapframe(tf);
ffffffffc0206138:	8522                	mv	a0,s0
ffffffffc020613a:	efcfa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020613e:	609c                	ld	a5,0(s1)
ffffffffc0206140:	86ca                	mv	a3,s2
ffffffffc0206142:	00002617          	auipc	a2,0x2
ffffffffc0206146:	78660613          	addi	a2,a2,1926 # ffffffffc02088c8 <default_pmm_manager+0x558>
ffffffffc020614a:	43d8                	lw	a4,4(a5)
ffffffffc020614c:	06200593          	li	a1,98
ffffffffc0206150:	0b478793          	addi	a5,a5,180
ffffffffc0206154:	00002517          	auipc	a0,0x2
ffffffffc0206158:	7a450513          	addi	a0,a0,1956 # ffffffffc02088f8 <default_pmm_manager+0x588>
ffffffffc020615c:	8acfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0206160 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206160:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206164:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206166:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206168:	cb81                	beqz	a5,ffffffffc0206178 <strlen+0x18>
        cnt ++;
ffffffffc020616a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020616c:	00a707b3          	add	a5,a4,a0
ffffffffc0206170:	0007c783          	lbu	a5,0(a5)
ffffffffc0206174:	fbfd                	bnez	a5,ffffffffc020616a <strlen+0xa>
ffffffffc0206176:	8082                	ret
    }
    return cnt;
}
ffffffffc0206178:	8082                	ret

ffffffffc020617a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020617a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020617c:	e589                	bnez	a1,ffffffffc0206186 <strnlen+0xc>
ffffffffc020617e:	a811                	j	ffffffffc0206192 <strnlen+0x18>
        cnt ++;
ffffffffc0206180:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206182:	00f58863          	beq	a1,a5,ffffffffc0206192 <strnlen+0x18>
ffffffffc0206186:	00f50733          	add	a4,a0,a5
ffffffffc020618a:	00074703          	lbu	a4,0(a4)
ffffffffc020618e:	fb6d                	bnez	a4,ffffffffc0206180 <strnlen+0x6>
ffffffffc0206190:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206192:	852e                	mv	a0,a1
ffffffffc0206194:	8082                	ret

ffffffffc0206196 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206196:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206198:	0005c703          	lbu	a4,0(a1)
ffffffffc020619c:	0785                	addi	a5,a5,1
ffffffffc020619e:	0585                	addi	a1,a1,1
ffffffffc02061a0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02061a4:	fb75                	bnez	a4,ffffffffc0206198 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02061a6:	8082                	ret

ffffffffc02061a8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061a8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061ac:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061b0:	cb89                	beqz	a5,ffffffffc02061c2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02061b2:	0505                	addi	a0,a0,1
ffffffffc02061b4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061b6:	fee789e3          	beq	a5,a4,ffffffffc02061a8 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061ba:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02061be:	9d19                	subw	a0,a0,a4
ffffffffc02061c0:	8082                	ret
ffffffffc02061c2:	4501                	li	a0,0
ffffffffc02061c4:	bfed                	j	ffffffffc02061be <strcmp+0x16>

ffffffffc02061c6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061c6:	00054783          	lbu	a5,0(a0)
ffffffffc02061ca:	c799                	beqz	a5,ffffffffc02061d8 <strchr+0x12>
        if (*s == c) {
ffffffffc02061cc:	00f58763          	beq	a1,a5,ffffffffc02061da <strchr+0x14>
    while (*s != '\0') {
ffffffffc02061d0:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02061d4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061d6:	fbfd                	bnez	a5,ffffffffc02061cc <strchr+0x6>
    }
    return NULL;
ffffffffc02061d8:	4501                	li	a0,0
}
ffffffffc02061da:	8082                	ret

ffffffffc02061dc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061dc:	ca01                	beqz	a2,ffffffffc02061ec <memset+0x10>
ffffffffc02061de:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061e0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061e2:	0785                	addi	a5,a5,1
ffffffffc02061e4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061e8:	fec79de3          	bne	a5,a2,ffffffffc02061e2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061ec:	8082                	ret

ffffffffc02061ee <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061ee:	ca19                	beqz	a2,ffffffffc0206204 <memcpy+0x16>
ffffffffc02061f0:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061f2:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061f4:	0005c703          	lbu	a4,0(a1)
ffffffffc02061f8:	0585                	addi	a1,a1,1
ffffffffc02061fa:	0785                	addi	a5,a5,1
ffffffffc02061fc:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206200:	fec59ae3          	bne	a1,a2,ffffffffc02061f4 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206204:	8082                	ret

ffffffffc0206206 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206206:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020620a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020620c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206210:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206212:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206216:	f022                	sd	s0,32(sp)
ffffffffc0206218:	ec26                	sd	s1,24(sp)
ffffffffc020621a:	e84a                	sd	s2,16(sp)
ffffffffc020621c:	f406                	sd	ra,40(sp)
ffffffffc020621e:	e44e                	sd	s3,8(sp)
ffffffffc0206220:	84aa                	mv	s1,a0
ffffffffc0206222:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206224:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206228:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020622a:	03067e63          	bgeu	a2,a6,ffffffffc0206266 <printnum+0x60>
ffffffffc020622e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206230:	00805763          	blez	s0,ffffffffc020623e <printnum+0x38>
ffffffffc0206234:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206236:	85ca                	mv	a1,s2
ffffffffc0206238:	854e                	mv	a0,s3
ffffffffc020623a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020623c:	fc65                	bnez	s0,ffffffffc0206234 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020623e:	1a02                	slli	s4,s4,0x20
ffffffffc0206240:	00002797          	auipc	a5,0x2
ffffffffc0206244:	7d078793          	addi	a5,a5,2000 # ffffffffc0208a10 <syscalls+0x100>
ffffffffc0206248:	020a5a13          	srli	s4,s4,0x20
ffffffffc020624c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020624e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206250:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206254:	70a2                	ld	ra,40(sp)
ffffffffc0206256:	69a2                	ld	s3,8(sp)
ffffffffc0206258:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020625a:	85ca                	mv	a1,s2
ffffffffc020625c:	87a6                	mv	a5,s1
}
ffffffffc020625e:	6942                	ld	s2,16(sp)
ffffffffc0206260:	64e2                	ld	s1,24(sp)
ffffffffc0206262:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206264:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206266:	03065633          	divu	a2,a2,a6
ffffffffc020626a:	8722                	mv	a4,s0
ffffffffc020626c:	f9bff0ef          	jal	ra,ffffffffc0206206 <printnum>
ffffffffc0206270:	b7f9                	j	ffffffffc020623e <printnum+0x38>

ffffffffc0206272 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206272:	7119                	addi	sp,sp,-128
ffffffffc0206274:	f4a6                	sd	s1,104(sp)
ffffffffc0206276:	f0ca                	sd	s2,96(sp)
ffffffffc0206278:	ecce                	sd	s3,88(sp)
ffffffffc020627a:	e8d2                	sd	s4,80(sp)
ffffffffc020627c:	e4d6                	sd	s5,72(sp)
ffffffffc020627e:	e0da                	sd	s6,64(sp)
ffffffffc0206280:	fc5e                	sd	s7,56(sp)
ffffffffc0206282:	f06a                	sd	s10,32(sp)
ffffffffc0206284:	fc86                	sd	ra,120(sp)
ffffffffc0206286:	f8a2                	sd	s0,112(sp)
ffffffffc0206288:	f862                	sd	s8,48(sp)
ffffffffc020628a:	f466                	sd	s9,40(sp)
ffffffffc020628c:	ec6e                	sd	s11,24(sp)
ffffffffc020628e:	892a                	mv	s2,a0
ffffffffc0206290:	84ae                	mv	s1,a1
ffffffffc0206292:	8d32                	mv	s10,a2
ffffffffc0206294:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206296:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020629a:	5b7d                	li	s6,-1
ffffffffc020629c:	00002a97          	auipc	s5,0x2
ffffffffc02062a0:	7a0a8a93          	addi	s5,s5,1952 # ffffffffc0208a3c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062a4:	00003b97          	auipc	s7,0x3
ffffffffc02062a8:	9b4b8b93          	addi	s7,s7,-1612 # ffffffffc0208c58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ac:	000d4503          	lbu	a0,0(s10)
ffffffffc02062b0:	001d0413          	addi	s0,s10,1
ffffffffc02062b4:	01350a63          	beq	a0,s3,ffffffffc02062c8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02062b8:	c121                	beqz	a0,ffffffffc02062f8 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02062ba:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062bc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062be:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062c0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062c4:	ff351ae3          	bne	a0,s3,ffffffffc02062b8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062c8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062cc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062d0:	4c81                	li	s9,0
ffffffffc02062d2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02062d4:	5c7d                	li	s8,-1
ffffffffc02062d6:	5dfd                	li	s11,-1
ffffffffc02062d8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02062dc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062de:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062e2:	0ff5f593          	zext.b	a1,a1
ffffffffc02062e6:	00140d13          	addi	s10,s0,1
ffffffffc02062ea:	04b56263          	bltu	a0,a1,ffffffffc020632e <vprintfmt+0xbc>
ffffffffc02062ee:	058a                	slli	a1,a1,0x2
ffffffffc02062f0:	95d6                	add	a1,a1,s5
ffffffffc02062f2:	4194                	lw	a3,0(a1)
ffffffffc02062f4:	96d6                	add	a3,a3,s5
ffffffffc02062f6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062f8:	70e6                	ld	ra,120(sp)
ffffffffc02062fa:	7446                	ld	s0,112(sp)
ffffffffc02062fc:	74a6                	ld	s1,104(sp)
ffffffffc02062fe:	7906                	ld	s2,96(sp)
ffffffffc0206300:	69e6                	ld	s3,88(sp)
ffffffffc0206302:	6a46                	ld	s4,80(sp)
ffffffffc0206304:	6aa6                	ld	s5,72(sp)
ffffffffc0206306:	6b06                	ld	s6,64(sp)
ffffffffc0206308:	7be2                	ld	s7,56(sp)
ffffffffc020630a:	7c42                	ld	s8,48(sp)
ffffffffc020630c:	7ca2                	ld	s9,40(sp)
ffffffffc020630e:	7d02                	ld	s10,32(sp)
ffffffffc0206310:	6de2                	ld	s11,24(sp)
ffffffffc0206312:	6109                	addi	sp,sp,128
ffffffffc0206314:	8082                	ret
            padc = '0';
ffffffffc0206316:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206318:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020631c:	846a                	mv	s0,s10
ffffffffc020631e:	00140d13          	addi	s10,s0,1
ffffffffc0206322:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206326:	0ff5f593          	zext.b	a1,a1
ffffffffc020632a:	fcb572e3          	bgeu	a0,a1,ffffffffc02062ee <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020632e:	85a6                	mv	a1,s1
ffffffffc0206330:	02500513          	li	a0,37
ffffffffc0206334:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206336:	fff44783          	lbu	a5,-1(s0)
ffffffffc020633a:	8d22                	mv	s10,s0
ffffffffc020633c:	f73788e3          	beq	a5,s3,ffffffffc02062ac <vprintfmt+0x3a>
ffffffffc0206340:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206344:	1d7d                	addi	s10,s10,-1
ffffffffc0206346:	ff379de3          	bne	a5,s3,ffffffffc0206340 <vprintfmt+0xce>
ffffffffc020634a:	b78d                	j	ffffffffc02062ac <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020634c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0206350:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206354:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206356:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020635a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020635e:	02d86463          	bltu	a6,a3,ffffffffc0206386 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206362:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206366:	002c169b          	slliw	a3,s8,0x2
ffffffffc020636a:	0186873b          	addw	a4,a3,s8
ffffffffc020636e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206372:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206374:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206378:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020637a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020637e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206382:	fed870e3          	bgeu	a6,a3,ffffffffc0206362 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206386:	f40ddce3          	bgez	s11,ffffffffc02062de <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020638a:	8de2                	mv	s11,s8
ffffffffc020638c:	5c7d                	li	s8,-1
ffffffffc020638e:	bf81                	j	ffffffffc02062de <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206390:	fffdc693          	not	a3,s11
ffffffffc0206394:	96fd                	srai	a3,a3,0x3f
ffffffffc0206396:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020639a:	00144603          	lbu	a2,1(s0)
ffffffffc020639e:	2d81                	sext.w	s11,s11
ffffffffc02063a0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063a2:	bf35                	j	ffffffffc02062de <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02063a4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063a8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02063ac:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ae:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02063b0:	bfd9                	j	ffffffffc0206386 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02063b2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063b4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063b8:	01174463          	blt	a4,a7,ffffffffc02063c0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02063bc:	1a088e63          	beqz	a7,ffffffffc0206578 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02063c0:	000a3603          	ld	a2,0(s4)
ffffffffc02063c4:	46c1                	li	a3,16
ffffffffc02063c6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063c8:	2781                	sext.w	a5,a5
ffffffffc02063ca:	876e                	mv	a4,s11
ffffffffc02063cc:	85a6                	mv	a1,s1
ffffffffc02063ce:	854a                	mv	a0,s2
ffffffffc02063d0:	e37ff0ef          	jal	ra,ffffffffc0206206 <printnum>
            break;
ffffffffc02063d4:	bde1                	j	ffffffffc02062ac <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02063d6:	000a2503          	lw	a0,0(s4)
ffffffffc02063da:	85a6                	mv	a1,s1
ffffffffc02063dc:	0a21                	addi	s4,s4,8
ffffffffc02063de:	9902                	jalr	s2
            break;
ffffffffc02063e0:	b5f1                	j	ffffffffc02062ac <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063e8:	01174463          	blt	a4,a7,ffffffffc02063f0 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02063ec:	18088163          	beqz	a7,ffffffffc020656e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02063f0:	000a3603          	ld	a2,0(s4)
ffffffffc02063f4:	46a9                	li	a3,10
ffffffffc02063f6:	8a2e                	mv	s4,a1
ffffffffc02063f8:	bfc1                	j	ffffffffc02063c8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063fa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02063fe:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206400:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206402:	bdf1                	j	ffffffffc02062de <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206404:	85a6                	mv	a1,s1
ffffffffc0206406:	02500513          	li	a0,37
ffffffffc020640a:	9902                	jalr	s2
            break;
ffffffffc020640c:	b545                	j	ffffffffc02062ac <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020640e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206412:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206414:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206416:	b5e1                	j	ffffffffc02062de <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206418:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020641a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020641e:	01174463          	blt	a4,a7,ffffffffc0206426 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206422:	14088163          	beqz	a7,ffffffffc0206564 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206426:	000a3603          	ld	a2,0(s4)
ffffffffc020642a:	46a1                	li	a3,8
ffffffffc020642c:	8a2e                	mv	s4,a1
ffffffffc020642e:	bf69                	j	ffffffffc02063c8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206430:	03000513          	li	a0,48
ffffffffc0206434:	85a6                	mv	a1,s1
ffffffffc0206436:	e03e                	sd	a5,0(sp)
ffffffffc0206438:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020643a:	85a6                	mv	a1,s1
ffffffffc020643c:	07800513          	li	a0,120
ffffffffc0206440:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206442:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206444:	6782                	ld	a5,0(sp)
ffffffffc0206446:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206448:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020644c:	bfb5                	j	ffffffffc02063c8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020644e:	000a3403          	ld	s0,0(s4)
ffffffffc0206452:	008a0713          	addi	a4,s4,8
ffffffffc0206456:	e03a                	sd	a4,0(sp)
ffffffffc0206458:	14040263          	beqz	s0,ffffffffc020659c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020645c:	0fb05763          	blez	s11,ffffffffc020654a <vprintfmt+0x2d8>
ffffffffc0206460:	02d00693          	li	a3,45
ffffffffc0206464:	0cd79163          	bne	a5,a3,ffffffffc0206526 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206468:	00044783          	lbu	a5,0(s0)
ffffffffc020646c:	0007851b          	sext.w	a0,a5
ffffffffc0206470:	cf85                	beqz	a5,ffffffffc02064a8 <vprintfmt+0x236>
ffffffffc0206472:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206476:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020647a:	000c4563          	bltz	s8,ffffffffc0206484 <vprintfmt+0x212>
ffffffffc020647e:	3c7d                	addiw	s8,s8,-1
ffffffffc0206480:	036c0263          	beq	s8,s6,ffffffffc02064a4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206484:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206486:	0e0c8e63          	beqz	s9,ffffffffc0206582 <vprintfmt+0x310>
ffffffffc020648a:	3781                	addiw	a5,a5,-32
ffffffffc020648c:	0ef47b63          	bgeu	s0,a5,ffffffffc0206582 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206490:	03f00513          	li	a0,63
ffffffffc0206494:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206496:	000a4783          	lbu	a5,0(s4)
ffffffffc020649a:	3dfd                	addiw	s11,s11,-1
ffffffffc020649c:	0a05                	addi	s4,s4,1
ffffffffc020649e:	0007851b          	sext.w	a0,a5
ffffffffc02064a2:	ffe1                	bnez	a5,ffffffffc020647a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02064a4:	01b05963          	blez	s11,ffffffffc02064b6 <vprintfmt+0x244>
ffffffffc02064a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02064aa:	85a6                	mv	a1,s1
ffffffffc02064ac:	02000513          	li	a0,32
ffffffffc02064b0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02064b2:	fe0d9be3          	bnez	s11,ffffffffc02064a8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064b6:	6a02                	ld	s4,0(sp)
ffffffffc02064b8:	bbd5                	j	ffffffffc02062ac <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064bc:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02064c0:	01174463          	blt	a4,a7,ffffffffc02064c8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02064c4:	08088d63          	beqz	a7,ffffffffc020655e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02064c8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02064cc:	0a044d63          	bltz	s0,ffffffffc0206586 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02064d0:	8622                	mv	a2,s0
ffffffffc02064d2:	8a66                	mv	s4,s9
ffffffffc02064d4:	46a9                	li	a3,10
ffffffffc02064d6:	bdcd                	j	ffffffffc02063c8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02064d8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064dc:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02064de:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02064e0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02064e4:	8fb5                	xor	a5,a5,a3
ffffffffc02064e6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064ea:	02d74163          	blt	a4,a3,ffffffffc020650c <vprintfmt+0x29a>
ffffffffc02064ee:	00369793          	slli	a5,a3,0x3
ffffffffc02064f2:	97de                	add	a5,a5,s7
ffffffffc02064f4:	639c                	ld	a5,0(a5)
ffffffffc02064f6:	cb99                	beqz	a5,ffffffffc020650c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02064f8:	86be                	mv	a3,a5
ffffffffc02064fa:	00000617          	auipc	a2,0x0
ffffffffc02064fe:	13e60613          	addi	a2,a2,318 # ffffffffc0206638 <etext+0x2e>
ffffffffc0206502:	85a6                	mv	a1,s1
ffffffffc0206504:	854a                	mv	a0,s2
ffffffffc0206506:	0ce000ef          	jal	ra,ffffffffc02065d4 <printfmt>
ffffffffc020650a:	b34d                	j	ffffffffc02062ac <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020650c:	00002617          	auipc	a2,0x2
ffffffffc0206510:	52460613          	addi	a2,a2,1316 # ffffffffc0208a30 <syscalls+0x120>
ffffffffc0206514:	85a6                	mv	a1,s1
ffffffffc0206516:	854a                	mv	a0,s2
ffffffffc0206518:	0bc000ef          	jal	ra,ffffffffc02065d4 <printfmt>
ffffffffc020651c:	bb41                	j	ffffffffc02062ac <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020651e:	00002417          	auipc	s0,0x2
ffffffffc0206522:	50a40413          	addi	s0,s0,1290 # ffffffffc0208a28 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206526:	85e2                	mv	a1,s8
ffffffffc0206528:	8522                	mv	a0,s0
ffffffffc020652a:	e43e                	sd	a5,8(sp)
ffffffffc020652c:	c4fff0ef          	jal	ra,ffffffffc020617a <strnlen>
ffffffffc0206530:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206534:	01b05b63          	blez	s11,ffffffffc020654a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206538:	67a2                	ld	a5,8(sp)
ffffffffc020653a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020653e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206540:	85a6                	mv	a1,s1
ffffffffc0206542:	8552                	mv	a0,s4
ffffffffc0206544:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206546:	fe0d9ce3          	bnez	s11,ffffffffc020653e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020654a:	00044783          	lbu	a5,0(s0)
ffffffffc020654e:	00140a13          	addi	s4,s0,1
ffffffffc0206552:	0007851b          	sext.w	a0,a5
ffffffffc0206556:	d3a5                	beqz	a5,ffffffffc02064b6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206558:	05e00413          	li	s0,94
ffffffffc020655c:	bf39                	j	ffffffffc020647a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020655e:	000a2403          	lw	s0,0(s4)
ffffffffc0206562:	b7ad                	j	ffffffffc02064cc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206564:	000a6603          	lwu	a2,0(s4)
ffffffffc0206568:	46a1                	li	a3,8
ffffffffc020656a:	8a2e                	mv	s4,a1
ffffffffc020656c:	bdb1                	j	ffffffffc02063c8 <vprintfmt+0x156>
ffffffffc020656e:	000a6603          	lwu	a2,0(s4)
ffffffffc0206572:	46a9                	li	a3,10
ffffffffc0206574:	8a2e                	mv	s4,a1
ffffffffc0206576:	bd89                	j	ffffffffc02063c8 <vprintfmt+0x156>
ffffffffc0206578:	000a6603          	lwu	a2,0(s4)
ffffffffc020657c:	46c1                	li	a3,16
ffffffffc020657e:	8a2e                	mv	s4,a1
ffffffffc0206580:	b5a1                	j	ffffffffc02063c8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206582:	9902                	jalr	s2
ffffffffc0206584:	bf09                	j	ffffffffc0206496 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206586:	85a6                	mv	a1,s1
ffffffffc0206588:	02d00513          	li	a0,45
ffffffffc020658c:	e03e                	sd	a5,0(sp)
ffffffffc020658e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206590:	6782                	ld	a5,0(sp)
ffffffffc0206592:	8a66                	mv	s4,s9
ffffffffc0206594:	40800633          	neg	a2,s0
ffffffffc0206598:	46a9                	li	a3,10
ffffffffc020659a:	b53d                	j	ffffffffc02063c8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020659c:	03b05163          	blez	s11,ffffffffc02065be <vprintfmt+0x34c>
ffffffffc02065a0:	02d00693          	li	a3,45
ffffffffc02065a4:	f6d79de3          	bne	a5,a3,ffffffffc020651e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02065a8:	00002417          	auipc	s0,0x2
ffffffffc02065ac:	48040413          	addi	s0,s0,1152 # ffffffffc0208a28 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065b0:	02800793          	li	a5,40
ffffffffc02065b4:	02800513          	li	a0,40
ffffffffc02065b8:	00140a13          	addi	s4,s0,1
ffffffffc02065bc:	bd6d                	j	ffffffffc0206476 <vprintfmt+0x204>
ffffffffc02065be:	00002a17          	auipc	s4,0x2
ffffffffc02065c2:	46ba0a13          	addi	s4,s4,1131 # ffffffffc0208a29 <syscalls+0x119>
ffffffffc02065c6:	02800513          	li	a0,40
ffffffffc02065ca:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ce:	05e00413          	li	s0,94
ffffffffc02065d2:	b565                	j	ffffffffc020647a <vprintfmt+0x208>

ffffffffc02065d4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065d4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065d6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065da:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065dc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065de:	ec06                	sd	ra,24(sp)
ffffffffc02065e0:	f83a                	sd	a4,48(sp)
ffffffffc02065e2:	fc3e                	sd	a5,56(sp)
ffffffffc02065e4:	e0c2                	sd	a6,64(sp)
ffffffffc02065e6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065e8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065ea:	c89ff0ef          	jal	ra,ffffffffc0206272 <vprintfmt>
}
ffffffffc02065ee:	60e2                	ld	ra,24(sp)
ffffffffc02065f0:	6161                	addi	sp,sp,80
ffffffffc02065f2:	8082                	ret

ffffffffc02065f4 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065f4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065f8:	2785                	addiw	a5,a5,1
ffffffffc02065fa:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02065fe:	02000793          	li	a5,32
ffffffffc0206602:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206604:	00f5553b          	srlw	a0,a0,a5
ffffffffc0206608:	8082                	ret
