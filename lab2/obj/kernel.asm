
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
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
ffffffffc0200024:	c0204137          	lui	sp,0xc0204

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
ffffffffc0200032:	00005517          	auipc	a0,0x5
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0205010 <buddy_free_area>
ffffffffc020003a:	00005617          	auipc	a2,0x5
ffffffffc020003e:	52660613          	addi	a2,a2,1318 # ffffffffc0205560 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	62d000ef          	jal	ra,ffffffffc0200e76 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	32e50513          	addi	a0,a0,814 # ffffffffc0201380 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	019000ef          	jal	ra,ffffffffc020087e <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



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
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
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
ffffffffc02000a6:	64f000ef          	jal	ra,ffffffffc0200ef4 <vprintfmt>
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
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	619000ef          	jal	ra,ffffffffc0200ef4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00005317          	auipc	t1,0x5
ffffffffc020013e:	3de30313          	addi	t1,t1,990 # ffffffffc0205518 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	23850513          	addi	a0,a0,568 # ffffffffc02013a0 <etext+0x26>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	30a50513          	addi	a0,a0,778 # ffffffffc0201488 <etext+0x10e>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
    while (1) {
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	22850513          	addi	a0,a0,552 # ffffffffc02013c0 <etext+0x46>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	23250513          	addi	a0,a0,562 # ffffffffc02013e0 <etext+0x66>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	1c058593          	addi	a1,a1,448 # ffffffffc020137a <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	23e50513          	addi	a0,a0,574 # ffffffffc0201400 <etext+0x86>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00005597          	auipc	a1,0x5
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0205010 <buddy_free_area>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	24a50513          	addi	a0,a0,586 # ffffffffc0201420 <etext+0xa6>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00005597          	auipc	a1,0x5
ffffffffc02001e6:	37e58593          	addi	a1,a1,894 # ffffffffc0205560 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	25650513          	addi	a0,a0,598 # ffffffffc0201440 <etext+0xc6>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00005597          	auipc	a1,0x5
ffffffffc02001fa:	76958593          	addi	a1,a1,1897 # ffffffffc020595f <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	24850513          	addi	a0,a0,584 # ffffffffc0201460 <etext+0xe6>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	26a60613          	addi	a2,a2,618 # ffffffffc0201490 <etext+0x116>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	27650513          	addi	a0,a0,630 # ffffffffc02014a8 <etext+0x12e>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	27e60613          	addi	a2,a2,638 # ffffffffc02014c0 <etext+0x146>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	29658593          	addi	a1,a1,662 # ffffffffc02014e0 <etext+0x166>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	29650513          	addi	a0,a0,662 # ffffffffc02014e8 <etext+0x16e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	29860613          	addi	a2,a2,664 # ffffffffc02014f8 <etext+0x17e>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	2b858593          	addi	a1,a1,696 # ffffffffc0201520 <etext+0x1a6>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	27850513          	addi	a0,a0,632 # ffffffffc02014e8 <etext+0x16e>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	2b460613          	addi	a2,a2,692 # ffffffffc0201530 <etext+0x1b6>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	2cc58593          	addi	a1,a1,716 # ffffffffc0201550 <etext+0x1d6>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	25c50513          	addi	a0,a0,604 # ffffffffc02014e8 <etext+0x16e>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    return 0;
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
    return 0;
}
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	29a50513          	addi	a0,a0,666 # ffffffffc0201560 <etext+0x1e6>
kmonitor(struct trapframe *tf) {
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	2a050513          	addi	a0,a0,672 # ffffffffc0201588 <etext+0x20e>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	2fac0c13          	addi	s8,s8,762 # ffffffffc02015f8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	2aa90913          	addi	s2,s2,682 # ffffffffc02015b0 <etext+0x236>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	2aa48493          	addi	s1,s1,682 # ffffffffc02015b8 <etext+0x23e>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	2a8b0b13          	addi	s6,s6,680 # ffffffffc02015c0 <etext+0x246>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	1c0a0a13          	addi	s4,s4,448 # ffffffffc02014e0 <etext+0x166>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	74b000ef          	jal	ra,ffffffffc0201276 <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200338:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	2b6d0d13          	addi	s10,s10,694 # ffffffffc02015f8 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	2f3000ef          	jal	ra,ffffffffc0200e42 <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200362:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	2df000ef          	jal	ra,ffffffffc0200e42 <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
}
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	2bf000ef          	jal	ra,ffffffffc0200e60 <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	281000ef          	jal	ra,ffffffffc0200e60 <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	1e650513          	addi	a0,a0,486 # ffffffffc02015e0 <etext+0x266>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	725000ef          	jal	ra,ffffffffc0201344 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00005797          	auipc	a5,0x5
ffffffffc020042a:	0e07bd23          	sd	zero,250(a5) # ffffffffc0205520 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	21250513          	addi	a0,a0,530 # ffffffffc0201640 <commands+0x48>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	6ff0006f          	j	ffffffffc0201344 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	6db0006f          	j	ffffffffc020132a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	70b0006f          	j	ffffffffc020135e <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	1e250513          	addi	a0,a0,482 # ffffffffc0201660 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	1ea50513          	addi	a0,a0,490 # ffffffffc0201678 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	1f450513          	addi	a0,a0,500 # ffffffffc0201690 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	1fe50513          	addi	a0,a0,510 # ffffffffc02016a8 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	20850513          	addi	a0,a0,520 # ffffffffc02016c0 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	21250513          	addi	a0,a0,530 # ffffffffc02016d8 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	21c50513          	addi	a0,a0,540 # ffffffffc02016f0 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	22650513          	addi	a0,a0,550 # ffffffffc0201708 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	23050513          	addi	a0,a0,560 # ffffffffc0201720 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	23a50513          	addi	a0,a0,570 # ffffffffc0201738 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	24450513          	addi	a0,a0,580 # ffffffffc0201750 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	24e50513          	addi	a0,a0,590 # ffffffffc0201768 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	25850513          	addi	a0,a0,600 # ffffffffc0201780 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	26250513          	addi	a0,a0,610 # ffffffffc0201798 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	26c50513          	addi	a0,a0,620 # ffffffffc02017b0 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	27650513          	addi	a0,a0,630 # ffffffffc02017c8 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	28050513          	addi	a0,a0,640 # ffffffffc02017e0 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	28a50513          	addi	a0,a0,650 # ffffffffc02017f8 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	29450513          	addi	a0,a0,660 # ffffffffc0201810 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	29e50513          	addi	a0,a0,670 # ffffffffc0201828 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	2a850513          	addi	a0,a0,680 # ffffffffc0201840 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	2b250513          	addi	a0,a0,690 # ffffffffc0201858 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	2bc50513          	addi	a0,a0,700 # ffffffffc0201870 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	2c650513          	addi	a0,a0,710 # ffffffffc0201888 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	2d050513          	addi	a0,a0,720 # ffffffffc02018a0 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	2da50513          	addi	a0,a0,730 # ffffffffc02018b8 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	2e450513          	addi	a0,a0,740 # ffffffffc02018d0 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	2ee50513          	addi	a0,a0,750 # ffffffffc02018e8 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	2f850513          	addi	a0,a0,760 # ffffffffc0201900 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	30250513          	addi	a0,a0,770 # ffffffffc0201918 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	30c50513          	addi	a0,a0,780 # ffffffffc0201930 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	31250513          	addi	a0,a0,786 # ffffffffc0201948 <commands+0x350>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	31650513          	addi	a0,a0,790 # ffffffffc0201960 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	31650513          	addi	a0,a0,790 # ffffffffc0201978 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	31e50513          	addi	a0,a0,798 # ffffffffc0201990 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	32650513          	addi	a0,a0,806 # ffffffffc02019a8 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	32a50513          	addi	a0,a0,810 # ffffffffc02019c0 <commands+0x3c8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	3f070713          	addi	a4,a4,1008 # ffffffffc0201aa0 <commands+0x4a8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	37650513          	addi	a0,a0,886 # ffffffffc0201a38 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	34c50513          	addi	a0,a0,844 # ffffffffc0201a18 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	30250513          	addi	a0,a0,770 # ffffffffc02019d8 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	37850513          	addi	a0,a0,888 # ffffffffc0201a58 <commands+0x460>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00005697          	auipc	a3,0x5
ffffffffc02006f6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205520 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	37050513          	addi	a0,a0,880 # ffffffffc0201a80 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	2de50513          	addi	a0,a0,734 # ffffffffc02019f8 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	34450513          	addi	a0,a0,836 # ffffffffc0201a70 <commands+0x478>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

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
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

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

ffffffffc0200802 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200802:	100027f3          	csrr	a5,sstatus
ffffffffc0200806:	8b89                	andi	a5,a5,2
ffffffffc0200808:	e799                	bnez	a5,ffffffffc0200816 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020080a:	00005797          	auipc	a5,0x5
ffffffffc020080e:	d2e7b783          	ld	a5,-722(a5) # ffffffffc0205538 <pmm_manager>
ffffffffc0200812:	6f9c                	ld	a5,24(a5)
ffffffffc0200814:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e406                	sd	ra,8(sp)
ffffffffc020081a:	e022                	sd	s0,0(sp)
ffffffffc020081c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020081e:	c41ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200822:	00005797          	auipc	a5,0x5
ffffffffc0200826:	d167b783          	ld	a5,-746(a5) # ffffffffc0205538 <pmm_manager>
ffffffffc020082a:	6f9c                	ld	a5,24(a5)
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	9782                	jalr	a5
ffffffffc0200830:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200832:	c27ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200836:	60a2                	ld	ra,8(sp)
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	6402                	ld	s0,0(sp)
ffffffffc020083c:	0141                	addi	sp,sp,16
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200840:	100027f3          	csrr	a5,sstatus
ffffffffc0200844:	8b89                	andi	a5,a5,2
ffffffffc0200846:	e799                	bnez	a5,ffffffffc0200854 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200848:	00005797          	auipc	a5,0x5
ffffffffc020084c:	cf07b783          	ld	a5,-784(a5) # ffffffffc0205538 <pmm_manager>
ffffffffc0200850:	739c                	ld	a5,32(a5)
ffffffffc0200852:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200854:	1101                	addi	sp,sp,-32
ffffffffc0200856:	ec06                	sd	ra,24(sp)
ffffffffc0200858:	e822                	sd	s0,16(sp)
ffffffffc020085a:	e426                	sd	s1,8(sp)
ffffffffc020085c:	842a                	mv	s0,a0
ffffffffc020085e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200864:	00005797          	auipc	a5,0x5
ffffffffc0200868:	cd47b783          	ld	a5,-812(a5) # ffffffffc0205538 <pmm_manager>
ffffffffc020086c:	739c                	ld	a5,32(a5)
ffffffffc020086e:	85a6                	mv	a1,s1
ffffffffc0200870:	8522                	mv	a0,s0
ffffffffc0200872:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200874:	6442                	ld	s0,16(sp)
ffffffffc0200876:	60e2                	ld	ra,24(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020087c:	bef1                	j	ffffffffc0200458 <intr_enable>

ffffffffc020087e <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc020087e:	00001797          	auipc	a5,0x1
ffffffffc0200882:	47a78793          	addi	a5,a5,1146 # ffffffffc0201cf8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200886:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020088c:	00001517          	auipc	a0,0x1
ffffffffc0200890:	24450513          	addi	a0,a0,580 # ffffffffc0201ad0 <commands+0x4d8>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200894:	00005497          	auipc	s1,0x5
ffffffffc0200898:	ca448493          	addi	s1,s1,-860 # ffffffffc0205538 <pmm_manager>
void pmm_init(void) {
ffffffffc020089c:	ec06                	sd	ra,24(sp)
ffffffffc020089e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02008a0:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008a2:	811ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02008a6:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008a8:	00005417          	auipc	s0,0x5
ffffffffc02008ac:	ca840413          	addi	s0,s0,-856 # ffffffffc0205550 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008b0:	679c                	ld	a5,8(a5)
ffffffffc02008b2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008b4:	57f5                	li	a5,-3
ffffffffc02008b6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008b8:	00001517          	auipc	a0,0x1
ffffffffc02008bc:	23050513          	addi	a0,a0,560 # ffffffffc0201ae8 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008c0:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02008c2:	ff0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02008c6:	46c5                	li	a3,17
ffffffffc02008c8:	06ee                	slli	a3,a3,0x1b
ffffffffc02008ca:	40100613          	li	a2,1025
ffffffffc02008ce:	16fd                	addi	a3,a3,-1
ffffffffc02008d0:	07e005b7          	lui	a1,0x7e00
ffffffffc02008d4:	0656                	slli	a2,a2,0x15
ffffffffc02008d6:	00001517          	auipc	a0,0x1
ffffffffc02008da:	22a50513          	addi	a0,a0,554 # ffffffffc0201b00 <commands+0x508>
ffffffffc02008de:	fd4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008e2:	777d                	lui	a4,0xfffff
ffffffffc02008e4:	00006797          	auipc	a5,0x6
ffffffffc02008e8:	c7b78793          	addi	a5,a5,-901 # ffffffffc020655f <end+0xfff>
ffffffffc02008ec:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	c3a50513          	addi	a0,a0,-966 # ffffffffc0205528 <npage>
ffffffffc02008f6:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008fa:	00005597          	auipc	a1,0x5
ffffffffc02008fe:	c3658593          	addi	a1,a1,-970 # ffffffffc0205530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200902:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200904:	e19c                	sd	a5,0(a1)
ffffffffc0200906:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200908:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020090a:	4885                	li	a7,1
ffffffffc020090c:	fff80837          	lui	a6,0xfff80
ffffffffc0200910:	a011                	j	ffffffffc0200914 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200912:	619c                	ld	a5,0(a1)
ffffffffc0200914:	97b6                	add	a5,a5,a3
ffffffffc0200916:	07a1                	addi	a5,a5,8
ffffffffc0200918:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020091c:	611c                	ld	a5,0(a0)
ffffffffc020091e:	0705                	addi	a4,a4,1
ffffffffc0200920:	02868693          	addi	a3,a3,40
ffffffffc0200924:	01078633          	add	a2,a5,a6
ffffffffc0200928:	fec765e3          	bltu	a4,a2,ffffffffc0200912 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020092c:	6190                	ld	a2,0(a1)
ffffffffc020092e:	00279713          	slli	a4,a5,0x2
ffffffffc0200932:	973e                	add	a4,a4,a5
ffffffffc0200934:	fec006b7          	lui	a3,0xfec00
ffffffffc0200938:	070e                	slli	a4,a4,0x3
ffffffffc020093a:	96b2                	add	a3,a3,a2
ffffffffc020093c:	96ba                	add	a3,a3,a4
ffffffffc020093e:	c0200737          	lui	a4,0xc0200
ffffffffc0200942:	08e6ef63          	bltu	a3,a4,ffffffffc02009e0 <pmm_init+0x162>
ffffffffc0200946:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200948:	45c5                	li	a1,17
ffffffffc020094a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020094c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020094e:	04b6e863          	bltu	a3,a1,ffffffffc020099e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200952:	609c                	ld	a5,0(s1)
ffffffffc0200954:	7b9c                	ld	a5,48(a5)
ffffffffc0200956:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	24050513          	addi	a0,a0,576 # ffffffffc0201b98 <commands+0x5a0>
ffffffffc0200960:	f52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200964:	00003597          	auipc	a1,0x3
ffffffffc0200968:	69c58593          	addi	a1,a1,1692 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc020096c:	00005797          	auipc	a5,0x5
ffffffffc0200970:	bcb7be23          	sd	a1,-1060(a5) # ffffffffc0205548 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200974:	c02007b7          	lui	a5,0xc0200
ffffffffc0200978:	08f5e063          	bltu	a1,a5,ffffffffc02009f8 <pmm_init+0x17a>
ffffffffc020097c:	6010                	ld	a2,0(s0)
}
ffffffffc020097e:	6442                	ld	s0,16(sp)
ffffffffc0200980:	60e2                	ld	ra,24(sp)
ffffffffc0200982:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200984:	40c58633          	sub	a2,a1,a2
ffffffffc0200988:	00005797          	auipc	a5,0x5
ffffffffc020098c:	bac7bc23          	sd	a2,-1096(a5) # ffffffffc0205540 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200990:	00001517          	auipc	a0,0x1
ffffffffc0200994:	22850513          	addi	a0,a0,552 # ffffffffc0201bb8 <commands+0x5c0>
}
ffffffffc0200998:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020099a:	f18ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020099e:	6705                	lui	a4,0x1
ffffffffc02009a0:	177d                	addi	a4,a4,-1
ffffffffc02009a2:	96ba                	add	a3,a3,a4
ffffffffc02009a4:	777d                	lui	a4,0xfffff
ffffffffc02009a6:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009a8:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009ac:	00f57e63          	bgeu	a0,a5,ffffffffc02009c8 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009b0:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009b2:	982a                	add	a6,a6,a0
ffffffffc02009b4:	00281513          	slli	a0,a6,0x2
ffffffffc02009b8:	9542                	add	a0,a0,a6
ffffffffc02009ba:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009bc:	8d95                	sub	a1,a1,a3
ffffffffc02009be:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009c0:	81b1                	srli	a1,a1,0xc
ffffffffc02009c2:	9532                	add	a0,a0,a2
ffffffffc02009c4:	9782                	jalr	a5
}
ffffffffc02009c6:	b771                	j	ffffffffc0200952 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02009c8:	00001617          	auipc	a2,0x1
ffffffffc02009cc:	1a060613          	addi	a2,a2,416 # ffffffffc0201b68 <commands+0x570>
ffffffffc02009d0:	06b00593          	li	a1,107
ffffffffc02009d4:	00001517          	auipc	a0,0x1
ffffffffc02009d8:	1b450513          	addi	a0,a0,436 # ffffffffc0201b88 <commands+0x590>
ffffffffc02009dc:	f5eff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009e0:	00001617          	auipc	a2,0x1
ffffffffc02009e4:	15060613          	addi	a2,a2,336 # ffffffffc0201b30 <commands+0x538>
ffffffffc02009e8:	06f00593          	li	a1,111
ffffffffc02009ec:	00001517          	auipc	a0,0x1
ffffffffc02009f0:	16c50513          	addi	a0,a0,364 # ffffffffc0201b58 <commands+0x560>
ffffffffc02009f4:	f46ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009f8:	86ae                	mv	a3,a1
ffffffffc02009fa:	00001617          	auipc	a2,0x1
ffffffffc02009fe:	13660613          	addi	a2,a2,310 # ffffffffc0201b30 <commands+0x538>
ffffffffc0200a02:	08a00593          	li	a1,138
ffffffffc0200a06:	00001517          	auipc	a0,0x1
ffffffffc0200a0a:	15250513          	addi	a0,a0,338 # ffffffffc0201b58 <commands+0x560>
ffffffffc0200a0e:	f2cff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200a12 <buddy_init>:

#define MAX_ORDER 10

static void buddy_init(void)
{
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200a12:	00004797          	auipc	a5,0x4
ffffffffc0200a16:	5fe78793          	addi	a5,a5,1534 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200a1a:	00004717          	auipc	a4,0x4
ffffffffc0200a1e:	6fe70713          	addi	a4,a4,1790 # ffffffffc0205118 <buf>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a22:	e79c                	sd	a5,8(a5)
ffffffffc0200a24:	e39c                	sd	a5,0(a5)
    {
        list_init(&buddy_free_area[i].free_list);
        buddy_free_area[i].nr_free = 0;
ffffffffc0200a26:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200a2a:	07e1                	addi	a5,a5,24
ffffffffc0200a2c:	fee79be3          	bne	a5,a4,ffffffffc0200a22 <buddy_init+0x10>
    }
}
ffffffffc0200a30:	8082                	ret

ffffffffc0200a32 <buddy_alloc_pages>:
}

static struct Page *buddy_alloc_pages(size_t n)
{
    int order = 0;
    while ((1 << order) < n)
ffffffffc0200a32:	4785                	li	a5,1
{
ffffffffc0200a34:	88aa                	mv	a7,a0
    int order = 0;
ffffffffc0200a36:	4681                	li	a3,0
    while ((1 << order) < n)
ffffffffc0200a38:	00a7fb63          	bgeu	a5,a0,ffffffffc0200a4e <buddy_alloc_pages+0x1c>
ffffffffc0200a3c:	4705                	li	a4,1
    {
        order++;
ffffffffc0200a3e:	2685                	addiw	a3,a3,1
    while ((1 << order) < n)
ffffffffc0200a40:	00d717bb          	sllw	a5,a4,a3
ffffffffc0200a44:	ff17ede3          	bltu	a5,a7,ffffffffc0200a3e <buddy_alloc_pages+0xc>
    }
    if (order > MAX_ORDER)
ffffffffc0200a48:	47a9                	li	a5,10
ffffffffc0200a4a:	02d7c463          	blt	a5,a3,ffffffffc0200a72 <buddy_alloc_pages+0x40>
ffffffffc0200a4e:	00169793          	slli	a5,a3,0x1
ffffffffc0200a52:	97b6                	add	a5,a5,a3
ffffffffc0200a54:	00004617          	auipc	a2,0x4
ffffffffc0200a58:	5bc60613          	addi	a2,a2,1468 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200a5c:	078e                	slli	a5,a5,0x3
ffffffffc0200a5e:	97b2                	add	a5,a5,a2
    int order = 0;
ffffffffc0200a60:	8736                	mv	a4,a3
        return NULL; // 请求的块超出最大支持块的大小

    // 查找适合的块
    for (int current_order = order; current_order <= MAX_ORDER; current_order++)
ffffffffc0200a62:	452d                	li	a0,11
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200a64:	678c                	ld	a1,8(a5)
    {
        if (!list_empty(&buddy_free_area[current_order].free_list))
ffffffffc0200a66:	00f59863          	bne	a1,a5,ffffffffc0200a76 <buddy_alloc_pages+0x44>
    for (int current_order = order; current_order <= MAX_ORDER; current_order++)
ffffffffc0200a6a:	2705                	addiw	a4,a4,1
ffffffffc0200a6c:	07e1                	addi	a5,a5,24
ffffffffc0200a6e:	fea71be3          	bne	a4,a0,ffffffffc0200a64 <buddy_alloc_pages+0x32>
        return NULL; // 请求的块超出最大支持块的大小
ffffffffc0200a72:	4501                	li	a0,0
            page->property = n;
            return page;
        }
    }
    return NULL; // 如果没有合适的块，返回NULL
}
ffffffffc0200a74:	8082                	ret
            buddy_free_area[current_order].nr_free--;
ffffffffc0200a76:	00171793          	slli	a5,a4,0x1
ffffffffc0200a7a:	97ba                	add	a5,a5,a4
ffffffffc0200a7c:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a7e:	0005be03          	ld	t3,0(a1)
ffffffffc0200a82:	0085b303          	ld	t1,8(a1)
ffffffffc0200a86:	00f60833          	add	a6,a2,a5
ffffffffc0200a8a:	01082503          	lw	a0,16(a6) # fffffffffff80010 <end+0x3fd7aab0>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200a8e:	006e3423          	sd	t1,8(t3)
    next->prev = prev;
ffffffffc0200a92:	01c33023          	sd	t3,0(t1)
ffffffffc0200a96:	357d                	addiw	a0,a0,-1
ffffffffc0200a98:	00a82823          	sw	a0,16(a6)
            struct Page *page = le2page(le, page_link);
ffffffffc0200a9c:	fe858513          	addi	a0,a1,-24
            while (current_order > order)
ffffffffc0200aa0:	04e6d763          	bge	a3,a4,ffffffffc0200aee <buddy_alloc_pages+0xbc>
ffffffffc0200aa4:	17a1                	addi	a5,a5,-24
ffffffffc0200aa6:	963e                	add	a2,a2,a5
                struct Page *buddy = page + (1 << current_order);
ffffffffc0200aa8:	4f05                	li	t5,1
ffffffffc0200aaa:	4e89                	li	t4,2
                current_order--;
ffffffffc0200aac:	377d                	addiw	a4,a4,-1
                struct Page *buddy = page + (1 << current_order);
ffffffffc0200aae:	00ef133b          	sllw	t1,t5,a4
ffffffffc0200ab2:	00231793          	slli	a5,t1,0x2
ffffffffc0200ab6:	979a                	add	a5,a5,t1
ffffffffc0200ab8:	078e                	slli	a5,a5,0x3
ffffffffc0200aba:	97aa                	add	a5,a5,a0
                buddy->property = (1 << current_order);
ffffffffc0200abc:	0067a823          	sw	t1,16(a5)
ffffffffc0200ac0:	00878813          	addi	a6,a5,8
ffffffffc0200ac4:	41d8302f          	amoor.d	zero,t4,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ac8:	00863303          	ld	t1,8(a2)
                buddy_free_area[current_order].nr_free++;
ffffffffc0200acc:	01062803          	lw	a6,16(a2)
                list_add(&buddy_free_area[current_order].free_list, &(buddy->page_link));
ffffffffc0200ad0:	01878e13          	addi	t3,a5,24
    prev->next = next->prev = elm;
ffffffffc0200ad4:	01c33023          	sd	t3,0(t1)
ffffffffc0200ad8:	01c63423          	sd	t3,8(a2)
    elm->prev = prev;
ffffffffc0200adc:	ef90                	sd	a2,24(a5)
    elm->next = next;
ffffffffc0200ade:	0267b023          	sd	t1,32(a5)
                buddy_free_area[current_order].nr_free++;
ffffffffc0200ae2:	0018079b          	addiw	a5,a6,1
ffffffffc0200ae6:	ca1c                	sw	a5,16(a2)
            while (current_order > order)
ffffffffc0200ae8:	1621                	addi	a2,a2,-24
ffffffffc0200aea:	fce691e3          	bne	a3,a4,ffffffffc0200aac <buddy_alloc_pages+0x7a>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200aee:	57f5                	li	a5,-3
ffffffffc0200af0:	ff058713          	addi	a4,a1,-16
ffffffffc0200af4:	60f7302f          	amoand.d	zero,a5,(a4)
            page->property = n;
ffffffffc0200af8:	ff15ac23          	sw	a7,-8(a1)
            return page;
ffffffffc0200afc:	8082                	ret

ffffffffc0200afe <buddy_nr_free_pages>:
}

static size_t buddy_nr_free_pages(void)
{
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200afe:	00004697          	auipc	a3,0x4
ffffffffc0200b02:	52268693          	addi	a3,a3,1314 # ffffffffc0205020 <buddy_free_area+0x10>
ffffffffc0200b06:	4701                	li	a4,0
    size_t total = 0;
ffffffffc0200b08:	4501                	li	a0,0
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200b0a:	462d                	li	a2,11
    {
        total += buddy_free_area[i].nr_free * (1 << i);
ffffffffc0200b0c:	429c                	lw	a5,0(a3)
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200b0e:	06e1                	addi	a3,a3,24
        total += buddy_free_area[i].nr_free * (1 << i);
ffffffffc0200b10:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200b14:	1782                	slli	a5,a5,0x20
ffffffffc0200b16:	9381                	srli	a5,a5,0x20
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200b18:	2705                	addiw	a4,a4,1
        total += buddy_free_area[i].nr_free * (1 << i);
ffffffffc0200b1a:	953e                	add	a0,a0,a5
    for (int i = 0; i <= MAX_ORDER; i++)
ffffffffc0200b1c:	fec718e3          	bne	a4,a2,ffffffffc0200b0c <buddy_nr_free_pages+0xe>
    }
    return total;
}
ffffffffc0200b20:	8082                	ret

ffffffffc0200b22 <buddy_free_pages>:
    while ((1 << order) < n)
ffffffffc0200b22:	4785                	li	a5,1
    int order = 0;
ffffffffc0200b24:	4681                	li	a3,0
    while ((1 << order) < n)
ffffffffc0200b26:	0eb7f263          	bgeu	a5,a1,ffffffffc0200c0a <buddy_free_pages+0xe8>
ffffffffc0200b2a:	4705                	li	a4,1
        order++;
ffffffffc0200b2c:	2685                	addiw	a3,a3,1
    while ((1 << order) < n)
ffffffffc0200b2e:	00d717bb          	sllw	a5,a4,a3
ffffffffc0200b32:	feb7ede3          	bltu	a5,a1,ffffffffc0200b2c <buddy_free_pages+0xa>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b36:	6518                	ld	a4,8(a0)
ffffffffc0200b38:	8305                	srli	a4,a4,0x1
    if (PageProperty(base))
ffffffffc0200b3a:	8b05                	andi	a4,a4,1
ffffffffc0200b3c:	e771                	bnez	a4,ffffffffc0200c08 <buddy_free_pages+0xe6>
    base->property = (1 << order);
ffffffffc0200b3e:	c91c                	sw	a5,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b40:	00850713          	addi	a4,a0,8
ffffffffc0200b44:	4789                	li	a5,2
ffffffffc0200b46:	40f7302f          	amoor.d	zero,a5,(a4)
    while (order <= MAX_ORDER)
ffffffffc0200b4a:	47a9                	li	a5,10
ffffffffc0200b4c:	08d7ca63          	blt	a5,a3,ffffffffc0200be0 <buddy_free_pages+0xbe>
ffffffffc0200b50:	00005f17          	auipc	t5,0x5
ffffffffc0200b54:	9e0f0f13          	addi	t5,t5,-1568 # ffffffffc0205530 <pages>
ffffffffc0200b58:	00001e97          	auipc	t4,0x1
ffffffffc0200b5c:	428ebe83          	ld	t4,1064(t4) # ffffffffc0201f80 <nbase+0x8>
ffffffffc0200b60:	00005e17          	auipc	t3,0x5
ffffffffc0200b64:	9c8e0e13          	addi	t3,t3,-1592 # ffffffffc0205528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b68:	00001897          	auipc	a7,0x1
ffffffffc0200b6c:	4108b883          	ld	a7,1040(a7) # ffffffffc0201f78 <nbase>
        uintptr_t buddy_addr = addr ^ (1 << (PGSHIFT + order));
ffffffffc0200b70:	4305                	li	t1,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b72:	52f5                	li	t0,-3
    while (order <= MAX_ORDER)
ffffffffc0200b74:	4fad                	li	t6,11
ffffffffc0200b76:	a03d                	j	ffffffffc0200ba4 <buddy_free_pages+0x82>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b78:	671c                	ld	a5,8(a4)
        if (buddy_addr >= npage * PGSIZE || !PageProperty(buddy) || buddy->property != (1 << order))
ffffffffc0200b7a:	8b89                	andi	a5,a5,2
ffffffffc0200b7c:	c3b5                	beqz	a5,ffffffffc0200be0 <buddy_free_pages+0xbe>
ffffffffc0200b7e:	4b10                	lw	a2,16(a4)
ffffffffc0200b80:	00d317bb          	sllw	a5,t1,a3
ffffffffc0200b84:	04f61e63          	bne	a2,a5,ffffffffc0200be0 <buddy_free_pages+0xbe>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b88:	731c                	ld	a5,32(a4)
ffffffffc0200b8a:	6f10                	ld	a2,24(a4)
    prev->next = next;
ffffffffc0200b8c:	e61c                	sd	a5,8(a2)
    next->prev = prev;
ffffffffc0200b8e:	e390                	sd	a2,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b90:	00870793          	addi	a5,a4,8
ffffffffc0200b94:	6057b02f          	amoand.d	zero,t0,(a5)
        base = (base < buddy) ? base : buddy; // 合并到较小地址的块
ffffffffc0200b98:	00a77363          	bgeu	a4,a0,ffffffffc0200b9e <buddy_free_pages+0x7c>
ffffffffc0200b9c:	853a                	mv	a0,a4
        order++;
ffffffffc0200b9e:	2685                	addiw	a3,a3,1
    while (order <= MAX_ORDER)
ffffffffc0200ba0:	05f68063          	beq	a3,t6,ffffffffc0200be0 <buddy_free_pages+0xbe>
ffffffffc0200ba4:	000f3703          	ld	a4,0(t5)
        uintptr_t buddy_addr = addr ^ (1 << (PGSHIFT + order));
ffffffffc0200ba8:	00c6879b          	addiw	a5,a3,12
ffffffffc0200bac:	00f3163b          	sllw	a2,t1,a5
ffffffffc0200bb0:	40e507b3          	sub	a5,a0,a4
ffffffffc0200bb4:	878d                	srai	a5,a5,0x3
ffffffffc0200bb6:	03d787b3          	mul	a5,a5,t4
    if (PPN(pa) >= npage) {
ffffffffc0200bba:	000e3803          	ld	a6,0(t3)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bbe:	97c6                	add	a5,a5,a7
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bc0:	07b2                	slli	a5,a5,0xc
ffffffffc0200bc2:	8fb1                	xor	a5,a5,a2
    if (PPN(pa) >= npage) {
ffffffffc0200bc4:	00c7d613          	srli	a2,a5,0xc
ffffffffc0200bc8:	05067363          	bgeu	a2,a6,ffffffffc0200c0e <buddy_free_pages+0xec>
    return &pages[PPN(pa) - nbase];
ffffffffc0200bcc:	411605b3          	sub	a1,a2,a7
ffffffffc0200bd0:	00259613          	slli	a2,a1,0x2
ffffffffc0200bd4:	962e                	add	a2,a2,a1
ffffffffc0200bd6:	060e                	slli	a2,a2,0x3
        if (buddy_addr >= npage * PGSIZE || !PageProperty(buddy) || buddy->property != (1 << order))
ffffffffc0200bd8:	0832                	slli	a6,a6,0xc
ffffffffc0200bda:	9732                	add	a4,a4,a2
ffffffffc0200bdc:	f907eee3          	bltu	a5,a6,ffffffffc0200b78 <buddy_free_pages+0x56>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200be0:	00169793          	slli	a5,a3,0x1
ffffffffc0200be4:	96be                	add	a3,a3,a5
ffffffffc0200be6:	00369793          	slli	a5,a3,0x3
ffffffffc0200bea:	00004697          	auipc	a3,0x4
ffffffffc0200bee:	42668693          	addi	a3,a3,1062 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200bf2:	96be                	add	a3,a3,a5
ffffffffc0200bf4:	6698                	ld	a4,8(a3)
    buddy_free_area[order].nr_free++; // 更新空闲块数量
ffffffffc0200bf6:	4a9c                	lw	a5,16(a3)
    list_add(&buddy_free_area[order].free_list, &(base->page_link));
ffffffffc0200bf8:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200bfc:	e310                	sd	a2,0(a4)
ffffffffc0200bfe:	e690                	sd	a2,8(a3)
    elm->next = next;
ffffffffc0200c00:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200c02:	ed14                	sd	a3,24(a0)
    buddy_free_area[order].nr_free++; // 更新空闲块数量
ffffffffc0200c04:	2785                	addiw	a5,a5,1
ffffffffc0200c06:	ca9c                	sw	a5,16(a3)
ffffffffc0200c08:	8082                	ret
    while ((1 << order) < n)
ffffffffc0200c0a:	4785                	li	a5,1
ffffffffc0200c0c:	b72d                	j	ffffffffc0200b36 <buddy_free_pages+0x14>
{
ffffffffc0200c0e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0200c10:	00001617          	auipc	a2,0x1
ffffffffc0200c14:	f5860613          	addi	a2,a2,-168 # ffffffffc0201b68 <commands+0x570>
ffffffffc0200c18:	06b00593          	li	a1,107
ffffffffc0200c1c:	00001517          	auipc	a0,0x1
ffffffffc0200c20:	f6c50513          	addi	a0,a0,-148 # ffffffffc0201b88 <commands+0x590>
ffffffffc0200c24:	e406                	sd	ra,8(sp)
ffffffffc0200c26:	d14ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200c2a <buddy_check_2>:
    cprintf("伙伴系统测试1成功完成\n");
}

// 测试大规模块分配与释放
static void buddy_check_2(void)
{
ffffffffc0200c2a:	1101                	addi	sp,sp,-32
    cprintf("伙伴系统测试2开始\n");
ffffffffc0200c2c:	00001517          	auipc	a0,0x1
ffffffffc0200c30:	fcc50513          	addi	a0,a0,-52 # ffffffffc0201bf8 <commands+0x600>
{
ffffffffc0200c34:	ec06                	sd	ra,24(sp)
ffffffffc0200c36:	e822                	sd	s0,16(sp)
ffffffffc0200c38:	e426                	sd	s1,8(sp)
ffffffffc0200c3a:	e04a                	sd	s2,0(sp)
    cprintf("伙伴系统测试2开始\n");
ffffffffc0200c3c:	c76ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    // 分配较大的内存块
    assert((p0 = alloc_pages(128)) != NULL);
ffffffffc0200c40:	08000513          	li	a0,128
ffffffffc0200c44:	bbfff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c48:	c959                	beqz	a0,ffffffffc0200cde <buddy_check_2+0xb4>
ffffffffc0200c4a:	842a                	mv	s0,a0
    assert((p1 = alloc_pages(64)) != NULL);
ffffffffc0200c4c:	04000513          	li	a0,64
ffffffffc0200c50:	bb3ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c54:	892a                	mv	s2,a0
ffffffffc0200c56:	12050463          	beqz	a0,ffffffffc0200d7e <buddy_check_2+0x154>
    assert((p2 = alloc_pages(256)) != NULL);
ffffffffc0200c5a:	10000513          	li	a0,256
ffffffffc0200c5e:	ba5ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c62:	84aa                	mv	s1,a0
ffffffffc0200c64:	0e050d63          	beqz	a0,ffffffffc0200d5e <buddy_check_2+0x134>

    // 释放这些内存块
    free_pages(p0, 128);
ffffffffc0200c68:	08000593          	li	a1,128
ffffffffc0200c6c:	8522                	mv	a0,s0
ffffffffc0200c6e:	bd3ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_pages(p1, 64);
ffffffffc0200c72:	854a                	mv	a0,s2
ffffffffc0200c74:	04000593          	li	a1,64
ffffffffc0200c78:	bc9ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_pages(p2, 256);
ffffffffc0200c7c:	10000593          	li	a1,256
ffffffffc0200c80:	8526                	mv	a0,s1
ffffffffc0200c82:	bbfff0ef          	jal	ra,ffffffffc0200840 <free_pages>

    // 再次分配相同大小的块以验证内存是否正确释放
    assert((p0 = alloc_pages(128)) != NULL);
ffffffffc0200c86:	08000513          	li	a0,128
ffffffffc0200c8a:	b79ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c8e:	892a                	mv	s2,a0
ffffffffc0200c90:	c55d                	beqz	a0,ffffffffc0200d3e <buddy_check_2+0x114>
    assert((p1 = alloc_pages(64)) != NULL);
ffffffffc0200c92:	04000513          	li	a0,64
ffffffffc0200c96:	b6dff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c9a:	84aa                	mv	s1,a0
ffffffffc0200c9c:	c149                	beqz	a0,ffffffffc0200d1e <buddy_check_2+0xf4>
    assert((p2 = alloc_pages(256)) != NULL);
ffffffffc0200c9e:	10000513          	li	a0,256
ffffffffc0200ca2:	b61ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ca6:	842a                	mv	s0,a0
ffffffffc0200ca8:	c939                	beqz	a0,ffffffffc0200cfe <buddy_check_2+0xd4>

    // 最后释放所有内存块
    free_pages(p0, 128);
ffffffffc0200caa:	854a                	mv	a0,s2
ffffffffc0200cac:	08000593          	li	a1,128
ffffffffc0200cb0:	b91ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_pages(p1, 64);
ffffffffc0200cb4:	8526                	mv	a0,s1
ffffffffc0200cb6:	04000593          	li	a1,64
ffffffffc0200cba:	b87ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_pages(p2, 256);
ffffffffc0200cbe:	8522                	mv	a0,s0
ffffffffc0200cc0:	10000593          	li	a1,256
ffffffffc0200cc4:	b7dff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    cprintf("伙伴系统测试2成功完成\n");
}
ffffffffc0200cc8:	6442                	ld	s0,16(sp)
ffffffffc0200cca:	60e2                	ld	ra,24(sp)
ffffffffc0200ccc:	64a2                	ld	s1,8(sp)
ffffffffc0200cce:	6902                	ld	s2,0(sp)
    cprintf("伙伴系统测试2成功完成\n");
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	fd850513          	addi	a0,a0,-40 # ffffffffc0201ca8 <commands+0x6b0>
}
ffffffffc0200cd8:	6105                	addi	sp,sp,32
    cprintf("伙伴系统测试2成功完成\n");
ffffffffc0200cda:	bd8ff06f          	j	ffffffffc02000b2 <cprintf>
    assert((p0 = alloc_pages(128)) != NULL);
ffffffffc0200cde:	00001697          	auipc	a3,0x1
ffffffffc0200ce2:	f3a68693          	addi	a3,a3,-198 # ffffffffc0201c18 <commands+0x620>
ffffffffc0200ce6:	00001617          	auipc	a2,0x1
ffffffffc0200cea:	f5260613          	addi	a2,a2,-174 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200cee:	0db00593          	li	a1,219
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200cfa:	c40ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_pages(256)) != NULL);
ffffffffc0200cfe:	00001697          	auipc	a3,0x1
ffffffffc0200d02:	f8a68693          	addi	a3,a3,-118 # ffffffffc0201c88 <commands+0x690>
ffffffffc0200d06:	00001617          	auipc	a2,0x1
ffffffffc0200d0a:	f3260613          	addi	a2,a2,-206 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200d0e:	0e700593          	li	a1,231
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	f3e50513          	addi	a0,a0,-194 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200d1a:	c20ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_pages(64)) != NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	f4a68693          	addi	a3,a3,-182 # ffffffffc0201c68 <commands+0x670>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	f1260613          	addi	a2,a2,-238 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200d2e:	0e600593          	li	a1,230
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	f1e50513          	addi	a0,a0,-226 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200d3a:	c00ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_pages(128)) != NULL);
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	eda68693          	addi	a3,a3,-294 # ffffffffc0201c18 <commands+0x620>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	ef260613          	addi	a2,a2,-270 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200d4e:	0e500593          	li	a1,229
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	efe50513          	addi	a0,a0,-258 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200d5a:	be0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_pages(256)) != NULL);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	f2a68693          	addi	a3,a3,-214 # ffffffffc0201c88 <commands+0x690>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	ed260613          	addi	a2,a2,-302 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200d6e:	0dd00593          	li	a1,221
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	ede50513          	addi	a0,a0,-290 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200d7a:	bc0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_pages(64)) != NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	eea68693          	addi	a3,a3,-278 # ffffffffc0201c68 <commands+0x670>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	eb260613          	addi	a2,a2,-334 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200d8e:	0dc00593          	li	a1,220
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	ebe50513          	addi	a0,a0,-322 # ffffffffc0201c50 <commands+0x658>
ffffffffc0200d9a:	ba0ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200d9e <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0200d9e:	c1bd                	beqz	a1,ffffffffc0200e04 <buddy_init_memmap+0x66>
    while ((1 << order) > n)
ffffffffc0200da0:	3ff00713          	li	a4,1023
    int order = MAX_ORDER;
ffffffffc0200da4:	47a9                	li	a5,10
    while ((1 << order) > n)
ffffffffc0200da6:	4685                	li	a3,1
ffffffffc0200da8:	04b76863          	bltu	a4,a1,ffffffffc0200df8 <buddy_init_memmap+0x5a>
        order--;
ffffffffc0200dac:	37fd                	addiw	a5,a5,-1
    while ((1 << order) > n)
ffffffffc0200dae:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200db2:	fee5ede3          	bltu	a1,a4,ffffffffc0200dac <buddy_init_memmap+0xe>
ffffffffc0200db6:	00179693          	slli	a3,a5,0x1
ffffffffc0200dba:	00f68633          	add	a2,a3,a5
ffffffffc0200dbe:	060e                	slli	a2,a2,0x3
    base->property = (1 << order);
ffffffffc0200dc0:	2701                	sext.w	a4,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200dc2:	97b6                	add	a5,a5,a3
ffffffffc0200dc4:	078e                	slli	a5,a5,0x3
ffffffffc0200dc6:	00004697          	auipc	a3,0x4
ffffffffc0200dca:	24a68693          	addi	a3,a3,586 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200dce:	97b6                	add	a5,a5,a3
ffffffffc0200dd0:	678c                	ld	a1,8(a5)
    list_add(&buddy_free_area[order].free_list, &(base->page_link));
ffffffffc0200dd2:	01850813          	addi	a6,a0,24
ffffffffc0200dd6:	96b2                	add	a3,a3,a2
    prev->next = next->prev = elm;
ffffffffc0200dd8:	0105b023          	sd	a6,0(a1)
ffffffffc0200ddc:	0107b423          	sd	a6,8(a5)
    elm->prev = prev;
ffffffffc0200de0:	ed14                	sd	a3,24(a0)
    base->property = (1 << order);
ffffffffc0200de2:	c918                	sw	a4,16(a0)
    elm->next = next;
ffffffffc0200de4:	f10c                	sd	a1,32(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200de6:	4709                	li	a4,2
ffffffffc0200de8:	00850693          	addi	a3,a0,8
ffffffffc0200dec:	40e6b02f          	amoor.d	zero,a4,(a3)
    buddy_free_area[order].nr_free++;
ffffffffc0200df0:	4b98                	lw	a4,16(a5)
ffffffffc0200df2:	2705                	addiw	a4,a4,1
ffffffffc0200df4:	cb98                	sw	a4,16(a5)
ffffffffc0200df6:	8082                	ret
    while ((1 << order) > n)
ffffffffc0200df8:	40000713          	li	a4,1024
ffffffffc0200dfc:	0f000613          	li	a2,240
ffffffffc0200e00:	46d1                	li	a3,20
ffffffffc0200e02:	b7c1                	j	ffffffffc0200dc2 <buddy_init_memmap+0x24>
{
ffffffffc0200e04:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200e06:	00001697          	auipc	a3,0x1
ffffffffc0200e0a:	eca68693          	addi	a3,a3,-310 # ffffffffc0201cd0 <commands+0x6d8>
ffffffffc0200e0e:	00001617          	auipc	a2,0x1
ffffffffc0200e12:	e2a60613          	addi	a2,a2,-470 # ffffffffc0201c38 <commands+0x640>
ffffffffc0200e16:	45dd                	li	a1,23
ffffffffc0200e18:	00001517          	auipc	a0,0x1
ffffffffc0200e1c:	e3850513          	addi	a0,a0,-456 # ffffffffc0201c50 <commands+0x658>
{
ffffffffc0200e20:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e22:	b18ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200e26 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200e26:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200e28:	e589                	bnez	a1,ffffffffc0200e32 <strnlen+0xc>
ffffffffc0200e2a:	a811                	j	ffffffffc0200e3e <strnlen+0x18>
        cnt ++;
ffffffffc0200e2c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200e2e:	00f58863          	beq	a1,a5,ffffffffc0200e3e <strnlen+0x18>
ffffffffc0200e32:	00f50733          	add	a4,a0,a5
ffffffffc0200e36:	00074703          	lbu	a4,0(a4)
ffffffffc0200e3a:	fb6d                	bnez	a4,ffffffffc0200e2c <strnlen+0x6>
ffffffffc0200e3c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200e3e:	852e                	mv	a0,a1
ffffffffc0200e40:	8082                	ret

ffffffffc0200e42 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200e42:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200e46:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200e4a:	cb89                	beqz	a5,ffffffffc0200e5c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200e4c:	0505                	addi	a0,a0,1
ffffffffc0200e4e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200e50:	fee789e3          	beq	a5,a4,ffffffffc0200e42 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200e54:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0200e58:	9d19                	subw	a0,a0,a4
ffffffffc0200e5a:	8082                	ret
ffffffffc0200e5c:	4501                	li	a0,0
ffffffffc0200e5e:	bfed                	j	ffffffffc0200e58 <strcmp+0x16>

ffffffffc0200e60 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0200e60:	00054783          	lbu	a5,0(a0)
ffffffffc0200e64:	c799                	beqz	a5,ffffffffc0200e72 <strchr+0x12>
        if (*s == c) {
ffffffffc0200e66:	00f58763          	beq	a1,a5,ffffffffc0200e74 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0200e6a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0200e6e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0200e70:	fbfd                	bnez	a5,ffffffffc0200e66 <strchr+0x6>
    }
    return NULL;
ffffffffc0200e72:	4501                	li	a0,0
}
ffffffffc0200e74:	8082                	ret

ffffffffc0200e76 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0200e76:	ca01                	beqz	a2,ffffffffc0200e86 <memset+0x10>
ffffffffc0200e78:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0200e7a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0200e7c:	0785                	addi	a5,a5,1
ffffffffc0200e7e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0200e82:	fec79de3          	bne	a5,a2,ffffffffc0200e7c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0200e86:	8082                	ret

ffffffffc0200e88 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200e88:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e8c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200e8e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e92:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200e94:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e98:	f022                	sd	s0,32(sp)
ffffffffc0200e9a:	ec26                	sd	s1,24(sp)
ffffffffc0200e9c:	e84a                	sd	s2,16(sp)
ffffffffc0200e9e:	f406                	sd	ra,40(sp)
ffffffffc0200ea0:	e44e                	sd	s3,8(sp)
ffffffffc0200ea2:	84aa                	mv	s1,a0
ffffffffc0200ea4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200ea6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200eaa:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200eac:	03067e63          	bgeu	a2,a6,ffffffffc0200ee8 <printnum+0x60>
ffffffffc0200eb0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200eb2:	00805763          	blez	s0,ffffffffc0200ec0 <printnum+0x38>
ffffffffc0200eb6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200eb8:	85ca                	mv	a1,s2
ffffffffc0200eba:	854e                	mv	a0,s3
ffffffffc0200ebc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200ebe:	fc65                	bnez	s0,ffffffffc0200eb6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ec0:	1a02                	slli	s4,s4,0x20
ffffffffc0200ec2:	00001797          	auipc	a5,0x1
ffffffffc0200ec6:	e6e78793          	addi	a5,a5,-402 # ffffffffc0201d30 <buddy_system_pmm_manager+0x38>
ffffffffc0200eca:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200ece:	9a3e                	add	s4,s4,a5
}
ffffffffc0200ed0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ed2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200ed6:	70a2                	ld	ra,40(sp)
ffffffffc0200ed8:	69a2                	ld	s3,8(sp)
ffffffffc0200eda:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200edc:	85ca                	mv	a1,s2
ffffffffc0200ede:	87a6                	mv	a5,s1
}
ffffffffc0200ee0:	6942                	ld	s2,16(sp)
ffffffffc0200ee2:	64e2                	ld	s1,24(sp)
ffffffffc0200ee4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ee6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200ee8:	03065633          	divu	a2,a2,a6
ffffffffc0200eec:	8722                	mv	a4,s0
ffffffffc0200eee:	f9bff0ef          	jal	ra,ffffffffc0200e88 <printnum>
ffffffffc0200ef2:	b7f9                	j	ffffffffc0200ec0 <printnum+0x38>

ffffffffc0200ef4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200ef4:	7119                	addi	sp,sp,-128
ffffffffc0200ef6:	f4a6                	sd	s1,104(sp)
ffffffffc0200ef8:	f0ca                	sd	s2,96(sp)
ffffffffc0200efa:	ecce                	sd	s3,88(sp)
ffffffffc0200efc:	e8d2                	sd	s4,80(sp)
ffffffffc0200efe:	e4d6                	sd	s5,72(sp)
ffffffffc0200f00:	e0da                	sd	s6,64(sp)
ffffffffc0200f02:	fc5e                	sd	s7,56(sp)
ffffffffc0200f04:	f06a                	sd	s10,32(sp)
ffffffffc0200f06:	fc86                	sd	ra,120(sp)
ffffffffc0200f08:	f8a2                	sd	s0,112(sp)
ffffffffc0200f0a:	f862                	sd	s8,48(sp)
ffffffffc0200f0c:	f466                	sd	s9,40(sp)
ffffffffc0200f0e:	ec6e                	sd	s11,24(sp)
ffffffffc0200f10:	892a                	mv	s2,a0
ffffffffc0200f12:	84ae                	mv	s1,a1
ffffffffc0200f14:	8d32                	mv	s10,a2
ffffffffc0200f16:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f18:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200f1c:	5b7d                	li	s6,-1
ffffffffc0200f1e:	00001a97          	auipc	s5,0x1
ffffffffc0200f22:	e46a8a93          	addi	s5,s5,-442 # ffffffffc0201d64 <buddy_system_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200f26:	00001b97          	auipc	s7,0x1
ffffffffc0200f2a:	01ab8b93          	addi	s7,s7,26 # ffffffffc0201f40 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f2e:	000d4503          	lbu	a0,0(s10)
ffffffffc0200f32:	001d0413          	addi	s0,s10,1
ffffffffc0200f36:	01350a63          	beq	a0,s3,ffffffffc0200f4a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200f3a:	c121                	beqz	a0,ffffffffc0200f7a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200f3c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f3e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200f40:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f42:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200f46:	ff351ae3          	bne	a0,s3,ffffffffc0200f3a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f4a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200f4e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200f52:	4c81                	li	s9,0
ffffffffc0200f54:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200f56:	5c7d                	li	s8,-1
ffffffffc0200f58:	5dfd                	li	s11,-1
ffffffffc0200f5a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200f5e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f60:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200f64:	0ff5f593          	zext.b	a1,a1
ffffffffc0200f68:	00140d13          	addi	s10,s0,1
ffffffffc0200f6c:	04b56263          	bltu	a0,a1,ffffffffc0200fb0 <vprintfmt+0xbc>
ffffffffc0200f70:	058a                	slli	a1,a1,0x2
ffffffffc0200f72:	95d6                	add	a1,a1,s5
ffffffffc0200f74:	4194                	lw	a3,0(a1)
ffffffffc0200f76:	96d6                	add	a3,a3,s5
ffffffffc0200f78:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200f7a:	70e6                	ld	ra,120(sp)
ffffffffc0200f7c:	7446                	ld	s0,112(sp)
ffffffffc0200f7e:	74a6                	ld	s1,104(sp)
ffffffffc0200f80:	7906                	ld	s2,96(sp)
ffffffffc0200f82:	69e6                	ld	s3,88(sp)
ffffffffc0200f84:	6a46                	ld	s4,80(sp)
ffffffffc0200f86:	6aa6                	ld	s5,72(sp)
ffffffffc0200f88:	6b06                	ld	s6,64(sp)
ffffffffc0200f8a:	7be2                	ld	s7,56(sp)
ffffffffc0200f8c:	7c42                	ld	s8,48(sp)
ffffffffc0200f8e:	7ca2                	ld	s9,40(sp)
ffffffffc0200f90:	7d02                	ld	s10,32(sp)
ffffffffc0200f92:	6de2                	ld	s11,24(sp)
ffffffffc0200f94:	6109                	addi	sp,sp,128
ffffffffc0200f96:	8082                	ret
            padc = '0';
ffffffffc0200f98:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200f9a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f9e:	846a                	mv	s0,s10
ffffffffc0200fa0:	00140d13          	addi	s10,s0,1
ffffffffc0200fa4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200fa8:	0ff5f593          	zext.b	a1,a1
ffffffffc0200fac:	fcb572e3          	bgeu	a0,a1,ffffffffc0200f70 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200fb0:	85a6                	mv	a1,s1
ffffffffc0200fb2:	02500513          	li	a0,37
ffffffffc0200fb6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200fb8:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200fbc:	8d22                	mv	s10,s0
ffffffffc0200fbe:	f73788e3          	beq	a5,s3,ffffffffc0200f2e <vprintfmt+0x3a>
ffffffffc0200fc2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200fc6:	1d7d                	addi	s10,s10,-1
ffffffffc0200fc8:	ff379de3          	bne	a5,s3,ffffffffc0200fc2 <vprintfmt+0xce>
ffffffffc0200fcc:	b78d                	j	ffffffffc0200f2e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200fce:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200fd2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fd6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200fd8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200fdc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200fe0:	02d86463          	bltu	a6,a3,ffffffffc0201008 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200fe4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200fe8:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200fec:	0186873b          	addw	a4,a3,s8
ffffffffc0200ff0:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200ff4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200ff6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200ffa:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200ffc:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201000:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201004:	fed870e3          	bgeu	a6,a3,ffffffffc0200fe4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201008:	f40ddce3          	bgez	s11,ffffffffc0200f60 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020100c:	8de2                	mv	s11,s8
ffffffffc020100e:	5c7d                	li	s8,-1
ffffffffc0201010:	bf81                	j	ffffffffc0200f60 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201012:	fffdc693          	not	a3,s11
ffffffffc0201016:	96fd                	srai	a3,a3,0x3f
ffffffffc0201018:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020101c:	00144603          	lbu	a2,1(s0)
ffffffffc0201020:	2d81                	sext.w	s11,s11
ffffffffc0201022:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201024:	bf35                	j	ffffffffc0200f60 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201026:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020102a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020102e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201030:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201032:	bfd9                	j	ffffffffc0201008 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201034:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201036:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020103a:	01174463          	blt	a4,a7,ffffffffc0201042 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020103e:	1a088e63          	beqz	a7,ffffffffc02011fa <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201042:	000a3603          	ld	a2,0(s4)
ffffffffc0201046:	46c1                	li	a3,16
ffffffffc0201048:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020104a:	2781                	sext.w	a5,a5
ffffffffc020104c:	876e                	mv	a4,s11
ffffffffc020104e:	85a6                	mv	a1,s1
ffffffffc0201050:	854a                	mv	a0,s2
ffffffffc0201052:	e37ff0ef          	jal	ra,ffffffffc0200e88 <printnum>
            break;
ffffffffc0201056:	bde1                	j	ffffffffc0200f2e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201058:	000a2503          	lw	a0,0(s4)
ffffffffc020105c:	85a6                	mv	a1,s1
ffffffffc020105e:	0a21                	addi	s4,s4,8
ffffffffc0201060:	9902                	jalr	s2
            break;
ffffffffc0201062:	b5f1                	j	ffffffffc0200f2e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201064:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201066:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020106a:	01174463          	blt	a4,a7,ffffffffc0201072 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020106e:	18088163          	beqz	a7,ffffffffc02011f0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201072:	000a3603          	ld	a2,0(s4)
ffffffffc0201076:	46a9                	li	a3,10
ffffffffc0201078:	8a2e                	mv	s4,a1
ffffffffc020107a:	bfc1                	j	ffffffffc020104a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020107c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201080:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201082:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201084:	bdf1                	j	ffffffffc0200f60 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201086:	85a6                	mv	a1,s1
ffffffffc0201088:	02500513          	li	a0,37
ffffffffc020108c:	9902                	jalr	s2
            break;
ffffffffc020108e:	b545                	j	ffffffffc0200f2e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201090:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201094:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201096:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201098:	b5e1                	j	ffffffffc0200f60 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020109a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020109c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02010a0:	01174463          	blt	a4,a7,ffffffffc02010a8 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02010a4:	14088163          	beqz	a7,ffffffffc02011e6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02010a8:	000a3603          	ld	a2,0(s4)
ffffffffc02010ac:	46a1                	li	a3,8
ffffffffc02010ae:	8a2e                	mv	s4,a1
ffffffffc02010b0:	bf69                	j	ffffffffc020104a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02010b2:	03000513          	li	a0,48
ffffffffc02010b6:	85a6                	mv	a1,s1
ffffffffc02010b8:	e03e                	sd	a5,0(sp)
ffffffffc02010ba:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02010bc:	85a6                	mv	a1,s1
ffffffffc02010be:	07800513          	li	a0,120
ffffffffc02010c2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02010c4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02010c6:	6782                	ld	a5,0(sp)
ffffffffc02010c8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02010ca:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02010ce:	bfb5                	j	ffffffffc020104a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02010d0:	000a3403          	ld	s0,0(s4)
ffffffffc02010d4:	008a0713          	addi	a4,s4,8
ffffffffc02010d8:	e03a                	sd	a4,0(sp)
ffffffffc02010da:	14040263          	beqz	s0,ffffffffc020121e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02010de:	0fb05763          	blez	s11,ffffffffc02011cc <vprintfmt+0x2d8>
ffffffffc02010e2:	02d00693          	li	a3,45
ffffffffc02010e6:	0cd79163          	bne	a5,a3,ffffffffc02011a8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010ea:	00044783          	lbu	a5,0(s0)
ffffffffc02010ee:	0007851b          	sext.w	a0,a5
ffffffffc02010f2:	cf85                	beqz	a5,ffffffffc020112a <vprintfmt+0x236>
ffffffffc02010f4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010f8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010fc:	000c4563          	bltz	s8,ffffffffc0201106 <vprintfmt+0x212>
ffffffffc0201100:	3c7d                	addiw	s8,s8,-1
ffffffffc0201102:	036c0263          	beq	s8,s6,ffffffffc0201126 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201106:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201108:	0e0c8e63          	beqz	s9,ffffffffc0201204 <vprintfmt+0x310>
ffffffffc020110c:	3781                	addiw	a5,a5,-32
ffffffffc020110e:	0ef47b63          	bgeu	s0,a5,ffffffffc0201204 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201112:	03f00513          	li	a0,63
ffffffffc0201116:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201118:	000a4783          	lbu	a5,0(s4)
ffffffffc020111c:	3dfd                	addiw	s11,s11,-1
ffffffffc020111e:	0a05                	addi	s4,s4,1
ffffffffc0201120:	0007851b          	sext.w	a0,a5
ffffffffc0201124:	ffe1                	bnez	a5,ffffffffc02010fc <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201126:	01b05963          	blez	s11,ffffffffc0201138 <vprintfmt+0x244>
ffffffffc020112a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020112c:	85a6                	mv	a1,s1
ffffffffc020112e:	02000513          	li	a0,32
ffffffffc0201132:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201134:	fe0d9be3          	bnez	s11,ffffffffc020112a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201138:	6a02                	ld	s4,0(sp)
ffffffffc020113a:	bbd5                	j	ffffffffc0200f2e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020113c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020113e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201142:	01174463          	blt	a4,a7,ffffffffc020114a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201146:	08088d63          	beqz	a7,ffffffffc02011e0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020114a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020114e:	0a044d63          	bltz	s0,ffffffffc0201208 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201152:	8622                	mv	a2,s0
ffffffffc0201154:	8a66                	mv	s4,s9
ffffffffc0201156:	46a9                	li	a3,10
ffffffffc0201158:	bdcd                	j	ffffffffc020104a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020115a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020115e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201160:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201162:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201166:	8fb5                	xor	a5,a5,a3
ffffffffc0201168:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020116c:	02d74163          	blt	a4,a3,ffffffffc020118e <vprintfmt+0x29a>
ffffffffc0201170:	00369793          	slli	a5,a3,0x3
ffffffffc0201174:	97de                	add	a5,a5,s7
ffffffffc0201176:	639c                	ld	a5,0(a5)
ffffffffc0201178:	cb99                	beqz	a5,ffffffffc020118e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020117a:	86be                	mv	a3,a5
ffffffffc020117c:	00001617          	auipc	a2,0x1
ffffffffc0201180:	be460613          	addi	a2,a2,-1052 # ffffffffc0201d60 <buddy_system_pmm_manager+0x68>
ffffffffc0201184:	85a6                	mv	a1,s1
ffffffffc0201186:	854a                	mv	a0,s2
ffffffffc0201188:	0ce000ef          	jal	ra,ffffffffc0201256 <printfmt>
ffffffffc020118c:	b34d                	j	ffffffffc0200f2e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020118e:	00001617          	auipc	a2,0x1
ffffffffc0201192:	bc260613          	addi	a2,a2,-1086 # ffffffffc0201d50 <buddy_system_pmm_manager+0x58>
ffffffffc0201196:	85a6                	mv	a1,s1
ffffffffc0201198:	854a                	mv	a0,s2
ffffffffc020119a:	0bc000ef          	jal	ra,ffffffffc0201256 <printfmt>
ffffffffc020119e:	bb41                	j	ffffffffc0200f2e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02011a0:	00001417          	auipc	s0,0x1
ffffffffc02011a4:	ba840413          	addi	s0,s0,-1112 # ffffffffc0201d48 <buddy_system_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02011a8:	85e2                	mv	a1,s8
ffffffffc02011aa:	8522                	mv	a0,s0
ffffffffc02011ac:	e43e                	sd	a5,8(sp)
ffffffffc02011ae:	c79ff0ef          	jal	ra,ffffffffc0200e26 <strnlen>
ffffffffc02011b2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02011b6:	01b05b63          	blez	s11,ffffffffc02011cc <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02011ba:	67a2                	ld	a5,8(sp)
ffffffffc02011bc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02011c0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02011c2:	85a6                	mv	a1,s1
ffffffffc02011c4:	8552                	mv	a0,s4
ffffffffc02011c6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02011c8:	fe0d9ce3          	bnez	s11,ffffffffc02011c0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011cc:	00044783          	lbu	a5,0(s0)
ffffffffc02011d0:	00140a13          	addi	s4,s0,1
ffffffffc02011d4:	0007851b          	sext.w	a0,a5
ffffffffc02011d8:	d3a5                	beqz	a5,ffffffffc0201138 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011da:	05e00413          	li	s0,94
ffffffffc02011de:	bf39                	j	ffffffffc02010fc <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02011e0:	000a2403          	lw	s0,0(s4)
ffffffffc02011e4:	b7ad                	j	ffffffffc020114e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02011e6:	000a6603          	lwu	a2,0(s4)
ffffffffc02011ea:	46a1                	li	a3,8
ffffffffc02011ec:	8a2e                	mv	s4,a1
ffffffffc02011ee:	bdb1                	j	ffffffffc020104a <vprintfmt+0x156>
ffffffffc02011f0:	000a6603          	lwu	a2,0(s4)
ffffffffc02011f4:	46a9                	li	a3,10
ffffffffc02011f6:	8a2e                	mv	s4,a1
ffffffffc02011f8:	bd89                	j	ffffffffc020104a <vprintfmt+0x156>
ffffffffc02011fa:	000a6603          	lwu	a2,0(s4)
ffffffffc02011fe:	46c1                	li	a3,16
ffffffffc0201200:	8a2e                	mv	s4,a1
ffffffffc0201202:	b5a1                	j	ffffffffc020104a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201204:	9902                	jalr	s2
ffffffffc0201206:	bf09                	j	ffffffffc0201118 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201208:	85a6                	mv	a1,s1
ffffffffc020120a:	02d00513          	li	a0,45
ffffffffc020120e:	e03e                	sd	a5,0(sp)
ffffffffc0201210:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201212:	6782                	ld	a5,0(sp)
ffffffffc0201214:	8a66                	mv	s4,s9
ffffffffc0201216:	40800633          	neg	a2,s0
ffffffffc020121a:	46a9                	li	a3,10
ffffffffc020121c:	b53d                	j	ffffffffc020104a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020121e:	03b05163          	blez	s11,ffffffffc0201240 <vprintfmt+0x34c>
ffffffffc0201222:	02d00693          	li	a3,45
ffffffffc0201226:	f6d79de3          	bne	a5,a3,ffffffffc02011a0 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020122a:	00001417          	auipc	s0,0x1
ffffffffc020122e:	b1e40413          	addi	s0,s0,-1250 # ffffffffc0201d48 <buddy_system_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201232:	02800793          	li	a5,40
ffffffffc0201236:	02800513          	li	a0,40
ffffffffc020123a:	00140a13          	addi	s4,s0,1
ffffffffc020123e:	bd6d                	j	ffffffffc02010f8 <vprintfmt+0x204>
ffffffffc0201240:	00001a17          	auipc	s4,0x1
ffffffffc0201244:	b09a0a13          	addi	s4,s4,-1271 # ffffffffc0201d49 <buddy_system_pmm_manager+0x51>
ffffffffc0201248:	02800513          	li	a0,40
ffffffffc020124c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201250:	05e00413          	li	s0,94
ffffffffc0201254:	b565                	j	ffffffffc02010fc <vprintfmt+0x208>

ffffffffc0201256 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201256:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201258:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020125c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020125e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201260:	ec06                	sd	ra,24(sp)
ffffffffc0201262:	f83a                	sd	a4,48(sp)
ffffffffc0201264:	fc3e                	sd	a5,56(sp)
ffffffffc0201266:	e0c2                	sd	a6,64(sp)
ffffffffc0201268:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020126a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020126c:	c89ff0ef          	jal	ra,ffffffffc0200ef4 <vprintfmt>
}
ffffffffc0201270:	60e2                	ld	ra,24(sp)
ffffffffc0201272:	6161                	addi	sp,sp,80
ffffffffc0201274:	8082                	ret

ffffffffc0201276 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201276:	715d                	addi	sp,sp,-80
ffffffffc0201278:	e486                	sd	ra,72(sp)
ffffffffc020127a:	e0a6                	sd	s1,64(sp)
ffffffffc020127c:	fc4a                	sd	s2,56(sp)
ffffffffc020127e:	f84e                	sd	s3,48(sp)
ffffffffc0201280:	f452                	sd	s4,40(sp)
ffffffffc0201282:	f056                	sd	s5,32(sp)
ffffffffc0201284:	ec5a                	sd	s6,24(sp)
ffffffffc0201286:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201288:	c901                	beqz	a0,ffffffffc0201298 <readline+0x22>
ffffffffc020128a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020128c:	00001517          	auipc	a0,0x1
ffffffffc0201290:	ad450513          	addi	a0,a0,-1324 # ffffffffc0201d60 <buddy_system_pmm_manager+0x68>
ffffffffc0201294:	e1ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201298:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020129a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020129c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020129e:	4aa9                	li	s5,10
ffffffffc02012a0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02012a2:	00004b97          	auipc	s7,0x4
ffffffffc02012a6:	e76b8b93          	addi	s7,s7,-394 # ffffffffc0205118 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012aa:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02012ae:	e7dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02012b2:	00054a63          	bltz	a0,ffffffffc02012c6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012b6:	00a95a63          	bge	s2,a0,ffffffffc02012ca <readline+0x54>
ffffffffc02012ba:	029a5263          	bge	s4,s1,ffffffffc02012de <readline+0x68>
        c = getchar();
ffffffffc02012be:	e6dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02012c2:	fe055ae3          	bgez	a0,ffffffffc02012b6 <readline+0x40>
            return NULL;
ffffffffc02012c6:	4501                	li	a0,0
ffffffffc02012c8:	a091                	j	ffffffffc020130c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02012ca:	03351463          	bne	a0,s3,ffffffffc02012f2 <readline+0x7c>
ffffffffc02012ce:	e8a9                	bnez	s1,ffffffffc0201320 <readline+0xaa>
        c = getchar();
ffffffffc02012d0:	e5bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02012d4:	fe0549e3          	bltz	a0,ffffffffc02012c6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012d8:	fea959e3          	bge	s2,a0,ffffffffc02012ca <readline+0x54>
ffffffffc02012dc:	4481                	li	s1,0
            cputchar(c);
ffffffffc02012de:	e42a                	sd	a0,8(sp)
ffffffffc02012e0:	e09fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02012e4:	6522                	ld	a0,8(sp)
ffffffffc02012e6:	009b87b3          	add	a5,s7,s1
ffffffffc02012ea:	2485                	addiw	s1,s1,1
ffffffffc02012ec:	00a78023          	sb	a0,0(a5)
ffffffffc02012f0:	bf7d                	j	ffffffffc02012ae <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02012f2:	01550463          	beq	a0,s5,ffffffffc02012fa <readline+0x84>
ffffffffc02012f6:	fb651ce3          	bne	a0,s6,ffffffffc02012ae <readline+0x38>
            cputchar(c);
ffffffffc02012fa:	deffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02012fe:	00004517          	auipc	a0,0x4
ffffffffc0201302:	e1a50513          	addi	a0,a0,-486 # ffffffffc0205118 <buf>
ffffffffc0201306:	94aa                	add	s1,s1,a0
ffffffffc0201308:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020130c:	60a6                	ld	ra,72(sp)
ffffffffc020130e:	6486                	ld	s1,64(sp)
ffffffffc0201310:	7962                	ld	s2,56(sp)
ffffffffc0201312:	79c2                	ld	s3,48(sp)
ffffffffc0201314:	7a22                	ld	s4,40(sp)
ffffffffc0201316:	7a82                	ld	s5,32(sp)
ffffffffc0201318:	6b62                	ld	s6,24(sp)
ffffffffc020131a:	6bc2                	ld	s7,16(sp)
ffffffffc020131c:	6161                	addi	sp,sp,80
ffffffffc020131e:	8082                	ret
            cputchar(c);
ffffffffc0201320:	4521                	li	a0,8
ffffffffc0201322:	dc7fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201326:	34fd                	addiw	s1,s1,-1
ffffffffc0201328:	b759                	j	ffffffffc02012ae <readline+0x38>

ffffffffc020132a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020132a:	4781                	li	a5,0
ffffffffc020132c:	00004717          	auipc	a4,0x4
ffffffffc0201330:	cdc73703          	ld	a4,-804(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201334:	88ba                	mv	a7,a4
ffffffffc0201336:	852a                	mv	a0,a0
ffffffffc0201338:	85be                	mv	a1,a5
ffffffffc020133a:	863e                	mv	a2,a5
ffffffffc020133c:	00000073          	ecall
ffffffffc0201340:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201342:	8082                	ret

ffffffffc0201344 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201344:	4781                	li	a5,0
ffffffffc0201346:	00004717          	auipc	a4,0x4
ffffffffc020134a:	21273703          	ld	a4,530(a4) # ffffffffc0205558 <SBI_SET_TIMER>
ffffffffc020134e:	88ba                	mv	a7,a4
ffffffffc0201350:	852a                	mv	a0,a0
ffffffffc0201352:	85be                	mv	a1,a5
ffffffffc0201354:	863e                	mv	a2,a5
ffffffffc0201356:	00000073          	ecall
ffffffffc020135a:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020135c:	8082                	ret

ffffffffc020135e <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020135e:	4501                	li	a0,0
ffffffffc0201360:	00004797          	auipc	a5,0x4
ffffffffc0201364:	ca07b783          	ld	a5,-864(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201368:	88be                	mv	a7,a5
ffffffffc020136a:	852a                	mv	a0,a0
ffffffffc020136c:	85aa                	mv	a1,a0
ffffffffc020136e:	862a                	mv	a2,a0
ffffffffc0201370:	00000073          	ecall
ffffffffc0201374:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201376:	2501                	sext.w	a0,a0
ffffffffc0201378:	8082                	ret
