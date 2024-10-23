
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
ffffffffc020003e:	46e60613          	addi	a2,a2,1134 # ffffffffc02064a8 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	3bb010ef          	jal	ra,ffffffffc0201c04 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	bc650513          	addi	a0,a0,-1082 # ffffffffc0201c18 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	4c8010ef          	jal	ra,ffffffffc020152e <pmm_init>

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
ffffffffc02000a6:	688010ef          	jal	ra,ffffffffc020172e <vprintfmt>
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
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
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
ffffffffc02000dc:	652010ef          	jal	ra,ffffffffc020172e <vprintfmt>
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

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	afc50513          	addi	a0,a0,-1284 # ffffffffc0201c38 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	b0650513          	addi	a0,a0,-1274 # ffffffffc0201c58 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	ab858593          	addi	a1,a1,-1352 # ffffffffc0201c16 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0201c78 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0201c98 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	32258593          	addi	a1,a1,802 # ffffffffc02064a8 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0201cb8 <etext+0xa2>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	70d58593          	addi	a1,a1,1805 # ffffffffc02068a7 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0201cd8 <etext+0xc2>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0201d08 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0201d20 <etext+0x10a>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	b5260613          	addi	a2,a2,-1198 # ffffffffc0201d38 <etext+0x122>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	b6a58593          	addi	a1,a1,-1174 # ffffffffc0201d58 <etext+0x142>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0201d60 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0201d70 <etext+0x15a>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	b8c58593          	addi	a1,a1,-1140 # ffffffffc0201d98 <etext+0x182>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0201d60 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	b8860613          	addi	a2,a2,-1144 # ffffffffc0201da8 <etext+0x192>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	ba058593          	addi	a1,a1,-1120 # ffffffffc0201dc8 <etext+0x1b2>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	b3050513          	addi	a0,a0,-1232 # ffffffffc0201d60 <etext+0x14a>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0201dd8 <etext+0x1c2>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	b7450513          	addi	a0,a0,-1164 # ffffffffc0201e00 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	bcec0c13          	addi	s8,s8,-1074 # ffffffffc0201e70 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	b7e90913          	addi	s2,s2,-1154 # ffffffffc0201e28 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	b7e48493          	addi	s1,s1,-1154 # ffffffffc0201e30 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	b7cb0b13          	addi	s6,s6,-1156 # ffffffffc0201e38 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	a94a0a13          	addi	s4,s4,-1388 # ffffffffc0201d58 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	7e0010ef          	jal	ra,ffffffffc0201ab0 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	b8ad0d13          	addi	s10,s10,-1142 # ffffffffc0201e70 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	0dd010ef          	jal	ra,ffffffffc0201bd0 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	0c9010ef          	jal	ra,ffffffffc0201bd0 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	0a9010ef          	jal	ra,ffffffffc0201bee <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	06b010ef          	jal	ra,ffffffffc0201bee <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201e58 <etext+0x242>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	ade50513          	addi	a0,a0,-1314 # ffffffffc0201eb8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	91050513          	addi	a0,a0,-1776 # ffffffffc0201d00 <etext+0xea>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

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
ffffffffc0200420:	75e010ef          	jal	ra,ffffffffc0201b7e <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201ed8 <commands+0x68>
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
ffffffffc0200446:	7380106f          	j	ffffffffc0201b7e <sbi_set_timer>

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
ffffffffc0200450:	7140106f          	j	ffffffffc0201b64 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	7440106f          	j	ffffffffc0201b98 <sbi_console_getchar>

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
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201ef8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201f10 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201f28 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201f40 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201f58 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201f70 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	ab450513          	addi	a0,a0,-1356 # ffffffffc0201f88 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	abe50513          	addi	a0,a0,-1346 # ffffffffc0201fa0 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0201fb8 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201fd0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	adc50513          	addi	a0,a0,-1316 # ffffffffc0201fe8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0202000 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	af050513          	addi	a0,a0,-1296 # ffffffffc0202018 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0202030 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	b0450513          	addi	a0,a0,-1276 # ffffffffc0202048 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202060 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	b1850513          	addi	a0,a0,-1256 # ffffffffc0202078 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	b2250513          	addi	a0,a0,-1246 # ffffffffc0202090 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02020a8 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	b3650513          	addi	a0,a0,-1226 # ffffffffc02020c0 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	b4050513          	addi	a0,a0,-1216 # ffffffffc02020d8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02020f0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202108 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202120 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0202138 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202150 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0202168 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b8650513          	addi	a0,a0,-1146 # ffffffffc0202180 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b9050513          	addi	a0,a0,-1136 # ffffffffc0202198 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc02021b0 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	ba450513          	addi	a0,a0,-1116 # ffffffffc02021c8 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	baa50513          	addi	a0,a0,-1110 # ffffffffc02021e0 <commands+0x370>
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
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	bae50513          	addi	a0,a0,-1106 # ffffffffc02021f8 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	bae50513          	addi	a0,a0,-1106 # ffffffffc0202210 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	bb650513          	addi	a0,a0,-1098 # ffffffffc0202228 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0202240 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	bc250513          	addi	a0,a0,-1086 # ffffffffc0202258 <commands+0x3e8>
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
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	c8870713          	addi	a4,a4,-888 # ffffffffc0202338 <commands+0x4c8>
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
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02022d0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	be450513          	addi	a0,a0,-1052 # ffffffffc02022b0 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0202270 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	c1050513          	addi	a0,a0,-1008 # ffffffffc02022f0 <commands+0x480>
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
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
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
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	c0850513          	addi	a0,a0,-1016 # ffffffffc0202318 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202290 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0202308 <commands+0x498>
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

ffffffffc0200802 <buddy_init>:
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


static void 
buddy_init(void){
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n){
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
ffffffffc0200822:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200824:	20058763          	beqz	a1,ffffffffc0200a32 <buddy_free_pages+0x214>
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200828:	0015d793          	srli	a5,a1,0x1
ffffffffc020082c:	8fcd                	or	a5,a5,a1
ffffffffc020082e:	0027d713          	srli	a4,a5,0x2
ffffffffc0200832:	8fd9                	or	a5,a5,a4
ffffffffc0200834:	0047d713          	srli	a4,a5,0x4
ffffffffc0200838:	8f5d                	or	a4,a4,a5
ffffffffc020083a:	00875793          	srli	a5,a4,0x8
ffffffffc020083e:	8f5d                	or	a4,a4,a5
ffffffffc0200840:	01075793          	srli	a5,a4,0x10
ffffffffc0200844:	8fd9                	or	a5,a5,a4
ffffffffc0200846:	8385                	srli	a5,a5,0x1
ffffffffc0200848:	00b7f733          	and	a4,a5,a1
ffffffffc020084c:	8e2e                	mv	t3,a1
ffffffffc020084e:	1a071c63          	bnez	a4,ffffffffc0200a06 <buddy_free_pages+0x1e8>
    size_t begin = (base - allocate_area);
ffffffffc0200852:	00006897          	auipc	a7,0x6
ffffffffc0200856:	be68b883          	ld	a7,-1050(a7) # ffffffffc0206438 <allocate_area>
ffffffffc020085a:	411506b3          	sub	a3,a0,a7
ffffffffc020085e:	00002797          	auipc	a5,0x2
ffffffffc0200862:	18a7b783          	ld	a5,394(a5) # ffffffffc02029e8 <error_string+0x38>
ffffffffc0200866:	868d                	srai	a3,a3,0x3
ffffffffc0200868:	02f686b3          	mul	a3,a3,a5
    size_t block = BUDDY_BLOCK(begin, end);//要释放的内存所在的树节点索引
ffffffffc020086c:	00006817          	auipc	a6,0x6
ffffffffc0200870:	bd483803          	ld	a6,-1068(a6) # ffffffffc0206440 <full_tree_size>
    for (; p != base + n; p++)
ffffffffc0200874:	00259613          	slli	a2,a1,0x2
ffffffffc0200878:	962e                	add	a2,a2,a1
ffffffffc020087a:	060e                	slli	a2,a2,0x3
ffffffffc020087c:	962a                	add	a2,a2,a0
ffffffffc020087e:	87aa                	mv	a5,a0
    size_t block = BUDDY_BLOCK(begin, end);//要释放的内存所在的树节点索引
ffffffffc0200880:	03c6d6b3          	divu	a3,a3,t3
ffffffffc0200884:	03c85733          	divu	a4,a6,t3
ffffffffc0200888:	96ba                	add	a3,a3,a4
    for (; p != base + n; p++)
ffffffffc020088a:	00c50e63          	beq	a0,a2,ffffffffc02008a6 <buddy_free_pages+0x88>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020088e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p));
ffffffffc0200890:	8b05                	andi	a4,a4,1
ffffffffc0200892:	18071063          	bnez	a4,ffffffffc0200a12 <buddy_free_pages+0x1f4>
        p->flags = 0;
ffffffffc0200896:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020089a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020089e:	02878793          	addi	a5,a5,40
ffffffffc02008a2:	fec796e3          	bne	a5,a2,ffffffffc020088e <buddy_free_pages+0x70>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc02008a6:	00005317          	auipc	t1,0x5
ffffffffc02008aa:	76a30313          	addi	t1,t1,1898 # ffffffffc0206010 <free_area>
    nr_free += length;
ffffffffc02008ae:	01032783          	lw	a5,16(t1)
ffffffffc02008b2:	00833603          	ld	a2,8(t1)
    base->property = length;
ffffffffc02008b6:	000e071b          	sext.w	a4,t3
ffffffffc02008ba:	c918                	sw	a4,16(a0)
    list_add(&free_list, &(base->page_link));
ffffffffc02008bc:	01850e93          	addi	t4,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02008c0:	01d63023          	sd	t4,0(a2)
    nr_free += length;
ffffffffc02008c4:	9fb9                	addw	a5,a5,a4
    record_area[block] = length;
ffffffffc02008c6:	00006597          	auipc	a1,0x6
ffffffffc02008ca:	b925b583          	ld	a1,-1134(a1) # ffffffffc0206458 <record_area>
ffffffffc02008ce:	00369713          	slli	a4,a3,0x3
    elm->next = next;
ffffffffc02008d2:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02008d4:	00653c23          	sd	t1,24(a0)
    nr_free += length;
ffffffffc02008d8:	00f32823          	sw	a5,16(t1)
    prev->next = next->prev = elm;
ffffffffc02008dc:	01d33423          	sd	t4,8(t1)
    record_area[block] = length;
ffffffffc02008e0:	972e                	add	a4,a4,a1
ffffffffc02008e2:	01c73023          	sd	t3,0(a4)
    while (block != TREE_ROOT)
ffffffffc02008e6:	4785                	li	a5,1
ffffffffc02008e8:	4505                	li	a0,1
ffffffffc02008ea:	06f68563          	beq	a3,a5,ffffffffc0200954 <buddy_free_pages+0x136>
        size_t left = LEFT_CHILD(block);
ffffffffc02008ee:	ffe6f793          	andi	a5,a3,-2
        block = PARENT(block);
ffffffffc02008f2:	8285                	srli	a3,a3,0x1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc02008f4:	00f6e733          	or	a4,a3,a5
ffffffffc02008f8:	00275613          	srli	a2,a4,0x2
ffffffffc02008fc:	8f51                	or	a4,a4,a2
ffffffffc02008fe:	00475613          	srli	a2,a4,0x4
ffffffffc0200902:	8e59                	or	a2,a2,a4
ffffffffc0200904:	00865713          	srli	a4,a2,0x8
ffffffffc0200908:	8e59                	or	a2,a2,a4
ffffffffc020090a:	01065713          	srli	a4,a2,0x10
ffffffffc020090e:	8f51                	or	a4,a4,a2
ffffffffc0200910:	00379e13          	slli	t3,a5,0x3
ffffffffc0200914:	8305                	srli	a4,a4,0x1
ffffffffc0200916:	9e2e                	add	t3,t3,a1
ffffffffc0200918:	00f77f33          	and	t5,a4,a5
ffffffffc020091c:	000e3283          	ld	t0,0(t3)
        size_t left = LEFT_CHILD(block);
ffffffffc0200920:	863e                	mv	a2,a5
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0200922:	000f0663          	beqz	t5,ffffffffc020092e <buddy_free_pages+0x110>
ffffffffc0200926:	fff74713          	not	a4,a4
ffffffffc020092a:	00f77633          	and	a2,a4,a5
ffffffffc020092e:	02c85733          	divu	a4,a6,a2
            record_area[block] = record_area[left] << 1;
ffffffffc0200932:	00369613          	slli	a2,a3,0x3
ffffffffc0200936:	00c58eb3          	add	t4,a1,a2
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc020093a:	02e28163          	beq	t0,a4,ffffffffc020095c <buddy_free_pages+0x13e>
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc020093e:	00469793          	slli	a5,a3,0x4
ffffffffc0200942:	97ae                	add	a5,a5,a1
ffffffffc0200944:	9676                	add	a2,a2,t4
ffffffffc0200946:	679c                	ld	a5,8(a5)
ffffffffc0200948:	6218                	ld	a4,0(a2)
ffffffffc020094a:	8fd9                	or	a5,a5,a4
ffffffffc020094c:	00feb023          	sd	a5,0(t4)
    while (block != TREE_ROOT)
ffffffffc0200950:	f8a69fe3          	bne	a3,a0,ffffffffc02008ee <buddy_free_pages+0xd0>
}
ffffffffc0200954:	60a2                	ld	ra,8(sp)
ffffffffc0200956:	6402                	ld	s0,0(sp)
ffffffffc0200958:	0141                	addi	sp,sp,16
ffffffffc020095a:	8082                	ret
        size_t right = RIGHT_CHILD(block);
ffffffffc020095c:	00178f93          	addi	t6,a5,1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0200960:	8385                	srli	a5,a5,0x1
ffffffffc0200962:	01f7e7b3          	or	a5,a5,t6
ffffffffc0200966:	0027d393          	srli	t2,a5,0x2
ffffffffc020096a:	00f3e7b3          	or	a5,t2,a5
ffffffffc020096e:	0047d393          	srli	t2,a5,0x4
ffffffffc0200972:	00f3e3b3          	or	t2,t2,a5
ffffffffc0200976:	0083d793          	srli	a5,t2,0x8
ffffffffc020097a:	0077e3b3          	or	t2,a5,t2
ffffffffc020097e:	0103d793          	srli	a5,t2,0x10
ffffffffc0200982:	0077e7b3          	or	a5,a5,t2
ffffffffc0200986:	8385                	srli	a5,a5,0x1
ffffffffc0200988:	01f7f3b3          	and	t2,a5,t6
ffffffffc020098c:	008e3403          	ld	s0,8(t3)
ffffffffc0200990:	00038663          	beqz	t2,ffffffffc020099c <buddy_free_pages+0x17e>
ffffffffc0200994:	fff7c793          	not	a5,a5
ffffffffc0200998:	00ffffb3          	and	t6,t6,a5
ffffffffc020099c:	03f85fb3          	divu	t6,a6,t6
ffffffffc02009a0:	f9f41fe3          	bne	s0,t6,ffffffffc020093e <buddy_free_pages+0x120>
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc02009a4:	02ef0733          	mul	a4,t5,a4
            record_area[block] = record_area[left] << 1;
ffffffffc02009a8:	0286                	slli	t0,t0,0x1
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc02009aa:	028383b3          	mul	t2,t2,s0
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc02009ae:	00271793          	slli	a5,a4,0x2
ffffffffc02009b2:	973e                	add	a4,a4,a5
ffffffffc02009b4:	00371793          	slli	a5,a4,0x3
ffffffffc02009b8:	97c6                	add	a5,a5,a7
    __list_del(listelm->prev, listelm->next);
ffffffffc02009ba:	7390                	ld	a2,32(a5)
ffffffffc02009bc:	0187bf83          	ld	t6,24(a5)
            list_add(&free_list, &(allocate_area[lbegin].page_link));
ffffffffc02009c0:	01878f13          	addi	t5,a5,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02009c4:	00cfb423          	sd	a2,8(t6)
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc02009c8:	00239713          	slli	a4,t2,0x2
ffffffffc02009cc:	93ba                	add	t2,t2,a4
ffffffffc02009ce:	00339713          	slli	a4,t2,0x3
    next->prev = prev;
ffffffffc02009d2:	01f63023          	sd	t6,0(a2)
ffffffffc02009d6:	9746                	add	a4,a4,a7
    __list_del(listelm->prev, listelm->next);
ffffffffc02009d8:	6f10                	ld	a2,24(a4)
ffffffffc02009da:	7318                	ld	a4,32(a4)
    prev->next = next;
ffffffffc02009dc:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02009de:	e310                	sd	a2,0(a4)
            record_area[block] = record_area[left] << 1;
ffffffffc02009e0:	005eb023          	sd	t0,0(t4)
            allocate_area[lbegin].property = record_area[left] << 1;
ffffffffc02009e4:	000e3703          	ld	a4,0(t3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02009e8:	00833603          	ld	a2,8(t1)
ffffffffc02009ec:	0017171b          	slliw	a4,a4,0x1
ffffffffc02009f0:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc02009f2:	01e63023          	sd	t5,0(a2)
ffffffffc02009f6:	01e33423          	sd	t5,8(t1)
    elm->next = next;
ffffffffc02009fa:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc02009fc:	0067bc23          	sd	t1,24(a5)
    while (block != TREE_ROOT)
ffffffffc0200a00:	eea697e3          	bne	a3,a0,ffffffffc02008ee <buddy_free_pages+0xd0>
ffffffffc0200a04:	bf81                	j	ffffffffc0200954 <buddy_free_pages+0x136>
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200a06:	fff7c793          	not	a5,a5
ffffffffc0200a0a:	8fed                	and	a5,a5,a1
ffffffffc0200a0c:	00179e13          	slli	t3,a5,0x1
ffffffffc0200a10:	b589                	j	ffffffffc0200852 <buddy_free_pages+0x34>
        assert(!PageReserved(p));
ffffffffc0200a12:	00002697          	auipc	a3,0x2
ffffffffc0200a16:	98668693          	addi	a3,a3,-1658 # ffffffffc0202398 <commands+0x528>
ffffffffc0200a1a:	00002617          	auipc	a2,0x2
ffffffffc0200a1e:	95660613          	addi	a2,a2,-1706 # ffffffffc0202370 <commands+0x500>
ffffffffc0200a22:	0c800593          	li	a1,200
ffffffffc0200a26:	00002517          	auipc	a0,0x2
ffffffffc0200a2a:	96250513          	addi	a0,a0,-1694 # ffffffffc0202388 <commands+0x518>
ffffffffc0200a2e:	97fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200a32:	00002697          	auipc	a3,0x2
ffffffffc0200a36:	93668693          	addi	a3,a3,-1738 # ffffffffc0202368 <commands+0x4f8>
ffffffffc0200a3a:	00002617          	auipc	a2,0x2
ffffffffc0200a3e:	93660613          	addi	a2,a2,-1738 # ffffffffc0202370 <commands+0x500>
ffffffffc0200a42:	0bf00593          	li	a1,191
ffffffffc0200a46:	00002517          	auipc	a0,0x2
ffffffffc0200a4a:	94250513          	addi	a0,a0,-1726 # ffffffffc0202388 <commands+0x518>
ffffffffc0200a4e:	95fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a52 <buddy_allocate_pages>:
    assert(n > 0);
ffffffffc0200a52:	1e050063          	beqz	a0,ffffffffc0200c32 <buddy_allocate_pages+0x1e0>
    size_t length = POWER_ROUND_UP(n);//需要分配的页面数量
ffffffffc0200a56:	00155793          	srli	a5,a0,0x1
ffffffffc0200a5a:	8fc9                	or	a5,a5,a0
ffffffffc0200a5c:	0027d713          	srli	a4,a5,0x2
ffffffffc0200a60:	8fd9                	or	a5,a5,a4
ffffffffc0200a62:	0047d713          	srli	a4,a5,0x4
ffffffffc0200a66:	8f5d                	or	a4,a4,a5
ffffffffc0200a68:	00875793          	srli	a5,a4,0x8
ffffffffc0200a6c:	8f5d                	or	a4,a4,a5
ffffffffc0200a6e:	01075793          	srli	a5,a4,0x10
ffffffffc0200a72:	8fd9                	or	a5,a5,a4
ffffffffc0200a74:	8385                	srli	a5,a5,0x1
ffffffffc0200a76:	00a7f733          	and	a4,a5,a0
ffffffffc0200a7a:	18071963          	bnez	a4,ffffffffc0200c0c <buddy_allocate_pages+0x1ba>
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200a7e:	00006897          	auipc	a7,0x6
ffffffffc0200a82:	9da8b883          	ld	a7,-1574(a7) # ffffffffc0206458 <record_area>
ffffffffc0200a86:	0088b783          	ld	a5,8(a7)
ffffffffc0200a8a:	00888f93          	addi	t6,a7,8
ffffffffc0200a8e:	16a7e763          	bltu	a5,a0,ffffffffc0200bfc <buddy_allocate_pages+0x1aa>
ffffffffc0200a92:	00006e97          	auipc	t4,0x6
ffffffffc0200a96:	9aeebe83          	ld	t4,-1618(t4) # ffffffffc0206440 <full_tree_size>
    size_t block = TREE_ROOT;
ffffffffc0200a9a:	4585                	li	a1,1
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200a9c:	02bed5b3          	divu	a1,t4,a1
            list_del(&(allocate_area[begin].page_link));
ffffffffc0200aa0:	00006317          	auipc	t1,0x6
ffffffffc0200aa4:	99833303          	ld	t1,-1640(t1) # ffffffffc0206438 <allocate_area>
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200aa8:	4801                	li	a6,0
ffffffffc0200aaa:	4601                	li	a2,0
    size_t block = TREE_ROOT;
ffffffffc0200aac:	4685                	li	a3,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200aae:	00005f17          	auipc	t5,0x5
ffffffffc0200ab2:	562f0f13          	addi	t5,t5,1378 # ffffffffc0206010 <free_area>
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200ab6:	06b57e63          	bgeu	a0,a1,ffffffffc0200b32 <buddy_allocate_pages+0xe0>
        size_t left = LEFT_CHILD(block);
ffffffffc0200aba:	00169713          	slli	a4,a3,0x1
            record_area[left] = record_area[block] >> 1;
ffffffffc0200abe:	00469613          	slli	a2,a3,0x4
        size_t right = RIGHT_CHILD(block);
ffffffffc0200ac2:	00170293          	addi	t0,a4,1
            record_area[left] = record_area[block] >> 1;
ffffffffc0200ac6:	00c88e33          	add	t3,a7,a2
        if (BUDDY_EMPTY(block))//该块是空闲的，将其分裂成两个子块
ffffffffc0200aca:	0af58f63          	beq	a1,a5,ffffffffc0200b88 <buddy_allocate_pages+0x136>
        else if (length & record_area[left])//因为都是2的幂，结果非0表示大小满足
ffffffffc0200ace:	000e3783          	ld	a5,0(t3)
ffffffffc0200ad2:	00a7f5b3          	and	a1,a5,a0
ffffffffc0200ad6:	12059163          	bnez	a1,ffffffffc0200bf8 <buddy_allocate_pages+0x1a6>
        else if (length & record_area[right])
ffffffffc0200ada:	0621                	addi	a2,a2,8
ffffffffc0200adc:	9646                	add	a2,a2,a7
ffffffffc0200ade:	620c                	ld	a1,0(a2)
ffffffffc0200ae0:	00a5f833          	and	a6,a1,a0
ffffffffc0200ae4:	10081e63          	bnez	a6,ffffffffc0200c00 <buddy_allocate_pages+0x1ae>
        else if (length <= record_area[left])
ffffffffc0200ae8:	00a7f763          	bgeu	a5,a0,ffffffffc0200af6 <buddy_allocate_pages+0xa4>
        else if (length <= record_area[right])
ffffffffc0200aec:	12a5e963          	bltu	a1,a0,ffffffffc0200c1e <buddy_allocate_pages+0x1cc>
ffffffffc0200af0:	87ae                	mv	a5,a1
ffffffffc0200af2:	8e32                	mv	t3,a2
            block = right;
ffffffffc0200af4:	8716                	mv	a4,t0
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200af6:	00175613          	srli	a2,a4,0x1
ffffffffc0200afa:	8e59                	or	a2,a2,a4
ffffffffc0200afc:	00265693          	srli	a3,a2,0x2
ffffffffc0200b00:	8e55                	or	a2,a2,a3
ffffffffc0200b02:	00465693          	srli	a3,a2,0x4
ffffffffc0200b06:	8ed1                	or	a3,a3,a2
ffffffffc0200b08:	0086d613          	srli	a2,a3,0x8
ffffffffc0200b0c:	8ed1                	or	a3,a3,a2
ffffffffc0200b0e:	0106d613          	srli	a2,a3,0x10
ffffffffc0200b12:	8e55                	or	a2,a2,a3
ffffffffc0200b14:	8205                	srli	a2,a2,0x1
ffffffffc0200b16:	00e67833          	and	a6,a2,a4
ffffffffc0200b1a:	85ba                	mv	a1,a4
ffffffffc0200b1c:	00080563          	beqz	a6,ffffffffc0200b26 <buddy_allocate_pages+0xd4>
ffffffffc0200b20:	fff64593          	not	a1,a2
ffffffffc0200b24:	8df9                	and	a1,a1,a4
ffffffffc0200b26:	02bed5b3          	divu	a1,t4,a1
ffffffffc0200b2a:	8ff2                	mv	t6,t3
ffffffffc0200b2c:	86ba                	mv	a3,a4
ffffffffc0200b2e:	f8b566e3          	bltu	a0,a1,ffffffffc0200aba <buddy_allocate_pages+0x68>
    page = &(allocate_area[NODE_BEGINNING(block)]);
ffffffffc0200b32:	0e081263          	bnez	a6,ffffffffc0200c16 <buddy_allocate_pages+0x1c4>
ffffffffc0200b36:	8636                	mv	a2,a3
ffffffffc0200b38:	02ced633          	divu	a2,t4,a2
    nr_free -= length; 
ffffffffc0200b3c:	00005597          	auipc	a1,0x5
ffffffffc0200b40:	4d458593          	addi	a1,a1,1236 # ffffffffc0206010 <free_area>
ffffffffc0200b44:	4998                	lw	a4,16(a1)
    while (block != TREE_ROOT)
ffffffffc0200b46:	4e05                	li	t3,1
    nr_free -= length; 
ffffffffc0200b48:	9f09                	subw	a4,a4,a0
    page = &(allocate_area[NODE_BEGINNING(block)]);
ffffffffc0200b4a:	030607b3          	mul	a5,a2,a6
ffffffffc0200b4e:	00279513          	slli	a0,a5,0x2
ffffffffc0200b52:	953e                	add	a0,a0,a5
ffffffffc0200b54:	050e                	slli	a0,a0,0x3
ffffffffc0200b56:	951a                	add	a0,a0,t1
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b58:	6d10                	ld	a2,24(a0)
ffffffffc0200b5a:	711c                	ld	a5,32(a0)
    prev->next = next;
ffffffffc0200b5c:	e61c                	sd	a5,8(a2)
    next->prev = prev;
ffffffffc0200b5e:	e390                	sd	a2,0(a5)
    record_area[block] = 0;
ffffffffc0200b60:	000fb023          	sd	zero,0(t6)
    nr_free -= length; 
ffffffffc0200b64:	c998                	sw	a4,16(a1)
    while (block != TREE_ROOT)
ffffffffc0200b66:	0dc68563          	beq	a3,t3,ffffffffc0200c30 <buddy_allocate_pages+0x1de>
ffffffffc0200b6a:	4585                	li	a1,1
        block = PARENT(block);
ffffffffc0200b6c:	8285                	srli	a3,a3,0x1
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc0200b6e:	00469793          	slli	a5,a3,0x4
ffffffffc0200b72:	97c6                	add	a5,a5,a7
ffffffffc0200b74:	6390                	ld	a2,0(a5)
ffffffffc0200b76:	6798                	ld	a4,8(a5)
ffffffffc0200b78:	00369793          	slli	a5,a3,0x3
ffffffffc0200b7c:	97c6                	add	a5,a5,a7
ffffffffc0200b7e:	8f51                	or	a4,a4,a2
ffffffffc0200b80:	e398                	sd	a4,0(a5)
    while (block != TREE_ROOT)
ffffffffc0200b82:	feb695e3          	bne	a3,a1,ffffffffc0200b6c <buddy_allocate_pages+0x11a>
ffffffffc0200b86:	8082                	ret
            size_t begin = NODE_BEGINNING(block);
ffffffffc0200b88:	03078833          	mul	a6,a5,a6
            record_area[left] = record_area[block] >> 1;
ffffffffc0200b8c:	0017d393          	srli	t2,a5,0x1
            list_del(&(allocate_area[begin].page_link));
ffffffffc0200b90:	00281693          	slli	a3,a6,0x2
ffffffffc0200b94:	96c2                	add	a3,a3,a6
ffffffffc0200b96:	068e                	slli	a3,a3,0x3
ffffffffc0200b98:	969a                	add	a3,a3,t1
            size_t end = NODE_ENDDING(block);
ffffffffc0200b9a:	97c2                	add	a5,a5,a6
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b9c:	728c                	ld	a1,32(a3)
ffffffffc0200b9e:	0186b283          	ld	t0,24(a3)
            size_t mid = (begin + end) >> 1;
ffffffffc0200ba2:	983e                	add	a6,a6,a5
ffffffffc0200ba4:	00185813          	srli	a6,a6,0x1
            allocate_area[begin].property >>= 1;
ffffffffc0200ba8:	4a9c                	lw	a5,16(a3)
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200baa:	00281613          	slli	a2,a6,0x2
    prev->next = next;
ffffffffc0200bae:	00b2b423          	sd	a1,8(t0)
ffffffffc0200bb2:	9642                	add	a2,a2,a6
    next->prev = prev;
ffffffffc0200bb4:	0055b023          	sd	t0,0(a1)
            allocate_area[begin].property >>= 1;
ffffffffc0200bb8:	0017d79b          	srliw	a5,a5,0x1
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200bbc:	060e                	slli	a2,a2,0x3
            allocate_area[begin].property >>= 1;
ffffffffc0200bbe:	ca9c                	sw	a5,16(a3)
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200bc0:	961a                	add	a2,a2,t1
ffffffffc0200bc2:	ca1c                	sw	a5,16(a2)
            record_area[left] = record_area[block] >> 1;
ffffffffc0200bc4:	007e3023          	sd	t2,0(t3)
            record_area[right] = record_area[block] >> 1;
ffffffffc0200bc8:	000fb783          	ld	a5,0(t6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bcc:	008f3f83          	ld	t6,8(t5)
            list_add(&free_list, &(allocate_area[begin].page_link));
ffffffffc0200bd0:	01868593          	addi	a1,a3,24
            record_area[right] = record_area[block] >> 1;
ffffffffc0200bd4:	8385                	srli	a5,a5,0x1
ffffffffc0200bd6:	00fe3423          	sd	a5,8(t3)
    prev->next = next->prev = elm;
ffffffffc0200bda:	00bfb023          	sd	a1,0(t6)
            list_add(&free_list, &(allocate_area[mid].page_link));
ffffffffc0200bde:	01860813          	addi	a6,a2,24
    elm->next = next;
ffffffffc0200be2:	03f6b023          	sd	t6,32(a3)
    prev->next = next->prev = elm;
ffffffffc0200be6:	0106bc23          	sd	a6,24(a3)
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200bea:	000e3783          	ld	a5,0(t3)
ffffffffc0200bee:	010f3423          	sd	a6,8(t5)
    elm->next = next;
ffffffffc0200bf2:	f20c                	sd	a1,32(a2)
    elm->prev = prev;
ffffffffc0200bf4:	01e63c23          	sd	t5,24(a2)
ffffffffc0200bf8:	eea7ffe3          	bgeu	a5,a0,ffffffffc0200af6 <buddy_allocate_pages+0xa4>
        return NULL;
ffffffffc0200bfc:	4501                	li	a0,0
ffffffffc0200bfe:	8082                	ret
ffffffffc0200c00:	87ae                	mv	a5,a1
ffffffffc0200c02:	8e32                	mv	t3,a2
            block = right;
ffffffffc0200c04:	8716                	mv	a4,t0
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200c06:	eea7f8e3          	bgeu	a5,a0,ffffffffc0200af6 <buddy_allocate_pages+0xa4>
ffffffffc0200c0a:	bfcd                	j	ffffffffc0200bfc <buddy_allocate_pages+0x1aa>
    size_t length = POWER_ROUND_UP(n);//需要分配的页面数量
ffffffffc0200c0c:	fff7c793          	not	a5,a5
ffffffffc0200c10:	8d7d                	and	a0,a0,a5
ffffffffc0200c12:	0506                	slli	a0,a0,0x1
ffffffffc0200c14:	b5ad                	j	ffffffffc0200a7e <buddy_allocate_pages+0x2c>
    page = &(allocate_area[NODE_BEGINNING(block)]);
ffffffffc0200c16:	fff64613          	not	a2,a2
ffffffffc0200c1a:	8e75                	and	a2,a2,a3
ffffffffc0200c1c:	bf31                	j	ffffffffc0200b38 <buddy_allocate_pages+0xe6>
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200c1e:	00369e13          	slli	t3,a3,0x3
ffffffffc0200c22:	9e46                	add	t3,t3,a7
ffffffffc0200c24:	000e3783          	ld	a5,0(t3)
ffffffffc0200c28:	8736                	mv	a4,a3
ffffffffc0200c2a:	eca7f6e3          	bgeu	a5,a0,ffffffffc0200af6 <buddy_allocate_pages+0xa4>
ffffffffc0200c2e:	b7f9                	j	ffffffffc0200bfc <buddy_allocate_pages+0x1aa>
}
ffffffffc0200c30:	8082                	ret
{
ffffffffc0200c32:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	73468693          	addi	a3,a3,1844 # ffffffffc0202368 <commands+0x4f8>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	73460613          	addi	a2,a2,1844 # ffffffffc0202370 <commands+0x500>
ffffffffc0200c44:	08900593          	li	a1,137
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	74050513          	addi	a0,a0,1856 # ffffffffc0202388 <commands+0x518>
{
ffffffffc0200c50:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c52:	f5aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c56 <buddy_init_memmap.part.0>:
    for (p = base; p < base + n; p++)
ffffffffc0200c56:	00259793          	slli	a5,a1,0x2
ffffffffc0200c5a:	97ae                	add	a5,a5,a1
buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200c5c:	7179                	addi	sp,sp,-48
    for (p = base; p < base + n; p++)
ffffffffc0200c5e:	078e                	slli	a5,a5,0x3
ffffffffc0200c60:	00f506b3          	add	a3,a0,a5
buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200c64:	f406                	sd	ra,40(sp)
ffffffffc0200c66:	f022                	sd	s0,32(sp)
ffffffffc0200c68:	ec26                	sd	s1,24(sp)
ffffffffc0200c6a:	e84a                	sd	s2,16(sp)
ffffffffc0200c6c:	e44e                	sd	s3,8(sp)
ffffffffc0200c6e:	882a                	mv	a6,a0
    for (p = base; p < base + n; p++)
ffffffffc0200c70:	87aa                	mv	a5,a0
ffffffffc0200c72:	00d57e63          	bgeu	a0,a3,ffffffffc0200c8e <buddy_init_memmap.part.0+0x38>
ffffffffc0200c76:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200c78:	8b05                	andi	a4,a4,1
ffffffffc0200c7a:	2c070463          	beqz	a4,ffffffffc0200f42 <buddy_init_memmap.part.0+0x2ec>
        p->flags = p->property = 0;
ffffffffc0200c7e:	0007a823          	sw	zero,16(a5)
ffffffffc0200c82:	0007b423          	sd	zero,8(a5)
    for (p = base; p < base + n; p++)
ffffffffc0200c86:	02878793          	addi	a5,a5,40
ffffffffc0200c8a:	fed7e6e3          	bltu	a5,a3,ffffffffc0200c76 <buddy_init_memmap.part.0+0x20>
    total_size = n;
ffffffffc0200c8e:	00005797          	auipc	a5,0x5
ffffffffc0200c92:	7cb7bd23          	sd	a1,2010(a5) # ffffffffc0206468 <total_size>
    if (n < 512)
ffffffffc0200c96:	1ff00793          	li	a5,511
ffffffffc0200c9a:	06b7f363          	bgeu	a5,a1,ffffffffc0200d00 <buddy_init_memmap.part.0+0xaa>
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200c9e:	0015d793          	srli	a5,a1,0x1
ffffffffc0200ca2:	8fcd                	or	a5,a5,a1
ffffffffc0200ca4:	0027d713          	srli	a4,a5,0x2
ffffffffc0200ca8:	8fd9                	or	a5,a5,a4
ffffffffc0200caa:	0047d713          	srli	a4,a5,0x4
ffffffffc0200cae:	8f5d                	or	a4,a4,a5
ffffffffc0200cb0:	00875793          	srli	a5,a4,0x8
ffffffffc0200cb4:	8f5d                	or	a4,a4,a5
ffffffffc0200cb6:	01075793          	srli	a5,a4,0x10
ffffffffc0200cba:	8fd9                	or	a5,a5,a4
ffffffffc0200cbc:	8385                	srli	a5,a5,0x1
ffffffffc0200cbe:	00f5f6b3          	and	a3,a1,a5
ffffffffc0200cc2:	872e                	mv	a4,a1
ffffffffc0200cc4:	c689                	beqz	a3,ffffffffc0200cce <buddy_init_memmap.part.0+0x78>
ffffffffc0200cc6:	fff7c793          	not	a5,a5
ffffffffc0200cca:	00b7f733          	and	a4,a5,a1
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200cce:	00471693          	slli	a3,a4,0x4
ffffffffc0200cd2:	82b1                	srli	a3,a3,0xc
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200cd4:	00005497          	auipc	s1,0x5
ffffffffc0200cd8:	76c48493          	addi	s1,s1,1900 # ffffffffc0206440 <full_tree_size>
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200cdc:	00005797          	auipc	a5,0x5
ffffffffc0200ce0:	78478793          	addi	a5,a5,1924 # ffffffffc0206460 <record_area_size>
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0200ce4:	00169613          	slli	a2,a3,0x1
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200ce8:	e098                	sd	a4,0(s1)
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200cea:	e394                	sd	a3,0(a5)
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0200cec:	00c70533          	add	a0,a4,a2
ffffffffc0200cf0:	22b56863          	bltu	a0,a1,ffffffffc0200f20 <buddy_init_memmap.part.0+0x2ca>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200cf4:	40d587b3          	sub	a5,a1,a3
ffffffffc0200cf8:	22f76f63          	bltu	a4,a5,ffffffffc0200f36 <buddy_init_memmap.part.0+0x2e0>
ffffffffc0200cfc:	8636                	mv	a2,a3
ffffffffc0200cfe:	a0b1                	j	ffffffffc0200d4a <buddy_init_memmap.part.0+0xf4>
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0200d00:	15fd                	addi	a1,a1,-1
ffffffffc0200d02:	0015d793          	srli	a5,a1,0x1
ffffffffc0200d06:	00b7e733          	or	a4,a5,a1
ffffffffc0200d0a:	00275793          	srli	a5,a4,0x2
ffffffffc0200d0e:	8fd9                	or	a5,a5,a4
ffffffffc0200d10:	0047d713          	srli	a4,a5,0x4
ffffffffc0200d14:	8fd9                	or	a5,a5,a4
ffffffffc0200d16:	0087d713          	srli	a4,a5,0x8
ffffffffc0200d1a:	8f5d                	or	a4,a4,a5
ffffffffc0200d1c:	8305                	srli	a4,a4,0x1
ffffffffc0200d1e:	00e5f6b3          	and	a3,a1,a4
ffffffffc0200d22:	87ae                	mv	a5,a1
ffffffffc0200d24:	ca81                	beqz	a3,ffffffffc0200d34 <buddy_init_memmap.part.0+0xde>
ffffffffc0200d26:	fff74713          	not	a4,a4
ffffffffc0200d2a:	8f6d                	and	a4,a4,a1
ffffffffc0200d2c:	00171593          	slli	a1,a4,0x1
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200d30:	20f5e163          	bltu	a1,a5,ffffffffc0200f32 <buddy_init_memmap.part.0+0x2dc>
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0200d34:	00005497          	auipc	s1,0x5
ffffffffc0200d38:	70c48493          	addi	s1,s1,1804 # ffffffffc0206440 <full_tree_size>
        record_area_size = 1;
ffffffffc0200d3c:	4705                	li	a4,1
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0200d3e:	e08c                	sd	a1,0(s1)
        record_area_size = 1;
ffffffffc0200d40:	00005697          	auipc	a3,0x5
ffffffffc0200d44:	72e6b023          	sd	a4,1824(a3) # ffffffffc0206460 <record_area_size>
ffffffffc0200d48:	4605                	li	a2,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d4a:	00005697          	auipc	a3,0x5
ffffffffc0200d4e:	72e6b683          	ld	a3,1838(a3) # ffffffffc0206478 <pages>
ffffffffc0200d52:	40d806b3          	sub	a3,a6,a3
ffffffffc0200d56:	00002717          	auipc	a4,0x2
ffffffffc0200d5a:	c9273703          	ld	a4,-878(a4) # ffffffffc02029e8 <error_string+0x38>
ffffffffc0200d5e:	868d                	srai	a3,a3,0x3
ffffffffc0200d60:	02e686b3          	mul	a3,a3,a4
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200d64:	00005997          	auipc	s3,0x5
ffffffffc0200d68:	6ec98993          	addi	s3,s3,1772 # ffffffffc0206450 <real_tree_size>
ffffffffc0200d6c:	00002517          	auipc	a0,0x2
ffffffffc0200d70:	c8453503          	ld	a0,-892(a0) # ffffffffc02029f0 <nbase>
ffffffffc0200d74:	00f9b023          	sd	a5,0(s3)
    physical_area = base;
ffffffffc0200d78:	00005797          	auipc	a5,0x5
ffffffffc0200d7c:	6d07b823          	sd	a6,1744(a5) # ffffffffc0206448 <physical_area>
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
ffffffffc0200d80:	00005717          	auipc	a4,0x5
ffffffffc0200d84:	6f073703          	ld	a4,1776(a4) # ffffffffc0206470 <npage>
ffffffffc0200d88:	96aa                	add	a3,a3,a0
ffffffffc0200d8a:	00c69793          	slli	a5,a3,0xc
ffffffffc0200d8e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d90:	06b2                	slli	a3,a3,0xc
ffffffffc0200d92:	1ce7f863          	bgeu	a5,a4,ffffffffc0200f62 <buddy_init_memmap.part.0+0x30c>
    allocate_area = base + record_area_size;
ffffffffc0200d96:	00261793          	slli	a5,a2,0x2
ffffffffc0200d9a:	97b2                	add	a5,a5,a2
ffffffffc0200d9c:	078e                	slli	a5,a5,0x3
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
ffffffffc0200d9e:	00005517          	auipc	a0,0x5
ffffffffc0200da2:	6fa53503          	ld	a0,1786(a0) # ffffffffc0206498 <va_pa_offset>
ffffffffc0200da6:	9536                	add	a0,a0,a3
    allocate_area = base + record_area_size;
ffffffffc0200da8:	983e                	add	a6,a6,a5
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
ffffffffc0200daa:	00005417          	auipc	s0,0x5
ffffffffc0200dae:	6ae40413          	addi	s0,s0,1710 # ffffffffc0206458 <record_area>
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0200db2:	0632                	slli	a2,a2,0xc
ffffffffc0200db4:	4581                	li	a1,0
    allocate_area = base + record_area_size;
ffffffffc0200db6:	00005917          	auipc	s2,0x5
ffffffffc0200dba:	68290913          	addi	s2,s2,1666 # ffffffffc0206438 <allocate_area>
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
ffffffffc0200dbe:	e008                	sd	a0,0(s0)
    allocate_area = base + record_area_size;
ffffffffc0200dc0:	01093023          	sd	a6,0(s2)
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0200dc4:	641000ef          	jal	ra,ffffffffc0201c04 <memset>
    nr_free += real_tree_size;//全局空闲页面
ffffffffc0200dc8:	00005897          	auipc	a7,0x5
ffffffffc0200dcc:	24888893          	addi	a7,a7,584 # ffffffffc0206010 <free_area>
ffffffffc0200dd0:	0009b683          	ld	a3,0(s3)
ffffffffc0200dd4:	0108a783          	lw	a5,16(a7)
    record_area[block] = real_subtree_size;//length[index]=真实大小
ffffffffc0200dd8:	6010                	ld	a2,0(s0)
    size_t full_subtree_size = full_tree_size;//size,
ffffffffc0200dda:	6098                	ld	a4,0(s1)
    nr_free += real_tree_size;//全局空闲页面
ffffffffc0200ddc:	9fb5                	addw	a5,a5,a3
ffffffffc0200dde:	00f8a823          	sw	a5,16(a7)
    record_area[block] = real_subtree_size;//length[index]=真实大小
ffffffffc0200de2:	e614                	sd	a3,8(a2)
    nr_free += real_tree_size;//全局空闲页面
ffffffffc0200de4:	0006859b          	sext.w	a1,a3
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200de8:	10068a63          	beqz	a3,ffffffffc0200efc <buddy_init_memmap.part.0+0x2a6>
ffffffffc0200dec:	14e6f863          	bgeu	a3,a4,ffffffffc0200f3c <buddy_init_memmap.part.0+0x2e6>
    size_t block = TREE_ROOT;//当前节点
ffffffffc0200df0:	4785                	li	a5,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200df2:	4309                	li	t1,2
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0200df4:	00479613          	slli	a2,a5,0x4
        full_subtree_size >>= 1;
ffffffffc0200df8:	8305                	srli	a4,a4,0x1
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
ffffffffc0200dfa:	00860e93          	addi	t4,a2,8
            block = RIGHT_CHILD(block);
ffffffffc0200dfe:	00179e13          	slli	t3,a5,0x1
        if (real_subtree_size > full_subtree_size)
ffffffffc0200e02:	10d77463          	bgeu	a4,a3,ffffffffc0200f0a <buddy_init_memmap.part.0+0x2b4>
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200e06:	0017d513          	srli	a0,a5,0x1
ffffffffc0200e0a:	8d5d                	or	a0,a0,a5
ffffffffc0200e0c:	00255813          	srli	a6,a0,0x2
ffffffffc0200e10:	00a86533          	or	a0,a6,a0
ffffffffc0200e14:	00455813          	srli	a6,a0,0x4
ffffffffc0200e18:	00a86833          	or	a6,a6,a0
ffffffffc0200e1c:	00885513          	srli	a0,a6,0x8
ffffffffc0200e20:	01056833          	or	a6,a0,a6
ffffffffc0200e24:	01085513          	srli	a0,a6,0x10
ffffffffc0200e28:	01056533          	or	a0,a0,a6
ffffffffc0200e2c:	8105                	srli	a0,a0,0x1
ffffffffc0200e2e:	00f57f33          	and	t5,a0,a5
ffffffffc0200e32:	00093583          	ld	a1,0(s2)
ffffffffc0200e36:	0004b803          	ld	a6,0(s1)
ffffffffc0200e3a:	000f0563          	beqz	t5,ffffffffc0200e44 <buddy_init_memmap.part.0+0x1ee>
ffffffffc0200e3e:	fff54513          	not	a0,a0
ffffffffc0200e42:	8fe9                	and	a5,a5,a0
ffffffffc0200e44:	02f857b3          	divu	a5,a6,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e48:	0088b803          	ld	a6,8(a7)
ffffffffc0200e4c:	03e787b3          	mul	a5,a5,t5
ffffffffc0200e50:	00279513          	slli	a0,a5,0x2
ffffffffc0200e54:	97aa                	add	a5,a5,a0
ffffffffc0200e56:	078e                	slli	a5,a5,0x3
ffffffffc0200e58:	97ae                	add	a5,a5,a1
            list_add(&(free_list), &(page->page_link));
ffffffffc0200e5a:	01878593          	addi	a1,a5,24
            page->property = full_subtree_size;
ffffffffc0200e5e:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200e60:	00b83023          	sd	a1,0(a6)
ffffffffc0200e64:	00b8b423          	sd	a1,8(a7)
    elm->next = next;
ffffffffc0200e68:	0307b023          	sd	a6,32(a5)
    elm->prev = prev;
ffffffffc0200e6c:	0117bc23          	sd	a7,24(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200e70:	0007a023          	sw	zero,0(a5)
ffffffffc0200e74:	07a1                	addi	a5,a5,8
ffffffffc0200e76:	4067b02f          	amoor.d	zero,t1,(a5)
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0200e7a:	600c                	ld	a1,0(s0)
            real_subtree_size -= full_subtree_size;
ffffffffc0200e7c:	8e99                	sub	a3,a3,a4
            block = RIGHT_CHILD(block);
ffffffffc0200e7e:	001e0793          	addi	a5,t3,1
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0200e82:	962e                	add	a2,a2,a1
ffffffffc0200e84:	e218                	sd	a4,0(a2)
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
ffffffffc0200e86:	95f6                	add	a1,a1,t4
ffffffffc0200e88:	e194                	sd	a3,0(a1)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200e8a:	f6e6e5e3          	bltu	a3,a4,ffffffffc0200df4 <buddy_init_memmap.part.0+0x19e>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200e8e:	0017d613          	srli	a2,a5,0x1
ffffffffc0200e92:	8e5d                	or	a2,a2,a5
ffffffffc0200e94:	00265713          	srli	a4,a2,0x2
ffffffffc0200e98:	8e59                	or	a2,a2,a4
ffffffffc0200e9a:	00465713          	srli	a4,a2,0x4
ffffffffc0200e9e:	8f51                	or	a4,a4,a2
ffffffffc0200ea0:	00875613          	srli	a2,a4,0x8
ffffffffc0200ea4:	8f51                	or	a4,a4,a2
ffffffffc0200ea6:	01075613          	srli	a2,a4,0x10
ffffffffc0200eaa:	8e59                	or	a2,a2,a4
ffffffffc0200eac:	8205                	srli	a2,a2,0x1
ffffffffc0200eae:	00c7f833          	and	a6,a5,a2
ffffffffc0200eb2:	00093703          	ld	a4,0(s2)
ffffffffc0200eb6:	6088                	ld	a0,0(s1)
        page->property = real_subtree_size;
ffffffffc0200eb8:	0006859b          	sext.w	a1,a3
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200ebc:	00080e63          	beqz	a6,ffffffffc0200ed8 <buddy_init_memmap.part.0+0x282>
ffffffffc0200ec0:	fff64613          	not	a2,a2
ffffffffc0200ec4:	8ff1                	and	a5,a5,a2
ffffffffc0200ec6:	02f557b3          	divu	a5,a0,a5
ffffffffc0200eca:	030787b3          	mul	a5,a5,a6
ffffffffc0200ece:	00279693          	slli	a3,a5,0x2
ffffffffc0200ed2:	97b6                	add	a5,a5,a3
ffffffffc0200ed4:	078e                	slli	a5,a5,0x3
ffffffffc0200ed6:	973e                	add	a4,a4,a5
        page->property = real_subtree_size;
ffffffffc0200ed8:	cb0c                	sw	a1,16(a4)
ffffffffc0200eda:	00072023          	sw	zero,0(a4)
ffffffffc0200ede:	4789                	li	a5,2
ffffffffc0200ee0:	00870693          	addi	a3,a4,8
ffffffffc0200ee4:	40f6b02f          	amoor.d	zero,a5,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ee8:	0088b783          	ld	a5,8(a7)
        list_add(&(free_list), &(page->page_link));
ffffffffc0200eec:	01870693          	addi	a3,a4,24
    prev->next = next->prev = elm;
ffffffffc0200ef0:	e394                	sd	a3,0(a5)
ffffffffc0200ef2:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0200ef6:	f31c                	sd	a5,32(a4)
    elm->prev = prev;
ffffffffc0200ef8:	01173c23          	sd	a7,24(a4)
}
ffffffffc0200efc:	70a2                	ld	ra,40(sp)
ffffffffc0200efe:	7402                	ld	s0,32(sp)
ffffffffc0200f00:	64e2                	ld	s1,24(sp)
ffffffffc0200f02:	6942                	ld	s2,16(sp)
ffffffffc0200f04:	69a2                	ld	s3,8(sp)
ffffffffc0200f06:	6145                	addi	sp,sp,48
ffffffffc0200f08:	8082                	ret
            record_area[LEFT_CHILD(block)] = real_subtree_size;
ffffffffc0200f0a:	601c                	ld	a5,0(s0)
ffffffffc0200f0c:	963e                	add	a2,a2,a5
ffffffffc0200f0e:	e214                	sd	a3,0(a2)
            record_area[RIGHT_CHILD(block)] = 0;
ffffffffc0200f10:	97f6                	add	a5,a5,t4
ffffffffc0200f12:	0007b023          	sd	zero,0(a5)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200f16:	d2fd                	beqz	a3,ffffffffc0200efc <buddy_init_memmap.part.0+0x2a6>
            block = LEFT_CHILD(block);
ffffffffc0200f18:	87f2                	mv	a5,t3
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200f1a:	ece6ede3          	bltu	a3,a4,ffffffffc0200df4 <buddy_init_memmap.part.0+0x19e>
ffffffffc0200f1e:	bf85                	j	ffffffffc0200e8e <buddy_init_memmap.part.0+0x238>
            full_tree_size <<= 1;
ffffffffc0200f20:	0706                	slli	a4,a4,0x1
            record_area_size <<= 1;
ffffffffc0200f22:	e390                	sd	a2,0(a5)
            full_tree_size <<= 1;
ffffffffc0200f24:	e098                	sd	a4,0(s1)
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200f26:	40c587b3          	sub	a5,a1,a2
ffffffffc0200f2a:	e2f770e3          	bgeu	a4,a5,ffffffffc0200d4a <buddy_init_memmap.part.0+0xf4>
ffffffffc0200f2e:	87ba                	mv	a5,a4
ffffffffc0200f30:	bd29                	j	ffffffffc0200d4a <buddy_init_memmap.part.0+0xf4>
ffffffffc0200f32:	87ae                	mv	a5,a1
ffffffffc0200f34:	b501                	j	ffffffffc0200d34 <buddy_init_memmap.part.0+0xde>
ffffffffc0200f36:	87ba                	mv	a5,a4
ffffffffc0200f38:	8636                	mv	a2,a3
ffffffffc0200f3a:	bd01                	j	ffffffffc0200d4a <buddy_init_memmap.part.0+0xf4>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200f3c:	00093703          	ld	a4,0(s2)
ffffffffc0200f40:	bf61                	j	ffffffffc0200ed8 <buddy_init_memmap.part.0+0x282>
        assert(PageReserved(p));
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	46e68693          	addi	a3,a3,1134 # ffffffffc02023b0 <commands+0x540>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	42660613          	addi	a2,a2,1062 # ffffffffc0202370 <commands+0x500>
ffffffffc0200f52:	04200593          	li	a1,66
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	43250513          	addi	a0,a0,1074 # ffffffffc0202388 <commands+0x518>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	45e60613          	addi	a2,a2,1118 # ffffffffc02023c0 <commands+0x550>
ffffffffc0200f6a:	05a00593          	li	a1,90
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	41a50513          	addi	a0,a0,1050 # ffffffffc0202388 <commands+0x518>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f7a <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0200f7a:	c191                	beqz	a1,ffffffffc0200f7e <buddy_init_memmap+0x4>
ffffffffc0200f7c:	b9e9                	j	ffffffffc0200c56 <buddy_init_memmap.part.0>
buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200f7e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200f80:	00001697          	auipc	a3,0x1
ffffffffc0200f84:	3e868693          	addi	a3,a3,1000 # ffffffffc0202368 <commands+0x4f8>
ffffffffc0200f88:	00001617          	auipc	a2,0x1
ffffffffc0200f8c:	3e860613          	addi	a2,a2,1000 # ffffffffc0202370 <commands+0x500>
ffffffffc0200f90:	03e00593          	li	a1,62
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	3f450513          	addi	a0,a0,1012 # ffffffffc0202388 <commands+0x518>
buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200f9c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f9e:	c0eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fa2 <alloc_check>:

//验证buddy system内存管理的分配和释放操作是否正确
static void 
alloc_check(void){
ffffffffc0200fa2:	715d                	addi	sp,sp,-80
ffffffffc0200fa4:	f84a                	sd	s2,48(sp)
    size_t total_size_store = total_size;
    struct Page *p;
    for (p = physical_area; p < physical_area + 1026; p++)
ffffffffc0200fa6:	00005917          	auipc	s2,0x5
ffffffffc0200faa:	4a290913          	addi	s2,s2,1186 # ffffffffc0206448 <physical_area>
ffffffffc0200fae:	00093783          	ld	a5,0(s2)
ffffffffc0200fb2:	66a9                	lui	a3,0xa
alloc_check(void){
ffffffffc0200fb4:	f44e                	sd	s3,40(sp)
ffffffffc0200fb6:	e486                	sd	ra,72(sp)
ffffffffc0200fb8:	e0a2                	sd	s0,64(sp)
ffffffffc0200fba:	fc26                	sd	s1,56(sp)
ffffffffc0200fbc:	f052                	sd	s4,32(sp)
ffffffffc0200fbe:	ec56                	sd	s5,24(sp)
ffffffffc0200fc0:	e85a                	sd	s6,16(sp)
ffffffffc0200fc2:	e45e                	sd	s7,8(sp)
    size_t total_size_store = total_size;
ffffffffc0200fc4:	00005997          	auipc	s3,0x5
ffffffffc0200fc8:	4a49b983          	ld	s3,1188(s3) # ffffffffc0206468 <total_size>
ffffffffc0200fcc:	4605                	li	a2,1
    for (p = physical_area; p < physical_area + 1026; p++)
ffffffffc0200fce:	05068693          	addi	a3,a3,80 # a050 <kern_entry-0xffffffffc01f5fb0>
ffffffffc0200fd2:	00878713          	addi	a4,a5,8
ffffffffc0200fd6:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc0200fda:	00093503          	ld	a0,0(s2)
ffffffffc0200fde:	02878793          	addi	a5,a5,40
ffffffffc0200fe2:	00d50733          	add	a4,a0,a3
ffffffffc0200fe6:	fee7e6e3          	bltu	a5,a4,ffffffffc0200fd2 <alloc_check+0x30>
    elm->prev = elm->next = elm;
ffffffffc0200fea:	00005497          	auipc	s1,0x5
ffffffffc0200fee:	02648493          	addi	s1,s1,38 # ffffffffc0206010 <free_area>
ffffffffc0200ff2:	40200593          	li	a1,1026
ffffffffc0200ff6:	e484                	sd	s1,8(s1)
ffffffffc0200ff8:	e084                	sd	s1,0(s1)
    nr_free = 0;
ffffffffc0200ffa:	00005797          	auipc	a5,0x5
ffffffffc0200ffe:	0207a323          	sw	zero,38(a5) # ffffffffc0206020 <free_area+0x10>
    assert(n > 0);
ffffffffc0201002:	c55ff0ef          	jal	ra,ffffffffc0200c56 <buddy_init_memmap.part.0>
    buddy_init_memmap(physical_area, 1026);//预留1026个物理页面,初始化

    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = NULL;
    //分配四页内存，并验证它们是连续的
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201006:	4505                	li	a0,1
ffffffffc0201008:	4a8000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc020100c:	8a2a                	mv	s4,a0
ffffffffc020100e:	34050163          	beqz	a0,ffffffffc0201350 <alloc_check+0x3ae>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201012:	4505                	li	a0,1
ffffffffc0201014:	49c000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201018:	8b2a                	mv	s6,a0
ffffffffc020101a:	30050b63          	beqz	a0,ffffffffc0201330 <alloc_check+0x38e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020101e:	4505                	li	a0,1
ffffffffc0201020:	490000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201024:	8aaa                	mv	s5,a0
ffffffffc0201026:	2e050563          	beqz	a0,ffffffffc0201310 <alloc_check+0x36e>
    assert((p3 = alloc_page()) != NULL);
ffffffffc020102a:	4505                	li	a0,1
ffffffffc020102c:	484000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201030:	8baa                	mv	s7,a0
ffffffffc0201032:	2a050f63          	beqz	a0,ffffffffc02012f0 <alloc_check+0x34e>
    assert(p0 + 1 == p1);
ffffffffc0201036:	028a0793          	addi	a5,s4,40
ffffffffc020103a:	34fb1b63          	bne	s6,a5,ffffffffc0201390 <alloc_check+0x3ee>
    assert(p1 + 1 == p2);
ffffffffc020103e:	050a0793          	addi	a5,s4,80
ffffffffc0201042:	32fa9763          	bne	s5,a5,ffffffffc0201370 <alloc_check+0x3ce>
    assert(p2 + 1 == p3);
ffffffffc0201046:	078a0793          	addi	a5,s4,120
ffffffffc020104a:	38f51363          	bne	a0,a5,ffffffffc02013d0 <alloc_check+0x42e>
    //验证分配的页面引用计数为0
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc020104e:	000a2783          	lw	a5,0(s4)
ffffffffc0201052:	18079f63          	bnez	a5,ffffffffc02011f0 <alloc_check+0x24e>
ffffffffc0201056:	000b2783          	lw	a5,0(s6)
ffffffffc020105a:	18079b63          	bnez	a5,ffffffffc02011f0 <alloc_check+0x24e>
ffffffffc020105e:	000aa783          	lw	a5,0(s5)
ffffffffc0201062:	18079763          	bnez	a5,ffffffffc02011f0 <alloc_check+0x24e>
ffffffffc0201066:	411c                	lw	a5,0(a0)
ffffffffc0201068:	18079463          	bnez	a5,ffffffffc02011f0 <alloc_check+0x24e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020106c:	00005797          	auipc	a5,0x5
ffffffffc0201070:	40c7b783          	ld	a5,1036(a5) # ffffffffc0206478 <pages>
ffffffffc0201074:	40fa0733          	sub	a4,s4,a5
ffffffffc0201078:	870d                	srai	a4,a4,0x3
ffffffffc020107a:	00002597          	auipc	a1,0x2
ffffffffc020107e:	96e5b583          	ld	a1,-1682(a1) # ffffffffc02029e8 <error_string+0x38>
ffffffffc0201082:	02b70733          	mul	a4,a4,a1
ffffffffc0201086:	00002617          	auipc	a2,0x2
ffffffffc020108a:	96a63603          	ld	a2,-1686(a2) # ffffffffc02029f0 <nbase>
    //验证分配的页面物理地址有效
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020108e:	00005697          	auipc	a3,0x5
ffffffffc0201092:	3e26b683          	ld	a3,994(a3) # ffffffffc0206470 <npage>
ffffffffc0201096:	06b2                	slli	a3,a3,0xc
ffffffffc0201098:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020109a:	0732                	slli	a4,a4,0xc
ffffffffc020109c:	3cd77a63          	bgeu	a4,a3,ffffffffc0201470 <alloc_check+0x4ce>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010a0:	40fb0733          	sub	a4,s6,a5
ffffffffc02010a4:	870d                	srai	a4,a4,0x3
ffffffffc02010a6:	02b70733          	mul	a4,a4,a1
ffffffffc02010aa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010ac:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010ae:	18d77163          	bgeu	a4,a3,ffffffffc0201230 <alloc_check+0x28e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010b2:	40fa8733          	sub	a4,s5,a5
ffffffffc02010b6:	870d                	srai	a4,a4,0x3
ffffffffc02010b8:	02b70733          	mul	a4,a4,a1
ffffffffc02010bc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010be:	0732                	slli	a4,a4,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010c0:	20d77863          	bgeu	a4,a3,ffffffffc02012d0 <alloc_check+0x32e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010c4:	40f507b3          	sub	a5,a0,a5
ffffffffc02010c8:	878d                	srai	a5,a5,0x3
ffffffffc02010ca:	02b787b3          	mul	a5,a5,a1
    assert(page2pa(p3) < npage * PGSIZE);
    //遍历空闲列表，验证分配是否成功
    list_entry_t *le = &free_list;
ffffffffc02010ce:	00005417          	auipc	s0,0x5
ffffffffc02010d2:	f4240413          	addi	s0,s0,-190 # ffffffffc0206010 <free_area>
ffffffffc02010d6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010d8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p3) < npage * PGSIZE);
ffffffffc02010da:	00d7e963          	bltu	a5,a3,ffffffffc02010ec <alloc_check+0x14a>
ffffffffc02010de:	aa49                	j	ffffffffc0201270 <alloc_check+0x2ce>
    while ((le = list_next(le)) != &free_list)
    {
        p = le2page(le, page_link);
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02010e0:	ff846503          	lwu	a0,-8(s0)
ffffffffc02010e4:	96fff0ef          	jal	ra,ffffffffc0200a52 <buddy_allocate_pages>
ffffffffc02010e8:	0e050463          	beqz	a0,ffffffffc02011d0 <alloc_check+0x22e>
    return listelm->next;
ffffffffc02010ec:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != &free_list)
ffffffffc02010ee:	fe9419e3          	bne	s0,s1,ffffffffc02010e0 <alloc_check+0x13e>
    }
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败
    assert(alloc_page() == NULL);
ffffffffc02010f2:	4505                	li	a0,1
ffffffffc02010f4:	3bc000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc02010f8:	2a051c63          	bnez	a0,ffffffffc02013b0 <alloc_check+0x40e>
    //释放之前分配的页面，并检查空闲页面计数 nr_free 是否正确
    free_page(p0);
ffffffffc02010fc:	4585                	li	a1,1
ffffffffc02010fe:	8552                	mv	a0,s4
ffffffffc0201100:	3ee000ef          	jal	ra,ffffffffc02014ee <free_pages>
    free_page(p1);
ffffffffc0201104:	4585                	li	a1,1
ffffffffc0201106:	855a                	mv	a0,s6
ffffffffc0201108:	3e6000ef          	jal	ra,ffffffffc02014ee <free_pages>
    free_page(p2);
ffffffffc020110c:	4585                	li	a1,1
ffffffffc020110e:	8556                	mv	a0,s5
ffffffffc0201110:	3de000ef          	jal	ra,ffffffffc02014ee <free_pages>
    assert(nr_free == 3);
ffffffffc0201114:	4818                	lw	a4,16(s0)
ffffffffc0201116:	478d                	li	a5,3
ffffffffc0201118:	16f71c63          	bne	a4,a5,ffffffffc0201290 <alloc_check+0x2ee>
    //再次分配一页和两页内存，并断言分配的页面是连续的
    assert((p1 = alloc_page()) != NULL);
ffffffffc020111c:	4505                	li	a0,1
ffffffffc020111e:	392000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201122:	8a2a                	mv	s4,a0
ffffffffc0201124:	30050663          	beqz	a0,ffffffffc0201430 <alloc_check+0x48e>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0201128:	4509                	li	a0,2
ffffffffc020112a:	386000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc020112e:	842a                	mv	s0,a0
ffffffffc0201130:	2e050063          	beqz	a0,ffffffffc0201410 <alloc_check+0x46e>
    assert(p0 + 2 == p1);
ffffffffc0201134:	05050793          	addi	a5,a0,80
ffffffffc0201138:	2afa1c63          	bne	s4,a5,ffffffffc02013f0 <alloc_check+0x44e>
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败
    assert(alloc_page() == NULL);
ffffffffc020113c:	4505                	li	a0,1
ffffffffc020113e:	372000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201142:	34051763          	bnez	a0,ffffffffc0201490 <alloc_check+0x4ee>
    free_pages(p0, 2);
ffffffffc0201146:	4589                	li	a1,2
ffffffffc0201148:	8522                	mv	a0,s0
ffffffffc020114a:	3a4000ef          	jal	ra,ffffffffc02014ee <free_pages>
    free_page(p1);
ffffffffc020114e:	4585                	li	a1,1
ffffffffc0201150:	8552                	mv	a0,s4
ffffffffc0201152:	39c000ef          	jal	ra,ffffffffc02014ee <free_pages>
    free_page(p3);
ffffffffc0201156:	855e                	mv	a0,s7
ffffffffc0201158:	4585                	li	a1,1
ffffffffc020115a:	394000ef          	jal	ra,ffffffffc02014ee <free_pages>
    //分配四页内存，并断言分配的页面是之前释放的页面
    assert((p = alloc_pages(4)) == p0);
ffffffffc020115e:	4511                	li	a0,4
ffffffffc0201160:	350000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc0201164:	14a41663          	bne	s0,a0,ffffffffc02012b0 <alloc_check+0x30e>
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败。同时断言当前的空闲页面计数为 0
    assert(alloc_page() == NULL);
ffffffffc0201168:	4505                	li	a0,1
ffffffffc020116a:	346000ef          	jal	ra,ffffffffc02014b0 <alloc_pages>
ffffffffc020116e:	2e051163          	bnez	a0,ffffffffc0201450 <alloc_check+0x4ae>
    assert(nr_free == 0);
ffffffffc0201172:	489c                	lw	a5,16(s1)
ffffffffc0201174:	eff1                	bnez	a5,ffffffffc0201250 <alloc_check+0x2ae>
    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc0201176:	00093783          	ld	a5,0(s2)
ffffffffc020117a:	00299693          	slli	a3,s3,0x2
ffffffffc020117e:	96ce                	add	a3,a3,s3
ffffffffc0201180:	068e                	slli	a3,a3,0x3
ffffffffc0201182:	00d78733          	add	a4,a5,a3
ffffffffc0201186:	04e7f363          	bgeu	a5,a4,ffffffffc02011cc <alloc_check+0x22a>
ffffffffc020118a:	4605                	li	a2,1
ffffffffc020118c:	00878713          	addi	a4,a5,8
ffffffffc0201190:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc0201194:	00093503          	ld	a0,0(s2)
ffffffffc0201198:	02878793          	addi	a5,a5,40
ffffffffc020119c:	00d50733          	add	a4,a0,a3
ffffffffc02011a0:	fee7e6e3          	bltu	a5,a4,ffffffffc020118c <alloc_check+0x1ea>
    elm->prev = elm->next = elm;
ffffffffc02011a4:	e484                	sd	s1,8(s1)
ffffffffc02011a6:	e084                	sd	s1,0(s1)
    nr_free = 0;
ffffffffc02011a8:	00005797          	auipc	a5,0x5
ffffffffc02011ac:	e607ac23          	sw	zero,-392(a5) # ffffffffc0206020 <free_area+0x10>
    assert(n > 0);
ffffffffc02011b0:	06098063          	beqz	s3,ffffffffc0201210 <alloc_check+0x26e>
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(physical_area, total_size_store);
}
ffffffffc02011b4:	6406                	ld	s0,64(sp)
ffffffffc02011b6:	60a6                	ld	ra,72(sp)
ffffffffc02011b8:	74e2                	ld	s1,56(sp)
ffffffffc02011ba:	7942                	ld	s2,48(sp)
ffffffffc02011bc:	7a02                	ld	s4,32(sp)
ffffffffc02011be:	6ae2                	ld	s5,24(sp)
ffffffffc02011c0:	6b42                	ld	s6,16(sp)
ffffffffc02011c2:	6ba2                	ld	s7,8(sp)
ffffffffc02011c4:	85ce                	mv	a1,s3
ffffffffc02011c6:	79a2                	ld	s3,40(sp)
ffffffffc02011c8:	6161                	addi	sp,sp,80
ffffffffc02011ca:	b471                	j	ffffffffc0200c56 <buddy_init_memmap.part.0>
    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc02011cc:	853e                	mv	a0,a5
ffffffffc02011ce:	bfd9                	j	ffffffffc02011a4 <alloc_check+0x202>
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02011d0:	00001697          	auipc	a3,0x1
ffffffffc02011d4:	3a068693          	addi	a3,a3,928 # ffffffffc0202570 <commands+0x700>
ffffffffc02011d8:	00001617          	auipc	a2,0x1
ffffffffc02011dc:	19860613          	addi	a2,a2,408 # ffffffffc0202370 <commands+0x500>
ffffffffc02011e0:	11200593          	li	a1,274
ffffffffc02011e4:	00001517          	auipc	a0,0x1
ffffffffc02011e8:	1a450513          	addi	a0,a0,420 # ffffffffc0202388 <commands+0x518>
ffffffffc02011ec:	9c0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc02011f0:	00001697          	auipc	a3,0x1
ffffffffc02011f4:	2a868693          	addi	a3,a3,680 # ffffffffc0202498 <commands+0x628>
ffffffffc02011f8:	00001617          	auipc	a2,0x1
ffffffffc02011fc:	17860613          	addi	a2,a2,376 # ffffffffc0202370 <commands+0x500>
ffffffffc0201200:	10700593          	li	a1,263
ffffffffc0201204:	00001517          	auipc	a0,0x1
ffffffffc0201208:	18450513          	addi	a0,a0,388 # ffffffffc0202388 <commands+0x518>
ffffffffc020120c:	9a0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201210:	00001697          	auipc	a3,0x1
ffffffffc0201214:	15868693          	addi	a3,a3,344 # ffffffffc0202368 <commands+0x4f8>
ffffffffc0201218:	00001617          	auipc	a2,0x1
ffffffffc020121c:	15860613          	addi	a2,a2,344 # ffffffffc0202370 <commands+0x500>
ffffffffc0201220:	03e00593          	li	a1,62
ffffffffc0201224:	00001517          	auipc	a0,0x1
ffffffffc0201228:	16450513          	addi	a0,a0,356 # ffffffffc0202388 <commands+0x518>
ffffffffc020122c:	980ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201230:	00001697          	auipc	a3,0x1
ffffffffc0201234:	2e068693          	addi	a3,a3,736 # ffffffffc0202510 <commands+0x6a0>
ffffffffc0201238:	00001617          	auipc	a2,0x1
ffffffffc020123c:	13860613          	addi	a2,a2,312 # ffffffffc0202370 <commands+0x500>
ffffffffc0201240:	10a00593          	li	a1,266
ffffffffc0201244:	00001517          	auipc	a0,0x1
ffffffffc0201248:	14450513          	addi	a0,a0,324 # ffffffffc0202388 <commands+0x518>
ffffffffc020124c:	960ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0201250:	00001697          	auipc	a3,0x1
ffffffffc0201254:	3c868693          	addi	a3,a3,968 # ffffffffc0202618 <commands+0x7a8>
ffffffffc0201258:	00001617          	auipc	a2,0x1
ffffffffc020125c:	11860613          	addi	a2,a2,280 # ffffffffc0202370 <commands+0x500>
ffffffffc0201260:	12800593          	li	a1,296
ffffffffc0201264:	00001517          	auipc	a0,0x1
ffffffffc0201268:	12450513          	addi	a0,a0,292 # ffffffffc0202388 <commands+0x518>
ffffffffc020126c:	940ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p3) < npage * PGSIZE);
ffffffffc0201270:	00001697          	auipc	a3,0x1
ffffffffc0201274:	2e068693          	addi	a3,a3,736 # ffffffffc0202550 <commands+0x6e0>
ffffffffc0201278:	00001617          	auipc	a2,0x1
ffffffffc020127c:	0f860613          	addi	a2,a2,248 # ffffffffc0202370 <commands+0x500>
ffffffffc0201280:	10c00593          	li	a1,268
ffffffffc0201284:	00001517          	auipc	a0,0x1
ffffffffc0201288:	10450513          	addi	a0,a0,260 # ffffffffc0202388 <commands+0x518>
ffffffffc020128c:	920ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0201290:	00001697          	auipc	a3,0x1
ffffffffc0201294:	32868693          	addi	a3,a3,808 # ffffffffc02025b8 <commands+0x748>
ffffffffc0201298:	00001617          	auipc	a2,0x1
ffffffffc020129c:	0d860613          	addi	a2,a2,216 # ffffffffc0202370 <commands+0x500>
ffffffffc02012a0:	11a00593          	li	a1,282
ffffffffc02012a4:	00001517          	auipc	a0,0x1
ffffffffc02012a8:	0e450513          	addi	a0,a0,228 # ffffffffc0202388 <commands+0x518>
ffffffffc02012ac:	900ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_pages(4)) == p0);
ffffffffc02012b0:	00001697          	auipc	a3,0x1
ffffffffc02012b4:	34868693          	addi	a3,a3,840 # ffffffffc02025f8 <commands+0x788>
ffffffffc02012b8:	00001617          	auipc	a2,0x1
ffffffffc02012bc:	0b860613          	addi	a2,a2,184 # ffffffffc0202370 <commands+0x500>
ffffffffc02012c0:	12500593          	li	a1,293
ffffffffc02012c4:	00001517          	auipc	a0,0x1
ffffffffc02012c8:	0c450513          	addi	a0,a0,196 # ffffffffc0202388 <commands+0x518>
ffffffffc02012cc:	8e0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012d0:	00001697          	auipc	a3,0x1
ffffffffc02012d4:	26068693          	addi	a3,a3,608 # ffffffffc0202530 <commands+0x6c0>
ffffffffc02012d8:	00001617          	auipc	a2,0x1
ffffffffc02012dc:	09860613          	addi	a2,a2,152 # ffffffffc0202370 <commands+0x500>
ffffffffc02012e0:	10b00593          	li	a1,267
ffffffffc02012e4:	00001517          	auipc	a0,0x1
ffffffffc02012e8:	0a450513          	addi	a0,a0,164 # ffffffffc0202388 <commands+0x518>
ffffffffc02012ec:	8c0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p3 = alloc_page()) != NULL);
ffffffffc02012f0:	00001697          	auipc	a3,0x1
ffffffffc02012f4:	15868693          	addi	a3,a3,344 # ffffffffc0202448 <commands+0x5d8>
ffffffffc02012f8:	00001617          	auipc	a2,0x1
ffffffffc02012fc:	07860613          	addi	a2,a2,120 # ffffffffc0202370 <commands+0x500>
ffffffffc0201300:	10200593          	li	a1,258
ffffffffc0201304:	00001517          	auipc	a0,0x1
ffffffffc0201308:	08450513          	addi	a0,a0,132 # ffffffffc0202388 <commands+0x518>
ffffffffc020130c:	8a0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201310:	00001697          	auipc	a3,0x1
ffffffffc0201314:	11868693          	addi	a3,a3,280 # ffffffffc0202428 <commands+0x5b8>
ffffffffc0201318:	00001617          	auipc	a2,0x1
ffffffffc020131c:	05860613          	addi	a2,a2,88 # ffffffffc0202370 <commands+0x500>
ffffffffc0201320:	10100593          	li	a1,257
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	06450513          	addi	a0,a0,100 # ffffffffc0202388 <commands+0x518>
ffffffffc020132c:	880ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201330:	00001697          	auipc	a3,0x1
ffffffffc0201334:	0d868693          	addi	a3,a3,216 # ffffffffc0202408 <commands+0x598>
ffffffffc0201338:	00001617          	auipc	a2,0x1
ffffffffc020133c:	03860613          	addi	a2,a2,56 # ffffffffc0202370 <commands+0x500>
ffffffffc0201340:	10000593          	li	a1,256
ffffffffc0201344:	00001517          	auipc	a0,0x1
ffffffffc0201348:	04450513          	addi	a0,a0,68 # ffffffffc0202388 <commands+0x518>
ffffffffc020134c:	860ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201350:	00001697          	auipc	a3,0x1
ffffffffc0201354:	09868693          	addi	a3,a3,152 # ffffffffc02023e8 <commands+0x578>
ffffffffc0201358:	00001617          	auipc	a2,0x1
ffffffffc020135c:	01860613          	addi	a2,a2,24 # ffffffffc0202370 <commands+0x500>
ffffffffc0201360:	0ff00593          	li	a1,255
ffffffffc0201364:	00001517          	auipc	a0,0x1
ffffffffc0201368:	02450513          	addi	a0,a0,36 # ffffffffc0202388 <commands+0x518>
ffffffffc020136c:	840ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 + 1 == p2);
ffffffffc0201370:	00001697          	auipc	a3,0x1
ffffffffc0201374:	10868693          	addi	a3,a3,264 # ffffffffc0202478 <commands+0x608>
ffffffffc0201378:	00001617          	auipc	a2,0x1
ffffffffc020137c:	ff860613          	addi	a2,a2,-8 # ffffffffc0202370 <commands+0x500>
ffffffffc0201380:	10400593          	li	a1,260
ffffffffc0201384:	00001517          	auipc	a0,0x1
ffffffffc0201388:	00450513          	addi	a0,a0,4 # ffffffffc0202388 <commands+0x518>
ffffffffc020138c:	820ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 1 == p1);
ffffffffc0201390:	00001697          	auipc	a3,0x1
ffffffffc0201394:	0d868693          	addi	a3,a3,216 # ffffffffc0202468 <commands+0x5f8>
ffffffffc0201398:	00001617          	auipc	a2,0x1
ffffffffc020139c:	fd860613          	addi	a2,a2,-40 # ffffffffc0202370 <commands+0x500>
ffffffffc02013a0:	10300593          	li	a1,259
ffffffffc02013a4:	00001517          	auipc	a0,0x1
ffffffffc02013a8:	fe450513          	addi	a0,a0,-28 # ffffffffc0202388 <commands+0x518>
ffffffffc02013ac:	800ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013b0:	00001697          	auipc	a3,0x1
ffffffffc02013b4:	1f068693          	addi	a3,a3,496 # ffffffffc02025a0 <commands+0x730>
ffffffffc02013b8:	00001617          	auipc	a2,0x1
ffffffffc02013bc:	fb860613          	addi	a2,a2,-72 # ffffffffc0202370 <commands+0x500>
ffffffffc02013c0:	11500593          	li	a1,277
ffffffffc02013c4:	00001517          	auipc	a0,0x1
ffffffffc02013c8:	fc450513          	addi	a0,a0,-60 # ffffffffc0202388 <commands+0x518>
ffffffffc02013cc:	fe1fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 + 1 == p3);
ffffffffc02013d0:	00001697          	auipc	a3,0x1
ffffffffc02013d4:	0b868693          	addi	a3,a3,184 # ffffffffc0202488 <commands+0x618>
ffffffffc02013d8:	00001617          	auipc	a2,0x1
ffffffffc02013dc:	f9860613          	addi	a2,a2,-104 # ffffffffc0202370 <commands+0x500>
ffffffffc02013e0:	10500593          	li	a1,261
ffffffffc02013e4:	00001517          	auipc	a0,0x1
ffffffffc02013e8:	fa450513          	addi	a0,a0,-92 # ffffffffc0202388 <commands+0x518>
ffffffffc02013ec:	fc1fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);
ffffffffc02013f0:	00001697          	auipc	a3,0x1
ffffffffc02013f4:	1f868693          	addi	a3,a3,504 # ffffffffc02025e8 <commands+0x778>
ffffffffc02013f8:	00001617          	auipc	a2,0x1
ffffffffc02013fc:	f7860613          	addi	a2,a2,-136 # ffffffffc0202370 <commands+0x500>
ffffffffc0201400:	11e00593          	li	a1,286
ffffffffc0201404:	00001517          	auipc	a0,0x1
ffffffffc0201408:	f8450513          	addi	a0,a0,-124 # ffffffffc0202388 <commands+0x518>
ffffffffc020140c:	fa1fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0201410:	00001697          	auipc	a3,0x1
ffffffffc0201414:	1b868693          	addi	a3,a3,440 # ffffffffc02025c8 <commands+0x758>
ffffffffc0201418:	00001617          	auipc	a2,0x1
ffffffffc020141c:	f5860613          	addi	a2,a2,-168 # ffffffffc0202370 <commands+0x500>
ffffffffc0201420:	11d00593          	li	a1,285
ffffffffc0201424:	00001517          	auipc	a0,0x1
ffffffffc0201428:	f6450513          	addi	a0,a0,-156 # ffffffffc0202388 <commands+0x518>
ffffffffc020142c:	f81fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201430:	00001697          	auipc	a3,0x1
ffffffffc0201434:	fd868693          	addi	a3,a3,-40 # ffffffffc0202408 <commands+0x598>
ffffffffc0201438:	00001617          	auipc	a2,0x1
ffffffffc020143c:	f3860613          	addi	a2,a2,-200 # ffffffffc0202370 <commands+0x500>
ffffffffc0201440:	11c00593          	li	a1,284
ffffffffc0201444:	00001517          	auipc	a0,0x1
ffffffffc0201448:	f4450513          	addi	a0,a0,-188 # ffffffffc0202388 <commands+0x518>
ffffffffc020144c:	f61fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201450:	00001697          	auipc	a3,0x1
ffffffffc0201454:	15068693          	addi	a3,a3,336 # ffffffffc02025a0 <commands+0x730>
ffffffffc0201458:	00001617          	auipc	a2,0x1
ffffffffc020145c:	f1860613          	addi	a2,a2,-232 # ffffffffc0202370 <commands+0x500>
ffffffffc0201460:	12700593          	li	a1,295
ffffffffc0201464:	00001517          	auipc	a0,0x1
ffffffffc0201468:	f2450513          	addi	a0,a0,-220 # ffffffffc0202388 <commands+0x518>
ffffffffc020146c:	f41fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201470:	00001697          	auipc	a3,0x1
ffffffffc0201474:	08068693          	addi	a3,a3,128 # ffffffffc02024f0 <commands+0x680>
ffffffffc0201478:	00001617          	auipc	a2,0x1
ffffffffc020147c:	ef860613          	addi	a2,a2,-264 # ffffffffc0202370 <commands+0x500>
ffffffffc0201480:	10900593          	li	a1,265
ffffffffc0201484:	00001517          	auipc	a0,0x1
ffffffffc0201488:	f0450513          	addi	a0,a0,-252 # ffffffffc0202388 <commands+0x518>
ffffffffc020148c:	f21fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201490:	00001697          	auipc	a3,0x1
ffffffffc0201494:	11068693          	addi	a3,a3,272 # ffffffffc02025a0 <commands+0x730>
ffffffffc0201498:	00001617          	auipc	a2,0x1
ffffffffc020149c:	ed860613          	addi	a2,a2,-296 # ffffffffc0202370 <commands+0x500>
ffffffffc02014a0:	12000593          	li	a1,288
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	ee450513          	addi	a0,a0,-284 # ffffffffc0202388 <commands+0x518>
ffffffffc02014ac:	f01fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02014b0 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014b0:	100027f3          	csrr	a5,sstatus
ffffffffc02014b4:	8b89                	andi	a5,a5,2
ffffffffc02014b6:	e799                	bnez	a5,ffffffffc02014c4 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02014b8:	00005797          	auipc	a5,0x5
ffffffffc02014bc:	fc87b783          	ld	a5,-56(a5) # ffffffffc0206480 <pmm_manager>
ffffffffc02014c0:	6f9c                	ld	a5,24(a5)
ffffffffc02014c2:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02014c4:	1141                	addi	sp,sp,-16
ffffffffc02014c6:	e406                	sd	ra,8(sp)
ffffffffc02014c8:	e022                	sd	s0,0(sp)
ffffffffc02014ca:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02014cc:	f93fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02014d0:	00005797          	auipc	a5,0x5
ffffffffc02014d4:	fb07b783          	ld	a5,-80(a5) # ffffffffc0206480 <pmm_manager>
ffffffffc02014d8:	6f9c                	ld	a5,24(a5)
ffffffffc02014da:	8522                	mv	a0,s0
ffffffffc02014dc:	9782                	jalr	a5
ffffffffc02014de:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02014e0:	f79fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02014e4:	60a2                	ld	ra,8(sp)
ffffffffc02014e6:	8522                	mv	a0,s0
ffffffffc02014e8:	6402                	ld	s0,0(sp)
ffffffffc02014ea:	0141                	addi	sp,sp,16
ffffffffc02014ec:	8082                	ret

ffffffffc02014ee <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014ee:	100027f3          	csrr	a5,sstatus
ffffffffc02014f2:	8b89                	andi	a5,a5,2
ffffffffc02014f4:	e799                	bnez	a5,ffffffffc0201502 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02014f6:	00005797          	auipc	a5,0x5
ffffffffc02014fa:	f8a7b783          	ld	a5,-118(a5) # ffffffffc0206480 <pmm_manager>
ffffffffc02014fe:	739c                	ld	a5,32(a5)
ffffffffc0201500:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201502:	1101                	addi	sp,sp,-32
ffffffffc0201504:	ec06                	sd	ra,24(sp)
ffffffffc0201506:	e822                	sd	s0,16(sp)
ffffffffc0201508:	e426                	sd	s1,8(sp)
ffffffffc020150a:	842a                	mv	s0,a0
ffffffffc020150c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020150e:	f51fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201512:	00005797          	auipc	a5,0x5
ffffffffc0201516:	f6e7b783          	ld	a5,-146(a5) # ffffffffc0206480 <pmm_manager>
ffffffffc020151a:	739c                	ld	a5,32(a5)
ffffffffc020151c:	85a6                	mv	a1,s1
ffffffffc020151e:	8522                	mv	a0,s0
ffffffffc0201520:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201522:	6442                	ld	s0,16(sp)
ffffffffc0201524:	60e2                	ld	ra,24(sp)
ffffffffc0201526:	64a2                	ld	s1,8(sp)
ffffffffc0201528:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020152a:	f2ffe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020152e <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020152e:	00001797          	auipc	a5,0x1
ffffffffc0201532:	11278793          	addi	a5,a5,274 # ffffffffc0202640 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201536:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201538:	1101                	addi	sp,sp,-32
ffffffffc020153a:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020153c:	00001517          	auipc	a0,0x1
ffffffffc0201540:	13c50513          	addi	a0,a0,316 # ffffffffc0202678 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201544:	00005497          	auipc	s1,0x5
ffffffffc0201548:	f3c48493          	addi	s1,s1,-196 # ffffffffc0206480 <pmm_manager>
void pmm_init(void) {
ffffffffc020154c:	ec06                	sd	ra,24(sp)
ffffffffc020154e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201550:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201552:	b61fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201556:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201558:	00005417          	auipc	s0,0x5
ffffffffc020155c:	f4040413          	addi	s0,s0,-192 # ffffffffc0206498 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201560:	679c                	ld	a5,8(a5)
ffffffffc0201562:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201564:	57f5                	li	a5,-3
ffffffffc0201566:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201568:	00001517          	auipc	a0,0x1
ffffffffc020156c:	12850513          	addi	a0,a0,296 # ffffffffc0202690 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201570:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201572:	b41fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201576:	46c5                	li	a3,17
ffffffffc0201578:	06ee                	slli	a3,a3,0x1b
ffffffffc020157a:	40100613          	li	a2,1025
ffffffffc020157e:	16fd                	addi	a3,a3,-1
ffffffffc0201580:	07e005b7          	lui	a1,0x7e00
ffffffffc0201584:	0656                	slli	a2,a2,0x15
ffffffffc0201586:	00001517          	auipc	a0,0x1
ffffffffc020158a:	12250513          	addi	a0,a0,290 # ffffffffc02026a8 <buddy_pmm_manager+0x68>
ffffffffc020158e:	b25fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201592:	777d                	lui	a4,0xfffff
ffffffffc0201594:	00006797          	auipc	a5,0x6
ffffffffc0201598:	f1378793          	addi	a5,a5,-237 # ffffffffc02074a7 <end+0xfff>
ffffffffc020159c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020159e:	00005517          	auipc	a0,0x5
ffffffffc02015a2:	ed250513          	addi	a0,a0,-302 # ffffffffc0206470 <npage>
ffffffffc02015a6:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02015aa:	00005597          	auipc	a1,0x5
ffffffffc02015ae:	ece58593          	addi	a1,a1,-306 # ffffffffc0206478 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02015b2:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02015b4:	e19c                	sd	a5,0(a1)
ffffffffc02015b6:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02015b8:	4701                	li	a4,0
ffffffffc02015ba:	4885                	li	a7,1
ffffffffc02015bc:	fff80837          	lui	a6,0xfff80
ffffffffc02015c0:	a011                	j	ffffffffc02015c4 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02015c2:	619c                	ld	a5,0(a1)
ffffffffc02015c4:	97b6                	add	a5,a5,a3
ffffffffc02015c6:	07a1                	addi	a5,a5,8
ffffffffc02015c8:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02015cc:	611c                	ld	a5,0(a0)
ffffffffc02015ce:	0705                	addi	a4,a4,1
ffffffffc02015d0:	02868693          	addi	a3,a3,40
ffffffffc02015d4:	01078633          	add	a2,a5,a6
ffffffffc02015d8:	fec765e3          	bltu	a4,a2,ffffffffc02015c2 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015dc:	6190                	ld	a2,0(a1)
ffffffffc02015de:	00279713          	slli	a4,a5,0x2
ffffffffc02015e2:	973e                	add	a4,a4,a5
ffffffffc02015e4:	fec006b7          	lui	a3,0xfec00
ffffffffc02015e8:	070e                	slli	a4,a4,0x3
ffffffffc02015ea:	96b2                	add	a3,a3,a2
ffffffffc02015ec:	96ba                	add	a3,a3,a4
ffffffffc02015ee:	c0200737          	lui	a4,0xc0200
ffffffffc02015f2:	08e6ef63          	bltu	a3,a4,ffffffffc0201690 <pmm_init+0x162>
ffffffffc02015f6:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02015f8:	45c5                	li	a1,17
ffffffffc02015fa:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015fc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02015fe:	04b6e863          	bltu	a3,a1,ffffffffc020164e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201602:	609c                	ld	a5,0(s1)
ffffffffc0201604:	7b9c                	ld	a5,48(a5)
ffffffffc0201606:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201608:	00001517          	auipc	a0,0x1
ffffffffc020160c:	13850513          	addi	a0,a0,312 # ffffffffc0202740 <buddy_pmm_manager+0x100>
ffffffffc0201610:	aa3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201614:	00004597          	auipc	a1,0x4
ffffffffc0201618:	9ec58593          	addi	a1,a1,-1556 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020161c:	00005797          	auipc	a5,0x5
ffffffffc0201620:	e6b7ba23          	sd	a1,-396(a5) # ffffffffc0206490 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201624:	c02007b7          	lui	a5,0xc0200
ffffffffc0201628:	08f5e063          	bltu	a1,a5,ffffffffc02016a8 <pmm_init+0x17a>
ffffffffc020162c:	6010                	ld	a2,0(s0)
}
ffffffffc020162e:	6442                	ld	s0,16(sp)
ffffffffc0201630:	60e2                	ld	ra,24(sp)
ffffffffc0201632:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201634:	40c58633          	sub	a2,a1,a2
ffffffffc0201638:	00005797          	auipc	a5,0x5
ffffffffc020163c:	e4c7b823          	sd	a2,-432(a5) # ffffffffc0206488 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201640:	00001517          	auipc	a0,0x1
ffffffffc0201644:	12050513          	addi	a0,a0,288 # ffffffffc0202760 <buddy_pmm_manager+0x120>
}
ffffffffc0201648:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020164a:	a69fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020164e:	6705                	lui	a4,0x1
ffffffffc0201650:	177d                	addi	a4,a4,-1
ffffffffc0201652:	96ba                	add	a3,a3,a4
ffffffffc0201654:	777d                	lui	a4,0xfffff
ffffffffc0201656:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201658:	00c6d513          	srli	a0,a3,0xc
ffffffffc020165c:	00f57e63          	bgeu	a0,a5,ffffffffc0201678 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201660:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201662:	982a                	add	a6,a6,a0
ffffffffc0201664:	00281513          	slli	a0,a6,0x2
ffffffffc0201668:	9542                	add	a0,a0,a6
ffffffffc020166a:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020166c:	8d95                	sub	a1,a1,a3
ffffffffc020166e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201670:	81b1                	srli	a1,a1,0xc
ffffffffc0201672:	9532                	add	a0,a0,a2
ffffffffc0201674:	9782                	jalr	a5
}
ffffffffc0201676:	b771                	j	ffffffffc0201602 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201678:	00001617          	auipc	a2,0x1
ffffffffc020167c:	09860613          	addi	a2,a2,152 # ffffffffc0202710 <buddy_pmm_manager+0xd0>
ffffffffc0201680:	06b00593          	li	a1,107
ffffffffc0201684:	00001517          	auipc	a0,0x1
ffffffffc0201688:	0ac50513          	addi	a0,a0,172 # ffffffffc0202730 <buddy_pmm_manager+0xf0>
ffffffffc020168c:	d21fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201690:	00001617          	auipc	a2,0x1
ffffffffc0201694:	04860613          	addi	a2,a2,72 # ffffffffc02026d8 <buddy_pmm_manager+0x98>
ffffffffc0201698:	06f00593          	li	a1,111
ffffffffc020169c:	00001517          	auipc	a0,0x1
ffffffffc02016a0:	06450513          	addi	a0,a0,100 # ffffffffc0202700 <buddy_pmm_manager+0xc0>
ffffffffc02016a4:	d09fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02016a8:	86ae                	mv	a3,a1
ffffffffc02016aa:	00001617          	auipc	a2,0x1
ffffffffc02016ae:	02e60613          	addi	a2,a2,46 # ffffffffc02026d8 <buddy_pmm_manager+0x98>
ffffffffc02016b2:	08a00593          	li	a1,138
ffffffffc02016b6:	00001517          	auipc	a0,0x1
ffffffffc02016ba:	04a50513          	addi	a0,a0,74 # ffffffffc0202700 <buddy_pmm_manager+0xc0>
ffffffffc02016be:	ceffe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02016c2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02016c2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016c6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02016c8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016cc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02016ce:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016d2:	f022                	sd	s0,32(sp)
ffffffffc02016d4:	ec26                	sd	s1,24(sp)
ffffffffc02016d6:	e84a                	sd	s2,16(sp)
ffffffffc02016d8:	f406                	sd	ra,40(sp)
ffffffffc02016da:	e44e                	sd	s3,8(sp)
ffffffffc02016dc:	84aa                	mv	s1,a0
ffffffffc02016de:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02016e0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02016e4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02016e6:	03067e63          	bgeu	a2,a6,ffffffffc0201722 <printnum+0x60>
ffffffffc02016ea:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02016ec:	00805763          	blez	s0,ffffffffc02016fa <printnum+0x38>
ffffffffc02016f0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02016f2:	85ca                	mv	a1,s2
ffffffffc02016f4:	854e                	mv	a0,s3
ffffffffc02016f6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02016f8:	fc65                	bnez	s0,ffffffffc02016f0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016fa:	1a02                	slli	s4,s4,0x20
ffffffffc02016fc:	00001797          	auipc	a5,0x1
ffffffffc0201700:	0a478793          	addi	a5,a5,164 # ffffffffc02027a0 <buddy_pmm_manager+0x160>
ffffffffc0201704:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201708:	9a3e                	add	s4,s4,a5
}
ffffffffc020170a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020170c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201710:	70a2                	ld	ra,40(sp)
ffffffffc0201712:	69a2                	ld	s3,8(sp)
ffffffffc0201714:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201716:	85ca                	mv	a1,s2
ffffffffc0201718:	87a6                	mv	a5,s1
}
ffffffffc020171a:	6942                	ld	s2,16(sp)
ffffffffc020171c:	64e2                	ld	s1,24(sp)
ffffffffc020171e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201720:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201722:	03065633          	divu	a2,a2,a6
ffffffffc0201726:	8722                	mv	a4,s0
ffffffffc0201728:	f9bff0ef          	jal	ra,ffffffffc02016c2 <printnum>
ffffffffc020172c:	b7f9                	j	ffffffffc02016fa <printnum+0x38>

ffffffffc020172e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020172e:	7119                	addi	sp,sp,-128
ffffffffc0201730:	f4a6                	sd	s1,104(sp)
ffffffffc0201732:	f0ca                	sd	s2,96(sp)
ffffffffc0201734:	ecce                	sd	s3,88(sp)
ffffffffc0201736:	e8d2                	sd	s4,80(sp)
ffffffffc0201738:	e4d6                	sd	s5,72(sp)
ffffffffc020173a:	e0da                	sd	s6,64(sp)
ffffffffc020173c:	fc5e                	sd	s7,56(sp)
ffffffffc020173e:	f06a                	sd	s10,32(sp)
ffffffffc0201740:	fc86                	sd	ra,120(sp)
ffffffffc0201742:	f8a2                	sd	s0,112(sp)
ffffffffc0201744:	f862                	sd	s8,48(sp)
ffffffffc0201746:	f466                	sd	s9,40(sp)
ffffffffc0201748:	ec6e                	sd	s11,24(sp)
ffffffffc020174a:	892a                	mv	s2,a0
ffffffffc020174c:	84ae                	mv	s1,a1
ffffffffc020174e:	8d32                	mv	s10,a2
ffffffffc0201750:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201752:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201756:	5b7d                	li	s6,-1
ffffffffc0201758:	00001a97          	auipc	s5,0x1
ffffffffc020175c:	07ca8a93          	addi	s5,s5,124 # ffffffffc02027d4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201760:	00001b97          	auipc	s7,0x1
ffffffffc0201764:	250b8b93          	addi	s7,s7,592 # ffffffffc02029b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201768:	000d4503          	lbu	a0,0(s10)
ffffffffc020176c:	001d0413          	addi	s0,s10,1
ffffffffc0201770:	01350a63          	beq	a0,s3,ffffffffc0201784 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201774:	c121                	beqz	a0,ffffffffc02017b4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201776:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201778:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020177a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020177c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201780:	ff351ae3          	bne	a0,s3,ffffffffc0201774 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201784:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201788:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020178c:	4c81                	li	s9,0
ffffffffc020178e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201790:	5c7d                	li	s8,-1
ffffffffc0201792:	5dfd                	li	s11,-1
ffffffffc0201794:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201798:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020179a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020179e:	0ff5f593          	zext.b	a1,a1
ffffffffc02017a2:	00140d13          	addi	s10,s0,1
ffffffffc02017a6:	04b56263          	bltu	a0,a1,ffffffffc02017ea <vprintfmt+0xbc>
ffffffffc02017aa:	058a                	slli	a1,a1,0x2
ffffffffc02017ac:	95d6                	add	a1,a1,s5
ffffffffc02017ae:	4194                	lw	a3,0(a1)
ffffffffc02017b0:	96d6                	add	a3,a3,s5
ffffffffc02017b2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02017b4:	70e6                	ld	ra,120(sp)
ffffffffc02017b6:	7446                	ld	s0,112(sp)
ffffffffc02017b8:	74a6                	ld	s1,104(sp)
ffffffffc02017ba:	7906                	ld	s2,96(sp)
ffffffffc02017bc:	69e6                	ld	s3,88(sp)
ffffffffc02017be:	6a46                	ld	s4,80(sp)
ffffffffc02017c0:	6aa6                	ld	s5,72(sp)
ffffffffc02017c2:	6b06                	ld	s6,64(sp)
ffffffffc02017c4:	7be2                	ld	s7,56(sp)
ffffffffc02017c6:	7c42                	ld	s8,48(sp)
ffffffffc02017c8:	7ca2                	ld	s9,40(sp)
ffffffffc02017ca:	7d02                	ld	s10,32(sp)
ffffffffc02017cc:	6de2                	ld	s11,24(sp)
ffffffffc02017ce:	6109                	addi	sp,sp,128
ffffffffc02017d0:	8082                	ret
            padc = '0';
ffffffffc02017d2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02017d4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017d8:	846a                	mv	s0,s10
ffffffffc02017da:	00140d13          	addi	s10,s0,1
ffffffffc02017de:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02017e2:	0ff5f593          	zext.b	a1,a1
ffffffffc02017e6:	fcb572e3          	bgeu	a0,a1,ffffffffc02017aa <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02017ea:	85a6                	mv	a1,s1
ffffffffc02017ec:	02500513          	li	a0,37
ffffffffc02017f0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02017f2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017f6:	8d22                	mv	s10,s0
ffffffffc02017f8:	f73788e3          	beq	a5,s3,ffffffffc0201768 <vprintfmt+0x3a>
ffffffffc02017fc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201800:	1d7d                	addi	s10,s10,-1
ffffffffc0201802:	ff379de3          	bne	a5,s3,ffffffffc02017fc <vprintfmt+0xce>
ffffffffc0201806:	b78d                	j	ffffffffc0201768 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201808:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020180c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201810:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201812:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201816:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020181a:	02d86463          	bltu	a6,a3,ffffffffc0201842 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020181e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201822:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201826:	0186873b          	addw	a4,a3,s8
ffffffffc020182a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020182e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201830:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201834:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201836:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020183a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020183e:	fed870e3          	bgeu	a6,a3,ffffffffc020181e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201842:	f40ddce3          	bgez	s11,ffffffffc020179a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201846:	8de2                	mv	s11,s8
ffffffffc0201848:	5c7d                	li	s8,-1
ffffffffc020184a:	bf81                	j	ffffffffc020179a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020184c:	fffdc693          	not	a3,s11
ffffffffc0201850:	96fd                	srai	a3,a3,0x3f
ffffffffc0201852:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201856:	00144603          	lbu	a2,1(s0)
ffffffffc020185a:	2d81                	sext.w	s11,s11
ffffffffc020185c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020185e:	bf35                	j	ffffffffc020179a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201860:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201864:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201868:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020186c:	bfd9                	j	ffffffffc0201842 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020186e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201870:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201874:	01174463          	blt	a4,a7,ffffffffc020187c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201878:	1a088e63          	beqz	a7,ffffffffc0201a34 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020187c:	000a3603          	ld	a2,0(s4)
ffffffffc0201880:	46c1                	li	a3,16
ffffffffc0201882:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201884:	2781                	sext.w	a5,a5
ffffffffc0201886:	876e                	mv	a4,s11
ffffffffc0201888:	85a6                	mv	a1,s1
ffffffffc020188a:	854a                	mv	a0,s2
ffffffffc020188c:	e37ff0ef          	jal	ra,ffffffffc02016c2 <printnum>
            break;
ffffffffc0201890:	bde1                	j	ffffffffc0201768 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201892:	000a2503          	lw	a0,0(s4)
ffffffffc0201896:	85a6                	mv	a1,s1
ffffffffc0201898:	0a21                	addi	s4,s4,8
ffffffffc020189a:	9902                	jalr	s2
            break;
ffffffffc020189c:	b5f1                	j	ffffffffc0201768 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020189e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02018a4:	01174463          	blt	a4,a7,ffffffffc02018ac <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02018a8:	18088163          	beqz	a7,ffffffffc0201a2a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02018ac:	000a3603          	ld	a2,0(s4)
ffffffffc02018b0:	46a9                	li	a3,10
ffffffffc02018b2:	8a2e                	mv	s4,a1
ffffffffc02018b4:	bfc1                	j	ffffffffc0201884 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018b6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02018ba:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018bc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018be:	bdf1                	j	ffffffffc020179a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02018c0:	85a6                	mv	a1,s1
ffffffffc02018c2:	02500513          	li	a0,37
ffffffffc02018c6:	9902                	jalr	s2
            break;
ffffffffc02018c8:	b545                	j	ffffffffc0201768 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018ca:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02018ce:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018d0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018d2:	b5e1                	j	ffffffffc020179a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02018d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018d6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02018da:	01174463          	blt	a4,a7,ffffffffc02018e2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02018de:	14088163          	beqz	a7,ffffffffc0201a20 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02018e2:	000a3603          	ld	a2,0(s4)
ffffffffc02018e6:	46a1                	li	a3,8
ffffffffc02018e8:	8a2e                	mv	s4,a1
ffffffffc02018ea:	bf69                	j	ffffffffc0201884 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02018ec:	03000513          	li	a0,48
ffffffffc02018f0:	85a6                	mv	a1,s1
ffffffffc02018f2:	e03e                	sd	a5,0(sp)
ffffffffc02018f4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02018f6:	85a6                	mv	a1,s1
ffffffffc02018f8:	07800513          	li	a0,120
ffffffffc02018fc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018fe:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201900:	6782                	ld	a5,0(sp)
ffffffffc0201902:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201904:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201908:	bfb5                	j	ffffffffc0201884 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020190a:	000a3403          	ld	s0,0(s4)
ffffffffc020190e:	008a0713          	addi	a4,s4,8
ffffffffc0201912:	e03a                	sd	a4,0(sp)
ffffffffc0201914:	14040263          	beqz	s0,ffffffffc0201a58 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201918:	0fb05763          	blez	s11,ffffffffc0201a06 <vprintfmt+0x2d8>
ffffffffc020191c:	02d00693          	li	a3,45
ffffffffc0201920:	0cd79163          	bne	a5,a3,ffffffffc02019e2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201924:	00044783          	lbu	a5,0(s0)
ffffffffc0201928:	0007851b          	sext.w	a0,a5
ffffffffc020192c:	cf85                	beqz	a5,ffffffffc0201964 <vprintfmt+0x236>
ffffffffc020192e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201932:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201936:	000c4563          	bltz	s8,ffffffffc0201940 <vprintfmt+0x212>
ffffffffc020193a:	3c7d                	addiw	s8,s8,-1
ffffffffc020193c:	036c0263          	beq	s8,s6,ffffffffc0201960 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201940:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201942:	0e0c8e63          	beqz	s9,ffffffffc0201a3e <vprintfmt+0x310>
ffffffffc0201946:	3781                	addiw	a5,a5,-32
ffffffffc0201948:	0ef47b63          	bgeu	s0,a5,ffffffffc0201a3e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020194c:	03f00513          	li	a0,63
ffffffffc0201950:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201952:	000a4783          	lbu	a5,0(s4)
ffffffffc0201956:	3dfd                	addiw	s11,s11,-1
ffffffffc0201958:	0a05                	addi	s4,s4,1
ffffffffc020195a:	0007851b          	sext.w	a0,a5
ffffffffc020195e:	ffe1                	bnez	a5,ffffffffc0201936 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201960:	01b05963          	blez	s11,ffffffffc0201972 <vprintfmt+0x244>
ffffffffc0201964:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201966:	85a6                	mv	a1,s1
ffffffffc0201968:	02000513          	li	a0,32
ffffffffc020196c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020196e:	fe0d9be3          	bnez	s11,ffffffffc0201964 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201972:	6a02                	ld	s4,0(sp)
ffffffffc0201974:	bbd5                	j	ffffffffc0201768 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201976:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201978:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020197c:	01174463          	blt	a4,a7,ffffffffc0201984 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201980:	08088d63          	beqz	a7,ffffffffc0201a1a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201984:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201988:	0a044d63          	bltz	s0,ffffffffc0201a42 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020198c:	8622                	mv	a2,s0
ffffffffc020198e:	8a66                	mv	s4,s9
ffffffffc0201990:	46a9                	li	a3,10
ffffffffc0201992:	bdcd                	j	ffffffffc0201884 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201994:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201998:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020199a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020199c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02019a0:	8fb5                	xor	a5,a5,a3
ffffffffc02019a2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019a6:	02d74163          	blt	a4,a3,ffffffffc02019c8 <vprintfmt+0x29a>
ffffffffc02019aa:	00369793          	slli	a5,a3,0x3
ffffffffc02019ae:	97de                	add	a5,a5,s7
ffffffffc02019b0:	639c                	ld	a5,0(a5)
ffffffffc02019b2:	cb99                	beqz	a5,ffffffffc02019c8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02019b4:	86be                	mv	a3,a5
ffffffffc02019b6:	00001617          	auipc	a2,0x1
ffffffffc02019ba:	e1a60613          	addi	a2,a2,-486 # ffffffffc02027d0 <buddy_pmm_manager+0x190>
ffffffffc02019be:	85a6                	mv	a1,s1
ffffffffc02019c0:	854a                	mv	a0,s2
ffffffffc02019c2:	0ce000ef          	jal	ra,ffffffffc0201a90 <printfmt>
ffffffffc02019c6:	b34d                	j	ffffffffc0201768 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02019c8:	00001617          	auipc	a2,0x1
ffffffffc02019cc:	df860613          	addi	a2,a2,-520 # ffffffffc02027c0 <buddy_pmm_manager+0x180>
ffffffffc02019d0:	85a6                	mv	a1,s1
ffffffffc02019d2:	854a                	mv	a0,s2
ffffffffc02019d4:	0bc000ef          	jal	ra,ffffffffc0201a90 <printfmt>
ffffffffc02019d8:	bb41                	j	ffffffffc0201768 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02019da:	00001417          	auipc	s0,0x1
ffffffffc02019de:	dde40413          	addi	s0,s0,-546 # ffffffffc02027b8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019e2:	85e2                	mv	a1,s8
ffffffffc02019e4:	8522                	mv	a0,s0
ffffffffc02019e6:	e43e                	sd	a5,8(sp)
ffffffffc02019e8:	1cc000ef          	jal	ra,ffffffffc0201bb4 <strnlen>
ffffffffc02019ec:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019f0:	01b05b63          	blez	s11,ffffffffc0201a06 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02019f4:	67a2                	ld	a5,8(sp)
ffffffffc02019f6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019fa:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019fc:	85a6                	mv	a1,s1
ffffffffc02019fe:	8552                	mv	a0,s4
ffffffffc0201a00:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a02:	fe0d9ce3          	bnez	s11,ffffffffc02019fa <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a06:	00044783          	lbu	a5,0(s0)
ffffffffc0201a0a:	00140a13          	addi	s4,s0,1
ffffffffc0201a0e:	0007851b          	sext.w	a0,a5
ffffffffc0201a12:	d3a5                	beqz	a5,ffffffffc0201972 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a14:	05e00413          	li	s0,94
ffffffffc0201a18:	bf39                	j	ffffffffc0201936 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201a1a:	000a2403          	lw	s0,0(s4)
ffffffffc0201a1e:	b7ad                	j	ffffffffc0201988 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201a20:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a24:	46a1                	li	a3,8
ffffffffc0201a26:	8a2e                	mv	s4,a1
ffffffffc0201a28:	bdb1                	j	ffffffffc0201884 <vprintfmt+0x156>
ffffffffc0201a2a:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a2e:	46a9                	li	a3,10
ffffffffc0201a30:	8a2e                	mv	s4,a1
ffffffffc0201a32:	bd89                	j	ffffffffc0201884 <vprintfmt+0x156>
ffffffffc0201a34:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a38:	46c1                	li	a3,16
ffffffffc0201a3a:	8a2e                	mv	s4,a1
ffffffffc0201a3c:	b5a1                	j	ffffffffc0201884 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201a3e:	9902                	jalr	s2
ffffffffc0201a40:	bf09                	j	ffffffffc0201952 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201a42:	85a6                	mv	a1,s1
ffffffffc0201a44:	02d00513          	li	a0,45
ffffffffc0201a48:	e03e                	sd	a5,0(sp)
ffffffffc0201a4a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a4c:	6782                	ld	a5,0(sp)
ffffffffc0201a4e:	8a66                	mv	s4,s9
ffffffffc0201a50:	40800633          	neg	a2,s0
ffffffffc0201a54:	46a9                	li	a3,10
ffffffffc0201a56:	b53d                	j	ffffffffc0201884 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201a58:	03b05163          	blez	s11,ffffffffc0201a7a <vprintfmt+0x34c>
ffffffffc0201a5c:	02d00693          	li	a3,45
ffffffffc0201a60:	f6d79de3          	bne	a5,a3,ffffffffc02019da <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201a64:	00001417          	auipc	s0,0x1
ffffffffc0201a68:	d5440413          	addi	s0,s0,-684 # ffffffffc02027b8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a6c:	02800793          	li	a5,40
ffffffffc0201a70:	02800513          	li	a0,40
ffffffffc0201a74:	00140a13          	addi	s4,s0,1
ffffffffc0201a78:	bd6d                	j	ffffffffc0201932 <vprintfmt+0x204>
ffffffffc0201a7a:	00001a17          	auipc	s4,0x1
ffffffffc0201a7e:	d3fa0a13          	addi	s4,s4,-705 # ffffffffc02027b9 <buddy_pmm_manager+0x179>
ffffffffc0201a82:	02800513          	li	a0,40
ffffffffc0201a86:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a8a:	05e00413          	li	s0,94
ffffffffc0201a8e:	b565                	j	ffffffffc0201936 <vprintfmt+0x208>

ffffffffc0201a90 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a90:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a92:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a96:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a98:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a9a:	ec06                	sd	ra,24(sp)
ffffffffc0201a9c:	f83a                	sd	a4,48(sp)
ffffffffc0201a9e:	fc3e                	sd	a5,56(sp)
ffffffffc0201aa0:	e0c2                	sd	a6,64(sp)
ffffffffc0201aa2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201aa4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201aa6:	c89ff0ef          	jal	ra,ffffffffc020172e <vprintfmt>
}
ffffffffc0201aaa:	60e2                	ld	ra,24(sp)
ffffffffc0201aac:	6161                	addi	sp,sp,80
ffffffffc0201aae:	8082                	ret

ffffffffc0201ab0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201ab0:	715d                	addi	sp,sp,-80
ffffffffc0201ab2:	e486                	sd	ra,72(sp)
ffffffffc0201ab4:	e0a6                	sd	s1,64(sp)
ffffffffc0201ab6:	fc4a                	sd	s2,56(sp)
ffffffffc0201ab8:	f84e                	sd	s3,48(sp)
ffffffffc0201aba:	f452                	sd	s4,40(sp)
ffffffffc0201abc:	f056                	sd	s5,32(sp)
ffffffffc0201abe:	ec5a                	sd	s6,24(sp)
ffffffffc0201ac0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201ac2:	c901                	beqz	a0,ffffffffc0201ad2 <readline+0x22>
ffffffffc0201ac4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201ac6:	00001517          	auipc	a0,0x1
ffffffffc0201aca:	d0a50513          	addi	a0,a0,-758 # ffffffffc02027d0 <buddy_pmm_manager+0x190>
ffffffffc0201ace:	de4fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201ad2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ad4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201ad6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201ad8:	4aa9                	li	s5,10
ffffffffc0201ada:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201adc:	00004b97          	auipc	s7,0x4
ffffffffc0201ae0:	54cb8b93          	addi	s7,s7,1356 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ae4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201ae8:	e42fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201aec:	00054a63          	bltz	a0,ffffffffc0201b00 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201af0:	00a95a63          	bge	s2,a0,ffffffffc0201b04 <readline+0x54>
ffffffffc0201af4:	029a5263          	bge	s4,s1,ffffffffc0201b18 <readline+0x68>
        c = getchar();
ffffffffc0201af8:	e32fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201afc:	fe055ae3          	bgez	a0,ffffffffc0201af0 <readline+0x40>
            return NULL;
ffffffffc0201b00:	4501                	li	a0,0
ffffffffc0201b02:	a091                	j	ffffffffc0201b46 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201b04:	03351463          	bne	a0,s3,ffffffffc0201b2c <readline+0x7c>
ffffffffc0201b08:	e8a9                	bnez	s1,ffffffffc0201b5a <readline+0xaa>
        c = getchar();
ffffffffc0201b0a:	e20fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201b0e:	fe0549e3          	bltz	a0,ffffffffc0201b00 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201b12:	fea959e3          	bge	s2,a0,ffffffffc0201b04 <readline+0x54>
ffffffffc0201b16:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201b18:	e42a                	sd	a0,8(sp)
ffffffffc0201b1a:	dcefe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201b1e:	6522                	ld	a0,8(sp)
ffffffffc0201b20:	009b87b3          	add	a5,s7,s1
ffffffffc0201b24:	2485                	addiw	s1,s1,1
ffffffffc0201b26:	00a78023          	sb	a0,0(a5)
ffffffffc0201b2a:	bf7d                	j	ffffffffc0201ae8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201b2c:	01550463          	beq	a0,s5,ffffffffc0201b34 <readline+0x84>
ffffffffc0201b30:	fb651ce3          	bne	a0,s6,ffffffffc0201ae8 <readline+0x38>
            cputchar(c);
ffffffffc0201b34:	db4fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201b38:	00004517          	auipc	a0,0x4
ffffffffc0201b3c:	4f050513          	addi	a0,a0,1264 # ffffffffc0206028 <buf>
ffffffffc0201b40:	94aa                	add	s1,s1,a0
ffffffffc0201b42:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201b46:	60a6                	ld	ra,72(sp)
ffffffffc0201b48:	6486                	ld	s1,64(sp)
ffffffffc0201b4a:	7962                	ld	s2,56(sp)
ffffffffc0201b4c:	79c2                	ld	s3,48(sp)
ffffffffc0201b4e:	7a22                	ld	s4,40(sp)
ffffffffc0201b50:	7a82                	ld	s5,32(sp)
ffffffffc0201b52:	6b62                	ld	s6,24(sp)
ffffffffc0201b54:	6bc2                	ld	s7,16(sp)
ffffffffc0201b56:	6161                	addi	sp,sp,80
ffffffffc0201b58:	8082                	ret
            cputchar(c);
ffffffffc0201b5a:	4521                	li	a0,8
ffffffffc0201b5c:	d8cfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201b60:	34fd                	addiw	s1,s1,-1
ffffffffc0201b62:	b759                	j	ffffffffc0201ae8 <readline+0x38>

ffffffffc0201b64 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201b64:	4781                	li	a5,0
ffffffffc0201b66:	00004717          	auipc	a4,0x4
ffffffffc0201b6a:	4a273703          	ld	a4,1186(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201b6e:	88ba                	mv	a7,a4
ffffffffc0201b70:	852a                	mv	a0,a0
ffffffffc0201b72:	85be                	mv	a1,a5
ffffffffc0201b74:	863e                	mv	a2,a5
ffffffffc0201b76:	00000073          	ecall
ffffffffc0201b7a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201b7c:	8082                	ret

ffffffffc0201b7e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201b7e:	4781                	li	a5,0
ffffffffc0201b80:	00005717          	auipc	a4,0x5
ffffffffc0201b84:	92073703          	ld	a4,-1760(a4) # ffffffffc02064a0 <SBI_SET_TIMER>
ffffffffc0201b88:	88ba                	mv	a7,a4
ffffffffc0201b8a:	852a                	mv	a0,a0
ffffffffc0201b8c:	85be                	mv	a1,a5
ffffffffc0201b8e:	863e                	mv	a2,a5
ffffffffc0201b90:	00000073          	ecall
ffffffffc0201b94:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201b96:	8082                	ret

ffffffffc0201b98 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201b98:	4501                	li	a0,0
ffffffffc0201b9a:	00004797          	auipc	a5,0x4
ffffffffc0201b9e:	4667b783          	ld	a5,1126(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201ba2:	88be                	mv	a7,a5
ffffffffc0201ba4:	852a                	mv	a0,a0
ffffffffc0201ba6:	85aa                	mv	a1,a0
ffffffffc0201ba8:	862a                	mv	a2,a0
ffffffffc0201baa:	00000073          	ecall
ffffffffc0201bae:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201bb0:	2501                	sext.w	a0,a0
ffffffffc0201bb2:	8082                	ret

ffffffffc0201bb4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201bb4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201bb6:	e589                	bnez	a1,ffffffffc0201bc0 <strnlen+0xc>
ffffffffc0201bb8:	a811                	j	ffffffffc0201bcc <strnlen+0x18>
        cnt ++;
ffffffffc0201bba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201bbc:	00f58863          	beq	a1,a5,ffffffffc0201bcc <strnlen+0x18>
ffffffffc0201bc0:	00f50733          	add	a4,a0,a5
ffffffffc0201bc4:	00074703          	lbu	a4,0(a4)
ffffffffc0201bc8:	fb6d                	bnez	a4,ffffffffc0201bba <strnlen+0x6>
ffffffffc0201bca:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201bcc:	852e                	mv	a0,a1
ffffffffc0201bce:	8082                	ret

ffffffffc0201bd0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bd0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201bd4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bd8:	cb89                	beqz	a5,ffffffffc0201bea <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201bda:	0505                	addi	a0,a0,1
ffffffffc0201bdc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bde:	fee789e3          	beq	a5,a4,ffffffffc0201bd0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201be2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201be6:	9d19                	subw	a0,a0,a4
ffffffffc0201be8:	8082                	ret
ffffffffc0201bea:	4501                	li	a0,0
ffffffffc0201bec:	bfed                	j	ffffffffc0201be6 <strcmp+0x16>

ffffffffc0201bee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201bee:	00054783          	lbu	a5,0(a0)
ffffffffc0201bf2:	c799                	beqz	a5,ffffffffc0201c00 <strchr+0x12>
        if (*s == c) {
ffffffffc0201bf4:	00f58763          	beq	a1,a5,ffffffffc0201c02 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201bf8:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201bfc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201bfe:	fbfd                	bnez	a5,ffffffffc0201bf4 <strchr+0x6>
    }
    return NULL;
ffffffffc0201c00:	4501                	li	a0,0
}
ffffffffc0201c02:	8082                	ret

ffffffffc0201c04 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201c04:	ca01                	beqz	a2,ffffffffc0201c14 <memset+0x10>
ffffffffc0201c06:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201c08:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201c0a:	0785                	addi	a5,a5,1
ffffffffc0201c0c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201c10:	fec79de3          	bne	a5,a2,ffffffffc0201c0a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201c14:	8082                	ret
