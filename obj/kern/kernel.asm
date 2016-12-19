
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 12 00       	mov    $0x123000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 30 12 f0       	mov    $0xf0123000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 8c de 2b f0 00 	cmpl   $0x0,0xf02bde8c
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 8c de 2b f0    	mov    %esi,0xf02bde8c

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 35 69 00 00       	call   f0106999 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 7b 10 f0 	movl   $0xf0107ba0,(%esp)
f010007d:	e8 07 42 00 00       	call   f0104289 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 c8 41 00 00       	call   f0104256 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f0100095:	e8 ef 41 00 00       	call   f0104289 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 4c 0d 00 00       	call   f0100df2 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000af:	b8 00 40 36 f0       	mov    $0xf0364000,%eax
f01000b4:	2d 3a ca 2b f0       	sub    $0xf02bca3a,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 3a ca 2b f0 	movl   $0xf02bca3a,(%esp)
f01000cc:	e8 76 62 00 00       	call   f0106347 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 e9 05 00 00       	call   f01006bf <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 0c 7c 10 f0 	movl   $0xf0107c0c,(%esp)
f01000e5:	e8 9f 41 00 00       	call   f0104289 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 b9 17 00 00       	call   f01018a8 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 cc 39 00 00       	call   f0103ac0 <env_init>
	trap_init();
f01000f4:	e8 96 42 00 00       	call   f010438f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 8c 65 00 00       	call   f010668a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 af 68 00 00       	call   f01069b4 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 9c 40 00 00       	call   f01041a6 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f010010a:	e8 a2 77 00 00       	call   f01078b1 <time_init>
	pci_init();
f010010f:	90                   	nop
f0100110:	e8 6e 77 00 00       	call   f0107883 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100115:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f010011c:	e8 f6 6a 00 00       	call   f0106c17 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100121:	83 3d 94 de 2b f0 07 	cmpl   $0x7,0xf02bde94
f0100128:	77 24                	ja     f010014e <i386_init+0xa6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010012a:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100131:	00 
f0100132:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0100139:	f0 
f010013a:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 27 7c 10 f0 	movl   $0xf0107c27,(%esp)
f0100149:	e8 f2 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010014e:	b8 c2 65 10 f0       	mov    $0xf01065c2,%eax
f0100153:	2d 48 65 10 f0       	sub    $0xf0106548,%eax
f0100158:	89 44 24 08          	mov    %eax,0x8(%esp)
f010015c:	c7 44 24 04 48 65 10 	movl   $0xf0106548,0x4(%esp)
f0100163:	f0 
f0100164:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f010016b:	e8 24 62 00 00       	call   f0106394 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100170:	bb 20 f0 2b f0       	mov    $0xf02bf020,%ebx
f0100175:	eb 4d                	jmp    f01001c4 <i386_init+0x11c>
		if (c == cpus + cpunum())  // We've started already.
f0100177:	e8 1d 68 00 00       	call   f0106999 <cpunum>
f010017c:	6b c0 74             	imul   $0x74,%eax,%eax
f010017f:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	74 39                	je     f01001c1 <i386_init+0x119>
f0100188:	89 d8                	mov    %ebx,%eax
f010018a:	2d 20 f0 2b f0       	sub    $0xf02bf020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010018f:	c1 f8 02             	sar    $0x2,%eax
f0100192:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100198:	c1 e0 0f             	shl    $0xf,%eax
f010019b:	8d 80 00 80 2c f0    	lea    -0xfd38000(%eax),%eax
f01001a1:	a3 90 de 2b f0       	mov    %eax,0xf02bde90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001a6:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001ad:	00 
f01001ae:	0f b6 03             	movzbl (%ebx),%eax
f01001b1:	89 04 24             	mov    %eax,(%esp)
f01001b4:	e8 4b 69 00 00       	call   f0106b04 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001b9:	8b 43 04             	mov    0x4(%ebx),%eax
f01001bc:	83 f8 01             	cmp    $0x1,%eax
f01001bf:	75 f8                	jne    f01001b9 <i386_init+0x111>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c1:	83 c3 74             	add    $0x74,%ebx
f01001c4:	6b 05 c4 f3 2b f0 74 	imul   $0x74,0xf02bf3c4,%eax
f01001cb:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
f01001d0:	39 c3                	cmp    %eax,%ebx
f01001d2:	72 a3                	jb     f0100177 <i386_init+0xcf>
	lock_kernel();
	boot_aps();
	//unlock_kernel();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01001db:	00 
f01001dc:	c7 04 24 e0 42 1e f0 	movl   $0xf01e42e0,(%esp)
f01001e3:	e8 a0 3a 00 00       	call   f0103c88 <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001e8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01001ef:	00 
f01001f0:	c7 04 24 d8 ef 23 f0 	movl   $0xf023efd8,(%esp)
f01001f7:	e8 8c 3a 00 00       	call   f0103c88 <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100203:	00 
f0100204:	c7 04 24 73 4d 20 f0 	movl   $0xf0204d73,(%esp)
f010020b:	e8 78 3a 00 00       	call   f0103c88 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100210:	e8 4e 04 00 00       	call   f0100663 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100215:	e8 94 4d 00 00       	call   f0104fae <sched_yield>

f010021a <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010021a:	55                   	push   %ebp
f010021b:	89 e5                	mov    %esp,%ebp
f010021d:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100220:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100225:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010022a:	77 20                	ja     f010024c <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010022c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100230:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0100237:	f0 
f0100238:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
f010023f:	00 
f0100240:	c7 04 24 27 7c 10 f0 	movl   $0xf0107c27,(%esp)
f0100247:	e8 f4 fd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010024c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100251:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100254:	e8 40 67 00 00       	call   f0106999 <cpunum>
f0100259:	89 44 24 04          	mov    %eax,0x4(%esp)
f010025d:	c7 04 24 33 7c 10 f0 	movl   $0xf0107c33,(%esp)
f0100264:	e8 20 40 00 00       	call   f0104289 <cprintf>

	lapic_init();
f0100269:	e8 46 67 00 00       	call   f01069b4 <lapic_init>
	env_init_percpu();
f010026e:	e8 23 38 00 00       	call   f0103a96 <env_init_percpu>
	trap_init_percpu();
f0100273:	e8 38 40 00 00       	call   f01042b0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100278:	e8 1c 67 00 00       	call   f0106999 <cpunum>
f010027d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100280:	81 c2 20 f0 2b f0    	add    $0xf02bf020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100286:	b8 01 00 00 00       	mov    $0x1,%eax
f010028b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010028f:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f0100296:	e8 7c 69 00 00       	call   f0106c17 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f010029b:	e8 0e 4d 00 00       	call   f0104fae <sched_yield>

f01002a0 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002a7:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b8:	c7 04 24 49 7c 10 f0 	movl   $0xf0107c49,(%esp)
f01002bf:	e8 c5 3f 00 00       	call   f0104289 <cprintf>
	vcprintf(fmt, ap);
f01002c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002c8:	8b 45 10             	mov    0x10(%ebp),%eax
f01002cb:	89 04 24             	mov    %eax,(%esp)
f01002ce:	e8 83 3f 00 00       	call   f0104256 <vcprintf>
	cprintf("\n");
f01002d3:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f01002da:	e8 aa 3f 00 00       	call   f0104289 <cprintf>
	va_end(ap);
}
f01002df:	83 c4 14             	add    $0x14,%esp
f01002e2:	5b                   	pop    %ebx
f01002e3:	5d                   	pop    %ebp
f01002e4:	c3                   	ret    
f01002e5:	66 90                	xchg   %ax,%ax
f01002e7:	66 90                	xchg   %ax,%ax
f01002e9:	66 90                	xchg   %ax,%ax
f01002eb:	66 90                	xchg   %ax,%ax
f01002ed:	66 90                	xchg   %ax,%ax
f01002ef:	90                   	nop

f01002f0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002f8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002f9:	a8 01                	test   $0x1,%al
f01002fb:	74 08                	je     f0100305 <serial_proc_data+0x15>
f01002fd:	b2 f8                	mov    $0xf8,%dl
f01002ff:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100300:	0f b6 c0             	movzbl %al,%eax
f0100303:	eb 05                	jmp    f010030a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010030a:	5d                   	pop    %ebp
f010030b:	c3                   	ret    

f010030c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030c:	55                   	push   %ebp
f010030d:	89 e5                	mov    %esp,%ebp
f010030f:	53                   	push   %ebx
f0100310:	83 ec 04             	sub    $0x4,%esp
f0100313:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100315:	eb 2a                	jmp    f0100341 <cons_intr+0x35>
		if (c == 0)
f0100317:	85 d2                	test   %edx,%edx
f0100319:	74 26                	je     f0100341 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010031b:	a1 24 d2 2b f0       	mov    0xf02bd224,%eax
f0100320:	8d 48 01             	lea    0x1(%eax),%ecx
f0100323:	89 0d 24 d2 2b f0    	mov    %ecx,0xf02bd224
f0100329:	88 90 20 d0 2b f0    	mov    %dl,-0xfd42fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010032f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100335:	75 0a                	jne    f0100341 <cons_intr+0x35>
			cons.wpos = 0;
f0100337:	c7 05 24 d2 2b f0 00 	movl   $0x0,0xf02bd224
f010033e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100341:	ff d3                	call   *%ebx
f0100343:	89 c2                	mov    %eax,%edx
f0100345:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100348:	75 cd                	jne    f0100317 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010034a:	83 c4 04             	add    $0x4,%esp
f010034d:	5b                   	pop    %ebx
f010034e:	5d                   	pop    %ebp
f010034f:	c3                   	ret    

f0100350 <kbd_proc_data>:
f0100350:	ba 64 00 00 00       	mov    $0x64,%edx
f0100355:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100356:	a8 01                	test   $0x1,%al
f0100358:	0f 84 f7 00 00 00    	je     f0100455 <kbd_proc_data+0x105>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010035e:	a8 20                	test   $0x20,%al
f0100360:	0f 85 f5 00 00 00    	jne    f010045b <kbd_proc_data+0x10b>
f0100366:	b2 60                	mov    $0x60,%dl
f0100368:	ec                   	in     (%dx),%al
f0100369:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010036b:	3c e0                	cmp    $0xe0,%al
f010036d:	75 0d                	jne    f010037c <kbd_proc_data+0x2c>
		// E0 escape character
		shift |= E0ESC;
f010036f:	83 0d 00 d0 2b f0 40 	orl    $0x40,0xf02bd000
		return 0;
f0100376:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010037b:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010037c:	55                   	push   %ebp
f010037d:	89 e5                	mov    %esp,%ebp
f010037f:	53                   	push   %ebx
f0100380:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100383:	84 c0                	test   %al,%al
f0100385:	79 37                	jns    f01003be <kbd_proc_data+0x6e>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100387:	8b 0d 00 d0 2b f0    	mov    0xf02bd000,%ecx
f010038d:	89 cb                	mov    %ecx,%ebx
f010038f:	83 e3 40             	and    $0x40,%ebx
f0100392:	83 e0 7f             	and    $0x7f,%eax
f0100395:	85 db                	test   %ebx,%ebx
f0100397:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010039a:	0f b6 d2             	movzbl %dl,%edx
f010039d:	0f b6 82 c0 7d 10 f0 	movzbl -0xfef8240(%edx),%eax
f01003a4:	83 c8 40             	or     $0x40,%eax
f01003a7:	0f b6 c0             	movzbl %al,%eax
f01003aa:	f7 d0                	not    %eax
f01003ac:	21 c1                	and    %eax,%ecx
f01003ae:	89 0d 00 d0 2b f0    	mov    %ecx,0xf02bd000
		return 0;
f01003b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01003b9:	e9 a3 00 00 00       	jmp    f0100461 <kbd_proc_data+0x111>
	} else if (shift & E0ESC) {
f01003be:	8b 0d 00 d0 2b f0    	mov    0xf02bd000,%ecx
f01003c4:	f6 c1 40             	test   $0x40,%cl
f01003c7:	74 0e                	je     f01003d7 <kbd_proc_data+0x87>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c9:	83 c8 80             	or     $0xffffff80,%eax
f01003cc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003ce:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003d1:	89 0d 00 d0 2b f0    	mov    %ecx,0xf02bd000
	}

	shift |= shiftcode[data];
f01003d7:	0f b6 d2             	movzbl %dl,%edx
f01003da:	0f b6 82 c0 7d 10 f0 	movzbl -0xfef8240(%edx),%eax
f01003e1:	0b 05 00 d0 2b f0    	or     0xf02bd000,%eax
	shift ^= togglecode[data];
f01003e7:	0f b6 8a c0 7c 10 f0 	movzbl -0xfef8340(%edx),%ecx
f01003ee:	31 c8                	xor    %ecx,%eax
f01003f0:	a3 00 d0 2b f0       	mov    %eax,0xf02bd000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f5:	89 c1                	mov    %eax,%ecx
f01003f7:	83 e1 03             	and    $0x3,%ecx
f01003fa:	8b 0c 8d a0 7c 10 f0 	mov    -0xfef8360(,%ecx,4),%ecx
f0100401:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100405:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100408:	a8 08                	test   $0x8,%al
f010040a:	74 1b                	je     f0100427 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f010040c:	89 da                	mov    %ebx,%edx
f010040e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100411:	83 f9 19             	cmp    $0x19,%ecx
f0100414:	77 05                	ja     f010041b <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f0100416:	83 eb 20             	sub    $0x20,%ebx
f0100419:	eb 0c                	jmp    f0100427 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f010041b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010041e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100421:	83 fa 19             	cmp    $0x19,%edx
f0100424:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100427:	f7 d0                	not    %eax
f0100429:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010042b:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010042d:	f6 c2 06             	test   $0x6,%dl
f0100430:	75 2f                	jne    f0100461 <kbd_proc_data+0x111>
f0100432:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100438:	75 27                	jne    f0100461 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f010043a:	c7 04 24 63 7c 10 f0 	movl   $0xf0107c63,(%esp)
f0100441:	e8 43 3e 00 00       	call   f0104289 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 92 00 00 00       	mov    $0x92,%edx
f010044b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100450:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100451:	89 d8                	mov    %ebx,%eax
f0100453:	eb 0c                	jmp    f0100461 <kbd_proc_data+0x111>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010045a:	c3                   	ret    
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010045b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100460:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100461:	83 c4 14             	add    $0x14,%esp
f0100464:	5b                   	pop    %ebx
f0100465:	5d                   	pop    %ebp
f0100466:	c3                   	ret    

f0100467 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100467:	55                   	push   %ebp
f0100468:	89 e5                	mov    %esp,%ebp
f010046a:	57                   	push   %edi
f010046b:	56                   	push   %esi
f010046c:	53                   	push   %ebx
f010046d:	83 ec 1c             	sub    $0x1c,%esp
f0100470:	89 c7                	mov    %eax,%edi
f0100472:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100477:	be fd 03 00 00       	mov    $0x3fd,%esi
f010047c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100481:	eb 06                	jmp    f0100489 <cons_putc+0x22>
f0100483:	89 ca                	mov    %ecx,%edx
f0100485:	ec                   	in     (%dx),%al
f0100486:	ec                   	in     (%dx),%al
f0100487:	ec                   	in     (%dx),%al
f0100488:	ec                   	in     (%dx),%al
f0100489:	89 f2                	mov    %esi,%edx
f010048b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010048c:	a8 20                	test   $0x20,%al
f010048e:	75 05                	jne    f0100495 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100490:	83 eb 01             	sub    $0x1,%ebx
f0100493:	75 ee                	jne    f0100483 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100495:	89 f8                	mov    %edi,%eax
f0100497:	0f b6 c0             	movzbl %al,%eax
f010049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004a2:	ee                   	out    %al,(%dx)
f01004a3:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004a8:	be 79 03 00 00       	mov    $0x379,%esi
f01004ad:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004b2:	eb 06                	jmp    f01004ba <cons_putc+0x53>
f01004b4:	89 ca                	mov    %ecx,%edx
f01004b6:	ec                   	in     (%dx),%al
f01004b7:	ec                   	in     (%dx),%al
f01004b8:	ec                   	in     (%dx),%al
f01004b9:	ec                   	in     (%dx),%al
f01004ba:	89 f2                	mov    %esi,%edx
f01004bc:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004bd:	84 c0                	test   %al,%al
f01004bf:	78 05                	js     f01004c6 <cons_putc+0x5f>
f01004c1:	83 eb 01             	sub    $0x1,%ebx
f01004c4:	75 ee                	jne    f01004b4 <cons_putc+0x4d>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c6:	ba 78 03 00 00       	mov    $0x378,%edx
f01004cb:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004cf:	ee                   	out    %al,(%dx)
f01004d0:	b2 7a                	mov    $0x7a,%dl
f01004d2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004d7:	ee                   	out    %al,(%dx)
f01004d8:	b8 08 00 00 00       	mov    $0x8,%eax
f01004dd:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004de:	89 fa                	mov    %edi,%edx
f01004e0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004e6:	89 f8                	mov    %edi,%eax
f01004e8:	80 cc 07             	or     $0x7,%ah
f01004eb:	85 d2                	test   %edx,%edx
f01004ed:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004f0:	89 f8                	mov    %edi,%eax
f01004f2:	0f b6 c0             	movzbl %al,%eax
f01004f5:	83 f8 09             	cmp    $0x9,%eax
f01004f8:	74 78                	je     f0100572 <cons_putc+0x10b>
f01004fa:	83 f8 09             	cmp    $0x9,%eax
f01004fd:	7f 0a                	jg     f0100509 <cons_putc+0xa2>
f01004ff:	83 f8 08             	cmp    $0x8,%eax
f0100502:	74 18                	je     f010051c <cons_putc+0xb5>
f0100504:	e9 9d 00 00 00       	jmp    f01005a6 <cons_putc+0x13f>
f0100509:	83 f8 0a             	cmp    $0xa,%eax
f010050c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100510:	74 3a                	je     f010054c <cons_putc+0xe5>
f0100512:	83 f8 0d             	cmp    $0xd,%eax
f0100515:	74 3d                	je     f0100554 <cons_putc+0xed>
f0100517:	e9 8a 00 00 00       	jmp    f01005a6 <cons_putc+0x13f>
	case '\b':
		if (crt_pos > 0) {
f010051c:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f0100523:	66 85 c0             	test   %ax,%ax
f0100526:	0f 84 e5 00 00 00    	je     f0100611 <cons_putc+0x1aa>
			crt_pos--;
f010052c:	83 e8 01             	sub    $0x1,%eax
f010052f:	66 a3 28 d2 2b f0    	mov    %ax,0xf02bd228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100535:	0f b7 c0             	movzwl %ax,%eax
f0100538:	66 81 e7 00 ff       	and    $0xff00,%di
f010053d:	83 cf 20             	or     $0x20,%edi
f0100540:	8b 15 2c d2 2b f0    	mov    0xf02bd22c,%edx
f0100546:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010054a:	eb 78                	jmp    f01005c4 <cons_putc+0x15d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010054c:	66 83 05 28 d2 2b f0 	addw   $0x50,0xf02bd228
f0100553:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100554:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f010055b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100561:	c1 e8 16             	shr    $0x16,%eax
f0100564:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100567:	c1 e0 04             	shl    $0x4,%eax
f010056a:	66 a3 28 d2 2b f0    	mov    %ax,0xf02bd228
f0100570:	eb 52                	jmp    f01005c4 <cons_putc+0x15d>
		break;
	case '\t':
		cons_putc(' ');
f0100572:	b8 20 00 00 00       	mov    $0x20,%eax
f0100577:	e8 eb fe ff ff       	call   f0100467 <cons_putc>
		cons_putc(' ');
f010057c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100581:	e8 e1 fe ff ff       	call   f0100467 <cons_putc>
		cons_putc(' ');
f0100586:	b8 20 00 00 00       	mov    $0x20,%eax
f010058b:	e8 d7 fe ff ff       	call   f0100467 <cons_putc>
		cons_putc(' ');
f0100590:	b8 20 00 00 00       	mov    $0x20,%eax
f0100595:	e8 cd fe ff ff       	call   f0100467 <cons_putc>
		cons_putc(' ');
f010059a:	b8 20 00 00 00       	mov    $0x20,%eax
f010059f:	e8 c3 fe ff ff       	call   f0100467 <cons_putc>
f01005a4:	eb 1e                	jmp    f01005c4 <cons_putc+0x15d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005a6:	0f b7 05 28 d2 2b f0 	movzwl 0xf02bd228,%eax
f01005ad:	8d 50 01             	lea    0x1(%eax),%edx
f01005b0:	66 89 15 28 d2 2b f0 	mov    %dx,0xf02bd228
f01005b7:	0f b7 c0             	movzwl %ax,%eax
f01005ba:	8b 15 2c d2 2b f0    	mov    0xf02bd22c,%edx
f01005c0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005c4:	66 81 3d 28 d2 2b f0 	cmpw   $0x7cf,0xf02bd228
f01005cb:	cf 07 
f01005cd:	76 42                	jbe    f0100611 <cons_putc+0x1aa>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005cf:	a1 2c d2 2b f0       	mov    0xf02bd22c,%eax
f01005d4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005db:	00 
f01005dc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005e2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005e6:	89 04 24             	mov    %eax,(%esp)
f01005e9:	e8 a6 5d 00 00       	call   f0106394 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005ee:	8b 15 2c d2 2b f0    	mov    0xf02bd22c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005f9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ff:	83 c0 01             	add    $0x1,%eax
f0100602:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100607:	75 f0                	jne    f01005f9 <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100609:	66 83 2d 28 d2 2b f0 	subw   $0x50,0xf02bd228
f0100610:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100611:	8b 0d 30 d2 2b f0    	mov    0xf02bd230,%ecx
f0100617:	b8 0e 00 00 00       	mov    $0xe,%eax
f010061c:	89 ca                	mov    %ecx,%edx
f010061e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010061f:	0f b7 1d 28 d2 2b f0 	movzwl 0xf02bd228,%ebx
f0100626:	8d 71 01             	lea    0x1(%ecx),%esi
f0100629:	89 d8                	mov    %ebx,%eax
f010062b:	66 c1 e8 08          	shr    $0x8,%ax
f010062f:	89 f2                	mov    %esi,%edx
f0100631:	ee                   	out    %al,(%dx)
f0100632:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100637:	89 ca                	mov    %ecx,%edx
f0100639:	ee                   	out    %al,(%dx)
f010063a:	89 d8                	mov    %ebx,%eax
f010063c:	89 f2                	mov    %esi,%edx
f010063e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010063f:	83 c4 1c             	add    $0x1c,%esp
f0100642:	5b                   	pop    %ebx
f0100643:	5e                   	pop    %esi
f0100644:	5f                   	pop    %edi
f0100645:	5d                   	pop    %ebp
f0100646:	c3                   	ret    

f0100647 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100647:	80 3d 34 d2 2b f0 00 	cmpb   $0x0,0xf02bd234
f010064e:	74 11                	je     f0100661 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100656:	b8 f0 02 10 f0       	mov    $0xf01002f0,%eax
f010065b:	e8 ac fc ff ff       	call   f010030c <cons_intr>
}
f0100660:	c9                   	leave  
f0100661:	f3 c3                	repz ret 

f0100663 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100669:	b8 50 03 10 f0       	mov    $0xf0100350,%eax
f010066e:	e8 99 fc ff ff       	call   f010030c <cons_intr>
}
f0100673:	c9                   	leave  
f0100674:	c3                   	ret    

f0100675 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100675:	55                   	push   %ebp
f0100676:	89 e5                	mov    %esp,%ebp
f0100678:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010067b:	e8 c7 ff ff ff       	call   f0100647 <serial_intr>
	kbd_intr();
f0100680:	e8 de ff ff ff       	call   f0100663 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100685:	a1 20 d2 2b f0       	mov    0xf02bd220,%eax
f010068a:	3b 05 24 d2 2b f0    	cmp    0xf02bd224,%eax
f0100690:	74 26                	je     f01006b8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100692:	8d 50 01             	lea    0x1(%eax),%edx
f0100695:	89 15 20 d2 2b f0    	mov    %edx,0xf02bd220
f010069b:	0f b6 88 20 d0 2b f0 	movzbl -0xfd42fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01006a2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01006a4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006aa:	75 11                	jne    f01006bd <cons_getc+0x48>
			cons.rpos = 0;
f01006ac:	c7 05 20 d2 2b f0 00 	movl   $0x0,0xf02bd220
f01006b3:	00 00 00 
f01006b6:	eb 05                	jmp    f01006bd <cons_getc+0x48>
		return c;
	}
	return 0;
f01006b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006bd:	c9                   	leave  
f01006be:	c3                   	ret    

f01006bf <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006bf:	55                   	push   %ebp
f01006c0:	89 e5                	mov    %esp,%ebp
f01006c2:	57                   	push   %edi
f01006c3:	56                   	push   %esi
f01006c4:	53                   	push   %ebx
f01006c5:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006c8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006cf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006d6:	5a a5 
	if (*cp != 0xA55A) {
f01006d8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006df:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006e3:	74 11                	je     f01006f6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006e5:	c7 05 30 d2 2b f0 b4 	movl   $0x3b4,0xf02bd230
f01006ec:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ef:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006f4:	eb 16                	jmp    f010070c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006f6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006fd:	c7 05 30 d2 2b f0 d4 	movl   $0x3d4,0xf02bd230
f0100704:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100707:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010070c:	8b 0d 30 d2 2b f0    	mov    0xf02bd230,%ecx
f0100712:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100717:	89 ca                	mov    %ecx,%edx
f0100719:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010071a:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	89 da                	mov    %ebx,%edx
f010071f:	ec                   	in     (%dx),%al
f0100720:	0f b6 f0             	movzbl %al,%esi
f0100723:	c1 e6 08             	shl    $0x8,%esi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100726:	b8 0f 00 00 00       	mov    $0xf,%eax
f010072b:	89 ca                	mov    %ecx,%edx
f010072d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072e:	89 da                	mov    %ebx,%edx
f0100730:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100731:	89 3d 2c d2 2b f0    	mov    %edi,0xf02bd22c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100737:	0f b6 d8             	movzbl %al,%ebx
f010073a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010073c:	66 89 35 28 d2 2b f0 	mov    %si,0xf02bd228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100743:	e8 1b ff ff ff       	call   f0100663 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100748:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f010074f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100754:	89 04 24             	mov    %eax,(%esp)
f0100757:	e8 db 39 00 00       	call   f0104137 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010075c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100761:	b8 00 00 00 00       	mov    $0x0,%eax
f0100766:	89 f2                	mov    %esi,%edx
f0100768:	ee                   	out    %al,(%dx)
f0100769:	b2 fb                	mov    $0xfb,%dl
f010076b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100770:	ee                   	out    %al,(%dx)
f0100771:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100776:	b8 0c 00 00 00       	mov    $0xc,%eax
f010077b:	89 da                	mov    %ebx,%edx
f010077d:	ee                   	out    %al,(%dx)
f010077e:	b2 f9                	mov    $0xf9,%dl
f0100780:	b8 00 00 00 00       	mov    $0x0,%eax
f0100785:	ee                   	out    %al,(%dx)
f0100786:	b2 fb                	mov    $0xfb,%dl
f0100788:	b8 03 00 00 00       	mov    $0x3,%eax
f010078d:	ee                   	out    %al,(%dx)
f010078e:	b2 fc                	mov    $0xfc,%dl
f0100790:	b8 00 00 00 00       	mov    $0x0,%eax
f0100795:	ee                   	out    %al,(%dx)
f0100796:	b2 f9                	mov    $0xf9,%dl
f0100798:	b8 01 00 00 00       	mov    $0x1,%eax
f010079d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010079e:	b2 fd                	mov    $0xfd,%dl
f01007a0:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007a1:	3c ff                	cmp    $0xff,%al
f01007a3:	0f 95 c1             	setne  %cl
f01007a6:	88 0d 34 d2 2b f0    	mov    %cl,0xf02bd234
f01007ac:	89 f2                	mov    %esi,%edx
f01007ae:	ec                   	in     (%dx),%al
f01007af:	89 da                	mov    %ebx,%edx
f01007b1:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f01007b2:	84 c9                	test   %cl,%cl
f01007b4:	74 1d                	je     f01007d3 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f01007b6:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f01007bd:	25 ef ff 00 00       	and    $0xffef,%eax
f01007c2:	89 04 24             	mov    %eax,(%esp)
f01007c5:	e8 6d 39 00 00       	call   f0104137 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007ca:	80 3d 34 d2 2b f0 00 	cmpb   $0x0,0xf02bd234
f01007d1:	75 0c                	jne    f01007df <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f01007d3:	c7 04 24 6f 7c 10 f0 	movl   $0xf0107c6f,(%esp)
f01007da:	e8 aa 3a 00 00       	call   f0104289 <cprintf>
}
f01007df:	83 c4 1c             	add    $0x1c,%esp
f01007e2:	5b                   	pop    %ebx
f01007e3:	5e                   	pop    %esi
f01007e4:	5f                   	pop    %edi
f01007e5:	5d                   	pop    %ebp
f01007e6:	c3                   	ret    

f01007e7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007e7:	55                   	push   %ebp
f01007e8:	89 e5                	mov    %esp,%ebp
f01007ea:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01007f0:	e8 72 fc ff ff       	call   f0100467 <cons_putc>
}
f01007f5:	c9                   	leave  
f01007f6:	c3                   	ret    

f01007f7 <getchar>:

int
getchar(void)
{
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
f01007fa:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007fd:	e8 73 fe ff ff       	call   f0100675 <cons_getc>
f0100802:	85 c0                	test   %eax,%eax
f0100804:	74 f7                	je     f01007fd <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100806:	c9                   	leave  
f0100807:	c3                   	ret    

f0100808 <iscons>:

int
iscons(int fdnum)
{
f0100808:	55                   	push   %ebp
f0100809:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010080b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100810:	5d                   	pop    %ebp
f0100811:	c3                   	ret    
f0100812:	66 90                	xchg   %ax,%ax
f0100814:	66 90                	xchg   %ax,%ax
f0100816:	66 90                	xchg   %ax,%ax
f0100818:	66 90                	xchg   %ax,%ax
f010081a:	66 90                	xchg   %ax,%ax
f010081c:	66 90                	xchg   %ax,%ax
f010081e:	66 90                	xchg   %ax,%ax

f0100820 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100820:	55                   	push   %ebp
f0100821:	89 e5                	mov    %esp,%ebp
f0100823:	56                   	push   %esi
f0100824:	53                   	push   %ebx
f0100825:	83 ec 10             	sub    $0x10,%esp
f0100828:	bb c4 83 10 f0       	mov    $0xf01083c4,%ebx
f010082d:	be 30 84 10 f0       	mov    $0xf0108430,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100832:	8b 03                	mov    (%ebx),%eax
f0100834:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100838:	8b 43 fc             	mov    -0x4(%ebx),%eax
f010083b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083f:	c7 04 24 c0 7e 10 f0 	movl   $0xf0107ec0,(%esp)
f0100846:	e8 3e 3a 00 00       	call   f0104289 <cprintf>
f010084b:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010084e:	39 f3                	cmp    %esi,%ebx
f0100850:	75 e0                	jne    f0100832 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100852:	b8 00 00 00 00       	mov    $0x0,%eax
f0100857:	83 c4 10             	add    $0x10,%esp
f010085a:	5b                   	pop    %ebx
f010085b:	5e                   	pop    %esi
f010085c:	5d                   	pop    %ebp
f010085d:	c3                   	ret    

f010085e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010085e:	55                   	push   %ebp
f010085f:	89 e5                	mov    %esp,%ebp
f0100861:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100864:	c7 04 24 c9 7e 10 f0 	movl   $0xf0107ec9,(%esp)
f010086b:	e8 19 3a 00 00       	call   f0104289 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100870:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100877:	00 
f0100878:	c7 04 24 14 80 10 f0 	movl   $0xf0108014,(%esp)
f010087f:	e8 05 3a 00 00       	call   f0104289 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100884:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010088b:	00 
f010088c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100893:	f0 
f0100894:	c7 04 24 3c 80 10 f0 	movl   $0xf010803c,(%esp)
f010089b:	e8 e9 39 00 00       	call   f0104289 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008a0:	c7 44 24 08 97 7b 10 	movl   $0x107b97,0x8(%esp)
f01008a7:	00 
f01008a8:	c7 44 24 04 97 7b 10 	movl   $0xf0107b97,0x4(%esp)
f01008af:	f0 
f01008b0:	c7 04 24 60 80 10 f0 	movl   $0xf0108060,(%esp)
f01008b7:	e8 cd 39 00 00       	call   f0104289 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008bc:	c7 44 24 08 3a ca 2b 	movl   $0x2bca3a,0x8(%esp)
f01008c3:	00 
f01008c4:	c7 44 24 04 3a ca 2b 	movl   $0xf02bca3a,0x4(%esp)
f01008cb:	f0 
f01008cc:	c7 04 24 84 80 10 f0 	movl   $0xf0108084,(%esp)
f01008d3:	e8 b1 39 00 00       	call   f0104289 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008d8:	c7 44 24 08 00 40 36 	movl   $0x364000,0x8(%esp)
f01008df:	00 
f01008e0:	c7 44 24 04 00 40 36 	movl   $0xf0364000,0x4(%esp)
f01008e7:	f0 
f01008e8:	c7 04 24 a8 80 10 f0 	movl   $0xf01080a8,(%esp)
f01008ef:	e8 95 39 00 00       	call   f0104289 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008f4:	b8 ff 43 36 f0       	mov    $0xf03643ff,%eax
f01008f9:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008fe:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100903:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100909:	85 c0                	test   %eax,%eax
f010090b:	0f 48 c2             	cmovs  %edx,%eax
f010090e:	c1 f8 0a             	sar    $0xa,%eax
f0100911:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100915:	c7 04 24 cc 80 10 f0 	movl   $0xf01080cc,(%esp)
f010091c:	e8 68 39 00 00       	call   f0104289 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100921:	b8 00 00 00 00       	mov    $0x0,%eax
f0100926:	c9                   	leave  
f0100927:	c3                   	ret    

f0100928 <mon_step>:
	return 0;
}

int
mon_step(int argc, char **argv, struct Trapframe *tf)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	83 ec 18             	sub    $0x18,%esp
f010092e:	8b 45 10             	mov    0x10(%ebp),%eax
	//Set trap flag (bit 8). This adds an int1 after each step automatically
	tf->tf_eflags |= 0x100;
f0100931:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	cprintf("EIP 0x%x -> 0x%x\n", tf->tf_eip, *((uint32_t*)tf->tf_eip));
f0100938:	8b 40 30             	mov    0x30(%eax),%eax
f010093b:	8b 10                	mov    (%eax),%edx
f010093d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100941:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100945:	c7 04 24 e2 7e 10 f0 	movl   $0xf0107ee2,(%esp)
f010094c:	e8 38 39 00 00       	call   f0104289 <cprintf>
	return -1;
}
f0100951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100956:	c9                   	leave  
f0100957:	c3                   	ret    

f0100958 <mon_continue>:

int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	83 ec 18             	sub    $0x18,%esp
f010095e:	8b 45 10             	mov    0x10(%ebp),%eax
	//Clear trap flag (bit 8). 
	tf->tf_eflags &= ~0x100;
f0100961:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	cprintf("Continuing... \n");
f0100968:	c7 04 24 f4 7e 10 f0 	movl   $0xf0107ef4,(%esp)
f010096f:	e8 15 39 00 00       	call   f0104289 <cprintf>
	return -1;
}
f0100974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100979:	c9                   	leave  
f010097a:	c3                   	ret    

f010097b <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010097b:	55                   	push   %ebp
f010097c:	89 e5                	mov    %esp,%ebp
f010097e:	56                   	push   %esi
f010097f:	53                   	push   %ebx
f0100980:	83 ec 40             	sub    $0x40,%esp
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100983:	89 eb                	mov    %ebp,%ebx

	while (ebp) 
	{
		debuginfo_eip(*(ebp+1),&info);
f0100985:	8d 75 e0             	lea    -0x20(%ebp),%esi
{
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));

	while (ebp) 
f0100988:	eb 7a                	jmp    f0100a04 <mon_backtrace+0x89>
	{
		debuginfo_eip(*(ebp+1),&info);
f010098a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010098e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100991:	89 04 24             	mov    %eax,(%esp)
f0100994:	e8 25 4f 00 00       	call   f01058be <debuginfo_eip>
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, *(ebp+1), *(ebp+2), *(ebp+3), *(ebp+3), *(ebp+4), *(ebp+5));
f0100999:	8b 43 0c             	mov    0xc(%ebx),%eax
f010099c:	8b 53 14             	mov    0x14(%ebx),%edx
f010099f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
f01009a3:	8b 53 10             	mov    0x10(%ebx),%edx
f01009a6:	89 54 24 18          	mov    %edx,0x18(%esp)
f01009aa:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009ae:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009b2:	8b 43 08             	mov    0x8(%ebx),%eax
f01009b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009b9:	8b 43 04             	mov    0x4(%ebx),%eax
f01009bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009c4:	c7 04 24 f8 80 10 f0 	movl   $0xf01080f8,(%esp)
f01009cb:	e8 b9 38 00 00       	call   f0104289 <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - (int)info.eip_fn_addr);
f01009d0:	8b 43 04             	mov    0x4(%ebx),%eax
f01009d3:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01009d6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009da:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009dd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01009e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f6:	c7 04 24 04 7f 10 f0 	movl   $0xf0107f04,(%esp)
f01009fd:	e8 87 38 00 00       	call   f0104289 <cprintf>
		ebp = (int*)(*ebp);
f0100a02:	8b 1b                	mov    (%ebx),%ebx
{
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));

	while (ebp) 
f0100a04:	85 db                	test   %ebx,%ebx
f0100a06:	75 82                	jne    f010098a <mon_backtrace+0xf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - (int)info.eip_fn_addr);
		ebp = (int*)(*ebp);
	}

	return 0;
}
f0100a08:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a0d:	83 c4 40             	add    $0x40,%esp
f0100a10:	5b                   	pop    %ebx
f0100a11:	5e                   	pop    %esi
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <mon_dumpv>:
	return 0;
}

int 
mon_dumpv(int argc, char **argv, struct Trapframe *tf)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
f0100a17:	57                   	push   %edi
f0100a18:	56                   	push   %esi
f0100a19:	53                   	push   %ebx
f0100a1a:	83 ec 1c             	sub    $0x1c,%esp
f0100a1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f0100a20:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a24:	7f 13                	jg     f0100a39 <mon_dumpv+0x25>
		cprintf("Need to specify address or address range!");
f0100a26:	c7 04 24 2c 81 10 f0 	movl   $0xf010812c,(%esp)
f0100a2d:	e8 57 38 00 00       	call   f0104289 <cprintf>
		return -1;
f0100a32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a37:	eb 6e                	jmp    f0100aa7 <mon_dumpv+0x93>
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
f0100a39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a40:	00 
f0100a41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a48:	00 
f0100a49:	8b 47 04             	mov    0x4(%edi),%eax
f0100a4c:	89 04 24             	mov    %eax,(%esp)
f0100a4f:	e8 1f 5a 00 00       	call   f0106473 <strtol>
f0100a54:	89 c3                	mov    %eax,%ebx
	uint32_t* last = first;
f0100a56:	89 c6                	mov    %eax,%esi
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);
f0100a58:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a5c:	75 34                	jne    f0100a92 <mon_dumpv+0x7e>
f0100a5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a65:	00 
f0100a66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a6d:	00 
f0100a6e:	8b 47 08             	mov    0x8(%edi),%eax
f0100a71:	89 04 24             	mov    %eax,(%esp)
f0100a74:	e8 fa 59 00 00       	call   f0106473 <strtol>
f0100a79:	89 c6                	mov    %eax,%esi

	for(uint32_t* i = first; i <= last; i++) {
f0100a7b:	eb 15                	jmp    f0100a92 <mon_dumpv+0x7e>
		cprintf("%x ",*i); //paging hardware just translates virtual address for us
f0100a7d:	8b 03                	mov    (%ebx),%eax
f0100a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a83:	c7 04 24 15 7f 10 f0 	movl   $0xf0107f15,(%esp)
f0100a8a:	e8 fa 37 00 00       	call   f0104289 <cprintf>

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
f0100a8f:	83 c3 04             	add    $0x4,%ebx
f0100a92:	39 de                	cmp    %ebx,%esi
f0100a94:	73 e7                	jae    f0100a7d <mon_dumpv+0x69>
		cprintf("%x ",*i); //paging hardware just translates virtual address for us
	}
	cprintf("\n");
f0100a96:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f0100a9d:	e8 e7 37 00 00       	call   f0104289 <cprintf>
	return 0;
f0100aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aa7:	83 c4 1c             	add    $0x1c,%esp
f0100aaa:	5b                   	pop    %ebx
f0100aab:	5e                   	pop    %esi
f0100aac:	5f                   	pop    %edi
f0100aad:	5d                   	pop    %ebp
f0100aae:	c3                   	ret    

f0100aaf <mon_dumpp>:

int 
mon_dumpp(int argc, char **argv, struct Trapframe *tf)
{
f0100aaf:	55                   	push   %ebp
f0100ab0:	89 e5                	mov    %esp,%ebp
f0100ab2:	57                   	push   %edi
f0100ab3:	56                   	push   %esi
f0100ab4:	53                   	push   %ebx
f0100ab5:	83 ec 1c             	sub    $0x1c,%esp
f0100ab8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f0100abb:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100abf:	7f 16                	jg     f0100ad7 <mon_dumpp+0x28>
		cprintf("Need to specify address or address range!");
f0100ac1:	c7 04 24 2c 81 10 f0 	movl   $0xf010812c,(%esp)
f0100ac8:	e8 bc 37 00 00       	call   f0104289 <cprintf>
		return -1;
f0100acd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ad2:	e9 9f 00 00 00       	jmp    f0100b76 <mon_dumpp+0xc7>
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
f0100ad7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ade:	00 
f0100adf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ae6:	00 
f0100ae7:	8b 47 04             	mov    0x4(%edi),%eax
f0100aea:	89 04 24             	mov    %eax,(%esp)
f0100aed:	e8 81 59 00 00       	call   f0106473 <strtol>
f0100af2:	89 c3                	mov    %eax,%ebx
	uint32_t* last = first;
f0100af4:	89 c6                	mov    %eax,%esi
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);
f0100af6:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100afa:	75 65                	jne    f0100b61 <mon_dumpp+0xb2>
f0100afc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b03:	00 
f0100b04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b0b:	00 
f0100b0c:	8b 47 08             	mov    0x8(%edi),%eax
f0100b0f:	89 04 24             	mov    %eax,(%esp)
f0100b12:	e8 5c 59 00 00       	call   f0106473 <strtol>
f0100b17:	89 c6                	mov    %eax,%esi

	for(uint32_t* i = first; i <= last; i++) {
f0100b19:	eb 46                	jmp    f0100b61 <mon_dumpp+0xb2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b1b:	89 d8                	mov    %ebx,%eax
f0100b1d:	c1 e8 0c             	shr    $0xc,%eax
f0100b20:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0100b26:	72 20                	jb     f0100b48 <mon_dumpp+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b28:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100b2c:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0100b33:	f0 
f0100b34:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0100b3b:	00 
f0100b3c:	c7 04 24 19 7f 10 f0 	movl   $0xf0107f19,(%esp)
f0100b43:	e8 f8 f4 ff ff       	call   f0100040 <_panic>
		cprintf("%x ",*((int*)KADDR((physaddr_t)i))); 
f0100b48:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b52:	c7 04 24 15 7f 10 f0 	movl   $0xf0107f15,(%esp)
f0100b59:	e8 2b 37 00 00       	call   f0104289 <cprintf>

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
f0100b5e:	83 c3 04             	add    $0x4,%ebx
f0100b61:	39 de                	cmp    %ebx,%esi
f0100b63:	73 b6                	jae    f0100b1b <mon_dumpp+0x6c>
		cprintf("%x ",*((int*)KADDR((physaddr_t)i))); 
	}
	cprintf("\n");
f0100b65:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f0100b6c:	e8 18 37 00 00       	call   f0104289 <cprintf>
	return 0;
f0100b71:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b76:	83 c4 1c             	add    $0x1c,%esp
f0100b79:	5b                   	pop    %ebx
f0100b7a:	5e                   	pop    %esi
f0100b7b:	5f                   	pop    %edi
f0100b7c:	5d                   	pop    %ebp
f0100b7d:	c3                   	ret    

f0100b7e <traversePages>:
	return 0;
}

// Used by both showmappings and changeperms to loop over page ranges 
// and perform operations on them
void traversePages(uintptr_t first, uintptr_t last, int print, int set, int clear) {
f0100b7e:	55                   	push   %ebp
f0100b7f:	89 e5                	mov    %esp,%ebp
f0100b81:	57                   	push   %edi
f0100b82:	56                   	push   %esi
f0100b83:	53                   	push   %ebx
f0100b84:	83 ec 1c             	sub    $0x1c,%esp
f0100b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100b8a:	8b 7d 10             	mov    0x10(%ebp),%edi

	//The first 20 bits of va specify the page, so we increment 0x1000
	for(uintptr_t i = first; i <= last; i += 0x1000) {
f0100b8d:	e9 a8 00 00 00       	jmp    f0100c3a <traversePages+0xbc>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) i, 0);
f0100b92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b99:	00 
f0100b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b9e:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0100ba3:	89 04 24             	mov    %eax,(%esp)
f0100ba6:	e8 28 0a 00 00       	call   f01015d3 <pgdir_walk>
f0100bab:	89 c6                	mov    %eax,%esi

		if(!pte || !(*pte & PTE_P)) {
f0100bad:	85 c0                	test   %eax,%eax
f0100baf:	74 06                	je     f0100bb7 <traversePages+0x39>
f0100bb1:	8b 00                	mov    (%eax),%eax
f0100bb3:	a8 01                	test   $0x1,%al
f0100bb5:	75 16                	jne    f0100bcd <traversePages+0x4f>
			//Page table or page doesn't exist
			if(print) cprintf("0x%x: --- \n", i);
f0100bb7:	85 ff                	test   %edi,%edi
f0100bb9:	74 79                	je     f0100c34 <traversePages+0xb6>
f0100bbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bbf:	c7 04 24 28 7f 10 f0 	movl   $0xf0107f28,(%esp)
f0100bc6:	e8 be 36 00 00       	call   f0104289 <cprintf>
f0100bcb:	eb 67                	jmp    f0100c34 <traversePages+0xb6>
			continue;
		}

		//Either changer perms, or print but not both
		if(print) {
f0100bcd:	85 ff                	test   %edi,%edi
f0100bcf:	74 5b                	je     f0100c2c <traversePages+0xae>
			cprintf("0x%x: 0x%x - ", i, PTE_ADDR(i));
f0100bd1:	89 d8                	mov    %ebx,%eax
f0100bd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100be0:	c7 04 24 34 7f 10 f0 	movl   $0xf0107f34,(%esp)
f0100be7:	e8 9d 36 00 00       	call   f0104289 <cprintf>

			if(*pte & PTE_U) cprintf("U ");
f0100bec:	f6 06 04             	testb  $0x4,(%esi)
f0100bef:	74 0e                	je     f0100bff <traversePages+0x81>
f0100bf1:	c7 04 24 42 7f 10 f0 	movl   $0xf0107f42,(%esp)
f0100bf8:	e8 8c 36 00 00       	call   f0104289 <cprintf>
f0100bfd:	eb 0c                	jmp    f0100c0b <traversePages+0x8d>
			else cprintf("S ");
f0100bff:	c7 04 24 45 7f 10 f0 	movl   $0xf0107f45,(%esp)
f0100c06:	e8 7e 36 00 00       	call   f0104289 <cprintf>

			if(*pte & PTE_W) cprintf("RW\n");
f0100c0b:	f6 06 02             	testb  $0x2,(%esi)
f0100c0e:	74 0e                	je     f0100c1e <traversePages+0xa0>
f0100c10:	c7 04 24 48 7f 10 f0 	movl   $0xf0107f48,(%esp)
f0100c17:	e8 6d 36 00 00       	call   f0104289 <cprintf>
f0100c1c:	eb 16                	jmp    f0100c34 <traversePages+0xb6>
			else cprintf("R\n");
f0100c1e:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f0100c25:	e8 5f 36 00 00       	call   f0104289 <cprintf>
f0100c2a:	eb 08                	jmp    f0100c34 <traversePages+0xb6>
		} else {
			*pte |= set;
f0100c2c:	0b 45 14             	or     0x14(%ebp),%eax
			*pte &= clear;
f0100c2f:	23 45 18             	and    0x18(%ebp),%eax
f0100c32:	89 06                	mov    %eax,(%esi)
// Used by both showmappings and changeperms to loop over page ranges 
// and perform operations on them
void traversePages(uintptr_t first, uintptr_t last, int print, int set, int clear) {

	//The first 20 bits of va specify the page, so we increment 0x1000
	for(uintptr_t i = first; i <= last; i += 0x1000) {
f0100c34:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100c3a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0100c3d:	0f 86 4f ff ff ff    	jbe    f0100b92 <traversePages+0x14>
		} else {
			*pte |= set;
			*pte &= clear;
		}
	}
}
f0100c43:	83 c4 1c             	add    $0x1c,%esp
f0100c46:	5b                   	pop    %ebx
f0100c47:	5e                   	pop    %esi
f0100c48:	5f                   	pop    %edi
f0100c49:	5d                   	pop    %ebp
f0100c4a:	c3                   	ret    

f0100c4b <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100c4b:	55                   	push   %ebp
f0100c4c:	89 e5                	mov    %esp,%ebp
f0100c4e:	57                   	push   %edi
f0100c4f:	56                   	push   %esi
f0100c50:	53                   	push   %ebx
f0100c51:	83 ec 2c             	sub    $0x2c,%esp
f0100c54:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100c57:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f0100c5a:	83 fb 01             	cmp    $0x1,%ebx
f0100c5d:	7f 13                	jg     f0100c72 <mon_showmappings+0x27>
		cprintf("Need to specify address or address range!");
f0100c5f:	c7 04 24 2c 81 10 f0 	movl   $0xf010812c,(%esp)
f0100c66:	e8 1e 36 00 00       	call   f0104289 <cprintf>
		return -1;
f0100c6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c70:	eb 66                	jmp    f0100cd8 <mon_showmappings+0x8d>
	}
	
	//Get first and last page of address range
	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
f0100c72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c79:	00 
f0100c7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c81:	00 
f0100c82:	8b 47 04             	mov    0x4(%edi),%eax
f0100c85:	89 04 24             	mov    %eax,(%esp)
f0100c88:	e8 e6 57 00 00       	call   f0106473 <strtol>
f0100c8d:	89 c6                	mov    %eax,%esi
	uintptr_t last = first;
	if(argc == 3) last = (uintptr_t) strtol(argv[2], NULL, 0);
f0100c8f:	83 fb 03             	cmp    $0x3,%ebx
f0100c92:	75 1b                	jne    f0100caf <mon_showmappings+0x64>
f0100c94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c9b:	00 
f0100c9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ca3:	00 
f0100ca4:	8b 47 08             	mov    0x8(%edi),%eax
f0100ca7:	89 04 24             	mov    %eax,(%esp)
f0100caa:	e8 c4 57 00 00       	call   f0106473 <strtol>

	traversePages(first, last, 1, 0, 0); // last two arguments are unused
f0100caf:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
f0100cb6:	00 
f0100cb7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100cbe:	00 
f0100cbf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100cc6:	00 
f0100cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ccb:	89 34 24             	mov    %esi,(%esp)
f0100cce:	e8 ab fe ff ff       	call   f0100b7e <traversePages>
	return 0;
f0100cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cd8:	83 c4 2c             	add    $0x2c,%esp
f0100cdb:	5b                   	pop    %ebx
f0100cdc:	5e                   	pop    %esi
f0100cdd:	5f                   	pop    %edi
f0100cde:	5d                   	pop    %ebp
f0100cdf:	c3                   	ret    

f0100ce0 <mon_changeperms>:

int 
mon_changeperms(int argc, char **argv, struct Trapframe *tf)
{
f0100ce0:	55                   	push   %ebp
f0100ce1:	89 e5                	mov    %esp,%ebp
f0100ce3:	57                   	push   %edi
f0100ce4:	56                   	push   %esi
f0100ce5:	53                   	push   %ebx
f0100ce6:	83 ec 2c             	sub    $0x2c,%esp
f0100ce9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc < 4) {
f0100cec:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100cf0:	7f 16                	jg     f0100d08 <mon_changeperms+0x28>
		cprintf("Need to specify address range and at least one change!");
f0100cf2:	c7 04 24 58 81 10 f0 	movl   $0xf0108158,(%esp)
f0100cf9:	e8 8b 35 00 00       	call   f0104289 <cprintf>
		return -1;
f0100cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d03:	e9 e2 00 00 00       	jmp    f0100dea <mon_changeperms+0x10a>
	}

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
f0100d08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100d0f:	00 
f0100d10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d17:	00 
f0100d18:	8b 43 04             	mov    0x4(%ebx),%eax
f0100d1b:	89 04 24             	mov    %eax,(%esp)
f0100d1e:	e8 50 57 00 00       	call   f0106473 <strtol>
f0100d23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);
f0100d26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100d2d:	00 
f0100d2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d35:	00 
f0100d36:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d39:	89 04 24             	mov    %eax,(%esp)
f0100d3c:	e8 32 57 00 00       	call   f0106473 <strtol>
f0100d41:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
f0100d44:	b8 03 00 00 00       	mov    $0x3,%eax
	}

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);

	int set = 0, clear = 0;
f0100d49:	be 00 00 00 00       	mov    $0x0,%esi
f0100d4e:	bf 00 00 00 00       	mov    $0x0,%edi
	for(int i = 3; i < argc; i ++ ) {
		int flag = 0;
		switch(argv[i][1]) {
f0100d53:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0100d56:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f0100d5a:	80 fa 55             	cmp    $0x55,%dl
f0100d5d:	74 2d                	je     f0100d8c <mon_changeperms+0xac>
f0100d5f:	80 fa 57             	cmp    $0x57,%dl
f0100d62:	74 07                	je     f0100d6b <mon_changeperms+0x8b>
f0100d64:	80 fa 50             	cmp    $0x50,%dl
f0100d67:	75 09                	jne    f0100d72 <mon_changeperms+0x92>
f0100d69:	eb 1a                	jmp    f0100d85 <mon_changeperms+0xa5>
				break;
			case 'U': 
				flag = PTE_U;
				break;
			case 'W': 
				flag = PTE_W;
f0100d6b:	ba 02 00 00 00       	mov    $0x2,%edx
				break;
f0100d70:	eb 1f                	jmp    f0100d91 <mon_changeperms+0xb1>
			default:
				cprintf("Illegal! See help for usage\n");
f0100d72:	c7 04 24 4f 7f 10 f0 	movl   $0xf0107f4f,(%esp)
f0100d79:	e8 0b 35 00 00       	call   f0104289 <cprintf>
				return -1;
f0100d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d83:	eb 65                	jmp    f0100dea <mon_changeperms+0x10a>
	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
		int flag = 0;
		switch(argv[i][1]) {
			case 'P': 
				flag = PTE_P;
f0100d85:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d8a:	eb 05                	jmp    f0100d91 <mon_changeperms+0xb1>
				break;
			case 'U': 
				flag = PTE_U;
f0100d8c:	ba 04 00 00 00       	mov    $0x4,%edx
				cprintf("Illegal! See help for usage\n");
				return -1;
		}

		//Accumulate flag values in set and clear
		if(argv[i][0] == '+') set |= flag;
f0100d91:	0f b6 09             	movzbl (%ecx),%ecx
f0100d94:	80 f9 2b             	cmp    $0x2b,%cl
f0100d97:	75 04                	jne    f0100d9d <mon_changeperms+0xbd>
f0100d99:	09 d7                	or     %edx,%edi
f0100d9b:	eb 1c                	jmp    f0100db9 <mon_changeperms+0xd9>
		else if(argv[i][0] == '-') clear |= flag;
f0100d9d:	80 f9 2d             	cmp    $0x2d,%cl
f0100da0:	75 04                	jne    f0100da6 <mon_changeperms+0xc6>
f0100da2:	09 d6                	or     %edx,%esi
f0100da4:	eb 13                	jmp    f0100db9 <mon_changeperms+0xd9>
		else {
			cprintf("Illegal! See help for usage\n");
f0100da6:	c7 04 24 4f 7f 10 f0 	movl   $0xf0107f4f,(%esp)
f0100dad:	e8 d7 34 00 00       	call   f0104289 <cprintf>
			return -1;
f0100db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100db7:	eb 31                	jmp    f0100dea <mon_changeperms+0x10a>

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);

	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
f0100db9:	83 c0 01             	add    $0x1,%eax
f0100dbc:	3b 45 08             	cmp    0x8(%ebp),%eax
f0100dbf:	75 92                	jne    f0100d53 <mon_changeperms+0x73>
			cprintf("Illegal! See help for usage\n");
			return -1;
		}
	}

	traversePages(first, last, 0, set, ~clear); 
f0100dc1:	f7 d6                	not    %esi
f0100dc3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100dc7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100dcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100dd2:	00 
f0100dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ddd:	89 04 24             	mov    %eax,(%esp)
f0100de0:	e8 99 fd ff ff       	call   f0100b7e <traversePages>
	return 0;
f0100de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100dea:	83 c4 2c             	add    $0x2c,%esp
f0100ded:	5b                   	pop    %ebx
f0100dee:	5e                   	pop    %esi
f0100def:	5f                   	pop    %edi
f0100df0:	5d                   	pop    %ebp
f0100df1:	c3                   	ret    

f0100df2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100df2:	55                   	push   %ebp
f0100df3:	89 e5                	mov    %esp,%ebp
f0100df5:	57                   	push   %edi
f0100df6:	56                   	push   %esi
f0100df7:	53                   	push   %ebx
f0100df8:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100dfb:	c7 04 24 90 81 10 f0 	movl   $0xf0108190,(%esp)
f0100e02:	e8 82 34 00 00       	call   f0104289 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e07:	c7 04 24 b4 81 10 f0 	movl   $0xf01081b4,(%esp)
f0100e0e:	e8 76 34 00 00       	call   f0104289 <cprintf>

	if (tf != NULL)
f0100e13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e17:	74 0b                	je     f0100e24 <monitor+0x32>
		print_trapframe(tf);
f0100e19:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e1c:	89 04 24             	mov    %eax,(%esp)
f0100e1f:	e8 52 3a 00 00       	call   f0104876 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100e24:	c7 04 24 6c 7f 10 f0 	movl   $0xf0107f6c,(%esp)
f0100e2b:	e8 b0 52 00 00       	call   f01060e0 <readline>
f0100e30:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e32:	85 c0                	test   %eax,%eax
f0100e34:	74 ee                	je     f0100e24 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e36:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e3d:	be 00 00 00 00       	mov    $0x0,%esi
f0100e42:	eb 0a                	jmp    f0100e4e <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e44:	c6 03 00             	movb   $0x0,(%ebx)
f0100e47:	89 f7                	mov    %esi,%edi
f0100e49:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100e4c:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e4e:	0f b6 03             	movzbl (%ebx),%eax
f0100e51:	84 c0                	test   %al,%al
f0100e53:	74 63                	je     f0100eb8 <monitor+0xc6>
f0100e55:	0f be c0             	movsbl %al,%eax
f0100e58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5c:	c7 04 24 70 7f 10 f0 	movl   $0xf0107f70,(%esp)
f0100e63:	e8 a2 54 00 00       	call   f010630a <strchr>
f0100e68:	85 c0                	test   %eax,%eax
f0100e6a:	75 d8                	jne    f0100e44 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100e6c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e6f:	74 47                	je     f0100eb8 <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e71:	83 fe 0f             	cmp    $0xf,%esi
f0100e74:	75 16                	jne    f0100e8c <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e76:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100e7d:	00 
f0100e7e:	c7 04 24 75 7f 10 f0 	movl   $0xf0107f75,(%esp)
f0100e85:	e8 ff 33 00 00       	call   f0104289 <cprintf>
f0100e8a:	eb 98                	jmp    f0100e24 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100e8c:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e8f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e93:	eb 03                	jmp    f0100e98 <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e95:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e98:	0f b6 03             	movzbl (%ebx),%eax
f0100e9b:	84 c0                	test   %al,%al
f0100e9d:	74 ad                	je     f0100e4c <monitor+0x5a>
f0100e9f:	0f be c0             	movsbl %al,%eax
f0100ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ea6:	c7 04 24 70 7f 10 f0 	movl   $0xf0107f70,(%esp)
f0100ead:	e8 58 54 00 00       	call   f010630a <strchr>
f0100eb2:	85 c0                	test   %eax,%eax
f0100eb4:	74 df                	je     f0100e95 <monitor+0xa3>
f0100eb6:	eb 94                	jmp    f0100e4c <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100eb8:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ebf:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ec0:	85 f6                	test   %esi,%esi
f0100ec2:	0f 84 5c ff ff ff    	je     f0100e24 <monitor+0x32>
f0100ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ecd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ed0:	8b 04 85 c0 83 10 f0 	mov    -0xfef7c40(,%eax,4),%eax
f0100ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100edb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ede:	89 04 24             	mov    %eax,(%esp)
f0100ee1:	e8 c6 53 00 00       	call   f01062ac <strcmp>
f0100ee6:	85 c0                	test   %eax,%eax
f0100ee8:	75 24                	jne    f0100f0e <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100eea:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100eed:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ef0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ef4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ef7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100efb:	89 34 24             	mov    %esi,(%esp)
f0100efe:	ff 14 85 c8 83 10 f0 	call   *-0xfef7c38(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f05:	85 c0                	test   %eax,%eax
f0100f07:	78 25                	js     f0100f2e <monitor+0x13c>
f0100f09:	e9 16 ff ff ff       	jmp    f0100e24 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f0e:	83 c3 01             	add    $0x1,%ebx
f0100f11:	83 fb 09             	cmp    $0x9,%ebx
f0100f14:	75 b7                	jne    f0100ecd <monitor+0xdb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f16:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100f19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1d:	c7 04 24 92 7f 10 f0 	movl   $0xf0107f92,(%esp)
f0100f24:	e8 60 33 00 00       	call   f0104289 <cprintf>
f0100f29:	e9 f6 fe ff ff       	jmp    f0100e24 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f2e:	83 c4 5c             	add    $0x5c,%esp
f0100f31:	5b                   	pop    %ebx
f0100f32:	5e                   	pop    %esi
f0100f33:	5f                   	pop    %edi
f0100f34:	5d                   	pop    %ebp
f0100f35:	c3                   	ret    
f0100f36:	66 90                	xchg   %ax,%ax
f0100f38:	66 90                	xchg   %ax,%ax
f0100f3a:	66 90                	xchg   %ax,%ax
f0100f3c:	66 90                	xchg   %ax,%ax
f0100f3e:	66 90                	xchg   %ax,%ax

f0100f40 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f40:	55                   	push   %ebp
f0100f41:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f43:	83 3d 38 d2 2b f0 00 	cmpl   $0x0,0xf02bd238
f0100f4a:	75 11                	jne    f0100f5d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f4c:	ba ff 4f 36 f0       	mov    $0xf0364fff,%edx
f0100f51:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f57:	89 15 38 d2 2b f0    	mov    %edx,0xf02bd238

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.

	result = nextfree;
f0100f5d:	8b 15 38 d2 2b f0    	mov    0xf02bd238,%edx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f63:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f6f:	a3 38 d2 2b f0       	mov    %eax,0xf02bd238

	return result;
}
f0100f74:	89 d0                	mov    %edx,%eax
f0100f76:	5d                   	pop    %ebp
f0100f77:	c3                   	ret    

f0100f78 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	56                   	push   %esi
f0100f7c:	53                   	push   %ebx
f0100f7d:	83 ec 10             	sub    $0x10,%esp
f0100f80:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f82:	89 04 24             	mov    %eax,(%esp)
f0100f85:	e8 83 31 00 00       	call   f010410d <mc146818_read>
f0100f8a:	89 c6                	mov    %eax,%esi
f0100f8c:	83 c3 01             	add    $0x1,%ebx
f0100f8f:	89 1c 24             	mov    %ebx,(%esp)
f0100f92:	e8 76 31 00 00       	call   f010410d <mc146818_read>
f0100f97:	c1 e0 08             	shl    $0x8,%eax
f0100f9a:	09 f0                	or     %esi,%eax
}
f0100f9c:	83 c4 10             	add    $0x10,%esp
f0100f9f:	5b                   	pop    %ebx
f0100fa0:	5e                   	pop    %esi
f0100fa1:	5d                   	pop    %ebp
f0100fa2:	c3                   	ret    

f0100fa3 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fa3:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f0100fa9:	c1 f8 03             	sar    $0x3,%eax
f0100fac:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100faf:	89 c2                	mov    %eax,%edx
f0100fb1:	c1 ea 0c             	shr    $0xc,%edx
f0100fb4:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f0100fba:	72 26                	jb     f0100fe2 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100fbc:	55                   	push   %ebp
f0100fbd:	89 e5                	mov    %esp,%ebp
f0100fbf:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc6:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0100fcd:	f0 
f0100fce:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100fd5:	00 
f0100fd6:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0100fdd:	e8 5e f0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100fe2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100fe7:	c3                   	ret    

f0100fe8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fe8:	89 d1                	mov    %edx,%ecx
f0100fea:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fed:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ff0:	a8 01                	test   $0x1,%al
f0100ff2:	74 5d                	je     f0101051 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ff4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff9:	89 c1                	mov    %eax,%ecx
f0100ffb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ffe:	3b 0d 94 de 2b f0    	cmp    0xf02bde94,%ecx
f0101004:	72 26                	jb     f010102c <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101006:	55                   	push   %ebp
f0101007:	89 e5                	mov    %esp,%ebp
f0101009:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101010:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0101017:	f0 
f0101018:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f010101f:	00 
f0101020:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101027:	e8 14 f0 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f010102c:	c1 ea 0c             	shr    $0xc,%edx
f010102f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101035:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010103c:	89 c2                	mov    %eax,%edx
f010103e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101041:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101046:	85 d2                	test   %edx,%edx
f0101048:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010104d:	0f 44 c2             	cmove  %edx,%eax
f0101050:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0101051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0101056:	c3                   	ret    

f0101057 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
f010105a:	57                   	push   %edi
f010105b:	56                   	push   %esi
f010105c:	53                   	push   %ebx
f010105d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101060:	84 c0                	test   %al,%al
f0101062:	0f 85 3f 03 00 00    	jne    f01013a7 <check_page_free_list+0x350>
f0101068:	e9 4c 03 00 00       	jmp    f01013b9 <check_page_free_list+0x362>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f010106d:	c7 44 24 08 2c 84 10 	movl   $0xf010842c,0x8(%esp)
f0101074:	f0 
f0101075:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f010107c:	00 
f010107d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101084:	e8 b7 ef ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101089:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010108c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010108f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101092:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101095:	89 c2                	mov    %eax,%edx
f0101097:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010109d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01010a3:	0f 95 c2             	setne  %dl
f01010a6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01010a9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01010ad:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01010af:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b3:	8b 00                	mov    (%eax),%eax
f01010b5:	85 c0                	test   %eax,%eax
f01010b7:	75 dc                	jne    f0101095 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01010b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010c8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010cd:	a3 40 d2 2b f0       	mov    %eax,0xf02bd240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01010d2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010d7:	8b 1d 40 d2 2b f0    	mov    0xf02bd240,%ebx
f01010dd:	eb 63                	jmp    f0101142 <check_page_free_list+0xeb>
f01010df:	89 d8                	mov    %ebx,%eax
f01010e1:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f01010e7:	c1 f8 03             	sar    $0x3,%eax
f01010ea:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010ed:	89 c2                	mov    %eax,%edx
f01010ef:	c1 ea 16             	shr    $0x16,%edx
f01010f2:	39 f2                	cmp    %esi,%edx
f01010f4:	73 4a                	jae    f0101140 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010f6:	89 c2                	mov    %eax,%edx
f01010f8:	c1 ea 0c             	shr    $0xc,%edx
f01010fb:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f0101101:	72 20                	jb     f0101123 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101103:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101107:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f010110e:	f0 
f010110f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101116:	00 
f0101117:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f010111e:	e8 1d ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101123:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010112a:	00 
f010112b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101132:	00 
	return (void *)(pa + KERNBASE);
f0101133:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101138:	89 04 24             	mov    %eax,(%esp)
f010113b:	e8 07 52 00 00       	call   f0106347 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101140:	8b 1b                	mov    (%ebx),%ebx
f0101142:	85 db                	test   %ebx,%ebx
f0101144:	75 99                	jne    f01010df <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101146:	b8 00 00 00 00       	mov    $0x0,%eax
f010114b:	e8 f0 fd ff ff       	call   f0100f40 <boot_alloc>
f0101150:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101153:	8b 15 40 d2 2b f0    	mov    0xf02bd240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101159:	8b 0d 9c de 2b f0    	mov    0xf02bde9c,%ecx
		assert(pp < pages + npages);
f010115f:	a1 94 de 2b f0       	mov    0xf02bde94,%eax
f0101164:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101167:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010116a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010116d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101170:	bf 00 00 00 00       	mov    $0x0,%edi
f0101175:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101178:	e9 c4 01 00 00       	jmp    f0101341 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010117d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101180:	73 24                	jae    f01011a6 <check_page_free_list+0x14f>
f0101182:	c7 44 24 0c 67 8d 10 	movl   $0xf0108d67,0xc(%esp)
f0101189:	f0 
f010118a:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101191:	f0 
f0101192:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101199:	00 
f010119a:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01011a1:	e8 9a ee ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f01011a6:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01011a9:	72 24                	jb     f01011cf <check_page_free_list+0x178>
f01011ab:	c7 44 24 0c 88 8d 10 	movl   $0xf0108d88,0xc(%esp)
f01011b2:	f0 
f01011b3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01011ba:	f0 
f01011bb:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01011c2:	00 
f01011c3:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01011ca:	e8 71 ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011cf:	89 d0                	mov    %edx,%eax
f01011d1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01011d4:	a8 07                	test   $0x7,%al
f01011d6:	74 24                	je     f01011fc <check_page_free_list+0x1a5>
f01011d8:	c7 44 24 0c 50 84 10 	movl   $0xf0108450,0xc(%esp)
f01011df:	f0 
f01011e0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01011e7:	f0 
f01011e8:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01011ef:	00 
f01011f0:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01011f7:	e8 44 ee ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011fc:	c1 f8 03             	sar    $0x3,%eax
f01011ff:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101202:	85 c0                	test   %eax,%eax
f0101204:	75 24                	jne    f010122a <check_page_free_list+0x1d3>
f0101206:	c7 44 24 0c 9c 8d 10 	movl   $0xf0108d9c,0xc(%esp)
f010120d:	f0 
f010120e:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101215:	f0 
f0101216:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f010121d:	00 
f010121e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101225:	e8 16 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010122a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010122f:	75 24                	jne    f0101255 <check_page_free_list+0x1fe>
f0101231:	c7 44 24 0c ad 8d 10 	movl   $0xf0108dad,0xc(%esp)
f0101238:	f0 
f0101239:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101240:	f0 
f0101241:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0101248:	00 
f0101249:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101250:	e8 eb ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101255:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010125a:	75 24                	jne    f0101280 <check_page_free_list+0x229>
f010125c:	c7 44 24 0c 84 84 10 	movl   $0xf0108484,0xc(%esp)
f0101263:	f0 
f0101264:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010126b:	f0 
f010126c:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101273:	00 
f0101274:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010127b:	e8 c0 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101280:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101285:	75 24                	jne    f01012ab <check_page_free_list+0x254>
f0101287:	c7 44 24 0c c6 8d 10 	movl   $0xf0108dc6,0xc(%esp)
f010128e:	f0 
f010128f:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101296:	f0 
f0101297:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f010129e:	00 
f010129f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01012ab:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01012b0:	0f 86 2a 01 00 00    	jbe    f01013e0 <check_page_free_list+0x389>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b6:	89 c1                	mov    %eax,%ecx
f01012b8:	c1 e9 0c             	shr    $0xc,%ecx
f01012bb:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f01012be:	77 20                	ja     f01012e0 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012c4:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f01012cb:	f0 
f01012cc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012d3:	00 
f01012d4:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f01012db:	e8 60 ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01012e0:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f01012e6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01012e9:	0f 86 e1 00 00 00    	jbe    f01013d0 <check_page_free_list+0x379>
f01012ef:	c7 44 24 0c a8 84 10 	movl   $0xf01084a8,0xc(%esp)
f01012f6:	f0 
f01012f7:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01012fe:	f0 
f01012ff:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101306:	00 
f0101307:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010130e:	e8 2d ed ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101313:	c7 44 24 0c e0 8d 10 	movl   $0xf0108de0,0xc(%esp)
f010131a:	f0 
f010131b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101322:	f0 
f0101323:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f010132a:	00 
f010132b:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101332:	e8 09 ed ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101337:	83 c3 01             	add    $0x1,%ebx
f010133a:	eb 03                	jmp    f010133f <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f010133c:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010133f:	8b 12                	mov    (%edx),%edx
f0101341:	85 d2                	test   %edx,%edx
f0101343:	0f 85 34 fe ff ff    	jne    f010117d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101349:	85 db                	test   %ebx,%ebx
f010134b:	7f 24                	jg     f0101371 <check_page_free_list+0x31a>
f010134d:	c7 44 24 0c fd 8d 10 	movl   $0xf0108dfd,0xc(%esp)
f0101354:	f0 
f0101355:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010135c:	f0 
f010135d:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0101364:	00 
f0101365:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010136c:	e8 cf ec ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101371:	85 ff                	test   %edi,%edi
f0101373:	7f 24                	jg     f0101399 <check_page_free_list+0x342>
f0101375:	c7 44 24 0c 0f 8e 10 	movl   $0xf0108e0f,0xc(%esp)
f010137c:	f0 
f010137d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101384:	f0 
f0101385:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f010138c:	00 
f010138d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101394:	e8 a7 ec ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101399:	c7 04 24 f0 84 10 f0 	movl   $0xf01084f0,(%esp)
f01013a0:	e8 e4 2e 00 00       	call   f0104289 <cprintf>
f01013a5:	eb 4e                	jmp    f01013f5 <check_page_free_list+0x39e>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01013a7:	a1 40 d2 2b f0       	mov    0xf02bd240,%eax
f01013ac:	85 c0                	test   %eax,%eax
f01013ae:	0f 85 d5 fc ff ff    	jne    f0101089 <check_page_free_list+0x32>
f01013b4:	e9 b4 fc ff ff       	jmp    f010106d <check_page_free_list+0x16>
f01013b9:	83 3d 40 d2 2b f0 00 	cmpl   $0x0,0xf02bd240
f01013c0:	0f 84 a7 fc ff ff    	je     f010106d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01013c6:	be 00 04 00 00       	mov    $0x400,%esi
f01013cb:	e9 07 fd ff ff       	jmp    f01010d7 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01013d0:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01013d5:	0f 85 61 ff ff ff    	jne    f010133c <check_page_free_list+0x2e5>
f01013db:	e9 33 ff ff ff       	jmp    f0101313 <check_page_free_list+0x2bc>
f01013e0:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01013e5:	0f 85 4c ff ff ff    	jne    f0101337 <check_page_free_list+0x2e0>
f01013eb:	90                   	nop
f01013ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01013f0:	e9 1e ff ff ff       	jmp    f0101313 <check_page_free_list+0x2bc>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f01013f5:	83 c4 4c             	add    $0x4c,%esp
f01013f8:	5b                   	pop    %ebx
f01013f9:	5e                   	pop    %esi
f01013fa:	5f                   	pop    %edi
f01013fb:	5d                   	pop    %ebp
f01013fc:	c3                   	ret    

f01013fd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01013fd:	55                   	push   %ebp
f01013fe:	89 e5                	mov    %esp,%ebp
f0101400:	56                   	push   %esi
f0101401:	53                   	push   %ebx
f0101402:	83 ec 10             	sub    $0x10,%esp

	//Allocate [PGSIZE, npages_basemem*PGSIZE)
	size_t i;
	size_t mpentry  = (size_t) PGNUM(MPENTRY_PADDR);

	for (i = 1; i < npages_basemem; i++) {
f0101405:	8b 35 44 d2 2b f0    	mov    0xf02bd244,%esi
f010140b:	8b 1d 40 d2 2b f0    	mov    0xf02bd240,%ebx
f0101411:	b8 01 00 00 00       	mov    $0x1,%eax
f0101416:	eb 27                	jmp    f010143f <page_init+0x42>
		if(i == mpentry) continue;
f0101418:	83 f8 07             	cmp    $0x7,%eax
f010141b:	74 1f                	je     f010143c <page_init+0x3f>
f010141d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101424:	89 d1                	mov    %edx,%ecx
f0101426:	03 0d 9c de 2b f0    	add    0xf02bde9c,%ecx
f010142c:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101432:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101434:	89 d3                	mov    %edx,%ebx
f0101436:	03 1d 9c de 2b f0    	add    0xf02bde9c,%ebx

	//Allocate [PGSIZE, npages_basemem*PGSIZE)
	size_t i;
	size_t mpentry  = (size_t) PGNUM(MPENTRY_PADDR);

	for (i = 1; i < npages_basemem; i++) {
f010143c:	83 c0 01             	add    $0x1,%eax
f010143f:	39 f0                	cmp    %esi,%eax
f0101441:	72 d5                	jb     f0101418 <page_init+0x1b>
f0101443:	89 1d 40 d2 2b f0    	mov    %ebx,0xf02bd240
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	//Allocate the part of extended memory above the kernel's allocation
	i = (size_t) PGNUM(PADDR(boot_alloc(0)));
f0101449:	b8 00 00 00 00       	mov    $0x0,%eax
f010144e:	e8 ed fa ff ff       	call   f0100f40 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101453:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101458:	77 20                	ja     f010147a <page_init+0x7d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010145a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010145e:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0101465:	f0 
f0101466:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f010146d:	00 
f010146e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101475:	e8 c6 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010147a:	05 00 00 00 10       	add    $0x10000000,%eax
f010147f:	c1 e8 0c             	shr    $0xc,%eax
f0101482:	8b 1d 40 d2 2b f0    	mov    0xf02bd240,%ebx
f0101488:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	for(; i < npages; i++ ) {
f010148f:	eb 23                	jmp    f01014b4 <page_init+0xb7>
		if(i == mpentry) continue;
f0101491:	83 f8 07             	cmp    $0x7,%eax
f0101494:	74 18                	je     f01014ae <page_init+0xb1>
		pages[i].pp_ref = 0;
f0101496:	89 d1                	mov    %edx,%ecx
f0101498:	03 0d 9c de 2b f0    	add    0xf02bde9c,%ecx
f010149e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01014a4:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01014a6:	89 d3                	mov    %edx,%ebx
f01014a8:	03 1d 9c de 2b f0    	add    0xf02bde9c,%ebx
		page_free_list = &pages[i];
	}

	//Allocate the part of extended memory above the kernel's allocation
	i = (size_t) PGNUM(PADDR(boot_alloc(0)));
	for(; i < npages; i++ ) {
f01014ae:	83 c0 01             	add    $0x1,%eax
f01014b1:	83 c2 08             	add    $0x8,%edx
f01014b4:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f01014ba:	72 d5                	jb     f0101491 <page_init+0x94>
f01014bc:	89 1d 40 d2 2b f0    	mov    %ebx,0xf02bd240
		if(i == mpentry) continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01014c2:	83 c4 10             	add    $0x10,%esp
f01014c5:	5b                   	pop    %ebx
f01014c6:	5e                   	pop    %esi
f01014c7:	5d                   	pop    %ebp
f01014c8:	c3                   	ret    

f01014c9 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01014c9:	55                   	push   %ebp
f01014ca:	89 e5                	mov    %esp,%ebp
f01014cc:	53                   	push   %ebx
f01014cd:	83 ec 14             	sub    $0x14,%esp
	if(!page_free_list) return NULL;
f01014d0:	8b 1d 40 d2 2b f0    	mov    0xf02bd240,%ebx
f01014d6:	85 db                	test   %ebx,%ebx
f01014d8:	74 6f                	je     f0101549 <page_alloc+0x80>

	struct PageInfo* curPage = page_free_list;
	page_free_list = page_free_list->pp_link;
f01014da:	8b 03                	mov    (%ebx),%eax
f01014dc:	a3 40 d2 2b f0       	mov    %eax,0xf02bd240
	curPage->pp_link = NULL;
f01014e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO) {
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
	}

	return curPage;
f01014e7:	89 d8                	mov    %ebx,%eax

	struct PageInfo* curPage = page_free_list;
	page_free_list = page_free_list->pp_link;
	curPage->pp_link = NULL;

	if(alloc_flags & ALLOC_ZERO) {
f01014e9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014ed:	74 5f                	je     f010154e <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014ef:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f01014f5:	c1 f8 03             	sar    $0x3,%eax
f01014f8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014fb:	89 c2                	mov    %eax,%edx
f01014fd:	c1 ea 0c             	shr    $0xc,%edx
f0101500:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f0101506:	72 20                	jb     f0101528 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101508:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010150c:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0101513:	f0 
f0101514:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010151b:	00 
f010151c:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0101523:	e8 18 eb ff ff       	call   f0100040 <_panic>
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
f0101528:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010152f:	00 
f0101530:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101537:	00 
	return (void *)(pa + KERNBASE);
f0101538:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010153d:	89 04 24             	mov    %eax,(%esp)
f0101540:	e8 02 4e 00 00       	call   f0106347 <memset>
	}

	return curPage;
f0101545:	89 d8                	mov    %ebx,%eax
f0101547:	eb 05                	jmp    f010154e <page_alloc+0x85>
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if(!page_free_list) return NULL;
f0101549:	b8 00 00 00 00       	mov    $0x0,%eax
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
	}

	return curPage;
}
f010154e:	83 c4 14             	add    $0x14,%esp
f0101551:	5b                   	pop    %ebx
f0101552:	5d                   	pop    %ebp
f0101553:	c3                   	ret    

f0101554 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101554:	55                   	push   %ebp
f0101555:	89 e5                	mov    %esp,%ebp
f0101557:	83 ec 18             	sub    $0x18,%esp
f010155a:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0) {
f010155d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101562:	74 1c                	je     f0101580 <page_free+0x2c>
		panic("freeing a page in use\n");
f0101564:	c7 44 24 08 20 8e 10 	movl   $0xf0108e20,0x8(%esp)
f010156b:	f0 
f010156c:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0101573:	00 
f0101574:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010157b:	e8 c0 ea ff ff       	call   f0100040 <_panic>
	}
	if(pp->pp_link) {
f0101580:	83 38 00             	cmpl   $0x0,(%eax)
f0101583:	74 1c                	je     f01015a1 <page_free+0x4d>
		panic("page was already free\n");
f0101585:	c7 44 24 08 37 8e 10 	movl   $0xf0108e37,0x8(%esp)
f010158c:	f0 
f010158d:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0101594:	00 
f0101595:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010159c:	e8 9f ea ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f01015a1:	8b 15 40 d2 2b f0    	mov    0xf02bd240,%edx
f01015a7:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01015a9:	a3 40 d2 2b f0       	mov    %eax,0xf02bd240
}
f01015ae:	c9                   	leave  
f01015af:	c3                   	ret    

f01015b0 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	83 ec 18             	sub    $0x18,%esp
f01015b6:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01015b9:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01015bd:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01015c0:	66 89 50 04          	mov    %dx,0x4(%eax)
f01015c4:	66 85 d2             	test   %dx,%dx
f01015c7:	75 08                	jne    f01015d1 <page_decref+0x21>
		page_free(pp);
f01015c9:	89 04 24             	mov    %eax,(%esp)
f01015cc:	e8 83 ff ff ff       	call   f0101554 <page_free>
}
f01015d1:	c9                   	leave  
f01015d2:	c3                   	ret    

f01015d3 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01015d3:	55                   	push   %ebp
f01015d4:	89 e5                	mov    %esp,%ebp
f01015d6:	56                   	push   %esi
f01015d7:	53                   	push   %ebx
f01015d8:	83 ec 10             	sub    $0x10,%esp
f01015db:	8b 75 0c             	mov    0xc(%ebp),%esi
	//Read correct entry in page directory
	pde_t* dir_entry = pgdir + PDX(va); //Remember kids: va = la rn
f01015de:	89 f3                	mov    %esi,%ebx
f01015e0:	c1 eb 16             	shr    $0x16,%ebx
f01015e3:	c1 e3 02             	shl    $0x2,%ebx
f01015e6:	03 5d 08             	add    0x8(%ebp),%ebx

	if(!(*dir_entry & PTE_P)) {
f01015e9:	f6 03 01             	testb  $0x1,(%ebx)
f01015ec:	75 2c                	jne    f010161a <pgdir_walk+0x47>
		if(create) {
f01015ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015f2:	74 6c                	je     f0101660 <pgdir_walk+0x8d>
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
f01015f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015fb:	e8 c9 fe ff ff       	call   f01014c9 <page_alloc>
			if(!new_pg) return NULL;
f0101600:	85 c0                	test   %eax,%eax
f0101602:	74 63                	je     f0101667 <pgdir_walk+0x94>
			new_pg->pp_ref++;
f0101604:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101609:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f010160f:	c1 f8 03             	sar    $0x3,%eax
f0101612:	c1 e0 0c             	shl    $0xc,%eax
			*dir_entry = (page2pa(new_pg) | PTE_P | PTE_U |PTE_W);
f0101615:	83 c8 07             	or     $0x7,%eax
f0101618:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}

	//Convert pde to pte
	pte_t* tab_entry = (pte_t*)KADDR(PTE_ADDR(*dir_entry));
f010161a:	8b 03                	mov    (%ebx),%eax
f010161c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101621:	89 c2                	mov    %eax,%edx
f0101623:	c1 ea 0c             	shr    $0xc,%edx
f0101626:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f010162c:	72 20                	jb     f010164e <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101632:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0101639:	f0 
f010163a:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0101641:	00 
f0101642:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101649:	e8 f2 e9 ff ff       	call   f0100040 <_panic>

	//Add offset from va to read into the page table
	return tab_entry + PTX(va);
f010164e:	c1 ee 0a             	shr    $0xa,%esi
f0101651:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101657:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010165e:	eb 0c                	jmp    f010166c <pgdir_walk+0x99>
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
			if(!new_pg) return NULL;
			new_pg->pp_ref++;
			*dir_entry = (page2pa(new_pg) | PTE_P | PTE_U |PTE_W);
		} else return NULL;
f0101660:	b8 00 00 00 00       	mov    $0x0,%eax
f0101665:	eb 05                	jmp    f010166c <pgdir_walk+0x99>

	if(!(*dir_entry & PTE_P)) {
		if(create) {
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
			if(!new_pg) return NULL;
f0101667:	b8 00 00 00 00       	mov    $0x0,%eax
	//Convert pde to pte
	pte_t* tab_entry = (pte_t*)KADDR(PTE_ADDR(*dir_entry));

	//Add offset from va to read into the page table
	return tab_entry + PTX(va);
}
f010166c:	83 c4 10             	add    $0x10,%esp
f010166f:	5b                   	pop    %ebx
f0101670:	5e                   	pop    %esi
f0101671:	5d                   	pop    %ebp
f0101672:	c3                   	ret    

f0101673 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101673:	55                   	push   %ebp
f0101674:	89 e5                	mov    %esp,%ebp
f0101676:	57                   	push   %edi
f0101677:	56                   	push   %esi
f0101678:	53                   	push   %ebx
f0101679:	83 ec 2c             	sub    $0x2c,%esp
f010167c:	89 c7                	mov    %eax,%edi
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f010167e:	c1 e9 0c             	shr    $0xc,%ecx
f0101681:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101684:	89 d3                	mov    %edx,%ebx
f0101686:	be 00 00 00 00       	mov    $0x0,%esi
		pte = pgdir_walk(pgdir, (void*)(va + (i*PGSIZE)), 1);

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
f010168b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010168e:	83 c8 01             	or     $0x1,%eax
f0101691:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101694:	8b 45 08             	mov    0x8(%ebp),%eax
f0101697:	29 d0                	sub    %edx,%eax
f0101699:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f010169c:	eb 28                	jmp    f01016c6 <boot_map_region+0x53>
		pte = pgdir_walk(pgdir, (void*)(va + (i*PGSIZE)), 1);
f010169e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016a5:	00 
f01016a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016aa:	89 3c 24             	mov    %edi,(%esp)
f01016ad:	e8 21 ff ff ff       	call   f01015d3 <pgdir_walk>
f01016b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01016b5:	8d 14 19             	lea    (%ecx,%ebx,1),%edx

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
f01016b8:	0b 55 e0             	or     -0x20(%ebp),%edx
f01016bb:	89 10                	mov    %edx,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f01016bd:	83 c6 01             	add    $0x1,%esi
f01016c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016c6:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01016c9:	75 d3                	jne    f010169e <boot_map_region+0x2b>

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
	}
}
f01016cb:	83 c4 2c             	add    $0x2c,%esp
f01016ce:	5b                   	pop    %ebx
f01016cf:	5e                   	pop    %esi
f01016d0:	5f                   	pop    %edi
f01016d1:	5d                   	pop    %ebp
f01016d2:	c3                   	ret    

f01016d3 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01016d3:	55                   	push   %ebp
f01016d4:	89 e5                	mov    %esp,%ebp
f01016d6:	53                   	push   %ebx
f01016d7:	83 ec 14             	sub    $0x14,%esp
f01016da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir,va,0);
f01016dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016e4:	00 
f01016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ef:	89 04 24             	mov    %eax,(%esp)
f01016f2:	e8 dc fe ff ff       	call   f01015d3 <pgdir_walk>
	if((!pte) || !(*pte & PTE_P)) return NULL; // no page mapped here
f01016f7:	85 c0                	test   %eax,%eax
f01016f9:	74 3f                	je     f010173a <page_lookup+0x67>
f01016fb:	f6 00 01             	testb  $0x1,(%eax)
f01016fe:	74 41                	je     f0101741 <page_lookup+0x6e>

	if(pte_store) *pte_store = pte;
f0101700:	85 db                	test   %ebx,%ebx
f0101702:	74 02                	je     f0101706 <page_lookup+0x33>
f0101704:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101706:	8b 00                	mov    (%eax),%eax
f0101708:	c1 e8 0c             	shr    $0xc,%eax
f010170b:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0101711:	72 1c                	jb     f010172f <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101713:	c7 44 24 08 14 85 10 	movl   $0xf0108514,0x8(%esp)
f010171a:	f0 
f010171b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101722:	00 
f0101723:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f010172a:	e8 11 e9 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010172f:	8b 15 9c de 2b f0    	mov    0xf02bde9c,%edx
f0101735:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(*pte);
f0101738:	eb 0c                	jmp    f0101746 <page_lookup+0x73>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if((!pte) || !(*pte & PTE_P)) return NULL; // no page mapped here
f010173a:	b8 00 00 00 00       	mov    $0x0,%eax
f010173f:	eb 05                	jmp    f0101746 <page_lookup+0x73>
f0101741:	b8 00 00 00 00       	mov    $0x0,%eax

	if(pte_store) *pte_store = pte;

	return pa2page(*pte);
}
f0101746:	83 c4 14             	add    $0x14,%esp
f0101749:	5b                   	pop    %ebx
f010174a:	5d                   	pop    %ebp
f010174b:	c3                   	ret    

f010174c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010174c:	55                   	push   %ebp
f010174d:	89 e5                	mov    %esp,%ebp
f010174f:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101752:	e8 42 52 00 00       	call   f0106999 <cpunum>
f0101757:	6b c0 74             	imul   $0x74,%eax,%eax
f010175a:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0101761:	74 16                	je     f0101779 <tlb_invalidate+0x2d>
f0101763:	e8 31 52 00 00       	call   f0106999 <cpunum>
f0101768:	6b c0 74             	imul   $0x74,%eax,%eax
f010176b:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0101771:	8b 55 08             	mov    0x8(%ebp),%edx
f0101774:	39 50 60             	cmp    %edx,0x60(%eax)
f0101777:	75 06                	jne    f010177f <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010177c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010177f:	c9                   	leave  
f0101780:	c3                   	ret    

f0101781 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101781:	55                   	push   %ebp
f0101782:	89 e5                	mov    %esp,%ebp
f0101784:	56                   	push   %esi
f0101785:	53                   	push   %ebx
f0101786:	83 ec 20             	sub    $0x20,%esp
f0101789:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010178c:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f010178f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101792:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101796:	89 74 24 04          	mov    %esi,0x4(%esp)
f010179a:	89 1c 24             	mov    %ebx,(%esp)
f010179d:	e8 31 ff ff ff       	call   f01016d3 <page_lookup>

	if(!page) return; // page doesn't exist so exit silently
f01017a2:	85 c0                	test   %eax,%eax
f01017a4:	74 1d                	je     f01017c3 <page_remove+0x42>

	page_decref(page); //this method frees page if ref count reaches 0
f01017a6:	89 04 24             	mov    %eax,(%esp)
f01017a9:	e8 02 fe ff ff       	call   f01015b0 <page_decref>
	*pte = 0;
f01017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01017b7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017bb:	89 1c 24             	mov    %ebx,(%esp)
f01017be:	e8 89 ff ff ff       	call   f010174c <tlb_invalidate>
}
f01017c3:	83 c4 20             	add    $0x20,%esp
f01017c6:	5b                   	pop    %ebx
f01017c7:	5e                   	pop    %esi
f01017c8:	5d                   	pop    %ebp
f01017c9:	c3                   	ret    

f01017ca <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01017ca:	55                   	push   %ebp
f01017cb:	89 e5                	mov    %esp,%ebp
f01017cd:	57                   	push   %edi
f01017ce:	56                   	push   %esi
f01017cf:	53                   	push   %ebx
f01017d0:	83 ec 1c             	sub    $0x1c,%esp
f01017d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017d6:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01017d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01017e0:	00 
f01017e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01017e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01017e8:	89 04 24             	mov    %eax,(%esp)
f01017eb:	e8 e3 fd ff ff       	call   f01015d3 <pgdir_walk>
f01017f0:	89 c3                	mov    %eax,%ebx

	if(!pte) return -E_NO_MEM;
f01017f2:	85 c0                	test   %eax,%eax
f01017f4:	74 36                	je     f010182c <page_insert+0x62>

	// We increment pp_ref before page_remove to deal with the case
	// when a pp is re-inserted to the same virtual address in the 
	// same pgdir. Otherwise, page_remove would free the page.
	pp->pp_ref++;
f01017f6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	if(*pte & PTE_P) page_remove(pgdir, va);
f01017fb:	f6 00 01             	testb  $0x1,(%eax)
f01017fe:	74 0f                	je     f010180f <page_insert+0x45>
f0101800:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101804:	8b 45 08             	mov    0x8(%ebp),%eax
f0101807:	89 04 24             	mov    %eax,(%esp)
f010180a:	e8 72 ff ff ff       	call   f0101781 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f010180f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101812:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101815:	2b 35 9c de 2b f0    	sub    0xf02bde9c,%esi
f010181b:	c1 fe 03             	sar    $0x3,%esi
f010181e:	c1 e6 0c             	shl    $0xc,%esi
f0101821:	09 c6                	or     %eax,%esi
f0101823:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101825:	b8 00 00 00 00       	mov    $0x0,%eax
f010182a:	eb 05                	jmp    f0101831 <page_insert+0x67>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);

	if(!pte) return -E_NO_MEM;
f010182c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;

	if(*pte & PTE_P) page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101831:	83 c4 1c             	add    $0x1c,%esp
f0101834:	5b                   	pop    %ebx
f0101835:	5e                   	pop    %esi
f0101836:	5f                   	pop    %edi
f0101837:	5d                   	pop    %ebp
f0101838:	c3                   	ret    

f0101839 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101839:	55                   	push   %ebp
f010183a:	89 e5                	mov    %esp,%ebp
f010183c:	53                   	push   %ebx
f010183d:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size = ROUNDUP(size, PGSIZE);
f0101840:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101843:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101849:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if((base + size) > MMIOLIM) {
f010184f:	8b 15 00 53 12 f0    	mov    0xf0125300,%edx
f0101855:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101858:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010185d:	76 1c                	jbe    f010187b <mmio_map_region+0x42>
		panic("MMIO overflow!");
f010185f:	c7 44 24 08 4e 8e 10 	movl   $0xf0108e4e,0x8(%esp)
f0101866:	f0 
f0101867:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f010186e:	00 
f010186f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101876:	e8 c5 e7 ff ff       	call   f0100040 <_panic>
	}

	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010187b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101882:	00 
f0101883:	8b 45 08             	mov    0x8(%ebp),%eax
f0101886:	89 04 24             	mov    %eax,(%esp)
f0101889:	89 d9                	mov    %ebx,%ecx
f010188b:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0101890:	e8 de fd ff ff       	call   f0101673 <boot_map_region>
	uintptr_t ret = base;
f0101895:	a1 00 53 12 f0       	mov    0xf0125300,%eax
	base = base + size;
f010189a:	01 c3                	add    %eax,%ebx
f010189c:	89 1d 00 53 12 f0    	mov    %ebx,0xf0125300

	//cprintf("MMIO mapping address 0x%x\n", ret);
	return (void *) ret;
}
f01018a2:	83 c4 14             	add    $0x14,%esp
f01018a5:	5b                   	pop    %ebx
f01018a6:	5d                   	pop    %ebp
f01018a7:	c3                   	ret    

f01018a8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01018a8:	55                   	push   %ebp
f01018a9:	89 e5                	mov    %esp,%ebp
f01018ab:	57                   	push   %edi
f01018ac:	56                   	push   %esi
f01018ad:	53                   	push   %ebx
f01018ae:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01018b1:	b8 15 00 00 00       	mov    $0x15,%eax
f01018b6:	e8 bd f6 ff ff       	call   f0100f78 <nvram_read>
f01018bb:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01018bd:	b8 17 00 00 00       	mov    $0x17,%eax
f01018c2:	e8 b1 f6 ff ff       	call   f0100f78 <nvram_read>
f01018c7:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01018c9:	b8 34 00 00 00       	mov    $0x34,%eax
f01018ce:	e8 a5 f6 ff ff       	call   f0100f78 <nvram_read>
f01018d3:	c1 e0 06             	shl    $0x6,%eax
f01018d6:	89 c2                	mov    %eax,%edx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f01018d8:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01018de:	85 d2                	test   %edx,%edx
f01018e0:	75 0b                	jne    f01018ed <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01018e2:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01018e8:	85 f6                	test   %esi,%esi
f01018ea:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01018ed:	89 c2                	mov    %eax,%edx
f01018ef:	c1 ea 02             	shr    $0x2,%edx
f01018f2:	89 15 94 de 2b f0    	mov    %edx,0xf02bde94
	npages_basemem = basemem / (PGSIZE / 1024);
f01018f8:	89 da                	mov    %ebx,%edx
f01018fa:	c1 ea 02             	shr    $0x2,%edx
f01018fd:	89 15 44 d2 2b f0    	mov    %edx,0xf02bd244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101903:	89 c2                	mov    %eax,%edx
f0101905:	29 da                	sub    %ebx,%edx
f0101907:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010190b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010190f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101913:	c7 04 24 34 85 10 f0 	movl   $0xf0108534,(%esp)
f010191a:	e8 6a 29 00 00       	call   f0104289 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010191f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101924:	e8 17 f6 ff ff       	call   f0100f40 <boot_alloc>
f0101929:	a3 98 de 2b f0       	mov    %eax,0xf02bde98
	memset(kern_pgdir, 0, PGSIZE);
f010192e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101935:	00 
f0101936:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010193d:	00 
f010193e:	89 04 24             	mov    %eax,(%esp)
f0101941:	e8 01 4a 00 00       	call   f0106347 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101946:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010194b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101950:	77 20                	ja     f0101972 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101952:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101956:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f010195d:	f0 
f010195e:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101965:	00 
f0101966:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010196d:	e8 ce e6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101972:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101978:	83 ca 05             	or     $0x5,%edx
f010197b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101981:	a1 94 de 2b f0       	mov    0xf02bde94,%eax
f0101986:	c1 e0 03             	shl    $0x3,%eax
f0101989:	e8 b2 f5 ff ff       	call   f0100f40 <boot_alloc>
f010198e:	a3 9c de 2b f0       	mov    %eax,0xf02bde9c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101993:	8b 0d 94 de 2b f0    	mov    0xf02bde94,%ecx
f0101999:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01019a0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019ab:	00 
f01019ac:	89 04 24             	mov    %eax,(%esp)
f01019af:	e8 93 49 00 00       	call   f0106347 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01019b4:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01019b9:	e8 82 f5 ff ff       	call   f0100f40 <boot_alloc>
f01019be:	a3 48 d2 2b f0       	mov    %eax,0xf02bd248
	memset(pages, 0, NENV*sizeof(struct Env));
f01019c3:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01019ca:	00 
f01019cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019d2:	00 
f01019d3:	a1 9c de 2b f0       	mov    0xf02bde9c,%eax
f01019d8:	89 04 24             	mov    %eax,(%esp)
f01019db:	e8 67 49 00 00       	call   f0106347 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01019e0:	e8 18 fa ff ff       	call   f01013fd <page_init>

	check_page_free_list(1);
f01019e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01019ea:	e8 68 f6 ff ff       	call   f0101057 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01019ef:	83 3d 9c de 2b f0 00 	cmpl   $0x0,0xf02bde9c
f01019f6:	75 1c                	jne    f0101a14 <mem_init+0x16c>
		panic("'pages' is a null pointer!");
f01019f8:	c7 44 24 08 5d 8e 10 	movl   $0xf0108e5d,0x8(%esp)
f01019ff:	f0 
f0101a00:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101a07:	00 
f0101a08:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101a0f:	e8 2c e6 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a14:	a1 40 d2 2b f0       	mov    0xf02bd240,%eax
f0101a19:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a1e:	eb 05                	jmp    f0101a25 <mem_init+0x17d>
		++nfree;
f0101a20:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a23:	8b 00                	mov    (%eax),%eax
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	75 f7                	jne    f0101a20 <mem_init+0x178>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a30:	e8 94 fa ff ff       	call   f01014c9 <page_alloc>
f0101a35:	89 c7                	mov    %eax,%edi
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	75 24                	jne    f0101a5f <mem_init+0x1b7>
f0101a3b:	c7 44 24 0c 78 8e 10 	movl   $0xf0108e78,0xc(%esp)
f0101a42:	f0 
f0101a43:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101a4a:	f0 
f0101a4b:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101a52:	00 
f0101a53:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101a5a:	e8 e1 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a66:	e8 5e fa ff ff       	call   f01014c9 <page_alloc>
f0101a6b:	89 c6                	mov    %eax,%esi
f0101a6d:	85 c0                	test   %eax,%eax
f0101a6f:	75 24                	jne    f0101a95 <mem_init+0x1ed>
f0101a71:	c7 44 24 0c 8e 8e 10 	movl   $0xf0108e8e,0xc(%esp)
f0101a78:	f0 
f0101a79:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101a80:	f0 
f0101a81:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101a88:	00 
f0101a89:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101a90:	e8 ab e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a9c:	e8 28 fa ff ff       	call   f01014c9 <page_alloc>
f0101aa1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	75 24                	jne    f0101acc <mem_init+0x224>
f0101aa8:	c7 44 24 0c a4 8e 10 	movl   $0xf0108ea4,0xc(%esp)
f0101aaf:	f0 
f0101ab0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101ab7:	f0 
f0101ab8:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101abf:	00 
f0101ac0:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101ac7:	e8 74 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101acc:	39 f7                	cmp    %esi,%edi
f0101ace:	75 24                	jne    f0101af4 <mem_init+0x24c>
f0101ad0:	c7 44 24 0c ba 8e 10 	movl   $0xf0108eba,0xc(%esp)
f0101ad7:	f0 
f0101ad8:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101adf:	f0 
f0101ae0:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101ae7:	00 
f0101ae8:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101aef:	e8 4c e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101af4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101af7:	39 c6                	cmp    %eax,%esi
f0101af9:	74 04                	je     f0101aff <mem_init+0x257>
f0101afb:	39 c7                	cmp    %eax,%edi
f0101afd:	75 24                	jne    f0101b23 <mem_init+0x27b>
f0101aff:	c7 44 24 0c 70 85 10 	movl   $0xf0108570,0xc(%esp)
f0101b06:	f0 
f0101b07:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101b0e:	f0 
f0101b0f:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101b16:	00 
f0101b17:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101b1e:	e8 1d e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b23:	8b 15 9c de 2b f0    	mov    0xf02bde9c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b29:	a1 94 de 2b f0       	mov    0xf02bde94,%eax
f0101b2e:	c1 e0 0c             	shl    $0xc,%eax
f0101b31:	89 f9                	mov    %edi,%ecx
f0101b33:	29 d1                	sub    %edx,%ecx
f0101b35:	c1 f9 03             	sar    $0x3,%ecx
f0101b38:	c1 e1 0c             	shl    $0xc,%ecx
f0101b3b:	39 c1                	cmp    %eax,%ecx
f0101b3d:	72 24                	jb     f0101b63 <mem_init+0x2bb>
f0101b3f:	c7 44 24 0c cc 8e 10 	movl   $0xf0108ecc,0xc(%esp)
f0101b46:	f0 
f0101b47:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101b4e:	f0 
f0101b4f:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101b56:	00 
f0101b57:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101b5e:	e8 dd e4 ff ff       	call   f0100040 <_panic>
f0101b63:	89 f1                	mov    %esi,%ecx
f0101b65:	29 d1                	sub    %edx,%ecx
f0101b67:	c1 f9 03             	sar    $0x3,%ecx
f0101b6a:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b6d:	39 c8                	cmp    %ecx,%eax
f0101b6f:	77 24                	ja     f0101b95 <mem_init+0x2ed>
f0101b71:	c7 44 24 0c e9 8e 10 	movl   $0xf0108ee9,0xc(%esp)
f0101b78:	f0 
f0101b79:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101b80:	f0 
f0101b81:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101b88:	00 
f0101b89:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101b90:	e8 ab e4 ff ff       	call   f0100040 <_panic>
f0101b95:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b98:	29 d1                	sub    %edx,%ecx
f0101b9a:	89 ca                	mov    %ecx,%edx
f0101b9c:	c1 fa 03             	sar    $0x3,%edx
f0101b9f:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ba2:	39 d0                	cmp    %edx,%eax
f0101ba4:	77 24                	ja     f0101bca <mem_init+0x322>
f0101ba6:	c7 44 24 0c 06 8f 10 	movl   $0xf0108f06,0xc(%esp)
f0101bad:	f0 
f0101bae:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101bb5:	f0 
f0101bb6:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101bbd:	00 
f0101bbe:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101bc5:	e8 76 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bca:	a1 40 d2 2b f0       	mov    0xf02bd240,%eax
f0101bcf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bd2:	c7 05 40 d2 2b f0 00 	movl   $0x0,0xf02bd240
f0101bd9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be3:	e8 e1 f8 ff ff       	call   f01014c9 <page_alloc>
f0101be8:	85 c0                	test   %eax,%eax
f0101bea:	74 24                	je     f0101c10 <mem_init+0x368>
f0101bec:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f0101bf3:	f0 
f0101bf4:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101c03:	00 
f0101c04:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101c0b:	e8 30 e4 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c10:	89 3c 24             	mov    %edi,(%esp)
f0101c13:	e8 3c f9 ff ff       	call   f0101554 <page_free>
	page_free(pp1);
f0101c18:	89 34 24             	mov    %esi,(%esp)
f0101c1b:	e8 34 f9 ff ff       	call   f0101554 <page_free>
	page_free(pp2);
f0101c20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c23:	89 04 24             	mov    %eax,(%esp)
f0101c26:	e8 29 f9 ff ff       	call   f0101554 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c32:	e8 92 f8 ff ff       	call   f01014c9 <page_alloc>
f0101c37:	89 c6                	mov    %eax,%esi
f0101c39:	85 c0                	test   %eax,%eax
f0101c3b:	75 24                	jne    f0101c61 <mem_init+0x3b9>
f0101c3d:	c7 44 24 0c 78 8e 10 	movl   $0xf0108e78,0xc(%esp)
f0101c44:	f0 
f0101c45:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101c4c:	f0 
f0101c4d:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101c54:	00 
f0101c55:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101c5c:	e8 df e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c68:	e8 5c f8 ff ff       	call   f01014c9 <page_alloc>
f0101c6d:	89 c7                	mov    %eax,%edi
f0101c6f:	85 c0                	test   %eax,%eax
f0101c71:	75 24                	jne    f0101c97 <mem_init+0x3ef>
f0101c73:	c7 44 24 0c 8e 8e 10 	movl   $0xf0108e8e,0xc(%esp)
f0101c7a:	f0 
f0101c7b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101c82:	f0 
f0101c83:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101c8a:	00 
f0101c8b:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101c92:	e8 a9 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c9e:	e8 26 f8 ff ff       	call   f01014c9 <page_alloc>
f0101ca3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ca6:	85 c0                	test   %eax,%eax
f0101ca8:	75 24                	jne    f0101cce <mem_init+0x426>
f0101caa:	c7 44 24 0c a4 8e 10 	movl   $0xf0108ea4,0xc(%esp)
f0101cb1:	f0 
f0101cb2:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101cc1:	00 
f0101cc2:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101cc9:	e8 72 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cce:	39 fe                	cmp    %edi,%esi
f0101cd0:	75 24                	jne    f0101cf6 <mem_init+0x44e>
f0101cd2:	c7 44 24 0c ba 8e 10 	movl   $0xf0108eba,0xc(%esp)
f0101cd9:	f0 
f0101cda:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101ce1:	f0 
f0101ce2:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101ce9:	00 
f0101cea:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101cf1:	e8 4a e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cf9:	39 c7                	cmp    %eax,%edi
f0101cfb:	74 04                	je     f0101d01 <mem_init+0x459>
f0101cfd:	39 c6                	cmp    %eax,%esi
f0101cff:	75 24                	jne    f0101d25 <mem_init+0x47d>
f0101d01:	c7 44 24 0c 70 85 10 	movl   $0xf0108570,0xc(%esp)
f0101d08:	f0 
f0101d09:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101d10:	f0 
f0101d11:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101d18:	00 
f0101d19:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101d20:	e8 1b e3 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d2c:	e8 98 f7 ff ff       	call   f01014c9 <page_alloc>
f0101d31:	85 c0                	test   %eax,%eax
f0101d33:	74 24                	je     f0101d59 <mem_init+0x4b1>
f0101d35:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f0101d3c:	f0 
f0101d3d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101d44:	f0 
f0101d45:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101d4c:	00 
f0101d4d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101d54:	e8 e7 e2 ff ff       	call   f0100040 <_panic>
f0101d59:	89 f0                	mov    %esi,%eax
f0101d5b:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f0101d61:	c1 f8 03             	sar    $0x3,%eax
f0101d64:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d67:	89 c2                	mov    %eax,%edx
f0101d69:	c1 ea 0c             	shr    $0xc,%edx
f0101d6c:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f0101d72:	72 20                	jb     f0101d94 <mem_init+0x4ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d78:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0101d7f:	f0 
f0101d80:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101d87:	00 
f0101d88:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0101d8f:	e8 ac e2 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d94:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d9b:	00 
f0101d9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101da3:	00 
	return (void *)(pa + KERNBASE);
f0101da4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101da9:	89 04 24             	mov    %eax,(%esp)
f0101dac:	e8 96 45 00 00       	call   f0106347 <memset>
	page_free(pp0);
f0101db1:	89 34 24             	mov    %esi,(%esp)
f0101db4:	e8 9b f7 ff ff       	call   f0101554 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101db9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101dc0:	e8 04 f7 ff ff       	call   f01014c9 <page_alloc>
f0101dc5:	85 c0                	test   %eax,%eax
f0101dc7:	75 24                	jne    f0101ded <mem_init+0x545>
f0101dc9:	c7 44 24 0c 32 8f 10 	movl   $0xf0108f32,0xc(%esp)
f0101dd0:	f0 
f0101dd1:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101dd8:	f0 
f0101dd9:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101de0:	00 
f0101de1:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101de8:	e8 53 e2 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101ded:	39 c6                	cmp    %eax,%esi
f0101def:	74 24                	je     f0101e15 <mem_init+0x56d>
f0101df1:	c7 44 24 0c 50 8f 10 	movl   $0xf0108f50,0xc(%esp)
f0101df8:	f0 
f0101df9:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101e00:	f0 
f0101e01:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101e08:	00 
f0101e09:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101e10:	e8 2b e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e15:	89 f0                	mov    %esi,%eax
f0101e17:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f0101e1d:	c1 f8 03             	sar    $0x3,%eax
f0101e20:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e23:	89 c2                	mov    %eax,%edx
f0101e25:	c1 ea 0c             	shr    $0xc,%edx
f0101e28:	3b 15 94 de 2b f0    	cmp    0xf02bde94,%edx
f0101e2e:	72 20                	jb     f0101e50 <mem_init+0x5a8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e34:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0101e3b:	f0 
f0101e3c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e43:	00 
f0101e44:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0101e4b:	e8 f0 e1 ff ff       	call   f0100040 <_panic>
f0101e50:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101e56:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e5c:	80 38 00             	cmpb   $0x0,(%eax)
f0101e5f:	74 24                	je     f0101e85 <mem_init+0x5dd>
f0101e61:	c7 44 24 0c 60 8f 10 	movl   $0xf0108f60,0xc(%esp)
f0101e68:	f0 
f0101e69:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101e70:	f0 
f0101e71:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101e78:	00 
f0101e79:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101e80:	e8 bb e1 ff ff       	call   f0100040 <_panic>
f0101e85:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101e88:	39 d0                	cmp    %edx,%eax
f0101e8a:	75 d0                	jne    f0101e5c <mem_init+0x5b4>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e8f:	a3 40 d2 2b f0       	mov    %eax,0xf02bd240

	// free the pages we took
	page_free(pp0);
f0101e94:	89 34 24             	mov    %esi,(%esp)
f0101e97:	e8 b8 f6 ff ff       	call   f0101554 <page_free>
	page_free(pp1);
f0101e9c:	89 3c 24             	mov    %edi,(%esp)
f0101e9f:	e8 b0 f6 ff ff       	call   f0101554 <page_free>
	page_free(pp2);
f0101ea4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea7:	89 04 24             	mov    %eax,(%esp)
f0101eaa:	e8 a5 f6 ff ff       	call   f0101554 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101eaf:	a1 40 d2 2b f0       	mov    0xf02bd240,%eax
f0101eb4:	eb 05                	jmp    f0101ebb <mem_init+0x613>
		--nfree;
f0101eb6:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101eb9:	8b 00                	mov    (%eax),%eax
f0101ebb:	85 c0                	test   %eax,%eax
f0101ebd:	75 f7                	jne    f0101eb6 <mem_init+0x60e>
		--nfree;
	assert(nfree == 0);
f0101ebf:	85 db                	test   %ebx,%ebx
f0101ec1:	74 24                	je     f0101ee7 <mem_init+0x63f>
f0101ec3:	c7 44 24 0c 6a 8f 10 	movl   $0xf0108f6a,0xc(%esp)
f0101eca:	f0 
f0101ecb:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101eda:	00 
f0101edb:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101ee2:	e8 59 e1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101ee7:	c7 04 24 90 85 10 f0 	movl   $0xf0108590,(%esp)
f0101eee:	e8 96 23 00 00       	call   f0104289 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101efa:	e8 ca f5 ff ff       	call   f01014c9 <page_alloc>
f0101eff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f02:	85 c0                	test   %eax,%eax
f0101f04:	75 24                	jne    f0101f2a <mem_init+0x682>
f0101f06:	c7 44 24 0c 78 8e 10 	movl   $0xf0108e78,0xc(%esp)
f0101f0d:	f0 
f0101f0e:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101f15:	f0 
f0101f16:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101f1d:	00 
f0101f1e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101f25:	e8 16 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f31:	e8 93 f5 ff ff       	call   f01014c9 <page_alloc>
f0101f36:	89 c3                	mov    %eax,%ebx
f0101f38:	85 c0                	test   %eax,%eax
f0101f3a:	75 24                	jne    f0101f60 <mem_init+0x6b8>
f0101f3c:	c7 44 24 0c 8e 8e 10 	movl   $0xf0108e8e,0xc(%esp)
f0101f43:	f0 
f0101f44:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101f4b:	f0 
f0101f4c:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101f53:	00 
f0101f54:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101f5b:	e8 e0 e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f67:	e8 5d f5 ff ff       	call   f01014c9 <page_alloc>
f0101f6c:	89 c6                	mov    %eax,%esi
f0101f6e:	85 c0                	test   %eax,%eax
f0101f70:	75 24                	jne    f0101f96 <mem_init+0x6ee>
f0101f72:	c7 44 24 0c a4 8e 10 	movl   $0xf0108ea4,0xc(%esp)
f0101f79:	f0 
f0101f7a:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101f81:	f0 
f0101f82:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101f89:	00 
f0101f8a:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101f91:	e8 aa e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f96:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101f99:	75 24                	jne    f0101fbf <mem_init+0x717>
f0101f9b:	c7 44 24 0c ba 8e 10 	movl   $0xf0108eba,0xc(%esp)
f0101fa2:	f0 
f0101fa3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101faa:	f0 
f0101fab:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101fb2:	00 
f0101fb3:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101fba:	e8 81 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fbf:	39 c3                	cmp    %eax,%ebx
f0101fc1:	74 05                	je     f0101fc8 <mem_init+0x720>
f0101fc3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101fc6:	75 24                	jne    f0101fec <mem_init+0x744>
f0101fc8:	c7 44 24 0c 70 85 10 	movl   $0xf0108570,0xc(%esp)
f0101fcf:	f0 
f0101fd0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0101fd7:	f0 
f0101fd8:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101fdf:	00 
f0101fe0:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0101fe7:	e8 54 e0 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101fec:	a1 40 d2 2b f0       	mov    0xf02bd240,%eax
f0101ff1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ff4:	c7 05 40 d2 2b f0 00 	movl   $0x0,0xf02bd240
f0101ffb:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ffe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102005:	e8 bf f4 ff ff       	call   f01014c9 <page_alloc>
f010200a:	85 c0                	test   %eax,%eax
f010200c:	74 24                	je     f0102032 <mem_init+0x78a>
f010200e:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f0102015:	f0 
f0102016:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010201d:	f0 
f010201e:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102025:	00 
f0102026:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010202d:	e8 0e e0 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102032:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102035:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102039:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102040:	00 
f0102041:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102046:	89 04 24             	mov    %eax,(%esp)
f0102049:	e8 85 f6 ff ff       	call   f01016d3 <page_lookup>
f010204e:	85 c0                	test   %eax,%eax
f0102050:	74 24                	je     f0102076 <mem_init+0x7ce>
f0102052:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0102059:	f0 
f010205a:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102061:	f0 
f0102062:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102069:	00 
f010206a:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102071:	e8 ca df ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102076:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010207d:	00 
f010207e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102085:	00 
f0102086:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010208a:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010208f:	89 04 24             	mov    %eax,(%esp)
f0102092:	e8 33 f7 ff ff       	call   f01017ca <page_insert>
f0102097:	85 c0                	test   %eax,%eax
f0102099:	78 24                	js     f01020bf <mem_init+0x817>
f010209b:	c7 44 24 0c e8 85 10 	movl   $0xf01085e8,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01020ba:	e8 81 df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01020bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c2:	89 04 24             	mov    %eax,(%esp)
f01020c5:	e8 8a f4 ff ff       	call   f0101554 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01020ca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020d1:	00 
f01020d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020d9:	00 
f01020da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020de:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01020e3:	89 04 24             	mov    %eax,(%esp)
f01020e6:	e8 df f6 ff ff       	call   f01017ca <page_insert>
f01020eb:	85 c0                	test   %eax,%eax
f01020ed:	74 24                	je     f0102113 <mem_init+0x86b>
f01020ef:	c7 44 24 0c 18 86 10 	movl   $0xf0108618,0xc(%esp)
f01020f6:	f0 
f01020f7:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01020fe:	f0 
f01020ff:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102106:	00 
f0102107:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010210e:	e8 2d df ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102113:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102119:	a1 9c de 2b f0       	mov    0xf02bde9c,%eax
f010211e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102121:	8b 17                	mov    (%edi),%edx
f0102123:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102129:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010212c:	29 c1                	sub    %eax,%ecx
f010212e:	89 c8                	mov    %ecx,%eax
f0102130:	c1 f8 03             	sar    $0x3,%eax
f0102133:	c1 e0 0c             	shl    $0xc,%eax
f0102136:	39 c2                	cmp    %eax,%edx
f0102138:	74 24                	je     f010215e <mem_init+0x8b6>
f010213a:	c7 44 24 0c 48 86 10 	movl   $0xf0108648,0xc(%esp)
f0102141:	f0 
f0102142:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102149:	f0 
f010214a:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102151:	00 
f0102152:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102159:	e8 e2 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010215e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102163:	89 f8                	mov    %edi,%eax
f0102165:	e8 7e ee ff ff       	call   f0100fe8 <check_va2pa>
f010216a:	89 da                	mov    %ebx,%edx
f010216c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010216f:	c1 fa 03             	sar    $0x3,%edx
f0102172:	c1 e2 0c             	shl    $0xc,%edx
f0102175:	39 d0                	cmp    %edx,%eax
f0102177:	74 24                	je     f010219d <mem_init+0x8f5>
f0102179:	c7 44 24 0c 70 86 10 	movl   $0xf0108670,0xc(%esp)
f0102180:	f0 
f0102181:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102188:	f0 
f0102189:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102190:	00 
f0102191:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102198:	e8 a3 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010219d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021a2:	74 24                	je     f01021c8 <mem_init+0x920>
f01021a4:	c7 44 24 0c 75 8f 10 	movl   $0xf0108f75,0xc(%esp)
f01021ab:	f0 
f01021ac:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01021b3:	f0 
f01021b4:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f01021bb:	00 
f01021bc:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01021c3:	e8 78 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01021c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021cb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021d0:	74 24                	je     f01021f6 <mem_init+0x94e>
f01021d2:	c7 44 24 0c 86 8f 10 	movl   $0xf0108f86,0xc(%esp)
f01021d9:	f0 
f01021da:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01021e1:	f0 
f01021e2:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01021e9:	00 
f01021ea:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01021f1:	e8 4a de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021f6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021fd:	00 
f01021fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102205:	00 
f0102206:	89 74 24 04          	mov    %esi,0x4(%esp)
f010220a:	89 3c 24             	mov    %edi,(%esp)
f010220d:	e8 b8 f5 ff ff       	call   f01017ca <page_insert>
f0102212:	85 c0                	test   %eax,%eax
f0102214:	74 24                	je     f010223a <mem_init+0x992>
f0102216:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f010221d:	f0 
f010221e:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102225:	f0 
f0102226:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f010222d:	00 
f010222e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102235:	e8 06 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010223a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010223f:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102244:	e8 9f ed ff ff       	call   f0100fe8 <check_va2pa>
f0102249:	89 f2                	mov    %esi,%edx
f010224b:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f0102251:	c1 fa 03             	sar    $0x3,%edx
f0102254:	c1 e2 0c             	shl    $0xc,%edx
f0102257:	39 d0                	cmp    %edx,%eax
f0102259:	74 24                	je     f010227f <mem_init+0x9d7>
f010225b:	c7 44 24 0c dc 86 10 	movl   $0xf01086dc,0xc(%esp)
f0102262:	f0 
f0102263:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010226a:	f0 
f010226b:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102272:	00 
f0102273:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010227a:	e8 c1 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010227f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102284:	74 24                	je     f01022aa <mem_init+0xa02>
f0102286:	c7 44 24 0c 97 8f 10 	movl   $0xf0108f97,0xc(%esp)
f010228d:	f0 
f010228e:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102295:	f0 
f0102296:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f010229d:	00 
f010229e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01022a5:	e8 96 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022b1:	e8 13 f2 ff ff       	call   f01014c9 <page_alloc>
f01022b6:	85 c0                	test   %eax,%eax
f01022b8:	74 24                	je     f01022de <mem_init+0xa36>
f01022ba:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01022c9:	f0 
f01022ca:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01022d1:	00 
f01022d2:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01022d9:	e8 62 dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022de:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022e5:	00 
f01022e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022ed:	00 
f01022ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022f2:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01022f7:	89 04 24             	mov    %eax,(%esp)
f01022fa:	e8 cb f4 ff ff       	call   f01017ca <page_insert>
f01022ff:	85 c0                	test   %eax,%eax
f0102301:	74 24                	je     f0102327 <mem_init+0xa7f>
f0102303:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f010230a:	f0 
f010230b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102322:	e8 19 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102327:	ba 00 10 00 00       	mov    $0x1000,%edx
f010232c:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102331:	e8 b2 ec ff ff       	call   f0100fe8 <check_va2pa>
f0102336:	89 f2                	mov    %esi,%edx
f0102338:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f010233e:	c1 fa 03             	sar    $0x3,%edx
f0102341:	c1 e2 0c             	shl    $0xc,%edx
f0102344:	39 d0                	cmp    %edx,%eax
f0102346:	74 24                	je     f010236c <mem_init+0xac4>
f0102348:	c7 44 24 0c dc 86 10 	movl   $0xf01086dc,0xc(%esp)
f010234f:	f0 
f0102350:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102357:	f0 
f0102358:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010235f:	00 
f0102360:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010236c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102371:	74 24                	je     f0102397 <mem_init+0xaef>
f0102373:	c7 44 24 0c 97 8f 10 	movl   $0xf0108f97,0xc(%esp)
f010237a:	f0 
f010237b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102382:	f0 
f0102383:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f010238a:	00 
f010238b:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102392:	e8 a9 dc ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102397:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010239e:	e8 26 f1 ff ff       	call   f01014c9 <page_alloc>
f01023a3:	85 c0                	test   %eax,%eax
f01023a5:	74 24                	je     f01023cb <mem_init+0xb23>
f01023a7:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f01023ae:	f0 
f01023af:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01023b6:	f0 
f01023b7:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01023be:	00 
f01023bf:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01023cb:	8b 15 98 de 2b f0    	mov    0xf02bde98,%edx
f01023d1:	8b 02                	mov    (%edx),%eax
f01023d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d8:	89 c1                	mov    %eax,%ecx
f01023da:	c1 e9 0c             	shr    $0xc,%ecx
f01023dd:	3b 0d 94 de 2b f0    	cmp    0xf02bde94,%ecx
f01023e3:	72 20                	jb     f0102405 <mem_init+0xb5d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023e9:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f01023f0:	f0 
f01023f1:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f01023f8:	00 
f01023f9:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102400:	e8 3b dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102405:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010240a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010240d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102414:	00 
f0102415:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010241c:	00 
f010241d:	89 14 24             	mov    %edx,(%esp)
f0102420:	e8 ae f1 ff ff       	call   f01015d3 <pgdir_walk>
f0102425:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102428:	8d 51 04             	lea    0x4(%ecx),%edx
f010242b:	39 d0                	cmp    %edx,%eax
f010242d:	74 24                	je     f0102453 <mem_init+0xbab>
f010242f:	c7 44 24 0c 0c 87 10 	movl   $0xf010870c,0xc(%esp)
f0102436:	f0 
f0102437:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010243e:	f0 
f010243f:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102446:	00 
f0102447:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102453:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010245a:	00 
f010245b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102462:	00 
f0102463:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102467:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010246c:	89 04 24             	mov    %eax,(%esp)
f010246f:	e8 56 f3 ff ff       	call   f01017ca <page_insert>
f0102474:	85 c0                	test   %eax,%eax
f0102476:	74 24                	je     f010249c <mem_init+0xbf4>
f0102478:	c7 44 24 0c 4c 87 10 	movl   $0xf010874c,0xc(%esp)
f010247f:	f0 
f0102480:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102487:	f0 
f0102488:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010248f:	00 
f0102490:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102497:	e8 a4 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010249c:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
f01024a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024a7:	89 f8                	mov    %edi,%eax
f01024a9:	e8 3a eb ff ff       	call   f0100fe8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ae:	89 f2                	mov    %esi,%edx
f01024b0:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f01024b6:	c1 fa 03             	sar    $0x3,%edx
f01024b9:	c1 e2 0c             	shl    $0xc,%edx
f01024bc:	39 d0                	cmp    %edx,%eax
f01024be:	74 24                	je     f01024e4 <mem_init+0xc3c>
f01024c0:	c7 44 24 0c dc 86 10 	movl   $0xf01086dc,0xc(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01024cf:	f0 
f01024d0:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01024d7:	00 
f01024d8:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01024df:	e8 5c db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024e4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024e9:	74 24                	je     f010250f <mem_init+0xc67>
f01024eb:	c7 44 24 0c 97 8f 10 	movl   $0xf0108f97,0xc(%esp)
f01024f2:	f0 
f01024f3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01024fa:	f0 
f01024fb:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0102502:	00 
f0102503:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010250a:	e8 31 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010250f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102516:	00 
f0102517:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010251e:	00 
f010251f:	89 3c 24             	mov    %edi,(%esp)
f0102522:	e8 ac f0 ff ff       	call   f01015d3 <pgdir_walk>
f0102527:	f6 00 04             	testb  $0x4,(%eax)
f010252a:	75 24                	jne    f0102550 <mem_init+0xca8>
f010252c:	c7 44 24 0c 8c 87 10 	movl   $0xf010878c,0xc(%esp)
f0102533:	f0 
f0102534:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010253b:	f0 
f010253c:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0102543:	00 
f0102544:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102550:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102555:	f6 00 04             	testb  $0x4,(%eax)
f0102558:	75 24                	jne    f010257e <mem_init+0xcd6>
f010255a:	c7 44 24 0c a8 8f 10 	movl   $0xf0108fa8,0xc(%esp)
f0102561:	f0 
f0102562:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102569:	f0 
f010256a:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102571:	00 
f0102572:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102579:	e8 c2 da ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010257e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102585:	00 
f0102586:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010258d:	00 
f010258e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102592:	89 04 24             	mov    %eax,(%esp)
f0102595:	e8 30 f2 ff ff       	call   f01017ca <page_insert>
f010259a:	85 c0                	test   %eax,%eax
f010259c:	74 24                	je     f01025c2 <mem_init+0xd1a>
f010259e:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f01025a5:	f0 
f01025a6:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01025ad:	f0 
f01025ae:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01025b5:	00 
f01025b6:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01025bd:	e8 7e da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025c9:	00 
f01025ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025d1:	00 
f01025d2:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01025d7:	89 04 24             	mov    %eax,(%esp)
f01025da:	e8 f4 ef ff ff       	call   f01015d3 <pgdir_walk>
f01025df:	f6 00 02             	testb  $0x2,(%eax)
f01025e2:	75 24                	jne    f0102608 <mem_init+0xd60>
f01025e4:	c7 44 24 0c c0 87 10 	movl   $0xf01087c0,0xc(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01025f3:	f0 
f01025f4:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01025fb:	00 
f01025fc:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102608:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010260f:	00 
f0102610:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102617:	00 
f0102618:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010261d:	89 04 24             	mov    %eax,(%esp)
f0102620:	e8 ae ef ff ff       	call   f01015d3 <pgdir_walk>
f0102625:	f6 00 04             	testb  $0x4,(%eax)
f0102628:	74 24                	je     f010264e <mem_init+0xda6>
f010262a:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f0102631:	f0 
f0102632:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102639:	f0 
f010263a:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0102641:	00 
f0102642:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102649:	e8 f2 d9 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010264e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102655:	00 
f0102656:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010265d:	00 
f010265e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102661:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102665:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010266a:	89 04 24             	mov    %eax,(%esp)
f010266d:	e8 58 f1 ff ff       	call   f01017ca <page_insert>
f0102672:	85 c0                	test   %eax,%eax
f0102674:	78 24                	js     f010269a <mem_init+0xdf2>
f0102676:	c7 44 24 0c 2c 88 10 	movl   $0xf010882c,0xc(%esp)
f010267d:	f0 
f010267e:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102685:	f0 
f0102686:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010268d:	00 
f010268e:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102695:	e8 a6 d9 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010269a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026a1:	00 
f01026a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026a9:	00 
f01026aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026ae:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01026b3:	89 04 24             	mov    %eax,(%esp)
f01026b6:	e8 0f f1 ff ff       	call   f01017ca <page_insert>
f01026bb:	85 c0                	test   %eax,%eax
f01026bd:	74 24                	je     f01026e3 <mem_init+0xe3b>
f01026bf:	c7 44 24 0c 64 88 10 	movl   $0xf0108864,0xc(%esp)
f01026c6:	f0 
f01026c7:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01026ce:	f0 
f01026cf:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01026d6:	00 
f01026d7:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01026de:	e8 5d d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026ea:	00 
f01026eb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026f2:	00 
f01026f3:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01026f8:	89 04 24             	mov    %eax,(%esp)
f01026fb:	e8 d3 ee ff ff       	call   f01015d3 <pgdir_walk>
f0102700:	f6 00 04             	testb  $0x4,(%eax)
f0102703:	74 24                	je     f0102729 <mem_init+0xe81>
f0102705:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f010270c:	f0 
f010270d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102714:	f0 
f0102715:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f010271c:	00 
f010271d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102724:	e8 17 d9 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102729:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
f010272f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102734:	89 f8                	mov    %edi,%eax
f0102736:	e8 ad e8 ff ff       	call   f0100fe8 <check_va2pa>
f010273b:	89 c1                	mov    %eax,%ecx
f010273d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102740:	89 d8                	mov    %ebx,%eax
f0102742:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f0102748:	c1 f8 03             	sar    $0x3,%eax
f010274b:	c1 e0 0c             	shl    $0xc,%eax
f010274e:	39 c1                	cmp    %eax,%ecx
f0102750:	74 24                	je     f0102776 <mem_init+0xece>
f0102752:	c7 44 24 0c a0 88 10 	movl   $0xf01088a0,0xc(%esp)
f0102759:	f0 
f010275a:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102761:	f0 
f0102762:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102769:	00 
f010276a:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102771:	e8 ca d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102776:	ba 00 10 00 00       	mov    $0x1000,%edx
f010277b:	89 f8                	mov    %edi,%eax
f010277d:	e8 66 e8 ff ff       	call   f0100fe8 <check_va2pa>
f0102782:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102785:	74 24                	je     f01027ab <mem_init+0xf03>
f0102787:	c7 44 24 0c cc 88 10 	movl   $0xf01088cc,0xc(%esp)
f010278e:	f0 
f010278f:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102796:	f0 
f0102797:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f010279e:	00 
f010279f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01027a6:	e8 95 d8 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027ab:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01027b0:	74 24                	je     f01027d6 <mem_init+0xf2e>
f01027b2:	c7 44 24 0c be 8f 10 	movl   $0xf0108fbe,0xc(%esp)
f01027b9:	f0 
f01027ba:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01027c1:	f0 
f01027c2:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01027c9:	00 
f01027ca:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01027d1:	e8 6a d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01027d6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027db:	74 24                	je     f0102801 <mem_init+0xf59>
f01027dd:	c7 44 24 0c cf 8f 10 	movl   $0xf0108fcf,0xc(%esp)
f01027e4:	f0 
f01027e5:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01027ec:	f0 
f01027ed:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01027f4:	00 
f01027f5:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01027fc:	e8 3f d8 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102808:	e8 bc ec ff ff       	call   f01014c9 <page_alloc>
f010280d:	85 c0                	test   %eax,%eax
f010280f:	74 04                	je     f0102815 <mem_init+0xf6d>
f0102811:	39 c6                	cmp    %eax,%esi
f0102813:	74 24                	je     f0102839 <mem_init+0xf91>
f0102815:	c7 44 24 0c fc 88 10 	movl   $0xf01088fc,0xc(%esp)
f010281c:	f0 
f010281d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102824:	f0 
f0102825:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f010282c:	00 
f010282d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102834:	e8 07 d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102839:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102840:	00 
f0102841:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102846:	89 04 24             	mov    %eax,(%esp)
f0102849:	e8 33 ef ff ff       	call   f0101781 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010284e:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
f0102854:	ba 00 00 00 00       	mov    $0x0,%edx
f0102859:	89 f8                	mov    %edi,%eax
f010285b:	e8 88 e7 ff ff       	call   f0100fe8 <check_va2pa>
f0102860:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102863:	74 24                	je     f0102889 <mem_init+0xfe1>
f0102865:	c7 44 24 0c 20 89 10 	movl   $0xf0108920,0xc(%esp)
f010286c:	f0 
f010286d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102874:	f0 
f0102875:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f010287c:	00 
f010287d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102884:	e8 b7 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102889:	ba 00 10 00 00       	mov    $0x1000,%edx
f010288e:	89 f8                	mov    %edi,%eax
f0102890:	e8 53 e7 ff ff       	call   f0100fe8 <check_va2pa>
f0102895:	89 da                	mov    %ebx,%edx
f0102897:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f010289d:	c1 fa 03             	sar    $0x3,%edx
f01028a0:	c1 e2 0c             	shl    $0xc,%edx
f01028a3:	39 d0                	cmp    %edx,%eax
f01028a5:	74 24                	je     f01028cb <mem_init+0x1023>
f01028a7:	c7 44 24 0c cc 88 10 	movl   $0xf01088cc,0xc(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01028b6:	f0 
f01028b7:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01028be:	00 
f01028bf:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01028c6:	e8 75 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01028cb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028d0:	74 24                	je     f01028f6 <mem_init+0x104e>
f01028d2:	c7 44 24 0c 75 8f 10 	movl   $0xf0108f75,0xc(%esp)
f01028d9:	f0 
f01028da:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01028e9:	00 
f01028ea:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01028f1:	e8 4a d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01028f6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028fb:	74 24                	je     f0102921 <mem_init+0x1079>
f01028fd:	c7 44 24 0c cf 8f 10 	movl   $0xf0108fcf,0xc(%esp)
f0102904:	f0 
f0102905:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010290c:	f0 
f010290d:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102914:	00 
f0102915:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010291c:	e8 1f d7 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102921:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102928:	00 
f0102929:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102930:	00 
f0102931:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102935:	89 3c 24             	mov    %edi,(%esp)
f0102938:	e8 8d ee ff ff       	call   f01017ca <page_insert>
f010293d:	85 c0                	test   %eax,%eax
f010293f:	74 24                	je     f0102965 <mem_init+0x10bd>
f0102941:	c7 44 24 0c 44 89 10 	movl   $0xf0108944,0xc(%esp)
f0102948:	f0 
f0102949:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102950:	f0 
f0102951:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102958:	00 
f0102959:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102960:	e8 db d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102965:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010296a:	75 24                	jne    f0102990 <mem_init+0x10e8>
f010296c:	c7 44 24 0c e0 8f 10 	movl   $0xf0108fe0,0xc(%esp)
f0102973:	f0 
f0102974:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010297b:	f0 
f010297c:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102983:	00 
f0102984:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010298b:	e8 b0 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102990:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102993:	74 24                	je     f01029b9 <mem_init+0x1111>
f0102995:	c7 44 24 0c ec 8f 10 	movl   $0xf0108fec,0xc(%esp)
f010299c:	f0 
f010299d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01029a4:	f0 
f01029a5:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01029ac:	00 
f01029ad:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01029b4:	e8 87 d6 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029c0:	00 
f01029c1:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01029c6:	89 04 24             	mov    %eax,(%esp)
f01029c9:	e8 b3 ed ff ff       	call   f0101781 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029ce:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
f01029d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01029d9:	89 f8                	mov    %edi,%eax
f01029db:	e8 08 e6 ff ff       	call   f0100fe8 <check_va2pa>
f01029e0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e3:	74 24                	je     f0102a09 <mem_init+0x1161>
f01029e5:	c7 44 24 0c 20 89 10 	movl   $0xf0108920,0xc(%esp)
f01029ec:	f0 
f01029ed:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01029f4:	f0 
f01029f5:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f01029fc:	00 
f01029fd:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102a04:	e8 37 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a0e:	89 f8                	mov    %edi,%eax
f0102a10:	e8 d3 e5 ff ff       	call   f0100fe8 <check_va2pa>
f0102a15:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a18:	74 24                	je     f0102a3e <mem_init+0x1196>
f0102a1a:	c7 44 24 0c 7c 89 10 	movl   $0xf010897c,0xc(%esp)
f0102a21:	f0 
f0102a22:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102a29:	f0 
f0102a2a:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102a31:	00 
f0102a32:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102a39:	e8 02 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a3e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a43:	74 24                	je     f0102a69 <mem_init+0x11c1>
f0102a45:	c7 44 24 0c 01 90 10 	movl   $0xf0109001,0xc(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102a54:	f0 
f0102a55:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102a5c:	00 
f0102a5d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102a64:	e8 d7 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a69:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a6e:	74 24                	je     f0102a94 <mem_init+0x11ec>
f0102a70:	c7 44 24 0c cf 8f 10 	movl   $0xf0108fcf,0xc(%esp)
f0102a77:	f0 
f0102a78:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102a7f:	f0 
f0102a80:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102a87:	00 
f0102a88:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102a8f:	e8 ac d5 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a9b:	e8 29 ea ff ff       	call   f01014c9 <page_alloc>
f0102aa0:	85 c0                	test   %eax,%eax
f0102aa2:	74 04                	je     f0102aa8 <mem_init+0x1200>
f0102aa4:	39 c3                	cmp    %eax,%ebx
f0102aa6:	74 24                	je     f0102acc <mem_init+0x1224>
f0102aa8:	c7 44 24 0c a4 89 10 	movl   $0xf01089a4,0xc(%esp)
f0102aaf:	f0 
f0102ab0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102ab7:	f0 
f0102ab8:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102abf:	00 
f0102ac0:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102ac7:	e8 74 d5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102acc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ad3:	e8 f1 e9 ff ff       	call   f01014c9 <page_alloc>
f0102ad8:	85 c0                	test   %eax,%eax
f0102ada:	74 24                	je     f0102b00 <mem_init+0x1258>
f0102adc:	c7 44 24 0c 23 8f 10 	movl   $0xf0108f23,0xc(%esp)
f0102ae3:	f0 
f0102ae4:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102aeb:	f0 
f0102aec:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102af3:	00 
f0102af4:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102afb:	e8 40 d5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b00:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102b05:	8b 08                	mov    (%eax),%ecx
f0102b07:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b0d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b10:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f0102b16:	c1 fa 03             	sar    $0x3,%edx
f0102b19:	c1 e2 0c             	shl    $0xc,%edx
f0102b1c:	39 d1                	cmp    %edx,%ecx
f0102b1e:	74 24                	je     f0102b44 <mem_init+0x129c>
f0102b20:	c7 44 24 0c 48 86 10 	movl   $0xf0108648,0xc(%esp)
f0102b27:	f0 
f0102b28:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102b2f:	f0 
f0102b30:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102b37:	00 
f0102b38:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102b3f:	e8 fc d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102b44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b4d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102b52:	74 24                	je     f0102b78 <mem_init+0x12d0>
f0102b54:	c7 44 24 0c 86 8f 10 	movl   $0xf0108f86,0xc(%esp)
f0102b5b:	f0 
f0102b5c:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102b63:	f0 
f0102b64:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102b6b:	00 
f0102b6c:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102b73:	e8 c8 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102b78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b7b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b81:	89 04 24             	mov    %eax,(%esp)
f0102b84:	e8 cb e9 ff ff       	call   f0101554 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b90:	00 
f0102b91:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b98:	00 
f0102b99:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102b9e:	89 04 24             	mov    %eax,(%esp)
f0102ba1:	e8 2d ea ff ff       	call   f01015d3 <pgdir_walk>
f0102ba6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102ba9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102bac:	8b 15 98 de 2b f0    	mov    0xf02bde98,%edx
f0102bb2:	8b 7a 04             	mov    0x4(%edx),%edi
f0102bb5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bbb:	8b 0d 94 de 2b f0    	mov    0xf02bde94,%ecx
f0102bc1:	89 f8                	mov    %edi,%eax
f0102bc3:	c1 e8 0c             	shr    $0xc,%eax
f0102bc6:	39 c8                	cmp    %ecx,%eax
f0102bc8:	72 20                	jb     f0102bea <mem_init+0x1342>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bca:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102bce:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0102bd5:	f0 
f0102bd6:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102bdd:	00 
f0102bde:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102be5:	e8 56 d4 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102bea:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102bf0:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102bf3:	74 24                	je     f0102c19 <mem_init+0x1371>
f0102bf5:	c7 44 24 0c 12 90 10 	movl   $0xf0109012,0xc(%esp)
f0102bfc:	f0 
f0102bfd:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102c04:	f0 
f0102c05:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102c0c:	00 
f0102c0d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102c14:	e8 27 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c19:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102c20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c23:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c29:	2b 05 9c de 2b f0    	sub    0xf02bde9c,%eax
f0102c2f:	c1 f8 03             	sar    $0x3,%eax
f0102c32:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c35:	89 c2                	mov    %eax,%edx
f0102c37:	c1 ea 0c             	shr    $0xc,%edx
f0102c3a:	39 d1                	cmp    %edx,%ecx
f0102c3c:	77 20                	ja     f0102c5e <mem_init+0x13b6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c42:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0102c49:	f0 
f0102c4a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c51:	00 
f0102c52:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0102c59:	e8 e2 d3 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c65:	00 
f0102c66:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c6d:	00 
	return (void *)(pa + KERNBASE);
f0102c6e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c73:	89 04 24             	mov    %eax,(%esp)
f0102c76:	e8 cc 36 00 00       	call   f0106347 <memset>
	page_free(pp0);
f0102c7b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c7e:	89 3c 24             	mov    %edi,(%esp)
f0102c81:	e8 ce e8 ff ff       	call   f0101554 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c86:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c8d:	00 
f0102c8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c95:	00 
f0102c96:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102c9b:	89 04 24             	mov    %eax,(%esp)
f0102c9e:	e8 30 e9 ff ff       	call   f01015d3 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ca3:	89 fa                	mov    %edi,%edx
f0102ca5:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f0102cab:	c1 fa 03             	sar    $0x3,%edx
f0102cae:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cb1:	89 d0                	mov    %edx,%eax
f0102cb3:	c1 e8 0c             	shr    $0xc,%eax
f0102cb6:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0102cbc:	72 20                	jb     f0102cde <mem_init+0x1436>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cbe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cc2:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0102cc9:	f0 
f0102cca:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102cd1:	00 
f0102cd2:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0102cd9:	e8 62 d3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102cde:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102ce4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ce7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102ced:	f6 00 01             	testb  $0x1,(%eax)
f0102cf0:	74 24                	je     f0102d16 <mem_init+0x146e>
f0102cf2:	c7 44 24 0c 2a 90 10 	movl   $0xf010902a,0xc(%esp)
f0102cf9:	f0 
f0102cfa:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102d01:	f0 
f0102d02:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102d09:	00 
f0102d0a:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
f0102d16:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d19:	39 d0                	cmp    %edx,%eax
f0102d1b:	75 d0                	jne    f0102ced <mem_init+0x1445>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d1d:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102d22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d2b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102d31:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102d34:	89 0d 40 d2 2b f0    	mov    %ecx,0xf02bd240

	// free the pages we took
	page_free(pp0);
f0102d3a:	89 04 24             	mov    %eax,(%esp)
f0102d3d:	e8 12 e8 ff ff       	call   f0101554 <page_free>
	page_free(pp1);
f0102d42:	89 1c 24             	mov    %ebx,(%esp)
f0102d45:	e8 0a e8 ff ff       	call   f0101554 <page_free>
	page_free(pp2);
f0102d4a:	89 34 24             	mov    %esi,(%esp)
f0102d4d:	e8 02 e8 ff ff       	call   f0101554 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102d52:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102d59:	00 
f0102d5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d61:	e8 d3 ea ff ff       	call   f0101839 <mmio_map_region>
f0102d66:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102d68:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d6f:	00 
f0102d70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d77:	e8 bd ea ff ff       	call   f0101839 <mmio_map_region>
f0102d7c:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102d7e:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102d84:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102d89:	77 08                	ja     f0102d93 <mem_init+0x14eb>
f0102d8b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d91:	77 24                	ja     f0102db7 <mem_init+0x150f>
f0102d93:	c7 44 24 0c c8 89 10 	movl   $0xf01089c8,0xc(%esp)
f0102d9a:	f0 
f0102d9b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102da2:	f0 
f0102da3:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102daa:	00 
f0102dab:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102db2:	e8 89 d2 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102db7:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102dbd:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102dc3:	77 08                	ja     f0102dcd <mem_init+0x1525>
f0102dc5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102dcb:	77 24                	ja     f0102df1 <mem_init+0x1549>
f0102dcd:	c7 44 24 0c f0 89 10 	movl   $0xf01089f0,0xc(%esp)
f0102dd4:	f0 
f0102dd5:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102ddc:	f0 
f0102ddd:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102de4:	00 
f0102de5:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102dec:	e8 4f d2 ff ff       	call   f0100040 <_panic>
f0102df1:	89 da                	mov    %ebx,%edx
f0102df3:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102df5:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102dfb:	74 24                	je     f0102e21 <mem_init+0x1579>
f0102dfd:	c7 44 24 0c 18 8a 10 	movl   $0xf0108a18,0xc(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102e0c:	f0 
f0102e0d:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102e14:	00 
f0102e15:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102e1c:	e8 1f d2 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102e21:	39 c6                	cmp    %eax,%esi
f0102e23:	73 24                	jae    f0102e49 <mem_init+0x15a1>
f0102e25:	c7 44 24 0c 41 90 10 	movl   $0xf0109041,0xc(%esp)
f0102e2c:	f0 
f0102e2d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102e34:	f0 
f0102e35:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102e3c:	00 
f0102e3d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102e44:	e8 f7 d1 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102e49:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi
f0102e4f:	89 da                	mov    %ebx,%edx
f0102e51:	89 f8                	mov    %edi,%eax
f0102e53:	e8 90 e1 ff ff       	call   f0100fe8 <check_va2pa>
f0102e58:	85 c0                	test   %eax,%eax
f0102e5a:	74 24                	je     f0102e80 <mem_init+0x15d8>
f0102e5c:	c7 44 24 0c 40 8a 10 	movl   $0xf0108a40,0xc(%esp)
f0102e63:	f0 
f0102e64:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102e6b:	f0 
f0102e6c:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102e73:	00 
f0102e74:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102e7b:	e8 c0 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102e80:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102e86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e89:	89 c2                	mov    %eax,%edx
f0102e8b:	89 f8                	mov    %edi,%eax
f0102e8d:	e8 56 e1 ff ff       	call   f0100fe8 <check_va2pa>
f0102e92:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102e97:	74 24                	je     f0102ebd <mem_init+0x1615>
f0102e99:	c7 44 24 0c 64 8a 10 	movl   $0xf0108a64,0xc(%esp)
f0102ea0:	f0 
f0102ea1:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102ea8:	f0 
f0102ea9:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102eb0:	00 
f0102eb1:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102eb8:	e8 83 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102ebd:	89 f2                	mov    %esi,%edx
f0102ebf:	89 f8                	mov    %edi,%eax
f0102ec1:	e8 22 e1 ff ff       	call   f0100fe8 <check_va2pa>
f0102ec6:	85 c0                	test   %eax,%eax
f0102ec8:	74 24                	je     f0102eee <mem_init+0x1646>
f0102eca:	c7 44 24 0c 94 8a 10 	movl   $0xf0108a94,0xc(%esp)
f0102ed1:	f0 
f0102ed2:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102ed9:	f0 
f0102eda:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102ee1:	00 
f0102ee2:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102ee9:	e8 52 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102eee:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ef4:	89 f8                	mov    %edi,%eax
f0102ef6:	e8 ed e0 ff ff       	call   f0100fe8 <check_va2pa>
f0102efb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102efe:	74 24                	je     f0102f24 <mem_init+0x167c>
f0102f00:	c7 44 24 0c b8 8a 10 	movl   $0xf0108ab8,0xc(%esp)
f0102f07:	f0 
f0102f08:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102f0f:	f0 
f0102f10:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0102f17:	00 
f0102f18:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102f1f:	e8 1c d1 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102f24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f2b:	00 
f0102f2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f30:	89 3c 24             	mov    %edi,(%esp)
f0102f33:	e8 9b e6 ff ff       	call   f01015d3 <pgdir_walk>
f0102f38:	f6 00 1a             	testb  $0x1a,(%eax)
f0102f3b:	75 24                	jne    f0102f61 <mem_init+0x16b9>
f0102f3d:	c7 44 24 0c e4 8a 10 	movl   $0xf0108ae4,0xc(%esp)
f0102f44:	f0 
f0102f45:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102f4c:	f0 
f0102f4d:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102f54:	00 
f0102f55:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102f5c:	e8 df d0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102f61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f68:	00 
f0102f69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f6d:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102f72:	89 04 24             	mov    %eax,(%esp)
f0102f75:	e8 59 e6 ff ff       	call   f01015d3 <pgdir_walk>
f0102f7a:	f6 00 04             	testb  $0x4,(%eax)
f0102f7d:	74 24                	je     f0102fa3 <mem_init+0x16fb>
f0102f7f:	c7 44 24 0c 28 8b 10 	movl   $0xf0108b28,0xc(%esp)
f0102f86:	f0 
f0102f87:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0102f8e:	f0 
f0102f8f:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102f96:	00 
f0102f97:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0102f9e:	e8 9d d0 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102fa3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102faa:	00 
f0102fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102faf:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102fb4:	89 04 24             	mov    %eax,(%esp)
f0102fb7:	e8 17 e6 ff ff       	call   f01015d3 <pgdir_walk>
f0102fbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102fc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fc9:	00 
f0102fca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fd1:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102fd6:	89 04 24             	mov    %eax,(%esp)
f0102fd9:	e8 f5 e5 ff ff       	call   f01015d3 <pgdir_walk>
f0102fde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102fe4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102feb:	00 
f0102fec:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ff0:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0102ff5:	89 04 24             	mov    %eax,(%esp)
f0102ff8:	e8 d6 e5 ff ff       	call   f01015d3 <pgdir_walk>
f0102ffd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103003:	c7 04 24 53 90 10 f0 	movl   $0xf0109053,(%esp)
f010300a:	e8 7a 12 00 00       	call   f0104289 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f010300f:	a1 9c de 2b f0       	mov    0xf02bde9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103014:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103019:	77 20                	ja     f010303b <mem_init+0x1793>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010301b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010301f:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103026:	f0 
f0103027:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f010302e:	00 
f010302f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103036:	e8 05 d0 ff ff       	call   f0100040 <_panic>
f010303b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103042:	00 
	return (physaddr_t)kva - KERNBASE;
f0103043:	05 00 00 00 10       	add    $0x10000000,%eax
f0103048:	89 04 24             	mov    %eax,(%esp)
f010304b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103050:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103055:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010305a:	e8 14 e6 ff ff       	call   f0101673 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f010305f:	a1 48 d2 2b f0       	mov    0xf02bd248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103064:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103069:	77 20                	ja     f010308b <mem_init+0x17e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010306b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010306f:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103076:	f0 
f0103077:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f010307e:	00 
f010307f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103086:	e8 b5 cf ff ff       	call   f0100040 <_panic>
f010308b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103092:	00 
	return (physaddr_t)kva - KERNBASE;
f0103093:	05 00 00 00 10       	add    $0x10000000,%eax
f0103098:	89 04 24             	mov    %eax,(%esp)
f010309b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01030a0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01030a5:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01030aa:	e8 c4 e5 ff ff       	call   f0101673 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030af:	b8 00 b0 11 f0       	mov    $0xf011b000,%eax
f01030b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030b9:	77 20                	ja     f01030db <mem_init+0x1833>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030bf:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f01030c6:	f0 
f01030c7:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f01030ce:	00 
f01030cf:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01030d6:	e8 65 cf ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W|PTE_P);
f01030db:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01030e2:	00 
f01030e3:	c7 04 24 00 b0 11 00 	movl   $0x11b000,(%esp)
f01030ea:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01030ef:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01030f4:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01030f9:	e8 75 e5 ff ff       	call   f0101673 <boot_map_region>
f01030fe:	bf 00 00 30 f0       	mov    $0xf0300000,%edi
f0103103:	bb 00 00 2c f0       	mov    $0xf02c0000,%ebx
f0103108:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010310d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103113:	77 20                	ja     f0103135 <mem_init+0x188d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103115:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103119:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103120:	f0 
f0103121:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0103128:	00 
f0103129:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103130:	e8 0b cf ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	for(int i = 0; i<NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - (i+1)*KSTKSIZE - i*KSTKGAP, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W|PTE_P);
f0103135:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010313c:	00 
f010313d:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103143:	89 04 24             	mov    %eax,(%esp)
f0103146:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010314b:	89 f2                	mov    %esi,%edx
f010314d:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0103152:	e8 1c e5 ff ff       	call   f0101673 <boot_map_region>
f0103157:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010315d:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	for(int i = 0; i<NCPU; i++) {
f0103163:	39 fb                	cmp    %edi,%ebx
f0103165:	75 a6                	jne    f010310d <mem_init+0x1865>
	// Your code goes here:

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	boot_map_region(kern_pgdir, KERNBASE,(size_t) (-KERNBASE), 0, PTE_W|PTE_P);
f0103167:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010316e:	00 
f010316f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103176:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010317b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103180:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0103185:	e8 e9 e4 ff ff       	call   f0101673 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010318a:	8b 3d 98 de 2b f0    	mov    0xf02bde98,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103190:	a1 94 de 2b f0       	mov    0xf02bde94,%eax
f0103195:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103198:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010319f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031a7:	8b 35 9c de 2b f0    	mov    0xf02bde9c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031ad:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01031b0:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01031b6:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f01031b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01031be:	eb 6a                	jmp    f010322a <mem_init+0x1982>
f01031c0:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031c6:	89 f8                	mov    %edi,%eax
f01031c8:	e8 1b de ff ff       	call   f0100fe8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031cd:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01031d4:	77 20                	ja     f01031f6 <mem_init+0x194e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01031da:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f01031e1:	f0 
f01031e2:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01031e9:	00 
f01031ea:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01031f1:	e8 4a ce ff ff       	call   f0100040 <_panic>
f01031f6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01031f9:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01031fc:	39 d0                	cmp    %edx,%eax
f01031fe:	74 24                	je     f0103224 <mem_init+0x197c>
f0103200:	c7 44 24 0c 5c 8b 10 	movl   $0xf0108b5c,0xc(%esp)
f0103207:	f0 
f0103208:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010320f:	f0 
f0103210:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0103217:	00 
f0103218:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010321f:	e8 1c ce ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0103224:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010322a:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f010322d:	77 91                	ja     f01031c0 <mem_init+0x1918>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010322f:	8b 1d 48 d2 2b f0    	mov    0xf02bd248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103235:	89 de                	mov    %ebx,%esi
f0103237:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010323c:	89 f8                	mov    %edi,%eax
f010323e:	e8 a5 dd ff ff       	call   f0100fe8 <check_va2pa>
f0103243:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103249:	77 20                	ja     f010326b <mem_init+0x19c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010324b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010324f:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103256:	f0 
f0103257:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f010325e:	00 
f010325f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103266:	e8 d5 cd ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010326b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0103270:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0103276:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103279:	39 d0                	cmp    %edx,%eax
f010327b:	74 24                	je     f01032a1 <mem_init+0x19f9>
f010327d:	c7 44 24 0c 90 8b 10 	movl   $0xf0108b90,0xc(%esp)
f0103284:	f0 
f0103285:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010328c:	f0 
f010328d:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0103294:	00 
f0103295:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010329c:	e8 9f cd ff ff       	call   f0100040 <_panic>
f01032a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01032a7:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01032ad:	0f 85 a8 05 00 00    	jne    f010385b <mem_init+0x1fb3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032b3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01032b6:	c1 e6 0c             	shl    $0xc,%esi
f01032b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01032be:	eb 3b                	jmp    f01032fb <mem_init+0x1a53>
f01032c0:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01032c6:	89 f8                	mov    %edi,%eax
f01032c8:	e8 1b dd ff ff       	call   f0100fe8 <check_va2pa>
f01032cd:	39 c3                	cmp    %eax,%ebx
f01032cf:	74 24                	je     f01032f5 <mem_init+0x1a4d>
f01032d1:	c7 44 24 0c c4 8b 10 	movl   $0xf0108bc4,0xc(%esp)
f01032d8:	f0 
f01032d9:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01032e0:	f0 
f01032e1:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01032e8:	00 
f01032e9:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01032f0:	e8 4b cd ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032fb:	39 f3                	cmp    %esi,%ebx
f01032fd:	72 c1                	jb     f01032c0 <mem_init+0x1a18>
f01032ff:	c7 45 d0 00 00 2c f0 	movl   $0xf02c0000,-0x30(%ebp)
f0103306:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010330d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0103312:	b8 00 00 2c f0       	mov    $0xf02c0000,%eax
f0103317:	05 00 80 00 20       	add    $0x20008000,%eax
f010331c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010331f:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0103325:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103328:	89 f2                	mov    %esi,%edx
f010332a:	89 f8                	mov    %edi,%eax
f010332c:	e8 b7 dc ff ff       	call   f0100fe8 <check_va2pa>
f0103331:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103334:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010333a:	77 20                	ja     f010335c <mem_init+0x1ab4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010333c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103340:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103347:	f0 
f0103348:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f010334f:	00 
f0103350:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103357:	e8 e4 cc ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010335c:	89 f3                	mov    %esi,%ebx
f010335e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103361:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0103364:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103367:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010336a:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f010336d:	39 c2                	cmp    %eax,%edx
f010336f:	74 24                	je     f0103395 <mem_init+0x1aed>
f0103371:	c7 44 24 0c ec 8b 10 	movl   $0xf0108bec,0xc(%esp)
f0103378:	f0 
f0103379:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103380:	f0 
f0103381:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0103388:	00 
f0103389:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103390:	e8 ab cc ff ff       	call   f0100040 <_panic>
f0103395:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010339b:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f010339e:	0f 85 a9 04 00 00    	jne    f010384d <mem_init+0x1fa5>
f01033a4:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01033aa:	89 da                	mov    %ebx,%edx
f01033ac:	89 f8                	mov    %edi,%eax
f01033ae:	e8 35 dc ff ff       	call   f0100fe8 <check_va2pa>
f01033b3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01033b6:	74 24                	je     f01033dc <mem_init+0x1b34>
f01033b8:	c7 44 24 0c 34 8c 10 	movl   $0xf0108c34,0xc(%esp)
f01033bf:	f0 
f01033c0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01033c7:	f0 
f01033c8:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01033cf:	00 
f01033d0:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01033d7:	e8 64 cc ff ff       	call   f0100040 <_panic>
f01033dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01033e2:	39 de                	cmp    %ebx,%esi
f01033e4:	75 c4                	jne    f01033aa <mem_init+0x1b02>
f01033e6:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01033ec:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f01033f3:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01033fa:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103400:	0f 85 19 ff ff ff    	jne    f010331f <mem_init+0x1a77>
f0103406:	b8 00 00 00 00       	mov    $0x0,%eax
f010340b:	e9 c2 00 00 00       	jmp    f01034d2 <mem_init+0x1c2a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103410:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103416:	83 fa 04             	cmp    $0x4,%edx
f0103419:	77 2e                	ja     f0103449 <mem_init+0x1ba1>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010341b:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010341f:	0f 85 aa 00 00 00    	jne    f01034cf <mem_init+0x1c27>
f0103425:	c7 44 24 0c 6c 90 10 	movl   $0xf010906c,0xc(%esp)
f010342c:	f0 
f010342d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103434:	f0 
f0103435:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f010343c:	00 
f010343d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103444:	e8 f7 cb ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103449:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010344e:	76 55                	jbe    f01034a5 <mem_init+0x1bfd>
				assert(pgdir[i] & PTE_P);
f0103450:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103453:	f6 c2 01             	test   $0x1,%dl
f0103456:	75 24                	jne    f010347c <mem_init+0x1bd4>
f0103458:	c7 44 24 0c 6c 90 10 	movl   $0xf010906c,0xc(%esp)
f010345f:	f0 
f0103460:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103467:	f0 
f0103468:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010346f:	00 
f0103470:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103477:	e8 c4 cb ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010347c:	f6 c2 02             	test   $0x2,%dl
f010347f:	75 4e                	jne    f01034cf <mem_init+0x1c27>
f0103481:	c7 44 24 0c 7d 90 10 	movl   $0xf010907d,0xc(%esp)
f0103488:	f0 
f0103489:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103490:	f0 
f0103491:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0103498:	00 
f0103499:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01034a0:	e8 9b cb ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01034a5:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01034a9:	74 24                	je     f01034cf <mem_init+0x1c27>
f01034ab:	c7 44 24 0c 8e 90 10 	movl   $0xf010908e,0xc(%esp)
f01034b2:	f0 
f01034b3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01034ba:	f0 
f01034bb:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01034c2:	00 
f01034c3:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01034ca:	e8 71 cb ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01034cf:	83 c0 01             	add    $0x1,%eax
f01034d2:	3d 00 04 00 00       	cmp    $0x400,%eax
f01034d7:	0f 85 33 ff ff ff    	jne    f0103410 <mem_init+0x1b68>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01034dd:	c7 04 24 58 8c 10 f0 	movl   $0xf0108c58,(%esp)
f01034e4:	e8 a0 0d 00 00       	call   f0104289 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01034e9:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01034ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034f3:	77 20                	ja     f0103515 <mem_init+0x1c6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034f9:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103500:	f0 
f0103501:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0103508:	00 
f0103509:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103510:	e8 2b cb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103515:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010351a:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010351d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103522:	e8 30 db ff ff       	call   f0101057 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0103527:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010352a:	83 e0 f3             	and    $0xfffffff3,%eax
f010352d:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0103532:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103535:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010353c:	e8 88 df ff ff       	call   f01014c9 <page_alloc>
f0103541:	89 c3                	mov    %eax,%ebx
f0103543:	85 c0                	test   %eax,%eax
f0103545:	75 24                	jne    f010356b <mem_init+0x1cc3>
f0103547:	c7 44 24 0c 78 8e 10 	movl   $0xf0108e78,0xc(%esp)
f010354e:	f0 
f010354f:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103556:	f0 
f0103557:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f010355e:	00 
f010355f:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103566:	e8 d5 ca ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010356b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103572:	e8 52 df ff ff       	call   f01014c9 <page_alloc>
f0103577:	89 c7                	mov    %eax,%edi
f0103579:	85 c0                	test   %eax,%eax
f010357b:	75 24                	jne    f01035a1 <mem_init+0x1cf9>
f010357d:	c7 44 24 0c 8e 8e 10 	movl   $0xf0108e8e,0xc(%esp)
f0103584:	f0 
f0103585:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010358c:	f0 
f010358d:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0103594:	00 
f0103595:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010359c:	e8 9f ca ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01035a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035a8:	e8 1c df ff ff       	call   f01014c9 <page_alloc>
f01035ad:	89 c6                	mov    %eax,%esi
f01035af:	85 c0                	test   %eax,%eax
f01035b1:	75 24                	jne    f01035d7 <mem_init+0x1d2f>
f01035b3:	c7 44 24 0c a4 8e 10 	movl   $0xf0108ea4,0xc(%esp)
f01035ba:	f0 
f01035bb:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01035c2:	f0 
f01035c3:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01035ca:	00 
f01035cb:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01035d2:	e8 69 ca ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01035d7:	89 1c 24             	mov    %ebx,(%esp)
f01035da:	e8 75 df ff ff       	call   f0101554 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01035df:	89 f8                	mov    %edi,%eax
f01035e1:	e8 bd d9 ff ff       	call   f0100fa3 <page2kva>
f01035e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01035ed:	00 
f01035ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01035f5:	00 
f01035f6:	89 04 24             	mov    %eax,(%esp)
f01035f9:	e8 49 2d 00 00       	call   f0106347 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f01035fe:	89 f0                	mov    %esi,%eax
f0103600:	e8 9e d9 ff ff       	call   f0100fa3 <page2kva>
f0103605:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010360c:	00 
f010360d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103614:	00 
f0103615:	89 04 24             	mov    %eax,(%esp)
f0103618:	e8 2a 2d 00 00       	call   f0106347 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010361d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103624:	00 
f0103625:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010362c:	00 
f010362d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103631:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f0103636:	89 04 24             	mov    %eax,(%esp)
f0103639:	e8 8c e1 ff ff       	call   f01017ca <page_insert>
	assert(pp1->pp_ref == 1);
f010363e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103643:	74 24                	je     f0103669 <mem_init+0x1dc1>
f0103645:	c7 44 24 0c 75 8f 10 	movl   $0xf0108f75,0xc(%esp)
f010364c:	f0 
f010364d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103654:	f0 
f0103655:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010365c:	00 
f010365d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103664:	e8 d7 c9 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103669:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103670:	01 01 01 
f0103673:	74 24                	je     f0103699 <mem_init+0x1df1>
f0103675:	c7 44 24 0c 78 8c 10 	movl   $0xf0108c78,0xc(%esp)
f010367c:	f0 
f010367d:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103684:	f0 
f0103685:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f010368c:	00 
f010368d:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103694:	e8 a7 c9 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103699:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01036a0:	00 
f01036a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01036a8:	00 
f01036a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036ad:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01036b2:	89 04 24             	mov    %eax,(%esp)
f01036b5:	e8 10 e1 ff ff       	call   f01017ca <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01036ba:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01036c1:	02 02 02 
f01036c4:	74 24                	je     f01036ea <mem_init+0x1e42>
f01036c6:	c7 44 24 0c 9c 8c 10 	movl   $0xf0108c9c,0xc(%esp)
f01036cd:	f0 
f01036ce:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01036d5:	f0 
f01036d6:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01036dd:	00 
f01036de:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01036e5:	e8 56 c9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01036ea:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01036ef:	74 24                	je     f0103715 <mem_init+0x1e6d>
f01036f1:	c7 44 24 0c 97 8f 10 	movl   $0xf0108f97,0xc(%esp)
f01036f8:	f0 
f01036f9:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103700:	f0 
f0103701:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0103708:	00 
f0103709:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103710:	e8 2b c9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103715:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010371a:	74 24                	je     f0103740 <mem_init+0x1e98>
f010371c:	c7 44 24 0c 01 90 10 	movl   $0xf0109001,0xc(%esp)
f0103723:	f0 
f0103724:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010372b:	f0 
f010372c:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0103733:	00 
f0103734:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010373b:	e8 00 c9 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103740:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103747:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010374a:	89 f0                	mov    %esi,%eax
f010374c:	e8 52 d8 ff ff       	call   f0100fa3 <page2kva>
f0103751:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103757:	74 24                	je     f010377d <mem_init+0x1ed5>
f0103759:	c7 44 24 0c c0 8c 10 	movl   $0xf0108cc0,0xc(%esp)
f0103760:	f0 
f0103761:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0103768:	f0 
f0103769:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103770:	00 
f0103771:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f0103778:	e8 c3 c8 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010377d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103784:	00 
f0103785:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f010378a:	89 04 24             	mov    %eax,(%esp)
f010378d:	e8 ef df ff ff       	call   f0101781 <page_remove>
	assert(pp2->pp_ref == 0);
f0103792:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103797:	74 24                	je     f01037bd <mem_init+0x1f15>
f0103799:	c7 44 24 0c cf 8f 10 	movl   $0xf0108fcf,0xc(%esp)
f01037a0:	f0 
f01037a1:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01037a8:	f0 
f01037a9:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01037b0:	00 
f01037b1:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01037b8:	e8 83 c8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01037bd:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01037c2:	8b 08                	mov    (%eax),%ecx
f01037c4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01037ca:	89 da                	mov    %ebx,%edx
f01037cc:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f01037d2:	c1 fa 03             	sar    $0x3,%edx
f01037d5:	c1 e2 0c             	shl    $0xc,%edx
f01037d8:	39 d1                	cmp    %edx,%ecx
f01037da:	74 24                	je     f0103800 <mem_init+0x1f58>
f01037dc:	c7 44 24 0c 48 86 10 	movl   $0xf0108648,0xc(%esp)
f01037e3:	f0 
f01037e4:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01037eb:	f0 
f01037ec:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f01037f3:	00 
f01037f4:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f01037fb:	e8 40 c8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103800:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103806:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010380b:	74 24                	je     f0103831 <mem_init+0x1f89>
f010380d:	c7 44 24 0c 86 8f 10 	movl   $0xf0108f86,0xc(%esp)
f0103814:	f0 
f0103815:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010381c:	f0 
f010381d:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0103824:	00 
f0103825:	c7 04 24 5b 8d 10 f0 	movl   $0xf0108d5b,(%esp)
f010382c:	e8 0f c8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103831:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103837:	89 1c 24             	mov    %ebx,(%esp)
f010383a:	e8 15 dd ff ff       	call   f0101554 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010383f:	c7 04 24 ec 8c 10 f0 	movl   $0xf0108cec,(%esp)
f0103846:	e8 3e 0a 00 00       	call   f0104289 <cprintf>
f010384b:	eb 1c                	jmp    f0103869 <mem_init+0x1fc1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010384d:	89 da                	mov    %ebx,%edx
f010384f:	89 f8                	mov    %edi,%eax
f0103851:	e8 92 d7 ff ff       	call   f0100fe8 <check_va2pa>
f0103856:	e9 0c fb ff ff       	jmp    f0103367 <mem_init+0x1abf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010385b:	89 da                	mov    %ebx,%edx
f010385d:	89 f8                	mov    %edi,%eax
f010385f:	e8 84 d7 ff ff       	call   f0100fe8 <check_va2pa>
f0103864:	e9 0d fa ff ff       	jmp    f0103276 <mem_init+0x19ce>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103869:	83 c4 4c             	add    $0x4c,%esp
f010386c:	5b                   	pop    %ebx
f010386d:	5e                   	pop    %esi
f010386e:	5f                   	pop    %edi
f010386f:	5d                   	pop    %ebp
f0103870:	c3                   	ret    

f0103871 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103871:	55                   	push   %ebp
f0103872:	89 e5                	mov    %esp,%ebp
f0103874:	57                   	push   %edi
f0103875:	56                   	push   %esi
f0103876:	53                   	push   %ebx
f0103877:	83 ec 2c             	sub    $0x2c,%esp
f010387a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010387d:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
f0103880:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103883:	03 45 10             	add    0x10(%ebp),%eax
f0103886:	05 ff 0f 00 00       	add    $0xfff,%eax
f010388b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103890:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
f0103893:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103896:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010389b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010389e:	89 c3                	mov    %eax,%ebx
f01038a0:	eb 52                	jmp    f01038f4 <user_mem_check+0x83>
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);
f01038a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01038a9:	00 
f01038aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038ae:	8b 47 60             	mov    0x60(%edi),%eax
f01038b1:	89 04 24             	mov    %eax,(%esp)
f01038b4:	e8 1a dd ff ff       	call   f01015d3 <pgdir_walk>

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
f01038b9:	85 c0                	test   %eax,%eax
f01038bb:	74 10                	je     f01038cd <user_mem_check+0x5c>
f01038bd:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01038c3:	77 08                	ja     f01038cd <user_mem_check+0x5c>
f01038c5:	89 f2                	mov    %esi,%edx
f01038c7:	23 10                	and    (%eax),%edx
f01038c9:	39 d6                	cmp    %edx,%esi
f01038cb:	74 21                	je     f01038ee <user_mem_check+0x7d>
			user_mem_check_addr = i;
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
f01038cd:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01038d0:	74 0d                	je     f01038df <user_mem_check+0x6e>

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
			user_mem_check_addr = i;
f01038d2:	89 1d 3c d2 2b f0    	mov    %ebx,0xf02bd23c
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
				user_mem_check_addr = (uintptr_t) va;
			}
			return -E_FAULT;
f01038d8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01038dd:	eb 1f                	jmp    f01038fe <user_mem_check+0x8d>
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
			user_mem_check_addr = i;
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
				user_mem_check_addr = (uintptr_t) va;
f01038df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038e2:	a3 3c d2 2b f0       	mov    %eax,0xf02bd23c
			}
			return -E_FAULT;
f01038e7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01038ec:	eb 10                	jmp    f01038fe <user_mem_check+0x8d>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
f01038ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01038f4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01038f7:	72 a9                	jb     f01038a2 <user_mem_check+0x31>
			}
			return -E_FAULT;
		}
	}

	return 0;
f01038f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038fe:	83 c4 2c             	add    $0x2c,%esp
f0103901:	5b                   	pop    %ebx
f0103902:	5e                   	pop    %esi
f0103903:	5f                   	pop    %edi
f0103904:	5d                   	pop    %ebp
f0103905:	c3                   	ret    

f0103906 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103906:	55                   	push   %ebp
f0103907:	89 e5                	mov    %esp,%ebp
f0103909:	53                   	push   %ebx
f010390a:	83 ec 14             	sub    $0x14,%esp
f010390d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103910:	8b 45 14             	mov    0x14(%ebp),%eax
f0103913:	83 c8 04             	or     $0x4,%eax
f0103916:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010391a:	8b 45 10             	mov    0x10(%ebp),%eax
f010391d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103921:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103924:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103928:	89 1c 24             	mov    %ebx,(%esp)
f010392b:	e8 41 ff ff ff       	call   f0103871 <user_mem_check>
f0103930:	85 c0                	test   %eax,%eax
f0103932:	79 24                	jns    f0103958 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103934:	a1 3c d2 2b f0       	mov    0xf02bd23c,%eax
f0103939:	89 44 24 08          	mov    %eax,0x8(%esp)
f010393d:	8b 43 48             	mov    0x48(%ebx),%eax
f0103940:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103944:	c7 04 24 18 8d 10 f0 	movl   $0xf0108d18,(%esp)
f010394b:	e8 39 09 00 00       	call   f0104289 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103950:	89 1c 24             	mov    %ebx,(%esp)
f0103953:	e8 38 06 00 00       	call   f0103f90 <env_destroy>
	}
}
f0103958:	83 c4 14             	add    $0x14,%esp
f010395b:	5b                   	pop    %ebx
f010395c:	5d                   	pop    %ebp
f010395d:	c3                   	ret    

f010395e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010395e:	55                   	push   %ebp
f010395f:	89 e5                	mov    %esp,%ebp
f0103961:	57                   	push   %edi
f0103962:	56                   	push   %esi
f0103963:	53                   	push   %ebx
f0103964:	83 ec 1c             	sub    $0x1c,%esp
f0103967:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)

	pte_t* pte;
	struct PageInfo * p;
	size_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
f0103969:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103970:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(size_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i+= PGSIZE) {
f0103976:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010397c:	89 d3                	mov    %edx,%ebx
f010397e:	eb 6d                	jmp    f01039ed <region_alloc+0x8f>
		p = page_alloc(0);
f0103980:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103987:	e8 3d db ff ff       	call   f01014c9 <page_alloc>
		if(!p) panic("could not initialize new page");
f010398c:	85 c0                	test   %eax,%eax
f010398e:	75 1c                	jne    f01039ac <region_alloc+0x4e>
f0103990:	c7 44 24 08 9c 90 10 	movl   $0xf010909c,0x8(%esp)
f0103997:	f0 
f0103998:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f010399f:	00 
f01039a0:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f01039a7:	e8 94 c6 ff ff       	call   f0100040 <_panic>

		if(page_insert(e->env_pgdir, p, (void*) i, PTE_W| PTE_U |PTE_P) < 0 ) {
f01039ac:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01039b3:	00 
f01039b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01039b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039bc:	8b 47 60             	mov    0x60(%edi),%eax
f01039bf:	89 04 24             	mov    %eax,(%esp)
f01039c2:	e8 03 de ff ff       	call   f01017ca <page_insert>
f01039c7:	85 c0                	test   %eax,%eax
f01039c9:	79 1c                	jns    f01039e7 <region_alloc+0x89>
			panic("could not insert page into pgdir");
f01039cb:	c7 44 24 08 d4 90 10 	movl   $0xf01090d4,0x8(%esp)
f01039d2:	f0 
f01039d3:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01039da:	00 
f01039db:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f01039e2:	e8 59 c6 ff ff       	call   f0100040 <_panic>
	// (But only if you need it for load_icode.)

	pte_t* pte;
	struct PageInfo * p;
	size_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
	for(size_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i+= PGSIZE) {
f01039e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01039ed:	39 f3                	cmp    %esi,%ebx
f01039ef:	72 8f                	jb     f0103980 <region_alloc+0x22>

	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01039f1:	83 c4 1c             	add    $0x1c,%esp
f01039f4:	5b                   	pop    %ebx
f01039f5:	5e                   	pop    %esi
f01039f6:	5f                   	pop    %edi
f01039f7:	5d                   	pop    %ebp
f01039f8:	c3                   	ret    

f01039f9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039f9:	55                   	push   %ebp
f01039fa:	89 e5                	mov    %esp,%ebp
f01039fc:	56                   	push   %esi
f01039fd:	53                   	push   %ebx
f01039fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a01:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103a04:	85 c0                	test   %eax,%eax
f0103a06:	75 1a                	jne    f0103a22 <envid2env+0x29>
		*env_store = curenv;
f0103a08:	e8 8c 2f 00 00       	call   f0106999 <cpunum>
f0103a0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a10:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0103a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a19:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103a1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a20:	eb 70                	jmp    f0103a92 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103a22:	89 c3                	mov    %eax,%ebx
f0103a24:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103a2a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103a2d:	03 1d 48 d2 2b f0    	add    0xf02bd248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a33:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103a37:	74 05                	je     f0103a3e <envid2env+0x45>
f0103a39:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103a3c:	74 10                	je     f0103a4e <envid2env+0x55>
		*env_store = 0;
f0103a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a47:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a4c:	eb 44                	jmp    f0103a92 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a4e:	84 d2                	test   %dl,%dl
f0103a50:	74 36                	je     f0103a88 <envid2env+0x8f>
f0103a52:	e8 42 2f 00 00       	call   f0106999 <cpunum>
f0103a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a5a:	39 98 28 f0 2b f0    	cmp    %ebx,-0xfd40fd8(%eax)
f0103a60:	74 26                	je     f0103a88 <envid2env+0x8f>
f0103a62:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103a65:	e8 2f 2f 00 00       	call   f0106999 <cpunum>
f0103a6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6d:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0103a73:	3b 70 48             	cmp    0x48(%eax),%esi
f0103a76:	74 10                	je     f0103a88 <envid2env+0x8f>
		*env_store = 0;
f0103a78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a81:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a86:	eb 0a                	jmp    f0103a92 <envid2env+0x99>
	}

	*env_store = e;
f0103a88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a8b:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a92:	5b                   	pop    %ebx
f0103a93:	5e                   	pop    %esi
f0103a94:	5d                   	pop    %ebp
f0103a95:	c3                   	ret    

f0103a96 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a96:	55                   	push   %ebp
f0103a97:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103a99:	b8 20 53 12 f0       	mov    $0xf0125320,%eax
f0103a9e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103aa1:	b8 23 00 00 00       	mov    $0x23,%eax
f0103aa6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103aa8:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103aaa:	b0 10                	mov    $0x10,%al
f0103aac:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103aae:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103ab0:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103ab2:	ea b9 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103ab9
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103ab9:	b0 00                	mov    $0x0,%al
f0103abb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103abe:	5d                   	pop    %ebp
f0103abf:	c3                   	ret    

f0103ac0 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103ac0:	55                   	push   %ebp
f0103ac1:	89 e5                	mov    %esp,%ebp
f0103ac3:	56                   	push   %esi
f0103ac4:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for(int i=NENV-1; i>=0; i--) {
		envs[i].env_status = ENV_FREE;
f0103ac5:	8b 35 48 d2 2b f0    	mov    0xf02bd248,%esi
f0103acb:	8b 0d 4c d2 2b f0    	mov    0xf02bd24c,%ecx
f0103ad1:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103ad7:	ba 00 04 00 00       	mov    $0x400,%edx
f0103adc:	89 c3                	mov    %eax,%ebx
f0103ade:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103ae5:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103aec:	89 48 44             	mov    %ecx,0x44(%eax)
f0103aef:	83 e8 7c             	sub    $0x7c,%eax
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for(int i=NENV-1; i>=0; i--) {
f0103af2:	83 ea 01             	sub    $0x1,%edx
f0103af5:	74 04                	je     f0103afb <env_init+0x3b>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &(envs[i]);
f0103af7:	89 d9                	mov    %ebx,%ecx
f0103af9:	eb e1                	jmp    f0103adc <env_init+0x1c>
f0103afb:	89 35 4c d2 2b f0    	mov    %esi,0xf02bd24c
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103b01:	e8 90 ff ff ff       	call   f0103a96 <env_init_percpu>
}
f0103b06:	5b                   	pop    %ebx
f0103b07:	5e                   	pop    %esi
f0103b08:	5d                   	pop    %ebp
f0103b09:	c3                   	ret    

f0103b0a <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103b0a:	55                   	push   %ebp
f0103b0b:	89 e5                	mov    %esp,%ebp
f0103b0d:	53                   	push   %ebx
f0103b0e:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103b11:	8b 1d 4c d2 2b f0    	mov    0xf02bd24c,%ebx
f0103b17:	85 db                	test   %ebx,%ebx
f0103b19:	0f 84 57 01 00 00    	je     f0103c76 <env_alloc+0x16c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b1f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103b26:	e8 9e d9 ff ff       	call   f01014c9 <page_alloc>
f0103b2b:	85 c0                	test   %eax,%eax
f0103b2d:	0f 84 4a 01 00 00    	je     f0103c7d <env_alloc+0x173>
f0103b33:	89 c2                	mov    %eax,%edx
f0103b35:	2b 15 9c de 2b f0    	sub    0xf02bde9c,%edx
f0103b3b:	c1 fa 03             	sar    $0x3,%edx
f0103b3e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b41:	89 d1                	mov    %edx,%ecx
f0103b43:	c1 e9 0c             	shr    $0xc,%ecx
f0103b46:	3b 0d 94 de 2b f0    	cmp    0xf02bde94,%ecx
f0103b4c:	72 20                	jb     f0103b6e <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b52:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0103b59:	f0 
f0103b5a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103b61:	00 
f0103b62:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0103b69:	e8 d2 c4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b6e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103b74:	89 53 60             	mov    %edx,0x60(%ebx)
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
f0103b77:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103b7c:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	//boot_map_region(e->env_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_W| PTE_U | PTE_P);
	//boot_map_region(e->env_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
	for(int i=PDX(UTOP);i<NPDENTRIES;i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0103b81:	8b 15 98 de 2b f0    	mov    0xf02bde98,%edx
f0103b87:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103b8a:	8b 53 60             	mov    0x60(%ebx),%edx
f0103b8d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103b90:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;

	//boot_map_region(e->env_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_W| PTE_U | PTE_P);
	//boot_map_region(e->env_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
	for(int i=PDX(UTOP);i<NPDENTRIES;i++) {
f0103b93:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103b98:	75 e7                	jne    f0103b81 <env_alloc+0x77>
		e->env_pgdir[i] = kern_pgdir[i];
	}
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103b9a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b9d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ba2:	77 20                	ja     f0103bc4 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ba4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ba8:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103baf:	f0 
f0103bb0:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0103bb7:	00 
f0103bb8:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103bbf:	e8 7c c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bc4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103bca:	83 ca 05             	or     $0x5,%edx
f0103bcd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103bd3:	8b 43 48             	mov    0x48(%ebx),%eax
f0103bd6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103bdb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103be0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103be5:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103be8:	89 da                	mov    %ebx,%edx
f0103bea:	2b 15 48 d2 2b f0    	sub    0xf02bd248,%edx
f0103bf0:	c1 fa 02             	sar    $0x2,%edx
f0103bf3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103bf9:	09 d0                	or     %edx,%eax
f0103bfb:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c01:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103c04:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	//cprintf("Setting 1 %d \n", e->env_id);
	e->env_status = ENV_RUNNABLE;
f0103c0b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103c12:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c19:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103c20:	00 
f0103c21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c28:	00 
f0103c29:	89 1c 24             	mov    %ebx,(%esp)
f0103c2c:	e8 16 27 00 00       	call   f0106347 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103c31:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103c37:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103c3d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103c43:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103c4a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103c50:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103c57:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103c5e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103c62:	8b 43 44             	mov    0x44(%ebx),%eax
f0103c65:	a3 4c d2 2b f0       	mov    %eax,0xf02bd24c
	*newenv_store = e;
f0103c6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6d:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103c6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c74:	eb 0c                	jmp    f0103c82 <env_alloc+0x178>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103c76:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103c7b:	eb 05                	jmp    f0103c82 <env_alloc+0x178>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103c7d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103c82:	83 c4 14             	add    $0x14,%esp
f0103c85:	5b                   	pop    %ebx
f0103c86:	5d                   	pop    %ebp
f0103c87:	c3                   	ret    

f0103c88 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103c88:	55                   	push   %ebp
f0103c89:	89 e5                	mov    %esp,%ebp
f0103c8b:	57                   	push   %edi
f0103c8c:	56                   	push   %esi
f0103c8d:	53                   	push   %ebx
f0103c8e:	83 ec 3c             	sub    $0x3c,%esp
f0103c91:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *newenv;
	int r;
	if((r = env_alloc(&newenv, 0)) < 0) {
f0103c94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c9b:	00 
f0103c9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103c9f:	89 04 24             	mov    %eax,(%esp)
f0103ca2:	e8 63 fe ff ff       	call   f0103b0a <env_alloc>
f0103ca7:	85 c0                	test   %eax,%eax
f0103ca9:	79 20                	jns    f0103ccb <env_create+0x43>
		panic("Couldn't allocate user env. Env_alloc failed with error %e\n", r);
f0103cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103caf:	c7 44 24 08 f8 90 10 	movl   $0xf01090f8,0x8(%esp)
f0103cb6:	f0 
f0103cb7:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0103cbe:	00 
f0103cbf:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103cc6:	e8 75 c3 ff ff       	call   f0100040 <_panic>
	}

	load_icode(newenv, binary);
f0103ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103cce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	struct Elf *elfhdr = (struct Elf *) binary;
	struct Proghdr *ph,*eph;

	if(elfhdr->e_magic != ELF_MAGIC) {
f0103cd1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103cd7:	74 1c                	je     f0103cf5 <env_create+0x6d>
		panic("Binary image doesn't have valid elf hdr");
f0103cd9:	c7 44 24 08 34 91 10 	movl   $0xf0109134,0x8(%esp)
f0103ce0:	f0 
f0103ce1:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0103ce8:	00 
f0103ce9:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103cf0:	e8 4b c3 ff ff       	call   f0100040 <_panic>
	}

	ph = (struct Proghdr *)(binary + elfhdr->e_phoff);
f0103cf5:	89 fb                	mov    %edi,%ebx
f0103cf7:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0103cfa:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103cfe:	c1 e6 05             	shl    $0x5,%esi
f0103d01:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103d03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d06:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d0e:	77 20                	ja     f0103d30 <env_create+0xa8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d14:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103d1b:	f0 
f0103d1c:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f0103d23:	00 
f0103d24:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103d2b:	e8 10 c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d30:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103d35:	0f 22 d8             	mov    %eax,%cr3
f0103d38:	eb 50                	jmp    f0103d8a <env_create+0x102>

	for(; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
f0103d3a:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103d3d:	75 48                	jne    f0103d87 <env_create+0xff>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0103d3f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103d42:	8b 53 08             	mov    0x8(%ebx),%edx
f0103d45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d48:	e8 11 fc ff ff       	call   f010395e <region_alloc>
			memcpy((void*)ph->p_va, (binary + ph->p_offset), ph->p_filesz);
f0103d4d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d50:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d54:	89 f8                	mov    %edi,%eax
f0103d56:	03 43 04             	add    0x4(%ebx),%eax
f0103d59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d5d:	8b 43 08             	mov    0x8(%ebx),%eax
f0103d60:	89 04 24             	mov    %eax,(%esp)
f0103d63:	e8 94 26 00 00       	call   f01063fc <memcpy>
			memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103d68:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d6b:	8b 53 14             	mov    0x14(%ebx),%edx
f0103d6e:	29 c2                	sub    %eax,%edx
f0103d70:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d7b:	00 
f0103d7c:	03 43 08             	add    0x8(%ebx),%eax
f0103d7f:	89 04 24             	mov    %eax,(%esp)
f0103d82:	e8 c0 25 00 00       	call   f0106347 <memset>

	ph = (struct Proghdr *)(binary + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for(; ph < eph; ph++) {
f0103d87:	83 c3 20             	add    $0x20,%ebx
f0103d8a:	39 de                	cmp    %ebx,%esi
f0103d8c:	77 ac                	ja     f0103d3a <env_create+0xb2>
		}
	}


	//set IP in trapframe
	e->env_tf.tf_eip = elfhdr->e_entry;
f0103d8e:	8b 47 18             	mov    0x18(%edi),%eax
f0103d91:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103d94:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.

	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103d97:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103d9c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103da1:	89 f8                	mov    %edi,%eax
f0103da3:	e8 b6 fb ff ff       	call   f010395e <region_alloc>
		panic("Couldn't allocate user env. Env_alloc failed with error %e\n", r);
	}

	load_icode(newenv, binary);

	newenv->env_type = type;
f0103da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103dae:	89 48 50             	mov    %ecx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if(type == ENV_TYPE_FS) {
f0103db1:	83 f9 01             	cmp    $0x1,%ecx
f0103db4:	75 07                	jne    f0103dbd <env_create+0x135>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
f0103db6:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f0103dbd:	83 c4 3c             	add    $0x3c,%esp
f0103dc0:	5b                   	pop    %ebx
f0103dc1:	5e                   	pop    %esi
f0103dc2:	5f                   	pop    %edi
f0103dc3:	5d                   	pop    %ebp
f0103dc4:	c3                   	ret    

f0103dc5 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103dc5:	55                   	push   %ebp
f0103dc6:	89 e5                	mov    %esp,%ebp
f0103dc8:	57                   	push   %edi
f0103dc9:	56                   	push   %esi
f0103dca:	53                   	push   %ebx
f0103dcb:	83 ec 2c             	sub    $0x2c,%esp
f0103dce:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103dd1:	e8 c3 2b 00 00       	call   f0106999 <cpunum>
f0103dd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd9:	39 b8 28 f0 2b f0    	cmp    %edi,-0xfd40fd8(%eax)
f0103ddf:	74 09                	je     f0103dea <env_free+0x25>
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103de1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103de8:	eb 36                	jmp    f0103e20 <env_free+0x5b>

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));
f0103dea:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103def:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103df4:	77 20                	ja     f0103e16 <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103df6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dfa:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103e01:	f0 
f0103e02:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103e09:	00 
f0103e0a:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103e11:	e8 2a c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e16:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e1b:	0f 22 d8             	mov    %eax,%cr3
f0103e1e:	eb c1                	jmp    f0103de1 <env_free+0x1c>
f0103e20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e23:	89 c8                	mov    %ecx,%eax
f0103e25:	c1 e0 02             	shl    $0x2,%eax
f0103e28:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103e2b:	8b 47 60             	mov    0x60(%edi),%eax
f0103e2e:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103e31:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103e37:	0f 84 b7 00 00 00    	je     f0103ef4 <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103e3d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e43:	89 f0                	mov    %esi,%eax
f0103e45:	c1 e8 0c             	shr    $0xc,%eax
f0103e48:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e4b:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0103e51:	72 20                	jb     f0103e73 <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e53:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103e57:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0103e5e:	f0 
f0103e5f:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103e66:	00 
f0103e67:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103e6e:	e8 cd c1 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e76:	c1 e0 16             	shl    $0x16,%eax
f0103e79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103e81:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103e88:	01 
f0103e89:	74 17                	je     f0103ea2 <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103e8b:	89 d8                	mov    %ebx,%eax
f0103e8d:	c1 e0 0c             	shl    $0xc,%eax
f0103e90:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103e93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e97:	8b 47 60             	mov    0x60(%edi),%eax
f0103e9a:	89 04 24             	mov    %eax,(%esp)
f0103e9d:	e8 df d8 ff ff       	call   f0101781 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ea2:	83 c3 01             	add    $0x1,%ebx
f0103ea5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103eab:	75 d4                	jne    f0103e81 <env_free+0xbc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103ead:	8b 47 60             	mov    0x60(%edi),%eax
f0103eb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103eb3:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103eba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ebd:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0103ec3:	72 1c                	jb     f0103ee1 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103ec5:	c7 44 24 08 14 85 10 	movl   $0xf0108514,0x8(%esp)
f0103ecc:	f0 
f0103ecd:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ed4:	00 
f0103ed5:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0103edc:	e8 5f c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ee1:	a1 9c de 2b f0       	mov    0xf02bde9c,%eax
f0103ee6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ee9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103eec:	89 04 24             	mov    %eax,(%esp)
f0103eef:	e8 bc d6 ff ff       	call   f01015b0 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ef4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ef8:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103eff:	0f 85 1b ff ff ff    	jne    f0103e20 <env_free+0x5b>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103f05:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f08:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f0d:	77 20                	ja     f0103f2f <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f13:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0103f1a:	f0 
f0103f1b:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103f22:	00 
f0103f23:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f0103f2a:	e8 11 c1 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103f2f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103f36:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f3b:	c1 e8 0c             	shr    $0xc,%eax
f0103f3e:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0103f44:	72 1c                	jb     f0103f62 <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103f46:	c7 44 24 08 14 85 10 	movl   $0xf0108514,0x8(%esp)
f0103f4d:	f0 
f0103f4e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103f55:	00 
f0103f56:	c7 04 24 4d 8d 10 f0 	movl   $0xf0108d4d,(%esp)
f0103f5d:	e8 de c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103f62:	8b 15 9c de 2b f0    	mov    0xf02bde9c,%edx
f0103f68:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103f6b:	89 04 24             	mov    %eax,(%esp)
f0103f6e:	e8 3d d6 ff ff       	call   f01015b0 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103f73:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103f7a:	a1 4c d2 2b f0       	mov    0xf02bd24c,%eax
f0103f7f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103f82:	89 3d 4c d2 2b f0    	mov    %edi,0xf02bd24c
}
f0103f88:	83 c4 2c             	add    $0x2c,%esp
f0103f8b:	5b                   	pop    %ebx
f0103f8c:	5e                   	pop    %esi
f0103f8d:	5f                   	pop    %edi
f0103f8e:	5d                   	pop    %ebp
f0103f8f:	c3                   	ret    

f0103f90 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	53                   	push   %ebx
f0103f94:	83 ec 14             	sub    $0x14,%esp
f0103f97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103f9a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103f9e:	75 19                	jne    f0103fb9 <env_destroy+0x29>
f0103fa0:	e8 f4 29 00 00       	call   f0106999 <cpunum>
f0103fa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa8:	39 98 28 f0 2b f0    	cmp    %ebx,-0xfd40fd8(%eax)
f0103fae:	74 09                	je     f0103fb9 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103fb0:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103fb7:	eb 2f                	jmp    f0103fe8 <env_destroy+0x58>
	}

	env_free(e);
f0103fb9:	89 1c 24             	mov    %ebx,(%esp)
f0103fbc:	e8 04 fe ff ff       	call   f0103dc5 <env_free>

	if (curenv == e) {
f0103fc1:	e8 d3 29 00 00       	call   f0106999 <cpunum>
f0103fc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc9:	39 98 28 f0 2b f0    	cmp    %ebx,-0xfd40fd8(%eax)
f0103fcf:	75 17                	jne    f0103fe8 <env_destroy+0x58>
		curenv = NULL;
f0103fd1:	e8 c3 29 00 00       	call   f0106999 <cpunum>
f0103fd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd9:	c7 80 28 f0 2b f0 00 	movl   $0x0,-0xfd40fd8(%eax)
f0103fe0:	00 00 00 
		sched_yield();
f0103fe3:	e8 c6 0f 00 00       	call   f0104fae <sched_yield>
	}
}
f0103fe8:	83 c4 14             	add    $0x14,%esp
f0103feb:	5b                   	pop    %ebx
f0103fec:	5d                   	pop    %ebp
f0103fed:	c3                   	ret    

f0103fee <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103fee:	55                   	push   %ebp
f0103fef:	89 e5                	mov    %esp,%ebp
f0103ff1:	53                   	push   %ebx
f0103ff2:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ff5:	e8 9f 29 00 00       	call   f0106999 <cpunum>
f0103ffa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ffd:	8b 98 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%ebx
f0104003:	e8 91 29 00 00       	call   f0106999 <cpunum>
f0104008:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010400b:	8b 65 08             	mov    0x8(%ebp),%esp
f010400e:	61                   	popa   
f010400f:	07                   	pop    %es
f0104010:	1f                   	pop    %ds
f0104011:	83 c4 08             	add    $0x8,%esp
f0104014:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104015:	c7 44 24 08 c5 90 10 	movl   $0xf01090c5,0x8(%esp)
f010401c:	f0 
f010401d:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0104024:	00 
f0104025:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f010402c:	e8 0f c0 ff ff       	call   f0100040 <_panic>

f0104031 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104031:	55                   	push   %ebp
f0104032:	89 e5                	mov    %esp,%ebp
f0104034:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && (curenv->env_status == ENV_RUNNING) ) {
f0104037:	e8 5d 29 00 00       	call   f0106999 <cpunum>
f010403c:	6b c0 74             	imul   $0x74,%eax,%eax
f010403f:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0104046:	74 29                	je     f0104071 <env_run+0x40>
f0104048:	e8 4c 29 00 00       	call   f0106999 <cpunum>
f010404d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104050:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104056:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010405a:	75 15                	jne    f0104071 <env_run+0x40>
		//cprintf("Setting 2 %d\n", curenv->env_id);
		curenv->env_status = ENV_RUNNABLE;
f010405c:	e8 38 29 00 00       	call   f0106999 <cpunum>
f0104061:	6b c0 74             	imul   $0x74,%eax,%eax
f0104064:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f010406a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}

	curenv = e;
f0104071:	e8 23 29 00 00       	call   f0106999 <cpunum>
f0104076:	6b c0 74             	imul   $0x74,%eax,%eax
f0104079:	8b 55 08             	mov    0x8(%ebp),%edx
f010407c:	89 90 28 f0 2b f0    	mov    %edx,-0xfd40fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0104082:	e8 12 29 00 00       	call   f0106999 <cpunum>
f0104087:	6b c0 74             	imul   $0x74,%eax,%eax
f010408a:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104090:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104097:	e8 fd 28 00 00       	call   f0106999 <cpunum>
f010409c:	6b c0 74             	imul   $0x74,%eax,%eax
f010409f:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01040a5:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f01040a9:	e8 eb 28 00 00       	call   f0106999 <cpunum>
f01040ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b1:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01040b7:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040bf:	77 20                	ja     f01040e1 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040c5:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f01040cc:	f0 
f01040cd:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
f01040d4:	00 
f01040d5:	c7 04 24 ba 90 10 f0 	movl   $0xf01090ba,(%esp)
f01040dc:	e8 5f bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01040e6:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01040e9:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f01040f0:	e8 ce 2b 00 00       	call   f0106cc3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01040f5:	f3 90                	pause  

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01040f7:	e8 9d 28 00 00       	call   f0106999 <cpunum>
f01040fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ff:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104105:	89 04 24             	mov    %eax,(%esp)
f0104108:	e8 e1 fe ff ff       	call   f0103fee <env_pop_tf>

f010410d <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010410d:	55                   	push   %ebp
f010410e:	89 e5                	mov    %esp,%ebp
f0104110:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104114:	ba 70 00 00 00       	mov    $0x70,%edx
f0104119:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010411a:	b2 71                	mov    $0x71,%dl
f010411c:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010411d:	0f b6 c0             	movzbl %al,%eax
}
f0104120:	5d                   	pop    %ebp
f0104121:	c3                   	ret    

f0104122 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104122:	55                   	push   %ebp
f0104123:	89 e5                	mov    %esp,%ebp
f0104125:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104129:	ba 70 00 00 00       	mov    $0x70,%edx
f010412e:	ee                   	out    %al,(%dx)
f010412f:	b2 71                	mov    $0x71,%dl
f0104131:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104134:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104135:	5d                   	pop    %ebp
f0104136:	c3                   	ret    

f0104137 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104137:	55                   	push   %ebp
f0104138:	89 e5                	mov    %esp,%ebp
f010413a:	56                   	push   %esi
f010413b:	53                   	push   %ebx
f010413c:	83 ec 10             	sub    $0x10,%esp
f010413f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0104142:	66 a3 a8 53 12 f0    	mov    %ax,0xf01253a8
	if (!didinit)
f0104148:	80 3d 50 d2 2b f0 00 	cmpb   $0x0,0xf02bd250
f010414f:	74 4e                	je     f010419f <irq_setmask_8259A+0x68>
f0104151:	89 c6                	mov    %eax,%esi
f0104153:	ba 21 00 00 00       	mov    $0x21,%edx
f0104158:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104159:	66 c1 e8 08          	shr    $0x8,%ax
f010415d:	b2 a1                	mov    $0xa1,%dl
f010415f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104160:	c7 04 24 5c 91 10 f0 	movl   $0xf010915c,(%esp)
f0104167:	e8 1d 01 00 00       	call   f0104289 <cprintf>
	for (i = 0; i < 16; i++)
f010416c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0104171:	0f b7 f6             	movzwl %si,%esi
f0104174:	f7 d6                	not    %esi
f0104176:	0f a3 de             	bt     %ebx,%esi
f0104179:	73 10                	jae    f010418b <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f010417b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010417f:	c7 04 24 d3 99 10 f0 	movl   $0xf01099d3,(%esp)
f0104186:	e8 fe 00 00 00       	call   f0104289 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010418b:	83 c3 01             	add    $0x1,%ebx
f010418e:	83 fb 10             	cmp    $0x10,%ebx
f0104191:	75 e3                	jne    f0104176 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104193:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f010419a:	e8 ea 00 00 00       	call   f0104289 <cprintf>
}
f010419f:	83 c4 10             	add    $0x10,%esp
f01041a2:	5b                   	pop    %ebx
f01041a3:	5e                   	pop    %esi
f01041a4:	5d                   	pop    %ebp
f01041a5:	c3                   	ret    

f01041a6 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01041a6:	c6 05 50 d2 2b f0 01 	movb   $0x1,0xf02bd250
f01041ad:	ba 21 00 00 00       	mov    $0x21,%edx
f01041b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01041b7:	ee                   	out    %al,(%dx)
f01041b8:	b2 a1                	mov    $0xa1,%dl
f01041ba:	ee                   	out    %al,(%dx)
f01041bb:	b2 20                	mov    $0x20,%dl
f01041bd:	b8 11 00 00 00       	mov    $0x11,%eax
f01041c2:	ee                   	out    %al,(%dx)
f01041c3:	b2 21                	mov    $0x21,%dl
f01041c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01041ca:	ee                   	out    %al,(%dx)
f01041cb:	b8 04 00 00 00       	mov    $0x4,%eax
f01041d0:	ee                   	out    %al,(%dx)
f01041d1:	b8 03 00 00 00       	mov    $0x3,%eax
f01041d6:	ee                   	out    %al,(%dx)
f01041d7:	b2 a0                	mov    $0xa0,%dl
f01041d9:	b8 11 00 00 00       	mov    $0x11,%eax
f01041de:	ee                   	out    %al,(%dx)
f01041df:	b2 a1                	mov    $0xa1,%dl
f01041e1:	b8 28 00 00 00       	mov    $0x28,%eax
f01041e6:	ee                   	out    %al,(%dx)
f01041e7:	b8 02 00 00 00       	mov    $0x2,%eax
f01041ec:	ee                   	out    %al,(%dx)
f01041ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01041f2:	ee                   	out    %al,(%dx)
f01041f3:	b2 20                	mov    $0x20,%dl
f01041f5:	b8 68 00 00 00       	mov    $0x68,%eax
f01041fa:	ee                   	out    %al,(%dx)
f01041fb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104200:	ee                   	out    %al,(%dx)
f0104201:	b2 a0                	mov    $0xa0,%dl
f0104203:	b8 68 00 00 00       	mov    $0x68,%eax
f0104208:	ee                   	out    %al,(%dx)
f0104209:	b8 0a 00 00 00       	mov    $0xa,%eax
f010420e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010420f:	0f b7 05 a8 53 12 f0 	movzwl 0xf01253a8,%eax
f0104216:	66 83 f8 ff          	cmp    $0xffff,%ax
f010421a:	74 12                	je     f010422e <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010421c:	55                   	push   %ebp
f010421d:	89 e5                	mov    %esp,%ebp
f010421f:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0104222:	0f b7 c0             	movzwl %ax,%eax
f0104225:	89 04 24             	mov    %eax,(%esp)
f0104228:	e8 0a ff ff ff       	call   f0104137 <irq_setmask_8259A>
}
f010422d:	c9                   	leave  
f010422e:	f3 c3                	repz ret 

f0104230 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0104230:	55                   	push   %ebp
f0104231:	89 e5                	mov    %esp,%ebp
f0104233:	ba 20 00 00 00       	mov    $0x20,%edx
f0104238:	b8 20 00 00 00       	mov    $0x20,%eax
f010423d:	ee                   	out    %al,(%dx)
f010423e:	b2 a0                	mov    $0xa0,%dl
f0104240:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0104241:	5d                   	pop    %ebp
f0104242:	c3                   	ret    

f0104243 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104243:	55                   	push   %ebp
f0104244:	89 e5                	mov    %esp,%ebp
f0104246:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104249:	8b 45 08             	mov    0x8(%ebp),%eax
f010424c:	89 04 24             	mov    %eax,(%esp)
f010424f:	e8 93 c5 ff ff       	call   f01007e7 <cputchar>
	*cnt++;
}
f0104254:	c9                   	leave  
f0104255:	c3                   	ret    

f0104256 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104256:	55                   	push   %ebp
f0104257:	89 e5                	mov    %esp,%ebp
f0104259:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010425c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104263:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104266:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010426a:	8b 45 08             	mov    0x8(%ebp),%eax
f010426d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104271:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104274:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104278:	c7 04 24 43 42 10 f0 	movl   $0xf0104243,(%esp)
f010427f:	e8 fa 19 00 00       	call   f0105c7e <vprintfmt>
	return cnt;
}
f0104284:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104287:	c9                   	leave  
f0104288:	c3                   	ret    

f0104289 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104289:	55                   	push   %ebp
f010428a:	89 e5                	mov    %esp,%ebp
f010428c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010428f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104292:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104296:	8b 45 08             	mov    0x8(%ebp),%eax
f0104299:	89 04 24             	mov    %eax,(%esp)
f010429c:	e8 b5 ff ff ff       	call   f0104256 <vcprintf>
	va_end(ap);

	return cnt;
}
f01042a1:	c9                   	leave  
f01042a2:	c3                   	ret    
f01042a3:	66 90                	xchg   %ax,%ax
f01042a5:	66 90                	xchg   %ax,%ax
f01042a7:	66 90                	xchg   %ax,%ax
f01042a9:	66 90                	xchg   %ax,%ax
f01042ab:	66 90                	xchg   %ax,%ax
f01042ad:	66 90                	xchg   %ax,%ax
f01042af:	90                   	nop

f01042b0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01042b0:	55                   	push   %ebp
f01042b1:	89 e5                	mov    %esp,%ebp
f01042b3:	57                   	push   %edi
f01042b4:	56                   	push   %esi
f01042b5:	53                   	push   %ebx
f01042b6:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i = thiscpu->cpu_id;
f01042b9:	e8 db 26 00 00       	call   f0106999 <cpunum>
f01042be:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c1:	0f b6 80 20 f0 2b f0 	movzbl -0xfd40fe0(%eax),%eax
f01042c8:	89 c3                	mov    %eax,%ebx

	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) (percpu_kstacks[i] + KSTKSIZE);
f01042ca:	e8 ca 26 00 00       	call   f0106999 <cpunum>
f01042cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d2:	88 5d e7             	mov    %bl,-0x19(%ebp)
f01042d5:	0f b6 db             	movzbl %bl,%ebx
f01042d8:	89 da                	mov    %ebx,%edx
f01042da:	c1 e2 0f             	shl    $0xf,%edx
f01042dd:	8d 92 00 80 2c f0    	lea    -0xfd38000(%edx),%edx
f01042e3:	89 90 30 f0 2b f0    	mov    %edx,-0xfd40fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01042e9:	e8 ab 26 00 00       	call   f0106999 <cpunum>
f01042ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f1:	66 c7 80 34 f0 2b f0 	movw   $0x10,-0xfd40fcc(%eax)
f01042f8:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01042fa:	e8 9a 26 00 00       	call   f0106999 <cpunum>
f01042ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104302:	66 c7 80 92 f0 2b f0 	movw   $0x68,-0xfd40f6e(%eax)
f0104309:	68 00 

	//cprintf("Current tss for cpu %d is %x\n", i, &(thiscpu->cpu_ts));
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010430b:	83 c3 05             	add    $0x5,%ebx
f010430e:	e8 86 26 00 00       	call   f0106999 <cpunum>
f0104313:	89 c7                	mov    %eax,%edi
f0104315:	e8 7f 26 00 00       	call   f0106999 <cpunum>
f010431a:	89 c6                	mov    %eax,%esi
f010431c:	e8 78 26 00 00       	call   f0106999 <cpunum>
f0104321:	66 c7 04 dd 40 53 12 	movw   $0x67,-0xfedacc0(,%ebx,8)
f0104328:	f0 67 00 
f010432b:	6b ff 74             	imul   $0x74,%edi,%edi
f010432e:	81 c7 2c f0 2b f0    	add    $0xf02bf02c,%edi
f0104334:	66 89 3c dd 42 53 12 	mov    %di,-0xfedacbe(,%ebx,8)
f010433b:	f0 
f010433c:	6b d6 74             	imul   $0x74,%esi,%edx
f010433f:	81 c2 2c f0 2b f0    	add    $0xf02bf02c,%edx
f0104345:	c1 ea 10             	shr    $0x10,%edx
f0104348:	88 14 dd 44 53 12 f0 	mov    %dl,-0xfedacbc(,%ebx,8)
f010434f:	c6 04 dd 46 53 12 f0 	movb   $0x40,-0xfedacba(,%ebx,8)
f0104356:	40 
f0104357:	6b c0 74             	imul   $0x74,%eax,%eax
f010435a:	05 2c f0 2b f0       	add    $0xf02bf02c,%eax
f010435f:	c1 e8 18             	shr    $0x18,%eax
f0104362:	88 04 dd 47 53 12 f0 	mov    %al,-0xfedacb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0104369:	c6 04 dd 45 53 12 f0 	movb   $0x89,-0xfedacbb(,%ebx,8)
f0104370:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));
f0104371:	0f b6 75 e7          	movzbl -0x19(%ebp),%esi
f0104375:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010437c:	0f 00 de             	ltr    %si
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010437f:	b8 aa 53 12 f0       	mov    $0xf01253aa,%eax
f0104384:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104387:	83 c4 1c             	add    $0x1c,%esp
f010438a:	5b                   	pop    %ebx
f010438b:	5e                   	pop    %esi
f010438c:	5f                   	pop    %edi
f010438d:	5d                   	pop    %ebp
f010438e:	c3                   	ret    

f010438f <trap_init>:
}


void
trap_init(void)
{
f010438f:	55                   	push   %ebp
f0104390:	89 e5                	mov    %esp,%ebp
f0104392:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide, 0);
f0104395:	b8 3a 4e 10 f0       	mov    $0xf0104e3a,%eax
f010439a:	66 a3 60 d2 2b f0    	mov    %ax,0xf02bd260
f01043a0:	66 c7 05 62 d2 2b f0 	movw   $0x8,0xf02bd262
f01043a7:	08 00 
f01043a9:	c6 05 64 d2 2b f0 00 	movb   $0x0,0xf02bd264
f01043b0:	c6 05 65 d2 2b f0 8e 	movb   $0x8e,0xf02bd265
f01043b7:	c1 e8 10             	shr    $0x10,%eax
f01043ba:	66 a3 66 d2 2b f0    	mov    %ax,0xf02bd266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug, 0);
f01043c0:	b8 44 4e 10 f0       	mov    $0xf0104e44,%eax
f01043c5:	66 a3 68 d2 2b f0    	mov    %ax,0xf02bd268
f01043cb:	66 c7 05 6a d2 2b f0 	movw   $0x8,0xf02bd26a
f01043d2:	08 00 
f01043d4:	c6 05 6c d2 2b f0 00 	movb   $0x0,0xf02bd26c
f01043db:	c6 05 6d d2 2b f0 8e 	movb   $0x8e,0xf02bd26d
f01043e2:	c1 e8 10             	shr    $0x10,%eax
f01043e5:	66 a3 6e d2 2b f0    	mov    %ax,0xf02bd26e
	SETGATE(idt[T_NMI], 0, GD_KT, nmi, 0);
f01043eb:	b8 4a 4e 10 f0       	mov    $0xf0104e4a,%eax
f01043f0:	66 a3 70 d2 2b f0    	mov    %ax,0xf02bd270
f01043f6:	66 c7 05 72 d2 2b f0 	movw   $0x8,0xf02bd272
f01043fd:	08 00 
f01043ff:	c6 05 74 d2 2b f0 00 	movb   $0x0,0xf02bd274
f0104406:	c6 05 75 d2 2b f0 8e 	movb   $0x8e,0xf02bd275
f010440d:	c1 e8 10             	shr    $0x10,%eax
f0104410:	66 a3 76 d2 2b f0    	mov    %ax,0xf02bd276
	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt, 3);
f0104416:	b8 50 4e 10 f0       	mov    $0xf0104e50,%eax
f010441b:	66 a3 78 d2 2b f0    	mov    %ax,0xf02bd278
f0104421:	66 c7 05 7a d2 2b f0 	movw   $0x8,0xf02bd27a
f0104428:	08 00 
f010442a:	c6 05 7c d2 2b f0 00 	movb   $0x0,0xf02bd27c
f0104431:	c6 05 7d d2 2b f0 ee 	movb   $0xee,0xf02bd27d
f0104438:	c1 e8 10             	shr    $0x10,%eax
f010443b:	66 a3 7e d2 2b f0    	mov    %ax,0xf02bd27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow, 0);
f0104441:	b8 56 4e 10 f0       	mov    $0xf0104e56,%eax
f0104446:	66 a3 80 d2 2b f0    	mov    %ax,0xf02bd280
f010444c:	66 c7 05 82 d2 2b f0 	movw   $0x8,0xf02bd282
f0104453:	08 00 
f0104455:	c6 05 84 d2 2b f0 00 	movb   $0x0,0xf02bd284
f010445c:	c6 05 85 d2 2b f0 8e 	movb   $0x8e,0xf02bd285
f0104463:	c1 e8 10             	shr    $0x10,%eax
f0104466:	66 a3 86 d2 2b f0    	mov    %ax,0xf02bd286
	SETGATE(idt[T_BOUND], 0, GD_KT, bound, 0);
f010446c:	b8 5c 4e 10 f0       	mov    $0xf0104e5c,%eax
f0104471:	66 a3 88 d2 2b f0    	mov    %ax,0xf02bd288
f0104477:	66 c7 05 8a d2 2b f0 	movw   $0x8,0xf02bd28a
f010447e:	08 00 
f0104480:	c6 05 8c d2 2b f0 00 	movb   $0x0,0xf02bd28c
f0104487:	c6 05 8d d2 2b f0 8e 	movb   $0x8e,0xf02bd28d
f010448e:	c1 e8 10             	shr    $0x10,%eax
f0104491:	66 a3 8e d2 2b f0    	mov    %ax,0xf02bd28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illop, 0);
f0104497:	b8 62 4e 10 f0       	mov    $0xf0104e62,%eax
f010449c:	66 a3 90 d2 2b f0    	mov    %ax,0xf02bd290
f01044a2:	66 c7 05 92 d2 2b f0 	movw   $0x8,0xf02bd292
f01044a9:	08 00 
f01044ab:	c6 05 94 d2 2b f0 00 	movb   $0x0,0xf02bd294
f01044b2:	c6 05 95 d2 2b f0 8e 	movb   $0x8e,0xf02bd295
f01044b9:	c1 e8 10             	shr    $0x10,%eax
f01044bc:	66 a3 96 d2 2b f0    	mov    %ax,0xf02bd296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device, 0);
f01044c2:	b8 68 4e 10 f0       	mov    $0xf0104e68,%eax
f01044c7:	66 a3 98 d2 2b f0    	mov    %ax,0xf02bd298
f01044cd:	66 c7 05 9a d2 2b f0 	movw   $0x8,0xf02bd29a
f01044d4:	08 00 
f01044d6:	c6 05 9c d2 2b f0 00 	movb   $0x0,0xf02bd29c
f01044dd:	c6 05 9d d2 2b f0 8e 	movb   $0x8e,0xf02bd29d
f01044e4:	c1 e8 10             	shr    $0x10,%eax
f01044e7:	66 a3 9e d2 2b f0    	mov    %ax,0xf02bd29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt, 0);
f01044ed:	b8 6e 4e 10 f0       	mov    $0xf0104e6e,%eax
f01044f2:	66 a3 a0 d2 2b f0    	mov    %ax,0xf02bd2a0
f01044f8:	66 c7 05 a2 d2 2b f0 	movw   $0x8,0xf02bd2a2
f01044ff:	08 00 
f0104501:	c6 05 a4 d2 2b f0 00 	movb   $0x0,0xf02bd2a4
f0104508:	c6 05 a5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2a5
f010450f:	c1 e8 10             	shr    $0x10,%eax
f0104512:	66 a3 a6 d2 2b f0    	mov    %ax,0xf02bd2a6
	SETGATE(idt[T_TSS], 0, GD_KT, tss, 0);
f0104518:	b8 72 4e 10 f0       	mov    $0xf0104e72,%eax
f010451d:	66 a3 b0 d2 2b f0    	mov    %ax,0xf02bd2b0
f0104523:	66 c7 05 b2 d2 2b f0 	movw   $0x8,0xf02bd2b2
f010452a:	08 00 
f010452c:	c6 05 b4 d2 2b f0 00 	movb   $0x0,0xf02bd2b4
f0104533:	c6 05 b5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2b5
f010453a:	c1 e8 10             	shr    $0x10,%eax
f010453d:	66 a3 b6 d2 2b f0    	mov    %ax,0xf02bd2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp, 0);
f0104543:	b8 76 4e 10 f0       	mov    $0xf0104e76,%eax
f0104548:	66 a3 b8 d2 2b f0    	mov    %ax,0xf02bd2b8
f010454e:	66 c7 05 ba d2 2b f0 	movw   $0x8,0xf02bd2ba
f0104555:	08 00 
f0104557:	c6 05 bc d2 2b f0 00 	movb   $0x0,0xf02bd2bc
f010455e:	c6 05 bd d2 2b f0 8e 	movb   $0x8e,0xf02bd2bd
f0104565:	c1 e8 10             	shr    $0x10,%eax
f0104568:	66 a3 be d2 2b f0    	mov    %ax,0xf02bd2be
	SETGATE(idt[T_STACK], 0, GD_KT, stack, 0);
f010456e:	b8 7a 4e 10 f0       	mov    $0xf0104e7a,%eax
f0104573:	66 a3 c0 d2 2b f0    	mov    %ax,0xf02bd2c0
f0104579:	66 c7 05 c2 d2 2b f0 	movw   $0x8,0xf02bd2c2
f0104580:	08 00 
f0104582:	c6 05 c4 d2 2b f0 00 	movb   $0x0,0xf02bd2c4
f0104589:	c6 05 c5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2c5
f0104590:	c1 e8 10             	shr    $0x10,%eax
f0104593:	66 a3 c6 d2 2b f0    	mov    %ax,0xf02bd2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt, 0);
f0104599:	b8 7e 4e 10 f0       	mov    $0xf0104e7e,%eax
f010459e:	66 a3 c8 d2 2b f0    	mov    %ax,0xf02bd2c8
f01045a4:	66 c7 05 ca d2 2b f0 	movw   $0x8,0xf02bd2ca
f01045ab:	08 00 
f01045ad:	c6 05 cc d2 2b f0 00 	movb   $0x0,0xf02bd2cc
f01045b4:	c6 05 cd d2 2b f0 8e 	movb   $0x8e,0xf02bd2cd
f01045bb:	c1 e8 10             	shr    $0x10,%eax
f01045be:	66 a3 ce d2 2b f0    	mov    %ax,0xf02bd2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt, 0);
f01045c4:	b8 82 4e 10 f0       	mov    $0xf0104e82,%eax
f01045c9:	66 a3 d0 d2 2b f0    	mov    %ax,0xf02bd2d0
f01045cf:	66 c7 05 d2 d2 2b f0 	movw   $0x8,0xf02bd2d2
f01045d6:	08 00 
f01045d8:	c6 05 d4 d2 2b f0 00 	movb   $0x0,0xf02bd2d4
f01045df:	c6 05 d5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2d5
f01045e6:	c1 e8 10             	shr    $0x10,%eax
f01045e9:	66 a3 d6 d2 2b f0    	mov    %ax,0xf02bd2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, fperr, 0);
f01045ef:	b8 86 4e 10 f0       	mov    $0xf0104e86,%eax
f01045f4:	66 a3 e0 d2 2b f0    	mov    %ax,0xf02bd2e0
f01045fa:	66 c7 05 e2 d2 2b f0 	movw   $0x8,0xf02bd2e2
f0104601:	08 00 
f0104603:	c6 05 e4 d2 2b f0 00 	movb   $0x0,0xf02bd2e4
f010460a:	c6 05 e5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2e5
f0104611:	c1 e8 10             	shr    $0x10,%eax
f0104614:	66 a3 e6 d2 2b f0    	mov    %ax,0xf02bd2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, align, 0);
f010461a:	b8 8c 4e 10 f0       	mov    $0xf0104e8c,%eax
f010461f:	66 a3 e8 d2 2b f0    	mov    %ax,0xf02bd2e8
f0104625:	66 c7 05 ea d2 2b f0 	movw   $0x8,0xf02bd2ea
f010462c:	08 00 
f010462e:	c6 05 ec d2 2b f0 00 	movb   $0x0,0xf02bd2ec
f0104635:	c6 05 ed d2 2b f0 8e 	movb   $0x8e,0xf02bd2ed
f010463c:	c1 e8 10             	shr    $0x10,%eax
f010463f:	66 a3 ee d2 2b f0    	mov    %ax,0xf02bd2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, mchk, 0);
f0104645:	b8 90 4e 10 f0       	mov    $0xf0104e90,%eax
f010464a:	66 a3 f0 d2 2b f0    	mov    %ax,0xf02bd2f0
f0104650:	66 c7 05 f2 d2 2b f0 	movw   $0x8,0xf02bd2f2
f0104657:	08 00 
f0104659:	c6 05 f4 d2 2b f0 00 	movb   $0x0,0xf02bd2f4
f0104660:	c6 05 f5 d2 2b f0 8e 	movb   $0x8e,0xf02bd2f5
f0104667:	c1 e8 10             	shr    $0x10,%eax
f010466a:	66 a3 f6 d2 2b f0    	mov    %ax,0xf02bd2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr, 0);
f0104670:	b8 96 4e 10 f0       	mov    $0xf0104e96,%eax
f0104675:	66 a3 f8 d2 2b f0    	mov    %ax,0xf02bd2f8
f010467b:	66 c7 05 fa d2 2b f0 	movw   $0x8,0xf02bd2fa
f0104682:	08 00 
f0104684:	c6 05 fc d2 2b f0 00 	movb   $0x0,0xf02bd2fc
f010468b:	c6 05 fd d2 2b f0 8e 	movb   $0x8e,0xf02bd2fd
f0104692:	c1 e8 10             	shr    $0x10,%eax
f0104695:	66 a3 fe d2 2b f0    	mov    %ax,0xf02bd2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trp_syscall, 3);
f010469b:	b8 9c 4e 10 f0       	mov    $0xf0104e9c,%eax
f01046a0:	66 a3 e0 d3 2b f0    	mov    %ax,0xf02bd3e0
f01046a6:	66 c7 05 e2 d3 2b f0 	movw   $0x8,0xf02bd3e2
f01046ad:	08 00 
f01046af:	c6 05 e4 d3 2b f0 00 	movb   $0x0,0xf02bd3e4
f01046b6:	c6 05 e5 d3 2b f0 ee 	movb   $0xee,0xf02bd3e5
f01046bd:	c1 e8 10             	shr    $0x10,%eax
f01046c0:	66 a3 e6 d3 2b f0    	mov    %ax,0xf02bd3e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, i_timer, 0);
f01046c6:	b8 a2 4e 10 f0       	mov    $0xf0104ea2,%eax
f01046cb:	66 a3 60 d3 2b f0    	mov    %ax,0xf02bd360
f01046d1:	66 c7 05 62 d3 2b f0 	movw   $0x8,0xf02bd362
f01046d8:	08 00 
f01046da:	c6 05 64 d3 2b f0 00 	movb   $0x0,0xf02bd364
f01046e1:	c6 05 65 d3 2b f0 8e 	movb   $0x8e,0xf02bd365
f01046e8:	c1 e8 10             	shr    $0x10,%eax
f01046eb:	66 a3 66 d3 2b f0    	mov    %ax,0xf02bd366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, i_kbd, 0);
f01046f1:	b8 a8 4e 10 f0       	mov    $0xf0104ea8,%eax
f01046f6:	66 a3 68 d3 2b f0    	mov    %ax,0xf02bd368
f01046fc:	66 c7 05 6a d3 2b f0 	movw   $0x8,0xf02bd36a
f0104703:	08 00 
f0104705:	c6 05 6c d3 2b f0 00 	movb   $0x0,0xf02bd36c
f010470c:	c6 05 6d d3 2b f0 8e 	movb   $0x8e,0xf02bd36d
f0104713:	c1 e8 10             	shr    $0x10,%eax
f0104716:	66 a3 6e d3 2b f0    	mov    %ax,0xf02bd36e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, i_serial, 0);
f010471c:	b8 ae 4e 10 f0       	mov    $0xf0104eae,%eax
f0104721:	66 a3 80 d3 2b f0    	mov    %ax,0xf02bd380
f0104727:	66 c7 05 82 d3 2b f0 	movw   $0x8,0xf02bd382
f010472e:	08 00 
f0104730:	c6 05 84 d3 2b f0 00 	movb   $0x0,0xf02bd384
f0104737:	c6 05 85 d3 2b f0 8e 	movb   $0x8e,0xf02bd385
f010473e:	c1 e8 10             	shr    $0x10,%eax
f0104741:	66 a3 86 d3 2b f0    	mov    %ax,0xf02bd386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, i_spurious, 0);
f0104747:	b8 b4 4e 10 f0       	mov    $0xf0104eb4,%eax
f010474c:	66 a3 98 d3 2b f0    	mov    %ax,0xf02bd398
f0104752:	66 c7 05 9a d3 2b f0 	movw   $0x8,0xf02bd39a
f0104759:	08 00 
f010475b:	c6 05 9c d3 2b f0 00 	movb   $0x0,0xf02bd39c
f0104762:	c6 05 9d d3 2b f0 8e 	movb   $0x8e,0xf02bd39d
f0104769:	c1 e8 10             	shr    $0x10,%eax
f010476c:	66 a3 9e d3 2b f0    	mov    %ax,0xf02bd39e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, i_ide, 0);
f0104772:	b8 ba 4e 10 f0       	mov    $0xf0104eba,%eax
f0104777:	66 a3 d0 d3 2b f0    	mov    %ax,0xf02bd3d0
f010477d:	66 c7 05 d2 d3 2b f0 	movw   $0x8,0xf02bd3d2
f0104784:	08 00 
f0104786:	c6 05 d4 d3 2b f0 00 	movb   $0x0,0xf02bd3d4
f010478d:	c6 05 d5 d3 2b f0 8e 	movb   $0x8e,0xf02bd3d5
f0104794:	c1 e8 10             	shr    $0x10,%eax
f0104797:	66 a3 d6 d3 2b f0    	mov    %ax,0xf02bd3d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, i_error, 0);
f010479d:	b8 c0 4e 10 f0       	mov    $0xf0104ec0,%eax
f01047a2:	66 a3 f8 d3 2b f0    	mov    %ax,0xf02bd3f8
f01047a8:	66 c7 05 fa d3 2b f0 	movw   $0x8,0xf02bd3fa
f01047af:	08 00 
f01047b1:	c6 05 fc d3 2b f0 00 	movb   $0x0,0xf02bd3fc
f01047b8:	c6 05 fd d3 2b f0 8e 	movb   $0x8e,0xf02bd3fd
f01047bf:	c1 e8 10             	shr    $0x10,%eax
f01047c2:	66 a3 fe d3 2b f0    	mov    %ax,0xf02bd3fe

	// Per-CPU setup 
	trap_init_percpu();
f01047c8:	e8 e3 fa ff ff       	call   f01042b0 <trap_init_percpu>
}
f01047cd:	c9                   	leave  
f01047ce:	c3                   	ret    

f01047cf <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01047cf:	55                   	push   %ebp
f01047d0:	89 e5                	mov    %esp,%ebp
f01047d2:	53                   	push   %ebx
f01047d3:	83 ec 14             	sub    $0x14,%esp
f01047d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01047d9:	8b 03                	mov    (%ebx),%eax
f01047db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047df:	c7 04 24 70 91 10 f0 	movl   $0xf0109170,(%esp)
f01047e6:	e8 9e fa ff ff       	call   f0104289 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01047eb:	8b 43 04             	mov    0x4(%ebx),%eax
f01047ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f2:	c7 04 24 7f 91 10 f0 	movl   $0xf010917f,(%esp)
f01047f9:	e8 8b fa ff ff       	call   f0104289 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01047fe:	8b 43 08             	mov    0x8(%ebx),%eax
f0104801:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104805:	c7 04 24 8e 91 10 f0 	movl   $0xf010918e,(%esp)
f010480c:	e8 78 fa ff ff       	call   f0104289 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104811:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104814:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104818:	c7 04 24 9d 91 10 f0 	movl   $0xf010919d,(%esp)
f010481f:	e8 65 fa ff ff       	call   f0104289 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104824:	8b 43 10             	mov    0x10(%ebx),%eax
f0104827:	89 44 24 04          	mov    %eax,0x4(%esp)
f010482b:	c7 04 24 ac 91 10 f0 	movl   $0xf01091ac,(%esp)
f0104832:	e8 52 fa ff ff       	call   f0104289 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104837:	8b 43 14             	mov    0x14(%ebx),%eax
f010483a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010483e:	c7 04 24 bb 91 10 f0 	movl   $0xf01091bb,(%esp)
f0104845:	e8 3f fa ff ff       	call   f0104289 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010484a:	8b 43 18             	mov    0x18(%ebx),%eax
f010484d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104851:	c7 04 24 ca 91 10 f0 	movl   $0xf01091ca,(%esp)
f0104858:	e8 2c fa ff ff       	call   f0104289 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010485d:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104860:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104864:	c7 04 24 d9 91 10 f0 	movl   $0xf01091d9,(%esp)
f010486b:	e8 19 fa ff ff       	call   f0104289 <cprintf>
}
f0104870:	83 c4 14             	add    $0x14,%esp
f0104873:	5b                   	pop    %ebx
f0104874:	5d                   	pop    %ebp
f0104875:	c3                   	ret    

f0104876 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104876:	55                   	push   %ebp
f0104877:	89 e5                	mov    %esp,%ebp
f0104879:	56                   	push   %esi
f010487a:	53                   	push   %ebx
f010487b:	83 ec 10             	sub    $0x10,%esp
f010487e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104881:	e8 13 21 00 00       	call   f0106999 <cpunum>
f0104886:	89 44 24 08          	mov    %eax,0x8(%esp)
f010488a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010488e:	c7 04 24 3d 92 10 f0 	movl   $0xf010923d,(%esp)
f0104895:	e8 ef f9 ff ff       	call   f0104289 <cprintf>
	print_regs(&tf->tf_regs);
f010489a:	89 1c 24             	mov    %ebx,(%esp)
f010489d:	e8 2d ff ff ff       	call   f01047cf <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048a2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048aa:	c7 04 24 5b 92 10 f0 	movl   $0xf010925b,(%esp)
f01048b1:	e8 d3 f9 ff ff       	call   f0104289 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01048b6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 6e 92 10 f0 	movl   $0xf010926e,(%esp)
f01048c5:	e8 bf f9 ff ff       	call   f0104289 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048ca:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01048cd:	83 f8 13             	cmp    $0x13,%eax
f01048d0:	77 09                	ja     f01048db <print_trapframe+0x65>
		return excnames[trapno];
f01048d2:	8b 14 85 00 95 10 f0 	mov    -0xfef6b00(,%eax,4),%edx
f01048d9:	eb 1f                	jmp    f01048fa <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01048db:	83 f8 30             	cmp    $0x30,%eax
f01048de:	74 15                	je     f01048f5 <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01048e0:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01048e3:	83 fa 0f             	cmp    $0xf,%edx
f01048e6:	ba f4 91 10 f0       	mov    $0xf01091f4,%edx
f01048eb:	b9 07 92 10 f0       	mov    $0xf0109207,%ecx
f01048f0:	0f 47 d1             	cmova  %ecx,%edx
f01048f3:	eb 05                	jmp    f01048fa <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01048f5:	ba e8 91 10 f0       	mov    $0xf01091e8,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048fa:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104902:	c7 04 24 81 92 10 f0 	movl   $0xf0109281,(%esp)
f0104909:	e8 7b f9 ff ff       	call   f0104289 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010490e:	3b 1d 60 da 2b f0    	cmp    0xf02bda60,%ebx
f0104914:	75 19                	jne    f010492f <print_trapframe+0xb9>
f0104916:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010491a:	75 13                	jne    f010492f <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010491c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010491f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104923:	c7 04 24 93 92 10 f0 	movl   $0xf0109293,(%esp)
f010492a:	e8 5a f9 ff ff       	call   f0104289 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010492f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104932:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104936:	c7 04 24 a2 92 10 f0 	movl   $0xf01092a2,(%esp)
f010493d:	e8 47 f9 ff ff       	call   f0104289 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104942:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104946:	75 51                	jne    f0104999 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104948:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010494b:	89 c2                	mov    %eax,%edx
f010494d:	83 e2 01             	and    $0x1,%edx
f0104950:	ba 16 92 10 f0       	mov    $0xf0109216,%edx
f0104955:	b9 21 92 10 f0       	mov    $0xf0109221,%ecx
f010495a:	0f 45 ca             	cmovne %edx,%ecx
f010495d:	89 c2                	mov    %eax,%edx
f010495f:	83 e2 02             	and    $0x2,%edx
f0104962:	ba 2d 92 10 f0       	mov    $0xf010922d,%edx
f0104967:	be 33 92 10 f0       	mov    $0xf0109233,%esi
f010496c:	0f 44 d6             	cmove  %esi,%edx
f010496f:	83 e0 04             	and    $0x4,%eax
f0104972:	b8 38 92 10 f0       	mov    $0xf0109238,%eax
f0104977:	be 88 93 10 f0       	mov    $0xf0109388,%esi
f010497c:	0f 44 c6             	cmove  %esi,%eax
f010497f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104983:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104987:	89 44 24 04          	mov    %eax,0x4(%esp)
f010498b:	c7 04 24 b0 92 10 f0 	movl   $0xf01092b0,(%esp)
f0104992:	e8 f2 f8 ff ff       	call   f0104289 <cprintf>
f0104997:	eb 0c                	jmp    f01049a5 <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104999:	c7 04 24 32 7f 10 f0 	movl   $0xf0107f32,(%esp)
f01049a0:	e8 e4 f8 ff ff       	call   f0104289 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049a5:	8b 43 30             	mov    0x30(%ebx),%eax
f01049a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ac:	c7 04 24 bf 92 10 f0 	movl   $0xf01092bf,(%esp)
f01049b3:	e8 d1 f8 ff ff       	call   f0104289 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01049b8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01049bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049c0:	c7 04 24 ce 92 10 f0 	movl   $0xf01092ce,(%esp)
f01049c7:	e8 bd f8 ff ff       	call   f0104289 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01049cc:	8b 43 38             	mov    0x38(%ebx),%eax
f01049cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d3:	c7 04 24 e1 92 10 f0 	movl   $0xf01092e1,(%esp)
f01049da:	e8 aa f8 ff ff       	call   f0104289 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01049df:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01049e3:	74 27                	je     f0104a0c <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01049e5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ec:	c7 04 24 f0 92 10 f0 	movl   $0xf01092f0,(%esp)
f01049f3:	e8 91 f8 ff ff       	call   f0104289 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01049f8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01049fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a00:	c7 04 24 ff 92 10 f0 	movl   $0xf01092ff,(%esp)
f0104a07:	e8 7d f8 ff ff       	call   f0104289 <cprintf>
	}
}
f0104a0c:	83 c4 10             	add    $0x10,%esp
f0104a0f:	5b                   	pop    %ebx
f0104a10:	5e                   	pop    %esi
f0104a11:	5d                   	pop    %ebp
f0104a12:	c3                   	ret    

f0104a13 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104a13:	55                   	push   %ebp
f0104a14:	89 e5                	mov    %esp,%ebp
f0104a16:	57                   	push   %edi
f0104a17:	56                   	push   %esi
f0104a18:	53                   	push   %ebx
f0104a19:	83 ec 2c             	sub    $0x2c,%esp
f0104a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a1f:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 1) == 0) {
f0104a22:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0104a26:	75 1c                	jne    f0104a44 <page_fault_handler+0x31>
		panic("Page fault in kernel mode!");
f0104a28:	c7 44 24 08 12 93 10 	movl   $0xf0109312,0x8(%esp)
f0104a2f:	f0 
f0104a30:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0104a37:	00 
f0104a38:	c7 04 24 2d 93 10 f0 	movl   $0xf010932d,(%esp)
f0104a3f:	e8 fc b5 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if(curenv->env_pgfault_upcall) {
f0104a44:	e8 50 1f 00 00       	call   f0106999 <cpunum>
f0104a49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4c:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104a52:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104a56:	0f 84 e8 00 00 00    	je     f0104b44 <page_fault_handler+0x131>
		uint32_t *sp;
		if((UXSTACKTOP-PGSIZE) <= tf->tf_esp && tf->tf_esp <= (UXSTACKTOP-1)) {
f0104a5c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a5f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			sp = (uint32_t*)tf->tf_esp;
			sp --; //"push empty word"
f0104a65:	83 e8 04             	sub    $0x4,%eax
f0104a68:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104a6e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104a73:	0f 46 d0             	cmovbe %eax,%edx
f0104a76:	89 d7                	mov    %edx,%edi
f0104a78:	89 55 e0             	mov    %edx,-0x20(%ebp)
		} else {
			sp = (uint32_t*) UXSTACKTOP;
		}
		sp -= 13;
f0104a7b:	8d 42 cc             	lea    -0x34(%edx),%eax
f0104a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		user_mem_assert(curenv, (const void *)sp, 1, PTE_W | PTE_U);
f0104a81:	e8 13 1f 00 00       	call   f0106999 <cpunum>
f0104a86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104a8d:	00 
f0104a8e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104a95:	00 
f0104a96:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104a99:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104a9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa0:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104aa6:	89 04 24             	mov    %eax,(%esp)
f0104aa9:	e8 58 ee ff ff       	call   f0103906 <user_mem_assert>
		*sp = fault_va;
f0104aae:	89 77 cc             	mov    %esi,-0x34(%edi)
		*(sp+1) = tf->tf_err;
f0104ab1:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104ab4:	89 47 d0             	mov    %eax,-0x30(%edi)
		*((struct PushRegs *)(sp+2)) = tf->tf_regs;
f0104ab7:	8d 7f d4             	lea    -0x2c(%edi),%edi
f0104aba:	89 de                	mov    %ebx,%esi
f0104abc:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ac1:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104ac7:	74 03                	je     f0104acc <page_fault_handler+0xb9>
f0104ac9:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104aca:	b0 1f                	mov    $0x1f,%al
f0104acc:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ad2:	74 05                	je     f0104ad9 <page_fault_handler+0xc6>
f0104ad4:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104ad6:	83 e8 02             	sub    $0x2,%eax
f0104ad9:	89 c1                	mov    %eax,%ecx
f0104adb:	c1 e9 02             	shr    $0x2,%ecx
f0104ade:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104ae0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ae5:	a8 02                	test   $0x2,%al
f0104ae7:	74 0b                	je     f0104af4 <page_fault_handler+0xe1>
f0104ae9:	0f b7 16             	movzwl (%esi),%edx
f0104aec:	66 89 17             	mov    %dx,(%edi)
f0104aef:	ba 02 00 00 00       	mov    $0x2,%edx
f0104af4:	a8 01                	test   $0x1,%al
f0104af6:	74 07                	je     f0104aff <page_fault_handler+0xec>
f0104af8:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104afc:	88 04 17             	mov    %al,(%edi,%edx,1)
		*(sp+10) = tf->tf_eip;
f0104aff:	8b 43 30             	mov    0x30(%ebx),%eax
f0104b02:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b05:	89 41 f4             	mov    %eax,-0xc(%ecx)
		*(sp+11) = tf->tf_eflags;
f0104b08:	8b 43 38             	mov    0x38(%ebx),%eax
f0104b0b:	89 41 f8             	mov    %eax,-0x8(%ecx)
		*(sp+12) = tf->tf_esp;
f0104b0e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104b11:	89 41 fc             	mov    %eax,-0x4(%ecx)
		
		tf->tf_esp = (uintptr_t) sp;
f0104b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b17:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104b1a:	e8 7a 1e 00 00       	call   f0106999 <cpunum>
f0104b1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b22:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104b28:	8b 40 64             	mov    0x64(%eax),%eax
f0104b2b:	89 43 30             	mov    %eax,0x30(%ebx)

		env_run(curenv);
f0104b2e:	e8 66 1e 00 00       	call   f0106999 <cpunum>
f0104b33:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b36:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104b3c:	89 04 24             	mov    %eax,(%esp)
f0104b3f:	e8 ed f4 ff ff       	call   f0104031 <env_run>
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b44:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104b47:	e8 4d 1e 00 00       	call   f0106999 <cpunum>
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b4c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104b50:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104b54:	6b c0 74             	imul   $0x74,%eax,%eax
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b57:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104b5d:	8b 40 48             	mov    0x48(%eax),%eax
f0104b60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b64:	c7 04 24 d4 94 10 f0 	movl   $0xf01094d4,(%esp)
f0104b6b:	e8 19 f7 ff ff       	call   f0104289 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104b70:	89 1c 24             	mov    %ebx,(%esp)
f0104b73:	e8 fe fc ff ff       	call   f0104876 <print_trapframe>
		env_destroy(curenv);
f0104b78:	e8 1c 1e 00 00       	call   f0106999 <cpunum>
f0104b7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b80:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104b86:	89 04 24             	mov    %eax,(%esp)
f0104b89:	e8 02 f4 ff ff       	call   f0103f90 <env_destroy>
	}
}
f0104b8e:	83 c4 2c             	add    $0x2c,%esp
f0104b91:	5b                   	pop    %ebx
f0104b92:	5e                   	pop    %esi
f0104b93:	5f                   	pop    %edi
f0104b94:	5d                   	pop    %ebp
f0104b95:	c3                   	ret    

f0104b96 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104b96:	55                   	push   %ebp
f0104b97:	89 e5                	mov    %esp,%ebp
f0104b99:	57                   	push   %edi
f0104b9a:	56                   	push   %esi
f0104b9b:	83 ec 20             	sub    $0x20,%esp
f0104b9e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104ba1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104ba2:	83 3d 8c de 2b f0 00 	cmpl   $0x0,0xf02bde8c
f0104ba9:	74 01                	je     f0104bac <trap+0x16>
		asm volatile("hlt");
f0104bab:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104bac:	e8 e8 1d 00 00       	call   f0106999 <cpunum>
f0104bb1:	6b d0 74             	imul   $0x74,%eax,%edx
f0104bb4:	81 c2 20 f0 2b f0    	add    $0xf02bf020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104bba:	b8 01 00 00 00       	mov    $0x1,%eax
f0104bbf:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104bc3:	83 f8 02             	cmp    $0x2,%eax
f0104bc6:	75 0c                	jne    f0104bd4 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104bc8:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f0104bcf:	e8 43 20 00 00       	call   f0106c17 <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104bd4:	9c                   	pushf  
f0104bd5:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104bd6:	f6 c4 02             	test   $0x2,%ah
f0104bd9:	74 24                	je     f0104bff <trap+0x69>
f0104bdb:	c7 44 24 0c 39 93 10 	movl   $0xf0109339,0xc(%esp)
f0104be2:	f0 
f0104be3:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0104bea:	f0 
f0104beb:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0104bf2:	00 
f0104bf3:	c7 04 24 2d 93 10 f0 	movl   $0xf010932d,(%esp)
f0104bfa:	e8 41 b4 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104bff:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c03:	83 e0 03             	and    $0x3,%eax
f0104c06:	66 83 f8 03          	cmp    $0x3,%ax
f0104c0a:	0f 85 a7 00 00 00    	jne    f0104cb7 <trap+0x121>
f0104c10:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f0104c17:	e8 fb 1f 00 00       	call   f0106c17 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104c1c:	e8 78 1d 00 00       	call   f0106999 <cpunum>
f0104c21:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c24:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0104c2b:	75 24                	jne    f0104c51 <trap+0xbb>
f0104c2d:	c7 44 24 0c 52 93 10 	movl   $0xf0109352,0xc(%esp)
f0104c34:	f0 
f0104c35:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0104c3c:	f0 
f0104c3d:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0104c44:	00 
f0104c45:	c7 04 24 2d 93 10 f0 	movl   $0xf010932d,(%esp)
f0104c4c:	e8 ef b3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104c51:	e8 43 1d 00 00       	call   f0106999 <cpunum>
f0104c56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c59:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104c5f:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104c63:	75 2d                	jne    f0104c92 <trap+0xfc>
			env_free(curenv);
f0104c65:	e8 2f 1d 00 00       	call   f0106999 <cpunum>
f0104c6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c6d:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104c73:	89 04 24             	mov    %eax,(%esp)
f0104c76:	e8 4a f1 ff ff       	call   f0103dc5 <env_free>
			curenv = NULL;
f0104c7b:	e8 19 1d 00 00       	call   f0106999 <cpunum>
f0104c80:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c83:	c7 80 28 f0 2b f0 00 	movl   $0x0,-0xfd40fd8(%eax)
f0104c8a:	00 00 00 
			sched_yield();
f0104c8d:	e8 1c 03 00 00       	call   f0104fae <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104c92:	e8 02 1d 00 00       	call   f0106999 <cpunum>
f0104c97:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c9a:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104ca0:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ca5:	89 c7                	mov    %eax,%edi
f0104ca7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104ca9:	e8 eb 1c 00 00       	call   f0106999 <cpunum>
f0104cae:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb1:	8b b0 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104cb7:	89 35 60 da 2b f0    	mov    %esi,0xf02bda60
{
	// Handle processor exceptions.
	// LAB 3: Your code here.


	switch(tf->tf_trapno) {
f0104cbd:	8b 46 28             	mov    0x28(%esi),%eax
f0104cc0:	83 f8 20             	cmp    $0x20,%eax
f0104cc3:	74 6b                	je     f0104d30 <trap+0x19a>
f0104cc5:	83 f8 20             	cmp    $0x20,%eax
f0104cc8:	77 21                	ja     f0104ceb <trap+0x155>
f0104cca:	83 f8 03             	cmp    $0x3,%eax
f0104ccd:	0f 84 9f 00 00 00    	je     f0104d72 <trap+0x1dc>
f0104cd3:	83 f8 0e             	cmp    $0xe,%eax
f0104cd6:	0f 84 89 00 00 00    	je     f0104d65 <trap+0x1cf>
f0104cdc:	83 f8 01             	cmp    $0x1,%eax
f0104cdf:	90                   	nop
f0104ce0:	0f 85 d2 00 00 00    	jne    f0104db8 <trap+0x222>
f0104ce6:	e9 91 00 00 00       	jmp    f0104d7c <trap+0x1e6>
f0104ceb:	83 f8 24             	cmp    $0x24,%eax
f0104cee:	66 90                	xchg   %ax,%ax
f0104cf0:	74 63                	je     f0104d55 <trap+0x1bf>
f0104cf2:	83 f8 24             	cmp    $0x24,%eax
f0104cf5:	77 0e                	ja     f0104d05 <trap+0x16f>
f0104cf7:	83 f8 21             	cmp    $0x21,%eax
f0104cfa:	74 4e                	je     f0104d4a <trap+0x1b4>
f0104cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d00:	e9 b3 00 00 00       	jmp    f0104db8 <trap+0x222>
f0104d05:	83 f8 27             	cmp    $0x27,%eax
f0104d08:	74 0d                	je     f0104d17 <trap+0x181>
f0104d0a:	83 f8 30             	cmp    $0x30,%eax
f0104d0d:	8d 76 00             	lea    0x0(%esi),%esi
f0104d10:	74 74                	je     f0104d86 <trap+0x1f0>
f0104d12:	e9 a1 00 00 00       	jmp    f0104db8 <trap+0x222>
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
		case IRQ_OFFSET + IRQ_SPURIOUS:
			cprintf("Spurious interrupt on irq 7\n");
f0104d17:	c7 04 24 59 93 10 f0 	movl   $0xf0109359,(%esp)
f0104d1e:	e8 66 f5 ff ff       	call   f0104289 <cprintf>
			print_trapframe(tf);
f0104d23:	89 34 24             	mov    %esi,(%esp)
f0104d26:	e8 4b fb ff ff       	call   f0104876 <print_trapframe>
f0104d2b:	e9 c9 00 00 00       	jmp    f0104df9 <trap+0x263>
	// Add time tick increment to clock interrupts.
	// Be careful! In multiprocessors, clock interrupts are
	// triggered on every CPU.
	// LAB 6: Your code here.
		case IRQ_OFFSET + IRQ_TIMER:
			lapic_eoi();
f0104d30:	e8 b1 1d 00 00       	call   f0106ae6 <lapic_eoi>
			if(cpunum() == 0) {
f0104d35:	e8 5f 1c 00 00       	call   f0106999 <cpunum>
f0104d3a:	85 c0                	test   %eax,%eax
f0104d3c:	75 07                	jne    f0104d45 <trap+0x1af>
				time_tick();
f0104d3e:	66 90                	xchg   %ax,%ax
f0104d40:	e8 7b 2b 00 00       	call   f01078c0 <time_tick>
			}
			sched_yield();
f0104d45:	e8 64 02 00 00       	call   f0104fae <sched_yield>


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
		case IRQ_OFFSET + IRQ_KBD:
			kbd_intr();
f0104d4a:	e8 14 b9 ff ff       	call   f0100663 <kbd_intr>
f0104d4f:	90                   	nop
f0104d50:	e9 a4 00 00 00       	jmp    f0104df9 <trap+0x263>
			return;
		case IRQ_OFFSET + IRQ_SERIAL:
			serial_intr();
f0104d55:	e8 ed b8 ff ff       	call   f0100647 <serial_intr>
f0104d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104d60:	e9 94 00 00 00       	jmp    f0104df9 <trap+0x263>
			return;
		case T_PGFLT:
			page_fault_handler(tf);
f0104d65:	89 34 24             	mov    %esi,(%esp)
f0104d68:	e8 a6 fc ff ff       	call   f0104a13 <page_fault_handler>
f0104d6d:	8d 76 00             	lea    0x0(%esi),%esi
f0104d70:	eb 46                	jmp    f0104db8 <trap+0x222>
			break;
		case T_BRKPT:
			return monitor(tf);
f0104d72:	89 34 24             	mov    %esi,(%esp)
f0104d75:	e8 78 c0 ff ff       	call   f0100df2 <monitor>
f0104d7a:	eb 7d                	jmp    f0104df9 <trap+0x263>
		case T_DEBUG:
			return monitor(tf);
f0104d7c:	89 34 24             	mov    %esi,(%esp)
f0104d7f:	e8 6e c0 ff ff       	call   f0100df2 <monitor>
f0104d84:	eb 73                	jmp    f0104df9 <trap+0x263>
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f0104d86:	8b 46 04             	mov    0x4(%esi),%eax
f0104d89:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104d8d:	8b 06                	mov    (%esi),%eax
f0104d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104d93:	8b 46 10             	mov    0x10(%esi),%eax
f0104d96:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d9a:	8b 46 18             	mov    0x18(%esi),%eax
f0104d9d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104da1:	8b 46 14             	mov    0x14(%esi),%eax
f0104da4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104da8:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104dab:	89 04 24             	mov    %eax,(%esp)
f0104dae:	e8 cd 02 00 00       	call   f0105080 <syscall>
f0104db3:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104db6:	eb 41                	jmp    f0104df9 <trap+0x263>
			return;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104db8:	89 34 24             	mov    %esi,(%esp)
f0104dbb:	e8 b6 fa ff ff       	call   f0104876 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104dc0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104dc5:	75 1c                	jne    f0104de3 <trap+0x24d>
		panic("unhandled trap in kernel");
f0104dc7:	c7 44 24 08 76 93 10 	movl   $0xf0109376,0x8(%esp)
f0104dce:	f0 
f0104dcf:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
f0104dd6:	00 
f0104dd7:	c7 04 24 2d 93 10 f0 	movl   $0xf010932d,(%esp)
f0104dde:	e8 5d b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104de3:	e8 b1 1b 00 00       	call   f0106999 <cpunum>
f0104de8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104deb:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104df1:	89 04 24             	mov    %eax,(%esp)
f0104df4:	e8 97 f1 ff ff       	call   f0103f90 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104df9:	e8 9b 1b 00 00       	call   f0106999 <cpunum>
f0104dfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e01:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0104e08:	74 2a                	je     f0104e34 <trap+0x29e>
f0104e0a:	e8 8a 1b 00 00       	call   f0106999 <cpunum>
f0104e0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e12:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104e18:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e1c:	75 16                	jne    f0104e34 <trap+0x29e>
		env_run(curenv);
f0104e1e:	e8 76 1b 00 00       	call   f0106999 <cpunum>
f0104e23:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e26:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104e2c:	89 04 24             	mov    %eax,(%esp)
f0104e2f:	e8 fd f1 ff ff       	call   f0104031 <env_run>
	else
		sched_yield();
f0104e34:	e8 75 01 00 00       	call   f0104fae <sched_yield>
f0104e39:	90                   	nop

f0104e3a <divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
*/
TRAPHANDLER_NOEC(divide, T_DIVIDE)
f0104e3a:	6a 00                	push   $0x0
f0104e3c:	6a 00                	push   $0x0
f0104e3e:	e9 83 00 00 00       	jmp    f0104ec6 <_alltraps>
f0104e43:	90                   	nop

f0104e44 <debug>:
TRAPHANDLER_NOEC(debug, T_DEBUG)
f0104e44:	6a 00                	push   $0x0
f0104e46:	6a 01                	push   $0x1
f0104e48:	eb 7c                	jmp    f0104ec6 <_alltraps>

f0104e4a <nmi>:
TRAPHANDLER_NOEC(nmi, T_NMI)
f0104e4a:	6a 00                	push   $0x0
f0104e4c:	6a 02                	push   $0x2
f0104e4e:	eb 76                	jmp    f0104ec6 <_alltraps>

f0104e50 <brkpt>:
TRAPHANDLER_NOEC(brkpt, T_BRKPT)
f0104e50:	6a 00                	push   $0x0
f0104e52:	6a 03                	push   $0x3
f0104e54:	eb 70                	jmp    f0104ec6 <_alltraps>

f0104e56 <oflow>:
TRAPHANDLER_NOEC(oflow, T_OFLOW)
f0104e56:	6a 00                	push   $0x0
f0104e58:	6a 04                	push   $0x4
f0104e5a:	eb 6a                	jmp    f0104ec6 <_alltraps>

f0104e5c <bound>:
TRAPHANDLER_NOEC(bound, T_BOUND)
f0104e5c:	6a 00                	push   $0x0
f0104e5e:	6a 05                	push   $0x5
f0104e60:	eb 64                	jmp    f0104ec6 <_alltraps>

f0104e62 <illop>:
TRAPHANDLER_NOEC(illop, T_ILLOP)
f0104e62:	6a 00                	push   $0x0
f0104e64:	6a 06                	push   $0x6
f0104e66:	eb 5e                	jmp    f0104ec6 <_alltraps>

f0104e68 <device>:
TRAPHANDLER_NOEC(device, T_DEVICE)
f0104e68:	6a 00                	push   $0x0
f0104e6a:	6a 07                	push   $0x7
f0104e6c:	eb 58                	jmp    f0104ec6 <_alltraps>

f0104e6e <dblflt>:
TRAPHANDLER(dblflt, T_DBLFLT)
f0104e6e:	6a 08                	push   $0x8
f0104e70:	eb 54                	jmp    f0104ec6 <_alltraps>

f0104e72 <tss>:
// 9 is reserved
TRAPHANDLER(tss, T_TSS)
f0104e72:	6a 0a                	push   $0xa
f0104e74:	eb 50                	jmp    f0104ec6 <_alltraps>

f0104e76 <segnp>:
TRAPHANDLER(segnp, T_SEGNP)
f0104e76:	6a 0b                	push   $0xb
f0104e78:	eb 4c                	jmp    f0104ec6 <_alltraps>

f0104e7a <stack>:
TRAPHANDLER(stack, T_STACK)
f0104e7a:	6a 0c                	push   $0xc
f0104e7c:	eb 48                	jmp    f0104ec6 <_alltraps>

f0104e7e <gpflt>:
TRAPHANDLER(gpflt, T_GPFLT)
f0104e7e:	6a 0d                	push   $0xd
f0104e80:	eb 44                	jmp    f0104ec6 <_alltraps>

f0104e82 <pgflt>:
TRAPHANDLER(pgflt, T_PGFLT)
f0104e82:	6a 0e                	push   $0xe
f0104e84:	eb 40                	jmp    f0104ec6 <_alltraps>

f0104e86 <fperr>:
//15 is reserved
TRAPHANDLER_NOEC(fperr, T_FPERR)
f0104e86:	6a 00                	push   $0x0
f0104e88:	6a 10                	push   $0x10
f0104e8a:	eb 3a                	jmp    f0104ec6 <_alltraps>

f0104e8c <align>:
TRAPHANDLER(align, T_ALIGN)
f0104e8c:	6a 11                	push   $0x11
f0104e8e:	eb 36                	jmp    f0104ec6 <_alltraps>

f0104e90 <mchk>:
TRAPHANDLER_NOEC(mchk, T_MCHK)
f0104e90:	6a 00                	push   $0x0
f0104e92:	6a 12                	push   $0x12
f0104e94:	eb 30                	jmp    f0104ec6 <_alltraps>

f0104e96 <simderr>:
TRAPHANDLER_NOEC(simderr, T_SIMDERR)
f0104e96:	6a 00                	push   $0x0
f0104e98:	6a 13                	push   $0x13
f0104e9a:	eb 2a                	jmp    f0104ec6 <_alltraps>

f0104e9c <trp_syscall>:
TRAPHANDLER_NOEC(trp_syscall, T_SYSCALL)
f0104e9c:	6a 00                	push   $0x0
f0104e9e:	6a 30                	push   $0x30
f0104ea0:	eb 24                	jmp    f0104ec6 <_alltraps>

f0104ea2 <i_timer>:

TRAPHANDLER_NOEC(i_timer, IRQ_OFFSET + IRQ_TIMER)
f0104ea2:	6a 00                	push   $0x0
f0104ea4:	6a 20                	push   $0x20
f0104ea6:	eb 1e                	jmp    f0104ec6 <_alltraps>

f0104ea8 <i_kbd>:
TRAPHANDLER_NOEC(i_kbd,  IRQ_OFFSET + IRQ_KBD)
f0104ea8:	6a 00                	push   $0x0
f0104eaa:	6a 21                	push   $0x21
f0104eac:	eb 18                	jmp    f0104ec6 <_alltraps>

f0104eae <i_serial>:
TRAPHANDLER_NOEC(i_serial,  IRQ_OFFSET + IRQ_SERIAL)
f0104eae:	6a 00                	push   $0x0
f0104eb0:	6a 24                	push   $0x24
f0104eb2:	eb 12                	jmp    f0104ec6 <_alltraps>

f0104eb4 <i_spurious>:
TRAPHANDLER_NOEC(i_spurious,  IRQ_OFFSET + IRQ_SPURIOUS)
f0104eb4:	6a 00                	push   $0x0
f0104eb6:	6a 27                	push   $0x27
f0104eb8:	eb 0c                	jmp    f0104ec6 <_alltraps>

f0104eba <i_ide>:
TRAPHANDLER_NOEC(i_ide,  IRQ_OFFSET + IRQ_IDE)
f0104eba:	6a 00                	push   $0x0
f0104ebc:	6a 2e                	push   $0x2e
f0104ebe:	eb 06                	jmp    f0104ec6 <_alltraps>

f0104ec0 <i_error>:
TRAPHANDLER_NOEC(i_error,  IRQ_OFFSET + IRQ_ERROR)
f0104ec0:	6a 00                	push   $0x0
f0104ec2:	6a 33                	push   $0x33
f0104ec4:	eb 00                	jmp    f0104ec6 <_alltraps>

f0104ec6 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds //pushes with padding
f0104ec6:	1e                   	push   %ds
	pushl %es
f0104ec7:	06                   	push   %es
	pushal //push all registers
f0104ec8:	60                   	pusha  

	movl $GD_KD, %eax
f0104ec9:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %es
f0104ece:	8e c0                	mov    %eax,%es
	movl %eax, %ds
f0104ed0:	8e d8                	mov    %eax,%ds
	pushl %esp
f0104ed2:	54                   	push   %esp
	call trap
f0104ed3:	e8 be fc ff ff       	call   f0104b96 <trap>

f0104ed8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104ed8:	55                   	push   %ebp
f0104ed9:	89 e5                	mov    %esp,%ebp
f0104edb:	83 ec 18             	sub    $0x18,%esp
f0104ede:	8b 15 48 d2 2b f0    	mov    0xf02bd248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ee4:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104ee9:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104eec:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104eef:	83 f9 02             	cmp    $0x2,%ecx
f0104ef2:	76 0f                	jbe    f0104f03 <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ef4:	83 c0 01             	add    $0x1,%eax
f0104ef7:	83 c2 7c             	add    $0x7c,%edx
f0104efa:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104eff:	75 e8                	jne    f0104ee9 <sched_halt+0x11>
f0104f01:	eb 07                	jmp    f0104f0a <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104f03:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f08:	75 1a                	jne    f0104f24 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104f0a:	c7 04 24 50 95 10 f0 	movl   $0xf0109550,(%esp)
f0104f11:	e8 73 f3 ff ff       	call   f0104289 <cprintf>
		while (1)
			monitor(NULL);
f0104f16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f1d:	e8 d0 be ff ff       	call   f0100df2 <monitor>
f0104f22:	eb f2                	jmp    f0104f16 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104f24:	e8 70 1a 00 00       	call   f0106999 <cpunum>
f0104f29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f2c:	c7 80 28 f0 2b f0 00 	movl   $0x0,-0xfd40fd8(%eax)
f0104f33:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104f36:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104f3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104f40:	77 20                	ja     f0104f62 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104f42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f46:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0104f4d:	f0 
f0104f4e:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0104f55:	00 
f0104f56:	c7 04 24 79 95 10 f0 	movl   $0xf0109579,(%esp)
f0104f5d:	e8 de b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104f62:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104f67:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104f6a:	e8 2a 1a 00 00       	call   f0106999 <cpunum>
f0104f6f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104f72:	81 c2 20 f0 2b f0    	add    $0xf02bf020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104f78:	b8 02 00 00 00       	mov    $0x2,%eax
f0104f7d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104f81:	c7 04 24 c0 53 12 f0 	movl   $0xf01253c0,(%esp)
f0104f88:	e8 36 1d 00 00       	call   f0106cc3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104f8d:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104f8f:	e8 05 1a 00 00       	call   f0106999 <cpunum>
f0104f94:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104f97:	8b 80 30 f0 2b f0    	mov    -0xfd40fd0(%eax),%eax
f0104f9d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104fa2:	89 c4                	mov    %eax,%esp
f0104fa4:	6a 00                	push   $0x0
f0104fa6:	6a 00                	push   $0x0
f0104fa8:	fb                   	sti    
f0104fa9:	f4                   	hlt    
f0104faa:	eb fd                	jmp    f0104fa9 <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104fac:	c9                   	leave  
f0104fad:	c3                   	ret    

f0104fae <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104fae:	55                   	push   %ebp
f0104faf:	89 e5                	mov    %esp,%ebp
f0104fb1:	57                   	push   %edi
f0104fb2:	56                   	push   %esi
f0104fb3:	53                   	push   %ebx
f0104fb4:	83 ec 1c             	sub    $0x1c,%esp
f0104fb7:	be 00 00 00 00       	mov    $0x0,%esi
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.
	int id = 0 ;
	for(id = 0; id < NENV; id++) {
f0104fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(curenv && envs[id].env_id == curenv->env_id) break;
f0104fc1:	e8 d3 19 00 00       	call   f0106999 <cpunum>
f0104fc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fc9:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0104fd0:	74 1c                	je     f0104fee <sched_yield+0x40>
f0104fd2:	a1 48 d2 2b f0       	mov    0xf02bd248,%eax
f0104fd7:	8b 7c 30 48          	mov    0x48(%eax,%esi,1),%edi
f0104fdb:	e8 b9 19 00 00       	call   f0106999 <cpunum>
f0104fe0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fe3:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0104fe9:	3b 78 48             	cmp    0x48(%eax),%edi
f0104fec:	74 0e                	je     f0104ffc <sched_yield+0x4e>
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.
	int id = 0 ;
	for(id = 0; id < NENV; id++) {
f0104fee:	83 c3 01             	add    $0x1,%ebx
f0104ff1:	83 c6 7c             	add    $0x7c,%esi
f0104ff4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104ffa:	75 c5                	jne    f0104fc1 <sched_yield+0x13>
		if(curenv && envs[id].env_id == curenv->env_id) break;
	}
	// LAB 4: Your code here.
	for(int i = 0; i < NENV; i++) {
		id = (id+1) % NENV;
		if(envs[id].env_status == ENV_RUNNABLE) {
f0104ffc:	8b 35 48 d2 2b f0    	mov    0xf02bd248,%esi
f0105002:	b8 00 04 00 00       	mov    $0x400,%eax
	for(id = 0; id < NENV; id++) {
		if(curenv && envs[id].env_id == curenv->env_id) break;
	}
	// LAB 4: Your code here.
	for(int i = 0; i < NENV; i++) {
		id = (id+1) % NENV;
f0105007:	8d 53 01             	lea    0x1(%ebx),%edx
f010500a:	89 d1                	mov    %edx,%ecx
f010500c:	c1 f9 1f             	sar    $0x1f,%ecx
f010500f:	c1 e9 16             	shr    $0x16,%ecx
f0105012:	01 ca                	add    %ecx,%edx
f0105014:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010501a:	29 ca                	sub    %ecx,%edx
f010501c:	89 d3                	mov    %edx,%ebx
		if(envs[id].env_status == ENV_RUNNABLE) {
f010501e:	6b d2 7c             	imul   $0x7c,%edx,%edx
f0105021:	01 f2                	add    %esi,%edx
f0105023:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0105027:	75 08                	jne    f0105031 <sched_yield+0x83>
			//cprintf("Running new env %d\n", envs[i].env_id);
			env_run(&envs[id]);
f0105029:	89 14 24             	mov    %edx,(%esp)
f010502c:	e8 00 f0 ff ff       	call   f0104031 <env_run>
	int id = 0 ;
	for(id = 0; id < NENV; id++) {
		if(curenv && envs[id].env_id == curenv->env_id) break;
	}
	// LAB 4: Your code here.
	for(int i = 0; i < NENV; i++) {
f0105031:	83 e8 01             	sub    $0x1,%eax
f0105034:	75 d1                	jne    f0105007 <sched_yield+0x59>
			//cprintf("Running new env %d\n", envs[i].env_id);
			env_run(&envs[id]);
		}
	}

	if(curenv && curenv->env_status == ENV_RUNNING) {
f0105036:	e8 5e 19 00 00       	call   f0106999 <cpunum>
f010503b:	6b c0 74             	imul   $0x74,%eax,%eax
f010503e:	83 b8 28 f0 2b f0 00 	cmpl   $0x0,-0xfd40fd8(%eax)
f0105045:	74 2a                	je     f0105071 <sched_yield+0xc3>
f0105047:	e8 4d 19 00 00       	call   f0106999 <cpunum>
f010504c:	6b c0 74             	imul   $0x74,%eax,%eax
f010504f:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105055:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105059:	75 16                	jne    f0105071 <sched_yield+0xc3>
		env_run(curenv);
f010505b:	e8 39 19 00 00       	call   f0106999 <cpunum>
f0105060:	6b c0 74             	imul   $0x74,%eax,%eax
f0105063:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105069:	89 04 24             	mov    %eax,(%esp)
f010506c:	e8 c0 ef ff ff       	call   f0104031 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0105071:	e8 62 fe ff ff       	call   f0104ed8 <sched_halt>
}
f0105076:	83 c4 1c             	add    $0x1c,%esp
f0105079:	5b                   	pop    %ebx
f010507a:	5e                   	pop    %esi
f010507b:	5f                   	pop    %edi
f010507c:	5d                   	pop    %ebp
f010507d:	c3                   	ret    
f010507e:	66 90                	xchg   %ax,%ax

f0105080 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105080:	55                   	push   %ebp
f0105081:	89 e5                	mov    %esp,%ebp
f0105083:	57                   	push   %edi
f0105084:	56                   	push   %esi
f0105085:	53                   	push   %ebx
f0105086:	83 ec 2c             	sub    $0x2c,%esp
f0105089:	8b 45 08             	mov    0x8(%ebp),%eax
f010508c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f010508f:	83 f8 10             	cmp    $0x10,%eax
f0105092:	0f 87 17 07 00 00    	ja     f01057af <syscall+0x72f>
f0105098:	ff 24 85 68 99 10 f0 	jmp    *-0xfef6698(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f010509f:	e8 f5 18 00 00       	call   f0106999 <cpunum>
f01050a4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01050ab:	00 
f01050ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01050b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01050b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ba:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01050c0:	89 04 24             	mov    %eax,(%esp)
f01050c3:	e8 3e e8 ff ff       	call   f0103906 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01050c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050d3:	c7 04 24 86 95 10 f0 	movl   $0xf0109586,(%esp)
f01050da:	e8 aa f1 ff ff       	call   f0104289 <cprintf>
	// LAB 3: Your code here.

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f01050df:	b8 00 00 00 00       	mov    $0x0,%eax
f01050e4:	e9 cb 06 00 00       	jmp    f01057b4 <syscall+0x734>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01050e9:	e8 87 b5 ff ff       	call   f0100675 <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01050ee:	66 90                	xchg   %ax,%ax
f01050f0:	e9 bf 06 00 00       	jmp    f01057b4 <syscall+0x734>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01050f5:	e8 9f 18 00 00       	call   f0106999 <cpunum>
f01050fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01050fd:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105103:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0105106:	e9 a9 06 00 00       	jmp    f01057b4 <syscall+0x734>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010510b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105112:	00 
f0105113:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105116:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010511d:	89 04 24             	mov    %eax,(%esp)
f0105120:	e8 d4 e8 ff ff       	call   f01039f9 <envid2env>
		return r;
f0105125:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105127:	85 c0                	test   %eax,%eax
f0105129:	78 10                	js     f010513b <syscall+0xbb>
		return r;
	env_destroy(e);
f010512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010512e:	89 04 24             	mov    %eax,(%esp)
f0105131:	e8 5a ee ff ff       	call   f0103f90 <env_destroy>
	return 0;
f0105136:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
f010513b:	89 d0                	mov    %edx,%eax
f010513d:	e9 72 06 00 00       	jmp    f01057b4 <syscall+0x734>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105142:	e8 67 fe ff ff       	call   f0104fae <sched_yield>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *newenv;
	int ret = env_alloc(&newenv, curenv->env_id);
f0105147:	e8 4d 18 00 00       	call   f0106999 <cpunum>
f010514c:	6b c0 74             	imul   $0x74,%eax,%eax
f010514f:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105155:	8b 40 48             	mov    0x48(%eax),%eax
f0105158:	89 44 24 04          	mov    %eax,0x4(%esp)
f010515c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010515f:	89 04 24             	mov    %eax,(%esp)
f0105162:	e8 a3 e9 ff ff       	call   f0103b0a <env_alloc>
f0105167:	89 c3                	mov    %eax,%ebx

	if(ret < 0) {
f0105169:	85 c0                	test   %eax,%eax
f010516b:	79 17                	jns    f0105184 <syscall+0x104>
		// TODO: print more error codes in other places to avoid debugging nightmares
		cprintf("%e\n", ret);
f010516d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105171:	c7 04 24 cb 9c 10 f0 	movl   $0xf0109ccb,(%esp)
f0105178:	e8 0c f1 ff ff       	call   f0104289 <cprintf>
		return ret;
f010517d:	89 d8                	mov    %ebx,%eax
f010517f:	e9 30 06 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	newenv->env_status = ENV_NOT_RUNNABLE;
f0105184:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105187:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	newenv->env_tf = curenv->env_tf;
f010518e:	e8 06 18 00 00       	call   f0106999 <cpunum>
f0105193:	6b c0 74             	imul   $0x74,%eax,%eax
f0105196:	8b b0 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%esi
f010519c:	b9 11 00 00 00       	mov    $0x11,%ecx
f01051a1:	89 df                	mov    %ebx,%edi
f01051a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_regs.reg_eax = 0;
f01051a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051a8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f01051af:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
		case SYS_yield:
			sys_yield();
		case SYS_exofork:
			return sys_exofork();
f01051b2:	e9 fd 05 00 00       	jmp    f01057b4 <syscall+0x734>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f01051b7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051be:	00 
f01051bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051c9:	89 04 24             	mov    %eax,(%esp)
f01051cc:	e8 28 e8 ff ff       	call   f01039f9 <envid2env>
f01051d1:	85 c0                	test   %eax,%eax
f01051d3:	79 16                	jns    f01051eb <syscall+0x16b>
		cprintf("Bad env passed to envid2env from env_set_status\n");
f01051d5:	c7 04 24 a8 95 10 f0 	movl   $0xf01095a8,(%esp)
f01051dc:	e8 a8 f0 ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f01051e1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01051e6:	e9 c9 05 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if( (status!=ENV_RUNNABLE) && (status!=ENV_NOT_RUNNABLE) ) {
f01051eb:	83 fb 04             	cmp    $0x4,%ebx
f01051ee:	74 1b                	je     f010520b <syscall+0x18b>
f01051f0:	83 fb 02             	cmp    $0x2,%ebx
f01051f3:	74 16                	je     f010520b <syscall+0x18b>
		cprintf("Invalid status to env_set_status");
f01051f5:	c7 04 24 dc 95 10 f0 	movl   $0xf01095dc,(%esp)
f01051fc:	e8 88 f0 ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f0105201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105206:	e9 a9 05 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	target_env->env_status = status;
f010520b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010520e:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f0105211:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_yield:
			sys_yield();
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0105216:	e9 99 05 00 00       	jmp    f01057b4 <syscall+0x734>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	if( ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & ~(PTE_AVAIL|PTE_W|PTE_U|PTE_P))) {
f010521b:	8b 45 14             	mov    0x14(%ebp),%eax
f010521e:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105223:	83 f8 05             	cmp    $0x5,%eax
f0105226:	74 16                	je     f010523e <syscall+0x1be>
		cprintf("Invalid perms passed to sys_page_alloc\n");
f0105228:	c7 04 24 00 96 10 f0 	movl   $0xf0109600,(%esp)
f010522f:	e8 55 f0 ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f0105234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105239:	e9 76 05 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if( ((uintptr_t)va >= UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)) {
f010523e:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105244:	77 0b                	ja     f0105251 <syscall+0x1d1>
f0105246:	89 d8                	mov    %ebx,%eax
f0105248:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010524d:	39 c3                	cmp    %eax,%ebx
f010524f:	74 16                	je     f0105267 <syscall+0x1e7>
		cprintf("Invalid va passed to sys_page_alloc\n");
f0105251:	c7 04 24 28 96 10 f0 	movl   $0xf0109628,(%esp)
f0105258:	e8 2c f0 ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f010525d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105262:	e9 4d 05 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f0105267:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010526e:	00 
f010526f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105272:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105276:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105279:	89 04 24             	mov    %eax,(%esp)
f010527c:	e8 78 e7 ff ff       	call   f01039f9 <envid2env>
f0105281:	85 c0                	test   %eax,%eax
f0105283:	79 16                	jns    f010529b <syscall+0x21b>
		cprintf("Bad env passed to envid2env from sys_page_alloc\n");
f0105285:	c7 04 24 50 96 10 f0 	movl   $0xf0109650,(%esp)
f010528c:	e8 f8 ef ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f0105291:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105296:	e9 19 05 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f010529b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01052a2:	e8 22 c2 ff ff       	call   f01014c9 <page_alloc>

	if(!pp || (page_insert(target_env->env_pgdir, pp, va, perm)<0) ) {
f01052a7:	85 c0                	test   %eax,%eax
f01052a9:	74 21                	je     f01052cc <syscall+0x24c>
f01052ab:	8b 7d 14             	mov    0x14(%ebp),%edi
f01052ae:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01052b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01052b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052bd:	8b 40 60             	mov    0x60(%eax),%eax
f01052c0:	89 04 24             	mov    %eax,(%esp)
f01052c3:	e8 02 c5 ff ff       	call   f01017ca <page_insert>
f01052c8:	85 c0                	test   %eax,%eax
f01052ca:	79 16                	jns    f01052e2 <syscall+0x262>
		cprintf("No memory in sys_page_alloc\n");
f01052cc:	c7 04 24 8b 95 10 f0 	movl   $0xf010958b,(%esp)
f01052d3:	e8 b1 ef ff ff       	call   f0104289 <cprintf>
		return -E_NO_MEM;
f01052d8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01052dd:	e9 d2 04 00 00       	jmp    f01057b4 <syscall+0x734>
	}
	return 0;
f01052e2:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
f01052e7:	e9 c8 04 00 00       	jmp    f01057b4 <syscall+0x734>
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	if( ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & ~(PTE_AVAIL|PTE_W|PTE_U|PTE_P))) {
f01052ec:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01052ef:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01052f4:	83 f8 05             	cmp    $0x5,%eax
f01052f7:	74 16                	je     f010530f <syscall+0x28f>
		cprintf("Invalid perms passed to sys_page_med\n");
f01052f9:	c7 04 24 84 96 10 f0 	movl   $0xf0109684,(%esp)
f0105300:	e8 84 ef ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f0105305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010530a:	e9 a5 04 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if( ((uintptr_t)srcva >= UTOP) || (ROUNDDOWN((uintptr_t)srcva, PGSIZE) != (uintptr_t)srcva)) {
f010530f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105315:	77 0b                	ja     f0105322 <syscall+0x2a2>
f0105317:	89 d8                	mov    %ebx,%eax
f0105319:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010531e:	39 c3                	cmp    %eax,%ebx
f0105320:	74 16                	je     f0105338 <syscall+0x2b8>
		cprintf("Invalid srcva passed to sys_page_map\n");
f0105322:	c7 04 24 ac 96 10 f0 	movl   $0xf01096ac,(%esp)
f0105329:	e8 5b ef ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f010532e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105333:	e9 7c 04 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if( ((uintptr_t)dstva >= UTOP) || (ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)) {
f0105338:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010533f:	77 0d                	ja     f010534e <syscall+0x2ce>
f0105341:	8b 45 18             	mov    0x18(%ebp),%eax
f0105344:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105349:	39 45 18             	cmp    %eax,0x18(%ebp)
f010534c:	74 16                	je     f0105364 <syscall+0x2e4>
		cprintf("Invalid dstva passed to sys_page_map\n");
f010534e:	c7 04 24 d4 96 10 f0 	movl   $0xf01096d4,(%esp)
f0105355:	e8 2f ef ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f010535a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010535f:	e9 50 04 00 00       	jmp    f01057b4 <syscall+0x734>
	}
	
	struct Env *srcenv, *dstenv;
	pte_t *src_pte;

	if((envid2env(srcenvid, &srcenv, 1) < 0) || (envid2env(dstenvid, &dstenv, 1) < 0) ) {
f0105364:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010536b:	00 
f010536c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010536f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105373:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105376:	89 04 24             	mov    %eax,(%esp)
f0105379:	e8 7b e6 ff ff       	call   f01039f9 <envid2env>
f010537e:	85 c0                	test   %eax,%eax
f0105380:	78 1e                	js     f01053a0 <syscall+0x320>
f0105382:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105389:	00 
f010538a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010538d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105391:	8b 45 14             	mov    0x14(%ebp),%eax
f0105394:	89 04 24             	mov    %eax,(%esp)
f0105397:	e8 5d e6 ff ff       	call   f01039f9 <envid2env>
f010539c:	85 c0                	test   %eax,%eax
f010539e:	79 16                	jns    f01053b6 <syscall+0x336>
		cprintf("Bad env passed to envid2env from sys_page_map\n");
f01053a0:	c7 04 24 fc 96 10 f0 	movl   $0xf01096fc,(%esp)
f01053a7:	e8 dd ee ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f01053ac:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01053b1:	e9 fe 03 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	struct PageInfo* pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f01053b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053c4:	8b 40 60             	mov    0x60(%eax),%eax
f01053c7:	89 04 24             	mov    %eax,(%esp)
f01053ca:	e8 04 c3 ff ff       	call   f01016d3 <page_lookup>
	
	if(!pp) {
f01053cf:	85 c0                	test   %eax,%eax
f01053d1:	75 16                	jne    f01053e9 <syscall+0x369>
		cprintf("srcva not mapped in sys_page_map\n");
f01053d3:	c7 04 24 2c 97 10 f0 	movl   $0xf010972c,(%esp)
f01053da:	e8 aa ee ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f01053df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053e4:	e9 cb 03 00 00       	jmp    f01057b4 <syscall+0x734>
	if( (!(*src_pte & PTE_W)) & (perm & PTE_W)) {
		cprintf("cannot set a read-only page to writable in sys_page_map\n");
		return -E_INVAL;
	}

	if(page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0) {
f01053e9:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01053ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01053f0:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01053f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053fe:	8b 40 60             	mov    0x60(%eax),%eax
f0105401:	89 04 24             	mov    %eax,(%esp)
f0105404:	e8 c1 c3 ff ff       	call   f01017ca <page_insert>
f0105409:	85 c0                	test   %eax,%eax
f010540b:	79 16                	jns    f0105423 <syscall+0x3a3>
		cprintf("page_insert out of memory in sys_page_map\n");
f010540d:	c7 04 24 50 97 10 f0 	movl   $0xf0109750,(%esp)
f0105414:	e8 70 ee ff ff       	call   f0104289 <cprintf>
		return -E_NO_MEM;
f0105419:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010541e:	e9 91 03 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	return 0;
f0105423:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
f0105428:	e9 87 03 00 00       	jmp    f01057b4 <syscall+0x734>
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f010542d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105434:	00 
f0105435:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105438:	89 44 24 04          	mov    %eax,0x4(%esp)
f010543c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010543f:	89 04 24             	mov    %eax,(%esp)
f0105442:	e8 b2 e5 ff ff       	call   f01039f9 <envid2env>
f0105447:	85 c0                	test   %eax,%eax
f0105449:	79 16                	jns    f0105461 <syscall+0x3e1>
		cprintf("Bad env passed to envid2env from sys_page_unmap\n");
f010544b:	c7 04 24 7c 97 10 f0 	movl   $0xf010977c,(%esp)
f0105452:	e8 32 ee ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f0105457:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010545c:	e9 53 03 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if( ((uintptr_t)va >= UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)) {
f0105461:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105467:	77 0b                	ja     f0105474 <syscall+0x3f4>
f0105469:	89 d8                	mov    %ebx,%eax
f010546b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105470:	39 c3                	cmp    %eax,%ebx
f0105472:	74 16                	je     f010548a <syscall+0x40a>
		cprintf("Invalid va passed to sys_page_unmap\n");
f0105474:	c7 04 24 b0 97 10 f0 	movl   $0xf01097b0,(%esp)
f010547b:	e8 09 ee ff ff       	call   f0104289 <cprintf>
		return -E_INVAL;
f0105480:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105485:	e9 2a 03 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	page_remove(target_env->env_pgdir, va);
f010548a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010548e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105491:	8b 40 60             	mov    0x60(%eax),%eax
f0105494:	89 04 24             	mov    %eax,(%esp)
f0105497:	e8 e5 c2 ff ff       	call   f0101781 <page_remove>
	return 0;
f010549c:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *) a2);
f01054a1:	e9 0e 03 00 00       	jmp    f01057b4 <syscall+0x734>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f01054a6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054ad:	00 
f01054ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054b8:	89 04 24             	mov    %eax,(%esp)
f01054bb:	e8 39 e5 ff ff       	call   f01039f9 <envid2env>
f01054c0:	85 c0                	test   %eax,%eax
f01054c2:	79 1d                	jns    f01054e1 <syscall+0x461>
		cprintf("Bad envid %d passed to envid2env from env_set_pgfault_upcall\n", envid);
f01054c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054cb:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01054d2:	e8 b2 ed ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f01054d7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01054dc:	e9 d3 02 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	target_env->env_pgfault_upcall = func;
f01054e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054e4:	89 58 64             	mov    %ebx,0x64(%eax)

	return 0;
f01054e7:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *) a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);
f01054ec:	e9 c3 02 00 00       	jmp    f01057b4 <syscall+0x734>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	struct Env *target_env;

	if(envid2env(envid, &target_env, 0) < 0) {
f01054f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01054f8:	00 
f01054f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01054fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105500:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105503:	89 04 24             	mov    %eax,(%esp)
f0105506:	e8 ee e4 ff ff       	call   f01039f9 <envid2env>
f010550b:	85 c0                	test   %eax,%eax
f010550d:	79 16                	jns    f0105525 <syscall+0x4a5>
		cprintf("Bad env passed to envid2env from sys_ipc_try_send\n");
f010550f:	c7 04 24 18 98 10 f0 	movl   $0xf0109818,(%esp)
f0105516:	e8 6e ed ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f010551b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105520:	e9 8f 02 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	if(!target_env->env_ipc_recving) {
f0105525:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105528:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010552c:	0f 84 1f 01 00 00    	je     f0105651 <syscall+0x5d1>
		return -E_IPC_NOT_RECV;
	}

	target_env->env_ipc_perm = 0;
f0105532:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

	if((uintptr_t)srcva < UTOP) {
f0105539:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105540:	0f 87 d2 00 00 00    	ja     f0105618 <syscall+0x598>

		pte_t * src_pte;
		uintptr_t dstva = (uintptr_t) target_env->env_ipc_dstva;
f0105546:	8b 70 6c             	mov    0x6c(%eax),%esi

		if( ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & ~(PTE_AVAIL|PTE_W|PTE_U|PTE_P))) {
f0105549:	8b 45 18             	mov    0x18(%ebp),%eax
f010554c:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105551:	83 f8 05             	cmp    $0x5,%eax
f0105554:	74 16                	je     f010556c <syscall+0x4ec>
			cprintf("Invalid perms passed to sys_ipc_try_send\n");
f0105556:	c7 04 24 4c 98 10 f0 	movl   $0xf010984c,(%esp)
f010555d:	e8 27 ed ff ff       	call   f0104289 <cprintf>
			return -E_INVAL;
f0105562:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105567:	e9 48 02 00 00       	jmp    f01057b4 <syscall+0x734>
		}

		if( (ROUNDDOWN((uintptr_t)srcva, PGSIZE) != (uintptr_t)srcva)) {
f010556c:	8b 45 14             	mov    0x14(%ebp),%eax
f010556f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105574:	39 45 14             	cmp    %eax,0x14(%ebp)
f0105577:	74 16                	je     f010558f <syscall+0x50f>
			cprintf("Non page aligned va passed to sys_ipc_try_send\n");
f0105579:	c7 04 24 78 98 10 f0 	movl   $0xf0109878,(%esp)
f0105580:	e8 04 ed ff ff       	call   f0104289 <cprintf>
			return -E_INVAL;
f0105585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010558a:	e9 25 02 00 00       	jmp    f01057b4 <syscall+0x734>
		}

		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &src_pte);
f010558f:	e8 05 14 00 00       	call   f0106999 <cpunum>
f0105594:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105597:	89 54 24 08          	mov    %edx,0x8(%esp)
f010559b:	8b 55 14             	mov    0x14(%ebp),%edx
f010559e:	89 54 24 04          	mov    %edx,0x4(%esp)
f01055a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01055a5:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01055ab:	8b 40 60             	mov    0x60(%eax),%eax
f01055ae:	89 04 24             	mov    %eax,(%esp)
f01055b1:	e8 1d c1 ff ff       	call   f01016d3 <page_lookup>
	
		if(!pp) {
f01055b6:	85 c0                	test   %eax,%eax
f01055b8:	75 16                	jne    f01055d0 <syscall+0x550>
			cprintf("srcva not mapped in sys_ipc_try_send\n");
f01055ba:	c7 04 24 a8 98 10 f0 	movl   $0xf01098a8,(%esp)
f01055c1:	e8 c3 ec ff ff       	call   f0104289 <cprintf>
			return -E_INVAL;
f01055c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055cb:	e9 e4 01 00 00       	jmp    f01057b4 <syscall+0x734>
		if( (!(*src_pte & PTE_W)) & (perm & PTE_W)) {
			cprintf("cannot set a read-only page to writable in sys_ipc_try_send\n");
			return -E_INVAL;
		}

		if(dstva < UTOP)  {
f01055d0:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01055d6:	77 40                	ja     f0105618 <syscall+0x598>
			if(page_insert(target_env->env_pgdir, pp, (void *)dstva, perm) < 0) {
f01055d8:	8b 55 18             	mov    0x18(%ebp),%edx
f01055db:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01055df:	89 74 24 08          	mov    %esi,0x8(%esp)
f01055e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055ea:	8b 40 60             	mov    0x60(%eax),%eax
f01055ed:	89 04 24             	mov    %eax,(%esp)
f01055f0:	e8 d5 c1 ff ff       	call   f01017ca <page_insert>
f01055f5:	85 c0                	test   %eax,%eax
f01055f7:	79 16                	jns    f010560f <syscall+0x58f>
				cprintf("page_insert out of memory in sys_ipc_try_send\n");
f01055f9:	c7 04 24 d0 98 10 f0 	movl   $0xf01098d0,(%esp)
f0105600:	e8 84 ec ff ff       	call   f0104289 <cprintf>
				return -E_NO_MEM;
f0105605:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010560a:	e9 a5 01 00 00       	jmp    f01057b4 <syscall+0x734>
			}
			target_env->env_ipc_perm = perm;
f010560f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105612:	8b 75 18             	mov    0x18(%ebp),%esi
f0105615:	89 70 78             	mov    %esi,0x78(%eax)
		}
	}

	target_env->env_ipc_recving = false;
f0105618:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010561b:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	target_env->env_ipc_value = value;
f010561f:	89 5e 70             	mov    %ebx,0x70(%esi)
	target_env->env_ipc_from = curenv->env_id;
f0105622:	e8 72 13 00 00       	call   f0106999 <cpunum>
f0105627:	6b c0 74             	imul   $0x74,%eax,%eax
f010562a:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105630:	8b 40 48             	mov    0x48(%eax),%eax
f0105633:	89 46 74             	mov    %eax,0x74(%esi)
	target_env->env_status = ENV_RUNNABLE;
f0105636:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105639:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	target_env->env_tf.tf_regs.reg_eax = 0;
f0105640:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f0105647:	b8 00 00 00 00       	mov    $0x0,%eax
f010564c:	e9 63 01 00 00       	jmp    f01057b4 <syscall+0x734>
		cprintf("Bad env passed to envid2env from sys_ipc_try_send\n");
		return -E_BAD_ENV;
	}

	if(!target_env->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0105651:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *) a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
f0105656:	e9 59 01 00 00       	jmp    f01057b4 <syscall+0x734>
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	curenv->env_ipc_recving = true;
f010565b:	e8 39 13 00 00       	call   f0106999 <cpunum>
f0105660:	6b c0 74             	imul   $0x74,%eax,%eax
f0105663:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105669:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	if((uintptr_t)dstva < UTOP && (ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)) {
f010566d:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105674:	77 23                	ja     f0105699 <syscall+0x619>
f0105676:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105679:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010567e:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0105681:	74 16                	je     f0105699 <syscall+0x619>
		cprintf("Non page aligned va passed to sys_ipc_recv\n");
f0105683:	c7 04 24 00 99 10 f0 	movl   $0xf0109900,(%esp)
f010568a:	e8 fa eb ff ff       	call   f0104289 <cprintf>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *) a1);
f010568f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105694:	e9 1b 01 00 00       	jmp    f01057b4 <syscall+0x734>
	curenv->env_ipc_recving = true;
	if((uintptr_t)dstva < UTOP && (ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)) {
		cprintf("Non page aligned va passed to sys_ipc_recv\n");
		return -E_INVAL;
	}
	curenv->env_ipc_dstva = dstva;
f0105699:	e8 fb 12 00 00       	call   f0106999 <cpunum>
f010569e:	6b c0 74             	imul   $0x74,%eax,%eax
f01056a1:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01056a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056aa:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01056ad:	e8 e7 12 00 00       	call   f0106999 <cpunum>
f01056b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01056b5:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f01056bb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f01056c2:	e8 e7 f8 ff ff       	call   f0104fae <sched_yield>
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *) a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
f01056c7:	89 de                	mov    %ebx,%esi
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f01056c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01056d0:	00 
f01056d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056db:	89 04 24             	mov    %eax,(%esp)
f01056de:	e8 16 e3 ff ff       	call   f01039f9 <envid2env>
f01056e3:	85 c0                	test   %eax,%eax
f01056e5:	79 1d                	jns    f0105704 <syscall+0x684>
		cprintf("Bad envid %d passed to envid2env from env_set_trapframe\n", envid);
f01056e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056ee:	c7 04 24 2c 99 10 f0 	movl   $0xf010992c,(%esp)
f01056f5:	e8 8f eb ff ff       	call   f0104289 <cprintf>
		return -E_BAD_ENV;
f01056fa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01056ff:	e9 b0 00 00 00       	jmp    f01057b4 <syscall+0x734>
	}

	user_mem_assert(target_env, tf, sizeof(struct Trapframe), PTE_W);
f0105704:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010570b:	00 
f010570c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105713:	00 
f0105714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010571b:	89 04 24             	mov    %eax,(%esp)
f010571e:	e8 e3 e1 ff ff       	call   f0103906 <user_mem_assert>

	target_env->env_tf = *tf;
f0105723:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010572b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	target_env->env_tf.tf_eflags |= FL_IF;
f010572d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105730:	8b 50 38             	mov    0x38(%eax),%edx
f0105733:	89 d1                	mov    %edx,%ecx
f0105735:	80 cd 02             	or     $0x2,%ch
f0105738:	89 48 38             	mov    %ecx,0x38(%eax)
	target_env->env_tf.tf_cs |= 0x3;
f010573b:	66 83 48 34 03       	orw    $0x3,0x34(%eax)
	if(target_env->env_type !=  ENV_TYPE_FS) {
f0105740:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105744:	74 10                	je     f0105756 <syscall+0x6d6>
		target_env->env_tf.tf_eflags &= ~FL_IOPL_3;
f0105746:	80 e6 cf             	and    $0xcf,%dh
f0105749:	80 ce 02             	or     $0x2,%dh
f010574c:	89 50 38             	mov    %edx,0x38(%eax)
	}

	return 0;
f010574f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105754:	eb 5e                	jmp    f01057b4 <syscall+0x734>
f0105756:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *) a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
f010575b:	eb 57                	jmp    f01057b4 <syscall+0x734>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	return time_msec();
f010575d:	e8 98 21 00 00       	call   f01078fa <time_msec>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *) a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
		case SYS_time_msec:
			return sys_time_msec();
f0105762:	eb 50                	jmp    f01057b4 <syscall+0x734>
struct packet_buf packet;

static int
sys_try_send_packet(void * packetva, int size)
{
	user_mem_assert(curenv, packetva, size, PTE_U);
f0105764:	e8 30 12 00 00       	call   f0106999 <cpunum>
f0105769:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105770:	00 
f0105771:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105775:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105778:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010577c:	6b c0 74             	imul   $0x74,%eax,%eax
f010577f:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0105785:	89 04 24             	mov    %eax,(%esp)
f0105788:	e8 79 e1 ff ff       	call   f0103906 <user_mem_assert>
	return e1000_transmit(packetva, size);
f010578d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105791:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105794:	89 04 24             	mov    %eax,(%esp)
f0105797:	e8 24 19 00 00       	call   f01070c0 <e1000_transmit>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
		case SYS_time_msec:
			return sys_time_msec();
		case SYS_try_send_packet:
			return sys_try_send_packet((void*)a1, (int)a2);
f010579c:	eb 16                	jmp    f01057b4 <syscall+0x734>
}

static int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return e1000_receive(packet_dst, size_store);
f010579e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057a5:	89 04 24             	mov    %eax,(%esp)
f01057a8:	e8 da 19 00 00       	call   f0107187 <e1000_receive>
		case SYS_time_msec:
			return sys_time_msec();
		case SYS_try_send_packet:
			return sys_try_send_packet((void*)a1, (int)a2);
		case SYS_try_recv_packet:
			return sys_try_recv_packet((void**)a1, (int*)a2);
f01057ad:	eb 05                	jmp    f01057b4 <syscall+0x734>
	default:
		return -E_INVAL;
f01057af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01057b4:	83 c4 2c             	add    $0x2c,%esp
f01057b7:	5b                   	pop    %ebx
f01057b8:	5e                   	pop    %esi
f01057b9:	5f                   	pop    %edi
f01057ba:	5d                   	pop    %ebp
f01057bb:	c3                   	ret    

f01057bc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01057bc:	55                   	push   %ebp
f01057bd:	89 e5                	mov    %esp,%ebp
f01057bf:	57                   	push   %edi
f01057c0:	56                   	push   %esi
f01057c1:	53                   	push   %ebx
f01057c2:	83 ec 14             	sub    $0x14,%esp
f01057c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01057c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01057cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01057ce:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01057d1:	8b 1a                	mov    (%edx),%ebx
f01057d3:	8b 01                	mov    (%ecx),%eax
f01057d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01057d8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01057df:	e9 88 00 00 00       	jmp    f010586c <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01057e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01057e7:	01 d8                	add    %ebx,%eax
f01057e9:	89 c7                	mov    %eax,%edi
f01057eb:	c1 ef 1f             	shr    $0x1f,%edi
f01057ee:	01 c7                	add    %eax,%edi
f01057f0:	d1 ff                	sar    %edi
f01057f2:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01057f5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01057f8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01057fb:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01057fd:	eb 03                	jmp    f0105802 <stab_binsearch+0x46>
			m--;
f01057ff:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105802:	39 c3                	cmp    %eax,%ebx
f0105804:	7f 1f                	jg     f0105825 <stab_binsearch+0x69>
f0105806:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010580a:	83 ea 0c             	sub    $0xc,%edx
f010580d:	39 f1                	cmp    %esi,%ecx
f010580f:	75 ee                	jne    f01057ff <stab_binsearch+0x43>
f0105811:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105814:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105817:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010581a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010581e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105821:	76 18                	jbe    f010583b <stab_binsearch+0x7f>
f0105823:	eb 05                	jmp    f010582a <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105825:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105828:	eb 42                	jmp    f010586c <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010582a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010582d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010582f:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105832:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105839:	eb 31                	jmp    f010586c <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010583b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010583e:	73 17                	jae    f0105857 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105840:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105843:	83 e8 01             	sub    $0x1,%eax
f0105846:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105849:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010584c:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010584e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105855:	eb 15                	jmp    f010586c <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010585a:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010585d:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010585f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105863:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105865:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010586c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010586f:	0f 8e 6f ff ff ff    	jle    f01057e4 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105875:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105879:	75 0f                	jne    f010588a <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010587b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010587e:	8b 00                	mov    (%eax),%eax
f0105880:	83 e8 01             	sub    $0x1,%eax
f0105883:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105886:	89 07                	mov    %eax,(%edi)
f0105888:	eb 2c                	jmp    f01058b6 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010588a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010588d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010588f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105892:	8b 0f                	mov    (%edi),%ecx
f0105894:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105897:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010589a:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010589d:	eb 03                	jmp    f01058a2 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010589f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01058a2:	39 c8                	cmp    %ecx,%eax
f01058a4:	7e 0b                	jle    f01058b1 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01058a6:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01058aa:	83 ea 0c             	sub    $0xc,%edx
f01058ad:	39 f3                	cmp    %esi,%ebx
f01058af:	75 ee                	jne    f010589f <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01058b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058b4:	89 07                	mov    %eax,(%edi)
	}
}
f01058b6:	83 c4 14             	add    $0x14,%esp
f01058b9:	5b                   	pop    %ebx
f01058ba:	5e                   	pop    %esi
f01058bb:	5f                   	pop    %edi
f01058bc:	5d                   	pop    %ebp
f01058bd:	c3                   	ret    

f01058be <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01058be:	55                   	push   %ebp
f01058bf:	89 e5                	mov    %esp,%ebp
f01058c1:	57                   	push   %edi
f01058c2:	56                   	push   %esi
f01058c3:	53                   	push   %ebx
f01058c4:	83 ec 4c             	sub    $0x4c,%esp
f01058c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01058ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01058cd:	c7 03 ac 99 10 f0    	movl   $0xf01099ac,(%ebx)
	info->eip_line = 0;
f01058d3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01058da:	c7 43 08 ac 99 10 f0 	movl   $0xf01099ac,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01058e1:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01058e8:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01058eb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01058f2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01058f8:	77 21                	ja     f010591b <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01058fa:	a1 00 00 20 00       	mov    0x200000,%eax
f01058ff:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105902:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0105907:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010590d:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105910:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0105916:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0105919:	eb 1a                	jmp    f0105935 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010591b:	c7 45 bc 5c a8 11 f0 	movl   $0xf011a85c,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105922:	c7 45 c0 71 63 11 f0 	movl   $0xf0116371,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105929:	b8 70 63 11 f0       	mov    $0xf0116370,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010592e:	c7 45 c4 cc a1 10 f0 	movl   $0xf010a1cc,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105935:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105938:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f010593b:	0f 83 9d 01 00 00    	jae    f0105ade <debuginfo_eip+0x220>
f0105941:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105945:	0f 85 9a 01 00 00    	jne    f0105ae5 <debuginfo_eip+0x227>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010594b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105952:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105955:	29 f8                	sub    %edi,%eax
f0105957:	c1 f8 02             	sar    $0x2,%eax
f010595a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105960:	83 e8 01             	sub    $0x1,%eax
f0105963:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105966:	89 74 24 04          	mov    %esi,0x4(%esp)
f010596a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105971:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105974:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105977:	89 f8                	mov    %edi,%eax
f0105979:	e8 3e fe ff ff       	call   f01057bc <stab_binsearch>
	if (lfile == 0)
f010597e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105981:	85 c0                	test   %eax,%eax
f0105983:	0f 84 63 01 00 00    	je     f0105aec <debuginfo_eip+0x22e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105989:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010598c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010598f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105992:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105996:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010599d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01059a0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01059a3:	89 f8                	mov    %edi,%eax
f01059a5:	e8 12 fe ff ff       	call   f01057bc <stab_binsearch>

	if (lfun <= rfun) {
f01059aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059ad:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01059b0:	39 c8                	cmp    %ecx,%eax
f01059b2:	7f 32                	jg     f01059e6 <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01059b4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01059b7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059ba:	8d 3c 97             	lea    (%edi,%edx,4),%edi
f01059bd:	8b 17                	mov    (%edi),%edx
f01059bf:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01059c2:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01059c5:	2b 55 c0             	sub    -0x40(%ebp),%edx
f01059c8:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f01059cb:	73 09                	jae    f01059d6 <debuginfo_eip+0x118>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01059cd:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01059d0:	03 55 c0             	add    -0x40(%ebp),%edx
f01059d3:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01059d6:	8b 57 08             	mov    0x8(%edi),%edx
f01059d9:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01059dc:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01059de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01059e1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01059e4:	eb 0f                	jmp    f01059f5 <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01059e6:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01059e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01059ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01059f5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01059fc:	00 
f01059fd:	8b 43 08             	mov    0x8(%ebx),%eax
f0105a00:	89 04 24             	mov    %eax,(%esp)
f0105a03:	e8 23 09 00 00       	call   f010632b <strfind>
f0105a08:	2b 43 08             	sub    0x8(%ebx),%eax
f0105a0b:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105a0e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a12:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105a19:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105a1c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105a1f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105a22:	89 f8                	mov    %edi,%eax
f0105a24:	e8 93 fd ff ff       	call   f01057bc <stab_binsearch>
	if (lline <= rline) {
f0105a29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105a2c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105a2f:	0f 8f be 00 00 00    	jg     f0105af3 <debuginfo_eip+0x235>
		info->eip_line = stabs[lline].n_desc;
f0105a35:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105a38:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0105a3d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a43:	89 c6                	mov    %eax,%esi
f0105a45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105a48:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105a4b:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105a4e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a51:	eb 06                	jmp    f0105a59 <debuginfo_eip+0x19b>
f0105a53:	83 e8 01             	sub    $0x1,%eax
f0105a56:	83 ea 0c             	sub    $0xc,%edx
f0105a59:	89 c7                	mov    %eax,%edi
f0105a5b:	39 c6                	cmp    %eax,%esi
f0105a5d:	7f 3c                	jg     f0105a9b <debuginfo_eip+0x1dd>
	       && stabs[lline].n_type != N_SOL
f0105a5f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105a63:	80 f9 84             	cmp    $0x84,%cl
f0105a66:	75 08                	jne    f0105a70 <debuginfo_eip+0x1b2>
f0105a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a6b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a6e:	eb 11                	jmp    f0105a81 <debuginfo_eip+0x1c3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105a70:	80 f9 64             	cmp    $0x64,%cl
f0105a73:	75 de                	jne    f0105a53 <debuginfo_eip+0x195>
f0105a75:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105a79:	74 d8                	je     f0105a53 <debuginfo_eip+0x195>
f0105a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105a81:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105a84:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105a87:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105a8a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105a8d:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105a90:	39 d0                	cmp    %edx,%eax
f0105a92:	73 0a                	jae    f0105a9e <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105a94:	03 45 c0             	add    -0x40(%ebp),%eax
f0105a97:	89 03                	mov    %eax,(%ebx)
f0105a99:	eb 03                	jmp    f0105a9e <debuginfo_eip+0x1e0>
f0105a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105a9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105aa1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105aa9:	39 f2                	cmp    %esi,%edx
f0105aab:	7d 52                	jge    f0105aff <debuginfo_eip+0x241>
		for (lline = lfun + 1;
f0105aad:	83 c2 01             	add    $0x1,%edx
f0105ab0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105ab3:	89 d0                	mov    %edx,%eax
f0105ab5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105ab8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105abb:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105abe:	eb 04                	jmp    f0105ac4 <debuginfo_eip+0x206>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105ac0:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105ac4:	39 c6                	cmp    %eax,%esi
f0105ac6:	7e 32                	jle    f0105afa <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105ac8:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105acc:	83 c0 01             	add    $0x1,%eax
f0105acf:	83 c2 0c             	add    $0xc,%edx
f0105ad2:	80 f9 a0             	cmp    $0xa0,%cl
f0105ad5:	74 e9                	je     f0105ac0 <debuginfo_eip+0x202>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105ad7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105adc:	eb 21                	jmp    f0105aff <debuginfo_eip+0x241>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105ade:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ae3:	eb 1a                	jmp    f0105aff <debuginfo_eip+0x241>
f0105ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105aea:	eb 13                	jmp    f0105aff <debuginfo_eip+0x241>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105aec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105af1:	eb 0c                	jmp    f0105aff <debuginfo_eip+0x241>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		// Couldn't find line stab!  
		return -1;
f0105af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105af8:	eb 05                	jmp    f0105aff <debuginfo_eip+0x241>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105afa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105aff:	83 c4 4c             	add    $0x4c,%esp
f0105b02:	5b                   	pop    %ebx
f0105b03:	5e                   	pop    %esi
f0105b04:	5f                   	pop    %edi
f0105b05:	5d                   	pop    %ebp
f0105b06:	c3                   	ret    
f0105b07:	66 90                	xchg   %ax,%ax
f0105b09:	66 90                	xchg   %ax,%ax
f0105b0b:	66 90                	xchg   %ax,%ax
f0105b0d:	66 90                	xchg   %ax,%ax
f0105b0f:	90                   	nop

f0105b10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105b10:	55                   	push   %ebp
f0105b11:	89 e5                	mov    %esp,%ebp
f0105b13:	57                   	push   %edi
f0105b14:	56                   	push   %esi
f0105b15:	53                   	push   %ebx
f0105b16:	83 ec 3c             	sub    $0x3c,%esp
f0105b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b1c:	89 d7                	mov    %edx,%edi
f0105b1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b21:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b27:	89 c3                	mov    %eax,%ebx
f0105b29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105b2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b2f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105b32:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105b37:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b3a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b3d:	39 d9                	cmp    %ebx,%ecx
f0105b3f:	72 05                	jb     f0105b46 <printnum+0x36>
f0105b41:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105b44:	77 69                	ja     f0105baf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105b46:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105b49:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105b4d:	83 ee 01             	sub    $0x1,%esi
f0105b50:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105b54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b58:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105b5c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105b60:	89 c3                	mov    %eax,%ebx
f0105b62:	89 d6                	mov    %edx,%esi
f0105b64:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b67:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105b6a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105b6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b75:	89 04 24             	mov    %eax,(%esp)
f0105b78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b7f:	e8 8c 1d 00 00       	call   f0107910 <__udivdi3>
f0105b84:	89 d9                	mov    %ebx,%ecx
f0105b86:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105b8a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105b8e:	89 04 24             	mov    %eax,(%esp)
f0105b91:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b95:	89 fa                	mov    %edi,%edx
f0105b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b9a:	e8 71 ff ff ff       	call   f0105b10 <printnum>
f0105b9f:	eb 1b                	jmp    f0105bbc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105ba1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ba5:	8b 45 18             	mov    0x18(%ebp),%eax
f0105ba8:	89 04 24             	mov    %eax,(%esp)
f0105bab:	ff d3                	call   *%ebx
f0105bad:	eb 03                	jmp    f0105bb2 <printnum+0xa2>
f0105baf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105bb2:	83 ee 01             	sub    $0x1,%esi
f0105bb5:	85 f6                	test   %esi,%esi
f0105bb7:	7f e8                	jg     f0105ba1 <printnum+0x91>
f0105bb9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105bbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bc0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105bc4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105bc7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105bca:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bce:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bd5:	89 04 24             	mov    %eax,(%esp)
f0105bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bdf:	e8 5c 1e 00 00       	call   f0107a40 <__umoddi3>
f0105be4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105be8:	0f be 80 b6 99 10 f0 	movsbl -0xfef664a(%eax),%eax
f0105bef:	89 04 24             	mov    %eax,(%esp)
f0105bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bf5:	ff d0                	call   *%eax
}
f0105bf7:	83 c4 3c             	add    $0x3c,%esp
f0105bfa:	5b                   	pop    %ebx
f0105bfb:	5e                   	pop    %esi
f0105bfc:	5f                   	pop    %edi
f0105bfd:	5d                   	pop    %ebp
f0105bfe:	c3                   	ret    

f0105bff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105bff:	55                   	push   %ebp
f0105c00:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105c02:	83 fa 01             	cmp    $0x1,%edx
f0105c05:	7e 0e                	jle    f0105c15 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105c07:	8b 10                	mov    (%eax),%edx
f0105c09:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105c0c:	89 08                	mov    %ecx,(%eax)
f0105c0e:	8b 02                	mov    (%edx),%eax
f0105c10:	8b 52 04             	mov    0x4(%edx),%edx
f0105c13:	eb 22                	jmp    f0105c37 <getuint+0x38>
	else if (lflag)
f0105c15:	85 d2                	test   %edx,%edx
f0105c17:	74 10                	je     f0105c29 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105c19:	8b 10                	mov    (%eax),%edx
f0105c1b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c1e:	89 08                	mov    %ecx,(%eax)
f0105c20:	8b 02                	mov    (%edx),%eax
f0105c22:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c27:	eb 0e                	jmp    f0105c37 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105c29:	8b 10                	mov    (%eax),%edx
f0105c2b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c2e:	89 08                	mov    %ecx,(%eax)
f0105c30:	8b 02                	mov    (%edx),%eax
f0105c32:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105c37:	5d                   	pop    %ebp
f0105c38:	c3                   	ret    

f0105c39 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105c39:	55                   	push   %ebp
f0105c3a:	89 e5                	mov    %esp,%ebp
f0105c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105c3f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105c43:	8b 10                	mov    (%eax),%edx
f0105c45:	3b 50 04             	cmp    0x4(%eax),%edx
f0105c48:	73 0a                	jae    f0105c54 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105c4a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105c4d:	89 08                	mov    %ecx,(%eax)
f0105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c52:	88 02                	mov    %al,(%edx)
}
f0105c54:	5d                   	pop    %ebp
f0105c55:	c3                   	ret    

f0105c56 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105c56:	55                   	push   %ebp
f0105c57:	89 e5                	mov    %esp,%ebp
f0105c59:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105c5c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105c5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c63:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c71:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c74:	89 04 24             	mov    %eax,(%esp)
f0105c77:	e8 02 00 00 00       	call   f0105c7e <vprintfmt>
	va_end(ap);
}
f0105c7c:	c9                   	leave  
f0105c7d:	c3                   	ret    

f0105c7e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105c7e:	55                   	push   %ebp
f0105c7f:	89 e5                	mov    %esp,%ebp
f0105c81:	57                   	push   %edi
f0105c82:	56                   	push   %esi
f0105c83:	53                   	push   %ebx
f0105c84:	83 ec 3c             	sub    $0x3c,%esp
f0105c87:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105c8d:	eb 14                	jmp    f0105ca3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105c8f:	85 c0                	test   %eax,%eax
f0105c91:	0f 84 b3 03 00 00    	je     f010604a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0105c97:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c9b:	89 04 24             	mov    %eax,(%esp)
f0105c9e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105ca1:	89 f3                	mov    %esi,%ebx
f0105ca3:	8d 73 01             	lea    0x1(%ebx),%esi
f0105ca6:	0f b6 03             	movzbl (%ebx),%eax
f0105ca9:	83 f8 25             	cmp    $0x25,%eax
f0105cac:	75 e1                	jne    f0105c8f <vprintfmt+0x11>
f0105cae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105cb2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105cb9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105cc0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105cc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ccc:	eb 1d                	jmp    f0105ceb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cce:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105cd0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105cd4:	eb 15                	jmp    f0105ceb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cd6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105cd8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105cdc:	eb 0d                	jmp    f0105ceb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105cde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105ce1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105ce4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ceb:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105cee:	0f b6 0e             	movzbl (%esi),%ecx
f0105cf1:	0f b6 c1             	movzbl %cl,%eax
f0105cf4:	83 e9 23             	sub    $0x23,%ecx
f0105cf7:	80 f9 55             	cmp    $0x55,%cl
f0105cfa:	0f 87 2a 03 00 00    	ja     f010602a <vprintfmt+0x3ac>
f0105d00:	0f b6 c9             	movzbl %cl,%ecx
f0105d03:	ff 24 8d 00 9b 10 f0 	jmp    *-0xfef6500(,%ecx,4)
f0105d0a:	89 de                	mov    %ebx,%esi
f0105d0c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105d11:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105d14:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105d18:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105d1b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105d1e:	83 fb 09             	cmp    $0x9,%ebx
f0105d21:	77 36                	ja     f0105d59 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105d23:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105d26:	eb e9                	jmp    f0105d11 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105d28:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d2b:	8d 48 04             	lea    0x4(%eax),%ecx
f0105d2e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105d31:	8b 00                	mov    (%eax),%eax
f0105d33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d36:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105d38:	eb 22                	jmp    f0105d5c <vprintfmt+0xde>
f0105d3a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105d3d:	85 c9                	test   %ecx,%ecx
f0105d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d44:	0f 49 c1             	cmovns %ecx,%eax
f0105d47:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d4a:	89 de                	mov    %ebx,%esi
f0105d4c:	eb 9d                	jmp    f0105ceb <vprintfmt+0x6d>
f0105d4e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105d50:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105d57:	eb 92                	jmp    f0105ceb <vprintfmt+0x6d>
f0105d59:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0105d5c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d60:	79 89                	jns    f0105ceb <vprintfmt+0x6d>
f0105d62:	e9 77 ff ff ff       	jmp    f0105cde <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105d67:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d6a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105d6c:	e9 7a ff ff ff       	jmp    f0105ceb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105d71:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d74:	8d 50 04             	lea    0x4(%eax),%edx
f0105d77:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d7e:	8b 00                	mov    (%eax),%eax
f0105d80:	89 04 24             	mov    %eax,(%esp)
f0105d83:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105d86:	e9 18 ff ff ff       	jmp    f0105ca3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105d8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d8e:	8d 50 04             	lea    0x4(%eax),%edx
f0105d91:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d94:	8b 00                	mov    (%eax),%eax
f0105d96:	99                   	cltd   
f0105d97:	31 d0                	xor    %edx,%eax
f0105d99:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105d9b:	83 f8 0f             	cmp    $0xf,%eax
f0105d9e:	7f 0b                	jg     f0105dab <vprintfmt+0x12d>
f0105da0:	8b 14 85 60 9c 10 f0 	mov    -0xfef63a0(,%eax,4),%edx
f0105da7:	85 d2                	test   %edx,%edx
f0105da9:	75 20                	jne    f0105dcb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f0105dab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105daf:	c7 44 24 08 ce 99 10 	movl   $0xf01099ce,0x8(%esp)
f0105db6:	f0 
f0105db7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dbe:	89 04 24             	mov    %eax,(%esp)
f0105dc1:	e8 90 fe ff ff       	call   f0105c56 <printfmt>
f0105dc6:	e9 d8 fe ff ff       	jmp    f0105ca3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105dcf:	c7 44 24 08 85 8d 10 	movl   $0xf0108d85,0x8(%esp)
f0105dd6:	f0 
f0105dd7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dde:	89 04 24             	mov    %eax,(%esp)
f0105de1:	e8 70 fe ff ff       	call   f0105c56 <printfmt>
f0105de6:	e9 b8 fe ff ff       	jmp    f0105ca3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105deb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105dee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105df1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105df4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105df7:	8d 50 04             	lea    0x4(%eax),%edx
f0105dfa:	89 55 14             	mov    %edx,0x14(%ebp)
f0105dfd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105dff:	85 f6                	test   %esi,%esi
f0105e01:	b8 c7 99 10 f0       	mov    $0xf01099c7,%eax
f0105e06:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105e09:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105e0d:	0f 84 97 00 00 00    	je     f0105eaa <vprintfmt+0x22c>
f0105e13:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105e17:	0f 8e 9b 00 00 00    	jle    f0105eb8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105e1d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105e21:	89 34 24             	mov    %esi,(%esp)
f0105e24:	e8 af 03 00 00       	call   f01061d8 <strnlen>
f0105e29:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105e2c:	29 c2                	sub    %eax,%edx
f0105e2e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0105e31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105e35:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105e38:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105e3b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105e41:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105e43:	eb 0f                	jmp    f0105e54 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105e45:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e49:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105e4c:	89 04 24             	mov    %eax,(%esp)
f0105e4f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105e51:	83 eb 01             	sub    $0x1,%ebx
f0105e54:	85 db                	test   %ebx,%ebx
f0105e56:	7f ed                	jg     f0105e45 <vprintfmt+0x1c7>
f0105e58:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105e5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105e5e:	85 d2                	test   %edx,%edx
f0105e60:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e65:	0f 49 c2             	cmovns %edx,%eax
f0105e68:	29 c2                	sub    %eax,%edx
f0105e6a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105e6d:	89 d7                	mov    %edx,%edi
f0105e6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105e72:	eb 50                	jmp    f0105ec4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105e74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105e78:	74 1e                	je     f0105e98 <vprintfmt+0x21a>
f0105e7a:	0f be d2             	movsbl %dl,%edx
f0105e7d:	83 ea 20             	sub    $0x20,%edx
f0105e80:	83 fa 5e             	cmp    $0x5e,%edx
f0105e83:	76 13                	jbe    f0105e98 <vprintfmt+0x21a>
					putch('?', putdat);
f0105e85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105e93:	ff 55 08             	call   *0x8(%ebp)
f0105e96:	eb 0d                	jmp    f0105ea5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0105e98:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e9b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e9f:	89 04 24             	mov    %eax,(%esp)
f0105ea2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105ea5:	83 ef 01             	sub    $0x1,%edi
f0105ea8:	eb 1a                	jmp    f0105ec4 <vprintfmt+0x246>
f0105eaa:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105ead:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105eb0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105eb3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105eb6:	eb 0c                	jmp    f0105ec4 <vprintfmt+0x246>
f0105eb8:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105ebb:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105ebe:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105ec1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105ec4:	83 c6 01             	add    $0x1,%esi
f0105ec7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105ecb:	0f be c2             	movsbl %dl,%eax
f0105ece:	85 c0                	test   %eax,%eax
f0105ed0:	74 27                	je     f0105ef9 <vprintfmt+0x27b>
f0105ed2:	85 db                	test   %ebx,%ebx
f0105ed4:	78 9e                	js     f0105e74 <vprintfmt+0x1f6>
f0105ed6:	83 eb 01             	sub    $0x1,%ebx
f0105ed9:	79 99                	jns    f0105e74 <vprintfmt+0x1f6>
f0105edb:	89 f8                	mov    %edi,%eax
f0105edd:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105ee0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ee3:	89 c3                	mov    %eax,%ebx
f0105ee5:	eb 1a                	jmp    f0105f01 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105ee7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105eeb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105ef2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105ef4:	83 eb 01             	sub    $0x1,%ebx
f0105ef7:	eb 08                	jmp    f0105f01 <vprintfmt+0x283>
f0105ef9:	89 fb                	mov    %edi,%ebx
f0105efb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105efe:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105f01:	85 db                	test   %ebx,%ebx
f0105f03:	7f e2                	jg     f0105ee7 <vprintfmt+0x269>
f0105f05:	89 75 08             	mov    %esi,0x8(%ebp)
f0105f08:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105f0b:	e9 93 fd ff ff       	jmp    f0105ca3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105f10:	83 fa 01             	cmp    $0x1,%edx
f0105f13:	7e 16                	jle    f0105f2b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0105f15:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f18:	8d 50 08             	lea    0x8(%eax),%edx
f0105f1b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f1e:	8b 50 04             	mov    0x4(%eax),%edx
f0105f21:	8b 00                	mov    (%eax),%eax
f0105f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105f26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105f29:	eb 32                	jmp    f0105f5d <vprintfmt+0x2df>
	else if (lflag)
f0105f2b:	85 d2                	test   %edx,%edx
f0105f2d:	74 18                	je     f0105f47 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f0105f2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f32:	8d 50 04             	lea    0x4(%eax),%edx
f0105f35:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f38:	8b 30                	mov    (%eax),%esi
f0105f3a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105f3d:	89 f0                	mov    %esi,%eax
f0105f3f:	c1 f8 1f             	sar    $0x1f,%eax
f0105f42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f45:	eb 16                	jmp    f0105f5d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0105f47:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f4a:	8d 50 04             	lea    0x4(%eax),%edx
f0105f4d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f50:	8b 30                	mov    (%eax),%esi
f0105f52:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105f55:	89 f0                	mov    %esi,%eax
f0105f57:	c1 f8 1f             	sar    $0x1f,%eax
f0105f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105f5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105f63:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105f68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105f6c:	0f 89 80 00 00 00    	jns    f0105ff2 <vprintfmt+0x374>
				putch('-', putdat);
f0105f72:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105f7d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105f80:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105f86:	f7 d8                	neg    %eax
f0105f88:	83 d2 00             	adc    $0x0,%edx
f0105f8b:	f7 da                	neg    %edx
			}
			base = 10;
f0105f8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105f92:	eb 5e                	jmp    f0105ff2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105f94:	8d 45 14             	lea    0x14(%ebp),%eax
f0105f97:	e8 63 fc ff ff       	call   f0105bff <getuint>
			base = 10;
f0105f9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105fa1:	eb 4f                	jmp    f0105ff2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105fa3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105fa6:	e8 54 fc ff ff       	call   f0105bff <getuint>
			base = 8;
f0105fab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105fb0:	eb 40                	jmp    f0105ff2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f0105fb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fb6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105fbd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105fc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fc4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105fcb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105fce:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fd1:	8d 50 04             	lea    0x4(%eax),%edx
f0105fd4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105fd7:	8b 00                	mov    (%eax),%eax
f0105fd9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105fde:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105fe3:	eb 0d                	jmp    f0105ff2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105fe5:	8d 45 14             	lea    0x14(%ebp),%eax
f0105fe8:	e8 12 fc ff ff       	call   f0105bff <getuint>
			base = 16;
f0105fed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105ff2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105ff6:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105ffa:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105ffd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106001:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106005:	89 04 24             	mov    %eax,(%esp)
f0106008:	89 54 24 04          	mov    %edx,0x4(%esp)
f010600c:	89 fa                	mov    %edi,%edx
f010600e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106011:	e8 fa fa ff ff       	call   f0105b10 <printnum>
			break;
f0106016:	e9 88 fc ff ff       	jmp    f0105ca3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010601b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010601f:	89 04 24             	mov    %eax,(%esp)
f0106022:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106025:	e9 79 fc ff ff       	jmp    f0105ca3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010602a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010602e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106035:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106038:	89 f3                	mov    %esi,%ebx
f010603a:	eb 03                	jmp    f010603f <vprintfmt+0x3c1>
f010603c:	83 eb 01             	sub    $0x1,%ebx
f010603f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106043:	75 f7                	jne    f010603c <vprintfmt+0x3be>
f0106045:	e9 59 fc ff ff       	jmp    f0105ca3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010604a:	83 c4 3c             	add    $0x3c,%esp
f010604d:	5b                   	pop    %ebx
f010604e:	5e                   	pop    %esi
f010604f:	5f                   	pop    %edi
f0106050:	5d                   	pop    %ebp
f0106051:	c3                   	ret    

f0106052 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106052:	55                   	push   %ebp
f0106053:	89 e5                	mov    %esp,%ebp
f0106055:	83 ec 28             	sub    $0x28,%esp
f0106058:	8b 45 08             	mov    0x8(%ebp),%eax
f010605b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010605e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106061:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0106065:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106068:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010606f:	85 c0                	test   %eax,%eax
f0106071:	74 30                	je     f01060a3 <vsnprintf+0x51>
f0106073:	85 d2                	test   %edx,%edx
f0106075:	7e 2c                	jle    f01060a3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0106077:	8b 45 14             	mov    0x14(%ebp),%eax
f010607a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010607e:	8b 45 10             	mov    0x10(%ebp),%eax
f0106081:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106085:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106088:	89 44 24 04          	mov    %eax,0x4(%esp)
f010608c:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0106093:	e8 e6 fb ff ff       	call   f0105c7e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106098:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010609b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010609e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01060a1:	eb 05                	jmp    f01060a8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01060a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01060a8:	c9                   	leave  
f01060a9:	c3                   	ret    

f01060aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01060aa:	55                   	push   %ebp
f01060ab:	89 e5                	mov    %esp,%ebp
f01060ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01060b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01060b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01060ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01060be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01060c8:	89 04 24             	mov    %eax,(%esp)
f01060cb:	e8 82 ff ff ff       	call   f0106052 <vsnprintf>
	va_end(ap);

	return rc;
}
f01060d0:	c9                   	leave  
f01060d1:	c3                   	ret    
f01060d2:	66 90                	xchg   %ax,%ax
f01060d4:	66 90                	xchg   %ax,%ax
f01060d6:	66 90                	xchg   %ax,%ax
f01060d8:	66 90                	xchg   %ax,%ax
f01060da:	66 90                	xchg   %ax,%ax
f01060dc:	66 90                	xchg   %ax,%ax
f01060de:	66 90                	xchg   %ax,%ax

f01060e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01060e0:	55                   	push   %ebp
f01060e1:	89 e5                	mov    %esp,%ebp
f01060e3:	57                   	push   %edi
f01060e4:	56                   	push   %esi
f01060e5:	53                   	push   %ebx
f01060e6:	83 ec 1c             	sub    $0x1c,%esp
f01060e9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01060ec:	85 c0                	test   %eax,%eax
f01060ee:	74 10                	je     f0106100 <readline+0x20>
		cprintf("%s", prompt);
f01060f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060f4:	c7 04 24 85 8d 10 f0 	movl   $0xf0108d85,(%esp)
f01060fb:	e8 89 e1 ff ff       	call   f0104289 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0106100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106107:	e8 fc a6 ff ff       	call   f0100808 <iscons>
f010610c:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010610e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106113:	e8 df a6 ff ff       	call   f01007f7 <getchar>
f0106118:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010611a:	85 c0                	test   %eax,%eax
f010611c:	79 25                	jns    f0106143 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010611e:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0106123:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0106126:	0f 84 89 00 00 00    	je     f01061b5 <readline+0xd5>
				cprintf("read error: %e\n", c);
f010612c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106130:	c7 04 24 bf 9c 10 f0 	movl   $0xf0109cbf,(%esp)
f0106137:	e8 4d e1 ff ff       	call   f0104289 <cprintf>
			return NULL;
f010613c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106141:	eb 72                	jmp    f01061b5 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106143:	83 f8 7f             	cmp    $0x7f,%eax
f0106146:	74 05                	je     f010614d <readline+0x6d>
f0106148:	83 f8 08             	cmp    $0x8,%eax
f010614b:	75 1a                	jne    f0106167 <readline+0x87>
f010614d:	85 f6                	test   %esi,%esi
f010614f:	90                   	nop
f0106150:	7e 15                	jle    f0106167 <readline+0x87>
			if (echoing)
f0106152:	85 ff                	test   %edi,%edi
f0106154:	74 0c                	je     f0106162 <readline+0x82>
				cputchar('\b');
f0106156:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010615d:	e8 85 a6 ff ff       	call   f01007e7 <cputchar>
			i--;
f0106162:	83 ee 01             	sub    $0x1,%esi
f0106165:	eb ac                	jmp    f0106113 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106167:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010616d:	7f 1c                	jg     f010618b <readline+0xab>
f010616f:	83 fb 1f             	cmp    $0x1f,%ebx
f0106172:	7e 17                	jle    f010618b <readline+0xab>
			if (echoing)
f0106174:	85 ff                	test   %edi,%edi
f0106176:	74 08                	je     f0106180 <readline+0xa0>
				cputchar(c);
f0106178:	89 1c 24             	mov    %ebx,(%esp)
f010617b:	e8 67 a6 ff ff       	call   f01007e7 <cputchar>
			buf[i++] = c;
f0106180:	88 9e 80 da 2b f0    	mov    %bl,-0xfd42580(%esi)
f0106186:	8d 76 01             	lea    0x1(%esi),%esi
f0106189:	eb 88                	jmp    f0106113 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010618b:	83 fb 0d             	cmp    $0xd,%ebx
f010618e:	74 09                	je     f0106199 <readline+0xb9>
f0106190:	83 fb 0a             	cmp    $0xa,%ebx
f0106193:	0f 85 7a ff ff ff    	jne    f0106113 <readline+0x33>
			if (echoing)
f0106199:	85 ff                	test   %edi,%edi
f010619b:	74 0c                	je     f01061a9 <readline+0xc9>
				cputchar('\n');
f010619d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01061a4:	e8 3e a6 ff ff       	call   f01007e7 <cputchar>
			buf[i] = 0;
f01061a9:	c6 86 80 da 2b f0 00 	movb   $0x0,-0xfd42580(%esi)
			return buf;
f01061b0:	b8 80 da 2b f0       	mov    $0xf02bda80,%eax
		}
	}
}
f01061b5:	83 c4 1c             	add    $0x1c,%esp
f01061b8:	5b                   	pop    %ebx
f01061b9:	5e                   	pop    %esi
f01061ba:	5f                   	pop    %edi
f01061bb:	5d                   	pop    %ebp
f01061bc:	c3                   	ret    
f01061bd:	66 90                	xchg   %ax,%ax
f01061bf:	90                   	nop

f01061c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01061c0:	55                   	push   %ebp
f01061c1:	89 e5                	mov    %esp,%ebp
f01061c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01061c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01061cb:	eb 03                	jmp    f01061d0 <strlen+0x10>
		n++;
f01061cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01061d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01061d4:	75 f7                	jne    f01061cd <strlen+0xd>
		n++;
	return n;
}
f01061d6:	5d                   	pop    %ebp
f01061d7:	c3                   	ret    

f01061d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01061d8:	55                   	push   %ebp
f01061d9:	89 e5                	mov    %esp,%ebp
f01061db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01061de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01061e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01061e6:	eb 03                	jmp    f01061eb <strnlen+0x13>
		n++;
f01061e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01061eb:	39 d0                	cmp    %edx,%eax
f01061ed:	74 06                	je     f01061f5 <strnlen+0x1d>
f01061ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01061f3:	75 f3                	jne    f01061e8 <strnlen+0x10>
		n++;
	return n;
}
f01061f5:	5d                   	pop    %ebp
f01061f6:	c3                   	ret    

f01061f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01061f7:	55                   	push   %ebp
f01061f8:	89 e5                	mov    %esp,%ebp
f01061fa:	53                   	push   %ebx
f01061fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01061fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106201:	89 c2                	mov    %eax,%edx
f0106203:	83 c2 01             	add    $0x1,%edx
f0106206:	83 c1 01             	add    $0x1,%ecx
f0106209:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010620d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106210:	84 db                	test   %bl,%bl
f0106212:	75 ef                	jne    f0106203 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106214:	5b                   	pop    %ebx
f0106215:	5d                   	pop    %ebp
f0106216:	c3                   	ret    

f0106217 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106217:	55                   	push   %ebp
f0106218:	89 e5                	mov    %esp,%ebp
f010621a:	53                   	push   %ebx
f010621b:	83 ec 08             	sub    $0x8,%esp
f010621e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106221:	89 1c 24             	mov    %ebx,(%esp)
f0106224:	e8 97 ff ff ff       	call   f01061c0 <strlen>
	strcpy(dst + len, src);
f0106229:	8b 55 0c             	mov    0xc(%ebp),%edx
f010622c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106230:	01 d8                	add    %ebx,%eax
f0106232:	89 04 24             	mov    %eax,(%esp)
f0106235:	e8 bd ff ff ff       	call   f01061f7 <strcpy>
	return dst;
}
f010623a:	89 d8                	mov    %ebx,%eax
f010623c:	83 c4 08             	add    $0x8,%esp
f010623f:	5b                   	pop    %ebx
f0106240:	5d                   	pop    %ebp
f0106241:	c3                   	ret    

f0106242 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106242:	55                   	push   %ebp
f0106243:	89 e5                	mov    %esp,%ebp
f0106245:	56                   	push   %esi
f0106246:	53                   	push   %ebx
f0106247:	8b 75 08             	mov    0x8(%ebp),%esi
f010624a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010624d:	89 f3                	mov    %esi,%ebx
f010624f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106252:	89 f2                	mov    %esi,%edx
f0106254:	eb 0f                	jmp    f0106265 <strncpy+0x23>
		*dst++ = *src;
f0106256:	83 c2 01             	add    $0x1,%edx
f0106259:	0f b6 01             	movzbl (%ecx),%eax
f010625c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010625f:	80 39 01             	cmpb   $0x1,(%ecx)
f0106262:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106265:	39 da                	cmp    %ebx,%edx
f0106267:	75 ed                	jne    f0106256 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106269:	89 f0                	mov    %esi,%eax
f010626b:	5b                   	pop    %ebx
f010626c:	5e                   	pop    %esi
f010626d:	5d                   	pop    %ebp
f010626e:	c3                   	ret    

f010626f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010626f:	55                   	push   %ebp
f0106270:	89 e5                	mov    %esp,%ebp
f0106272:	56                   	push   %esi
f0106273:	53                   	push   %ebx
f0106274:	8b 75 08             	mov    0x8(%ebp),%esi
f0106277:	8b 55 0c             	mov    0xc(%ebp),%edx
f010627a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010627d:	89 f0                	mov    %esi,%eax
f010627f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106283:	85 c9                	test   %ecx,%ecx
f0106285:	75 0b                	jne    f0106292 <strlcpy+0x23>
f0106287:	eb 1d                	jmp    f01062a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0106289:	83 c0 01             	add    $0x1,%eax
f010628c:	83 c2 01             	add    $0x1,%edx
f010628f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106292:	39 d8                	cmp    %ebx,%eax
f0106294:	74 0b                	je     f01062a1 <strlcpy+0x32>
f0106296:	0f b6 0a             	movzbl (%edx),%ecx
f0106299:	84 c9                	test   %cl,%cl
f010629b:	75 ec                	jne    f0106289 <strlcpy+0x1a>
f010629d:	89 c2                	mov    %eax,%edx
f010629f:	eb 02                	jmp    f01062a3 <strlcpy+0x34>
f01062a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01062a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01062a6:	29 f0                	sub    %esi,%eax
}
f01062a8:	5b                   	pop    %ebx
f01062a9:	5e                   	pop    %esi
f01062aa:	5d                   	pop    %ebp
f01062ab:	c3                   	ret    

f01062ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01062ac:	55                   	push   %ebp
f01062ad:	89 e5                	mov    %esp,%ebp
f01062af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01062b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01062b5:	eb 06                	jmp    f01062bd <strcmp+0x11>
		p++, q++;
f01062b7:	83 c1 01             	add    $0x1,%ecx
f01062ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01062bd:	0f b6 01             	movzbl (%ecx),%eax
f01062c0:	84 c0                	test   %al,%al
f01062c2:	74 04                	je     f01062c8 <strcmp+0x1c>
f01062c4:	3a 02                	cmp    (%edx),%al
f01062c6:	74 ef                	je     f01062b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01062c8:	0f b6 c0             	movzbl %al,%eax
f01062cb:	0f b6 12             	movzbl (%edx),%edx
f01062ce:	29 d0                	sub    %edx,%eax
}
f01062d0:	5d                   	pop    %ebp
f01062d1:	c3                   	ret    

f01062d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01062d2:	55                   	push   %ebp
f01062d3:	89 e5                	mov    %esp,%ebp
f01062d5:	53                   	push   %ebx
f01062d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01062d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062dc:	89 c3                	mov    %eax,%ebx
f01062de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01062e1:	eb 06                	jmp    f01062e9 <strncmp+0x17>
		n--, p++, q++;
f01062e3:	83 c0 01             	add    $0x1,%eax
f01062e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01062e9:	39 d8                	cmp    %ebx,%eax
f01062eb:	74 15                	je     f0106302 <strncmp+0x30>
f01062ed:	0f b6 08             	movzbl (%eax),%ecx
f01062f0:	84 c9                	test   %cl,%cl
f01062f2:	74 04                	je     f01062f8 <strncmp+0x26>
f01062f4:	3a 0a                	cmp    (%edx),%cl
f01062f6:	74 eb                	je     f01062e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01062f8:	0f b6 00             	movzbl (%eax),%eax
f01062fb:	0f b6 12             	movzbl (%edx),%edx
f01062fe:	29 d0                	sub    %edx,%eax
f0106300:	eb 05                	jmp    f0106307 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106302:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106307:	5b                   	pop    %ebx
f0106308:	5d                   	pop    %ebp
f0106309:	c3                   	ret    

f010630a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010630a:	55                   	push   %ebp
f010630b:	89 e5                	mov    %esp,%ebp
f010630d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106310:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106314:	eb 07                	jmp    f010631d <strchr+0x13>
		if (*s == c)
f0106316:	38 ca                	cmp    %cl,%dl
f0106318:	74 0f                	je     f0106329 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010631a:	83 c0 01             	add    $0x1,%eax
f010631d:	0f b6 10             	movzbl (%eax),%edx
f0106320:	84 d2                	test   %dl,%dl
f0106322:	75 f2                	jne    f0106316 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0106324:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106329:	5d                   	pop    %ebp
f010632a:	c3                   	ret    

f010632b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010632b:	55                   	push   %ebp
f010632c:	89 e5                	mov    %esp,%ebp
f010632e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106331:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106335:	eb 07                	jmp    f010633e <strfind+0x13>
		if (*s == c)
f0106337:	38 ca                	cmp    %cl,%dl
f0106339:	74 0a                	je     f0106345 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010633b:	83 c0 01             	add    $0x1,%eax
f010633e:	0f b6 10             	movzbl (%eax),%edx
f0106341:	84 d2                	test   %dl,%dl
f0106343:	75 f2                	jne    f0106337 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0106345:	5d                   	pop    %ebp
f0106346:	c3                   	ret    

f0106347 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106347:	55                   	push   %ebp
f0106348:	89 e5                	mov    %esp,%ebp
f010634a:	57                   	push   %edi
f010634b:	56                   	push   %esi
f010634c:	53                   	push   %ebx
f010634d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106350:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106353:	85 c9                	test   %ecx,%ecx
f0106355:	74 36                	je     f010638d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106357:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010635d:	75 28                	jne    f0106387 <memset+0x40>
f010635f:	f6 c1 03             	test   $0x3,%cl
f0106362:	75 23                	jne    f0106387 <memset+0x40>
		c &= 0xFF;
f0106364:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106368:	89 d3                	mov    %edx,%ebx
f010636a:	c1 e3 08             	shl    $0x8,%ebx
f010636d:	89 d6                	mov    %edx,%esi
f010636f:	c1 e6 18             	shl    $0x18,%esi
f0106372:	89 d0                	mov    %edx,%eax
f0106374:	c1 e0 10             	shl    $0x10,%eax
f0106377:	09 f0                	or     %esi,%eax
f0106379:	09 c2                	or     %eax,%edx
f010637b:	89 d0                	mov    %edx,%eax
f010637d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010637f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106382:	fc                   	cld    
f0106383:	f3 ab                	rep stos %eax,%es:(%edi)
f0106385:	eb 06                	jmp    f010638d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106387:	8b 45 0c             	mov    0xc(%ebp),%eax
f010638a:	fc                   	cld    
f010638b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010638d:	89 f8                	mov    %edi,%eax
f010638f:	5b                   	pop    %ebx
f0106390:	5e                   	pop    %esi
f0106391:	5f                   	pop    %edi
f0106392:	5d                   	pop    %ebp
f0106393:	c3                   	ret    

f0106394 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106394:	55                   	push   %ebp
f0106395:	89 e5                	mov    %esp,%ebp
f0106397:	57                   	push   %edi
f0106398:	56                   	push   %esi
f0106399:	8b 45 08             	mov    0x8(%ebp),%eax
f010639c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010639f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01063a2:	39 c6                	cmp    %eax,%esi
f01063a4:	73 35                	jae    f01063db <memmove+0x47>
f01063a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01063a9:	39 d0                	cmp    %edx,%eax
f01063ab:	73 2e                	jae    f01063db <memmove+0x47>
		s += n;
		d += n;
f01063ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01063b0:	89 d6                	mov    %edx,%esi
f01063b2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01063b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01063ba:	75 13                	jne    f01063cf <memmove+0x3b>
f01063bc:	f6 c1 03             	test   $0x3,%cl
f01063bf:	75 0e                	jne    f01063cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01063c1:	83 ef 04             	sub    $0x4,%edi
f01063c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01063c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01063ca:	fd                   	std    
f01063cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01063cd:	eb 09                	jmp    f01063d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01063cf:	83 ef 01             	sub    $0x1,%edi
f01063d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01063d5:	fd                   	std    
f01063d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01063d8:	fc                   	cld    
f01063d9:	eb 1d                	jmp    f01063f8 <memmove+0x64>
f01063db:	89 f2                	mov    %esi,%edx
f01063dd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01063df:	f6 c2 03             	test   $0x3,%dl
f01063e2:	75 0f                	jne    f01063f3 <memmove+0x5f>
f01063e4:	f6 c1 03             	test   $0x3,%cl
f01063e7:	75 0a                	jne    f01063f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01063e9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01063ec:	89 c7                	mov    %eax,%edi
f01063ee:	fc                   	cld    
f01063ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01063f1:	eb 05                	jmp    f01063f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01063f3:	89 c7                	mov    %eax,%edi
f01063f5:	fc                   	cld    
f01063f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01063f8:	5e                   	pop    %esi
f01063f9:	5f                   	pop    %edi
f01063fa:	5d                   	pop    %ebp
f01063fb:	c3                   	ret    

f01063fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01063fc:	55                   	push   %ebp
f01063fd:	89 e5                	mov    %esp,%ebp
f01063ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106402:	8b 45 10             	mov    0x10(%ebp),%eax
f0106405:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106409:	8b 45 0c             	mov    0xc(%ebp),%eax
f010640c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106410:	8b 45 08             	mov    0x8(%ebp),%eax
f0106413:	89 04 24             	mov    %eax,(%esp)
f0106416:	e8 79 ff ff ff       	call   f0106394 <memmove>
}
f010641b:	c9                   	leave  
f010641c:	c3                   	ret    

f010641d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010641d:	55                   	push   %ebp
f010641e:	89 e5                	mov    %esp,%ebp
f0106420:	56                   	push   %esi
f0106421:	53                   	push   %ebx
f0106422:	8b 55 08             	mov    0x8(%ebp),%edx
f0106425:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106428:	89 d6                	mov    %edx,%esi
f010642a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010642d:	eb 1a                	jmp    f0106449 <memcmp+0x2c>
		if (*s1 != *s2)
f010642f:	0f b6 02             	movzbl (%edx),%eax
f0106432:	0f b6 19             	movzbl (%ecx),%ebx
f0106435:	38 d8                	cmp    %bl,%al
f0106437:	74 0a                	je     f0106443 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0106439:	0f b6 c0             	movzbl %al,%eax
f010643c:	0f b6 db             	movzbl %bl,%ebx
f010643f:	29 d8                	sub    %ebx,%eax
f0106441:	eb 0f                	jmp    f0106452 <memcmp+0x35>
		s1++, s2++;
f0106443:	83 c2 01             	add    $0x1,%edx
f0106446:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106449:	39 f2                	cmp    %esi,%edx
f010644b:	75 e2                	jne    f010642f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010644d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106452:	5b                   	pop    %ebx
f0106453:	5e                   	pop    %esi
f0106454:	5d                   	pop    %ebp
f0106455:	c3                   	ret    

f0106456 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106456:	55                   	push   %ebp
f0106457:	89 e5                	mov    %esp,%ebp
f0106459:	8b 45 08             	mov    0x8(%ebp),%eax
f010645c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010645f:	89 c2                	mov    %eax,%edx
f0106461:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106464:	eb 07                	jmp    f010646d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106466:	38 08                	cmp    %cl,(%eax)
f0106468:	74 07                	je     f0106471 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010646a:	83 c0 01             	add    $0x1,%eax
f010646d:	39 d0                	cmp    %edx,%eax
f010646f:	72 f5                	jb     f0106466 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106471:	5d                   	pop    %ebp
f0106472:	c3                   	ret    

f0106473 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106473:	55                   	push   %ebp
f0106474:	89 e5                	mov    %esp,%ebp
f0106476:	57                   	push   %edi
f0106477:	56                   	push   %esi
f0106478:	53                   	push   %ebx
f0106479:	8b 55 08             	mov    0x8(%ebp),%edx
f010647c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010647f:	eb 03                	jmp    f0106484 <strtol+0x11>
		s++;
f0106481:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106484:	0f b6 0a             	movzbl (%edx),%ecx
f0106487:	80 f9 09             	cmp    $0x9,%cl
f010648a:	74 f5                	je     f0106481 <strtol+0xe>
f010648c:	80 f9 20             	cmp    $0x20,%cl
f010648f:	74 f0                	je     f0106481 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106491:	80 f9 2b             	cmp    $0x2b,%cl
f0106494:	75 0a                	jne    f01064a0 <strtol+0x2d>
		s++;
f0106496:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106499:	bf 00 00 00 00       	mov    $0x0,%edi
f010649e:	eb 11                	jmp    f01064b1 <strtol+0x3e>
f01064a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01064a5:	80 f9 2d             	cmp    $0x2d,%cl
f01064a8:	75 07                	jne    f01064b1 <strtol+0x3e>
		s++, neg = 1;
f01064aa:	8d 52 01             	lea    0x1(%edx),%edx
f01064ad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01064b1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01064b6:	75 15                	jne    f01064cd <strtol+0x5a>
f01064b8:	80 3a 30             	cmpb   $0x30,(%edx)
f01064bb:	75 10                	jne    f01064cd <strtol+0x5a>
f01064bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01064c1:	75 0a                	jne    f01064cd <strtol+0x5a>
		s += 2, base = 16;
f01064c3:	83 c2 02             	add    $0x2,%edx
f01064c6:	b8 10 00 00 00       	mov    $0x10,%eax
f01064cb:	eb 10                	jmp    f01064dd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f01064cd:	85 c0                	test   %eax,%eax
f01064cf:	75 0c                	jne    f01064dd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01064d1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01064d3:	80 3a 30             	cmpb   $0x30,(%edx)
f01064d6:	75 05                	jne    f01064dd <strtol+0x6a>
		s++, base = 8;
f01064d8:	83 c2 01             	add    $0x1,%edx
f01064db:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f01064dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01064e2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01064e5:	0f b6 0a             	movzbl (%edx),%ecx
f01064e8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01064eb:	89 f0                	mov    %esi,%eax
f01064ed:	3c 09                	cmp    $0x9,%al
f01064ef:	77 08                	ja     f01064f9 <strtol+0x86>
			dig = *s - '0';
f01064f1:	0f be c9             	movsbl %cl,%ecx
f01064f4:	83 e9 30             	sub    $0x30,%ecx
f01064f7:	eb 20                	jmp    f0106519 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01064f9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01064fc:	89 f0                	mov    %esi,%eax
f01064fe:	3c 19                	cmp    $0x19,%al
f0106500:	77 08                	ja     f010650a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106502:	0f be c9             	movsbl %cl,%ecx
f0106505:	83 e9 57             	sub    $0x57,%ecx
f0106508:	eb 0f                	jmp    f0106519 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010650a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010650d:	89 f0                	mov    %esi,%eax
f010650f:	3c 19                	cmp    $0x19,%al
f0106511:	77 16                	ja     f0106529 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106513:	0f be c9             	movsbl %cl,%ecx
f0106516:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106519:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010651c:	7d 0f                	jge    f010652d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010651e:	83 c2 01             	add    $0x1,%edx
f0106521:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106525:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106527:	eb bc                	jmp    f01064e5 <strtol+0x72>
f0106529:	89 d8                	mov    %ebx,%eax
f010652b:	eb 02                	jmp    f010652f <strtol+0xbc>
f010652d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010652f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106533:	74 05                	je     f010653a <strtol+0xc7>
		*endptr = (char *) s;
f0106535:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106538:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010653a:	f7 d8                	neg    %eax
f010653c:	85 ff                	test   %edi,%edi
f010653e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106541:	5b                   	pop    %ebx
f0106542:	5e                   	pop    %esi
f0106543:	5f                   	pop    %edi
f0106544:	5d                   	pop    %ebp
f0106545:	c3                   	ret    
f0106546:	66 90                	xchg   %ax,%ax

f0106548 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106548:	fa                   	cli    

	xorw    %ax, %ax
f0106549:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010654b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010654d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010654f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106551:	0f 01 16             	lgdtl  (%esi)
f0106554:	74 70                	je     f01065c6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106556:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106559:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010655d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106560:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106566:	08 00                	or     %al,(%eax)

f0106568 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106568:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010656c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010656e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106570:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106572:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106576:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106578:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010657a:	b8 00 30 12 00       	mov    $0x123000,%eax
	movl    %eax, %cr3
f010657f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106582:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106585:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010658a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010658d:	8b 25 90 de 2b f0    	mov    0xf02bde90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106593:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106598:	b8 1a 02 10 f0       	mov    $0xf010021a,%eax
	call    *%eax
f010659d:	ff d0                	call   *%eax

f010659f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010659f:	eb fe                	jmp    f010659f <spin>
f01065a1:	8d 76 00             	lea    0x0(%esi),%esi

f01065a4 <gdt>:
	...
f01065ac:	ff                   	(bad)  
f01065ad:	ff 00                	incl   (%eax)
f01065af:	00 00                	add    %al,(%eax)
f01065b1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01065b8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01065bc <gdtdesc>:
f01065bc:	17                   	pop    %ss
f01065bd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01065c2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01065c2:	90                   	nop
f01065c3:	66 90                	xchg   %ax,%ax
f01065c5:	66 90                	xchg   %ax,%ax
f01065c7:	66 90                	xchg   %ax,%ax
f01065c9:	66 90                	xchg   %ax,%ax
f01065cb:	66 90                	xchg   %ax,%ax
f01065cd:	66 90                	xchg   %ax,%ax
f01065cf:	90                   	nop

f01065d0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01065d0:	55                   	push   %ebp
f01065d1:	89 e5                	mov    %esp,%ebp
f01065d3:	56                   	push   %esi
f01065d4:	53                   	push   %ebx
f01065d5:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065d8:	8b 0d 94 de 2b f0    	mov    0xf02bde94,%ecx
f01065de:	89 c3                	mov    %eax,%ebx
f01065e0:	c1 eb 0c             	shr    $0xc,%ebx
f01065e3:	39 cb                	cmp    %ecx,%ebx
f01065e5:	72 20                	jb     f0106607 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065eb:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f01065f2:	f0 
f01065f3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01065fa:	00 
f01065fb:	c7 04 24 5d 9e 10 f0 	movl   $0xf0109e5d,(%esp)
f0106602:	e8 39 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106607:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010660d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010660f:	89 c2                	mov    %eax,%edx
f0106611:	c1 ea 0c             	shr    $0xc,%edx
f0106614:	39 d1                	cmp    %edx,%ecx
f0106616:	77 20                	ja     f0106638 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106618:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010661c:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0106623:	f0 
f0106624:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010662b:	00 
f010662c:	c7 04 24 5d 9e 10 f0 	movl   $0xf0109e5d,(%esp)
f0106633:	e8 08 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106638:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010663e:	eb 36                	jmp    f0106676 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106640:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106647:	00 
f0106648:	c7 44 24 04 6d 9e 10 	movl   $0xf0109e6d,0x4(%esp)
f010664f:	f0 
f0106650:	89 1c 24             	mov    %ebx,(%esp)
f0106653:	e8 c5 fd ff ff       	call   f010641d <memcmp>
f0106658:	85 c0                	test   %eax,%eax
f010665a:	75 17                	jne    f0106673 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010665c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106661:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106665:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106667:	83 c2 01             	add    $0x1,%edx
f010666a:	83 fa 10             	cmp    $0x10,%edx
f010666d:	75 f2                	jne    f0106661 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010666f:	84 c0                	test   %al,%al
f0106671:	74 0e                	je     f0106681 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106673:	83 c3 10             	add    $0x10,%ebx
f0106676:	39 f3                	cmp    %esi,%ebx
f0106678:	72 c6                	jb     f0106640 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010667a:	b8 00 00 00 00       	mov    $0x0,%eax
f010667f:	eb 02                	jmp    f0106683 <mpsearch1+0xb3>
f0106681:	89 d8                	mov    %ebx,%eax
}
f0106683:	83 c4 10             	add    $0x10,%esp
f0106686:	5b                   	pop    %ebx
f0106687:	5e                   	pop    %esi
f0106688:	5d                   	pop    %ebp
f0106689:	c3                   	ret    

f010668a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010668a:	55                   	push   %ebp
f010668b:	89 e5                	mov    %esp,%ebp
f010668d:	57                   	push   %edi
f010668e:	56                   	push   %esi
f010668f:	53                   	push   %ebx
f0106690:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106693:	c7 05 c0 f3 2b f0 20 	movl   $0xf02bf020,0xf02bf3c0
f010669a:	f0 2b f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010669d:	83 3d 94 de 2b f0 00 	cmpl   $0x0,0xf02bde94
f01066a4:	75 24                	jne    f01066ca <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066a6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01066ad:	00 
f01066ae:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f01066b5:	f0 
f01066b6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01066bd:	00 
f01066be:	c7 04 24 5d 9e 10 f0 	movl   $0xf0109e5d,(%esp)
f01066c5:	e8 76 99 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01066ca:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01066d1:	85 c0                	test   %eax,%eax
f01066d3:	74 16                	je     f01066eb <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01066d5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01066d8:	ba 00 04 00 00       	mov    $0x400,%edx
f01066dd:	e8 ee fe ff ff       	call   f01065d0 <mpsearch1>
f01066e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01066e5:	85 c0                	test   %eax,%eax
f01066e7:	75 3c                	jne    f0106725 <mp_init+0x9b>
f01066e9:	eb 20                	jmp    f010670b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01066eb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01066f2:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01066f5:	2d 00 04 00 00       	sub    $0x400,%eax
f01066fa:	ba 00 04 00 00       	mov    $0x400,%edx
f01066ff:	e8 cc fe ff ff       	call   f01065d0 <mpsearch1>
f0106704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106707:	85 c0                	test   %eax,%eax
f0106709:	75 1a                	jne    f0106725 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010670b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106710:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106715:	e8 b6 fe ff ff       	call   f01065d0 <mpsearch1>
f010671a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010671d:	85 c0                	test   %eax,%eax
f010671f:	0f 84 54 02 00 00    	je     f0106979 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106728:	8b 70 04             	mov    0x4(%eax),%esi
f010672b:	85 f6                	test   %esi,%esi
f010672d:	74 06                	je     f0106735 <mp_init+0xab>
f010672f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106733:	74 11                	je     f0106746 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106735:	c7 04 24 d0 9c 10 f0 	movl   $0xf0109cd0,(%esp)
f010673c:	e8 48 db ff ff       	call   f0104289 <cprintf>
f0106741:	e9 33 02 00 00       	jmp    f0106979 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106746:	89 f0                	mov    %esi,%eax
f0106748:	c1 e8 0c             	shr    $0xc,%eax
f010674b:	3b 05 94 de 2b f0    	cmp    0xf02bde94,%eax
f0106751:	72 20                	jb     f0106773 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106753:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106757:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f010675e:	f0 
f010675f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106766:	00 
f0106767:	c7 04 24 5d 9e 10 f0 	movl   $0xf0109e5d,(%esp)
f010676e:	e8 cd 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106773:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106779:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106780:	00 
f0106781:	c7 44 24 04 72 9e 10 	movl   $0xf0109e72,0x4(%esp)
f0106788:	f0 
f0106789:	89 1c 24             	mov    %ebx,(%esp)
f010678c:	e8 8c fc ff ff       	call   f010641d <memcmp>
f0106791:	85 c0                	test   %eax,%eax
f0106793:	74 11                	je     f01067a6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106795:	c7 04 24 00 9d 10 f0 	movl   $0xf0109d00,(%esp)
f010679c:	e8 e8 da ff ff       	call   f0104289 <cprintf>
f01067a1:	e9 d3 01 00 00       	jmp    f0106979 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01067a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01067aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01067ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01067b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01067b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01067bb:	eb 0d                	jmp    f01067ca <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f01067bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01067c4:	f0 
f01067c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067c7:	83 c0 01             	add    $0x1,%eax
f01067ca:	39 c7                	cmp    %eax,%edi
f01067cc:	7f ef                	jg     f01067bd <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01067ce:	84 d2                	test   %dl,%dl
f01067d0:	74 11                	je     f01067e3 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f01067d2:	c7 04 24 34 9d 10 f0 	movl   $0xf0109d34,(%esp)
f01067d9:	e8 ab da ff ff       	call   f0104289 <cprintf>
f01067de:	e9 96 01 00 00       	jmp    f0106979 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01067e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01067e7:	3c 04                	cmp    $0x4,%al
f01067e9:	74 1f                	je     f010680a <mp_init+0x180>
f01067eb:	3c 01                	cmp    $0x1,%al
f01067ed:	8d 76 00             	lea    0x0(%esi),%esi
f01067f0:	74 18                	je     f010680a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01067f2:	0f b6 c0             	movzbl %al,%eax
f01067f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067f9:	c7 04 24 58 9d 10 f0 	movl   $0xf0109d58,(%esp)
f0106800:	e8 84 da ff ff       	call   f0104289 <cprintf>
f0106805:	e9 6f 01 00 00       	jmp    f0106979 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010680a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010680e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106812:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106814:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106819:	b8 00 00 00 00       	mov    $0x0,%eax
f010681e:	eb 09                	jmp    f0106829 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106820:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106824:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106826:	83 c0 01             	add    $0x1,%eax
f0106829:	39 c6                	cmp    %eax,%esi
f010682b:	7f f3                	jg     f0106820 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010682d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106830:	84 d2                	test   %dl,%dl
f0106832:	74 11                	je     f0106845 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106834:	c7 04 24 78 9d 10 f0 	movl   $0xf0109d78,(%esp)
f010683b:	e8 49 da ff ff       	call   f0104289 <cprintf>
f0106840:	e9 34 01 00 00       	jmp    f0106979 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106845:	85 db                	test   %ebx,%ebx
f0106847:	0f 84 2c 01 00 00    	je     f0106979 <mp_init+0x2ef>
		return;
	ismp = 1;
f010684d:	c7 05 00 f0 2b f0 01 	movl   $0x1,0xf02bf000
f0106854:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106857:	8b 43 24             	mov    0x24(%ebx),%eax
f010685a:	a3 00 00 30 f0       	mov    %eax,0xf0300000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010685f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106862:	be 00 00 00 00       	mov    $0x0,%esi
f0106867:	e9 86 00 00 00       	jmp    f01068f2 <mp_init+0x268>
		switch (*p) {
f010686c:	0f b6 07             	movzbl (%edi),%eax
f010686f:	84 c0                	test   %al,%al
f0106871:	74 06                	je     f0106879 <mp_init+0x1ef>
f0106873:	3c 04                	cmp    $0x4,%al
f0106875:	77 57                	ja     f01068ce <mp_init+0x244>
f0106877:	eb 50                	jmp    f01068c9 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106879:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010687d:	8d 76 00             	lea    0x0(%esi),%esi
f0106880:	74 11                	je     f0106893 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106882:	6b 05 c4 f3 2b f0 74 	imul   $0x74,0xf02bf3c4,%eax
f0106889:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
f010688e:	a3 c0 f3 2b f0       	mov    %eax,0xf02bf3c0
			if (ncpu < NCPU) {
f0106893:	a1 c4 f3 2b f0       	mov    0xf02bf3c4,%eax
f0106898:	83 f8 07             	cmp    $0x7,%eax
f010689b:	7f 13                	jg     f01068b0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010689d:	6b d0 74             	imul   $0x74,%eax,%edx
f01068a0:	88 82 20 f0 2b f0    	mov    %al,-0xfd40fe0(%edx)
				ncpu++;
f01068a6:	83 c0 01             	add    $0x1,%eax
f01068a9:	a3 c4 f3 2b f0       	mov    %eax,0xf02bf3c4
f01068ae:	eb 14                	jmp    f01068c4 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01068b0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01068b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068b8:	c7 04 24 a8 9d 10 f0 	movl   $0xf0109da8,(%esp)
f01068bf:	e8 c5 d9 ff ff       	call   f0104289 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01068c4:	83 c7 14             	add    $0x14,%edi
			continue;
f01068c7:	eb 26                	jmp    f01068ef <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01068c9:	83 c7 08             	add    $0x8,%edi
			continue;
f01068cc:	eb 21                	jmp    f01068ef <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01068ce:	0f b6 c0             	movzbl %al,%eax
f01068d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068d5:	c7 04 24 d0 9d 10 f0 	movl   $0xf0109dd0,(%esp)
f01068dc:	e8 a8 d9 ff ff       	call   f0104289 <cprintf>
			ismp = 0;
f01068e1:	c7 05 00 f0 2b f0 00 	movl   $0x0,0xf02bf000
f01068e8:	00 00 00 
			i = conf->entry;
f01068eb:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01068ef:	83 c6 01             	add    $0x1,%esi
f01068f2:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01068f6:	39 c6                	cmp    %eax,%esi
f01068f8:	0f 82 6e ff ff ff    	jb     f010686c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01068fe:	a1 c0 f3 2b f0       	mov    0xf02bf3c0,%eax
f0106903:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010690a:	83 3d 00 f0 2b f0 00 	cmpl   $0x0,0xf02bf000
f0106911:	75 22                	jne    f0106935 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106913:	c7 05 c4 f3 2b f0 01 	movl   $0x1,0xf02bf3c4
f010691a:	00 00 00 
		lapicaddr = 0;
f010691d:	c7 05 00 00 30 f0 00 	movl   $0x0,0xf0300000
f0106924:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106927:	c7 04 24 f0 9d 10 f0 	movl   $0xf0109df0,(%esp)
f010692e:	e8 56 d9 ff ff       	call   f0104289 <cprintf>
		return;
f0106933:	eb 44                	jmp    f0106979 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106935:	8b 15 c4 f3 2b f0    	mov    0xf02bf3c4,%edx
f010693b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010693f:	0f b6 00             	movzbl (%eax),%eax
f0106942:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106946:	c7 04 24 77 9e 10 f0 	movl   $0xf0109e77,(%esp)
f010694d:	e8 37 d9 ff ff       	call   f0104289 <cprintf>

	if (mp->imcrp) {
f0106952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106955:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106959:	74 1e                	je     f0106979 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010695b:	c7 04 24 1c 9e 10 f0 	movl   $0xf0109e1c,(%esp)
f0106962:	e8 22 d9 ff ff       	call   f0104289 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106967:	ba 22 00 00 00       	mov    $0x22,%edx
f010696c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106971:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106972:	b2 23                	mov    $0x23,%dl
f0106974:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106975:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106978:	ee                   	out    %al,(%dx)
	}
}
f0106979:	83 c4 2c             	add    $0x2c,%esp
f010697c:	5b                   	pop    %ebx
f010697d:	5e                   	pop    %esi
f010697e:	5f                   	pop    %edi
f010697f:	5d                   	pop    %ebp
f0106980:	c3                   	ret    

f0106981 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106981:	55                   	push   %ebp
f0106982:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106984:	8b 0d 04 00 30 f0    	mov    0xf0300004,%ecx
f010698a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010698d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010698f:	a1 04 00 30 f0       	mov    0xf0300004,%eax
f0106994:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106997:	5d                   	pop    %ebp
f0106998:	c3                   	ret    

f0106999 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106999:	55                   	push   %ebp
f010699a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010699c:	a1 04 00 30 f0       	mov    0xf0300004,%eax
f01069a1:	85 c0                	test   %eax,%eax
f01069a3:	74 08                	je     f01069ad <cpunum+0x14>
		return lapic[ID] >> 24;
f01069a5:	8b 40 20             	mov    0x20(%eax),%eax
f01069a8:	c1 e8 18             	shr    $0x18,%eax
f01069ab:	eb 05                	jmp    f01069b2 <cpunum+0x19>
	return 0;
f01069ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01069b2:	5d                   	pop    %ebp
f01069b3:	c3                   	ret    

f01069b4 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01069b4:	a1 00 00 30 f0       	mov    0xf0300000,%eax
f01069b9:	85 c0                	test   %eax,%eax
f01069bb:	0f 84 23 01 00 00    	je     f0106ae4 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01069c1:	55                   	push   %ebp
f01069c2:	89 e5                	mov    %esp,%ebp
f01069c4:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01069c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01069ce:	00 
f01069cf:	89 04 24             	mov    %eax,(%esp)
f01069d2:	e8 62 ae ff ff       	call   f0101839 <mmio_map_region>
f01069d7:	a3 04 00 30 f0       	mov    %eax,0xf0300004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01069dc:	ba 27 01 00 00       	mov    $0x127,%edx
f01069e1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01069e6:	e8 96 ff ff ff       	call   f0106981 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01069eb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01069f0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01069f5:	e8 87 ff ff ff       	call   f0106981 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01069fa:	ba 20 00 02 00       	mov    $0x20020,%edx
f01069ff:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106a04:	e8 78 ff ff ff       	call   f0106981 <lapicw>
	lapicw(TICR, 10000000); 
f0106a09:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106a0e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106a13:	e8 69 ff ff ff       	call   f0106981 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106a18:	e8 7c ff ff ff       	call   f0106999 <cpunum>
f0106a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a20:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
f0106a25:	39 05 c0 f3 2b f0    	cmp    %eax,0xf02bf3c0
f0106a2b:	74 0f                	je     f0106a3c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106a2d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106a32:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106a37:	e8 45 ff ff ff       	call   f0106981 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106a3c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106a41:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106a46:	e8 36 ff ff ff       	call   f0106981 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106a4b:	a1 04 00 30 f0       	mov    0xf0300004,%eax
f0106a50:	8b 40 30             	mov    0x30(%eax),%eax
f0106a53:	c1 e8 10             	shr    $0x10,%eax
f0106a56:	3c 03                	cmp    $0x3,%al
f0106a58:	76 0f                	jbe    f0106a69 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106a5a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106a5f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106a64:	e8 18 ff ff ff       	call   f0106981 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106a69:	ba 33 00 00 00       	mov    $0x33,%edx
f0106a6e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106a73:	e8 09 ff ff ff       	call   f0106981 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106a78:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a7d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106a82:	e8 fa fe ff ff       	call   f0106981 <lapicw>
	lapicw(ESR, 0);
f0106a87:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a8c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106a91:	e8 eb fe ff ff       	call   f0106981 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106a96:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a9b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106aa0:	e8 dc fe ff ff       	call   f0106981 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106aa5:	ba 00 00 00 00       	mov    $0x0,%edx
f0106aaa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106aaf:	e8 cd fe ff ff       	call   f0106981 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106ab4:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106ab9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106abe:	e8 be fe ff ff       	call   f0106981 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106ac3:	8b 15 04 00 30 f0    	mov    0xf0300004,%edx
f0106ac9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106acf:	f6 c4 10             	test   $0x10,%ah
f0106ad2:	75 f5                	jne    f0106ac9 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106ad4:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ad9:	b8 20 00 00 00       	mov    $0x20,%eax
f0106ade:	e8 9e fe ff ff       	call   f0106981 <lapicw>
}
f0106ae3:	c9                   	leave  
f0106ae4:	f3 c3                	repz ret 

f0106ae6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106ae6:	83 3d 04 00 30 f0 00 	cmpl   $0x0,0xf0300004
f0106aed:	74 13                	je     f0106b02 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106aef:	55                   	push   %ebp
f0106af0:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106af2:	ba 00 00 00 00       	mov    $0x0,%edx
f0106af7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106afc:	e8 80 fe ff ff       	call   f0106981 <lapicw>
}
f0106b01:	5d                   	pop    %ebp
f0106b02:	f3 c3                	repz ret 

f0106b04 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106b04:	55                   	push   %ebp
f0106b05:	89 e5                	mov    %esp,%ebp
f0106b07:	56                   	push   %esi
f0106b08:	53                   	push   %ebx
f0106b09:	83 ec 10             	sub    $0x10,%esp
f0106b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106b0f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106b12:	ba 70 00 00 00       	mov    $0x70,%edx
f0106b17:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106b1c:	ee                   	out    %al,(%dx)
f0106b1d:	b2 71                	mov    $0x71,%dl
f0106b1f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106b24:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106b25:	83 3d 94 de 2b f0 00 	cmpl   $0x0,0xf02bde94
f0106b2c:	75 24                	jne    f0106b52 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106b2e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106b35:	00 
f0106b36:	c7 44 24 08 c4 7b 10 	movl   $0xf0107bc4,0x8(%esp)
f0106b3d:	f0 
f0106b3e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106b45:	00 
f0106b46:	c7 04 24 94 9e 10 f0 	movl   $0xf0109e94,(%esp)
f0106b4d:	e8 ee 94 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106b52:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106b59:	00 00 
	wrv[1] = addr >> 4;
f0106b5b:	89 f0                	mov    %esi,%eax
f0106b5d:	c1 e8 04             	shr    $0x4,%eax
f0106b60:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106b66:	c1 e3 18             	shl    $0x18,%ebx
f0106b69:	89 da                	mov    %ebx,%edx
f0106b6b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106b70:	e8 0c fe ff ff       	call   f0106981 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106b75:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106b7a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b7f:	e8 fd fd ff ff       	call   f0106981 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106b84:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106b89:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b8e:	e8 ee fd ff ff       	call   f0106981 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106b93:	c1 ee 0c             	shr    $0xc,%esi
f0106b96:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106b9c:	89 da                	mov    %ebx,%edx
f0106b9e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ba3:	e8 d9 fd ff ff       	call   f0106981 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ba8:	89 f2                	mov    %esi,%edx
f0106baa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106baf:	e8 cd fd ff ff       	call   f0106981 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106bb4:	89 da                	mov    %ebx,%edx
f0106bb6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106bbb:	e8 c1 fd ff ff       	call   f0106981 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106bc0:	89 f2                	mov    %esi,%edx
f0106bc2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106bc7:	e8 b5 fd ff ff       	call   f0106981 <lapicw>
		microdelay(200);
	}
}
f0106bcc:	83 c4 10             	add    $0x10,%esp
f0106bcf:	5b                   	pop    %ebx
f0106bd0:	5e                   	pop    %esi
f0106bd1:	5d                   	pop    %ebp
f0106bd2:	c3                   	ret    

f0106bd3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106bd3:	55                   	push   %ebp
f0106bd4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106bd6:	8b 55 08             	mov    0x8(%ebp),%edx
f0106bd9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106bdf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106be4:	e8 98 fd ff ff       	call   f0106981 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106be9:	8b 15 04 00 30 f0    	mov    0xf0300004,%edx
f0106bef:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106bf5:	f6 c4 10             	test   $0x10,%ah
f0106bf8:	75 f5                	jne    f0106bef <lapic_ipi+0x1c>
		;
}
f0106bfa:	5d                   	pop    %ebp
f0106bfb:	c3                   	ret    

f0106bfc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106bfc:	55                   	push   %ebp
f0106bfd:	89 e5                	mov    %esp,%ebp
f0106bff:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106c02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106c08:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c0b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106c0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106c15:	5d                   	pop    %ebp
f0106c16:	c3                   	ret    

f0106c17 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106c17:	55                   	push   %ebp
f0106c18:	89 e5                	mov    %esp,%ebp
f0106c1a:	56                   	push   %esi
f0106c1b:	53                   	push   %ebx
f0106c1c:	83 ec 20             	sub    $0x20,%esp
f0106c1f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106c22:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106c25:	75 07                	jne    f0106c2e <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106c27:	ba 01 00 00 00       	mov    $0x1,%edx
f0106c2c:	eb 42                	jmp    f0106c70 <spin_lock+0x59>
f0106c2e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106c31:	e8 63 fd ff ff       	call   f0106999 <cpunum>
f0106c36:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c39:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106c3e:	39 c6                	cmp    %eax,%esi
f0106c40:	75 e5                	jne    f0106c27 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106c42:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106c45:	e8 4f fd ff ff       	call   f0106999 <cpunum>
f0106c4a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106c4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c52:	c7 44 24 08 a4 9e 10 	movl   $0xf0109ea4,0x8(%esp)
f0106c59:	f0 
f0106c5a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106c61:	00 
f0106c62:	c7 04 24 06 9f 10 f0 	movl   $0xf0109f06,(%esp)
f0106c69:	e8 d2 93 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106c6e:	f3 90                	pause  
f0106c70:	89 d0                	mov    %edx,%eax
f0106c72:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106c75:	85 c0                	test   %eax,%eax
f0106c77:	75 f5                	jne    f0106c6e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106c79:	e8 1b fd ff ff       	call   f0106999 <cpunum>
f0106c7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c81:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
f0106c86:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106c89:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106c8c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106c8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106c93:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106c99:	76 12                	jbe    f0106cad <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106c9b:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106c9e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106ca1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106ca3:	83 c0 01             	add    $0x1,%eax
f0106ca6:	83 f8 0a             	cmp    $0xa,%eax
f0106ca9:	75 e8                	jne    f0106c93 <spin_lock+0x7c>
f0106cab:	eb 0f                	jmp    f0106cbc <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106cad:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106cb4:	83 c0 01             	add    $0x1,%eax
f0106cb7:	83 f8 09             	cmp    $0x9,%eax
f0106cba:	7e f1                	jle    f0106cad <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106cbc:	83 c4 20             	add    $0x20,%esp
f0106cbf:	5b                   	pop    %ebx
f0106cc0:	5e                   	pop    %esi
f0106cc1:	5d                   	pop    %ebp
f0106cc2:	c3                   	ret    

f0106cc3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106cc3:	55                   	push   %ebp
f0106cc4:	89 e5                	mov    %esp,%ebp
f0106cc6:	57                   	push   %edi
f0106cc7:	56                   	push   %esi
f0106cc8:	53                   	push   %ebx
f0106cc9:	83 ec 6c             	sub    $0x6c,%esp
f0106ccc:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106ccf:	83 3e 00             	cmpl   $0x0,(%esi)
f0106cd2:	74 18                	je     f0106cec <spin_unlock+0x29>
f0106cd4:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106cd7:	e8 bd fc ff ff       	call   f0106999 <cpunum>
f0106cdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0106cdf:	05 20 f0 2b f0       	add    $0xf02bf020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ce4:	39 c3                	cmp    %eax,%ebx
f0106ce6:	0f 84 ce 00 00 00    	je     f0106dba <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106cec:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106cf3:	00 
f0106cf4:	8d 46 0c             	lea    0xc(%esi),%eax
f0106cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cfb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106cfe:	89 1c 24             	mov    %ebx,(%esp)
f0106d01:	e8 8e f6 ff ff       	call   f0106394 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106d06:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106d09:	0f b6 38             	movzbl (%eax),%edi
f0106d0c:	8b 76 04             	mov    0x4(%esi),%esi
f0106d0f:	e8 85 fc ff ff       	call   f0106999 <cpunum>
f0106d14:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d18:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d20:	c7 04 24 d0 9e 10 f0 	movl   $0xf0109ed0,(%esp)
f0106d27:	e8 5d d5 ff ff       	call   f0104289 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106d2c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106d2f:	eb 65                	jmp    f0106d96 <spin_unlock+0xd3>
f0106d31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106d35:	89 04 24             	mov    %eax,(%esp)
f0106d38:	e8 81 eb ff ff       	call   f01058be <debuginfo_eip>
f0106d3d:	85 c0                	test   %eax,%eax
f0106d3f:	78 39                	js     f0106d7a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106d41:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106d43:	89 c2                	mov    %eax,%edx
f0106d45:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106d48:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106d4c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106d4f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106d53:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106d56:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106d5a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106d5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106d61:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106d64:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106d68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d6c:	c7 04 24 16 9f 10 f0 	movl   $0xf0109f16,(%esp)
f0106d73:	e8 11 d5 ff ff       	call   f0104289 <cprintf>
f0106d78:	eb 12                	jmp    f0106d8c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106d7a:	8b 06                	mov    (%esi),%eax
f0106d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d80:	c7 04 24 2d 9f 10 f0 	movl   $0xf0109f2d,(%esp)
f0106d87:	e8 fd d4 ff ff       	call   f0104289 <cprintf>
f0106d8c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106d8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106d92:	39 c3                	cmp    %eax,%ebx
f0106d94:	74 08                	je     f0106d9e <spin_unlock+0xdb>
f0106d96:	89 de                	mov    %ebx,%esi
f0106d98:	8b 03                	mov    (%ebx),%eax
f0106d9a:	85 c0                	test   %eax,%eax
f0106d9c:	75 93                	jne    f0106d31 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106d9e:	c7 44 24 08 35 9f 10 	movl   $0xf0109f35,0x8(%esp)
f0106da5:	f0 
f0106da6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106dad:	00 
f0106dae:	c7 04 24 06 9f 10 f0 	movl   $0xf0109f06,(%esp)
f0106db5:	e8 86 92 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106dba:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106dc1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106dc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0106dcd:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106dd0:	83 c4 6c             	add    $0x6c,%esp
f0106dd3:	5b                   	pop    %ebx
f0106dd4:	5e                   	pop    %esi
f0106dd5:	5f                   	pop    %edi
f0106dd6:	5d                   	pop    %ebp
f0106dd7:	c3                   	ret    

f0106dd8 <va2pa>:
struct rx_desc rx_ring[NRD] __attribute__((aligned(4096)));

struct packet_buf tx_bufs[NTD] __attribute__((aligned(4096)));
struct packet_buf rx_bufs[NRD] __attribute__((aligned(4096)));

int va2pa(void* packet, uint32_t* pa_store) {
f0106dd8:	55                   	push   %ebp
f0106dd9:	89 e5                	mov    %esp,%ebp
f0106ddb:	53                   	push   %ebx
f0106ddc:	83 ec 14             	sub    $0x14,%esp
f0106ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pte_t *pte = pgdir_walk(curenv->env_pgdir, packet, 0);
f0106de2:	e8 b2 fb ff ff       	call   f0106999 <cpunum>
f0106de7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106dee:	00 
f0106def:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106df3:	6b c0 74             	imul   $0x74,%eax,%eax
f0106df6:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0106dfc:	8b 40 60             	mov    0x60(%eax),%eax
f0106dff:	89 04 24             	mov    %eax,(%esp)
f0106e02:	e8 cc a7 ff ff       	call   f01015d3 <pgdir_walk>
	if( !pte || !(*pte & PTE_P)) {
f0106e07:	85 c0                	test   %eax,%eax
f0106e09:	74 06                	je     f0106e11 <va2pa+0x39>
f0106e0b:	8b 00                	mov    (%eax),%eax
f0106e0d:	a8 01                	test   $0x1,%al
f0106e0f:	75 13                	jne    f0106e24 <va2pa+0x4c>
		cprintf("mappign doesn't exist\n");
f0106e11:	c7 04 24 4d 9f 10 f0 	movl   $0xf0109f4d,(%esp)
f0106e18:	e8 6c d4 ff ff       	call   f0104289 <cprintf>
		return -1;
f0106e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106e22:	eb 17                	jmp    f0106e3b <va2pa+0x63>
	}
	*pa_store = ((PGNUM(*pte))<<PTXSHIFT) + (PGOFF(packet));
f0106e24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106e29:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
f0106e2f:	01 d8                	add    %ebx,%eax
f0106e31:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e34:	89 02                	mov    %eax,(%edx)
	return 0;
f0106e36:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106e3b:	83 c4 14             	add    $0x14,%esp
f0106e3e:	5b                   	pop    %ebx
f0106e3f:	5d                   	pop    %ebp
f0106e40:	c3                   	ret    

f0106e41 <e1000_attach>:


int e1000_attach(struct pci_func *pcif) {
f0106e41:	55                   	push   %ebp
f0106e42:	89 e5                	mov    %esp,%ebp
f0106e44:	57                   	push   %edi
f0106e45:	56                   	push   %esi
f0106e46:	53                   	push   %ebx
f0106e47:	83 ec 1c             	sub    $0x1c,%esp
f0106e4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f0106e4d:	89 1c 24             	mov    %ebx,(%esp)
f0106e50:	e8 d2 08 00 00       	call   f0107727 <pci_func_enable>
	base = mmio_map_region((physaddr_t) pcif->reg_base[0], pcif->reg_size[0]);
f0106e55:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0106e58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e5c:	8b 43 14             	mov    0x14(%ebx),%eax
f0106e5f:	89 04 24             	mov    %eax,(%esp)
f0106e62:	e8 d2 a9 ff ff       	call   f0101839 <mmio_map_region>
f0106e67:	a3 00 10 30 f0       	mov    %eax,0xf0301000
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106e6c:	ba 00 20 32 f0       	mov    $0xf0322000,%edx
f0106e71:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106e77:	77 20                	ja     f0106e99 <e1000_attach+0x58>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106e79:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106e7d:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0106e84:	f0 
f0106e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
f0106e8c:	00 
f0106e8d:	c7 04 24 64 9f 10 f0 	movl   $0xf0109f64,(%esp)
f0106e94:	e8 a7 91 ff ff       	call   f0100040 <_panic>

	//print device status just to check

	NMEM(E1000_TDBAL) = PADDR(tx_ring);
f0106e99:	c7 80 00 38 00 00 00 	movl   $0x322000,0x3800(%eax)
f0106ea0:	20 32 00 
	NMEM(E1000_TDLEN) = sizeof(struct tx_desc) * NTD;
f0106ea3:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f0106eaa:	04 00 00 
	NMEM(E1000_TDH)   = 0;
f0106ead:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106eb4:	00 00 00 
	NMEM(E1000_TDT)   = 0;
f0106eb7:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0106ebe:	00 00 00 

	NMEM(E1000_TCTL) |= E1000_TCTL_EN;
f0106ec1:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106ec7:	83 ca 02             	or     $0x2,%edx
f0106eca:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	NMEM(E1000_TCTL) |= E1000_TCTL_PSP;
f0106ed0:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106ed6:	83 ca 08             	or     $0x8,%edx
f0106ed9:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	NMEM(E1000_TCTL) |= E1000_TCTL_CT;
f0106edf:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106ee5:	81 ca f0 0f 00 00    	or     $0xff0,%edx
f0106eeb:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	NMEM(E1000_TCTL) |= E1000_TCTL_COLD;
f0106ef1:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106ef7:	81 ca 00 f0 3f 00    	or     $0x3ff000,%edx
f0106efd:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

	NMEM(E1000_TIPG)  = 0;
f0106f03:	c7 80 10 04 00 00 00 	movl   $0x0,0x410(%eax)
f0106f0a:	00 00 00 
	NMEM(E1000_TIPG) |= 10;
f0106f0d:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106f13:	83 ca 0a             	or     $0xa,%edx
f0106f16:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	NMEM(E1000_TIPG) |= 8  << 10;
f0106f1c:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106f22:	80 ce 20             	or     $0x20,%dh
f0106f25:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	NMEM(E1000_TIPG) |= 12 << 20;
f0106f2b:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0106f31:	81 ca 00 00 c0 00    	or     $0xc00000,%edx
f0106f37:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
f0106f3d:	ba 0c 20 32 f0       	mov    $0xf032200c,%edx
f0106f42:	b9 0c 24 32 f0       	mov    $0xf032240c,%ecx

	for(int i = 0; i < NTD; i++ ) {
		tx_ring[i].status |= E1000_TXD_STAT_DD;
f0106f47:	80 0a 01             	orb    $0x1,(%edx)
f0106f4a:	83 c2 10             	add    $0x10,%edx
	NMEM(E1000_TIPG)  = 0;
	NMEM(E1000_TIPG) |= 10;
	NMEM(E1000_TIPG) |= 8  << 10;
	NMEM(E1000_TIPG) |= 12 << 20;

	for(int i = 0; i < NTD; i++ ) {
f0106f4d:	39 ca                	cmp    %ecx,%edx
f0106f4f:	75 f6                	jne    f0106f47 <e1000_attach+0x106>
		tx_ring[i].status |= E1000_TXD_STAT_DD;
	}

	NMEM(E1000_RAL)  = 0x52 + (0x54 << 8) + (0x12 << 24);
f0106f51:	c7 80 00 54 00 00 52 	movl   $0x12005452,0x5400(%eax)
f0106f58:	54 00 12 
	NMEM(E1000_RAH)  = 0x34 + (0x56 << 8);
f0106f5b:	c7 80 04 54 00 00 34 	movl   $0x5634,0x5404(%eax)
f0106f62:	56 00 00 
	NMEM(E1000_RAH) |= (0x1 << 31);
f0106f65:	8b 90 04 54 00 00    	mov    0x5404(%eax),%edx
f0106f6b:	81 ca 00 00 00 80    	or     $0x80000000,%edx
f0106f71:	89 90 04 54 00 00    	mov    %edx,0x5404(%eax)
f0106f77:	b8 00 52 00 00       	mov    $0x5200,%eax

	for(int i = 0; i < 127; i++) {
		NMEM((E1000_MTA + (i*4))) = 0;
f0106f7c:	89 c2                	mov    %eax,%edx
f0106f7e:	83 e2 fc             	and    $0xfffffffc,%edx
f0106f81:	03 15 00 10 30 f0    	add    0xf0301000,%edx
f0106f87:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0106f8d:	83 c0 04             	add    $0x4,%eax

	NMEM(E1000_RAL)  = 0x52 + (0x54 << 8) + (0x12 << 24);
	NMEM(E1000_RAH)  = 0x34 + (0x56 << 8);
	NMEM(E1000_RAH) |= (0x1 << 31);

	for(int i = 0; i < 127; i++) {
f0106f90:	3d fc 53 00 00       	cmp    $0x53fc,%eax
f0106f95:	75 e5                	jne    f0106f7c <e1000_attach+0x13b>
		NMEM((E1000_MTA + (i*4))) = 0;
	}

	NMEM(E1000_IMS) = 0; //add interrupts later
f0106f97:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f0106f9c:	c7 80 d0 00 00 00 00 	movl   $0x0,0xd0(%eax)
f0106fa3:	00 00 00 
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106fa6:	ba 00 30 32 f0       	mov    $0xf0323000,%edx
f0106fab:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106fb1:	77 20                	ja     f0106fd3 <e1000_attach+0x192>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106fb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106fb7:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0106fbe:	f0 
f0106fbf:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f0106fc6:	00 
f0106fc7:	c7 04 24 64 9f 10 f0 	movl   $0xf0109f64,(%esp)
f0106fce:	e8 6d 90 ff ff       	call   f0100040 <_panic>

	NMEM(E1000_RDBAL) = PADDR(rx_ring);
f0106fd3:	c7 80 00 28 00 00 00 	movl   $0x323000,0x2800(%eax)
f0106fda:	30 32 00 
	NMEM(E1000_RDLEN) = sizeof(struct rx_desc) * NRD;
f0106fdd:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f0106fe4:	08 00 00 
	NMEM(E1000_RDH)   = 0;
f0106fe7:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106fee:	00 00 00 
	NMEM(E1000_RDT)   = NRD - 1;
f0106ff1:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f0106ff8:	00 00 00 
f0106ffb:	bb 00 40 32 f0       	mov    $0xf0324000,%ebx
f0107000:	bf 00 40 36 f0       	mov    $0xf0364000,%edi
f0107005:	be 00 30 32 f0       	mov    $0xf0323000,%esi

	for(int i = 0; i < NRD; i++ ) {
		memset(&rx_ring[i], 0, sizeof(struct rx_desc));
f010700a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107011:	00 
f0107012:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107019:	00 
f010701a:	89 34 24             	mov    %esi,(%esp)
f010701d:	e8 25 f3 ff ff       	call   f0106347 <memset>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0107022:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0107028:	77 20                	ja     f010704a <e1000_attach+0x209>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010702a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010702e:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0107035:	f0 
f0107036:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
f010703d:	00 
f010703e:	c7 04 24 64 9f 10 f0 	movl   $0xf0109f64,(%esp)
f0107045:	e8 f6 8f ff ff       	call   f0100040 <_panic>
f010704a:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
		rx_ring[i].buffer_addr = PADDR(&rx_bufs[i]);
f0107050:	89 06                	mov    %eax,(%esi)
f0107052:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
f0107059:	81 c3 00 08 00 00    	add    $0x800,%ebx
f010705f:	83 c6 10             	add    $0x10,%esi
	NMEM(E1000_RDBAL) = PADDR(rx_ring);
	NMEM(E1000_RDLEN) = sizeof(struct rx_desc) * NRD;
	NMEM(E1000_RDH)   = 0;
	NMEM(E1000_RDT)   = NRD - 1;

	for(int i = 0; i < NRD; i++ ) {
f0107062:	39 fb                	cmp    %edi,%ebx
f0107064:	75 a4                	jne    f010700a <e1000_attach+0x1c9>
		memset(&rx_ring[i], 0, sizeof(struct rx_desc));
		rx_ring[i].buffer_addr = PADDR(&rx_bufs[i]);
	}

	NMEM(E1000_RCTL) &= ~E1000_RCTL_LPE;
f0107066:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f010706b:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0107071:	83 e2 df             	and    $0xffffffdf,%edx
f0107074:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	NMEM(E1000_RCTL) |= E1000_RCTL_LBM_NO;
f010707a:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0107080:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	NMEM(E1000_RCTL) |= E1000_RCTL_SECRC;
f0107086:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f010708c:	81 ca 00 00 00 04    	or     $0x4000000,%edx
f0107092:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	NMEM(E1000_RCTL) |= E1000_RCTL_SZ_2048;
f0107098:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f010709e:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)

	NMEM(E1000_RCTL) |= E1000_RCTL_EN; // enable at the end
f01070a4:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f01070aa:	83 ca 02             	or     $0x2,%edx
f01070ad:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)

	return 0;
}
f01070b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01070b8:	83 c4 1c             	add    $0x1c,%esp
f01070bb:	5b                   	pop    %ebx
f01070bc:	5e                   	pop    %esi
f01070bd:	5f                   	pop    %edi
f01070be:	5d                   	pop    %ebp
f01070bf:	c3                   	ret    

f01070c0 <e1000_transmit>:

int e1000_transmit(void* packet, int size) {
f01070c0:	55                   	push   %ebp
f01070c1:	89 e5                	mov    %esp,%ebp
f01070c3:	57                   	push   %edi
f01070c4:	56                   	push   %esi
f01070c5:	53                   	push   %ebx
f01070c6:	83 ec 2c             	sub    $0x2c,%esp
	int next = NMEM(E1000_TDT);
f01070c9:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f01070ce:	8b b0 18 38 00 00    	mov    0x3818(%eax),%esi

	if(!(tx_ring[next].status & E1000_TXD_STAT_DD)) {
f01070d4:	89 f0                	mov    %esi,%eax
f01070d6:	c1 e0 04             	shl    $0x4,%eax
f01070d9:	f6 80 0c 20 32 f0 01 	testb  $0x1,-0xfcddff4(%eax)
f01070e0:	0f 84 8d 00 00 00    	je     f0107173 <e1000_transmit+0xb3>
		// just drop for now
		return -1;
	}

	uint32_t pa;
	if(va2pa(packet, &pa) < 0) {
f01070e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01070e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01070f0:	89 04 24             	mov    %eax,(%esp)
f01070f3:	e8 e0 fc ff ff       	call   f0106dd8 <va2pa>
f01070f8:	85 c0                	test   %eax,%eax
f01070fa:	78 7e                	js     f010717a <e1000_transmit+0xba>
		return -1;
	}
	
	memset(&tx_ring[next], 0, sizeof(struct tx_desc));
f01070fc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107103:	00 
f0107104:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010710b:	00 
f010710c:	89 f7                	mov    %esi,%edi
f010710e:	c1 e7 04             	shl    $0x4,%edi
f0107111:	8d 9f 00 20 32 f0    	lea    -0xfcde000(%edi),%ebx
f0107117:	89 1c 24             	mov    %ebx,(%esp)
f010711a:	e8 28 f2 ff ff       	call   f0106347 <memset>
	tx_ring[next].addr   = pa;
f010711f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107122:	89 87 00 20 32 f0    	mov    %eax,-0xfcde000(%edi)
f0107128:	c7 87 04 20 32 f0 00 	movl   $0x0,-0xfcddffc(%edi)
f010712f:	00 00 00 
	tx_ring[next].length = size;
f0107132:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107135:	66 89 87 08 20 32 f0 	mov    %ax,-0xfcddff8(%edi)
	tx_ring[next].cmd   |= E1000_TXD_CMD_RS;
	tx_ring[next].cmd   |= E1000_TXD_CMD_EOP;
	tx_ring[next].cmd   &= ~E1000_TXD_CMD_DEXT;
f010713c:	0f b6 87 0b 20 32 f0 	movzbl -0xfcddff5(%edi),%eax
f0107143:	83 e0 df             	and    $0xffffffdf,%eax
f0107146:	83 c8 09             	or     $0x9,%eax
f0107149:	88 87 0b 20 32 f0    	mov    %al,-0xfcddff5(%edi)

	NMEM(E1000_TDT) = (next + 1) % NTD;
f010714f:	83 c6 01             	add    $0x1,%esi
f0107152:	89 f0                	mov    %esi,%eax
f0107154:	c1 f8 1f             	sar    $0x1f,%eax
f0107157:	c1 e8 1a             	shr    $0x1a,%eax
f010715a:	01 c6                	add    %eax,%esi
f010715c:	83 e6 3f             	and    $0x3f,%esi
f010715f:	29 c6                	sub    %eax,%esi
f0107161:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f0107166:	89 b0 18 38 00 00    	mov    %esi,0x3818(%eax)
	return 0;
f010716c:	b8 00 00 00 00       	mov    $0x0,%eax
f0107171:	eb 0c                	jmp    f010717f <e1000_transmit+0xbf>
	int next = NMEM(E1000_TDT);

	if(!(tx_ring[next].status & E1000_TXD_STAT_DD)) {
		// cannot send more packets rn
		// just drop for now
		return -1;
f0107173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107178:	eb 05                	jmp    f010717f <e1000_transmit+0xbf>
	}

	uint32_t pa;
	if(va2pa(packet, &pa) < 0) {
		return -1;
f010717a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	tx_ring[next].cmd   |= E1000_TXD_CMD_EOP;
	tx_ring[next].cmd   &= ~E1000_TXD_CMD_DEXT;

	NMEM(E1000_TDT) = (next + 1) % NTD;
	return 0;
}
f010717f:	83 c4 2c             	add    $0x2c,%esp
f0107182:	5b                   	pop    %ebx
f0107183:	5e                   	pop    %esi
f0107184:	5f                   	pop    %edi
f0107185:	5d                   	pop    %ebp
f0107186:	c3                   	ret    

f0107187 <e1000_receive>:

int e1000_receive(void** packet_dst, int *size_store) {
f0107187:	55                   	push   %ebp
f0107188:	89 e5                	mov    %esp,%ebp
f010718a:	57                   	push   %edi
f010718b:	56                   	push   %esi
f010718c:	53                   	push   %ebx
f010718d:	83 ec 2c             	sub    $0x2c,%esp
f0107190:	8b 7d 08             	mov    0x8(%ebp),%edi
	int next = (NMEM(E1000_RDT) + 1) % NRD; 
f0107193:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f0107198:	8b 98 18 28 00 00    	mov    0x2818(%eax),%ebx
f010719e:	83 c3 01             	add    $0x1,%ebx
f01071a1:	83 e3 7f             	and    $0x7f,%ebx

	//cprintf("TRYING PACKET AT %d\n", next);
	if(!(rx_ring[next].status & E1000_RXD_STAT_DD)) {
f01071a4:	89 d8                	mov    %ebx,%eax
f01071a6:	c1 e0 04             	shl    $0x4,%eax
f01071a9:	f6 80 0c 30 32 f0 01 	testb  $0x1,-0xfcdcff4(%eax)
f01071b0:	0f 84 f2 00 00 00    	je     f01072a8 <e1000_receive+0x121>
		// cannot receive more packets rn
		return -1;
	}

	struct PageInfo* pp = page_lookup(kern_pgdir, &rx_bufs[next], 0);
f01071b6:	89 de                	mov    %ebx,%esi
f01071b8:	c1 e6 0b             	shl    $0xb,%esi
f01071bb:	81 c6 00 40 32 f0    	add    $0xf0324000,%esi
f01071c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01071c8:	00 
f01071c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01071cd:	a1 98 de 2b f0       	mov    0xf02bde98,%eax
f01071d2:	89 04 24             	mov    %eax,(%esp)
f01071d5:	e8 f9 a4 ff ff       	call   f01016d3 <page_lookup>
f01071da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	page_insert(curenv->env_pgdir, pp, *packet_dst, PTE_U|PTE_W|PTE_P);
f01071dd:	8b 0f                	mov    (%edi),%ecx
f01071df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01071e2:	e8 b2 f7 ff ff       	call   f0106999 <cpunum>
f01071e7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01071ee:	00 
f01071ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01071f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01071f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01071f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01071fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0107200:	8b 80 28 f0 2b f0    	mov    -0xfd40fd8(%eax),%eax
f0107206:	8b 40 60             	mov    0x60(%eax),%eax
f0107209:	89 04 24             	mov    %eax,(%esp)
f010720c:	e8 b9 a5 ff ff       	call   f01017ca <page_insert>
	*packet_dst = (*packet_dst) - (PGOFF(*packet_dst)) + (PGOFF(&rx_bufs[next]));
f0107211:	89 f0                	mov    %esi,%eax
f0107213:	25 ff 0f 00 00       	and    $0xfff,%eax
f0107218:	8b 17                	mov    (%edi),%edx
f010721a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0107220:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0107223:	89 07                	mov    %eax,(%edi)

	*size_store = rx_ring[next].length;
f0107225:	89 d8                	mov    %ebx,%eax
f0107227:	c1 e0 04             	shl    $0x4,%eax
f010722a:	0f b7 88 08 30 32 f0 	movzwl -0xfcdcff8(%eax),%ecx
f0107231:	05 00 30 32 f0       	add    $0xf0323000,%eax
f0107236:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107239:	89 0a                	mov    %ecx,(%edx)
	memset(&rx_ring[next], 0, sizeof(struct rx_desc));
f010723b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107242:	00 
f0107243:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010724a:	00 
f010724b:	89 04 24             	mov    %eax,(%esp)
f010724e:	e8 f4 f0 ff ff       	call   f0106347 <memset>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0107253:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0107259:	77 20                	ja     f010727b <e1000_receive+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010725b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010725f:	c7 44 24 08 e8 7b 10 	movl   $0xf0107be8,0x8(%esp)
f0107266:	f0 
f0107267:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f010726e:	00 
f010726f:	c7 04 24 64 9f 10 f0 	movl   $0xf0109f64,(%esp)
f0107276:	e8 c5 8d ff ff       	call   f0100040 <_panic>
	rx_ring[next].buffer_addr = PADDR(&rx_bufs[next]);
f010727b:	89 d8                	mov    %ebx,%eax
f010727d:	c1 e0 04             	shl    $0x4,%eax
	return (physaddr_t)kva - KERNBASE;
f0107280:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0107286:	89 b0 00 30 32 f0    	mov    %esi,-0xfcdd000(%eax)
f010728c:	c7 80 04 30 32 f0 00 	movl   $0x0,-0xfcdcffc(%eax)
f0107293:	00 00 00 

	NMEM(E1000_RDT) = next;
f0107296:	a1 00 10 30 f0       	mov    0xf0301000,%eax
f010729b:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
	return 0;
f01072a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01072a6:	eb 05                	jmp    f01072ad <e1000_receive+0x126>
	int next = (NMEM(E1000_RDT) + 1) % NRD; 

	//cprintf("TRYING PACKET AT %d\n", next);
	if(!(rx_ring[next].status & E1000_RXD_STAT_DD)) {
		// cannot receive more packets rn
		return -1;
f01072a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	memset(&rx_ring[next], 0, sizeof(struct rx_desc));
	rx_ring[next].buffer_addr = PADDR(&rx_bufs[next]);

	NMEM(E1000_RDT) = next;
	return 0;
}
f01072ad:	83 c4 2c             	add    $0x2c,%esp
f01072b0:	5b                   	pop    %ebx
f01072b1:	5e                   	pop    %esi
f01072b2:	5f                   	pop    %edi
f01072b3:	5d                   	pop    %ebp
f01072b4:	c3                   	ret    

f01072b5 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f01072b5:	55                   	push   %ebp
f01072b6:	89 e5                	mov    %esp,%ebp
f01072b8:	57                   	push   %edi
f01072b9:	56                   	push   %esi
f01072ba:	53                   	push   %ebx
f01072bb:	83 ec 2c             	sub    $0x2c,%esp
f01072be:	8b 7d 08             	mov    0x8(%ebp),%edi
f01072c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01072c4:	eb 41                	jmp    f0107307 <pci_attach_match+0x52>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f01072c6:	39 3b                	cmp    %edi,(%ebx)
f01072c8:	75 3a                	jne    f0107304 <pci_attach_match+0x4f>
f01072ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01072cd:	39 56 04             	cmp    %edx,0x4(%esi)
f01072d0:	75 32                	jne    f0107304 <pci_attach_match+0x4f>
			int r = list[i].attachfn(pcif);
f01072d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01072d5:	89 0c 24             	mov    %ecx,(%esp)
f01072d8:	ff d0                	call   *%eax
			if (r > 0)
f01072da:	85 c0                	test   %eax,%eax
f01072dc:	7f 32                	jg     f0107310 <pci_attach_match+0x5b>
				return r;
			if (r < 0)
f01072de:	85 c0                	test   %eax,%eax
f01072e0:	79 22                	jns    f0107304 <pci_attach_match+0x4f>
				cprintf("pci_attach_match: attaching "
f01072e2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01072e6:	8b 46 08             	mov    0x8(%esi),%eax
f01072e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01072ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01072f0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01072f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01072f8:	c7 04 24 74 9f 10 f0 	movl   $0xf0109f74,(%esp)
f01072ff:	e8 85 cf ff ff       	call   f0104289 <cprintf>
f0107304:	83 c3 0c             	add    $0xc,%ebx
f0107307:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0107309:	8b 43 08             	mov    0x8(%ebx),%eax
f010730c:	85 c0                	test   %eax,%eax
f010730e:	75 b6                	jne    f01072c6 <pci_attach_match+0x11>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0107310:	83 c4 2c             	add    $0x2c,%esp
f0107313:	5b                   	pop    %ebx
f0107314:	5e                   	pop    %esi
f0107315:	5f                   	pop    %edi
f0107316:	5d                   	pop    %ebp
f0107317:	c3                   	ret    

f0107318 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0107318:	55                   	push   %ebp
f0107319:	89 e5                	mov    %esp,%ebp
f010731b:	56                   	push   %esi
f010731c:	53                   	push   %ebx
f010731d:	83 ec 10             	sub    $0x10,%esp
f0107320:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0107323:	3d ff 00 00 00       	cmp    $0xff,%eax
f0107328:	76 24                	jbe    f010734e <pci_conf1_set_addr+0x36>
f010732a:	c7 44 24 0c cc a0 10 	movl   $0xf010a0cc,0xc(%esp)
f0107331:	f0 
f0107332:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0107339:	f0 
f010733a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f0107341:	00 
f0107342:	c7 04 24 d6 a0 10 f0 	movl   $0xf010a0d6,(%esp)
f0107349:	e8 f2 8c ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f010734e:	83 fa 1f             	cmp    $0x1f,%edx
f0107351:	76 24                	jbe    f0107377 <pci_conf1_set_addr+0x5f>
f0107353:	c7 44 24 0c e1 a0 10 	movl   $0xf010a0e1,0xc(%esp)
f010735a:	f0 
f010735b:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f0107362:	f0 
f0107363:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f010736a:	00 
f010736b:	c7 04 24 d6 a0 10 f0 	movl   $0xf010a0d6,(%esp)
f0107372:	e8 c9 8c ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0107377:	83 f9 07             	cmp    $0x7,%ecx
f010737a:	76 24                	jbe    f01073a0 <pci_conf1_set_addr+0x88>
f010737c:	c7 44 24 0c ea a0 10 	movl   $0xf010a0ea,0xc(%esp)
f0107383:	f0 
f0107384:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f010738b:	f0 
f010738c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f0107393:	00 
f0107394:	c7 04 24 d6 a0 10 f0 	movl   $0xf010a0d6,(%esp)
f010739b:	e8 a0 8c ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f01073a0:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f01073a6:	76 24                	jbe    f01073cc <pci_conf1_set_addr+0xb4>
f01073a8:	c7 44 24 0c f3 a0 10 	movl   $0xf010a0f3,0xc(%esp)
f01073af:	f0 
f01073b0:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01073b7:	f0 
f01073b8:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f01073bf:	00 
f01073c0:	c7 04 24 d6 a0 10 f0 	movl   $0xf010a0d6,(%esp)
f01073c7:	e8 74 8c ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01073cc:	f6 c3 03             	test   $0x3,%bl
f01073cf:	74 24                	je     f01073f5 <pci_conf1_set_addr+0xdd>
f01073d1:	c7 44 24 0c 00 a1 10 	movl   $0xf010a100,0xc(%esp)
f01073d8:	f0 
f01073d9:	c7 44 24 08 73 8d 10 	movl   $0xf0108d73,0x8(%esp)
f01073e0:	f0 
f01073e1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f01073e8:	00 
f01073e9:	c7 04 24 d6 a0 10 f0 	movl   $0xf010a0d6,(%esp)
f01073f0:	e8 4b 8c ff ff       	call   f0100040 <_panic>

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f01073f5:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f01073fb:	c1 e1 08             	shl    $0x8,%ecx
f01073fe:	09 cb                	or     %ecx,%ebx
f0107400:	89 d6                	mov    %edx,%esi
f0107402:	c1 e6 0b             	shl    $0xb,%esi
f0107405:	09 f3                	or     %esi,%ebx
f0107407:	c1 e0 10             	shl    $0x10,%eax
f010740a:	89 c6                	mov    %eax,%esi
	assert(dev < 32);
	assert(func < 8);
	assert(offset < 256);
	assert((offset & 0x3) == 0);

	uint32_t v = (1 << 31) |		// config-space
f010740c:	89 d8                	mov    %ebx,%eax
f010740e:	09 f0                	or     %esi,%eax
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0107410:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0107415:	ef                   	out    %eax,(%dx)
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0107416:	83 c4 10             	add    $0x10,%esp
f0107419:	5b                   	pop    %ebx
f010741a:	5e                   	pop    %esi
f010741b:	5d                   	pop    %ebp
f010741c:	c3                   	ret    

f010741d <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f010741d:	55                   	push   %ebp
f010741e:	89 e5                	mov    %esp,%ebp
f0107420:	53                   	push   %ebx
f0107421:	83 ec 14             	sub    $0x14,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0107424:	8b 48 08             	mov    0x8(%eax),%ecx
f0107427:	8b 58 04             	mov    0x4(%eax),%ebx
f010742a:	8b 00                	mov    (%eax),%eax
f010742c:	8b 40 04             	mov    0x4(%eax),%eax
f010742f:	89 14 24             	mov    %edx,(%esp)
f0107432:	89 da                	mov    %ebx,%edx
f0107434:	e8 df fe ff ff       	call   f0107318 <pci_conf1_set_addr>

static inline uint32_t
inl(int port)
{
	uint32_t data;
	asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0107439:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010743e:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f010743f:	83 c4 14             	add    $0x14,%esp
f0107442:	5b                   	pop    %ebx
f0107443:	5d                   	pop    %ebp
f0107444:	c3                   	ret    

f0107445 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0107445:	55                   	push   %ebp
f0107446:	89 e5                	mov    %esp,%ebp
f0107448:	57                   	push   %edi
f0107449:	56                   	push   %esi
f010744a:	53                   	push   %ebx
f010744b:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
f0107451:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0107453:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f010745a:	00 
f010745b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107462:	00 
f0107463:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107466:	89 04 24             	mov    %eax,(%esp)
f0107469:	e8 d9 ee ff ff       	call   f0106347 <memset>
	df.bus = bus;
f010746e:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0107471:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f0107478:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f010747f:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0107482:	ba 0c 00 00 00       	mov    $0xc,%edx
f0107487:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010748a:	e8 8e ff ff ff       	call   f010741d <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f010748f:	89 c2                	mov    %eax,%edx
f0107491:	c1 ea 10             	shr    $0x10,%edx
f0107494:	83 e2 7f             	and    $0x7f,%edx
f0107497:	83 fa 01             	cmp    $0x1,%edx
f010749a:	0f 87 6f 01 00 00    	ja     f010760f <pci_scan_bus+0x1ca>
			continue;

		totaldev++;
f01074a0:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f01074a7:	b9 12 00 00 00       	mov    $0x12,%ecx
f01074ac:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f01074b2:	8d 75 a0             	lea    -0x60(%ebp),%esi
f01074b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01074b7:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f01074be:	00 00 00 
f01074c1:	25 00 00 80 00       	and    $0x800000,%eax
f01074c6:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
		     f.func++) {
			struct pci_func af = f;
f01074cc:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01074d2:	e9 1d 01 00 00       	jmp    f01075f4 <pci_scan_bus+0x1af>
		     f.func++) {
			struct pci_func af = f;
f01074d7:	b9 12 00 00 00       	mov    $0x12,%ecx
f01074dc:	89 df                	mov    %ebx,%edi
f01074de:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01074e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01074e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01074eb:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01074f1:	e8 27 ff ff ff       	call   f010741d <pci_conf_read>
f01074f6:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f01074fc:	66 83 f8 ff          	cmp    $0xffff,%ax
f0107500:	0f 84 e7 00 00 00    	je     f01075ed <pci_scan_bus+0x1a8>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0107506:	ba 3c 00 00 00       	mov    $0x3c,%edx
f010750b:	89 d8                	mov    %ebx,%eax
f010750d:	e8 0b ff ff ff       	call   f010741d <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0107512:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0107515:	ba 08 00 00 00       	mov    $0x8,%edx
f010751a:	89 d8                	mov    %ebx,%eax
f010751c:	e8 fc fe ff ff       	call   f010741d <pci_conf_read>
f0107521:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0107527:	89 c2                	mov    %eax,%edx
f0107529:	c1 ea 18             	shr    $0x18,%edx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f010752c:	b9 14 a1 10 f0       	mov    $0xf010a114,%ecx
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
f0107531:	83 fa 06             	cmp    $0x6,%edx
f0107534:	77 07                	ja     f010753d <pci_scan_bus+0xf8>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0107536:	8b 0c 95 88 a1 10 f0 	mov    -0xfef5e78(,%edx,4),%ecx

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f010753d:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0107543:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0107547:	89 7c 24 24          	mov    %edi,0x24(%esp)
f010754b:	89 4c 24 20          	mov    %ecx,0x20(%esp)
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f010754f:	c1 e8 10             	shr    $0x10,%eax
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < ARRAY_SIZE(pci_class))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0107552:	0f b6 c0             	movzbl %al,%eax
f0107555:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0107559:	89 54 24 18          	mov    %edx,0x18(%esp)
f010755d:	89 f0                	mov    %esi,%eax
f010755f:	c1 e8 10             	shr    $0x10,%eax
f0107562:	89 44 24 14          	mov    %eax,0x14(%esp)
f0107566:	0f b7 f6             	movzwl %si,%esi
f0107569:	89 74 24 10          	mov    %esi,0x10(%esp)
f010756d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f0107573:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107577:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f010757d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107581:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0107587:	8b 40 04             	mov    0x4(%eax),%eax
f010758a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010758e:	c7 04 24 a0 9f 10 f0 	movl   $0xf0109fa0,(%esp)
f0107595:	e8 ef cc ff ff       	call   f0104289 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f010759a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f01075a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01075a4:	c7 44 24 08 0c 54 12 	movl   $0xf012540c,0x8(%esp)
f01075ab:	f0 
				 PCI_SUBCLASS(f->dev_class),
f01075ac:	89 c2                	mov    %eax,%edx
f01075ae:	c1 ea 10             	shr    $0x10,%edx

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f01075b1:	0f b6 d2             	movzbl %dl,%edx
f01075b4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01075b8:	c1 e8 18             	shr    $0x18,%eax
f01075bb:	89 04 24             	mov    %eax,(%esp)
f01075be:	e8 f2 fc ff ff       	call   f01072b5 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f01075c3:	85 c0                	test   %eax,%eax
f01075c5:	75 26                	jne    f01075ed <pci_scan_bus+0x1a8>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f01075c7:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f01075cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01075d1:	c7 44 24 08 f4 53 12 	movl   $0xf01253f4,0x8(%esp)
f01075d8:	f0 
f01075d9:	89 c2                	mov    %eax,%edx
f01075db:	c1 ea 10             	shr    $0x10,%edx
f01075de:	89 54 24 04          	mov    %edx,0x4(%esp)
f01075e2:	0f b7 c0             	movzwl %ax,%eax
f01075e5:	89 04 24             	mov    %eax,(%esp)
f01075e8:	e8 c8 fc ff ff       	call   f01072b5 <pci_attach_match>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01075ed:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01075f4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
f01075fb:	19 c0                	sbb    %eax,%eax
f01075fd:	83 e0 f9             	and    $0xfffffff9,%eax
f0107600:	83 c0 08             	add    $0x8,%eax
f0107603:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0107609:	0f 87 c8 fe ff ff    	ja     f01074d7 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010760f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0107612:	83 c0 01             	add    $0x1,%eax
f0107615:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0107618:	83 f8 1f             	cmp    $0x1f,%eax
f010761b:	0f 86 61 fe ff ff    	jbe    f0107482 <pci_scan_bus+0x3d>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0107621:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0107627:	81 c4 1c 01 00 00    	add    $0x11c,%esp
f010762d:	5b                   	pop    %ebx
f010762e:	5e                   	pop    %esi
f010762f:	5f                   	pop    %edi
f0107630:	5d                   	pop    %ebp
f0107631:	c3                   	ret    

f0107632 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0107632:	55                   	push   %ebp
f0107633:	89 e5                	mov    %esp,%ebp
f0107635:	57                   	push   %edi
f0107636:	56                   	push   %esi
f0107637:	53                   	push   %ebx
f0107638:	83 ec 3c             	sub    $0x3c,%esp
f010763b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f010763e:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0107643:	89 d8                	mov    %ebx,%eax
f0107645:	e8 d3 fd ff ff       	call   f010741d <pci_conf_read>
f010764a:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f010764c:	ba 18 00 00 00       	mov    $0x18,%edx
f0107651:	89 d8                	mov    %ebx,%eax
f0107653:	e8 c5 fd ff ff       	call   f010741d <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0107658:	83 e7 0f             	and    $0xf,%edi
f010765b:	83 ff 01             	cmp    $0x1,%edi
f010765e:	75 2a                	jne    f010768a <pci_bridge_attach+0x58>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f0107660:	8b 43 08             	mov    0x8(%ebx),%eax
f0107663:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107667:	8b 43 04             	mov    0x4(%ebx),%eax
f010766a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010766e:	8b 03                	mov    (%ebx),%eax
f0107670:	8b 40 04             	mov    0x4(%eax),%eax
f0107673:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107677:	c7 04 24 dc 9f 10 f0 	movl   $0xf0109fdc,(%esp)
f010767e:	e8 06 cc ff ff       	call   f0104289 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0107683:	b8 00 00 00 00       	mov    $0x0,%eax
f0107688:	eb 67                	jmp    f01076f1 <pci_bridge_attach+0xbf>
f010768a:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f010768c:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107693:	00 
f0107694:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010769b:	00 
f010769c:	8d 7d e0             	lea    -0x20(%ebp),%edi
f010769f:	89 3c 24             	mov    %edi,(%esp)
f01076a2:	e8 a0 ec ff ff       	call   f0106347 <memset>
	nbus.parent_bridge = pcif;
f01076a7:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f01076aa:	89 f0                	mov    %esi,%eax
f01076ac:	0f b6 c4             	movzbl %ah,%eax
f01076af:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f01076b2:	89 f2                	mov    %esi,%edx
f01076b4:	c1 ea 10             	shr    $0x10,%edx
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01076b7:	0f b6 f2             	movzbl %dl,%esi
f01076ba:	89 74 24 14          	mov    %esi,0x14(%esp)
f01076be:	89 44 24 10          	mov    %eax,0x10(%esp)
f01076c2:	8b 43 08             	mov    0x8(%ebx),%eax
f01076c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01076c9:	8b 43 04             	mov    0x4(%ebx),%eax
f01076cc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01076d0:	8b 03                	mov    (%ebx),%eax
f01076d2:	8b 40 04             	mov    0x4(%eax),%eax
f01076d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01076d9:	c7 04 24 10 a0 10 f0 	movl   $0xf010a010,(%esp)
f01076e0:	e8 a4 cb ff ff       	call   f0104289 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f01076e5:	89 f8                	mov    %edi,%eax
f01076e7:	e8 59 fd ff ff       	call   f0107445 <pci_scan_bus>
	return 1;
f01076ec:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01076f1:	83 c4 3c             	add    $0x3c,%esp
f01076f4:	5b                   	pop    %ebx
f01076f5:	5e                   	pop    %esi
f01076f6:	5f                   	pop    %edi
f01076f7:	5d                   	pop    %ebp
f01076f8:	c3                   	ret    

f01076f9 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f01076f9:	55                   	push   %ebp
f01076fa:	89 e5                	mov    %esp,%ebp
f01076fc:	56                   	push   %esi
f01076fd:	53                   	push   %ebx
f01076fe:	83 ec 10             	sub    $0x10,%esp
f0107701:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0107703:	8b 48 08             	mov    0x8(%eax),%ecx
f0107706:	8b 70 04             	mov    0x4(%eax),%esi
f0107709:	8b 00                	mov    (%eax),%eax
f010770b:	8b 40 04             	mov    0x4(%eax),%eax
f010770e:	89 14 24             	mov    %edx,(%esp)
f0107711:	89 f2                	mov    %esi,%edx
f0107713:	e8 00 fc ff ff       	call   f0107318 <pci_conf1_set_addr>
}

static inline void
outl(int port, uint32_t data)
{
	asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0107718:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010771d:	89 d8                	mov    %ebx,%eax
f010771f:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0107720:	83 c4 10             	add    $0x10,%esp
f0107723:	5b                   	pop    %ebx
f0107724:	5e                   	pop    %esi
f0107725:	5d                   	pop    %ebp
f0107726:	c3                   	ret    

f0107727 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0107727:	55                   	push   %ebp
f0107728:	89 e5                	mov    %esp,%ebp
f010772a:	57                   	push   %edi
f010772b:	56                   	push   %esi
f010772c:	53                   	push   %ebx
f010772d:	83 ec 4c             	sub    $0x4c,%esp
f0107730:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0107733:	b9 07 00 00 00       	mov    $0x7,%ecx
f0107738:	ba 04 00 00 00       	mov    $0x4,%edx
f010773d:	89 f8                	mov    %edi,%eax
f010773f:	e8 b5 ff ff ff       	call   f01076f9 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0107744:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0107749:	89 f2                	mov    %esi,%edx
f010774b:	89 f8                	mov    %edi,%eax
f010774d:	e8 cb fc ff ff       	call   f010741d <pci_conf_read>
f0107752:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0107755:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f010775a:	89 f2                	mov    %esi,%edx
f010775c:	89 f8                	mov    %edi,%eax
f010775e:	e8 96 ff ff ff       	call   f01076f9 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0107763:	89 f2                	mov    %esi,%edx
f0107765:	89 f8                	mov    %edi,%eax
f0107767:	e8 b1 fc ff ff       	call   f010741d <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f010776c:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0107771:	85 c0                	test   %eax,%eax
f0107773:	0f 84 c1 00 00 00    	je     f010783a <pci_func_enable+0x113>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0107779:	8d 56 f0             	lea    -0x10(%esi),%edx
f010777c:	c1 ea 02             	shr    $0x2,%edx
f010777f:	89 55 dc             	mov    %edx,-0x24(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0107782:	a8 01                	test   $0x1,%al
f0107784:	75 2c                	jne    f01077b2 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0107786:	89 c2                	mov    %eax,%edx
f0107788:	83 e2 06             	and    $0x6,%edx
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f010778b:	83 fa 04             	cmp    $0x4,%edx
f010778e:	0f 94 c3             	sete   %bl
f0107791:	0f b6 db             	movzbl %bl,%ebx
f0107794:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
				bar_width = 8;

			size = PCI_MAPREG_MEM_SIZE(rv);
f010779b:	83 e0 f0             	and    $0xfffffff0,%eax
f010779e:	89 c2                	mov    %eax,%edx
f01077a0:	f7 da                	neg    %edx
f01077a2:	21 d0                	and    %edx,%eax
f01077a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01077a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01077aa:	83 e0 f0             	and    $0xfffffff0,%eax
f01077ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01077b0:	eb 1a                	jmp    f01077cc <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f01077b2:	83 e0 fc             	and    $0xfffffffc,%eax
f01077b5:	89 c2                	mov    %eax,%edx
f01077b7:	f7 da                	neg    %edx
f01077b9:	21 d0                	and    %edx,%eax
f01077bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f01077be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01077c1:	83 e0 fc             	and    $0xfffffffc,%eax
f01077c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01077c7:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01077cc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01077cf:	89 f2                	mov    %esi,%edx
f01077d1:	89 f8                	mov    %edi,%eax
f01077d3:	e8 21 ff ff ff       	call   f01076f9 <pci_conf_write>
f01077d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01077db:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f01077de:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01077e1:	89 48 14             	mov    %ecx,0x14(%eax)
		f->reg_size[regnum] = size;
f01077e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01077e7:	89 50 2c             	mov    %edx,0x2c(%eax)

		if (size && !base)
f01077ea:	85 c9                	test   %ecx,%ecx
f01077ec:	75 4c                	jne    f010783a <pci_func_enable+0x113>
f01077ee:	85 d2                	test   %edx,%edx
f01077f0:	74 48                	je     f010783a <pci_func_enable+0x113>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01077f2:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01077f5:	89 54 24 20          	mov    %edx,0x20(%esp)
f01077f9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01077fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0107800:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0107803:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0107807:	89 c2                	mov    %eax,%edx
f0107809:	c1 ea 10             	shr    $0x10,%edx
f010780c:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107810:	0f b7 c0             	movzwl %ax,%eax
f0107813:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107817:	8b 47 08             	mov    0x8(%edi),%eax
f010781a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010781e:	8b 47 04             	mov    0x4(%edi),%eax
f0107821:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107825:	8b 07                	mov    (%edi),%eax
f0107827:	8b 40 04             	mov    0x4(%eax),%eax
f010782a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010782e:	c7 04 24 40 a0 10 f0 	movl   $0xf010a040,(%esp)
f0107835:	e8 4f ca ff ff       	call   f0104289 <cprintf>
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f010783a:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f010783c:	83 fe 27             	cmp    $0x27,%esi
f010783f:	0f 86 04 ff ff ff    	jbe    f0107749 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0107845:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0107848:	89 c2                	mov    %eax,%edx
f010784a:	c1 ea 10             	shr    $0x10,%edx
f010784d:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107851:	0f b7 c0             	movzwl %ax,%eax
f0107854:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107858:	8b 47 08             	mov    0x8(%edi),%eax
f010785b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010785f:	8b 47 04             	mov    0x4(%edi),%eax
f0107862:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107866:	8b 07                	mov    (%edi),%eax
f0107868:	8b 40 04             	mov    0x4(%eax),%eax
f010786b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010786f:	c7 04 24 9c a0 10 f0 	movl   $0xf010a09c,(%esp)
f0107876:	e8 0e ca ff ff       	call   f0104289 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f010787b:	83 c4 4c             	add    $0x4c,%esp
f010787e:	5b                   	pop    %ebx
f010787f:	5e                   	pop    %esi
f0107880:	5f                   	pop    %edi
f0107881:	5d                   	pop    %ebp
f0107882:	c3                   	ret    

f0107883 <pci_init>:

int
pci_init(void)
{
f0107883:	55                   	push   %ebp
f0107884:	89 e5                	mov    %esp,%ebp
f0107886:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0107889:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107890:	00 
f0107891:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107898:	00 
f0107899:	c7 04 24 80 de 2b f0 	movl   $0xf02bde80,(%esp)
f01078a0:	e8 a2 ea ff ff       	call   f0106347 <memset>

	return pci_scan_bus(&root_bus);
f01078a5:	b8 80 de 2b f0       	mov    $0xf02bde80,%eax
f01078aa:	e8 96 fb ff ff       	call   f0107445 <pci_scan_bus>
}
f01078af:	c9                   	leave  
f01078b0:	c3                   	ret    

f01078b1 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f01078b1:	55                   	push   %ebp
f01078b2:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f01078b4:	c7 05 88 de 2b f0 00 	movl   $0x0,0xf02bde88
f01078bb:	00 00 00 
}
f01078be:	5d                   	pop    %ebp
f01078bf:	c3                   	ret    

f01078c0 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f01078c0:	a1 88 de 2b f0       	mov    0xf02bde88,%eax
f01078c5:	83 c0 01             	add    $0x1,%eax
f01078c8:	a3 88 de 2b f0       	mov    %eax,0xf02bde88
	if (ticks * 10 < ticks)
f01078cd:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01078d0:	01 d2                	add    %edx,%edx
f01078d2:	39 d0                	cmp    %edx,%eax
f01078d4:	76 22                	jbe    f01078f8 <time_tick+0x38>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f01078d6:	55                   	push   %ebp
f01078d7:	89 e5                	mov    %esp,%ebp
f01078d9:	83 ec 18             	sub    $0x18,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f01078dc:	c7 44 24 08 a4 a1 10 	movl   $0xf010a1a4,0x8(%esp)
f01078e3:	f0 
f01078e4:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f01078eb:	00 
f01078ec:	c7 04 24 bf a1 10 f0 	movl   $0xf010a1bf,(%esp)
f01078f3:	e8 48 87 ff ff       	call   f0100040 <_panic>
f01078f8:	f3 c3                	repz ret 

f01078fa <time_msec>:
}

unsigned int
time_msec(void)
{
f01078fa:	55                   	push   %ebp
f01078fb:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01078fd:	a1 88 de 2b f0       	mov    0xf02bde88,%eax
f0107902:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0107905:	01 c0                	add    %eax,%eax
}
f0107907:	5d                   	pop    %ebp
f0107908:	c3                   	ret    
f0107909:	66 90                	xchg   %ax,%ax
f010790b:	66 90                	xchg   %ax,%ax
f010790d:	66 90                	xchg   %ax,%ax
f010790f:	90                   	nop

f0107910 <__udivdi3>:
f0107910:	55                   	push   %ebp
f0107911:	57                   	push   %edi
f0107912:	56                   	push   %esi
f0107913:	83 ec 0c             	sub    $0xc,%esp
f0107916:	8b 44 24 28          	mov    0x28(%esp),%eax
f010791a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010791e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0107922:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0107926:	85 c0                	test   %eax,%eax
f0107928:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010792c:	89 ea                	mov    %ebp,%edx
f010792e:	89 0c 24             	mov    %ecx,(%esp)
f0107931:	75 2d                	jne    f0107960 <__udivdi3+0x50>
f0107933:	39 e9                	cmp    %ebp,%ecx
f0107935:	77 61                	ja     f0107998 <__udivdi3+0x88>
f0107937:	85 c9                	test   %ecx,%ecx
f0107939:	89 ce                	mov    %ecx,%esi
f010793b:	75 0b                	jne    f0107948 <__udivdi3+0x38>
f010793d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107942:	31 d2                	xor    %edx,%edx
f0107944:	f7 f1                	div    %ecx
f0107946:	89 c6                	mov    %eax,%esi
f0107948:	31 d2                	xor    %edx,%edx
f010794a:	89 e8                	mov    %ebp,%eax
f010794c:	f7 f6                	div    %esi
f010794e:	89 c5                	mov    %eax,%ebp
f0107950:	89 f8                	mov    %edi,%eax
f0107952:	f7 f6                	div    %esi
f0107954:	89 ea                	mov    %ebp,%edx
f0107956:	83 c4 0c             	add    $0xc,%esp
f0107959:	5e                   	pop    %esi
f010795a:	5f                   	pop    %edi
f010795b:	5d                   	pop    %ebp
f010795c:	c3                   	ret    
f010795d:	8d 76 00             	lea    0x0(%esi),%esi
f0107960:	39 e8                	cmp    %ebp,%eax
f0107962:	77 24                	ja     f0107988 <__udivdi3+0x78>
f0107964:	0f bd e8             	bsr    %eax,%ebp
f0107967:	83 f5 1f             	xor    $0x1f,%ebp
f010796a:	75 3c                	jne    f01079a8 <__udivdi3+0x98>
f010796c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107970:	39 34 24             	cmp    %esi,(%esp)
f0107973:	0f 86 9f 00 00 00    	jbe    f0107a18 <__udivdi3+0x108>
f0107979:	39 d0                	cmp    %edx,%eax
f010797b:	0f 82 97 00 00 00    	jb     f0107a18 <__udivdi3+0x108>
f0107981:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107988:	31 d2                	xor    %edx,%edx
f010798a:	31 c0                	xor    %eax,%eax
f010798c:	83 c4 0c             	add    $0xc,%esp
f010798f:	5e                   	pop    %esi
f0107990:	5f                   	pop    %edi
f0107991:	5d                   	pop    %ebp
f0107992:	c3                   	ret    
f0107993:	90                   	nop
f0107994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107998:	89 f8                	mov    %edi,%eax
f010799a:	f7 f1                	div    %ecx
f010799c:	31 d2                	xor    %edx,%edx
f010799e:	83 c4 0c             	add    $0xc,%esp
f01079a1:	5e                   	pop    %esi
f01079a2:	5f                   	pop    %edi
f01079a3:	5d                   	pop    %ebp
f01079a4:	c3                   	ret    
f01079a5:	8d 76 00             	lea    0x0(%esi),%esi
f01079a8:	89 e9                	mov    %ebp,%ecx
f01079aa:	8b 3c 24             	mov    (%esp),%edi
f01079ad:	d3 e0                	shl    %cl,%eax
f01079af:	89 c6                	mov    %eax,%esi
f01079b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01079b6:	29 e8                	sub    %ebp,%eax
f01079b8:	89 c1                	mov    %eax,%ecx
f01079ba:	d3 ef                	shr    %cl,%edi
f01079bc:	89 e9                	mov    %ebp,%ecx
f01079be:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01079c2:	8b 3c 24             	mov    (%esp),%edi
f01079c5:	09 74 24 08          	or     %esi,0x8(%esp)
f01079c9:	89 d6                	mov    %edx,%esi
f01079cb:	d3 e7                	shl    %cl,%edi
f01079cd:	89 c1                	mov    %eax,%ecx
f01079cf:	89 3c 24             	mov    %edi,(%esp)
f01079d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01079d6:	d3 ee                	shr    %cl,%esi
f01079d8:	89 e9                	mov    %ebp,%ecx
f01079da:	d3 e2                	shl    %cl,%edx
f01079dc:	89 c1                	mov    %eax,%ecx
f01079de:	d3 ef                	shr    %cl,%edi
f01079e0:	09 d7                	or     %edx,%edi
f01079e2:	89 f2                	mov    %esi,%edx
f01079e4:	89 f8                	mov    %edi,%eax
f01079e6:	f7 74 24 08          	divl   0x8(%esp)
f01079ea:	89 d6                	mov    %edx,%esi
f01079ec:	89 c7                	mov    %eax,%edi
f01079ee:	f7 24 24             	mull   (%esp)
f01079f1:	39 d6                	cmp    %edx,%esi
f01079f3:	89 14 24             	mov    %edx,(%esp)
f01079f6:	72 30                	jb     f0107a28 <__udivdi3+0x118>
f01079f8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01079fc:	89 e9                	mov    %ebp,%ecx
f01079fe:	d3 e2                	shl    %cl,%edx
f0107a00:	39 c2                	cmp    %eax,%edx
f0107a02:	73 05                	jae    f0107a09 <__udivdi3+0xf9>
f0107a04:	3b 34 24             	cmp    (%esp),%esi
f0107a07:	74 1f                	je     f0107a28 <__udivdi3+0x118>
f0107a09:	89 f8                	mov    %edi,%eax
f0107a0b:	31 d2                	xor    %edx,%edx
f0107a0d:	e9 7a ff ff ff       	jmp    f010798c <__udivdi3+0x7c>
f0107a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107a18:	31 d2                	xor    %edx,%edx
f0107a1a:	b8 01 00 00 00       	mov    $0x1,%eax
f0107a1f:	e9 68 ff ff ff       	jmp    f010798c <__udivdi3+0x7c>
f0107a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107a28:	8d 47 ff             	lea    -0x1(%edi),%eax
f0107a2b:	31 d2                	xor    %edx,%edx
f0107a2d:	83 c4 0c             	add    $0xc,%esp
f0107a30:	5e                   	pop    %esi
f0107a31:	5f                   	pop    %edi
f0107a32:	5d                   	pop    %ebp
f0107a33:	c3                   	ret    
f0107a34:	66 90                	xchg   %ax,%ax
f0107a36:	66 90                	xchg   %ax,%ax
f0107a38:	66 90                	xchg   %ax,%ax
f0107a3a:	66 90                	xchg   %ax,%ax
f0107a3c:	66 90                	xchg   %ax,%ax
f0107a3e:	66 90                	xchg   %ax,%ax

f0107a40 <__umoddi3>:
f0107a40:	55                   	push   %ebp
f0107a41:	57                   	push   %edi
f0107a42:	56                   	push   %esi
f0107a43:	83 ec 14             	sub    $0x14,%esp
f0107a46:	8b 44 24 28          	mov    0x28(%esp),%eax
f0107a4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0107a4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0107a52:	89 c7                	mov    %eax,%edi
f0107a54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107a58:	8b 44 24 30          	mov    0x30(%esp),%eax
f0107a5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0107a60:	89 34 24             	mov    %esi,(%esp)
f0107a63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107a67:	85 c0                	test   %eax,%eax
f0107a69:	89 c2                	mov    %eax,%edx
f0107a6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107a6f:	75 17                	jne    f0107a88 <__umoddi3+0x48>
f0107a71:	39 fe                	cmp    %edi,%esi
f0107a73:	76 4b                	jbe    f0107ac0 <__umoddi3+0x80>
f0107a75:	89 c8                	mov    %ecx,%eax
f0107a77:	89 fa                	mov    %edi,%edx
f0107a79:	f7 f6                	div    %esi
f0107a7b:	89 d0                	mov    %edx,%eax
f0107a7d:	31 d2                	xor    %edx,%edx
f0107a7f:	83 c4 14             	add    $0x14,%esp
f0107a82:	5e                   	pop    %esi
f0107a83:	5f                   	pop    %edi
f0107a84:	5d                   	pop    %ebp
f0107a85:	c3                   	ret    
f0107a86:	66 90                	xchg   %ax,%ax
f0107a88:	39 f8                	cmp    %edi,%eax
f0107a8a:	77 54                	ja     f0107ae0 <__umoddi3+0xa0>
f0107a8c:	0f bd e8             	bsr    %eax,%ebp
f0107a8f:	83 f5 1f             	xor    $0x1f,%ebp
f0107a92:	75 5c                	jne    f0107af0 <__umoddi3+0xb0>
f0107a94:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107a98:	39 3c 24             	cmp    %edi,(%esp)
f0107a9b:	0f 87 e7 00 00 00    	ja     f0107b88 <__umoddi3+0x148>
f0107aa1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107aa5:	29 f1                	sub    %esi,%ecx
f0107aa7:	19 c7                	sbb    %eax,%edi
f0107aa9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107aad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107ab1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0107ab5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0107ab9:	83 c4 14             	add    $0x14,%esp
f0107abc:	5e                   	pop    %esi
f0107abd:	5f                   	pop    %edi
f0107abe:	5d                   	pop    %ebp
f0107abf:	c3                   	ret    
f0107ac0:	85 f6                	test   %esi,%esi
f0107ac2:	89 f5                	mov    %esi,%ebp
f0107ac4:	75 0b                	jne    f0107ad1 <__umoddi3+0x91>
f0107ac6:	b8 01 00 00 00       	mov    $0x1,%eax
f0107acb:	31 d2                	xor    %edx,%edx
f0107acd:	f7 f6                	div    %esi
f0107acf:	89 c5                	mov    %eax,%ebp
f0107ad1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0107ad5:	31 d2                	xor    %edx,%edx
f0107ad7:	f7 f5                	div    %ebp
f0107ad9:	89 c8                	mov    %ecx,%eax
f0107adb:	f7 f5                	div    %ebp
f0107add:	eb 9c                	jmp    f0107a7b <__umoddi3+0x3b>
f0107adf:	90                   	nop
f0107ae0:	89 c8                	mov    %ecx,%eax
f0107ae2:	89 fa                	mov    %edi,%edx
f0107ae4:	83 c4 14             	add    $0x14,%esp
f0107ae7:	5e                   	pop    %esi
f0107ae8:	5f                   	pop    %edi
f0107ae9:	5d                   	pop    %ebp
f0107aea:	c3                   	ret    
f0107aeb:	90                   	nop
f0107aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107af0:	8b 04 24             	mov    (%esp),%eax
f0107af3:	be 20 00 00 00       	mov    $0x20,%esi
f0107af8:	89 e9                	mov    %ebp,%ecx
f0107afa:	29 ee                	sub    %ebp,%esi
f0107afc:	d3 e2                	shl    %cl,%edx
f0107afe:	89 f1                	mov    %esi,%ecx
f0107b00:	d3 e8                	shr    %cl,%eax
f0107b02:	89 e9                	mov    %ebp,%ecx
f0107b04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b08:	8b 04 24             	mov    (%esp),%eax
f0107b0b:	09 54 24 04          	or     %edx,0x4(%esp)
f0107b0f:	89 fa                	mov    %edi,%edx
f0107b11:	d3 e0                	shl    %cl,%eax
f0107b13:	89 f1                	mov    %esi,%ecx
f0107b15:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107b19:	8b 44 24 10          	mov    0x10(%esp),%eax
f0107b1d:	d3 ea                	shr    %cl,%edx
f0107b1f:	89 e9                	mov    %ebp,%ecx
f0107b21:	d3 e7                	shl    %cl,%edi
f0107b23:	89 f1                	mov    %esi,%ecx
f0107b25:	d3 e8                	shr    %cl,%eax
f0107b27:	89 e9                	mov    %ebp,%ecx
f0107b29:	09 f8                	or     %edi,%eax
f0107b2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0107b2f:	f7 74 24 04          	divl   0x4(%esp)
f0107b33:	d3 e7                	shl    %cl,%edi
f0107b35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107b39:	89 d7                	mov    %edx,%edi
f0107b3b:	f7 64 24 08          	mull   0x8(%esp)
f0107b3f:	39 d7                	cmp    %edx,%edi
f0107b41:	89 c1                	mov    %eax,%ecx
f0107b43:	89 14 24             	mov    %edx,(%esp)
f0107b46:	72 2c                	jb     f0107b74 <__umoddi3+0x134>
f0107b48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0107b4c:	72 22                	jb     f0107b70 <__umoddi3+0x130>
f0107b4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107b52:	29 c8                	sub    %ecx,%eax
f0107b54:	19 d7                	sbb    %edx,%edi
f0107b56:	89 e9                	mov    %ebp,%ecx
f0107b58:	89 fa                	mov    %edi,%edx
f0107b5a:	d3 e8                	shr    %cl,%eax
f0107b5c:	89 f1                	mov    %esi,%ecx
f0107b5e:	d3 e2                	shl    %cl,%edx
f0107b60:	89 e9                	mov    %ebp,%ecx
f0107b62:	d3 ef                	shr    %cl,%edi
f0107b64:	09 d0                	or     %edx,%eax
f0107b66:	89 fa                	mov    %edi,%edx
f0107b68:	83 c4 14             	add    $0x14,%esp
f0107b6b:	5e                   	pop    %esi
f0107b6c:	5f                   	pop    %edi
f0107b6d:	5d                   	pop    %ebp
f0107b6e:	c3                   	ret    
f0107b6f:	90                   	nop
f0107b70:	39 d7                	cmp    %edx,%edi
f0107b72:	75 da                	jne    f0107b4e <__umoddi3+0x10e>
f0107b74:	8b 14 24             	mov    (%esp),%edx
f0107b77:	89 c1                	mov    %eax,%ecx
f0107b79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0107b7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0107b81:	eb cb                	jmp    f0107b4e <__umoddi3+0x10e>
f0107b83:	90                   	nop
f0107b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107b88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0107b8c:	0f 82 0f ff ff ff    	jb     f0107aa1 <__umoddi3+0x61>
f0107b92:	e9 1a ff ff ff       	jmp    f0107ab1 <__umoddi3+0x71>
