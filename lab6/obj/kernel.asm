
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020c2b7          	lui	t0,0xc020c
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
ffffffffc0200024:	c020c137          	lui	sp,0xc020c

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
ffffffffc0200032:	000c4517          	auipc	a0,0xc4
ffffffffc0200036:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02c3a40 <buf>
ffffffffc020003a:	000cf617          	auipc	a2,0xcf
ffffffffc020003e:	f9e60613          	addi	a2,a2,-98 # ffffffffc02cefd8 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	3a1060ef          	jal	ra,ffffffffc0206bea <memset>
    cons_init();                // init the console
ffffffffc020004e:	524000ef          	jal	ra,ffffffffc0200572 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00007597          	auipc	a1,0x7
ffffffffc0200056:	bc658593          	addi	a1,a1,-1082 # ffffffffc0206c18 <etext+0x4>
ffffffffc020005a:	00007517          	auipc	a0,0x7
ffffffffc020005e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0206c38 <etext+0x24>
ffffffffc0200062:	122000ef          	jal	ra,ffffffffc0200184 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a6000ef          	jal	ra,ffffffffc020020c <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	506020ef          	jal	ra,ffffffffc0202570 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d8000ef          	jal	ra,ffffffffc0200646 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5d6000ef          	jal	ra,ffffffffc0200648 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	426040ef          	jal	ra,ffffffffc020449c <vmm_init>
    sched_init();
ffffffffc020007a:	42c060ef          	jal	ra,ffffffffc02064a6 <sched_init>
    proc_init();                // init process table
ffffffffc020007e:	4c7050ef          	jal	ra,ffffffffc0205d44 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	562000ef          	jal	ra,ffffffffc02005e4 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	374030ef          	jal	ra,ffffffffc02033fa <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a0000ef          	jal	ra,ffffffffc020052a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5ac000ef          	jal	ra,ffffffffc020063a <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	64b050ef          	jal	ra,ffffffffc0205edc <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a6                	sd	s1,64(sp)
ffffffffc020009c:	fc4a                	sd	s2,56(sp)
ffffffffc020009e:	f84e                	sd	s3,48(sp)
ffffffffc02000a0:	f452                	sd	s4,40(sp)
ffffffffc02000a2:	f056                	sd	s5,32(sp)
ffffffffc02000a4:	ec5a                	sd	s6,24(sp)
ffffffffc02000a6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a8:	c901                	beqz	a0,ffffffffc02000b8 <readline+0x22>
ffffffffc02000aa:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000ac:	00007517          	auipc	a0,0x7
ffffffffc02000b0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0206c40 <etext+0x2c>
ffffffffc02000b4:	0d0000ef          	jal	ra,ffffffffc0200184 <cprintf>
readline(const char *prompt) {
ffffffffc02000b8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ba:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000bc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000be:	4aa9                	li	s5,10
ffffffffc02000c0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c2:	000c4b97          	auipc	s7,0xc4
ffffffffc02000c6:	97eb8b93          	addi	s7,s7,-1666 # ffffffffc02c3a40 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ce:	12e000ef          	jal	ra,ffffffffc02001fc <getchar>
        if (c < 0) {
ffffffffc02000d2:	00054a63          	bltz	a0,ffffffffc02000e6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d6:	00a95a63          	bge	s2,a0,ffffffffc02000ea <readline+0x54>
ffffffffc02000da:	029a5263          	bge	s4,s1,ffffffffc02000fe <readline+0x68>
        c = getchar();
ffffffffc02000de:	11e000ef          	jal	ra,ffffffffc02001fc <getchar>
        if (c < 0) {
ffffffffc02000e2:	fe055ae3          	bgez	a0,ffffffffc02000d6 <readline+0x40>
            return NULL;
ffffffffc02000e6:	4501                	li	a0,0
ffffffffc02000e8:	a091                	j	ffffffffc020012c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000ea:	03351463          	bne	a0,s3,ffffffffc0200112 <readline+0x7c>
ffffffffc02000ee:	e8a9                	bnez	s1,ffffffffc0200140 <readline+0xaa>
        c = getchar();
ffffffffc02000f0:	10c000ef          	jal	ra,ffffffffc02001fc <getchar>
        if (c < 0) {
ffffffffc02000f4:	fe0549e3          	bltz	a0,ffffffffc02000e6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f8:	fea959e3          	bge	s2,a0,ffffffffc02000ea <readline+0x54>
ffffffffc02000fc:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fe:	e42a                	sd	a0,8(sp)
ffffffffc0200100:	0ba000ef          	jal	ra,ffffffffc02001ba <cputchar>
            buf[i ++] = c;
ffffffffc0200104:	6522                	ld	a0,8(sp)
ffffffffc0200106:	009b87b3          	add	a5,s7,s1
ffffffffc020010a:	2485                	addiw	s1,s1,1
ffffffffc020010c:	00a78023          	sb	a0,0(a5)
ffffffffc0200110:	bf7d                	j	ffffffffc02000ce <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200112:	01550463          	beq	a0,s5,ffffffffc020011a <readline+0x84>
ffffffffc0200116:	fb651ce3          	bne	a0,s6,ffffffffc02000ce <readline+0x38>
            cputchar(c);
ffffffffc020011a:	0a0000ef          	jal	ra,ffffffffc02001ba <cputchar>
            buf[i] = '\0';
ffffffffc020011e:	000c4517          	auipc	a0,0xc4
ffffffffc0200122:	92250513          	addi	a0,a0,-1758 # ffffffffc02c3a40 <buf>
ffffffffc0200126:	94aa                	add	s1,s1,a0
ffffffffc0200128:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020012c:	60a6                	ld	ra,72(sp)
ffffffffc020012e:	6486                	ld	s1,64(sp)
ffffffffc0200130:	7962                	ld	s2,56(sp)
ffffffffc0200132:	79c2                	ld	s3,48(sp)
ffffffffc0200134:	7a22                	ld	s4,40(sp)
ffffffffc0200136:	7a82                	ld	s5,32(sp)
ffffffffc0200138:	6b62                	ld	s6,24(sp)
ffffffffc020013a:	6bc2                	ld	s7,16(sp)
ffffffffc020013c:	6161                	addi	sp,sp,80
ffffffffc020013e:	8082                	ret
            cputchar(c);
ffffffffc0200140:	4521                	li	a0,8
ffffffffc0200142:	078000ef          	jal	ra,ffffffffc02001ba <cputchar>
            i --;
ffffffffc0200146:	34fd                	addiw	s1,s1,-1
ffffffffc0200148:	b759                	j	ffffffffc02000ce <readline+0x38>

ffffffffc020014a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020014a:	1141                	addi	sp,sp,-16
ffffffffc020014c:	e022                	sd	s0,0(sp)
ffffffffc020014e:	e406                	sd	ra,8(sp)
ffffffffc0200150:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200152:	422000ef          	jal	ra,ffffffffc0200574 <cons_putc>
    (*cnt) ++;
ffffffffc0200156:	401c                	lw	a5,0(s0)
}
ffffffffc0200158:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020015a:	2785                	addiw	a5,a5,1
ffffffffc020015c:	c01c                	sw	a5,0(s0)
}
ffffffffc020015e:	6402                	ld	s0,0(sp)
ffffffffc0200160:	0141                	addi	sp,sp,16
ffffffffc0200162:	8082                	ret

ffffffffc0200164 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200164:	1101                	addi	sp,sp,-32
ffffffffc0200166:	862a                	mv	a2,a0
ffffffffc0200168:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020016a:	00000517          	auipc	a0,0x0
ffffffffc020016e:	fe050513          	addi	a0,a0,-32 # ffffffffc020014a <cputch>
ffffffffc0200172:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200174:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200176:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200178:	674060ef          	jal	ra,ffffffffc02067ec <vprintfmt>
    return cnt;
}
ffffffffc020017c:	60e2                	ld	ra,24(sp)
ffffffffc020017e:	4532                	lw	a0,12(sp)
ffffffffc0200180:	6105                	addi	sp,sp,32
ffffffffc0200182:	8082                	ret

ffffffffc0200184 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200184:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200186:	02810313          	addi	t1,sp,40 # ffffffffc020c028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc020018a:	8e2a                	mv	t3,a0
ffffffffc020018c:	f42e                	sd	a1,40(sp)
ffffffffc020018e:	f832                	sd	a2,48(sp)
ffffffffc0200190:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200192:	00000517          	auipc	a0,0x0
ffffffffc0200196:	fb850513          	addi	a0,a0,-72 # ffffffffc020014a <cputch>
ffffffffc020019a:	004c                	addi	a1,sp,4
ffffffffc020019c:	869a                	mv	a3,t1
ffffffffc020019e:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02001a0:	ec06                	sd	ra,24(sp)
ffffffffc02001a2:	e0ba                	sd	a4,64(sp)
ffffffffc02001a4:	e4be                	sd	a5,72(sp)
ffffffffc02001a6:	e8c2                	sd	a6,80(sp)
ffffffffc02001a8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001aa:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001ac:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001ae:	63e060ef          	jal	ra,ffffffffc02067ec <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	4512                	lw	a0,4(sp)
ffffffffc02001b6:	6125                	addi	sp,sp,96
ffffffffc02001b8:	8082                	ret

ffffffffc02001ba <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001ba:	ae6d                	j	ffffffffc0200574 <cons_putc>

ffffffffc02001bc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001bc:	1101                	addi	sp,sp,-32
ffffffffc02001be:	e822                	sd	s0,16(sp)
ffffffffc02001c0:	ec06                	sd	ra,24(sp)
ffffffffc02001c2:	e426                	sd	s1,8(sp)
ffffffffc02001c4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c6:	00054503          	lbu	a0,0(a0)
ffffffffc02001ca:	c51d                	beqz	a0,ffffffffc02001f8 <cputs+0x3c>
ffffffffc02001cc:	0405                	addi	s0,s0,1
ffffffffc02001ce:	4485                	li	s1,1
ffffffffc02001d0:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001d2:	3a2000ef          	jal	ra,ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d6:	00044503          	lbu	a0,0(s0)
ffffffffc02001da:	008487bb          	addw	a5,s1,s0
ffffffffc02001de:	0405                	addi	s0,s0,1
ffffffffc02001e0:	f96d                	bnez	a0,ffffffffc02001d2 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001e2:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e6:	4529                	li	a0,10
ffffffffc02001e8:	38c000ef          	jal	ra,ffffffffc0200574 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001ec:	60e2                	ld	ra,24(sp)
ffffffffc02001ee:	8522                	mv	a0,s0
ffffffffc02001f0:	6442                	ld	s0,16(sp)
ffffffffc02001f2:	64a2                	ld	s1,8(sp)
ffffffffc02001f4:	6105                	addi	sp,sp,32
ffffffffc02001f6:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f8:	4405                	li	s0,1
ffffffffc02001fa:	b7f5                	j	ffffffffc02001e6 <cputs+0x2a>

ffffffffc02001fc <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001fc:	1141                	addi	sp,sp,-16
ffffffffc02001fe:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200200:	3a8000ef          	jal	ra,ffffffffc02005a8 <cons_getc>
ffffffffc0200204:	dd75                	beqz	a0,ffffffffc0200200 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200206:	60a2                	ld	ra,8(sp)
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020e:	00007517          	auipc	a0,0x7
ffffffffc0200212:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0206c48 <etext+0x34>
void print_kerninfo(void) {
ffffffffc0200216:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	f6dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020021c:	00000597          	auipc	a1,0x0
ffffffffc0200220:	e1658593          	addi	a1,a1,-490 # ffffffffc0200032 <kern_init>
ffffffffc0200224:	00007517          	auipc	a0,0x7
ffffffffc0200228:	a4450513          	addi	a0,a0,-1468 # ffffffffc0206c68 <etext+0x54>
ffffffffc020022c:	f59ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200230:	00007597          	auipc	a1,0x7
ffffffffc0200234:	9e458593          	addi	a1,a1,-1564 # ffffffffc0206c14 <etext>
ffffffffc0200238:	00007517          	auipc	a0,0x7
ffffffffc020023c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0206c88 <etext+0x74>
ffffffffc0200240:	f45ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200244:	000c3597          	auipc	a1,0xc3
ffffffffc0200248:	7fc58593          	addi	a1,a1,2044 # ffffffffc02c3a40 <buf>
ffffffffc020024c:	00007517          	auipc	a0,0x7
ffffffffc0200250:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0206ca8 <etext+0x94>
ffffffffc0200254:	f31ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200258:	000cf597          	auipc	a1,0xcf
ffffffffc020025c:	d8058593          	addi	a1,a1,-640 # ffffffffc02cefd8 <end>
ffffffffc0200260:	00007517          	auipc	a0,0x7
ffffffffc0200264:	a6850513          	addi	a0,a0,-1432 # ffffffffc0206cc8 <etext+0xb4>
ffffffffc0200268:	f1dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020026c:	000cf597          	auipc	a1,0xcf
ffffffffc0200270:	16b58593          	addi	a1,a1,363 # ffffffffc02cf3d7 <end+0x3ff>
ffffffffc0200274:	00000797          	auipc	a5,0x0
ffffffffc0200278:	dbe78793          	addi	a5,a5,-578 # ffffffffc0200032 <kern_init>
ffffffffc020027c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200280:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200284:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200286:	3ff5f593          	andi	a1,a1,1023
ffffffffc020028a:	95be                	add	a1,a1,a5
ffffffffc020028c:	85a9                	srai	a1,a1,0xa
ffffffffc020028e:	00007517          	auipc	a0,0x7
ffffffffc0200292:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0206ce8 <etext+0xd4>
}
ffffffffc0200296:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	b5f5                	j	ffffffffc0200184 <cprintf>

ffffffffc020029a <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020029a:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020029c:	00007617          	auipc	a2,0x7
ffffffffc02002a0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206d18 <etext+0x104>
ffffffffc02002a4:	04d00593          	li	a1,77
ffffffffc02002a8:	00007517          	auipc	a0,0x7
ffffffffc02002ac:	a8850513          	addi	a0,a0,-1400 # ffffffffc0206d30 <etext+0x11c>
void print_stackframe(void) {
ffffffffc02002b0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002b2:	1cc000ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02002b6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b8:	00007617          	auipc	a2,0x7
ffffffffc02002bc:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206d48 <etext+0x134>
ffffffffc02002c0:	00007597          	auipc	a1,0x7
ffffffffc02002c4:	aa858593          	addi	a1,a1,-1368 # ffffffffc0206d68 <etext+0x154>
ffffffffc02002c8:	00007517          	auipc	a0,0x7
ffffffffc02002cc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0206d70 <etext+0x15c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d2:	eb3ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc02002d6:	00007617          	auipc	a2,0x7
ffffffffc02002da:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206d80 <etext+0x16c>
ffffffffc02002de:	00007597          	auipc	a1,0x7
ffffffffc02002e2:	aca58593          	addi	a1,a1,-1334 # ffffffffc0206da8 <etext+0x194>
ffffffffc02002e6:	00007517          	auipc	a0,0x7
ffffffffc02002ea:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0206d70 <etext+0x15c>
ffffffffc02002ee:	e97ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc02002f2:	00007617          	auipc	a2,0x7
ffffffffc02002f6:	ac660613          	addi	a2,a2,-1338 # ffffffffc0206db8 <etext+0x1a4>
ffffffffc02002fa:	00007597          	auipc	a1,0x7
ffffffffc02002fe:	ade58593          	addi	a1,a1,-1314 # ffffffffc0206dd8 <etext+0x1c4>
ffffffffc0200302:	00007517          	auipc	a0,0x7
ffffffffc0200306:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206d70 <etext+0x15c>
ffffffffc020030a:	e7bff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    }
    return 0;
}
ffffffffc020030e:	60a2                	ld	ra,8(sp)
ffffffffc0200310:	4501                	li	a0,0
ffffffffc0200312:	0141                	addi	sp,sp,16
ffffffffc0200314:	8082                	ret

ffffffffc0200316 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200316:	1141                	addi	sp,sp,-16
ffffffffc0200318:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020031a:	ef3ff0ef          	jal	ra,ffffffffc020020c <print_kerninfo>
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020032a:	f71ff0ef          	jal	ra,ffffffffc020029a <print_stackframe>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200336:	7115                	addi	sp,sp,-224
ffffffffc0200338:	ed5e                	sd	s7,152(sp)
ffffffffc020033a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020033c:	00007517          	auipc	a0,0x7
ffffffffc0200340:	aac50513          	addi	a0,a0,-1364 # ffffffffc0206de8 <etext+0x1d4>
kmonitor(struct trapframe *tf) {
ffffffffc0200344:	ed86                	sd	ra,216(sp)
ffffffffc0200346:	e9a2                	sd	s0,208(sp)
ffffffffc0200348:	e5a6                	sd	s1,200(sp)
ffffffffc020034a:	e1ca                	sd	s2,192(sp)
ffffffffc020034c:	fd4e                	sd	s3,184(sp)
ffffffffc020034e:	f952                	sd	s4,176(sp)
ffffffffc0200350:	f556                	sd	s5,168(sp)
ffffffffc0200352:	f15a                	sd	s6,160(sp)
ffffffffc0200354:	e962                	sd	s8,144(sp)
ffffffffc0200356:	e566                	sd	s9,136(sp)
ffffffffc0200358:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020035a:	e2bff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035e:	00007517          	auipc	a0,0x7
ffffffffc0200362:	ab250513          	addi	a0,a0,-1358 # ffffffffc0206e10 <etext+0x1fc>
ffffffffc0200366:	e1fff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    if (tf != NULL) {
ffffffffc020036a:	000b8563          	beqz	s7,ffffffffc0200374 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036e:	855e                	mv	a0,s7
ffffffffc0200370:	4be000ef          	jal	ra,ffffffffc020082e <print_trapframe>
ffffffffc0200374:	00007c17          	auipc	s8,0x7
ffffffffc0200378:	b0cc0c13          	addi	s8,s8,-1268 # ffffffffc0206e80 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020037c:	00007917          	auipc	s2,0x7
ffffffffc0200380:	abc90913          	addi	s2,s2,-1348 # ffffffffc0206e38 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200384:	00007497          	auipc	s1,0x7
ffffffffc0200388:	abc48493          	addi	s1,s1,-1348 # ffffffffc0206e40 <etext+0x22c>
        if (argc == MAXARGS - 1) {
ffffffffc020038c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038e:	00007b17          	auipc	s6,0x7
ffffffffc0200392:	abab0b13          	addi	s6,s6,-1350 # ffffffffc0206e48 <etext+0x234>
        argv[argc ++] = buf;
ffffffffc0200396:	00007a17          	auipc	s4,0x7
ffffffffc020039a:	9d2a0a13          	addi	s4,s4,-1582 # ffffffffc0206d68 <etext+0x154>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039e:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	854a                	mv	a0,s2
ffffffffc02003a2:	cf5ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003a6:	842a                	mv	s0,a0
ffffffffc02003a8:	dd65                	beqz	a0,ffffffffc02003a0 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003aa:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ae:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b0:	e1bd                	bnez	a1,ffffffffc0200416 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003b2:	fe0c87e3          	beqz	s9,ffffffffc02003a0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b6:	6582                	ld	a1,0(sp)
ffffffffc02003b8:	00007d17          	auipc	s10,0x7
ffffffffc02003bc:	ac8d0d13          	addi	s10,s10,-1336 # ffffffffc0206e80 <commands>
        argv[argc ++] = buf;
ffffffffc02003c0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4401                	li	s0,0
ffffffffc02003c4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c6:	7f0060ef          	jal	ra,ffffffffc0206bb6 <strcmp>
ffffffffc02003ca:	c919                	beqz	a0,ffffffffc02003e0 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003cc:	2405                	addiw	s0,s0,1
ffffffffc02003ce:	0b540063          	beq	s0,s5,ffffffffc020046e <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d2:	000d3503          	ld	a0,0(s10)
ffffffffc02003d6:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	7dc060ef          	jal	ra,ffffffffc0206bb6 <strcmp>
ffffffffc02003de:	f57d                	bnez	a0,ffffffffc02003cc <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003e0:	00141793          	slli	a5,s0,0x1
ffffffffc02003e4:	97a2                	add	a5,a5,s0
ffffffffc02003e6:	078e                	slli	a5,a5,0x3
ffffffffc02003e8:	97e2                	add	a5,a5,s8
ffffffffc02003ea:	6b9c                	ld	a5,16(a5)
ffffffffc02003ec:	865e                	mv	a2,s7
ffffffffc02003ee:	002c                	addi	a1,sp,8
ffffffffc02003f0:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f4:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f6:	fa0555e3          	bgez	a0,ffffffffc02003a0 <kmonitor+0x6a>
}
ffffffffc02003fa:	60ee                	ld	ra,216(sp)
ffffffffc02003fc:	644e                	ld	s0,208(sp)
ffffffffc02003fe:	64ae                	ld	s1,200(sp)
ffffffffc0200400:	690e                	ld	s2,192(sp)
ffffffffc0200402:	79ea                	ld	s3,184(sp)
ffffffffc0200404:	7a4a                	ld	s4,176(sp)
ffffffffc0200406:	7aaa                	ld	s5,168(sp)
ffffffffc0200408:	7b0a                	ld	s6,160(sp)
ffffffffc020040a:	6bea                	ld	s7,152(sp)
ffffffffc020040c:	6c4a                	ld	s8,144(sp)
ffffffffc020040e:	6caa                	ld	s9,136(sp)
ffffffffc0200410:	6d0a                	ld	s10,128(sp)
ffffffffc0200412:	612d                	addi	sp,sp,224
ffffffffc0200414:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200416:	8526                	mv	a0,s1
ffffffffc0200418:	7bc060ef          	jal	ra,ffffffffc0206bd4 <strchr>
ffffffffc020041c:	c901                	beqz	a0,ffffffffc020042c <kmonitor+0xf6>
ffffffffc020041e:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200422:	00040023          	sb	zero,0(s0)
ffffffffc0200426:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200428:	d5c9                	beqz	a1,ffffffffc02003b2 <kmonitor+0x7c>
ffffffffc020042a:	b7f5                	j	ffffffffc0200416 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020042c:	00044783          	lbu	a5,0(s0)
ffffffffc0200430:	d3c9                	beqz	a5,ffffffffc02003b2 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200432:	033c8963          	beq	s9,s3,ffffffffc0200464 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200436:	003c9793          	slli	a5,s9,0x3
ffffffffc020043a:	0118                	addi	a4,sp,128
ffffffffc020043c:	97ba                	add	a5,a5,a4
ffffffffc020043e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200442:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200446:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200448:	e591                	bnez	a1,ffffffffc0200454 <kmonitor+0x11e>
ffffffffc020044a:	b7b5                	j	ffffffffc02003b6 <kmonitor+0x80>
ffffffffc020044c:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200450:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200452:	d1a5                	beqz	a1,ffffffffc02003b2 <kmonitor+0x7c>
ffffffffc0200454:	8526                	mv	a0,s1
ffffffffc0200456:	77e060ef          	jal	ra,ffffffffc0206bd4 <strchr>
ffffffffc020045a:	d96d                	beqz	a0,ffffffffc020044c <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020045c:	00044583          	lbu	a1,0(s0)
ffffffffc0200460:	d9a9                	beqz	a1,ffffffffc02003b2 <kmonitor+0x7c>
ffffffffc0200462:	bf55                	j	ffffffffc0200416 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200464:	45c1                	li	a1,16
ffffffffc0200466:	855a                	mv	a0,s6
ffffffffc0200468:	d1dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc020046c:	b7e9                	j	ffffffffc0200436 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046e:	6582                	ld	a1,0(sp)
ffffffffc0200470:	00007517          	auipc	a0,0x7
ffffffffc0200474:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206e68 <etext+0x254>
ffffffffc0200478:	d0dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    return 0;
ffffffffc020047c:	b715                	j	ffffffffc02003a0 <kmonitor+0x6a>

ffffffffc020047e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047e:	000cf317          	auipc	t1,0xcf
ffffffffc0200482:	aba30313          	addi	t1,t1,-1350 # ffffffffc02cef38 <is_panic>
ffffffffc0200486:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020048a:	715d                	addi	sp,sp,-80
ffffffffc020048c:	ec06                	sd	ra,24(sp)
ffffffffc020048e:	e822                	sd	s0,16(sp)
ffffffffc0200490:	f436                	sd	a3,40(sp)
ffffffffc0200492:	f83a                	sd	a4,48(sp)
ffffffffc0200494:	fc3e                	sd	a5,56(sp)
ffffffffc0200496:	e0c2                	sd	a6,64(sp)
ffffffffc0200498:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020049a:	020e1a63          	bnez	t3,ffffffffc02004ce <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049e:	4785                	li	a5,1
ffffffffc02004a0:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a4:	8432                	mv	s0,a2
ffffffffc02004a6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a8:	862e                	mv	a2,a1
ffffffffc02004aa:	85aa                	mv	a1,a0
ffffffffc02004ac:	00007517          	auipc	a0,0x7
ffffffffc02004b0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206ec8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b6:	ccfff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ba:	65a2                	ld	a1,8(sp)
ffffffffc02004bc:	8522                	mv	a0,s0
ffffffffc02004be:	ca7ff0ef          	jal	ra,ffffffffc0200164 <vcprintf>
    cprintf("\n");
ffffffffc02004c2:	00008517          	auipc	a0,0x8
ffffffffc02004c6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207e80 <default_pmm_manager+0x518>
ffffffffc02004ca:	cbbff0ef          	jal	ra,ffffffffc0200184 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ce:	4501                	li	a0,0
ffffffffc02004d0:	4581                	li	a1,0
ffffffffc02004d2:	4601                	li	a2,0
ffffffffc02004d4:	48a1                	li	a7,8
ffffffffc02004d6:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004da:	166000ef          	jal	ra,ffffffffc0200640 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004de:	4501                	li	a0,0
ffffffffc02004e0:	e57ff0ef          	jal	ra,ffffffffc0200336 <kmonitor>
    while (1) {
ffffffffc02004e4:	bfed                	j	ffffffffc02004de <__panic+0x60>

ffffffffc02004e6 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e6:	715d                	addi	sp,sp,-80
ffffffffc02004e8:	832e                	mv	t1,a1
ffffffffc02004ea:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ec:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ee:	8432                	mv	s0,a2
ffffffffc02004f0:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f6:	00007517          	auipc	a0,0x7
ffffffffc02004fa:	9f250513          	addi	a0,a0,-1550 # ffffffffc0206ee8 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fe:	ec06                	sd	ra,24(sp)
ffffffffc0200500:	f436                	sd	a3,40(sp)
ffffffffc0200502:	f83a                	sd	a4,48(sp)
ffffffffc0200504:	e0c2                	sd	a6,64(sp)
ffffffffc0200506:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200508:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020050a:	c7bff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050e:	65a2                	ld	a1,8(sp)
ffffffffc0200510:	8522                	mv	a0,s0
ffffffffc0200512:	c53ff0ef          	jal	ra,ffffffffc0200164 <vcprintf>
    cprintf("\n");
ffffffffc0200516:	00008517          	auipc	a0,0x8
ffffffffc020051a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0207e80 <default_pmm_manager+0x518>
ffffffffc020051e:	c67ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    va_end(ap);
}
ffffffffc0200522:	60e2                	ld	ra,24(sp)
ffffffffc0200524:	6442                	ld	s0,16(sp)
ffffffffc0200526:	6161                	addi	sp,sp,80
ffffffffc0200528:	8082                	ret

ffffffffc020052a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    set_csr(sie, MIP_STIP);
ffffffffc020052a:	02000793          	li	a5,32
ffffffffc020052e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200532:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200536:	67e1                	lui	a5,0x18
ffffffffc0200538:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf68>
ffffffffc020053c:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020053e:	4581                	li	a1,0
ffffffffc0200540:	4601                	li	a2,0
ffffffffc0200542:	4881                	li	a7,0
ffffffffc0200544:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200548:	00007517          	auipc	a0,0x7
ffffffffc020054c:	9c050513          	addi	a0,a0,-1600 # ffffffffc0206f08 <commands+0x88>
    ticks = 0;
ffffffffc0200550:	000cf797          	auipc	a5,0xcf
ffffffffc0200554:	9e07b823          	sd	zero,-1552(a5) # ffffffffc02cef40 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	b135                	j	ffffffffc0200184 <cprintf>

ffffffffc020055a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020055e:	67e1                	lui	a5,0x18
ffffffffc0200560:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf68>
ffffffffc0200564:	953e                	add	a0,a0,a5
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4881                	li	a7,0
ffffffffc020056c:	00000073          	ecall
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <cons_putc>:
#include <riscv.h>
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200574:	100027f3          	csrr	a5,sstatus
ffffffffc0200578:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020057a:	0ff57513          	zext.b	a0,a0
ffffffffc020057e:	e799                	bnez	a5,ffffffffc020058c <cons_putc+0x18>
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4885                	li	a7,1
ffffffffc0200586:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020058a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020058c:	1101                	addi	sp,sp,-32
ffffffffc020058e:	ec06                	sd	ra,24(sp)
ffffffffc0200590:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200592:	0ae000ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0200596:	6522                	ld	a0,8(sp)
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4885                	li	a7,1
ffffffffc020059e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a2:	60e2                	ld	ra,24(sp)
ffffffffc02005a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005a6:	a851                	j	ffffffffc020063a <intr_enable>

ffffffffc02005a8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005a8:	100027f3          	csrr	a5,sstatus
ffffffffc02005ac:	8b89                	andi	a5,a5,2
ffffffffc02005ae:	eb89                	bnez	a5,ffffffffc02005c0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b0:	4501                	li	a0,0
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4889                	li	a7,2
ffffffffc02005b8:	00000073          	ecall
ffffffffc02005bc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005be:	8082                	ret
int cons_getc(void) {
ffffffffc02005c0:	1101                	addi	sp,sp,-32
ffffffffc02005c2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005c4:	07c000ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
ffffffffc02005d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005d8:	062000ef          	jal	ra,ffffffffc020063a <intr_enable>
}
ffffffffc02005dc:	60e2                	ld	ra,24(sp)
ffffffffc02005de:	6522                	ld	a0,8(sp)
ffffffffc02005e0:	6105                	addi	sp,sp,32
ffffffffc02005e2:	8082                	ret

ffffffffc02005e4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005e4:	8082                	ret

ffffffffc02005e6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005e6:	00253513          	sltiu	a0,a0,2
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005ec:	03800513          	li	a0,56
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f2:	000c4797          	auipc	a5,0xc4
ffffffffc02005f6:	84e78793          	addi	a5,a5,-1970 # ffffffffc02c3e40 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02005fa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02005fe:	1141                	addi	sp,sp,-16
ffffffffc0200600:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	95be                	add	a1,a1,a5
ffffffffc0200604:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200608:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	5f2060ef          	jal	ra,ffffffffc0206bfc <memcpy>
    return 0;
}
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	4501                	li	a0,0
ffffffffc0200612:	0141                	addi	sp,sp,16
ffffffffc0200614:	8082                	ret

ffffffffc0200616 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200616:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061a:	000c4517          	auipc	a0,0xc4
ffffffffc020061e:	82650513          	addi	a0,a0,-2010 # ffffffffc02c3e40 <ide>
                   size_t nsecs) {
ffffffffc0200622:	1141                	addi	sp,sp,-16
ffffffffc0200624:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200626:	953e                	add	a0,a0,a5
ffffffffc0200628:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020062c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062e:	5ce060ef          	jal	ra,ffffffffc0206bfc <memcpy>
    return 0;
}
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	4501                	li	a0,0
ffffffffc0200636:	0141                	addi	sp,sp,16
ffffffffc0200638:	8082                	ret

ffffffffc020063a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020063a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200648:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020064c:	00000797          	auipc	a5,0x0
ffffffffc0200650:	65478793          	addi	a5,a5,1620 # ffffffffc0200ca0 <__alltraps>
ffffffffc0200654:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200658:	000407b7          	lui	a5,0x40
ffffffffc020065c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200664:	1141                	addi	sp,sp,-16
ffffffffc0200666:	e022                	sd	s0,0(sp)
ffffffffc0200668:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	00007517          	auipc	a0,0x7
ffffffffc020066e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0206f28 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200672:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	b11ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200678:	640c                	ld	a1,8(s0)
ffffffffc020067a:	00007517          	auipc	a0,0x7
ffffffffc020067e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0206f40 <commands+0xc0>
ffffffffc0200682:	b03ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200686:	680c                	ld	a1,16(s0)
ffffffffc0200688:	00007517          	auipc	a0,0x7
ffffffffc020068c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0206f58 <commands+0xd8>
ffffffffc0200690:	af5ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200694:	6c0c                	ld	a1,24(s0)
ffffffffc0200696:	00007517          	auipc	a0,0x7
ffffffffc020069a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0206f70 <commands+0xf0>
ffffffffc020069e:	ae7ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a2:	700c                	ld	a1,32(s0)
ffffffffc02006a4:	00007517          	auipc	a0,0x7
ffffffffc02006a8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206f88 <commands+0x108>
ffffffffc02006ac:	ad9ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b0:	740c                	ld	a1,40(s0)
ffffffffc02006b2:	00007517          	auipc	a0,0x7
ffffffffc02006b6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0206fa0 <commands+0x120>
ffffffffc02006ba:	acbff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006be:	780c                	ld	a1,48(s0)
ffffffffc02006c0:	00007517          	auipc	a0,0x7
ffffffffc02006c4:	8f850513          	addi	a0,a0,-1800 # ffffffffc0206fb8 <commands+0x138>
ffffffffc02006c8:	abdff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006cc:	7c0c                	ld	a1,56(s0)
ffffffffc02006ce:	00007517          	auipc	a0,0x7
ffffffffc02006d2:	90250513          	addi	a0,a0,-1790 # ffffffffc0206fd0 <commands+0x150>
ffffffffc02006d6:	aafff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006da:	602c                	ld	a1,64(s0)
ffffffffc02006dc:	00007517          	auipc	a0,0x7
ffffffffc02006e0:	90c50513          	addi	a0,a0,-1780 # ffffffffc0206fe8 <commands+0x168>
ffffffffc02006e4:	aa1ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006e8:	642c                	ld	a1,72(s0)
ffffffffc02006ea:	00007517          	auipc	a0,0x7
ffffffffc02006ee:	91650513          	addi	a0,a0,-1770 # ffffffffc0207000 <commands+0x180>
ffffffffc02006f2:	a93ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f6:	682c                	ld	a1,80(s0)
ffffffffc02006f8:	00007517          	auipc	a0,0x7
ffffffffc02006fc:	92050513          	addi	a0,a0,-1760 # ffffffffc0207018 <commands+0x198>
ffffffffc0200700:	a85ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200704:	6c2c                	ld	a1,88(s0)
ffffffffc0200706:	00007517          	auipc	a0,0x7
ffffffffc020070a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0207030 <commands+0x1b0>
ffffffffc020070e:	a77ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200712:	702c                	ld	a1,96(s0)
ffffffffc0200714:	00007517          	auipc	a0,0x7
ffffffffc0200718:	93450513          	addi	a0,a0,-1740 # ffffffffc0207048 <commands+0x1c8>
ffffffffc020071c:	a69ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200720:	742c                	ld	a1,104(s0)
ffffffffc0200722:	00007517          	auipc	a0,0x7
ffffffffc0200726:	93e50513          	addi	a0,a0,-1730 # ffffffffc0207060 <commands+0x1e0>
ffffffffc020072a:	a5bff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020072e:	782c                	ld	a1,112(s0)
ffffffffc0200730:	00007517          	auipc	a0,0x7
ffffffffc0200734:	94850513          	addi	a0,a0,-1720 # ffffffffc0207078 <commands+0x1f8>
ffffffffc0200738:	a4dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073c:	7c2c                	ld	a1,120(s0)
ffffffffc020073e:	00007517          	auipc	a0,0x7
ffffffffc0200742:	95250513          	addi	a0,a0,-1710 # ffffffffc0207090 <commands+0x210>
ffffffffc0200746:	a3fff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074a:	604c                	ld	a1,128(s0)
ffffffffc020074c:	00007517          	auipc	a0,0x7
ffffffffc0200750:	95c50513          	addi	a0,a0,-1700 # ffffffffc02070a8 <commands+0x228>
ffffffffc0200754:	a31ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200758:	644c                	ld	a1,136(s0)
ffffffffc020075a:	00007517          	auipc	a0,0x7
ffffffffc020075e:	96650513          	addi	a0,a0,-1690 # ffffffffc02070c0 <commands+0x240>
ffffffffc0200762:	a23ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200766:	684c                	ld	a1,144(s0)
ffffffffc0200768:	00007517          	auipc	a0,0x7
ffffffffc020076c:	97050513          	addi	a0,a0,-1680 # ffffffffc02070d8 <commands+0x258>
ffffffffc0200770:	a15ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200774:	6c4c                	ld	a1,152(s0)
ffffffffc0200776:	00007517          	auipc	a0,0x7
ffffffffc020077a:	97a50513          	addi	a0,a0,-1670 # ffffffffc02070f0 <commands+0x270>
ffffffffc020077e:	a07ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200782:	704c                	ld	a1,160(s0)
ffffffffc0200784:	00007517          	auipc	a0,0x7
ffffffffc0200788:	98450513          	addi	a0,a0,-1660 # ffffffffc0207108 <commands+0x288>
ffffffffc020078c:	9f9ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200790:	744c                	ld	a1,168(s0)
ffffffffc0200792:	00007517          	auipc	a0,0x7
ffffffffc0200796:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207120 <commands+0x2a0>
ffffffffc020079a:	9ebff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020079e:	784c                	ld	a1,176(s0)
ffffffffc02007a0:	00007517          	auipc	a0,0x7
ffffffffc02007a4:	99850513          	addi	a0,a0,-1640 # ffffffffc0207138 <commands+0x2b8>
ffffffffc02007a8:	9ddff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ac:	7c4c                	ld	a1,184(s0)
ffffffffc02007ae:	00007517          	auipc	a0,0x7
ffffffffc02007b2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0207150 <commands+0x2d0>
ffffffffc02007b6:	9cfff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ba:	606c                	ld	a1,192(s0)
ffffffffc02007bc:	00007517          	auipc	a0,0x7
ffffffffc02007c0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207168 <commands+0x2e8>
ffffffffc02007c4:	9c1ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007c8:	646c                	ld	a1,200(s0)
ffffffffc02007ca:	00007517          	auipc	a0,0x7
ffffffffc02007ce:	9b650513          	addi	a0,a0,-1610 # ffffffffc0207180 <commands+0x300>
ffffffffc02007d2:	9b3ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d6:	686c                	ld	a1,208(s0)
ffffffffc02007d8:	00007517          	auipc	a0,0x7
ffffffffc02007dc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0207198 <commands+0x318>
ffffffffc02007e0:	9a5ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e4:	6c6c                	ld	a1,216(s0)
ffffffffc02007e6:	00007517          	auipc	a0,0x7
ffffffffc02007ea:	9ca50513          	addi	a0,a0,-1590 # ffffffffc02071b0 <commands+0x330>
ffffffffc02007ee:	997ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f2:	706c                	ld	a1,224(s0)
ffffffffc02007f4:	00007517          	auipc	a0,0x7
ffffffffc02007f8:	9d450513          	addi	a0,a0,-1580 # ffffffffc02071c8 <commands+0x348>
ffffffffc02007fc:	989ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200800:	746c                	ld	a1,232(s0)
ffffffffc0200802:	00007517          	auipc	a0,0x7
ffffffffc0200806:	9de50513          	addi	a0,a0,-1570 # ffffffffc02071e0 <commands+0x360>
ffffffffc020080a:	97bff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020080e:	786c                	ld	a1,240(s0)
ffffffffc0200810:	00007517          	auipc	a0,0x7
ffffffffc0200814:	9e850513          	addi	a0,a0,-1560 # ffffffffc02071f8 <commands+0x378>
ffffffffc0200818:	96dff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020081e:	6402                	ld	s0,0(sp)
ffffffffc0200820:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	00007517          	auipc	a0,0x7
ffffffffc0200826:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0207210 <commands+0x390>
}
ffffffffc020082a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	baa1                	j	ffffffffc0200184 <cprintf>

ffffffffc020082e <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020082e:	1141                	addi	sp,sp,-16
ffffffffc0200830:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200836:	00007517          	auipc	a0,0x7
ffffffffc020083a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0207228 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc020083e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200840:	945ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200844:	8522                	mv	a0,s0
ffffffffc0200846:	e1dff0ef          	jal	ra,ffffffffc0200662 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084a:	10043583          	ld	a1,256(s0)
ffffffffc020084e:	00007517          	auipc	a0,0x7
ffffffffc0200852:	9f250513          	addi	a0,a0,-1550 # ffffffffc0207240 <commands+0x3c0>
ffffffffc0200856:	92fff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085a:	10843583          	ld	a1,264(s0)
ffffffffc020085e:	00007517          	auipc	a0,0x7
ffffffffc0200862:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0207258 <commands+0x3d8>
ffffffffc0200866:	91fff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020086a:	11043583          	ld	a1,272(s0)
ffffffffc020086e:	00007517          	auipc	a0,0x7
ffffffffc0200872:	a0250513          	addi	a0,a0,-1534 # ffffffffc0207270 <commands+0x3f0>
ffffffffc0200876:	90fff0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	11843583          	ld	a1,280(s0)
}
ffffffffc020087e:	6402                	ld	s0,0(sp)
ffffffffc0200880:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	00007517          	auipc	a0,0x7
ffffffffc0200886:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0207280 <commands+0x400>
}
ffffffffc020088a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088c:	8f9ff06f          	j	ffffffffc0200184 <cprintf>

ffffffffc0200890 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200890:	1101                	addi	sp,sp,-32
ffffffffc0200892:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200894:	000ce497          	auipc	s1,0xce
ffffffffc0200898:	70448493          	addi	s1,s1,1796 # ffffffffc02cef98 <check_mm_struct>
ffffffffc020089c:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc020089e:	e822                	sd	s0,16(sp)
ffffffffc02008a0:	ec06                	sd	ra,24(sp)
ffffffffc02008a2:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a4:	cbad                	beqz	a5,ffffffffc0200916 <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a6:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008aa:	11053583          	ld	a1,272(a0)
ffffffffc02008ae:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b2:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b6:	c7b1                	beqz	a5,ffffffffc0200902 <pgfault_handler+0x72>
ffffffffc02008b8:	11843703          	ld	a4,280(s0)
ffffffffc02008bc:	47bd                	li	a5,15
ffffffffc02008be:	05700693          	li	a3,87
ffffffffc02008c2:	00f70463          	beq	a4,a5,ffffffffc02008ca <pgfault_handler+0x3a>
ffffffffc02008c6:	05200693          	li	a3,82
ffffffffc02008ca:	00007517          	auipc	a0,0x7
ffffffffc02008ce:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0207298 <commands+0x418>
ffffffffc02008d2:	8b3ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008d6:	6088                	ld	a0,0(s1)
ffffffffc02008d8:	cd1d                	beqz	a0,ffffffffc0200916 <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008da:	000ce717          	auipc	a4,0xce
ffffffffc02008de:	6ce73703          	ld	a4,1742(a4) # ffffffffc02cefa8 <current>
ffffffffc02008e2:	000ce797          	auipc	a5,0xce
ffffffffc02008e6:	6ce7b783          	ld	a5,1742(a5) # ffffffffc02cefb0 <idleproc>
ffffffffc02008ea:	04f71663          	bne	a4,a5,ffffffffc0200936 <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008ee:	11043603          	ld	a2,272(s0)
ffffffffc02008f2:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f6:	6442                	ld	s0,16(sp)
ffffffffc02008f8:	60e2                	ld	ra,24(sp)
ffffffffc02008fa:	64a2                	ld	s1,8(sp)
ffffffffc02008fc:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008fe:	0de0406f          	j	ffffffffc02049dc <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200902:	11843703          	ld	a4,280(s0)
ffffffffc0200906:	47bd                	li	a5,15
ffffffffc0200908:	05500613          	li	a2,85
ffffffffc020090c:	05700693          	li	a3,87
ffffffffc0200910:	faf71be3          	bne	a4,a5,ffffffffc02008c6 <pgfault_handler+0x36>
ffffffffc0200914:	bf5d                	j	ffffffffc02008ca <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200916:	000ce797          	auipc	a5,0xce
ffffffffc020091a:	6927b783          	ld	a5,1682(a5) # ffffffffc02cefa8 <current>
ffffffffc020091e:	cf85                	beqz	a5,ffffffffc0200956 <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200920:	11043603          	ld	a2,272(s0)
ffffffffc0200924:	11843583          	ld	a1,280(s0)
}
ffffffffc0200928:	6442                	ld	s0,16(sp)
ffffffffc020092a:	60e2                	ld	ra,24(sp)
ffffffffc020092c:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc020092e:	7788                	ld	a0,40(a5)
}
ffffffffc0200930:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200932:	0aa0406f          	j	ffffffffc02049dc <do_pgfault>
        assert(current == idleproc);
ffffffffc0200936:	00007697          	auipc	a3,0x7
ffffffffc020093a:	98268693          	addi	a3,a3,-1662 # ffffffffc02072b8 <commands+0x438>
ffffffffc020093e:	00007617          	auipc	a2,0x7
ffffffffc0200942:	99260613          	addi	a2,a2,-1646 # ffffffffc02072d0 <commands+0x450>
ffffffffc0200946:	06c00593          	li	a1,108
ffffffffc020094a:	00007517          	auipc	a0,0x7
ffffffffc020094e:	99e50513          	addi	a0,a0,-1634 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200952:	b2dff0ef          	jal	ra,ffffffffc020047e <__panic>
            print_trapframe(tf);
ffffffffc0200956:	8522                	mv	a0,s0
ffffffffc0200958:	ed7ff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095c:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200960:	11043583          	ld	a1,272(s0)
ffffffffc0200964:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200968:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020096c:	e399                	bnez	a5,ffffffffc0200972 <pgfault_handler+0xe2>
ffffffffc020096e:	05500613          	li	a2,85
ffffffffc0200972:	11843703          	ld	a4,280(s0)
ffffffffc0200976:	47bd                	li	a5,15
ffffffffc0200978:	02f70663          	beq	a4,a5,ffffffffc02009a4 <pgfault_handler+0x114>
ffffffffc020097c:	05200693          	li	a3,82
ffffffffc0200980:	00007517          	auipc	a0,0x7
ffffffffc0200984:	91850513          	addi	a0,a0,-1768 # ffffffffc0207298 <commands+0x418>
ffffffffc0200988:	ffcff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020098c:	00007617          	auipc	a2,0x7
ffffffffc0200990:	97460613          	addi	a2,a2,-1676 # ffffffffc0207300 <commands+0x480>
ffffffffc0200994:	07300593          	li	a1,115
ffffffffc0200998:	00007517          	auipc	a0,0x7
ffffffffc020099c:	95050513          	addi	a0,a0,-1712 # ffffffffc02072e8 <commands+0x468>
ffffffffc02009a0:	adfff0ef          	jal	ra,ffffffffc020047e <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009a4:	05700693          	li	a3,87
ffffffffc02009a8:	bfe1                	j	ffffffffc0200980 <pgfault_handler+0xf0>

ffffffffc02009aa <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009aa:	11853783          	ld	a5,280(a0)
ffffffffc02009ae:	472d                	li	a4,11
ffffffffc02009b0:	0786                	slli	a5,a5,0x1
ffffffffc02009b2:	8385                	srli	a5,a5,0x1
ffffffffc02009b4:	06f76d63          	bltu	a4,a5,ffffffffc0200a2e <interrupt_handler+0x84>
ffffffffc02009b8:	00007717          	auipc	a4,0x7
ffffffffc02009bc:	a0070713          	addi	a4,a4,-1536 # ffffffffc02073b8 <commands+0x538>
ffffffffc02009c0:	078a                	slli	a5,a5,0x2
ffffffffc02009c2:	97ba                	add	a5,a5,a4
ffffffffc02009c4:	439c                	lw	a5,0(a5)
ffffffffc02009c6:	97ba                	add	a5,a5,a4
ffffffffc02009c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ca:	00007517          	auipc	a0,0x7
ffffffffc02009ce:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207378 <commands+0x4f8>
ffffffffc02009d2:	fb2ff06f          	j	ffffffffc0200184 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009d6:	00007517          	auipc	a0,0x7
ffffffffc02009da:	98250513          	addi	a0,a0,-1662 # ffffffffc0207358 <commands+0x4d8>
ffffffffc02009de:	fa6ff06f          	j	ffffffffc0200184 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e2:	00007517          	auipc	a0,0x7
ffffffffc02009e6:	93650513          	addi	a0,a0,-1738 # ffffffffc0207318 <commands+0x498>
ffffffffc02009ea:	f9aff06f          	j	ffffffffc0200184 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009ee:	00007517          	auipc	a0,0x7
ffffffffc02009f2:	94a50513          	addi	a0,a0,-1718 # ffffffffc0207338 <commands+0x4b8>
ffffffffc02009f6:	f8eff06f          	j	ffffffffc0200184 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009fa:	1141                	addi	sp,sp,-16
ffffffffc02009fc:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009fe:	b5dff0ef          	jal	ra,ffffffffc020055a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a02:	000ce717          	auipc	a4,0xce
ffffffffc0200a06:	53e70713          	addi	a4,a4,1342 # ffffffffc02cef40 <ticks>
ffffffffc0200a0a:	631c                	ld	a5,0(a4)
                //print_ticks()
            }
            if (current){
ffffffffc0200a0c:	000ce517          	auipc	a0,0xce
ffffffffc0200a10:	59c53503          	ld	a0,1436(a0) # ffffffffc02cefa8 <current>
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a14:	0785                	addi	a5,a5,1
ffffffffc0200a16:	e31c                	sd	a5,0(a4)
            if (current){
ffffffffc0200a18:	cd01                	beqz	a0,ffffffffc0200a30 <interrupt_handler+0x86>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a1a:	60a2                	ld	ra,8(sp)
ffffffffc0200a1c:	0141                	addi	sp,sp,16
                sched_class_proc_tick(current); 
ffffffffc0200a1e:	2610506f          	j	ffffffffc020647e <sched_class_proc_tick>
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a22:	00007517          	auipc	a0,0x7
ffffffffc0200a26:	97650513          	addi	a0,a0,-1674 # ffffffffc0207398 <commands+0x518>
ffffffffc0200a2a:	f5aff06f          	j	ffffffffc0200184 <cprintf>
            print_trapframe(tf);
ffffffffc0200a2e:	b501                	j	ffffffffc020082e <print_trapframe>
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret

ffffffffc0200a36 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a36:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a3a:	1101                	addi	sp,sp,-32
ffffffffc0200a3c:	e822                	sd	s0,16(sp)
ffffffffc0200a3e:	ec06                	sd	ra,24(sp)
ffffffffc0200a40:	e426                	sd	s1,8(sp)
ffffffffc0200a42:	473d                	li	a4,15
ffffffffc0200a44:	842a                	mv	s0,a0
ffffffffc0200a46:	18f76563          	bltu	a4,a5,ffffffffc0200bd0 <exception_handler+0x19a>
ffffffffc0200a4a:	00007717          	auipc	a4,0x7
ffffffffc0200a4e:	b3670713          	addi	a4,a4,-1226 # ffffffffc0207580 <commands+0x700>
ffffffffc0200a52:	078a                	slli	a5,a5,0x2
ffffffffc0200a54:	97ba                	add	a5,a5,a4
ffffffffc0200a56:	439c                	lw	a5,0(a5)
ffffffffc0200a58:	97ba                	add	a5,a5,a4
ffffffffc0200a5a:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a5c:	00007517          	auipc	a0,0x7
ffffffffc0200a60:	a7c50513          	addi	a0,a0,-1412 # ffffffffc02074d8 <commands+0x658>
ffffffffc0200a64:	f20ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            tf->epc += 4;
ffffffffc0200a68:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a6c:	60e2                	ld	ra,24(sp)
ffffffffc0200a6e:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a70:	0791                	addi	a5,a5,4
ffffffffc0200a72:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a76:	6442                	ld	s0,16(sp)
ffffffffc0200a78:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a7a:	46f0506f          	j	ffffffffc02066e8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a7e:	00007517          	auipc	a0,0x7
ffffffffc0200a82:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02074f8 <commands+0x678>
}
ffffffffc0200a86:	6442                	ld	s0,16(sp)
ffffffffc0200a88:	60e2                	ld	ra,24(sp)
ffffffffc0200a8a:	64a2                	ld	s1,8(sp)
ffffffffc0200a8c:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a8e:	ef6ff06f          	j	ffffffffc0200184 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a92:	00007517          	auipc	a0,0x7
ffffffffc0200a96:	a8650513          	addi	a0,a0,-1402 # ffffffffc0207518 <commands+0x698>
ffffffffc0200a9a:	b7f5                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a9c:	00007517          	auipc	a0,0x7
ffffffffc0200aa0:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0207538 <commands+0x6b8>
ffffffffc0200aa4:	b7cd                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200aa6:	00007517          	auipc	a0,0x7
ffffffffc0200aaa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0207550 <commands+0x6d0>
ffffffffc0200aae:	ed6ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ab2:	8522                	mv	a0,s0
ffffffffc0200ab4:	dddff0ef          	jal	ra,ffffffffc0200890 <pgfault_handler>
ffffffffc0200ab8:	84aa                	mv	s1,a0
ffffffffc0200aba:	12051d63          	bnez	a0,ffffffffc0200bf4 <exception_handler+0x1be>
}
ffffffffc0200abe:	60e2                	ld	ra,24(sp)
ffffffffc0200ac0:	6442                	ld	s0,16(sp)
ffffffffc0200ac2:	64a2                	ld	s1,8(sp)
ffffffffc0200ac4:	6105                	addi	sp,sp,32
ffffffffc0200ac6:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ac8:	00007517          	auipc	a0,0x7
ffffffffc0200acc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0207568 <commands+0x6e8>
ffffffffc0200ad0:	eb4ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad4:	8522                	mv	a0,s0
ffffffffc0200ad6:	dbbff0ef          	jal	ra,ffffffffc0200890 <pgfault_handler>
ffffffffc0200ada:	84aa                	mv	s1,a0
ffffffffc0200adc:	d16d                	beqz	a0,ffffffffc0200abe <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ade:	8522                	mv	a0,s0
ffffffffc0200ae0:	d4fff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ae4:	86a6                	mv	a3,s1
ffffffffc0200ae6:	00007617          	auipc	a2,0x7
ffffffffc0200aea:	9a260613          	addi	a2,a2,-1630 # ffffffffc0207488 <commands+0x608>
ffffffffc0200aee:	0fb00593          	li	a1,251
ffffffffc0200af2:	00006517          	auipc	a0,0x6
ffffffffc0200af6:	7f650513          	addi	a0,a0,2038 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200afa:	985ff0ef          	jal	ra,ffffffffc020047e <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200afe:	00007517          	auipc	a0,0x7
ffffffffc0200b02:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02073e8 <commands+0x568>
ffffffffc0200b06:	b741                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b08:	00007517          	auipc	a0,0x7
ffffffffc0200b0c:	90050513          	addi	a0,a0,-1792 # ffffffffc0207408 <commands+0x588>
ffffffffc0200b10:	bf9d                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b12:	00007517          	auipc	a0,0x7
ffffffffc0200b16:	91650513          	addi	a0,a0,-1770 # ffffffffc0207428 <commands+0x5a8>
ffffffffc0200b1a:	b7b5                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b1c:	00007517          	auipc	a0,0x7
ffffffffc0200b20:	92450513          	addi	a0,a0,-1756 # ffffffffc0207440 <commands+0x5c0>
ffffffffc0200b24:	e60ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b28:	6458                	ld	a4,136(s0)
ffffffffc0200b2a:	47a9                	li	a5,10
ffffffffc0200b2c:	f8f719e3          	bne	a4,a5,ffffffffc0200abe <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b30:	10843783          	ld	a5,264(s0)
ffffffffc0200b34:	0791                	addi	a5,a5,4
ffffffffc0200b36:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b3a:	3af050ef          	jal	ra,ffffffffc02066e8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3e:	000ce797          	auipc	a5,0xce
ffffffffc0200b42:	46a7b783          	ld	a5,1130(a5) # ffffffffc02cefa8 <current>
ffffffffc0200b46:	6b9c                	ld	a5,16(a5)
ffffffffc0200b48:	8522                	mv	a0,s0
}
ffffffffc0200b4a:	6442                	ld	s0,16(sp)
ffffffffc0200b4c:	60e2                	ld	ra,24(sp)
ffffffffc0200b4e:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b50:	6589                	lui	a1,0x2
ffffffffc0200b52:	95be                	add	a1,a1,a5
}
ffffffffc0200b54:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b56:	ac21                	j	ffffffffc0200d6e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b58:	00007517          	auipc	a0,0x7
ffffffffc0200b5c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0207450 <commands+0x5d0>
ffffffffc0200b60:	b71d                	j	ffffffffc0200a86 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b62:	00007517          	auipc	a0,0x7
ffffffffc0200b66:	90e50513          	addi	a0,a0,-1778 # ffffffffc0207470 <commands+0x5f0>
ffffffffc0200b6a:	e1aff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b6e:	8522                	mv	a0,s0
ffffffffc0200b70:	d21ff0ef          	jal	ra,ffffffffc0200890 <pgfault_handler>
ffffffffc0200b74:	84aa                	mv	s1,a0
ffffffffc0200b76:	d521                	beqz	a0,ffffffffc0200abe <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b78:	8522                	mv	a0,s0
ffffffffc0200b7a:	cb5ff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b7e:	86a6                	mv	a3,s1
ffffffffc0200b80:	00007617          	auipc	a2,0x7
ffffffffc0200b84:	90860613          	addi	a2,a2,-1784 # ffffffffc0207488 <commands+0x608>
ffffffffc0200b88:	0d000593          	li	a1,208
ffffffffc0200b8c:	00006517          	auipc	a0,0x6
ffffffffc0200b90:	75c50513          	addi	a0,a0,1884 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200b94:	8ebff0ef          	jal	ra,ffffffffc020047e <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b98:	00007517          	auipc	a0,0x7
ffffffffc0200b9c:	92850513          	addi	a0,a0,-1752 # ffffffffc02074c0 <commands+0x640>
ffffffffc0200ba0:	de4ff0ef          	jal	ra,ffffffffc0200184 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba4:	8522                	mv	a0,s0
ffffffffc0200ba6:	cebff0ef          	jal	ra,ffffffffc0200890 <pgfault_handler>
ffffffffc0200baa:	84aa                	mv	s1,a0
ffffffffc0200bac:	f00509e3          	beqz	a0,ffffffffc0200abe <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c7dff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00007617          	auipc	a2,0x7
ffffffffc0200bbc:	8d060613          	addi	a2,a2,-1840 # ffffffffc0207488 <commands+0x608>
ffffffffc0200bc0:	0da00593          	li	a1,218
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	72450513          	addi	a0,a0,1828 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200bcc:	8b3ff0ef          	jal	ra,ffffffffc020047e <__panic>
            print_trapframe(tf);
ffffffffc0200bd0:	8522                	mv	a0,s0
}
ffffffffc0200bd2:	6442                	ld	s0,16(sp)
ffffffffc0200bd4:	60e2                	ld	ra,24(sp)
ffffffffc0200bd6:	64a2                	ld	s1,8(sp)
ffffffffc0200bd8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bda:	b991                	j	ffffffffc020082e <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bdc:	00007617          	auipc	a2,0x7
ffffffffc0200be0:	8cc60613          	addi	a2,a2,-1844 # ffffffffc02074a8 <commands+0x628>
ffffffffc0200be4:	0d400593          	li	a1,212
ffffffffc0200be8:	00006517          	auipc	a0,0x6
ffffffffc0200bec:	70050513          	addi	a0,a0,1792 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200bf0:	88fff0ef          	jal	ra,ffffffffc020047e <__panic>
                print_trapframe(tf);
ffffffffc0200bf4:	8522                	mv	a0,s0
ffffffffc0200bf6:	c39ff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bfa:	86a6                	mv	a3,s1
ffffffffc0200bfc:	00007617          	auipc	a2,0x7
ffffffffc0200c00:	88c60613          	addi	a2,a2,-1908 # ffffffffc0207488 <commands+0x608>
ffffffffc0200c04:	0f400593          	li	a1,244
ffffffffc0200c08:	00006517          	auipc	a0,0x6
ffffffffc0200c0c:	6e050513          	addi	a0,a0,1760 # ffffffffc02072e8 <commands+0x468>
ffffffffc0200c10:	86fff0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0200c14 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c14:	1101                	addi	sp,sp,-32
ffffffffc0200c16:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c18:	000ce417          	auipc	s0,0xce
ffffffffc0200c1c:	39040413          	addi	s0,s0,912 # ffffffffc02cefa8 <current>
ffffffffc0200c20:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c22:	ec06                	sd	ra,24(sp)
ffffffffc0200c24:	e426                	sd	s1,8(sp)
ffffffffc0200c26:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c28:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c2c:	cf1d                	beqz	a4,ffffffffc0200c6a <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c2e:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c32:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c36:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c38:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c3c:	0206c463          	bltz	a3,ffffffffc0200c64 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c40:	df7ff0ef          	jal	ra,ffffffffc0200a36 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c44:	601c                	ld	a5,0(s0)
ffffffffc0200c46:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c4a:	e499                	bnez	s1,ffffffffc0200c58 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c4c:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c50:	8b05                	andi	a4,a4,1
ffffffffc0200c52:	e329                	bnez	a4,ffffffffc0200c94 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c54:	6f9c                	ld	a5,24(a5)
ffffffffc0200c56:	eb85                	bnez	a5,ffffffffc0200c86 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c58:	60e2                	ld	ra,24(sp)
ffffffffc0200c5a:	6442                	ld	s0,16(sp)
ffffffffc0200c5c:	64a2                	ld	s1,8(sp)
ffffffffc0200c5e:	6902                	ld	s2,0(sp)
ffffffffc0200c60:	6105                	addi	sp,sp,32
ffffffffc0200c62:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c64:	d47ff0ef          	jal	ra,ffffffffc02009aa <interrupt_handler>
ffffffffc0200c68:	bff1                	j	ffffffffc0200c44 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6a:	0006c863          	bltz	a3,ffffffffc0200c7a <trap+0x66>
}
ffffffffc0200c6e:	6442                	ld	s0,16(sp)
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	64a2                	ld	s1,8(sp)
ffffffffc0200c74:	6902                	ld	s2,0(sp)
ffffffffc0200c76:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c78:	bb7d                	j	ffffffffc0200a36 <exception_handler>
}
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6902                	ld	s2,0(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c84:	b31d                	j	ffffffffc02009aa <interrupt_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c90:	11b0506f          	j	ffffffffc02065aa <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c94:	555d                	li	a0,-9
ffffffffc0200c96:	694040ef          	jal	ra,ffffffffc020532a <do_exit>
            if (current->need_resched) {
ffffffffc0200c9a:	601c                	ld	a5,0(s0)
ffffffffc0200c9c:	bf65                	j	ffffffffc0200c54 <trap+0x40>
	...

ffffffffc0200ca0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ca0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ca4:	00011463          	bnez	sp,ffffffffc0200cac <__alltraps+0xc>
ffffffffc0200ca8:	14002173          	csrr	sp,sscratch
ffffffffc0200cac:	712d                	addi	sp,sp,-288
ffffffffc0200cae:	e002                	sd	zero,0(sp)
ffffffffc0200cb0:	e406                	sd	ra,8(sp)
ffffffffc0200cb2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cb4:	f012                	sd	tp,32(sp)
ffffffffc0200cb6:	f416                	sd	t0,40(sp)
ffffffffc0200cb8:	f81a                	sd	t1,48(sp)
ffffffffc0200cba:	fc1e                	sd	t2,56(sp)
ffffffffc0200cbc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cbe:	e4a6                	sd	s1,72(sp)
ffffffffc0200cc0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cc2:	ecae                	sd	a1,88(sp)
ffffffffc0200cc4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cc6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cc8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cca:	fcbe                	sd	a5,120(sp)
ffffffffc0200ccc:	e142                	sd	a6,128(sp)
ffffffffc0200cce:	e546                	sd	a7,136(sp)
ffffffffc0200cd0:	e94a                	sd	s2,144(sp)
ffffffffc0200cd2:	ed4e                	sd	s3,152(sp)
ffffffffc0200cd4:	f152                	sd	s4,160(sp)
ffffffffc0200cd6:	f556                	sd	s5,168(sp)
ffffffffc0200cd8:	f95a                	sd	s6,176(sp)
ffffffffc0200cda:	fd5e                	sd	s7,184(sp)
ffffffffc0200cdc:	e1e2                	sd	s8,192(sp)
ffffffffc0200cde:	e5e6                	sd	s9,200(sp)
ffffffffc0200ce0:	e9ea                	sd	s10,208(sp)
ffffffffc0200ce2:	edee                	sd	s11,216(sp)
ffffffffc0200ce4:	f1f2                	sd	t3,224(sp)
ffffffffc0200ce6:	f5f6                	sd	t4,232(sp)
ffffffffc0200ce8:	f9fa                	sd	t5,240(sp)
ffffffffc0200cea:	fdfe                	sd	t6,248(sp)
ffffffffc0200cec:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cf0:	100024f3          	csrr	s1,sstatus
ffffffffc0200cf4:	14102973          	csrr	s2,sepc
ffffffffc0200cf8:	143029f3          	csrr	s3,stval
ffffffffc0200cfc:	14202a73          	csrr	s4,scause
ffffffffc0200d00:	e822                	sd	s0,16(sp)
ffffffffc0200d02:	e226                	sd	s1,256(sp)
ffffffffc0200d04:	e64a                	sd	s2,264(sp)
ffffffffc0200d06:	ea4e                	sd	s3,272(sp)
ffffffffc0200d08:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d0a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d0c:	f09ff0ef          	jal	ra,ffffffffc0200c14 <trap>

ffffffffc0200d10 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d10:	6492                	ld	s1,256(sp)
ffffffffc0200d12:	6932                	ld	s2,264(sp)
ffffffffc0200d14:	1004f413          	andi	s0,s1,256
ffffffffc0200d18:	e401                	bnez	s0,ffffffffc0200d20 <__trapret+0x10>
ffffffffc0200d1a:	1200                	addi	s0,sp,288
ffffffffc0200d1c:	14041073          	csrw	sscratch,s0
ffffffffc0200d20:	10049073          	csrw	sstatus,s1
ffffffffc0200d24:	14191073          	csrw	sepc,s2
ffffffffc0200d28:	60a2                	ld	ra,8(sp)
ffffffffc0200d2a:	61e2                	ld	gp,24(sp)
ffffffffc0200d2c:	7202                	ld	tp,32(sp)
ffffffffc0200d2e:	72a2                	ld	t0,40(sp)
ffffffffc0200d30:	7342                	ld	t1,48(sp)
ffffffffc0200d32:	73e2                	ld	t2,56(sp)
ffffffffc0200d34:	6406                	ld	s0,64(sp)
ffffffffc0200d36:	64a6                	ld	s1,72(sp)
ffffffffc0200d38:	6546                	ld	a0,80(sp)
ffffffffc0200d3a:	65e6                	ld	a1,88(sp)
ffffffffc0200d3c:	7606                	ld	a2,96(sp)
ffffffffc0200d3e:	76a6                	ld	a3,104(sp)
ffffffffc0200d40:	7746                	ld	a4,112(sp)
ffffffffc0200d42:	77e6                	ld	a5,120(sp)
ffffffffc0200d44:	680a                	ld	a6,128(sp)
ffffffffc0200d46:	68aa                	ld	a7,136(sp)
ffffffffc0200d48:	694a                	ld	s2,144(sp)
ffffffffc0200d4a:	69ea                	ld	s3,152(sp)
ffffffffc0200d4c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d4e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d50:	7b4a                	ld	s6,176(sp)
ffffffffc0200d52:	7bea                	ld	s7,184(sp)
ffffffffc0200d54:	6c0e                	ld	s8,192(sp)
ffffffffc0200d56:	6cae                	ld	s9,200(sp)
ffffffffc0200d58:	6d4e                	ld	s10,208(sp)
ffffffffc0200d5a:	6dee                	ld	s11,216(sp)
ffffffffc0200d5c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d5e:	7eae                	ld	t4,232(sp)
ffffffffc0200d60:	7f4e                	ld	t5,240(sp)
ffffffffc0200d62:	7fee                	ld	t6,248(sp)
ffffffffc0200d64:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d66:	10200073          	sret

ffffffffc0200d6a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d6a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d6c:	b755                	j	ffffffffc0200d10 <__trapret>

ffffffffc0200d6e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d6e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8088>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d72:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d76:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d7a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d7e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d82:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d86:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d8a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d8e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d92:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d94:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d96:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d98:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d9a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d9c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d9e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200da0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200da2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200da4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200da6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200da8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200daa:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dac:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dae:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200db0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200db2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200db4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200db6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200db8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dba:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dbc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dbe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dc0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dc2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dc4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dc6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dc8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dca:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dcc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dce:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dd0:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dd2:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dd4:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dd6:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dd8:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dda:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200ddc:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dde:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200de0:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200de2:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200de4:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200de6:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200de8:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dea:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dec:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dee:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200df0:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200df2:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200df4:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200df6:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200df8:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dfa:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200dfc:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200dfe:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e00:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e02:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e04:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e06:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e08:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e0a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e0c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e0e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e10:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e12:	812e                	mv	sp,a1
ffffffffc0200e14:	bdf5                	j	ffffffffc0200d10 <__trapret>

ffffffffc0200e16 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e16:	000ca797          	auipc	a5,0xca
ffffffffc0200e1a:	02a78793          	addi	a5,a5,42 # ffffffffc02cae40 <free_area>
ffffffffc0200e1e:	e79c                	sd	a5,8(a5)
ffffffffc0200e20:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e22:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e26:	8082                	ret

ffffffffc0200e28 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e28:	000ca517          	auipc	a0,0xca
ffffffffc0200e2c:	02856503          	lwu	a0,40(a0) # ffffffffc02cae50 <free_area+0x10>
ffffffffc0200e30:	8082                	ret

ffffffffc0200e32 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e32:	715d                	addi	sp,sp,-80
ffffffffc0200e34:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e36:	000ca417          	auipc	s0,0xca
ffffffffc0200e3a:	00a40413          	addi	s0,s0,10 # ffffffffc02cae40 <free_area>
ffffffffc0200e3e:	641c                	ld	a5,8(s0)
ffffffffc0200e40:	e486                	sd	ra,72(sp)
ffffffffc0200e42:	fc26                	sd	s1,56(sp)
ffffffffc0200e44:	f84a                	sd	s2,48(sp)
ffffffffc0200e46:	f44e                	sd	s3,40(sp)
ffffffffc0200e48:	f052                	sd	s4,32(sp)
ffffffffc0200e4a:	ec56                	sd	s5,24(sp)
ffffffffc0200e4c:	e85a                	sd	s6,16(sp)
ffffffffc0200e4e:	e45e                	sd	s7,8(sp)
ffffffffc0200e50:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e52:	2a878d63          	beq	a5,s0,ffffffffc020110c <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e56:	4481                	li	s1,0
ffffffffc0200e58:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e5a:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e5e:	8b09                	andi	a4,a4,2
ffffffffc0200e60:	2a070a63          	beqz	a4,ffffffffc0201114 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e64:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e68:	679c                	ld	a5,8(a5)
ffffffffc0200e6a:	2905                	addiw	s2,s2,1
ffffffffc0200e6c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e6e:	fe8796e3          	bne	a5,s0,ffffffffc0200e5a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e72:	89a6                	mv	s3,s1
ffffffffc0200e74:	733000ef          	jal	ra,ffffffffc0201da6 <nr_free_pages>
ffffffffc0200e78:	6f351e63          	bne	a0,s3,ffffffffc0201574 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	657000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200e82:	8aaa                	mv	s5,a0
ffffffffc0200e84:	42050863          	beqz	a0,ffffffffc02012b4 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	64b000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200e8e:	89aa                	mv	s3,a0
ffffffffc0200e90:	70050263          	beqz	a0,ffffffffc0201594 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e94:	4505                	li	a0,1
ffffffffc0200e96:	63f000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200e9a:	8a2a                	mv	s4,a0
ffffffffc0200e9c:	48050c63          	beqz	a0,ffffffffc0201334 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ea0:	293a8a63          	beq	s5,s3,ffffffffc0201134 <default_check+0x302>
ffffffffc0200ea4:	28aa8863          	beq	s5,a0,ffffffffc0201134 <default_check+0x302>
ffffffffc0200ea8:	28a98663          	beq	s3,a0,ffffffffc0201134 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eac:	000aa783          	lw	a5,0(s5)
ffffffffc0200eb0:	2a079263          	bnez	a5,ffffffffc0201154 <default_check+0x322>
ffffffffc0200eb4:	0009a783          	lw	a5,0(s3)
ffffffffc0200eb8:	28079e63          	bnez	a5,ffffffffc0201154 <default_check+0x322>
ffffffffc0200ebc:	411c                	lw	a5,0(a0)
ffffffffc0200ebe:	28079b63          	bnez	a5,ffffffffc0201154 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ec2:	000ce797          	auipc	a5,0xce
ffffffffc0200ec6:	0a67b783          	ld	a5,166(a5) # ffffffffc02cef68 <pages>
ffffffffc0200eca:	40fa8733          	sub	a4,s5,a5
ffffffffc0200ece:	00009617          	auipc	a2,0x9
ffffffffc0200ed2:	ba263603          	ld	a2,-1118(a2) # ffffffffc0209a70 <nbase>
ffffffffc0200ed6:	8719                	srai	a4,a4,0x6
ffffffffc0200ed8:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eda:	000ce697          	auipc	a3,0xce
ffffffffc0200ede:	0866b683          	ld	a3,134(a3) # ffffffffc02cef60 <npage>
ffffffffc0200ee2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee4:	0732                	slli	a4,a4,0xc
ffffffffc0200ee6:	28d77763          	bgeu	a4,a3,ffffffffc0201174 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200eea:	40f98733          	sub	a4,s3,a5
ffffffffc0200eee:	8719                	srai	a4,a4,0x6
ffffffffc0200ef0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ef4:	4cd77063          	bgeu	a4,a3,ffffffffc02013b4 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200ef8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200efc:	8799                	srai	a5,a5,0x6
ffffffffc0200efe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f00:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f02:	30d7f963          	bgeu	a5,a3,ffffffffc0201214 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200f06:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f08:	00043c03          	ld	s8,0(s0)
ffffffffc0200f0c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f10:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200f14:	e400                	sd	s0,8(s0)
ffffffffc0200f16:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f18:	000ca797          	auipc	a5,0xca
ffffffffc0200f1c:	f207ac23          	sw	zero,-200(a5) # ffffffffc02cae50 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f20:	5b5000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f24:	2c051863          	bnez	a0,ffffffffc02011f4 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f28:	4585                	li	a1,1
ffffffffc0200f2a:	8556                	mv	a0,s5
ffffffffc0200f2c:	63b000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_page(p1);
ffffffffc0200f30:	4585                	li	a1,1
ffffffffc0200f32:	854e                	mv	a0,s3
ffffffffc0200f34:	633000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_page(p2);
ffffffffc0200f38:	4585                	li	a1,1
ffffffffc0200f3a:	8552                	mv	a0,s4
ffffffffc0200f3c:	62b000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f40:	4818                	lw	a4,16(s0)
ffffffffc0200f42:	478d                	li	a5,3
ffffffffc0200f44:	28f71863          	bne	a4,a5,ffffffffc02011d4 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f48:	4505                	li	a0,1
ffffffffc0200f4a:	58b000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f4e:	89aa                	mv	s3,a0
ffffffffc0200f50:	26050263          	beqz	a0,ffffffffc02011b4 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	57f000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f5a:	8aaa                	mv	s5,a0
ffffffffc0200f5c:	3a050c63          	beqz	a0,ffffffffc0201314 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f60:	4505                	li	a0,1
ffffffffc0200f62:	573000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f66:	8a2a                	mv	s4,a0
ffffffffc0200f68:	38050663          	beqz	a0,ffffffffc02012f4 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	567000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f72:	36051163          	bnez	a0,ffffffffc02012d4 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f76:	4585                	li	a1,1
ffffffffc0200f78:	854e                	mv	a0,s3
ffffffffc0200f7a:	5ed000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f7e:	641c                	ld	a5,8(s0)
ffffffffc0200f80:	20878a63          	beq	a5,s0,ffffffffc0201194 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f84:	4505                	li	a0,1
ffffffffc0200f86:	54f000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f8a:	30a99563          	bne	s3,a0,ffffffffc0201294 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f8e:	4505                	li	a0,1
ffffffffc0200f90:	545000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200f94:	2e051063          	bnez	a0,ffffffffc0201274 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200f98:	481c                	lw	a5,16(s0)
ffffffffc0200f9a:	2a079d63          	bnez	a5,ffffffffc0201254 <default_check+0x422>
    free_page(p);
ffffffffc0200f9e:	854e                	mv	a0,s3
ffffffffc0200fa0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fa2:	01843023          	sd	s8,0(s0)
ffffffffc0200fa6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200faa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200fae:	5b9000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_page(p1);
ffffffffc0200fb2:	4585                	li	a1,1
ffffffffc0200fb4:	8556                	mv	a0,s5
ffffffffc0200fb6:	5b1000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_page(p2);
ffffffffc0200fba:	4585                	li	a1,1
ffffffffc0200fbc:	8552                	mv	a0,s4
ffffffffc0200fbe:	5a9000ef          	jal	ra,ffffffffc0201d66 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fc2:	4515                	li	a0,5
ffffffffc0200fc4:	511000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200fc8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fca:	26050563          	beqz	a0,ffffffffc0201234 <default_check+0x402>
ffffffffc0200fce:	651c                	ld	a5,8(a0)
ffffffffc0200fd0:	8385                	srli	a5,a5,0x1
ffffffffc0200fd2:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fd4:	54079063          	bnez	a5,ffffffffc0201514 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fd8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fda:	00043b03          	ld	s6,0(s0)
ffffffffc0200fde:	00843a83          	ld	s5,8(s0)
ffffffffc0200fe2:	e000                	sd	s0,0(s0)
ffffffffc0200fe4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fe6:	4ef000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0200fea:	50051563          	bnez	a0,ffffffffc02014f4 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fee:	08098a13          	addi	s4,s3,128
ffffffffc0200ff2:	8552                	mv	a0,s4
ffffffffc0200ff4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ff6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200ffa:	000ca797          	auipc	a5,0xca
ffffffffc0200ffe:	e407ab23          	sw	zero,-426(a5) # ffffffffc02cae50 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201002:	565000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201006:	4511                	li	a0,4
ffffffffc0201008:	4cd000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc020100c:	4c051463          	bnez	a0,ffffffffc02014d4 <default_check+0x6a2>
ffffffffc0201010:	0889b783          	ld	a5,136(s3)
ffffffffc0201014:	8385                	srli	a5,a5,0x1
ffffffffc0201016:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201018:	48078e63          	beqz	a5,ffffffffc02014b4 <default_check+0x682>
ffffffffc020101c:	0909a703          	lw	a4,144(s3)
ffffffffc0201020:	478d                	li	a5,3
ffffffffc0201022:	48f71963          	bne	a4,a5,ffffffffc02014b4 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201026:	450d                	li	a0,3
ffffffffc0201028:	4ad000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc020102c:	8c2a                	mv	s8,a0
ffffffffc020102e:	46050363          	beqz	a0,ffffffffc0201494 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201032:	4505                	li	a0,1
ffffffffc0201034:	4a1000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0201038:	42051e63          	bnez	a0,ffffffffc0201474 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020103c:	418a1c63          	bne	s4,s8,ffffffffc0201454 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201040:	4585                	li	a1,1
ffffffffc0201042:	854e                	mv	a0,s3
ffffffffc0201044:	523000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_pages(p1, 3);
ffffffffc0201048:	458d                	li	a1,3
ffffffffc020104a:	8552                	mv	a0,s4
ffffffffc020104c:	51b000ef          	jal	ra,ffffffffc0201d66 <free_pages>
ffffffffc0201050:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201054:	04098c13          	addi	s8,s3,64
ffffffffc0201058:	8385                	srli	a5,a5,0x1
ffffffffc020105a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020105c:	3c078c63          	beqz	a5,ffffffffc0201434 <default_check+0x602>
ffffffffc0201060:	0109a703          	lw	a4,16(s3)
ffffffffc0201064:	4785                	li	a5,1
ffffffffc0201066:	3cf71763          	bne	a4,a5,ffffffffc0201434 <default_check+0x602>
ffffffffc020106a:	008a3783          	ld	a5,8(s4)
ffffffffc020106e:	8385                	srli	a5,a5,0x1
ffffffffc0201070:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201072:	3a078163          	beqz	a5,ffffffffc0201414 <default_check+0x5e2>
ffffffffc0201076:	010a2703          	lw	a4,16(s4)
ffffffffc020107a:	478d                	li	a5,3
ffffffffc020107c:	38f71c63          	bne	a4,a5,ffffffffc0201414 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201080:	4505                	li	a0,1
ffffffffc0201082:	453000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0201086:	36a99763          	bne	s3,a0,ffffffffc02013f4 <default_check+0x5c2>
    free_page(p0);
ffffffffc020108a:	4585                	li	a1,1
ffffffffc020108c:	4db000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201090:	4509                	li	a0,2
ffffffffc0201092:	443000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0201096:	32aa1f63          	bne	s4,a0,ffffffffc02013d4 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020109a:	4589                	li	a1,2
ffffffffc020109c:	4cb000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    free_page(p2);
ffffffffc02010a0:	4585                	li	a1,1
ffffffffc02010a2:	8562                	mv	a0,s8
ffffffffc02010a4:	4c3000ef          	jal	ra,ffffffffc0201d66 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010a8:	4515                	li	a0,5
ffffffffc02010aa:	42b000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc02010ae:	89aa                	mv	s3,a0
ffffffffc02010b0:	48050263          	beqz	a0,ffffffffc0201534 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02010b4:	4505                	li	a0,1
ffffffffc02010b6:	41f000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc02010ba:	2c051d63          	bnez	a0,ffffffffc0201394 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010be:	481c                	lw	a5,16(s0)
ffffffffc02010c0:	2a079a63          	bnez	a5,ffffffffc0201374 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010c4:	4595                	li	a1,5
ffffffffc02010c6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010c8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010cc:	01643023          	sd	s6,0(s0)
ffffffffc02010d0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010d4:	493000ef          	jal	ra,ffffffffc0201d66 <free_pages>
    return listelm->next;
ffffffffc02010d8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010da:	00878963          	beq	a5,s0,ffffffffc02010ec <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010de:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010e2:	679c                	ld	a5,8(a5)
ffffffffc02010e4:	397d                	addiw	s2,s2,-1
ffffffffc02010e6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e8:	fe879be3          	bne	a5,s0,ffffffffc02010de <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010ec:	26091463          	bnez	s2,ffffffffc0201354 <default_check+0x522>
    assert(total == 0);
ffffffffc02010f0:	46049263          	bnez	s1,ffffffffc0201554 <default_check+0x722>
}
ffffffffc02010f4:	60a6                	ld	ra,72(sp)
ffffffffc02010f6:	6406                	ld	s0,64(sp)
ffffffffc02010f8:	74e2                	ld	s1,56(sp)
ffffffffc02010fa:	7942                	ld	s2,48(sp)
ffffffffc02010fc:	79a2                	ld	s3,40(sp)
ffffffffc02010fe:	7a02                	ld	s4,32(sp)
ffffffffc0201100:	6ae2                	ld	s5,24(sp)
ffffffffc0201102:	6b42                	ld	s6,16(sp)
ffffffffc0201104:	6ba2                	ld	s7,8(sp)
ffffffffc0201106:	6c02                	ld	s8,0(sp)
ffffffffc0201108:	6161                	addi	sp,sp,80
ffffffffc020110a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020110c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020110e:	4481                	li	s1,0
ffffffffc0201110:	4901                	li	s2,0
ffffffffc0201112:	b38d                	j	ffffffffc0200e74 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201114:	00006697          	auipc	a3,0x6
ffffffffc0201118:	4ac68693          	addi	a3,a3,1196 # ffffffffc02075c0 <commands+0x740>
ffffffffc020111c:	00006617          	auipc	a2,0x6
ffffffffc0201120:	1b460613          	addi	a2,a2,436 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201124:	0ef00593          	li	a1,239
ffffffffc0201128:	00006517          	auipc	a0,0x6
ffffffffc020112c:	4a850513          	addi	a0,a0,1192 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201130:	b4eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201134:	00006697          	auipc	a3,0x6
ffffffffc0201138:	53468693          	addi	a3,a3,1332 # ffffffffc0207668 <commands+0x7e8>
ffffffffc020113c:	00006617          	auipc	a2,0x6
ffffffffc0201140:	19460613          	addi	a2,a2,404 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201144:	0bc00593          	li	a1,188
ffffffffc0201148:	00006517          	auipc	a0,0x6
ffffffffc020114c:	48850513          	addi	a0,a0,1160 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201150:	b2eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201154:	00006697          	auipc	a3,0x6
ffffffffc0201158:	53c68693          	addi	a3,a3,1340 # ffffffffc0207690 <commands+0x810>
ffffffffc020115c:	00006617          	auipc	a2,0x6
ffffffffc0201160:	17460613          	addi	a2,a2,372 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201164:	0bd00593          	li	a1,189
ffffffffc0201168:	00006517          	auipc	a0,0x6
ffffffffc020116c:	46850513          	addi	a0,a0,1128 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201170:	b0eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201174:	00006697          	auipc	a3,0x6
ffffffffc0201178:	55c68693          	addi	a3,a3,1372 # ffffffffc02076d0 <commands+0x850>
ffffffffc020117c:	00006617          	auipc	a2,0x6
ffffffffc0201180:	15460613          	addi	a2,a2,340 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201184:	0bf00593          	li	a1,191
ffffffffc0201188:	00006517          	auipc	a0,0x6
ffffffffc020118c:	44850513          	addi	a0,a0,1096 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201190:	aeeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201194:	00006697          	auipc	a3,0x6
ffffffffc0201198:	5c468693          	addi	a3,a3,1476 # ffffffffc0207758 <commands+0x8d8>
ffffffffc020119c:	00006617          	auipc	a2,0x6
ffffffffc02011a0:	13460613          	addi	a2,a2,308 # ffffffffc02072d0 <commands+0x450>
ffffffffc02011a4:	0d800593          	li	a1,216
ffffffffc02011a8:	00006517          	auipc	a0,0x6
ffffffffc02011ac:	42850513          	addi	a0,a0,1064 # ffffffffc02075d0 <commands+0x750>
ffffffffc02011b0:	aceff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011b4:	00006697          	auipc	a3,0x6
ffffffffc02011b8:	45468693          	addi	a3,a3,1108 # ffffffffc0207608 <commands+0x788>
ffffffffc02011bc:	00006617          	auipc	a2,0x6
ffffffffc02011c0:	11460613          	addi	a2,a2,276 # ffffffffc02072d0 <commands+0x450>
ffffffffc02011c4:	0d100593          	li	a1,209
ffffffffc02011c8:	00006517          	auipc	a0,0x6
ffffffffc02011cc:	40850513          	addi	a0,a0,1032 # ffffffffc02075d0 <commands+0x750>
ffffffffc02011d0:	aaeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free == 3);
ffffffffc02011d4:	00006697          	auipc	a3,0x6
ffffffffc02011d8:	57468693          	addi	a3,a3,1396 # ffffffffc0207748 <commands+0x8c8>
ffffffffc02011dc:	00006617          	auipc	a2,0x6
ffffffffc02011e0:	0f460613          	addi	a2,a2,244 # ffffffffc02072d0 <commands+0x450>
ffffffffc02011e4:	0cf00593          	li	a1,207
ffffffffc02011e8:	00006517          	auipc	a0,0x6
ffffffffc02011ec:	3e850513          	addi	a0,a0,1000 # ffffffffc02075d0 <commands+0x750>
ffffffffc02011f0:	a8eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011f4:	00006697          	auipc	a3,0x6
ffffffffc02011f8:	53c68693          	addi	a3,a3,1340 # ffffffffc0207730 <commands+0x8b0>
ffffffffc02011fc:	00006617          	auipc	a2,0x6
ffffffffc0201200:	0d460613          	addi	a2,a2,212 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201204:	0ca00593          	li	a1,202
ffffffffc0201208:	00006517          	auipc	a0,0x6
ffffffffc020120c:	3c850513          	addi	a0,a0,968 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201210:	a6eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201214:	00006697          	auipc	a3,0x6
ffffffffc0201218:	4fc68693          	addi	a3,a3,1276 # ffffffffc0207710 <commands+0x890>
ffffffffc020121c:	00006617          	auipc	a2,0x6
ffffffffc0201220:	0b460613          	addi	a2,a2,180 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201224:	0c100593          	li	a1,193
ffffffffc0201228:	00006517          	auipc	a0,0x6
ffffffffc020122c:	3a850513          	addi	a0,a0,936 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201230:	a4eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(p0 != NULL);
ffffffffc0201234:	00006697          	auipc	a3,0x6
ffffffffc0201238:	56c68693          	addi	a3,a3,1388 # ffffffffc02077a0 <commands+0x920>
ffffffffc020123c:	00006617          	auipc	a2,0x6
ffffffffc0201240:	09460613          	addi	a2,a2,148 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201244:	0f700593          	li	a1,247
ffffffffc0201248:	00006517          	auipc	a0,0x6
ffffffffc020124c:	38850513          	addi	a0,a0,904 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201250:	a2eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free == 0);
ffffffffc0201254:	00006697          	auipc	a3,0x6
ffffffffc0201258:	53c68693          	addi	a3,a3,1340 # ffffffffc0207790 <commands+0x910>
ffffffffc020125c:	00006617          	auipc	a2,0x6
ffffffffc0201260:	07460613          	addi	a2,a2,116 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201264:	0de00593          	li	a1,222
ffffffffc0201268:	00006517          	auipc	a0,0x6
ffffffffc020126c:	36850513          	addi	a0,a0,872 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201270:	a0eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201274:	00006697          	auipc	a3,0x6
ffffffffc0201278:	4bc68693          	addi	a3,a3,1212 # ffffffffc0207730 <commands+0x8b0>
ffffffffc020127c:	00006617          	auipc	a2,0x6
ffffffffc0201280:	05460613          	addi	a2,a2,84 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201284:	0dc00593          	li	a1,220
ffffffffc0201288:	00006517          	auipc	a0,0x6
ffffffffc020128c:	34850513          	addi	a0,a0,840 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201290:	9eeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201294:	00006697          	auipc	a3,0x6
ffffffffc0201298:	4dc68693          	addi	a3,a3,1244 # ffffffffc0207770 <commands+0x8f0>
ffffffffc020129c:	00006617          	auipc	a2,0x6
ffffffffc02012a0:	03460613          	addi	a2,a2,52 # ffffffffc02072d0 <commands+0x450>
ffffffffc02012a4:	0db00593          	li	a1,219
ffffffffc02012a8:	00006517          	auipc	a0,0x6
ffffffffc02012ac:	32850513          	addi	a0,a0,808 # ffffffffc02075d0 <commands+0x750>
ffffffffc02012b0:	9ceff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012b4:	00006697          	auipc	a3,0x6
ffffffffc02012b8:	35468693          	addi	a3,a3,852 # ffffffffc0207608 <commands+0x788>
ffffffffc02012bc:	00006617          	auipc	a2,0x6
ffffffffc02012c0:	01460613          	addi	a2,a2,20 # ffffffffc02072d0 <commands+0x450>
ffffffffc02012c4:	0b800593          	li	a1,184
ffffffffc02012c8:	00006517          	auipc	a0,0x6
ffffffffc02012cc:	30850513          	addi	a0,a0,776 # ffffffffc02075d0 <commands+0x750>
ffffffffc02012d0:	9aeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012d4:	00006697          	auipc	a3,0x6
ffffffffc02012d8:	45c68693          	addi	a3,a3,1116 # ffffffffc0207730 <commands+0x8b0>
ffffffffc02012dc:	00006617          	auipc	a2,0x6
ffffffffc02012e0:	ff460613          	addi	a2,a2,-12 # ffffffffc02072d0 <commands+0x450>
ffffffffc02012e4:	0d500593          	li	a1,213
ffffffffc02012e8:	00006517          	auipc	a0,0x6
ffffffffc02012ec:	2e850513          	addi	a0,a0,744 # ffffffffc02075d0 <commands+0x750>
ffffffffc02012f0:	98eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012f4:	00006697          	auipc	a3,0x6
ffffffffc02012f8:	35468693          	addi	a3,a3,852 # ffffffffc0207648 <commands+0x7c8>
ffffffffc02012fc:	00006617          	auipc	a2,0x6
ffffffffc0201300:	fd460613          	addi	a2,a2,-44 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201304:	0d300593          	li	a1,211
ffffffffc0201308:	00006517          	auipc	a0,0x6
ffffffffc020130c:	2c850513          	addi	a0,a0,712 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201310:	96eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201314:	00006697          	auipc	a3,0x6
ffffffffc0201318:	31468693          	addi	a3,a3,788 # ffffffffc0207628 <commands+0x7a8>
ffffffffc020131c:	00006617          	auipc	a2,0x6
ffffffffc0201320:	fb460613          	addi	a2,a2,-76 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201324:	0d200593          	li	a1,210
ffffffffc0201328:	00006517          	auipc	a0,0x6
ffffffffc020132c:	2a850513          	addi	a0,a0,680 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201330:	94eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201334:	00006697          	auipc	a3,0x6
ffffffffc0201338:	31468693          	addi	a3,a3,788 # ffffffffc0207648 <commands+0x7c8>
ffffffffc020133c:	00006617          	auipc	a2,0x6
ffffffffc0201340:	f9460613          	addi	a2,a2,-108 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201344:	0ba00593          	li	a1,186
ffffffffc0201348:	00006517          	auipc	a0,0x6
ffffffffc020134c:	28850513          	addi	a0,a0,648 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201350:	92eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(count == 0);
ffffffffc0201354:	00006697          	auipc	a3,0x6
ffffffffc0201358:	59c68693          	addi	a3,a3,1436 # ffffffffc02078f0 <commands+0xa70>
ffffffffc020135c:	00006617          	auipc	a2,0x6
ffffffffc0201360:	f7460613          	addi	a2,a2,-140 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201364:	12400593          	li	a1,292
ffffffffc0201368:	00006517          	auipc	a0,0x6
ffffffffc020136c:	26850513          	addi	a0,a0,616 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201370:	90eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free == 0);
ffffffffc0201374:	00006697          	auipc	a3,0x6
ffffffffc0201378:	41c68693          	addi	a3,a3,1052 # ffffffffc0207790 <commands+0x910>
ffffffffc020137c:	00006617          	auipc	a2,0x6
ffffffffc0201380:	f5460613          	addi	a2,a2,-172 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201384:	11900593          	li	a1,281
ffffffffc0201388:	00006517          	auipc	a0,0x6
ffffffffc020138c:	24850513          	addi	a0,a0,584 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201390:	8eeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201394:	00006697          	auipc	a3,0x6
ffffffffc0201398:	39c68693          	addi	a3,a3,924 # ffffffffc0207730 <commands+0x8b0>
ffffffffc020139c:	00006617          	auipc	a2,0x6
ffffffffc02013a0:	f3460613          	addi	a2,a2,-204 # ffffffffc02072d0 <commands+0x450>
ffffffffc02013a4:	11700593          	li	a1,279
ffffffffc02013a8:	00006517          	auipc	a0,0x6
ffffffffc02013ac:	22850513          	addi	a0,a0,552 # ffffffffc02075d0 <commands+0x750>
ffffffffc02013b0:	8ceff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02013b4:	00006697          	auipc	a3,0x6
ffffffffc02013b8:	33c68693          	addi	a3,a3,828 # ffffffffc02076f0 <commands+0x870>
ffffffffc02013bc:	00006617          	auipc	a2,0x6
ffffffffc02013c0:	f1460613          	addi	a2,a2,-236 # ffffffffc02072d0 <commands+0x450>
ffffffffc02013c4:	0c000593          	li	a1,192
ffffffffc02013c8:	00006517          	auipc	a0,0x6
ffffffffc02013cc:	20850513          	addi	a0,a0,520 # ffffffffc02075d0 <commands+0x750>
ffffffffc02013d0:	8aeff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013d4:	00006697          	auipc	a3,0x6
ffffffffc02013d8:	4dc68693          	addi	a3,a3,1244 # ffffffffc02078b0 <commands+0xa30>
ffffffffc02013dc:	00006617          	auipc	a2,0x6
ffffffffc02013e0:	ef460613          	addi	a2,a2,-268 # ffffffffc02072d0 <commands+0x450>
ffffffffc02013e4:	11100593          	li	a1,273
ffffffffc02013e8:	00006517          	auipc	a0,0x6
ffffffffc02013ec:	1e850513          	addi	a0,a0,488 # ffffffffc02075d0 <commands+0x750>
ffffffffc02013f0:	88eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013f4:	00006697          	auipc	a3,0x6
ffffffffc02013f8:	49c68693          	addi	a3,a3,1180 # ffffffffc0207890 <commands+0xa10>
ffffffffc02013fc:	00006617          	auipc	a2,0x6
ffffffffc0201400:	ed460613          	addi	a2,a2,-300 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201404:	10f00593          	li	a1,271
ffffffffc0201408:	00006517          	auipc	a0,0x6
ffffffffc020140c:	1c850513          	addi	a0,a0,456 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201410:	86eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201414:	00006697          	auipc	a3,0x6
ffffffffc0201418:	45468693          	addi	a3,a3,1108 # ffffffffc0207868 <commands+0x9e8>
ffffffffc020141c:	00006617          	auipc	a2,0x6
ffffffffc0201420:	eb460613          	addi	a2,a2,-332 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201424:	10d00593          	li	a1,269
ffffffffc0201428:	00006517          	auipc	a0,0x6
ffffffffc020142c:	1a850513          	addi	a0,a0,424 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201430:	84eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201434:	00006697          	auipc	a3,0x6
ffffffffc0201438:	40c68693          	addi	a3,a3,1036 # ffffffffc0207840 <commands+0x9c0>
ffffffffc020143c:	00006617          	auipc	a2,0x6
ffffffffc0201440:	e9460613          	addi	a2,a2,-364 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201444:	10c00593          	li	a1,268
ffffffffc0201448:	00006517          	auipc	a0,0x6
ffffffffc020144c:	18850513          	addi	a0,a0,392 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201450:	82eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201454:	00006697          	auipc	a3,0x6
ffffffffc0201458:	3dc68693          	addi	a3,a3,988 # ffffffffc0207830 <commands+0x9b0>
ffffffffc020145c:	00006617          	auipc	a2,0x6
ffffffffc0201460:	e7460613          	addi	a2,a2,-396 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201464:	10700593          	li	a1,263
ffffffffc0201468:	00006517          	auipc	a0,0x6
ffffffffc020146c:	16850513          	addi	a0,a0,360 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201470:	80eff0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201474:	00006697          	auipc	a3,0x6
ffffffffc0201478:	2bc68693          	addi	a3,a3,700 # ffffffffc0207730 <commands+0x8b0>
ffffffffc020147c:	00006617          	auipc	a2,0x6
ffffffffc0201480:	e5460613          	addi	a2,a2,-428 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201484:	10600593          	li	a1,262
ffffffffc0201488:	00006517          	auipc	a0,0x6
ffffffffc020148c:	14850513          	addi	a0,a0,328 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201490:	feffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201494:	00006697          	auipc	a3,0x6
ffffffffc0201498:	37c68693          	addi	a3,a3,892 # ffffffffc0207810 <commands+0x990>
ffffffffc020149c:	00006617          	auipc	a2,0x6
ffffffffc02014a0:	e3460613          	addi	a2,a2,-460 # ffffffffc02072d0 <commands+0x450>
ffffffffc02014a4:	10500593          	li	a1,261
ffffffffc02014a8:	00006517          	auipc	a0,0x6
ffffffffc02014ac:	12850513          	addi	a0,a0,296 # ffffffffc02075d0 <commands+0x750>
ffffffffc02014b0:	fcffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02014b4:	00006697          	auipc	a3,0x6
ffffffffc02014b8:	32c68693          	addi	a3,a3,812 # ffffffffc02077e0 <commands+0x960>
ffffffffc02014bc:	00006617          	auipc	a2,0x6
ffffffffc02014c0:	e1460613          	addi	a2,a2,-492 # ffffffffc02072d0 <commands+0x450>
ffffffffc02014c4:	10400593          	li	a1,260
ffffffffc02014c8:	00006517          	auipc	a0,0x6
ffffffffc02014cc:	10850513          	addi	a0,a0,264 # ffffffffc02075d0 <commands+0x750>
ffffffffc02014d0:	faffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014d4:	00006697          	auipc	a3,0x6
ffffffffc02014d8:	2f468693          	addi	a3,a3,756 # ffffffffc02077c8 <commands+0x948>
ffffffffc02014dc:	00006617          	auipc	a2,0x6
ffffffffc02014e0:	df460613          	addi	a2,a2,-524 # ffffffffc02072d0 <commands+0x450>
ffffffffc02014e4:	10300593          	li	a1,259
ffffffffc02014e8:	00006517          	auipc	a0,0x6
ffffffffc02014ec:	0e850513          	addi	a0,a0,232 # ffffffffc02075d0 <commands+0x750>
ffffffffc02014f0:	f8ffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f4:	00006697          	auipc	a3,0x6
ffffffffc02014f8:	23c68693          	addi	a3,a3,572 # ffffffffc0207730 <commands+0x8b0>
ffffffffc02014fc:	00006617          	auipc	a2,0x6
ffffffffc0201500:	dd460613          	addi	a2,a2,-556 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201504:	0fd00593          	li	a1,253
ffffffffc0201508:	00006517          	auipc	a0,0x6
ffffffffc020150c:	0c850513          	addi	a0,a0,200 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201510:	f6ffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201514:	00006697          	auipc	a3,0x6
ffffffffc0201518:	29c68693          	addi	a3,a3,668 # ffffffffc02077b0 <commands+0x930>
ffffffffc020151c:	00006617          	auipc	a2,0x6
ffffffffc0201520:	db460613          	addi	a2,a2,-588 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201524:	0f800593          	li	a1,248
ffffffffc0201528:	00006517          	auipc	a0,0x6
ffffffffc020152c:	0a850513          	addi	a0,a0,168 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201530:	f4ffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201534:	00006697          	auipc	a3,0x6
ffffffffc0201538:	39c68693          	addi	a3,a3,924 # ffffffffc02078d0 <commands+0xa50>
ffffffffc020153c:	00006617          	auipc	a2,0x6
ffffffffc0201540:	d9460613          	addi	a2,a2,-620 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201544:	11600593          	li	a1,278
ffffffffc0201548:	00006517          	auipc	a0,0x6
ffffffffc020154c:	08850513          	addi	a0,a0,136 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201550:	f2ffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(total == 0);
ffffffffc0201554:	00006697          	auipc	a3,0x6
ffffffffc0201558:	3ac68693          	addi	a3,a3,940 # ffffffffc0207900 <commands+0xa80>
ffffffffc020155c:	00006617          	auipc	a2,0x6
ffffffffc0201560:	d7460613          	addi	a2,a2,-652 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201564:	12500593          	li	a1,293
ffffffffc0201568:	00006517          	auipc	a0,0x6
ffffffffc020156c:	06850513          	addi	a0,a0,104 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201570:	f0ffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201574:	00006697          	auipc	a3,0x6
ffffffffc0201578:	07468693          	addi	a3,a3,116 # ffffffffc02075e8 <commands+0x768>
ffffffffc020157c:	00006617          	auipc	a2,0x6
ffffffffc0201580:	d5460613          	addi	a2,a2,-684 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201584:	0f200593          	li	a1,242
ffffffffc0201588:	00006517          	auipc	a0,0x6
ffffffffc020158c:	04850513          	addi	a0,a0,72 # ffffffffc02075d0 <commands+0x750>
ffffffffc0201590:	eeffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201594:	00006697          	auipc	a3,0x6
ffffffffc0201598:	09468693          	addi	a3,a3,148 # ffffffffc0207628 <commands+0x7a8>
ffffffffc020159c:	00006617          	auipc	a2,0x6
ffffffffc02015a0:	d3460613          	addi	a2,a2,-716 # ffffffffc02072d0 <commands+0x450>
ffffffffc02015a4:	0b900593          	li	a1,185
ffffffffc02015a8:	00006517          	auipc	a0,0x6
ffffffffc02015ac:	02850513          	addi	a0,a0,40 # ffffffffc02075d0 <commands+0x750>
ffffffffc02015b0:	ecffe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02015b4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02015b4:	1141                	addi	sp,sp,-16
ffffffffc02015b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015b8:	14058463          	beqz	a1,ffffffffc0201700 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015bc:	00659693          	slli	a3,a1,0x6
ffffffffc02015c0:	96aa                	add	a3,a3,a0
ffffffffc02015c2:	87aa                	mv	a5,a0
ffffffffc02015c4:	02d50263          	beq	a0,a3,ffffffffc02015e8 <default_free_pages+0x34>
ffffffffc02015c8:	6798                	ld	a4,8(a5)
ffffffffc02015ca:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015cc:	10071a63          	bnez	a4,ffffffffc02016e0 <default_free_pages+0x12c>
ffffffffc02015d0:	6798                	ld	a4,8(a5)
ffffffffc02015d2:	8b09                	andi	a4,a4,2
ffffffffc02015d4:	10071663          	bnez	a4,ffffffffc02016e0 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015d8:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015dc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015e0:	04078793          	addi	a5,a5,64
ffffffffc02015e4:	fed792e3          	bne	a5,a3,ffffffffc02015c8 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015e8:	2581                	sext.w	a1,a1
ffffffffc02015ea:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015ec:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015f0:	4789                	li	a5,2
ffffffffc02015f2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015f6:	000ca697          	auipc	a3,0xca
ffffffffc02015fa:	84a68693          	addi	a3,a3,-1974 # ffffffffc02cae40 <free_area>
ffffffffc02015fe:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201600:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201602:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201606:	9db9                	addw	a1,a1,a4
ffffffffc0201608:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020160a:	0ad78463          	beq	a5,a3,ffffffffc02016b2 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020160e:	fe878713          	addi	a4,a5,-24
ffffffffc0201612:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201616:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201618:	00e56a63          	bltu	a0,a4,ffffffffc020162c <default_free_pages+0x78>
    return listelm->next;
ffffffffc020161c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020161e:	04d70c63          	beq	a4,a3,ffffffffc0201676 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0201622:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201624:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201628:	fee57ae3          	bgeu	a0,a4,ffffffffc020161c <default_free_pages+0x68>
ffffffffc020162c:	c199                	beqz	a1,ffffffffc0201632 <default_free_pages+0x7e>
ffffffffc020162e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201632:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201634:	e390                	sd	a2,0(a5)
ffffffffc0201636:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201638:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020163a:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020163c:	00d70d63          	beq	a4,a3,ffffffffc0201656 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201640:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201644:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201648:	02059813          	slli	a6,a1,0x20
ffffffffc020164c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201650:	97b2                	add	a5,a5,a2
ffffffffc0201652:	02f50c63          	beq	a0,a5,ffffffffc020168a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201656:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201658:	00d78c63          	beq	a5,a3,ffffffffc0201670 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc020165c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020165e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201662:	02061593          	slli	a1,a2,0x20
ffffffffc0201666:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020166a:	972a                	add	a4,a4,a0
ffffffffc020166c:	04e68a63          	beq	a3,a4,ffffffffc02016c0 <default_free_pages+0x10c>
}
ffffffffc0201670:	60a2                	ld	ra,8(sp)
ffffffffc0201672:	0141                	addi	sp,sp,16
ffffffffc0201674:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201676:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201678:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020167a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020167c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020167e:	02d70763          	beq	a4,a3,ffffffffc02016ac <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201682:	8832                	mv	a6,a2
ffffffffc0201684:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201686:	87ba                	mv	a5,a4
ffffffffc0201688:	bf71                	j	ffffffffc0201624 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020168a:	491c                	lw	a5,16(a0)
ffffffffc020168c:	9dbd                	addw	a1,a1,a5
ffffffffc020168e:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201692:	57f5                	li	a5,-3
ffffffffc0201694:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201698:	01853803          	ld	a6,24(a0)
ffffffffc020169c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020169e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016a0:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02016a4:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02016a6:	0105b023          	sd	a6,0(a1)
ffffffffc02016aa:	b77d                	j	ffffffffc0201658 <default_free_pages+0xa4>
ffffffffc02016ac:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ae:	873e                	mv	a4,a5
ffffffffc02016b0:	bf41                	j	ffffffffc0201640 <default_free_pages+0x8c>
}
ffffffffc02016b2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016b4:	e390                	sd	a2,0(a5)
ffffffffc02016b6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016b8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016ba:	ed1c                	sd	a5,24(a0)
ffffffffc02016bc:	0141                	addi	sp,sp,16
ffffffffc02016be:	8082                	ret
            base->property += p->property;
ffffffffc02016c0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016c4:	ff078693          	addi	a3,a5,-16
ffffffffc02016c8:	9e39                	addw	a2,a2,a4
ffffffffc02016ca:	c910                	sw	a2,16(a0)
ffffffffc02016cc:	5775                	li	a4,-3
ffffffffc02016ce:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016d2:	6398                	ld	a4,0(a5)
ffffffffc02016d4:	679c                	ld	a5,8(a5)
}
ffffffffc02016d6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016d8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016da:	e398                	sd	a4,0(a5)
ffffffffc02016dc:	0141                	addi	sp,sp,16
ffffffffc02016de:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016e0:	00006697          	auipc	a3,0x6
ffffffffc02016e4:	23868693          	addi	a3,a3,568 # ffffffffc0207918 <commands+0xa98>
ffffffffc02016e8:	00006617          	auipc	a2,0x6
ffffffffc02016ec:	be860613          	addi	a2,a2,-1048 # ffffffffc02072d0 <commands+0x450>
ffffffffc02016f0:	08200593          	li	a1,130
ffffffffc02016f4:	00006517          	auipc	a0,0x6
ffffffffc02016f8:	edc50513          	addi	a0,a0,-292 # ffffffffc02075d0 <commands+0x750>
ffffffffc02016fc:	d83fe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(n > 0);
ffffffffc0201700:	00006697          	auipc	a3,0x6
ffffffffc0201704:	21068693          	addi	a3,a3,528 # ffffffffc0207910 <commands+0xa90>
ffffffffc0201708:	00006617          	auipc	a2,0x6
ffffffffc020170c:	bc860613          	addi	a2,a2,-1080 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201710:	07f00593          	li	a1,127
ffffffffc0201714:	00006517          	auipc	a0,0x6
ffffffffc0201718:	ebc50513          	addi	a0,a0,-324 # ffffffffc02075d0 <commands+0x750>
ffffffffc020171c:	d63fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201720 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201720:	c941                	beqz	a0,ffffffffc02017b0 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0201722:	000c9597          	auipc	a1,0xc9
ffffffffc0201726:	71e58593          	addi	a1,a1,1822 # ffffffffc02cae40 <free_area>
ffffffffc020172a:	0105a803          	lw	a6,16(a1)
ffffffffc020172e:	872a                	mv	a4,a0
ffffffffc0201730:	02081793          	slli	a5,a6,0x20
ffffffffc0201734:	9381                	srli	a5,a5,0x20
ffffffffc0201736:	00a7ee63          	bltu	a5,a0,ffffffffc0201752 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020173a:	87ae                	mv	a5,a1
ffffffffc020173c:	a801                	j	ffffffffc020174c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020173e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201742:	02069613          	slli	a2,a3,0x20
ffffffffc0201746:	9201                	srli	a2,a2,0x20
ffffffffc0201748:	00e67763          	bgeu	a2,a4,ffffffffc0201756 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020174c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020174e:	feb798e3          	bne	a5,a1,ffffffffc020173e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201752:	4501                	li	a0,0
}
ffffffffc0201754:	8082                	ret
    return listelm->prev;
ffffffffc0201756:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020175a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020175e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201762:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201766:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020176a:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020176e:	02c77863          	bgeu	a4,a2,ffffffffc020179e <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201772:	071a                	slli	a4,a4,0x6
ffffffffc0201774:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201776:	41c686bb          	subw	a3,a3,t3
ffffffffc020177a:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020177c:	00870613          	addi	a2,a4,8
ffffffffc0201780:	4689                	li	a3,2
ffffffffc0201782:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201786:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020178a:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020178e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201792:	e290                	sd	a2,0(a3)
ffffffffc0201794:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201798:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020179a:	01173c23          	sd	a7,24(a4)
ffffffffc020179e:	41c8083b          	subw	a6,a6,t3
ffffffffc02017a2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017a6:	5775                	li	a4,-3
ffffffffc02017a8:	17c1                	addi	a5,a5,-16
ffffffffc02017aa:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02017ae:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02017b0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02017b2:	00006697          	auipc	a3,0x6
ffffffffc02017b6:	15e68693          	addi	a3,a3,350 # ffffffffc0207910 <commands+0xa90>
ffffffffc02017ba:	00006617          	auipc	a2,0x6
ffffffffc02017be:	b1660613          	addi	a2,a2,-1258 # ffffffffc02072d0 <commands+0x450>
ffffffffc02017c2:	06100593          	li	a1,97
ffffffffc02017c6:	00006517          	auipc	a0,0x6
ffffffffc02017ca:	e0a50513          	addi	a0,a0,-502 # ffffffffc02075d0 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017d0:	caffe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02017d4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017d4:	1141                	addi	sp,sp,-16
ffffffffc02017d6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017d8:	c5f1                	beqz	a1,ffffffffc02018a4 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017da:	00659693          	slli	a3,a1,0x6
ffffffffc02017de:	96aa                	add	a3,a3,a0
ffffffffc02017e0:	87aa                	mv	a5,a0
ffffffffc02017e2:	00d50f63          	beq	a0,a3,ffffffffc0201800 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017e6:	6798                	ld	a4,8(a5)
ffffffffc02017e8:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017ea:	cf49                	beqz	a4,ffffffffc0201884 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017ec:	0007a823          	sw	zero,16(a5)
ffffffffc02017f0:	0007b423          	sd	zero,8(a5)
ffffffffc02017f4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017f8:	04078793          	addi	a5,a5,64
ffffffffc02017fc:	fed795e3          	bne	a5,a3,ffffffffc02017e6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201800:	2581                	sext.w	a1,a1
ffffffffc0201802:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201804:	4789                	li	a5,2
ffffffffc0201806:	00850713          	addi	a4,a0,8
ffffffffc020180a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020180e:	000c9697          	auipc	a3,0xc9
ffffffffc0201812:	63268693          	addi	a3,a3,1586 # ffffffffc02cae40 <free_area>
ffffffffc0201816:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201818:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020181a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020181e:	9db9                	addw	a1,a1,a4
ffffffffc0201820:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201822:	04d78a63          	beq	a5,a3,ffffffffc0201876 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201826:	fe878713          	addi	a4,a5,-24
ffffffffc020182a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020182e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201830:	00e56a63          	bltu	a0,a4,ffffffffc0201844 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201834:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201836:	02d70263          	beq	a4,a3,ffffffffc020185a <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc020183a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020183c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201840:	fee57ae3          	bgeu	a0,a4,ffffffffc0201834 <default_init_memmap+0x60>
ffffffffc0201844:	c199                	beqz	a1,ffffffffc020184a <default_init_memmap+0x76>
ffffffffc0201846:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020184a:	6398                	ld	a4,0(a5)
}
ffffffffc020184c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020184e:	e390                	sd	a2,0(a5)
ffffffffc0201850:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201852:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201854:	ed18                	sd	a4,24(a0)
ffffffffc0201856:	0141                	addi	sp,sp,16
ffffffffc0201858:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020185a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020185c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020185e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201860:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201862:	00d70663          	beq	a4,a3,ffffffffc020186e <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201866:	8832                	mv	a6,a2
ffffffffc0201868:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020186a:	87ba                	mv	a5,a4
ffffffffc020186c:	bfc1                	j	ffffffffc020183c <default_init_memmap+0x68>
}
ffffffffc020186e:	60a2                	ld	ra,8(sp)
ffffffffc0201870:	e290                	sd	a2,0(a3)
ffffffffc0201872:	0141                	addi	sp,sp,16
ffffffffc0201874:	8082                	ret
ffffffffc0201876:	60a2                	ld	ra,8(sp)
ffffffffc0201878:	e390                	sd	a2,0(a5)
ffffffffc020187a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020187c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020187e:	ed1c                	sd	a5,24(a0)
ffffffffc0201880:	0141                	addi	sp,sp,16
ffffffffc0201882:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201884:	00006697          	auipc	a3,0x6
ffffffffc0201888:	0bc68693          	addi	a3,a3,188 # ffffffffc0207940 <commands+0xac0>
ffffffffc020188c:	00006617          	auipc	a2,0x6
ffffffffc0201890:	a4460613          	addi	a2,a2,-1468 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201894:	04800593          	li	a1,72
ffffffffc0201898:	00006517          	auipc	a0,0x6
ffffffffc020189c:	d3850513          	addi	a0,a0,-712 # ffffffffc02075d0 <commands+0x750>
ffffffffc02018a0:	bdffe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(n > 0);
ffffffffc02018a4:	00006697          	auipc	a3,0x6
ffffffffc02018a8:	06c68693          	addi	a3,a3,108 # ffffffffc0207910 <commands+0xa90>
ffffffffc02018ac:	00006617          	auipc	a2,0x6
ffffffffc02018b0:	a2460613          	addi	a2,a2,-1500 # ffffffffc02072d0 <commands+0x450>
ffffffffc02018b4:	04500593          	li	a1,69
ffffffffc02018b8:	00006517          	auipc	a0,0x6
ffffffffc02018bc:	d1850513          	addi	a0,a0,-744 # ffffffffc02075d0 <commands+0x750>
ffffffffc02018c0:	bbffe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02018c4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018c4:	c94d                	beqz	a0,ffffffffc0201976 <slob_free+0xb2>
{
ffffffffc02018c6:	1141                	addi	sp,sp,-16
ffffffffc02018c8:	e022                	sd	s0,0(sp)
ffffffffc02018ca:	e406                	sd	ra,8(sp)
ffffffffc02018cc:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018ce:	e9c1                	bnez	a1,ffffffffc020195e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018d0:	100027f3          	csrr	a5,sstatus
ffffffffc02018d4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018d6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018d8:	ebd9                	bnez	a5,ffffffffc020196e <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018da:	000c2617          	auipc	a2,0xc2
ffffffffc02018de:	15660613          	addi	a2,a2,342 # ffffffffc02c3a30 <slobfree>
ffffffffc02018e2:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018e4:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018e6:	679c                	ld	a5,8(a5)
ffffffffc02018e8:	02877a63          	bgeu	a4,s0,ffffffffc020191c <slob_free+0x58>
ffffffffc02018ec:	00f46463          	bltu	s0,a5,ffffffffc02018f4 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018f0:	fef76ae3          	bltu	a4,a5,ffffffffc02018e4 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02018f4:	400c                	lw	a1,0(s0)
ffffffffc02018f6:	00459693          	slli	a3,a1,0x4
ffffffffc02018fa:	96a2                	add	a3,a3,s0
ffffffffc02018fc:	02d78a63          	beq	a5,a3,ffffffffc0201930 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201900:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201902:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201904:	00469793          	slli	a5,a3,0x4
ffffffffc0201908:	97ba                	add	a5,a5,a4
ffffffffc020190a:	02f40e63          	beq	s0,a5,ffffffffc0201946 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020190e:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201910:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201912:	e129                	bnez	a0,ffffffffc0201954 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201914:	60a2                	ld	ra,8(sp)
ffffffffc0201916:	6402                	ld	s0,0(sp)
ffffffffc0201918:	0141                	addi	sp,sp,16
ffffffffc020191a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020191c:	fcf764e3          	bltu	a4,a5,ffffffffc02018e4 <slob_free+0x20>
ffffffffc0201920:	fcf472e3          	bgeu	s0,a5,ffffffffc02018e4 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201924:	400c                	lw	a1,0(s0)
ffffffffc0201926:	00459693          	slli	a3,a1,0x4
ffffffffc020192a:	96a2                	add	a3,a3,s0
ffffffffc020192c:	fcd79ae3          	bne	a5,a3,ffffffffc0201900 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201930:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201932:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201934:	9db5                	addw	a1,a1,a3
ffffffffc0201936:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201938:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020193a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020193c:	00469793          	slli	a5,a3,0x4
ffffffffc0201940:	97ba                	add	a5,a5,a4
ffffffffc0201942:	fcf416e3          	bne	s0,a5,ffffffffc020190e <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201946:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201948:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020194a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc020194c:	9ebd                	addw	a3,a3,a5
ffffffffc020194e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201950:	e70c                	sd	a1,8(a4)
ffffffffc0201952:	d169                	beqz	a0,ffffffffc0201914 <slob_free+0x50>
}
ffffffffc0201954:	6402                	ld	s0,0(sp)
ffffffffc0201956:	60a2                	ld	ra,8(sp)
ffffffffc0201958:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020195a:	ce1fe06f          	j	ffffffffc020063a <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020195e:	25bd                	addiw	a1,a1,15
ffffffffc0201960:	8191                	srli	a1,a1,0x4
ffffffffc0201962:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201964:	100027f3          	csrr	a5,sstatus
ffffffffc0201968:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020196a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020196c:	d7bd                	beqz	a5,ffffffffc02018da <slob_free+0x16>
        intr_disable();
ffffffffc020196e:	cd3fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201972:	4505                	li	a0,1
ffffffffc0201974:	b79d                	j	ffffffffc02018da <slob_free+0x16>
ffffffffc0201976:	8082                	ret

ffffffffc0201978 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201978:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020197a:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020197c:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201980:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201982:	352000ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
  if(!page)
ffffffffc0201986:	c91d                	beqz	a0,ffffffffc02019bc <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201988:	000cd697          	auipc	a3,0xcd
ffffffffc020198c:	5e06b683          	ld	a3,1504(a3) # ffffffffc02cef68 <pages>
ffffffffc0201990:	8d15                	sub	a0,a0,a3
ffffffffc0201992:	8519                	srai	a0,a0,0x6
ffffffffc0201994:	00008697          	auipc	a3,0x8
ffffffffc0201998:	0dc6b683          	ld	a3,220(a3) # ffffffffc0209a70 <nbase>
ffffffffc020199c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020199e:	00c51793          	slli	a5,a0,0xc
ffffffffc02019a2:	83b1                	srli	a5,a5,0xc
ffffffffc02019a4:	000cd717          	auipc	a4,0xcd
ffffffffc02019a8:	5bc73703          	ld	a4,1468(a4) # ffffffffc02cef60 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ac:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ae:	00e7fa63          	bgeu	a5,a4,ffffffffc02019c2 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019b2:	000cd697          	auipc	a3,0xcd
ffffffffc02019b6:	5c66b683          	ld	a3,1478(a3) # ffffffffc02cef78 <va_pa_offset>
ffffffffc02019ba:	9536                	add	a0,a0,a3
}
ffffffffc02019bc:	60a2                	ld	ra,8(sp)
ffffffffc02019be:	0141                	addi	sp,sp,16
ffffffffc02019c0:	8082                	ret
ffffffffc02019c2:	86aa                	mv	a3,a0
ffffffffc02019c4:	00006617          	auipc	a2,0x6
ffffffffc02019c8:	fdc60613          	addi	a2,a2,-36 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc02019cc:	06900593          	li	a1,105
ffffffffc02019d0:	00006517          	auipc	a0,0x6
ffffffffc02019d4:	ff850513          	addi	a0,a0,-8 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02019d8:	aa7fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02019dc <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019dc:	1101                	addi	sp,sp,-32
ffffffffc02019de:	ec06                	sd	ra,24(sp)
ffffffffc02019e0:	e822                	sd	s0,16(sp)
ffffffffc02019e2:	e426                	sd	s1,8(sp)
ffffffffc02019e4:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019e6:	01050713          	addi	a4,a0,16
ffffffffc02019ea:	6785                	lui	a5,0x1
ffffffffc02019ec:	0cf77363          	bgeu	a4,a5,ffffffffc0201ab2 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019f0:	00f50493          	addi	s1,a0,15
ffffffffc02019f4:	8091                	srli	s1,s1,0x4
ffffffffc02019f6:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f8:	10002673          	csrr	a2,sstatus
ffffffffc02019fc:	8a09                	andi	a2,a2,2
ffffffffc02019fe:	e25d                	bnez	a2,ffffffffc0201aa4 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a00:	000c2917          	auipc	s2,0xc2
ffffffffc0201a04:	03090913          	addi	s2,s2,48 # ffffffffc02c3a30 <slobfree>
ffffffffc0201a08:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a0c:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a0e:	4398                	lw	a4,0(a5)
ffffffffc0201a10:	08975e63          	bge	a4,s1,ffffffffc0201aac <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201a14:	00f68b63          	beq	a3,a5,ffffffffc0201a2a <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a18:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a1a:	4018                	lw	a4,0(s0)
ffffffffc0201a1c:	02975a63          	bge	a4,s1,ffffffffc0201a50 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a20:	00093683          	ld	a3,0(s2)
ffffffffc0201a24:	87a2                	mv	a5,s0
ffffffffc0201a26:	fef699e3          	bne	a3,a5,ffffffffc0201a18 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a2a:	ee31                	bnez	a2,ffffffffc0201a86 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a2c:	4501                	li	a0,0
ffffffffc0201a2e:	f4bff0ef          	jal	ra,ffffffffc0201978 <__slob_get_free_pages.constprop.0>
ffffffffc0201a32:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a34:	cd05                	beqz	a0,ffffffffc0201a6c <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a36:	6585                	lui	a1,0x1
ffffffffc0201a38:	e8dff0ef          	jal	ra,ffffffffc02018c4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a3c:	10002673          	csrr	a2,sstatus
ffffffffc0201a40:	8a09                	andi	a2,a2,2
ffffffffc0201a42:	ee05                	bnez	a2,ffffffffc0201a7a <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a44:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a48:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a4a:	4018                	lw	a4,0(s0)
ffffffffc0201a4c:	fc974ae3          	blt	a4,s1,ffffffffc0201a20 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a50:	04e48763          	beq	s1,a4,ffffffffc0201a9e <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a54:	00449693          	slli	a3,s1,0x4
ffffffffc0201a58:	96a2                	add	a3,a3,s0
ffffffffc0201a5a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a5c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a5e:	9f05                	subw	a4,a4,s1
ffffffffc0201a60:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a62:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a64:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a66:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a6a:	e20d                	bnez	a2,ffffffffc0201a8c <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a6c:	60e2                	ld	ra,24(sp)
ffffffffc0201a6e:	8522                	mv	a0,s0
ffffffffc0201a70:	6442                	ld	s0,16(sp)
ffffffffc0201a72:	64a2                	ld	s1,8(sp)
ffffffffc0201a74:	6902                	ld	s2,0(sp)
ffffffffc0201a76:	6105                	addi	sp,sp,32
ffffffffc0201a78:	8082                	ret
        intr_disable();
ffffffffc0201a7a:	bc7fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
			cur = slobfree;
ffffffffc0201a7e:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a82:	4605                	li	a2,1
ffffffffc0201a84:	b7d1                	j	ffffffffc0201a48 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a86:	bb5fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0201a8a:	b74d                	j	ffffffffc0201a2c <slob_alloc.constprop.0+0x50>
ffffffffc0201a8c:	baffe0ef          	jal	ra,ffffffffc020063a <intr_enable>
}
ffffffffc0201a90:	60e2                	ld	ra,24(sp)
ffffffffc0201a92:	8522                	mv	a0,s0
ffffffffc0201a94:	6442                	ld	s0,16(sp)
ffffffffc0201a96:	64a2                	ld	s1,8(sp)
ffffffffc0201a98:	6902                	ld	s2,0(sp)
ffffffffc0201a9a:	6105                	addi	sp,sp,32
ffffffffc0201a9c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a9e:	6418                	ld	a4,8(s0)
ffffffffc0201aa0:	e798                	sd	a4,8(a5)
ffffffffc0201aa2:	b7d1                	j	ffffffffc0201a66 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201aa4:	b9dfe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201aa8:	4605                	li	a2,1
ffffffffc0201aaa:	bf99                	j	ffffffffc0201a00 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201aac:	843e                	mv	s0,a5
ffffffffc0201aae:	87b6                	mv	a5,a3
ffffffffc0201ab0:	b745                	j	ffffffffc0201a50 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201ab2:	00006697          	auipc	a3,0x6
ffffffffc0201ab6:	f2668693          	addi	a3,a3,-218 # ffffffffc02079d8 <default_pmm_manager+0x70>
ffffffffc0201aba:	00006617          	auipc	a2,0x6
ffffffffc0201abe:	81660613          	addi	a2,a2,-2026 # ffffffffc02072d0 <commands+0x450>
ffffffffc0201ac2:	06400593          	li	a1,100
ffffffffc0201ac6:	00006517          	auipc	a0,0x6
ffffffffc0201aca:	f3250513          	addi	a0,a0,-206 # ffffffffc02079f8 <default_pmm_manager+0x90>
ffffffffc0201ace:	9b1fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201ad2 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201ad2:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201ad4:	00006517          	auipc	a0,0x6
ffffffffc0201ad8:	f3c50513          	addi	a0,a0,-196 # ffffffffc0207a10 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201adc:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201ade:	ea6fe0ef          	jal	ra,ffffffffc0200184 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201ae2:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ae4:	00006517          	auipc	a0,0x6
ffffffffc0201ae8:	f4450513          	addi	a0,a0,-188 # ffffffffc0207a28 <default_pmm_manager+0xc0>
}
ffffffffc0201aec:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201aee:	e96fe06f          	j	ffffffffc0200184 <cprintf>

ffffffffc0201af2 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201af2:	4501                	li	a0,0
ffffffffc0201af4:	8082                	ret

ffffffffc0201af6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201af6:	1101                	addi	sp,sp,-32
ffffffffc0201af8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201afa:	6905                	lui	s2,0x1
{
ffffffffc0201afc:	e822                	sd	s0,16(sp)
ffffffffc0201afe:	ec06                	sd	ra,24(sp)
ffffffffc0201b00:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b02:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8f79>
{
ffffffffc0201b06:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b08:	04a7f963          	bgeu	a5,a0,ffffffffc0201b5a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b0c:	4561                	li	a0,24
ffffffffc0201b0e:	ecfff0ef          	jal	ra,ffffffffc02019dc <slob_alloc.constprop.0>
ffffffffc0201b12:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b14:	c929                	beqz	a0,ffffffffc0201b66 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b16:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b1a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b1c:	00f95763          	bge	s2,a5,ffffffffc0201b2a <kmalloc+0x34>
ffffffffc0201b20:	6705                	lui	a4,0x1
ffffffffc0201b22:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b24:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b26:	fef74ee3          	blt	a4,a5,ffffffffc0201b22 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b2a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b2c:	e4dff0ef          	jal	ra,ffffffffc0201978 <__slob_get_free_pages.constprop.0>
ffffffffc0201b30:	e488                	sd	a0,8(s1)
ffffffffc0201b32:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b34:	c525                	beqz	a0,ffffffffc0201b9c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b36:	100027f3          	csrr	a5,sstatus
ffffffffc0201b3a:	8b89                	andi	a5,a5,2
ffffffffc0201b3c:	ef8d                	bnez	a5,ffffffffc0201b76 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b3e:	000cd797          	auipc	a5,0xcd
ffffffffc0201b42:	40a78793          	addi	a5,a5,1034 # ffffffffc02cef48 <bigblocks>
ffffffffc0201b46:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b48:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b4a:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b4c:	60e2                	ld	ra,24(sp)
ffffffffc0201b4e:	8522                	mv	a0,s0
ffffffffc0201b50:	6442                	ld	s0,16(sp)
ffffffffc0201b52:	64a2                	ld	s1,8(sp)
ffffffffc0201b54:	6902                	ld	s2,0(sp)
ffffffffc0201b56:	6105                	addi	sp,sp,32
ffffffffc0201b58:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b5a:	0541                	addi	a0,a0,16
ffffffffc0201b5c:	e81ff0ef          	jal	ra,ffffffffc02019dc <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b60:	01050413          	addi	s0,a0,16
ffffffffc0201b64:	f565                	bnez	a0,ffffffffc0201b4c <kmalloc+0x56>
ffffffffc0201b66:	4401                	li	s0,0
}
ffffffffc0201b68:	60e2                	ld	ra,24(sp)
ffffffffc0201b6a:	8522                	mv	a0,s0
ffffffffc0201b6c:	6442                	ld	s0,16(sp)
ffffffffc0201b6e:	64a2                	ld	s1,8(sp)
ffffffffc0201b70:	6902                	ld	s2,0(sp)
ffffffffc0201b72:	6105                	addi	sp,sp,32
ffffffffc0201b74:	8082                	ret
        intr_disable();
ffffffffc0201b76:	acbfe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b7a:	000cd797          	auipc	a5,0xcd
ffffffffc0201b7e:	3ce78793          	addi	a5,a5,974 # ffffffffc02cef48 <bigblocks>
ffffffffc0201b82:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b84:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b86:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b88:	ab3fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
		return bb->pages;
ffffffffc0201b8c:	6480                	ld	s0,8(s1)
}
ffffffffc0201b8e:	60e2                	ld	ra,24(sp)
ffffffffc0201b90:	64a2                	ld	s1,8(sp)
ffffffffc0201b92:	8522                	mv	a0,s0
ffffffffc0201b94:	6442                	ld	s0,16(sp)
ffffffffc0201b96:	6902                	ld	s2,0(sp)
ffffffffc0201b98:	6105                	addi	sp,sp,32
ffffffffc0201b9a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b9c:	45e1                	li	a1,24
ffffffffc0201b9e:	8526                	mv	a0,s1
ffffffffc0201ba0:	d25ff0ef          	jal	ra,ffffffffc02018c4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ba4:	b765                	j	ffffffffc0201b4c <kmalloc+0x56>

ffffffffc0201ba6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ba6:	c169                	beqz	a0,ffffffffc0201c68 <kfree+0xc2>
{
ffffffffc0201ba8:	1101                	addi	sp,sp,-32
ffffffffc0201baa:	e822                	sd	s0,16(sp)
ffffffffc0201bac:	ec06                	sd	ra,24(sp)
ffffffffc0201bae:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201bb0:	03451793          	slli	a5,a0,0x34
ffffffffc0201bb4:	842a                	mv	s0,a0
ffffffffc0201bb6:	e3d9                	bnez	a5,ffffffffc0201c3c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bb8:	100027f3          	csrr	a5,sstatus
ffffffffc0201bbc:	8b89                	andi	a5,a5,2
ffffffffc0201bbe:	e7d9                	bnez	a5,ffffffffc0201c4c <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bc0:	000cd797          	auipc	a5,0xcd
ffffffffc0201bc4:	3887b783          	ld	a5,904(a5) # ffffffffc02cef48 <bigblocks>
    return 0;
ffffffffc0201bc8:	4601                	li	a2,0
ffffffffc0201bca:	cbad                	beqz	a5,ffffffffc0201c3c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bcc:	000cd697          	auipc	a3,0xcd
ffffffffc0201bd0:	37c68693          	addi	a3,a3,892 # ffffffffc02cef48 <bigblocks>
ffffffffc0201bd4:	a021                	j	ffffffffc0201bdc <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bd6:	01048693          	addi	a3,s1,16
ffffffffc0201bda:	c3a5                	beqz	a5,ffffffffc0201c3a <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201bdc:	6798                	ld	a4,8(a5)
ffffffffc0201bde:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201be0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201be2:	fe871ae3          	bne	a4,s0,ffffffffc0201bd6 <kfree+0x30>
				*last = bb->next;
ffffffffc0201be6:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201be8:	ee2d                	bnez	a2,ffffffffc0201c62 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bea:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bee:	4098                	lw	a4,0(s1)
ffffffffc0201bf0:	08f46963          	bltu	s0,a5,ffffffffc0201c82 <kfree+0xdc>
ffffffffc0201bf4:	000cd697          	auipc	a3,0xcd
ffffffffc0201bf8:	3846b683          	ld	a3,900(a3) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0201bfc:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201bfe:	8031                	srli	s0,s0,0xc
ffffffffc0201c00:	000cd797          	auipc	a5,0xcd
ffffffffc0201c04:	3607b783          	ld	a5,864(a5) # ffffffffc02cef60 <npage>
ffffffffc0201c08:	06f47163          	bgeu	s0,a5,ffffffffc0201c6a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c0c:	00008517          	auipc	a0,0x8
ffffffffc0201c10:	e6453503          	ld	a0,-412(a0) # ffffffffc0209a70 <nbase>
ffffffffc0201c14:	8c09                	sub	s0,s0,a0
ffffffffc0201c16:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c18:	000cd517          	auipc	a0,0xcd
ffffffffc0201c1c:	35053503          	ld	a0,848(a0) # ffffffffc02cef68 <pages>
ffffffffc0201c20:	4585                	li	a1,1
ffffffffc0201c22:	9522                	add	a0,a0,s0
ffffffffc0201c24:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c28:	13e000ef          	jal	ra,ffffffffc0201d66 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c2c:	6442                	ld	s0,16(sp)
ffffffffc0201c2e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c30:	8526                	mv	a0,s1
}
ffffffffc0201c32:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c34:	45e1                	li	a1,24
}
ffffffffc0201c36:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c38:	b171                	j	ffffffffc02018c4 <slob_free>
ffffffffc0201c3a:	e20d                	bnez	a2,ffffffffc0201c5c <kfree+0xb6>
ffffffffc0201c3c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c40:	6442                	ld	s0,16(sp)
ffffffffc0201c42:	60e2                	ld	ra,24(sp)
ffffffffc0201c44:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c46:	4581                	li	a1,0
}
ffffffffc0201c48:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c4a:	b9ad                	j	ffffffffc02018c4 <slob_free>
        intr_disable();
ffffffffc0201c4c:	9f5fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c50:	000cd797          	auipc	a5,0xcd
ffffffffc0201c54:	2f87b783          	ld	a5,760(a5) # ffffffffc02cef48 <bigblocks>
        return 1;
ffffffffc0201c58:	4605                	li	a2,1
ffffffffc0201c5a:	fbad                	bnez	a5,ffffffffc0201bcc <kfree+0x26>
        intr_enable();
ffffffffc0201c5c:	9dffe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0201c60:	bff1                	j	ffffffffc0201c3c <kfree+0x96>
ffffffffc0201c62:	9d9fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0201c66:	b751                	j	ffffffffc0201bea <kfree+0x44>
ffffffffc0201c68:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c6a:	00006617          	auipc	a2,0x6
ffffffffc0201c6e:	e0660613          	addi	a2,a2,-506 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0201c72:	06200593          	li	a1,98
ffffffffc0201c76:	00006517          	auipc	a0,0x6
ffffffffc0201c7a:	d5250513          	addi	a0,a0,-686 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0201c7e:	801fe0ef          	jal	ra,ffffffffc020047e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c82:	86a2                	mv	a3,s0
ffffffffc0201c84:	00006617          	auipc	a2,0x6
ffffffffc0201c88:	dc460613          	addi	a2,a2,-572 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0201c8c:	06e00593          	li	a1,110
ffffffffc0201c90:	00006517          	auipc	a0,0x6
ffffffffc0201c94:	d3850513          	addi	a0,a0,-712 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0201c98:	fe6fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201c9c <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201c9c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c9e:	00006617          	auipc	a2,0x6
ffffffffc0201ca2:	dd260613          	addi	a2,a2,-558 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0201ca6:	06200593          	li	a1,98
ffffffffc0201caa:	00006517          	auipc	a0,0x6
ffffffffc0201cae:	d1e50513          	addi	a0,a0,-738 # ffffffffc02079c8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201cb2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201cb4:	fcafe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201cb8 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201cb8:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201cba:	00006617          	auipc	a2,0x6
ffffffffc0201cbe:	dd660613          	addi	a2,a2,-554 # ffffffffc0207a90 <default_pmm_manager+0x128>
ffffffffc0201cc2:	07400593          	li	a1,116
ffffffffc0201cc6:	00006517          	auipc	a0,0x6
ffffffffc0201cca:	d0250513          	addi	a0,a0,-766 # ffffffffc02079c8 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cce:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cd0:	faefe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201cd4 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201cd4:	7139                	addi	sp,sp,-64
ffffffffc0201cd6:	f426                	sd	s1,40(sp)
ffffffffc0201cd8:	f04a                	sd	s2,32(sp)
ffffffffc0201cda:	ec4e                	sd	s3,24(sp)
ffffffffc0201cdc:	e852                	sd	s4,16(sp)
ffffffffc0201cde:	e456                	sd	s5,8(sp)
ffffffffc0201ce0:	e05a                	sd	s6,0(sp)
ffffffffc0201ce2:	fc06                	sd	ra,56(sp)
ffffffffc0201ce4:	f822                	sd	s0,48(sp)
ffffffffc0201ce6:	84aa                	mv	s1,a0
ffffffffc0201ce8:	000cd917          	auipc	s2,0xcd
ffffffffc0201cec:	28890913          	addi	s2,s2,648 # ffffffffc02cef70 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cf0:	4a05                	li	s4,1
ffffffffc0201cf2:	000cda97          	auipc	s5,0xcd
ffffffffc0201cf6:	29ea8a93          	addi	s5,s5,670 # ffffffffc02cef90 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cfa:	0005099b          	sext.w	s3,a0
ffffffffc0201cfe:	000cdb17          	auipc	s6,0xcd
ffffffffc0201d02:	29ab0b13          	addi	s6,s6,666 # ffffffffc02cef98 <check_mm_struct>
ffffffffc0201d06:	a01d                	j	ffffffffc0201d2c <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d08:	00093783          	ld	a5,0(s2)
ffffffffc0201d0c:	6f9c                	ld	a5,24(a5)
ffffffffc0201d0e:	9782                	jalr	a5
ffffffffc0201d10:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d12:	4601                	li	a2,0
ffffffffc0201d14:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d16:	ec0d                	bnez	s0,ffffffffc0201d50 <alloc_pages+0x7c>
ffffffffc0201d18:	029a6c63          	bltu	s4,s1,ffffffffc0201d50 <alloc_pages+0x7c>
ffffffffc0201d1c:	000aa783          	lw	a5,0(s5)
ffffffffc0201d20:	2781                	sext.w	a5,a5
ffffffffc0201d22:	c79d                	beqz	a5,ffffffffc0201d50 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d24:	000b3503          	ld	a0,0(s6)
ffffffffc0201d28:	631010ef          	jal	ra,ffffffffc0203b58 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d2c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d30:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d32:	8526                	mv	a0,s1
ffffffffc0201d34:	dbf1                	beqz	a5,ffffffffc0201d08 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d36:	90bfe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0201d3a:	00093783          	ld	a5,0(s2)
ffffffffc0201d3e:	8526                	mv	a0,s1
ffffffffc0201d40:	6f9c                	ld	a5,24(a5)
ffffffffc0201d42:	9782                	jalr	a5
ffffffffc0201d44:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d46:	8f5fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d4a:	4601                	li	a2,0
ffffffffc0201d4c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d4e:	d469                	beqz	s0,ffffffffc0201d18 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d50:	70e2                	ld	ra,56(sp)
ffffffffc0201d52:	8522                	mv	a0,s0
ffffffffc0201d54:	7442                	ld	s0,48(sp)
ffffffffc0201d56:	74a2                	ld	s1,40(sp)
ffffffffc0201d58:	7902                	ld	s2,32(sp)
ffffffffc0201d5a:	69e2                	ld	s3,24(sp)
ffffffffc0201d5c:	6a42                	ld	s4,16(sp)
ffffffffc0201d5e:	6aa2                	ld	s5,8(sp)
ffffffffc0201d60:	6b02                	ld	s6,0(sp)
ffffffffc0201d62:	6121                	addi	sp,sp,64
ffffffffc0201d64:	8082                	ret

ffffffffc0201d66 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d66:	100027f3          	csrr	a5,sstatus
ffffffffc0201d6a:	8b89                	andi	a5,a5,2
ffffffffc0201d6c:	e799                	bnez	a5,ffffffffc0201d7a <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d6e:	000cd797          	auipc	a5,0xcd
ffffffffc0201d72:	2027b783          	ld	a5,514(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0201d76:	739c                	ld	a5,32(a5)
ffffffffc0201d78:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d7a:	1101                	addi	sp,sp,-32
ffffffffc0201d7c:	ec06                	sd	ra,24(sp)
ffffffffc0201d7e:	e822                	sd	s0,16(sp)
ffffffffc0201d80:	e426                	sd	s1,8(sp)
ffffffffc0201d82:	842a                	mv	s0,a0
ffffffffc0201d84:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d86:	8bbfe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d8a:	000cd797          	auipc	a5,0xcd
ffffffffc0201d8e:	1e67b783          	ld	a5,486(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0201d92:	739c                	ld	a5,32(a5)
ffffffffc0201d94:	85a6                	mv	a1,s1
ffffffffc0201d96:	8522                	mv	a0,s0
ffffffffc0201d98:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d9a:	6442                	ld	s0,16(sp)
ffffffffc0201d9c:	60e2                	ld	ra,24(sp)
ffffffffc0201d9e:	64a2                	ld	s1,8(sp)
ffffffffc0201da0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201da2:	899fe06f          	j	ffffffffc020063a <intr_enable>

ffffffffc0201da6 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201da6:	100027f3          	csrr	a5,sstatus
ffffffffc0201daa:	8b89                	andi	a5,a5,2
ffffffffc0201dac:	e799                	bnez	a5,ffffffffc0201dba <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dae:	000cd797          	auipc	a5,0xcd
ffffffffc0201db2:	1c27b783          	ld	a5,450(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0201db6:	779c                	ld	a5,40(a5)
ffffffffc0201db8:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201dba:	1141                	addi	sp,sp,-16
ffffffffc0201dbc:	e406                	sd	ra,8(sp)
ffffffffc0201dbe:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dc0:	881fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dc4:	000cd797          	auipc	a5,0xcd
ffffffffc0201dc8:	1ac7b783          	ld	a5,428(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0201dcc:	779c                	ld	a5,40(a5)
ffffffffc0201dce:	9782                	jalr	a5
ffffffffc0201dd0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dd2:	869fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201dd6:	60a2                	ld	ra,8(sp)
ffffffffc0201dd8:	8522                	mv	a0,s0
ffffffffc0201dda:	6402                	ld	s0,0(sp)
ffffffffc0201ddc:	0141                	addi	sp,sp,16
ffffffffc0201dde:	8082                	ret

ffffffffc0201de0 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201de0:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201de4:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201de8:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dea:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dec:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dee:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201df2:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df4:	f04a                	sd	s2,32(sp)
ffffffffc0201df6:	ec4e                	sd	s3,24(sp)
ffffffffc0201df8:	e852                	sd	s4,16(sp)
ffffffffc0201dfa:	fc06                	sd	ra,56(sp)
ffffffffc0201dfc:	f822                	sd	s0,48(sp)
ffffffffc0201dfe:	e456                	sd	s5,8(sp)
ffffffffc0201e00:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e02:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e06:	892e                	mv	s2,a1
ffffffffc0201e08:	89b2                	mv	s3,a2
ffffffffc0201e0a:	000cda17          	auipc	s4,0xcd
ffffffffc0201e0e:	156a0a13          	addi	s4,s4,342 # ffffffffc02cef60 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e12:	e7b5                	bnez	a5,ffffffffc0201e7e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e14:	12060b63          	beqz	a2,ffffffffc0201f4a <get_pte+0x16a>
ffffffffc0201e18:	4505                	li	a0,1
ffffffffc0201e1a:	ebbff0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0201e1e:	842a                	mv	s0,a0
ffffffffc0201e20:	12050563          	beqz	a0,ffffffffc0201f4a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e24:	000cdb17          	auipc	s6,0xcd
ffffffffc0201e28:	144b0b13          	addi	s6,s6,324 # ffffffffc02cef68 <pages>
ffffffffc0201e2c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e30:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e34:	000cda17          	auipc	s4,0xcd
ffffffffc0201e38:	12ca0a13          	addi	s4,s4,300 # ffffffffc02cef60 <npage>
ffffffffc0201e3c:	40a40533          	sub	a0,s0,a0
ffffffffc0201e40:	8519                	srai	a0,a0,0x6
ffffffffc0201e42:	9556                	add	a0,a0,s5
ffffffffc0201e44:	000a3703          	ld	a4,0(s4)
ffffffffc0201e48:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e4c:	4685                	li	a3,1
ffffffffc0201e4e:	c014                	sw	a3,0(s0)
ffffffffc0201e50:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e52:	0532                	slli	a0,a0,0xc
ffffffffc0201e54:	14e7f263          	bgeu	a5,a4,ffffffffc0201f98 <get_pte+0x1b8>
ffffffffc0201e58:	000cd797          	auipc	a5,0xcd
ffffffffc0201e5c:	1207b783          	ld	a5,288(a5) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0201e60:	6605                	lui	a2,0x1
ffffffffc0201e62:	4581                	li	a1,0
ffffffffc0201e64:	953e                	add	a0,a0,a5
ffffffffc0201e66:	585040ef          	jal	ra,ffffffffc0206bea <memset>
    return page - pages + nbase;
ffffffffc0201e6a:	000b3683          	ld	a3,0(s6)
ffffffffc0201e6e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e72:	8699                	srai	a3,a3,0x6
ffffffffc0201e74:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e76:	06aa                	slli	a3,a3,0xa
ffffffffc0201e78:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e7c:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e7e:	77fd                	lui	a5,0xfffff
ffffffffc0201e80:	068a                	slli	a3,a3,0x2
ffffffffc0201e82:	000a3703          	ld	a4,0(s4)
ffffffffc0201e86:	8efd                	and	a3,a3,a5
ffffffffc0201e88:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e8c:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f4e <get_pte+0x16e>
ffffffffc0201e90:	000cda97          	auipc	s5,0xcd
ffffffffc0201e94:	0e8a8a93          	addi	s5,s5,232 # ffffffffc02cef78 <va_pa_offset>
ffffffffc0201e98:	000ab403          	ld	s0,0(s5)
ffffffffc0201e9c:	01595793          	srli	a5,s2,0x15
ffffffffc0201ea0:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ea4:	96a2                	add	a3,a3,s0
ffffffffc0201ea6:	00379413          	slli	s0,a5,0x3
ffffffffc0201eaa:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201eac:	6014                	ld	a3,0(s0)
ffffffffc0201eae:	0016f793          	andi	a5,a3,1
ffffffffc0201eb2:	e3ad                	bnez	a5,ffffffffc0201f14 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201eb4:	08098b63          	beqz	s3,ffffffffc0201f4a <get_pte+0x16a>
ffffffffc0201eb8:	4505                	li	a0,1
ffffffffc0201eba:	e1bff0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0201ebe:	84aa                	mv	s1,a0
ffffffffc0201ec0:	c549                	beqz	a0,ffffffffc0201f4a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ec2:	000cdb17          	auipc	s6,0xcd
ffffffffc0201ec6:	0a6b0b13          	addi	s6,s6,166 # ffffffffc02cef68 <pages>
ffffffffc0201eca:	000b3503          	ld	a0,0(s6)
ffffffffc0201ece:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ed2:	000a3703          	ld	a4,0(s4)
ffffffffc0201ed6:	40a48533          	sub	a0,s1,a0
ffffffffc0201eda:	8519                	srai	a0,a0,0x6
ffffffffc0201edc:	954e                	add	a0,a0,s3
ffffffffc0201ede:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201ee2:	4685                	li	a3,1
ffffffffc0201ee4:	c094                	sw	a3,0(s1)
ffffffffc0201ee6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ee8:	0532                	slli	a0,a0,0xc
ffffffffc0201eea:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f7e <get_pte+0x19e>
ffffffffc0201eee:	000ab783          	ld	a5,0(s5)
ffffffffc0201ef2:	6605                	lui	a2,0x1
ffffffffc0201ef4:	4581                	li	a1,0
ffffffffc0201ef6:	953e                	add	a0,a0,a5
ffffffffc0201ef8:	4f3040ef          	jal	ra,ffffffffc0206bea <memset>
    return page - pages + nbase;
ffffffffc0201efc:	000b3683          	ld	a3,0(s6)
ffffffffc0201f00:	40d486b3          	sub	a3,s1,a3
ffffffffc0201f04:	8699                	srai	a3,a3,0x6
ffffffffc0201f06:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f08:	06aa                	slli	a3,a3,0xa
ffffffffc0201f0a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f0e:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f10:	000a3703          	ld	a4,0(s4)
ffffffffc0201f14:	068a                	slli	a3,a3,0x2
ffffffffc0201f16:	757d                	lui	a0,0xfffff
ffffffffc0201f18:	8ee9                	and	a3,a3,a0
ffffffffc0201f1a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f1e:	04e7f463          	bgeu	a5,a4,ffffffffc0201f66 <get_pte+0x186>
ffffffffc0201f22:	000ab503          	ld	a0,0(s5)
ffffffffc0201f26:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f2a:	1ff97913          	andi	s2,s2,511
ffffffffc0201f2e:	96aa                	add	a3,a3,a0
ffffffffc0201f30:	00391513          	slli	a0,s2,0x3
ffffffffc0201f34:	9536                	add	a0,a0,a3
}
ffffffffc0201f36:	70e2                	ld	ra,56(sp)
ffffffffc0201f38:	7442                	ld	s0,48(sp)
ffffffffc0201f3a:	74a2                	ld	s1,40(sp)
ffffffffc0201f3c:	7902                	ld	s2,32(sp)
ffffffffc0201f3e:	69e2                	ld	s3,24(sp)
ffffffffc0201f40:	6a42                	ld	s4,16(sp)
ffffffffc0201f42:	6aa2                	ld	s5,8(sp)
ffffffffc0201f44:	6b02                	ld	s6,0(sp)
ffffffffc0201f46:	6121                	addi	sp,sp,64
ffffffffc0201f48:	8082                	ret
            return NULL;
ffffffffc0201f4a:	4501                	li	a0,0
ffffffffc0201f4c:	b7ed                	j	ffffffffc0201f36 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f4e:	00006617          	auipc	a2,0x6
ffffffffc0201f52:	a5260613          	addi	a2,a2,-1454 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0201f56:	0fd00593          	li	a1,253
ffffffffc0201f5a:	00006517          	auipc	a0,0x6
ffffffffc0201f5e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0201f62:	d1cfe0ef          	jal	ra,ffffffffc020047e <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f66:	00006617          	auipc	a2,0x6
ffffffffc0201f6a:	a3a60613          	addi	a2,a2,-1478 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0201f6e:	10800593          	li	a1,264
ffffffffc0201f72:	00006517          	auipc	a0,0x6
ffffffffc0201f76:	b4650513          	addi	a0,a0,-1210 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0201f7a:	d04fe0ef          	jal	ra,ffffffffc020047e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f7e:	86aa                	mv	a3,a0
ffffffffc0201f80:	00006617          	auipc	a2,0x6
ffffffffc0201f84:	a2060613          	addi	a2,a2,-1504 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0201f88:	10500593          	li	a1,261
ffffffffc0201f8c:	00006517          	auipc	a0,0x6
ffffffffc0201f90:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0201f94:	ceafe0ef          	jal	ra,ffffffffc020047e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f98:	86aa                	mv	a3,a0
ffffffffc0201f9a:	00006617          	auipc	a2,0x6
ffffffffc0201f9e:	a0660613          	addi	a2,a2,-1530 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0201fa2:	0f900593          	li	a1,249
ffffffffc0201fa6:	00006517          	auipc	a0,0x6
ffffffffc0201faa:	b1250513          	addi	a0,a0,-1262 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0201fae:	cd0fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0201fb2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fb2:	1141                	addi	sp,sp,-16
ffffffffc0201fb4:	e022                	sd	s0,0(sp)
ffffffffc0201fb6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fb8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fba:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fbc:	e25ff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fc0:	c011                	beqz	s0,ffffffffc0201fc4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201fc2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fc4:	c511                	beqz	a0,ffffffffc0201fd0 <get_page+0x1e>
ffffffffc0201fc6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fc8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fca:	0017f713          	andi	a4,a5,1
ffffffffc0201fce:	e709                	bnez	a4,ffffffffc0201fd8 <get_page+0x26>
}
ffffffffc0201fd0:	60a2                	ld	ra,8(sp)
ffffffffc0201fd2:	6402                	ld	s0,0(sp)
ffffffffc0201fd4:	0141                	addi	sp,sp,16
ffffffffc0201fd6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fd8:	078a                	slli	a5,a5,0x2
ffffffffc0201fda:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fdc:	000cd717          	auipc	a4,0xcd
ffffffffc0201fe0:	f8473703          	ld	a4,-124(a4) # ffffffffc02cef60 <npage>
ffffffffc0201fe4:	00e7ff63          	bgeu	a5,a4,ffffffffc0202002 <get_page+0x50>
ffffffffc0201fe8:	60a2                	ld	ra,8(sp)
ffffffffc0201fea:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fec:	fff80537          	lui	a0,0xfff80
ffffffffc0201ff0:	97aa                	add	a5,a5,a0
ffffffffc0201ff2:	079a                	slli	a5,a5,0x6
ffffffffc0201ff4:	000cd517          	auipc	a0,0xcd
ffffffffc0201ff8:	f7453503          	ld	a0,-140(a0) # ffffffffc02cef68 <pages>
ffffffffc0201ffc:	953e                	add	a0,a0,a5
ffffffffc0201ffe:	0141                	addi	sp,sp,16
ffffffffc0202000:	8082                	ret
ffffffffc0202002:	c9bff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>

ffffffffc0202006 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202006:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202008:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020200c:	f486                	sd	ra,104(sp)
ffffffffc020200e:	f0a2                	sd	s0,96(sp)
ffffffffc0202010:	eca6                	sd	s1,88(sp)
ffffffffc0202012:	e8ca                	sd	s2,80(sp)
ffffffffc0202014:	e4ce                	sd	s3,72(sp)
ffffffffc0202016:	e0d2                	sd	s4,64(sp)
ffffffffc0202018:	fc56                	sd	s5,56(sp)
ffffffffc020201a:	f85a                	sd	s6,48(sp)
ffffffffc020201c:	f45e                	sd	s7,40(sp)
ffffffffc020201e:	f062                	sd	s8,32(sp)
ffffffffc0202020:	ec66                	sd	s9,24(sp)
ffffffffc0202022:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202024:	17d2                	slli	a5,a5,0x34
ffffffffc0202026:	e3ed                	bnez	a5,ffffffffc0202108 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202028:	002007b7          	lui	a5,0x200
ffffffffc020202c:	842e                	mv	s0,a1
ffffffffc020202e:	0ef5ed63          	bltu	a1,a5,ffffffffc0202128 <unmap_range+0x122>
ffffffffc0202032:	8932                	mv	s2,a2
ffffffffc0202034:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202128 <unmap_range+0x122>
ffffffffc0202038:	4785                	li	a5,1
ffffffffc020203a:	07fe                	slli	a5,a5,0x1f
ffffffffc020203c:	0ec7e663          	bltu	a5,a2,ffffffffc0202128 <unmap_range+0x122>
ffffffffc0202040:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202042:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202044:	000cdc97          	auipc	s9,0xcd
ffffffffc0202048:	f1cc8c93          	addi	s9,s9,-228 # ffffffffc02cef60 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020204c:	000cdc17          	auipc	s8,0xcd
ffffffffc0202050:	f1cc0c13          	addi	s8,s8,-228 # ffffffffc02cef68 <pages>
ffffffffc0202054:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202058:	000cdd17          	auipc	s10,0xcd
ffffffffc020205c:	f18d0d13          	addi	s10,s10,-232 # ffffffffc02cef70 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202060:	00200b37          	lui	s6,0x200
ffffffffc0202064:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202068:	4601                	li	a2,0
ffffffffc020206a:	85a2                	mv	a1,s0
ffffffffc020206c:	854e                	mv	a0,s3
ffffffffc020206e:	d73ff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0202072:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202074:	cd29                	beqz	a0,ffffffffc02020ce <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0202076:	611c                	ld	a5,0(a0)
ffffffffc0202078:	e395                	bnez	a5,ffffffffc020209c <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020207a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020207c:	ff2466e3          	bltu	s0,s2,ffffffffc0202068 <unmap_range+0x62>
}
ffffffffc0202080:	70a6                	ld	ra,104(sp)
ffffffffc0202082:	7406                	ld	s0,96(sp)
ffffffffc0202084:	64e6                	ld	s1,88(sp)
ffffffffc0202086:	6946                	ld	s2,80(sp)
ffffffffc0202088:	69a6                	ld	s3,72(sp)
ffffffffc020208a:	6a06                	ld	s4,64(sp)
ffffffffc020208c:	7ae2                	ld	s5,56(sp)
ffffffffc020208e:	7b42                	ld	s6,48(sp)
ffffffffc0202090:	7ba2                	ld	s7,40(sp)
ffffffffc0202092:	7c02                	ld	s8,32(sp)
ffffffffc0202094:	6ce2                	ld	s9,24(sp)
ffffffffc0202096:	6d42                	ld	s10,16(sp)
ffffffffc0202098:	6165                	addi	sp,sp,112
ffffffffc020209a:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020209c:	0017f713          	andi	a4,a5,1
ffffffffc02020a0:	df69                	beqz	a4,ffffffffc020207a <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02020a2:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02020a6:	078a                	slli	a5,a5,0x2
ffffffffc02020a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020aa:	08e7ff63          	bgeu	a5,a4,ffffffffc0202148 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02020ae:	000c3503          	ld	a0,0(s8)
ffffffffc02020b2:	97de                	add	a5,a5,s7
ffffffffc02020b4:	079a                	slli	a5,a5,0x6
ffffffffc02020b6:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020b8:	411c                	lw	a5,0(a0)
ffffffffc02020ba:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020be:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020c0:	cf11                	beqz	a4,ffffffffc02020dc <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020c2:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020c6:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020ca:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020cc:	bf45                	j	ffffffffc020207c <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020ce:	945a                	add	s0,s0,s6
ffffffffc02020d0:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020d4:	d455                	beqz	s0,ffffffffc0202080 <unmap_range+0x7a>
ffffffffc02020d6:	f92469e3          	bltu	s0,s2,ffffffffc0202068 <unmap_range+0x62>
ffffffffc02020da:	b75d                	j	ffffffffc0202080 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020dc:	100027f3          	csrr	a5,sstatus
ffffffffc02020e0:	8b89                	andi	a5,a5,2
ffffffffc02020e2:	e799                	bnez	a5,ffffffffc02020f0 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020e4:	000d3783          	ld	a5,0(s10)
ffffffffc02020e8:	4585                	li	a1,1
ffffffffc02020ea:	739c                	ld	a5,32(a5)
ffffffffc02020ec:	9782                	jalr	a5
    if (flag) {
ffffffffc02020ee:	bfd1                	j	ffffffffc02020c2 <unmap_range+0xbc>
ffffffffc02020f0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020f2:	d4efe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc02020f6:	000d3783          	ld	a5,0(s10)
ffffffffc02020fa:	6522                	ld	a0,8(sp)
ffffffffc02020fc:	4585                	li	a1,1
ffffffffc02020fe:	739c                	ld	a5,32(a5)
ffffffffc0202100:	9782                	jalr	a5
        intr_enable();
ffffffffc0202102:	d38fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202106:	bf75                	j	ffffffffc02020c2 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202108:	00006697          	auipc	a3,0x6
ffffffffc020210c:	9c068693          	addi	a3,a3,-1600 # ffffffffc0207ac8 <default_pmm_manager+0x160>
ffffffffc0202110:	00005617          	auipc	a2,0x5
ffffffffc0202114:	1c060613          	addi	a2,a2,448 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202118:	13f00593          	li	a1,319
ffffffffc020211c:	00006517          	auipc	a0,0x6
ffffffffc0202120:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202124:	b5afe0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202128:	00006697          	auipc	a3,0x6
ffffffffc020212c:	9d068693          	addi	a3,a3,-1584 # ffffffffc0207af8 <default_pmm_manager+0x190>
ffffffffc0202130:	00005617          	auipc	a2,0x5
ffffffffc0202134:	1a060613          	addi	a2,a2,416 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202138:	14000593          	li	a1,320
ffffffffc020213c:	00006517          	auipc	a0,0x6
ffffffffc0202140:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202144:	b3afe0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0202148:	b55ff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>

ffffffffc020214c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020214c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020214e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202152:	fc86                	sd	ra,120(sp)
ffffffffc0202154:	f8a2                	sd	s0,112(sp)
ffffffffc0202156:	f4a6                	sd	s1,104(sp)
ffffffffc0202158:	f0ca                	sd	s2,96(sp)
ffffffffc020215a:	ecce                	sd	s3,88(sp)
ffffffffc020215c:	e8d2                	sd	s4,80(sp)
ffffffffc020215e:	e4d6                	sd	s5,72(sp)
ffffffffc0202160:	e0da                	sd	s6,64(sp)
ffffffffc0202162:	fc5e                	sd	s7,56(sp)
ffffffffc0202164:	f862                	sd	s8,48(sp)
ffffffffc0202166:	f466                	sd	s9,40(sp)
ffffffffc0202168:	f06a                	sd	s10,32(sp)
ffffffffc020216a:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020216c:	17d2                	slli	a5,a5,0x34
ffffffffc020216e:	20079a63          	bnez	a5,ffffffffc0202382 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202172:	002007b7          	lui	a5,0x200
ffffffffc0202176:	24f5e463          	bltu	a1,a5,ffffffffc02023be <exit_range+0x272>
ffffffffc020217a:	8ab2                	mv	s5,a2
ffffffffc020217c:	24c5f163          	bgeu	a1,a2,ffffffffc02023be <exit_range+0x272>
ffffffffc0202180:	4785                	li	a5,1
ffffffffc0202182:	07fe                	slli	a5,a5,0x1f
ffffffffc0202184:	22c7ed63          	bltu	a5,a2,ffffffffc02023be <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202188:	c00009b7          	lui	s3,0xc0000
ffffffffc020218c:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202190:	ffe00937          	lui	s2,0xffe00
ffffffffc0202194:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202198:	5cfd                	li	s9,-1
ffffffffc020219a:	8c2a                	mv	s8,a0
ffffffffc020219c:	0125f933          	and	s2,a1,s2
ffffffffc02021a0:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc02021a2:	000cdd17          	auipc	s10,0xcd
ffffffffc02021a6:	dbed0d13          	addi	s10,s10,-578 # ffffffffc02cef60 <npage>
    return KADDR(page2pa(page));
ffffffffc02021aa:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02021ae:	000cd717          	auipc	a4,0xcd
ffffffffc02021b2:	dba70713          	addi	a4,a4,-582 # ffffffffc02cef68 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02021b6:	000cdd97          	auipc	s11,0xcd
ffffffffc02021ba:	dbad8d93          	addi	s11,s11,-582 # ffffffffc02cef70 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021be:	c0000437          	lui	s0,0xc0000
ffffffffc02021c2:	944e                	add	s0,s0,s3
ffffffffc02021c4:	8079                	srli	s0,s0,0x1e
ffffffffc02021c6:	1ff47413          	andi	s0,s0,511
ffffffffc02021ca:	040e                	slli	s0,s0,0x3
ffffffffc02021cc:	9462                	add	s0,s0,s8
ffffffffc02021ce:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38c8>
        if (pde1&PTE_V){
ffffffffc02021d2:	001a7793          	andi	a5,s4,1
ffffffffc02021d6:	eb99                	bnez	a5,ffffffffc02021ec <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021d8:	12098463          	beqz	s3,ffffffffc0202300 <exit_range+0x1b4>
ffffffffc02021dc:	400007b7          	lui	a5,0x40000
ffffffffc02021e0:	97ce                	add	a5,a5,s3
ffffffffc02021e2:	894e                	mv	s2,s3
ffffffffc02021e4:	1159fe63          	bgeu	s3,s5,ffffffffc0202300 <exit_range+0x1b4>
ffffffffc02021e8:	89be                	mv	s3,a5
ffffffffc02021ea:	bfd1                	j	ffffffffc02021be <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021ec:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021f0:	0a0a                	slli	s4,s4,0x2
ffffffffc02021f2:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021f6:	1cfa7263          	bgeu	s4,a5,ffffffffc02023ba <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021fa:	fff80637          	lui	a2,0xfff80
ffffffffc02021fe:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202200:	000806b7          	lui	a3,0x80
ffffffffc0202204:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202206:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020220a:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020220c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020220e:	18f5fa63          	bgeu	a1,a5,ffffffffc02023a2 <exit_range+0x256>
ffffffffc0202212:	000cd817          	auipc	a6,0xcd
ffffffffc0202216:	d6680813          	addi	a6,a6,-666 # ffffffffc02cef78 <va_pa_offset>
ffffffffc020221a:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020221e:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202220:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202224:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202226:	00080337          	lui	t1,0x80
ffffffffc020222a:	6885                	lui	a7,0x1
ffffffffc020222c:	a819                	j	ffffffffc0202242 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020222e:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202230:	002007b7          	lui	a5,0x200
ffffffffc0202234:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202236:	08090c63          	beqz	s2,ffffffffc02022ce <exit_range+0x182>
ffffffffc020223a:	09397a63          	bgeu	s2,s3,ffffffffc02022ce <exit_range+0x182>
ffffffffc020223e:	0f597063          	bgeu	s2,s5,ffffffffc020231e <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202242:	01595493          	srli	s1,s2,0x15
ffffffffc0202246:	1ff4f493          	andi	s1,s1,511
ffffffffc020224a:	048e                	slli	s1,s1,0x3
ffffffffc020224c:	94da                	add	s1,s1,s6
ffffffffc020224e:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0202250:	0017f693          	andi	a3,a5,1
ffffffffc0202254:	dee9                	beqz	a3,ffffffffc020222e <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0202256:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020225a:	078a                	slli	a5,a5,0x2
ffffffffc020225c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020225e:	14b7fe63          	bgeu	a5,a1,ffffffffc02023ba <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202262:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202264:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202268:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020226c:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202270:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202272:	12bef863          	bgeu	t4,a1,ffffffffc02023a2 <exit_range+0x256>
ffffffffc0202276:	00083783          	ld	a5,0(a6)
ffffffffc020227a:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020227c:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202280:	629c                	ld	a5,0(a3)
ffffffffc0202282:	8b85                	andi	a5,a5,1
ffffffffc0202284:	f7d5                	bnez	a5,ffffffffc0202230 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202286:	06a1                	addi	a3,a3,8
ffffffffc0202288:	fed59ce3          	bne	a1,a3,ffffffffc0202280 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020228c:	631c                	ld	a5,0(a4)
ffffffffc020228e:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202290:	100027f3          	csrr	a5,sstatus
ffffffffc0202294:	8b89                	andi	a5,a5,2
ffffffffc0202296:	e7d9                	bnez	a5,ffffffffc0202324 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202298:	000db783          	ld	a5,0(s11)
ffffffffc020229c:	4585                	li	a1,1
ffffffffc020229e:	e032                	sd	a2,0(sp)
ffffffffc02022a0:	739c                	ld	a5,32(a5)
ffffffffc02022a2:	9782                	jalr	a5
    if (flag) {
ffffffffc02022a4:	6602                	ld	a2,0(sp)
ffffffffc02022a6:	000cd817          	auipc	a6,0xcd
ffffffffc02022aa:	cd280813          	addi	a6,a6,-814 # ffffffffc02cef78 <va_pa_offset>
ffffffffc02022ae:	fff80e37          	lui	t3,0xfff80
ffffffffc02022b2:	00080337          	lui	t1,0x80
ffffffffc02022b6:	6885                	lui	a7,0x1
ffffffffc02022b8:	000cd717          	auipc	a4,0xcd
ffffffffc02022bc:	cb070713          	addi	a4,a4,-848 # ffffffffc02cef68 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022c0:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022c4:	002007b7          	lui	a5,0x200
ffffffffc02022c8:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022ca:	f60918e3          	bnez	s2,ffffffffc020223a <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022ce:	f00b85e3          	beqz	s7,ffffffffc02021d8 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022d2:	000d3783          	ld	a5,0(s10)
ffffffffc02022d6:	0efa7263          	bgeu	s4,a5,ffffffffc02023ba <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022da:	6308                	ld	a0,0(a4)
ffffffffc02022dc:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022de:	100027f3          	csrr	a5,sstatus
ffffffffc02022e2:	8b89                	andi	a5,a5,2
ffffffffc02022e4:	efad                	bnez	a5,ffffffffc020235e <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022e6:	000db783          	ld	a5,0(s11)
ffffffffc02022ea:	4585                	li	a1,1
ffffffffc02022ec:	739c                	ld	a5,32(a5)
ffffffffc02022ee:	9782                	jalr	a5
ffffffffc02022f0:	000cd717          	auipc	a4,0xcd
ffffffffc02022f4:	c7870713          	addi	a4,a4,-904 # ffffffffc02cef68 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022f8:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02022fc:	ee0990e3          	bnez	s3,ffffffffc02021dc <exit_range+0x90>
}
ffffffffc0202300:	70e6                	ld	ra,120(sp)
ffffffffc0202302:	7446                	ld	s0,112(sp)
ffffffffc0202304:	74a6                	ld	s1,104(sp)
ffffffffc0202306:	7906                	ld	s2,96(sp)
ffffffffc0202308:	69e6                	ld	s3,88(sp)
ffffffffc020230a:	6a46                	ld	s4,80(sp)
ffffffffc020230c:	6aa6                	ld	s5,72(sp)
ffffffffc020230e:	6b06                	ld	s6,64(sp)
ffffffffc0202310:	7be2                	ld	s7,56(sp)
ffffffffc0202312:	7c42                	ld	s8,48(sp)
ffffffffc0202314:	7ca2                	ld	s9,40(sp)
ffffffffc0202316:	7d02                	ld	s10,32(sp)
ffffffffc0202318:	6de2                	ld	s11,24(sp)
ffffffffc020231a:	6109                	addi	sp,sp,128
ffffffffc020231c:	8082                	ret
            if (free_pd0) {
ffffffffc020231e:	ea0b8fe3          	beqz	s7,ffffffffc02021dc <exit_range+0x90>
ffffffffc0202322:	bf45                	j	ffffffffc02022d2 <exit_range+0x186>
ffffffffc0202324:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202326:	e42a                	sd	a0,8(sp)
ffffffffc0202328:	b18fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020232c:	000db783          	ld	a5,0(s11)
ffffffffc0202330:	6522                	ld	a0,8(sp)
ffffffffc0202332:	4585                	li	a1,1
ffffffffc0202334:	739c                	ld	a5,32(a5)
ffffffffc0202336:	9782                	jalr	a5
        intr_enable();
ffffffffc0202338:	b02fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc020233c:	6602                	ld	a2,0(sp)
ffffffffc020233e:	000cd717          	auipc	a4,0xcd
ffffffffc0202342:	c2a70713          	addi	a4,a4,-982 # ffffffffc02cef68 <pages>
ffffffffc0202346:	6885                	lui	a7,0x1
ffffffffc0202348:	00080337          	lui	t1,0x80
ffffffffc020234c:	fff80e37          	lui	t3,0xfff80
ffffffffc0202350:	000cd817          	auipc	a6,0xcd
ffffffffc0202354:	c2880813          	addi	a6,a6,-984 # ffffffffc02cef78 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202358:	0004b023          	sd	zero,0(s1)
ffffffffc020235c:	b7a5                	j	ffffffffc02022c4 <exit_range+0x178>
ffffffffc020235e:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202360:	ae0fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202364:	000db783          	ld	a5,0(s11)
ffffffffc0202368:	6502                	ld	a0,0(sp)
ffffffffc020236a:	4585                	li	a1,1
ffffffffc020236c:	739c                	ld	a5,32(a5)
ffffffffc020236e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202370:	acafe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202374:	000cd717          	auipc	a4,0xcd
ffffffffc0202378:	bf470713          	addi	a4,a4,-1036 # ffffffffc02cef68 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020237c:	00043023          	sd	zero,0(s0)
ffffffffc0202380:	bfb5                	j	ffffffffc02022fc <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202382:	00005697          	auipc	a3,0x5
ffffffffc0202386:	74668693          	addi	a3,a3,1862 # ffffffffc0207ac8 <default_pmm_manager+0x160>
ffffffffc020238a:	00005617          	auipc	a2,0x5
ffffffffc020238e:	f4660613          	addi	a2,a2,-186 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202392:	15000593          	li	a1,336
ffffffffc0202396:	00005517          	auipc	a0,0x5
ffffffffc020239a:	72250513          	addi	a0,a0,1826 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020239e:	8e0fe0ef          	jal	ra,ffffffffc020047e <__panic>
    return KADDR(page2pa(page));
ffffffffc02023a2:	00005617          	auipc	a2,0x5
ffffffffc02023a6:	5fe60613          	addi	a2,a2,1534 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc02023aa:	06900593          	li	a1,105
ffffffffc02023ae:	00005517          	auipc	a0,0x5
ffffffffc02023b2:	61a50513          	addi	a0,a0,1562 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02023b6:	8c8fe0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc02023ba:	8e3ff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023be:	00005697          	auipc	a3,0x5
ffffffffc02023c2:	73a68693          	addi	a3,a3,1850 # ffffffffc0207af8 <default_pmm_manager+0x190>
ffffffffc02023c6:	00005617          	auipc	a2,0x5
ffffffffc02023ca:	f0a60613          	addi	a2,a2,-246 # ffffffffc02072d0 <commands+0x450>
ffffffffc02023ce:	15100593          	li	a1,337
ffffffffc02023d2:	00005517          	auipc	a0,0x5
ffffffffc02023d6:	6e650513          	addi	a0,a0,1766 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02023da:	8a4fe0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02023de <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023de:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023e0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023e2:	ec26                	sd	s1,24(sp)
ffffffffc02023e4:	f406                	sd	ra,40(sp)
ffffffffc02023e6:	f022                	sd	s0,32(sp)
ffffffffc02023e8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023ea:	9f7ff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
    if (ptep != NULL) {
ffffffffc02023ee:	c511                	beqz	a0,ffffffffc02023fa <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023f0:	611c                	ld	a5,0(a0)
ffffffffc02023f2:	842a                	mv	s0,a0
ffffffffc02023f4:	0017f713          	andi	a4,a5,1
ffffffffc02023f8:	e711                	bnez	a4,ffffffffc0202404 <page_remove+0x26>
}
ffffffffc02023fa:	70a2                	ld	ra,40(sp)
ffffffffc02023fc:	7402                	ld	s0,32(sp)
ffffffffc02023fe:	64e2                	ld	s1,24(sp)
ffffffffc0202400:	6145                	addi	sp,sp,48
ffffffffc0202402:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202404:	078a                	slli	a5,a5,0x2
ffffffffc0202406:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202408:	000cd717          	auipc	a4,0xcd
ffffffffc020240c:	b5873703          	ld	a4,-1192(a4) # ffffffffc02cef60 <npage>
ffffffffc0202410:	06e7f363          	bgeu	a5,a4,ffffffffc0202476 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202414:	fff80537          	lui	a0,0xfff80
ffffffffc0202418:	97aa                	add	a5,a5,a0
ffffffffc020241a:	079a                	slli	a5,a5,0x6
ffffffffc020241c:	000cd517          	auipc	a0,0xcd
ffffffffc0202420:	b4c53503          	ld	a0,-1204(a0) # ffffffffc02cef68 <pages>
ffffffffc0202424:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202426:	411c                	lw	a5,0(a0)
ffffffffc0202428:	fff7871b          	addiw	a4,a5,-1
ffffffffc020242c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020242e:	cb11                	beqz	a4,ffffffffc0202442 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202430:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202434:	12048073          	sfence.vma	s1
}
ffffffffc0202438:	70a2                	ld	ra,40(sp)
ffffffffc020243a:	7402                	ld	s0,32(sp)
ffffffffc020243c:	64e2                	ld	s1,24(sp)
ffffffffc020243e:	6145                	addi	sp,sp,48
ffffffffc0202440:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202442:	100027f3          	csrr	a5,sstatus
ffffffffc0202446:	8b89                	andi	a5,a5,2
ffffffffc0202448:	eb89                	bnez	a5,ffffffffc020245a <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020244a:	000cd797          	auipc	a5,0xcd
ffffffffc020244e:	b267b783          	ld	a5,-1242(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0202452:	739c                	ld	a5,32(a5)
ffffffffc0202454:	4585                	li	a1,1
ffffffffc0202456:	9782                	jalr	a5
    if (flag) {
ffffffffc0202458:	bfe1                	j	ffffffffc0202430 <page_remove+0x52>
        intr_disable();
ffffffffc020245a:	e42a                	sd	a0,8(sp)
ffffffffc020245c:	9e4fe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202460:	000cd797          	auipc	a5,0xcd
ffffffffc0202464:	b107b783          	ld	a5,-1264(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0202468:	739c                	ld	a5,32(a5)
ffffffffc020246a:	6522                	ld	a0,8(sp)
ffffffffc020246c:	4585                	li	a1,1
ffffffffc020246e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202470:	9cafe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202474:	bf75                	j	ffffffffc0202430 <page_remove+0x52>
ffffffffc0202476:	827ff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>

ffffffffc020247a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020247a:	7139                	addi	sp,sp,-64
ffffffffc020247c:	e852                	sd	s4,16(sp)
ffffffffc020247e:	8a32                	mv	s4,a2
ffffffffc0202480:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202482:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202484:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202486:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202488:	f426                	sd	s1,40(sp)
ffffffffc020248a:	fc06                	sd	ra,56(sp)
ffffffffc020248c:	f04a                	sd	s2,32(sp)
ffffffffc020248e:	ec4e                	sd	s3,24(sp)
ffffffffc0202490:	e456                	sd	s5,8(sp)
ffffffffc0202492:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202494:	94dff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
    if (ptep == NULL) {
ffffffffc0202498:	c961                	beqz	a0,ffffffffc0202568 <page_insert+0xee>
    page->ref += 1;
ffffffffc020249a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020249c:	611c                	ld	a5,0(a0)
ffffffffc020249e:	89aa                	mv	s3,a0
ffffffffc02024a0:	0016871b          	addiw	a4,a3,1
ffffffffc02024a4:	c018                	sw	a4,0(s0)
ffffffffc02024a6:	0017f713          	andi	a4,a5,1
ffffffffc02024aa:	ef05                	bnez	a4,ffffffffc02024e2 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02024ac:	000cd717          	auipc	a4,0xcd
ffffffffc02024b0:	abc73703          	ld	a4,-1348(a4) # ffffffffc02cef68 <pages>
ffffffffc02024b4:	8c19                	sub	s0,s0,a4
ffffffffc02024b6:	000807b7          	lui	a5,0x80
ffffffffc02024ba:	8419                	srai	s0,s0,0x6
ffffffffc02024bc:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024be:	042a                	slli	s0,s0,0xa
ffffffffc02024c0:	8cc1                	or	s1,s1,s0
ffffffffc02024c2:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024c6:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38c8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024ca:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024ce:	4501                	li	a0,0
}
ffffffffc02024d0:	70e2                	ld	ra,56(sp)
ffffffffc02024d2:	7442                	ld	s0,48(sp)
ffffffffc02024d4:	74a2                	ld	s1,40(sp)
ffffffffc02024d6:	7902                	ld	s2,32(sp)
ffffffffc02024d8:	69e2                	ld	s3,24(sp)
ffffffffc02024da:	6a42                	ld	s4,16(sp)
ffffffffc02024dc:	6aa2                	ld	s5,8(sp)
ffffffffc02024de:	6121                	addi	sp,sp,64
ffffffffc02024e0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024e2:	078a                	slli	a5,a5,0x2
ffffffffc02024e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024e6:	000cd717          	auipc	a4,0xcd
ffffffffc02024ea:	a7a73703          	ld	a4,-1414(a4) # ffffffffc02cef60 <npage>
ffffffffc02024ee:	06e7ff63          	bgeu	a5,a4,ffffffffc020256c <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024f2:	000cda97          	auipc	s5,0xcd
ffffffffc02024f6:	a76a8a93          	addi	s5,s5,-1418 # ffffffffc02cef68 <pages>
ffffffffc02024fa:	000ab703          	ld	a4,0(s5)
ffffffffc02024fe:	fff80937          	lui	s2,0xfff80
ffffffffc0202502:	993e                	add	s2,s2,a5
ffffffffc0202504:	091a                	slli	s2,s2,0x6
ffffffffc0202506:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202508:	01240c63          	beq	s0,s2,ffffffffc0202520 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020250c:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcb1028>
ffffffffc0202510:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202514:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202518:	c691                	beqz	a3,ffffffffc0202524 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020251a:	120a0073          	sfence.vma	s4
}
ffffffffc020251e:	bf59                	j	ffffffffc02024b4 <page_insert+0x3a>
ffffffffc0202520:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202522:	bf49                	j	ffffffffc02024b4 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202524:	100027f3          	csrr	a5,sstatus
ffffffffc0202528:	8b89                	andi	a5,a5,2
ffffffffc020252a:	ef91                	bnez	a5,ffffffffc0202546 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020252c:	000cd797          	auipc	a5,0xcd
ffffffffc0202530:	a447b783          	ld	a5,-1468(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0202534:	739c                	ld	a5,32(a5)
ffffffffc0202536:	4585                	li	a1,1
ffffffffc0202538:	854a                	mv	a0,s2
ffffffffc020253a:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020253c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202540:	120a0073          	sfence.vma	s4
ffffffffc0202544:	bf85                	j	ffffffffc02024b4 <page_insert+0x3a>
        intr_disable();
ffffffffc0202546:	8fafe0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020254a:	000cd797          	auipc	a5,0xcd
ffffffffc020254e:	a267b783          	ld	a5,-1498(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0202552:	739c                	ld	a5,32(a5)
ffffffffc0202554:	4585                	li	a1,1
ffffffffc0202556:	854a                	mv	a0,s2
ffffffffc0202558:	9782                	jalr	a5
        intr_enable();
ffffffffc020255a:	8e0fe0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc020255e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202562:	120a0073          	sfence.vma	s4
ffffffffc0202566:	b7b9                	j	ffffffffc02024b4 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202568:	5571                	li	a0,-4
ffffffffc020256a:	b79d                	j	ffffffffc02024d0 <page_insert+0x56>
ffffffffc020256c:	f30ff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>

ffffffffc0202570 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202570:	00005797          	auipc	a5,0x5
ffffffffc0202574:	3f878793          	addi	a5,a5,1016 # ffffffffc0207968 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202578:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020257a:	711d                	addi	sp,sp,-96
ffffffffc020257c:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020257e:	00005517          	auipc	a0,0x5
ffffffffc0202582:	59250513          	addi	a0,a0,1426 # ffffffffc0207b10 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202586:	000cdb97          	auipc	s7,0xcd
ffffffffc020258a:	9eab8b93          	addi	s7,s7,-1558 # ffffffffc02cef70 <pmm_manager>
void pmm_init(void) {
ffffffffc020258e:	ec86                	sd	ra,88(sp)
ffffffffc0202590:	e4a6                	sd	s1,72(sp)
ffffffffc0202592:	fc4e                	sd	s3,56(sp)
ffffffffc0202594:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202596:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020259a:	e8a2                	sd	s0,80(sp)
ffffffffc020259c:	e0ca                	sd	s2,64(sp)
ffffffffc020259e:	f852                	sd	s4,48(sp)
ffffffffc02025a0:	f456                	sd	s5,40(sp)
ffffffffc02025a2:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025a4:	be1fd0ef          	jal	ra,ffffffffc0200184 <cprintf>
    pmm_manager->init();
ffffffffc02025a8:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025ac:	000cd997          	auipc	s3,0xcd
ffffffffc02025b0:	9cc98993          	addi	s3,s3,-1588 # ffffffffc02cef78 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02025b4:	000cd497          	auipc	s1,0xcd
ffffffffc02025b8:	9ac48493          	addi	s1,s1,-1620 # ffffffffc02cef60 <npage>
    pmm_manager->init();
ffffffffc02025bc:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025be:	000cdb17          	auipc	s6,0xcd
ffffffffc02025c2:	9aab0b13          	addi	s6,s6,-1622 # ffffffffc02cef68 <pages>
    pmm_manager->init();
ffffffffc02025c6:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025c8:	57f5                	li	a5,-3
ffffffffc02025ca:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025cc:	00005517          	auipc	a0,0x5
ffffffffc02025d0:	55c50513          	addi	a0,a0,1372 # ffffffffc0207b28 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025d4:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025d8:	badfd0ef          	jal	ra,ffffffffc0200184 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025dc:	46c5                	li	a3,17
ffffffffc02025de:	06ee                	slli	a3,a3,0x1b
ffffffffc02025e0:	40100613          	li	a2,1025
ffffffffc02025e4:	07e005b7          	lui	a1,0x7e00
ffffffffc02025e8:	16fd                	addi	a3,a3,-1
ffffffffc02025ea:	0656                	slli	a2,a2,0x15
ffffffffc02025ec:	00005517          	auipc	a0,0x5
ffffffffc02025f0:	55450513          	addi	a0,a0,1364 # ffffffffc0207b40 <default_pmm_manager+0x1d8>
ffffffffc02025f4:	b91fd0ef          	jal	ra,ffffffffc0200184 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025f8:	777d                	lui	a4,0xfffff
ffffffffc02025fa:	000ce797          	auipc	a5,0xce
ffffffffc02025fe:	9dd78793          	addi	a5,a5,-1571 # ffffffffc02cffd7 <end+0xfff>
ffffffffc0202602:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202604:	00088737          	lui	a4,0x88
ffffffffc0202608:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020260a:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020260e:	4701                	li	a4,0
ffffffffc0202610:	4585                	li	a1,1
ffffffffc0202612:	fff80837          	lui	a6,0xfff80
ffffffffc0202616:	a019                	j	ffffffffc020261c <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202618:	000b3783          	ld	a5,0(s6)
ffffffffc020261c:	00671693          	slli	a3,a4,0x6
ffffffffc0202620:	97b6                	add	a5,a5,a3
ffffffffc0202622:	07a1                	addi	a5,a5,8
ffffffffc0202624:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202628:	6090                	ld	a2,0(s1)
ffffffffc020262a:	0705                	addi	a4,a4,1
ffffffffc020262c:	010607b3          	add	a5,a2,a6
ffffffffc0202630:	fef764e3          	bltu	a4,a5,ffffffffc0202618 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202634:	000b3503          	ld	a0,0(s6)
ffffffffc0202638:	079a                	slli	a5,a5,0x6
ffffffffc020263a:	c0200737          	lui	a4,0xc0200
ffffffffc020263e:	00f506b3          	add	a3,a0,a5
ffffffffc0202642:	60e6e563          	bltu	a3,a4,ffffffffc0202c4c <pmm_init+0x6dc>
ffffffffc0202646:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020264a:	4745                	li	a4,17
ffffffffc020264c:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020264e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202650:	4ae6e563          	bltu	a3,a4,ffffffffc0202afa <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202654:	00005517          	auipc	a0,0x5
ffffffffc0202658:	51450513          	addi	a0,a0,1300 # ffffffffc0207b68 <default_pmm_manager+0x200>
ffffffffc020265c:	b29fd0ef          	jal	ra,ffffffffc0200184 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202660:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202664:	000cd917          	auipc	s2,0xcd
ffffffffc0202668:	8f490913          	addi	s2,s2,-1804 # ffffffffc02cef58 <boot_pgdir>
    pmm_manager->check();
ffffffffc020266c:	7b9c                	ld	a5,48(a5)
ffffffffc020266e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202670:	00005517          	auipc	a0,0x5
ffffffffc0202674:	51050513          	addi	a0,a0,1296 # ffffffffc0207b80 <default_pmm_manager+0x218>
ffffffffc0202678:	b0dfd0ef          	jal	ra,ffffffffc0200184 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020267c:	0000a697          	auipc	a3,0xa
ffffffffc0202680:	98468693          	addi	a3,a3,-1660 # ffffffffc020c000 <boot_page_table_sv39>
ffffffffc0202684:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202688:	c02007b7          	lui	a5,0xc0200
ffffffffc020268c:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c64 <pmm_init+0x6f4>
ffffffffc0202690:	0009b783          	ld	a5,0(s3)
ffffffffc0202694:	8e9d                	sub	a3,a3,a5
ffffffffc0202696:	000cd797          	auipc	a5,0xcd
ffffffffc020269a:	8ad7bd23          	sd	a3,-1862(a5) # ffffffffc02cef50 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020269e:	100027f3          	csrr	a5,sstatus
ffffffffc02026a2:	8b89                	andi	a5,a5,2
ffffffffc02026a4:	48079263          	bnez	a5,ffffffffc0202b28 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026a8:	000bb783          	ld	a5,0(s7)
ffffffffc02026ac:	779c                	ld	a5,40(a5)
ffffffffc02026ae:	9782                	jalr	a5
ffffffffc02026b0:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026b2:	6098                	ld	a4,0(s1)
ffffffffc02026b4:	c80007b7          	lui	a5,0xc8000
ffffffffc02026b8:	83b1                	srli	a5,a5,0xc
ffffffffc02026ba:	5ee7e163          	bltu	a5,a4,ffffffffc0202c9c <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026be:	00093503          	ld	a0,0(s2)
ffffffffc02026c2:	5a050d63          	beqz	a0,ffffffffc0202c7c <pmm_init+0x70c>
ffffffffc02026c6:	03451793          	slli	a5,a0,0x34
ffffffffc02026ca:	5a079963          	bnez	a5,ffffffffc0202c7c <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026ce:	4601                	li	a2,0
ffffffffc02026d0:	4581                	li	a1,0
ffffffffc02026d2:	8e1ff0ef          	jal	ra,ffffffffc0201fb2 <get_page>
ffffffffc02026d6:	62051563          	bnez	a0,ffffffffc0202d00 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026da:	4505                	li	a0,1
ffffffffc02026dc:	df8ff0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc02026e0:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026e2:	00093503          	ld	a0,0(s2)
ffffffffc02026e6:	4681                	li	a3,0
ffffffffc02026e8:	4601                	li	a2,0
ffffffffc02026ea:	85d2                	mv	a1,s4
ffffffffc02026ec:	d8fff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc02026f0:	5e051863          	bnez	a0,ffffffffc0202ce0 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02026f4:	00093503          	ld	a0,0(s2)
ffffffffc02026f8:	4601                	li	a2,0
ffffffffc02026fa:	4581                	li	a1,0
ffffffffc02026fc:	ee4ff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0202700:	5c050063          	beqz	a0,ffffffffc0202cc0 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202704:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202706:	0017f713          	andi	a4,a5,1
ffffffffc020270a:	5a070963          	beqz	a4,ffffffffc0202cbc <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020270e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202710:	078a                	slli	a5,a5,0x2
ffffffffc0202712:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202714:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202718:	000b3683          	ld	a3,0(s6)
ffffffffc020271c:	fff80637          	lui	a2,0xfff80
ffffffffc0202720:	97b2                	add	a5,a5,a2
ffffffffc0202722:	079a                	slli	a5,a5,0x6
ffffffffc0202724:	97b6                	add	a5,a5,a3
ffffffffc0202726:	10fa16e3          	bne	s4,a5,ffffffffc0203032 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020272a:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
ffffffffc020272e:	4785                	li	a5,1
ffffffffc0202730:	12f69de3          	bne	a3,a5,ffffffffc020306a <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202734:	00093503          	ld	a0,0(s2)
ffffffffc0202738:	77fd                	lui	a5,0xfffff
ffffffffc020273a:	6114                	ld	a3,0(a0)
ffffffffc020273c:	068a                	slli	a3,a3,0x2
ffffffffc020273e:	8efd                	and	a3,a3,a5
ffffffffc0202740:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202744:	10e677e3          	bgeu	a2,a4,ffffffffc0203052 <pmm_init+0xae2>
ffffffffc0202748:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020274c:	96e2                	add	a3,a3,s8
ffffffffc020274e:	0006ba83          	ld	s5,0(a3)
ffffffffc0202752:	0a8a                	slli	s5,s5,0x2
ffffffffc0202754:	00fafab3          	and	s5,s5,a5
ffffffffc0202758:	00cad793          	srli	a5,s5,0xc
ffffffffc020275c:	62e7f263          	bgeu	a5,a4,ffffffffc0202d80 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202760:	4601                	li	a2,0
ffffffffc0202762:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202764:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202766:	e7aff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020276a:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020276c:	5f551a63          	bne	a0,s5,ffffffffc0202d60 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0202770:	4505                	li	a0,1
ffffffffc0202772:	d62ff0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0202776:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202778:	00093503          	ld	a0,0(s2)
ffffffffc020277c:	46d1                	li	a3,20
ffffffffc020277e:	6605                	lui	a2,0x1
ffffffffc0202780:	85d6                	mv	a1,s5
ffffffffc0202782:	cf9ff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc0202786:	58051d63          	bnez	a0,ffffffffc0202d20 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020278a:	00093503          	ld	a0,0(s2)
ffffffffc020278e:	4601                	li	a2,0
ffffffffc0202790:	6585                	lui	a1,0x1
ffffffffc0202792:	e4eff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0202796:	0e050ae3          	beqz	a0,ffffffffc020308a <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020279a:	611c                	ld	a5,0(a0)
ffffffffc020279c:	0107f713          	andi	a4,a5,16
ffffffffc02027a0:	6e070d63          	beqz	a4,ffffffffc0202e9a <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02027a4:	8b91                	andi	a5,a5,4
ffffffffc02027a6:	6a078a63          	beqz	a5,ffffffffc0202e5a <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027aa:	00093503          	ld	a0,0(s2)
ffffffffc02027ae:	611c                	ld	a5,0(a0)
ffffffffc02027b0:	8bc1                	andi	a5,a5,16
ffffffffc02027b2:	68078463          	beqz	a5,ffffffffc0202e3a <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02027b6:	000aa703          	lw	a4,0(s5)
ffffffffc02027ba:	4785                	li	a5,1
ffffffffc02027bc:	58f71263          	bne	a4,a5,ffffffffc0202d40 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027c0:	4681                	li	a3,0
ffffffffc02027c2:	6605                	lui	a2,0x1
ffffffffc02027c4:	85d2                	mv	a1,s4
ffffffffc02027c6:	cb5ff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc02027ca:	62051863          	bnez	a0,ffffffffc0202dfa <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02027ce:	000a2703          	lw	a4,0(s4)
ffffffffc02027d2:	4789                	li	a5,2
ffffffffc02027d4:	60f71363          	bne	a4,a5,ffffffffc0202dda <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02027d8:	000aa783          	lw	a5,0(s5)
ffffffffc02027dc:	5c079f63          	bnez	a5,ffffffffc0202dba <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027e0:	00093503          	ld	a0,0(s2)
ffffffffc02027e4:	4601                	li	a2,0
ffffffffc02027e6:	6585                	lui	a1,0x1
ffffffffc02027e8:	df8ff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc02027ec:	5a050763          	beqz	a0,ffffffffc0202d9a <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027f0:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027f2:	00177793          	andi	a5,a4,1
ffffffffc02027f6:	4c078363          	beqz	a5,ffffffffc0202cbc <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02027fa:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027fc:	00271793          	slli	a5,a4,0x2
ffffffffc0202800:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202802:	44d7f363          	bgeu	a5,a3,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202806:	000b3683          	ld	a3,0(s6)
ffffffffc020280a:	fff80637          	lui	a2,0xfff80
ffffffffc020280e:	97b2                	add	a5,a5,a2
ffffffffc0202810:	079a                	slli	a5,a5,0x6
ffffffffc0202812:	97b6                	add	a5,a5,a3
ffffffffc0202814:	6efa1363          	bne	s4,a5,ffffffffc0202efa <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202818:	8b41                	andi	a4,a4,16
ffffffffc020281a:	6c071063          	bnez	a4,ffffffffc0202eda <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020281e:	00093503          	ld	a0,0(s2)
ffffffffc0202822:	4581                	li	a1,0
ffffffffc0202824:	bbbff0ef          	jal	ra,ffffffffc02023de <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202828:	000a2703          	lw	a4,0(s4)
ffffffffc020282c:	4785                	li	a5,1
ffffffffc020282e:	68f71663          	bne	a4,a5,ffffffffc0202eba <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0202832:	000aa783          	lw	a5,0(s5)
ffffffffc0202836:	74079e63          	bnez	a5,ffffffffc0202f92 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020283a:	00093503          	ld	a0,0(s2)
ffffffffc020283e:	6585                	lui	a1,0x1
ffffffffc0202840:	b9fff0ef          	jal	ra,ffffffffc02023de <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202844:	000a2783          	lw	a5,0(s4)
ffffffffc0202848:	72079563          	bnez	a5,ffffffffc0202f72 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc020284c:	000aa783          	lw	a5,0(s5)
ffffffffc0202850:	70079163          	bnez	a5,ffffffffc0202f52 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202854:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202858:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020285a:	000a3683          	ld	a3,0(s4)
ffffffffc020285e:	068a                	slli	a3,a3,0x2
ffffffffc0202860:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202862:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202866:	fff807b7          	lui	a5,0xfff80
ffffffffc020286a:	000b3503          	ld	a0,0(s6)
ffffffffc020286e:	96be                	add	a3,a3,a5
ffffffffc0202870:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202872:	00d507b3          	add	a5,a0,a3
ffffffffc0202876:	4390                	lw	a2,0(a5)
ffffffffc0202878:	4785                	li	a5,1
ffffffffc020287a:	6af61c63          	bne	a2,a5,ffffffffc0202f32 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020287e:	8699                	srai	a3,a3,0x6
ffffffffc0202880:	000805b7          	lui	a1,0x80
ffffffffc0202884:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202886:	00c69613          	slli	a2,a3,0xc
ffffffffc020288a:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020288c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020288e:	68e67663          	bgeu	a2,a4,ffffffffc0202f1a <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202892:	0009b603          	ld	a2,0(s3)
ffffffffc0202896:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202898:	629c                	ld	a5,0(a3)
ffffffffc020289a:	078a                	slli	a5,a5,0x2
ffffffffc020289c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020289e:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028a2:	8f8d                	sub	a5,a5,a1
ffffffffc02028a4:	079a                	slli	a5,a5,0x6
ffffffffc02028a6:	953e                	add	a0,a0,a5
ffffffffc02028a8:	100027f3          	csrr	a5,sstatus
ffffffffc02028ac:	8b89                	andi	a5,a5,2
ffffffffc02028ae:	2c079763          	bnez	a5,ffffffffc0202b7c <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02028b2:	000bb783          	ld	a5,0(s7)
ffffffffc02028b6:	4585                	li	a1,1
ffffffffc02028b8:	739c                	ld	a5,32(a5)
ffffffffc02028ba:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028bc:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028c0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028c2:	078a                	slli	a5,a5,0x2
ffffffffc02028c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028c6:	38e7f163          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ca:	000b3503          	ld	a0,0(s6)
ffffffffc02028ce:	fff80737          	lui	a4,0xfff80
ffffffffc02028d2:	97ba                	add	a5,a5,a4
ffffffffc02028d4:	079a                	slli	a5,a5,0x6
ffffffffc02028d6:	953e                	add	a0,a0,a5
ffffffffc02028d8:	100027f3          	csrr	a5,sstatus
ffffffffc02028dc:	8b89                	andi	a5,a5,2
ffffffffc02028de:	28079363          	bnez	a5,ffffffffc0202b64 <pmm_init+0x5f4>
ffffffffc02028e2:	000bb783          	ld	a5,0(s7)
ffffffffc02028e6:	4585                	li	a1,1
ffffffffc02028e8:	739c                	ld	a5,32(a5)
ffffffffc02028ea:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028ec:	00093783          	ld	a5,0(s2)
ffffffffc02028f0:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fcb1028>
  asm volatile("sfence.vma");
ffffffffc02028f4:	12000073          	sfence.vma
ffffffffc02028f8:	100027f3          	csrr	a5,sstatus
ffffffffc02028fc:	8b89                	andi	a5,a5,2
ffffffffc02028fe:	24079963          	bnez	a5,ffffffffc0202b50 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202902:	000bb783          	ld	a5,0(s7)
ffffffffc0202906:	779c                	ld	a5,40(a5)
ffffffffc0202908:	9782                	jalr	a5
ffffffffc020290a:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020290c:	71441363          	bne	s0,s4,ffffffffc0203012 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202910:	00005517          	auipc	a0,0x5
ffffffffc0202914:	55850513          	addi	a0,a0,1368 # ffffffffc0207e68 <default_pmm_manager+0x500>
ffffffffc0202918:	86dfd0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc020291c:	100027f3          	csrr	a5,sstatus
ffffffffc0202920:	8b89                	andi	a5,a5,2
ffffffffc0202922:	20079d63          	bnez	a5,ffffffffc0202b3c <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202926:	000bb783          	ld	a5,0(s7)
ffffffffc020292a:	779c                	ld	a5,40(a5)
ffffffffc020292c:	9782                	jalr	a5
ffffffffc020292e:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202930:	6098                	ld	a4,0(s1)
ffffffffc0202932:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202936:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202938:	00c71793          	slli	a5,a4,0xc
ffffffffc020293c:	6a05                	lui	s4,0x1
ffffffffc020293e:	02f47c63          	bgeu	s0,a5,ffffffffc0202976 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202942:	00c45793          	srli	a5,s0,0xc
ffffffffc0202946:	00093503          	ld	a0,0(s2)
ffffffffc020294a:	2ee7f263          	bgeu	a5,a4,ffffffffc0202c2e <pmm_init+0x6be>
ffffffffc020294e:	0009b583          	ld	a1,0(s3)
ffffffffc0202952:	4601                	li	a2,0
ffffffffc0202954:	95a2                	add	a1,a1,s0
ffffffffc0202956:	c8aff0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc020295a:	2a050a63          	beqz	a0,ffffffffc0202c0e <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020295e:	611c                	ld	a5,0(a0)
ffffffffc0202960:	078a                	slli	a5,a5,0x2
ffffffffc0202962:	0157f7b3          	and	a5,a5,s5
ffffffffc0202966:	28879463          	bne	a5,s0,ffffffffc0202bee <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020296a:	6098                	ld	a4,0(s1)
ffffffffc020296c:	9452                	add	s0,s0,s4
ffffffffc020296e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202972:	fcf468e3          	bltu	s0,a5,ffffffffc0202942 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202976:	00093783          	ld	a5,0(s2)
ffffffffc020297a:	639c                	ld	a5,0(a5)
ffffffffc020297c:	66079b63          	bnez	a5,ffffffffc0202ff2 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202980:	4505                	li	a0,1
ffffffffc0202982:	b52ff0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0202986:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202988:	00093503          	ld	a0,0(s2)
ffffffffc020298c:	4699                	li	a3,6
ffffffffc020298e:	10000613          	li	a2,256
ffffffffc0202992:	85d6                	mv	a1,s5
ffffffffc0202994:	ae7ff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc0202998:	62051d63          	bnez	a0,ffffffffc0202fd2 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020299c:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd30028>
ffffffffc02029a0:	4785                	li	a5,1
ffffffffc02029a2:	60f71863          	bne	a4,a5,ffffffffc0202fb2 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029a6:	00093503          	ld	a0,0(s2)
ffffffffc02029aa:	6405                	lui	s0,0x1
ffffffffc02029ac:	4699                	li	a3,6
ffffffffc02029ae:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8e68>
ffffffffc02029b2:	85d6                	mv	a1,s5
ffffffffc02029b4:	ac7ff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc02029b8:	46051163          	bnez	a0,ffffffffc0202e1a <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02029bc:	000aa703          	lw	a4,0(s5)
ffffffffc02029c0:	4789                	li	a5,2
ffffffffc02029c2:	72f71463          	bne	a4,a5,ffffffffc02030ea <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029c6:	00005597          	auipc	a1,0x5
ffffffffc02029ca:	5da58593          	addi	a1,a1,1498 # ffffffffc0207fa0 <default_pmm_manager+0x638>
ffffffffc02029ce:	10000513          	li	a0,256
ffffffffc02029d2:	1d2040ef          	jal	ra,ffffffffc0206ba4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029d6:	10040593          	addi	a1,s0,256
ffffffffc02029da:	10000513          	li	a0,256
ffffffffc02029de:	1d8040ef          	jal	ra,ffffffffc0206bb6 <strcmp>
ffffffffc02029e2:	6e051463          	bnez	a0,ffffffffc02030ca <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02029e6:	000b3683          	ld	a3,0(s6)
ffffffffc02029ea:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029ee:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029f0:	40da86b3          	sub	a3,s5,a3
ffffffffc02029f4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02029f6:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02029f8:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02029fa:	8031                	srli	s0,s0,0xc
ffffffffc02029fc:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a00:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a02:	50f77c63          	bgeu	a4,a5,ffffffffc0202f1a <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a06:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a0a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a0e:	96be                	add	a3,a3,a5
ffffffffc0202a10:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a14:	15a040ef          	jal	ra,ffffffffc0206b6e <strlen>
ffffffffc0202a18:	68051963          	bnez	a0,ffffffffc02030aa <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a1c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a20:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a22:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
ffffffffc0202a26:	068a                	slli	a3,a3,0x2
ffffffffc0202a28:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a2a:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c48 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202a2e:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a30:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a32:	4ef47463          	bgeu	s0,a5,ffffffffc0202f1a <pmm_init+0x9aa>
ffffffffc0202a36:	0009b403          	ld	s0,0(s3)
ffffffffc0202a3a:	9436                	add	s0,s0,a3
ffffffffc0202a3c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a40:	8b89                	andi	a5,a5,2
ffffffffc0202a42:	18079b63          	bnez	a5,ffffffffc0202bd8 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202a46:	000bb783          	ld	a5,0(s7)
ffffffffc0202a4a:	4585                	li	a1,1
ffffffffc0202a4c:	8556                	mv	a0,s5
ffffffffc0202a4e:	739c                	ld	a5,32(a5)
ffffffffc0202a50:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a52:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a54:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a56:	078a                	slli	a5,a5,0x2
ffffffffc0202a58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a5a:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a5e:	000b3503          	ld	a0,0(s6)
ffffffffc0202a62:	fff80737          	lui	a4,0xfff80
ffffffffc0202a66:	97ba                	add	a5,a5,a4
ffffffffc0202a68:	079a                	slli	a5,a5,0x6
ffffffffc0202a6a:	953e                	add	a0,a0,a5
ffffffffc0202a6c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a70:	8b89                	andi	a5,a5,2
ffffffffc0202a72:	14079763          	bnez	a5,ffffffffc0202bc0 <pmm_init+0x650>
ffffffffc0202a76:	000bb783          	ld	a5,0(s7)
ffffffffc0202a7a:	4585                	li	a1,1
ffffffffc0202a7c:	739c                	ld	a5,32(a5)
ffffffffc0202a7e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a80:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a84:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a86:	078a                	slli	a5,a5,0x2
ffffffffc0202a88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a8a:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c48 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a8e:	000b3503          	ld	a0,0(s6)
ffffffffc0202a92:	fff80737          	lui	a4,0xfff80
ffffffffc0202a96:	97ba                	add	a5,a5,a4
ffffffffc0202a98:	079a                	slli	a5,a5,0x6
ffffffffc0202a9a:	953e                	add	a0,a0,a5
ffffffffc0202a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0202aa0:	8b89                	andi	a5,a5,2
ffffffffc0202aa2:	10079363          	bnez	a5,ffffffffc0202ba8 <pmm_init+0x638>
ffffffffc0202aa6:	000bb783          	ld	a5,0(s7)
ffffffffc0202aaa:	4585                	li	a1,1
ffffffffc0202aac:	739c                	ld	a5,32(a5)
ffffffffc0202aae:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202ab0:	00093783          	ld	a5,0(s2)
ffffffffc0202ab4:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ab8:	12000073          	sfence.vma
ffffffffc0202abc:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac0:	8b89                	andi	a5,a5,2
ffffffffc0202ac2:	0c079963          	bnez	a5,ffffffffc0202b94 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ac6:	000bb783          	ld	a5,0(s7)
ffffffffc0202aca:	779c                	ld	a5,40(a5)
ffffffffc0202acc:	9782                	jalr	a5
ffffffffc0202ace:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202ad0:	3a8c1563          	bne	s8,s0,ffffffffc0202e7a <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ad4:	00005517          	auipc	a0,0x5
ffffffffc0202ad8:	54450513          	addi	a0,a0,1348 # ffffffffc0208018 <default_pmm_manager+0x6b0>
ffffffffc0202adc:	ea8fd0ef          	jal	ra,ffffffffc0200184 <cprintf>
}
ffffffffc0202ae0:	6446                	ld	s0,80(sp)
ffffffffc0202ae2:	60e6                	ld	ra,88(sp)
ffffffffc0202ae4:	64a6                	ld	s1,72(sp)
ffffffffc0202ae6:	6906                	ld	s2,64(sp)
ffffffffc0202ae8:	79e2                	ld	s3,56(sp)
ffffffffc0202aea:	7a42                	ld	s4,48(sp)
ffffffffc0202aec:	7aa2                	ld	s5,40(sp)
ffffffffc0202aee:	7b02                	ld	s6,32(sp)
ffffffffc0202af0:	6be2                	ld	s7,24(sp)
ffffffffc0202af2:	6c42                	ld	s8,16(sp)
ffffffffc0202af4:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202af6:	fddfe06f          	j	ffffffffc0201ad2 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202afa:	6785                	lui	a5,0x1
ffffffffc0202afc:	17fd                	addi	a5,a5,-1
ffffffffc0202afe:	96be                	add	a3,a3,a5
ffffffffc0202b00:	77fd                	lui	a5,0xfffff
ffffffffc0202b02:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202b04:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b08:	14c6f063          	bgeu	a3,a2,ffffffffc0202c48 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b0c:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b10:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b12:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202b16:	6a10                	ld	a2,16(a2)
ffffffffc0202b18:	069a                	slli	a3,a3,0x6
ffffffffc0202b1a:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202b1e:	9536                	add	a0,a0,a3
ffffffffc0202b20:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b22:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b26:	b63d                	j	ffffffffc0202654 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202b28:	b19fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b2c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b30:	779c                	ld	a5,40(a5)
ffffffffc0202b32:	9782                	jalr	a5
ffffffffc0202b34:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b36:	b05fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202b3a:	bea5                	j	ffffffffc02026b2 <pmm_init+0x142>
        intr_disable();
ffffffffc0202b3c:	b05fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202b40:	000bb783          	ld	a5,0(s7)
ffffffffc0202b44:	779c                	ld	a5,40(a5)
ffffffffc0202b46:	9782                	jalr	a5
ffffffffc0202b48:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b4a:	af1fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202b4e:	b3cd                	j	ffffffffc0202930 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b50:	af1fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202b54:	000bb783          	ld	a5,0(s7)
ffffffffc0202b58:	779c                	ld	a5,40(a5)
ffffffffc0202b5a:	9782                	jalr	a5
ffffffffc0202b5c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b5e:	addfd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202b62:	b36d                	j	ffffffffc020290c <pmm_init+0x39c>
ffffffffc0202b64:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b66:	adbfd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b6a:	000bb783          	ld	a5,0(s7)
ffffffffc0202b6e:	6522                	ld	a0,8(sp)
ffffffffc0202b70:	4585                	li	a1,1
ffffffffc0202b72:	739c                	ld	a5,32(a5)
ffffffffc0202b74:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b76:	ac5fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202b7a:	bb8d                	j	ffffffffc02028ec <pmm_init+0x37c>
ffffffffc0202b7c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b7e:	ac3fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202b82:	000bb783          	ld	a5,0(s7)
ffffffffc0202b86:	6522                	ld	a0,8(sp)
ffffffffc0202b88:	4585                	li	a1,1
ffffffffc0202b8a:	739c                	ld	a5,32(a5)
ffffffffc0202b8c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b8e:	aadfd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202b92:	b32d                	j	ffffffffc02028bc <pmm_init+0x34c>
        intr_disable();
ffffffffc0202b94:	aadfd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b98:	000bb783          	ld	a5,0(s7)
ffffffffc0202b9c:	779c                	ld	a5,40(a5)
ffffffffc0202b9e:	9782                	jalr	a5
ffffffffc0202ba0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ba2:	a99fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202ba6:	b72d                	j	ffffffffc0202ad0 <pmm_init+0x560>
ffffffffc0202ba8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202baa:	a97fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202bae:	000bb783          	ld	a5,0(s7)
ffffffffc0202bb2:	6522                	ld	a0,8(sp)
ffffffffc0202bb4:	4585                	li	a1,1
ffffffffc0202bb6:	739c                	ld	a5,32(a5)
ffffffffc0202bb8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bba:	a81fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202bbe:	bdcd                	j	ffffffffc0202ab0 <pmm_init+0x540>
ffffffffc0202bc0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bc2:	a7ffd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202bc6:	000bb783          	ld	a5,0(s7)
ffffffffc0202bca:	6522                	ld	a0,8(sp)
ffffffffc0202bcc:	4585                	li	a1,1
ffffffffc0202bce:	739c                	ld	a5,32(a5)
ffffffffc0202bd0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bd2:	a69fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202bd6:	b56d                	j	ffffffffc0202a80 <pmm_init+0x510>
        intr_disable();
ffffffffc0202bd8:	a69fd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
ffffffffc0202bdc:	000bb783          	ld	a5,0(s7)
ffffffffc0202be0:	4585                	li	a1,1
ffffffffc0202be2:	8556                	mv	a0,s5
ffffffffc0202be4:	739c                	ld	a5,32(a5)
ffffffffc0202be6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202be8:	a53fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0202bec:	b59d                	j	ffffffffc0202a52 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bee:	00005697          	auipc	a3,0x5
ffffffffc0202bf2:	2da68693          	addi	a3,a3,730 # ffffffffc0207ec8 <default_pmm_manager+0x560>
ffffffffc0202bf6:	00004617          	auipc	a2,0x4
ffffffffc0202bfa:	6da60613          	addi	a2,a2,1754 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202bfe:	25d00593          	li	a1,605
ffffffffc0202c02:	00005517          	auipc	a0,0x5
ffffffffc0202c06:	eb650513          	addi	a0,a0,-330 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c0a:	875fd0ef          	jal	ra,ffffffffc020047e <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c0e:	00005697          	auipc	a3,0x5
ffffffffc0202c12:	27a68693          	addi	a3,a3,634 # ffffffffc0207e88 <default_pmm_manager+0x520>
ffffffffc0202c16:	00004617          	auipc	a2,0x4
ffffffffc0202c1a:	6ba60613          	addi	a2,a2,1722 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202c1e:	25c00593          	li	a1,604
ffffffffc0202c22:	00005517          	auipc	a0,0x5
ffffffffc0202c26:	e9650513          	addi	a0,a0,-362 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c2a:	855fd0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0202c2e:	86a2                	mv	a3,s0
ffffffffc0202c30:	00005617          	auipc	a2,0x5
ffffffffc0202c34:	d7060613          	addi	a2,a2,-656 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0202c38:	25c00593          	li	a1,604
ffffffffc0202c3c:	00005517          	auipc	a0,0x5
ffffffffc0202c40:	e7c50513          	addi	a0,a0,-388 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c44:	83bfd0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0202c48:	854ff0ef          	jal	ra,ffffffffc0201c9c <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c4c:	00005617          	auipc	a2,0x5
ffffffffc0202c50:	dfc60613          	addi	a2,a2,-516 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0202c54:	07f00593          	li	a1,127
ffffffffc0202c58:	00005517          	auipc	a0,0x5
ffffffffc0202c5c:	e6050513          	addi	a0,a0,-416 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c60:	81ffd0ef          	jal	ra,ffffffffc020047e <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c64:	00005617          	auipc	a2,0x5
ffffffffc0202c68:	de460613          	addi	a2,a2,-540 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0202c6c:	0c100593          	li	a1,193
ffffffffc0202c70:	00005517          	auipc	a0,0x5
ffffffffc0202c74:	e4850513          	addi	a0,a0,-440 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c78:	807fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c7c:	00005697          	auipc	a3,0x5
ffffffffc0202c80:	f4468693          	addi	a3,a3,-188 # ffffffffc0207bc0 <default_pmm_manager+0x258>
ffffffffc0202c84:	00004617          	auipc	a2,0x4
ffffffffc0202c88:	64c60613          	addi	a2,a2,1612 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202c8c:	22000593          	li	a1,544
ffffffffc0202c90:	00005517          	auipc	a0,0x5
ffffffffc0202c94:	e2850513          	addi	a0,a0,-472 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202c98:	fe6fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202c9c:	00005697          	auipc	a3,0x5
ffffffffc0202ca0:	f0468693          	addi	a3,a3,-252 # ffffffffc0207ba0 <default_pmm_manager+0x238>
ffffffffc0202ca4:	00004617          	auipc	a2,0x4
ffffffffc0202ca8:	62c60613          	addi	a2,a2,1580 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202cac:	21f00593          	li	a1,543
ffffffffc0202cb0:	00005517          	auipc	a0,0x5
ffffffffc0202cb4:	e0850513          	addi	a0,a0,-504 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202cb8:	fc6fd0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0202cbc:	ffdfe0ef          	jal	ra,ffffffffc0201cb8 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202cc0:	00005697          	auipc	a3,0x5
ffffffffc0202cc4:	f9068693          	addi	a3,a3,-112 # ffffffffc0207c50 <default_pmm_manager+0x2e8>
ffffffffc0202cc8:	00004617          	auipc	a2,0x4
ffffffffc0202ccc:	60860613          	addi	a2,a2,1544 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202cd0:	22800593          	li	a1,552
ffffffffc0202cd4:	00005517          	auipc	a0,0x5
ffffffffc0202cd8:	de450513          	addi	a0,a0,-540 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202cdc:	fa2fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202ce0:	00005697          	auipc	a3,0x5
ffffffffc0202ce4:	f4068693          	addi	a3,a3,-192 # ffffffffc0207c20 <default_pmm_manager+0x2b8>
ffffffffc0202ce8:	00004617          	auipc	a2,0x4
ffffffffc0202cec:	5e860613          	addi	a2,a2,1512 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202cf0:	22500593          	li	a1,549
ffffffffc0202cf4:	00005517          	auipc	a0,0x5
ffffffffc0202cf8:	dc450513          	addi	a0,a0,-572 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202cfc:	f82fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d00:	00005697          	auipc	a3,0x5
ffffffffc0202d04:	ef868693          	addi	a3,a3,-264 # ffffffffc0207bf8 <default_pmm_manager+0x290>
ffffffffc0202d08:	00004617          	auipc	a2,0x4
ffffffffc0202d0c:	5c860613          	addi	a2,a2,1480 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202d10:	22100593          	li	a1,545
ffffffffc0202d14:	00005517          	auipc	a0,0x5
ffffffffc0202d18:	da450513          	addi	a0,a0,-604 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202d1c:	f62fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d20:	00005697          	auipc	a3,0x5
ffffffffc0202d24:	fb868693          	addi	a3,a3,-72 # ffffffffc0207cd8 <default_pmm_manager+0x370>
ffffffffc0202d28:	00004617          	auipc	a2,0x4
ffffffffc0202d2c:	5a860613          	addi	a2,a2,1448 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202d30:	23100593          	li	a1,561
ffffffffc0202d34:	00005517          	auipc	a0,0x5
ffffffffc0202d38:	d8450513          	addi	a0,a0,-636 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202d3c:	f42fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d40:	00005697          	auipc	a3,0x5
ffffffffc0202d44:	03868693          	addi	a3,a3,56 # ffffffffc0207d78 <default_pmm_manager+0x410>
ffffffffc0202d48:	00004617          	auipc	a2,0x4
ffffffffc0202d4c:	58860613          	addi	a2,a2,1416 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202d50:	23600593          	li	a1,566
ffffffffc0202d54:	00005517          	auipc	a0,0x5
ffffffffc0202d58:	d6450513          	addi	a0,a0,-668 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202d5c:	f22fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d60:	00005697          	auipc	a3,0x5
ffffffffc0202d64:	f5068693          	addi	a3,a3,-176 # ffffffffc0207cb0 <default_pmm_manager+0x348>
ffffffffc0202d68:	00004617          	auipc	a2,0x4
ffffffffc0202d6c:	56860613          	addi	a2,a2,1384 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202d70:	22e00593          	li	a1,558
ffffffffc0202d74:	00005517          	auipc	a0,0x5
ffffffffc0202d78:	d4450513          	addi	a0,a0,-700 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202d7c:	f02fd0ef          	jal	ra,ffffffffc020047e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d80:	86d6                	mv	a3,s5
ffffffffc0202d82:	00005617          	auipc	a2,0x5
ffffffffc0202d86:	c1e60613          	addi	a2,a2,-994 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0202d8a:	22d00593          	li	a1,557
ffffffffc0202d8e:	00005517          	auipc	a0,0x5
ffffffffc0202d92:	d2a50513          	addi	a0,a0,-726 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202d96:	ee8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d9a:	00005697          	auipc	a3,0x5
ffffffffc0202d9e:	f7668693          	addi	a3,a3,-138 # ffffffffc0207d10 <default_pmm_manager+0x3a8>
ffffffffc0202da2:	00004617          	auipc	a2,0x4
ffffffffc0202da6:	52e60613          	addi	a2,a2,1326 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202daa:	23b00593          	li	a1,571
ffffffffc0202dae:	00005517          	auipc	a0,0x5
ffffffffc0202db2:	d0a50513          	addi	a0,a0,-758 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202db6:	ec8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dba:	00005697          	auipc	a3,0x5
ffffffffc0202dbe:	01e68693          	addi	a3,a3,30 # ffffffffc0207dd8 <default_pmm_manager+0x470>
ffffffffc0202dc2:	00004617          	auipc	a2,0x4
ffffffffc0202dc6:	50e60613          	addi	a2,a2,1294 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202dca:	23a00593          	li	a1,570
ffffffffc0202dce:	00005517          	auipc	a0,0x5
ffffffffc0202dd2:	cea50513          	addi	a0,a0,-790 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202dd6:	ea8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202dda:	00005697          	auipc	a3,0x5
ffffffffc0202dde:	fe668693          	addi	a3,a3,-26 # ffffffffc0207dc0 <default_pmm_manager+0x458>
ffffffffc0202de2:	00004617          	auipc	a2,0x4
ffffffffc0202de6:	4ee60613          	addi	a2,a2,1262 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202dea:	23900593          	li	a1,569
ffffffffc0202dee:	00005517          	auipc	a0,0x5
ffffffffc0202df2:	cca50513          	addi	a0,a0,-822 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202df6:	e88fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202dfa:	00005697          	auipc	a3,0x5
ffffffffc0202dfe:	f9668693          	addi	a3,a3,-106 # ffffffffc0207d90 <default_pmm_manager+0x428>
ffffffffc0202e02:	00004617          	auipc	a2,0x4
ffffffffc0202e06:	4ce60613          	addi	a2,a2,1230 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202e0a:	23800593          	li	a1,568
ffffffffc0202e0e:	00005517          	auipc	a0,0x5
ffffffffc0202e12:	caa50513          	addi	a0,a0,-854 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202e16:	e68fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e1a:	00005697          	auipc	a3,0x5
ffffffffc0202e1e:	12e68693          	addi	a3,a3,302 # ffffffffc0207f48 <default_pmm_manager+0x5e0>
ffffffffc0202e22:	00004617          	auipc	a2,0x4
ffffffffc0202e26:	4ae60613          	addi	a2,a2,1198 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202e2a:	26700593          	li	a1,615
ffffffffc0202e2e:	00005517          	auipc	a0,0x5
ffffffffc0202e32:	c8a50513          	addi	a0,a0,-886 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202e36:	e48fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e3a:	00005697          	auipc	a3,0x5
ffffffffc0202e3e:	f2668693          	addi	a3,a3,-218 # ffffffffc0207d60 <default_pmm_manager+0x3f8>
ffffffffc0202e42:	00004617          	auipc	a2,0x4
ffffffffc0202e46:	48e60613          	addi	a2,a2,1166 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202e4a:	23500593          	li	a1,565
ffffffffc0202e4e:	00005517          	auipc	a0,0x5
ffffffffc0202e52:	c6a50513          	addi	a0,a0,-918 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202e56:	e28fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e5a:	00005697          	auipc	a3,0x5
ffffffffc0202e5e:	ef668693          	addi	a3,a3,-266 # ffffffffc0207d50 <default_pmm_manager+0x3e8>
ffffffffc0202e62:	00004617          	auipc	a2,0x4
ffffffffc0202e66:	46e60613          	addi	a2,a2,1134 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202e6a:	23400593          	li	a1,564
ffffffffc0202e6e:	00005517          	auipc	a0,0x5
ffffffffc0202e72:	c4a50513          	addi	a0,a0,-950 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202e76:	e08fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e7a:	00005697          	auipc	a3,0x5
ffffffffc0202e7e:	fce68693          	addi	a3,a3,-50 # ffffffffc0207e48 <default_pmm_manager+0x4e0>
ffffffffc0202e82:	00004617          	auipc	a2,0x4
ffffffffc0202e86:	44e60613          	addi	a2,a2,1102 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202e8a:	27800593          	li	a1,632
ffffffffc0202e8e:	00005517          	auipc	a0,0x5
ffffffffc0202e92:	c2a50513          	addi	a0,a0,-982 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202e96:	de8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202e9a:	00005697          	auipc	a3,0x5
ffffffffc0202e9e:	ea668693          	addi	a3,a3,-346 # ffffffffc0207d40 <default_pmm_manager+0x3d8>
ffffffffc0202ea2:	00004617          	auipc	a2,0x4
ffffffffc0202ea6:	42e60613          	addi	a2,a2,1070 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202eaa:	23300593          	li	a1,563
ffffffffc0202eae:	00005517          	auipc	a0,0x5
ffffffffc0202eb2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202eb6:	dc8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202eba:	00005697          	auipc	a3,0x5
ffffffffc0202ebe:	dde68693          	addi	a3,a3,-546 # ffffffffc0207c98 <default_pmm_manager+0x330>
ffffffffc0202ec2:	00004617          	auipc	a2,0x4
ffffffffc0202ec6:	40e60613          	addi	a2,a2,1038 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202eca:	24000593          	li	a1,576
ffffffffc0202ece:	00005517          	auipc	a0,0x5
ffffffffc0202ed2:	bea50513          	addi	a0,a0,-1046 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202ed6:	da8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202eda:	00005697          	auipc	a3,0x5
ffffffffc0202ede:	f1668693          	addi	a3,a3,-234 # ffffffffc0207df0 <default_pmm_manager+0x488>
ffffffffc0202ee2:	00004617          	auipc	a2,0x4
ffffffffc0202ee6:	3ee60613          	addi	a2,a2,1006 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202eea:	23d00593          	li	a1,573
ffffffffc0202eee:	00005517          	auipc	a0,0x5
ffffffffc0202ef2:	bca50513          	addi	a0,a0,-1078 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202ef6:	d88fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202efa:	00005697          	auipc	a3,0x5
ffffffffc0202efe:	d8668693          	addi	a3,a3,-634 # ffffffffc0207c80 <default_pmm_manager+0x318>
ffffffffc0202f02:	00004617          	auipc	a2,0x4
ffffffffc0202f06:	3ce60613          	addi	a2,a2,974 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202f0a:	23c00593          	li	a1,572
ffffffffc0202f0e:	00005517          	auipc	a0,0x5
ffffffffc0202f12:	baa50513          	addi	a0,a0,-1110 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202f16:	d68fd0ef          	jal	ra,ffffffffc020047e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f1a:	00005617          	auipc	a2,0x5
ffffffffc0202f1e:	a8660613          	addi	a2,a2,-1402 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0202f22:	06900593          	li	a1,105
ffffffffc0202f26:	00005517          	auipc	a0,0x5
ffffffffc0202f2a:	aa250513          	addi	a0,a0,-1374 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0202f2e:	d50fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f32:	00005697          	auipc	a3,0x5
ffffffffc0202f36:	eee68693          	addi	a3,a3,-274 # ffffffffc0207e20 <default_pmm_manager+0x4b8>
ffffffffc0202f3a:	00004617          	auipc	a2,0x4
ffffffffc0202f3e:	39660613          	addi	a2,a2,918 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202f42:	24700593          	li	a1,583
ffffffffc0202f46:	00005517          	auipc	a0,0x5
ffffffffc0202f4a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202f4e:	d30fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f52:	00005697          	auipc	a3,0x5
ffffffffc0202f56:	e8668693          	addi	a3,a3,-378 # ffffffffc0207dd8 <default_pmm_manager+0x470>
ffffffffc0202f5a:	00004617          	auipc	a2,0x4
ffffffffc0202f5e:	37660613          	addi	a2,a2,886 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202f62:	24500593          	li	a1,581
ffffffffc0202f66:	00005517          	auipc	a0,0x5
ffffffffc0202f6a:	b5250513          	addi	a0,a0,-1198 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202f6e:	d10fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f72:	00005697          	auipc	a3,0x5
ffffffffc0202f76:	e9668693          	addi	a3,a3,-362 # ffffffffc0207e08 <default_pmm_manager+0x4a0>
ffffffffc0202f7a:	00004617          	auipc	a2,0x4
ffffffffc0202f7e:	35660613          	addi	a2,a2,854 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202f82:	24400593          	li	a1,580
ffffffffc0202f86:	00005517          	auipc	a0,0x5
ffffffffc0202f8a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202f8e:	cf0fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f92:	00005697          	auipc	a3,0x5
ffffffffc0202f96:	e4668693          	addi	a3,a3,-442 # ffffffffc0207dd8 <default_pmm_manager+0x470>
ffffffffc0202f9a:	00004617          	auipc	a2,0x4
ffffffffc0202f9e:	33660613          	addi	a2,a2,822 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202fa2:	24100593          	li	a1,577
ffffffffc0202fa6:	00005517          	auipc	a0,0x5
ffffffffc0202faa:	b1250513          	addi	a0,a0,-1262 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202fae:	cd0fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fb2:	00005697          	auipc	a3,0x5
ffffffffc0202fb6:	f7e68693          	addi	a3,a3,-130 # ffffffffc0207f30 <default_pmm_manager+0x5c8>
ffffffffc0202fba:	00004617          	auipc	a2,0x4
ffffffffc0202fbe:	31660613          	addi	a2,a2,790 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202fc2:	26600593          	li	a1,614
ffffffffc0202fc6:	00005517          	auipc	a0,0x5
ffffffffc0202fca:	af250513          	addi	a0,a0,-1294 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202fce:	cb0fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fd2:	00005697          	auipc	a3,0x5
ffffffffc0202fd6:	f2668693          	addi	a3,a3,-218 # ffffffffc0207ef8 <default_pmm_manager+0x590>
ffffffffc0202fda:	00004617          	auipc	a2,0x4
ffffffffc0202fde:	2f660613          	addi	a2,a2,758 # ffffffffc02072d0 <commands+0x450>
ffffffffc0202fe2:	26500593          	li	a1,613
ffffffffc0202fe6:	00005517          	auipc	a0,0x5
ffffffffc0202fea:	ad250513          	addi	a0,a0,-1326 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0202fee:	c90fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202ff2:	00005697          	auipc	a3,0x5
ffffffffc0202ff6:	eee68693          	addi	a3,a3,-274 # ffffffffc0207ee0 <default_pmm_manager+0x578>
ffffffffc0202ffa:	00004617          	auipc	a2,0x4
ffffffffc0202ffe:	2d660613          	addi	a2,a2,726 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203002:	26100593          	li	a1,609
ffffffffc0203006:	00005517          	auipc	a0,0x5
ffffffffc020300a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020300e:	c70fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203012:	00005697          	auipc	a3,0x5
ffffffffc0203016:	e3668693          	addi	a3,a3,-458 # ffffffffc0207e48 <default_pmm_manager+0x4e0>
ffffffffc020301a:	00004617          	auipc	a2,0x4
ffffffffc020301e:	2b660613          	addi	a2,a2,694 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203022:	24f00593          	li	a1,591
ffffffffc0203026:	00005517          	auipc	a0,0x5
ffffffffc020302a:	a9250513          	addi	a0,a0,-1390 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020302e:	c50fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203032:	00005697          	auipc	a3,0x5
ffffffffc0203036:	c4e68693          	addi	a3,a3,-946 # ffffffffc0207c80 <default_pmm_manager+0x318>
ffffffffc020303a:	00004617          	auipc	a2,0x4
ffffffffc020303e:	29660613          	addi	a2,a2,662 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203042:	22900593          	li	a1,553
ffffffffc0203046:	00005517          	auipc	a0,0x5
ffffffffc020304a:	a7250513          	addi	a0,a0,-1422 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020304e:	c30fd0ef          	jal	ra,ffffffffc020047e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203052:	00005617          	auipc	a2,0x5
ffffffffc0203056:	94e60613          	addi	a2,a2,-1714 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc020305a:	22c00593          	li	a1,556
ffffffffc020305e:	00005517          	auipc	a0,0x5
ffffffffc0203062:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0203066:	c18fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020306a:	00005697          	auipc	a3,0x5
ffffffffc020306e:	c2e68693          	addi	a3,a3,-978 # ffffffffc0207c98 <default_pmm_manager+0x330>
ffffffffc0203072:	00004617          	auipc	a2,0x4
ffffffffc0203076:	25e60613          	addi	a2,a2,606 # ffffffffc02072d0 <commands+0x450>
ffffffffc020307a:	22a00593          	li	a1,554
ffffffffc020307e:	00005517          	auipc	a0,0x5
ffffffffc0203082:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0203086:	bf8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020308a:	00005697          	auipc	a3,0x5
ffffffffc020308e:	c8668693          	addi	a3,a3,-890 # ffffffffc0207d10 <default_pmm_manager+0x3a8>
ffffffffc0203092:	00004617          	auipc	a2,0x4
ffffffffc0203096:	23e60613          	addi	a2,a2,574 # ffffffffc02072d0 <commands+0x450>
ffffffffc020309a:	23200593          	li	a1,562
ffffffffc020309e:	00005517          	auipc	a0,0x5
ffffffffc02030a2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02030a6:	bd8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030aa:	00005697          	auipc	a3,0x5
ffffffffc02030ae:	f4668693          	addi	a3,a3,-186 # ffffffffc0207ff0 <default_pmm_manager+0x688>
ffffffffc02030b2:	00004617          	auipc	a2,0x4
ffffffffc02030b6:	21e60613          	addi	a2,a2,542 # ffffffffc02072d0 <commands+0x450>
ffffffffc02030ba:	26f00593          	li	a1,623
ffffffffc02030be:	00005517          	auipc	a0,0x5
ffffffffc02030c2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02030c6:	bb8fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030ca:	00005697          	auipc	a3,0x5
ffffffffc02030ce:	eee68693          	addi	a3,a3,-274 # ffffffffc0207fb8 <default_pmm_manager+0x650>
ffffffffc02030d2:	00004617          	auipc	a2,0x4
ffffffffc02030d6:	1fe60613          	addi	a2,a2,510 # ffffffffc02072d0 <commands+0x450>
ffffffffc02030da:	26c00593          	li	a1,620
ffffffffc02030de:	00005517          	auipc	a0,0x5
ffffffffc02030e2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02030e6:	b98fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030ea:	00005697          	auipc	a3,0x5
ffffffffc02030ee:	e9e68693          	addi	a3,a3,-354 # ffffffffc0207f88 <default_pmm_manager+0x620>
ffffffffc02030f2:	00004617          	auipc	a2,0x4
ffffffffc02030f6:	1de60613          	addi	a2,a2,478 # ffffffffc02072d0 <commands+0x450>
ffffffffc02030fa:	26800593          	li	a1,616
ffffffffc02030fe:	00005517          	auipc	a0,0x5
ffffffffc0203102:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc0203106:	b78fd0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020310a <copy_range>:
               bool share) {
ffffffffc020310a:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020310c:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0203110:	f486                	sd	ra,104(sp)
ffffffffc0203112:	f0a2                	sd	s0,96(sp)
ffffffffc0203114:	eca6                	sd	s1,88(sp)
ffffffffc0203116:	e8ca                	sd	s2,80(sp)
ffffffffc0203118:	e4ce                	sd	s3,72(sp)
ffffffffc020311a:	e0d2                	sd	s4,64(sp)
ffffffffc020311c:	fc56                	sd	s5,56(sp)
ffffffffc020311e:	f85a                	sd	s6,48(sp)
ffffffffc0203120:	f45e                	sd	s7,40(sp)
ffffffffc0203122:	f062                	sd	s8,32(sp)
ffffffffc0203124:	ec66                	sd	s9,24(sp)
ffffffffc0203126:	e86a                	sd	s10,16(sp)
ffffffffc0203128:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020312a:	17d2                	slli	a5,a5,0x34
ffffffffc020312c:	1c079963          	bnez	a5,ffffffffc02032fe <copy_range+0x1f4>
    assert(USER_ACCESS(start, end));
ffffffffc0203130:	002007b7          	lui	a5,0x200
ffffffffc0203134:	8432                	mv	s0,a2
ffffffffc0203136:	18f66463          	bltu	a2,a5,ffffffffc02032be <copy_range+0x1b4>
ffffffffc020313a:	8936                	mv	s2,a3
ffffffffc020313c:	18d67163          	bgeu	a2,a3,ffffffffc02032be <copy_range+0x1b4>
ffffffffc0203140:	4785                	li	a5,1
ffffffffc0203142:	07fe                	slli	a5,a5,0x1f
ffffffffc0203144:	16d7ed63          	bltu	a5,a3,ffffffffc02032be <copy_range+0x1b4>
ffffffffc0203148:	5afd                	li	s5,-1
ffffffffc020314a:	8a2a                	mv	s4,a0
ffffffffc020314c:	89ae                	mv	s3,a1
    if (PPN(pa) >= npage) {
ffffffffc020314e:	000ccc17          	auipc	s8,0xcc
ffffffffc0203152:	e12c0c13          	addi	s8,s8,-494 # ffffffffc02cef60 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203156:	000ccb97          	auipc	s7,0xcc
ffffffffc020315a:	e12b8b93          	addi	s7,s7,-494 # ffffffffc02cef68 <pages>
ffffffffc020315e:	fff80d37          	lui	s10,0xfff80
    return page - pages + nbase;
ffffffffc0203162:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0203166:	00cada93          	srli	s5,s5,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020316a:	4601                	li	a2,0
ffffffffc020316c:	85a2                	mv	a1,s0
ffffffffc020316e:	854e                	mv	a0,s3
ffffffffc0203170:	c71fe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0203174:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203176:	c179                	beqz	a0,ffffffffc020323c <copy_range+0x132>
        if (*ptep & PTE_V) {
ffffffffc0203178:	611c                	ld	a5,0(a0)
ffffffffc020317a:	8b85                	andi	a5,a5,1
ffffffffc020317c:	e78d                	bnez	a5,ffffffffc02031a6 <copy_range+0x9c>
        start += PGSIZE;
ffffffffc020317e:	6785                	lui	a5,0x1
ffffffffc0203180:	943e                	add	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0203182:	ff2464e3          	bltu	s0,s2,ffffffffc020316a <copy_range+0x60>
    return 0;
ffffffffc0203186:	4501                	li	a0,0
}
ffffffffc0203188:	70a6                	ld	ra,104(sp)
ffffffffc020318a:	7406                	ld	s0,96(sp)
ffffffffc020318c:	64e6                	ld	s1,88(sp)
ffffffffc020318e:	6946                	ld	s2,80(sp)
ffffffffc0203190:	69a6                	ld	s3,72(sp)
ffffffffc0203192:	6a06                	ld	s4,64(sp)
ffffffffc0203194:	7ae2                	ld	s5,56(sp)
ffffffffc0203196:	7b42                	ld	s6,48(sp)
ffffffffc0203198:	7ba2                	ld	s7,40(sp)
ffffffffc020319a:	7c02                	ld	s8,32(sp)
ffffffffc020319c:	6ce2                	ld	s9,24(sp)
ffffffffc020319e:	6d42                	ld	s10,16(sp)
ffffffffc02031a0:	6da2                	ld	s11,8(sp)
ffffffffc02031a2:	6165                	addi	sp,sp,112
ffffffffc02031a4:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031a6:	4605                	li	a2,1
ffffffffc02031a8:	85a2                	mv	a1,s0
ffffffffc02031aa:	8552                	mv	a0,s4
ffffffffc02031ac:	c35fe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc02031b0:	c145                	beqz	a0,ffffffffc0203250 <copy_range+0x146>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031b2:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc02031b4:	0017f713          	andi	a4,a5,1
ffffffffc02031b8:	01f7f493          	andi	s1,a5,31
ffffffffc02031bc:	0e070563          	beqz	a4,ffffffffc02032a6 <copy_range+0x19c>
    if (PPN(pa) >= npage) {
ffffffffc02031c0:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031c4:	078a                	slli	a5,a5,0x2
ffffffffc02031c6:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031ca:	0cd77263          	bgeu	a4,a3,ffffffffc020328e <copy_range+0x184>
    return &pages[PPN(pa) - nbase];
ffffffffc02031ce:	000bb783          	ld	a5,0(s7)
ffffffffc02031d2:	976a                	add	a4,a4,s10
ffffffffc02031d4:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02031d6:	4505                	li	a0,1
ffffffffc02031d8:	00e78cb3          	add	s9,a5,a4
ffffffffc02031dc:	af9fe0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc02031e0:	8daa                	mv	s11,a0
            assert(page != NULL);
ffffffffc02031e2:	080c8663          	beqz	s9,ffffffffc020326e <copy_range+0x164>
            assert(npage != NULL);
ffffffffc02031e6:	0e050c63          	beqz	a0,ffffffffc02032de <copy_range+0x1d4>
    return page - pages + nbase;
ffffffffc02031ea:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc02031ee:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02031f2:	40ec86b3          	sub	a3,s9,a4
ffffffffc02031f6:	8699                	srai	a3,a3,0x6
ffffffffc02031f8:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031fa:	0156f7b3          	and	a5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02031fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203200:	04c7fb63          	bgeu	a5,a2,ffffffffc0203256 <copy_range+0x14c>
    return page - pages + nbase;
ffffffffc0203204:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0203208:	000cc717          	auipc	a4,0xcc
ffffffffc020320c:	d7070713          	addi	a4,a4,-656 # ffffffffc02cef78 <va_pa_offset>
ffffffffc0203210:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0203212:	8799                	srai	a5,a5,0x6
ffffffffc0203214:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0203216:	0157f733          	and	a4,a5,s5
ffffffffc020321a:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020321e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203220:	02c77a63          	bgeu	a4,a2,ffffffffc0203254 <copy_range+0x14a>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0203224:	6605                	lui	a2,0x1
ffffffffc0203226:	953e                	add	a0,a0,a5
ffffffffc0203228:	1d5030ef          	jal	ra,ffffffffc0206bfc <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc020322c:	86a6                	mv	a3,s1
ffffffffc020322e:	8622                	mv	a2,s0
ffffffffc0203230:	85ee                	mv	a1,s11
ffffffffc0203232:	8552                	mv	a0,s4
ffffffffc0203234:	a46ff0ef          	jal	ra,ffffffffc020247a <page_insert>
                if (ret != 0) {
ffffffffc0203238:	d139                	beqz	a0,ffffffffc020317e <copy_range+0x74>
ffffffffc020323a:	b7b9                	j	ffffffffc0203188 <copy_range+0x7e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020323c:	002007b7          	lui	a5,0x200
ffffffffc0203240:	943e                	add	s0,s0,a5
ffffffffc0203242:	ffe007b7          	lui	a5,0xffe00
ffffffffc0203246:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0203248:	dc1d                	beqz	s0,ffffffffc0203186 <copy_range+0x7c>
ffffffffc020324a:	f32460e3          	bltu	s0,s2,ffffffffc020316a <copy_range+0x60>
ffffffffc020324e:	bf25                	j	ffffffffc0203186 <copy_range+0x7c>
                return -E_NO_MEM;
ffffffffc0203250:	5571                	li	a0,-4
ffffffffc0203252:	bf1d                	j	ffffffffc0203188 <copy_range+0x7e>
ffffffffc0203254:	86be                	mv	a3,a5
ffffffffc0203256:	00004617          	auipc	a2,0x4
ffffffffc020325a:	74a60613          	addi	a2,a2,1866 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc020325e:	06900593          	li	a1,105
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	76650513          	addi	a0,a0,1894 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc020326a:	a14fd0ef          	jal	ra,ffffffffc020047e <__panic>
            assert(page != NULL);
ffffffffc020326e:	00005697          	auipc	a3,0x5
ffffffffc0203272:	dca68693          	addi	a3,a3,-566 # ffffffffc0208038 <default_pmm_manager+0x6d0>
ffffffffc0203276:	00004617          	auipc	a2,0x4
ffffffffc020327a:	05a60613          	addi	a2,a2,90 # ffffffffc02072d0 <commands+0x450>
ffffffffc020327e:	1a200593          	li	a1,418
ffffffffc0203282:	00005517          	auipc	a0,0x5
ffffffffc0203286:	83650513          	addi	a0,a0,-1994 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020328a:	9f4fd0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020328e:	00004617          	auipc	a2,0x4
ffffffffc0203292:	7e260613          	addi	a2,a2,2018 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0203296:	06200593          	li	a1,98
ffffffffc020329a:	00004517          	auipc	a0,0x4
ffffffffc020329e:	72e50513          	addi	a0,a0,1838 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02032a2:	9dcfd0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032a6:	00004617          	auipc	a2,0x4
ffffffffc02032aa:	7ea60613          	addi	a2,a2,2026 # ffffffffc0207a90 <default_pmm_manager+0x128>
ffffffffc02032ae:	07400593          	li	a1,116
ffffffffc02032b2:	00004517          	auipc	a0,0x4
ffffffffc02032b6:	71650513          	addi	a0,a0,1814 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02032ba:	9c4fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02032be:	00005697          	auipc	a3,0x5
ffffffffc02032c2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207af8 <default_pmm_manager+0x190>
ffffffffc02032c6:	00004617          	auipc	a2,0x4
ffffffffc02032ca:	00a60613          	addi	a2,a2,10 # ffffffffc02072d0 <commands+0x450>
ffffffffc02032ce:	18e00593          	li	a1,398
ffffffffc02032d2:	00004517          	auipc	a0,0x4
ffffffffc02032d6:	7e650513          	addi	a0,a0,2022 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02032da:	9a4fd0ef          	jal	ra,ffffffffc020047e <__panic>
            assert(npage != NULL);
ffffffffc02032de:	00005697          	auipc	a3,0x5
ffffffffc02032e2:	d6a68693          	addi	a3,a3,-662 # ffffffffc0208048 <default_pmm_manager+0x6e0>
ffffffffc02032e6:	00004617          	auipc	a2,0x4
ffffffffc02032ea:	fea60613          	addi	a2,a2,-22 # ffffffffc02072d0 <commands+0x450>
ffffffffc02032ee:	1a300593          	li	a1,419
ffffffffc02032f2:	00004517          	auipc	a0,0x4
ffffffffc02032f6:	7c650513          	addi	a0,a0,1990 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02032fa:	984fd0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032fe:	00004697          	auipc	a3,0x4
ffffffffc0203302:	7ca68693          	addi	a3,a3,1994 # ffffffffc0207ac8 <default_pmm_manager+0x160>
ffffffffc0203306:	00004617          	auipc	a2,0x4
ffffffffc020330a:	fca60613          	addi	a2,a2,-54 # ffffffffc02072d0 <commands+0x450>
ffffffffc020330e:	18d00593          	li	a1,397
ffffffffc0203312:	00004517          	auipc	a0,0x4
ffffffffc0203316:	7a650513          	addi	a0,a0,1958 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc020331a:	964fd0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020331e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020331e:	12058073          	sfence.vma	a1
}
ffffffffc0203322:	8082                	ret

ffffffffc0203324 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203324:	7179                	addi	sp,sp,-48
ffffffffc0203326:	e84a                	sd	s2,16(sp)
ffffffffc0203328:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020332a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020332c:	f022                	sd	s0,32(sp)
ffffffffc020332e:	ec26                	sd	s1,24(sp)
ffffffffc0203330:	e44e                	sd	s3,8(sp)
ffffffffc0203332:	f406                	sd	ra,40(sp)
ffffffffc0203334:	84ae                	mv	s1,a1
ffffffffc0203336:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203338:	99dfe0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc020333c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020333e:	cd05                	beqz	a0,ffffffffc0203376 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203340:	85aa                	mv	a1,a0
ffffffffc0203342:	86ce                	mv	a3,s3
ffffffffc0203344:	8626                	mv	a2,s1
ffffffffc0203346:	854a                	mv	a0,s2
ffffffffc0203348:	932ff0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc020334c:	ed0d                	bnez	a0,ffffffffc0203386 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc020334e:	000cc797          	auipc	a5,0xcc
ffffffffc0203352:	c427a783          	lw	a5,-958(a5) # ffffffffc02cef90 <swap_init_ok>
ffffffffc0203356:	c385                	beqz	a5,ffffffffc0203376 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0203358:	000cc517          	auipc	a0,0xcc
ffffffffc020335c:	c4053503          	ld	a0,-960(a0) # ffffffffc02cef98 <check_mm_struct>
ffffffffc0203360:	c919                	beqz	a0,ffffffffc0203376 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203362:	4681                	li	a3,0
ffffffffc0203364:	8622                	mv	a2,s0
ffffffffc0203366:	85a6                	mv	a1,s1
ffffffffc0203368:	7e4000ef          	jal	ra,ffffffffc0203b4c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020336c:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc020336e:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203370:	4785                	li	a5,1
ffffffffc0203372:	04f71663          	bne	a4,a5,ffffffffc02033be <pgdir_alloc_page+0x9a>
}
ffffffffc0203376:	70a2                	ld	ra,40(sp)
ffffffffc0203378:	8522                	mv	a0,s0
ffffffffc020337a:	7402                	ld	s0,32(sp)
ffffffffc020337c:	64e2                	ld	s1,24(sp)
ffffffffc020337e:	6942                	ld	s2,16(sp)
ffffffffc0203380:	69a2                	ld	s3,8(sp)
ffffffffc0203382:	6145                	addi	sp,sp,48
ffffffffc0203384:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203386:	100027f3          	csrr	a5,sstatus
ffffffffc020338a:	8b89                	andi	a5,a5,2
ffffffffc020338c:	eb99                	bnez	a5,ffffffffc02033a2 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc020338e:	000cc797          	auipc	a5,0xcc
ffffffffc0203392:	be27b783          	ld	a5,-1054(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc0203396:	739c                	ld	a5,32(a5)
ffffffffc0203398:	8522                	mv	a0,s0
ffffffffc020339a:	4585                	li	a1,1
ffffffffc020339c:	9782                	jalr	a5
            return NULL;
ffffffffc020339e:	4401                	li	s0,0
ffffffffc02033a0:	bfd9                	j	ffffffffc0203376 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc02033a2:	a9efd0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02033a6:	000cc797          	auipc	a5,0xcc
ffffffffc02033aa:	bca7b783          	ld	a5,-1078(a5) # ffffffffc02cef70 <pmm_manager>
ffffffffc02033ae:	739c                	ld	a5,32(a5)
ffffffffc02033b0:	8522                	mv	a0,s0
ffffffffc02033b2:	4585                	li	a1,1
ffffffffc02033b4:	9782                	jalr	a5
            return NULL;
ffffffffc02033b6:	4401                	li	s0,0
        intr_enable();
ffffffffc02033b8:	a82fd0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc02033bc:	bf6d                	j	ffffffffc0203376 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc02033be:	00005697          	auipc	a3,0x5
ffffffffc02033c2:	c9a68693          	addi	a3,a3,-870 # ffffffffc0208058 <default_pmm_manager+0x6f0>
ffffffffc02033c6:	00004617          	auipc	a2,0x4
ffffffffc02033ca:	f0a60613          	addi	a2,a2,-246 # ffffffffc02072d0 <commands+0x450>
ffffffffc02033ce:	20000593          	li	a1,512
ffffffffc02033d2:	00004517          	auipc	a0,0x4
ffffffffc02033d6:	6e650513          	addi	a0,a0,1766 # ffffffffc0207ab8 <default_pmm_manager+0x150>
ffffffffc02033da:	8a4fd0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02033de <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02033de:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02033e0:	00004617          	auipc	a2,0x4
ffffffffc02033e4:	69060613          	addi	a2,a2,1680 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc02033e8:	06200593          	li	a1,98
ffffffffc02033ec:	00004517          	auipc	a0,0x4
ffffffffc02033f0:	5dc50513          	addi	a0,a0,1500 # ffffffffc02079c8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02033f4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02033f6:	888fd0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02033fa <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02033fa:	7135                	addi	sp,sp,-160
ffffffffc02033fc:	ed06                	sd	ra,152(sp)
ffffffffc02033fe:	e922                	sd	s0,144(sp)
ffffffffc0203400:	e526                	sd	s1,136(sp)
ffffffffc0203402:	e14a                	sd	s2,128(sp)
ffffffffc0203404:	fcce                	sd	s3,120(sp)
ffffffffc0203406:	f8d2                	sd	s4,112(sp)
ffffffffc0203408:	f4d6                	sd	s5,104(sp)
ffffffffc020340a:	f0da                	sd	s6,96(sp)
ffffffffc020340c:	ecde                	sd	s7,88(sp)
ffffffffc020340e:	e8e2                	sd	s8,80(sp)
ffffffffc0203410:	e4e6                	sd	s9,72(sp)
ffffffffc0203412:	e0ea                	sd	s10,64(sp)
ffffffffc0203414:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203416:	75e010ef          	jal	ra,ffffffffc0204b74 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020341a:	000cc697          	auipc	a3,0xcc
ffffffffc020341e:	b666b683          	ld	a3,-1178(a3) # ffffffffc02cef80 <max_swap_offset>
ffffffffc0203422:	010007b7          	lui	a5,0x1000
ffffffffc0203426:	ff968713          	addi	a4,a3,-7
ffffffffc020342a:	17e1                	addi	a5,a5,-8
ffffffffc020342c:	42e7e663          	bltu	a5,a4,ffffffffc0203858 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203430:	000c0797          	auipc	a5,0xc0
ffffffffc0203434:	59078793          	addi	a5,a5,1424 # ffffffffc02c39c0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203438:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020343a:	000ccb97          	auipc	s7,0xcc
ffffffffc020343e:	b4eb8b93          	addi	s7,s7,-1202 # ffffffffc02cef88 <sm>
ffffffffc0203442:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0203446:	9702                	jalr	a4
ffffffffc0203448:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020344a:	c10d                	beqz	a0,ffffffffc020346c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020344c:	60ea                	ld	ra,152(sp)
ffffffffc020344e:	644a                	ld	s0,144(sp)
ffffffffc0203450:	64aa                	ld	s1,136(sp)
ffffffffc0203452:	79e6                	ld	s3,120(sp)
ffffffffc0203454:	7a46                	ld	s4,112(sp)
ffffffffc0203456:	7aa6                	ld	s5,104(sp)
ffffffffc0203458:	7b06                	ld	s6,96(sp)
ffffffffc020345a:	6be6                	ld	s7,88(sp)
ffffffffc020345c:	6c46                	ld	s8,80(sp)
ffffffffc020345e:	6ca6                	ld	s9,72(sp)
ffffffffc0203460:	6d06                	ld	s10,64(sp)
ffffffffc0203462:	7de2                	ld	s11,56(sp)
ffffffffc0203464:	854a                	mv	a0,s2
ffffffffc0203466:	690a                	ld	s2,128(sp)
ffffffffc0203468:	610d                	addi	sp,sp,160
ffffffffc020346a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020346c:	000bb783          	ld	a5,0(s7)
ffffffffc0203470:	00005517          	auipc	a0,0x5
ffffffffc0203474:	c3050513          	addi	a0,a0,-976 # ffffffffc02080a0 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0203478:	000c8417          	auipc	s0,0xc8
ffffffffc020347c:	9c840413          	addi	s0,s0,-1592 # ffffffffc02cae40 <free_area>
ffffffffc0203480:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203482:	4785                	li	a5,1
ffffffffc0203484:	000cc717          	auipc	a4,0xcc
ffffffffc0203488:	b0f72623          	sw	a5,-1268(a4) # ffffffffc02cef90 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020348c:	cf9fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc0203490:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203492:	4d01                	li	s10,0
ffffffffc0203494:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203496:	34878163          	beq	a5,s0,ffffffffc02037d8 <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020349a:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020349e:	8b09                	andi	a4,a4,2
ffffffffc02034a0:	32070e63          	beqz	a4,ffffffffc02037dc <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc02034a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02034a8:	679c                	ld	a5,8(a5)
ffffffffc02034aa:	2d85                	addiw	s11,s11,1
ffffffffc02034ac:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034b0:	fe8795e3          	bne	a5,s0,ffffffffc020349a <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02034b4:	84ea                	mv	s1,s10
ffffffffc02034b6:	8f1fe0ef          	jal	ra,ffffffffc0201da6 <nr_free_pages>
ffffffffc02034ba:	42951763          	bne	a0,s1,ffffffffc02038e8 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02034be:	866a                	mv	a2,s10
ffffffffc02034c0:	85ee                	mv	a1,s11
ffffffffc02034c2:	00005517          	auipc	a0,0x5
ffffffffc02034c6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02080b8 <default_pmm_manager+0x750>
ffffffffc02034ca:	cbbfc0ef          	jal	ra,ffffffffc0200184 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02034ce:	437000ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc02034d2:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02034d4:	46050a63          	beqz	a0,ffffffffc0203948 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02034d8:	000cc797          	auipc	a5,0xcc
ffffffffc02034dc:	ac078793          	addi	a5,a5,-1344 # ffffffffc02cef98 <check_mm_struct>
ffffffffc02034e0:	6398                	ld	a4,0(a5)
ffffffffc02034e2:	3e071363          	bnez	a4,ffffffffc02038c8 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034e6:	000cc717          	auipc	a4,0xcc
ffffffffc02034ea:	a7270713          	addi	a4,a4,-1422 # ffffffffc02cef58 <boot_pgdir>
ffffffffc02034ee:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02034f2:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02034f4:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x738c8>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034f8:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034fc:	42079663          	bnez	a5,ffffffffc0203928 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203500:	6599                	lui	a1,0x6
ffffffffc0203502:	460d                	li	a2,3
ffffffffc0203504:	6505                	lui	a0,0x1
ffffffffc0203506:	447000ef          	jal	ra,ffffffffc020414c <vma_create>
ffffffffc020350a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020350c:	52050a63          	beqz	a0,ffffffffc0203a40 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0203510:	8556                	mv	a0,s5
ffffffffc0203512:	4a9000ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203516:	00005517          	auipc	a0,0x5
ffffffffc020351a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0208128 <default_pmm_manager+0x7c0>
ffffffffc020351e:	c67fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203522:	018ab503          	ld	a0,24(s5)
ffffffffc0203526:	4605                	li	a2,1
ffffffffc0203528:	6585                	lui	a1,0x1
ffffffffc020352a:	8b7fe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020352e:	4c050963          	beqz	a0,ffffffffc0203a00 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203532:	00005517          	auipc	a0,0x5
ffffffffc0203536:	c4650513          	addi	a0,a0,-954 # ffffffffc0208178 <default_pmm_manager+0x810>
ffffffffc020353a:	000c8497          	auipc	s1,0xc8
ffffffffc020353e:	93e48493          	addi	s1,s1,-1730 # ffffffffc02cae78 <check_rp>
ffffffffc0203542:	c43fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203546:	000c8997          	auipc	s3,0xc8
ffffffffc020354a:	95298993          	addi	s3,s3,-1710 # ffffffffc02cae98 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020354e:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203550:	4505                	li	a0,1
ffffffffc0203552:	f82fe0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0203556:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc020355a:	2c050f63          	beqz	a0,ffffffffc0203838 <swap_init+0x43e>
ffffffffc020355e:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203560:	8b89                	andi	a5,a5,2
ffffffffc0203562:	34079363          	bnez	a5,ffffffffc02038a8 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203566:	0a21                	addi	s4,s4,8
ffffffffc0203568:	ff3a14e3          	bne	s4,s3,ffffffffc0203550 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020356c:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020356e:	000c8a17          	auipc	s4,0xc8
ffffffffc0203572:	90aa0a13          	addi	s4,s4,-1782 # ffffffffc02cae78 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0203576:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0203578:	ec3e                	sd	a5,24(sp)
ffffffffc020357a:	641c                	ld	a5,8(s0)
ffffffffc020357c:	e400                	sd	s0,8(s0)
ffffffffc020357e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203580:	481c                	lw	a5,16(s0)
ffffffffc0203582:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203584:	000c8797          	auipc	a5,0xc8
ffffffffc0203588:	8c07a623          	sw	zero,-1844(a5) # ffffffffc02cae50 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020358c:	000a3503          	ld	a0,0(s4)
ffffffffc0203590:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203592:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203594:	fd2fe0ef          	jal	ra,ffffffffc0201d66 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203598:	ff3a1ae3          	bne	s4,s3,ffffffffc020358c <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020359c:	01042a03          	lw	s4,16(s0)
ffffffffc02035a0:	4791                	li	a5,4
ffffffffc02035a2:	42fa1f63          	bne	s4,a5,ffffffffc02039e0 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02035a6:	00005517          	auipc	a0,0x5
ffffffffc02035aa:	c5a50513          	addi	a0,a0,-934 # ffffffffc0208200 <default_pmm_manager+0x898>
ffffffffc02035ae:	bd7fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035b2:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02035b4:	000cc797          	auipc	a5,0xcc
ffffffffc02035b8:	9e07a623          	sw	zero,-1556(a5) # ffffffffc02cefa0 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035bc:	4629                	li	a2,10
ffffffffc02035be:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
     assert(pgfault_num==1);
ffffffffc02035c2:	000cc697          	auipc	a3,0xcc
ffffffffc02035c6:	9de6a683          	lw	a3,-1570(a3) # ffffffffc02cefa0 <pgfault_num>
ffffffffc02035ca:	4585                	li	a1,1
ffffffffc02035cc:	000cc797          	auipc	a5,0xcc
ffffffffc02035d0:	9d478793          	addi	a5,a5,-1580 # ffffffffc02cefa0 <pgfault_num>
ffffffffc02035d4:	54b69663          	bne	a3,a1,ffffffffc0203b20 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02035d8:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02035dc:	4398                	lw	a4,0(a5)
ffffffffc02035de:	2701                	sext.w	a4,a4
ffffffffc02035e0:	3ed71063          	bne	a4,a3,ffffffffc02039c0 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035e4:	6689                	lui	a3,0x2
ffffffffc02035e6:	462d                	li	a2,11
ffffffffc02035e8:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7f68>
     assert(pgfault_num==2);
ffffffffc02035ec:	4398                	lw	a4,0(a5)
ffffffffc02035ee:	4589                	li	a1,2
ffffffffc02035f0:	2701                	sext.w	a4,a4
ffffffffc02035f2:	4ab71763          	bne	a4,a1,ffffffffc0203aa0 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035f6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02035fa:	4394                	lw	a3,0(a5)
ffffffffc02035fc:	2681                	sext.w	a3,a3
ffffffffc02035fe:	4ce69163          	bne	a3,a4,ffffffffc0203ac0 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203602:	668d                	lui	a3,0x3
ffffffffc0203604:	4631                	li	a2,12
ffffffffc0203606:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6f68>
     assert(pgfault_num==3);
ffffffffc020360a:	4398                	lw	a4,0(a5)
ffffffffc020360c:	458d                	li	a1,3
ffffffffc020360e:	2701                	sext.w	a4,a4
ffffffffc0203610:	4cb71863          	bne	a4,a1,ffffffffc0203ae0 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203614:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203618:	4394                	lw	a3,0(a5)
ffffffffc020361a:	2681                	sext.w	a3,a3
ffffffffc020361c:	4ee69263          	bne	a3,a4,ffffffffc0203b00 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203620:	6691                	lui	a3,0x4
ffffffffc0203622:	4635                	li	a2,13
ffffffffc0203624:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5f68>
     assert(pgfault_num==4);
ffffffffc0203628:	4398                	lw	a4,0(a5)
ffffffffc020362a:	2701                	sext.w	a4,a4
ffffffffc020362c:	43471a63          	bne	a4,s4,ffffffffc0203a60 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203630:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203634:	439c                	lw	a5,0(a5)
ffffffffc0203636:	2781                	sext.w	a5,a5
ffffffffc0203638:	44e79463          	bne	a5,a4,ffffffffc0203a80 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020363c:	481c                	lw	a5,16(s0)
ffffffffc020363e:	2c079563          	bnez	a5,ffffffffc0203908 <swap_init+0x50e>
ffffffffc0203642:	000c8797          	auipc	a5,0xc8
ffffffffc0203646:	85678793          	addi	a5,a5,-1962 # ffffffffc02cae98 <swap_in_seq_no>
ffffffffc020364a:	000c8717          	auipc	a4,0xc8
ffffffffc020364e:	87670713          	addi	a4,a4,-1930 # ffffffffc02caec0 <swap_out_seq_no>
ffffffffc0203652:	000c8617          	auipc	a2,0xc8
ffffffffc0203656:	86e60613          	addi	a2,a2,-1938 # ffffffffc02caec0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020365a:	56fd                	li	a3,-1
ffffffffc020365c:	c394                	sw	a3,0(a5)
ffffffffc020365e:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203660:	0791                	addi	a5,a5,4
ffffffffc0203662:	0711                	addi	a4,a4,4
ffffffffc0203664:	fec79ce3          	bne	a5,a2,ffffffffc020365c <swap_init+0x262>
ffffffffc0203668:	000c7717          	auipc	a4,0xc7
ffffffffc020366c:	7f070713          	addi	a4,a4,2032 # ffffffffc02cae58 <check_ptep>
ffffffffc0203670:	000c8697          	auipc	a3,0xc8
ffffffffc0203674:	80868693          	addi	a3,a3,-2040 # ffffffffc02cae78 <check_rp>
ffffffffc0203678:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020367a:	000ccc17          	auipc	s8,0xcc
ffffffffc020367e:	8e6c0c13          	addi	s8,s8,-1818 # ffffffffc02cef60 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203682:	000ccc97          	auipc	s9,0xcc
ffffffffc0203686:	8e6c8c93          	addi	s9,s9,-1818 # ffffffffc02cef68 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020368a:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020368e:	4601                	li	a2,0
ffffffffc0203690:	855a                	mv	a0,s6
ffffffffc0203692:	e836                	sd	a3,16(sp)
ffffffffc0203694:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203696:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203698:	f48fe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc020369c:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020369e:	65a2                	ld	a1,8(sp)
ffffffffc02036a0:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036a2:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc02036a4:	1c050663          	beqz	a0,ffffffffc0203870 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02036a8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036aa:	0017f613          	andi	a2,a5,1
ffffffffc02036ae:	1e060163          	beqz	a2,ffffffffc0203890 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc02036b2:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036b6:	078a                	slli	a5,a5,0x2
ffffffffc02036b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ba:	14c7f363          	bgeu	a5,a2,ffffffffc0203800 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc02036be:	00006617          	auipc	a2,0x6
ffffffffc02036c2:	3b260613          	addi	a2,a2,946 # ffffffffc0209a70 <nbase>
ffffffffc02036c6:	00063a03          	ld	s4,0(a2)
ffffffffc02036ca:	000cb603          	ld	a2,0(s9)
ffffffffc02036ce:	6288                	ld	a0,0(a3)
ffffffffc02036d0:	414787b3          	sub	a5,a5,s4
ffffffffc02036d4:	079a                	slli	a5,a5,0x6
ffffffffc02036d6:	97b2                	add	a5,a5,a2
ffffffffc02036d8:	14f51063          	bne	a0,a5,ffffffffc0203818 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036dc:	6785                	lui	a5,0x1
ffffffffc02036de:	95be                	add	a1,a1,a5
ffffffffc02036e0:	6795                	lui	a5,0x5
ffffffffc02036e2:	0721                	addi	a4,a4,8
ffffffffc02036e4:	06a1                	addi	a3,a3,8
ffffffffc02036e6:	faf592e3          	bne	a1,a5,ffffffffc020368a <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02036ea:	00005517          	auipc	a0,0x5
ffffffffc02036ee:	bbe50513          	addi	a0,a0,-1090 # ffffffffc02082a8 <default_pmm_manager+0x940>
ffffffffc02036f2:	a93fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    int ret = sm->check_swap();
ffffffffc02036f6:	000bb783          	ld	a5,0(s7)
ffffffffc02036fa:	7f9c                	ld	a5,56(a5)
ffffffffc02036fc:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036fe:	32051163          	bnez	a0,ffffffffc0203a20 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203702:	77a2                	ld	a5,40(sp)
ffffffffc0203704:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203706:	67e2                	ld	a5,24(sp)
ffffffffc0203708:	e01c                	sd	a5,0(s0)
ffffffffc020370a:	7782                	ld	a5,32(sp)
ffffffffc020370c:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020370e:	6088                	ld	a0,0(s1)
ffffffffc0203710:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203712:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203714:	e52fe0ef          	jal	ra,ffffffffc0201d66 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203718:	ff349be3          	bne	s1,s3,ffffffffc020370e <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc020371c:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203720:	8556                	mv	a0,s5
ffffffffc0203722:	369000ef          	jal	ra,ffffffffc020428a <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203726:	000cc797          	auipc	a5,0xcc
ffffffffc020372a:	83278793          	addi	a5,a5,-1998 # ffffffffc02cef58 <boot_pgdir>
ffffffffc020372e:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203730:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203734:	000cc697          	auipc	a3,0xcc
ffffffffc0203738:	8606b223          	sd	zero,-1948(a3) # ffffffffc02cef98 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc020373c:	639c                	ld	a5,0(a5)
ffffffffc020373e:	078a                	slli	a5,a5,0x2
ffffffffc0203740:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203742:	0ae7fd63          	bgeu	a5,a4,ffffffffc02037fc <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203746:	414786b3          	sub	a3,a5,s4
ffffffffc020374a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020374c:	8699                	srai	a3,a3,0x6
ffffffffc020374e:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203750:	00c69793          	slli	a5,a3,0xc
ffffffffc0203754:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203756:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc020375a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020375c:	22e7f663          	bgeu	a5,a4,ffffffffc0203988 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203760:	000cc797          	auipc	a5,0xcc
ffffffffc0203764:	8187b783          	ld	a5,-2024(a5) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0203768:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020376a:	629c                	ld	a5,0(a3)
ffffffffc020376c:	078a                	slli	a5,a5,0x2
ffffffffc020376e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203770:	08e7f663          	bgeu	a5,a4,ffffffffc02037fc <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203774:	414787b3          	sub	a5,a5,s4
ffffffffc0203778:	079a                	slli	a5,a5,0x6
ffffffffc020377a:	953e                	add	a0,a0,a5
ffffffffc020377c:	4585                	li	a1,1
ffffffffc020377e:	de8fe0ef          	jal	ra,ffffffffc0201d66 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203782:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203786:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020378a:	078a                	slli	a5,a5,0x2
ffffffffc020378c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020378e:	06e7f763          	bgeu	a5,a4,ffffffffc02037fc <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203792:	000cb503          	ld	a0,0(s9)
ffffffffc0203796:	414787b3          	sub	a5,a5,s4
ffffffffc020379a:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020379c:	4585                	li	a1,1
ffffffffc020379e:	953e                	add	a0,a0,a5
ffffffffc02037a0:	dc6fe0ef          	jal	ra,ffffffffc0201d66 <free_pages>
     pgdir[0] = 0;
ffffffffc02037a4:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02037a8:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02037ac:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037ae:	00878a63          	beq	a5,s0,ffffffffc02037c2 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02037b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02037b6:	679c                	ld	a5,8(a5)
ffffffffc02037b8:	3dfd                	addiw	s11,s11,-1
ffffffffc02037ba:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037be:	fe879ae3          	bne	a5,s0,ffffffffc02037b2 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc02037c2:	1c0d9f63          	bnez	s11,ffffffffc02039a0 <swap_init+0x5a6>
     assert(total==0);
ffffffffc02037c6:	1a0d1163          	bnez	s10,ffffffffc0203968 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc02037ca:	00005517          	auipc	a0,0x5
ffffffffc02037ce:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02082f8 <default_pmm_manager+0x990>
ffffffffc02037d2:	9b3fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
}
ffffffffc02037d6:	b99d                	j	ffffffffc020344c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037d8:	4481                	li	s1,0
ffffffffc02037da:	b9f1                	j	ffffffffc02034b6 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc02037dc:	00004697          	auipc	a3,0x4
ffffffffc02037e0:	de468693          	addi	a3,a3,-540 # ffffffffc02075c0 <commands+0x740>
ffffffffc02037e4:	00004617          	auipc	a2,0x4
ffffffffc02037e8:	aec60613          	addi	a2,a2,-1300 # ffffffffc02072d0 <commands+0x450>
ffffffffc02037ec:	0bc00593          	li	a1,188
ffffffffc02037f0:	00005517          	auipc	a0,0x5
ffffffffc02037f4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02037f8:	c87fc0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc02037fc:	be3ff0ef          	jal	ra,ffffffffc02033de <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203800:	00004617          	auipc	a2,0x4
ffffffffc0203804:	27060613          	addi	a2,a2,624 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0203808:	06200593          	li	a1,98
ffffffffc020380c:	00004517          	auipc	a0,0x4
ffffffffc0203810:	1bc50513          	addi	a0,a0,444 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0203814:	c6bfc0ef          	jal	ra,ffffffffc020047e <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203818:	00005697          	auipc	a3,0x5
ffffffffc020381c:	a6868693          	addi	a3,a3,-1432 # ffffffffc0208280 <default_pmm_manager+0x918>
ffffffffc0203820:	00004617          	auipc	a2,0x4
ffffffffc0203824:	ab060613          	addi	a2,a2,-1360 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203828:	0fc00593          	li	a1,252
ffffffffc020382c:	00005517          	auipc	a0,0x5
ffffffffc0203830:	86450513          	addi	a0,a0,-1948 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203834:	c4bfc0ef          	jal	ra,ffffffffc020047e <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203838:	00005697          	auipc	a3,0x5
ffffffffc020383c:	96868693          	addi	a3,a3,-1688 # ffffffffc02081a0 <default_pmm_manager+0x838>
ffffffffc0203840:	00004617          	auipc	a2,0x4
ffffffffc0203844:	a9060613          	addi	a2,a2,-1392 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203848:	0dc00593          	li	a1,220
ffffffffc020384c:	00005517          	auipc	a0,0x5
ffffffffc0203850:	84450513          	addi	a0,a0,-1980 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203854:	c2bfc0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203858:	00005617          	auipc	a2,0x5
ffffffffc020385c:	81860613          	addi	a2,a2,-2024 # ffffffffc0208070 <default_pmm_manager+0x708>
ffffffffc0203860:	02800593          	li	a1,40
ffffffffc0203864:	00005517          	auipc	a0,0x5
ffffffffc0203868:	82c50513          	addi	a0,a0,-2004 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc020386c:	c13fc0ef          	jal	ra,ffffffffc020047e <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203870:	00005697          	auipc	a3,0x5
ffffffffc0203874:	9f868693          	addi	a3,a3,-1544 # ffffffffc0208268 <default_pmm_manager+0x900>
ffffffffc0203878:	00004617          	auipc	a2,0x4
ffffffffc020387c:	a5860613          	addi	a2,a2,-1448 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203880:	0fb00593          	li	a1,251
ffffffffc0203884:	00005517          	auipc	a0,0x5
ffffffffc0203888:	80c50513          	addi	a0,a0,-2036 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc020388c:	bf3fc0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203890:	00004617          	auipc	a2,0x4
ffffffffc0203894:	20060613          	addi	a2,a2,512 # ffffffffc0207a90 <default_pmm_manager+0x128>
ffffffffc0203898:	07400593          	li	a1,116
ffffffffc020389c:	00004517          	auipc	a0,0x4
ffffffffc02038a0:	12c50513          	addi	a0,a0,300 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02038a4:	bdbfc0ef          	jal	ra,ffffffffc020047e <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02038a8:	00005697          	auipc	a3,0x5
ffffffffc02038ac:	91068693          	addi	a3,a3,-1776 # ffffffffc02081b8 <default_pmm_manager+0x850>
ffffffffc02038b0:	00004617          	auipc	a2,0x4
ffffffffc02038b4:	a2060613          	addi	a2,a2,-1504 # ffffffffc02072d0 <commands+0x450>
ffffffffc02038b8:	0dd00593          	li	a1,221
ffffffffc02038bc:	00004517          	auipc	a0,0x4
ffffffffc02038c0:	7d450513          	addi	a0,a0,2004 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02038c4:	bbbfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02038c8:	00005697          	auipc	a3,0x5
ffffffffc02038cc:	82868693          	addi	a3,a3,-2008 # ffffffffc02080f0 <default_pmm_manager+0x788>
ffffffffc02038d0:	00004617          	auipc	a2,0x4
ffffffffc02038d4:	a0060613          	addi	a2,a2,-1536 # ffffffffc02072d0 <commands+0x450>
ffffffffc02038d8:	0c700593          	li	a1,199
ffffffffc02038dc:	00004517          	auipc	a0,0x4
ffffffffc02038e0:	7b450513          	addi	a0,a0,1972 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02038e4:	b9bfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(total == nr_free_pages());
ffffffffc02038e8:	00004697          	auipc	a3,0x4
ffffffffc02038ec:	d0068693          	addi	a3,a3,-768 # ffffffffc02075e8 <commands+0x768>
ffffffffc02038f0:	00004617          	auipc	a2,0x4
ffffffffc02038f4:	9e060613          	addi	a2,a2,-1568 # ffffffffc02072d0 <commands+0x450>
ffffffffc02038f8:	0bf00593          	li	a1,191
ffffffffc02038fc:	00004517          	auipc	a0,0x4
ffffffffc0203900:	79450513          	addi	a0,a0,1940 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203904:	b7bfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert( nr_free == 0);         
ffffffffc0203908:	00004697          	auipc	a3,0x4
ffffffffc020390c:	e8868693          	addi	a3,a3,-376 # ffffffffc0207790 <commands+0x910>
ffffffffc0203910:	00004617          	auipc	a2,0x4
ffffffffc0203914:	9c060613          	addi	a2,a2,-1600 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203918:	0f300593          	li	a1,243
ffffffffc020391c:	00004517          	auipc	a0,0x4
ffffffffc0203920:	77450513          	addi	a0,a0,1908 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203924:	b5bfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203928:	00004697          	auipc	a3,0x4
ffffffffc020392c:	7e068693          	addi	a3,a3,2016 # ffffffffc0208108 <default_pmm_manager+0x7a0>
ffffffffc0203930:	00004617          	auipc	a2,0x4
ffffffffc0203934:	9a060613          	addi	a2,a2,-1632 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203938:	0cc00593          	li	a1,204
ffffffffc020393c:	00004517          	auipc	a0,0x4
ffffffffc0203940:	75450513          	addi	a0,a0,1876 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203944:	b3bfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(mm != NULL);
ffffffffc0203948:	00004697          	auipc	a3,0x4
ffffffffc020394c:	79868693          	addi	a3,a3,1944 # ffffffffc02080e0 <default_pmm_manager+0x778>
ffffffffc0203950:	00004617          	auipc	a2,0x4
ffffffffc0203954:	98060613          	addi	a2,a2,-1664 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203958:	0c400593          	li	a1,196
ffffffffc020395c:	00004517          	auipc	a0,0x4
ffffffffc0203960:	73450513          	addi	a0,a0,1844 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203964:	b1bfc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(total==0);
ffffffffc0203968:	00005697          	auipc	a3,0x5
ffffffffc020396c:	98068693          	addi	a3,a3,-1664 # ffffffffc02082e8 <default_pmm_manager+0x980>
ffffffffc0203970:	00004617          	auipc	a2,0x4
ffffffffc0203974:	96060613          	addi	a2,a2,-1696 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203978:	11e00593          	li	a1,286
ffffffffc020397c:	00004517          	auipc	a0,0x4
ffffffffc0203980:	71450513          	addi	a0,a0,1812 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203984:	afbfc0ef          	jal	ra,ffffffffc020047e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203988:	00004617          	auipc	a2,0x4
ffffffffc020398c:	01860613          	addi	a2,a2,24 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0203990:	06900593          	li	a1,105
ffffffffc0203994:	00004517          	auipc	a0,0x4
ffffffffc0203998:	03450513          	addi	a0,a0,52 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc020399c:	ae3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(count==0);
ffffffffc02039a0:	00005697          	auipc	a3,0x5
ffffffffc02039a4:	93868693          	addi	a3,a3,-1736 # ffffffffc02082d8 <default_pmm_manager+0x970>
ffffffffc02039a8:	00004617          	auipc	a2,0x4
ffffffffc02039ac:	92860613          	addi	a2,a2,-1752 # ffffffffc02072d0 <commands+0x450>
ffffffffc02039b0:	11d00593          	li	a1,285
ffffffffc02039b4:	00004517          	auipc	a0,0x4
ffffffffc02039b8:	6dc50513          	addi	a0,a0,1756 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02039bc:	ac3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==1);
ffffffffc02039c0:	00005697          	auipc	a3,0x5
ffffffffc02039c4:	86868693          	addi	a3,a3,-1944 # ffffffffc0208228 <default_pmm_manager+0x8c0>
ffffffffc02039c8:	00004617          	auipc	a2,0x4
ffffffffc02039cc:	90860613          	addi	a2,a2,-1784 # ffffffffc02072d0 <commands+0x450>
ffffffffc02039d0:	09500593          	li	a1,149
ffffffffc02039d4:	00004517          	auipc	a0,0x4
ffffffffc02039d8:	6bc50513          	addi	a0,a0,1724 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02039dc:	aa3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02039e0:	00004697          	auipc	a3,0x4
ffffffffc02039e4:	7f868693          	addi	a3,a3,2040 # ffffffffc02081d8 <default_pmm_manager+0x870>
ffffffffc02039e8:	00004617          	auipc	a2,0x4
ffffffffc02039ec:	8e860613          	addi	a2,a2,-1816 # ffffffffc02072d0 <commands+0x450>
ffffffffc02039f0:	0ea00593          	li	a1,234
ffffffffc02039f4:	00004517          	auipc	a0,0x4
ffffffffc02039f8:	69c50513          	addi	a0,a0,1692 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc02039fc:	a83fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a00:	00004697          	auipc	a3,0x4
ffffffffc0203a04:	76068693          	addi	a3,a3,1888 # ffffffffc0208160 <default_pmm_manager+0x7f8>
ffffffffc0203a08:	00004617          	auipc	a2,0x4
ffffffffc0203a0c:	8c860613          	addi	a2,a2,-1848 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203a10:	0d700593          	li	a1,215
ffffffffc0203a14:	00004517          	auipc	a0,0x4
ffffffffc0203a18:	67c50513          	addi	a0,a0,1660 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203a1c:	a63fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(ret==0);
ffffffffc0203a20:	00005697          	auipc	a3,0x5
ffffffffc0203a24:	8b068693          	addi	a3,a3,-1872 # ffffffffc02082d0 <default_pmm_manager+0x968>
ffffffffc0203a28:	00004617          	auipc	a2,0x4
ffffffffc0203a2c:	8a860613          	addi	a2,a2,-1880 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203a30:	10200593          	li	a1,258
ffffffffc0203a34:	00004517          	auipc	a0,0x4
ffffffffc0203a38:	65c50513          	addi	a0,a0,1628 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203a3c:	a43fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(vma != NULL);
ffffffffc0203a40:	00004697          	auipc	a3,0x4
ffffffffc0203a44:	6d868693          	addi	a3,a3,1752 # ffffffffc0208118 <default_pmm_manager+0x7b0>
ffffffffc0203a48:	00004617          	auipc	a2,0x4
ffffffffc0203a4c:	88860613          	addi	a2,a2,-1912 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203a50:	0cf00593          	li	a1,207
ffffffffc0203a54:	00004517          	auipc	a0,0x4
ffffffffc0203a58:	63c50513          	addi	a0,a0,1596 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203a5c:	a23fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==4);
ffffffffc0203a60:	00004697          	auipc	a3,0x4
ffffffffc0203a64:	7f868693          	addi	a3,a3,2040 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0203a68:	00004617          	auipc	a2,0x4
ffffffffc0203a6c:	86860613          	addi	a2,a2,-1944 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203a70:	09f00593          	li	a1,159
ffffffffc0203a74:	00004517          	auipc	a0,0x4
ffffffffc0203a78:	61c50513          	addi	a0,a0,1564 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203a7c:	a03fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==4);
ffffffffc0203a80:	00004697          	auipc	a3,0x4
ffffffffc0203a84:	7d868693          	addi	a3,a3,2008 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0203a88:	00004617          	auipc	a2,0x4
ffffffffc0203a8c:	84860613          	addi	a2,a2,-1976 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203a90:	0a100593          	li	a1,161
ffffffffc0203a94:	00004517          	auipc	a0,0x4
ffffffffc0203a98:	5fc50513          	addi	a0,a0,1532 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203a9c:	9e3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==2);
ffffffffc0203aa0:	00004697          	auipc	a3,0x4
ffffffffc0203aa4:	79868693          	addi	a3,a3,1944 # ffffffffc0208238 <default_pmm_manager+0x8d0>
ffffffffc0203aa8:	00004617          	auipc	a2,0x4
ffffffffc0203aac:	82860613          	addi	a2,a2,-2008 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203ab0:	09700593          	li	a1,151
ffffffffc0203ab4:	00004517          	auipc	a0,0x4
ffffffffc0203ab8:	5dc50513          	addi	a0,a0,1500 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203abc:	9c3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==2);
ffffffffc0203ac0:	00004697          	auipc	a3,0x4
ffffffffc0203ac4:	77868693          	addi	a3,a3,1912 # ffffffffc0208238 <default_pmm_manager+0x8d0>
ffffffffc0203ac8:	00004617          	auipc	a2,0x4
ffffffffc0203acc:	80860613          	addi	a2,a2,-2040 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203ad0:	09900593          	li	a1,153
ffffffffc0203ad4:	00004517          	auipc	a0,0x4
ffffffffc0203ad8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203adc:	9a3fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==3);
ffffffffc0203ae0:	00004697          	auipc	a3,0x4
ffffffffc0203ae4:	76868693          	addi	a3,a3,1896 # ffffffffc0208248 <default_pmm_manager+0x8e0>
ffffffffc0203ae8:	00003617          	auipc	a2,0x3
ffffffffc0203aec:	7e860613          	addi	a2,a2,2024 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203af0:	09b00593          	li	a1,155
ffffffffc0203af4:	00004517          	auipc	a0,0x4
ffffffffc0203af8:	59c50513          	addi	a0,a0,1436 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203afc:	983fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==3);
ffffffffc0203b00:	00004697          	auipc	a3,0x4
ffffffffc0203b04:	74868693          	addi	a3,a3,1864 # ffffffffc0208248 <default_pmm_manager+0x8e0>
ffffffffc0203b08:	00003617          	auipc	a2,0x3
ffffffffc0203b0c:	7c860613          	addi	a2,a2,1992 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203b10:	09d00593          	li	a1,157
ffffffffc0203b14:	00004517          	auipc	a0,0x4
ffffffffc0203b18:	57c50513          	addi	a0,a0,1404 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203b1c:	963fc0ef          	jal	ra,ffffffffc020047e <__panic>
     assert(pgfault_num==1);
ffffffffc0203b20:	00004697          	auipc	a3,0x4
ffffffffc0203b24:	70868693          	addi	a3,a3,1800 # ffffffffc0208228 <default_pmm_manager+0x8c0>
ffffffffc0203b28:	00003617          	auipc	a2,0x3
ffffffffc0203b2c:	7a860613          	addi	a2,a2,1960 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203b30:	09300593          	li	a1,147
ffffffffc0203b34:	00004517          	auipc	a0,0x4
ffffffffc0203b38:	55c50513          	addi	a0,a0,1372 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203b3c:	943fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0203b40 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b40:	000cb797          	auipc	a5,0xcb
ffffffffc0203b44:	4487b783          	ld	a5,1096(a5) # ffffffffc02cef88 <sm>
ffffffffc0203b48:	6b9c                	ld	a5,16(a5)
ffffffffc0203b4a:	8782                	jr	a5

ffffffffc0203b4c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b4c:	000cb797          	auipc	a5,0xcb
ffffffffc0203b50:	43c7b783          	ld	a5,1084(a5) # ffffffffc02cef88 <sm>
ffffffffc0203b54:	739c                	ld	a5,32(a5)
ffffffffc0203b56:	8782                	jr	a5

ffffffffc0203b58 <swap_out>:
{
ffffffffc0203b58:	711d                	addi	sp,sp,-96
ffffffffc0203b5a:	ec86                	sd	ra,88(sp)
ffffffffc0203b5c:	e8a2                	sd	s0,80(sp)
ffffffffc0203b5e:	e4a6                	sd	s1,72(sp)
ffffffffc0203b60:	e0ca                	sd	s2,64(sp)
ffffffffc0203b62:	fc4e                	sd	s3,56(sp)
ffffffffc0203b64:	f852                	sd	s4,48(sp)
ffffffffc0203b66:	f456                	sd	s5,40(sp)
ffffffffc0203b68:	f05a                	sd	s6,32(sp)
ffffffffc0203b6a:	ec5e                	sd	s7,24(sp)
ffffffffc0203b6c:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b6e:	cde9                	beqz	a1,ffffffffc0203c48 <swap_out+0xf0>
ffffffffc0203b70:	8a2e                	mv	s4,a1
ffffffffc0203b72:	892a                	mv	s2,a0
ffffffffc0203b74:	8ab2                	mv	s5,a2
ffffffffc0203b76:	4401                	li	s0,0
ffffffffc0203b78:	000cb997          	auipc	s3,0xcb
ffffffffc0203b7c:	41098993          	addi	s3,s3,1040 # ffffffffc02cef88 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b80:	00004b17          	auipc	s6,0x4
ffffffffc0203b84:	7f8b0b13          	addi	s6,s6,2040 # ffffffffc0208378 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b88:	00004b97          	auipc	s7,0x4
ffffffffc0203b8c:	7d8b8b93          	addi	s7,s7,2008 # ffffffffc0208360 <default_pmm_manager+0x9f8>
ffffffffc0203b90:	a825                	j	ffffffffc0203bc8 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b92:	67a2                	ld	a5,8(sp)
ffffffffc0203b94:	8626                	mv	a2,s1
ffffffffc0203b96:	85a2                	mv	a1,s0
ffffffffc0203b98:	7f94                	ld	a3,56(a5)
ffffffffc0203b9a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b9c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b9e:	82b1                	srli	a3,a3,0xc
ffffffffc0203ba0:	0685                	addi	a3,a3,1
ffffffffc0203ba2:	de2fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203ba6:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203ba8:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203baa:	7d1c                	ld	a5,56(a0)
ffffffffc0203bac:	83b1                	srli	a5,a5,0xc
ffffffffc0203bae:	0785                	addi	a5,a5,1
ffffffffc0203bb0:	07a2                	slli	a5,a5,0x8
ffffffffc0203bb2:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203bb6:	9b0fe0ef          	jal	ra,ffffffffc0201d66 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203bba:	01893503          	ld	a0,24(s2)
ffffffffc0203bbe:	85a6                	mv	a1,s1
ffffffffc0203bc0:	f5eff0ef          	jal	ra,ffffffffc020331e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203bc4:	048a0d63          	beq	s4,s0,ffffffffc0203c1e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203bc8:	0009b783          	ld	a5,0(s3)
ffffffffc0203bcc:	8656                	mv	a2,s5
ffffffffc0203bce:	002c                	addi	a1,sp,8
ffffffffc0203bd0:	7b9c                	ld	a5,48(a5)
ffffffffc0203bd2:	854a                	mv	a0,s2
ffffffffc0203bd4:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203bd6:	e12d                	bnez	a0,ffffffffc0203c38 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203bd8:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bda:	01893503          	ld	a0,24(s2)
ffffffffc0203bde:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203be0:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203be2:	85a6                	mv	a1,s1
ffffffffc0203be4:	9fcfe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203be8:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bea:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bec:	8b85                	andi	a5,a5,1
ffffffffc0203bee:	cfb9                	beqz	a5,ffffffffc0203c4c <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bf0:	65a2                	ld	a1,8(sp)
ffffffffc0203bf2:	7d9c                	ld	a5,56(a1)
ffffffffc0203bf4:	83b1                	srli	a5,a5,0xc
ffffffffc0203bf6:	0785                	addi	a5,a5,1
ffffffffc0203bf8:	00879513          	slli	a0,a5,0x8
ffffffffc0203bfc:	03e010ef          	jal	ra,ffffffffc0204c3a <swapfs_write>
ffffffffc0203c00:	d949                	beqz	a0,ffffffffc0203b92 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c02:	855e                	mv	a0,s7
ffffffffc0203c04:	d80fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c08:	0009b783          	ld	a5,0(s3)
ffffffffc0203c0c:	6622                	ld	a2,8(sp)
ffffffffc0203c0e:	4681                	li	a3,0
ffffffffc0203c10:	739c                	ld	a5,32(a5)
ffffffffc0203c12:	85a6                	mv	a1,s1
ffffffffc0203c14:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203c16:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c18:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203c1a:	fa8a17e3          	bne	s4,s0,ffffffffc0203bc8 <swap_out+0x70>
}
ffffffffc0203c1e:	60e6                	ld	ra,88(sp)
ffffffffc0203c20:	8522                	mv	a0,s0
ffffffffc0203c22:	6446                	ld	s0,80(sp)
ffffffffc0203c24:	64a6                	ld	s1,72(sp)
ffffffffc0203c26:	6906                	ld	s2,64(sp)
ffffffffc0203c28:	79e2                	ld	s3,56(sp)
ffffffffc0203c2a:	7a42                	ld	s4,48(sp)
ffffffffc0203c2c:	7aa2                	ld	s5,40(sp)
ffffffffc0203c2e:	7b02                	ld	s6,32(sp)
ffffffffc0203c30:	6be2                	ld	s7,24(sp)
ffffffffc0203c32:	6c42                	ld	s8,16(sp)
ffffffffc0203c34:	6125                	addi	sp,sp,96
ffffffffc0203c36:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c38:	85a2                	mv	a1,s0
ffffffffc0203c3a:	00004517          	auipc	a0,0x4
ffffffffc0203c3e:	6de50513          	addi	a0,a0,1758 # ffffffffc0208318 <default_pmm_manager+0x9b0>
ffffffffc0203c42:	d42fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
                  break;
ffffffffc0203c46:	bfe1                	j	ffffffffc0203c1e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c48:	4401                	li	s0,0
ffffffffc0203c4a:	bfd1                	j	ffffffffc0203c1e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c4c:	00004697          	auipc	a3,0x4
ffffffffc0203c50:	6fc68693          	addi	a3,a3,1788 # ffffffffc0208348 <default_pmm_manager+0x9e0>
ffffffffc0203c54:	00003617          	auipc	a2,0x3
ffffffffc0203c58:	67c60613          	addi	a2,a2,1660 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203c5c:	06800593          	li	a1,104
ffffffffc0203c60:	00004517          	auipc	a0,0x4
ffffffffc0203c64:	43050513          	addi	a0,a0,1072 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203c68:	817fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0203c6c <swap_in>:
{
ffffffffc0203c6c:	7179                	addi	sp,sp,-48
ffffffffc0203c6e:	e84a                	sd	s2,16(sp)
ffffffffc0203c70:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c72:	4505                	li	a0,1
{
ffffffffc0203c74:	ec26                	sd	s1,24(sp)
ffffffffc0203c76:	e44e                	sd	s3,8(sp)
ffffffffc0203c78:	f406                	sd	ra,40(sp)
ffffffffc0203c7a:	f022                	sd	s0,32(sp)
ffffffffc0203c7c:	84ae                	mv	s1,a1
ffffffffc0203c7e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c80:	854fe0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c84:	c129                	beqz	a0,ffffffffc0203cc6 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c86:	842a                	mv	s0,a0
ffffffffc0203c88:	01893503          	ld	a0,24(s2)
ffffffffc0203c8c:	4601                	li	a2,0
ffffffffc0203c8e:	85a6                	mv	a1,s1
ffffffffc0203c90:	950fe0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0203c94:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c96:	6108                	ld	a0,0(a0)
ffffffffc0203c98:	85a2                	mv	a1,s0
ffffffffc0203c9a:	713000ef          	jal	ra,ffffffffc0204bac <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c9e:	00093583          	ld	a1,0(s2)
ffffffffc0203ca2:	8626                	mv	a2,s1
ffffffffc0203ca4:	00004517          	auipc	a0,0x4
ffffffffc0203ca8:	72450513          	addi	a0,a0,1828 # ffffffffc02083c8 <default_pmm_manager+0xa60>
ffffffffc0203cac:	81a1                	srli	a1,a1,0x8
ffffffffc0203cae:	cd6fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
}
ffffffffc0203cb2:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203cb4:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203cb8:	7402                	ld	s0,32(sp)
ffffffffc0203cba:	64e2                	ld	s1,24(sp)
ffffffffc0203cbc:	6942                	ld	s2,16(sp)
ffffffffc0203cbe:	69a2                	ld	s3,8(sp)
ffffffffc0203cc0:	4501                	li	a0,0
ffffffffc0203cc2:	6145                	addi	sp,sp,48
ffffffffc0203cc4:	8082                	ret
     assert(result!=NULL);
ffffffffc0203cc6:	00004697          	auipc	a3,0x4
ffffffffc0203cca:	6f268693          	addi	a3,a3,1778 # ffffffffc02083b8 <default_pmm_manager+0xa50>
ffffffffc0203cce:	00003617          	auipc	a2,0x3
ffffffffc0203cd2:	60260613          	addi	a2,a2,1538 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203cd6:	07e00593          	li	a1,126
ffffffffc0203cda:	00004517          	auipc	a0,0x4
ffffffffc0203cde:	3b650513          	addi	a0,a0,950 # ffffffffc0208090 <default_pmm_manager+0x728>
ffffffffc0203ce2:	f9cfc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0203ce6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203ce6:	000c7797          	auipc	a5,0xc7
ffffffffc0203cea:	20278793          	addi	a5,a5,514 # ffffffffc02caee8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cee:	f51c                	sd	a5,40(a0)
ffffffffc0203cf0:	e79c                	sd	a5,8(a5)
ffffffffc0203cf2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cf4:	4501                	li	a0,0
ffffffffc0203cf6:	8082                	ret

ffffffffc0203cf8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cf8:	4501                	li	a0,0
ffffffffc0203cfa:	8082                	ret

ffffffffc0203cfc <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cfc:	4501                	li	a0,0
ffffffffc0203cfe:	8082                	ret

ffffffffc0203d00 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d00:	4501                	li	a0,0
ffffffffc0203d02:	8082                	ret

ffffffffc0203d04 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d04:	711d                	addi	sp,sp,-96
ffffffffc0203d06:	fc4e                	sd	s3,56(sp)
ffffffffc0203d08:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d0a:	00004517          	auipc	a0,0x4
ffffffffc0203d0e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0208408 <default_pmm_manager+0xaa0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d12:	698d                	lui	s3,0x3
ffffffffc0203d14:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203d16:	e0ca                	sd	s2,64(sp)
ffffffffc0203d18:	ec86                	sd	ra,88(sp)
ffffffffc0203d1a:	e8a2                	sd	s0,80(sp)
ffffffffc0203d1c:	e4a6                	sd	s1,72(sp)
ffffffffc0203d1e:	f456                	sd	s5,40(sp)
ffffffffc0203d20:	f05a                	sd	s6,32(sp)
ffffffffc0203d22:	ec5e                	sd	s7,24(sp)
ffffffffc0203d24:	e862                	sd	s8,16(sp)
ffffffffc0203d26:	e466                	sd	s9,8(sp)
ffffffffc0203d28:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d2a:	c5afc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d2e:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6f68>
    assert(pgfault_num==4);
ffffffffc0203d32:	000cb917          	auipc	s2,0xcb
ffffffffc0203d36:	26e92903          	lw	s2,622(s2) # ffffffffc02cefa0 <pgfault_num>
ffffffffc0203d3a:	4791                	li	a5,4
ffffffffc0203d3c:	14f91e63          	bne	s2,a5,ffffffffc0203e98 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	70850513          	addi	a0,a0,1800 # ffffffffc0208448 <default_pmm_manager+0xae0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d48:	6a85                	lui	s5,0x1
ffffffffc0203d4a:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d4c:	c38fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc0203d50:	000cb417          	auipc	s0,0xcb
ffffffffc0203d54:	25040413          	addi	s0,s0,592 # ffffffffc02cefa0 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d58:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
    assert(pgfault_num==4);
ffffffffc0203d5c:	4004                	lw	s1,0(s0)
ffffffffc0203d5e:	2481                	sext.w	s1,s1
ffffffffc0203d60:	2b249c63          	bne	s1,s2,ffffffffc0204018 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d64:	00004517          	auipc	a0,0x4
ffffffffc0203d68:	70c50513          	addi	a0,a0,1804 # ffffffffc0208470 <default_pmm_manager+0xb08>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d6c:	6b91                	lui	s7,0x4
ffffffffc0203d6e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d70:	c14fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d74:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5f68>
    assert(pgfault_num==4);
ffffffffc0203d78:	00042903          	lw	s2,0(s0)
ffffffffc0203d7c:	2901                	sext.w	s2,s2
ffffffffc0203d7e:	26991d63          	bne	s2,s1,ffffffffc0203ff8 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d82:	00004517          	auipc	a0,0x4
ffffffffc0203d86:	71650513          	addi	a0,a0,1814 # ffffffffc0208498 <default_pmm_manager+0xb30>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d8a:	6c89                	lui	s9,0x2
ffffffffc0203d8c:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d8e:	bf6fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d92:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7f68>
    assert(pgfault_num==4);
ffffffffc0203d96:	401c                	lw	a5,0(s0)
ffffffffc0203d98:	2781                	sext.w	a5,a5
ffffffffc0203d9a:	23279f63          	bne	a5,s2,ffffffffc0203fd8 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	72250513          	addi	a0,a0,1826 # ffffffffc02084c0 <default_pmm_manager+0xb58>
ffffffffc0203da6:	bdefc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203daa:	6795                	lui	a5,0x5
ffffffffc0203dac:	4739                	li	a4,14
ffffffffc0203dae:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4f68>
    assert(pgfault_num==5);
ffffffffc0203db2:	4004                	lw	s1,0(s0)
ffffffffc0203db4:	4795                	li	a5,5
ffffffffc0203db6:	2481                	sext.w	s1,s1
ffffffffc0203db8:	20f49063          	bne	s1,a5,ffffffffc0203fb8 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dbc:	00004517          	auipc	a0,0x4
ffffffffc0203dc0:	6dc50513          	addi	a0,a0,1756 # ffffffffc0208498 <default_pmm_manager+0xb30>
ffffffffc0203dc4:	bc0fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dc8:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203dcc:	401c                	lw	a5,0(s0)
ffffffffc0203dce:	2781                	sext.w	a5,a5
ffffffffc0203dd0:	1c979463          	bne	a5,s1,ffffffffc0203f98 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dd4:	00004517          	auipc	a0,0x4
ffffffffc0203dd8:	67450513          	addi	a0,a0,1652 # ffffffffc0208448 <default_pmm_manager+0xae0>
ffffffffc0203ddc:	ba8fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203de0:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203de4:	401c                	lw	a5,0(s0)
ffffffffc0203de6:	4719                	li	a4,6
ffffffffc0203de8:	2781                	sext.w	a5,a5
ffffffffc0203dea:	18e79763          	bne	a5,a4,ffffffffc0203f78 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dee:	00004517          	auipc	a0,0x4
ffffffffc0203df2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0208498 <default_pmm_manager+0xb30>
ffffffffc0203df6:	b8efc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dfa:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203dfe:	401c                	lw	a5,0(s0)
ffffffffc0203e00:	471d                	li	a4,7
ffffffffc0203e02:	2781                	sext.w	a5,a5
ffffffffc0203e04:	14e79a63          	bne	a5,a4,ffffffffc0203f58 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e08:	00004517          	auipc	a0,0x4
ffffffffc0203e0c:	60050513          	addi	a0,a0,1536 # ffffffffc0208408 <default_pmm_manager+0xaa0>
ffffffffc0203e10:	b74fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e14:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203e18:	401c                	lw	a5,0(s0)
ffffffffc0203e1a:	4721                	li	a4,8
ffffffffc0203e1c:	2781                	sext.w	a5,a5
ffffffffc0203e1e:	10e79d63          	bne	a5,a4,ffffffffc0203f38 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e22:	00004517          	auipc	a0,0x4
ffffffffc0203e26:	64e50513          	addi	a0,a0,1614 # ffffffffc0208470 <default_pmm_manager+0xb08>
ffffffffc0203e2a:	b5afc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e2e:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e32:	401c                	lw	a5,0(s0)
ffffffffc0203e34:	4725                	li	a4,9
ffffffffc0203e36:	2781                	sext.w	a5,a5
ffffffffc0203e38:	0ee79063          	bne	a5,a4,ffffffffc0203f18 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e3c:	00004517          	auipc	a0,0x4
ffffffffc0203e40:	68450513          	addi	a0,a0,1668 # ffffffffc02084c0 <default_pmm_manager+0xb58>
ffffffffc0203e44:	b40fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e48:	6795                	lui	a5,0x5
ffffffffc0203e4a:	4739                	li	a4,14
ffffffffc0203e4c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4f68>
    assert(pgfault_num==10);
ffffffffc0203e50:	4004                	lw	s1,0(s0)
ffffffffc0203e52:	47a9                	li	a5,10
ffffffffc0203e54:	2481                	sext.w	s1,s1
ffffffffc0203e56:	0af49163          	bne	s1,a5,ffffffffc0203ef8 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e5a:	00004517          	auipc	a0,0x4
ffffffffc0203e5e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0208448 <default_pmm_manager+0xae0>
ffffffffc0203e62:	b22fc0ef          	jal	ra,ffffffffc0200184 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e66:	6785                	lui	a5,0x1
ffffffffc0203e68:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
ffffffffc0203e6c:	06979663          	bne	a5,s1,ffffffffc0203ed8 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203e70:	401c                	lw	a5,0(s0)
ffffffffc0203e72:	472d                	li	a4,11
ffffffffc0203e74:	2781                	sext.w	a5,a5
ffffffffc0203e76:	04e79163          	bne	a5,a4,ffffffffc0203eb8 <_fifo_check_swap+0x1b4>
}
ffffffffc0203e7a:	60e6                	ld	ra,88(sp)
ffffffffc0203e7c:	6446                	ld	s0,80(sp)
ffffffffc0203e7e:	64a6                	ld	s1,72(sp)
ffffffffc0203e80:	6906                	ld	s2,64(sp)
ffffffffc0203e82:	79e2                	ld	s3,56(sp)
ffffffffc0203e84:	7a42                	ld	s4,48(sp)
ffffffffc0203e86:	7aa2                	ld	s5,40(sp)
ffffffffc0203e88:	7b02                	ld	s6,32(sp)
ffffffffc0203e8a:	6be2                	ld	s7,24(sp)
ffffffffc0203e8c:	6c42                	ld	s8,16(sp)
ffffffffc0203e8e:	6ca2                	ld	s9,8(sp)
ffffffffc0203e90:	6d02                	ld	s10,0(sp)
ffffffffc0203e92:	4501                	li	a0,0
ffffffffc0203e94:	6125                	addi	sp,sp,96
ffffffffc0203e96:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e98:	00004697          	auipc	a3,0x4
ffffffffc0203e9c:	3c068693          	addi	a3,a3,960 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0203ea0:	00003617          	auipc	a2,0x3
ffffffffc0203ea4:	43060613          	addi	a2,a2,1072 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203ea8:	05400593          	li	a1,84
ffffffffc0203eac:	00004517          	auipc	a0,0x4
ffffffffc0203eb0:	58450513          	addi	a0,a0,1412 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203eb4:	dcafc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==11);
ffffffffc0203eb8:	00004697          	auipc	a3,0x4
ffffffffc0203ebc:	6b868693          	addi	a3,a3,1720 # ffffffffc0208570 <default_pmm_manager+0xc08>
ffffffffc0203ec0:	00003617          	auipc	a2,0x3
ffffffffc0203ec4:	41060613          	addi	a2,a2,1040 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203ec8:	07600593          	li	a1,118
ffffffffc0203ecc:	00004517          	auipc	a0,0x4
ffffffffc0203ed0:	56450513          	addi	a0,a0,1380 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203ed4:	daafc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ed8:	00004697          	auipc	a3,0x4
ffffffffc0203edc:	67068693          	addi	a3,a3,1648 # ffffffffc0208548 <default_pmm_manager+0xbe0>
ffffffffc0203ee0:	00003617          	auipc	a2,0x3
ffffffffc0203ee4:	3f060613          	addi	a2,a2,1008 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203ee8:	07400593          	li	a1,116
ffffffffc0203eec:	00004517          	auipc	a0,0x4
ffffffffc0203ef0:	54450513          	addi	a0,a0,1348 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203ef4:	d8afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==10);
ffffffffc0203ef8:	00004697          	auipc	a3,0x4
ffffffffc0203efc:	64068693          	addi	a3,a3,1600 # ffffffffc0208538 <default_pmm_manager+0xbd0>
ffffffffc0203f00:	00003617          	auipc	a2,0x3
ffffffffc0203f04:	3d060613          	addi	a2,a2,976 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203f08:	07200593          	li	a1,114
ffffffffc0203f0c:	00004517          	auipc	a0,0x4
ffffffffc0203f10:	52450513          	addi	a0,a0,1316 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203f14:	d6afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==9);
ffffffffc0203f18:	00004697          	auipc	a3,0x4
ffffffffc0203f1c:	61068693          	addi	a3,a3,1552 # ffffffffc0208528 <default_pmm_manager+0xbc0>
ffffffffc0203f20:	00003617          	auipc	a2,0x3
ffffffffc0203f24:	3b060613          	addi	a2,a2,944 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203f28:	06f00593          	li	a1,111
ffffffffc0203f2c:	00004517          	auipc	a0,0x4
ffffffffc0203f30:	50450513          	addi	a0,a0,1284 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203f34:	d4afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==8);
ffffffffc0203f38:	00004697          	auipc	a3,0x4
ffffffffc0203f3c:	5e068693          	addi	a3,a3,1504 # ffffffffc0208518 <default_pmm_manager+0xbb0>
ffffffffc0203f40:	00003617          	auipc	a2,0x3
ffffffffc0203f44:	39060613          	addi	a2,a2,912 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203f48:	06c00593          	li	a1,108
ffffffffc0203f4c:	00004517          	auipc	a0,0x4
ffffffffc0203f50:	4e450513          	addi	a0,a0,1252 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203f54:	d2afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==7);
ffffffffc0203f58:	00004697          	auipc	a3,0x4
ffffffffc0203f5c:	5b068693          	addi	a3,a3,1456 # ffffffffc0208508 <default_pmm_manager+0xba0>
ffffffffc0203f60:	00003617          	auipc	a2,0x3
ffffffffc0203f64:	37060613          	addi	a2,a2,880 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203f68:	06900593          	li	a1,105
ffffffffc0203f6c:	00004517          	auipc	a0,0x4
ffffffffc0203f70:	4c450513          	addi	a0,a0,1220 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203f74:	d0afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==6);
ffffffffc0203f78:	00004697          	auipc	a3,0x4
ffffffffc0203f7c:	58068693          	addi	a3,a3,1408 # ffffffffc02084f8 <default_pmm_manager+0xb90>
ffffffffc0203f80:	00003617          	auipc	a2,0x3
ffffffffc0203f84:	35060613          	addi	a2,a2,848 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203f88:	06600593          	li	a1,102
ffffffffc0203f8c:	00004517          	auipc	a0,0x4
ffffffffc0203f90:	4a450513          	addi	a0,a0,1188 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203f94:	ceafc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==5);
ffffffffc0203f98:	00004697          	auipc	a3,0x4
ffffffffc0203f9c:	55068693          	addi	a3,a3,1360 # ffffffffc02084e8 <default_pmm_manager+0xb80>
ffffffffc0203fa0:	00003617          	auipc	a2,0x3
ffffffffc0203fa4:	33060613          	addi	a2,a2,816 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203fa8:	06300593          	li	a1,99
ffffffffc0203fac:	00004517          	auipc	a0,0x4
ffffffffc0203fb0:	48450513          	addi	a0,a0,1156 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203fb4:	ccafc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==5);
ffffffffc0203fb8:	00004697          	auipc	a3,0x4
ffffffffc0203fbc:	53068693          	addi	a3,a3,1328 # ffffffffc02084e8 <default_pmm_manager+0xb80>
ffffffffc0203fc0:	00003617          	auipc	a2,0x3
ffffffffc0203fc4:	31060613          	addi	a2,a2,784 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203fc8:	06000593          	li	a1,96
ffffffffc0203fcc:	00004517          	auipc	a0,0x4
ffffffffc0203fd0:	46450513          	addi	a0,a0,1124 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203fd4:	caafc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd8:	00004697          	auipc	a3,0x4
ffffffffc0203fdc:	28068693          	addi	a3,a3,640 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0203fe0:	00003617          	auipc	a2,0x3
ffffffffc0203fe4:	2f060613          	addi	a2,a2,752 # ffffffffc02072d0 <commands+0x450>
ffffffffc0203fe8:	05d00593          	li	a1,93
ffffffffc0203fec:	00004517          	auipc	a0,0x4
ffffffffc0203ff0:	44450513          	addi	a0,a0,1092 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0203ff4:	c8afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==4);
ffffffffc0203ff8:	00004697          	auipc	a3,0x4
ffffffffc0203ffc:	26068693          	addi	a3,a3,608 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0204000:	00003617          	auipc	a2,0x3
ffffffffc0204004:	2d060613          	addi	a2,a2,720 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204008:	05a00593          	li	a1,90
ffffffffc020400c:	00004517          	auipc	a0,0x4
ffffffffc0204010:	42450513          	addi	a0,a0,1060 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0204014:	c6afc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgfault_num==4);
ffffffffc0204018:	00004697          	auipc	a3,0x4
ffffffffc020401c:	24068693          	addi	a3,a3,576 # ffffffffc0208258 <default_pmm_manager+0x8f0>
ffffffffc0204020:	00003617          	auipc	a2,0x3
ffffffffc0204024:	2b060613          	addi	a2,a2,688 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204028:	05700593          	li	a1,87
ffffffffc020402c:	00004517          	auipc	a0,0x4
ffffffffc0204030:	40450513          	addi	a0,a0,1028 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0204034:	c4afc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204038 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204038:	7518                	ld	a4,40(a0)
{
ffffffffc020403a:	1141                	addi	sp,sp,-16
ffffffffc020403c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020403e:	c721                	beqz	a4,ffffffffc0204086 <_fifo_swap_out_victim+0x4e>
     assert(in_tick==0);
ffffffffc0204040:	e21d                	bnez	a2,ffffffffc0204066 <_fifo_swap_out_victim+0x2e>
    return listelm->next;
ffffffffc0204042:	671c                	ld	a5,8(a4)
	if (entry != head) {
ffffffffc0204044:	00f70c63          	beq	a4,a5,ffffffffc020405c <_fifo_swap_out_victim+0x24>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204048:	6394                	ld	a3,0(a5)
ffffffffc020404a:	6798                	ld	a4,8(a5)
}
ffffffffc020404c:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc020404e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204052:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204054:	e314                	sd	a3,0(a4)
ffffffffc0204056:	e19c                	sd	a5,0(a1)
}
ffffffffc0204058:	0141                	addi	sp,sp,16
ffffffffc020405a:	8082                	ret
ffffffffc020405c:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc020405e:	0005b023          	sd	zero,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8f68>
}
ffffffffc0204062:	0141                	addi	sp,sp,16
ffffffffc0204064:	8082                	ret
     assert(in_tick==0);
ffffffffc0204066:	00004697          	auipc	a3,0x4
ffffffffc020406a:	52a68693          	addi	a3,a3,1322 # ffffffffc0208590 <default_pmm_manager+0xc28>
ffffffffc020406e:	00003617          	auipc	a2,0x3
ffffffffc0204072:	26260613          	addi	a2,a2,610 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204076:	04200593          	li	a1,66
ffffffffc020407a:	00004517          	auipc	a0,0x4
ffffffffc020407e:	3b650513          	addi	a0,a0,950 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc0204082:	bfcfc0ef          	jal	ra,ffffffffc020047e <__panic>
         assert(head != NULL);
ffffffffc0204086:	00004697          	auipc	a3,0x4
ffffffffc020408a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0208580 <default_pmm_manager+0xc18>
ffffffffc020408e:	00003617          	auipc	a2,0x3
ffffffffc0204092:	24260613          	addi	a2,a2,578 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204096:	04100593          	li	a1,65
ffffffffc020409a:	00004517          	auipc	a0,0x4
ffffffffc020409e:	39650513          	addi	a0,a0,918 # ffffffffc0208430 <default_pmm_manager+0xac8>
ffffffffc02040a2:	bdcfc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02040a6 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040a6:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02040a8:	cb91                	beqz	a5,ffffffffc02040bc <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02040aa:	6394                	ld	a3,0(a5)
ffffffffc02040ac:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02040b0:	e398                	sd	a4,0(a5)
ffffffffc02040b2:	e698                	sd	a4,8(a3)
}
ffffffffc02040b4:	4501                	li	a0,0
    elm->next = next;
ffffffffc02040b6:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02040b8:	f614                	sd	a3,40(a2)
ffffffffc02040ba:	8082                	ret
{
ffffffffc02040bc:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02040be:	00004697          	auipc	a3,0x4
ffffffffc02040c2:	4e268693          	addi	a3,a3,1250 # ffffffffc02085a0 <default_pmm_manager+0xc38>
ffffffffc02040c6:	00003617          	auipc	a2,0x3
ffffffffc02040ca:	20a60613          	addi	a2,a2,522 # ffffffffc02072d0 <commands+0x450>
ffffffffc02040ce:	03200593          	li	a1,50
ffffffffc02040d2:	00004517          	auipc	a0,0x4
ffffffffc02040d6:	35e50513          	addi	a0,a0,862 # ffffffffc0208430 <default_pmm_manager+0xac8>
{
ffffffffc02040da:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02040dc:	ba2fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02040e0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040e0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040e2:	00004697          	auipc	a3,0x4
ffffffffc02040e6:	4f668693          	addi	a3,a3,1270 # ffffffffc02085d8 <default_pmm_manager+0xc70>
ffffffffc02040ea:	00003617          	auipc	a2,0x3
ffffffffc02040ee:	1e660613          	addi	a2,a2,486 # ffffffffc02072d0 <commands+0x450>
ffffffffc02040f2:	06d00593          	li	a1,109
ffffffffc02040f6:	00004517          	auipc	a0,0x4
ffffffffc02040fa:	50250513          	addi	a0,a0,1282 # ffffffffc02085f8 <default_pmm_manager+0xc90>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040fe:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204100:	b7efc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204104 <mm_create>:
mm_create(void) {
ffffffffc0204104:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204106:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020410a:	e022                	sd	s0,0(sp)
ffffffffc020410c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020410e:	9e9fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc0204112:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204114:	c505                	beqz	a0,ffffffffc020413c <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0204116:	e408                	sd	a0,8(s0)
ffffffffc0204118:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020411a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020411e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204122:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204126:	000cb797          	auipc	a5,0xcb
ffffffffc020412a:	e6a7a783          	lw	a5,-406(a5) # ffffffffc02cef90 <swap_init_ok>
ffffffffc020412e:	ef81                	bnez	a5,ffffffffc0204146 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204130:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204134:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204138:	02043c23          	sd	zero,56(s0)
}
ffffffffc020413c:	60a2                	ld	ra,8(sp)
ffffffffc020413e:	8522                	mv	a0,s0
ffffffffc0204140:	6402                	ld	s0,0(sp)
ffffffffc0204142:	0141                	addi	sp,sp,16
ffffffffc0204144:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204146:	9fbff0ef          	jal	ra,ffffffffc0203b40 <swap_init_mm>
ffffffffc020414a:	b7ed                	j	ffffffffc0204134 <mm_create+0x30>

ffffffffc020414c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020414c:	1101                	addi	sp,sp,-32
ffffffffc020414e:	e04a                	sd	s2,0(sp)
ffffffffc0204150:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204152:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204156:	e822                	sd	s0,16(sp)
ffffffffc0204158:	e426                	sd	s1,8(sp)
ffffffffc020415a:	ec06                	sd	ra,24(sp)
ffffffffc020415c:	84ae                	mv	s1,a1
ffffffffc020415e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204160:	997fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
    if (vma != NULL) {
ffffffffc0204164:	c509                	beqz	a0,ffffffffc020416e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204166:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020416a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020416c:	cd00                	sw	s0,24(a0)
}
ffffffffc020416e:	60e2                	ld	ra,24(sp)
ffffffffc0204170:	6442                	ld	s0,16(sp)
ffffffffc0204172:	64a2                	ld	s1,8(sp)
ffffffffc0204174:	6902                	ld	s2,0(sp)
ffffffffc0204176:	6105                	addi	sp,sp,32
ffffffffc0204178:	8082                	ret

ffffffffc020417a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020417a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020417c:	c505                	beqz	a0,ffffffffc02041a4 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020417e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204180:	c501                	beqz	a0,ffffffffc0204188 <find_vma+0xe>
ffffffffc0204182:	651c                	ld	a5,8(a0)
ffffffffc0204184:	02f5f263          	bgeu	a1,a5,ffffffffc02041a8 <find_vma+0x2e>
    return listelm->next;
ffffffffc0204188:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020418a:	00f68d63          	beq	a3,a5,ffffffffc02041a4 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020418e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204192:	00e5e663          	bltu	a1,a4,ffffffffc020419e <find_vma+0x24>
ffffffffc0204196:	ff07b703          	ld	a4,-16(a5)
ffffffffc020419a:	00e5ec63          	bltu	a1,a4,ffffffffc02041b2 <find_vma+0x38>
ffffffffc020419e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02041a0:	fef697e3          	bne	a3,a5,ffffffffc020418e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02041a4:	4501                	li	a0,0
}
ffffffffc02041a6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041a8:	691c                	ld	a5,16(a0)
ffffffffc02041aa:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0204188 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02041ae:	ea88                	sd	a0,16(a3)
ffffffffc02041b0:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02041b2:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02041b6:	ea88                	sd	a0,16(a3)
ffffffffc02041b8:	8082                	ret

ffffffffc02041ba <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041ba:	6590                	ld	a2,8(a1)
ffffffffc02041bc:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02041c0:	1141                	addi	sp,sp,-16
ffffffffc02041c2:	e406                	sd	ra,8(sp)
ffffffffc02041c4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041c6:	01066763          	bltu	a2,a6,ffffffffc02041d4 <insert_vma_struct+0x1a>
ffffffffc02041ca:	a085                	j	ffffffffc020422a <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041cc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02041d0:	04e66863          	bltu	a2,a4,ffffffffc0204220 <insert_vma_struct+0x66>
ffffffffc02041d4:	86be                	mv	a3,a5
ffffffffc02041d6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02041d8:	fef51ae3          	bne	a0,a5,ffffffffc02041cc <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041dc:	02a68463          	beq	a3,a0,ffffffffc0204204 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041e0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041e4:	fe86b883          	ld	a7,-24(a3)
ffffffffc02041e8:	08e8f163          	bgeu	a7,a4,ffffffffc020426a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ec:	04e66f63          	bltu	a2,a4,ffffffffc020424a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02041f0:	00f50a63          	beq	a0,a5,ffffffffc0204204 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041f4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041f8:	05076963          	bltu	a4,a6,ffffffffc020424a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02041fc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204200:	02c77363          	bgeu	a4,a2,ffffffffc0204226 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204204:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0204206:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0204208:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020420c:	e390                	sd	a2,0(a5)
ffffffffc020420e:	e690                	sd	a2,8(a3)
}
ffffffffc0204210:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204212:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204214:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0204216:	0017079b          	addiw	a5,a4,1
ffffffffc020421a:	d11c                	sw	a5,32(a0)
}
ffffffffc020421c:	0141                	addi	sp,sp,16
ffffffffc020421e:	8082                	ret
    if (le_prev != list) {
ffffffffc0204220:	fca690e3          	bne	a3,a0,ffffffffc02041e0 <insert_vma_struct+0x26>
ffffffffc0204224:	bfd1                	j	ffffffffc02041f8 <insert_vma_struct+0x3e>
ffffffffc0204226:	ebbff0ef          	jal	ra,ffffffffc02040e0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020422a:	00004697          	auipc	a3,0x4
ffffffffc020422e:	3de68693          	addi	a3,a3,990 # ffffffffc0208608 <default_pmm_manager+0xca0>
ffffffffc0204232:	00003617          	auipc	a2,0x3
ffffffffc0204236:	09e60613          	addi	a2,a2,158 # ffffffffc02072d0 <commands+0x450>
ffffffffc020423a:	07400593          	li	a1,116
ffffffffc020423e:	00004517          	auipc	a0,0x4
ffffffffc0204242:	3ba50513          	addi	a0,a0,954 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204246:	a38fc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020424a:	00004697          	auipc	a3,0x4
ffffffffc020424e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0208648 <default_pmm_manager+0xce0>
ffffffffc0204252:	00003617          	auipc	a2,0x3
ffffffffc0204256:	07e60613          	addi	a2,a2,126 # ffffffffc02072d0 <commands+0x450>
ffffffffc020425a:	06c00593          	li	a1,108
ffffffffc020425e:	00004517          	auipc	a0,0x4
ffffffffc0204262:	39a50513          	addi	a0,a0,922 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204266:	a18fc0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020426a:	00004697          	auipc	a3,0x4
ffffffffc020426e:	3be68693          	addi	a3,a3,958 # ffffffffc0208628 <default_pmm_manager+0xcc0>
ffffffffc0204272:	00003617          	auipc	a2,0x3
ffffffffc0204276:	05e60613          	addi	a2,a2,94 # ffffffffc02072d0 <commands+0x450>
ffffffffc020427a:	06b00593          	li	a1,107
ffffffffc020427e:	00004517          	auipc	a0,0x4
ffffffffc0204282:	37a50513          	addi	a0,a0,890 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204286:	9f8fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020428a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020428a:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020428c:	1141                	addi	sp,sp,-16
ffffffffc020428e:	e406                	sd	ra,8(sp)
ffffffffc0204290:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204292:	e78d                	bnez	a5,ffffffffc02042bc <mm_destroy+0x32>
ffffffffc0204294:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204296:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204298:	00a40c63          	beq	s0,a0,ffffffffc02042b0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020429c:	6118                	ld	a4,0(a0)
ffffffffc020429e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02042a0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02042a2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02042a4:	e398                	sd	a4,0(a5)
ffffffffc02042a6:	901fd0ef          	jal	ra,ffffffffc0201ba6 <kfree>
    return listelm->next;
ffffffffc02042aa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02042ac:	fea418e3          	bne	s0,a0,ffffffffc020429c <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02042b0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02042b2:	6402                	ld	s0,0(sp)
ffffffffc02042b4:	60a2                	ld	ra,8(sp)
ffffffffc02042b6:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02042b8:	8effd06f          	j	ffffffffc0201ba6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02042bc:	00004697          	auipc	a3,0x4
ffffffffc02042c0:	3ac68693          	addi	a3,a3,940 # ffffffffc0208668 <default_pmm_manager+0xd00>
ffffffffc02042c4:	00003617          	auipc	a2,0x3
ffffffffc02042c8:	00c60613          	addi	a2,a2,12 # ffffffffc02072d0 <commands+0x450>
ffffffffc02042cc:	09400593          	li	a1,148
ffffffffc02042d0:	00004517          	auipc	a0,0x4
ffffffffc02042d4:	32850513          	addi	a0,a0,808 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02042d8:	9a6fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02042dc <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc02042dc:	7139                	addi	sp,sp,-64
ffffffffc02042de:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042e0:	6405                	lui	s0,0x1
ffffffffc02042e2:	147d                	addi	s0,s0,-1
ffffffffc02042e4:	77fd                	lui	a5,0xfffff
ffffffffc02042e6:	9622                	add	a2,a2,s0
ffffffffc02042e8:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc02042ea:	f426                	sd	s1,40(sp)
ffffffffc02042ec:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ee:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc02042f2:	f04a                	sd	s2,32(sp)
ffffffffc02042f4:	ec4e                	sd	s3,24(sp)
ffffffffc02042f6:	e852                	sd	s4,16(sp)
ffffffffc02042f8:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc02042fa:	002005b7          	lui	a1,0x200
ffffffffc02042fe:	00f67433          	and	s0,a2,a5
ffffffffc0204302:	06b4e363          	bltu	s1,a1,ffffffffc0204368 <mm_map+0x8c>
ffffffffc0204306:	0684f163          	bgeu	s1,s0,ffffffffc0204368 <mm_map+0x8c>
ffffffffc020430a:	4785                	li	a5,1
ffffffffc020430c:	07fe                	slli	a5,a5,0x1f
ffffffffc020430e:	0487ed63          	bltu	a5,s0,ffffffffc0204368 <mm_map+0x8c>
ffffffffc0204312:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204314:	cd21                	beqz	a0,ffffffffc020436c <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204316:	85a6                	mv	a1,s1
ffffffffc0204318:	8ab6                	mv	s5,a3
ffffffffc020431a:	8a3a                	mv	s4,a4
ffffffffc020431c:	e5fff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc0204320:	c501                	beqz	a0,ffffffffc0204328 <mm_map+0x4c>
ffffffffc0204322:	651c                	ld	a5,8(a0)
ffffffffc0204324:	0487e263          	bltu	a5,s0,ffffffffc0204368 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204328:	03000513          	li	a0,48
ffffffffc020432c:	fcafd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc0204330:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204332:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204334:	02090163          	beqz	s2,ffffffffc0204356 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204338:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020433a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020433e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204342:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204346:	85ca                	mv	a1,s2
ffffffffc0204348:	e73ff0ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020434c:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020434e:	000a0463          	beqz	s4,ffffffffc0204356 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0204352:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204356:	70e2                	ld	ra,56(sp)
ffffffffc0204358:	7442                	ld	s0,48(sp)
ffffffffc020435a:	74a2                	ld	s1,40(sp)
ffffffffc020435c:	7902                	ld	s2,32(sp)
ffffffffc020435e:	69e2                	ld	s3,24(sp)
ffffffffc0204360:	6a42                	ld	s4,16(sp)
ffffffffc0204362:	6aa2                	ld	s5,8(sp)
ffffffffc0204364:	6121                	addi	sp,sp,64
ffffffffc0204366:	8082                	ret
        return -E_INVAL;
ffffffffc0204368:	5575                	li	a0,-3
ffffffffc020436a:	b7f5                	j	ffffffffc0204356 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020436c:	00004697          	auipc	a3,0x4
ffffffffc0204370:	d7468693          	addi	a3,a3,-652 # ffffffffc02080e0 <default_pmm_manager+0x778>
ffffffffc0204374:	00003617          	auipc	a2,0x3
ffffffffc0204378:	f5c60613          	addi	a2,a2,-164 # ffffffffc02072d0 <commands+0x450>
ffffffffc020437c:	0a700593          	li	a1,167
ffffffffc0204380:	00004517          	auipc	a0,0x4
ffffffffc0204384:	27850513          	addi	a0,a0,632 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204388:	8f6fc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020438c <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020438c:	7139                	addi	sp,sp,-64
ffffffffc020438e:	fc06                	sd	ra,56(sp)
ffffffffc0204390:	f822                	sd	s0,48(sp)
ffffffffc0204392:	f426                	sd	s1,40(sp)
ffffffffc0204394:	f04a                	sd	s2,32(sp)
ffffffffc0204396:	ec4e                	sd	s3,24(sp)
ffffffffc0204398:	e852                	sd	s4,16(sp)
ffffffffc020439a:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020439c:	c52d                	beqz	a0,ffffffffc0204406 <dup_mmap+0x7a>
ffffffffc020439e:	892a                	mv	s2,a0
ffffffffc02043a0:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02043a2:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02043a4:	e595                	bnez	a1,ffffffffc02043d0 <dup_mmap+0x44>
ffffffffc02043a6:	a085                	j	ffffffffc0204406 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02043a8:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02043aa:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_matrix_out_size+0x1f38d0>
        vma->vm_end = vm_end;
ffffffffc02043ae:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02043b2:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02043b6:	e05ff0ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02043ba:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8f78>
ffffffffc02043be:	fe843603          	ld	a2,-24(s0)
ffffffffc02043c2:	6c8c                	ld	a1,24(s1)
ffffffffc02043c4:	01893503          	ld	a0,24(s2)
ffffffffc02043c8:	4701                	li	a4,0
ffffffffc02043ca:	d41fe0ef          	jal	ra,ffffffffc020310a <copy_range>
ffffffffc02043ce:	e105                	bnez	a0,ffffffffc02043ee <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02043d0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043d2:	02848863          	beq	s1,s0,ffffffffc0204402 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043d6:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043da:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043de:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043e2:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043e6:	f10fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc02043ea:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02043ec:	fd55                	bnez	a0,ffffffffc02043a8 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043ee:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043f0:	70e2                	ld	ra,56(sp)
ffffffffc02043f2:	7442                	ld	s0,48(sp)
ffffffffc02043f4:	74a2                	ld	s1,40(sp)
ffffffffc02043f6:	7902                	ld	s2,32(sp)
ffffffffc02043f8:	69e2                	ld	s3,24(sp)
ffffffffc02043fa:	6a42                	ld	s4,16(sp)
ffffffffc02043fc:	6aa2                	ld	s5,8(sp)
ffffffffc02043fe:	6121                	addi	sp,sp,64
ffffffffc0204400:	8082                	ret
    return 0;
ffffffffc0204402:	4501                	li	a0,0
ffffffffc0204404:	b7f5                	j	ffffffffc02043f0 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0204406:	00004697          	auipc	a3,0x4
ffffffffc020440a:	27a68693          	addi	a3,a3,634 # ffffffffc0208680 <default_pmm_manager+0xd18>
ffffffffc020440e:	00003617          	auipc	a2,0x3
ffffffffc0204412:	ec260613          	addi	a2,a2,-318 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204416:	0c000593          	li	a1,192
ffffffffc020441a:	00004517          	auipc	a0,0x4
ffffffffc020441e:	1de50513          	addi	a0,a0,478 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204422:	85cfc0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204426 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204426:	1101                	addi	sp,sp,-32
ffffffffc0204428:	ec06                	sd	ra,24(sp)
ffffffffc020442a:	e822                	sd	s0,16(sp)
ffffffffc020442c:	e426                	sd	s1,8(sp)
ffffffffc020442e:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204430:	c531                	beqz	a0,ffffffffc020447c <exit_mmap+0x56>
ffffffffc0204432:	591c                	lw	a5,48(a0)
ffffffffc0204434:	84aa                	mv	s1,a0
ffffffffc0204436:	e3b9                	bnez	a5,ffffffffc020447c <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204438:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020443a:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020443e:	02850663          	beq	a0,s0,ffffffffc020446a <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204442:	ff043603          	ld	a2,-16(s0)
ffffffffc0204446:	fe843583          	ld	a1,-24(s0)
ffffffffc020444a:	854a                	mv	a0,s2
ffffffffc020444c:	bbbfd0ef          	jal	ra,ffffffffc0202006 <unmap_range>
ffffffffc0204450:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204452:	fe8498e3          	bne	s1,s0,ffffffffc0204442 <exit_mmap+0x1c>
ffffffffc0204456:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204458:	00848c63          	beq	s1,s0,ffffffffc0204470 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020445c:	ff043603          	ld	a2,-16(s0)
ffffffffc0204460:	fe843583          	ld	a1,-24(s0)
ffffffffc0204464:	854a                	mv	a0,s2
ffffffffc0204466:	ce7fd0ef          	jal	ra,ffffffffc020214c <exit_range>
ffffffffc020446a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020446c:	fe8498e3          	bne	s1,s0,ffffffffc020445c <exit_mmap+0x36>
    }
}
ffffffffc0204470:	60e2                	ld	ra,24(sp)
ffffffffc0204472:	6442                	ld	s0,16(sp)
ffffffffc0204474:	64a2                	ld	s1,8(sp)
ffffffffc0204476:	6902                	ld	s2,0(sp)
ffffffffc0204478:	6105                	addi	sp,sp,32
ffffffffc020447a:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020447c:	00004697          	auipc	a3,0x4
ffffffffc0204480:	22468693          	addi	a3,a3,548 # ffffffffc02086a0 <default_pmm_manager+0xd38>
ffffffffc0204484:	00003617          	auipc	a2,0x3
ffffffffc0204488:	e4c60613          	addi	a2,a2,-436 # ffffffffc02072d0 <commands+0x450>
ffffffffc020448c:	0d600593          	li	a1,214
ffffffffc0204490:	00004517          	auipc	a0,0x4
ffffffffc0204494:	16850513          	addi	a0,a0,360 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204498:	fe7fb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020449c <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020449c:	7139                	addi	sp,sp,-64
ffffffffc020449e:	f822                	sd	s0,48(sp)
ffffffffc02044a0:	f426                	sd	s1,40(sp)
ffffffffc02044a2:	fc06                	sd	ra,56(sp)
ffffffffc02044a4:	f04a                	sd	s2,32(sp)
ffffffffc02044a6:	ec4e                	sd	s3,24(sp)
ffffffffc02044a8:	e852                	sd	s4,16(sp)
ffffffffc02044aa:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02044ac:	c59ff0ef          	jal	ra,ffffffffc0204104 <mm_create>
    assert(mm != NULL);
ffffffffc02044b0:	84aa                	mv	s1,a0
ffffffffc02044b2:	03200413          	li	s0,50
ffffffffc02044b6:	e919                	bnez	a0,ffffffffc02044cc <vmm_init+0x30>
ffffffffc02044b8:	a991                	j	ffffffffc020490c <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02044ba:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044bc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044be:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02044c2:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044c4:	8526                	mv	a0,s1
ffffffffc02044c6:	cf5ff0ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02044ca:	c80d                	beqz	s0,ffffffffc02044fc <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044cc:	03000513          	li	a0,48
ffffffffc02044d0:	e26fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc02044d4:	85aa                	mv	a1,a0
ffffffffc02044d6:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02044da:	f165                	bnez	a0,ffffffffc02044ba <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044dc:	00004697          	auipc	a3,0x4
ffffffffc02044e0:	c3c68693          	addi	a3,a3,-964 # ffffffffc0208118 <default_pmm_manager+0x7b0>
ffffffffc02044e4:	00003617          	auipc	a2,0x3
ffffffffc02044e8:	dec60613          	addi	a2,a2,-532 # ffffffffc02072d0 <commands+0x450>
ffffffffc02044ec:	11300593          	li	a1,275
ffffffffc02044f0:	00004517          	auipc	a0,0x4
ffffffffc02044f4:	10850513          	addi	a0,a0,264 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02044f8:	f87fb0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc02044fc:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204500:	1f900913          	li	s2,505
ffffffffc0204504:	a819                	j	ffffffffc020451a <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0204506:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204508:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020450a:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020450e:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204510:	8526                	mv	a0,s1
ffffffffc0204512:	ca9ff0ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204516:	03240a63          	beq	s0,s2,ffffffffc020454a <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020451a:	03000513          	li	a0,48
ffffffffc020451e:	dd8fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc0204522:	85aa                	mv	a1,a0
ffffffffc0204524:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204528:	fd79                	bnez	a0,ffffffffc0204506 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020452a:	00004697          	auipc	a3,0x4
ffffffffc020452e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0208118 <default_pmm_manager+0x7b0>
ffffffffc0204532:	00003617          	auipc	a2,0x3
ffffffffc0204536:	d9e60613          	addi	a2,a2,-610 # ffffffffc02072d0 <commands+0x450>
ffffffffc020453a:	11900593          	li	a1,281
ffffffffc020453e:	00004517          	auipc	a0,0x4
ffffffffc0204542:	0ba50513          	addi	a0,a0,186 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204546:	f39fb0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc020454a:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020454c:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc020454e:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204552:	2cf48d63          	beq	s1,a5,ffffffffc020482c <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204556:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd30010>
ffffffffc020455a:	ffe70613          	addi	a2,a4,-2
ffffffffc020455e:	24d61763          	bne	a2,a3,ffffffffc02047ac <vmm_init+0x310>
ffffffffc0204562:	ff07b683          	ld	a3,-16(a5)
ffffffffc0204566:	24e69363          	bne	a3,a4,ffffffffc02047ac <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc020456a:	0715                	addi	a4,a4,5
ffffffffc020456c:	679c                	ld	a5,8(a5)
ffffffffc020456e:	feb712e3          	bne	a4,a1,ffffffffc0204552 <vmm_init+0xb6>
ffffffffc0204572:	4a1d                	li	s4,7
ffffffffc0204574:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204576:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020457a:	85a2                	mv	a1,s0
ffffffffc020457c:	8526                	mv	a0,s1
ffffffffc020457e:	bfdff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc0204582:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0204584:	30050463          	beqz	a0,ffffffffc020488c <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204588:	00140593          	addi	a1,s0,1
ffffffffc020458c:	8526                	mv	a0,s1
ffffffffc020458e:	bedff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc0204592:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204594:	2c050c63          	beqz	a0,ffffffffc020486c <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204598:	85d2                	mv	a1,s4
ffffffffc020459a:	8526                	mv	a0,s1
ffffffffc020459c:	bdfff0ef          	jal	ra,ffffffffc020417a <find_vma>
        assert(vma3 == NULL);
ffffffffc02045a0:	2a051663          	bnez	a0,ffffffffc020484c <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02045a4:	00340593          	addi	a1,s0,3
ffffffffc02045a8:	8526                	mv	a0,s1
ffffffffc02045aa:	bd1ff0ef          	jal	ra,ffffffffc020417a <find_vma>
        assert(vma4 == NULL);
ffffffffc02045ae:	30051f63          	bnez	a0,ffffffffc02048cc <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02045b2:	00440593          	addi	a1,s0,4
ffffffffc02045b6:	8526                	mv	a0,s1
ffffffffc02045b8:	bc3ff0ef          	jal	ra,ffffffffc020417a <find_vma>
        assert(vma5 == NULL);
ffffffffc02045bc:	2e051863          	bnez	a0,ffffffffc02048ac <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02045c0:	00893783          	ld	a5,8(s2)
ffffffffc02045c4:	20879463          	bne	a5,s0,ffffffffc02047cc <vmm_init+0x330>
ffffffffc02045c8:	01093783          	ld	a5,16(s2)
ffffffffc02045cc:	20fa1063          	bne	s4,a5,ffffffffc02047cc <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045d0:	0089b783          	ld	a5,8(s3)
ffffffffc02045d4:	20879c63          	bne	a5,s0,ffffffffc02047ec <vmm_init+0x350>
ffffffffc02045d8:	0109b783          	ld	a5,16(s3)
ffffffffc02045dc:	20fa1863          	bne	s4,a5,ffffffffc02047ec <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045e0:	0415                	addi	s0,s0,5
ffffffffc02045e2:	0a15                	addi	s4,s4,5
ffffffffc02045e4:	f9541be3          	bne	s0,s5,ffffffffc020457a <vmm_init+0xde>
ffffffffc02045e8:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045ea:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045ec:	85a2                	mv	a1,s0
ffffffffc02045ee:	8526                	mv	a0,s1
ffffffffc02045f0:	b8bff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc02045f4:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02045f8:	c90d                	beqz	a0,ffffffffc020462a <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045fa:	6914                	ld	a3,16(a0)
ffffffffc02045fc:	6510                	ld	a2,8(a0)
ffffffffc02045fe:	00004517          	auipc	a0,0x4
ffffffffc0204602:	1c250513          	addi	a0,a0,450 # ffffffffc02087c0 <default_pmm_manager+0xe58>
ffffffffc0204606:	b7ffb0ef          	jal	ra,ffffffffc0200184 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020460a:	00004697          	auipc	a3,0x4
ffffffffc020460e:	1de68693          	addi	a3,a3,478 # ffffffffc02087e8 <default_pmm_manager+0xe80>
ffffffffc0204612:	00003617          	auipc	a2,0x3
ffffffffc0204616:	cbe60613          	addi	a2,a2,-834 # ffffffffc02072d0 <commands+0x450>
ffffffffc020461a:	13b00593          	li	a1,315
ffffffffc020461e:	00004517          	auipc	a0,0x4
ffffffffc0204622:	fda50513          	addi	a0,a0,-38 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204626:	e59fb0ef          	jal	ra,ffffffffc020047e <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020462a:	147d                	addi	s0,s0,-1
ffffffffc020462c:	fd2410e3          	bne	s0,s2,ffffffffc02045ec <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204630:	8526                	mv	a0,s1
ffffffffc0204632:	c59ff0ef          	jal	ra,ffffffffc020428a <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204636:	00004517          	auipc	a0,0x4
ffffffffc020463a:	1ca50513          	addi	a0,a0,458 # ffffffffc0208800 <default_pmm_manager+0xe98>
ffffffffc020463e:	b47fb0ef          	jal	ra,ffffffffc0200184 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204642:	f64fd0ef          	jal	ra,ffffffffc0201da6 <nr_free_pages>
ffffffffc0204646:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0204648:	abdff0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc020464c:	000cb797          	auipc	a5,0xcb
ffffffffc0204650:	94a7b623          	sd	a0,-1716(a5) # ffffffffc02cef98 <check_mm_struct>
ffffffffc0204654:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0204656:	28050b63          	beqz	a0,ffffffffc02048ec <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020465a:	000cb497          	auipc	s1,0xcb
ffffffffc020465e:	8fe4b483          	ld	s1,-1794(s1) # ffffffffc02cef58 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0204662:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204664:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204666:	2e079f63          	bnez	a5,ffffffffc0204964 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020466a:	03000513          	li	a0,48
ffffffffc020466e:	c88fd0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc0204672:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0204674:	18050c63          	beqz	a0,ffffffffc020480c <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0204678:	002007b7          	lui	a5,0x200
ffffffffc020467c:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204680:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204682:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204684:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204688:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020468a:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc020468e:	b2dff0ef          	jal	ra,ffffffffc02041ba <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204692:	10000593          	li	a1,256
ffffffffc0204696:	8522                	mv	a0,s0
ffffffffc0204698:	ae3ff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc020469c:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02046a0:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02046a4:	2ea99063          	bne	s3,a0,ffffffffc0204984 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02046a8:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f38c8>
    for (i = 0; i < 100; i ++) {
ffffffffc02046ac:	0785                	addi	a5,a5,1
ffffffffc02046ae:	fee79de3          	bne	a5,a4,ffffffffc02046a8 <vmm_init+0x20c>
        sum += i;
ffffffffc02046b2:	6705                	lui	a4,0x1
ffffffffc02046b4:	10000793          	li	a5,256
ffffffffc02046b8:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8c12>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02046bc:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02046c0:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02046c4:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02046c6:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02046c8:	fec79ce3          	bne	a5,a2,ffffffffc02046c0 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02046cc:	2e071863          	bnez	a4,ffffffffc02049bc <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02046d2:	000cba97          	auipc	s5,0xcb
ffffffffc02046d6:	88ea8a93          	addi	s5,s5,-1906 # ffffffffc02cef60 <npage>
ffffffffc02046da:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046de:	078a                	slli	a5,a5,0x2
ffffffffc02046e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046e2:	2cc7f163          	bgeu	a5,a2,ffffffffc02049a4 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02046e6:	00005a17          	auipc	s4,0x5
ffffffffc02046ea:	38aa3a03          	ld	s4,906(s4) # ffffffffc0209a70 <nbase>
ffffffffc02046ee:	414787b3          	sub	a5,a5,s4
ffffffffc02046f2:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02046f4:	8799                	srai	a5,a5,0x6
ffffffffc02046f6:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02046f8:	00c79713          	slli	a4,a5,0xc
ffffffffc02046fc:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02046fe:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204702:	24c77563          	bgeu	a4,a2,ffffffffc020494c <vmm_init+0x4b0>
ffffffffc0204706:	000cb997          	auipc	s3,0xcb
ffffffffc020470a:	8729b983          	ld	s3,-1934(s3) # ffffffffc02cef78 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020470e:	4581                	li	a1,0
ffffffffc0204710:	8526                	mv	a0,s1
ffffffffc0204712:	99b6                	add	s3,s3,a3
ffffffffc0204714:	ccbfd0ef          	jal	ra,ffffffffc02023de <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204718:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020471c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204720:	078a                	slli	a5,a5,0x2
ffffffffc0204722:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204724:	28e7f063          	bgeu	a5,a4,ffffffffc02049a4 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204728:	000cb997          	auipc	s3,0xcb
ffffffffc020472c:	84098993          	addi	s3,s3,-1984 # ffffffffc02cef68 <pages>
ffffffffc0204730:	0009b503          	ld	a0,0(s3)
ffffffffc0204734:	414787b3          	sub	a5,a5,s4
ffffffffc0204738:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020473a:	953e                	add	a0,a0,a5
ffffffffc020473c:	4585                	li	a1,1
ffffffffc020473e:	e28fd0ef          	jal	ra,ffffffffc0201d66 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204742:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204744:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204748:	078a                	slli	a5,a5,0x2
ffffffffc020474a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020474c:	24e7fc63          	bgeu	a5,a4,ffffffffc02049a4 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204750:	0009b503          	ld	a0,0(s3)
ffffffffc0204754:	414787b3          	sub	a5,a5,s4
ffffffffc0204758:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020475a:	4585                	li	a1,1
ffffffffc020475c:	953e                	add	a0,a0,a5
ffffffffc020475e:	e08fd0ef          	jal	ra,ffffffffc0201d66 <free_pages>
    pgdir[0] = 0;
ffffffffc0204762:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0204766:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020476a:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020476c:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204770:	b1bff0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204774:	000cb797          	auipc	a5,0xcb
ffffffffc0204778:	8207b223          	sd	zero,-2012(a5) # ffffffffc02cef98 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020477c:	e2afd0ef          	jal	ra,ffffffffc0201da6 <nr_free_pages>
ffffffffc0204780:	1aa91663          	bne	s2,a0,ffffffffc020492c <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204784:	00004517          	auipc	a0,0x4
ffffffffc0204788:	10c50513          	addi	a0,a0,268 # ffffffffc0208890 <default_pmm_manager+0xf28>
ffffffffc020478c:	9f9fb0ef          	jal	ra,ffffffffc0200184 <cprintf>
}
ffffffffc0204790:	7442                	ld	s0,48(sp)
ffffffffc0204792:	70e2                	ld	ra,56(sp)
ffffffffc0204794:	74a2                	ld	s1,40(sp)
ffffffffc0204796:	7902                	ld	s2,32(sp)
ffffffffc0204798:	69e2                	ld	s3,24(sp)
ffffffffc020479a:	6a42                	ld	s4,16(sp)
ffffffffc020479c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020479e:	00004517          	auipc	a0,0x4
ffffffffc02047a2:	11250513          	addi	a0,a0,274 # ffffffffc02088b0 <default_pmm_manager+0xf48>
}
ffffffffc02047a6:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02047a8:	9ddfb06f          	j	ffffffffc0200184 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02047ac:	00004697          	auipc	a3,0x4
ffffffffc02047b0:	f2c68693          	addi	a3,a3,-212 # ffffffffc02086d8 <default_pmm_manager+0xd70>
ffffffffc02047b4:	00003617          	auipc	a2,0x3
ffffffffc02047b8:	b1c60613          	addi	a2,a2,-1252 # ffffffffc02072d0 <commands+0x450>
ffffffffc02047bc:	12200593          	li	a1,290
ffffffffc02047c0:	00004517          	auipc	a0,0x4
ffffffffc02047c4:	e3850513          	addi	a0,a0,-456 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02047c8:	cb7fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02047cc:	00004697          	auipc	a3,0x4
ffffffffc02047d0:	f9468693          	addi	a3,a3,-108 # ffffffffc0208760 <default_pmm_manager+0xdf8>
ffffffffc02047d4:	00003617          	auipc	a2,0x3
ffffffffc02047d8:	afc60613          	addi	a2,a2,-1284 # ffffffffc02072d0 <commands+0x450>
ffffffffc02047dc:	13200593          	li	a1,306
ffffffffc02047e0:	00004517          	auipc	a0,0x4
ffffffffc02047e4:	e1850513          	addi	a0,a0,-488 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02047e8:	c97fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047ec:	00004697          	auipc	a3,0x4
ffffffffc02047f0:	fa468693          	addi	a3,a3,-92 # ffffffffc0208790 <default_pmm_manager+0xe28>
ffffffffc02047f4:	00003617          	auipc	a2,0x3
ffffffffc02047f8:	adc60613          	addi	a2,a2,-1316 # ffffffffc02072d0 <commands+0x450>
ffffffffc02047fc:	13300593          	li	a1,307
ffffffffc0204800:	00004517          	auipc	a0,0x4
ffffffffc0204804:	df850513          	addi	a0,a0,-520 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204808:	c77fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(vma != NULL);
ffffffffc020480c:	00004697          	auipc	a3,0x4
ffffffffc0204810:	90c68693          	addi	a3,a3,-1780 # ffffffffc0208118 <default_pmm_manager+0x7b0>
ffffffffc0204814:	00003617          	auipc	a2,0x3
ffffffffc0204818:	abc60613          	addi	a2,a2,-1348 # ffffffffc02072d0 <commands+0x450>
ffffffffc020481c:	15200593          	li	a1,338
ffffffffc0204820:	00004517          	auipc	a0,0x4
ffffffffc0204824:	dd850513          	addi	a0,a0,-552 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204828:	c57fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020482c:	00004697          	auipc	a3,0x4
ffffffffc0204830:	e9468693          	addi	a3,a3,-364 # ffffffffc02086c0 <default_pmm_manager+0xd58>
ffffffffc0204834:	00003617          	auipc	a2,0x3
ffffffffc0204838:	a9c60613          	addi	a2,a2,-1380 # ffffffffc02072d0 <commands+0x450>
ffffffffc020483c:	12000593          	li	a1,288
ffffffffc0204840:	00004517          	auipc	a0,0x4
ffffffffc0204844:	db850513          	addi	a0,a0,-584 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204848:	c37fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma3 == NULL);
ffffffffc020484c:	00004697          	auipc	a3,0x4
ffffffffc0204850:	ee468693          	addi	a3,a3,-284 # ffffffffc0208730 <default_pmm_manager+0xdc8>
ffffffffc0204854:	00003617          	auipc	a2,0x3
ffffffffc0204858:	a7c60613          	addi	a2,a2,-1412 # ffffffffc02072d0 <commands+0x450>
ffffffffc020485c:	12c00593          	li	a1,300
ffffffffc0204860:	00004517          	auipc	a0,0x4
ffffffffc0204864:	d9850513          	addi	a0,a0,-616 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204868:	c17fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma2 != NULL);
ffffffffc020486c:	00004697          	auipc	a3,0x4
ffffffffc0204870:	eb468693          	addi	a3,a3,-332 # ffffffffc0208720 <default_pmm_manager+0xdb8>
ffffffffc0204874:	00003617          	auipc	a2,0x3
ffffffffc0204878:	a5c60613          	addi	a2,a2,-1444 # ffffffffc02072d0 <commands+0x450>
ffffffffc020487c:	12a00593          	li	a1,298
ffffffffc0204880:	00004517          	auipc	a0,0x4
ffffffffc0204884:	d7850513          	addi	a0,a0,-648 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204888:	bf7fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma1 != NULL);
ffffffffc020488c:	00004697          	auipc	a3,0x4
ffffffffc0204890:	e8468693          	addi	a3,a3,-380 # ffffffffc0208710 <default_pmm_manager+0xda8>
ffffffffc0204894:	00003617          	auipc	a2,0x3
ffffffffc0204898:	a3c60613          	addi	a2,a2,-1476 # ffffffffc02072d0 <commands+0x450>
ffffffffc020489c:	12800593          	li	a1,296
ffffffffc02048a0:	00004517          	auipc	a0,0x4
ffffffffc02048a4:	d5850513          	addi	a0,a0,-680 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02048a8:	bd7fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma5 == NULL);
ffffffffc02048ac:	00004697          	auipc	a3,0x4
ffffffffc02048b0:	ea468693          	addi	a3,a3,-348 # ffffffffc0208750 <default_pmm_manager+0xde8>
ffffffffc02048b4:	00003617          	auipc	a2,0x3
ffffffffc02048b8:	a1c60613          	addi	a2,a2,-1508 # ffffffffc02072d0 <commands+0x450>
ffffffffc02048bc:	13000593          	li	a1,304
ffffffffc02048c0:	00004517          	auipc	a0,0x4
ffffffffc02048c4:	d3850513          	addi	a0,a0,-712 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02048c8:	bb7fb0ef          	jal	ra,ffffffffc020047e <__panic>
        assert(vma4 == NULL);
ffffffffc02048cc:	00004697          	auipc	a3,0x4
ffffffffc02048d0:	e7468693          	addi	a3,a3,-396 # ffffffffc0208740 <default_pmm_manager+0xdd8>
ffffffffc02048d4:	00003617          	auipc	a2,0x3
ffffffffc02048d8:	9fc60613          	addi	a2,a2,-1540 # ffffffffc02072d0 <commands+0x450>
ffffffffc02048dc:	12e00593          	li	a1,302
ffffffffc02048e0:	00004517          	auipc	a0,0x4
ffffffffc02048e4:	d1850513          	addi	a0,a0,-744 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02048e8:	b97fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02048ec:	00004697          	auipc	a3,0x4
ffffffffc02048f0:	f3468693          	addi	a3,a3,-204 # ffffffffc0208820 <default_pmm_manager+0xeb8>
ffffffffc02048f4:	00003617          	auipc	a2,0x3
ffffffffc02048f8:	9dc60613          	addi	a2,a2,-1572 # ffffffffc02072d0 <commands+0x450>
ffffffffc02048fc:	14b00593          	li	a1,331
ffffffffc0204900:	00004517          	auipc	a0,0x4
ffffffffc0204904:	cf850513          	addi	a0,a0,-776 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204908:	b77fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(mm != NULL);
ffffffffc020490c:	00003697          	auipc	a3,0x3
ffffffffc0204910:	7d468693          	addi	a3,a3,2004 # ffffffffc02080e0 <default_pmm_manager+0x778>
ffffffffc0204914:	00003617          	auipc	a2,0x3
ffffffffc0204918:	9bc60613          	addi	a2,a2,-1604 # ffffffffc02072d0 <commands+0x450>
ffffffffc020491c:	10c00593          	li	a1,268
ffffffffc0204920:	00004517          	auipc	a0,0x4
ffffffffc0204924:	cd850513          	addi	a0,a0,-808 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204928:	b57fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020492c:	00004697          	auipc	a3,0x4
ffffffffc0204930:	f3c68693          	addi	a3,a3,-196 # ffffffffc0208868 <default_pmm_manager+0xf00>
ffffffffc0204934:	00003617          	auipc	a2,0x3
ffffffffc0204938:	99c60613          	addi	a2,a2,-1636 # ffffffffc02072d0 <commands+0x450>
ffffffffc020493c:	17000593          	li	a1,368
ffffffffc0204940:	00004517          	auipc	a0,0x4
ffffffffc0204944:	cb850513          	addi	a0,a0,-840 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204948:	b37fb0ef          	jal	ra,ffffffffc020047e <__panic>
    return KADDR(page2pa(page));
ffffffffc020494c:	00003617          	auipc	a2,0x3
ffffffffc0204950:	05460613          	addi	a2,a2,84 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0204954:	06900593          	li	a1,105
ffffffffc0204958:	00003517          	auipc	a0,0x3
ffffffffc020495c:	07050513          	addi	a0,a0,112 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0204960:	b1ffb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204964:	00003697          	auipc	a3,0x3
ffffffffc0204968:	7a468693          	addi	a3,a3,1956 # ffffffffc0208108 <default_pmm_manager+0x7a0>
ffffffffc020496c:	00003617          	auipc	a2,0x3
ffffffffc0204970:	96460613          	addi	a2,a2,-1692 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204974:	14f00593          	li	a1,335
ffffffffc0204978:	00004517          	auipc	a0,0x4
ffffffffc020497c:	c8050513          	addi	a0,a0,-896 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc0204980:	afffb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204984:	00004697          	auipc	a3,0x4
ffffffffc0204988:	eb468693          	addi	a3,a3,-332 # ffffffffc0208838 <default_pmm_manager+0xed0>
ffffffffc020498c:	00003617          	auipc	a2,0x3
ffffffffc0204990:	94460613          	addi	a2,a2,-1724 # ffffffffc02072d0 <commands+0x450>
ffffffffc0204994:	15700593          	li	a1,343
ffffffffc0204998:	00004517          	auipc	a0,0x4
ffffffffc020499c:	c6050513          	addi	a0,a0,-928 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02049a0:	adffb0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049a4:	00003617          	auipc	a2,0x3
ffffffffc02049a8:	0cc60613          	addi	a2,a2,204 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc02049ac:	06200593          	li	a1,98
ffffffffc02049b0:	00003517          	auipc	a0,0x3
ffffffffc02049b4:	01850513          	addi	a0,a0,24 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02049b8:	ac7fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(sum == 0);
ffffffffc02049bc:	00004697          	auipc	a3,0x4
ffffffffc02049c0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0208858 <default_pmm_manager+0xef0>
ffffffffc02049c4:	00003617          	auipc	a2,0x3
ffffffffc02049c8:	90c60613          	addi	a2,a2,-1780 # ffffffffc02072d0 <commands+0x450>
ffffffffc02049cc:	16300593          	li	a1,355
ffffffffc02049d0:	00004517          	auipc	a0,0x4
ffffffffc02049d4:	c2850513          	addi	a0,a0,-984 # ffffffffc02085f8 <default_pmm_manager+0xc90>
ffffffffc02049d8:	aa7fb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02049dc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049dc:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049de:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049e0:	f022                	sd	s0,32(sp)
ffffffffc02049e2:	ec26                	sd	s1,24(sp)
ffffffffc02049e4:	f406                	sd	ra,40(sp)
ffffffffc02049e6:	e84a                	sd	s2,16(sp)
ffffffffc02049e8:	8432                	mv	s0,a2
ffffffffc02049ea:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049ec:	f8eff0ef          	jal	ra,ffffffffc020417a <find_vma>

    pgfault_num++;
ffffffffc02049f0:	000ca797          	auipc	a5,0xca
ffffffffc02049f4:	5b07a783          	lw	a5,1456(a5) # ffffffffc02cefa0 <pgfault_num>
ffffffffc02049f8:	2785                	addiw	a5,a5,1
ffffffffc02049fa:	000ca717          	auipc	a4,0xca
ffffffffc02049fe:	5af72323          	sw	a5,1446(a4) # ffffffffc02cefa0 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a02:	c551                	beqz	a0,ffffffffc0204a8e <do_pgfault+0xb2>
ffffffffc0204a04:	651c                	ld	a5,8(a0)
ffffffffc0204a06:	08f46463          	bltu	s0,a5,ffffffffc0204a8e <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a0a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204a0c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a0e:	8b89                	andi	a5,a5,2
ffffffffc0204a10:	efb1                	bnez	a5,ffffffffc0204a6c <do_pgfault+0x90>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a12:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a14:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a16:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a18:	4605                	li	a2,1
ffffffffc0204a1a:	85a2                	mv	a1,s0
ffffffffc0204a1c:	bc4fd0ef          	jal	ra,ffffffffc0201de0 <get_pte>
ffffffffc0204a20:	c945                	beqz	a0,ffffffffc0204ad0 <do_pgfault+0xf4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a22:	610c                	ld	a1,0(a0)
ffffffffc0204a24:	c5b1                	beqz	a1,ffffffffc0204a70 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if(swap_init_ok) {
ffffffffc0204a26:	000ca797          	auipc	a5,0xca
ffffffffc0204a2a:	56a7a783          	lw	a5,1386(a5) # ffffffffc02cef90 <swap_init_ok>
ffffffffc0204a2e:	cbad                	beqz	a5,ffffffffc0204aa0 <do_pgfault+0xc4>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);*/
			 if(swap_in(mm, addr, &page) != 0 ){
ffffffffc0204a30:	0030                	addi	a2,sp,8
ffffffffc0204a32:	85a2                	mv	a1,s0
ffffffffc0204a34:	8526                	mv	a0,s1
            struct Page *page=NULL;
ffffffffc0204a36:	e402                	sd	zero,8(sp)
			 if(swap_in(mm, addr, &page) != 0 ){
ffffffffc0204a38:	a34ff0ef          	jal	ra,ffffffffc0203c6c <swap_in>
ffffffffc0204a3c:	e935                	bnez	a0,ffffffffc0204ab0 <do_pgfault+0xd4>
            }
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            if(page_insert(mm->pgdir, page, addr, perm) != 0){
ffffffffc0204a3e:	65a2                	ld	a1,8(sp)
ffffffffc0204a40:	6c88                	ld	a0,24(s1)
ffffffffc0204a42:	86ca                	mv	a3,s2
ffffffffc0204a44:	8622                	mv	a2,s0
ffffffffc0204a46:	a35fd0ef          	jal	ra,ffffffffc020247a <page_insert>
ffffffffc0204a4a:	892a                	mv	s2,a0
ffffffffc0204a4c:	e935                	bnez	a0,ffffffffc0204ac0 <do_pgfault+0xe4>
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a4e:	6622                	ld	a2,8(sp)
ffffffffc0204a50:	4685                	li	a3,1
ffffffffc0204a52:	85a2                	mv	a1,s0
ffffffffc0204a54:	8526                	mv	a0,s1
ffffffffc0204a56:	8f6ff0ef          	jal	ra,ffffffffc0203b4c <swap_map_swappable>
			page->pra_vaddr = addr;
ffffffffc0204a5a:	67a2                	ld	a5,8(sp)
ffffffffc0204a5c:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a5e:	70a2                	ld	ra,40(sp)
ffffffffc0204a60:	7402                	ld	s0,32(sp)
ffffffffc0204a62:	64e2                	ld	s1,24(sp)
ffffffffc0204a64:	854a                	mv	a0,s2
ffffffffc0204a66:	6942                	ld	s2,16(sp)
ffffffffc0204a68:	6145                	addi	sp,sp,48
ffffffffc0204a6a:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a6c:	495d                	li	s2,23
ffffffffc0204a6e:	b755                	j	ffffffffc0204a12 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a70:	6c88                	ld	a0,24(s1)
ffffffffc0204a72:	864a                	mv	a2,s2
ffffffffc0204a74:	85a2                	mv	a1,s0
ffffffffc0204a76:	8affe0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a7a:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a7c:	f16d                	bnez	a0,ffffffffc0204a5e <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a7e:	00004517          	auipc	a0,0x4
ffffffffc0204a82:	e9a50513          	addi	a0,a0,-358 # ffffffffc0208918 <default_pmm_manager+0xfb0>
ffffffffc0204a86:	efefb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a8a:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a8c:	bfc9                	j	ffffffffc0204a5e <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a8e:	85a2                	mv	a1,s0
ffffffffc0204a90:	00004517          	auipc	a0,0x4
ffffffffc0204a94:	e3850513          	addi	a0,a0,-456 # ffffffffc02088c8 <default_pmm_manager+0xf60>
ffffffffc0204a98:	eecfb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a9c:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a9e:	b7c1                	j	ffffffffc0204a5e <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204aa0:	00004517          	auipc	a0,0x4
ffffffffc0204aa4:	ee850513          	addi	a0,a0,-280 # ffffffffc0208988 <default_pmm_manager+0x1020>
ffffffffc0204aa8:	edcfb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204aac:	5971                	li	s2,-4
            goto failed;
ffffffffc0204aae:	bf45                	j	ffffffffc0204a5e <do_pgfault+0x82>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204ab0:	00004517          	auipc	a0,0x4
ffffffffc0204ab4:	e9050513          	addi	a0,a0,-368 # ffffffffc0208940 <default_pmm_manager+0xfd8>
ffffffffc0204ab8:	eccfb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204abc:	5971                	li	s2,-4
ffffffffc0204abe:	b745                	j	ffffffffc0204a5e <do_pgfault+0x82>
                cprintf("page_insert in do_pgfault failed\n");
ffffffffc0204ac0:	00004517          	auipc	a0,0x4
ffffffffc0204ac4:	ea050513          	addi	a0,a0,-352 # ffffffffc0208960 <default_pmm_manager+0xff8>
ffffffffc0204ac8:	ebcfb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204acc:	5971                	li	s2,-4
ffffffffc0204ace:	bf41                	j	ffffffffc0204a5e <do_pgfault+0x82>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204ad0:	00004517          	auipc	a0,0x4
ffffffffc0204ad4:	e2850513          	addi	a0,a0,-472 # ffffffffc02088f8 <default_pmm_manager+0xf90>
ffffffffc0204ad8:	eacfb0ef          	jal	ra,ffffffffc0200184 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204adc:	5971                	li	s2,-4
        goto failed;
ffffffffc0204ade:	b741                	j	ffffffffc0204a5e <do_pgfault+0x82>

ffffffffc0204ae0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204ae0:	7179                	addi	sp,sp,-48
ffffffffc0204ae2:	f022                	sd	s0,32(sp)
ffffffffc0204ae4:	f406                	sd	ra,40(sp)
ffffffffc0204ae6:	ec26                	sd	s1,24(sp)
ffffffffc0204ae8:	e84a                	sd	s2,16(sp)
ffffffffc0204aea:	e44e                	sd	s3,8(sp)
ffffffffc0204aec:	e052                	sd	s4,0(sp)
ffffffffc0204aee:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204af0:	c135                	beqz	a0,ffffffffc0204b54 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204af2:	002007b7          	lui	a5,0x200
ffffffffc0204af6:	04f5e663          	bltu	a1,a5,ffffffffc0204b42 <user_mem_check+0x62>
ffffffffc0204afa:	00c584b3          	add	s1,a1,a2
ffffffffc0204afe:	0495f263          	bgeu	a1,s1,ffffffffc0204b42 <user_mem_check+0x62>
ffffffffc0204b02:	4785                	li	a5,1
ffffffffc0204b04:	07fe                	slli	a5,a5,0x1f
ffffffffc0204b06:	0297ee63          	bltu	a5,s1,ffffffffc0204b42 <user_mem_check+0x62>
ffffffffc0204b0a:	892a                	mv	s2,a0
ffffffffc0204b0c:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b0e:	6a05                	lui	s4,0x1
ffffffffc0204b10:	a821                	j	ffffffffc0204b28 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b12:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b16:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204b18:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b1a:	c685                	beqz	a3,ffffffffc0204b42 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204b1c:	c399                	beqz	a5,ffffffffc0204b22 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b1e:	02e46263          	bltu	s0,a4,ffffffffc0204b42 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204b22:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204b24:	04947663          	bgeu	s0,s1,ffffffffc0204b70 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204b28:	85a2                	mv	a1,s0
ffffffffc0204b2a:	854a                	mv	a0,s2
ffffffffc0204b2c:	e4eff0ef          	jal	ra,ffffffffc020417a <find_vma>
ffffffffc0204b30:	c909                	beqz	a0,ffffffffc0204b42 <user_mem_check+0x62>
ffffffffc0204b32:	6518                	ld	a4,8(a0)
ffffffffc0204b34:	00e46763          	bltu	s0,a4,ffffffffc0204b42 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b38:	4d1c                	lw	a5,24(a0)
ffffffffc0204b3a:	fc099ce3          	bnez	s3,ffffffffc0204b12 <user_mem_check+0x32>
ffffffffc0204b3e:	8b85                	andi	a5,a5,1
ffffffffc0204b40:	f3ed                	bnez	a5,ffffffffc0204b22 <user_mem_check+0x42>
            return 0;
ffffffffc0204b42:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b44:	70a2                	ld	ra,40(sp)
ffffffffc0204b46:	7402                	ld	s0,32(sp)
ffffffffc0204b48:	64e2                	ld	s1,24(sp)
ffffffffc0204b4a:	6942                	ld	s2,16(sp)
ffffffffc0204b4c:	69a2                	ld	s3,8(sp)
ffffffffc0204b4e:	6a02                	ld	s4,0(sp)
ffffffffc0204b50:	6145                	addi	sp,sp,48
ffffffffc0204b52:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b54:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b58:	4501                	li	a0,0
ffffffffc0204b5a:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b44 <user_mem_check+0x64>
ffffffffc0204b5e:	962e                	add	a2,a2,a1
ffffffffc0204b60:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204b44 <user_mem_check+0x64>
ffffffffc0204b64:	c8000537          	lui	a0,0xc8000
ffffffffc0204b68:	0505                	addi	a0,a0,1
ffffffffc0204b6a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b6e:	bfd9                	j	ffffffffc0204b44 <user_mem_check+0x64>
        return 1;
ffffffffc0204b70:	4505                	li	a0,1
ffffffffc0204b72:	bfc9                	j	ffffffffc0204b44 <user_mem_check+0x64>

ffffffffc0204b74 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b74:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b76:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b78:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b7a:	a6dfb0ef          	jal	ra,ffffffffc02005e6 <ide_device_valid>
ffffffffc0204b7e:	cd01                	beqz	a0,ffffffffc0204b96 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b80:	4505                	li	a0,1
ffffffffc0204b82:	a6bfb0ef          	jal	ra,ffffffffc02005ec <ide_device_size>
}
ffffffffc0204b86:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b88:	810d                	srli	a0,a0,0x3
ffffffffc0204b8a:	000ca797          	auipc	a5,0xca
ffffffffc0204b8e:	3ea7bb23          	sd	a0,1014(a5) # ffffffffc02cef80 <max_swap_offset>
}
ffffffffc0204b92:	0141                	addi	sp,sp,16
ffffffffc0204b94:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b96:	00004617          	auipc	a2,0x4
ffffffffc0204b9a:	e1a60613          	addi	a2,a2,-486 # ffffffffc02089b0 <default_pmm_manager+0x1048>
ffffffffc0204b9e:	45b5                	li	a1,13
ffffffffc0204ba0:	00004517          	auipc	a0,0x4
ffffffffc0204ba4:	e3050513          	addi	a0,a0,-464 # ffffffffc02089d0 <default_pmm_manager+0x1068>
ffffffffc0204ba8:	8d7fb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204bac <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204bac:	1141                	addi	sp,sp,-16
ffffffffc0204bae:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bb0:	00855793          	srli	a5,a0,0x8
ffffffffc0204bb4:	cbb1                	beqz	a5,ffffffffc0204c08 <swapfs_read+0x5c>
ffffffffc0204bb6:	000ca717          	auipc	a4,0xca
ffffffffc0204bba:	3ca73703          	ld	a4,970(a4) # ffffffffc02cef80 <max_swap_offset>
ffffffffc0204bbe:	04e7f563          	bgeu	a5,a4,ffffffffc0204c08 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204bc2:	000ca617          	auipc	a2,0xca
ffffffffc0204bc6:	3a663603          	ld	a2,934(a2) # ffffffffc02cef68 <pages>
ffffffffc0204bca:	8d91                	sub	a1,a1,a2
ffffffffc0204bcc:	4065d613          	srai	a2,a1,0x6
ffffffffc0204bd0:	00005717          	auipc	a4,0x5
ffffffffc0204bd4:	ea073703          	ld	a4,-352(a4) # ffffffffc0209a70 <nbase>
ffffffffc0204bd8:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204bda:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bde:	8331                	srli	a4,a4,0xc
ffffffffc0204be0:	000ca697          	auipc	a3,0xca
ffffffffc0204be4:	3806b683          	ld	a3,896(a3) # ffffffffc02cef60 <npage>
ffffffffc0204be8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bec:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bee:	02d77963          	bgeu	a4,a3,ffffffffc0204c20 <swapfs_read+0x74>
}
ffffffffc0204bf2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bf4:	000ca797          	auipc	a5,0xca
ffffffffc0204bf8:	3847b783          	ld	a5,900(a5) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0204bfc:	46a1                	li	a3,8
ffffffffc0204bfe:	963e                	add	a2,a2,a5
ffffffffc0204c00:	4505                	li	a0,1
}
ffffffffc0204c02:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c04:	9effb06f          	j	ffffffffc02005f2 <ide_read_secs>
ffffffffc0204c08:	86aa                	mv	a3,a0
ffffffffc0204c0a:	00004617          	auipc	a2,0x4
ffffffffc0204c0e:	dde60613          	addi	a2,a2,-546 # ffffffffc02089e8 <default_pmm_manager+0x1080>
ffffffffc0204c12:	45d1                	li	a1,20
ffffffffc0204c14:	00004517          	auipc	a0,0x4
ffffffffc0204c18:	dbc50513          	addi	a0,a0,-580 # ffffffffc02089d0 <default_pmm_manager+0x1068>
ffffffffc0204c1c:	863fb0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0204c20:	86b2                	mv	a3,a2
ffffffffc0204c22:	06900593          	li	a1,105
ffffffffc0204c26:	00003617          	auipc	a2,0x3
ffffffffc0204c2a:	d7a60613          	addi	a2,a2,-646 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0204c2e:	00003517          	auipc	a0,0x3
ffffffffc0204c32:	d9a50513          	addi	a0,a0,-614 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0204c36:	849fb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204c3a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c3a:	1141                	addi	sp,sp,-16
ffffffffc0204c3c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c3e:	00855793          	srli	a5,a0,0x8
ffffffffc0204c42:	cbb1                	beqz	a5,ffffffffc0204c96 <swapfs_write+0x5c>
ffffffffc0204c44:	000ca717          	auipc	a4,0xca
ffffffffc0204c48:	33c73703          	ld	a4,828(a4) # ffffffffc02cef80 <max_swap_offset>
ffffffffc0204c4c:	04e7f563          	bgeu	a5,a4,ffffffffc0204c96 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c50:	000ca617          	auipc	a2,0xca
ffffffffc0204c54:	31863603          	ld	a2,792(a2) # ffffffffc02cef68 <pages>
ffffffffc0204c58:	8d91                	sub	a1,a1,a2
ffffffffc0204c5a:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c5e:	00005717          	auipc	a4,0x5
ffffffffc0204c62:	e1273703          	ld	a4,-494(a4) # ffffffffc0209a70 <nbase>
ffffffffc0204c66:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c68:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c6c:	8331                	srli	a4,a4,0xc
ffffffffc0204c6e:	000ca697          	auipc	a3,0xca
ffffffffc0204c72:	2f26b683          	ld	a3,754(a3) # ffffffffc02cef60 <npage>
ffffffffc0204c76:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c7a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c7c:	02d77963          	bgeu	a4,a3,ffffffffc0204cae <swapfs_write+0x74>
}
ffffffffc0204c80:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c82:	000ca797          	auipc	a5,0xca
ffffffffc0204c86:	2f67b783          	ld	a5,758(a5) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0204c8a:	46a1                	li	a3,8
ffffffffc0204c8c:	963e                	add	a2,a2,a5
ffffffffc0204c8e:	4505                	li	a0,1
}
ffffffffc0204c90:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c92:	985fb06f          	j	ffffffffc0200616 <ide_write_secs>
ffffffffc0204c96:	86aa                	mv	a3,a0
ffffffffc0204c98:	00004617          	auipc	a2,0x4
ffffffffc0204c9c:	d5060613          	addi	a2,a2,-688 # ffffffffc02089e8 <default_pmm_manager+0x1080>
ffffffffc0204ca0:	45e5                	li	a1,25
ffffffffc0204ca2:	00004517          	auipc	a0,0x4
ffffffffc0204ca6:	d2e50513          	addi	a0,a0,-722 # ffffffffc02089d0 <default_pmm_manager+0x1068>
ffffffffc0204caa:	fd4fb0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0204cae:	86b2                	mv	a3,a2
ffffffffc0204cb0:	06900593          	li	a1,105
ffffffffc0204cb4:	00003617          	auipc	a2,0x3
ffffffffc0204cb8:	cec60613          	addi	a2,a2,-788 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0204cbc:	00003517          	auipc	a0,0x3
ffffffffc0204cc0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0204cc4:	fbafb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204cc8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cc8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cca:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ccc:	65e000ef          	jal	ra,ffffffffc020532a <do_exit>

ffffffffc0204cd0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204cd0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cd2:	14800513          	li	a0,328
alloc_proc(void) {
ffffffffc0204cd6:	e022                	sd	s0,0(sp)
ffffffffc0204cd8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cda:	e1dfc0ef          	jal	ra,ffffffffc0201af6 <kmalloc>
ffffffffc0204cde:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204ce0:	cd21                	beqz	a0,ffffffffc0204d38 <alloc_proc+0x68>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204ce2:	57fd                	li	a5,-1
ffffffffc0204ce4:	1782                	slli	a5,a5,0x20
ffffffffc0204ce6:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204ce8:	07000613          	li	a2,112
ffffffffc0204cec:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204cee:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204cf2:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204cf6:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cfa:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cfe:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d02:	03050513          	addi	a0,a0,48
ffffffffc0204d06:	6e5010ef          	jal	ra,ffffffffc0206bea <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204d0a:	000ca797          	auipc	a5,0xca
ffffffffc0204d0e:	2467b783          	ld	a5,582(a5) # ffffffffc02cef50 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204d12:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204d16:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0204d18:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204d1c:	4641                	li	a2,16
ffffffffc0204d1e:	4581                	li	a1,0
ffffffffc0204d20:	0b440513          	addi	a0,s0,180
ffffffffc0204d24:	6c7010ef          	jal	ra,ffffffffc0206bea <memset>

        proc->wait_state = 0;
ffffffffc0204d28:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204d2c:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc0204d30:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc0204d34:	0e043c23          	sd	zero,248(s0)
	}
    return proc;
}
ffffffffc0204d38:	60a2                	ld	ra,8(sp)
ffffffffc0204d3a:	8522                	mv	a0,s0
ffffffffc0204d3c:	6402                	ld	s0,0(sp)
ffffffffc0204d3e:	0141                	addi	sp,sp,16
ffffffffc0204d40:	8082                	ret

ffffffffc0204d42 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d42:	000ca797          	auipc	a5,0xca
ffffffffc0204d46:	2667b783          	ld	a5,614(a5) # ffffffffc02cefa8 <current>
ffffffffc0204d4a:	73c8                	ld	a0,160(a5)
ffffffffc0204d4c:	81efc06f          	j	ffffffffc0200d6a <forkrets>

ffffffffc0204d50 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(priority);
ffffffffc0204d50:	000ca797          	auipc	a5,0xca
ffffffffc0204d54:	2587b783          	ld	a5,600(a5) # ffffffffc02cefa8 <current>
ffffffffc0204d58:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204d5a:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(priority);
ffffffffc0204d5c:	00004617          	auipc	a2,0x4
ffffffffc0204d60:	cac60613          	addi	a2,a2,-852 # ffffffffc0208a08 <default_pmm_manager+0x10a0>
ffffffffc0204d64:	00004517          	auipc	a0,0x4
ffffffffc0204d68:	cb450513          	addi	a0,a0,-844 # ffffffffc0208a18 <default_pmm_manager+0x10b0>
user_main(void *arg) {
ffffffffc0204d6c:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(priority);
ffffffffc0204d6e:	c16fb0ef          	jal	ra,ffffffffc0200184 <cprintf>
ffffffffc0204d72:	3fe07797          	auipc	a5,0x3fe07
ffffffffc0204d76:	a0678793          	addi	a5,a5,-1530 # b778 <_binary_obj___user_priority_out_size>
ffffffffc0204d7a:	e43e                	sd	a5,8(sp)
ffffffffc0204d7c:	00004517          	auipc	a0,0x4
ffffffffc0204d80:	c8c50513          	addi	a0,a0,-884 # ffffffffc0208a08 <default_pmm_manager+0x10a0>
ffffffffc0204d84:	0007e797          	auipc	a5,0x7e
ffffffffc0204d88:	16478793          	addi	a5,a5,356 # ffffffffc0282ee8 <_binary_obj___user_priority_out_start>
ffffffffc0204d8c:	f03e                	sd	a5,32(sp)
ffffffffc0204d8e:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d90:	e802                	sd	zero,16(sp)
ffffffffc0204d92:	5dd010ef          	jal	ra,ffffffffc0206b6e <strlen>
ffffffffc0204d96:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d98:	4511                	li	a0,4
ffffffffc0204d9a:	55a2                	lw	a1,40(sp)
ffffffffc0204d9c:	4662                	lw	a2,24(sp)
ffffffffc0204d9e:	5682                	lw	a3,32(sp)
ffffffffc0204da0:	4722                	lw	a4,8(sp)
ffffffffc0204da2:	48a9                	li	a7,10
ffffffffc0204da4:	9002                	ebreak
ffffffffc0204da6:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204da8:	65c2                	ld	a1,16(sp)
ffffffffc0204daa:	00004517          	auipc	a0,0x4
ffffffffc0204dae:	c9650513          	addi	a0,a0,-874 # ffffffffc0208a40 <default_pmm_manager+0x10d8>
ffffffffc0204db2:	bd2fb0ef          	jal	ra,ffffffffc0200184 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204db6:	00004617          	auipc	a2,0x4
ffffffffc0204dba:	c9a60613          	addi	a2,a2,-870 # ffffffffc0208a50 <default_pmm_manager+0x10e8>
ffffffffc0204dbe:	36200593          	li	a1,866
ffffffffc0204dc2:	00004517          	auipc	a0,0x4
ffffffffc0204dc6:	cae50513          	addi	a0,a0,-850 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0204dca:	eb4fb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204dce <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dce:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dd0:	1141                	addi	sp,sp,-16
ffffffffc0204dd2:	e406                	sd	ra,8(sp)
ffffffffc0204dd4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dd8:	02f6ee63          	bltu	a3,a5,ffffffffc0204e14 <put_pgdir+0x46>
ffffffffc0204ddc:	000ca517          	auipc	a0,0xca
ffffffffc0204de0:	19c53503          	ld	a0,412(a0) # ffffffffc02cef78 <va_pa_offset>
ffffffffc0204de4:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204de6:	82b1                	srli	a3,a3,0xc
ffffffffc0204de8:	000ca797          	auipc	a5,0xca
ffffffffc0204dec:	1787b783          	ld	a5,376(a5) # ffffffffc02cef60 <npage>
ffffffffc0204df0:	02f6fe63          	bgeu	a3,a5,ffffffffc0204e2c <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204df4:	00005517          	auipc	a0,0x5
ffffffffc0204df8:	c7c53503          	ld	a0,-900(a0) # ffffffffc0209a70 <nbase>
}
ffffffffc0204dfc:	60a2                	ld	ra,8(sp)
ffffffffc0204dfe:	8e89                	sub	a3,a3,a0
ffffffffc0204e00:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e02:	000ca517          	auipc	a0,0xca
ffffffffc0204e06:	16653503          	ld	a0,358(a0) # ffffffffc02cef68 <pages>
ffffffffc0204e0a:	4585                	li	a1,1
ffffffffc0204e0c:	9536                	add	a0,a0,a3
}
ffffffffc0204e0e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e10:	f57fc06f          	j	ffffffffc0201d66 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e14:	00003617          	auipc	a2,0x3
ffffffffc0204e18:	c3460613          	addi	a2,a2,-972 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0204e1c:	06e00593          	li	a1,110
ffffffffc0204e20:	00003517          	auipc	a0,0x3
ffffffffc0204e24:	ba850513          	addi	a0,a0,-1112 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0204e28:	e56fb0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e2c:	00003617          	auipc	a2,0x3
ffffffffc0204e30:	c4460613          	addi	a2,a2,-956 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0204e34:	06200593          	li	a1,98
ffffffffc0204e38:	00003517          	auipc	a0,0x3
ffffffffc0204e3c:	b9050513          	addi	a0,a0,-1136 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0204e40:	e3efb0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0204e44 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204e44:	7179                	addi	sp,sp,-48
ffffffffc0204e46:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204e48:	000ca917          	auipc	s2,0xca
ffffffffc0204e4c:	16090913          	addi	s2,s2,352 # ffffffffc02cefa8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204e50:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204e52:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204e56:	f406                	sd	ra,40(sp)
ffffffffc0204e58:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204e5a:	02a48863          	beq	s1,a0,ffffffffc0204e8a <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e5e:	100027f3          	csrr	a5,sstatus
ffffffffc0204e62:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204e64:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e66:	ef9d                	bnez	a5,ffffffffc0204ea4 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204e68:	755c                	ld	a5,168(a0)
ffffffffc0204e6a:	577d                	li	a4,-1
ffffffffc0204e6c:	177e                	slli	a4,a4,0x3f
ffffffffc0204e6e:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204e70:	00a93023          	sd	a0,0(s2)
ffffffffc0204e74:	8fd9                	or	a5,a5,a4
ffffffffc0204e76:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204e7a:	03050593          	addi	a1,a0,48
ffffffffc0204e7e:	03048513          	addi	a0,s1,48
ffffffffc0204e82:	0ae010ef          	jal	ra,ffffffffc0205f30 <switch_to>
    if (flag) {
ffffffffc0204e86:	00099863          	bnez	s3,ffffffffc0204e96 <proc_run+0x52>
}
ffffffffc0204e8a:	70a2                	ld	ra,40(sp)
ffffffffc0204e8c:	7482                	ld	s1,32(sp)
ffffffffc0204e8e:	6962                	ld	s2,24(sp)
ffffffffc0204e90:	69c2                	ld	s3,16(sp)
ffffffffc0204e92:	6145                	addi	sp,sp,48
ffffffffc0204e94:	8082                	ret
ffffffffc0204e96:	70a2                	ld	ra,40(sp)
ffffffffc0204e98:	7482                	ld	s1,32(sp)
ffffffffc0204e9a:	6962                	ld	s2,24(sp)
ffffffffc0204e9c:	69c2                	ld	s3,16(sp)
ffffffffc0204e9e:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204ea0:	f9afb06f          	j	ffffffffc020063a <intr_enable>
ffffffffc0204ea4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204ea6:	f9afb0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0204eaa:	6522                	ld	a0,8(sp)
ffffffffc0204eac:	4985                	li	s3,1
ffffffffc0204eae:	bf6d                	j	ffffffffc0204e68 <proc_run+0x24>

ffffffffc0204eb0 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204eb0:	7119                	addi	sp,sp,-128
ffffffffc0204eb2:	f4a6                	sd	s1,104(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204eb4:	000ca497          	auipc	s1,0xca
ffffffffc0204eb8:	10c48493          	addi	s1,s1,268 # ffffffffc02cefc0 <nr_process>
ffffffffc0204ebc:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204ebe:	fc86                	sd	ra,120(sp)
ffffffffc0204ec0:	f8a2                	sd	s0,112(sp)
ffffffffc0204ec2:	f0ca                	sd	s2,96(sp)
ffffffffc0204ec4:	ecce                	sd	s3,88(sp)
ffffffffc0204ec6:	e8d2                	sd	s4,80(sp)
ffffffffc0204ec8:	e4d6                	sd	s5,72(sp)
ffffffffc0204eca:	e0da                	sd	s6,64(sp)
ffffffffc0204ecc:	fc5e                	sd	s7,56(sp)
ffffffffc0204ece:	f862                	sd	s8,48(sp)
ffffffffc0204ed0:	f466                	sd	s9,40(sp)
ffffffffc0204ed2:	f06a                	sd	s10,32(sp)
ffffffffc0204ed4:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204ed6:	6785                	lui	a5,0x1
ffffffffc0204ed8:	34f75c63          	bge	a4,a5,ffffffffc0205230 <do_fork+0x380>
	 if ((proc = alloc_proc()) == NULL) {
ffffffffc0204edc:	89aa                	mv	s3,a0
ffffffffc0204ede:	892e                	mv	s2,a1
ffffffffc0204ee0:	8432                	mv	s0,a2
ffffffffc0204ee2:	defff0ef          	jal	ra,ffffffffc0204cd0 <alloc_proc>
ffffffffc0204ee6:	3e050763          	beqz	a0,ffffffffc02052d4 <do_fork+0x424>
	   proc = alloc_proc();
ffffffffc0204eea:	de7ff0ef          	jal	ra,ffffffffc0204cd0 <alloc_proc>
    proc->parent = current;
ffffffffc0204eee:	000caa17          	auipc	s4,0xca
ffffffffc0204ef2:	0baa0a13          	addi	s4,s4,186 # ffffffffc02cefa8 <current>
ffffffffc0204ef6:	000a3783          	ld	a5,0(s4)
	   proc = alloc_proc();
ffffffffc0204efa:	8c2a                	mv	s8,a0
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204efc:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8e7c>
    proc->parent = current;
ffffffffc0204f00:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204f02:	36071563          	bnez	a4,ffffffffc020526c <do_fork+0x3bc>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f06:	4509                	li	a0,2
ffffffffc0204f08:	dcdfc0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
    if (page != NULL) {
ffffffffc0204f0c:	30050063          	beqz	a0,ffffffffc020520c <do_fork+0x35c>
    return page - pages + nbase;
ffffffffc0204f10:	000caa97          	auipc	s5,0xca
ffffffffc0204f14:	058a8a93          	addi	s5,s5,88 # ffffffffc02cef68 <pages>
ffffffffc0204f18:	000ab683          	ld	a3,0(s5)
ffffffffc0204f1c:	00005b17          	auipc	s6,0x5
ffffffffc0204f20:	b54b0b13          	addi	s6,s6,-1196 # ffffffffc0209a70 <nbase>
ffffffffc0204f24:	000b3703          	ld	a4,0(s6)
ffffffffc0204f28:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204f2c:	000cab97          	auipc	s7,0xca
ffffffffc0204f30:	034b8b93          	addi	s7,s7,52 # ffffffffc02cef60 <npage>
    return page - pages + nbase;
ffffffffc0204f34:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f36:	5dfd                	li	s11,-1
ffffffffc0204f38:	000bb783          	ld	a5,0(s7)
    return page - pages + nbase;
ffffffffc0204f3c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204f3e:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204f42:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f46:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f48:	34f67e63          	bgeu	a2,a5,ffffffffc02052a4 <do_fork+0x3f4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204f4c:	000a3603          	ld	a2,0(s4)
ffffffffc0204f50:	000caa17          	auipc	s4,0xca
ffffffffc0204f54:	028a0a13          	addi	s4,s4,40 # ffffffffc02cef78 <va_pa_offset>
ffffffffc0204f58:	000a3783          	ld	a5,0(s4)
ffffffffc0204f5c:	02863d03          	ld	s10,40(a2)
ffffffffc0204f60:	e43a                	sd	a4,8(sp)
ffffffffc0204f62:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204f64:	00dc3823          	sd	a3,16(s8)
    if (oldmm == NULL) {
ffffffffc0204f68:	020d0a63          	beqz	s10,ffffffffc0204f9c <do_fork+0xec>
    if (clone_flags & CLONE_VM) {
ffffffffc0204f6c:	1009f993          	andi	s3,s3,256
ffffffffc0204f70:	1c098f63          	beqz	s3,ffffffffc020514e <do_fork+0x29e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204f74:	030d2703          	lw	a4,48(s10) # fffffffffff80030 <end+0x3fcb1058>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f78:	018d3783          	ld	a5,24(s10)
ffffffffc0204f7c:	c02006b7          	lui	a3,0xc0200
ffffffffc0204f80:	2705                	addiw	a4,a4,1
ffffffffc0204f82:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204f86:	03ac3423          	sd	s10,40(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f8a:	2cd7e463          	bltu	a5,a3,ffffffffc0205252 <do_fork+0x3a2>
ffffffffc0204f8e:	000a3703          	ld	a4,0(s4)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f92:	010c3683          	ld	a3,16(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f96:	8f99                	sub	a5,a5,a4
ffffffffc0204f98:	0afc3423          	sd	a5,168(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f9c:	6789                	lui	a5,0x2
ffffffffc0204f9e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8088>
ffffffffc0204fa2:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204fa4:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fa6:	0adc3023          	sd	a3,160(s8)
    *(proc->tf) = *tf;
ffffffffc0204faa:	87b6                	mv	a5,a3
ffffffffc0204fac:	12040893          	addi	a7,s0,288
ffffffffc0204fb0:	00063803          	ld	a6,0(a2)
ffffffffc0204fb4:	6608                	ld	a0,8(a2)
ffffffffc0204fb6:	6a0c                	ld	a1,16(a2)
ffffffffc0204fb8:	6e18                	ld	a4,24(a2)
ffffffffc0204fba:	0107b023          	sd	a6,0(a5)
ffffffffc0204fbe:	e788                	sd	a0,8(a5)
ffffffffc0204fc0:	eb8c                	sd	a1,16(a5)
ffffffffc0204fc2:	ef98                	sd	a4,24(a5)
ffffffffc0204fc4:	02060613          	addi	a2,a2,32
ffffffffc0204fc8:	02078793          	addi	a5,a5,32
ffffffffc0204fcc:	ff1612e3          	bne	a2,a7,ffffffffc0204fb0 <do_fork+0x100>
    proc->tf->gpr.a0 = 0;
ffffffffc0204fd0:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204fd4:	14090863          	beqz	s2,ffffffffc0205124 <do_fork+0x274>
ffffffffc0204fd8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204fdc:	00000797          	auipc	a5,0x0
ffffffffc0204fe0:	d6678793          	addi	a5,a5,-666 # ffffffffc0204d42 <forkret>
ffffffffc0204fe4:	02fc3823          	sd	a5,48(s8)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204fe8:	02dc3c23          	sd	a3,56(s8)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204fec:	100027f3          	csrr	a5,sstatus
ffffffffc0204ff0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ff2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ff4:	14079963          	bnez	a5,ffffffffc0205146 <do_fork+0x296>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ff8:	000bf817          	auipc	a6,0xbf
ffffffffc0204ffc:	a4080813          	addi	a6,a6,-1472 # ffffffffc02c3a38 <last_pid.1>
ffffffffc0205000:	00082783          	lw	a5,0(a6)
ffffffffc0205004:	6709                	lui	a4,0x2
ffffffffc0205006:	0017851b          	addiw	a0,a5,1
ffffffffc020500a:	00a82023          	sw	a0,0(a6)
ffffffffc020500e:	0ae55463          	bge	a0,a4,ffffffffc02050b6 <do_fork+0x206>
    if (last_pid >= next_safe) {
ffffffffc0205012:	000bf317          	auipc	t1,0xbf
ffffffffc0205016:	a2a30313          	addi	t1,t1,-1494 # ffffffffc02c3a3c <next_safe.0>
ffffffffc020501a:	00032783          	lw	a5,0(t1)
ffffffffc020501e:	000ca417          	auipc	s0,0xca
ffffffffc0205022:	eda40413          	addi	s0,s0,-294 # ffffffffc02ceef8 <proc_list>
ffffffffc0205026:	0af55063          	bge	a0,a5,ffffffffc02050c6 <do_fork+0x216>
        proc->pid = get_pid();
ffffffffc020502a:	00ac2223          	sw	a0,4(s8)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020502e:	45a9                	li	a1,10
ffffffffc0205030:	2501                	sext.w	a0,a0
ffffffffc0205032:	738010ef          	jal	ra,ffffffffc020676a <hash32>
ffffffffc0205036:	02051793          	slli	a5,a0,0x20
ffffffffc020503a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020503e:	000c6797          	auipc	a5,0xc6
ffffffffc0205042:	eba78793          	addi	a5,a5,-326 # ffffffffc02caef8 <hash_list>
ffffffffc0205046:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205048:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020504a:	020c3683          	ld	a3,32(s8)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020504e:	0d8c0793          	addi	a5,s8,216
    prev->next = next->prev = elm;
ffffffffc0205052:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205054:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0205056:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205058:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020505a:	0c8c0793          	addi	a5,s8,200
    elm->next = next;
ffffffffc020505e:	0ebc3023          	sd	a1,224(s8)
    elm->prev = prev;
ffffffffc0205062:	0cac3c23          	sd	a0,216(s8)
    prev->next = next->prev = elm;
ffffffffc0205066:	e21c                	sd	a5,0(a2)
ffffffffc0205068:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc020506a:	0ccc3823          	sd	a2,208(s8)
    elm->prev = prev;
ffffffffc020506e:	0c8c3423          	sd	s0,200(s8)
    proc->yptr = NULL;
ffffffffc0205072:	0e0c3c23          	sd	zero,248(s8)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205076:	10ec3023          	sd	a4,256(s8)
ffffffffc020507a:	c319                	beqz	a4,ffffffffc0205080 <do_fork+0x1d0>
        proc->optr->yptr = proc;
ffffffffc020507c:	0f873c23          	sd	s8,248(a4) # 20f8 <_binary_obj___user_faultread_out_size-0x7e70>
    nr_process ++;
ffffffffc0205080:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc0205082:	0f86b823          	sd	s8,240(a3)
    nr_process ++;
ffffffffc0205086:	2785                	addiw	a5,a5,1
ffffffffc0205088:	c09c                	sw	a5,0(s1)
    if (flag) {
ffffffffc020508a:	18091663          	bnez	s2,ffffffffc0205216 <do_fork+0x366>
		wakeup_proc(proc);
ffffffffc020508e:	8562                	mv	a0,s8
ffffffffc0205090:	468010ef          	jal	ra,ffffffffc02064f8 <wakeup_proc>
    	ret = proc->pid;
ffffffffc0205094:	004c2503          	lw	a0,4(s8)
}
ffffffffc0205098:	70e6                	ld	ra,120(sp)
ffffffffc020509a:	7446                	ld	s0,112(sp)
ffffffffc020509c:	74a6                	ld	s1,104(sp)
ffffffffc020509e:	7906                	ld	s2,96(sp)
ffffffffc02050a0:	69e6                	ld	s3,88(sp)
ffffffffc02050a2:	6a46                	ld	s4,80(sp)
ffffffffc02050a4:	6aa6                	ld	s5,72(sp)
ffffffffc02050a6:	6b06                	ld	s6,64(sp)
ffffffffc02050a8:	7be2                	ld	s7,56(sp)
ffffffffc02050aa:	7c42                	ld	s8,48(sp)
ffffffffc02050ac:	7ca2                	ld	s9,40(sp)
ffffffffc02050ae:	7d02                	ld	s10,32(sp)
ffffffffc02050b0:	6de2                	ld	s11,24(sp)
ffffffffc02050b2:	6109                	addi	sp,sp,128
ffffffffc02050b4:	8082                	ret
        last_pid = 1;
ffffffffc02050b6:	4785                	li	a5,1
ffffffffc02050b8:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02050bc:	4505                	li	a0,1
ffffffffc02050be:	000bf317          	auipc	t1,0xbf
ffffffffc02050c2:	97e30313          	addi	t1,t1,-1666 # ffffffffc02c3a3c <next_safe.0>
    return listelm->next;
ffffffffc02050c6:	000ca417          	auipc	s0,0xca
ffffffffc02050ca:	e3240413          	addi	s0,s0,-462 # ffffffffc02ceef8 <proc_list>
ffffffffc02050ce:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02050d2:	6789                	lui	a5,0x2
ffffffffc02050d4:	00f32023          	sw	a5,0(t1)
ffffffffc02050d8:	86aa                	mv	a3,a0
ffffffffc02050da:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02050dc:	6e89                	lui	t4,0x2
ffffffffc02050de:	148e0463          	beq	t3,s0,ffffffffc0205226 <do_fork+0x376>
ffffffffc02050e2:	88ae                	mv	a7,a1
ffffffffc02050e4:	87f2                	mv	a5,t3
ffffffffc02050e6:	6609                	lui	a2,0x2
ffffffffc02050e8:	a811                	j	ffffffffc02050fc <do_fork+0x24c>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02050ea:	00e6d663          	bge	a3,a4,ffffffffc02050f6 <do_fork+0x246>
ffffffffc02050ee:	00c75463          	bge	a4,a2,ffffffffc02050f6 <do_fork+0x246>
ffffffffc02050f2:	863a                	mv	a2,a4
ffffffffc02050f4:	4885                	li	a7,1
ffffffffc02050f6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02050f8:	00878d63          	beq	a5,s0,ffffffffc0205112 <do_fork+0x262>
            if (proc->pid == last_pid) {
ffffffffc02050fc:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x802c>
ffffffffc0205100:	fee695e3          	bne	a3,a4,ffffffffc02050ea <do_fork+0x23a>
                if (++ last_pid >= next_safe) {
ffffffffc0205104:	2685                	addiw	a3,a3,1
ffffffffc0205106:	10c6db63          	bge	a3,a2,ffffffffc020521c <do_fork+0x36c>
ffffffffc020510a:	679c                	ld	a5,8(a5)
ffffffffc020510c:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020510e:	fe8797e3          	bne	a5,s0,ffffffffc02050fc <do_fork+0x24c>
ffffffffc0205112:	c581                	beqz	a1,ffffffffc020511a <do_fork+0x26a>
ffffffffc0205114:	00d82023          	sw	a3,0(a6)
ffffffffc0205118:	8536                	mv	a0,a3
ffffffffc020511a:	f00888e3          	beqz	a7,ffffffffc020502a <do_fork+0x17a>
ffffffffc020511e:	00c32023          	sw	a2,0(t1)
ffffffffc0205122:	b721                	j	ffffffffc020502a <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205124:	8936                	mv	s2,a3
ffffffffc0205126:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020512a:	00000797          	auipc	a5,0x0
ffffffffc020512e:	c1878793          	addi	a5,a5,-1000 # ffffffffc0204d42 <forkret>
ffffffffc0205132:	02fc3823          	sd	a5,48(s8)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205136:	02dc3c23          	sd	a3,56(s8)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020513a:	100027f3          	csrr	a5,sstatus
ffffffffc020513e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205140:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205142:	ea078be3          	beqz	a5,ffffffffc0204ff8 <do_fork+0x148>
        intr_disable();
ffffffffc0205146:	cfafb0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc020514a:	4905                	li	s2,1
ffffffffc020514c:	b575                	j	ffffffffc0204ff8 <do_fork+0x148>
    if ((mm = mm_create()) == NULL) {
ffffffffc020514e:	fb7fe0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0205152:	8caa                	mv	s9,a0
ffffffffc0205154:	c159                	beqz	a0,ffffffffc02051da <do_fork+0x32a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205156:	4505                	li	a0,1
ffffffffc0205158:	b7dfc0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc020515c:	cd25                	beqz	a0,ffffffffc02051d4 <do_fork+0x324>
    return page - pages + nbase;
ffffffffc020515e:	000ab683          	ld	a3,0(s5)
ffffffffc0205162:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205164:	000bb783          	ld	a5,0(s7)
    return page - pages + nbase;
ffffffffc0205168:	40d506b3          	sub	a3,a0,a3
ffffffffc020516c:	8699                	srai	a3,a3,0x6
ffffffffc020516e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0205170:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0205174:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205176:	12fdf763          	bgeu	s11,a5,ffffffffc02052a4 <do_fork+0x3f4>
ffffffffc020517a:	000a3983          	ld	s3,0(s4)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020517e:	6605                	lui	a2,0x1
ffffffffc0205180:	000ca597          	auipc	a1,0xca
ffffffffc0205184:	dd85b583          	ld	a1,-552(a1) # ffffffffc02cef58 <boot_pgdir>
ffffffffc0205188:	99b6                	add	s3,s3,a3
ffffffffc020518a:	854e                	mv	a0,s3
ffffffffc020518c:	271010ef          	jal	ra,ffffffffc0206bfc <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205190:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0205194:	013cbc23          	sd	s3,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205198:	4785                	li	a5,1
ffffffffc020519a:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020519e:	8b85                	andi	a5,a5,1
ffffffffc02051a0:	4985                	li	s3,1
ffffffffc02051a2:	c799                	beqz	a5,ffffffffc02051b0 <do_fork+0x300>
        schedule();
ffffffffc02051a4:	406010ef          	jal	ra,ffffffffc02065aa <schedule>
ffffffffc02051a8:	413db7af          	amoor.d	a5,s3,(s11)
    while (!try_lock(lock)) {
ffffffffc02051ac:	8b85                	andi	a5,a5,1
ffffffffc02051ae:	fbfd                	bnez	a5,ffffffffc02051a4 <do_fork+0x2f4>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051b0:	85ea                	mv	a1,s10
ffffffffc02051b2:	8566                	mv	a0,s9
ffffffffc02051b4:	9d8ff0ef          	jal	ra,ffffffffc020438c <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051b8:	57f9                	li	a5,-2
ffffffffc02051ba:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02051be:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02051c0:	c7f1                	beqz	a5,ffffffffc020528c <do_fork+0x3dc>
good_mm:
ffffffffc02051c2:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc02051c4:	da0508e3          	beqz	a0,ffffffffc0204f74 <do_fork+0xc4>
    exit_mmap(mm);
ffffffffc02051c8:	8566                	mv	a0,s9
ffffffffc02051ca:	a5cff0ef          	jal	ra,ffffffffc0204426 <exit_mmap>
    put_pgdir(mm);
ffffffffc02051ce:	8566                	mv	a0,s9
ffffffffc02051d0:	bffff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc02051d4:	8566                	mv	a0,s9
ffffffffc02051d6:	8b4ff0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02051da:	010c3683          	ld	a3,16(s8)
    return pa2page(PADDR(kva));
ffffffffc02051de:	c02007b7          	lui	a5,0xc0200
ffffffffc02051e2:	0cf6ed63          	bltu	a3,a5,ffffffffc02052bc <do_fork+0x40c>
ffffffffc02051e6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02051ea:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02051ee:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02051f2:	83b1                	srli	a5,a5,0xc
ffffffffc02051f4:	04e7f363          	bgeu	a5,a4,ffffffffc020523a <do_fork+0x38a>
    return &pages[PPN(pa) - nbase];
ffffffffc02051f8:	000b3703          	ld	a4,0(s6)
ffffffffc02051fc:	000ab503          	ld	a0,0(s5)
ffffffffc0205200:	4589                	li	a1,2
ffffffffc0205202:	8f99                	sub	a5,a5,a4
ffffffffc0205204:	079a                	slli	a5,a5,0x6
ffffffffc0205206:	953e                	add	a0,a0,a5
ffffffffc0205208:	b5ffc0ef          	jal	ra,ffffffffc0201d66 <free_pages>
    kfree(proc);
ffffffffc020520c:	8562                	mv	a0,s8
ffffffffc020520e:	999fc0ef          	jal	ra,ffffffffc0201ba6 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205212:	5571                	li	a0,-4
    return ret;
ffffffffc0205214:	b551                	j	ffffffffc0205098 <do_fork+0x1e8>
        intr_enable();
ffffffffc0205216:	c24fb0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc020521a:	bd95                	j	ffffffffc020508e <do_fork+0x1de>
                    if (last_pid >= MAX_PID) {
ffffffffc020521c:	01d6c363          	blt	a3,t4,ffffffffc0205222 <do_fork+0x372>
                        last_pid = 1;
ffffffffc0205220:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205222:	4585                	li	a1,1
ffffffffc0205224:	bd6d                	j	ffffffffc02050de <do_fork+0x22e>
ffffffffc0205226:	c599                	beqz	a1,ffffffffc0205234 <do_fork+0x384>
ffffffffc0205228:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020522c:	8536                	mv	a0,a3
ffffffffc020522e:	bbf5                	j	ffffffffc020502a <do_fork+0x17a>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205230:	556d                	li	a0,-5
ffffffffc0205232:	b59d                	j	ffffffffc0205098 <do_fork+0x1e8>
    return last_pid;
ffffffffc0205234:	00082503          	lw	a0,0(a6)
ffffffffc0205238:	bbcd                	j	ffffffffc020502a <do_fork+0x17a>
        panic("pa2page called with invalid pa");
ffffffffc020523a:	00003617          	auipc	a2,0x3
ffffffffc020523e:	83660613          	addi	a2,a2,-1994 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0205242:	06200593          	li	a1,98
ffffffffc0205246:	00002517          	auipc	a0,0x2
ffffffffc020524a:	78250513          	addi	a0,a0,1922 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc020524e:	a30fb0ef          	jal	ra,ffffffffc020047e <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205252:	86be                	mv	a3,a5
ffffffffc0205254:	00002617          	auipc	a2,0x2
ffffffffc0205258:	7f460613          	addi	a2,a2,2036 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc020525c:	17e00593          	li	a1,382
ffffffffc0205260:	00004517          	auipc	a0,0x4
ffffffffc0205264:	81050513          	addi	a0,a0,-2032 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205268:	a16fb0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc020526c:	00004697          	auipc	a3,0x4
ffffffffc0205270:	81c68693          	addi	a3,a3,-2020 # ffffffffc0208a88 <default_pmm_manager+0x1120>
ffffffffc0205274:	00002617          	auipc	a2,0x2
ffffffffc0205278:	05c60613          	addi	a2,a2,92 # ffffffffc02072d0 <commands+0x450>
ffffffffc020527c:	1cb00593          	li	a1,459
ffffffffc0205280:	00003517          	auipc	a0,0x3
ffffffffc0205284:	7f050513          	addi	a0,a0,2032 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205288:	9f6fb0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("Unlock failed.\n");
ffffffffc020528c:	00004617          	auipc	a2,0x4
ffffffffc0205290:	81c60613          	addi	a2,a2,-2020 # ffffffffc0208aa8 <default_pmm_manager+0x1140>
ffffffffc0205294:	03200593          	li	a1,50
ffffffffc0205298:	00004517          	auipc	a0,0x4
ffffffffc020529c:	82050513          	addi	a0,a0,-2016 # ffffffffc0208ab8 <default_pmm_manager+0x1150>
ffffffffc02052a0:	9defb0ef          	jal	ra,ffffffffc020047e <__panic>
    return KADDR(page2pa(page));
ffffffffc02052a4:	00002617          	auipc	a2,0x2
ffffffffc02052a8:	6fc60613          	addi	a2,a2,1788 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc02052ac:	06900593          	li	a1,105
ffffffffc02052b0:	00002517          	auipc	a0,0x2
ffffffffc02052b4:	71850513          	addi	a0,a0,1816 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02052b8:	9c6fb0ef          	jal	ra,ffffffffc020047e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052bc:	00002617          	auipc	a2,0x2
ffffffffc02052c0:	78c60613          	addi	a2,a2,1932 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc02052c4:	06e00593          	li	a1,110
ffffffffc02052c8:	00002517          	auipc	a0,0x2
ffffffffc02052cc:	70050513          	addi	a0,a0,1792 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc02052d0:	9aefb0ef          	jal	ra,ffffffffc020047e <__panic>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052d4:	01003783          	ld	a5,16(zero) # 10 <_binary_obj___user_faultread_out_size-0x9f58>
ffffffffc02052d8:	9002                	ebreak

ffffffffc02052da <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02052da:	7129                	addi	sp,sp,-320
ffffffffc02052dc:	fa22                	sd	s0,304(sp)
ffffffffc02052de:	f626                	sd	s1,296(sp)
ffffffffc02052e0:	f24a                	sd	s2,288(sp)
ffffffffc02052e2:	84ae                	mv	s1,a1
ffffffffc02052e4:	892a                	mv	s2,a0
ffffffffc02052e6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02052e8:	4581                	li	a1,0
ffffffffc02052ea:	12000613          	li	a2,288
ffffffffc02052ee:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02052f0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02052f2:	0f9010ef          	jal	ra,ffffffffc0206bea <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02052f6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02052f8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02052fa:	100027f3          	csrr	a5,sstatus
ffffffffc02052fe:	edd7f793          	andi	a5,a5,-291
ffffffffc0205302:	1207e793          	ori	a5,a5,288
ffffffffc0205306:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205308:	860a                	mv	a2,sp
ffffffffc020530a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020530e:	00000797          	auipc	a5,0x0
ffffffffc0205312:	9ba78793          	addi	a5,a5,-1606 # ffffffffc0204cc8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205316:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205318:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020531a:	b97ff0ef          	jal	ra,ffffffffc0204eb0 <do_fork>
}
ffffffffc020531e:	70f2                	ld	ra,312(sp)
ffffffffc0205320:	7452                	ld	s0,304(sp)
ffffffffc0205322:	74b2                	ld	s1,296(sp)
ffffffffc0205324:	7912                	ld	s2,288(sp)
ffffffffc0205326:	6131                	addi	sp,sp,320
ffffffffc0205328:	8082                	ret

ffffffffc020532a <do_exit>:
do_exit(int error_code) {
ffffffffc020532a:	7179                	addi	sp,sp,-48
ffffffffc020532c:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020532e:	000ca417          	auipc	s0,0xca
ffffffffc0205332:	c7a40413          	addi	s0,s0,-902 # ffffffffc02cefa8 <current>
ffffffffc0205336:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205338:	f406                	sd	ra,40(sp)
ffffffffc020533a:	ec26                	sd	s1,24(sp)
ffffffffc020533c:	e84a                	sd	s2,16(sp)
ffffffffc020533e:	e44e                	sd	s3,8(sp)
ffffffffc0205340:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205342:	000ca717          	auipc	a4,0xca
ffffffffc0205346:	c6e73703          	ld	a4,-914(a4) # ffffffffc02cefb0 <idleproc>
ffffffffc020534a:	0ce78c63          	beq	a5,a4,ffffffffc0205422 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020534e:	000ca497          	auipc	s1,0xca
ffffffffc0205352:	c6a48493          	addi	s1,s1,-918 # ffffffffc02cefb8 <initproc>
ffffffffc0205356:	6098                	ld	a4,0(s1)
ffffffffc0205358:	0ee78b63          	beq	a5,a4,ffffffffc020544e <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020535c:	0287b983          	ld	s3,40(a5)
ffffffffc0205360:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205362:	02098663          	beqz	s3,ffffffffc020538e <do_exit+0x64>
ffffffffc0205366:	000ca797          	auipc	a5,0xca
ffffffffc020536a:	bea7b783          	ld	a5,-1046(a5) # ffffffffc02cef50 <boot_cr3>
ffffffffc020536e:	577d                	li	a4,-1
ffffffffc0205370:	177e                	slli	a4,a4,0x3f
ffffffffc0205372:	83b1                	srli	a5,a5,0xc
ffffffffc0205374:	8fd9                	or	a5,a5,a4
ffffffffc0205376:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020537a:	0309a783          	lw	a5,48(s3)
ffffffffc020537e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205382:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205386:	cb55                	beqz	a4,ffffffffc020543a <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205388:	601c                	ld	a5,0(s0)
ffffffffc020538a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020538e:	601c                	ld	a5,0(s0)
ffffffffc0205390:	470d                	li	a4,3
ffffffffc0205392:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205394:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205398:	100027f3          	csrr	a5,sstatus
ffffffffc020539c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020539e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053a0:	e3f9                	bnez	a5,ffffffffc0205466 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02053a2:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053a4:	800007b7          	lui	a5,0x80000
ffffffffc02053a8:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02053aa:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053ac:	0ec52703          	lw	a4,236(a0)
ffffffffc02053b0:	0af70f63          	beq	a4,a5,ffffffffc020546e <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02053b4:	6018                	ld	a4,0(s0)
ffffffffc02053b6:	7b7c                	ld	a5,240(a4)
ffffffffc02053b8:	c3a1                	beqz	a5,ffffffffc02053f8 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053ba:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053be:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053c0:	0985                	addi	s3,s3,1
ffffffffc02053c2:	a021                	j	ffffffffc02053ca <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02053c4:	6018                	ld	a4,0(s0)
ffffffffc02053c6:	7b7c                	ld	a5,240(a4)
ffffffffc02053c8:	cb85                	beqz	a5,ffffffffc02053f8 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02053ca:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff39c8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053ce:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02053d0:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053d2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02053d4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053d8:	10e7b023          	sd	a4,256(a5)
ffffffffc02053dc:	c311                	beqz	a4,ffffffffc02053e0 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02053de:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053e0:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02053e2:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02053e4:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053e6:	fd271fe3          	bne	a4,s2,ffffffffc02053c4 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053ea:	0ec52783          	lw	a5,236(a0)
ffffffffc02053ee:	fd379be3          	bne	a5,s3,ffffffffc02053c4 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02053f2:	106010ef          	jal	ra,ffffffffc02064f8 <wakeup_proc>
ffffffffc02053f6:	b7f9                	j	ffffffffc02053c4 <do_exit+0x9a>
    if (flag) {
ffffffffc02053f8:	020a1263          	bnez	s4,ffffffffc020541c <do_exit+0xf2>
    schedule();
ffffffffc02053fc:	1ae010ef          	jal	ra,ffffffffc02065aa <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205400:	601c                	ld	a5,0(s0)
ffffffffc0205402:	00003617          	auipc	a2,0x3
ffffffffc0205406:	6ee60613          	addi	a2,a2,1774 # ffffffffc0208af0 <default_pmm_manager+0x1188>
ffffffffc020540a:	21a00593          	li	a1,538
ffffffffc020540e:	43d4                	lw	a3,4(a5)
ffffffffc0205410:	00003517          	auipc	a0,0x3
ffffffffc0205414:	66050513          	addi	a0,a0,1632 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205418:	866fb0ef          	jal	ra,ffffffffc020047e <__panic>
        intr_enable();
ffffffffc020541c:	a1efb0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc0205420:	bff1                	j	ffffffffc02053fc <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0205422:	00003617          	auipc	a2,0x3
ffffffffc0205426:	6ae60613          	addi	a2,a2,1710 # ffffffffc0208ad0 <default_pmm_manager+0x1168>
ffffffffc020542a:	1ee00593          	li	a1,494
ffffffffc020542e:	00003517          	auipc	a0,0x3
ffffffffc0205432:	64250513          	addi	a0,a0,1602 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205436:	848fb0ef          	jal	ra,ffffffffc020047e <__panic>
            exit_mmap(mm);
ffffffffc020543a:	854e                	mv	a0,s3
ffffffffc020543c:	febfe0ef          	jal	ra,ffffffffc0204426 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205440:	854e                	mv	a0,s3
ffffffffc0205442:	98dff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205446:	854e                	mv	a0,s3
ffffffffc0205448:	e43fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
ffffffffc020544c:	bf35                	j	ffffffffc0205388 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020544e:	00003617          	auipc	a2,0x3
ffffffffc0205452:	69260613          	addi	a2,a2,1682 # ffffffffc0208ae0 <default_pmm_manager+0x1178>
ffffffffc0205456:	1f100593          	li	a1,497
ffffffffc020545a:	00003517          	auipc	a0,0x3
ffffffffc020545e:	61650513          	addi	a0,a0,1558 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205462:	81cfb0ef          	jal	ra,ffffffffc020047e <__panic>
        intr_disable();
ffffffffc0205466:	9dafb0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc020546a:	4a05                	li	s4,1
ffffffffc020546c:	bf1d                	j	ffffffffc02053a2 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020546e:	08a010ef          	jal	ra,ffffffffc02064f8 <wakeup_proc>
ffffffffc0205472:	b789                	j	ffffffffc02053b4 <do_exit+0x8a>

ffffffffc0205474 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205474:	715d                	addi	sp,sp,-80
ffffffffc0205476:	f84a                	sd	s2,48(sp)
ffffffffc0205478:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020547a:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020547e:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205480:	fc26                	sd	s1,56(sp)
ffffffffc0205482:	f052                	sd	s4,32(sp)
ffffffffc0205484:	ec56                	sd	s5,24(sp)
ffffffffc0205486:	e85a                	sd	s6,16(sp)
ffffffffc0205488:	e45e                	sd	s7,8(sp)
ffffffffc020548a:	e486                	sd	ra,72(sp)
ffffffffc020548c:	e0a2                	sd	s0,64(sp)
ffffffffc020548e:	84aa                	mv	s1,a0
ffffffffc0205490:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205492:	000cab97          	auipc	s7,0xca
ffffffffc0205496:	b16b8b93          	addi	s7,s7,-1258 # ffffffffc02cefa8 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020549a:	00050b1b          	sext.w	s6,a0
ffffffffc020549e:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02054a2:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02054a4:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02054a6:	ccbd                	beqz	s1,ffffffffc0205524 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054a8:	0359e863          	bltu	s3,s5,ffffffffc02054d8 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02054ac:	45a9                	li	a1,10
ffffffffc02054ae:	855a                	mv	a0,s6
ffffffffc02054b0:	2ba010ef          	jal	ra,ffffffffc020676a <hash32>
ffffffffc02054b4:	02051793          	slli	a5,a0,0x20
ffffffffc02054b8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02054bc:	000c6797          	auipc	a5,0xc6
ffffffffc02054c0:	a3c78793          	addi	a5,a5,-1476 # ffffffffc02caef8 <hash_list>
ffffffffc02054c4:	953e                	add	a0,a0,a5
ffffffffc02054c6:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02054c8:	a029                	j	ffffffffc02054d2 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02054ca:	f2c42783          	lw	a5,-212(s0)
ffffffffc02054ce:	02978163          	beq	a5,s1,ffffffffc02054f0 <do_wait.part.0+0x7c>
ffffffffc02054d2:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02054d4:	fe851be3          	bne	a0,s0,ffffffffc02054ca <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02054d8:	5579                	li	a0,-2
}
ffffffffc02054da:	60a6                	ld	ra,72(sp)
ffffffffc02054dc:	6406                	ld	s0,64(sp)
ffffffffc02054de:	74e2                	ld	s1,56(sp)
ffffffffc02054e0:	7942                	ld	s2,48(sp)
ffffffffc02054e2:	79a2                	ld	s3,40(sp)
ffffffffc02054e4:	7a02                	ld	s4,32(sp)
ffffffffc02054e6:	6ae2                	ld	s5,24(sp)
ffffffffc02054e8:	6b42                	ld	s6,16(sp)
ffffffffc02054ea:	6ba2                	ld	s7,8(sp)
ffffffffc02054ec:	6161                	addi	sp,sp,80
ffffffffc02054ee:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02054f0:	000bb683          	ld	a3,0(s7)
ffffffffc02054f4:	f4843783          	ld	a5,-184(s0)
ffffffffc02054f8:	fed790e3          	bne	a5,a3,ffffffffc02054d8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054fc:	f2842703          	lw	a4,-216(s0)
ffffffffc0205500:	478d                	li	a5,3
ffffffffc0205502:	0ef70b63          	beq	a4,a5,ffffffffc02055f8 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205506:	4785                	li	a5,1
ffffffffc0205508:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020550a:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020550e:	09c010ef          	jal	ra,ffffffffc02065aa <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205512:	000bb783          	ld	a5,0(s7)
ffffffffc0205516:	0b07a783          	lw	a5,176(a5)
ffffffffc020551a:	8b85                	andi	a5,a5,1
ffffffffc020551c:	d7c9                	beqz	a5,ffffffffc02054a6 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020551e:	555d                	li	a0,-9
ffffffffc0205520:	e0bff0ef          	jal	ra,ffffffffc020532a <do_exit>
        proc = current->cptr;
ffffffffc0205524:	000bb683          	ld	a3,0(s7)
ffffffffc0205528:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020552a:	d45d                	beqz	s0,ffffffffc02054d8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020552c:	470d                	li	a4,3
ffffffffc020552e:	a021                	j	ffffffffc0205536 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205530:	10043403          	ld	s0,256(s0)
ffffffffc0205534:	d869                	beqz	s0,ffffffffc0205506 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205536:	401c                	lw	a5,0(s0)
ffffffffc0205538:	fee79ce3          	bne	a5,a4,ffffffffc0205530 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc020553c:	000ca797          	auipc	a5,0xca
ffffffffc0205540:	a747b783          	ld	a5,-1420(a5) # ffffffffc02cefb0 <idleproc>
ffffffffc0205544:	0c878963          	beq	a5,s0,ffffffffc0205616 <do_wait.part.0+0x1a2>
ffffffffc0205548:	000ca797          	auipc	a5,0xca
ffffffffc020554c:	a707b783          	ld	a5,-1424(a5) # ffffffffc02cefb8 <initproc>
ffffffffc0205550:	0cf40363          	beq	s0,a5,ffffffffc0205616 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205554:	000a0663          	beqz	s4,ffffffffc0205560 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205558:	0e842783          	lw	a5,232(s0)
ffffffffc020555c:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205560:	100027f3          	csrr	a5,sstatus
ffffffffc0205564:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205566:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205568:	e7c1                	bnez	a5,ffffffffc02055f0 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020556a:	6c70                	ld	a2,216(s0)
ffffffffc020556c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020556e:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205572:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205574:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205576:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205578:	6470                	ld	a2,200(s0)
ffffffffc020557a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020557c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020557e:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205580:	c319                	beqz	a4,ffffffffc0205586 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205582:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205584:	7c7c                	ld	a5,248(s0)
ffffffffc0205586:	c3b5                	beqz	a5,ffffffffc02055ea <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205588:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020558c:	000ca717          	auipc	a4,0xca
ffffffffc0205590:	a3470713          	addi	a4,a4,-1484 # ffffffffc02cefc0 <nr_process>
ffffffffc0205594:	431c                	lw	a5,0(a4)
ffffffffc0205596:	37fd                	addiw	a5,a5,-1
ffffffffc0205598:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020559a:	e5a9                	bnez	a1,ffffffffc02055e4 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020559c:	6814                	ld	a3,16(s0)
ffffffffc020559e:	c02007b7          	lui	a5,0xc0200
ffffffffc02055a2:	04f6ee63          	bltu	a3,a5,ffffffffc02055fe <do_wait.part.0+0x18a>
ffffffffc02055a6:	000ca797          	auipc	a5,0xca
ffffffffc02055aa:	9d27b783          	ld	a5,-1582(a5) # ffffffffc02cef78 <va_pa_offset>
ffffffffc02055ae:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02055b0:	82b1                	srli	a3,a3,0xc
ffffffffc02055b2:	000ca797          	auipc	a5,0xca
ffffffffc02055b6:	9ae7b783          	ld	a5,-1618(a5) # ffffffffc02cef60 <npage>
ffffffffc02055ba:	06f6fa63          	bgeu	a3,a5,ffffffffc020562e <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02055be:	00004517          	auipc	a0,0x4
ffffffffc02055c2:	4b253503          	ld	a0,1202(a0) # ffffffffc0209a70 <nbase>
ffffffffc02055c6:	8e89                	sub	a3,a3,a0
ffffffffc02055c8:	069a                	slli	a3,a3,0x6
ffffffffc02055ca:	000ca517          	auipc	a0,0xca
ffffffffc02055ce:	99e53503          	ld	a0,-1634(a0) # ffffffffc02cef68 <pages>
ffffffffc02055d2:	9536                	add	a0,a0,a3
ffffffffc02055d4:	4589                	li	a1,2
ffffffffc02055d6:	f90fc0ef          	jal	ra,ffffffffc0201d66 <free_pages>
    kfree(proc);
ffffffffc02055da:	8522                	mv	a0,s0
ffffffffc02055dc:	dcafc0ef          	jal	ra,ffffffffc0201ba6 <kfree>
    return 0;
ffffffffc02055e0:	4501                	li	a0,0
ffffffffc02055e2:	bde5                	j	ffffffffc02054da <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02055e4:	856fb0ef          	jal	ra,ffffffffc020063a <intr_enable>
ffffffffc02055e8:	bf55                	j	ffffffffc020559c <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02055ea:	701c                	ld	a5,32(s0)
ffffffffc02055ec:	fbf8                	sd	a4,240(a5)
ffffffffc02055ee:	bf79                	j	ffffffffc020558c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02055f0:	850fb0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02055f4:	4585                	li	a1,1
ffffffffc02055f6:	bf95                	j	ffffffffc020556a <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02055f8:	f2840413          	addi	s0,s0,-216
ffffffffc02055fc:	b781                	j	ffffffffc020553c <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02055fe:	00002617          	auipc	a2,0x2
ffffffffc0205602:	44a60613          	addi	a2,a2,1098 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0205606:	06e00593          	li	a1,110
ffffffffc020560a:	00002517          	auipc	a0,0x2
ffffffffc020560e:	3be50513          	addi	a0,a0,958 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0205612:	e6dfa0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205616:	00003617          	auipc	a2,0x3
ffffffffc020561a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0208b10 <default_pmm_manager+0x11a8>
ffffffffc020561e:	31100593          	li	a1,785
ffffffffc0205622:	00003517          	auipc	a0,0x3
ffffffffc0205626:	44e50513          	addi	a0,a0,1102 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc020562a:	e55fa0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020562e:	00002617          	auipc	a2,0x2
ffffffffc0205632:	44260613          	addi	a2,a2,1090 # ffffffffc0207a70 <default_pmm_manager+0x108>
ffffffffc0205636:	06200593          	li	a1,98
ffffffffc020563a:	00002517          	auipc	a0,0x2
ffffffffc020563e:	38e50513          	addi	a0,a0,910 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0205642:	e3dfa0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0205646 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205646:	1141                	addi	sp,sp,-16
ffffffffc0205648:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020564a:	f5cfc0ef          	jal	ra,ffffffffc0201da6 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020564e:	ca4fc0ef          	jal	ra,ffffffffc0201af2 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205652:	4601                	li	a2,0
ffffffffc0205654:	4581                	li	a1,0
ffffffffc0205656:	fffff517          	auipc	a0,0xfffff
ffffffffc020565a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0204d50 <user_main>
ffffffffc020565e:	c7dff0ef          	jal	ra,ffffffffc02052da <kernel_thread>
    if (pid <= 0) {
ffffffffc0205662:	00a04563          	bgtz	a0,ffffffffc020566c <init_main+0x26>
ffffffffc0205666:	a071                	j	ffffffffc02056f2 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205668:	743000ef          	jal	ra,ffffffffc02065aa <schedule>
    if (code_store != NULL) {
ffffffffc020566c:	4581                	li	a1,0
ffffffffc020566e:	4501                	li	a0,0
ffffffffc0205670:	e05ff0ef          	jal	ra,ffffffffc0205474 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205674:	d975                	beqz	a0,ffffffffc0205668 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205676:	00003517          	auipc	a0,0x3
ffffffffc020567a:	4da50513          	addi	a0,a0,1242 # ffffffffc0208b50 <default_pmm_manager+0x11e8>
ffffffffc020567e:	b07fa0ef          	jal	ra,ffffffffc0200184 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205682:	000ca797          	auipc	a5,0xca
ffffffffc0205686:	9367b783          	ld	a5,-1738(a5) # ffffffffc02cefb8 <initproc>
ffffffffc020568a:	7bf8                	ld	a4,240(a5)
ffffffffc020568c:	e339                	bnez	a4,ffffffffc02056d2 <init_main+0x8c>
ffffffffc020568e:	7ff8                	ld	a4,248(a5)
ffffffffc0205690:	e329                	bnez	a4,ffffffffc02056d2 <init_main+0x8c>
ffffffffc0205692:	1007b703          	ld	a4,256(a5)
ffffffffc0205696:	ef15                	bnez	a4,ffffffffc02056d2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205698:	000ca697          	auipc	a3,0xca
ffffffffc020569c:	9286a683          	lw	a3,-1752(a3) # ffffffffc02cefc0 <nr_process>
ffffffffc02056a0:	4709                	li	a4,2
ffffffffc02056a2:	0ae69463          	bne	a3,a4,ffffffffc020574a <init_main+0x104>
    return listelm->next;
ffffffffc02056a6:	000ca697          	auipc	a3,0xca
ffffffffc02056aa:	85268693          	addi	a3,a3,-1966 # ffffffffc02ceef8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056ae:	6698                	ld	a4,8(a3)
ffffffffc02056b0:	0c878793          	addi	a5,a5,200
ffffffffc02056b4:	06f71b63          	bne	a4,a5,ffffffffc020572a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02056b8:	629c                	ld	a5,0(a3)
ffffffffc02056ba:	04f71863          	bne	a4,a5,ffffffffc020570a <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02056be:	00003517          	auipc	a0,0x3
ffffffffc02056c2:	57a50513          	addi	a0,a0,1402 # ffffffffc0208c38 <default_pmm_manager+0x12d0>
ffffffffc02056c6:	abffa0ef          	jal	ra,ffffffffc0200184 <cprintf>
    return 0;
}
ffffffffc02056ca:	60a2                	ld	ra,8(sp)
ffffffffc02056cc:	4501                	li	a0,0
ffffffffc02056ce:	0141                	addi	sp,sp,16
ffffffffc02056d0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056d2:	00003697          	auipc	a3,0x3
ffffffffc02056d6:	4a668693          	addi	a3,a3,1190 # ffffffffc0208b78 <default_pmm_manager+0x1210>
ffffffffc02056da:	00002617          	auipc	a2,0x2
ffffffffc02056de:	bf660613          	addi	a2,a2,-1034 # ffffffffc02072d0 <commands+0x450>
ffffffffc02056e2:	37500593          	li	a1,885
ffffffffc02056e6:	00003517          	auipc	a0,0x3
ffffffffc02056ea:	38a50513          	addi	a0,a0,906 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc02056ee:	d91fa0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("create user_main failed.\n");
ffffffffc02056f2:	00003617          	auipc	a2,0x3
ffffffffc02056f6:	43e60613          	addi	a2,a2,1086 # ffffffffc0208b30 <default_pmm_manager+0x11c8>
ffffffffc02056fa:	36d00593          	li	a1,877
ffffffffc02056fe:	00003517          	auipc	a0,0x3
ffffffffc0205702:	37250513          	addi	a0,a0,882 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205706:	d79fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020570a:	00003697          	auipc	a3,0x3
ffffffffc020570e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0208c08 <default_pmm_manager+0x12a0>
ffffffffc0205712:	00002617          	auipc	a2,0x2
ffffffffc0205716:	bbe60613          	addi	a2,a2,-1090 # ffffffffc02072d0 <commands+0x450>
ffffffffc020571a:	37800593          	li	a1,888
ffffffffc020571e:	00003517          	auipc	a0,0x3
ffffffffc0205722:	35250513          	addi	a0,a0,850 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205726:	d59fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020572a:	00003697          	auipc	a3,0x3
ffffffffc020572e:	4ae68693          	addi	a3,a3,1198 # ffffffffc0208bd8 <default_pmm_manager+0x1270>
ffffffffc0205732:	00002617          	auipc	a2,0x2
ffffffffc0205736:	b9e60613          	addi	a2,a2,-1122 # ffffffffc02072d0 <commands+0x450>
ffffffffc020573a:	37700593          	li	a1,887
ffffffffc020573e:	00003517          	auipc	a0,0x3
ffffffffc0205742:	33250513          	addi	a0,a0,818 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205746:	d39fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(nr_process == 2);
ffffffffc020574a:	00003697          	auipc	a3,0x3
ffffffffc020574e:	47e68693          	addi	a3,a3,1150 # ffffffffc0208bc8 <default_pmm_manager+0x1260>
ffffffffc0205752:	00002617          	auipc	a2,0x2
ffffffffc0205756:	b7e60613          	addi	a2,a2,-1154 # ffffffffc02072d0 <commands+0x450>
ffffffffc020575a:	37600593          	li	a1,886
ffffffffc020575e:	00003517          	auipc	a0,0x3
ffffffffc0205762:	31250513          	addi	a0,a0,786 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205766:	d19fa0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020576a <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020576a:	7171                	addi	sp,sp,-176
ffffffffc020576c:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020576e:	000cad97          	auipc	s11,0xca
ffffffffc0205772:	83ad8d93          	addi	s11,s11,-1990 # ffffffffc02cefa8 <current>
ffffffffc0205776:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020577a:	e54e                	sd	s3,136(sp)
ffffffffc020577c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020577e:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205782:	e94a                	sd	s2,144(sp)
ffffffffc0205784:	f4de                	sd	s7,104(sp)
ffffffffc0205786:	892a                	mv	s2,a0
ffffffffc0205788:	8bb2                	mv	s7,a2
ffffffffc020578a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020578c:	862e                	mv	a2,a1
ffffffffc020578e:	4681                	li	a3,0
ffffffffc0205790:	85aa                	mv	a1,a0
ffffffffc0205792:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205794:	f506                	sd	ra,168(sp)
ffffffffc0205796:	f122                	sd	s0,160(sp)
ffffffffc0205798:	e152                	sd	s4,128(sp)
ffffffffc020579a:	fcd6                	sd	s5,120(sp)
ffffffffc020579c:	f8da                	sd	s6,112(sp)
ffffffffc020579e:	f0e2                	sd	s8,96(sp)
ffffffffc02057a0:	ece6                	sd	s9,88(sp)
ffffffffc02057a2:	e8ea                	sd	s10,80(sp)
ffffffffc02057a4:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057a6:	b3aff0ef          	jal	ra,ffffffffc0204ae0 <user_mem_check>
ffffffffc02057aa:	40050863          	beqz	a0,ffffffffc0205bba <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02057ae:	4641                	li	a2,16
ffffffffc02057b0:	4581                	li	a1,0
ffffffffc02057b2:	1808                	addi	a0,sp,48
ffffffffc02057b4:	436010ef          	jal	ra,ffffffffc0206bea <memset>
    memcpy(local_name, name, len);
ffffffffc02057b8:	47bd                	li	a5,15
ffffffffc02057ba:	8626                	mv	a2,s1
ffffffffc02057bc:	1e97e063          	bltu	a5,s1,ffffffffc020599c <do_execve+0x232>
ffffffffc02057c0:	85ca                	mv	a1,s2
ffffffffc02057c2:	1808                	addi	a0,sp,48
ffffffffc02057c4:	438010ef          	jal	ra,ffffffffc0206bfc <memcpy>
    if (mm != NULL) {
ffffffffc02057c8:	1e098163          	beqz	s3,ffffffffc02059aa <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02057cc:	00003517          	auipc	a0,0x3
ffffffffc02057d0:	91450513          	addi	a0,a0,-1772 # ffffffffc02080e0 <default_pmm_manager+0x778>
ffffffffc02057d4:	9e9fa0ef          	jal	ra,ffffffffc02001bc <cputs>
ffffffffc02057d8:	000c9797          	auipc	a5,0xc9
ffffffffc02057dc:	7787b783          	ld	a5,1912(a5) # ffffffffc02cef50 <boot_cr3>
ffffffffc02057e0:	577d                	li	a4,-1
ffffffffc02057e2:	177e                	slli	a4,a4,0x3f
ffffffffc02057e4:	83b1                	srli	a5,a5,0xc
ffffffffc02057e6:	8fd9                	or	a5,a5,a4
ffffffffc02057e8:	18079073          	csrw	satp,a5
ffffffffc02057ec:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7f38>
ffffffffc02057f0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02057f4:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02057f8:	2c070263          	beqz	a4,ffffffffc0205abc <do_execve+0x352>
        current->mm = NULL;
ffffffffc02057fc:	000db783          	ld	a5,0(s11)
ffffffffc0205800:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205804:	901fe0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0205808:	84aa                	mv	s1,a0
ffffffffc020580a:	1c050b63          	beqz	a0,ffffffffc02059e0 <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020580e:	4505                	li	a0,1
ffffffffc0205810:	cc4fc0ef          	jal	ra,ffffffffc0201cd4 <alloc_pages>
ffffffffc0205814:	3a050763          	beqz	a0,ffffffffc0205bc2 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205818:	000c9c97          	auipc	s9,0xc9
ffffffffc020581c:	750c8c93          	addi	s9,s9,1872 # ffffffffc02cef68 <pages>
ffffffffc0205820:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205824:	000c9c17          	auipc	s8,0xc9
ffffffffc0205828:	73cc0c13          	addi	s8,s8,1852 # ffffffffc02cef60 <npage>
    return page - pages + nbase;
ffffffffc020582c:	00004717          	auipc	a4,0x4
ffffffffc0205830:	24473703          	ld	a4,580(a4) # ffffffffc0209a70 <nbase>
ffffffffc0205834:	40d506b3          	sub	a3,a0,a3
ffffffffc0205838:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020583a:	5afd                	li	s5,-1
ffffffffc020583c:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205840:	96ba                	add	a3,a3,a4
ffffffffc0205842:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205844:	00cad713          	srli	a4,s5,0xc
ffffffffc0205848:	ec3a                	sd	a4,24(sp)
ffffffffc020584a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020584c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020584e:	36f77e63          	bgeu	a4,a5,ffffffffc0205bca <do_execve+0x460>
ffffffffc0205852:	000c9b17          	auipc	s6,0xc9
ffffffffc0205856:	726b0b13          	addi	s6,s6,1830 # ffffffffc02cef78 <va_pa_offset>
ffffffffc020585a:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020585e:	6605                	lui	a2,0x1
ffffffffc0205860:	000c9597          	auipc	a1,0xc9
ffffffffc0205864:	6f85b583          	ld	a1,1784(a1) # ffffffffc02cef58 <boot_pgdir>
ffffffffc0205868:	9936                	add	s2,s2,a3
ffffffffc020586a:	854a                	mv	a0,s2
ffffffffc020586c:	390010ef          	jal	ra,ffffffffc0206bfc <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205870:	7782                	ld	a5,32(sp)
ffffffffc0205872:	4398                	lw	a4,0(a5)
ffffffffc0205874:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205878:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020587c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b7e47>
ffffffffc0205880:	14f71663          	bne	a4,a5,ffffffffc02059cc <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205884:	7682                	ld	a3,32(sp)
ffffffffc0205886:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020588a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020588e:	00371793          	slli	a5,a4,0x3
ffffffffc0205892:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205894:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205896:	078e                	slli	a5,a5,0x3
ffffffffc0205898:	97ce                	add	a5,a5,s3
ffffffffc020589a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020589c:	00f9fc63          	bgeu	s3,a5,ffffffffc02058b4 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02058a0:	0009a783          	lw	a5,0(s3)
ffffffffc02058a4:	4705                	li	a4,1
ffffffffc02058a6:	12e78f63          	beq	a5,a4,ffffffffc02059e4 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02058aa:	77a2                	ld	a5,40(sp)
ffffffffc02058ac:	03898993          	addi	s3,s3,56
ffffffffc02058b0:	fef9e8e3          	bltu	s3,a5,ffffffffc02058a0 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02058b4:	4701                	li	a4,0
ffffffffc02058b6:	46ad                	li	a3,11
ffffffffc02058b8:	00100637          	lui	a2,0x100
ffffffffc02058bc:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02058c0:	8526                	mv	a0,s1
ffffffffc02058c2:	a1bfe0ef          	jal	ra,ffffffffc02042dc <mm_map>
ffffffffc02058c6:	8a2a                	mv	s4,a0
ffffffffc02058c8:	1e051063          	bnez	a0,ffffffffc0205aa8 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02058cc:	6c88                	ld	a0,24(s1)
ffffffffc02058ce:	467d                	li	a2,31
ffffffffc02058d0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02058d4:	a51fd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc02058d8:	38050163          	beqz	a0,ffffffffc0205c5a <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02058dc:	6c88                	ld	a0,24(s1)
ffffffffc02058de:	467d                	li	a2,31
ffffffffc02058e0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02058e4:	a41fd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc02058e8:	34050963          	beqz	a0,ffffffffc0205c3a <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02058ec:	6c88                	ld	a0,24(s1)
ffffffffc02058ee:	467d                	li	a2,31
ffffffffc02058f0:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02058f4:	a31fd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc02058f8:	32050163          	beqz	a0,ffffffffc0205c1a <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02058fc:	6c88                	ld	a0,24(s1)
ffffffffc02058fe:	467d                	li	a2,31
ffffffffc0205900:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205904:	a21fd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc0205908:	2e050963          	beqz	a0,ffffffffc0205bfa <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc020590c:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020590e:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205912:	6c94                	ld	a3,24(s1)
ffffffffc0205914:	2785                	addiw	a5,a5,1
ffffffffc0205916:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205918:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020591a:	c02007b7          	lui	a5,0xc0200
ffffffffc020591e:	2cf6e263          	bltu	a3,a5,ffffffffc0205be2 <do_execve+0x478>
ffffffffc0205922:	000b3783          	ld	a5,0(s6)
ffffffffc0205926:	577d                	li	a4,-1
ffffffffc0205928:	177e                	slli	a4,a4,0x3f
ffffffffc020592a:	8e9d                	sub	a3,a3,a5
ffffffffc020592c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205930:	f654                	sd	a3,168(a2)
ffffffffc0205932:	8fd9                	or	a5,a5,a4
ffffffffc0205934:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205938:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020593a:	4581                	li	a1,0
ffffffffc020593c:	12000613          	li	a2,288
ffffffffc0205940:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205942:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205946:	2a4010ef          	jal	ra,ffffffffc0206bea <memset>
     tf->epc = elf->e_entry;
ffffffffc020594a:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020594c:	000db483          	ld	s1,0(s11)
     tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205950:	edf97913          	andi	s2,s2,-289
     tf->epc = elf->e_entry;
ffffffffc0205954:	6f98                	ld	a4,24(a5)
	    tf->gpr.sp = USTACKTOP;
ffffffffc0205956:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205958:	0b448493          	addi	s1,s1,180
	    tf->gpr.sp = USTACKTOP;
ffffffffc020595c:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020595e:	4641                	li	a2,16
ffffffffc0205960:	4581                	li	a1,0
	    tf->gpr.sp = USTACKTOP;
ffffffffc0205962:	e81c                	sd	a5,16(s0)
     tf->epc = elf->e_entry;
ffffffffc0205964:	10e43423          	sd	a4,264(s0)
     tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205968:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020596c:	8526                	mv	a0,s1
ffffffffc020596e:	27c010ef          	jal	ra,ffffffffc0206bea <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205972:	463d                	li	a2,15
ffffffffc0205974:	180c                	addi	a1,sp,48
ffffffffc0205976:	8526                	mv	a0,s1
ffffffffc0205978:	284010ef          	jal	ra,ffffffffc0206bfc <memcpy>
}
ffffffffc020597c:	70aa                	ld	ra,168(sp)
ffffffffc020597e:	740a                	ld	s0,160(sp)
ffffffffc0205980:	64ea                	ld	s1,152(sp)
ffffffffc0205982:	694a                	ld	s2,144(sp)
ffffffffc0205984:	69aa                	ld	s3,136(sp)
ffffffffc0205986:	7ae6                	ld	s5,120(sp)
ffffffffc0205988:	7b46                	ld	s6,112(sp)
ffffffffc020598a:	7ba6                	ld	s7,104(sp)
ffffffffc020598c:	7c06                	ld	s8,96(sp)
ffffffffc020598e:	6ce6                	ld	s9,88(sp)
ffffffffc0205990:	6d46                	ld	s10,80(sp)
ffffffffc0205992:	6da6                	ld	s11,72(sp)
ffffffffc0205994:	8552                	mv	a0,s4
ffffffffc0205996:	6a0a                	ld	s4,128(sp)
ffffffffc0205998:	614d                	addi	sp,sp,176
ffffffffc020599a:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020599c:	463d                	li	a2,15
ffffffffc020599e:	85ca                	mv	a1,s2
ffffffffc02059a0:	1808                	addi	a0,sp,48
ffffffffc02059a2:	25a010ef          	jal	ra,ffffffffc0206bfc <memcpy>
    if (mm != NULL) {
ffffffffc02059a6:	e20993e3          	bnez	s3,ffffffffc02057cc <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02059aa:	000db783          	ld	a5,0(s11)
ffffffffc02059ae:	779c                	ld	a5,40(a5)
ffffffffc02059b0:	e4078ae3          	beqz	a5,ffffffffc0205804 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02059b4:	00003617          	auipc	a2,0x3
ffffffffc02059b8:	2a460613          	addi	a2,a2,676 # ffffffffc0208c58 <default_pmm_manager+0x12f0>
ffffffffc02059bc:	22400593          	li	a1,548
ffffffffc02059c0:	00003517          	auipc	a0,0x3
ffffffffc02059c4:	0b050513          	addi	a0,a0,176 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc02059c8:	ab7fa0ef          	jal	ra,ffffffffc020047e <__panic>
    put_pgdir(mm);
ffffffffc02059cc:	8526                	mv	a0,s1
ffffffffc02059ce:	c00ff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc02059d2:	8526                	mv	a0,s1
ffffffffc02059d4:	8b7fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02059d8:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02059da:	8552                	mv	a0,s4
ffffffffc02059dc:	94fff0ef          	jal	ra,ffffffffc020532a <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02059e0:	5a71                	li	s4,-4
ffffffffc02059e2:	bfe5                	j	ffffffffc02059da <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02059e4:	0289b603          	ld	a2,40(s3)
ffffffffc02059e8:	0209b783          	ld	a5,32(s3)
ffffffffc02059ec:	1cf66d63          	bltu	a2,a5,ffffffffc0205bc6 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02059f0:	0049a783          	lw	a5,4(s3)
ffffffffc02059f4:	0017f693          	andi	a3,a5,1
ffffffffc02059f8:	c291                	beqz	a3,ffffffffc02059fc <do_execve+0x292>
ffffffffc02059fa:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059fc:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a00:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a02:	e779                	bnez	a4,ffffffffc0205ad0 <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a04:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a06:	c781                	beqz	a5,ffffffffc0205a0e <do_execve+0x2a4>
ffffffffc0205a08:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a0c:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a0e:	0026f793          	andi	a5,a3,2
ffffffffc0205a12:	e3f1                	bnez	a5,ffffffffc0205ad6 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a14:	0046f793          	andi	a5,a3,4
ffffffffc0205a18:	c399                	beqz	a5,ffffffffc0205a1e <do_execve+0x2b4>
ffffffffc0205a1a:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a1e:	0109b583          	ld	a1,16(s3)
ffffffffc0205a22:	4701                	li	a4,0
ffffffffc0205a24:	8526                	mv	a0,s1
ffffffffc0205a26:	8b7fe0ef          	jal	ra,ffffffffc02042dc <mm_map>
ffffffffc0205a2a:	8a2a                	mv	s4,a0
ffffffffc0205a2c:	ed35                	bnez	a0,ffffffffc0205aa8 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a2e:	0109bb83          	ld	s7,16(s3)
ffffffffc0205a32:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a34:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a38:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a3c:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a40:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a42:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a44:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205a46:	054be963          	bltu	s7,s4,ffffffffc0205a98 <do_execve+0x32e>
ffffffffc0205a4a:	aa95                	j	ffffffffc0205bbe <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a4c:	6785                	lui	a5,0x1
ffffffffc0205a4e:	415b8533          	sub	a0,s7,s5
ffffffffc0205a52:	9abe                	add	s5,s5,a5
ffffffffc0205a54:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a58:	015a7463          	bgeu	s4,s5,ffffffffc0205a60 <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205a5c:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205a60:	000cb683          	ld	a3,0(s9)
ffffffffc0205a64:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a66:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205a6a:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a6e:	8699                	srai	a3,a3,0x6
ffffffffc0205a70:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a72:	67e2                	ld	a5,24(sp)
ffffffffc0205a74:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a78:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a7a:	14b87863          	bgeu	a6,a1,ffffffffc0205bca <do_execve+0x460>
ffffffffc0205a7e:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a82:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205a84:	9bb2                	add	s7,s7,a2
ffffffffc0205a86:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a88:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205a8a:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a8c:	170010ef          	jal	ra,ffffffffc0206bfc <memcpy>
            start += size, from += size;
ffffffffc0205a90:	6622                	ld	a2,8(sp)
ffffffffc0205a92:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205a94:	054bf363          	bgeu	s7,s4,ffffffffc0205ada <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a98:	6c88                	ld	a0,24(s1)
ffffffffc0205a9a:	866a                	mv	a2,s10
ffffffffc0205a9c:	85d6                	mv	a1,s5
ffffffffc0205a9e:	887fd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc0205aa2:	842a                	mv	s0,a0
ffffffffc0205aa4:	f545                	bnez	a0,ffffffffc0205a4c <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205aa6:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205aa8:	8526                	mv	a0,s1
ffffffffc0205aaa:	97dfe0ef          	jal	ra,ffffffffc0204426 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205aae:	8526                	mv	a0,s1
ffffffffc0205ab0:	b1eff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ab4:	8526                	mv	a0,s1
ffffffffc0205ab6:	fd4fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    return ret;
ffffffffc0205aba:	b705                	j	ffffffffc02059da <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205abc:	854e                	mv	a0,s3
ffffffffc0205abe:	969fe0ef          	jal	ra,ffffffffc0204426 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205ac2:	854e                	mv	a0,s3
ffffffffc0205ac4:	b0aff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205ac8:	854e                	mv	a0,s3
ffffffffc0205aca:	fc0fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
ffffffffc0205ace:	b33d                	j	ffffffffc02057fc <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ad0:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ad4:	fb95                	bnez	a5,ffffffffc0205a08 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ad6:	4d5d                	li	s10,23
ffffffffc0205ad8:	bf35                	j	ffffffffc0205a14 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205ada:	0109b683          	ld	a3,16(s3)
ffffffffc0205ade:	0289b903          	ld	s2,40(s3)
ffffffffc0205ae2:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205ae4:	075bfd63          	bgeu	s7,s5,ffffffffc0205b5e <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205ae8:	dd7901e3          	beq	s2,s7,ffffffffc02058aa <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205aec:	6785                	lui	a5,0x1
ffffffffc0205aee:	00fb8533          	add	a0,s7,a5
ffffffffc0205af2:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205af6:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205afa:	0b597d63          	bgeu	s2,s5,ffffffffc0205bb4 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205afe:	000cb683          	ld	a3,0(s9)
ffffffffc0205b02:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b04:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205b08:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b0c:	8699                	srai	a3,a3,0x6
ffffffffc0205b0e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b10:	67e2                	ld	a5,24(sp)
ffffffffc0205b12:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b16:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b18:	0ac5f963          	bgeu	a1,a2,ffffffffc0205bca <do_execve+0x460>
ffffffffc0205b1c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b20:	8652                	mv	a2,s4
ffffffffc0205b22:	4581                	li	a1,0
ffffffffc0205b24:	96c2                	add	a3,a3,a6
ffffffffc0205b26:	9536                	add	a0,a0,a3
ffffffffc0205b28:	0c2010ef          	jal	ra,ffffffffc0206bea <memset>
            start += size;
ffffffffc0205b2c:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b30:	03597463          	bgeu	s2,s5,ffffffffc0205b58 <do_execve+0x3ee>
ffffffffc0205b34:	d6e90be3          	beq	s2,a4,ffffffffc02058aa <do_execve+0x140>
ffffffffc0205b38:	00003697          	auipc	a3,0x3
ffffffffc0205b3c:	14868693          	addi	a3,a3,328 # ffffffffc0208c80 <default_pmm_manager+0x1318>
ffffffffc0205b40:	00001617          	auipc	a2,0x1
ffffffffc0205b44:	79060613          	addi	a2,a2,1936 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205b48:	27900593          	li	a1,633
ffffffffc0205b4c:	00003517          	auipc	a0,0x3
ffffffffc0205b50:	f2450513          	addi	a0,a0,-220 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205b54:	92bfa0ef          	jal	ra,ffffffffc020047e <__panic>
ffffffffc0205b58:	ff5710e3          	bne	a4,s5,ffffffffc0205b38 <do_execve+0x3ce>
ffffffffc0205b5c:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205b5e:	d52bf6e3          	bgeu	s7,s2,ffffffffc02058aa <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b62:	6c88                	ld	a0,24(s1)
ffffffffc0205b64:	866a                	mv	a2,s10
ffffffffc0205b66:	85d6                	mv	a1,s5
ffffffffc0205b68:	fbcfd0ef          	jal	ra,ffffffffc0203324 <pgdir_alloc_page>
ffffffffc0205b6c:	842a                	mv	s0,a0
ffffffffc0205b6e:	dd05                	beqz	a0,ffffffffc0205aa6 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b70:	6785                	lui	a5,0x1
ffffffffc0205b72:	415b8533          	sub	a0,s7,s5
ffffffffc0205b76:	9abe                	add	s5,s5,a5
ffffffffc0205b78:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b7c:	01597463          	bgeu	s2,s5,ffffffffc0205b84 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205b80:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205b84:	000cb683          	ld	a3,0(s9)
ffffffffc0205b88:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b8a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205b8e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b92:	8699                	srai	a3,a3,0x6
ffffffffc0205b94:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b96:	67e2                	ld	a5,24(sp)
ffffffffc0205b98:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b9c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b9e:	02b87663          	bgeu	a6,a1,ffffffffc0205bca <do_execve+0x460>
ffffffffc0205ba2:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ba6:	4581                	li	a1,0
            start += size;
ffffffffc0205ba8:	9bb2                	add	s7,s7,a2
ffffffffc0205baa:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bac:	9536                	add	a0,a0,a3
ffffffffc0205bae:	03c010ef          	jal	ra,ffffffffc0206bea <memset>
ffffffffc0205bb2:	b775                	j	ffffffffc0205b5e <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bb4:	417a8a33          	sub	s4,s5,s7
ffffffffc0205bb8:	b799                	j	ffffffffc0205afe <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205bba:	5a75                	li	s4,-3
ffffffffc0205bbc:	b3c1                	j	ffffffffc020597c <do_execve+0x212>
        while (start < end) {
ffffffffc0205bbe:	86de                	mv	a3,s7
ffffffffc0205bc0:	bf39                	j	ffffffffc0205ade <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205bc2:	5a71                	li	s4,-4
ffffffffc0205bc4:	bdc5                	j	ffffffffc0205ab4 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205bc6:	5a61                	li	s4,-8
ffffffffc0205bc8:	b5c5                	j	ffffffffc0205aa8 <do_execve+0x33e>
ffffffffc0205bca:	00002617          	auipc	a2,0x2
ffffffffc0205bce:	dd660613          	addi	a2,a2,-554 # ffffffffc02079a0 <default_pmm_manager+0x38>
ffffffffc0205bd2:	06900593          	li	a1,105
ffffffffc0205bd6:	00002517          	auipc	a0,0x2
ffffffffc0205bda:	df250513          	addi	a0,a0,-526 # ffffffffc02079c8 <default_pmm_manager+0x60>
ffffffffc0205bde:	8a1fa0ef          	jal	ra,ffffffffc020047e <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205be2:	00002617          	auipc	a2,0x2
ffffffffc0205be6:	e6660613          	addi	a2,a2,-410 # ffffffffc0207a48 <default_pmm_manager+0xe0>
ffffffffc0205bea:	29400593          	li	a1,660
ffffffffc0205bee:	00003517          	auipc	a0,0x3
ffffffffc0205bf2:	e8250513          	addi	a0,a0,-382 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205bf6:	889fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bfa:	00003697          	auipc	a3,0x3
ffffffffc0205bfe:	19e68693          	addi	a3,a3,414 # ffffffffc0208d98 <default_pmm_manager+0x1430>
ffffffffc0205c02:	00001617          	auipc	a2,0x1
ffffffffc0205c06:	6ce60613          	addi	a2,a2,1742 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205c0a:	28f00593          	li	a1,655
ffffffffc0205c0e:	00003517          	auipc	a0,0x3
ffffffffc0205c12:	e6250513          	addi	a0,a0,-414 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205c16:	869fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c1a:	00003697          	auipc	a3,0x3
ffffffffc0205c1e:	13668693          	addi	a3,a3,310 # ffffffffc0208d50 <default_pmm_manager+0x13e8>
ffffffffc0205c22:	00001617          	auipc	a2,0x1
ffffffffc0205c26:	6ae60613          	addi	a2,a2,1710 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205c2a:	28e00593          	li	a1,654
ffffffffc0205c2e:	00003517          	auipc	a0,0x3
ffffffffc0205c32:	e4250513          	addi	a0,a0,-446 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205c36:	849fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c3a:	00003697          	auipc	a3,0x3
ffffffffc0205c3e:	0ce68693          	addi	a3,a3,206 # ffffffffc0208d08 <default_pmm_manager+0x13a0>
ffffffffc0205c42:	00001617          	auipc	a2,0x1
ffffffffc0205c46:	68e60613          	addi	a2,a2,1678 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205c4a:	28d00593          	li	a1,653
ffffffffc0205c4e:	00003517          	auipc	a0,0x3
ffffffffc0205c52:	e2250513          	addi	a0,a0,-478 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205c56:	829fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205c5a:	00003697          	auipc	a3,0x3
ffffffffc0205c5e:	06668693          	addi	a3,a3,102 # ffffffffc0208cc0 <default_pmm_manager+0x1358>
ffffffffc0205c62:	00001617          	auipc	a2,0x1
ffffffffc0205c66:	66e60613          	addi	a2,a2,1646 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205c6a:	28c00593          	li	a1,652
ffffffffc0205c6e:	00003517          	auipc	a0,0x3
ffffffffc0205c72:	e0250513          	addi	a0,a0,-510 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205c76:	809fa0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0205c7a <do_yield>:
    current->need_resched = 1;
ffffffffc0205c7a:	000c9797          	auipc	a5,0xc9
ffffffffc0205c7e:	32e7b783          	ld	a5,814(a5) # ffffffffc02cefa8 <current>
ffffffffc0205c82:	4705                	li	a4,1
ffffffffc0205c84:	ef98                	sd	a4,24(a5)
}
ffffffffc0205c86:	4501                	li	a0,0
ffffffffc0205c88:	8082                	ret

ffffffffc0205c8a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205c8a:	1101                	addi	sp,sp,-32
ffffffffc0205c8c:	e822                	sd	s0,16(sp)
ffffffffc0205c8e:	e426                	sd	s1,8(sp)
ffffffffc0205c90:	ec06                	sd	ra,24(sp)
ffffffffc0205c92:	842e                	mv	s0,a1
ffffffffc0205c94:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205c96:	c999                	beqz	a1,ffffffffc0205cac <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205c98:	000c9797          	auipc	a5,0xc9
ffffffffc0205c9c:	3107b783          	ld	a5,784(a5) # ffffffffc02cefa8 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205ca0:	7788                	ld	a0,40(a5)
ffffffffc0205ca2:	4685                	li	a3,1
ffffffffc0205ca4:	4611                	li	a2,4
ffffffffc0205ca6:	e3bfe0ef          	jal	ra,ffffffffc0204ae0 <user_mem_check>
ffffffffc0205caa:	c909                	beqz	a0,ffffffffc0205cbc <do_wait+0x32>
ffffffffc0205cac:	85a2                	mv	a1,s0
}
ffffffffc0205cae:	6442                	ld	s0,16(sp)
ffffffffc0205cb0:	60e2                	ld	ra,24(sp)
ffffffffc0205cb2:	8526                	mv	a0,s1
ffffffffc0205cb4:	64a2                	ld	s1,8(sp)
ffffffffc0205cb6:	6105                	addi	sp,sp,32
ffffffffc0205cb8:	fbcff06f          	j	ffffffffc0205474 <do_wait.part.0>
ffffffffc0205cbc:	60e2                	ld	ra,24(sp)
ffffffffc0205cbe:	6442                	ld	s0,16(sp)
ffffffffc0205cc0:	64a2                	ld	s1,8(sp)
ffffffffc0205cc2:	5575                	li	a0,-3
ffffffffc0205cc4:	6105                	addi	sp,sp,32
ffffffffc0205cc6:	8082                	ret

ffffffffc0205cc8 <do_kill>:
do_kill(int pid) {
ffffffffc0205cc8:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205cca:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205ccc:	e406                	sd	ra,8(sp)
ffffffffc0205cce:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205cd0:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205cd4:	17f9                	addi	a5,a5,-2
ffffffffc0205cd6:	02e7e963          	bltu	a5,a4,ffffffffc0205d08 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205cda:	842a                	mv	s0,a0
ffffffffc0205cdc:	45a9                	li	a1,10
ffffffffc0205cde:	2501                	sext.w	a0,a0
ffffffffc0205ce0:	28b000ef          	jal	ra,ffffffffc020676a <hash32>
ffffffffc0205ce4:	02051793          	slli	a5,a0,0x20
ffffffffc0205ce8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205cec:	000c5797          	auipc	a5,0xc5
ffffffffc0205cf0:	20c78793          	addi	a5,a5,524 # ffffffffc02caef8 <hash_list>
ffffffffc0205cf4:	953e                	add	a0,a0,a5
ffffffffc0205cf6:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205cf8:	a029                	j	ffffffffc0205d02 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205cfa:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205cfe:	00870b63          	beq	a4,s0,ffffffffc0205d14 <do_kill+0x4c>
ffffffffc0205d02:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d04:	fef51be3          	bne	a0,a5,ffffffffc0205cfa <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205d08:	5475                	li	s0,-3
}
ffffffffc0205d0a:	60a2                	ld	ra,8(sp)
ffffffffc0205d0c:	8522                	mv	a0,s0
ffffffffc0205d0e:	6402                	ld	s0,0(sp)
ffffffffc0205d10:	0141                	addi	sp,sp,16
ffffffffc0205d12:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d14:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205d18:	00177693          	andi	a3,a4,1
ffffffffc0205d1c:	e295                	bnez	a3,ffffffffc0205d40 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d1e:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205d20:	00176713          	ori	a4,a4,1
ffffffffc0205d24:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205d28:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d2a:	fe06d0e3          	bgez	a3,ffffffffc0205d0a <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205d2e:	f2878513          	addi	a0,a5,-216
ffffffffc0205d32:	7c6000ef          	jal	ra,ffffffffc02064f8 <wakeup_proc>
}
ffffffffc0205d36:	60a2                	ld	ra,8(sp)
ffffffffc0205d38:	8522                	mv	a0,s0
ffffffffc0205d3a:	6402                	ld	s0,0(sp)
ffffffffc0205d3c:	0141                	addi	sp,sp,16
ffffffffc0205d3e:	8082                	ret
        return -E_KILLED;
ffffffffc0205d40:	545d                	li	s0,-9
ffffffffc0205d42:	b7e1                	j	ffffffffc0205d0a <do_kill+0x42>

ffffffffc0205d44 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d44:	1101                	addi	sp,sp,-32
ffffffffc0205d46:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205d48:	000c9797          	auipc	a5,0xc9
ffffffffc0205d4c:	1b078793          	addi	a5,a5,432 # ffffffffc02ceef8 <proc_list>
ffffffffc0205d50:	ec06                	sd	ra,24(sp)
ffffffffc0205d52:	e822                	sd	s0,16(sp)
ffffffffc0205d54:	e04a                	sd	s2,0(sp)
ffffffffc0205d56:	000c5497          	auipc	s1,0xc5
ffffffffc0205d5a:	1a248493          	addi	s1,s1,418 # ffffffffc02caef8 <hash_list>
ffffffffc0205d5e:	e79c                	sd	a5,8(a5)
ffffffffc0205d60:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205d62:	000c9717          	auipc	a4,0xc9
ffffffffc0205d66:	19670713          	addi	a4,a4,406 # ffffffffc02ceef8 <proc_list>
ffffffffc0205d6a:	87a6                	mv	a5,s1
ffffffffc0205d6c:	e79c                	sd	a5,8(a5)
ffffffffc0205d6e:	e39c                	sd	a5,0(a5)
ffffffffc0205d70:	07c1                	addi	a5,a5,16
ffffffffc0205d72:	fef71de3          	bne	a4,a5,ffffffffc0205d6c <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205d76:	f5bfe0ef          	jal	ra,ffffffffc0204cd0 <alloc_proc>
ffffffffc0205d7a:	000c9917          	auipc	s2,0xc9
ffffffffc0205d7e:	23690913          	addi	s2,s2,566 # ffffffffc02cefb0 <idleproc>
ffffffffc0205d82:	00a93023          	sd	a0,0(s2)
ffffffffc0205d86:	0e050f63          	beqz	a0,ffffffffc0205e84 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205d8a:	4789                	li	a5,2
ffffffffc0205d8c:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d8e:	00004797          	auipc	a5,0x4
ffffffffc0205d92:	27278793          	addi	a5,a5,626 # ffffffffc020a000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d96:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d9a:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205d9c:	4785                	li	a5,1
ffffffffc0205d9e:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205da0:	4641                	li	a2,16
ffffffffc0205da2:	4581                	li	a1,0
ffffffffc0205da4:	8522                	mv	a0,s0
ffffffffc0205da6:	645000ef          	jal	ra,ffffffffc0206bea <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205daa:	463d                	li	a2,15
ffffffffc0205dac:	00003597          	auipc	a1,0x3
ffffffffc0205db0:	04c58593          	addi	a1,a1,76 # ffffffffc0208df8 <default_pmm_manager+0x1490>
ffffffffc0205db4:	8522                	mv	a0,s0
ffffffffc0205db6:	647000ef          	jal	ra,ffffffffc0206bfc <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205dba:	000c9717          	auipc	a4,0xc9
ffffffffc0205dbe:	20670713          	addi	a4,a4,518 # ffffffffc02cefc0 <nr_process>
ffffffffc0205dc2:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205dc4:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dc8:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205dca:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dcc:	4581                	li	a1,0
ffffffffc0205dce:	00000517          	auipc	a0,0x0
ffffffffc0205dd2:	87850513          	addi	a0,a0,-1928 # ffffffffc0205646 <init_main>
    nr_process ++;
ffffffffc0205dd6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205dd8:	000c9797          	auipc	a5,0xc9
ffffffffc0205ddc:	1cd7b823          	sd	a3,464(a5) # ffffffffc02cefa8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205de0:	cfaff0ef          	jal	ra,ffffffffc02052da <kernel_thread>
ffffffffc0205de4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205de6:	08a05363          	blez	a0,ffffffffc0205e6c <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205dea:	6789                	lui	a5,0x2
ffffffffc0205dec:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205df0:	17f9                	addi	a5,a5,-2
ffffffffc0205df2:	2501                	sext.w	a0,a0
ffffffffc0205df4:	02e7e363          	bltu	a5,a4,ffffffffc0205e1a <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205df8:	45a9                	li	a1,10
ffffffffc0205dfa:	171000ef          	jal	ra,ffffffffc020676a <hash32>
ffffffffc0205dfe:	02051793          	slli	a5,a0,0x20
ffffffffc0205e02:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205e06:	96a6                	add	a3,a3,s1
ffffffffc0205e08:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205e0a:	a029                	j	ffffffffc0205e14 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205e0c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x803c>
ffffffffc0205e10:	04870b63          	beq	a4,s0,ffffffffc0205e66 <proc_init+0x122>
    return listelm->next;
ffffffffc0205e14:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e16:	fef69be3          	bne	a3,a5,ffffffffc0205e0c <proc_init+0xc8>
    return NULL;
ffffffffc0205e1a:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e1c:	0b478493          	addi	s1,a5,180
ffffffffc0205e20:	4641                	li	a2,16
ffffffffc0205e22:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e24:	000c9417          	auipc	s0,0xc9
ffffffffc0205e28:	19440413          	addi	s0,s0,404 # ffffffffc02cefb8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e2c:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205e2e:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e30:	5bb000ef          	jal	ra,ffffffffc0206bea <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e34:	463d                	li	a2,15
ffffffffc0205e36:	00003597          	auipc	a1,0x3
ffffffffc0205e3a:	fea58593          	addi	a1,a1,-22 # ffffffffc0208e20 <default_pmm_manager+0x14b8>
ffffffffc0205e3e:	8526                	mv	a0,s1
ffffffffc0205e40:	5bd000ef          	jal	ra,ffffffffc0206bfc <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e44:	00093783          	ld	a5,0(s2)
ffffffffc0205e48:	cbb5                	beqz	a5,ffffffffc0205ebc <proc_init+0x178>
ffffffffc0205e4a:	43dc                	lw	a5,4(a5)
ffffffffc0205e4c:	eba5                	bnez	a5,ffffffffc0205ebc <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e4e:	601c                	ld	a5,0(s0)
ffffffffc0205e50:	c7b1                	beqz	a5,ffffffffc0205e9c <proc_init+0x158>
ffffffffc0205e52:	43d8                	lw	a4,4(a5)
ffffffffc0205e54:	4785                	li	a5,1
ffffffffc0205e56:	04f71363          	bne	a4,a5,ffffffffc0205e9c <proc_init+0x158>
}
ffffffffc0205e5a:	60e2                	ld	ra,24(sp)
ffffffffc0205e5c:	6442                	ld	s0,16(sp)
ffffffffc0205e5e:	64a2                	ld	s1,8(sp)
ffffffffc0205e60:	6902                	ld	s2,0(sp)
ffffffffc0205e62:	6105                	addi	sp,sp,32
ffffffffc0205e64:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205e66:	f2878793          	addi	a5,a5,-216
ffffffffc0205e6a:	bf4d                	j	ffffffffc0205e1c <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205e6c:	00003617          	auipc	a2,0x3
ffffffffc0205e70:	f9460613          	addi	a2,a2,-108 # ffffffffc0208e00 <default_pmm_manager+0x1498>
ffffffffc0205e74:	39800593          	li	a1,920
ffffffffc0205e78:	00003517          	auipc	a0,0x3
ffffffffc0205e7c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205e80:	dfefa0ef          	jal	ra,ffffffffc020047e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205e84:	00003617          	auipc	a2,0x3
ffffffffc0205e88:	f5c60613          	addi	a2,a2,-164 # ffffffffc0208de0 <default_pmm_manager+0x1478>
ffffffffc0205e8c:	38a00593          	li	a1,906
ffffffffc0205e90:	00003517          	auipc	a0,0x3
ffffffffc0205e94:	be050513          	addi	a0,a0,-1056 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205e98:	de6fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e9c:	00003697          	auipc	a3,0x3
ffffffffc0205ea0:	fb468693          	addi	a3,a3,-76 # ffffffffc0208e50 <default_pmm_manager+0x14e8>
ffffffffc0205ea4:	00001617          	auipc	a2,0x1
ffffffffc0205ea8:	42c60613          	addi	a2,a2,1068 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205eac:	39f00593          	li	a1,927
ffffffffc0205eb0:	00003517          	auipc	a0,0x3
ffffffffc0205eb4:	bc050513          	addi	a0,a0,-1088 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205eb8:	dc6fa0ef          	jal	ra,ffffffffc020047e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ebc:	00003697          	auipc	a3,0x3
ffffffffc0205ec0:	f6c68693          	addi	a3,a3,-148 # ffffffffc0208e28 <default_pmm_manager+0x14c0>
ffffffffc0205ec4:	00001617          	auipc	a2,0x1
ffffffffc0205ec8:	40c60613          	addi	a2,a2,1036 # ffffffffc02072d0 <commands+0x450>
ffffffffc0205ecc:	39e00593          	li	a1,926
ffffffffc0205ed0:	00003517          	auipc	a0,0x3
ffffffffc0205ed4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0208a70 <default_pmm_manager+0x1108>
ffffffffc0205ed8:	da6fa0ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc0205edc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205edc:	1141                	addi	sp,sp,-16
ffffffffc0205ede:	e022                	sd	s0,0(sp)
ffffffffc0205ee0:	e406                	sd	ra,8(sp)
ffffffffc0205ee2:	000c9417          	auipc	s0,0xc9
ffffffffc0205ee6:	0c640413          	addi	s0,s0,198 # ffffffffc02cefa8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205eea:	6018                	ld	a4,0(s0)
ffffffffc0205eec:	6f1c                	ld	a5,24(a4)
ffffffffc0205eee:	dffd                	beqz	a5,ffffffffc0205eec <cpu_idle+0x10>
            schedule();
ffffffffc0205ef0:	6ba000ef          	jal	ra,ffffffffc02065aa <schedule>
ffffffffc0205ef4:	bfdd                	j	ffffffffc0205eea <cpu_idle+0xe>

ffffffffc0205ef6 <lab6_set_priority>:
    }
}
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void
lab6_set_priority(uint32_t priority)
{
ffffffffc0205ef6:	1141                	addi	sp,sp,-16
ffffffffc0205ef8:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205efa:	85aa                	mv	a1,a0
{
ffffffffc0205efc:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205efe:	00003517          	auipc	a0,0x3
ffffffffc0205f02:	f7a50513          	addi	a0,a0,-134 # ffffffffc0208e78 <default_pmm_manager+0x1510>
{
ffffffffc0205f06:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f08:	a7cfa0ef          	jal	ra,ffffffffc0200184 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0205f0c:	000c9797          	auipc	a5,0xc9
ffffffffc0205f10:	09c7b783          	ld	a5,156(a5) # ffffffffc02cefa8 <current>
    if (priority == 0)
ffffffffc0205f14:	e801                	bnez	s0,ffffffffc0205f24 <lab6_set_priority+0x2e>
    else current->lab6_priority = priority;
}
ffffffffc0205f16:	60a2                	ld	ra,8(sp)
ffffffffc0205f18:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0205f1a:	4705                	li	a4,1
ffffffffc0205f1c:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0205f20:	0141                	addi	sp,sp,16
ffffffffc0205f22:	8082                	ret
ffffffffc0205f24:	60a2                	ld	ra,8(sp)
    else current->lab6_priority = priority;
ffffffffc0205f26:	1487a223          	sw	s0,324(a5)
}
ffffffffc0205f2a:	6402                	ld	s0,0(sp)
ffffffffc0205f2c:	0141                	addi	sp,sp,16
ffffffffc0205f2e:	8082                	ret

ffffffffc0205f30 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f30:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f34:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f38:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f3a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f3c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f40:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f44:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f48:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f4c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f50:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f54:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f58:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f5c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f60:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f64:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f68:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f6c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f6e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f70:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f74:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f78:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f7c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f80:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f84:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f88:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f8c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f90:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f94:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f98:	8082                	ret

ffffffffc0205f9a <stride_init>:
    elm->prev = elm->next = elm;
ffffffffc0205f9a:	e508                	sd	a0,8(a0)
ffffffffc0205f9c:	e108                	sd	a0,0(a0)
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
	list_init(&(rq->run_list));
	  rq->lab6_run_pool = NULL;
ffffffffc0205f9e:	00053c23          	sd	zero,24(a0)
      rq->proc_num = 0;
ffffffffc0205fa2:	00052823          	sw	zero,16(a0)

}
ffffffffc0205fa6:	8082                	ret

ffffffffc0205fa8 <stride_pick_next>:
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pol
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
	skew_heap_entry_t * skew = rq->lab6_run_pool;
ffffffffc0205fa8:	6d1c                	ld	a5,24(a0)
	  if(skew!=NULL)
ffffffffc0205faa:	cb99                	beqz	a5,ffffffffc0205fc0 <stride_pick_next+0x18>
	  {
		  struct proc_struct *proc = le2proc(skew,lab6_run_pool);
		  proc->lab6_stride = proc->lab6_stride + BIG_STRIDE/proc->lab6_priority;
ffffffffc0205fac:	4fd0                	lw	a2,28(a5)
ffffffffc0205fae:	56fd                	li	a3,-1
ffffffffc0205fb0:	4f98                	lw	a4,24(a5)
ffffffffc0205fb2:	02c6d6bb          	divuw	a3,a3,a2
		  struct proc_struct *proc = le2proc(skew,lab6_run_pool);
ffffffffc0205fb6:	ed878513          	addi	a0,a5,-296
		  proc->lab6_stride = proc->lab6_stride + BIG_STRIDE/proc->lab6_priority;
ffffffffc0205fba:	9f35                	addw	a4,a4,a3
ffffffffc0205fbc:	cf98                	sw	a4,24(a5)
		  return proc;
ffffffffc0205fbe:	8082                	ret
	  }

	  return NULL;
ffffffffc0205fc0:	4501                	li	a0,0
}
ffffffffc0205fc2:	8082                	ret

ffffffffc0205fc4 <stride_proc_tick>:
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE 卢星宇2211287*/
	    if (proc->time_slice > 0) {
ffffffffc0205fc4:	1205a783          	lw	a5,288(a1)
ffffffffc0205fc8:	00f05563          	blez	a5,ffffffffc0205fd2 <stride_proc_tick+0xe>
        proc->time_slice --;
ffffffffc0205fcc:	37fd                	addiw	a5,a5,-1
ffffffffc0205fce:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc0205fd2:	e399                	bnez	a5,ffffffffc0205fd8 <stride_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc0205fd4:	4785                	li	a5,1
ffffffffc0205fd6:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0205fd8:	8082                	ret

ffffffffc0205fda <skew_heap_merge.constprop.0>:
{
     a->left = a->right = a->parent = NULL;
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
ffffffffc0205fda:	7139                	addi	sp,sp,-64
ffffffffc0205fdc:	f822                	sd	s0,48(sp)
ffffffffc0205fde:	fc06                	sd	ra,56(sp)
ffffffffc0205fe0:	f426                	sd	s1,40(sp)
ffffffffc0205fe2:	f04a                	sd	s2,32(sp)
ffffffffc0205fe4:	ec4e                	sd	s3,24(sp)
ffffffffc0205fe6:	e852                	sd	s4,16(sp)
ffffffffc0205fe8:	e456                	sd	s5,8(sp)
ffffffffc0205fea:	e05a                	sd	s6,0(sp)
ffffffffc0205fec:	842e                	mv	s0,a1
                compare_f comp)
{
     if (a == NULL) return b;
ffffffffc0205fee:	c925                	beqz	a0,ffffffffc020605e <skew_heap_merge.constprop.0+0x84>
ffffffffc0205ff0:	84aa                	mv	s1,a0
     else if (b == NULL) return a;
ffffffffc0205ff2:	c1ed                	beqz	a1,ffffffffc02060d4 <skew_heap_merge.constprop.0+0xfa>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205ff4:	4d1c                	lw	a5,24(a0)
ffffffffc0205ff6:	4d98                	lw	a4,24(a1)
     else if (c == 0) return 0;
ffffffffc0205ff8:	40e786bb          	subw	a3,a5,a4
ffffffffc0205ffc:	0606cc63          	bltz	a3,ffffffffc0206074 <skew_heap_merge.constprop.0+0x9a>
          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206000:	0105b903          	ld	s2,16(a1)
          r = b->left;
ffffffffc0206004:	0085ba03          	ld	s4,8(a1)
     else if (b == NULL) return a;
ffffffffc0206008:	04090763          	beqz	s2,ffffffffc0206056 <skew_heap_merge.constprop.0+0x7c>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc020600c:	01892703          	lw	a4,24(s2)
     else if (c == 0) return 0;
ffffffffc0206010:	40e786bb          	subw	a3,a5,a4
ffffffffc0206014:	0c06c263          	bltz	a3,ffffffffc02060d8 <skew_heap_merge.constprop.0+0xfe>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206018:	01093983          	ld	s3,16(s2)
          r = b->left;
ffffffffc020601c:	00893a83          	ld	s5,8(s2)
     else if (b == NULL) return a;
ffffffffc0206020:	10098c63          	beqz	s3,ffffffffc0206138 <skew_heap_merge.constprop.0+0x15e>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206024:	0189a703          	lw	a4,24(s3)
     else if (c == 0) return 0;
ffffffffc0206028:	9f99                	subw	a5,a5,a4
ffffffffc020602a:	1407c863          	bltz	a5,ffffffffc020617a <skew_heap_merge.constprop.0+0x1a0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020602e:	0109b583          	ld	a1,16(s3)
          r = b->left;
ffffffffc0206032:	0089b483          	ld	s1,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206036:	fa5ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          
          b->left = l;
ffffffffc020603a:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc020603e:	0099b823          	sd	s1,16(s3)
          if (l) l->parent = b;
ffffffffc0206042:	c119                	beqz	a0,ffffffffc0206048 <skew_heap_merge.constprop.0+0x6e>
ffffffffc0206044:	01353023          	sd	s3,0(a0)
          b->left = l;
ffffffffc0206048:	01393423          	sd	s3,8(s2)
          b->right = r;
ffffffffc020604c:	01593823          	sd	s5,16(s2)
          if (l) l->parent = b;
ffffffffc0206050:	0129b023          	sd	s2,0(s3)
ffffffffc0206054:	84ca                	mv	s1,s2
          b->left = l;
ffffffffc0206056:	e404                	sd	s1,8(s0)
          b->right = r;
ffffffffc0206058:	01443823          	sd	s4,16(s0)
          if (l) l->parent = b;
ffffffffc020605c:	e080                	sd	s0,0(s1)
ffffffffc020605e:	8522                	mv	a0,s0

          return b;
     }
}
ffffffffc0206060:	70e2                	ld	ra,56(sp)
ffffffffc0206062:	7442                	ld	s0,48(sp)
ffffffffc0206064:	74a2                	ld	s1,40(sp)
ffffffffc0206066:	7902                	ld	s2,32(sp)
ffffffffc0206068:	69e2                	ld	s3,24(sp)
ffffffffc020606a:	6a42                	ld	s4,16(sp)
ffffffffc020606c:	6aa2                	ld	s5,8(sp)
ffffffffc020606e:	6b02                	ld	s6,0(sp)
ffffffffc0206070:	6121                	addi	sp,sp,64
ffffffffc0206072:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206074:	01053903          	ld	s2,16(a0)
          r = a->left;
ffffffffc0206078:	00853a03          	ld	s4,8(a0)
     if (a == NULL) return b;
ffffffffc020607c:	04090863          	beqz	s2,ffffffffc02060cc <skew_heap_merge.constprop.0+0xf2>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206080:	01892783          	lw	a5,24(s2)
     else if (c == 0) return 0;
ffffffffc0206084:	40e7873b          	subw	a4,a5,a4
ffffffffc0206088:	08074963          	bltz	a4,ffffffffc020611a <skew_heap_merge.constprop.0+0x140>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020608c:	0105b983          	ld	s3,16(a1)
          r = b->left;
ffffffffc0206090:	0085ba83          	ld	s5,8(a1)
     else if (b == NULL) return a;
ffffffffc0206094:	02098663          	beqz	s3,ffffffffc02060c0 <skew_heap_merge.constprop.0+0xe6>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206098:	0189a703          	lw	a4,24(s3)
     else if (c == 0) return 0;
ffffffffc020609c:	9f99                	subw	a5,a5,a4
ffffffffc020609e:	0a07cf63          	bltz	a5,ffffffffc020615c <skew_heap_merge.constprop.0+0x182>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02060a2:	0109b583          	ld	a1,16(s3)
          r = b->left;
ffffffffc02060a6:	0089bb03          	ld	s6,8(s3)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02060aa:	854a                	mv	a0,s2
ffffffffc02060ac:	f2fff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc02060b0:	00a9b423          	sd	a0,8(s3)
          b->right = r;
ffffffffc02060b4:	0169b823          	sd	s6,16(s3)
          if (l) l->parent = b;
ffffffffc02060b8:	894e                	mv	s2,s3
ffffffffc02060ba:	c119                	beqz	a0,ffffffffc02060c0 <skew_heap_merge.constprop.0+0xe6>
ffffffffc02060bc:	01253023          	sd	s2,0(a0)
          b->left = l;
ffffffffc02060c0:	01243423          	sd	s2,8(s0)
          b->right = r;
ffffffffc02060c4:	01543823          	sd	s5,16(s0)
          if (l) l->parent = b;
ffffffffc02060c8:	00893023          	sd	s0,0(s2)
          a->left = l;
ffffffffc02060cc:	e480                	sd	s0,8(s1)
          a->right = r;
ffffffffc02060ce:	0144b823          	sd	s4,16(s1)
          if (l) l->parent = a;
ffffffffc02060d2:	e004                	sd	s1,0(s0)
ffffffffc02060d4:	8526                	mv	a0,s1
ffffffffc02060d6:	b769                	j	ffffffffc0206060 <skew_heap_merge.constprop.0+0x86>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02060d8:	01053983          	ld	s3,16(a0)
          r = a->left;
ffffffffc02060dc:	00853a83          	ld	s5,8(a0)
     if (a == NULL) return b;
ffffffffc02060e0:	02098663          	beqz	s3,ffffffffc020610c <skew_heap_merge.constprop.0+0x132>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02060e4:	0189a783          	lw	a5,24(s3)
     else if (c == 0) return 0;
ffffffffc02060e8:	40e7873b          	subw	a4,a5,a4
ffffffffc02060ec:	04074863          	bltz	a4,ffffffffc020613c <skew_heap_merge.constprop.0+0x162>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02060f0:	01093583          	ld	a1,16(s2)
          r = b->left;
ffffffffc02060f4:	00893b03          	ld	s6,8(s2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02060f8:	854e                	mv	a0,s3
ffffffffc02060fa:	ee1ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc02060fe:	00a93423          	sd	a0,8(s2)
          b->right = r;
ffffffffc0206102:	01693823          	sd	s6,16(s2)
          if (l) l->parent = b;
ffffffffc0206106:	c119                	beqz	a0,ffffffffc020610c <skew_heap_merge.constprop.0+0x132>
ffffffffc0206108:	01253023          	sd	s2,0(a0)
          a->left = l;
ffffffffc020610c:	0124b423          	sd	s2,8(s1)
          a->right = r;
ffffffffc0206110:	0154b823          	sd	s5,16(s1)
          if (l) l->parent = a;
ffffffffc0206114:	00993023          	sd	s1,0(s2)
ffffffffc0206118:	bf3d                	j	ffffffffc0206056 <skew_heap_merge.constprop.0+0x7c>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020611a:	01093503          	ld	a0,16(s2)
          r = a->left;
ffffffffc020611e:	00893983          	ld	s3,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206122:	844a                	mv	s0,s2
ffffffffc0206124:	eb7ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206128:	00a93423          	sd	a0,8(s2)
          a->right = r;
ffffffffc020612c:	01393823          	sd	s3,16(s2)
          if (l) l->parent = a;
ffffffffc0206130:	dd51                	beqz	a0,ffffffffc02060cc <skew_heap_merge.constprop.0+0xf2>
ffffffffc0206132:	01253023          	sd	s2,0(a0)
ffffffffc0206136:	bf59                	j	ffffffffc02060cc <skew_heap_merge.constprop.0+0xf2>
          if (l) l->parent = b;
ffffffffc0206138:	89a6                	mv	s3,s1
ffffffffc020613a:	b739                	j	ffffffffc0206048 <skew_heap_merge.constprop.0+0x6e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020613c:	0109b503          	ld	a0,16(s3)
          r = a->left;
ffffffffc0206140:	0089bb03          	ld	s6,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206144:	85ca                	mv	a1,s2
ffffffffc0206146:	e95ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc020614a:	00a9b423          	sd	a0,8(s3)
          a->right = r;
ffffffffc020614e:	0169b823          	sd	s6,16(s3)
          if (l) l->parent = a;
ffffffffc0206152:	894e                	mv	s2,s3
ffffffffc0206154:	dd45                	beqz	a0,ffffffffc020610c <skew_heap_merge.constprop.0+0x132>
          if (l) l->parent = b;
ffffffffc0206156:	01253023          	sd	s2,0(a0)
ffffffffc020615a:	bf4d                	j	ffffffffc020610c <skew_heap_merge.constprop.0+0x132>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020615c:	01093503          	ld	a0,16(s2)
          r = a->left;
ffffffffc0206160:	00893b03          	ld	s6,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206164:	85ce                	mv	a1,s3
ffffffffc0206166:	e75ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc020616a:	00a93423          	sd	a0,8(s2)
          a->right = r;
ffffffffc020616e:	01693823          	sd	s6,16(s2)
          if (l) l->parent = a;
ffffffffc0206172:	d539                	beqz	a0,ffffffffc02060c0 <skew_heap_merge.constprop.0+0xe6>
          if (l) l->parent = b;
ffffffffc0206174:	01253023          	sd	s2,0(a0)
ffffffffc0206178:	b7a1                	j	ffffffffc02060c0 <skew_heap_merge.constprop.0+0xe6>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020617a:	6908                	ld	a0,16(a0)
          r = a->left;
ffffffffc020617c:	0084bb03          	ld	s6,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206180:	85ce                	mv	a1,s3
ffffffffc0206182:	e59ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206186:	e488                	sd	a0,8(s1)
          a->right = r;
ffffffffc0206188:	0164b823          	sd	s6,16(s1)
          if (l) l->parent = a;
ffffffffc020618c:	d555                	beqz	a0,ffffffffc0206138 <skew_heap_merge.constprop.0+0x15e>
ffffffffc020618e:	e104                	sd	s1,0(a0)
ffffffffc0206190:	89a6                	mv	s3,s1
ffffffffc0206192:	bd5d                	j	ffffffffc0206048 <skew_heap_merge.constprop.0+0x6e>

ffffffffc0206194 <stride_enqueue>:
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206194:	7139                	addi	sp,sp,-64
ffffffffc0206196:	f04a                	sd	s2,32(sp)
	rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc0206198:	01853903          	ld	s2,24(a0)
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc020619c:	f822                	sd	s0,48(sp)
ffffffffc020619e:	f426                	sd	s1,40(sp)
ffffffffc02061a0:	fc06                	sd	ra,56(sp)
ffffffffc02061a2:	ec4e                	sd	s3,24(sp)
ffffffffc02061a4:	e852                	sd	s4,16(sp)
ffffffffc02061a6:	e456                	sd	s5,8(sp)
     a->left = a->right = a->parent = NULL;
ffffffffc02061a8:	1205b423          	sd	zero,296(a1)
ffffffffc02061ac:	1205bc23          	sd	zero,312(a1)
ffffffffc02061b0:	1205b823          	sd	zero,304(a1)
ffffffffc02061b4:	842e                	mv	s0,a1
ffffffffc02061b6:	84aa                	mv	s1,a0
	rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc02061b8:	12858593          	addi	a1,a1,296
     if (a == NULL) return b;
ffffffffc02061bc:	00090d63          	beqz	s2,ffffffffc02061d6 <stride_enqueue+0x42>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02061c0:	14042703          	lw	a4,320(s0)
ffffffffc02061c4:	01892783          	lw	a5,24(s2)
     else if (c == 0) return 0;
ffffffffc02061c8:	9f99                	subw	a5,a5,a4
ffffffffc02061ca:	0207cd63          	bltz	a5,ffffffffc0206204 <stride_enqueue+0x70>
          b->left = l;
ffffffffc02061ce:	13243823          	sd	s2,304(s0)
          if (l) l->parent = b;
ffffffffc02061d2:	00b93023          	sd	a1,0(s2)
 	  if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02061d6:	12042783          	lw	a5,288(s0)
	rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc02061da:	ec8c                	sd	a1,24(s1)
 	  if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02061dc:	48d8                	lw	a4,20(s1)
ffffffffc02061de:	c399                	beqz	a5,ffffffffc02061e4 <stride_enqueue+0x50>
ffffffffc02061e0:	00f75463          	bge	a4,a5,ffffffffc02061e8 <stride_enqueue+0x54>
 	    proc->time_slice = rq->max_time_slice;
ffffffffc02061e4:	12e42023          	sw	a4,288(s0)
	  rq->proc_num++;
ffffffffc02061e8:	489c                	lw	a5,16(s1)
}
ffffffffc02061ea:	70e2                	ld	ra,56(sp)
	  proc->rq = rq;
ffffffffc02061ec:	10943423          	sd	s1,264(s0)
}
ffffffffc02061f0:	7442                	ld	s0,48(sp)
	  rq->proc_num++;
ffffffffc02061f2:	2785                	addiw	a5,a5,1
ffffffffc02061f4:	c89c                	sw	a5,16(s1)
}
ffffffffc02061f6:	7902                	ld	s2,32(sp)
ffffffffc02061f8:	74a2                	ld	s1,40(sp)
ffffffffc02061fa:	69e2                	ld	s3,24(sp)
ffffffffc02061fc:	6a42                	ld	s4,16(sp)
ffffffffc02061fe:	6aa2                	ld	s5,8(sp)
ffffffffc0206200:	6121                	addi	sp,sp,64
ffffffffc0206202:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206204:	01093983          	ld	s3,16(s2)
          r = a->left;
ffffffffc0206208:	00893a03          	ld	s4,8(s2)
     if (a == NULL) return b;
ffffffffc020620c:	00098c63          	beqz	s3,ffffffffc0206224 <stride_enqueue+0x90>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206210:	0189a783          	lw	a5,24(s3)
     else if (c == 0) return 0;
ffffffffc0206214:	40e7873b          	subw	a4,a5,a4
ffffffffc0206218:	00074e63          	bltz	a4,ffffffffc0206234 <stride_enqueue+0xa0>
          b->left = l;
ffffffffc020621c:	13343823          	sd	s3,304(s0)
          if (l) l->parent = b;
ffffffffc0206220:	00b9b023          	sd	a1,0(s3)
          a->left = l;
ffffffffc0206224:	00b93423          	sd	a1,8(s2)
          a->right = r;
ffffffffc0206228:	01493823          	sd	s4,16(s2)
          if (l) l->parent = a;
ffffffffc020622c:	0125b023          	sd	s2,0(a1)
ffffffffc0206230:	85ca                	mv	a1,s2
ffffffffc0206232:	b755                	j	ffffffffc02061d6 <stride_enqueue+0x42>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206234:	0109b503          	ld	a0,16(s3)
          r = a->left;
ffffffffc0206238:	0089ba83          	ld	s5,8(s3)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020623c:	d9fff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206240:	00a9b423          	sd	a0,8(s3)
          a->right = r;
ffffffffc0206244:	0159b823          	sd	s5,16(s3)
          if (l) l->parent = a;
ffffffffc0206248:	85ce                	mv	a1,s3
ffffffffc020624a:	dd69                	beqz	a0,ffffffffc0206224 <stride_enqueue+0x90>
ffffffffc020624c:	01353023          	sd	s3,0(a0)
ffffffffc0206250:	bfd1                	j	ffffffffc0206224 <stride_enqueue+0x90>

ffffffffc0206252 <stride_dequeue>:
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206252:	711d                	addi	sp,sp,-96
ffffffffc0206254:	e0ca                	sd	s2,64(sp)
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206256:	1305b903          	ld	s2,304(a1)
ffffffffc020625a:	e8a2                	sd	s0,80(sp)
ffffffffc020625c:	e4a6                	sd	s1,72(sp)
ffffffffc020625e:	fc4e                	sd	s3,56(sp)
ffffffffc0206260:	f456                	sd	s5,40(sp)
ffffffffc0206262:	f05a                	sd	s6,32(sp)
ffffffffc0206264:	ec86                	sd	ra,88(sp)
ffffffffc0206266:	f852                	sd	s4,48(sp)
ffffffffc0206268:	ec5e                	sd	s7,24(sp)
ffffffffc020626a:	e862                	sd	s8,16(sp)
ffffffffc020626c:	e466                	sd	s9,8(sp)
ffffffffc020626e:	e06a                	sd	s10,0(sp)
	 rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc0206270:	01853b03          	ld	s6,24(a0)
     skew_heap_entry_t *p   = b->parent;
ffffffffc0206274:	1285b983          	ld	s3,296(a1)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206278:	1385b483          	ld	s1,312(a1)
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc020627c:	842e                	mv	s0,a1
ffffffffc020627e:	8aaa                	mv	s5,a0
     if (a == NULL) return b;
ffffffffc0206280:	12090563          	beqz	s2,ffffffffc02063aa <stride_dequeue+0x158>
     else if (b == NULL) return a;
ffffffffc0206284:	12048b63          	beqz	s1,ffffffffc02063ba <stride_dequeue+0x168>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206288:	01892783          	lw	a5,24(s2)
ffffffffc020628c:	4c98                	lw	a4,24(s1)
     else if (c == 0) return 0;
ffffffffc020628e:	40e786bb          	subw	a3,a5,a4
ffffffffc0206292:	0a06c663          	bltz	a3,ffffffffc020633e <stride_dequeue+0xec>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206296:	0104ba03          	ld	s4,16(s1)
          r = b->left;
ffffffffc020629a:	0084bc03          	ld	s8,8(s1)
     else if (b == NULL) return a;
ffffffffc020629e:	040a0963          	beqz	s4,ffffffffc02062f0 <stride_dequeue+0x9e>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02062a2:	018a2703          	lw	a4,24(s4)
     else if (c == 0) return 0;
ffffffffc02062a6:	40e786bb          	subw	a3,a5,a4
ffffffffc02062aa:	1006cc63          	bltz	a3,ffffffffc02063c2 <stride_dequeue+0x170>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062ae:	010a3b83          	ld	s7,16(s4)
          r = b->left;
ffffffffc02062b2:	008a3c83          	ld	s9,8(s4)
     else if (b == NULL) return a;
ffffffffc02062b6:	020b8663          	beqz	s7,ffffffffc02062e2 <stride_dequeue+0x90>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02062ba:	018ba703          	lw	a4,24(s7)
     else if (c == 0) return 0;
ffffffffc02062be:	9f99                	subw	a5,a5,a4
ffffffffc02062c0:	1a07c163          	bltz	a5,ffffffffc0206462 <stride_dequeue+0x210>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062c4:	010bb583          	ld	a1,16(s7)
          r = b->left;
ffffffffc02062c8:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062cc:	854a                	mv	a0,s2
ffffffffc02062ce:	d0dff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc02062d2:	00abb423          	sd	a0,8(s7)
          b->right = r;
ffffffffc02062d6:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = b;
ffffffffc02062da:	895e                	mv	s2,s7
ffffffffc02062dc:	c119                	beqz	a0,ffffffffc02062e2 <stride_dequeue+0x90>
ffffffffc02062de:	01253023          	sd	s2,0(a0)
          b->left = l;
ffffffffc02062e2:	012a3423          	sd	s2,8(s4)
          b->right = r;
ffffffffc02062e6:	019a3823          	sd	s9,16(s4)
          if (l) l->parent = b;
ffffffffc02062ea:	01493023          	sd	s4,0(s2)
ffffffffc02062ee:	8952                	mv	s2,s4
          b->left = l;
ffffffffc02062f0:	0124b423          	sd	s2,8(s1)
          b->right = r;
ffffffffc02062f4:	0184b823          	sd	s8,16(s1)
          if (l) l->parent = b;
ffffffffc02062f8:	00993023          	sd	s1,0(s2)
     if (rep) rep->parent = p;
ffffffffc02062fc:	0134b023          	sd	s3,0(s1)
     
     if (p)
ffffffffc0206300:	0a098863          	beqz	s3,ffffffffc02063b0 <stride_dequeue+0x15e>
     {
          if (p->left == b)
ffffffffc0206304:	0089b783          	ld	a5,8(s3)
	 rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc0206308:	12840413          	addi	s0,s0,296
ffffffffc020630c:	0a878463          	beq	a5,s0,ffffffffc02063b4 <stride_dequeue+0x162>
               p->left = rep;
          else p->right = rep;
ffffffffc0206310:	0099b823          	sd	s1,16(s3)
	  rq->proc_num--;
ffffffffc0206314:	010aa783          	lw	a5,16(s5)
}
ffffffffc0206318:	60e6                	ld	ra,88(sp)
ffffffffc020631a:	6446                	ld	s0,80(sp)
	  rq->proc_num--;
ffffffffc020631c:	37fd                	addiw	a5,a5,-1
	 rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool,&proc->lab6_run_pool,proc_stride_comp_f);
ffffffffc020631e:	016abc23          	sd	s6,24(s5)
	  rq->proc_num--;
ffffffffc0206322:	00faa823          	sw	a5,16(s5)
}
ffffffffc0206326:	64a6                	ld	s1,72(sp)
ffffffffc0206328:	6906                	ld	s2,64(sp)
ffffffffc020632a:	79e2                	ld	s3,56(sp)
ffffffffc020632c:	7a42                	ld	s4,48(sp)
ffffffffc020632e:	7aa2                	ld	s5,40(sp)
ffffffffc0206330:	7b02                	ld	s6,32(sp)
ffffffffc0206332:	6be2                	ld	s7,24(sp)
ffffffffc0206334:	6c42                	ld	s8,16(sp)
ffffffffc0206336:	6ca2                	ld	s9,8(sp)
ffffffffc0206338:	6d02                	ld	s10,0(sp)
ffffffffc020633a:	6125                	addi	sp,sp,96
ffffffffc020633c:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020633e:	01093a03          	ld	s4,16(s2)
          r = a->left;
ffffffffc0206342:	00893c03          	ld	s8,8(s2)
     if (a == NULL) return b;
ffffffffc0206346:	040a0863          	beqz	s4,ffffffffc0206396 <stride_dequeue+0x144>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc020634a:	018a2783          	lw	a5,24(s4)
     else if (c == 0) return 0;
ffffffffc020634e:	40e7873b          	subw	a4,a5,a4
ffffffffc0206352:	0a074963          	bltz	a4,ffffffffc0206404 <stride_dequeue+0x1b2>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206356:	0104bb83          	ld	s7,16(s1)
          r = b->left;
ffffffffc020635a:	0084bc83          	ld	s9,8(s1)
     else if (b == NULL) return a;
ffffffffc020635e:	020b8663          	beqz	s7,ffffffffc020638a <stride_dequeue+0x138>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0206362:	018ba703          	lw	a4,24(s7)
     else if (c == 0) return 0;
ffffffffc0206366:	9f99                	subw	a5,a5,a4
ffffffffc0206368:	0c07ce63          	bltz	a5,ffffffffc0206444 <stride_dequeue+0x1f2>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020636c:	010bb583          	ld	a1,16(s7)
          r = b->left;
ffffffffc0206370:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206374:	8552                	mv	a0,s4
ffffffffc0206376:	c65ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc020637a:	00abb423          	sd	a0,8(s7)
          b->right = r;
ffffffffc020637e:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = b;
ffffffffc0206382:	8a5e                	mv	s4,s7
ffffffffc0206384:	c119                	beqz	a0,ffffffffc020638a <stride_dequeue+0x138>
ffffffffc0206386:	01453023          	sd	s4,0(a0)
          b->left = l;
ffffffffc020638a:	0144b423          	sd	s4,8(s1)
          b->right = r;
ffffffffc020638e:	0194b823          	sd	s9,16(s1)
          if (l) l->parent = b;
ffffffffc0206392:	009a3023          	sd	s1,0(s4)
          a->left = l;
ffffffffc0206396:	00993423          	sd	s1,8(s2)
          a->right = r;
ffffffffc020639a:	01893823          	sd	s8,16(s2)
          if (l) l->parent = a;
ffffffffc020639e:	0124b023          	sd	s2,0(s1)
ffffffffc02063a2:	84ca                	mv	s1,s2
     if (rep) rep->parent = p;
ffffffffc02063a4:	0134b023          	sd	s3,0(s1)
ffffffffc02063a8:	bfa1                	j	ffffffffc0206300 <stride_dequeue+0xae>
ffffffffc02063aa:	f8a9                	bnez	s1,ffffffffc02062fc <stride_dequeue+0xaa>
     if (p)
ffffffffc02063ac:	f4099ce3          	bnez	s3,ffffffffc0206304 <stride_dequeue+0xb2>
ffffffffc02063b0:	8b26                	mv	s6,s1
ffffffffc02063b2:	b78d                	j	ffffffffc0206314 <stride_dequeue+0xc2>
               p->left = rep;
ffffffffc02063b4:	0099b423          	sd	s1,8(s3)
ffffffffc02063b8:	bfb1                	j	ffffffffc0206314 <stride_dequeue+0xc2>
ffffffffc02063ba:	84ca                	mv	s1,s2
     if (rep) rep->parent = p;
ffffffffc02063bc:	0134b023          	sd	s3,0(s1)
ffffffffc02063c0:	b781                	j	ffffffffc0206300 <stride_dequeue+0xae>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02063c2:	01093b83          	ld	s7,16(s2)
          r = a->left;
ffffffffc02063c6:	00893c83          	ld	s9,8(s2)
     if (a == NULL) return b;
ffffffffc02063ca:	020b8663          	beqz	s7,ffffffffc02063f6 <stride_dequeue+0x1a4>
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc02063ce:	018ba783          	lw	a5,24(s7)
     else if (c == 0) return 0;
ffffffffc02063d2:	40e7873b          	subw	a4,a5,a4
ffffffffc02063d6:	04074763          	bltz	a4,ffffffffc0206424 <stride_dequeue+0x1d2>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02063da:	010a3583          	ld	a1,16(s4)
          r = b->left;
ffffffffc02063de:	008a3d03          	ld	s10,8(s4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02063e2:	855e                	mv	a0,s7
ffffffffc02063e4:	bf7ff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          b->left = l;
ffffffffc02063e8:	00aa3423          	sd	a0,8(s4)
          b->right = r;
ffffffffc02063ec:	01aa3823          	sd	s10,16(s4)
          if (l) l->parent = b;
ffffffffc02063f0:	c119                	beqz	a0,ffffffffc02063f6 <stride_dequeue+0x1a4>
ffffffffc02063f2:	01453023          	sd	s4,0(a0)
          a->left = l;
ffffffffc02063f6:	01493423          	sd	s4,8(s2)
          a->right = r;
ffffffffc02063fa:	01993823          	sd	s9,16(s2)
          if (l) l->parent = a;
ffffffffc02063fe:	012a3023          	sd	s2,0(s4)
ffffffffc0206402:	b5fd                	j	ffffffffc02062f0 <stride_dequeue+0x9e>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206404:	010a3503          	ld	a0,16(s4)
          r = a->left;
ffffffffc0206408:	008a3b83          	ld	s7,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020640c:	85a6                	mv	a1,s1
ffffffffc020640e:	bcdff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206412:	00aa3423          	sd	a0,8(s4)
          a->right = r;
ffffffffc0206416:	017a3823          	sd	s7,16(s4)
          if (l) l->parent = a;
ffffffffc020641a:	84d2                	mv	s1,s4
ffffffffc020641c:	dd2d                	beqz	a0,ffffffffc0206396 <stride_dequeue+0x144>
ffffffffc020641e:	01453023          	sd	s4,0(a0)
ffffffffc0206422:	bf95                	j	ffffffffc0206396 <stride_dequeue+0x144>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206424:	010bb503          	ld	a0,16(s7)
          r = a->left;
ffffffffc0206428:	008bbd03          	ld	s10,8(s7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020642c:	85d2                	mv	a1,s4
ffffffffc020642e:	badff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206432:	00abb423          	sd	a0,8(s7)
          a->right = r;
ffffffffc0206436:	01abb823          	sd	s10,16(s7)
          if (l) l->parent = a;
ffffffffc020643a:	8a5e                	mv	s4,s7
ffffffffc020643c:	dd4d                	beqz	a0,ffffffffc02063f6 <stride_dequeue+0x1a4>
          if (l) l->parent = b;
ffffffffc020643e:	01453023          	sd	s4,0(a0)
ffffffffc0206442:	bf55                	j	ffffffffc02063f6 <stride_dequeue+0x1a4>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206444:	010a3503          	ld	a0,16(s4)
          r = a->left;
ffffffffc0206448:	008a3d03          	ld	s10,8(s4)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020644c:	85de                	mv	a1,s7
ffffffffc020644e:	b8dff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206452:	00aa3423          	sd	a0,8(s4)
          a->right = r;
ffffffffc0206456:	01aa3823          	sd	s10,16(s4)
          if (l) l->parent = a;
ffffffffc020645a:	d905                	beqz	a0,ffffffffc020638a <stride_dequeue+0x138>
          if (l) l->parent = b;
ffffffffc020645c:	01453023          	sd	s4,0(a0)
ffffffffc0206460:	b72d                	j	ffffffffc020638a <stride_dequeue+0x138>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206462:	01093503          	ld	a0,16(s2)
          r = a->left;
ffffffffc0206466:	00893d03          	ld	s10,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020646a:	85de                	mv	a1,s7
ffffffffc020646c:	b6fff0ef          	jal	ra,ffffffffc0205fda <skew_heap_merge.constprop.0>
          a->left = l;
ffffffffc0206470:	00a93423          	sd	a0,8(s2)
          a->right = r;
ffffffffc0206474:	01a93823          	sd	s10,16(s2)
          if (l) l->parent = a;
ffffffffc0206478:	e60513e3          	bnez	a0,ffffffffc02062de <stride_dequeue+0x8c>
ffffffffc020647c:	b59d                	j	ffffffffc02062e2 <stride_dequeue+0x90>

ffffffffc020647e <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void
sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
ffffffffc020647e:	000c9797          	auipc	a5,0xc9
ffffffffc0206482:	b327b783          	ld	a5,-1230(a5) # ffffffffc02cefb0 <idleproc>
sched_class_proc_tick(struct proc_struct *proc) {
ffffffffc0206486:	85aa                	mv	a1,a0
    if (proc != idleproc) {
ffffffffc0206488:	00a78c63          	beq	a5,a0,ffffffffc02064a0 <sched_class_proc_tick+0x22>
        sched_class->proc_tick(rq, proc);
ffffffffc020648c:	000c9797          	auipc	a5,0xc9
ffffffffc0206490:	b447b783          	ld	a5,-1212(a5) # ffffffffc02cefd0 <sched_class>
ffffffffc0206494:	779c                	ld	a5,40(a5)
ffffffffc0206496:	000c9517          	auipc	a0,0xc9
ffffffffc020649a:	b3253503          	ld	a0,-1230(a0) # ffffffffc02cefc8 <rq>
ffffffffc020649e:	8782                	jr	a5
    }
    else {
        proc->need_resched = 1;
ffffffffc02064a0:	4705                	li	a4,1
ffffffffc02064a2:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc02064a4:	8082                	ret

ffffffffc02064a6 <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc02064a6:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc02064a8:	000bd717          	auipc	a4,0xbd
ffffffffc02064ac:	55870713          	addi	a4,a4,1368 # ffffffffc02c3a00 <default_sched_class>
sched_init(void) {
ffffffffc02064b0:	e022                	sd	s0,0(sp)
ffffffffc02064b2:	e406                	sd	ra,8(sp)
ffffffffc02064b4:	000c9797          	auipc	a5,0xc9
ffffffffc02064b8:	a7478793          	addi	a5,a5,-1420 # ffffffffc02cef28 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc02064bc:	6714                	ld	a3,8(a4)
    rq = &__rq;
ffffffffc02064be:	000c9517          	auipc	a0,0xc9
ffffffffc02064c2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02cef08 <__rq>
ffffffffc02064c6:	e79c                	sd	a5,8(a5)
ffffffffc02064c8:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02064ca:	4795                	li	a5,5
ffffffffc02064cc:	c95c                	sw	a5,20(a0)
    sched_class = &default_sched_class;
ffffffffc02064ce:	000c9417          	auipc	s0,0xc9
ffffffffc02064d2:	b0240413          	addi	s0,s0,-1278 # ffffffffc02cefd0 <sched_class>
    rq = &__rq;
ffffffffc02064d6:	000c9797          	auipc	a5,0xc9
ffffffffc02064da:	aea7b923          	sd	a0,-1294(a5) # ffffffffc02cefc8 <rq>
    sched_class = &default_sched_class;
ffffffffc02064de:	e018                	sd	a4,0(s0)
    sched_class->init(rq);
ffffffffc02064e0:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02064e2:	601c                	ld	a5,0(s0)
}
ffffffffc02064e4:	6402                	ld	s0,0(sp)
ffffffffc02064e6:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02064e8:	638c                	ld	a1,0(a5)
ffffffffc02064ea:	00003517          	auipc	a0,0x3
ffffffffc02064ee:	9be50513          	addi	a0,a0,-1602 # ffffffffc0208ea8 <default_pmm_manager+0x1540>
}
ffffffffc02064f2:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02064f4:	c91f906f          	j	ffffffffc0200184 <cprintf>

ffffffffc02064f8 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02064f8:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02064fa:	1101                	addi	sp,sp,-32
ffffffffc02064fc:	ec06                	sd	ra,24(sp)
ffffffffc02064fe:	e822                	sd	s0,16(sp)
ffffffffc0206500:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206502:	478d                	li	a5,3
ffffffffc0206504:	08f70363          	beq	a4,a5,ffffffffc020658a <wakeup_proc+0x92>
ffffffffc0206508:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020650a:	100027f3          	csrr	a5,sstatus
ffffffffc020650e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206510:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206512:	e7bd                	bnez	a5,ffffffffc0206580 <wakeup_proc+0x88>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206514:	4789                	li	a5,2
ffffffffc0206516:	04f70863          	beq	a4,a5,ffffffffc0206566 <wakeup_proc+0x6e>
            proc->state = PROC_RUNNABLE;
ffffffffc020651a:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020651c:	0e042623          	sw	zero,236(s0)
            if (proc != current) {
ffffffffc0206520:	000c9797          	auipc	a5,0xc9
ffffffffc0206524:	a887b783          	ld	a5,-1400(a5) # ffffffffc02cefa8 <current>
ffffffffc0206528:	02878363          	beq	a5,s0,ffffffffc020654e <wakeup_proc+0x56>
    if (proc != idleproc) {
ffffffffc020652c:	000c9797          	auipc	a5,0xc9
ffffffffc0206530:	a847b783          	ld	a5,-1404(a5) # ffffffffc02cefb0 <idleproc>
ffffffffc0206534:	00f40d63          	beq	s0,a5,ffffffffc020654e <wakeup_proc+0x56>
        sched_class->enqueue(rq, proc);
ffffffffc0206538:	000c9797          	auipc	a5,0xc9
ffffffffc020653c:	a987b783          	ld	a5,-1384(a5) # ffffffffc02cefd0 <sched_class>
ffffffffc0206540:	6b9c                	ld	a5,16(a5)
ffffffffc0206542:	85a2                	mv	a1,s0
ffffffffc0206544:	000c9517          	auipc	a0,0xc9
ffffffffc0206548:	a8453503          	ld	a0,-1404(a0) # ffffffffc02cefc8 <rq>
ffffffffc020654c:	9782                	jalr	a5
    if (flag) {
ffffffffc020654e:	e491                	bnez	s1,ffffffffc020655a <wakeup_proc+0x62>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206550:	60e2                	ld	ra,24(sp)
ffffffffc0206552:	6442                	ld	s0,16(sp)
ffffffffc0206554:	64a2                	ld	s1,8(sp)
ffffffffc0206556:	6105                	addi	sp,sp,32
ffffffffc0206558:	8082                	ret
ffffffffc020655a:	6442                	ld	s0,16(sp)
ffffffffc020655c:	60e2                	ld	ra,24(sp)
ffffffffc020655e:	64a2                	ld	s1,8(sp)
ffffffffc0206560:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206562:	8d8fa06f          	j	ffffffffc020063a <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206566:	00003617          	auipc	a2,0x3
ffffffffc020656a:	99260613          	addi	a2,a2,-1646 # ffffffffc0208ef8 <default_pmm_manager+0x1590>
ffffffffc020656e:	04800593          	li	a1,72
ffffffffc0206572:	00003517          	auipc	a0,0x3
ffffffffc0206576:	96e50513          	addi	a0,a0,-1682 # ffffffffc0208ee0 <default_pmm_manager+0x1578>
ffffffffc020657a:	f6df90ef          	jal	ra,ffffffffc02004e6 <__warn>
ffffffffc020657e:	bfc1                	j	ffffffffc020654e <wakeup_proc+0x56>
        intr_disable();
ffffffffc0206580:	8c0fa0ef          	jal	ra,ffffffffc0200640 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206584:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0206586:	4485                	li	s1,1
ffffffffc0206588:	b771                	j	ffffffffc0206514 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020658a:	00003697          	auipc	a3,0x3
ffffffffc020658e:	93668693          	addi	a3,a3,-1738 # ffffffffc0208ec0 <default_pmm_manager+0x1558>
ffffffffc0206592:	00001617          	auipc	a2,0x1
ffffffffc0206596:	d3e60613          	addi	a2,a2,-706 # ffffffffc02072d0 <commands+0x450>
ffffffffc020659a:	03c00593          	li	a1,60
ffffffffc020659e:	00003517          	auipc	a0,0x3
ffffffffc02065a2:	94250513          	addi	a0,a0,-1726 # ffffffffc0208ee0 <default_pmm_manager+0x1578>
ffffffffc02065a6:	ed9f90ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc02065aa <schedule>:

void
schedule(void) {
ffffffffc02065aa:	7179                	addi	sp,sp,-48
ffffffffc02065ac:	f406                	sd	ra,40(sp)
ffffffffc02065ae:	f022                	sd	s0,32(sp)
ffffffffc02065b0:	ec26                	sd	s1,24(sp)
ffffffffc02065b2:	e84a                	sd	s2,16(sp)
ffffffffc02065b4:	e44e                	sd	s3,8(sp)
ffffffffc02065b6:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02065b8:	100027f3          	csrr	a5,sstatus
ffffffffc02065bc:	8b89                	andi	a5,a5,2
ffffffffc02065be:	4a01                	li	s4,0
ffffffffc02065c0:	e3cd                	bnez	a5,ffffffffc0206662 <schedule+0xb8>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02065c2:	000c9497          	auipc	s1,0xc9
ffffffffc02065c6:	9e648493          	addi	s1,s1,-1562 # ffffffffc02cefa8 <current>
ffffffffc02065ca:	608c                	ld	a1,0(s1)
        sched_class->enqueue(rq, proc);
ffffffffc02065cc:	000c9997          	auipc	s3,0xc9
ffffffffc02065d0:	a0498993          	addi	s3,s3,-1532 # ffffffffc02cefd0 <sched_class>
ffffffffc02065d4:	000c9917          	auipc	s2,0xc9
ffffffffc02065d8:	9f490913          	addi	s2,s2,-1548 # ffffffffc02cefc8 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc02065dc:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc02065de:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc02065e2:	4709                	li	a4,2
        sched_class->enqueue(rq, proc);
ffffffffc02065e4:	0009b783          	ld	a5,0(s3)
ffffffffc02065e8:	00093503          	ld	a0,0(s2)
        if (current->state == PROC_RUNNABLE) {
ffffffffc02065ec:	04e68e63          	beq	a3,a4,ffffffffc0206648 <schedule+0x9e>
    return sched_class->pick_next(rq);
ffffffffc02065f0:	739c                	ld	a5,32(a5)
ffffffffc02065f2:	9782                	jalr	a5
ffffffffc02065f4:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc02065f6:	c521                	beqz	a0,ffffffffc020663e <schedule+0x94>
    sched_class->dequeue(rq, proc);
ffffffffc02065f8:	0009b783          	ld	a5,0(s3)
ffffffffc02065fc:	00093503          	ld	a0,0(s2)
ffffffffc0206600:	85a2                	mv	a1,s0
ffffffffc0206602:	6f9c                	ld	a5,24(a5)
ffffffffc0206604:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206606:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0206608:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc020660a:	2785                	addiw	a5,a5,1
ffffffffc020660c:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc020660e:	00870563          	beq	a4,s0,ffffffffc0206618 <schedule+0x6e>
            proc_run(next);
ffffffffc0206612:	8522                	mv	a0,s0
ffffffffc0206614:	831fe0ef          	jal	ra,ffffffffc0204e44 <proc_run>
    if (flag) {
ffffffffc0206618:	000a1a63          	bnez	s4,ffffffffc020662c <schedule+0x82>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020661c:	70a2                	ld	ra,40(sp)
ffffffffc020661e:	7402                	ld	s0,32(sp)
ffffffffc0206620:	64e2                	ld	s1,24(sp)
ffffffffc0206622:	6942                	ld	s2,16(sp)
ffffffffc0206624:	69a2                	ld	s3,8(sp)
ffffffffc0206626:	6a02                	ld	s4,0(sp)
ffffffffc0206628:	6145                	addi	sp,sp,48
ffffffffc020662a:	8082                	ret
ffffffffc020662c:	7402                	ld	s0,32(sp)
ffffffffc020662e:	70a2                	ld	ra,40(sp)
ffffffffc0206630:	64e2                	ld	s1,24(sp)
ffffffffc0206632:	6942                	ld	s2,16(sp)
ffffffffc0206634:	69a2                	ld	s3,8(sp)
ffffffffc0206636:	6a02                	ld	s4,0(sp)
ffffffffc0206638:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020663a:	800fa06f          	j	ffffffffc020063a <intr_enable>
            next = idleproc;
ffffffffc020663e:	000c9417          	auipc	s0,0xc9
ffffffffc0206642:	97243403          	ld	s0,-1678(s0) # ffffffffc02cefb0 <idleproc>
ffffffffc0206646:	b7c1                	j	ffffffffc0206606 <schedule+0x5c>
    if (proc != idleproc) {
ffffffffc0206648:	000c9717          	auipc	a4,0xc9
ffffffffc020664c:	96873703          	ld	a4,-1688(a4) # ffffffffc02cefb0 <idleproc>
ffffffffc0206650:	fae580e3          	beq	a1,a4,ffffffffc02065f0 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0206654:	6b9c                	ld	a5,16(a5)
ffffffffc0206656:	9782                	jalr	a5
    return sched_class->pick_next(rq);
ffffffffc0206658:	0009b783          	ld	a5,0(s3)
ffffffffc020665c:	00093503          	ld	a0,0(s2)
ffffffffc0206660:	bf41                	j	ffffffffc02065f0 <schedule+0x46>
        intr_disable();
ffffffffc0206662:	fdff90ef          	jal	ra,ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0206666:	4a05                	li	s4,1
ffffffffc0206668:	bfa9                	j	ffffffffc02065c2 <schedule+0x18>

ffffffffc020666a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020666a:	000c9797          	auipc	a5,0xc9
ffffffffc020666e:	93e7b783          	ld	a5,-1730(a5) # ffffffffc02cefa8 <current>
}
ffffffffc0206672:	43c8                	lw	a0,4(a5)
ffffffffc0206674:	8082                	ret

ffffffffc0206676 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206676:	4501                	li	a0,0
ffffffffc0206678:	8082                	ret

ffffffffc020667a <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc020667a:	000c9797          	auipc	a5,0xc9
ffffffffc020667e:	8c67b783          	ld	a5,-1850(a5) # ffffffffc02cef40 <ticks>
ffffffffc0206682:	0027951b          	slliw	a0,a5,0x2
ffffffffc0206686:	9d3d                	addw	a0,a0,a5
}
ffffffffc0206688:	0015151b          	slliw	a0,a0,0x1
ffffffffc020668c:	8082                	ret

ffffffffc020668e <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc020668e:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0206690:	1141                	addi	sp,sp,-16
ffffffffc0206692:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0206694:	863ff0ef          	jal	ra,ffffffffc0205ef6 <lab6_set_priority>
    return 0;
}
ffffffffc0206698:	60a2                	ld	ra,8(sp)
ffffffffc020669a:	4501                	li	a0,0
ffffffffc020669c:	0141                	addi	sp,sp,16
ffffffffc020669e:	8082                	ret

ffffffffc02066a0 <sys_putc>:
    cputchar(c);
ffffffffc02066a0:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02066a2:	1141                	addi	sp,sp,-16
ffffffffc02066a4:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02066a6:	b15f90ef          	jal	ra,ffffffffc02001ba <cputchar>
}
ffffffffc02066aa:	60a2                	ld	ra,8(sp)
ffffffffc02066ac:	4501                	li	a0,0
ffffffffc02066ae:	0141                	addi	sp,sp,16
ffffffffc02066b0:	8082                	ret

ffffffffc02066b2 <sys_kill>:
    return do_kill(pid);
ffffffffc02066b2:	4108                	lw	a0,0(a0)
ffffffffc02066b4:	e14ff06f          	j	ffffffffc0205cc8 <do_kill>

ffffffffc02066b8 <sys_yield>:
    return do_yield();
ffffffffc02066b8:	dc2ff06f          	j	ffffffffc0205c7a <do_yield>

ffffffffc02066bc <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02066bc:	6d14                	ld	a3,24(a0)
ffffffffc02066be:	6910                	ld	a2,16(a0)
ffffffffc02066c0:	650c                	ld	a1,8(a0)
ffffffffc02066c2:	6108                	ld	a0,0(a0)
ffffffffc02066c4:	8a6ff06f          	j	ffffffffc020576a <do_execve>

ffffffffc02066c8 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02066c8:	650c                	ld	a1,8(a0)
ffffffffc02066ca:	4108                	lw	a0,0(a0)
ffffffffc02066cc:	dbeff06f          	j	ffffffffc0205c8a <do_wait>

ffffffffc02066d0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02066d0:	000c9797          	auipc	a5,0xc9
ffffffffc02066d4:	8d87b783          	ld	a5,-1832(a5) # ffffffffc02cefa8 <current>
ffffffffc02066d8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02066da:	4501                	li	a0,0
ffffffffc02066dc:	6a0c                	ld	a1,16(a2)
ffffffffc02066de:	fd2fe06f          	j	ffffffffc0204eb0 <do_fork>

ffffffffc02066e2 <sys_exit>:
    return do_exit(error_code);
ffffffffc02066e2:	4108                	lw	a0,0(a0)
ffffffffc02066e4:	c47fe06f          	j	ffffffffc020532a <do_exit>

ffffffffc02066e8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02066e8:	715d                	addi	sp,sp,-80
ffffffffc02066ea:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02066ec:	000c9497          	auipc	s1,0xc9
ffffffffc02066f0:	8bc48493          	addi	s1,s1,-1860 # ffffffffc02cefa8 <current>
ffffffffc02066f4:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02066f6:	e0a2                	sd	s0,64(sp)
ffffffffc02066f8:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02066fa:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02066fc:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02066fe:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0206702:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206706:	0327ee63          	bltu	a5,s2,ffffffffc0206742 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc020670a:	00391713          	slli	a4,s2,0x3
ffffffffc020670e:	00003797          	auipc	a5,0x3
ffffffffc0206712:	85278793          	addi	a5,a5,-1966 # ffffffffc0208f60 <syscalls>
ffffffffc0206716:	97ba                	add	a5,a5,a4
ffffffffc0206718:	639c                	ld	a5,0(a5)
ffffffffc020671a:	c785                	beqz	a5,ffffffffc0206742 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc020671c:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020671e:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206720:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206722:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206724:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206726:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206728:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020672a:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020672c:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020672e:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206730:	0028                	addi	a0,sp,8
ffffffffc0206732:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206734:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206736:	e828                	sd	a0,80(s0)
}
ffffffffc0206738:	6406                	ld	s0,64(sp)
ffffffffc020673a:	74e2                	ld	s1,56(sp)
ffffffffc020673c:	7942                	ld	s2,48(sp)
ffffffffc020673e:	6161                	addi	sp,sp,80
ffffffffc0206740:	8082                	ret
    print_trapframe(tf);
ffffffffc0206742:	8522                	mv	a0,s0
ffffffffc0206744:	8eafa0ef          	jal	ra,ffffffffc020082e <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206748:	609c                	ld	a5,0(s1)
ffffffffc020674a:	86ca                	mv	a3,s2
ffffffffc020674c:	00002617          	auipc	a2,0x2
ffffffffc0206750:	7cc60613          	addi	a2,a2,1996 # ffffffffc0208f18 <default_pmm_manager+0x15b0>
ffffffffc0206754:	43d8                	lw	a4,4(a5)
ffffffffc0206756:	06c00593          	li	a1,108
ffffffffc020675a:	0b478793          	addi	a5,a5,180
ffffffffc020675e:	00002517          	auipc	a0,0x2
ffffffffc0206762:	7ea50513          	addi	a0,a0,2026 # ffffffffc0208f48 <default_pmm_manager+0x15e0>
ffffffffc0206766:	d19f90ef          	jal	ra,ffffffffc020047e <__panic>

ffffffffc020676a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020676a:	9e3707b7          	lui	a5,0x9e370
ffffffffc020676e:	2785                	addiw	a5,a5,1
ffffffffc0206770:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206774:	02000793          	li	a5,32
ffffffffc0206778:	9f8d                	subw	a5,a5,a1
}
ffffffffc020677a:	00f5553b          	srlw	a0,a0,a5
ffffffffc020677e:	8082                	ret

ffffffffc0206780 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206780:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206784:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206786:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020678a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020678c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206790:	f022                	sd	s0,32(sp)
ffffffffc0206792:	ec26                	sd	s1,24(sp)
ffffffffc0206794:	e84a                	sd	s2,16(sp)
ffffffffc0206796:	f406                	sd	ra,40(sp)
ffffffffc0206798:	e44e                	sd	s3,8(sp)
ffffffffc020679a:	84aa                	mv	s1,a0
ffffffffc020679c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020679e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02067a2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02067a4:	03067e63          	bgeu	a2,a6,ffffffffc02067e0 <printnum+0x60>
ffffffffc02067a8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02067aa:	00805763          	blez	s0,ffffffffc02067b8 <printnum+0x38>
ffffffffc02067ae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02067b0:	85ca                	mv	a1,s2
ffffffffc02067b2:	854e                	mv	a0,s3
ffffffffc02067b4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02067b6:	fc65                	bnez	s0,ffffffffc02067ae <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02067b8:	1a02                	slli	s4,s4,0x20
ffffffffc02067ba:	00003797          	auipc	a5,0x3
ffffffffc02067be:	fa678793          	addi	a5,a5,-90 # ffffffffc0209760 <syscalls+0x800>
ffffffffc02067c2:	020a5a13          	srli	s4,s4,0x20
ffffffffc02067c6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02067c8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02067ca:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02067ce:	70a2                	ld	ra,40(sp)
ffffffffc02067d0:	69a2                	ld	s3,8(sp)
ffffffffc02067d2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02067d4:	85ca                	mv	a1,s2
ffffffffc02067d6:	87a6                	mv	a5,s1
}
ffffffffc02067d8:	6942                	ld	s2,16(sp)
ffffffffc02067da:	64e2                	ld	s1,24(sp)
ffffffffc02067dc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02067de:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02067e0:	03065633          	divu	a2,a2,a6
ffffffffc02067e4:	8722                	mv	a4,s0
ffffffffc02067e6:	f9bff0ef          	jal	ra,ffffffffc0206780 <printnum>
ffffffffc02067ea:	b7f9                	j	ffffffffc02067b8 <printnum+0x38>

ffffffffc02067ec <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02067ec:	7119                	addi	sp,sp,-128
ffffffffc02067ee:	f4a6                	sd	s1,104(sp)
ffffffffc02067f0:	f0ca                	sd	s2,96(sp)
ffffffffc02067f2:	ecce                	sd	s3,88(sp)
ffffffffc02067f4:	e8d2                	sd	s4,80(sp)
ffffffffc02067f6:	e4d6                	sd	s5,72(sp)
ffffffffc02067f8:	e0da                	sd	s6,64(sp)
ffffffffc02067fa:	fc5e                	sd	s7,56(sp)
ffffffffc02067fc:	f06a                	sd	s10,32(sp)
ffffffffc02067fe:	fc86                	sd	ra,120(sp)
ffffffffc0206800:	f8a2                	sd	s0,112(sp)
ffffffffc0206802:	f862                	sd	s8,48(sp)
ffffffffc0206804:	f466                	sd	s9,40(sp)
ffffffffc0206806:	ec6e                	sd	s11,24(sp)
ffffffffc0206808:	892a                	mv	s2,a0
ffffffffc020680a:	84ae                	mv	s1,a1
ffffffffc020680c:	8d32                	mv	s10,a2
ffffffffc020680e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206810:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206814:	5b7d                	li	s6,-1
ffffffffc0206816:	00003a97          	auipc	s5,0x3
ffffffffc020681a:	f76a8a93          	addi	s5,s5,-138 # ffffffffc020978c <syscalls+0x82c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020681e:	00003b97          	auipc	s7,0x3
ffffffffc0206822:	18ab8b93          	addi	s7,s7,394 # ffffffffc02099a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206826:	000d4503          	lbu	a0,0(s10)
ffffffffc020682a:	001d0413          	addi	s0,s10,1
ffffffffc020682e:	01350a63          	beq	a0,s3,ffffffffc0206842 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206832:	c121                	beqz	a0,ffffffffc0206872 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206834:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206836:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206838:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020683a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020683e:	ff351ae3          	bne	a0,s3,ffffffffc0206832 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206842:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206846:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020684a:	4c81                	li	s9,0
ffffffffc020684c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020684e:	5c7d                	li	s8,-1
ffffffffc0206850:	5dfd                	li	s11,-1
ffffffffc0206852:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206856:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206858:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020685c:	0ff5f593          	zext.b	a1,a1
ffffffffc0206860:	00140d13          	addi	s10,s0,1
ffffffffc0206864:	04b56263          	bltu	a0,a1,ffffffffc02068a8 <vprintfmt+0xbc>
ffffffffc0206868:	058a                	slli	a1,a1,0x2
ffffffffc020686a:	95d6                	add	a1,a1,s5
ffffffffc020686c:	4194                	lw	a3,0(a1)
ffffffffc020686e:	96d6                	add	a3,a3,s5
ffffffffc0206870:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206872:	70e6                	ld	ra,120(sp)
ffffffffc0206874:	7446                	ld	s0,112(sp)
ffffffffc0206876:	74a6                	ld	s1,104(sp)
ffffffffc0206878:	7906                	ld	s2,96(sp)
ffffffffc020687a:	69e6                	ld	s3,88(sp)
ffffffffc020687c:	6a46                	ld	s4,80(sp)
ffffffffc020687e:	6aa6                	ld	s5,72(sp)
ffffffffc0206880:	6b06                	ld	s6,64(sp)
ffffffffc0206882:	7be2                	ld	s7,56(sp)
ffffffffc0206884:	7c42                	ld	s8,48(sp)
ffffffffc0206886:	7ca2                	ld	s9,40(sp)
ffffffffc0206888:	7d02                	ld	s10,32(sp)
ffffffffc020688a:	6de2                	ld	s11,24(sp)
ffffffffc020688c:	6109                	addi	sp,sp,128
ffffffffc020688e:	8082                	ret
            padc = '0';
ffffffffc0206890:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206892:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206896:	846a                	mv	s0,s10
ffffffffc0206898:	00140d13          	addi	s10,s0,1
ffffffffc020689c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02068a0:	0ff5f593          	zext.b	a1,a1
ffffffffc02068a4:	fcb572e3          	bgeu	a0,a1,ffffffffc0206868 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02068a8:	85a6                	mv	a1,s1
ffffffffc02068aa:	02500513          	li	a0,37
ffffffffc02068ae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02068b0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02068b4:	8d22                	mv	s10,s0
ffffffffc02068b6:	f73788e3          	beq	a5,s3,ffffffffc0206826 <vprintfmt+0x3a>
ffffffffc02068ba:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02068be:	1d7d                	addi	s10,s10,-1
ffffffffc02068c0:	ff379de3          	bne	a5,s3,ffffffffc02068ba <vprintfmt+0xce>
ffffffffc02068c4:	b78d                	j	ffffffffc0206826 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02068c6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02068ca:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02068ce:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02068d0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02068d4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02068d8:	02d86463          	bltu	a6,a3,ffffffffc0206900 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02068dc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02068e0:	002c169b          	slliw	a3,s8,0x2
ffffffffc02068e4:	0186873b          	addw	a4,a3,s8
ffffffffc02068e8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02068ec:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02068ee:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02068f2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02068f4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02068f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02068fc:	fed870e3          	bgeu	a6,a3,ffffffffc02068dc <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206900:	f40ddce3          	bgez	s11,ffffffffc0206858 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206904:	8de2                	mv	s11,s8
ffffffffc0206906:	5c7d                	li	s8,-1
ffffffffc0206908:	bf81                	j	ffffffffc0206858 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020690a:	fffdc693          	not	a3,s11
ffffffffc020690e:	96fd                	srai	a3,a3,0x3f
ffffffffc0206910:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206914:	00144603          	lbu	a2,1(s0)
ffffffffc0206918:	2d81                	sext.w	s11,s11
ffffffffc020691a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020691c:	bf35                	j	ffffffffc0206858 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020691e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206922:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206926:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206928:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020692a:	bfd9                	j	ffffffffc0206900 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020692c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020692e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206932:	01174463          	blt	a4,a7,ffffffffc020693a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206936:	1a088e63          	beqz	a7,ffffffffc0206af2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020693a:	000a3603          	ld	a2,0(s4)
ffffffffc020693e:	46c1                	li	a3,16
ffffffffc0206940:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206942:	2781                	sext.w	a5,a5
ffffffffc0206944:	876e                	mv	a4,s11
ffffffffc0206946:	85a6                	mv	a1,s1
ffffffffc0206948:	854a                	mv	a0,s2
ffffffffc020694a:	e37ff0ef          	jal	ra,ffffffffc0206780 <printnum>
            break;
ffffffffc020694e:	bde1                	j	ffffffffc0206826 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206950:	000a2503          	lw	a0,0(s4)
ffffffffc0206954:	85a6                	mv	a1,s1
ffffffffc0206956:	0a21                	addi	s4,s4,8
ffffffffc0206958:	9902                	jalr	s2
            break;
ffffffffc020695a:	b5f1                	j	ffffffffc0206826 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020695c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020695e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206962:	01174463          	blt	a4,a7,ffffffffc020696a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206966:	18088163          	beqz	a7,ffffffffc0206ae8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020696a:	000a3603          	ld	a2,0(s4)
ffffffffc020696e:	46a9                	li	a3,10
ffffffffc0206970:	8a2e                	mv	s4,a1
ffffffffc0206972:	bfc1                	j	ffffffffc0206942 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206974:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206978:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020697a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020697c:	bdf1                	j	ffffffffc0206858 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020697e:	85a6                	mv	a1,s1
ffffffffc0206980:	02500513          	li	a0,37
ffffffffc0206984:	9902                	jalr	s2
            break;
ffffffffc0206986:	b545                	j	ffffffffc0206826 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206988:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020698c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020698e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206990:	b5e1                	j	ffffffffc0206858 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206992:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206994:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206998:	01174463          	blt	a4,a7,ffffffffc02069a0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020699c:	14088163          	beqz	a7,ffffffffc0206ade <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02069a0:	000a3603          	ld	a2,0(s4)
ffffffffc02069a4:	46a1                	li	a3,8
ffffffffc02069a6:	8a2e                	mv	s4,a1
ffffffffc02069a8:	bf69                	j	ffffffffc0206942 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02069aa:	03000513          	li	a0,48
ffffffffc02069ae:	85a6                	mv	a1,s1
ffffffffc02069b0:	e03e                	sd	a5,0(sp)
ffffffffc02069b2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02069b4:	85a6                	mv	a1,s1
ffffffffc02069b6:	07800513          	li	a0,120
ffffffffc02069ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02069bc:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02069be:	6782                	ld	a5,0(sp)
ffffffffc02069c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02069c2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02069c6:	bfb5                	j	ffffffffc0206942 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02069c8:	000a3403          	ld	s0,0(s4)
ffffffffc02069cc:	008a0713          	addi	a4,s4,8
ffffffffc02069d0:	e03a                	sd	a4,0(sp)
ffffffffc02069d2:	14040263          	beqz	s0,ffffffffc0206b16 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02069d6:	0fb05763          	blez	s11,ffffffffc0206ac4 <vprintfmt+0x2d8>
ffffffffc02069da:	02d00693          	li	a3,45
ffffffffc02069de:	0cd79163          	bne	a5,a3,ffffffffc0206aa0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02069e2:	00044783          	lbu	a5,0(s0)
ffffffffc02069e6:	0007851b          	sext.w	a0,a5
ffffffffc02069ea:	cf85                	beqz	a5,ffffffffc0206a22 <vprintfmt+0x236>
ffffffffc02069ec:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02069f0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02069f4:	000c4563          	bltz	s8,ffffffffc02069fe <vprintfmt+0x212>
ffffffffc02069f8:	3c7d                	addiw	s8,s8,-1
ffffffffc02069fa:	036c0263          	beq	s8,s6,ffffffffc0206a1e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02069fe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206a00:	0e0c8e63          	beqz	s9,ffffffffc0206afc <vprintfmt+0x310>
ffffffffc0206a04:	3781                	addiw	a5,a5,-32
ffffffffc0206a06:	0ef47b63          	bgeu	s0,a5,ffffffffc0206afc <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206a0a:	03f00513          	li	a0,63
ffffffffc0206a0e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206a10:	000a4783          	lbu	a5,0(s4)
ffffffffc0206a14:	3dfd                	addiw	s11,s11,-1
ffffffffc0206a16:	0a05                	addi	s4,s4,1
ffffffffc0206a18:	0007851b          	sext.w	a0,a5
ffffffffc0206a1c:	ffe1                	bnez	a5,ffffffffc02069f4 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206a1e:	01b05963          	blez	s11,ffffffffc0206a30 <vprintfmt+0x244>
ffffffffc0206a22:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206a24:	85a6                	mv	a1,s1
ffffffffc0206a26:	02000513          	li	a0,32
ffffffffc0206a2a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206a2c:	fe0d9be3          	bnez	s11,ffffffffc0206a22 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206a30:	6a02                	ld	s4,0(sp)
ffffffffc0206a32:	bbd5                	j	ffffffffc0206826 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206a34:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206a36:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206a3a:	01174463          	blt	a4,a7,ffffffffc0206a42 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206a3e:	08088d63          	beqz	a7,ffffffffc0206ad8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206a42:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206a46:	0a044d63          	bltz	s0,ffffffffc0206b00 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206a4a:	8622                	mv	a2,s0
ffffffffc0206a4c:	8a66                	mv	s4,s9
ffffffffc0206a4e:	46a9                	li	a3,10
ffffffffc0206a50:	bdcd                	j	ffffffffc0206942 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206a52:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206a56:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206a58:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206a5a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206a5e:	8fb5                	xor	a5,a5,a3
ffffffffc0206a60:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206a64:	02d74163          	blt	a4,a3,ffffffffc0206a86 <vprintfmt+0x29a>
ffffffffc0206a68:	00369793          	slli	a5,a3,0x3
ffffffffc0206a6c:	97de                	add	a5,a5,s7
ffffffffc0206a6e:	639c                	ld	a5,0(a5)
ffffffffc0206a70:	cb99                	beqz	a5,ffffffffc0206a86 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206a72:	86be                	mv	a3,a5
ffffffffc0206a74:	00000617          	auipc	a2,0x0
ffffffffc0206a78:	1cc60613          	addi	a2,a2,460 # ffffffffc0206c40 <etext+0x2c>
ffffffffc0206a7c:	85a6                	mv	a1,s1
ffffffffc0206a7e:	854a                	mv	a0,s2
ffffffffc0206a80:	0ce000ef          	jal	ra,ffffffffc0206b4e <printfmt>
ffffffffc0206a84:	b34d                	j	ffffffffc0206826 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206a86:	00003617          	auipc	a2,0x3
ffffffffc0206a8a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0209780 <syscalls+0x820>
ffffffffc0206a8e:	85a6                	mv	a1,s1
ffffffffc0206a90:	854a                	mv	a0,s2
ffffffffc0206a92:	0bc000ef          	jal	ra,ffffffffc0206b4e <printfmt>
ffffffffc0206a96:	bb41                	j	ffffffffc0206826 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206a98:	00003417          	auipc	s0,0x3
ffffffffc0206a9c:	ce040413          	addi	s0,s0,-800 # ffffffffc0209778 <syscalls+0x818>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206aa0:	85e2                	mv	a1,s8
ffffffffc0206aa2:	8522                	mv	a0,s0
ffffffffc0206aa4:	e43e                	sd	a5,8(sp)
ffffffffc0206aa6:	0e2000ef          	jal	ra,ffffffffc0206b88 <strnlen>
ffffffffc0206aaa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206aae:	01b05b63          	blez	s11,ffffffffc0206ac4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206ab2:	67a2                	ld	a5,8(sp)
ffffffffc0206ab4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206ab8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206aba:	85a6                	mv	a1,s1
ffffffffc0206abc:	8552                	mv	a0,s4
ffffffffc0206abe:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206ac0:	fe0d9ce3          	bnez	s11,ffffffffc0206ab8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206ac4:	00044783          	lbu	a5,0(s0)
ffffffffc0206ac8:	00140a13          	addi	s4,s0,1
ffffffffc0206acc:	0007851b          	sext.w	a0,a5
ffffffffc0206ad0:	d3a5                	beqz	a5,ffffffffc0206a30 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206ad2:	05e00413          	li	s0,94
ffffffffc0206ad6:	bf39                	j	ffffffffc02069f4 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0206ad8:	000a2403          	lw	s0,0(s4)
ffffffffc0206adc:	b7ad                	j	ffffffffc0206a46 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206ade:	000a6603          	lwu	a2,0(s4)
ffffffffc0206ae2:	46a1                	li	a3,8
ffffffffc0206ae4:	8a2e                	mv	s4,a1
ffffffffc0206ae6:	bdb1                	j	ffffffffc0206942 <vprintfmt+0x156>
ffffffffc0206ae8:	000a6603          	lwu	a2,0(s4)
ffffffffc0206aec:	46a9                	li	a3,10
ffffffffc0206aee:	8a2e                	mv	s4,a1
ffffffffc0206af0:	bd89                	j	ffffffffc0206942 <vprintfmt+0x156>
ffffffffc0206af2:	000a6603          	lwu	a2,0(s4)
ffffffffc0206af6:	46c1                	li	a3,16
ffffffffc0206af8:	8a2e                	mv	s4,a1
ffffffffc0206afa:	b5a1                	j	ffffffffc0206942 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206afc:	9902                	jalr	s2
ffffffffc0206afe:	bf09                	j	ffffffffc0206a10 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206b00:	85a6                	mv	a1,s1
ffffffffc0206b02:	02d00513          	li	a0,45
ffffffffc0206b06:	e03e                	sd	a5,0(sp)
ffffffffc0206b08:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206b0a:	6782                	ld	a5,0(sp)
ffffffffc0206b0c:	8a66                	mv	s4,s9
ffffffffc0206b0e:	40800633          	neg	a2,s0
ffffffffc0206b12:	46a9                	li	a3,10
ffffffffc0206b14:	b53d                	j	ffffffffc0206942 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206b16:	03b05163          	blez	s11,ffffffffc0206b38 <vprintfmt+0x34c>
ffffffffc0206b1a:	02d00693          	li	a3,45
ffffffffc0206b1e:	f6d79de3          	bne	a5,a3,ffffffffc0206a98 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206b22:	00003417          	auipc	s0,0x3
ffffffffc0206b26:	c5640413          	addi	s0,s0,-938 # ffffffffc0209778 <syscalls+0x818>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206b2a:	02800793          	li	a5,40
ffffffffc0206b2e:	02800513          	li	a0,40
ffffffffc0206b32:	00140a13          	addi	s4,s0,1
ffffffffc0206b36:	bd6d                	j	ffffffffc02069f0 <vprintfmt+0x204>
ffffffffc0206b38:	00003a17          	auipc	s4,0x3
ffffffffc0206b3c:	c41a0a13          	addi	s4,s4,-959 # ffffffffc0209779 <syscalls+0x819>
ffffffffc0206b40:	02800513          	li	a0,40
ffffffffc0206b44:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206b48:	05e00413          	li	s0,94
ffffffffc0206b4c:	b565                	j	ffffffffc02069f4 <vprintfmt+0x208>

ffffffffc0206b4e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206b4e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206b50:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206b54:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206b56:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206b58:	ec06                	sd	ra,24(sp)
ffffffffc0206b5a:	f83a                	sd	a4,48(sp)
ffffffffc0206b5c:	fc3e                	sd	a5,56(sp)
ffffffffc0206b5e:	e0c2                	sd	a6,64(sp)
ffffffffc0206b60:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206b62:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206b64:	c89ff0ef          	jal	ra,ffffffffc02067ec <vprintfmt>
}
ffffffffc0206b68:	60e2                	ld	ra,24(sp)
ffffffffc0206b6a:	6161                	addi	sp,sp,80
ffffffffc0206b6c:	8082                	ret

ffffffffc0206b6e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206b6e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206b72:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206b74:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206b76:	cb81                	beqz	a5,ffffffffc0206b86 <strlen+0x18>
        cnt ++;
ffffffffc0206b78:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206b7a:	00a707b3          	add	a5,a4,a0
ffffffffc0206b7e:	0007c783          	lbu	a5,0(a5)
ffffffffc0206b82:	fbfd                	bnez	a5,ffffffffc0206b78 <strlen+0xa>
ffffffffc0206b84:	8082                	ret
    }
    return cnt;
}
ffffffffc0206b86:	8082                	ret

ffffffffc0206b88 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206b88:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206b8a:	e589                	bnez	a1,ffffffffc0206b94 <strnlen+0xc>
ffffffffc0206b8c:	a811                	j	ffffffffc0206ba0 <strnlen+0x18>
        cnt ++;
ffffffffc0206b8e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206b90:	00f58863          	beq	a1,a5,ffffffffc0206ba0 <strnlen+0x18>
ffffffffc0206b94:	00f50733          	add	a4,a0,a5
ffffffffc0206b98:	00074703          	lbu	a4,0(a4)
ffffffffc0206b9c:	fb6d                	bnez	a4,ffffffffc0206b8e <strnlen+0x6>
ffffffffc0206b9e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206ba0:	852e                	mv	a0,a1
ffffffffc0206ba2:	8082                	ret

ffffffffc0206ba4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206ba4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206ba6:	0005c703          	lbu	a4,0(a1)
ffffffffc0206baa:	0785                	addi	a5,a5,1
ffffffffc0206bac:	0585                	addi	a1,a1,1
ffffffffc0206bae:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206bb2:	fb75                	bnez	a4,ffffffffc0206ba6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206bb4:	8082                	ret

ffffffffc0206bb6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206bb6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206bba:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206bbe:	cb89                	beqz	a5,ffffffffc0206bd0 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206bc0:	0505                	addi	a0,a0,1
ffffffffc0206bc2:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206bc4:	fee789e3          	beq	a5,a4,ffffffffc0206bb6 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206bc8:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206bcc:	9d19                	subw	a0,a0,a4
ffffffffc0206bce:	8082                	ret
ffffffffc0206bd0:	4501                	li	a0,0
ffffffffc0206bd2:	bfed                	j	ffffffffc0206bcc <strcmp+0x16>

ffffffffc0206bd4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206bd4:	00054783          	lbu	a5,0(a0)
ffffffffc0206bd8:	c799                	beqz	a5,ffffffffc0206be6 <strchr+0x12>
        if (*s == c) {
ffffffffc0206bda:	00f58763          	beq	a1,a5,ffffffffc0206be8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206bde:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206be2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206be4:	fbfd                	bnez	a5,ffffffffc0206bda <strchr+0x6>
    }
    return NULL;
ffffffffc0206be6:	4501                	li	a0,0
}
ffffffffc0206be8:	8082                	ret

ffffffffc0206bea <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206bea:	ca01                	beqz	a2,ffffffffc0206bfa <memset+0x10>
ffffffffc0206bec:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206bee:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206bf0:	0785                	addi	a5,a5,1
ffffffffc0206bf2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206bf6:	fec79de3          	bne	a5,a2,ffffffffc0206bf0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206bfa:	8082                	ret

ffffffffc0206bfc <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206bfc:	ca19                	beqz	a2,ffffffffc0206c12 <memcpy+0x16>
ffffffffc0206bfe:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206c00:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206c02:	0005c703          	lbu	a4,0(a1)
ffffffffc0206c06:	0585                	addi	a1,a1,1
ffffffffc0206c08:	0785                	addi	a5,a5,1
ffffffffc0206c0a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206c0e:	fec59ae3          	bne	a1,a2,ffffffffc0206c02 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206c12:	8082                	ret
