
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	175010ef          	jal	ffffffffc02019be <memset>
    cons_init();  // init the console
ffffffffc020004e:	3f8000ef          	jal	ffffffffc0200446 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	97e50513          	addi	a0,a0,-1666 # ffffffffc02019d0 <etext>
ffffffffc020005a:	08e000ef          	jal	ffffffffc02000e8 <cputs>

    print_kerninfo();
ffffffffc020005e:	0e8000ef          	jal	ffffffffc0200146 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	3fe000ef          	jal	ffffffffc0200460 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	25e010ef          	jal	ffffffffc02012c4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3f6000ef          	jal	ffffffffc0200460 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	396000ef          	jal	ffffffffc0200404 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e2000ef          	jal	ffffffffc0200454 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3c8000ef          	jal	ffffffffc0200448 <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	430010ef          	jal	ffffffffc02014d6 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	f42e                	sd	a1,40(sp)
ffffffffc02000ba:	f832                	sd	a2,48(sp)
ffffffffc02000bc:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000be:	862a                	mv	a2,a0
ffffffffc02000c0:	004c                	addi	a1,sp,4
ffffffffc02000c2:	00000517          	auipc	a0,0x0
ffffffffc02000c6:	fb650513          	addi	a0,a0,-74 # ffffffffc0200078 <cputch>
ffffffffc02000ca:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	ec06                	sd	ra,24(sp)
ffffffffc02000ce:	e0ba                	sd	a4,64(sp)
ffffffffc02000d0:	e4be                	sd	a5,72(sp)
ffffffffc02000d2:	e8c2                	sd	a6,80(sp)
ffffffffc02000d4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000d8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	3fc010ef          	jal	ffffffffc02014d6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000de:	60e2                	ld	ra,24(sp)
ffffffffc02000e0:	4512                	lw	a0,4(sp)
ffffffffc02000e2:	6125                	addi	sp,sp,96
ffffffffc02000e4:	8082                	ret

ffffffffc02000e6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e6:	a68d                	j	ffffffffc0200448 <cons_putc>

ffffffffc02000e8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000e8:	1101                	addi	sp,sp,-32
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f0:	00054503          	lbu	a0,0(a0)
ffffffffc02000f4:	c905                	beqz	a0,ffffffffc0200124 <cputs+0x3c>
ffffffffc02000f6:	e426                	sd	s1,8(sp)
ffffffffc02000f8:	00178493          	addi	s1,a5,1
ffffffffc02000fc:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc02000fe:	34a000ef          	jal	ffffffffc0200448 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200102:	00044503          	lbu	a0,0(s0)
ffffffffc0200106:	87a2                	mv	a5,s0
ffffffffc0200108:	0405                	addi	s0,s0,1
ffffffffc020010a:	f975                	bnez	a0,ffffffffc02000fe <cputs+0x16>
    (*cnt) ++;
ffffffffc020010c:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc020010e:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc0200110:	0027841b          	addiw	s0,a5,2
ffffffffc0200114:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc0200116:	332000ef          	jal	ffffffffc0200448 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	6105                	addi	sp,sp,32
ffffffffc0200122:	8082                	ret
    cons_putc(c);
ffffffffc0200124:	4529                	li	a0,10
ffffffffc0200126:	322000ef          	jal	ffffffffc0200448 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
}
ffffffffc020012c:	60e2                	ld	ra,24(sp)
ffffffffc020012e:	8522                	mv	a0,s0
ffffffffc0200130:	6442                	ld	s0,16(sp)
ffffffffc0200132:	6105                	addi	sp,sp,32
ffffffffc0200134:	8082                	ret

ffffffffc0200136 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200136:	1141                	addi	sp,sp,-16
ffffffffc0200138:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020013a:	316000ef          	jal	ffffffffc0200450 <cons_getc>
ffffffffc020013e:	dd75                	beqz	a0,ffffffffc020013a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200140:	60a2                	ld	ra,8(sp)
ffffffffc0200142:	0141                	addi	sp,sp,16
ffffffffc0200144:	8082                	ret

ffffffffc0200146 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	00002517          	auipc	a0,0x2
ffffffffc020014c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02019f0 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200150:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200152:	f61ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200156:	00000597          	auipc	a1,0x0
ffffffffc020015a:	edc58593          	addi	a1,a1,-292 # ffffffffc0200032 <kern_init>
ffffffffc020015e:	00002517          	auipc	a0,0x2
ffffffffc0200162:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201a10 <etext+0x40>
ffffffffc0200166:	f4dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020016a:	00002597          	auipc	a1,0x2
ffffffffc020016e:	86658593          	addi	a1,a1,-1946 # ffffffffc02019d0 <etext>
ffffffffc0200172:	00002517          	auipc	a0,0x2
ffffffffc0200176:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201a30 <etext+0x60>
ffffffffc020017a:	f39ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020017e:	00006597          	auipc	a1,0x6
ffffffffc0200182:	e9258593          	addi	a1,a1,-366 # ffffffffc0206010 <free_area>
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201a50 <etext+0x80>
ffffffffc020018e:	f25ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200192:	00006597          	auipc	a1,0x6
ffffffffc0200196:	2de58593          	addi	a1,a1,734 # ffffffffc0206470 <end>
ffffffffc020019a:	00002517          	auipc	a0,0x2
ffffffffc020019e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201a70 <etext+0xa0>
ffffffffc02001a2:	f11ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001a6:	00006797          	auipc	a5,0x6
ffffffffc02001aa:	6c978793          	addi	a5,a5,1737 # ffffffffc020686f <end+0x3ff>
ffffffffc02001ae:	00000717          	auipc	a4,0x0
ffffffffc02001b2:	e8470713          	addi	a4,a4,-380 # ffffffffc0200032 <kern_init>
ffffffffc02001b6:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001bc:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001be:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001c2:	95be                	add	a1,a1,a5
ffffffffc02001c4:	85a9                	srai	a1,a1,0xa
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201a90 <etext+0xc0>
}
ffffffffc02001ce:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d0:	b5cd                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001d2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001d2:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d4:	00002617          	auipc	a2,0x2
ffffffffc02001d8:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0201ac0 <etext+0xf0>
ffffffffc02001dc:	04e00593          	li	a1,78
ffffffffc02001e0:	00002517          	auipc	a0,0x2
ffffffffc02001e4:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201ad8 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001e8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ea:	1bc000ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc02001ee <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ee:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f0:	00002617          	auipc	a2,0x2
ffffffffc02001f4:	90060613          	addi	a2,a2,-1792 # ffffffffc0201af0 <etext+0x120>
ffffffffc02001f8:	00002597          	auipc	a1,0x2
ffffffffc02001fc:	91858593          	addi	a1,a1,-1768 # ffffffffc0201b10 <etext+0x140>
ffffffffc0200200:	00002517          	auipc	a0,0x2
ffffffffc0200204:	91850513          	addi	a0,a0,-1768 # ffffffffc0201b18 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	ea9ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020020e:	00002617          	auipc	a2,0x2
ffffffffc0200212:	91a60613          	addi	a2,a2,-1766 # ffffffffc0201b28 <etext+0x158>
ffffffffc0200216:	00002597          	auipc	a1,0x2
ffffffffc020021a:	93a58593          	addi	a1,a1,-1734 # ffffffffc0201b50 <etext+0x180>
ffffffffc020021e:	00002517          	auipc	a0,0x2
ffffffffc0200222:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201b18 <etext+0x148>
ffffffffc0200226:	e8dff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020022a:	00002617          	auipc	a2,0x2
ffffffffc020022e:	93660613          	addi	a2,a2,-1738 # ffffffffc0201b60 <etext+0x190>
ffffffffc0200232:	00002597          	auipc	a1,0x2
ffffffffc0200236:	94e58593          	addi	a1,a1,-1714 # ffffffffc0201b80 <etext+0x1b0>
ffffffffc020023a:	00002517          	auipc	a0,0x2
ffffffffc020023e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201b18 <etext+0x148>
ffffffffc0200242:	e71ff0ef          	jal	ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200246:	60a2                	ld	ra,8(sp)
ffffffffc0200248:	4501                	li	a0,0
ffffffffc020024a:	0141                	addi	sp,sp,16
ffffffffc020024c:	8082                	ret

ffffffffc020024e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024e:	1141                	addi	sp,sp,-16
ffffffffc0200250:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200252:	ef5ff0ef          	jal	ffffffffc0200146 <print_kerninfo>
    return 0;
}
ffffffffc0200256:	60a2                	ld	ra,8(sp)
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	0141                	addi	sp,sp,16
ffffffffc020025c:	8082                	ret

ffffffffc020025e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025e:	1141                	addi	sp,sp,-16
ffffffffc0200260:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200262:	f71ff0ef          	jal	ffffffffc02001d2 <print_stackframe>
    return 0;
}
ffffffffc0200266:	60a2                	ld	ra,8(sp)
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	0141                	addi	sp,sp,16
ffffffffc020026c:	8082                	ret

ffffffffc020026e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026e:	7115                	addi	sp,sp,-224
ffffffffc0200270:	f15a                	sd	s6,160(sp)
ffffffffc0200272:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200274:	00002517          	auipc	a0,0x2
ffffffffc0200278:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201b90 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc020027c:	ed86                	sd	ra,216(sp)
ffffffffc020027e:	e9a2                	sd	s0,208(sp)
ffffffffc0200280:	e5a6                	sd	s1,200(sp)
ffffffffc0200282:	e1ca                	sd	s2,192(sp)
ffffffffc0200284:	fd4e                	sd	s3,184(sp)
ffffffffc0200286:	f952                	sd	s4,176(sp)
ffffffffc0200288:	f556                	sd	s5,168(sp)
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	e962                	sd	s8,144(sp)
ffffffffc020028e:	e566                	sd	s9,136(sp)
ffffffffc0200290:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200292:	e21ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	92250513          	addi	a0,a0,-1758 # ffffffffc0201bb8 <etext+0x1e8>
ffffffffc020029e:	e15ff0ef          	jal	ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002a2:	000b0563          	beqz	s6,ffffffffc02002ac <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a6:	855a                	mv	a0,s6
ffffffffc02002a8:	396000ef          	jal	ffffffffc020063e <print_trapframe>
ffffffffc02002ac:	00002c17          	auipc	s8,0x2
ffffffffc02002b0:	32cc0c13          	addi	s8,s8,812 # ffffffffc02025d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	92c90913          	addi	s2,s2,-1748 # ffffffffc0201be0 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002bc:	00002497          	auipc	s1,0x2
ffffffffc02002c0:	92c48493          	addi	s1,s1,-1748 # ffffffffc0201be8 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002c4:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	92aa8a93          	addi	s5,s5,-1750 # ffffffffc0201bf0 <etext+0x220>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002d0:	00002b97          	auipc	s7,0x2
ffffffffc02002d4:	940b8b93          	addi	s7,s7,-1728 # ffffffffc0201c10 <etext+0x240>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d8:	854a                	mv	a0,s2
ffffffffc02002da:	576010ef          	jal	ffffffffc0201850 <readline>
ffffffffc02002de:	842a                	mv	s0,a0
ffffffffc02002e0:	dd65                	beqz	a0,ffffffffc02002d8 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e6:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e8:	e59d                	bnez	a1,ffffffffc0200316 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02002ea:	fe0c87e3          	beqz	s9,ffffffffc02002d8 <kmonitor+0x6a>
ffffffffc02002ee:	00002d17          	auipc	s10,0x2
ffffffffc02002f2:	2ead0d13          	addi	s10,s10,746 # ffffffffc02025d8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f6:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f8:	6582                	ld	a1,0(sp)
ffffffffc02002fa:	000d3503          	ld	a0,0(s10)
ffffffffc02002fe:	672010ef          	jal	ffffffffc0201970 <strcmp>
ffffffffc0200302:	c53d                	beqz	a0,ffffffffc0200370 <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	2405                	addiw	s0,s0,1
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	ff4418e3          	bne	s0,s4,ffffffffc02002f8 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020030c:	6582                	ld	a1,0(sp)
ffffffffc020030e:	855e                	mv	a0,s7
ffffffffc0200310:	da3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200314:	b7d1                	j	ffffffffc02002d8 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200316:	8526                	mv	a0,s1
ffffffffc0200318:	690010ef          	jal	ffffffffc02019a8 <strchr>
ffffffffc020031c:	c901                	beqz	a0,ffffffffc020032c <kmonitor+0xbe>
ffffffffc020031e:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200322:	00040023          	sb	zero,0(s0)
ffffffffc0200326:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200328:	d1e9                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc020032a:	b7f5                	j	ffffffffc0200316 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc020032c:	00044783          	lbu	a5,0(s0)
ffffffffc0200330:	dfcd                	beqz	a5,ffffffffc02002ea <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200332:	033c8a63          	beq	s9,s3,ffffffffc0200366 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc0200336:	003c9793          	slli	a5,s9,0x3
ffffffffc020033a:	08078793          	addi	a5,a5,128
ffffffffc020033e:	978a                	add	a5,a5,sp
ffffffffc0200340:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200344:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200348:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020034a:	e591                	bnez	a1,ffffffffc0200356 <kmonitor+0xe8>
ffffffffc020034c:	bf79                	j	ffffffffc02002ea <kmonitor+0x7c>
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200352:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200354:	d9d9                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc0200356:	8526                	mv	a0,s1
ffffffffc0200358:	650010ef          	jal	ffffffffc02019a8 <strchr>
ffffffffc020035c:	d96d                	beqz	a0,ffffffffc020034e <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035e:	00044583          	lbu	a1,0(s0)
ffffffffc0200362:	d5c1                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc0200364:	bf4d                	j	ffffffffc0200316 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	45c1                	li	a1,16
ffffffffc0200368:	8556                	mv	a0,s5
ffffffffc020036a:	d49ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020036e:	b7e1                	j	ffffffffc0200336 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200370:	00141793          	slli	a5,s0,0x1
ffffffffc0200374:	97a2                	add	a5,a5,s0
ffffffffc0200376:	078e                	slli	a5,a5,0x3
ffffffffc0200378:	97e2                	add	a5,a5,s8
ffffffffc020037a:	6b9c                	ld	a5,16(a5)
ffffffffc020037c:	865a                	mv	a2,s6
ffffffffc020037e:	002c                	addi	a1,sp,8
ffffffffc0200380:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200384:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200386:	f40559e3          	bgez	a0,ffffffffc02002d8 <kmonitor+0x6a>
}
ffffffffc020038a:	60ee                	ld	ra,216(sp)
ffffffffc020038c:	644e                	ld	s0,208(sp)
ffffffffc020038e:	64ae                	ld	s1,200(sp)
ffffffffc0200390:	690e                	ld	s2,192(sp)
ffffffffc0200392:	79ea                	ld	s3,184(sp)
ffffffffc0200394:	7a4a                	ld	s4,176(sp)
ffffffffc0200396:	7aaa                	ld	s5,168(sp)
ffffffffc0200398:	7b0a                	ld	s6,160(sp)
ffffffffc020039a:	6bea                	ld	s7,152(sp)
ffffffffc020039c:	6c4a                	ld	s8,144(sp)
ffffffffc020039e:	6caa                	ld	s9,136(sp)
ffffffffc02003a0:	6d0a                	ld	s10,128(sp)
ffffffffc02003a2:	612d                	addi	sp,sp,224
ffffffffc02003a4:	8082                	ret

ffffffffc02003a6 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003a6:	00006317          	auipc	t1,0x6
ffffffffc02003aa:	08230313          	addi	t1,t1,130 # ffffffffc0206428 <is_panic>
ffffffffc02003ae:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b2:	715d                	addi	sp,sp,-80
ffffffffc02003b4:	ec06                	sd	ra,24(sp)
ffffffffc02003b6:	f436                	sd	a3,40(sp)
ffffffffc02003b8:	f83a                	sd	a4,48(sp)
ffffffffc02003ba:	fc3e                	sd	a5,56(sp)
ffffffffc02003bc:	e0c2                	sd	a6,64(sp)
ffffffffc02003be:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c0:	020e1c63          	bnez	t3,ffffffffc02003f8 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003c4:	4785                	li	a5,1
ffffffffc02003c6:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003ca:	e822                	sd	s0,16(sp)
ffffffffc02003cc:	103c                	addi	a5,sp,40
ffffffffc02003ce:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d0:	862e                	mv	a2,a1
ffffffffc02003d2:	85aa                	mv	a1,a0
ffffffffc02003d4:	00002517          	auipc	a0,0x2
ffffffffc02003d8:	85450513          	addi	a0,a0,-1964 # ffffffffc0201c28 <etext+0x258>
    va_start(ap, fmt);
ffffffffc02003dc:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003de:	cd5ff0ef          	jal	ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e2:	65a2                	ld	a1,8(sp)
ffffffffc02003e4:	8522                	mv	a0,s0
ffffffffc02003e6:	cadff0ef          	jal	ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003ea:	00002517          	auipc	a0,0x2
ffffffffc02003ee:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201c48 <etext+0x278>
ffffffffc02003f2:	cc1ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003f8:	062000ef          	jal	ffffffffc020045a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	e71ff0ef          	jal	ffffffffc020026e <kmonitor>
    while (1) {
ffffffffc0200402:	bfed                	j	ffffffffc02003fc <__panic+0x56>

ffffffffc0200404 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200404:	1141                	addi	sp,sp,-16
ffffffffc0200406:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200408:	02000793          	li	a5,32
ffffffffc020040c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200410:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200414:	67e1                	lui	a5,0x18
ffffffffc0200416:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041a:	953e                	add	a0,a0,a5
ffffffffc020041c:	502010ef          	jal	ffffffffc020191e <sbi_set_timer>
}
ffffffffc0200420:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200422:	00006797          	auipc	a5,0x6
ffffffffc0200426:	0007b723          	sd	zero,14(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042a:	00002517          	auipc	a0,0x2
ffffffffc020042e:	82650513          	addi	a0,a0,-2010 # ffffffffc0201c50 <etext+0x280>
}
ffffffffc0200432:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200434:	b9bd                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200436 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200436:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	67e1                	lui	a5,0x18
ffffffffc020043c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4dc0106f          	j	ffffffffc020191e <sbi_set_timer>

ffffffffc0200446 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200446:	8082                	ret

ffffffffc0200448 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200448:	0ff57513          	zext.b	a0,a0
ffffffffc020044c:	4b80106f          	j	ffffffffc0201904 <sbi_console_putchar>

ffffffffc0200450 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200450:	4e80106f          	j	ffffffffc0201938 <sbi_console_getchar>

ffffffffc0200454 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200454:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200458:	8082                	ret

ffffffffc020045a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020045e:	8082                	ret

ffffffffc0200460 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200460:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200464:	00000797          	auipc	a5,0x0
ffffffffc0200468:	2e878793          	addi	a5,a5,744 # ffffffffc020074c <__alltraps>
ffffffffc020046c:	10579073          	csrw	stvec,a5
}
ffffffffc0200470:	8082                	ret

ffffffffc0200472 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200472:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200474:	1141                	addi	sp,sp,-16
ffffffffc0200476:	e022                	sd	s0,0(sp)
ffffffffc0200478:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047a:	00001517          	auipc	a0,0x1
ffffffffc020047e:	7f650513          	addi	a0,a0,2038 # ffffffffc0201c70 <etext+0x2a0>
void print_regs(struct pushregs *gpr) {
ffffffffc0200482:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	c2fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200488:	640c                	ld	a1,8(s0)
ffffffffc020048a:	00001517          	auipc	a0,0x1
ffffffffc020048e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0201c88 <etext+0x2b8>
ffffffffc0200492:	c21ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200496:	680c                	ld	a1,16(s0)
ffffffffc0200498:	00002517          	auipc	a0,0x2
ffffffffc020049c:	80850513          	addi	a0,a0,-2040 # ffffffffc0201ca0 <etext+0x2d0>
ffffffffc02004a0:	c13ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a4:	6c0c                	ld	a1,24(s0)
ffffffffc02004a6:	00002517          	auipc	a0,0x2
ffffffffc02004aa:	81250513          	addi	a0,a0,-2030 # ffffffffc0201cb8 <etext+0x2e8>
ffffffffc02004ae:	c05ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b2:	700c                	ld	a1,32(s0)
ffffffffc02004b4:	00002517          	auipc	a0,0x2
ffffffffc02004b8:	81c50513          	addi	a0,a0,-2020 # ffffffffc0201cd0 <etext+0x300>
ffffffffc02004bc:	bf7ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c0:	740c                	ld	a1,40(s0)
ffffffffc02004c2:	00002517          	auipc	a0,0x2
ffffffffc02004c6:	82650513          	addi	a0,a0,-2010 # ffffffffc0201ce8 <etext+0x318>
ffffffffc02004ca:	be9ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004ce:	780c                	ld	a1,48(s0)
ffffffffc02004d0:	00002517          	auipc	a0,0x2
ffffffffc02004d4:	83050513          	addi	a0,a0,-2000 # ffffffffc0201d00 <etext+0x330>
ffffffffc02004d8:	bdbff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004dc:	7c0c                	ld	a1,56(s0)
ffffffffc02004de:	00002517          	auipc	a0,0x2
ffffffffc02004e2:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201d18 <etext+0x348>
ffffffffc02004e6:	bcdff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ea:	602c                	ld	a1,64(s0)
ffffffffc02004ec:	00002517          	auipc	a0,0x2
ffffffffc02004f0:	84450513          	addi	a0,a0,-1980 # ffffffffc0201d30 <etext+0x360>
ffffffffc02004f4:	bbfff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004f8:	642c                	ld	a1,72(s0)
ffffffffc02004fa:	00002517          	auipc	a0,0x2
ffffffffc02004fe:	84e50513          	addi	a0,a0,-1970 # ffffffffc0201d48 <etext+0x378>
ffffffffc0200502:	bb1ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200506:	682c                	ld	a1,80(s0)
ffffffffc0200508:	00002517          	auipc	a0,0x2
ffffffffc020050c:	85850513          	addi	a0,a0,-1960 # ffffffffc0201d60 <etext+0x390>
ffffffffc0200510:	ba3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200514:	6c2c                	ld	a1,88(s0)
ffffffffc0200516:	00002517          	auipc	a0,0x2
ffffffffc020051a:	86250513          	addi	a0,a0,-1950 # ffffffffc0201d78 <etext+0x3a8>
ffffffffc020051e:	b95ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200522:	702c                	ld	a1,96(s0)
ffffffffc0200524:	00002517          	auipc	a0,0x2
ffffffffc0200528:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201d90 <etext+0x3c0>
ffffffffc020052c:	b87ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200530:	742c                	ld	a1,104(s0)
ffffffffc0200532:	00002517          	auipc	a0,0x2
ffffffffc0200536:	87650513          	addi	a0,a0,-1930 # ffffffffc0201da8 <etext+0x3d8>
ffffffffc020053a:	b79ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020053e:	782c                	ld	a1,112(s0)
ffffffffc0200540:	00002517          	auipc	a0,0x2
ffffffffc0200544:	88050513          	addi	a0,a0,-1920 # ffffffffc0201dc0 <etext+0x3f0>
ffffffffc0200548:	b6bff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020054c:	7c2c                	ld	a1,120(s0)
ffffffffc020054e:	00002517          	auipc	a0,0x2
ffffffffc0200552:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201dd8 <etext+0x408>
ffffffffc0200556:	b5dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055a:	604c                	ld	a1,128(s0)
ffffffffc020055c:	00002517          	auipc	a0,0x2
ffffffffc0200560:	89450513          	addi	a0,a0,-1900 # ffffffffc0201df0 <etext+0x420>
ffffffffc0200564:	b4fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200568:	644c                	ld	a1,136(s0)
ffffffffc020056a:	00002517          	auipc	a0,0x2
ffffffffc020056e:	89e50513          	addi	a0,a0,-1890 # ffffffffc0201e08 <etext+0x438>
ffffffffc0200572:	b41ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200576:	684c                	ld	a1,144(s0)
ffffffffc0200578:	00002517          	auipc	a0,0x2
ffffffffc020057c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0201e20 <etext+0x450>
ffffffffc0200580:	b33ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200584:	6c4c                	ld	a1,152(s0)
ffffffffc0200586:	00002517          	auipc	a0,0x2
ffffffffc020058a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201e38 <etext+0x468>
ffffffffc020058e:	b25ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200592:	704c                	ld	a1,160(s0)
ffffffffc0200594:	00002517          	auipc	a0,0x2
ffffffffc0200598:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0201e50 <etext+0x480>
ffffffffc020059c:	b17ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a0:	744c                	ld	a1,168(s0)
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201e68 <etext+0x498>
ffffffffc02005aa:	b09ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005ae:	784c                	ld	a1,176(s0)
ffffffffc02005b0:	00002517          	auipc	a0,0x2
ffffffffc02005b4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0201e80 <etext+0x4b0>
ffffffffc02005b8:	afbff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005bc:	7c4c                	ld	a1,184(s0)
ffffffffc02005be:	00002517          	auipc	a0,0x2
ffffffffc02005c2:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201e98 <etext+0x4c8>
ffffffffc02005c6:	aedff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ca:	606c                	ld	a1,192(s0)
ffffffffc02005cc:	00002517          	auipc	a0,0x2
ffffffffc02005d0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201eb0 <etext+0x4e0>
ffffffffc02005d4:	adfff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005d8:	646c                	ld	a1,200(s0)
ffffffffc02005da:	00002517          	auipc	a0,0x2
ffffffffc02005de:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201ec8 <etext+0x4f8>
ffffffffc02005e2:	ad1ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005e6:	686c                	ld	a1,208(s0)
ffffffffc02005e8:	00002517          	auipc	a0,0x2
ffffffffc02005ec:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201ee0 <etext+0x510>
ffffffffc02005f0:	ac3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f4:	6c6c                	ld	a1,216(s0)
ffffffffc02005f6:	00002517          	auipc	a0,0x2
ffffffffc02005fa:	90250513          	addi	a0,a0,-1790 # ffffffffc0201ef8 <etext+0x528>
ffffffffc02005fe:	ab5ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200602:	706c                	ld	a1,224(s0)
ffffffffc0200604:	00002517          	auipc	a0,0x2
ffffffffc0200608:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201f10 <etext+0x540>
ffffffffc020060c:	aa7ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200610:	746c                	ld	a1,232(s0)
ffffffffc0200612:	00002517          	auipc	a0,0x2
ffffffffc0200616:	91650513          	addi	a0,a0,-1770 # ffffffffc0201f28 <etext+0x558>
ffffffffc020061a:	a99ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020061e:	786c                	ld	a1,240(s0)
ffffffffc0200620:	00002517          	auipc	a0,0x2
ffffffffc0200624:	92050513          	addi	a0,a0,-1760 # ffffffffc0201f40 <etext+0x570>
ffffffffc0200628:	a8bff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020062c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020062e:	6402                	ld	s0,0(sp)
ffffffffc0200630:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200632:	00002517          	auipc	a0,0x2
ffffffffc0200636:	92650513          	addi	a0,a0,-1754 # ffffffffc0201f58 <etext+0x588>
}
ffffffffc020063a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	bc9d                	j	ffffffffc02000b2 <cprintf>

ffffffffc020063e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020063e:	1141                	addi	sp,sp,-16
ffffffffc0200640:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200642:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200644:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	00002517          	auipc	a0,0x2
ffffffffc020064a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201f70 <etext+0x5a0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020064e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200650:	a63ff0ef          	jal	ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200654:	8522                	mv	a0,s0
ffffffffc0200656:	e1dff0ef          	jal	ffffffffc0200472 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065a:	10043583          	ld	a1,256(s0)
ffffffffc020065e:	00002517          	auipc	a0,0x2
ffffffffc0200662:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201f88 <etext+0x5b8>
ffffffffc0200666:	a4dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066a:	10843583          	ld	a1,264(s0)
ffffffffc020066e:	00002517          	auipc	a0,0x2
ffffffffc0200672:	93250513          	addi	a0,a0,-1742 # ffffffffc0201fa0 <etext+0x5d0>
ffffffffc0200676:	a3dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067a:	11043583          	ld	a1,272(s0)
ffffffffc020067e:	00002517          	auipc	a0,0x2
ffffffffc0200682:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201fb8 <etext+0x5e8>
ffffffffc0200686:	a2dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068a:	11843583          	ld	a1,280(s0)
}
ffffffffc020068e:	6402                	ld	s0,0(sp)
ffffffffc0200690:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200692:	00002517          	auipc	a0,0x2
ffffffffc0200696:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201fd0 <etext+0x600>
}
ffffffffc020069a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069c:	bc19                	j	ffffffffc02000b2 <cprintf>

ffffffffc020069e <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020069e:	11853783          	ld	a5,280(a0)
ffffffffc02006a2:	472d                	li	a4,11
ffffffffc02006a4:	0786                	slli	a5,a5,0x1
ffffffffc02006a6:	8385                	srli	a5,a5,0x1
ffffffffc02006a8:	06f76c63          	bltu	a4,a5,ffffffffc0200720 <interrupt_handler+0x82>
ffffffffc02006ac:	00002717          	auipc	a4,0x2
ffffffffc02006b0:	f7470713          	addi	a4,a4,-140 # ffffffffc0202620 <commands+0x48>
ffffffffc02006b4:	078a                	slli	a5,a5,0x2
ffffffffc02006b6:	97ba                	add	a5,a5,a4
ffffffffc02006b8:	439c                	lw	a5,0(a5)
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006be:	00002517          	auipc	a0,0x2
ffffffffc02006c2:	98a50513          	addi	a0,a0,-1654 # ffffffffc0202048 <etext+0x678>
ffffffffc02006c6:	b2f5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006c8:	00002517          	auipc	a0,0x2
ffffffffc02006cc:	96050513          	addi	a0,a0,-1696 # ffffffffc0202028 <etext+0x658>
ffffffffc02006d0:	b2cd                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d2:	00002517          	auipc	a0,0x2
ffffffffc02006d6:	91650513          	addi	a0,a0,-1770 # ffffffffc0201fe8 <etext+0x618>
ffffffffc02006da:	bae1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006dc:	00002517          	auipc	a0,0x2
ffffffffc02006e0:	98c50513          	addi	a0,a0,-1652 # ffffffffc0202068 <etext+0x698>
ffffffffc02006e4:	b2f9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006e6:	1141                	addi	sp,sp,-16
ffffffffc02006e8:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ea:	d4dff0ef          	jal	ffffffffc0200436 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006ee:	00006697          	auipc	a3,0x6
ffffffffc02006f2:	d4268693          	addi	a3,a3,-702 # ffffffffc0206430 <ticks>
ffffffffc02006f6:	629c                	ld	a5,0(a3)
ffffffffc02006f8:	06400713          	li	a4,100
ffffffffc02006fc:	0785                	addi	a5,a5,1
ffffffffc02006fe:	02e7f733          	remu	a4,a5,a4
ffffffffc0200702:	e29c                	sd	a5,0(a3)
ffffffffc0200704:	cf19                	beqz	a4,ffffffffc0200722 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200706:	60a2                	ld	ra,8(sp)
ffffffffc0200708:	0141                	addi	sp,sp,16
ffffffffc020070a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020070c:	00002517          	auipc	a0,0x2
ffffffffc0200710:	98450513          	addi	a0,a0,-1660 # ffffffffc0202090 <etext+0x6c0>
ffffffffc0200714:	ba79                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200716:	00002517          	auipc	a0,0x2
ffffffffc020071a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0202008 <etext+0x638>
ffffffffc020071e:	ba51                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200720:	bf39                	j	ffffffffc020063e <print_trapframe>
}
ffffffffc0200722:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200724:	06400593          	li	a1,100
ffffffffc0200728:	00002517          	auipc	a0,0x2
ffffffffc020072c:	95850513          	addi	a0,a0,-1704 # ffffffffc0202080 <etext+0x6b0>
}
ffffffffc0200730:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200732:	981ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200736 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200736:	11853783          	ld	a5,280(a0)
ffffffffc020073a:	0007c763          	bltz	a5,ffffffffc0200748 <trap+0x12>
    switch (tf->cause) {
ffffffffc020073e:	472d                	li	a4,11
ffffffffc0200740:	00f76363          	bltu	a4,a5,ffffffffc0200746 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200744:	8082                	ret
            print_trapframe(tf);
ffffffffc0200746:	bde5                	j	ffffffffc020063e <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200748:	bf99                	j	ffffffffc020069e <interrupt_handler>
	...

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f87ff0ef          	jal	ffffffffc0200736 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
}
*/
static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020081e:	c14d                	beqz	a0,ffffffffc02008c0 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200820:	00005617          	auipc	a2,0x5
ffffffffc0200824:	7f060613          	addi	a2,a2,2032 # ffffffffc0206010 <free_area>
ffffffffc0200828:	01062803          	lw	a6,16(a2)
ffffffffc020082c:	86aa                	mv	a3,a0
ffffffffc020082e:	02081793          	slli	a5,a6,0x20
ffffffffc0200832:	9381                	srli	a5,a5,0x20
ffffffffc0200834:	08a7e463          	bltu	a5,a0,ffffffffc02008bc <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200838:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020083a:	0018059b          	addiw	a1,a6,1
ffffffffc020083e:	1582                	slli	a1,a1,0x20
ffffffffc0200840:	9181                	srli	a1,a1,0x20
    struct Page *best_page = NULL;
ffffffffc0200842:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200844:	06c78b63          	beq	a5,a2,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
        if (p->property >= n) {
ffffffffc0200848:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020084c:	00d76763          	bltu	a4,a3,ffffffffc020085a <best_fit_alloc_pages+0x3c>
            if (p->property < min_size) {
ffffffffc0200850:	00b77563          	bgeu	a4,a1,ffffffffc020085a <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200854:	fe878513          	addi	a0,a5,-24
                min_size = p->property;  // 更新最小块大小
ffffffffc0200858:	85ba                	mv	a1,a4
ffffffffc020085a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085c:	fec796e3          	bne	a5,a2,ffffffffc0200848 <best_fit_alloc_pages+0x2a>
    if (best_page != NULL) {
ffffffffc0200860:	cd29                	beqz	a0,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200862:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200864:	6d18                	ld	a4,24(a0)
        if (best_page->property > n) {
ffffffffc0200866:	490c                	lw	a1,16(a0)
            remaining_page->property = best_page->property - n; // 更新剩余页面的属性
ffffffffc0200868:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020086c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020086e:	e398                	sd	a4,0(a5)
        if (best_page->property > n) {
ffffffffc0200870:	02059793          	slli	a5,a1,0x20
ffffffffc0200874:	9381                	srli	a5,a5,0x20
ffffffffc0200876:	02f6f863          	bgeu	a3,a5,ffffffffc02008a6 <best_fit_alloc_pages+0x88>
            struct Page *remaining_page = best_page + n;
ffffffffc020087a:	00269793          	slli	a5,a3,0x2
ffffffffc020087e:	97b6                	add	a5,a5,a3
ffffffffc0200880:	078e                	slli	a5,a5,0x3
ffffffffc0200882:	97aa                	add	a5,a5,a0
            remaining_page->property = best_page->property - n; // 更新剩余页面的属性
ffffffffc0200884:	411585bb          	subw	a1,a1,a7
ffffffffc0200888:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088a:	4689                	li	a3,2
ffffffffc020088c:	00878593          	addi	a1,a5,8
ffffffffc0200890:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200894:	6714                	ld	a3,8(a4)
            list_add(prev, &(remaining_page->page_link)); // 将剩余页面添加回空闲链表
ffffffffc0200896:	01878593          	addi	a1,a5,24
        nr_free -= n;                // 更新空闲页面总数
ffffffffc020089a:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc020089e:	e28c                	sd	a1,0(a3)
ffffffffc02008a0:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008a2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008a4:	ef98                	sd	a4,24(a5)
ffffffffc02008a6:	4118083b          	subw	a6,a6,a7
ffffffffc02008aa:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008ae:	57f5                	li	a5,-3
ffffffffc02008b0:	00850713          	addi	a4,a0,8
ffffffffc02008b4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008b8:	8082                	ret
}
ffffffffc02008ba:	8082                	ret
        return NULL;
ffffffffc02008bc:	4501                	li	a0,0
ffffffffc02008be:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008c0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008c2:	00001697          	auipc	a3,0x1
ffffffffc02008c6:	7ee68693          	addi	a3,a3,2030 # ffffffffc02020b0 <etext+0x6e0>
ffffffffc02008ca:	00001617          	auipc	a2,0x1
ffffffffc02008ce:	7ee60613          	addi	a2,a2,2030 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc02008d2:	06b00593          	li	a1,107
ffffffffc02008d6:	00001517          	auipc	a0,0x1
ffffffffc02008da:	7fa50513          	addi	a0,a0,2042 # ffffffffc02020d0 <etext+0x700>
best_fit_alloc_pages(size_t n) {
ffffffffc02008de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008e0:	ac7ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc02008e4 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02008e4:	715d                	addi	sp,sp,-80
ffffffffc02008e6:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02008e8:	00005417          	auipc	s0,0x5
ffffffffc02008ec:	72840413          	addi	s0,s0,1832 # ffffffffc0206010 <free_area>
ffffffffc02008f0:	641c                	ld	a5,8(s0)
ffffffffc02008f2:	e486                	sd	ra,72(sp)
ffffffffc02008f4:	fc26                	sd	s1,56(sp)
ffffffffc02008f6:	f84a                	sd	s2,48(sp)
ffffffffc02008f8:	f44e                	sd	s3,40(sp)
ffffffffc02008fa:	f052                	sd	s4,32(sp)
ffffffffc02008fc:	ec56                	sd	s5,24(sp)
ffffffffc02008fe:	e85a                	sd	s6,16(sp)
ffffffffc0200900:	e45e                	sd	s7,8(sp)
ffffffffc0200902:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200904:	28878463          	beq	a5,s0,ffffffffc0200b8c <best_fit_check+0x2a8>
    int count = 0, total = 0;
ffffffffc0200908:	4481                	li	s1,0
ffffffffc020090a:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020090c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200910:	8b09                	andi	a4,a4,2
ffffffffc0200912:	28070163          	beqz	a4,ffffffffc0200b94 <best_fit_check+0x2b0>
        count ++, total += p->property;
ffffffffc0200916:	ff87a703          	lw	a4,-8(a5)
ffffffffc020091a:	679c                	ld	a5,8(a5)
ffffffffc020091c:	2905                	addiw	s2,s2,1
ffffffffc020091e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200920:	fe8796e3          	bne	a5,s0,ffffffffc020090c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200924:	89a6                	mv	s3,s1
ffffffffc0200926:	165000ef          	jal	ffffffffc020128a <nr_free_pages>
ffffffffc020092a:	35351563          	bne	a0,s3,ffffffffc0200c74 <best_fit_check+0x390>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020092e:	4505                	li	a0,1
ffffffffc0200930:	0dd000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200934:	8a2a                	mv	s4,a0
ffffffffc0200936:	36050f63          	beqz	a0,ffffffffc0200cb4 <best_fit_check+0x3d0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020093a:	4505                	li	a0,1
ffffffffc020093c:	0d1000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200940:	89aa                	mv	s3,a0
ffffffffc0200942:	34050963          	beqz	a0,ffffffffc0200c94 <best_fit_check+0x3b0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200946:	4505                	li	a0,1
ffffffffc0200948:	0c5000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc020094c:	8aaa                	mv	s5,a0
ffffffffc020094e:	2e050363          	beqz	a0,ffffffffc0200c34 <best_fit_check+0x350>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200952:	273a0163          	beq	s4,s3,ffffffffc0200bb4 <best_fit_check+0x2d0>
ffffffffc0200956:	24aa0f63          	beq	s4,a0,ffffffffc0200bb4 <best_fit_check+0x2d0>
ffffffffc020095a:	24a98d63          	beq	s3,a0,ffffffffc0200bb4 <best_fit_check+0x2d0>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020095e:	000a2783          	lw	a5,0(s4)
ffffffffc0200962:	26079963          	bnez	a5,ffffffffc0200bd4 <best_fit_check+0x2f0>
ffffffffc0200966:	0009a783          	lw	a5,0(s3)
ffffffffc020096a:	26079563          	bnez	a5,ffffffffc0200bd4 <best_fit_check+0x2f0>
ffffffffc020096e:	411c                	lw	a5,0(a0)
ffffffffc0200970:	26079263          	bnez	a5,ffffffffc0200bd4 <best_fit_check+0x2f0>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200974:	fcccd7b7          	lui	a5,0xfcccd
ffffffffc0200978:	ccd78793          	addi	a5,a5,-819 # fffffffffccccccd <end+0x3cac685d>
ffffffffc020097c:	07b2                	slli	a5,a5,0xc
ffffffffc020097e:	ccd78793          	addi	a5,a5,-819
ffffffffc0200982:	07b2                	slli	a5,a5,0xc
ffffffffc0200984:	00006717          	auipc	a4,0x6
ffffffffc0200988:	adc73703          	ld	a4,-1316(a4) # ffffffffc0206460 <pages>
ffffffffc020098c:	ccd78793          	addi	a5,a5,-819
ffffffffc0200990:	40ea06b3          	sub	a3,s4,a4
ffffffffc0200994:	07b2                	slli	a5,a5,0xc
ffffffffc0200996:	868d                	srai	a3,a3,0x3
ffffffffc0200998:	ccd78793          	addi	a5,a5,-819
ffffffffc020099c:	02f686b3          	mul	a3,a3,a5
ffffffffc02009a0:	00002597          	auipc	a1,0x2
ffffffffc02009a4:	e785b583          	ld	a1,-392(a1) # ffffffffc0202818 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009a8:	00006617          	auipc	a2,0x6
ffffffffc02009ac:	ab063603          	ld	a2,-1360(a2) # ffffffffc0206458 <npage>
ffffffffc02009b0:	0632                	slli	a2,a2,0xc
ffffffffc02009b2:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009b4:	06b2                	slli	a3,a3,0xc
ffffffffc02009b6:	22c6ff63          	bgeu	a3,a2,ffffffffc0200bf4 <best_fit_check+0x310>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ba:	40e986b3          	sub	a3,s3,a4
ffffffffc02009be:	868d                	srai	a3,a3,0x3
ffffffffc02009c0:	02f686b3          	mul	a3,a3,a5
ffffffffc02009c4:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02009c6:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009c8:	3ec6f663          	bgeu	a3,a2,ffffffffc0200db4 <best_fit_check+0x4d0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009cc:	40e50733          	sub	a4,a0,a4
ffffffffc02009d0:	870d                	srai	a4,a4,0x3
ffffffffc02009d2:	02f707b3          	mul	a5,a4,a5
ffffffffc02009d6:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02009d8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009da:	3ac7fd63          	bgeu	a5,a2,ffffffffc0200d94 <best_fit_check+0x4b0>
    assert(alloc_page() == NULL);
ffffffffc02009de:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009e0:	00043c03          	ld	s8,0(s0)
ffffffffc02009e4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02009e8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02009ec:	e400                	sd	s0,8(s0)
ffffffffc02009ee:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02009f0:	00005797          	auipc	a5,0x5
ffffffffc02009f4:	6207a823          	sw	zero,1584(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009f8:	015000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc02009fc:	36051c63          	bnez	a0,ffffffffc0200d74 <best_fit_check+0x490>
    free_page(p0);
ffffffffc0200a00:	4585                	li	a1,1
ffffffffc0200a02:	8552                	mv	a0,s4
ffffffffc0200a04:	047000ef          	jal	ffffffffc020124a <free_pages>
    free_page(p1);
ffffffffc0200a08:	4585                	li	a1,1
ffffffffc0200a0a:	854e                	mv	a0,s3
ffffffffc0200a0c:	03f000ef          	jal	ffffffffc020124a <free_pages>
    free_page(p2);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	037000ef          	jal	ffffffffc020124a <free_pages>
    assert(nr_free == 3);
ffffffffc0200a18:	4818                	lw	a4,16(s0)
ffffffffc0200a1a:	478d                	li	a5,3
ffffffffc0200a1c:	32f71c63          	bne	a4,a5,ffffffffc0200d54 <best_fit_check+0x470>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a20:	4505                	li	a0,1
ffffffffc0200a22:	7ea000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a26:	89aa                	mv	s3,a0
ffffffffc0200a28:	30050663          	beqz	a0,ffffffffc0200d34 <best_fit_check+0x450>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a2c:	4505                	li	a0,1
ffffffffc0200a2e:	7de000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a32:	8aaa                	mv	s5,a0
ffffffffc0200a34:	2e050063          	beqz	a0,ffffffffc0200d14 <best_fit_check+0x430>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a38:	4505                	li	a0,1
ffffffffc0200a3a:	7d2000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a3e:	8a2a                	mv	s4,a0
ffffffffc0200a40:	2a050a63          	beqz	a0,ffffffffc0200cf4 <best_fit_check+0x410>
    assert(alloc_page() == NULL);
ffffffffc0200a44:	4505                	li	a0,1
ffffffffc0200a46:	7c6000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a4a:	28051563          	bnez	a0,ffffffffc0200cd4 <best_fit_check+0x3f0>
    free_page(p0);
ffffffffc0200a4e:	4585                	li	a1,1
ffffffffc0200a50:	854e                	mv	a0,s3
ffffffffc0200a52:	7f8000ef          	jal	ffffffffc020124a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a56:	641c                	ld	a5,8(s0)
ffffffffc0200a58:	1a878e63          	beq	a5,s0,ffffffffc0200c14 <best_fit_check+0x330>
    assert((p = alloc_page()) == p0);
ffffffffc0200a5c:	4505                	li	a0,1
ffffffffc0200a5e:	7ae000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a62:	52a99963          	bne	s3,a0,ffffffffc0200f94 <best_fit_check+0x6b0>
    assert(alloc_page() == NULL);
ffffffffc0200a66:	4505                	li	a0,1
ffffffffc0200a68:	7a4000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200a6c:	50051463          	bnez	a0,ffffffffc0200f74 <best_fit_check+0x690>
    assert(nr_free == 0);
ffffffffc0200a70:	481c                	lw	a5,16(s0)
ffffffffc0200a72:	4e079163          	bnez	a5,ffffffffc0200f54 <best_fit_check+0x670>
    free_page(p);
ffffffffc0200a76:	854e                	mv	a0,s3
ffffffffc0200a78:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a7a:	01843023          	sd	s8,0(s0)
ffffffffc0200a7e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a82:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a86:	7c4000ef          	jal	ffffffffc020124a <free_pages>
    free_page(p1);
ffffffffc0200a8a:	4585                	li	a1,1
ffffffffc0200a8c:	8556                	mv	a0,s5
ffffffffc0200a8e:	7bc000ef          	jal	ffffffffc020124a <free_pages>
    free_page(p2);
ffffffffc0200a92:	4585                	li	a1,1
ffffffffc0200a94:	8552                	mv	a0,s4
ffffffffc0200a96:	7b4000ef          	jal	ffffffffc020124a <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a9a:	4515                	li	a0,5
ffffffffc0200a9c:	770000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200aa0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200aa2:	48050963          	beqz	a0,ffffffffc0200f34 <best_fit_check+0x650>
ffffffffc0200aa6:	651c                	ld	a5,8(a0)
ffffffffc0200aa8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200aaa:	8b85                	andi	a5,a5,1
ffffffffc0200aac:	46079463          	bnez	a5,ffffffffc0200f14 <best_fit_check+0x630>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ab0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ab2:	00043a83          	ld	s5,0(s0)
ffffffffc0200ab6:	00843a03          	ld	s4,8(s0)
ffffffffc0200aba:	e000                	sd	s0,0(s0)
ffffffffc0200abc:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200abe:	74e000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200ac2:	42051963          	bnez	a0,ffffffffc0200ef4 <best_fit_check+0x610>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200ac6:	4589                	li	a1,2
ffffffffc0200ac8:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200acc:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200ad0:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200ad4:	00005797          	auipc	a5,0x5
ffffffffc0200ad8:	5407a623          	sw	zero,1356(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200adc:	76e000ef          	jal	ffffffffc020124a <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200ae0:	8562                	mv	a0,s8
ffffffffc0200ae2:	4585                	li	a1,1
ffffffffc0200ae4:	766000ef          	jal	ffffffffc020124a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ae8:	4511                	li	a0,4
ffffffffc0200aea:	722000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200aee:	3e051363          	bnez	a0,ffffffffc0200ed4 <best_fit_check+0x5f0>
ffffffffc0200af2:	0309b783          	ld	a5,48(s3)
ffffffffc0200af6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200af8:	8b85                	andi	a5,a5,1
ffffffffc0200afa:	3a078d63          	beqz	a5,ffffffffc0200eb4 <best_fit_check+0x5d0>
ffffffffc0200afe:	0389a703          	lw	a4,56(s3)
ffffffffc0200b02:	4789                	li	a5,2
ffffffffc0200b04:	3af71863          	bne	a4,a5,ffffffffc0200eb4 <best_fit_check+0x5d0>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b08:	4505                	li	a0,1
ffffffffc0200b0a:	702000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200b0e:	8baa                	mv	s7,a0
ffffffffc0200b10:	38050263          	beqz	a0,ffffffffc0200e94 <best_fit_check+0x5b0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b14:	4509                	li	a0,2
ffffffffc0200b16:	6f6000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200b1a:	34050d63          	beqz	a0,ffffffffc0200e74 <best_fit_check+0x590>
    assert(p0 + 4 == p1);
ffffffffc0200b1e:	337c1b63          	bne	s8,s7,ffffffffc0200e54 <best_fit_check+0x570>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b22:	854e                	mv	a0,s3
ffffffffc0200b24:	4595                	li	a1,5
ffffffffc0200b26:	724000ef          	jal	ffffffffc020124a <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b2a:	4515                	li	a0,5
ffffffffc0200b2c:	6e0000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200b30:	89aa                	mv	s3,a0
ffffffffc0200b32:	30050163          	beqz	a0,ffffffffc0200e34 <best_fit_check+0x550>
    assert(alloc_page() == NULL);
ffffffffc0200b36:	4505                	li	a0,1
ffffffffc0200b38:	6d4000ef          	jal	ffffffffc020120c <alloc_pages>
ffffffffc0200b3c:	2c051c63          	bnez	a0,ffffffffc0200e14 <best_fit_check+0x530>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b40:	481c                	lw	a5,16(s0)
ffffffffc0200b42:	2a079963          	bnez	a5,ffffffffc0200df4 <best_fit_check+0x510>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b46:	4595                	li	a1,5
ffffffffc0200b48:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b4a:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b4e:	01543023          	sd	s5,0(s0)
ffffffffc0200b52:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b56:	6f4000ef          	jal	ffffffffc020124a <free_pages>
    return listelm->next;
ffffffffc0200b5a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b5c:	00878963          	beq	a5,s0,ffffffffc0200b6e <best_fit_check+0x28a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b60:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b64:	679c                	ld	a5,8(a5)
ffffffffc0200b66:	397d                	addiw	s2,s2,-1
ffffffffc0200b68:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b6a:	fe879be3          	bne	a5,s0,ffffffffc0200b60 <best_fit_check+0x27c>
    }
    assert(count == 0);
ffffffffc0200b6e:	26091363          	bnez	s2,ffffffffc0200dd4 <best_fit_check+0x4f0>
    assert(total == 0);
ffffffffc0200b72:	e0ed                	bnez	s1,ffffffffc0200c54 <best_fit_check+0x370>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b74:	60a6                	ld	ra,72(sp)
ffffffffc0200b76:	6406                	ld	s0,64(sp)
ffffffffc0200b78:	74e2                	ld	s1,56(sp)
ffffffffc0200b7a:	7942                	ld	s2,48(sp)
ffffffffc0200b7c:	79a2                	ld	s3,40(sp)
ffffffffc0200b7e:	7a02                	ld	s4,32(sp)
ffffffffc0200b80:	6ae2                	ld	s5,24(sp)
ffffffffc0200b82:	6b42                	ld	s6,16(sp)
ffffffffc0200b84:	6ba2                	ld	s7,8(sp)
ffffffffc0200b86:	6c02                	ld	s8,0(sp)
ffffffffc0200b88:	6161                	addi	sp,sp,80
ffffffffc0200b8a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b8c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b8e:	4481                	li	s1,0
ffffffffc0200b90:	4901                	li	s2,0
ffffffffc0200b92:	bb51                	j	ffffffffc0200926 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b94:	00001697          	auipc	a3,0x1
ffffffffc0200b98:	55468693          	addi	a3,a3,1364 # ffffffffc02020e8 <etext+0x718>
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	51c60613          	addi	a2,a2,1308 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ba4:	14300593          	li	a1,323
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	52850513          	addi	a0,a0,1320 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200bb0:	ff6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bb4:	00001697          	auipc	a3,0x1
ffffffffc0200bb8:	5c468693          	addi	a3,a3,1476 # ffffffffc0202178 <etext+0x7a8>
ffffffffc0200bbc:	00001617          	auipc	a2,0x1
ffffffffc0200bc0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200bc4:	10f00593          	li	a1,271
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	50850513          	addi	a0,a0,1288 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200bd0:	fd6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	5cc68693          	addi	a3,a3,1484 # ffffffffc02021a0 <etext+0x7d0>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	4dc60613          	addi	a2,a2,1244 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200be4:	11000593          	li	a1,272
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	4e850513          	addi	a0,a0,1256 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200bf0:	fb6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	5ec68693          	addi	a3,a3,1516 # ffffffffc02021e0 <etext+0x810>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	4bc60613          	addi	a2,a2,1212 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200c04:	11200593          	li	a1,274
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	4c850513          	addi	a0,a0,1224 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200c10:	f96ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	65468693          	addi	a3,a3,1620 # ffffffffc0202268 <etext+0x898>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	49c60613          	addi	a2,a2,1180 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200c24:	12b00593          	li	a1,299
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	4a850513          	addi	a0,a0,1192 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200c30:	f76ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	52468693          	addi	a3,a3,1316 # ffffffffc0202158 <etext+0x788>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	47c60613          	addi	a2,a2,1148 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200c44:	10d00593          	li	a1,269
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	48850513          	addi	a0,a0,1160 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200c50:	f56ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(total == 0);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	74468693          	addi	a3,a3,1860 # ffffffffc0202398 <etext+0x9c8>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	45c60613          	addi	a2,a2,1116 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200c64:	18500593          	li	a1,389
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	46850513          	addi	a0,a0,1128 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200c70:	f36ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	48468693          	addi	a3,a3,1156 # ffffffffc02020f8 <etext+0x728>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	43c60613          	addi	a2,a2,1084 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200c84:	14600593          	li	a1,326
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	44850513          	addi	a0,a0,1096 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200c90:	f16ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	4a468693          	addi	a3,a3,1188 # ffffffffc0202138 <etext+0x768>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	41c60613          	addi	a2,a2,1052 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ca4:	10c00593          	li	a1,268
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	42850513          	addi	a0,a0,1064 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200cb0:	ef6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	46468693          	addi	a3,a3,1124 # ffffffffc0202118 <etext+0x748>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	3fc60613          	addi	a2,a2,1020 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200cc4:	10b00593          	li	a1,267
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	40850513          	addi	a0,a0,1032 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200cd0:	ed6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	56c68693          	addi	a3,a3,1388 # ffffffffc0202240 <etext+0x870>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	3dc60613          	addi	a2,a2,988 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ce4:	12800593          	li	a1,296
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	3e850513          	addi	a0,a0,1000 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200cf0:	eb6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	46468693          	addi	a3,a3,1124 # ffffffffc0202158 <etext+0x788>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	3bc60613          	addi	a2,a2,956 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200d04:	12600593          	li	a1,294
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	3c850513          	addi	a0,a0,968 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200d10:	e96ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	42468693          	addi	a3,a3,1060 # ffffffffc0202138 <etext+0x768>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	39c60613          	addi	a2,a2,924 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200d24:	12500593          	li	a1,293
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	3a850513          	addi	a0,a0,936 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200d30:	e76ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	3e468693          	addi	a3,a3,996 # ffffffffc0202118 <etext+0x748>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	37c60613          	addi	a2,a2,892 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200d44:	12400593          	li	a1,292
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	38850513          	addi	a0,a0,904 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200d50:	e56ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 3);
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	50468693          	addi	a3,a3,1284 # ffffffffc0202258 <etext+0x888>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	35c60613          	addi	a2,a2,860 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200d64:	12200593          	li	a1,290
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	36850513          	addi	a0,a0,872 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200d70:	e36ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	4cc68693          	addi	a3,a3,1228 # ffffffffc0202240 <etext+0x870>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	33c60613          	addi	a2,a2,828 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200d84:	11d00593          	li	a1,285
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	34850513          	addi	a0,a0,840 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200d90:	e16ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	48c68693          	addi	a3,a3,1164 # ffffffffc0202220 <etext+0x850>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	31c60613          	addi	a2,a2,796 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200da4:	11400593          	li	a1,276
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	32850513          	addi	a0,a0,808 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200db0:	df6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	44c68693          	addi	a3,a3,1100 # ffffffffc0202200 <etext+0x830>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	2fc60613          	addi	a2,a2,764 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200dc4:	11300593          	li	a1,275
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	30850513          	addi	a0,a0,776 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200dd0:	dd6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(count == 0);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	5b468693          	addi	a3,a3,1460 # ffffffffc0202388 <etext+0x9b8>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	2dc60613          	addi	a2,a2,732 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200de4:	18400593          	li	a1,388
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	2e850513          	addi	a0,a0,744 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200df0:	db6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 0);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	4ac68693          	addi	a3,a3,1196 # ffffffffc02022a0 <etext+0x8d0>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	2bc60613          	addi	a2,a2,700 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200e04:	17900593          	li	a1,377
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	2c850513          	addi	a0,a0,712 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200e10:	d96ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	42c68693          	addi	a3,a3,1068 # ffffffffc0202240 <etext+0x870>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	29c60613          	addi	a2,a2,668 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200e24:	17300593          	li	a1,371
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	2a850513          	addi	a0,a0,680 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200e30:	d76ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	53468693          	addi	a3,a3,1332 # ffffffffc0202368 <etext+0x998>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	27c60613          	addi	a2,a2,636 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200e44:	17200593          	li	a1,370
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	28850513          	addi	a0,a0,648 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200e50:	d56ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	50468693          	addi	a3,a3,1284 # ffffffffc0202358 <etext+0x988>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	25c60613          	addi	a2,a2,604 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200e64:	16a00593          	li	a1,362
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	26850513          	addi	a0,a0,616 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200e70:	d36ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	4cc68693          	addi	a3,a3,1228 # ffffffffc0202340 <etext+0x970>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	23c60613          	addi	a2,a2,572 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200e84:	16900593          	li	a1,361
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	24850513          	addi	a0,a0,584 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200e90:	d16ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	48c68693          	addi	a3,a3,1164 # ffffffffc0202320 <etext+0x950>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	21c60613          	addi	a2,a2,540 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ea4:	16800593          	li	a1,360
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	22850513          	addi	a0,a0,552 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200eb0:	cf6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	43c68693          	addi	a3,a3,1084 # ffffffffc02022f0 <etext+0x920>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	1fc60613          	addi	a2,a2,508 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ec4:	16600593          	li	a1,358
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	20850513          	addi	a0,a0,520 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200ed0:	cd6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	40468693          	addi	a3,a3,1028 # ffffffffc02022d8 <etext+0x908>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	1dc60613          	addi	a2,a2,476 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200ee4:	16500593          	li	a1,357
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	1e850513          	addi	a0,a0,488 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200ef0:	cb6ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	34c68693          	addi	a3,a3,844 # ffffffffc0202240 <etext+0x870>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	1bc60613          	addi	a2,a2,444 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200f04:	15900593          	li	a1,345
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	1c850513          	addi	a0,a0,456 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200f10:	c96ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	3ac68693          	addi	a3,a3,940 # ffffffffc02022c0 <etext+0x8f0>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	19c60613          	addi	a2,a2,412 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200f24:	15000593          	li	a1,336
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	1a850513          	addi	a0,a0,424 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200f30:	c76ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 != NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	37c68693          	addi	a3,a3,892 # ffffffffc02022b0 <etext+0x8e0>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	17c60613          	addi	a2,a2,380 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200f44:	14f00593          	li	a1,335
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	18850513          	addi	a0,a0,392 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200f50:	c56ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 0);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	34c68693          	addi	a3,a3,844 # ffffffffc02022a0 <etext+0x8d0>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	15c60613          	addi	a2,a2,348 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200f64:	13100593          	li	a1,305
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	16850513          	addi	a0,a0,360 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200f70:	c36ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	2cc68693          	addi	a3,a3,716 # ffffffffc0202240 <etext+0x870>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	13c60613          	addi	a2,a2,316 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200f84:	12f00593          	li	a1,303
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	14850513          	addi	a0,a0,328 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200f90:	c16ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	2ec68693          	addi	a3,a3,748 # ffffffffc0202280 <etext+0x8b0>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	11c60613          	addi	a2,a2,284 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc0200fa4:	12e00593          	li	a1,302
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	12850513          	addi	a0,a0,296 # ffffffffc02020d0 <etext+0x700>
ffffffffc0200fb0:	bf6ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0200fb4 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fb4:	1141                	addi	sp,sp,-16
ffffffffc0200fb6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fb8:	14058a63          	beqz	a1,ffffffffc020110c <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200fbc:	00259713          	slli	a4,a1,0x2
ffffffffc0200fc0:	972e                	add	a4,a4,a1
ffffffffc0200fc2:	070e                	slli	a4,a4,0x3
ffffffffc0200fc4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200fc8:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200fca:	c30d                	beqz	a4,ffffffffc0200fec <best_fit_free_pages+0x38>
ffffffffc0200fcc:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fce:	8b05                	andi	a4,a4,1
ffffffffc0200fd0:	10071e63          	bnez	a4,ffffffffc02010ec <best_fit_free_pages+0x138>
ffffffffc0200fd4:	6798                	ld	a4,8(a5)
ffffffffc0200fd6:	8b09                	andi	a4,a4,2
ffffffffc0200fd8:	10071a63          	bnez	a4,ffffffffc02010ec <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fdc:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fe0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fe4:	02878793          	addi	a5,a5,40
ffffffffc0200fe8:	fed792e3          	bne	a5,a3,ffffffffc0200fcc <best_fit_free_pages+0x18>
	base->property = n;
ffffffffc0200fec:	2581                	sext.w	a1,a1
ffffffffc0200fee:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);    
ffffffffc0200ff0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ff4:	4789                	li	a5,2
ffffffffc0200ff6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;  
ffffffffc0200ffa:	00005697          	auipc	a3,0x5
ffffffffc0200ffe:	01668693          	addi	a3,a3,22 # ffffffffc0206010 <free_area>
ffffffffc0201002:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201004:	669c                	ld	a5,8(a3)
ffffffffc0201006:	9f2d                	addw	a4,a4,a1
ffffffffc0201008:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020100a:	0ad78563          	beq	a5,a3,ffffffffc02010b4 <best_fit_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc020100e:	fe878713          	addi	a4,a5,-24
ffffffffc0201012:	4581                	li	a1,0
ffffffffc0201014:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201018:	00e56a63          	bltu	a0,a4,ffffffffc020102c <best_fit_free_pages+0x78>
    return listelm->next;
ffffffffc020101c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020101e:	06d70263          	beq	a4,a3,ffffffffc0201082 <best_fit_free_pages+0xce>
    struct Page *p = base;
ffffffffc0201022:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201024:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201028:	fee57ae3          	bgeu	a0,a4,ffffffffc020101c <best_fit_free_pages+0x68>
ffffffffc020102c:	c199                	beqz	a1,ffffffffc0201032 <best_fit_free_pages+0x7e>
ffffffffc020102e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201032:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201034:	e390                	sd	a2,0(a5)
ffffffffc0201036:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201038:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020103a:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020103c:	02d70063          	beq	a4,a3,ffffffffc020105c <best_fit_free_pages+0xa8>
   		if (p + p->property == base) { // 如果前一个页块与当前页块连续
ffffffffc0201040:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201044:	fe870593          	addi	a1,a4,-24
   		if (p + p->property == base) { // 如果前一个页块与当前页块连续
ffffffffc0201048:	02081613          	slli	a2,a6,0x20
ffffffffc020104c:	9201                	srli	a2,a2,0x20
ffffffffc020104e:	00261793          	slli	a5,a2,0x2
ffffffffc0201052:	97b2                	add	a5,a5,a2
ffffffffc0201054:	078e                	slli	a5,a5,0x3
ffffffffc0201056:	97ae                	add	a5,a5,a1
ffffffffc0201058:	02f50f63          	beq	a0,a5,ffffffffc0201096 <best_fit_free_pages+0xe2>
    return listelm->next;
ffffffffc020105c:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020105e:	00d70f63          	beq	a4,a3,ffffffffc020107c <best_fit_free_pages+0xc8>
        if (base + base->property == p) { // 如果当前页块与下一个页块连续
ffffffffc0201062:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201064:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) { // 如果当前页块与下一个页块连续
ffffffffc0201068:	02059613          	slli	a2,a1,0x20
ffffffffc020106c:	9201                	srli	a2,a2,0x20
ffffffffc020106e:	00261793          	slli	a5,a2,0x2
ffffffffc0201072:	97b2                	add	a5,a5,a2
ffffffffc0201074:	078e                	slli	a5,a5,0x3
ffffffffc0201076:	97aa                	add	a5,a5,a0
ffffffffc0201078:	04f68a63          	beq	a3,a5,ffffffffc02010cc <best_fit_free_pages+0x118>
	}
ffffffffc020107c:	60a2                	ld	ra,8(sp)
ffffffffc020107e:	0141                	addi	sp,sp,16
ffffffffc0201080:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201082:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201084:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201086:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201088:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020108a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020108c:	02d70d63          	beq	a4,a3,ffffffffc02010c6 <best_fit_free_pages+0x112>
ffffffffc0201090:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201092:	87ba                	mv	a5,a4
ffffffffc0201094:	bf41                	j	ffffffffc0201024 <best_fit_free_pages+0x70>
            p->property += base->property; // 更新前一个空闲页块的大小
ffffffffc0201096:	491c                	lw	a5,16(a0)
ffffffffc0201098:	010787bb          	addw	a5,a5,a6
ffffffffc020109c:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010a0:	57f5                	li	a5,-3
ffffffffc02010a2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010a6:	6d10                	ld	a2,24(a0)
ffffffffc02010a8:	711c                	ld	a5,32(a0)
            base = p; // 指向前一个空闲页块以便继续合并
ffffffffc02010aa:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02010ac:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010ae:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010b0:	e390                	sd	a2,0(a5)
ffffffffc02010b2:	b775                	j	ffffffffc020105e <best_fit_free_pages+0xaa>
	}
ffffffffc02010b4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02010b6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02010ba:	e398                	sd	a4,0(a5)
ffffffffc02010bc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02010be:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010c0:	ed1c                	sd	a5,24(a0)
	}
ffffffffc02010c2:	0141                	addi	sp,sp,16
ffffffffc02010c4:	8082                	ret
ffffffffc02010c6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010c8:	873e                	mv	a4,a5
ffffffffc02010ca:	bf8d                	j	ffffffffc020103c <best_fit_free_pages+0x88>
            base->property += p->property; // 更新当前页块的大小
ffffffffc02010cc:	ff872783          	lw	a5,-8(a4)
ffffffffc02010d0:	ff070693          	addi	a3,a4,-16
ffffffffc02010d4:	9fad                	addw	a5,a5,a1
ffffffffc02010d6:	c91c                	sw	a5,16(a0)
ffffffffc02010d8:	57f5                	li	a5,-3
ffffffffc02010da:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010de:	6314                	ld	a3,0(a4)
ffffffffc02010e0:	671c                	ld	a5,8(a4)
	}
ffffffffc02010e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010e4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010e6:	e394                	sd	a3,0(a5)
ffffffffc02010e8:	0141                	addi	sp,sp,16
ffffffffc02010ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010ec:	00001697          	auipc	a3,0x1
ffffffffc02010f0:	2bc68693          	addi	a3,a3,700 # ffffffffc02023a8 <etext+0x9d8>
ffffffffc02010f4:	00001617          	auipc	a2,0x1
ffffffffc02010f8:	fc460613          	addi	a2,a2,-60 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc02010fc:	0b500593          	li	a1,181
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	fd050513          	addi	a0,a0,-48 # ffffffffc02020d0 <etext+0x700>
ffffffffc0201108:	a9eff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(n > 0);
ffffffffc020110c:	00001697          	auipc	a3,0x1
ffffffffc0201110:	fa468693          	addi	a3,a3,-92 # ffffffffc02020b0 <etext+0x6e0>
ffffffffc0201114:	00001617          	auipc	a2,0x1
ffffffffc0201118:	fa460613          	addi	a2,a2,-92 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc020111c:	0b200593          	li	a1,178
ffffffffc0201120:	00001517          	auipc	a0,0x1
ffffffffc0201124:	fb050513          	addi	a0,a0,-80 # ffffffffc02020d0 <etext+0x700>
ffffffffc0201128:	a7eff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc020112c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020112c:	1141                	addi	sp,sp,-16
ffffffffc020112e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201130:	cdd5                	beqz	a1,ffffffffc02011ec <best_fit_init_memmap+0xc0>
    for (; p != base + n; p ++) {
ffffffffc0201132:	00259713          	slli	a4,a1,0x2
ffffffffc0201136:	972e                	add	a4,a4,a1
ffffffffc0201138:	070e                	slli	a4,a4,0x3
ffffffffc020113a:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020113e:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201140:	cf11                	beqz	a4,ffffffffc020115c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201142:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201144:	8b05                	andi	a4,a4,1
ffffffffc0201146:	c359                	beqz	a4,ffffffffc02011cc <best_fit_init_memmap+0xa0>
   		p->flags = 0; // 清空标志
ffffffffc0201148:	0007b423          	sd	zero,8(a5)
        p->property = 0; // 清空属性
ffffffffc020114c:	0007a823          	sw	zero,16(a5)
        p->ref = 0; // 设置引用计数为0
ffffffffc0201150:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201154:	02878793          	addi	a5,a5,40
ffffffffc0201158:	fed795e3          	bne	a5,a3,ffffffffc0201142 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020115c:	2581                	sext.w	a1,a1
ffffffffc020115e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201160:	4789                	li	a5,2
ffffffffc0201162:	00850713          	addi	a4,a0,8
ffffffffc0201166:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020116a:	00005697          	auipc	a3,0x5
ffffffffc020116e:	ea668693          	addi	a3,a3,-346 # ffffffffc0206010 <free_area>
ffffffffc0201172:	4a9c                	lw	a5,16(a3)
    return list->next == list;
ffffffffc0201174:	6690                	ld	a2,8(a3)
ffffffffc0201176:	9fad                	addw	a5,a5,a1
ffffffffc0201178:	ca9c                	sw	a5,16(a3)
ffffffffc020117a:	87b2                	mv	a5,a2
    if (list_empty(&free_list)) {
ffffffffc020117c:	02d60e63          	beq	a2,a3,ffffffffc02011b8 <best_fit_init_memmap+0x8c>
            struct Page* page = le2page(le, page_link);
ffffffffc0201180:	fe878713          	addi	a4,a5,-24
       		if (base < page) {
ffffffffc0201184:	00e56e63          	bltu	a0,a4,ffffffffc02011a0 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201188:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020118a:	fed79be3          	bne	a5,a3,ffffffffc0201180 <best_fit_init_memmap+0x54>
}
ffffffffc020118e:	60a2                	ld	ra,8(sp)
        list_add(le, &(base->page_link)); // 添加到链表尾部
ffffffffc0201190:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201194:	e218                	sd	a4,0(a2)
ffffffffc0201196:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201198:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc020119a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020119c:	0141                	addi	sp,sp,16
ffffffffc020119e:	8082                	ret
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011a0:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc02011a2:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc02011a6:	e394                	sd	a3,0(a5)
}
ffffffffc02011a8:	60a2                	ld	ra,8(sp)
ffffffffc02011aa:	e714                	sd	a3,8(a4)
                return;
ffffffffc02011ac:	863e                	mv	a2,a5
ffffffffc02011ae:	87ba                	mv	a5,a4
    elm->next = next;
ffffffffc02011b0:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02011b2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02011b4:	0141                	addi	sp,sp,16
ffffffffc02011b6:	8082                	ret
        list_add(&free_list, &(base->page_link));
ffffffffc02011b8:	01850793          	addi	a5,a0,24
}
ffffffffc02011bc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011be:	e21c                	sd	a5,0(a2)
ffffffffc02011c0:	e61c                	sd	a5,8(a2)
}
ffffffffc02011c2:	87b2                	mv	a5,a2
    elm->next = next;
ffffffffc02011c4:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02011c6:	ed1c                	sd	a5,24(a0)
ffffffffc02011c8:	0141                	addi	sp,sp,16
ffffffffc02011ca:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011cc:	00001697          	auipc	a3,0x1
ffffffffc02011d0:	20468693          	addi	a3,a3,516 # ffffffffc02023d0 <etext+0xa00>
ffffffffc02011d4:	00001617          	auipc	a2,0x1
ffffffffc02011d8:	ee460613          	addi	a2,a2,-284 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc02011dc:	04a00593          	li	a1,74
ffffffffc02011e0:	00001517          	auipc	a0,0x1
ffffffffc02011e4:	ef050513          	addi	a0,a0,-272 # ffffffffc02020d0 <etext+0x700>
ffffffffc02011e8:	9beff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(n > 0);
ffffffffc02011ec:	00001697          	auipc	a3,0x1
ffffffffc02011f0:	ec468693          	addi	a3,a3,-316 # ffffffffc02020b0 <etext+0x6e0>
ffffffffc02011f4:	00001617          	auipc	a2,0x1
ffffffffc02011f8:	ec460613          	addi	a2,a2,-316 # ffffffffc02020b8 <etext+0x6e8>
ffffffffc02011fc:	04700593          	li	a1,71
ffffffffc0201200:	00001517          	auipc	a0,0x1
ffffffffc0201204:	ed050513          	addi	a0,a0,-304 # ffffffffc02020d0 <etext+0x700>
ffffffffc0201208:	99eff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc020120c <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020120c:	100027f3          	csrr	a5,sstatus
ffffffffc0201210:	8b89                	andi	a5,a5,2
ffffffffc0201212:	e799                	bnez	a5,ffffffffc0201220 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201214:	00005797          	auipc	a5,0x5
ffffffffc0201218:	2247b783          	ld	a5,548(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc020121c:	6f9c                	ld	a5,24(a5)
ffffffffc020121e:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201220:	1141                	addi	sp,sp,-16
ffffffffc0201222:	e406                	sd	ra,8(sp)
ffffffffc0201224:	e022                	sd	s0,0(sp)
ffffffffc0201226:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201228:	a32ff0ef          	jal	ffffffffc020045a <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020122c:	00005797          	auipc	a5,0x5
ffffffffc0201230:	20c7b783          	ld	a5,524(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc0201234:	6f9c                	ld	a5,24(a5)
ffffffffc0201236:	8522                	mv	a0,s0
ffffffffc0201238:	9782                	jalr	a5
ffffffffc020123a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020123c:	a18ff0ef          	jal	ffffffffc0200454 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201240:	60a2                	ld	ra,8(sp)
ffffffffc0201242:	8522                	mv	a0,s0
ffffffffc0201244:	6402                	ld	s0,0(sp)
ffffffffc0201246:	0141                	addi	sp,sp,16
ffffffffc0201248:	8082                	ret

ffffffffc020124a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020124a:	100027f3          	csrr	a5,sstatus
ffffffffc020124e:	8b89                	andi	a5,a5,2
ffffffffc0201250:	e799                	bnez	a5,ffffffffc020125e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201252:	00005797          	auipc	a5,0x5
ffffffffc0201256:	1e67b783          	ld	a5,486(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc020125a:	739c                	ld	a5,32(a5)
ffffffffc020125c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020125e:	1101                	addi	sp,sp,-32
ffffffffc0201260:	ec06                	sd	ra,24(sp)
ffffffffc0201262:	e822                	sd	s0,16(sp)
ffffffffc0201264:	e426                	sd	s1,8(sp)
ffffffffc0201266:	842a                	mv	s0,a0
ffffffffc0201268:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020126a:	9f0ff0ef          	jal	ffffffffc020045a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020126e:	00005797          	auipc	a5,0x5
ffffffffc0201272:	1ca7b783          	ld	a5,458(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc0201276:	739c                	ld	a5,32(a5)
ffffffffc0201278:	85a6                	mv	a1,s1
ffffffffc020127a:	8522                	mv	a0,s0
ffffffffc020127c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020127e:	6442                	ld	s0,16(sp)
ffffffffc0201280:	60e2                	ld	ra,24(sp)
ffffffffc0201282:	64a2                	ld	s1,8(sp)
ffffffffc0201284:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201286:	9ceff06f          	j	ffffffffc0200454 <intr_enable>

ffffffffc020128a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020128a:	100027f3          	csrr	a5,sstatus
ffffffffc020128e:	8b89                	andi	a5,a5,2
ffffffffc0201290:	e799                	bnez	a5,ffffffffc020129e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201292:	00005797          	auipc	a5,0x5
ffffffffc0201296:	1a67b783          	ld	a5,422(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc020129a:	779c                	ld	a5,40(a5)
ffffffffc020129c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020129e:	1141                	addi	sp,sp,-16
ffffffffc02012a0:	e406                	sd	ra,8(sp)
ffffffffc02012a2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012a4:	9b6ff0ef          	jal	ffffffffc020045a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012a8:	00005797          	auipc	a5,0x5
ffffffffc02012ac:	1907b783          	ld	a5,400(a5) # ffffffffc0206438 <pmm_manager>
ffffffffc02012b0:	779c                	ld	a5,40(a5)
ffffffffc02012b2:	9782                	jalr	a5
ffffffffc02012b4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012b6:	99eff0ef          	jal	ffffffffc0200454 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012ba:	60a2                	ld	ra,8(sp)
ffffffffc02012bc:	8522                	mv	a0,s0
ffffffffc02012be:	6402                	ld	s0,0(sp)
ffffffffc02012c0:	0141                	addi	sp,sp,16
ffffffffc02012c2:	8082                	ret

ffffffffc02012c4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012c4:	00001797          	auipc	a5,0x1
ffffffffc02012c8:	38c78793          	addi	a5,a5,908 # ffffffffc0202650 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012cc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012ce:	1101                	addi	sp,sp,-32
ffffffffc02012d0:	ec06                	sd	ra,24(sp)
ffffffffc02012d2:	e822                	sd	s0,16(sp)
ffffffffc02012d4:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d6:	00001517          	auipc	a0,0x1
ffffffffc02012da:	12250513          	addi	a0,a0,290 # ffffffffc02023f8 <etext+0xa28>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012de:	00005497          	auipc	s1,0x5
ffffffffc02012e2:	15a48493          	addi	s1,s1,346 # ffffffffc0206438 <pmm_manager>
ffffffffc02012e6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012e8:	dcbfe0ef          	jal	ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02012ec:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012ee:	00005417          	auipc	s0,0x5
ffffffffc02012f2:	16240413          	addi	s0,s0,354 # ffffffffc0206450 <va_pa_offset>
    pmm_manager->init();
ffffffffc02012f6:	679c                	ld	a5,8(a5)
ffffffffc02012f8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012fa:	57f5                	li	a5,-3
ffffffffc02012fc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	11250513          	addi	a0,a0,274 # ffffffffc0202410 <etext+0xa40>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201306:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201308:	dabfe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020130c:	46c5                	li	a3,17
ffffffffc020130e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201310:	40100613          	li	a2,1025
ffffffffc0201314:	16fd                	addi	a3,a3,-1
ffffffffc0201316:	0656                	slli	a2,a2,0x15
ffffffffc0201318:	07e005b7          	lui	a1,0x7e00
ffffffffc020131c:	00001517          	auipc	a0,0x1
ffffffffc0201320:	10c50513          	addi	a0,a0,268 # ffffffffc0202428 <etext+0xa58>
ffffffffc0201324:	d8ffe0ef          	jal	ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201328:	777d                	lui	a4,0xfffff
ffffffffc020132a:	00006797          	auipc	a5,0x6
ffffffffc020132e:	14578793          	addi	a5,a5,325 # ffffffffc020746f <end+0xfff>
ffffffffc0201332:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201334:	00005517          	auipc	a0,0x5
ffffffffc0201338:	12450513          	addi	a0,a0,292 # ffffffffc0206458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020133c:	00005597          	auipc	a1,0x5
ffffffffc0201340:	12458593          	addi	a1,a1,292 # ffffffffc0206460 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201344:	00088737          	lui	a4,0x88
ffffffffc0201348:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020134a:	e19c                	sd	a5,0(a1)
ffffffffc020134c:	4705                	li	a4,1
ffffffffc020134e:	07a1                	addi	a5,a5,8
ffffffffc0201350:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201354:	02800693          	li	a3,40
ffffffffc0201358:	4885                	li	a7,1
ffffffffc020135a:	fff80837          	lui	a6,0xfff80
        SetPageReserved(pages + i);
ffffffffc020135e:	619c                	ld	a5,0(a1)
ffffffffc0201360:	97b6                	add	a5,a5,a3
ffffffffc0201362:	07a1                	addi	a5,a5,8
ffffffffc0201364:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201368:	611c                	ld	a5,0(a0)
ffffffffc020136a:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc020136c:	02868693          	addi	a3,a3,40
ffffffffc0201370:	01078633          	add	a2,a5,a6
ffffffffc0201374:	fec765e3          	bltu	a4,a2,ffffffffc020135e <pmm_init+0x9a>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201378:	6190                	ld	a2,0(a1)
ffffffffc020137a:	00279693          	slli	a3,a5,0x2
ffffffffc020137e:	96be                	add	a3,a3,a5
ffffffffc0201380:	fec00737          	lui	a4,0xfec00
ffffffffc0201384:	9732                	add	a4,a4,a2
ffffffffc0201386:	068e                	slli	a3,a3,0x3
ffffffffc0201388:	96ba                	add	a3,a3,a4
ffffffffc020138a:	c0200737          	lui	a4,0xc0200
ffffffffc020138e:	0ae6e463          	bltu	a3,a4,ffffffffc0201436 <pmm_init+0x172>
ffffffffc0201392:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201394:	45c5                	li	a1,17
ffffffffc0201396:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201398:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020139a:	04b6e963          	bltu	a3,a1,ffffffffc02013ec <pmm_init+0x128>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020139e:	609c                	ld	a5,0(s1)
ffffffffc02013a0:	7b9c                	ld	a5,48(a5)
ffffffffc02013a2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013a4:	00001517          	auipc	a0,0x1
ffffffffc02013a8:	11c50513          	addi	a0,a0,284 # ffffffffc02024c0 <etext+0xaf0>
ffffffffc02013ac:	d07fe0ef          	jal	ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013b0:	00004597          	auipc	a1,0x4
ffffffffc02013b4:	c5058593          	addi	a1,a1,-944 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013b8:	00005797          	auipc	a5,0x5
ffffffffc02013bc:	08b7b823          	sd	a1,144(a5) # ffffffffc0206448 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02013c4:	08f5e563          	bltu	a1,a5,ffffffffc020144e <pmm_init+0x18a>
ffffffffc02013c8:	601c                	ld	a5,0(s0)
}
ffffffffc02013ca:	6442                	ld	s0,16(sp)
ffffffffc02013cc:	60e2                	ld	ra,24(sp)
ffffffffc02013ce:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013d0:	40f586b3          	sub	a3,a1,a5
ffffffffc02013d4:	00005797          	auipc	a5,0x5
ffffffffc02013d8:	06d7b623          	sd	a3,108(a5) # ffffffffc0206440 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013dc:	00001517          	auipc	a0,0x1
ffffffffc02013e0:	10450513          	addi	a0,a0,260 # ffffffffc02024e0 <etext+0xb10>
ffffffffc02013e4:	8636                	mv	a2,a3
}
ffffffffc02013e6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e8:	ccbfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013ec:	6705                	lui	a4,0x1
ffffffffc02013ee:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02013f0:	96ba                	add	a3,a3,a4
ffffffffc02013f2:	777d                	lui	a4,0xfffff
ffffffffc02013f4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013f6:	00c6d713          	srli	a4,a3,0xc
ffffffffc02013fa:	02f77263          	bgeu	a4,a5,ffffffffc020141e <pmm_init+0x15a>
    pmm_manager->init_memmap(base, n);
ffffffffc02013fe:	0004b803          	ld	a6,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201402:	fff807b7          	lui	a5,0xfff80
ffffffffc0201406:	97ba                	add	a5,a5,a4
ffffffffc0201408:	00279513          	slli	a0,a5,0x2
ffffffffc020140c:	953e                	add	a0,a0,a5
ffffffffc020140e:	01083783          	ld	a5,16(a6) # fffffffffff80010 <end+0x3fd79ba0>
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201412:	8d95                	sub	a1,a1,a3
ffffffffc0201414:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201416:	81b1                	srli	a1,a1,0xc
ffffffffc0201418:	9532                	add	a0,a0,a2
ffffffffc020141a:	9782                	jalr	a5
}
ffffffffc020141c:	b749                	j	ffffffffc020139e <pmm_init+0xda>
        panic("pa2page called with invalid pa");
ffffffffc020141e:	00001617          	auipc	a2,0x1
ffffffffc0201422:	07260613          	addi	a2,a2,114 # ffffffffc0202490 <etext+0xac0>
ffffffffc0201426:	06b00593          	li	a1,107
ffffffffc020142a:	00001517          	auipc	a0,0x1
ffffffffc020142e:	08650513          	addi	a0,a0,134 # ffffffffc02024b0 <etext+0xae0>
ffffffffc0201432:	f75fe0ef          	jal	ffffffffc02003a6 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201436:	00001617          	auipc	a2,0x1
ffffffffc020143a:	02260613          	addi	a2,a2,34 # ffffffffc0202458 <etext+0xa88>
ffffffffc020143e:	06e00593          	li	a1,110
ffffffffc0201442:	00001517          	auipc	a0,0x1
ffffffffc0201446:	03e50513          	addi	a0,a0,62 # ffffffffc0202480 <etext+0xab0>
ffffffffc020144a:	f5dfe0ef          	jal	ffffffffc02003a6 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020144e:	86ae                	mv	a3,a1
ffffffffc0201450:	00001617          	auipc	a2,0x1
ffffffffc0201454:	00860613          	addi	a2,a2,8 # ffffffffc0202458 <etext+0xa88>
ffffffffc0201458:	08900593          	li	a1,137
ffffffffc020145c:	00001517          	auipc	a0,0x1
ffffffffc0201460:	02450513          	addi	a0,a0,36 # ffffffffc0202480 <etext+0xab0>
ffffffffc0201464:	f43fe0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0201468 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201468:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020146c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020146e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201472:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201474:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201478:	f022                	sd	s0,32(sp)
ffffffffc020147a:	ec26                	sd	s1,24(sp)
ffffffffc020147c:	e84a                	sd	s2,16(sp)
ffffffffc020147e:	f406                	sd	ra,40(sp)
ffffffffc0201480:	84aa                	mv	s1,a0
ffffffffc0201482:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201484:	fff7041b          	addiw	s0,a4,-1 # ffffffffffffefff <end+0x3fdf8b8f>
    unsigned mod = do_div(result, base);
ffffffffc0201488:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020148a:	05067063          	bgeu	a2,a6,ffffffffc02014ca <printnum+0x62>
ffffffffc020148e:	e44e                	sd	s3,8(sp)
ffffffffc0201490:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201492:	4785                	li	a5,1
ffffffffc0201494:	00e7d763          	bge	a5,a4,ffffffffc02014a2 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0201498:	85ca                	mv	a1,s2
ffffffffc020149a:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020149c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020149e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014a0:	fc65                	bnez	s0,ffffffffc0201498 <printnum+0x30>
ffffffffc02014a2:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a4:	1a02                	slli	s4,s4,0x20
ffffffffc02014a6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014aa:	00001797          	auipc	a5,0x1
ffffffffc02014ae:	07678793          	addi	a5,a5,118 # ffffffffc0202520 <etext+0xb50>
ffffffffc02014b2:	97d2                	add	a5,a5,s4
}
ffffffffc02014b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014b6:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02014ba:	70a2                	ld	ra,40(sp)
ffffffffc02014bc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014be:	85ca                	mv	a1,s2
ffffffffc02014c0:	87a6                	mv	a5,s1
}
ffffffffc02014c2:	6942                	ld	s2,16(sp)
ffffffffc02014c4:	64e2                	ld	s1,24(sp)
ffffffffc02014c6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014c8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014ca:	03065633          	divu	a2,a2,a6
ffffffffc02014ce:	8722                	mv	a4,s0
ffffffffc02014d0:	f99ff0ef          	jal	ffffffffc0201468 <printnum>
ffffffffc02014d4:	bfc1                	j	ffffffffc02014a4 <printnum+0x3c>

ffffffffc02014d6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014d6:	7119                	addi	sp,sp,-128
ffffffffc02014d8:	f4a6                	sd	s1,104(sp)
ffffffffc02014da:	f0ca                	sd	s2,96(sp)
ffffffffc02014dc:	ecce                	sd	s3,88(sp)
ffffffffc02014de:	e8d2                	sd	s4,80(sp)
ffffffffc02014e0:	e4d6                	sd	s5,72(sp)
ffffffffc02014e2:	e0da                	sd	s6,64(sp)
ffffffffc02014e4:	f862                	sd	s8,48(sp)
ffffffffc02014e6:	fc86                	sd	ra,120(sp)
ffffffffc02014e8:	f8a2                	sd	s0,112(sp)
ffffffffc02014ea:	fc5e                	sd	s7,56(sp)
ffffffffc02014ec:	f466                	sd	s9,40(sp)
ffffffffc02014ee:	f06a                	sd	s10,32(sp)
ffffffffc02014f0:	ec6e                	sd	s11,24(sp)
ffffffffc02014f2:	892a                	mv	s2,a0
ffffffffc02014f4:	84ae                	mv	s1,a1
ffffffffc02014f6:	8c32                	mv	s8,a2
ffffffffc02014f8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014fa:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014fe:	05500b13          	li	s6,85
ffffffffc0201502:	00001a97          	auipc	s5,0x1
ffffffffc0201506:	186a8a93          	addi	s5,s5,390 # ffffffffc0202688 <best_fit_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020150a:	000c4503          	lbu	a0,0(s8)
ffffffffc020150e:	001c0413          	addi	s0,s8,1
ffffffffc0201512:	01350a63          	beq	a0,s3,ffffffffc0201526 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0201516:	cd0d                	beqz	a0,ffffffffc0201550 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0201518:	85a6                	mv	a1,s1
ffffffffc020151a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020151c:	00044503          	lbu	a0,0(s0)
ffffffffc0201520:	0405                	addi	s0,s0,1
ffffffffc0201522:	ff351ae3          	bne	a0,s3,ffffffffc0201516 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc0201526:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc020152a:	4b81                	li	s7,0
ffffffffc020152c:	4601                	li	a2,0
        width = precision = -1;
ffffffffc020152e:	5d7d                	li	s10,-1
ffffffffc0201530:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201532:	00044683          	lbu	a3,0(s0)
ffffffffc0201536:	00140c13          	addi	s8,s0,1
ffffffffc020153a:	fdd6859b          	addiw	a1,a3,-35
ffffffffc020153e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201542:	02bb6663          	bltu	s6,a1,ffffffffc020156e <vprintfmt+0x98>
ffffffffc0201546:	058a                	slli	a1,a1,0x2
ffffffffc0201548:	95d6                	add	a1,a1,s5
ffffffffc020154a:	4198                	lw	a4,0(a1)
ffffffffc020154c:	9756                	add	a4,a4,s5
ffffffffc020154e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201550:	70e6                	ld	ra,120(sp)
ffffffffc0201552:	7446                	ld	s0,112(sp)
ffffffffc0201554:	74a6                	ld	s1,104(sp)
ffffffffc0201556:	7906                	ld	s2,96(sp)
ffffffffc0201558:	69e6                	ld	s3,88(sp)
ffffffffc020155a:	6a46                	ld	s4,80(sp)
ffffffffc020155c:	6aa6                	ld	s5,72(sp)
ffffffffc020155e:	6b06                	ld	s6,64(sp)
ffffffffc0201560:	7be2                	ld	s7,56(sp)
ffffffffc0201562:	7c42                	ld	s8,48(sp)
ffffffffc0201564:	7ca2                	ld	s9,40(sp)
ffffffffc0201566:	7d02                	ld	s10,32(sp)
ffffffffc0201568:	6de2                	ld	s11,24(sp)
ffffffffc020156a:	6109                	addi	sp,sp,128
ffffffffc020156c:	8082                	ret
            putch('%', putdat);
ffffffffc020156e:	85a6                	mv	a1,s1
ffffffffc0201570:	02500513          	li	a0,37
ffffffffc0201574:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201576:	fff44703          	lbu	a4,-1(s0)
ffffffffc020157a:	02500793          	li	a5,37
ffffffffc020157e:	8c22                	mv	s8,s0
ffffffffc0201580:	f8f705e3          	beq	a4,a5,ffffffffc020150a <vprintfmt+0x34>
ffffffffc0201584:	02500713          	li	a4,37
ffffffffc0201588:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020158c:	1c7d                	addi	s8,s8,-1
ffffffffc020158e:	fee79de3          	bne	a5,a4,ffffffffc0201588 <vprintfmt+0xb2>
ffffffffc0201592:	bfa5                	j	ffffffffc020150a <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201594:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201598:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc020159a:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020159e:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc02015a2:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015a6:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc02015a8:	02b76563          	bltu	a4,a1,ffffffffc02015d2 <vprintfmt+0xfc>
ffffffffc02015ac:	4525                	li	a0,9
                ch = *fmt;
ffffffffc02015ae:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015b2:	002d171b          	slliw	a4,s10,0x2
ffffffffc02015b6:	01a7073b          	addw	a4,a4,s10
ffffffffc02015ba:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015be:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc02015c0:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015c4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015c6:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc02015ca:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc02015ce:	feb570e3          	bgeu	a0,a1,ffffffffc02015ae <vprintfmt+0xd8>
            if (width < 0)
ffffffffc02015d2:	f60cd0e3          	bgez	s9,ffffffffc0201532 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02015d6:	8cea                	mv	s9,s10
ffffffffc02015d8:	5d7d                	li	s10,-1
ffffffffc02015da:	bfa1                	j	ffffffffc0201532 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015dc:	8db6                	mv	s11,a3
ffffffffc02015de:	8462                	mv	s0,s8
ffffffffc02015e0:	bf89                	j	ffffffffc0201532 <vprintfmt+0x5c>
ffffffffc02015e2:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc02015e4:	4b85                	li	s7,1
            goto reswitch;
ffffffffc02015e6:	b7b1                	j	ffffffffc0201532 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02015e8:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02015ea:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02015ee:	00c7c463          	blt	a5,a2,ffffffffc02015f6 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc02015f2:	1a060163          	beqz	a2,ffffffffc0201794 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc02015f6:	000a3603          	ld	a2,0(s4)
ffffffffc02015fa:	46c1                	li	a3,16
ffffffffc02015fc:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02015fe:	000d879b          	sext.w	a5,s11
ffffffffc0201602:	8766                	mv	a4,s9
ffffffffc0201604:	85a6                	mv	a1,s1
ffffffffc0201606:	854a                	mv	a0,s2
ffffffffc0201608:	e61ff0ef          	jal	ffffffffc0201468 <printnum>
            break;
ffffffffc020160c:	bdfd                	j	ffffffffc020150a <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020160e:	000a2503          	lw	a0,0(s4)
ffffffffc0201612:	85a6                	mv	a1,s1
ffffffffc0201614:	0a21                	addi	s4,s4,8
ffffffffc0201616:	9902                	jalr	s2
            break;
ffffffffc0201618:	bdcd                	j	ffffffffc020150a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020161a:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020161c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201620:	00c7c463          	blt	a5,a2,ffffffffc0201628 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc0201624:	16060363          	beqz	a2,ffffffffc020178a <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0201628:	000a3603          	ld	a2,0(s4)
ffffffffc020162c:	46a9                	li	a3,10
ffffffffc020162e:	8a3a                	mv	s4,a4
ffffffffc0201630:	b7f9                	j	ffffffffc02015fe <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc0201632:	85a6                	mv	a1,s1
ffffffffc0201634:	03000513          	li	a0,48
ffffffffc0201638:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020163a:	85a6                	mv	a1,s1
ffffffffc020163c:	07800513          	li	a0,120
ffffffffc0201640:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201642:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0201646:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201648:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020164a:	bf55                	j	ffffffffc02015fe <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc020164c:	85a6                	mv	a1,s1
ffffffffc020164e:	02500513          	li	a0,37
ffffffffc0201652:	9902                	jalr	s2
            break;
ffffffffc0201654:	bd5d                	j	ffffffffc020150a <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201656:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020165c:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020165e:	bf95                	j	ffffffffc02015d2 <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc0201660:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201662:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201666:	00c7c463          	blt	a5,a2,ffffffffc020166e <vprintfmt+0x198>
    else if (lflag) {
ffffffffc020166a:	10060b63          	beqz	a2,ffffffffc0201780 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc020166e:	000a3603          	ld	a2,0(s4)
ffffffffc0201672:	46a1                	li	a3,8
ffffffffc0201674:	8a3a                	mv	s4,a4
ffffffffc0201676:	b761                	j	ffffffffc02015fe <vprintfmt+0x128>
            if (width < 0)
ffffffffc0201678:	fffcc793          	not	a5,s9
ffffffffc020167c:	97fd                	srai	a5,a5,0x3f
ffffffffc020167e:	00fcf7b3          	and	a5,s9,a5
ffffffffc0201682:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201686:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201688:	b56d                	j	ffffffffc0201532 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020168a:	000a3403          	ld	s0,0(s4)
ffffffffc020168e:	008a0793          	addi	a5,s4,8
ffffffffc0201692:	e43e                	sd	a5,8(sp)
ffffffffc0201694:	12040063          	beqz	s0,ffffffffc02017b4 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201698:	0d905963          	blez	s9,ffffffffc020176a <vprintfmt+0x294>
ffffffffc020169c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016a0:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc02016a4:	12fd9763          	bne	s11,a5,ffffffffc02017d2 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016a8:	00044783          	lbu	a5,0(s0)
ffffffffc02016ac:	0007851b          	sext.w	a0,a5
ffffffffc02016b0:	cb9d                	beqz	a5,ffffffffc02016e6 <vprintfmt+0x210>
ffffffffc02016b2:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016b4:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016b8:	000d4563          	bltz	s10,ffffffffc02016c2 <vprintfmt+0x1ec>
ffffffffc02016bc:	3d7d                	addiw	s10,s10,-1
ffffffffc02016be:	028d0263          	beq	s10,s0,ffffffffc02016e2 <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc02016c2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016c4:	0c0b8d63          	beqz	s7,ffffffffc020179e <vprintfmt+0x2c8>
ffffffffc02016c8:	3781                	addiw	a5,a5,-32
ffffffffc02016ca:	0cfdfa63          	bgeu	s11,a5,ffffffffc020179e <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc02016ce:	03f00513          	li	a0,63
ffffffffc02016d2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016d4:	000a4783          	lbu	a5,0(s4)
ffffffffc02016d8:	3cfd                	addiw	s9,s9,-1
ffffffffc02016da:	0a05                	addi	s4,s4,1
ffffffffc02016dc:	0007851b          	sext.w	a0,a5
ffffffffc02016e0:	ffe1                	bnez	a5,ffffffffc02016b8 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc02016e2:	01905963          	blez	s9,ffffffffc02016f4 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc02016e6:	85a6                	mv	a1,s1
ffffffffc02016e8:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02016ec:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc02016ee:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02016f0:	fe0c9be3          	bnez	s9,ffffffffc02016e6 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016f4:	6a22                	ld	s4,8(sp)
ffffffffc02016f6:	bd11                	j	ffffffffc020150a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02016f8:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02016fa:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02016fe:	00c7c363          	blt	a5,a2,ffffffffc0201704 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc0201702:	ce25                	beqz	a2,ffffffffc020177a <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0201704:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201708:	08044d63          	bltz	s0,ffffffffc02017a2 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc020170c:	8622                	mv	a2,s0
ffffffffc020170e:	8a5e                	mv	s4,s7
ffffffffc0201710:	46a9                	li	a3,10
ffffffffc0201712:	b5f5                	j	ffffffffc02015fe <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0201714:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201718:	4619                	li	a2,6
            if (err < 0) {
ffffffffc020171a:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020171e:	8fb9                	xor	a5,a5,a4
ffffffffc0201720:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201724:	02d64663          	blt	a2,a3,ffffffffc0201750 <vprintfmt+0x27a>
ffffffffc0201728:	00369713          	slli	a4,a3,0x3
ffffffffc020172c:	00001797          	auipc	a5,0x1
ffffffffc0201730:	0b478793          	addi	a5,a5,180 # ffffffffc02027e0 <error_string>
ffffffffc0201734:	97ba                	add	a5,a5,a4
ffffffffc0201736:	639c                	ld	a5,0(a5)
ffffffffc0201738:	cf81                	beqz	a5,ffffffffc0201750 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020173a:	86be                	mv	a3,a5
ffffffffc020173c:	00001617          	auipc	a2,0x1
ffffffffc0201740:	e1460613          	addi	a2,a2,-492 # ffffffffc0202550 <etext+0xb80>
ffffffffc0201744:	85a6                	mv	a1,s1
ffffffffc0201746:	854a                	mv	a0,s2
ffffffffc0201748:	0e8000ef          	jal	ffffffffc0201830 <printfmt>
            err = va_arg(ap, int);
ffffffffc020174c:	0a21                	addi	s4,s4,8
ffffffffc020174e:	bb75                	j	ffffffffc020150a <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201750:	00001617          	auipc	a2,0x1
ffffffffc0201754:	df060613          	addi	a2,a2,-528 # ffffffffc0202540 <etext+0xb70>
ffffffffc0201758:	85a6                	mv	a1,s1
ffffffffc020175a:	854a                	mv	a0,s2
ffffffffc020175c:	0d4000ef          	jal	ffffffffc0201830 <printfmt>
            err = va_arg(ap, int);
ffffffffc0201760:	0a21                	addi	s4,s4,8
ffffffffc0201762:	b365                	j	ffffffffc020150a <vprintfmt+0x34>
            lflag ++;
ffffffffc0201764:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201766:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201768:	b3e9                	j	ffffffffc0201532 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020176a:	00044783          	lbu	a5,0(s0)
ffffffffc020176e:	0007851b          	sext.w	a0,a5
ffffffffc0201772:	d3c9                	beqz	a5,ffffffffc02016f4 <vprintfmt+0x21e>
ffffffffc0201774:	00140a13          	addi	s4,s0,1
ffffffffc0201778:	bf2d                	j	ffffffffc02016b2 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc020177a:	000a2403          	lw	s0,0(s4)
ffffffffc020177e:	b769                	j	ffffffffc0201708 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc0201780:	000a6603          	lwu	a2,0(s4)
ffffffffc0201784:	46a1                	li	a3,8
ffffffffc0201786:	8a3a                	mv	s4,a4
ffffffffc0201788:	bd9d                	j	ffffffffc02015fe <vprintfmt+0x128>
ffffffffc020178a:	000a6603          	lwu	a2,0(s4)
ffffffffc020178e:	46a9                	li	a3,10
ffffffffc0201790:	8a3a                	mv	s4,a4
ffffffffc0201792:	b5b5                	j	ffffffffc02015fe <vprintfmt+0x128>
ffffffffc0201794:	000a6603          	lwu	a2,0(s4)
ffffffffc0201798:	46c1                	li	a3,16
ffffffffc020179a:	8a3a                	mv	s4,a4
ffffffffc020179c:	b58d                	j	ffffffffc02015fe <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc020179e:	9902                	jalr	s2
ffffffffc02017a0:	bf15                	j	ffffffffc02016d4 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc02017a2:	85a6                	mv	a1,s1
ffffffffc02017a4:	02d00513          	li	a0,45
ffffffffc02017a8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017aa:	40800633          	neg	a2,s0
ffffffffc02017ae:	8a5e                	mv	s4,s7
ffffffffc02017b0:	46a9                	li	a3,10
ffffffffc02017b2:	b5b1                	j	ffffffffc02015fe <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc02017b4:	01905663          	blez	s9,ffffffffc02017c0 <vprintfmt+0x2ea>
ffffffffc02017b8:	02d00793          	li	a5,45
ffffffffc02017bc:	04fd9263          	bne	s11,a5,ffffffffc0201800 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017c0:	02800793          	li	a5,40
ffffffffc02017c4:	00001a17          	auipc	s4,0x1
ffffffffc02017c8:	d75a0a13          	addi	s4,s4,-651 # ffffffffc0202539 <etext+0xb69>
ffffffffc02017cc:	02800513          	li	a0,40
ffffffffc02017d0:	b5cd                	j	ffffffffc02016b2 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017d2:	85ea                	mv	a1,s10
ffffffffc02017d4:	8522                	mv	a0,s0
ffffffffc02017d6:	17e000ef          	jal	ffffffffc0201954 <strnlen>
ffffffffc02017da:	40ac8cbb          	subw	s9,s9,a0
ffffffffc02017de:	01905963          	blez	s9,ffffffffc02017f0 <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc02017e2:	2d81                	sext.w	s11,s11
ffffffffc02017e4:	85a6                	mv	a1,s1
ffffffffc02017e6:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017e8:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc02017ea:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017ec:	fe0c9ce3          	bnez	s9,ffffffffc02017e4 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017f0:	00044783          	lbu	a5,0(s0)
ffffffffc02017f4:	0007851b          	sext.w	a0,a5
ffffffffc02017f8:	ea079de3          	bnez	a5,ffffffffc02016b2 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017fc:	6a22                	ld	s4,8(sp)
ffffffffc02017fe:	b331                	j	ffffffffc020150a <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201800:	85ea                	mv	a1,s10
ffffffffc0201802:	00001517          	auipc	a0,0x1
ffffffffc0201806:	d3650513          	addi	a0,a0,-714 # ffffffffc0202538 <etext+0xb68>
ffffffffc020180a:	14a000ef          	jal	ffffffffc0201954 <strnlen>
ffffffffc020180e:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc0201812:	00001417          	auipc	s0,0x1
ffffffffc0201816:	d2640413          	addi	s0,s0,-730 # ffffffffc0202538 <etext+0xb68>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020181a:	00001a17          	auipc	s4,0x1
ffffffffc020181e:	d1fa0a13          	addi	s4,s4,-737 # ffffffffc0202539 <etext+0xb69>
ffffffffc0201822:	02800793          	li	a5,40
ffffffffc0201826:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020182a:	fb904ce3          	bgtz	s9,ffffffffc02017e2 <vprintfmt+0x30c>
ffffffffc020182e:	b551                	j	ffffffffc02016b2 <vprintfmt+0x1dc>

ffffffffc0201830 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201830:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201832:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201836:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201838:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020183a:	ec06                	sd	ra,24(sp)
ffffffffc020183c:	f83a                	sd	a4,48(sp)
ffffffffc020183e:	fc3e                	sd	a5,56(sp)
ffffffffc0201840:	e0c2                	sd	a6,64(sp)
ffffffffc0201842:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201844:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201846:	c91ff0ef          	jal	ffffffffc02014d6 <vprintfmt>
}
ffffffffc020184a:	60e2                	ld	ra,24(sp)
ffffffffc020184c:	6161                	addi	sp,sp,80
ffffffffc020184e:	8082                	ret

ffffffffc0201850 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201850:	715d                	addi	sp,sp,-80
ffffffffc0201852:	e486                	sd	ra,72(sp)
ffffffffc0201854:	e0a2                	sd	s0,64(sp)
ffffffffc0201856:	fc26                	sd	s1,56(sp)
ffffffffc0201858:	f84a                	sd	s2,48(sp)
ffffffffc020185a:	f44e                	sd	s3,40(sp)
ffffffffc020185c:	f052                	sd	s4,32(sp)
ffffffffc020185e:	ec56                	sd	s5,24(sp)
ffffffffc0201860:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc0201862:	c901                	beqz	a0,ffffffffc0201872 <readline+0x22>
ffffffffc0201864:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201866:	00001517          	auipc	a0,0x1
ffffffffc020186a:	cea50513          	addi	a0,a0,-790 # ffffffffc0202550 <etext+0xb80>
ffffffffc020186e:	845fe0ef          	jal	ffffffffc02000b2 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201872:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201874:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201876:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201878:	4a29                	li	s4,10
ffffffffc020187a:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc020187c:	00004b17          	auipc	s6,0x4
ffffffffc0201880:	7acb0b13          	addi	s6,s6,1964 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201884:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0201888:	8affe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc020188c:	00054a63          	bltz	a0,ffffffffc02018a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201890:	00a4da63          	bge	s1,a0,ffffffffc02018a4 <readline+0x54>
ffffffffc0201894:	0289d263          	bge	s3,s0,ffffffffc02018b8 <readline+0x68>
        c = getchar();
ffffffffc0201898:	89ffe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc020189c:	fe055ae3          	bgez	a0,ffffffffc0201890 <readline+0x40>
            return NULL;
ffffffffc02018a0:	4501                	li	a0,0
ffffffffc02018a2:	a091                	j	ffffffffc02018e6 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018a4:	03251463          	bne	a0,s2,ffffffffc02018cc <readline+0x7c>
ffffffffc02018a8:	04804963          	bgtz	s0,ffffffffc02018fa <readline+0xaa>
        c = getchar();
ffffffffc02018ac:	88bfe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc02018b0:	fe0548e3          	bltz	a0,ffffffffc02018a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018b4:	fea4d8e3          	bge	s1,a0,ffffffffc02018a4 <readline+0x54>
            cputchar(c);
ffffffffc02018b8:	e42a                	sd	a0,8(sp)
ffffffffc02018ba:	82dfe0ef          	jal	ffffffffc02000e6 <cputchar>
            buf[i ++] = c;
ffffffffc02018be:	6522                	ld	a0,8(sp)
ffffffffc02018c0:	008b07b3          	add	a5,s6,s0
ffffffffc02018c4:	2405                	addiw	s0,s0,1
ffffffffc02018c6:	00a78023          	sb	a0,0(a5)
ffffffffc02018ca:	bf7d                	j	ffffffffc0201888 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018cc:	01450463          	beq	a0,s4,ffffffffc02018d4 <readline+0x84>
ffffffffc02018d0:	fb551ce3          	bne	a0,s5,ffffffffc0201888 <readline+0x38>
            cputchar(c);
ffffffffc02018d4:	813fe0ef          	jal	ffffffffc02000e6 <cputchar>
            buf[i] = '\0';
ffffffffc02018d8:	00004517          	auipc	a0,0x4
ffffffffc02018dc:	75050513          	addi	a0,a0,1872 # ffffffffc0206028 <buf>
ffffffffc02018e0:	942a                	add	s0,s0,a0
ffffffffc02018e2:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc02018e6:	60a6                	ld	ra,72(sp)
ffffffffc02018e8:	6406                	ld	s0,64(sp)
ffffffffc02018ea:	74e2                	ld	s1,56(sp)
ffffffffc02018ec:	7942                	ld	s2,48(sp)
ffffffffc02018ee:	79a2                	ld	s3,40(sp)
ffffffffc02018f0:	7a02                	ld	s4,32(sp)
ffffffffc02018f2:	6ae2                	ld	s5,24(sp)
ffffffffc02018f4:	6b42                	ld	s6,16(sp)
ffffffffc02018f6:	6161                	addi	sp,sp,80
ffffffffc02018f8:	8082                	ret
            cputchar(c);
ffffffffc02018fa:	4521                	li	a0,8
ffffffffc02018fc:	feafe0ef          	jal	ffffffffc02000e6 <cputchar>
            i --;
ffffffffc0201900:	347d                	addiw	s0,s0,-1
ffffffffc0201902:	b759                	j	ffffffffc0201888 <readline+0x38>

ffffffffc0201904 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201904:	4781                	li	a5,0
ffffffffc0201906:	00004717          	auipc	a4,0x4
ffffffffc020190a:	70273703          	ld	a4,1794(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020190e:	88ba                	mv	a7,a4
ffffffffc0201910:	852a                	mv	a0,a0
ffffffffc0201912:	85be                	mv	a1,a5
ffffffffc0201914:	863e                	mv	a2,a5
ffffffffc0201916:	00000073          	ecall
ffffffffc020191a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020191c:	8082                	ret

ffffffffc020191e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc020191e:	4781                	li	a5,0
ffffffffc0201920:	00005717          	auipc	a4,0x5
ffffffffc0201924:	b4873703          	ld	a4,-1208(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201928:	88ba                	mv	a7,a4
ffffffffc020192a:	852a                	mv	a0,a0
ffffffffc020192c:	85be                	mv	a1,a5
ffffffffc020192e:	863e                	mv	a2,a5
ffffffffc0201930:	00000073          	ecall
ffffffffc0201934:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201936:	8082                	ret

ffffffffc0201938 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201938:	4501                	li	a0,0
ffffffffc020193a:	00004797          	auipc	a5,0x4
ffffffffc020193e:	6c67b783          	ld	a5,1734(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201942:	88be                	mv	a7,a5
ffffffffc0201944:	852a                	mv	a0,a0
ffffffffc0201946:	85aa                	mv	a1,a0
ffffffffc0201948:	862a                	mv	a2,a0
ffffffffc020194a:	00000073          	ecall
ffffffffc020194e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201950:	2501                	sext.w	a0,a0
ffffffffc0201952:	8082                	ret

ffffffffc0201954 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201954:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201956:	e589                	bnez	a1,ffffffffc0201960 <strnlen+0xc>
ffffffffc0201958:	a811                	j	ffffffffc020196c <strnlen+0x18>
        cnt ++;
ffffffffc020195a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020195c:	00f58863          	beq	a1,a5,ffffffffc020196c <strnlen+0x18>
ffffffffc0201960:	00f50733          	add	a4,a0,a5
ffffffffc0201964:	00074703          	lbu	a4,0(a4)
ffffffffc0201968:	fb6d                	bnez	a4,ffffffffc020195a <strnlen+0x6>
ffffffffc020196a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020196c:	852e                	mv	a0,a1
ffffffffc020196e:	8082                	ret

ffffffffc0201970 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201970:	00054783          	lbu	a5,0(a0)
ffffffffc0201974:	e791                	bnez	a5,ffffffffc0201980 <strcmp+0x10>
ffffffffc0201976:	a02d                	j	ffffffffc02019a0 <strcmp+0x30>
ffffffffc0201978:	00054783          	lbu	a5,0(a0)
ffffffffc020197c:	cf89                	beqz	a5,ffffffffc0201996 <strcmp+0x26>
ffffffffc020197e:	85b6                	mv	a1,a3
ffffffffc0201980:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201984:	0505                	addi	a0,a0,1
ffffffffc0201986:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020198a:	fef707e3          	beq	a4,a5,ffffffffc0201978 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020198e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201992:	9d19                	subw	a0,a0,a4
ffffffffc0201994:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201996:	0015c703          	lbu	a4,1(a1)
ffffffffc020199a:	4501                	li	a0,0
}
ffffffffc020199c:	9d19                	subw	a0,a0,a4
ffffffffc020199e:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019a0:	0005c703          	lbu	a4,0(a1)
ffffffffc02019a4:	4501                	li	a0,0
ffffffffc02019a6:	b7f5                	j	ffffffffc0201992 <strcmp+0x22>

ffffffffc02019a8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019a8:	00054783          	lbu	a5,0(a0)
ffffffffc02019ac:	c799                	beqz	a5,ffffffffc02019ba <strchr+0x12>
        if (*s == c) {
ffffffffc02019ae:	00f58763          	beq	a1,a5,ffffffffc02019bc <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019b2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019b6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019b8:	fbfd                	bnez	a5,ffffffffc02019ae <strchr+0x6>
    }
    return NULL;
ffffffffc02019ba:	4501                	li	a0,0
}
ffffffffc02019bc:	8082                	ret

ffffffffc02019be <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019be:	ca01                	beqz	a2,ffffffffc02019ce <memset+0x10>
ffffffffc02019c0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019c2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019c4:	0785                	addi	a5,a5,1
ffffffffc02019c6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019ca:	fef61de3          	bne	a2,a5,ffffffffc02019c4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019ce:	8082                	ret
