
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

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
f010004b:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 23 f0    	mov    %esi,0xf0231e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 c5 64 00 00       	call   f0106529 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 6c 10 f0 	movl   $0xf0106c00,(%esp)
f010007d:	e8 09 42 00 00       	call   f010428b <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 ca 41 00 00       	call   f0104258 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f0100095:	e8 f1 41 00 00       	call   f010428b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 fc 0c 00 00       	call   f0100da2 <monitor>
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
f01000af:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f01000b4:	2d e8 00 23 f0       	sub    $0xf02300e8,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 e8 00 23 f0 	movl   $0xf02300e8,(%esp)
f01000cc:	e8 06 5e 00 00       	call   f0105ed7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 b9 05 00 00       	call   f010068f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 6c 6c 10 f0 	movl   $0xf0106c6c,(%esp)
f01000e5:	e8 a1 41 00 00       	call   f010428b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 69 17 00 00       	call   f0101858 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 7c 39 00 00       	call   f0103a70 <env_init>
	trap_init();
f01000f4:	e8 96 42 00 00       	call   f010438f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 1c 61 00 00       	call   f010621a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 3f 64 00 00       	call   f0106544 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 b1 40 00 00       	call   f01041bb <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 91 66 00 00       	call   f01067a7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 1e 23 f0 07 	cmpl   $0x7,0xf0231e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 87 6c 10 f0 	movl   $0xf0106c87,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 52 61 10 f0       	mov    $0xf0106152,%eax
f0100148:	2d d8 60 10 f0       	sub    $0xf01060d8,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 d8 60 10 	movl   $0xf01060d8,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 bf 5d 00 00       	call   f0105f24 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum())  // We've started already.
f010016c:	e8 b8 63 00 00       	call   f0106529 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 20 23 f0       	sub    $0xf0232020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 b0 23 f0    	lea    -0xfdc5000(%eax),%eax
f0100196:	a3 84 1e 23 f0       	mov    %eax,0xf0231e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 e6 64 00 00       	call   f0106694 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f01001c0:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	boot_aps();
	//unlock_kernel();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 44 66 22 f0 	movl   $0xf0226644,(%esp)
f01001d8:	e8 92 3a 00 00       	call   f0103c6f <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001dd:	e8 40 4c 00 00       	call   f0104e22 <sched_yield>

f01001e2 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e2:	55                   	push   %ebp
f01001e3:	89 e5                	mov    %esp,%ebp
f01001e5:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001e8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f2:	77 20                	ja     f0100214 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001f8:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f01001ff:	f0 
f0100200:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0100207:	00 
f0100208:	c7 04 24 87 6c 10 f0 	movl   $0xf0106c87,(%esp)
f010020f:	e8 2c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100214:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100219:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010021c:	e8 08 63 00 00       	call   f0106529 <cpunum>
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	c7 04 24 93 6c 10 f0 	movl   $0xf0106c93,(%esp)
f010022c:	e8 5a 40 00 00       	call   f010428b <cprintf>

	lapic_init();
f0100231:	e8 0e 63 00 00       	call   f0106544 <lapic_init>
	env_init_percpu();
f0100236:	e8 0b 38 00 00       	call   f0103a46 <env_init_percpu>
	trap_init_percpu();
f010023b:	90                   	nop
f010023c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100240:	e8 6b 40 00 00       	call   f01042b0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 df 62 00 00       	call   f0106529 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100263:	e8 3f 65 00 00       	call   f01067a7 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f0100268:	e8 b5 4b 00 00       	call   f0104e22 <sched_yield>

f010026d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010026d:	55                   	push   %ebp
f010026e:	89 e5                	mov    %esp,%ebp
f0100270:	53                   	push   %ebx
f0100271:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100274:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100277:	8b 45 0c             	mov    0xc(%ebp),%eax
f010027a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100281:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100285:	c7 04 24 a9 6c 10 f0 	movl   $0xf0106ca9,(%esp)
f010028c:	e8 fa 3f 00 00       	call   f010428b <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 b8 3f 00 00       	call   f0104258 <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f01002a7:	e8 df 3f 00 00       	call   f010428b <cprintf>
	va_end(ap);
}
f01002ac:	83 c4 14             	add    $0x14,%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5d                   	pop    %ebp
f01002b1:	c3                   	ret    
f01002b2:	66 90                	xchg   %ax,%ax
f01002b4:	66 90                	xchg   %ax,%ax
f01002b6:	66 90                	xchg   %ax,%ax
f01002b8:	66 90                	xchg   %ax,%ax
f01002ba:	66 90                	xchg   %ax,%ax
f01002bc:	66 90                	xchg   %ax,%ax
f01002be:	66 90                	xchg   %ax,%ax

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 08                	je     f01002d5 <serial_proc_data+0x15>
f01002cd:	b2 f8                	mov    $0xf8,%dl
f01002cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d0:	0f b6 c0             	movzbl %al,%eax
f01002d3:	eb 05                	jmp    f01002da <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002dc:	55                   	push   %ebp
f01002dd:	89 e5                	mov    %esp,%ebp
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 04             	sub    $0x4,%esp
f01002e3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e5:	eb 2a                	jmp    f0100311 <cons_intr+0x35>
		if (c == 0)
f01002e7:	85 d2                	test   %edx,%edx
f01002e9:	74 26                	je     f0100311 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002eb:	a1 24 12 23 f0       	mov    0xf0231224,%eax
f01002f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002f3:	89 0d 24 12 23 f0    	mov    %ecx,0xf0231224
f01002f9:	88 90 20 10 23 f0    	mov    %dl,-0xfdcefe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100305:	75 0a                	jne    f0100311 <cons_intr+0x35>
			cons.wpos = 0;
f0100307:	c7 05 24 12 23 f0 00 	movl   $0x0,0xf0231224
f010030e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100311:	ff d3                	call   *%ebx
f0100313:	89 c2                	mov    %eax,%edx
f0100315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100318:	75 cd                	jne    f01002e7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010031a:	83 c4 04             	add    $0x4,%esp
f010031d:	5b                   	pop    %ebx
f010031e:	5d                   	pop    %ebp
f010031f:	c3                   	ret    

f0100320 <kbd_proc_data>:
f0100320:	ba 64 00 00 00       	mov    $0x64,%edx
f0100325:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100326:	a8 01                	test   $0x1,%al
f0100328:	0f 84 f7 00 00 00    	je     f0100425 <kbd_proc_data+0x105>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010032e:	a8 20                	test   $0x20,%al
f0100330:	0f 85 f5 00 00 00    	jne    f010042b <kbd_proc_data+0x10b>
f0100336:	b2 60                	mov    $0x60,%dl
f0100338:	ec                   	in     (%dx),%al
f0100339:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010033b:	3c e0                	cmp    $0xe0,%al
f010033d:	75 0d                	jne    f010034c <kbd_proc_data+0x2c>
		// E0 escape character
		shift |= E0ESC;
f010033f:	83 0d 00 10 23 f0 40 	orl    $0x40,0xf0231000
		return 0;
f0100346:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010034b:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010034c:	55                   	push   %ebp
f010034d:	89 e5                	mov    %esp,%ebp
f010034f:	53                   	push   %ebx
f0100350:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100353:	84 c0                	test   %al,%al
f0100355:	79 37                	jns    f010038e <kbd_proc_data+0x6e>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100357:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f010035d:	89 cb                	mov    %ecx,%ebx
f010035f:	83 e3 40             	and    $0x40,%ebx
f0100362:	83 e0 7f             	and    $0x7f,%eax
f0100365:	85 db                	test   %ebx,%ebx
f0100367:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010036a:	0f b6 d2             	movzbl %dl,%edx
f010036d:	0f b6 82 20 6e 10 f0 	movzbl -0xfef91e0(%edx),%eax
f0100374:	83 c8 40             	or     $0x40,%eax
f0100377:	0f b6 c0             	movzbl %al,%eax
f010037a:	f7 d0                	not    %eax
f010037c:	21 c1                	and    %eax,%ecx
f010037e:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
		return 0;
f0100384:	b8 00 00 00 00       	mov    $0x0,%eax
f0100389:	e9 a3 00 00 00       	jmp    f0100431 <kbd_proc_data+0x111>
	} else if (shift & E0ESC) {
f010038e:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f0100394:	f6 c1 40             	test   $0x40,%cl
f0100397:	74 0e                	je     f01003a7 <kbd_proc_data+0x87>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100399:	83 c8 80             	or     $0xffffff80,%eax
f010039c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a1:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
	}

	shift |= shiftcode[data];
f01003a7:	0f b6 d2             	movzbl %dl,%edx
f01003aa:	0f b6 82 20 6e 10 f0 	movzbl -0xfef91e0(%edx),%eax
f01003b1:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f01003b7:	0f b6 8a 20 6d 10 f0 	movzbl -0xfef92e0(%edx),%ecx
f01003be:	31 c8                	xor    %ecx,%eax
f01003c0:	a3 00 10 23 f0       	mov    %eax,0xf0231000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c5:	89 c1                	mov    %eax,%ecx
f01003c7:	83 e1 03             	and    $0x3,%ecx
f01003ca:	8b 0c 8d 00 6d 10 f0 	mov    -0xfef9300(,%ecx,4),%ecx
f01003d1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003d5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d8:	a8 08                	test   $0x8,%al
f01003da:	74 1b                	je     f01003f7 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003dc:	89 da                	mov    %ebx,%edx
f01003de:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e1:	83 f9 19             	cmp    $0x19,%ecx
f01003e4:	77 05                	ja     f01003eb <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003e6:	83 eb 20             	sub    $0x20,%ebx
f01003e9:	eb 0c                	jmp    f01003f7 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003eb:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ee:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003f1:	83 fa 19             	cmp    $0x19,%edx
f01003f4:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f7:	f7 d0                	not    %eax
f01003f9:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003fb:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003fd:	f6 c2 06             	test   $0x6,%dl
f0100400:	75 2f                	jne    f0100431 <kbd_proc_data+0x111>
f0100402:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100408:	75 27                	jne    f0100431 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f010040a:	c7 04 24 c3 6c 10 f0 	movl   $0xf0106cc3,(%esp)
f0100411:	e8 75 3e 00 00       	call   f010428b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100416:	ba 92 00 00 00       	mov    $0x92,%edx
f010041b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100420:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100421:	89 d8                	mov    %ebx,%eax
f0100423:	eb 0c                	jmp    f0100431 <kbd_proc_data+0x111>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010042a:	c3                   	ret    
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010042b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100430:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100431:	83 c4 14             	add    $0x14,%esp
f0100434:	5b                   	pop    %ebx
f0100435:	5d                   	pop    %ebp
f0100436:	c3                   	ret    

f0100437 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100437:	55                   	push   %ebp
f0100438:	89 e5                	mov    %esp,%ebp
f010043a:	57                   	push   %edi
f010043b:	56                   	push   %esi
f010043c:	53                   	push   %ebx
f010043d:	83 ec 1c             	sub    $0x1c,%esp
f0100440:	89 c7                	mov    %eax,%edi
f0100442:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100447:	be fd 03 00 00       	mov    $0x3fd,%esi
f010044c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100451:	eb 06                	jmp    f0100459 <cons_putc+0x22>
f0100453:	89 ca                	mov    %ecx,%edx
f0100455:	ec                   	in     (%dx),%al
f0100456:	ec                   	in     (%dx),%al
f0100457:	ec                   	in     (%dx),%al
f0100458:	ec                   	in     (%dx),%al
f0100459:	89 f2                	mov    %esi,%edx
f010045b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010045c:	a8 20                	test   $0x20,%al
f010045e:	75 05                	jne    f0100465 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100460:	83 eb 01             	sub    $0x1,%ebx
f0100463:	75 ee                	jne    f0100453 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100478:	be 79 03 00 00       	mov    $0x379,%esi
f010047d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100482:	eb 06                	jmp    f010048a <cons_putc+0x53>
f0100484:	89 ca                	mov    %ecx,%edx
f0100486:	ec                   	in     (%dx),%al
f0100487:	ec                   	in     (%dx),%al
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	89 f2                	mov    %esi,%edx
f010048c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010048d:	84 c0                	test   %al,%al
f010048f:	78 05                	js     f0100496 <cons_putc+0x5f>
f0100491:	83 eb 01             	sub    $0x1,%ebx
f0100494:	75 ee                	jne    f0100484 <cons_putc+0x4d>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100496:	ba 78 03 00 00       	mov    $0x378,%edx
f010049b:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010049f:	ee                   	out    %al,(%dx)
f01004a0:	b2 7a                	mov    $0x7a,%dl
f01004a2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a7:	ee                   	out    %al,(%dx)
f01004a8:	b8 08 00 00 00       	mov    $0x8,%eax
f01004ad:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004ae:	89 fa                	mov    %edi,%edx
f01004b0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004b6:	89 f8                	mov    %edi,%eax
f01004b8:	80 cc 07             	or     $0x7,%ah
f01004bb:	85 d2                	test   %edx,%edx
f01004bd:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004c0:	89 f8                	mov    %edi,%eax
f01004c2:	0f b6 c0             	movzbl %al,%eax
f01004c5:	83 f8 09             	cmp    $0x9,%eax
f01004c8:	74 78                	je     f0100542 <cons_putc+0x10b>
f01004ca:	83 f8 09             	cmp    $0x9,%eax
f01004cd:	7f 0a                	jg     f01004d9 <cons_putc+0xa2>
f01004cf:	83 f8 08             	cmp    $0x8,%eax
f01004d2:	74 18                	je     f01004ec <cons_putc+0xb5>
f01004d4:	e9 9d 00 00 00       	jmp    f0100576 <cons_putc+0x13f>
f01004d9:	83 f8 0a             	cmp    $0xa,%eax
f01004dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004e0:	74 3a                	je     f010051c <cons_putc+0xe5>
f01004e2:	83 f8 0d             	cmp    $0xd,%eax
f01004e5:	74 3d                	je     f0100524 <cons_putc+0xed>
f01004e7:	e9 8a 00 00 00       	jmp    f0100576 <cons_putc+0x13f>
	case '\b':
		if (crt_pos > 0) {
f01004ec:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f01004f3:	66 85 c0             	test   %ax,%ax
f01004f6:	0f 84 e5 00 00 00    	je     f01005e1 <cons_putc+0x1aa>
			crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	66 81 e7 00 ff       	and    $0xff00,%di
f010050d:	83 cf 20             	or     $0x20,%edi
f0100510:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100516:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051a:	eb 78                	jmp    f0100594 <cons_putc+0x15d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010051c:	66 83 05 28 12 23 f0 	addw   $0x50,0xf0231228
f0100523:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100524:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010052b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100531:	c1 e8 16             	shr    $0x16,%eax
f0100534:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100537:	c1 e0 04             	shl    $0x4,%eax
f010053a:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
f0100540:	eb 52                	jmp    f0100594 <cons_putc+0x15d>
		break;
	case '\t':
		cons_putc(' ');
f0100542:	b8 20 00 00 00       	mov    $0x20,%eax
f0100547:	e8 eb fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 e1 fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 d7 fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f0100560:	b8 20 00 00 00       	mov    $0x20,%eax
f0100565:	e8 cd fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f010056a:	b8 20 00 00 00       	mov    $0x20,%eax
f010056f:	e8 c3 fe ff ff       	call   f0100437 <cons_putc>
f0100574:	eb 1e                	jmp    f0100594 <cons_putc+0x15d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100576:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 12 23 f0 	mov    %dx,0xf0231228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100594:	66 81 3d 28 12 23 f0 	cmpw   $0x7cf,0xf0231228
f010059b:	cf 07 
f010059d:	76 42                	jbe    f01005e1 <cons_putc+0x1aa>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059f:	a1 2c 12 23 f0       	mov    0xf023122c,%eax
f01005a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005ab:	00 
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005b6:	89 04 24             	mov    %eax,(%esp)
f01005b9:	e8 66 59 00 00       	call   f0105f24 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005be:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cf:	83 c0 01             	add    $0x1,%eax
f01005d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005d7:	75 f0                	jne    f01005c9 <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005d9:	66 83 2d 28 12 23 f0 	subw   $0x50,0xf0231228
f01005e0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005e1:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 ca                	mov    %ecx,%edx
f01005ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ef:	0f b7 1d 28 12 23 f0 	movzwl 0xf0231228,%ebx
f01005f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f9:	89 d8                	mov    %ebx,%eax
f01005fb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ff:	89 f2                	mov    %esi,%edx
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
f010060a:	89 d8                	mov    %ebx,%eax
f010060c:	89 f2                	mov    %esi,%edx
f010060e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010060f:	83 c4 1c             	add    $0x1c,%esp
f0100612:	5b                   	pop    %ebx
f0100613:	5e                   	pop    %esi
f0100614:	5f                   	pop    %edi
f0100615:	5d                   	pop    %ebp
f0100616:	c3                   	ret    

f0100617 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100617:	80 3d 34 12 23 f0 00 	cmpb   $0x0,0xf0231234
f010061e:	74 11                	je     f0100631 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100626:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010062b:	e8 ac fc ff ff       	call   f01002dc <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	f3 c3                	repz ret 

f0100633 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100639:	b8 20 03 10 f0       	mov    $0xf0100320,%eax
f010063e:	e8 99 fc ff ff       	call   f01002dc <cons_intr>
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010064b:	e8 c7 ff ff ff       	call   f0100617 <serial_intr>
	kbd_intr();
f0100650:	e8 de ff ff ff       	call   f0100633 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100655:	a1 20 12 23 f0       	mov    0xf0231220,%eax
f010065a:	3b 05 24 12 23 f0    	cmp    0xf0231224,%eax
f0100660:	74 26                	je     f0100688 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100662:	8d 50 01             	lea    0x1(%eax),%edx
f0100665:	89 15 20 12 23 f0    	mov    %edx,0xf0231220
f010066b:	0f b6 88 20 10 23 f0 	movzbl -0xfdcefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100672:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100674:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067a:	75 11                	jne    f010068d <cons_getc+0x48>
			cons.rpos = 0;
f010067c:	c7 05 20 12 23 f0 00 	movl   $0x0,0xf0231220
f0100683:	00 00 00 
f0100686:	eb 05                	jmp    f010068d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	57                   	push   %edi
f0100693:	56                   	push   %esi
f0100694:	53                   	push   %ebx
f0100695:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100698:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010069f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a6:	5a a5 
	if (*cp != 0xA55A) {
f01006a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b3:	74 11                	je     f01006c6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b5:	c7 05 30 12 23 f0 b4 	movl   $0x3b4,0xf0231230
f01006bc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006c4:	eb 16                	jmp    f01006dc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cd:	c7 05 30 12 23 f0 d4 	movl   $0x3d4,0xf0231230
f01006d4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006dc:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f01006e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e7:	89 ca                	mov    %ecx,%edx
f01006e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ea:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	89 da                	mov    %ebx,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	0f b6 f0             	movzbl %al,%esi
f01006f3:	c1 e6 08             	shl    $0x8,%esi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fb:	89 ca                	mov    %ecx,%edx
f01006fd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100701:	89 3d 2c 12 23 f0    	mov    %edi,0xf023122c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100707:	0f b6 d8             	movzbl %al,%ebx
f010070a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010070c:	66 89 35 28 12 23 f0 	mov    %si,0xf0231228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100713:	e8 1b ff ff ff       	call   f0100633 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100718:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010071f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100724:	89 04 24             	mov    %eax,(%esp)
f0100727:	e8 20 3a 00 00       	call   f010414c <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100731:	b8 00 00 00 00       	mov    $0x0,%eax
f0100736:	89 f2                	mov    %esi,%edx
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fb                	mov    $0xfb,%dl
f010073b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100740:	ee                   	out    %al,(%dx)
f0100741:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100746:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 f9                	mov    $0xf9,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 fb                	mov    $0xfb,%dl
f0100758:	b8 03 00 00 00       	mov    $0x3,%eax
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 fc                	mov    $0xfc,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 f9                	mov    $0xf9,%dl
f0100768:	b8 01 00 00 00       	mov    $0x1,%eax
f010076d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076e:	b2 fd                	mov    $0xfd,%dl
f0100770:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100771:	3c ff                	cmp    $0xff,%al
f0100773:	0f 95 c1             	setne  %cl
f0100776:	88 0d 34 12 23 f0    	mov    %cl,0xf0231234
f010077c:	89 f2                	mov    %esi,%edx
f010077e:	ec                   	in     (%dx),%al
f010077f:	89 da                	mov    %ebx,%edx
f0100781:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100782:	84 c9                	test   %cl,%cl
f0100784:	75 0c                	jne    f0100792 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100786:	c7 04 24 cf 6c 10 f0 	movl   $0xf0106ccf,(%esp)
f010078d:	e8 f9 3a 00 00       	call   f010428b <cprintf>
}
f0100792:	83 c4 1c             	add    $0x1c,%esp
f0100795:	5b                   	pop    %ebx
f0100796:	5e                   	pop    %esi
f0100797:	5f                   	pop    %edi
f0100798:	5d                   	pop    %ebp
f0100799:	c3                   	ret    

f010079a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a3:	e8 8f fc ff ff       	call   f0100437 <cons_putc>
}
f01007a8:	c9                   	leave  
f01007a9:	c3                   	ret    

f01007aa <getchar>:

int
getchar(void)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b0:	e8 90 fe ff ff       	call   f0100645 <cons_getc>
f01007b5:	85 c0                	test   %eax,%eax
f01007b7:	74 f7                	je     f01007b0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b9:	c9                   	leave  
f01007ba:	c3                   	ret    

f01007bb <iscons>:

int
iscons(int fdnum)
{
f01007bb:	55                   	push   %ebp
f01007bc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007be:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c3:	5d                   	pop    %ebp
f01007c4:	c3                   	ret    
f01007c5:	66 90                	xchg   %ax,%ax
f01007c7:	66 90                	xchg   %ax,%ax
f01007c9:	66 90                	xchg   %ax,%ax
f01007cb:	66 90                	xchg   %ax,%ax
f01007cd:	66 90                	xchg   %ax,%ax
f01007cf:	90                   	nop

f01007d0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	56                   	push   %esi
f01007d4:	53                   	push   %ebx
f01007d5:	83 ec 10             	sub    $0x10,%esp
f01007d8:	bb 24 74 10 f0       	mov    $0xf0107424,%ebx
f01007dd:	be 90 74 10 f0       	mov    $0xf0107490,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e2:	8b 03                	mov    (%ebx),%eax
f01007e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e8:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ef:	c7 04 24 20 6f 10 f0 	movl   $0xf0106f20,(%esp)
f01007f6:	e8 90 3a 00 00       	call   f010428b <cprintf>
f01007fb:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007fe:	39 f3                	cmp    %esi,%ebx
f0100800:	75 e0                	jne    f01007e2 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100802:	b8 00 00 00 00       	mov    $0x0,%eax
f0100807:	83 c4 10             	add    $0x10,%esp
f010080a:	5b                   	pop    %ebx
f010080b:	5e                   	pop    %esi
f010080c:	5d                   	pop    %ebp
f010080d:	c3                   	ret    

f010080e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010080e:	55                   	push   %ebp
f010080f:	89 e5                	mov    %esp,%ebp
f0100811:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100814:	c7 04 24 29 6f 10 f0 	movl   $0xf0106f29,(%esp)
f010081b:	e8 6b 3a 00 00       	call   f010428b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100820:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100827:	00 
f0100828:	c7 04 24 74 70 10 f0 	movl   $0xf0107074,(%esp)
f010082f:	e8 57 3a 00 00       	call   f010428b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100834:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010083b:	00 
f010083c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100843:	f0 
f0100844:	c7 04 24 9c 70 10 f0 	movl   $0xf010709c,(%esp)
f010084b:	e8 3b 3a 00 00       	call   f010428b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100850:	c7 44 24 08 f7 6b 10 	movl   $0x106bf7,0x8(%esp)
f0100857:	00 
f0100858:	c7 44 24 04 f7 6b 10 	movl   $0xf0106bf7,0x4(%esp)
f010085f:	f0 
f0100860:	c7 04 24 c0 70 10 f0 	movl   $0xf01070c0,(%esp)
f0100867:	e8 1f 3a 00 00       	call   f010428b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010086c:	c7 44 24 08 e8 00 23 	movl   $0x2300e8,0x8(%esp)
f0100873:	00 
f0100874:	c7 44 24 04 e8 00 23 	movl   $0xf02300e8,0x4(%esp)
f010087b:	f0 
f010087c:	c7 04 24 e4 70 10 f0 	movl   $0xf01070e4,(%esp)
f0100883:	e8 03 3a 00 00       	call   f010428b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100888:	c7 44 24 08 08 30 27 	movl   $0x273008,0x8(%esp)
f010088f:	00 
f0100890:	c7 44 24 04 08 30 27 	movl   $0xf0273008,0x4(%esp)
f0100897:	f0 
f0100898:	c7 04 24 08 71 10 f0 	movl   $0xf0107108,(%esp)
f010089f:	e8 e7 39 00 00       	call   f010428b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008a4:	b8 07 34 27 f0       	mov    $0xf0273407,%eax
f01008a9:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008ae:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008b9:	85 c0                	test   %eax,%eax
f01008bb:	0f 48 c2             	cmovs  %edx,%eax
f01008be:	c1 f8 0a             	sar    $0xa,%eax
f01008c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c5:	c7 04 24 2c 71 10 f0 	movl   $0xf010712c,(%esp)
f01008cc:	e8 ba 39 00 00       	call   f010428b <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d6:	c9                   	leave  
f01008d7:	c3                   	ret    

f01008d8 <mon_step>:
	return 0;
}

int
mon_step(int argc, char **argv, struct Trapframe *tf)
{
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	83 ec 18             	sub    $0x18,%esp
f01008de:	8b 45 10             	mov    0x10(%ebp),%eax
	//Set trap flag (bit 8). This adds an int1 after each step automatically
	tf->tf_eflags |= 0x100;
f01008e1:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	cprintf("EIP 0x%x -> 0x%x\n", tf->tf_eip, *((uint32_t*)tf->tf_eip));
f01008e8:	8b 40 30             	mov    0x30(%eax),%eax
f01008eb:	8b 10                	mov    (%eax),%edx
f01008ed:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f5:	c7 04 24 42 6f 10 f0 	movl   $0xf0106f42,(%esp)
f01008fc:	e8 8a 39 00 00       	call   f010428b <cprintf>
	return -1;
}
f0100901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100906:	c9                   	leave  
f0100907:	c3                   	ret    

f0100908 <mon_continue>:

int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100908:	55                   	push   %ebp
f0100909:	89 e5                	mov    %esp,%ebp
f010090b:	83 ec 18             	sub    $0x18,%esp
f010090e:	8b 45 10             	mov    0x10(%ebp),%eax
	//Clear trap flag (bit 8). 
	tf->tf_eflags &= ~0x100;
f0100911:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	cprintf("Continuing... \n");
f0100918:	c7 04 24 54 6f 10 f0 	movl   $0xf0106f54,(%esp)
f010091f:	e8 67 39 00 00       	call   f010428b <cprintf>
	return -1;
}
f0100924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100929:	c9                   	leave  
f010092a:	c3                   	ret    

f010092b <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010092b:	55                   	push   %ebp
f010092c:	89 e5                	mov    %esp,%ebp
f010092e:	56                   	push   %esi
f010092f:	53                   	push   %ebx
f0100930:	83 ec 40             	sub    $0x40,%esp
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100933:	89 eb                	mov    %ebp,%ebx

	while (ebp) 
	{
		debuginfo_eip(*(ebp+1),&info);
f0100935:	8d 75 e0             	lea    -0x20(%ebp),%esi
{
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));

	while (ebp) 
f0100938:	eb 7a                	jmp    f01009b4 <mon_backtrace+0x89>
	{
		debuginfo_eip(*(ebp+1),&info);
f010093a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010093e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 19 4b 00 00       	call   f0105462 <debuginfo_eip>
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, *(ebp+1), *(ebp+2), *(ebp+3), *(ebp+3), *(ebp+4), *(ebp+5));
f0100949:	8b 43 0c             	mov    0xc(%ebx),%eax
f010094c:	8b 53 14             	mov    0x14(%ebx),%edx
f010094f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
f0100953:	8b 53 10             	mov    0x10(%ebx),%edx
f0100956:	89 54 24 18          	mov    %edx,0x18(%esp)
f010095a:	89 44 24 14          	mov    %eax,0x14(%esp)
f010095e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100962:	8b 43 08             	mov    0x8(%ebx),%eax
f0100965:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100969:	8b 43 04             	mov    0x4(%ebx),%eax
f010096c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100970:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100974:	c7 04 24 58 71 10 f0 	movl   $0xf0107158,(%esp)
f010097b:	e8 0b 39 00 00       	call   f010428b <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - (int)info.eip_fn_addr);
f0100980:	8b 43 04             	mov    0x4(%ebx),%eax
f0100983:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100986:	89 44 24 14          	mov    %eax,0x14(%esp)
f010098a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010098d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100991:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100994:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100998:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010099b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a6:	c7 04 24 64 6f 10 f0 	movl   $0xf0106f64,(%esp)
f01009ad:	e8 d9 38 00 00       	call   f010428b <cprintf>
		ebp = (int*)(*ebp);
f01009b2:	8b 1b                	mov    (%ebx),%ebx
{
	int *ebp;
	struct Eipdebuginfo info;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));

	while (ebp) 
f01009b4:	85 db                	test   %ebx,%ebx
f01009b6:	75 82                	jne    f010093a <mon_backtrace+0xf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - (int)info.eip_fn_addr);
		ebp = (int*)(*ebp);
	}

	return 0;
}
f01009b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009bd:	83 c4 40             	add    $0x40,%esp
f01009c0:	5b                   	pop    %ebx
f01009c1:	5e                   	pop    %esi
f01009c2:	5d                   	pop    %ebp
f01009c3:	c3                   	ret    

f01009c4 <mon_dumpv>:
	return 0;
}

int 
mon_dumpv(int argc, char **argv, struct Trapframe *tf)
{
f01009c4:	55                   	push   %ebp
f01009c5:	89 e5                	mov    %esp,%ebp
f01009c7:	57                   	push   %edi
f01009c8:	56                   	push   %esi
f01009c9:	53                   	push   %ebx
f01009ca:	83 ec 1c             	sub    $0x1c,%esp
f01009cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f01009d0:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f01009d4:	7f 13                	jg     f01009e9 <mon_dumpv+0x25>
		cprintf("Need to specify address or address range!");
f01009d6:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f01009dd:	e8 a9 38 00 00       	call   f010428b <cprintf>
		return -1;
f01009e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009e7:	eb 6e                	jmp    f0100a57 <mon_dumpv+0x93>
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
f01009e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01009f0:	00 
f01009f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009f8:	00 
f01009f9:	8b 47 04             	mov    0x4(%edi),%eax
f01009fc:	89 04 24             	mov    %eax,(%esp)
f01009ff:	e8 ff 55 00 00       	call   f0106003 <strtol>
f0100a04:	89 c3                	mov    %eax,%ebx
	uint32_t* last = first;
f0100a06:	89 c6                	mov    %eax,%esi
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);
f0100a08:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a0c:	75 34                	jne    f0100a42 <mon_dumpv+0x7e>
f0100a0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a15:	00 
f0100a16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a1d:	00 
f0100a1e:	8b 47 08             	mov    0x8(%edi),%eax
f0100a21:	89 04 24             	mov    %eax,(%esp)
f0100a24:	e8 da 55 00 00       	call   f0106003 <strtol>
f0100a29:	89 c6                	mov    %eax,%esi

	for(uint32_t* i = first; i <= last; i++) {
f0100a2b:	eb 15                	jmp    f0100a42 <mon_dumpv+0x7e>
		cprintf("%x ",*i); //paging hardware just translates virtual address for us
f0100a2d:	8b 03                	mov    (%ebx),%eax
f0100a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a33:	c7 04 24 75 6f 10 f0 	movl   $0xf0106f75,(%esp)
f0100a3a:	e8 4c 38 00 00       	call   f010428b <cprintf>

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
f0100a3f:	83 c3 04             	add    $0x4,%ebx
f0100a42:	39 de                	cmp    %ebx,%esi
f0100a44:	73 e7                	jae    f0100a2d <mon_dumpv+0x69>
		cprintf("%x ",*i); //paging hardware just translates virtual address for us
	}
	cprintf("\n");
f0100a46:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f0100a4d:	e8 39 38 00 00       	call   f010428b <cprintf>
	return 0;
f0100a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a57:	83 c4 1c             	add    $0x1c,%esp
f0100a5a:	5b                   	pop    %ebx
f0100a5b:	5e                   	pop    %esi
f0100a5c:	5f                   	pop    %edi
f0100a5d:	5d                   	pop    %ebp
f0100a5e:	c3                   	ret    

f0100a5f <mon_dumpp>:

int 
mon_dumpp(int argc, char **argv, struct Trapframe *tf)
{
f0100a5f:	55                   	push   %ebp
f0100a60:	89 e5                	mov    %esp,%ebp
f0100a62:	57                   	push   %edi
f0100a63:	56                   	push   %esi
f0100a64:	53                   	push   %ebx
f0100a65:	83 ec 1c             	sub    $0x1c,%esp
f0100a68:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f0100a6b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a6f:	7f 16                	jg     f0100a87 <mon_dumpp+0x28>
		cprintf("Need to specify address or address range!");
f0100a71:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f0100a78:	e8 0e 38 00 00       	call   f010428b <cprintf>
		return -1;
f0100a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a82:	e9 9f 00 00 00       	jmp    f0100b26 <mon_dumpp+0xc7>
	}

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
f0100a87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a8e:	00 
f0100a8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a96:	00 
f0100a97:	8b 47 04             	mov    0x4(%edi),%eax
f0100a9a:	89 04 24             	mov    %eax,(%esp)
f0100a9d:	e8 61 55 00 00       	call   f0106003 <strtol>
f0100aa2:	89 c3                	mov    %eax,%ebx
	uint32_t* last = first;
f0100aa4:	89 c6                	mov    %eax,%esi
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);
f0100aa6:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100aaa:	75 65                	jne    f0100b11 <mon_dumpp+0xb2>
f0100aac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ab3:	00 
f0100ab4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100abb:	00 
f0100abc:	8b 47 08             	mov    0x8(%edi),%eax
f0100abf:	89 04 24             	mov    %eax,(%esp)
f0100ac2:	e8 3c 55 00 00       	call   f0106003 <strtol>
f0100ac7:	89 c6                	mov    %eax,%esi

	for(uint32_t* i = first; i <= last; i++) {
f0100ac9:	eb 46                	jmp    f0100b11 <mon_dumpp+0xb2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100acb:	89 d8                	mov    %ebx,%eax
f0100acd:	c1 e8 0c             	shr    $0xc,%eax
f0100ad0:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0100ad6:	72 20                	jb     f0100af8 <mon_dumpp+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100adc:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0100ae3:	f0 
f0100ae4:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0100aeb:	00 
f0100aec:	c7 04 24 79 6f 10 f0 	movl   $0xf0106f79,(%esp)
f0100af3:	e8 48 f5 ff ff       	call   f0100040 <_panic>
		cprintf("%x ",*((int*)KADDR((physaddr_t)i))); 
f0100af8:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100afe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b02:	c7 04 24 75 6f 10 f0 	movl   $0xf0106f75,(%esp)
f0100b09:	e8 7d 37 00 00       	call   f010428b <cprintf>

	uint32_t* first = (uint32_t*) strtol(argv[1], NULL, 0);
	uint32_t* last = first;
	if(argc == 3) last = (uint32_t*) strtol(argv[2], NULL, 0);

	for(uint32_t* i = first; i <= last; i++) {
f0100b0e:	83 c3 04             	add    $0x4,%ebx
f0100b11:	39 de                	cmp    %ebx,%esi
f0100b13:	73 b6                	jae    f0100acb <mon_dumpp+0x6c>
		cprintf("%x ",*((int*)KADDR((physaddr_t)i))); 
	}
	cprintf("\n");
f0100b15:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f0100b1c:	e8 6a 37 00 00       	call   f010428b <cprintf>
	return 0;
f0100b21:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b26:	83 c4 1c             	add    $0x1c,%esp
f0100b29:	5b                   	pop    %ebx
f0100b2a:	5e                   	pop    %esi
f0100b2b:	5f                   	pop    %edi
f0100b2c:	5d                   	pop    %ebp
f0100b2d:	c3                   	ret    

f0100b2e <traversePages>:
	return 0;
}

// Used by both showmappings and changeperms to loop over page ranges 
// and perform operations on them
void traversePages(uintptr_t first, uintptr_t last, int print, int set, int clear) {
f0100b2e:	55                   	push   %ebp
f0100b2f:	89 e5                	mov    %esp,%ebp
f0100b31:	57                   	push   %edi
f0100b32:	56                   	push   %esi
f0100b33:	53                   	push   %ebx
f0100b34:	83 ec 1c             	sub    $0x1c,%esp
f0100b37:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100b3a:	8b 7d 10             	mov    0x10(%ebp),%edi

	//The first 20 bits of va specify the page, so we increment 0x1000
	for(uintptr_t i = first; i <= last; i += 0x1000) {
f0100b3d:	e9 a8 00 00 00       	jmp    f0100bea <traversePages+0xbc>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) i, 0);
f0100b42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b49:	00 
f0100b4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b4e:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0100b53:	89 04 24             	mov    %eax,(%esp)
f0100b56:	e8 28 0a 00 00       	call   f0101583 <pgdir_walk>
f0100b5b:	89 c6                	mov    %eax,%esi

		if(!pte || !(*pte & PTE_P)) {
f0100b5d:	85 c0                	test   %eax,%eax
f0100b5f:	74 06                	je     f0100b67 <traversePages+0x39>
f0100b61:	8b 00                	mov    (%eax),%eax
f0100b63:	a8 01                	test   $0x1,%al
f0100b65:	75 16                	jne    f0100b7d <traversePages+0x4f>
			//Page table or page doesn't exist
			if(print) cprintf("0x%x: --- \n", i);
f0100b67:	85 ff                	test   %edi,%edi
f0100b69:	74 79                	je     f0100be4 <traversePages+0xb6>
f0100b6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b6f:	c7 04 24 88 6f 10 f0 	movl   $0xf0106f88,(%esp)
f0100b76:	e8 10 37 00 00       	call   f010428b <cprintf>
f0100b7b:	eb 67                	jmp    f0100be4 <traversePages+0xb6>
			continue;
		}

		//Either changer perms, or print but not both
		if(print) {
f0100b7d:	85 ff                	test   %edi,%edi
f0100b7f:	74 5b                	je     f0100bdc <traversePages+0xae>
			cprintf("0x%x: 0x%x - ", i, PTE_ADDR(i));
f0100b81:	89 d8                	mov    %ebx,%eax
f0100b83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b90:	c7 04 24 94 6f 10 f0 	movl   $0xf0106f94,(%esp)
f0100b97:	e8 ef 36 00 00       	call   f010428b <cprintf>

			if(*pte & PTE_U) cprintf("U ");
f0100b9c:	f6 06 04             	testb  $0x4,(%esi)
f0100b9f:	74 0e                	je     f0100baf <traversePages+0x81>
f0100ba1:	c7 04 24 a2 6f 10 f0 	movl   $0xf0106fa2,(%esp)
f0100ba8:	e8 de 36 00 00       	call   f010428b <cprintf>
f0100bad:	eb 0c                	jmp    f0100bbb <traversePages+0x8d>
			else cprintf("S ");
f0100baf:	c7 04 24 a5 6f 10 f0 	movl   $0xf0106fa5,(%esp)
f0100bb6:	e8 d0 36 00 00       	call   f010428b <cprintf>

			if(*pte & PTE_W) cprintf("RW\n");
f0100bbb:	f6 06 02             	testb  $0x2,(%esi)
f0100bbe:	74 0e                	je     f0100bce <traversePages+0xa0>
f0100bc0:	c7 04 24 a8 6f 10 f0 	movl   $0xf0106fa8,(%esp)
f0100bc7:	e8 bf 36 00 00       	call   f010428b <cprintf>
f0100bcc:	eb 16                	jmp    f0100be4 <traversePages+0xb6>
			else cprintf("R\n");
f0100bce:	c7 04 24 ac 6f 10 f0 	movl   $0xf0106fac,(%esp)
f0100bd5:	e8 b1 36 00 00       	call   f010428b <cprintf>
f0100bda:	eb 08                	jmp    f0100be4 <traversePages+0xb6>
		} else {
			*pte |= set;
f0100bdc:	0b 45 14             	or     0x14(%ebp),%eax
			*pte &= clear;
f0100bdf:	23 45 18             	and    0x18(%ebp),%eax
f0100be2:	89 06                	mov    %eax,(%esi)
// Used by both showmappings and changeperms to loop over page ranges 
// and perform operations on them
void traversePages(uintptr_t first, uintptr_t last, int print, int set, int clear) {

	//The first 20 bits of va specify the page, so we increment 0x1000
	for(uintptr_t i = first; i <= last; i += 0x1000) {
f0100be4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100bea:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0100bed:	0f 86 4f ff ff ff    	jbe    f0100b42 <traversePages+0x14>
		} else {
			*pte |= set;
			*pte &= clear;
		}
	}
}
f0100bf3:	83 c4 1c             	add    $0x1c,%esp
f0100bf6:	5b                   	pop    %ebx
f0100bf7:	5e                   	pop    %esi
f0100bf8:	5f                   	pop    %edi
f0100bf9:	5d                   	pop    %ebp
f0100bfa:	c3                   	ret    

f0100bfb <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100bfb:	55                   	push   %ebp
f0100bfc:	89 e5                	mov    %esp,%ebp
f0100bfe:	57                   	push   %edi
f0100bff:	56                   	push   %esi
f0100c00:	53                   	push   %ebx
f0100c01:	83 ec 2c             	sub    $0x2c,%esp
f0100c04:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100c07:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2) {
f0100c0a:	83 fb 01             	cmp    $0x1,%ebx
f0100c0d:	7f 13                	jg     f0100c22 <mon_showmappings+0x27>
		cprintf("Need to specify address or address range!");
f0100c0f:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f0100c16:	e8 70 36 00 00       	call   f010428b <cprintf>
		return -1;
f0100c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c20:	eb 66                	jmp    f0100c88 <mon_showmappings+0x8d>
	}
	
	//Get first and last page of address range
	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
f0100c22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c29:	00 
f0100c2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c31:	00 
f0100c32:	8b 47 04             	mov    0x4(%edi),%eax
f0100c35:	89 04 24             	mov    %eax,(%esp)
f0100c38:	e8 c6 53 00 00       	call   f0106003 <strtol>
f0100c3d:	89 c6                	mov    %eax,%esi
	uintptr_t last = first;
	if(argc == 3) last = (uintptr_t) strtol(argv[2], NULL, 0);
f0100c3f:	83 fb 03             	cmp    $0x3,%ebx
f0100c42:	75 1b                	jne    f0100c5f <mon_showmappings+0x64>
f0100c44:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c4b:	00 
f0100c4c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c53:	00 
f0100c54:	8b 47 08             	mov    0x8(%edi),%eax
f0100c57:	89 04 24             	mov    %eax,(%esp)
f0100c5a:	e8 a4 53 00 00       	call   f0106003 <strtol>

	traversePages(first, last, 1, 0, 0); // last two arguments are unused
f0100c5f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
f0100c66:	00 
f0100c67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c6e:	00 
f0100c6f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100c76:	00 
f0100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7b:	89 34 24             	mov    %esi,(%esp)
f0100c7e:	e8 ab fe ff ff       	call   f0100b2e <traversePages>
	return 0;
f0100c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c88:	83 c4 2c             	add    $0x2c,%esp
f0100c8b:	5b                   	pop    %ebx
f0100c8c:	5e                   	pop    %esi
f0100c8d:	5f                   	pop    %edi
f0100c8e:	5d                   	pop    %ebp
f0100c8f:	c3                   	ret    

f0100c90 <mon_changeperms>:

int 
mon_changeperms(int argc, char **argv, struct Trapframe *tf)
{
f0100c90:	55                   	push   %ebp
f0100c91:	89 e5                	mov    %esp,%ebp
f0100c93:	57                   	push   %edi
f0100c94:	56                   	push   %esi
f0100c95:	53                   	push   %ebx
f0100c96:	83 ec 2c             	sub    $0x2c,%esp
f0100c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc < 4) {
f0100c9c:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100ca0:	7f 16                	jg     f0100cb8 <mon_changeperms+0x28>
		cprintf("Need to specify address range and at least one change!");
f0100ca2:	c7 04 24 b8 71 10 f0 	movl   $0xf01071b8,(%esp)
f0100ca9:	e8 dd 35 00 00       	call   f010428b <cprintf>
		return -1;
f0100cae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb3:	e9 e2 00 00 00       	jmp    f0100d9a <mon_changeperms+0x10a>
	}

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
f0100cb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cbf:	00 
f0100cc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100cc7:	00 
f0100cc8:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ccb:	89 04 24             	mov    %eax,(%esp)
f0100cce:	e8 30 53 00 00       	call   f0106003 <strtol>
f0100cd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);
f0100cd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cdd:	00 
f0100cde:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ce5:	00 
f0100ce6:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ce9:	89 04 24             	mov    %eax,(%esp)
f0100cec:	e8 12 53 00 00       	call   f0106003 <strtol>
f0100cf1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
f0100cf4:	b8 03 00 00 00       	mov    $0x3,%eax
	}

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);

	int set = 0, clear = 0;
f0100cf9:	be 00 00 00 00       	mov    $0x0,%esi
f0100cfe:	bf 00 00 00 00       	mov    $0x0,%edi
	for(int i = 3; i < argc; i ++ ) {
		int flag = 0;
		switch(argv[i][1]) {
f0100d03:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0100d06:	0f b6 51 01          	movzbl 0x1(%ecx),%edx
f0100d0a:	80 fa 55             	cmp    $0x55,%dl
f0100d0d:	74 2d                	je     f0100d3c <mon_changeperms+0xac>
f0100d0f:	80 fa 57             	cmp    $0x57,%dl
f0100d12:	74 07                	je     f0100d1b <mon_changeperms+0x8b>
f0100d14:	80 fa 50             	cmp    $0x50,%dl
f0100d17:	75 09                	jne    f0100d22 <mon_changeperms+0x92>
f0100d19:	eb 1a                	jmp    f0100d35 <mon_changeperms+0xa5>
				break;
			case 'U': 
				flag = PTE_U;
				break;
			case 'W': 
				flag = PTE_W;
f0100d1b:	ba 02 00 00 00       	mov    $0x2,%edx
				break;
f0100d20:	eb 1f                	jmp    f0100d41 <mon_changeperms+0xb1>
			default:
				cprintf("Illegal! See help for usage\n");
f0100d22:	c7 04 24 af 6f 10 f0 	movl   $0xf0106faf,(%esp)
f0100d29:	e8 5d 35 00 00       	call   f010428b <cprintf>
				return -1;
f0100d2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d33:	eb 65                	jmp    f0100d9a <mon_changeperms+0x10a>
	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
		int flag = 0;
		switch(argv[i][1]) {
			case 'P': 
				flag = PTE_P;
f0100d35:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d3a:	eb 05                	jmp    f0100d41 <mon_changeperms+0xb1>
				break;
			case 'U': 
				flag = PTE_U;
f0100d3c:	ba 04 00 00 00       	mov    $0x4,%edx
				cprintf("Illegal! See help for usage\n");
				return -1;
		}

		//Accumulate flag values in set and clear
		if(argv[i][0] == '+') set |= flag;
f0100d41:	0f b6 09             	movzbl (%ecx),%ecx
f0100d44:	80 f9 2b             	cmp    $0x2b,%cl
f0100d47:	75 04                	jne    f0100d4d <mon_changeperms+0xbd>
f0100d49:	09 d7                	or     %edx,%edi
f0100d4b:	eb 1c                	jmp    f0100d69 <mon_changeperms+0xd9>
		else if(argv[i][0] == '-') clear |= flag;
f0100d4d:	80 f9 2d             	cmp    $0x2d,%cl
f0100d50:	75 04                	jne    f0100d56 <mon_changeperms+0xc6>
f0100d52:	09 d6                	or     %edx,%esi
f0100d54:	eb 13                	jmp    f0100d69 <mon_changeperms+0xd9>
		else {
			cprintf("Illegal! See help for usage\n");
f0100d56:	c7 04 24 af 6f 10 f0 	movl   $0xf0106faf,(%esp)
f0100d5d:	e8 29 35 00 00       	call   f010428b <cprintf>
			return -1;
f0100d62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d67:	eb 31                	jmp    f0100d9a <mon_changeperms+0x10a>

	uintptr_t first = (uintptr_t) strtol(argv[1], NULL, 0);
	uintptr_t last = (uintptr_t) strtol(argv[2], NULL, 0);

	int set = 0, clear = 0;
	for(int i = 3; i < argc; i ++ ) {
f0100d69:	83 c0 01             	add    $0x1,%eax
f0100d6c:	3b 45 08             	cmp    0x8(%ebp),%eax
f0100d6f:	75 92                	jne    f0100d03 <mon_changeperms+0x73>
			cprintf("Illegal! See help for usage\n");
			return -1;
		}
	}

	traversePages(first, last, 0, set, ~clear); 
f0100d71:	f7 d6                	not    %esi
f0100d73:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100d77:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100d7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100d82:	00 
f0100d83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d8d:	89 04 24             	mov    %eax,(%esp)
f0100d90:	e8 99 fd ff ff       	call   f0100b2e <traversePages>
	return 0;
f0100d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d9a:	83 c4 2c             	add    $0x2c,%esp
f0100d9d:	5b                   	pop    %ebx
f0100d9e:	5e                   	pop    %esi
f0100d9f:	5f                   	pop    %edi
f0100da0:	5d                   	pop    %ebp
f0100da1:	c3                   	ret    

f0100da2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100da2:	55                   	push   %ebp
f0100da3:	89 e5                	mov    %esp,%ebp
f0100da5:	57                   	push   %edi
f0100da6:	56                   	push   %esi
f0100da7:	53                   	push   %ebx
f0100da8:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100dab:	c7 04 24 f0 71 10 f0 	movl   $0xf01071f0,(%esp)
f0100db2:	e8 d4 34 00 00       	call   f010428b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100db7:	c7 04 24 14 72 10 f0 	movl   $0xf0107214,(%esp)
f0100dbe:	e8 c8 34 00 00       	call   f010428b <cprintf>

	if (tf != NULL)
f0100dc3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100dc7:	74 0b                	je     f0100dd4 <monitor+0x32>
		print_trapframe(tf);
f0100dc9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dcc:	89 04 24             	mov    %eax,(%esp)
f0100dcf:	e8 a0 39 00 00       	call   f0104774 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100dd4:	c7 04 24 cc 6f 10 f0 	movl   $0xf0106fcc,(%esp)
f0100ddb:	e8 a0 4e 00 00       	call   f0105c80 <readline>
f0100de0:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100de2:	85 c0                	test   %eax,%eax
f0100de4:	74 ee                	je     f0100dd4 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100de6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ded:	be 00 00 00 00       	mov    $0x0,%esi
f0100df2:	eb 0a                	jmp    f0100dfe <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100df4:	c6 03 00             	movb   $0x0,(%ebx)
f0100df7:	89 f7                	mov    %esi,%edi
f0100df9:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100dfc:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100dfe:	0f b6 03             	movzbl (%ebx),%eax
f0100e01:	84 c0                	test   %al,%al
f0100e03:	74 63                	je     f0100e68 <monitor+0xc6>
f0100e05:	0f be c0             	movsbl %al,%eax
f0100e08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e0c:	c7 04 24 d0 6f 10 f0 	movl   $0xf0106fd0,(%esp)
f0100e13:	e8 82 50 00 00       	call   f0105e9a <strchr>
f0100e18:	85 c0                	test   %eax,%eax
f0100e1a:	75 d8                	jne    f0100df4 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100e1c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e1f:	74 47                	je     f0100e68 <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e21:	83 fe 0f             	cmp    $0xf,%esi
f0100e24:	75 16                	jne    f0100e3c <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e26:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100e2d:	00 
f0100e2e:	c7 04 24 d5 6f 10 f0 	movl   $0xf0106fd5,(%esp)
f0100e35:	e8 51 34 00 00       	call   f010428b <cprintf>
f0100e3a:	eb 98                	jmp    f0100dd4 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100e3c:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e3f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e43:	eb 03                	jmp    f0100e48 <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e45:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e48:	0f b6 03             	movzbl (%ebx),%eax
f0100e4b:	84 c0                	test   %al,%al
f0100e4d:	74 ad                	je     f0100dfc <monitor+0x5a>
f0100e4f:	0f be c0             	movsbl %al,%eax
f0100e52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e56:	c7 04 24 d0 6f 10 f0 	movl   $0xf0106fd0,(%esp)
f0100e5d:	e8 38 50 00 00       	call   f0105e9a <strchr>
f0100e62:	85 c0                	test   %eax,%eax
f0100e64:	74 df                	je     f0100e45 <monitor+0xa3>
f0100e66:	eb 94                	jmp    f0100dfc <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100e68:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e6f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e70:	85 f6                	test   %esi,%esi
f0100e72:	0f 84 5c ff ff ff    	je     f0100dd4 <monitor+0x32>
f0100e78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e7d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e80:	8b 04 85 20 74 10 f0 	mov    -0xfef8be0(,%eax,4),%eax
f0100e87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e8b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e8e:	89 04 24             	mov    %eax,(%esp)
f0100e91:	e8 a6 4f 00 00       	call   f0105e3c <strcmp>
f0100e96:	85 c0                	test   %eax,%eax
f0100e98:	75 24                	jne    f0100ebe <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100e9a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e9d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ea0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ea4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ea7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100eab:	89 34 24             	mov    %esi,(%esp)
f0100eae:	ff 14 85 28 74 10 f0 	call   *-0xfef8bd8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100eb5:	85 c0                	test   %eax,%eax
f0100eb7:	78 25                	js     f0100ede <monitor+0x13c>
f0100eb9:	e9 16 ff ff ff       	jmp    f0100dd4 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ebe:	83 c3 01             	add    $0x1,%ebx
f0100ec1:	83 fb 09             	cmp    $0x9,%ebx
f0100ec4:	75 b7                	jne    f0100e7d <monitor+0xdb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ec6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ecd:	c7 04 24 f2 6f 10 f0 	movl   $0xf0106ff2,(%esp)
f0100ed4:	e8 b2 33 00 00       	call   f010428b <cprintf>
f0100ed9:	e9 f6 fe ff ff       	jmp    f0100dd4 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ede:	83 c4 5c             	add    $0x5c,%esp
f0100ee1:	5b                   	pop    %ebx
f0100ee2:	5e                   	pop    %esi
f0100ee3:	5f                   	pop    %edi
f0100ee4:	5d                   	pop    %ebp
f0100ee5:	c3                   	ret    
f0100ee6:	66 90                	xchg   %ax,%ax
f0100ee8:	66 90                	xchg   %ax,%ax
f0100eea:	66 90                	xchg   %ax,%ax
f0100eec:	66 90                	xchg   %ax,%ax
f0100eee:	66 90                	xchg   %ax,%ax

f0100ef0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ef0:	55                   	push   %ebp
f0100ef1:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ef3:	83 3d 38 12 23 f0 00 	cmpl   $0x0,0xf0231238
f0100efa:	75 11                	jne    f0100f0d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100efc:	ba 07 40 27 f0       	mov    $0xf0274007,%edx
f0100f01:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f07:	89 15 38 12 23 f0    	mov    %edx,0xf0231238

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.

	result = nextfree;
f0100f0d:	8b 15 38 12 23 f0    	mov    0xf0231238,%edx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f13:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100f1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f1f:	a3 38 12 23 f0       	mov    %eax,0xf0231238

	return result;
}
f0100f24:	89 d0                	mov    %edx,%eax
f0100f26:	5d                   	pop    %ebp
f0100f27:	c3                   	ret    

f0100f28 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f28:	55                   	push   %ebp
f0100f29:	89 e5                	mov    %esp,%ebp
f0100f2b:	56                   	push   %esi
f0100f2c:	53                   	push   %ebx
f0100f2d:	83 ec 10             	sub    $0x10,%esp
f0100f30:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f32:	89 04 24             	mov    %eax,(%esp)
f0100f35:	e8 e8 31 00 00       	call   f0104122 <mc146818_read>
f0100f3a:	89 c6                	mov    %eax,%esi
f0100f3c:	83 c3 01             	add    $0x1,%ebx
f0100f3f:	89 1c 24             	mov    %ebx,(%esp)
f0100f42:	e8 db 31 00 00       	call   f0104122 <mc146818_read>
f0100f47:	c1 e0 08             	shl    $0x8,%eax
f0100f4a:	09 f0                	or     %esi,%eax
}
f0100f4c:	83 c4 10             	add    $0x10,%esp
f0100f4f:	5b                   	pop    %ebx
f0100f50:	5e                   	pop    %esi
f0100f51:	5d                   	pop    %ebp
f0100f52:	c3                   	ret    

f0100f53 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f53:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100f59:	c1 f8 03             	sar    $0x3,%eax
f0100f5c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5f:	89 c2                	mov    %eax,%edx
f0100f61:	c1 ea 0c             	shr    $0xc,%edx
f0100f64:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100f6a:	72 26                	jb     f0100f92 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100f6c:	55                   	push   %ebp
f0100f6d:	89 e5                	mov    %esp,%ebp
f0100f6f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f76:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0100f7d:	f0 
f0100f7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f85:	00 
f0100f86:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0100f8d:	e8 ae f0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f92:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100f97:	c3                   	ret    

f0100f98 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f98:	89 d1                	mov    %edx,%ecx
f0100f9a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f9d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fa0:	a8 01                	test   $0x1,%al
f0100fa2:	74 5d                	je     f0101001 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fa4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa9:	89 c1                	mov    %eax,%ecx
f0100fab:	c1 e9 0c             	shr    $0xc,%ecx
f0100fae:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0100fb4:	72 26                	jb     f0100fdc <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fb6:	55                   	push   %ebp
f0100fb7:	89 e5                	mov    %esp,%ebp
f0100fb9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc0:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0100fc7:	f0 
f0100fc8:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0100fcf:	00 
f0100fd0:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0100fd7:	e8 64 f0 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100fdc:	c1 ea 0c             	shr    $0xc,%edx
f0100fdf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fe5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ff6:	85 d2                	test   %edx,%edx
f0100ff8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ffd:	0f 44 c2             	cmove  %edx,%eax
f0101000:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0101001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0101006:	c3                   	ret    

f0101007 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101007:	55                   	push   %ebp
f0101008:	89 e5                	mov    %esp,%ebp
f010100a:	57                   	push   %edi
f010100b:	56                   	push   %esi
f010100c:	53                   	push   %ebx
f010100d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101010:	84 c0                	test   %al,%al
f0101012:	0f 85 3f 03 00 00    	jne    f0101357 <check_page_free_list+0x350>
f0101018:	e9 4c 03 00 00       	jmp    f0101369 <check_page_free_list+0x362>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f010101d:	c7 44 24 08 8c 74 10 	movl   $0xf010748c,0x8(%esp)
f0101024:	f0 
f0101025:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f010102c:	00 
f010102d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101034:	e8 07 f0 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101039:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010103c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010103f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101042:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101045:	89 c2                	mov    %eax,%edx
f0101047:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010104d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101053:	0f 95 c2             	setne  %dl
f0101056:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101059:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f010105d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010105f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101063:	8b 00                	mov    (%eax),%eax
f0101065:	85 c0                	test   %eax,%eax
f0101067:	75 dc                	jne    f0101045 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010106c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101072:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101075:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101078:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010107a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010107d:	a3 40 12 23 f0       	mov    %eax,0xf0231240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101082:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101087:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f010108d:	eb 63                	jmp    f01010f2 <check_page_free_list+0xeb>
f010108f:	89 d8                	mov    %ebx,%eax
f0101091:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101097:	c1 f8 03             	sar    $0x3,%eax
f010109a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010109d:	89 c2                	mov    %eax,%edx
f010109f:	c1 ea 16             	shr    $0x16,%edx
f01010a2:	39 f2                	cmp    %esi,%edx
f01010a4:	73 4a                	jae    f01010f0 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a6:	89 c2                	mov    %eax,%edx
f01010a8:	c1 ea 0c             	shr    $0xc,%edx
f01010ab:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01010b1:	72 20                	jb     f01010d3 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010b7:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01010be:	f0 
f01010bf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010c6:	00 
f01010c7:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f01010ce:	e8 6d ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010d3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01010da:	00 
f01010db:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01010e2:	00 
	return (void *)(pa + KERNBASE);
f01010e3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010e8:	89 04 24             	mov    %eax,(%esp)
f01010eb:	e8 e7 4d 00 00       	call   f0105ed7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010f0:	8b 1b                	mov    (%ebx),%ebx
f01010f2:	85 db                	test   %ebx,%ebx
f01010f4:	75 99                	jne    f010108f <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010fb:	e8 f0 fd ff ff       	call   f0100ef0 <boot_alloc>
f0101100:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101103:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101109:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
		assert(pp < pages + npages);
f010110f:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101114:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101117:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010111a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010111d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101120:	bf 00 00 00 00       	mov    $0x0,%edi
f0101125:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101128:	e9 c4 01 00 00       	jmp    f01012f1 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010112d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101130:	73 24                	jae    f0101156 <check_page_free_list+0x14f>
f0101132:	c7 44 24 0c c7 7d 10 	movl   $0xf0107dc7,0xc(%esp)
f0101139:	f0 
f010113a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101141:	f0 
f0101142:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0101149:	00 
f010114a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101151:	e8 ea ee ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101156:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101159:	72 24                	jb     f010117f <check_page_free_list+0x178>
f010115b:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0101162:	f0 
f0101163:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010116a:	f0 
f010116b:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101172:	00 
f0101173:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010117a:	e8 c1 ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010117f:	89 d0                	mov    %edx,%eax
f0101181:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101184:	a8 07                	test   $0x7,%al
f0101186:	74 24                	je     f01011ac <check_page_free_list+0x1a5>
f0101188:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f010118f:	f0 
f0101190:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101197:	f0 
f0101198:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f010119f:	00 
f01011a0:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01011a7:	e8 94 ee ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011ac:	c1 f8 03             	sar    $0x3,%eax
f01011af:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011b2:	85 c0                	test   %eax,%eax
f01011b4:	75 24                	jne    f01011da <check_page_free_list+0x1d3>
f01011b6:	c7 44 24 0c fc 7d 10 	movl   $0xf0107dfc,0xc(%esp)
f01011bd:	f0 
f01011be:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01011c5:	f0 
f01011c6:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f01011cd:	00 
f01011ce:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01011d5:	e8 66 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011da:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011df:	75 24                	jne    f0101205 <check_page_free_list+0x1fe>
f01011e1:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f01011e8:	f0 
f01011e9:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01011f0:	f0 
f01011f1:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f01011f8:	00 
f01011f9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101200:	e8 3b ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101205:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010120a:	75 24                	jne    f0101230 <check_page_free_list+0x229>
f010120c:	c7 44 24 0c e4 74 10 	movl   $0xf01074e4,0xc(%esp)
f0101213:	f0 
f0101214:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010121b:	f0 
f010121c:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0101223:	00 
f0101224:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010122b:	e8 10 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101230:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101235:	75 24                	jne    f010125b <check_page_free_list+0x254>
f0101237:	c7 44 24 0c 26 7e 10 	movl   $0xf0107e26,0xc(%esp)
f010123e:	f0 
f010123f:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101246:	f0 
f0101247:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010124e:	00 
f010124f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101256:	e8 e5 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010125b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101260:	0f 86 2a 01 00 00    	jbe    f0101390 <check_page_free_list+0x389>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101266:	89 c1                	mov    %eax,%ecx
f0101268:	c1 e9 0c             	shr    $0xc,%ecx
f010126b:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f010126e:	77 20                	ja     f0101290 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101270:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101274:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f010127b:	f0 
f010127c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101283:	00 
f0101284:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f010128b:	e8 b0 ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101290:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0101296:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101299:	0f 86 e1 00 00 00    	jbe    f0101380 <check_page_free_list+0x379>
f010129f:	c7 44 24 0c 08 75 10 	movl   $0xf0107508,0xc(%esp)
f01012a6:	f0 
f01012a7:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01012ae:	f0 
f01012af:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f01012b6:	00 
f01012b7:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01012be:	e8 7d ed ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01012c3:	c7 44 24 0c 40 7e 10 	movl   $0xf0107e40,0xc(%esp)
f01012ca:	f0 
f01012cb:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01012d2:	f0 
f01012d3:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f01012da:	00 
f01012db:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01012e2:	e8 59 ed ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01012e7:	83 c3 01             	add    $0x1,%ebx
f01012ea:	eb 03                	jmp    f01012ef <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f01012ec:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012ef:	8b 12                	mov    (%edx),%edx
f01012f1:	85 d2                	test   %edx,%edx
f01012f3:	0f 85 34 fe ff ff    	jne    f010112d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01012f9:	85 db                	test   %ebx,%ebx
f01012fb:	7f 24                	jg     f0101321 <check_page_free_list+0x31a>
f01012fd:	c7 44 24 0c 5d 7e 10 	movl   $0xf0107e5d,0xc(%esp)
f0101304:	f0 
f0101305:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010130c:	f0 
f010130d:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101314:	00 
f0101315:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010131c:	e8 1f ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101321:	85 ff                	test   %edi,%edi
f0101323:	7f 24                	jg     f0101349 <check_page_free_list+0x342>
f0101325:	c7 44 24 0c 6f 7e 10 	movl   $0xf0107e6f,0xc(%esp)
f010132c:	f0 
f010132d:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101334:	f0 
f0101335:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f010133c:	00 
f010133d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101344:	e8 f7 ec ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101349:	c7 04 24 50 75 10 f0 	movl   $0xf0107550,(%esp)
f0101350:	e8 36 2f 00 00       	call   f010428b <cprintf>
f0101355:	eb 4e                	jmp    f01013a5 <check_page_free_list+0x39e>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101357:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f010135c:	85 c0                	test   %eax,%eax
f010135e:	0f 85 d5 fc ff ff    	jne    f0101039 <check_page_free_list+0x32>
f0101364:	e9 b4 fc ff ff       	jmp    f010101d <check_page_free_list+0x16>
f0101369:	83 3d 40 12 23 f0 00 	cmpl   $0x0,0xf0231240
f0101370:	0f 84 a7 fc ff ff    	je     f010101d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101376:	be 00 04 00 00       	mov    $0x400,%esi
f010137b:	e9 07 fd ff ff       	jmp    f0101087 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101380:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101385:	0f 85 61 ff ff ff    	jne    f01012ec <check_page_free_list+0x2e5>
f010138b:	e9 33 ff ff ff       	jmp    f01012c3 <check_page_free_list+0x2bc>
f0101390:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101395:	0f 85 4c ff ff ff    	jne    f01012e7 <check_page_free_list+0x2e0>
f010139b:	90                   	nop
f010139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01013a0:	e9 1e ff ff ff       	jmp    f01012c3 <check_page_free_list+0x2bc>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f01013a5:	83 c4 4c             	add    $0x4c,%esp
f01013a8:	5b                   	pop    %ebx
f01013a9:	5e                   	pop    %esi
f01013aa:	5f                   	pop    %edi
f01013ab:	5d                   	pop    %ebp
f01013ac:	c3                   	ret    

f01013ad <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01013ad:	55                   	push   %ebp
f01013ae:	89 e5                	mov    %esp,%ebp
f01013b0:	56                   	push   %esi
f01013b1:	53                   	push   %ebx
f01013b2:	83 ec 10             	sub    $0x10,%esp

	//Allocate [PGSIZE, npages_basemem*PGSIZE)
	size_t i;
	size_t mpentry  = (size_t) PGNUM(MPENTRY_PADDR);

	for (i = 1; i < npages_basemem; i++) {
f01013b5:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f01013bb:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f01013c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01013c6:	eb 27                	jmp    f01013ef <page_init+0x42>
		if(i == mpentry) continue;
f01013c8:	83 f8 07             	cmp    $0x7,%eax
f01013cb:	74 1f                	je     f01013ec <page_init+0x3f>
f01013cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f01013d4:	89 d1                	mov    %edx,%ecx
f01013d6:	03 0d 90 1e 23 f0    	add    0xf0231e90,%ecx
f01013dc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01013e2:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01013e4:	89 d3                	mov    %edx,%ebx
f01013e6:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx

	//Allocate [PGSIZE, npages_basemem*PGSIZE)
	size_t i;
	size_t mpentry  = (size_t) PGNUM(MPENTRY_PADDR);

	for (i = 1; i < npages_basemem; i++) {
f01013ec:	83 c0 01             	add    $0x1,%eax
f01013ef:	39 f0                	cmp    %esi,%eax
f01013f1:	72 d5                	jb     f01013c8 <page_init+0x1b>
f01013f3:	89 1d 40 12 23 f0    	mov    %ebx,0xf0231240
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	//Allocate the part of extended memory above the kernel's allocation
	i = (size_t) PGNUM(PADDR(boot_alloc(0)));
f01013f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01013fe:	e8 ed fa ff ff       	call   f0100ef0 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101403:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101408:	77 20                	ja     f010142a <page_init+0x7d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010140a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010140e:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0101415:	f0 
f0101416:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f010141d:	00 
f010141e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101425:	e8 16 ec ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010142a:	05 00 00 00 10       	add    $0x10000000,%eax
f010142f:	c1 e8 0c             	shr    $0xc,%eax
f0101432:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f0101438:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	for(; i < npages; i++ ) {
f010143f:	eb 23                	jmp    f0101464 <page_init+0xb7>
		if(i == mpentry) continue;
f0101441:	83 f8 07             	cmp    $0x7,%eax
f0101444:	74 18                	je     f010145e <page_init+0xb1>
		pages[i].pp_ref = 0;
f0101446:	89 d1                	mov    %edx,%ecx
f0101448:	03 0d 90 1e 23 f0    	add    0xf0231e90,%ecx
f010144e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101454:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101456:	89 d3                	mov    %edx,%ebx
f0101458:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx
		page_free_list = &pages[i];
	}

	//Allocate the part of extended memory above the kernel's allocation
	i = (size_t) PGNUM(PADDR(boot_alloc(0)));
	for(; i < npages; i++ ) {
f010145e:	83 c0 01             	add    $0x1,%eax
f0101461:	83 c2 08             	add    $0x8,%edx
f0101464:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f010146a:	72 d5                	jb     f0101441 <page_init+0x94>
f010146c:	89 1d 40 12 23 f0    	mov    %ebx,0xf0231240
		if(i == mpentry) continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	5b                   	pop    %ebx
f0101476:	5e                   	pop    %esi
f0101477:	5d                   	pop    %ebp
f0101478:	c3                   	ret    

f0101479 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101479:	55                   	push   %ebp
f010147a:	89 e5                	mov    %esp,%ebp
f010147c:	53                   	push   %ebx
f010147d:	83 ec 14             	sub    $0x14,%esp
	if(!page_free_list) return NULL;
f0101480:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f0101486:	85 db                	test   %ebx,%ebx
f0101488:	74 6f                	je     f01014f9 <page_alloc+0x80>

	struct PageInfo* curPage = page_free_list;
	page_free_list = page_free_list->pp_link;
f010148a:	8b 03                	mov    (%ebx),%eax
f010148c:	a3 40 12 23 f0       	mov    %eax,0xf0231240
	curPage->pp_link = NULL;
f0101491:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO) {
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
	}

	return curPage;
f0101497:	89 d8                	mov    %ebx,%eax

	struct PageInfo* curPage = page_free_list;
	page_free_list = page_free_list->pp_link;
	curPage->pp_link = NULL;

	if(alloc_flags & ALLOC_ZERO) {
f0101499:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010149d:	74 5f                	je     f01014fe <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010149f:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01014a5:	c1 f8 03             	sar    $0x3,%eax
f01014a8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014ab:	89 c2                	mov    %eax,%edx
f01014ad:	c1 ea 0c             	shr    $0xc,%edx
f01014b0:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01014b6:	72 20                	jb     f01014d8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014bc:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01014c3:	f0 
f01014c4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01014cb:	00 
f01014cc:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f01014d3:	e8 68 eb ff ff       	call   f0100040 <_panic>
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
f01014d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014df:	00 
f01014e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014e7:	00 
	return (void *)(pa + KERNBASE);
f01014e8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014ed:	89 04 24             	mov    %eax,(%esp)
f01014f0:	e8 e2 49 00 00       	call   f0105ed7 <memset>
	}

	return curPage;
f01014f5:	89 d8                	mov    %ebx,%eax
f01014f7:	eb 05                	jmp    f01014fe <page_alloc+0x85>
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if(!page_free_list) return NULL;
f01014f9:	b8 00 00 00 00       	mov    $0x0,%eax
		//Clear page if ALLOC_ZERO is set
		memset(page2kva(curPage), 0, PGSIZE);
	}

	return curPage;
}
f01014fe:	83 c4 14             	add    $0x14,%esp
f0101501:	5b                   	pop    %ebx
f0101502:	5d                   	pop    %ebp
f0101503:	c3                   	ret    

f0101504 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101504:	55                   	push   %ebp
f0101505:	89 e5                	mov    %esp,%ebp
f0101507:	83 ec 18             	sub    $0x18,%esp
f010150a:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref != 0) {
f010150d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101512:	74 1c                	je     f0101530 <page_free+0x2c>
		panic("freeing a page in use\n");
f0101514:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f010151b:	f0 
f010151c:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0101523:	00 
f0101524:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010152b:	e8 10 eb ff ff       	call   f0100040 <_panic>
	}
	if(pp->pp_link) {
f0101530:	83 38 00             	cmpl   $0x0,(%eax)
f0101533:	74 1c                	je     f0101551 <page_free+0x4d>
		panic("page was already free\n");
f0101535:	c7 44 24 08 97 7e 10 	movl   $0xf0107e97,0x8(%esp)
f010153c:	f0 
f010153d:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0101544:	00 
f0101545:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010154c:	e8 ef ea ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f0101551:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
f0101557:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101559:	a3 40 12 23 f0       	mov    %eax,0xf0231240
}
f010155e:	c9                   	leave  
f010155f:	c3                   	ret    

f0101560 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101560:	55                   	push   %ebp
f0101561:	89 e5                	mov    %esp,%ebp
f0101563:	83 ec 18             	sub    $0x18,%esp
f0101566:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101569:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010156d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101570:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101574:	66 85 d2             	test   %dx,%dx
f0101577:	75 08                	jne    f0101581 <page_decref+0x21>
		page_free(pp);
f0101579:	89 04 24             	mov    %eax,(%esp)
f010157c:	e8 83 ff ff ff       	call   f0101504 <page_free>
}
f0101581:	c9                   	leave  
f0101582:	c3                   	ret    

f0101583 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101583:	55                   	push   %ebp
f0101584:	89 e5                	mov    %esp,%ebp
f0101586:	56                   	push   %esi
f0101587:	53                   	push   %ebx
f0101588:	83 ec 10             	sub    $0x10,%esp
f010158b:	8b 75 0c             	mov    0xc(%ebp),%esi
	//Read correct entry in page directory
	pde_t* dir_entry = pgdir + PDX(va); //Remember kids: va = la rn
f010158e:	89 f3                	mov    %esi,%ebx
f0101590:	c1 eb 16             	shr    $0x16,%ebx
f0101593:	c1 e3 02             	shl    $0x2,%ebx
f0101596:	03 5d 08             	add    0x8(%ebp),%ebx

	if(!(*dir_entry & PTE_P)) {
f0101599:	f6 03 01             	testb  $0x1,(%ebx)
f010159c:	75 2c                	jne    f01015ca <pgdir_walk+0x47>
		if(create) {
f010159e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015a2:	74 6c                	je     f0101610 <pgdir_walk+0x8d>
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
f01015a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015ab:	e8 c9 fe ff ff       	call   f0101479 <page_alloc>
			if(!new_pg) return NULL;
f01015b0:	85 c0                	test   %eax,%eax
f01015b2:	74 63                	je     f0101617 <pgdir_walk+0x94>
			new_pg->pp_ref++;
f01015b4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015b9:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01015bf:	c1 f8 03             	sar    $0x3,%eax
f01015c2:	c1 e0 0c             	shl    $0xc,%eax
			*dir_entry = (page2pa(new_pg) | PTE_P | PTE_U |PTE_W);
f01015c5:	83 c8 07             	or     $0x7,%eax
f01015c8:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}

	//Convert pde to pte
	pte_t* tab_entry = (pte_t*)KADDR(PTE_ADDR(*dir_entry));
f01015ca:	8b 03                	mov    (%ebx),%eax
f01015cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d1:	89 c2                	mov    %eax,%edx
f01015d3:	c1 ea 0c             	shr    $0xc,%edx
f01015d6:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01015dc:	72 20                	jb     f01015fe <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015e2:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01015e9:	f0 
f01015ea:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f01015f1:	00 
f01015f2:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01015f9:	e8 42 ea ff ff       	call   f0100040 <_panic>

	//Add offset from va to read into the page table
	return tab_entry + PTX(va);
f01015fe:	c1 ee 0a             	shr    $0xa,%esi
f0101601:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101607:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010160e:	eb 0c                	jmp    f010161c <pgdir_walk+0x99>
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
			if(!new_pg) return NULL;
			new_pg->pp_ref++;
			*dir_entry = (page2pa(new_pg) | PTE_P | PTE_U |PTE_W);
		} else return NULL;
f0101610:	b8 00 00 00 00       	mov    $0x0,%eax
f0101615:	eb 05                	jmp    f010161c <pgdir_walk+0x99>

	if(!(*dir_entry & PTE_P)) {
		if(create) {
			// ALLOC_ZERO flag clears our page
			struct PageInfo* new_pg = page_alloc(ALLOC_ZERO);
			if(!new_pg) return NULL;
f0101617:	b8 00 00 00 00       	mov    $0x0,%eax
	//Convert pde to pte
	pte_t* tab_entry = (pte_t*)KADDR(PTE_ADDR(*dir_entry));

	//Add offset from va to read into the page table
	return tab_entry + PTX(va);
}
f010161c:	83 c4 10             	add    $0x10,%esp
f010161f:	5b                   	pop    %ebx
f0101620:	5e                   	pop    %esi
f0101621:	5d                   	pop    %ebp
f0101622:	c3                   	ret    

f0101623 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101623:	55                   	push   %ebp
f0101624:	89 e5                	mov    %esp,%ebp
f0101626:	57                   	push   %edi
f0101627:	56                   	push   %esi
f0101628:	53                   	push   %ebx
f0101629:	83 ec 2c             	sub    $0x2c,%esp
f010162c:	89 c7                	mov    %eax,%edi
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f010162e:	c1 e9 0c             	shr    $0xc,%ecx
f0101631:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101634:	89 d3                	mov    %edx,%ebx
f0101636:	be 00 00 00 00       	mov    $0x0,%esi
		pte = pgdir_walk(pgdir, (void*)(va + (i*PGSIZE)), 1);

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
f010163b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010163e:	83 c8 01             	or     $0x1,%eax
f0101641:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101644:	8b 45 08             	mov    0x8(%ebp),%eax
f0101647:	29 d0                	sub    %edx,%eax
f0101649:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f010164c:	eb 28                	jmp    f0101676 <boot_map_region+0x53>
		pte = pgdir_walk(pgdir, (void*)(va + (i*PGSIZE)), 1);
f010164e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101655:	00 
f0101656:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010165a:	89 3c 24             	mov    %edi,(%esp)
f010165d:	e8 21 ff ff ff       	call   f0101583 <pgdir_walk>
f0101662:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101665:	8d 14 19             	lea    (%ecx,%ebx,1),%edx

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
f0101668:	0b 55 e0             	or     -0x20(%ebp),%edx
f010166b:	89 10                	mov    %edx,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	pte_t* pte;
	for(int i = 0; i < (size/PGSIZE); i++) {
f010166d:	83 c6 01             	add    $0x1,%esi
f0101670:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101676:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101679:	75 d3                	jne    f010164e <boot_map_region+0x2b>

		//The first 20 bits of the pte are the same as the physical page address
		//We don't clear bottom bits because we know we are aligned to PGSIZE
		*pte = ((pa + i*PGSIZE) | perm | PTE_P);
	}
}
f010167b:	83 c4 2c             	add    $0x2c,%esp
f010167e:	5b                   	pop    %ebx
f010167f:	5e                   	pop    %esi
f0101680:	5f                   	pop    %edi
f0101681:	5d                   	pop    %ebp
f0101682:	c3                   	ret    

f0101683 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101683:	55                   	push   %ebp
f0101684:	89 e5                	mov    %esp,%ebp
f0101686:	53                   	push   %ebx
f0101687:	83 ec 14             	sub    $0x14,%esp
f010168a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir,va,0);
f010168d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101694:	00 
f0101695:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101698:	89 44 24 04          	mov    %eax,0x4(%esp)
f010169c:	8b 45 08             	mov    0x8(%ebp),%eax
f010169f:	89 04 24             	mov    %eax,(%esp)
f01016a2:	e8 dc fe ff ff       	call   f0101583 <pgdir_walk>
	if((!pte) || !(*pte & PTE_P)) return NULL; // no page mapped here
f01016a7:	85 c0                	test   %eax,%eax
f01016a9:	74 3f                	je     f01016ea <page_lookup+0x67>
f01016ab:	f6 00 01             	testb  $0x1,(%eax)
f01016ae:	74 41                	je     f01016f1 <page_lookup+0x6e>

	if(pte_store) *pte_store = pte;
f01016b0:	85 db                	test   %ebx,%ebx
f01016b2:	74 02                	je     f01016b6 <page_lookup+0x33>
f01016b4:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016b6:	8b 00                	mov    (%eax),%eax
f01016b8:	c1 e8 0c             	shr    $0xc,%eax
f01016bb:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01016c1:	72 1c                	jb     f01016df <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f01016c3:	c7 44 24 08 74 75 10 	movl   $0xf0107574,0x8(%esp)
f01016ca:	f0 
f01016cb:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01016d2:	00 
f01016d3:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f01016da:	e8 61 e9 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01016df:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f01016e5:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(*pte);
f01016e8:	eb 0c                	jmp    f01016f6 <page_lookup+0x73>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if((!pte) || !(*pte & PTE_P)) return NULL; // no page mapped here
f01016ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ef:	eb 05                	jmp    f01016f6 <page_lookup+0x73>
f01016f1:	b8 00 00 00 00       	mov    $0x0,%eax

	if(pte_store) *pte_store = pte;

	return pa2page(*pte);
}
f01016f6:	83 c4 14             	add    $0x14,%esp
f01016f9:	5b                   	pop    %ebx
f01016fa:	5d                   	pop    %ebp
f01016fb:	c3                   	ret    

f01016fc <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01016fc:	55                   	push   %ebp
f01016fd:	89 e5                	mov    %esp,%ebp
f01016ff:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101702:	e8 22 4e 00 00       	call   f0106529 <cpunum>
f0101707:	6b c0 74             	imul   $0x74,%eax,%eax
f010170a:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0101711:	74 16                	je     f0101729 <tlb_invalidate+0x2d>
f0101713:	e8 11 4e 00 00       	call   f0106529 <cpunum>
f0101718:	6b c0 74             	imul   $0x74,%eax,%eax
f010171b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0101721:	8b 55 08             	mov    0x8(%ebp),%edx
f0101724:	39 50 60             	cmp    %edx,0x60(%eax)
f0101727:	75 06                	jne    f010172f <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101729:	8b 45 0c             	mov    0xc(%ebp),%eax
f010172c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010172f:	c9                   	leave  
f0101730:	c3                   	ret    

f0101731 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101731:	55                   	push   %ebp
f0101732:	89 e5                	mov    %esp,%ebp
f0101734:	56                   	push   %esi
f0101735:	53                   	push   %ebx
f0101736:	83 ec 20             	sub    $0x20,%esp
f0101739:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010173c:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f010173f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101742:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101746:	89 74 24 04          	mov    %esi,0x4(%esp)
f010174a:	89 1c 24             	mov    %ebx,(%esp)
f010174d:	e8 31 ff ff ff       	call   f0101683 <page_lookup>

	if(!page) return; // page doesn't exist so exit silently
f0101752:	85 c0                	test   %eax,%eax
f0101754:	74 1d                	je     f0101773 <page_remove+0x42>

	page_decref(page); //this method frees page if ref count reaches 0
f0101756:	89 04 24             	mov    %eax,(%esp)
f0101759:	e8 02 fe ff ff       	call   f0101560 <page_decref>
	*pte = 0;
f010175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101761:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101767:	89 74 24 04          	mov    %esi,0x4(%esp)
f010176b:	89 1c 24             	mov    %ebx,(%esp)
f010176e:	e8 89 ff ff ff       	call   f01016fc <tlb_invalidate>
}
f0101773:	83 c4 20             	add    $0x20,%esp
f0101776:	5b                   	pop    %ebx
f0101777:	5e                   	pop    %esi
f0101778:	5d                   	pop    %ebp
f0101779:	c3                   	ret    

f010177a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010177a:	55                   	push   %ebp
f010177b:	89 e5                	mov    %esp,%ebp
f010177d:	57                   	push   %edi
f010177e:	56                   	push   %esi
f010177f:	53                   	push   %ebx
f0101780:	83 ec 1c             	sub    $0x1c,%esp
f0101783:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101786:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101789:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101790:	00 
f0101791:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101795:	8b 45 08             	mov    0x8(%ebp),%eax
f0101798:	89 04 24             	mov    %eax,(%esp)
f010179b:	e8 e3 fd ff ff       	call   f0101583 <pgdir_walk>
f01017a0:	89 c3                	mov    %eax,%ebx

	if(!pte) return -E_NO_MEM;
f01017a2:	85 c0                	test   %eax,%eax
f01017a4:	74 36                	je     f01017dc <page_insert+0x62>

	// We increment pp_ref before page_remove to deal with the case
	// when a pp is re-inserted to the same virtual address in the 
	// same pgdir. Otherwise, page_remove would free the page.
	pp->pp_ref++;
f01017a6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	if(*pte & PTE_P) page_remove(pgdir, va);
f01017ab:	f6 00 01             	testb  $0x1,(%eax)
f01017ae:	74 0f                	je     f01017bf <page_insert+0x45>
f01017b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01017b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b7:	89 04 24             	mov    %eax,(%esp)
f01017ba:	e8 72 ff ff ff       	call   f0101731 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f01017bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01017c2:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017c5:	2b 35 90 1e 23 f0    	sub    0xf0231e90,%esi
f01017cb:	c1 fe 03             	sar    $0x3,%esi
f01017ce:	c1 e6 0c             	shl    $0xc,%esi
f01017d1:	09 c6                	or     %eax,%esi
f01017d3:	89 33                	mov    %esi,(%ebx)
	return 0;
f01017d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01017da:	eb 05                	jmp    f01017e1 <page_insert+0x67>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);

	if(!pte) return -E_NO_MEM;
f01017dc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;

	if(*pte & PTE_P) page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f01017e1:	83 c4 1c             	add    $0x1c,%esp
f01017e4:	5b                   	pop    %ebx
f01017e5:	5e                   	pop    %esi
f01017e6:	5f                   	pop    %edi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    

f01017e9 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01017e9:	55                   	push   %ebp
f01017ea:	89 e5                	mov    %esp,%ebp
f01017ec:	53                   	push   %ebx
f01017ed:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size = ROUNDUP(size, PGSIZE);
f01017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017f3:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01017f9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if((base + size) > MMIOLIM) {
f01017ff:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101805:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101808:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010180d:	76 1c                	jbe    f010182b <mmio_map_region+0x42>
		panic("MMIO overflow!");
f010180f:	c7 44 24 08 ae 7e 10 	movl   $0xf0107eae,0x8(%esp)
f0101816:	f0 
f0101817:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f010181e:	00 
f010181f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
	}

	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010182b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101832:	00 
f0101833:	8b 45 08             	mov    0x8(%ebp),%eax
f0101836:	89 04 24             	mov    %eax,(%esp)
f0101839:	89 d9                	mov    %ebx,%ecx
f010183b:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101840:	e8 de fd ff ff       	call   f0101623 <boot_map_region>
	uintptr_t ret = base;
f0101845:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base + size;
f010184a:	01 c3                	add    %eax,%ebx
f010184c:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300

	return (void *) ret;
}
f0101852:	83 c4 14             	add    $0x14,%esp
f0101855:	5b                   	pop    %ebx
f0101856:	5d                   	pop    %ebp
f0101857:	c3                   	ret    

f0101858 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101858:	55                   	push   %ebp
f0101859:	89 e5                	mov    %esp,%ebp
f010185b:	57                   	push   %edi
f010185c:	56                   	push   %esi
f010185d:	53                   	push   %ebx
f010185e:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101861:	b8 15 00 00 00       	mov    $0x15,%eax
f0101866:	e8 bd f6 ff ff       	call   f0100f28 <nvram_read>
f010186b:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010186d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101872:	e8 b1 f6 ff ff       	call   f0100f28 <nvram_read>
f0101877:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101879:	b8 34 00 00 00       	mov    $0x34,%eax
f010187e:	e8 a5 f6 ff ff       	call   f0100f28 <nvram_read>
f0101883:	c1 e0 06             	shl    $0x6,%eax
f0101886:	89 c2                	mov    %eax,%edx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f0101888:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010188e:	85 d2                	test   %edx,%edx
f0101890:	75 0b                	jne    f010189d <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101892:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101898:	85 f6                	test   %esi,%esi
f010189a:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010189d:	89 c2                	mov    %eax,%edx
f010189f:	c1 ea 02             	shr    $0x2,%edx
f01018a2:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01018a8:	89 da                	mov    %ebx,%edx
f01018aa:	c1 ea 02             	shr    $0x2,%edx
f01018ad:	89 15 44 12 23 f0    	mov    %edx,0xf0231244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018b3:	89 c2                	mov    %eax,%edx
f01018b5:	29 da                	sub    %ebx,%edx
f01018b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018c3:	c7 04 24 94 75 10 f0 	movl   $0xf0107594,(%esp)
f01018ca:	e8 bc 29 00 00       	call   f010428b <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01018cf:	b8 00 10 00 00       	mov    $0x1000,%eax
f01018d4:	e8 17 f6 ff ff       	call   f0100ef0 <boot_alloc>
f01018d9:	a3 8c 1e 23 f0       	mov    %eax,0xf0231e8c
	memset(kern_pgdir, 0, PGSIZE);
f01018de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018e5:	00 
f01018e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018ed:	00 
f01018ee:	89 04 24             	mov    %eax,(%esp)
f01018f1:	e8 e1 45 00 00       	call   f0105ed7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018f6:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01018fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101900:	77 20                	ja     f0101922 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101902:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101906:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f010190d:	f0 
f010190e:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101915:	00 
f0101916:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010191d:	e8 1e e7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101922:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101928:	83 ca 05             	or     $0x5,%edx
f010192b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101931:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101936:	c1 e0 03             	shl    $0x3,%eax
f0101939:	e8 b2 f5 ff ff       	call   f0100ef0 <boot_alloc>
f010193e:	a3 90 1e 23 f0       	mov    %eax,0xf0231e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101943:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0101949:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101950:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101954:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010195b:	00 
f010195c:	89 04 24             	mov    %eax,(%esp)
f010195f:	e8 73 45 00 00       	call   f0105ed7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101964:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101969:	e8 82 f5 ff ff       	call   f0100ef0 <boot_alloc>
f010196e:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	memset(pages, 0, NENV*sizeof(struct Env));
f0101973:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010197a:	00 
f010197b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101982:	00 
f0101983:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0101988:	89 04 24             	mov    %eax,(%esp)
f010198b:	e8 47 45 00 00       	call   f0105ed7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101990:	e8 18 fa ff ff       	call   f01013ad <page_init>

	check_page_free_list(1);
f0101995:	b8 01 00 00 00       	mov    $0x1,%eax
f010199a:	e8 68 f6 ff ff       	call   f0101007 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010199f:	83 3d 90 1e 23 f0 00 	cmpl   $0x0,0xf0231e90
f01019a6:	75 1c                	jne    f01019c4 <mem_init+0x16c>
		panic("'pages' is a null pointer!");
f01019a8:	c7 44 24 08 bd 7e 10 	movl   $0xf0107ebd,0x8(%esp)
f01019af:	f0 
f01019b0:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f01019b7:	00 
f01019b8:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01019bf:	e8 7c e6 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019c4:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f01019c9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01019ce:	eb 05                	jmp    f01019d5 <mem_init+0x17d>
		++nfree;
f01019d0:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019d3:	8b 00                	mov    (%eax),%eax
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	75 f7                	jne    f01019d0 <mem_init+0x178>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e0:	e8 94 fa ff ff       	call   f0101479 <page_alloc>
f01019e5:	89 c7                	mov    %eax,%edi
f01019e7:	85 c0                	test   %eax,%eax
f01019e9:	75 24                	jne    f0101a0f <mem_init+0x1b7>
f01019eb:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f01019f2:	f0 
f01019f3:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01019fa:	f0 
f01019fb:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f0101a02:	00 
f0101a03:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101a0a:	e8 31 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a16:	e8 5e fa ff ff       	call   f0101479 <page_alloc>
f0101a1b:	89 c6                	mov    %eax,%esi
f0101a1d:	85 c0                	test   %eax,%eax
f0101a1f:	75 24                	jne    f0101a45 <mem_init+0x1ed>
f0101a21:	c7 44 24 0c ee 7e 10 	movl   $0xf0107eee,0xc(%esp)
f0101a28:	f0 
f0101a29:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101a30:	f0 
f0101a31:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101a38:	00 
f0101a39:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101a40:	e8 fb e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a4c:	e8 28 fa ff ff       	call   f0101479 <page_alloc>
f0101a51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a54:	85 c0                	test   %eax,%eax
f0101a56:	75 24                	jne    f0101a7c <mem_init+0x224>
f0101a58:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f0101a5f:	f0 
f0101a60:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101a67:	f0 
f0101a68:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101a6f:	00 
f0101a70:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101a77:	e8 c4 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a7c:	39 f7                	cmp    %esi,%edi
f0101a7e:	75 24                	jne    f0101aa4 <mem_init+0x24c>
f0101a80:	c7 44 24 0c 1a 7f 10 	movl   $0xf0107f1a,0xc(%esp)
f0101a87:	f0 
f0101a88:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101a8f:	f0 
f0101a90:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0101a97:	00 
f0101a98:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101a9f:	e8 9c e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aa4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aa7:	39 c6                	cmp    %eax,%esi
f0101aa9:	74 04                	je     f0101aaf <mem_init+0x257>
f0101aab:	39 c7                	cmp    %eax,%edi
f0101aad:	75 24                	jne    f0101ad3 <mem_init+0x27b>
f0101aaf:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f0101ab6:	f0 
f0101ab7:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101abe:	f0 
f0101abf:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101ac6:	00 
f0101ac7:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101ace:	e8 6d e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ad3:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101ad9:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101ade:	c1 e0 0c             	shl    $0xc,%eax
f0101ae1:	89 f9                	mov    %edi,%ecx
f0101ae3:	29 d1                	sub    %edx,%ecx
f0101ae5:	c1 f9 03             	sar    $0x3,%ecx
f0101ae8:	c1 e1 0c             	shl    $0xc,%ecx
f0101aeb:	39 c1                	cmp    %eax,%ecx
f0101aed:	72 24                	jb     f0101b13 <mem_init+0x2bb>
f0101aef:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101b0e:	e8 2d e5 ff ff       	call   f0100040 <_panic>
f0101b13:	89 f1                	mov    %esi,%ecx
f0101b15:	29 d1                	sub    %edx,%ecx
f0101b17:	c1 f9 03             	sar    $0x3,%ecx
f0101b1a:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b1d:	39 c8                	cmp    %ecx,%eax
f0101b1f:	77 24                	ja     f0101b45 <mem_init+0x2ed>
f0101b21:	c7 44 24 0c 49 7f 10 	movl   $0xf0107f49,0xc(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101b30:	f0 
f0101b31:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101b38:	00 
f0101b39:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101b40:	e8 fb e4 ff ff       	call   f0100040 <_panic>
f0101b45:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b48:	29 d1                	sub    %edx,%ecx
f0101b4a:	89 ca                	mov    %ecx,%edx
f0101b4c:	c1 fa 03             	sar    $0x3,%edx
f0101b4f:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101b52:	39 d0                	cmp    %edx,%eax
f0101b54:	77 24                	ja     f0101b7a <mem_init+0x322>
f0101b56:	c7 44 24 0c 66 7f 10 	movl   $0xf0107f66,0xc(%esp)
f0101b5d:	f0 
f0101b5e:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101b65:	f0 
f0101b66:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101b6d:	00 
f0101b6e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101b75:	e8 c6 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b7a:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101b7f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b82:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f0101b89:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b93:	e8 e1 f8 ff ff       	call   f0101479 <page_alloc>
f0101b98:	85 c0                	test   %eax,%eax
f0101b9a:	74 24                	je     f0101bc0 <mem_init+0x368>
f0101b9c:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f0101ba3:	f0 
f0101ba4:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101bab:	f0 
f0101bac:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0101bb3:	00 
f0101bb4:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101bbb:	e8 80 e4 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101bc0:	89 3c 24             	mov    %edi,(%esp)
f0101bc3:	e8 3c f9 ff ff       	call   f0101504 <page_free>
	page_free(pp1);
f0101bc8:	89 34 24             	mov    %esi,(%esp)
f0101bcb:	e8 34 f9 ff ff       	call   f0101504 <page_free>
	page_free(pp2);
f0101bd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bd3:	89 04 24             	mov    %eax,(%esp)
f0101bd6:	e8 29 f9 ff ff       	call   f0101504 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be2:	e8 92 f8 ff ff       	call   f0101479 <page_alloc>
f0101be7:	89 c6                	mov    %eax,%esi
f0101be9:	85 c0                	test   %eax,%eax
f0101beb:	75 24                	jne    f0101c11 <mem_init+0x3b9>
f0101bed:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101bfc:	f0 
f0101bfd:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101c04:	00 
f0101c05:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101c0c:	e8 2f e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c18:	e8 5c f8 ff ff       	call   f0101479 <page_alloc>
f0101c1d:	89 c7                	mov    %eax,%edi
f0101c1f:	85 c0                	test   %eax,%eax
f0101c21:	75 24                	jne    f0101c47 <mem_init+0x3ef>
f0101c23:	c7 44 24 0c ee 7e 10 	movl   $0xf0107eee,0xc(%esp)
f0101c2a:	f0 
f0101c2b:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101c3a:	00 
f0101c3b:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101c42:	e8 f9 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c4e:	e8 26 f8 ff ff       	call   f0101479 <page_alloc>
f0101c53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c56:	85 c0                	test   %eax,%eax
f0101c58:	75 24                	jne    f0101c7e <mem_init+0x426>
f0101c5a:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101c69:	f0 
f0101c6a:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101c71:	00 
f0101c72:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101c79:	e8 c2 e3 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c7e:	39 fe                	cmp    %edi,%esi
f0101c80:	75 24                	jne    f0101ca6 <mem_init+0x44e>
f0101c82:	c7 44 24 0c 1a 7f 10 	movl   $0xf0107f1a,0xc(%esp)
f0101c89:	f0 
f0101c8a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101c91:	f0 
f0101c92:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101c99:	00 
f0101c9a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101ca1:	e8 9a e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ca6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ca9:	39 c7                	cmp    %eax,%edi
f0101cab:	74 04                	je     f0101cb1 <mem_init+0x459>
f0101cad:	39 c6                	cmp    %eax,%esi
f0101caf:	75 24                	jne    f0101cd5 <mem_init+0x47d>
f0101cb1:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f0101cb8:	f0 
f0101cb9:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101cc8:	00 
f0101cc9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101cd0:	e8 6b e3 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cdc:	e8 98 f7 ff ff       	call   f0101479 <page_alloc>
f0101ce1:	85 c0                	test   %eax,%eax
f0101ce3:	74 24                	je     f0101d09 <mem_init+0x4b1>
f0101ce5:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101cfc:	00 
f0101cfd:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101d04:	e8 37 e3 ff ff       	call   f0100040 <_panic>
f0101d09:	89 f0                	mov    %esi,%eax
f0101d0b:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101d11:	c1 f8 03             	sar    $0x3,%eax
f0101d14:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d17:	89 c2                	mov    %eax,%edx
f0101d19:	c1 ea 0c             	shr    $0xc,%edx
f0101d1c:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101d22:	72 20                	jb     f0101d44 <mem_init+0x4ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d28:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101d37:	00 
f0101d38:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0101d3f:	e8 fc e2 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d44:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d4b:	00 
f0101d4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101d53:	00 
	return (void *)(pa + KERNBASE);
f0101d54:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d59:	89 04 24             	mov    %eax,(%esp)
f0101d5c:	e8 76 41 00 00       	call   f0105ed7 <memset>
	page_free(pp0);
f0101d61:	89 34 24             	mov    %esi,(%esp)
f0101d64:	e8 9b f7 ff ff       	call   f0101504 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d70:	e8 04 f7 ff ff       	call   f0101479 <page_alloc>
f0101d75:	85 c0                	test   %eax,%eax
f0101d77:	75 24                	jne    f0101d9d <mem_init+0x545>
f0101d79:	c7 44 24 0c 92 7f 10 	movl   $0xf0107f92,0xc(%esp)
f0101d80:	f0 
f0101d81:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101d88:	f0 
f0101d89:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101d90:	00 
f0101d91:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101d98:	e8 a3 e2 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101d9d:	39 c6                	cmp    %eax,%esi
f0101d9f:	74 24                	je     f0101dc5 <mem_init+0x56d>
f0101da1:	c7 44 24 0c b0 7f 10 	movl   $0xf0107fb0,0xc(%esp)
f0101da8:	f0 
f0101da9:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101db0:	f0 
f0101db1:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101db8:	00 
f0101db9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101dc0:	e8 7b e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dc5:	89 f0                	mov    %esi,%eax
f0101dc7:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101dcd:	c1 f8 03             	sar    $0x3,%eax
f0101dd0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dd3:	89 c2                	mov    %eax,%edx
f0101dd5:	c1 ea 0c             	shr    $0xc,%edx
f0101dd8:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101dde:	72 20                	jb     f0101e00 <mem_init+0x5a8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101de0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101de4:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0101deb:	f0 
f0101dec:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101df3:	00 
f0101df4:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0101dfb:	e8 40 e2 ff ff       	call   f0100040 <_panic>
f0101e00:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101e06:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e0c:	80 38 00             	cmpb   $0x0,(%eax)
f0101e0f:	74 24                	je     f0101e35 <mem_init+0x5dd>
f0101e11:	c7 44 24 0c c0 7f 10 	movl   $0xf0107fc0,0xc(%esp)
f0101e18:	f0 
f0101e19:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101e20:	f0 
f0101e21:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101e28:	00 
f0101e29:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101e30:	e8 0b e2 ff ff       	call   f0100040 <_panic>
f0101e35:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101e38:	39 d0                	cmp    %edx,%eax
f0101e3a:	75 d0                	jne    f0101e0c <mem_init+0x5b4>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e3f:	a3 40 12 23 f0       	mov    %eax,0xf0231240

	// free the pages we took
	page_free(pp0);
f0101e44:	89 34 24             	mov    %esi,(%esp)
f0101e47:	e8 b8 f6 ff ff       	call   f0101504 <page_free>
	page_free(pp1);
f0101e4c:	89 3c 24             	mov    %edi,(%esp)
f0101e4f:	e8 b0 f6 ff ff       	call   f0101504 <page_free>
	page_free(pp2);
f0101e54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e57:	89 04 24             	mov    %eax,(%esp)
f0101e5a:	e8 a5 f6 ff ff       	call   f0101504 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e5f:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101e64:	eb 05                	jmp    f0101e6b <mem_init+0x613>
		--nfree;
f0101e66:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e69:	8b 00                	mov    (%eax),%eax
f0101e6b:	85 c0                	test   %eax,%eax
f0101e6d:	75 f7                	jne    f0101e66 <mem_init+0x60e>
		--nfree;
	assert(nfree == 0);
f0101e6f:	85 db                	test   %ebx,%ebx
f0101e71:	74 24                	je     f0101e97 <mem_init+0x63f>
f0101e73:	c7 44 24 0c ca 7f 10 	movl   $0xf0107fca,0xc(%esp)
f0101e7a:	f0 
f0101e7b:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101e82:	f0 
f0101e83:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101e8a:	00 
f0101e8b:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101e92:	e8 a9 e1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e97:	c7 04 24 f0 75 10 f0 	movl   $0xf01075f0,(%esp)
f0101e9e:	e8 e8 23 00 00       	call   f010428b <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ea3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eaa:	e8 ca f5 ff ff       	call   f0101479 <page_alloc>
f0101eaf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101eb2:	85 c0                	test   %eax,%eax
f0101eb4:	75 24                	jne    f0101eda <mem_init+0x682>
f0101eb6:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f0101ebd:	f0 
f0101ebe:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101ec5:	f0 
f0101ec6:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0101ecd:	00 
f0101ece:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101ed5:	e8 66 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101eda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ee1:	e8 93 f5 ff ff       	call   f0101479 <page_alloc>
f0101ee6:	89 c3                	mov    %eax,%ebx
f0101ee8:	85 c0                	test   %eax,%eax
f0101eea:	75 24                	jne    f0101f10 <mem_init+0x6b8>
f0101eec:	c7 44 24 0c ee 7e 10 	movl   $0xf0107eee,0xc(%esp)
f0101ef3:	f0 
f0101ef4:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101efb:	f0 
f0101efc:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101f03:	00 
f0101f04:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101f0b:	e8 30 e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f17:	e8 5d f5 ff ff       	call   f0101479 <page_alloc>
f0101f1c:	89 c6                	mov    %eax,%esi
f0101f1e:	85 c0                	test   %eax,%eax
f0101f20:	75 24                	jne    f0101f46 <mem_init+0x6ee>
f0101f22:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f0101f29:	f0 
f0101f2a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101f31:	f0 
f0101f32:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101f39:	00 
f0101f3a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101f41:	e8 fa e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f46:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101f49:	75 24                	jne    f0101f6f <mem_init+0x717>
f0101f4b:	c7 44 24 0c 1a 7f 10 	movl   $0xf0107f1a,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101f6a:	e8 d1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f6f:	39 c3                	cmp    %eax,%ebx
f0101f71:	74 05                	je     f0101f78 <mem_init+0x720>
f0101f73:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101f76:	75 24                	jne    f0101f9c <mem_init+0x744>
f0101f78:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101f87:	f0 
f0101f88:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101f8f:	00 
f0101f90:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101f97:	e8 a4 e0 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f9c:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101fa1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101fa4:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f0101fab:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101fae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb5:	e8 bf f4 ff ff       	call   f0101479 <page_alloc>
f0101fba:	85 c0                	test   %eax,%eax
f0101fbc:	74 24                	je     f0101fe2 <mem_init+0x78a>
f0101fbe:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f0101fc5:	f0 
f0101fc6:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0101fcd:	f0 
f0101fce:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101fd5:	00 
f0101fd6:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0101fdd:	e8 5e e0 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101fe2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fe9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ff0:	00 
f0101ff1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101ff6:	89 04 24             	mov    %eax,(%esp)
f0101ff9:	e8 85 f6 ff ff       	call   f0101683 <page_lookup>
f0101ffe:	85 c0                	test   %eax,%eax
f0102000:	74 24                	je     f0102026 <mem_init+0x7ce>
f0102002:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f0102009:	f0 
f010200a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102011:	f0 
f0102012:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102019:	00 
f010201a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102021:	e8 1a e0 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102026:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010202d:	00 
f010202e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102035:	00 
f0102036:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010203a:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010203f:	89 04 24             	mov    %eax,(%esp)
f0102042:	e8 33 f7 ff ff       	call   f010177a <page_insert>
f0102047:	85 c0                	test   %eax,%eax
f0102049:	78 24                	js     f010206f <mem_init+0x817>
f010204b:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f0102052:	f0 
f0102053:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010205a:	f0 
f010205b:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102062:	00 
f0102063:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010206a:	e8 d1 df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010206f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102072:	89 04 24             	mov    %eax,(%esp)
f0102075:	e8 8a f4 ff ff       	call   f0101504 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010207a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102081:	00 
f0102082:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102089:	00 
f010208a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010208e:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102093:	89 04 24             	mov    %eax,(%esp)
f0102096:	e8 df f6 ff ff       	call   f010177a <page_insert>
f010209b:	85 c0                	test   %eax,%eax
f010209d:	74 24                	je     f01020c3 <mem_init+0x86b>
f010209f:	c7 44 24 0c 78 76 10 	movl   $0xf0107678,0xc(%esp)
f01020a6:	f0 
f01020a7:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01020ae:	f0 
f01020af:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01020b6:	00 
f01020b7:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01020be:	e8 7d df ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020c3:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020c9:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f01020ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020d1:	8b 17                	mov    (%edi),%edx
f01020d3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020d9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01020dc:	29 c1                	sub    %eax,%ecx
f01020de:	89 c8                	mov    %ecx,%eax
f01020e0:	c1 f8 03             	sar    $0x3,%eax
f01020e3:	c1 e0 0c             	shl    $0xc,%eax
f01020e6:	39 c2                	cmp    %eax,%edx
f01020e8:	74 24                	je     f010210e <mem_init+0x8b6>
f01020ea:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f01020f1:	f0 
f01020f2:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01020f9:	f0 
f01020fa:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102101:	00 
f0102102:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102109:	e8 32 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010210e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102113:	89 f8                	mov    %edi,%eax
f0102115:	e8 7e ee ff ff       	call   f0100f98 <check_va2pa>
f010211a:	89 da                	mov    %ebx,%edx
f010211c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010211f:	c1 fa 03             	sar    $0x3,%edx
f0102122:	c1 e2 0c             	shl    $0xc,%edx
f0102125:	39 d0                	cmp    %edx,%eax
f0102127:	74 24                	je     f010214d <mem_init+0x8f5>
f0102129:	c7 44 24 0c d0 76 10 	movl   $0xf01076d0,0xc(%esp)
f0102130:	f0 
f0102131:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102138:	f0 
f0102139:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102140:	00 
f0102141:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102148:	e8 f3 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010214d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102152:	74 24                	je     f0102178 <mem_init+0x920>
f0102154:	c7 44 24 0c d5 7f 10 	movl   $0xf0107fd5,0xc(%esp)
f010215b:	f0 
f010215c:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102163:	f0 
f0102164:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f010216b:	00 
f010216c:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102173:	e8 c8 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102178:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010217b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102180:	74 24                	je     f01021a6 <mem_init+0x94e>
f0102182:	c7 44 24 0c e6 7f 10 	movl   $0xf0107fe6,0xc(%esp)
f0102189:	f0 
f010218a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102191:	f0 
f0102192:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102199:	00 
f010219a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01021a1:	e8 9a de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021a6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021ad:	00 
f01021ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021b5:	00 
f01021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021ba:	89 3c 24             	mov    %edi,(%esp)
f01021bd:	e8 b8 f5 ff ff       	call   f010177a <page_insert>
f01021c2:	85 c0                	test   %eax,%eax
f01021c4:	74 24                	je     f01021ea <mem_init+0x992>
f01021c6:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f01021cd:	f0 
f01021ce:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01021d5:	f0 
f01021d6:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01021dd:	00 
f01021de:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01021e5:	e8 56 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021ea:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ef:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01021f4:	e8 9f ed ff ff       	call   f0100f98 <check_va2pa>
f01021f9:	89 f2                	mov    %esi,%edx
f01021fb:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102201:	c1 fa 03             	sar    $0x3,%edx
f0102204:	c1 e2 0c             	shl    $0xc,%edx
f0102207:	39 d0                	cmp    %edx,%eax
f0102209:	74 24                	je     f010222f <mem_init+0x9d7>
f010220b:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f0102212:	f0 
f0102213:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010221a:	f0 
f010221b:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102222:	00 
f0102223:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010222a:	e8 11 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010222f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102234:	74 24                	je     f010225a <mem_init+0xa02>
f0102236:	c7 44 24 0c f7 7f 10 	movl   $0xf0107ff7,0xc(%esp)
f010223d:	f0 
f010223e:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102245:	f0 
f0102246:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f010224d:	00 
f010224e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102255:	e8 e6 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010225a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102261:	e8 13 f2 ff ff       	call   f0101479 <page_alloc>
f0102266:	85 c0                	test   %eax,%eax
f0102268:	74 24                	je     f010228e <mem_init+0xa36>
f010226a:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f0102271:	f0 
f0102272:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102279:	f0 
f010227a:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102281:	00 
f0102282:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102289:	e8 b2 dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010228e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102295:	00 
f0102296:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010229d:	00 
f010229e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022a2:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01022a7:	89 04 24             	mov    %eax,(%esp)
f01022aa:	e8 cb f4 ff ff       	call   f010177a <page_insert>
f01022af:	85 c0                	test   %eax,%eax
f01022b1:	74 24                	je     f01022d7 <mem_init+0xa7f>
f01022b3:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f01022ba:	f0 
f01022bb:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01022c2:	f0 
f01022c3:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f01022ca:	00 
f01022cb:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01022d2:	e8 69 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022d7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022dc:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01022e1:	e8 b2 ec ff ff       	call   f0100f98 <check_va2pa>
f01022e6:	89 f2                	mov    %esi,%edx
f01022e8:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01022ee:	c1 fa 03             	sar    $0x3,%edx
f01022f1:	c1 e2 0c             	shl    $0xc,%edx
f01022f4:	39 d0                	cmp    %edx,%eax
f01022f6:	74 24                	je     f010231c <mem_init+0xac4>
f01022f8:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102307:	f0 
f0102308:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010230f:	00 
f0102310:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102317:	e8 24 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010231c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102321:	74 24                	je     f0102347 <mem_init+0xaef>
f0102323:	c7 44 24 0c f7 7f 10 	movl   $0xf0107ff7,0xc(%esp)
f010232a:	f0 
f010232b:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102332:	f0 
f0102333:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010233a:	00 
f010233b:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102342:	e8 f9 dc ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102347:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010234e:	e8 26 f1 ff ff       	call   f0101479 <page_alloc>
f0102353:	85 c0                	test   %eax,%eax
f0102355:	74 24                	je     f010237b <mem_init+0xb23>
f0102357:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f010235e:	f0 
f010235f:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102366:	f0 
f0102367:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f010236e:	00 
f010236f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102376:	e8 c5 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010237b:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0102381:	8b 02                	mov    (%edx),%eax
f0102383:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102388:	89 c1                	mov    %eax,%ecx
f010238a:	c1 e9 0c             	shr    $0xc,%ecx
f010238d:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0102393:	72 20                	jb     f01023b5 <mem_init+0xb5d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102395:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102399:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01023a0:	f0 
f01023a1:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01023a8:	00 
f01023a9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01023b0:	e8 8b dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01023b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023c4:	00 
f01023c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023cc:	00 
f01023cd:	89 14 24             	mov    %edx,(%esp)
f01023d0:	e8 ae f1 ff ff       	call   f0101583 <pgdir_walk>
f01023d5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023d8:	8d 51 04             	lea    0x4(%ecx),%edx
f01023db:	39 d0                	cmp    %edx,%eax
f01023dd:	74 24                	je     f0102403 <mem_init+0xbab>
f01023df:	c7 44 24 0c 6c 77 10 	movl   $0xf010776c,0xc(%esp)
f01023e6:	f0 
f01023e7:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01023ee:	f0 
f01023ef:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f01023f6:	00 
f01023f7:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01023fe:	e8 3d dc ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102403:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010240a:	00 
f010240b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102412:	00 
f0102413:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102417:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010241c:	89 04 24             	mov    %eax,(%esp)
f010241f:	e8 56 f3 ff ff       	call   f010177a <page_insert>
f0102424:	85 c0                	test   %eax,%eax
f0102426:	74 24                	je     f010244c <mem_init+0xbf4>
f0102428:	c7 44 24 0c ac 77 10 	movl   $0xf01077ac,0xc(%esp)
f010242f:	f0 
f0102430:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102437:	f0 
f0102438:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f010243f:	00 
f0102440:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102447:	e8 f4 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010244c:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102452:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102457:	89 f8                	mov    %edi,%eax
f0102459:	e8 3a eb ff ff       	call   f0100f98 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010245e:	89 f2                	mov    %esi,%edx
f0102460:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102466:	c1 fa 03             	sar    $0x3,%edx
f0102469:	c1 e2 0c             	shl    $0xc,%edx
f010246c:	39 d0                	cmp    %edx,%eax
f010246e:	74 24                	je     f0102494 <mem_init+0xc3c>
f0102470:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f0102477:	f0 
f0102478:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010247f:	f0 
f0102480:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102487:	00 
f0102488:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010248f:	e8 ac db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102494:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102499:	74 24                	je     f01024bf <mem_init+0xc67>
f010249b:	c7 44 24 0c f7 7f 10 	movl   $0xf0107ff7,0xc(%esp)
f01024a2:	f0 
f01024a3:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01024aa:	f0 
f01024ab:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01024b2:	00 
f01024b3:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01024ba:	e8 81 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024c6:	00 
f01024c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024ce:	00 
f01024cf:	89 3c 24             	mov    %edi,(%esp)
f01024d2:	e8 ac f0 ff ff       	call   f0101583 <pgdir_walk>
f01024d7:	f6 00 04             	testb  $0x4,(%eax)
f01024da:	75 24                	jne    f0102500 <mem_init+0xca8>
f01024dc:	c7 44 24 0c ec 77 10 	movl   $0xf01077ec,0xc(%esp)
f01024e3:	f0 
f01024e4:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01024eb:	f0 
f01024ec:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f01024f3:	00 
f01024f4:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01024fb:	e8 40 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102500:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102505:	f6 00 04             	testb  $0x4,(%eax)
f0102508:	75 24                	jne    f010252e <mem_init+0xcd6>
f010250a:	c7 44 24 0c 08 80 10 	movl   $0xf0108008,0xc(%esp)
f0102511:	f0 
f0102512:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102519:	f0 
f010251a:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0102521:	00 
f0102522:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102529:	e8 12 db ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010252e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102535:	00 
f0102536:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010253d:	00 
f010253e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102542:	89 04 24             	mov    %eax,(%esp)
f0102545:	e8 30 f2 ff ff       	call   f010177a <page_insert>
f010254a:	85 c0                	test   %eax,%eax
f010254c:	74 24                	je     f0102572 <mem_init+0xd1a>
f010254e:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f0102555:	f0 
f0102556:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010255d:	f0 
f010255e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102565:	00 
f0102566:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102572:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102579:	00 
f010257a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102581:	00 
f0102582:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102587:	89 04 24             	mov    %eax,(%esp)
f010258a:	e8 f4 ef ff ff       	call   f0101583 <pgdir_walk>
f010258f:	f6 00 02             	testb  $0x2,(%eax)
f0102592:	75 24                	jne    f01025b8 <mem_init+0xd60>
f0102594:	c7 44 24 0c 20 78 10 	movl   $0xf0107820,0xc(%esp)
f010259b:	f0 
f010259c:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01025a3:	f0 
f01025a4:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01025ab:	00 
f01025ac:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01025b3:	e8 88 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025bf:	00 
f01025c0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025c7:	00 
f01025c8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01025cd:	89 04 24             	mov    %eax,(%esp)
f01025d0:	e8 ae ef ff ff       	call   f0101583 <pgdir_walk>
f01025d5:	f6 00 04             	testb  $0x4,(%eax)
f01025d8:	74 24                	je     f01025fe <mem_init+0xda6>
f01025da:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01025e9:	f0 
f01025ea:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01025f1:	00 
f01025f2:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01025f9:	e8 42 da ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025fe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102605:	00 
f0102606:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010260d:	00 
f010260e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102611:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102615:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010261a:	89 04 24             	mov    %eax,(%esp)
f010261d:	e8 58 f1 ff ff       	call   f010177a <page_insert>
f0102622:	85 c0                	test   %eax,%eax
f0102624:	78 24                	js     f010264a <mem_init+0xdf2>
f0102626:	c7 44 24 0c 8c 78 10 	movl   $0xf010788c,0xc(%esp)
f010262d:	f0 
f010262e:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102635:	f0 
f0102636:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010263d:	00 
f010263e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102645:	e8 f6 d9 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010264a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102651:	00 
f0102652:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102659:	00 
f010265a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010265e:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102663:	89 04 24             	mov    %eax,(%esp)
f0102666:	e8 0f f1 ff ff       	call   f010177a <page_insert>
f010266b:	85 c0                	test   %eax,%eax
f010266d:	74 24                	je     f0102693 <mem_init+0xe3b>
f010266f:	c7 44 24 0c c4 78 10 	movl   $0xf01078c4,0xc(%esp)
f0102676:	f0 
f0102677:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010267e:	f0 
f010267f:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102686:	00 
f0102687:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010268e:	e8 ad d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102693:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010269a:	00 
f010269b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026a2:	00 
f01026a3:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01026a8:	89 04 24             	mov    %eax,(%esp)
f01026ab:	e8 d3 ee ff ff       	call   f0101583 <pgdir_walk>
f01026b0:	f6 00 04             	testb  $0x4,(%eax)
f01026b3:	74 24                	je     f01026d9 <mem_init+0xe81>
f01026b5:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f01026bc:	f0 
f01026bd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01026c4:	f0 
f01026c5:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01026cc:	00 
f01026cd:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01026d4:	e8 67 d9 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026d9:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f01026df:	ba 00 00 00 00       	mov    $0x0,%edx
f01026e4:	89 f8                	mov    %edi,%eax
f01026e6:	e8 ad e8 ff ff       	call   f0100f98 <check_va2pa>
f01026eb:	89 c1                	mov    %eax,%ecx
f01026ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026f0:	89 d8                	mov    %ebx,%eax
f01026f2:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01026f8:	c1 f8 03             	sar    $0x3,%eax
f01026fb:	c1 e0 0c             	shl    $0xc,%eax
f01026fe:	39 c1                	cmp    %eax,%ecx
f0102700:	74 24                	je     f0102726 <mem_init+0xece>
f0102702:	c7 44 24 0c 00 79 10 	movl   $0xf0107900,0xc(%esp)
f0102709:	f0 
f010270a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102711:	f0 
f0102712:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102719:	00 
f010271a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102721:	e8 1a d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102726:	ba 00 10 00 00       	mov    $0x1000,%edx
f010272b:	89 f8                	mov    %edi,%eax
f010272d:	e8 66 e8 ff ff       	call   f0100f98 <check_va2pa>
f0102732:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102735:	74 24                	je     f010275b <mem_init+0xf03>
f0102737:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f010273e:	f0 
f010273f:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102746:	f0 
f0102747:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010274e:	00 
f010274f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102756:	e8 e5 d8 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010275b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102760:	74 24                	je     f0102786 <mem_init+0xf2e>
f0102762:	c7 44 24 0c 1e 80 10 	movl   $0xf010801e,0xc(%esp)
f0102769:	f0 
f010276a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102771:	f0 
f0102772:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102779:	00 
f010277a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102786:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010278b:	74 24                	je     f01027b1 <mem_init+0xf59>
f010278d:	c7 44 24 0c 2f 80 10 	movl   $0xf010802f,0xc(%esp)
f0102794:	f0 
f0102795:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010279c:	f0 
f010279d:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01027a4:	00 
f01027a5:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01027ac:	e8 8f d8 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01027b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027b8:	e8 bc ec ff ff       	call   f0101479 <page_alloc>
f01027bd:	85 c0                	test   %eax,%eax
f01027bf:	74 04                	je     f01027c5 <mem_init+0xf6d>
f01027c1:	39 c6                	cmp    %eax,%esi
f01027c3:	74 24                	je     f01027e9 <mem_init+0xf91>
f01027c5:	c7 44 24 0c 5c 79 10 	movl   $0xf010795c,0xc(%esp)
f01027cc:	f0 
f01027cd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01027d4:	f0 
f01027d5:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01027dc:	00 
f01027dd:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01027e4:	e8 57 d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01027e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027f0:	00 
f01027f1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01027f6:	89 04 24             	mov    %eax,(%esp)
f01027f9:	e8 33 ef ff ff       	call   f0101731 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027fe:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102804:	ba 00 00 00 00       	mov    $0x0,%edx
f0102809:	89 f8                	mov    %edi,%eax
f010280b:	e8 88 e7 ff ff       	call   f0100f98 <check_va2pa>
f0102810:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102813:	74 24                	je     f0102839 <mem_init+0xfe1>
f0102815:	c7 44 24 0c 80 79 10 	movl   $0xf0107980,0xc(%esp)
f010281c:	f0 
f010281d:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102824:	f0 
f0102825:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f010282c:	00 
f010282d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102834:	e8 07 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102839:	ba 00 10 00 00       	mov    $0x1000,%edx
f010283e:	89 f8                	mov    %edi,%eax
f0102840:	e8 53 e7 ff ff       	call   f0100f98 <check_va2pa>
f0102845:	89 da                	mov    %ebx,%edx
f0102847:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f010284d:	c1 fa 03             	sar    $0x3,%edx
f0102850:	c1 e2 0c             	shl    $0xc,%edx
f0102853:	39 d0                	cmp    %edx,%eax
f0102855:	74 24                	je     f010287b <mem_init+0x1023>
f0102857:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f010285e:	f0 
f010285f:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102866:	f0 
f0102867:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f010286e:	00 
f010286f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102876:	e8 c5 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010287b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102880:	74 24                	je     f01028a6 <mem_init+0x104e>
f0102882:	c7 44 24 0c d5 7f 10 	movl   $0xf0107fd5,0xc(%esp)
f0102889:	f0 
f010288a:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102891:	f0 
f0102892:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102899:	00 
f010289a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01028a1:	e8 9a d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01028a6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028ab:	74 24                	je     f01028d1 <mem_init+0x1079>
f01028ad:	c7 44 24 0c 2f 80 10 	movl   $0xf010802f,0xc(%esp)
f01028b4:	f0 
f01028b5:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01028bc:	f0 
f01028bd:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01028c4:	00 
f01028c5:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01028cc:	e8 6f d7 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01028d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01028d8:	00 
f01028d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028e0:	00 
f01028e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01028e5:	89 3c 24             	mov    %edi,(%esp)
f01028e8:	e8 8d ee ff ff       	call   f010177a <page_insert>
f01028ed:	85 c0                	test   %eax,%eax
f01028ef:	74 24                	je     f0102915 <mem_init+0x10bd>
f01028f1:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f01028f8:	f0 
f01028f9:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102900:	f0 
f0102901:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102908:	00 
f0102909:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102910:	e8 2b d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102915:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010291a:	75 24                	jne    f0102940 <mem_init+0x10e8>
f010291c:	c7 44 24 0c 40 80 10 	movl   $0xf0108040,0xc(%esp)
f0102923:	f0 
f0102924:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010292b:	f0 
f010292c:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102933:	00 
f0102934:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010293b:	e8 00 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102940:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102943:	74 24                	je     f0102969 <mem_init+0x1111>
f0102945:	c7 44 24 0c 4c 80 10 	movl   $0xf010804c,0xc(%esp)
f010294c:	f0 
f010294d:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102954:	f0 
f0102955:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010295c:	00 
f010295d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102964:	e8 d7 d6 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102969:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102970:	00 
f0102971:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102976:	89 04 24             	mov    %eax,(%esp)
f0102979:	e8 b3 ed ff ff       	call   f0101731 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010297e:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102984:	ba 00 00 00 00       	mov    $0x0,%edx
f0102989:	89 f8                	mov    %edi,%eax
f010298b:	e8 08 e6 ff ff       	call   f0100f98 <check_va2pa>
f0102990:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102993:	74 24                	je     f01029b9 <mem_init+0x1161>
f0102995:	c7 44 24 0c 80 79 10 	movl   $0xf0107980,0xc(%esp)
f010299c:	f0 
f010299d:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01029a4:	f0 
f01029a5:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f01029ac:	00 
f01029ad:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01029b4:	e8 87 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01029b9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029be:	89 f8                	mov    %edi,%eax
f01029c0:	e8 d3 e5 ff ff       	call   f0100f98 <check_va2pa>
f01029c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029c8:	74 24                	je     f01029ee <mem_init+0x1196>
f01029ca:	c7 44 24 0c dc 79 10 	movl   $0xf01079dc,0xc(%esp)
f01029d1:	f0 
f01029d2:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01029d9:	f0 
f01029da:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f01029e1:	00 
f01029e2:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01029ee:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029f3:	74 24                	je     f0102a19 <mem_init+0x11c1>
f01029f5:	c7 44 24 0c 61 80 10 	movl   $0xf0108061,0xc(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102a0c:	00 
f0102a0d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102a14:	e8 27 d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a19:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a1e:	74 24                	je     f0102a44 <mem_init+0x11ec>
f0102a20:	c7 44 24 0c 2f 80 10 	movl   $0xf010802f,0xc(%esp)
f0102a27:	f0 
f0102a28:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102a2f:	f0 
f0102a30:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102a37:	00 
f0102a38:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102a3f:	e8 fc d5 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a4b:	e8 29 ea ff ff       	call   f0101479 <page_alloc>
f0102a50:	85 c0                	test   %eax,%eax
f0102a52:	74 04                	je     f0102a58 <mem_init+0x1200>
f0102a54:	39 c3                	cmp    %eax,%ebx
f0102a56:	74 24                	je     f0102a7c <mem_init+0x1224>
f0102a58:	c7 44 24 0c 04 7a 10 	movl   $0xf0107a04,0xc(%esp)
f0102a5f:	f0 
f0102a60:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102a67:	f0 
f0102a68:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102a6f:	00 
f0102a70:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102a77:	e8 c4 d5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a83:	e8 f1 e9 ff ff       	call   f0101479 <page_alloc>
f0102a88:	85 c0                	test   %eax,%eax
f0102a8a:	74 24                	je     f0102ab0 <mem_init+0x1258>
f0102a8c:	c7 44 24 0c 83 7f 10 	movl   $0xf0107f83,0xc(%esp)
f0102a93:	f0 
f0102a94:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102a9b:	f0 
f0102a9c:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102aa3:	00 
f0102aa4:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102aab:	e8 90 d5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ab0:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102ab5:	8b 08                	mov    (%eax),%ecx
f0102ab7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102abd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102ac0:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102ac6:	c1 fa 03             	sar    $0x3,%edx
f0102ac9:	c1 e2 0c             	shl    $0xc,%edx
f0102acc:	39 d1                	cmp    %edx,%ecx
f0102ace:	74 24                	je     f0102af4 <mem_init+0x129c>
f0102ad0:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f0102ad7:	f0 
f0102ad8:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102adf:	f0 
f0102ae0:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102ae7:	00 
f0102ae8:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102aef:	e8 4c d5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102af4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102afa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102afd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102b02:	74 24                	je     f0102b28 <mem_init+0x12d0>
f0102b04:	c7 44 24 0c e6 7f 10 	movl   $0xf0107fe6,0xc(%esp)
f0102b0b:	f0 
f0102b0c:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102b13:	f0 
f0102b14:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102b1b:	00 
f0102b1c:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102b23:	e8 18 d5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b2b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b31:	89 04 24             	mov    %eax,(%esp)
f0102b34:	e8 cb e9 ff ff       	call   f0101504 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b39:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b40:	00 
f0102b41:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b48:	00 
f0102b49:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102b4e:	89 04 24             	mov    %eax,(%esp)
f0102b51:	e8 2d ea ff ff       	call   f0101583 <pgdir_walk>
f0102b56:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102b5c:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0102b62:	8b 7a 04             	mov    0x4(%edx),%edi
f0102b65:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b6b:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0102b71:	89 f8                	mov    %edi,%eax
f0102b73:	c1 e8 0c             	shr    $0xc,%eax
f0102b76:	39 c8                	cmp    %ecx,%eax
f0102b78:	72 20                	jb     f0102b9a <mem_init+0x1342>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b7a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102b7e:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0102b85:	f0 
f0102b86:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102b8d:	00 
f0102b8e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102b95:	e8 a6 d4 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b9a:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102ba0:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102ba3:	74 24                	je     f0102bc9 <mem_init+0x1371>
f0102ba5:	c7 44 24 0c 72 80 10 	movl   $0xf0108072,0xc(%esp)
f0102bac:	f0 
f0102bad:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102bb4:	f0 
f0102bb5:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102bbc:	00 
f0102bbd:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102bc4:	e8 77 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102bc9:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102bd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bd3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd9:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102bdf:	c1 f8 03             	sar    $0x3,%eax
f0102be2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be5:	89 c2                	mov    %eax,%edx
f0102be7:	c1 ea 0c             	shr    $0xc,%edx
f0102bea:	39 d1                	cmp    %edx,%ecx
f0102bec:	77 20                	ja     f0102c0e <mem_init+0x13b6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bf2:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0102bf9:	f0 
f0102bfa:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c01:	00 
f0102c02:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0102c09:	e8 32 d4 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c0e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c15:	00 
f0102c16:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c1d:	00 
	return (void *)(pa + KERNBASE);
f0102c1e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c23:	89 04 24             	mov    %eax,(%esp)
f0102c26:	e8 ac 32 00 00       	call   f0105ed7 <memset>
	page_free(pp0);
f0102c2b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c2e:	89 3c 24             	mov    %edi,(%esp)
f0102c31:	e8 ce e8 ff ff       	call   f0101504 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c36:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c3d:	00 
f0102c3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c45:	00 
f0102c46:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102c4b:	89 04 24             	mov    %eax,(%esp)
f0102c4e:	e8 30 e9 ff ff       	call   f0101583 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c53:	89 fa                	mov    %edi,%edx
f0102c55:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102c5b:	c1 fa 03             	sar    $0x3,%edx
f0102c5e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c61:	89 d0                	mov    %edx,%eax
f0102c63:	c1 e8 0c             	shr    $0xc,%eax
f0102c66:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0102c6c:	72 20                	jb     f0102c8e <mem_init+0x1436>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c72:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0102c79:	f0 
f0102c7a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c81:	00 
f0102c82:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0102c89:	e8 b2 d3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102c8e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102c94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c97:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102c9d:	f6 00 01             	testb  $0x1,(%eax)
f0102ca0:	74 24                	je     f0102cc6 <mem_init+0x146e>
f0102ca2:	c7 44 24 0c 8a 80 10 	movl   $0xf010808a,0xc(%esp)
f0102ca9:	f0 
f0102caa:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102cb1:	f0 
f0102cb2:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102cb9:	00 
f0102cba:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102cc1:	e8 7a d3 ff ff       	call   f0100040 <_panic>
f0102cc6:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102cc9:	39 d0                	cmp    %edx,%eax
f0102ccb:	75 d0                	jne    f0102c9d <mem_init+0x1445>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102ccd:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102cd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cdb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102ce1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102ce4:	89 0d 40 12 23 f0    	mov    %ecx,0xf0231240

	// free the pages we took
	page_free(pp0);
f0102cea:	89 04 24             	mov    %eax,(%esp)
f0102ced:	e8 12 e8 ff ff       	call   f0101504 <page_free>
	page_free(pp1);
f0102cf2:	89 1c 24             	mov    %ebx,(%esp)
f0102cf5:	e8 0a e8 ff ff       	call   f0101504 <page_free>
	page_free(pp2);
f0102cfa:	89 34 24             	mov    %esi,(%esp)
f0102cfd:	e8 02 e8 ff ff       	call   f0101504 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102d02:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102d09:	00 
f0102d0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d11:	e8 d3 ea ff ff       	call   f01017e9 <mmio_map_region>
f0102d16:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102d18:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d1f:	00 
f0102d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d27:	e8 bd ea ff ff       	call   f01017e9 <mmio_map_region>
f0102d2c:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102d2e:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102d34:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102d39:	77 08                	ja     f0102d43 <mem_init+0x14eb>
f0102d3b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d41:	77 24                	ja     f0102d67 <mem_init+0x150f>
f0102d43:	c7 44 24 0c 28 7a 10 	movl   $0xf0107a28,0xc(%esp)
f0102d4a:	f0 
f0102d4b:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102d52:	f0 
f0102d53:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102d5a:	00 
f0102d5b:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102d62:	e8 d9 d2 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102d67:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102d6d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102d73:	77 08                	ja     f0102d7d <mem_init+0x1525>
f0102d75:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102d7b:	77 24                	ja     f0102da1 <mem_init+0x1549>
f0102d7d:	c7 44 24 0c 50 7a 10 	movl   $0xf0107a50,0xc(%esp)
f0102d84:	f0 
f0102d85:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102d8c:	f0 
f0102d8d:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102d94:	00 
f0102d95:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102d9c:	e8 9f d2 ff ff       	call   f0100040 <_panic>
f0102da1:	89 da                	mov    %ebx,%edx
f0102da3:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102da5:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102dab:	74 24                	je     f0102dd1 <mem_init+0x1579>
f0102dad:	c7 44 24 0c 78 7a 10 	movl   $0xf0107a78,0xc(%esp)
f0102db4:	f0 
f0102db5:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102dbc:	f0 
f0102dbd:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102dc4:	00 
f0102dc5:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102dcc:	e8 6f d2 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102dd1:	39 c6                	cmp    %eax,%esi
f0102dd3:	73 24                	jae    f0102df9 <mem_init+0x15a1>
f0102dd5:	c7 44 24 0c a1 80 10 	movl   $0xf01080a1,0xc(%esp)
f0102ddc:	f0 
f0102ddd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102de4:	f0 
f0102de5:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102dec:	00 
f0102ded:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102df4:	e8 47 d2 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102df9:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102dff:	89 da                	mov    %ebx,%edx
f0102e01:	89 f8                	mov    %edi,%eax
f0102e03:	e8 90 e1 ff ff       	call   f0100f98 <check_va2pa>
f0102e08:	85 c0                	test   %eax,%eax
f0102e0a:	74 24                	je     f0102e30 <mem_init+0x15d8>
f0102e0c:	c7 44 24 0c a0 7a 10 	movl   $0xf0107aa0,0xc(%esp)
f0102e13:	f0 
f0102e14:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102e1b:	f0 
f0102e1c:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102e23:	00 
f0102e24:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102e2b:	e8 10 d2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102e30:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102e36:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e39:	89 c2                	mov    %eax,%edx
f0102e3b:	89 f8                	mov    %edi,%eax
f0102e3d:	e8 56 e1 ff ff       	call   f0100f98 <check_va2pa>
f0102e42:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102e47:	74 24                	je     f0102e6d <mem_init+0x1615>
f0102e49:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f0102e50:	f0 
f0102e51:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102e58:	f0 
f0102e59:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102e60:	00 
f0102e61:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102e68:	e8 d3 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102e6d:	89 f2                	mov    %esi,%edx
f0102e6f:	89 f8                	mov    %edi,%eax
f0102e71:	e8 22 e1 ff ff       	call   f0100f98 <check_va2pa>
f0102e76:	85 c0                	test   %eax,%eax
f0102e78:	74 24                	je     f0102e9e <mem_init+0x1646>
f0102e7a:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f0102e81:	f0 
f0102e82:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102e89:	f0 
f0102e8a:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102e91:	00 
f0102e92:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102e99:	e8 a2 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102e9e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ea4:	89 f8                	mov    %edi,%eax
f0102ea6:	e8 ed e0 ff ff       	call   f0100f98 <check_va2pa>
f0102eab:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102eae:	74 24                	je     f0102ed4 <mem_init+0x167c>
f0102eb0:	c7 44 24 0c 18 7b 10 	movl   $0xf0107b18,0xc(%esp)
f0102eb7:	f0 
f0102eb8:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102ebf:	f0 
f0102ec0:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102ec7:	00 
f0102ec8:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102ed4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102edb:	00 
f0102edc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ee0:	89 3c 24             	mov    %edi,(%esp)
f0102ee3:	e8 9b e6 ff ff       	call   f0101583 <pgdir_walk>
f0102ee8:	f6 00 1a             	testb  $0x1a,(%eax)
f0102eeb:	75 24                	jne    f0102f11 <mem_init+0x16b9>
f0102eed:	c7 44 24 0c 44 7b 10 	movl   $0xf0107b44,0xc(%esp)
f0102ef4:	f0 
f0102ef5:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102f04:	00 
f0102f05:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102f0c:	e8 2f d1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f18:	00 
f0102f19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f1d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102f22:	89 04 24             	mov    %eax,(%esp)
f0102f25:	e8 59 e6 ff ff       	call   f0101583 <pgdir_walk>
f0102f2a:	f6 00 04             	testb  $0x4,(%eax)
f0102f2d:	74 24                	je     f0102f53 <mem_init+0x16fb>
f0102f2f:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f0102f36:	f0 
f0102f37:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0102f3e:	f0 
f0102f3f:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102f46:	00 
f0102f47:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102f4e:	e8 ed d0 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102f53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f5a:	00 
f0102f5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f5f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102f64:	89 04 24             	mov    %eax,(%esp)
f0102f67:	e8 17 e6 ff ff       	call   f0101583 <pgdir_walk>
f0102f6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102f72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f79:	00 
f0102f7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f81:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102f86:	89 04 24             	mov    %eax,(%esp)
f0102f89:	e8 f5 e5 ff ff       	call   f0101583 <pgdir_walk>
f0102f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102f94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f9b:	00 
f0102f9c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102fa0:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102fa5:	89 04 24             	mov    %eax,(%esp)
f0102fa8:	e8 d6 e5 ff ff       	call   f0101583 <pgdir_walk>
f0102fad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102fb3:	c7 04 24 b3 80 10 f0 	movl   $0xf01080b3,(%esp)
f0102fba:	e8 cc 12 00 00       	call   f010428b <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102fbf:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fc9:	77 20                	ja     f0102feb <mem_init+0x1793>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fcf:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0102fd6:	f0 
f0102fd7:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102fde:	00 
f0102fdf:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0102fe6:	e8 55 d0 ff ff       	call   f0100040 <_panic>
f0102feb:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102ff2:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ff3:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ff8:	89 04 24             	mov    %eax,(%esp)
f0102ffb:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103000:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103005:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010300a:	e8 14 e6 ff ff       	call   f0101623 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f010300f:	a1 48 12 23 f0       	mov    0xf0231248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103014:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103019:	77 20                	ja     f010303b <mem_init+0x17e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010301b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010301f:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103026:	f0 
f0103027:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f010302e:	00 
f010302f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103036:	e8 05 d0 ff ff       	call   f0100040 <_panic>
f010303b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103042:	00 
	return (physaddr_t)kva - KERNBASE;
f0103043:	05 00 00 00 10       	add    $0x10000000,%eax
f0103048:	89 04 24             	mov    %eax,(%esp)
f010304b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103050:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103055:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010305a:	e8 c4 e5 ff ff       	call   f0101623 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010305f:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0103064:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103069:	77 20                	ja     f010308b <mem_init+0x1833>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010306b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010306f:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103076:	f0 
f0103077:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f010307e:	00 
f010307f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103086:	e8 b5 cf ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W|PTE_P);
f010308b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103092:	00 
f0103093:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f010309a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010309f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01030a4:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01030a9:	e8 75 e5 ff ff       	call   f0101623 <boot_map_region>
f01030ae:	bf 00 30 27 f0       	mov    $0xf0273000,%edi
f01030b3:	bb 00 30 23 f0       	mov    $0xf0233000,%ebx
f01030b8:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030bd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01030c3:	77 20                	ja     f01030e5 <mem_init+0x188d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01030c9:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f01030d8:	00 
f01030d9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01030e0:	e8 5b cf ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	for(int i = 0; i<NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP - (i+1)*KSTKSIZE - i*KSTKGAP, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W|PTE_P);
f01030e5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01030ec:	00 
f01030ed:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01030f3:	89 04 24             	mov    %eax,(%esp)
f01030f6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01030fb:	89 f2                	mov    %esi,%edx
f01030fd:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103102:	e8 1c e5 ff ff       	call   f0101623 <boot_map_region>
f0103107:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010310d:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	for(int i = 0; i<NCPU; i++) {
f0103113:	39 fb                	cmp    %edi,%ebx
f0103115:	75 a6                	jne    f01030bd <mem_init+0x1865>
	// Your code goes here:

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	boot_map_region(kern_pgdir, KERNBASE,(size_t) (-KERNBASE), 0, PTE_W|PTE_P);
f0103117:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010311e:	00 
f010311f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103126:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010312b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103130:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103135:	e8 e9 e4 ff ff       	call   f0101623 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010313a:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103140:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0103145:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103148:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010314f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103154:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103157:	8b 35 90 1e 23 f0    	mov    0xf0231e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010315d:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103160:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0103166:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0103169:	bb 00 00 00 00       	mov    $0x0,%ebx
f010316e:	eb 6a                	jmp    f01031da <mem_init+0x1982>
f0103170:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103176:	89 f8                	mov    %edi,%eax
f0103178:	e8 1b de ff ff       	call   f0100f98 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010317d:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103184:	77 20                	ja     f01031a6 <mem_init+0x194e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103186:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010318a:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103191:	f0 
f0103192:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0103199:	00 
f010319a:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01031a1:	e8 9a ce ff ff       	call   f0100040 <_panic>
f01031a6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01031a9:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01031ac:	39 d0                	cmp    %edx,%eax
f01031ae:	74 24                	je     f01031d4 <mem_init+0x197c>
f01031b0:	c7 44 24 0c bc 7b 10 	movl   $0xf0107bbc,0xc(%esp)
f01031b7:	f0 
f01031b8:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01031bf:	f0 
f01031c0:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01031c7:	00 
f01031c8:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01031cf:	e8 6c ce ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f01031d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031da:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01031dd:	77 91                	ja     f0103170 <mem_init+0x1918>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01031df:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e5:	89 de                	mov    %ebx,%esi
f01031e7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01031ec:	89 f8                	mov    %edi,%eax
f01031ee:	e8 a5 dd ff ff       	call   f0100f98 <check_va2pa>
f01031f3:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01031f9:	77 20                	ja     f010321b <mem_init+0x19c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01031ff:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103206:	f0 
f0103207:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f010320e:	00 
f010320f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103216:	e8 25 ce ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010321b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0103220:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0103226:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103229:	39 d0                	cmp    %edx,%eax
f010322b:	74 24                	je     f0103251 <mem_init+0x19f9>
f010322d:	c7 44 24 0c f0 7b 10 	movl   $0xf0107bf0,0xc(%esp)
f0103234:	f0 
f0103235:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010323c:	f0 
f010323d:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0103244:	00 
f0103245:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010324c:	e8 ef cd ff ff       	call   f0100040 <_panic>
f0103251:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) 
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103257:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010325d:	0f 85 a8 05 00 00    	jne    f010380b <mem_init+0x1fb3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103263:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103266:	c1 e6 0c             	shl    $0xc,%esi
f0103269:	bb 00 00 00 00       	mov    $0x0,%ebx
f010326e:	eb 3b                	jmp    f01032ab <mem_init+0x1a53>
f0103270:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103276:	89 f8                	mov    %edi,%eax
f0103278:	e8 1b dd ff ff       	call   f0100f98 <check_va2pa>
f010327d:	39 c3                	cmp    %eax,%ebx
f010327f:	74 24                	je     f01032a5 <mem_init+0x1a4d>
f0103281:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0103288:	f0 
f0103289:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103290:	f0 
f0103291:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0103298:	00 
f0103299:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01032a0:	e8 9b cd ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032ab:	39 f3                	cmp    %esi,%ebx
f01032ad:	72 c1                	jb     f0103270 <mem_init+0x1a18>
f01032af:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
f01032b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01032bd:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01032c2:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f01032c7:	05 00 80 00 20       	add    $0x20008000,%eax
f01032cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01032cf:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f01032d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01032d8:	89 f2                	mov    %esi,%edx
f01032da:	89 f8                	mov    %edi,%eax
f01032dc:	e8 b7 dc ff ff       	call   f0100f98 <check_va2pa>
f01032e1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01032e4:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01032ea:	77 20                	ja     f010330c <mem_init+0x1ab4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032ec:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01032f0:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f01032f7:	f0 
f01032f8:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01032ff:	00 
f0103300:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103307:	e8 34 cd ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010330c:	89 f3                	mov    %esi,%ebx
f010330e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103311:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0103314:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103317:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010331a:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f010331d:	39 c2                	cmp    %eax,%edx
f010331f:	74 24                	je     f0103345 <mem_init+0x1aed>
f0103321:	c7 44 24 0c 4c 7c 10 	movl   $0xf0107c4c,0xc(%esp)
f0103328:	f0 
f0103329:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103330:	f0 
f0103331:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0103338:	00 
f0103339:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103340:	e8 fb cc ff ff       	call   f0100040 <_panic>
f0103345:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010334b:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f010334e:	0f 85 a9 04 00 00    	jne    f01037fd <mem_init+0x1fa5>
f0103354:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010335a:	89 da                	mov    %ebx,%edx
f010335c:	89 f8                	mov    %edi,%eax
f010335e:	e8 35 dc ff ff       	call   f0100f98 <check_va2pa>
f0103363:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103366:	74 24                	je     f010338c <mem_init+0x1b34>
f0103368:	c7 44 24 0c 94 7c 10 	movl   $0xf0107c94,0xc(%esp)
f010336f:	f0 
f0103370:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103377:	f0 
f0103378:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f010337f:	00 
f0103380:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103387:	e8 b4 cc ff ff       	call   f0100040 <_panic>
f010338c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103392:	39 de                	cmp    %ebx,%esi
f0103394:	75 c4                	jne    f010335a <mem_init+0x1b02>
f0103396:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010339c:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f01033a3:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01033aa:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01033b0:	0f 85 19 ff ff ff    	jne    f01032cf <mem_init+0x1a77>
f01033b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01033bb:	e9 c2 00 00 00       	jmp    f0103482 <mem_init+0x1c2a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01033c0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01033c6:	83 fa 04             	cmp    $0x4,%edx
f01033c9:	77 2e                	ja     f01033f9 <mem_init+0x1ba1>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01033cb:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01033cf:	0f 85 aa 00 00 00    	jne    f010347f <mem_init+0x1c27>
f01033d5:	c7 44 24 0c cc 80 10 	movl   $0xf01080cc,0xc(%esp)
f01033dc:	f0 
f01033dd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01033e4:	f0 
f01033e5:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f01033ec:	00 
f01033ed:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01033f4:	e8 47 cc ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01033f9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01033fe:	76 55                	jbe    f0103455 <mem_init+0x1bfd>
				assert(pgdir[i] & PTE_P);
f0103400:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103403:	f6 c2 01             	test   $0x1,%dl
f0103406:	75 24                	jne    f010342c <mem_init+0x1bd4>
f0103408:	c7 44 24 0c cc 80 10 	movl   $0xf01080cc,0xc(%esp)
f010340f:	f0 
f0103410:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103417:	f0 
f0103418:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f010341f:	00 
f0103420:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103427:	e8 14 cc ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010342c:	f6 c2 02             	test   $0x2,%dl
f010342f:	75 4e                	jne    f010347f <mem_init+0x1c27>
f0103431:	c7 44 24 0c dd 80 10 	movl   $0xf01080dd,0xc(%esp)
f0103438:	f0 
f0103439:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103440:	f0 
f0103441:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0103448:	00 
f0103449:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103450:	e8 eb cb ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103455:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103459:	74 24                	je     f010347f <mem_init+0x1c27>
f010345b:	c7 44 24 0c ee 80 10 	movl   $0xf01080ee,0xc(%esp)
f0103462:	f0 
f0103463:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010346a:	f0 
f010346b:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0103472:	00 
f0103473:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010347a:	e8 c1 cb ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010347f:	83 c0 01             	add    $0x1,%eax
f0103482:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103487:	0f 85 33 ff ff ff    	jne    f01033c0 <mem_init+0x1b68>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010348d:	c7 04 24 b8 7c 10 f0 	movl   $0xf0107cb8,(%esp)
f0103494:	e8 f2 0d 00 00       	call   f010428b <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103499:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010349e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034a3:	77 20                	ja     f01034c5 <mem_init+0x1c6d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034a9:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f01034b0:	f0 
f01034b1:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f01034b8:	00 
f01034b9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01034c0:	e8 7b cb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034c5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01034ca:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01034cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01034d2:	e8 30 db ff ff       	call   f0101007 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01034d7:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01034da:	83 e0 f3             	and    $0xfffffff3,%eax
f01034dd:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01034e2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01034e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01034ec:	e8 88 df ff ff       	call   f0101479 <page_alloc>
f01034f1:	89 c3                	mov    %eax,%ebx
f01034f3:	85 c0                	test   %eax,%eax
f01034f5:	75 24                	jne    f010351b <mem_init+0x1cc3>
f01034f7:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f01034fe:	f0 
f01034ff:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103506:	f0 
f0103507:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f010350e:	00 
f010350f:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103516:	e8 25 cb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010351b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103522:	e8 52 df ff ff       	call   f0101479 <page_alloc>
f0103527:	89 c7                	mov    %eax,%edi
f0103529:	85 c0                	test   %eax,%eax
f010352b:	75 24                	jne    f0103551 <mem_init+0x1cf9>
f010352d:	c7 44 24 0c ee 7e 10 	movl   $0xf0107eee,0xc(%esp)
f0103534:	f0 
f0103535:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010353c:	f0 
f010353d:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0103544:	00 
f0103545:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f010354c:	e8 ef ca ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103558:	e8 1c df ff ff       	call   f0101479 <page_alloc>
f010355d:	89 c6                	mov    %eax,%esi
f010355f:	85 c0                	test   %eax,%eax
f0103561:	75 24                	jne    f0103587 <mem_init+0x1d2f>
f0103563:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f010356a:	f0 
f010356b:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103572:	f0 
f0103573:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f010357a:	00 
f010357b:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103582:	e8 b9 ca ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103587:	89 1c 24             	mov    %ebx,(%esp)
f010358a:	e8 75 df ff ff       	call   f0101504 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f010358f:	89 f8                	mov    %edi,%eax
f0103591:	e8 bd d9 ff ff       	call   f0100f53 <page2kva>
f0103596:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010359d:	00 
f010359e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01035a5:	00 
f01035a6:	89 04 24             	mov    %eax,(%esp)
f01035a9:	e8 29 29 00 00       	call   f0105ed7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f01035ae:	89 f0                	mov    %esi,%eax
f01035b0:	e8 9e d9 ff ff       	call   f0100f53 <page2kva>
f01035b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01035bc:	00 
f01035bd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01035c4:	00 
f01035c5:	89 04 24             	mov    %eax,(%esp)
f01035c8:	e8 0a 29 00 00       	call   f0105ed7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01035cd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01035d4:	00 
f01035d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01035dc:	00 
f01035dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01035e1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01035e6:	89 04 24             	mov    %eax,(%esp)
f01035e9:	e8 8c e1 ff ff       	call   f010177a <page_insert>
	assert(pp1->pp_ref == 1);
f01035ee:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01035f3:	74 24                	je     f0103619 <mem_init+0x1dc1>
f01035f5:	c7 44 24 0c d5 7f 10 	movl   $0xf0107fd5,0xc(%esp)
f01035fc:	f0 
f01035fd:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103604:	f0 
f0103605:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f010360c:	00 
f010360d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103614:	e8 27 ca ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103619:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103620:	01 01 01 
f0103623:	74 24                	je     f0103649 <mem_init+0x1df1>
f0103625:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f010362c:	f0 
f010362d:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103634:	f0 
f0103635:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010363c:	00 
f010363d:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103644:	e8 f7 c9 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103649:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103650:	00 
f0103651:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103658:	00 
f0103659:	89 74 24 04          	mov    %esi,0x4(%esp)
f010365d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103662:	89 04 24             	mov    %eax,(%esp)
f0103665:	e8 10 e1 ff ff       	call   f010177a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010366a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103671:	02 02 02 
f0103674:	74 24                	je     f010369a <mem_init+0x1e42>
f0103676:	c7 44 24 0c fc 7c 10 	movl   $0xf0107cfc,0xc(%esp)
f010367d:	f0 
f010367e:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103685:	f0 
f0103686:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f010368d:	00 
f010368e:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103695:	e8 a6 c9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010369a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010369f:	74 24                	je     f01036c5 <mem_init+0x1e6d>
f01036a1:	c7 44 24 0c f7 7f 10 	movl   $0xf0107ff7,0xc(%esp)
f01036a8:	f0 
f01036a9:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01036b0:	f0 
f01036b1:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01036b8:	00 
f01036b9:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01036c0:	e8 7b c9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01036c5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01036ca:	74 24                	je     f01036f0 <mem_init+0x1e98>
f01036cc:	c7 44 24 0c 61 80 10 	movl   $0xf0108061,0xc(%esp)
f01036d3:	f0 
f01036d4:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01036db:	f0 
f01036dc:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01036e3:	00 
f01036e4:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01036eb:	e8 50 c9 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01036f0:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01036f7:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01036fa:	89 f0                	mov    %esi,%eax
f01036fc:	e8 52 d8 ff ff       	call   f0100f53 <page2kva>
f0103701:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103707:	74 24                	je     f010372d <mem_init+0x1ed5>
f0103709:	c7 44 24 0c 20 7d 10 	movl   $0xf0107d20,0xc(%esp)
f0103710:	f0 
f0103711:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103718:	f0 
f0103719:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0103720:	00 
f0103721:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103728:	e8 13 c9 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010372d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103734:	00 
f0103735:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010373a:	89 04 24             	mov    %eax,(%esp)
f010373d:	e8 ef df ff ff       	call   f0101731 <page_remove>
	assert(pp2->pp_ref == 0);
f0103742:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103747:	74 24                	je     f010376d <mem_init+0x1f15>
f0103749:	c7 44 24 0c 2f 80 10 	movl   $0xf010802f,0xc(%esp)
f0103750:	f0 
f0103751:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0103758:	f0 
f0103759:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0103760:	00 
f0103761:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0103768:	e8 d3 c8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010376d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103772:	8b 08                	mov    (%eax),%ecx
f0103774:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010377a:	89 da                	mov    %ebx,%edx
f010377c:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0103782:	c1 fa 03             	sar    $0x3,%edx
f0103785:	c1 e2 0c             	shl    $0xc,%edx
f0103788:	39 d1                	cmp    %edx,%ecx
f010378a:	74 24                	je     f01037b0 <mem_init+0x1f58>
f010378c:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f0103793:	f0 
f0103794:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f010379b:	f0 
f010379c:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f01037a3:	00 
f01037a4:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01037ab:	e8 90 c8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01037b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01037b6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01037bb:	74 24                	je     f01037e1 <mem_init+0x1f89>
f01037bd:	c7 44 24 0c e6 7f 10 	movl   $0xf0107fe6,0xc(%esp)
f01037c4:	f0 
f01037c5:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f01037cc:	f0 
f01037cd:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f01037d4:	00 
f01037d5:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f01037dc:	e8 5f c8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01037e1:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01037e7:	89 1c 24             	mov    %ebx,(%esp)
f01037ea:	e8 15 dd ff ff       	call   f0101504 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01037ef:	c7 04 24 4c 7d 10 f0 	movl   $0xf0107d4c,(%esp)
f01037f6:	e8 90 0a 00 00       	call   f010428b <cprintf>
f01037fb:	eb 1c                	jmp    f0103819 <mem_init+0x1fc1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01037fd:	89 da                	mov    %ebx,%edx
f01037ff:	89 f8                	mov    %edi,%eax
f0103801:	e8 92 d7 ff ff       	call   f0100f98 <check_va2pa>
f0103806:	e9 0c fb ff ff       	jmp    f0103317 <mem_init+0x1abf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010380b:	89 da                	mov    %ebx,%edx
f010380d:	89 f8                	mov    %edi,%eax
f010380f:	e8 84 d7 ff ff       	call   f0100f98 <check_va2pa>
f0103814:	e9 0d fa ff ff       	jmp    f0103226 <mem_init+0x19ce>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103819:	83 c4 4c             	add    $0x4c,%esp
f010381c:	5b                   	pop    %ebx
f010381d:	5e                   	pop    %esi
f010381e:	5f                   	pop    %edi
f010381f:	5d                   	pop    %ebp
f0103820:	c3                   	ret    

f0103821 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103821:	55                   	push   %ebp
f0103822:	89 e5                	mov    %esp,%ebp
f0103824:	57                   	push   %edi
f0103825:	56                   	push   %esi
f0103826:	53                   	push   %ebx
f0103827:	83 ec 2c             	sub    $0x2c,%esp
f010382a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010382d:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
f0103830:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103833:	03 45 10             	add    0x10(%ebp),%eax
f0103836:	05 ff 0f 00 00       	add    $0xfff,%eax
f010383b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103840:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
f0103843:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103846:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010384b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010384e:	89 c3                	mov    %eax,%ebx
f0103850:	eb 52                	jmp    f01038a4 <user_mem_check+0x83>
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);
f0103852:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103859:	00 
f010385a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010385e:	8b 47 60             	mov    0x60(%edi),%eax
f0103861:	89 04 24             	mov    %eax,(%esp)
f0103864:	e8 1a dd ff ff       	call   f0101583 <pgdir_walk>

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
f0103869:	85 c0                	test   %eax,%eax
f010386b:	74 10                	je     f010387d <user_mem_check+0x5c>
f010386d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103873:	77 08                	ja     f010387d <user_mem_check+0x5c>
f0103875:	89 f2                	mov    %esi,%edx
f0103877:	23 10                	and    (%eax),%edx
f0103879:	39 d6                	cmp    %edx,%esi
f010387b:	74 21                	je     f010389e <user_mem_check+0x7d>
			user_mem_check_addr = i;
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
f010387d:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0103880:	74 0d                	je     f010388f <user_mem_check+0x6e>

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
			user_mem_check_addr = i;
f0103882:	89 1d 3c 12 23 f0    	mov    %ebx,0xf023123c
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
				user_mem_check_addr = (uintptr_t) va;
			}
			return -E_FAULT;
f0103888:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010388d:	eb 1f                	jmp    f01038ae <user_mem_check+0x8d>
		pte_t * pte = pgdir_walk(env->env_pgdir, (const void *) i, 0);

		if((i >= ULIM) || (!pte) || (*pte & perm) != perm) {
			user_mem_check_addr = i;
			if( i == ROUNDDOWN((uint32_t)va,PGSIZE) ) {
				user_mem_check_addr = (uintptr_t) va;
f010388f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103892:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
			}
			return -E_FAULT;
f0103897:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010389c:	eb 10                	jmp    f01038ae <user_mem_check+0x8d>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);

	for(uintptr_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i += PGSIZE) {
f010389e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01038a4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01038a7:	72 a9                	jb     f0103852 <user_mem_check+0x31>
			}
			return -E_FAULT;
		}
	}

	return 0;
f01038a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038ae:	83 c4 2c             	add    $0x2c,%esp
f01038b1:	5b                   	pop    %ebx
f01038b2:	5e                   	pop    %esi
f01038b3:	5f                   	pop    %edi
f01038b4:	5d                   	pop    %ebp
f01038b5:	c3                   	ret    

f01038b6 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01038b6:	55                   	push   %ebp
f01038b7:	89 e5                	mov    %esp,%ebp
f01038b9:	53                   	push   %ebx
f01038ba:	83 ec 14             	sub    $0x14,%esp
f01038bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01038c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01038c3:	83 c8 04             	or     $0x4,%eax
f01038c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01038cd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038d8:	89 1c 24             	mov    %ebx,(%esp)
f01038db:	e8 41 ff ff ff       	call   f0103821 <user_mem_check>
f01038e0:	85 c0                	test   %eax,%eax
f01038e2:	79 24                	jns    f0103908 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01038e4:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f01038e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038ed:	8b 43 48             	mov    0x48(%ebx),%eax
f01038f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038f4:	c7 04 24 78 7d 10 f0 	movl   $0xf0107d78,(%esp)
f01038fb:	e8 8b 09 00 00       	call   f010428b <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103900:	89 1c 24             	mov    %ebx,(%esp)
f0103903:	e8 9d 06 00 00       	call   f0103fa5 <env_destroy>
	}
}
f0103908:	83 c4 14             	add    $0x14,%esp
f010390b:	5b                   	pop    %ebx
f010390c:	5d                   	pop    %ebp
f010390d:	c3                   	ret    

f010390e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010390e:	55                   	push   %ebp
f010390f:	89 e5                	mov    %esp,%ebp
f0103911:	57                   	push   %edi
f0103912:	56                   	push   %esi
f0103913:	53                   	push   %ebx
f0103914:	83 ec 1c             	sub    $0x1c,%esp
f0103917:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)

	pte_t* pte;
	struct PageInfo * p;
	size_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
f0103919:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103920:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(size_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i+= PGSIZE) {
f0103926:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010392c:	89 d3                	mov    %edx,%ebx
f010392e:	eb 6d                	jmp    f010399d <region_alloc+0x8f>
		p = page_alloc(0);
f0103930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103937:	e8 3d db ff ff       	call   f0101479 <page_alloc>
		if(!p) panic("could not initialize new page");
f010393c:	85 c0                	test   %eax,%eax
f010393e:	75 1c                	jne    f010395c <region_alloc+0x4e>
f0103940:	c7 44 24 08 fc 80 10 	movl   $0xf01080fc,0x8(%esp)
f0103947:	f0 
f0103948:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f010394f:	00 
f0103950:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103957:	e8 e4 c6 ff ff       	call   f0100040 <_panic>

		if(page_insert(e->env_pgdir, p, (void*) i, PTE_W| PTE_U |PTE_P) < 0 ) {
f010395c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103963:	00 
f0103964:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103968:	89 44 24 04          	mov    %eax,0x4(%esp)
f010396c:	8b 47 60             	mov    0x60(%edi),%eax
f010396f:	89 04 24             	mov    %eax,(%esp)
f0103972:	e8 03 de ff ff       	call   f010177a <page_insert>
f0103977:	85 c0                	test   %eax,%eax
f0103979:	79 1c                	jns    f0103997 <region_alloc+0x89>
			panic("could not insert page into pgdir");
f010397b:	c7 44 24 08 5c 81 10 	movl   $0xf010815c,0x8(%esp)
f0103982:	f0 
f0103983:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f010398a:	00 
f010398b:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103992:	e8 a9 c6 ff ff       	call   f0100040 <_panic>
	// (But only if you need it for load_icode.)

	pte_t* pte;
	struct PageInfo * p;
	size_t lim = ROUNDUP((uint32_t)(va+len), PGSIZE);
	for(size_t i = ROUNDDOWN((uint32_t)va,PGSIZE); i<lim; i+= PGSIZE) {
f0103997:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010399d:	39 f3                	cmp    %esi,%ebx
f010399f:	72 8f                	jb     f0103930 <region_alloc+0x22>

	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01039a1:	83 c4 1c             	add    $0x1c,%esp
f01039a4:	5b                   	pop    %ebx
f01039a5:	5e                   	pop    %esi
f01039a6:	5f                   	pop    %edi
f01039a7:	5d                   	pop    %ebp
f01039a8:	c3                   	ret    

f01039a9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039a9:	55                   	push   %ebp
f01039aa:	89 e5                	mov    %esp,%ebp
f01039ac:	56                   	push   %esi
f01039ad:	53                   	push   %ebx
f01039ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01039b1:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01039b4:	85 c0                	test   %eax,%eax
f01039b6:	75 1a                	jne    f01039d2 <envid2env+0x29>
		*env_store = curenv;
f01039b8:	e8 6c 2b 00 00       	call   f0106529 <cpunum>
f01039bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c0:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01039c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01039c9:	89 01                	mov    %eax,(%ecx)
		return 0;
f01039cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01039d0:	eb 70                	jmp    f0103a42 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01039d2:	89 c3                	mov    %eax,%ebx
f01039d4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01039da:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01039dd:	03 1d 48 12 23 f0    	add    0xf0231248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01039e3:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01039e7:	74 05                	je     f01039ee <envid2env+0x45>
f01039e9:	39 43 48             	cmp    %eax,0x48(%ebx)
f01039ec:	74 10                	je     f01039fe <envid2env+0x55>
		*env_store = 0;
f01039ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01039f7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01039fc:	eb 44                	jmp    f0103a42 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01039fe:	84 d2                	test   %dl,%dl
f0103a00:	74 36                	je     f0103a38 <envid2env+0x8f>
f0103a02:	e8 22 2b 00 00       	call   f0106529 <cpunum>
f0103a07:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a0a:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103a10:	74 26                	je     f0103a38 <envid2env+0x8f>
f0103a12:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103a15:	e8 0f 2b 00 00       	call   f0106529 <cpunum>
f0103a1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a1d:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103a23:	3b 70 48             	cmp    0x48(%eax),%esi
f0103a26:	74 10                	je     f0103a38 <envid2env+0x8f>
		*env_store = 0;
f0103a28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a31:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a36:	eb 0a                	jmp    f0103a42 <envid2env+0x99>
	}

	*env_store = e;
f0103a38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a3b:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a42:	5b                   	pop    %ebx
f0103a43:	5e                   	pop    %esi
f0103a44:	5d                   	pop    %ebp
f0103a45:	c3                   	ret    

f0103a46 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a46:	55                   	push   %ebp
f0103a47:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103a49:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103a4e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103a51:	b8 23 00 00 00       	mov    $0x23,%eax
f0103a56:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103a58:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103a5a:	b0 10                	mov    $0x10,%al
f0103a5c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103a5e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103a60:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103a62:	ea 69 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103a69
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103a69:	b0 00                	mov    $0x0,%al
f0103a6b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103a6e:	5d                   	pop    %ebp
f0103a6f:	c3                   	ret    

f0103a70 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103a70:	55                   	push   %ebp
f0103a71:	89 e5                	mov    %esp,%ebp
f0103a73:	56                   	push   %esi
f0103a74:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for(int i=NENV-1; i>=0; i--) {
		envs[i].env_status = ENV_FREE;
f0103a75:	8b 35 48 12 23 f0    	mov    0xf0231248,%esi
f0103a7b:	8b 0d 4c 12 23 f0    	mov    0xf023124c,%ecx
f0103a81:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103a87:	ba 00 04 00 00       	mov    $0x400,%edx
f0103a8c:	89 c3                	mov    %eax,%ebx
f0103a8e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103a95:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103a9c:	89 48 44             	mov    %ecx,0x44(%eax)
f0103a9f:	83 e8 7c             	sub    $0x7c,%eax
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for(int i=NENV-1; i>=0; i--) {
f0103aa2:	83 ea 01             	sub    $0x1,%edx
f0103aa5:	74 04                	je     f0103aab <env_init+0x3b>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &(envs[i]);
f0103aa7:	89 d9                	mov    %ebx,%ecx
f0103aa9:	eb e1                	jmp    f0103a8c <env_init+0x1c>
f0103aab:	89 35 4c 12 23 f0    	mov    %esi,0xf023124c
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103ab1:	e8 90 ff ff ff       	call   f0103a46 <env_init_percpu>
}
f0103ab6:	5b                   	pop    %ebx
f0103ab7:	5e                   	pop    %esi
f0103ab8:	5d                   	pop    %ebp
f0103ab9:	c3                   	ret    

f0103aba <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103aba:	55                   	push   %ebp
f0103abb:	89 e5                	mov    %esp,%ebp
f0103abd:	53                   	push   %ebx
f0103abe:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103ac1:	8b 1d 4c 12 23 f0    	mov    0xf023124c,%ebx
f0103ac7:	85 db                	test   %ebx,%ebx
f0103ac9:	0f 84 8e 01 00 00    	je     f0103c5d <env_alloc+0x1a3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103ad6:	e8 9e d9 ff ff       	call   f0101479 <page_alloc>
f0103adb:	85 c0                	test   %eax,%eax
f0103add:	0f 84 81 01 00 00    	je     f0103c64 <env_alloc+0x1aa>
f0103ae3:	89 c2                	mov    %eax,%edx
f0103ae5:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0103aeb:	c1 fa 03             	sar    $0x3,%edx
f0103aee:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103af1:	89 d1                	mov    %edx,%ecx
f0103af3:	c1 e9 0c             	shr    $0xc,%ecx
f0103af6:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0103afc:	72 20                	jb     f0103b1e <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103afe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b02:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0103b09:	f0 
f0103b0a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103b11:	00 
f0103b12:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0103b19:	e8 22 c5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b1e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103b24:	89 53 60             	mov    %edx,0x60(%ebx)
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
f0103b27:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103b2c:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	//boot_map_region(e->env_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_W| PTE_U | PTE_P);
	//boot_map_region(e->env_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
	for(int i=PDX(UTOP);i<NPDENTRIES;i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0103b31:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0103b37:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103b3a:	8b 53 60             	mov    0x60(%ebx),%edx
f0103b3d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103b40:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;

	//boot_map_region(e->env_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_W| PTE_U | PTE_P);
	//boot_map_region(e->env_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
	for(int i=PDX(UTOP);i<NPDENTRIES;i++) {
f0103b43:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103b48:	75 e7                	jne    f0103b31 <env_alloc+0x77>
		e->env_pgdir[i] = kern_pgdir[i];
	}
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103b4a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b4d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b52:	77 20                	ja     f0103b74 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b58:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103b5f:	f0 
f0103b60:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0103b67:	00 
f0103b68:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103b6f:	e8 cc c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b74:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103b7a:	83 ca 05             	or     $0x5,%edx
f0103b7d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103b83:	8b 43 48             	mov    0x48(%ebx),%eax
f0103b86:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103b8b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103b90:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103b95:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103b98:	89 da                	mov    %ebx,%edx
f0103b9a:	2b 15 48 12 23 f0    	sub    0xf0231248,%edx
f0103ba0:	c1 fa 02             	sar    $0x2,%edx
f0103ba3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103ba9:	09 d0                	or     %edx,%eax
f0103bab:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103bae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bb1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103bb4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103bbb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103bc2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103bc9:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103bd0:	00 
f0103bd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103bd8:	00 
f0103bd9:	89 1c 24             	mov    %ebx,(%esp)
f0103bdc:	e8 f6 22 00 00       	call   f0105ed7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103be1:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103be7:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103bed:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103bf3:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103bfa:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103c00:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103c07:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103c0b:	8b 43 44             	mov    0x44(%ebx),%eax
f0103c0e:	a3 4c 12 23 f0       	mov    %eax,0xf023124c
	*newenv_store = e;
f0103c13:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c16:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103c18:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103c1b:	e8 09 29 00 00       	call   f0106529 <cpunum>
f0103c20:	6b d0 74             	imul   $0x74,%eax,%edx
f0103c23:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c28:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f0103c2f:	74 11                	je     f0103c42 <env_alloc+0x188>
f0103c31:	e8 f3 28 00 00       	call   f0106529 <cpunum>
f0103c36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c39:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103c3f:	8b 40 48             	mov    0x48(%eax),%eax
f0103c42:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c4a:	c7 04 24 25 81 10 f0 	movl   $0xf0108125,(%esp)
f0103c51:	e8 35 06 00 00       	call   f010428b <cprintf>
	return 0;
f0103c56:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c5b:	eb 0c                	jmp    f0103c69 <env_alloc+0x1af>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103c5d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103c62:	eb 05                	jmp    f0103c69 <env_alloc+0x1af>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103c64:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103c69:	83 c4 14             	add    $0x14,%esp
f0103c6c:	5b                   	pop    %ebx
f0103c6d:	5d                   	pop    %ebp
f0103c6e:	c3                   	ret    

f0103c6f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103c6f:	55                   	push   %ebp
f0103c70:	89 e5                	mov    %esp,%ebp
f0103c72:	57                   	push   %edi
f0103c73:	56                   	push   %esi
f0103c74:	53                   	push   %ebx
f0103c75:	83 ec 3c             	sub    $0x3c,%esp
f0103c78:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct Env *newenv;
	int r;
	if((r = env_alloc(&newenv, 0)) < 0) {
f0103c7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c82:	00 
f0103c83:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103c86:	89 04 24             	mov    %eax,(%esp)
f0103c89:	e8 2c fe ff ff       	call   f0103aba <env_alloc>
f0103c8e:	85 c0                	test   %eax,%eax
f0103c90:	79 20                	jns    f0103cb2 <env_create+0x43>
		panic("Couldn't allocate user env. Env_alloc failed with error %e\n", r);
f0103c92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c96:	c7 44 24 08 80 81 10 	movl   $0xf0108180,0x8(%esp)
f0103c9d:	f0 
f0103c9e:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0103ca5:	00 
f0103ca6:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103cad:	e8 8e c3 ff ff       	call   f0100040 <_panic>
	}

	load_icode(newenv, binary);
f0103cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103cb5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	struct Elf *elfhdr = (struct Elf *) binary;
	struct Proghdr *ph,*eph;

	if(elfhdr->e_magic != ELF_MAGIC) {
f0103cb8:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103cbe:	74 1c                	je     f0103cdc <env_create+0x6d>
		panic("Binary image doesn't have valid elf hdr");
f0103cc0:	c7 44 24 08 bc 81 10 	movl   $0xf01081bc,0x8(%esp)
f0103cc7:	f0 
f0103cc8:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f0103ccf:	00 
f0103cd0:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103cd7:	e8 64 c3 ff ff       	call   f0100040 <_panic>
	}

	ph = (struct Proghdr *)(binary + elfhdr->e_phoff);
f0103cdc:	89 fb                	mov    %edi,%ebx
f0103cde:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0103ce1:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103ce5:	c1 e6 05             	shl    $0x5,%esi
f0103ce8:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103cea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ced:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cf0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cf5:	77 20                	ja     f0103d17 <env_create+0xa8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cfb:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103d02:	f0 
f0103d03:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103d0a:	00 
f0103d0b:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103d12:	e8 29 c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d17:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103d1c:	0f 22 d8             	mov    %eax,%cr3
f0103d1f:	eb 50                	jmp    f0103d71 <env_create+0x102>

	for(; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
f0103d21:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103d24:	75 48                	jne    f0103d6e <env_create+0xff>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0103d26:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103d29:	8b 53 08             	mov    0x8(%ebx),%edx
f0103d2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d2f:	e8 da fb ff ff       	call   f010390e <region_alloc>
			memcpy((void*)ph->p_va, (binary + ph->p_offset), ph->p_filesz);
f0103d34:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d37:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d3b:	89 f8                	mov    %edi,%eax
f0103d3d:	03 43 04             	add    0x4(%ebx),%eax
f0103d40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d44:	8b 43 08             	mov    0x8(%ebx),%eax
f0103d47:	89 04 24             	mov    %eax,(%esp)
f0103d4a:	e8 3d 22 00 00       	call   f0105f8c <memcpy>
			memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103d4f:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d52:	8b 53 14             	mov    0x14(%ebx),%edx
f0103d55:	29 c2                	sub    %eax,%edx
f0103d57:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d62:	00 
f0103d63:	03 43 08             	add    0x8(%ebx),%eax
f0103d66:	89 04 24             	mov    %eax,(%esp)
f0103d69:	e8 69 21 00 00       	call   f0105ed7 <memset>

	ph = (struct Proghdr *)(binary + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for(; ph < eph; ph++) {
f0103d6e:	83 c3 20             	add    $0x20,%ebx
f0103d71:	39 de                	cmp    %ebx,%esi
f0103d73:	77 ac                	ja     f0103d21 <env_create+0xb2>
		}
	}


	//set IP in trapframe
	e->env_tf.tf_eip = elfhdr->e_entry;
f0103d75:	8b 47 18             	mov    0x18(%edi),%eax
f0103d78:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103d7b:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.

	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103d7e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103d83:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103d88:	89 f8                	mov    %edi,%eax
f0103d8a:	e8 7f fb ff ff       	call   f010390e <region_alloc>
		panic("Couldn't allocate user env. Env_alloc failed with error %e\n", r);
	}

	load_icode(newenv, binary);

	newenv->env_type = type;
f0103d8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d92:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d95:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103d98:	83 c4 3c             	add    $0x3c,%esp
f0103d9b:	5b                   	pop    %ebx
f0103d9c:	5e                   	pop    %esi
f0103d9d:	5f                   	pop    %edi
f0103d9e:	5d                   	pop    %ebp
f0103d9f:	c3                   	ret    

f0103da0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103da0:	55                   	push   %ebp
f0103da1:	89 e5                	mov    %esp,%ebp
f0103da3:	57                   	push   %edi
f0103da4:	56                   	push   %esi
f0103da5:	53                   	push   %ebx
f0103da6:	83 ec 2c             	sub    $0x2c,%esp
f0103da9:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103dac:	e8 78 27 00 00       	call   f0106529 <cpunum>
f0103db1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db4:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f0103dba:	75 34                	jne    f0103df0 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103dbc:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dc1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dc6:	77 20                	ja     f0103de8 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dcc:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103dd3:	f0 
f0103dd4:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
f0103ddb:	00 
f0103ddc:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103de3:	e8 58 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103de8:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ded:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103df0:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103df3:	e8 31 27 00 00       	call   f0106529 <cpunum>
f0103df8:	6b d0 74             	imul   $0x74,%eax,%edx
f0103dfb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e00:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f0103e07:	74 11                	je     f0103e1a <env_free+0x7a>
f0103e09:	e8 1b 27 00 00       	call   f0106529 <cpunum>
f0103e0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e11:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103e17:	8b 40 48             	mov    0x48(%eax),%eax
f0103e1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e22:	c7 04 24 3a 81 10 f0 	movl   $0xf010813a,(%esp)
f0103e29:	e8 5d 04 00 00       	call   f010428b <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103e2e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103e35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e38:	89 c8                	mov    %ecx,%eax
f0103e3a:	c1 e0 02             	shl    $0x2,%eax
f0103e3d:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103e40:	8b 47 60             	mov    0x60(%edi),%eax
f0103e43:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103e46:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103e4c:	0f 84 b7 00 00 00    	je     f0103f09 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103e52:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e58:	89 f0                	mov    %esi,%eax
f0103e5a:	c1 e8 0c             	shr    $0xc,%eax
f0103e5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e60:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103e66:	72 20                	jb     f0103e88 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e68:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103e6c:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0103e73:	f0 
f0103e74:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0103e7b:	00 
f0103e7c:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103e83:	e8 b8 c1 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103e88:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e8b:	c1 e0 16             	shl    $0x16,%eax
f0103e8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103e91:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103e96:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103e9d:	01 
f0103e9e:	74 17                	je     f0103eb7 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ea0:	89 d8                	mov    %ebx,%eax
f0103ea2:	c1 e0 0c             	shl    $0xc,%eax
f0103ea5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103eac:	8b 47 60             	mov    0x60(%edi),%eax
f0103eaf:	89 04 24             	mov    %eax,(%esp)
f0103eb2:	e8 7a d8 ff ff       	call   f0101731 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103eb7:	83 c3 01             	add    $0x1,%ebx
f0103eba:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103ec0:	75 d4                	jne    f0103e96 <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103ec2:	8b 47 60             	mov    0x60(%edi),%eax
f0103ec5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ec8:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ecf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ed2:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103ed8:	72 1c                	jb     f0103ef6 <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103eda:	c7 44 24 08 74 75 10 	movl   $0xf0107574,0x8(%esp)
f0103ee1:	f0 
f0103ee2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ee9:	00 
f0103eea:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0103ef1:	e8 4a c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ef6:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0103efb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103efe:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103f01:	89 04 24             	mov    %eax,(%esp)
f0103f04:	e8 57 d6 ff ff       	call   f0101560 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103f09:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103f0d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103f14:	0f 85 1b ff ff ff    	jne    f0103e35 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103f1a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f22:	77 20                	ja     f0103f44 <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f28:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0103f2f:	f0 
f0103f30:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0103f37:	00 
f0103f38:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0103f3f:	e8 fc c0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103f44:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103f4b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f50:	c1 e8 0c             	shr    $0xc,%eax
f0103f53:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103f59:	72 1c                	jb     f0103f77 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103f5b:	c7 44 24 08 74 75 10 	movl   $0xf0107574,0x8(%esp)
f0103f62:	f0 
f0103f63:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103f6a:	00 
f0103f6b:	c7 04 24 ad 7d 10 f0 	movl   $0xf0107dad,(%esp)
f0103f72:	e8 c9 c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103f77:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0103f7d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103f80:	89 04 24             	mov    %eax,(%esp)
f0103f83:	e8 d8 d5 ff ff       	call   f0101560 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103f88:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103f8f:	a1 4c 12 23 f0       	mov    0xf023124c,%eax
f0103f94:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103f97:	89 3d 4c 12 23 f0    	mov    %edi,0xf023124c
}
f0103f9d:	83 c4 2c             	add    $0x2c,%esp
f0103fa0:	5b                   	pop    %ebx
f0103fa1:	5e                   	pop    %esi
f0103fa2:	5f                   	pop    %edi
f0103fa3:	5d                   	pop    %ebp
f0103fa4:	c3                   	ret    

f0103fa5 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103fa5:	55                   	push   %ebp
f0103fa6:	89 e5                	mov    %esp,%ebp
f0103fa8:	53                   	push   %ebx
f0103fa9:	83 ec 14             	sub    $0x14,%esp
f0103fac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103faf:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103fb3:	75 19                	jne    f0103fce <env_destroy+0x29>
f0103fb5:	e8 6f 25 00 00       	call   f0106529 <cpunum>
f0103fba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fbd:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103fc3:	74 09                	je     f0103fce <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103fc5:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103fcc:	eb 2f                	jmp    f0103ffd <env_destroy+0x58>
	}

	env_free(e);
f0103fce:	89 1c 24             	mov    %ebx,(%esp)
f0103fd1:	e8 ca fd ff ff       	call   f0103da0 <env_free>

	if (curenv == e) {
f0103fd6:	e8 4e 25 00 00       	call   f0106529 <cpunum>
f0103fdb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fde:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103fe4:	75 17                	jne    f0103ffd <env_destroy+0x58>
		curenv = NULL;
f0103fe6:	e8 3e 25 00 00       	call   f0106529 <cpunum>
f0103feb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fee:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0103ff5:	00 00 00 
		sched_yield();
f0103ff8:	e8 25 0e 00 00       	call   f0104e22 <sched_yield>
	}
}
f0103ffd:	83 c4 14             	add    $0x14,%esp
f0104000:	5b                   	pop    %ebx
f0104001:	5d                   	pop    %ebp
f0104002:	c3                   	ret    

f0104003 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104003:	55                   	push   %ebp
f0104004:	89 e5                	mov    %esp,%ebp
f0104006:	53                   	push   %ebx
f0104007:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010400a:	e8 1a 25 00 00       	call   f0106529 <cpunum>
f010400f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104012:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f0104018:	e8 0c 25 00 00       	call   f0106529 <cpunum>
f010401d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0104020:	8b 65 08             	mov    0x8(%ebp),%esp
f0104023:	61                   	popa   
f0104024:	07                   	pop    %es
f0104025:	1f                   	pop    %ds
f0104026:	83 c4 08             	add    $0x8,%esp
f0104029:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010402a:	c7 44 24 08 50 81 10 	movl   $0xf0108150,0x8(%esp)
f0104031:	f0 
f0104032:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
f0104039:	00 
f010403a:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f0104041:	e8 fa bf ff ff       	call   f0100040 <_panic>

f0104046 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104046:	55                   	push   %ebp
f0104047:	89 e5                	mov    %esp,%ebp
f0104049:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && (curenv->env_status == ENV_RUNNING) ) {
f010404c:	e8 d8 24 00 00       	call   f0106529 <cpunum>
f0104051:	6b c0 74             	imul   $0x74,%eax,%eax
f0104054:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010405b:	74 29                	je     f0104086 <env_run+0x40>
f010405d:	e8 c7 24 00 00       	call   f0106529 <cpunum>
f0104062:	6b c0 74             	imul   $0x74,%eax,%eax
f0104065:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010406b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010406f:	75 15                	jne    f0104086 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f0104071:	e8 b3 24 00 00       	call   f0106529 <cpunum>
f0104076:	6b c0 74             	imul   $0x74,%eax,%eax
f0104079:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010407f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}

	curenv = e;
f0104086:	e8 9e 24 00 00       	call   f0106529 <cpunum>
f010408b:	6b c0 74             	imul   $0x74,%eax,%eax
f010408e:	8b 55 08             	mov    0x8(%ebp),%edx
f0104091:	89 90 28 20 23 f0    	mov    %edx,-0xfdcdfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0104097:	e8 8d 24 00 00       	call   f0106529 <cpunum>
f010409c:	6b c0 74             	imul   $0x74,%eax,%eax
f010409f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01040a5:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01040ac:	e8 78 24 00 00       	call   f0106529 <cpunum>
f01040b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b4:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01040ba:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f01040be:	e8 66 24 00 00       	call   f0106529 <cpunum>
f01040c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c6:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01040cc:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040d4:	77 20                	ja     f01040f6 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040da:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f01040e1:	f0 
f01040e2:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
f01040e9:	00 
f01040ea:	c7 04 24 1a 81 10 f0 	movl   $0xf010811a,(%esp)
f01040f1:	e8 4a bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040f6:	05 00 00 00 10       	add    $0x10000000,%eax
f01040fb:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01040fe:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104105:	e8 49 27 00 00       	call   f0106853 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010410a:	f3 90                	pause  

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f010410c:	e8 18 24 00 00       	call   f0106529 <cpunum>
f0104111:	6b c0 74             	imul   $0x74,%eax,%eax
f0104114:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010411a:	89 04 24             	mov    %eax,(%esp)
f010411d:	e8 e1 fe ff ff       	call   f0104003 <env_pop_tf>

f0104122 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
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

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010412f:	b2 71                	mov    $0x71,%dl
f0104131:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104132:	0f b6 c0             	movzbl %al,%eax
}
f0104135:	5d                   	pop    %ebp
f0104136:	c3                   	ret    

f0104137 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104137:	55                   	push   %ebp
f0104138:	89 e5                	mov    %esp,%ebp
f010413a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010413e:	ba 70 00 00 00       	mov    $0x70,%edx
f0104143:	ee                   	out    %al,(%dx)
f0104144:	b2 71                	mov    $0x71,%dl
f0104146:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104149:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010414a:	5d                   	pop    %ebp
f010414b:	c3                   	ret    

f010414c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010414c:	55                   	push   %ebp
f010414d:	89 e5                	mov    %esp,%ebp
f010414f:	56                   	push   %esi
f0104150:	53                   	push   %ebx
f0104151:	83 ec 10             	sub    $0x10,%esp
f0104154:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0104157:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f010415d:	80 3d 50 12 23 f0 00 	cmpb   $0x0,0xf0231250
f0104164:	74 4e                	je     f01041b4 <irq_setmask_8259A+0x68>
f0104166:	89 c6                	mov    %eax,%esi
f0104168:	ba 21 00 00 00       	mov    $0x21,%edx
f010416d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f010416e:	66 c1 e8 08          	shr    $0x8,%ax
f0104172:	b2 a1                	mov    $0xa1,%dl
f0104174:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104175:	c7 04 24 e4 81 10 f0 	movl   $0xf01081e4,(%esp)
f010417c:	e8 0a 01 00 00       	call   f010428b <cprintf>
	for (i = 0; i < 16; i++)
f0104181:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0104186:	0f b7 f6             	movzwl %si,%esi
f0104189:	f7 d6                	not    %esi
f010418b:	0f a3 de             	bt     %ebx,%esi
f010418e:	73 10                	jae    f01041a0 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0104190:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104194:	c7 04 24 1f 89 10 f0 	movl   $0xf010891f,(%esp)
f010419b:	e8 eb 00 00 00       	call   f010428b <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01041a0:	83 c3 01             	add    $0x1,%ebx
f01041a3:	83 fb 10             	cmp    $0x10,%ebx
f01041a6:	75 e3                	jne    f010418b <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01041a8:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f01041af:	e8 d7 00 00 00       	call   f010428b <cprintf>
}
f01041b4:	83 c4 10             	add    $0x10,%esp
f01041b7:	5b                   	pop    %ebx
f01041b8:	5e                   	pop    %esi
f01041b9:	5d                   	pop    %ebp
f01041ba:	c3                   	ret    

f01041bb <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01041bb:	c6 05 50 12 23 f0 01 	movb   $0x1,0xf0231250
f01041c2:	ba 21 00 00 00       	mov    $0x21,%edx
f01041c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01041cc:	ee                   	out    %al,(%dx)
f01041cd:	b2 a1                	mov    $0xa1,%dl
f01041cf:	ee                   	out    %al,(%dx)
f01041d0:	b2 20                	mov    $0x20,%dl
f01041d2:	b8 11 00 00 00       	mov    $0x11,%eax
f01041d7:	ee                   	out    %al,(%dx)
f01041d8:	b2 21                	mov    $0x21,%dl
f01041da:	b8 20 00 00 00       	mov    $0x20,%eax
f01041df:	ee                   	out    %al,(%dx)
f01041e0:	b8 04 00 00 00       	mov    $0x4,%eax
f01041e5:	ee                   	out    %al,(%dx)
f01041e6:	b8 03 00 00 00       	mov    $0x3,%eax
f01041eb:	ee                   	out    %al,(%dx)
f01041ec:	b2 a0                	mov    $0xa0,%dl
f01041ee:	b8 11 00 00 00       	mov    $0x11,%eax
f01041f3:	ee                   	out    %al,(%dx)
f01041f4:	b2 a1                	mov    $0xa1,%dl
f01041f6:	b8 28 00 00 00       	mov    $0x28,%eax
f01041fb:	ee                   	out    %al,(%dx)
f01041fc:	b8 02 00 00 00       	mov    $0x2,%eax
f0104201:	ee                   	out    %al,(%dx)
f0104202:	b8 01 00 00 00       	mov    $0x1,%eax
f0104207:	ee                   	out    %al,(%dx)
f0104208:	b2 20                	mov    $0x20,%dl
f010420a:	b8 68 00 00 00       	mov    $0x68,%eax
f010420f:	ee                   	out    %al,(%dx)
f0104210:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104215:	ee                   	out    %al,(%dx)
f0104216:	b2 a0                	mov    $0xa0,%dl
f0104218:	b8 68 00 00 00       	mov    $0x68,%eax
f010421d:	ee                   	out    %al,(%dx)
f010421e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104223:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104224:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010422b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010422f:	74 12                	je     f0104243 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104231:	55                   	push   %ebp
f0104232:	89 e5                	mov    %esp,%ebp
f0104234:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0104237:	0f b7 c0             	movzwl %ax,%eax
f010423a:	89 04 24             	mov    %eax,(%esp)
f010423d:	e8 0a ff ff ff       	call   f010414c <irq_setmask_8259A>
}
f0104242:	c9                   	leave  
f0104243:	f3 c3                	repz ret 

f0104245 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104245:	55                   	push   %ebp
f0104246:	89 e5                	mov    %esp,%ebp
f0104248:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010424b:	8b 45 08             	mov    0x8(%ebp),%eax
f010424e:	89 04 24             	mov    %eax,(%esp)
f0104251:	e8 44 c5 ff ff       	call   f010079a <cputchar>
	*cnt++;
}
f0104256:	c9                   	leave  
f0104257:	c3                   	ret    

f0104258 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104258:	55                   	push   %ebp
f0104259:	89 e5                	mov    %esp,%ebp
f010425b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010425e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104265:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104268:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010426c:	8b 45 08             	mov    0x8(%ebp),%eax
f010426f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104273:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104276:	89 44 24 04          	mov    %eax,0x4(%esp)
f010427a:	c7 04 24 45 42 10 f0 	movl   $0xf0104245,(%esp)
f0104281:	e8 98 15 00 00       	call   f010581e <vprintfmt>
	return cnt;
}
f0104286:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104289:	c9                   	leave  
f010428a:	c3                   	ret    

f010428b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010428b:	55                   	push   %ebp
f010428c:	89 e5                	mov    %esp,%ebp
f010428e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104291:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104294:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104298:	8b 45 08             	mov    0x8(%ebp),%eax
f010429b:	89 04 24             	mov    %eax,(%esp)
f010429e:	e8 b5 ff ff ff       	call   f0104258 <vcprintf>
	va_end(ap);

	return cnt;
}
f01042a3:	c9                   	leave  
f01042a4:	c3                   	ret    
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
f01042b9:	e8 6b 22 00 00       	call   f0106529 <cpunum>
f01042be:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c1:	0f b6 80 20 20 23 f0 	movzbl -0xfdcdfe0(%eax),%eax
f01042c8:	89 c3                	mov    %eax,%ebx

	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) (percpu_kstacks[i] + KSTKSIZE);
f01042ca:	e8 5a 22 00 00       	call   f0106529 <cpunum>
f01042cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d2:	88 5d e7             	mov    %bl,-0x19(%ebp)
f01042d5:	0f b6 db             	movzbl %bl,%ebx
f01042d8:	89 da                	mov    %ebx,%edx
f01042da:	c1 e2 0f             	shl    $0xf,%edx
f01042dd:	8d 92 00 b0 23 f0    	lea    -0xfdc5000(%edx),%edx
f01042e3:	89 90 30 20 23 f0    	mov    %edx,-0xfdcdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01042e9:	e8 3b 22 00 00       	call   f0106529 <cpunum>
f01042ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f1:	66 c7 80 34 20 23 f0 	movw   $0x10,-0xfdcdfcc(%eax)
f01042f8:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01042fa:	e8 2a 22 00 00       	call   f0106529 <cpunum>
f01042ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104302:	66 c7 80 92 20 23 f0 	movw   $0x68,-0xfdcdf6e(%eax)
f0104309:	68 00 

	//cprintf("Current tss for cpu %d is %x\n", i, &(thiscpu->cpu_ts));
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010430b:	83 c3 05             	add    $0x5,%ebx
f010430e:	e8 16 22 00 00       	call   f0106529 <cpunum>
f0104313:	89 c7                	mov    %eax,%edi
f0104315:	e8 0f 22 00 00       	call   f0106529 <cpunum>
f010431a:	89 c6                	mov    %eax,%esi
f010431c:	e8 08 22 00 00       	call   f0106529 <cpunum>
f0104321:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0104328:	f0 67 00 
f010432b:	6b ff 74             	imul   $0x74,%edi,%edi
f010432e:	81 c7 2c 20 23 f0    	add    $0xf023202c,%edi
f0104334:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f010433b:	f0 
f010433c:	6b d6 74             	imul   $0x74,%esi,%edx
f010433f:	81 c2 2c 20 23 f0    	add    $0xf023202c,%edx
f0104345:	c1 ea 10             	shr    $0x10,%edx
f0104348:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f010434f:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0104356:	40 
f0104357:	6b c0 74             	imul   $0x74,%eax,%eax
f010435a:	05 2c 20 23 f0       	add    $0xf023202c,%eax
f010435f:	c1 e8 18             	shr    $0x18,%eax
f0104362:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0104369:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
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
f010437f:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
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
f0104395:	b8 d6 4c 10 f0       	mov    $0xf0104cd6,%eax
f010439a:	66 a3 60 12 23 f0    	mov    %ax,0xf0231260
f01043a0:	66 c7 05 62 12 23 f0 	movw   $0x8,0xf0231262
f01043a7:	08 00 
f01043a9:	c6 05 64 12 23 f0 00 	movb   $0x0,0xf0231264
f01043b0:	c6 05 65 12 23 f0 8e 	movb   $0x8e,0xf0231265
f01043b7:	c1 e8 10             	shr    $0x10,%eax
f01043ba:	66 a3 66 12 23 f0    	mov    %ax,0xf0231266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug, 0);
f01043c0:	b8 dc 4c 10 f0       	mov    $0xf0104cdc,%eax
f01043c5:	66 a3 68 12 23 f0    	mov    %ax,0xf0231268
f01043cb:	66 c7 05 6a 12 23 f0 	movw   $0x8,0xf023126a
f01043d2:	08 00 
f01043d4:	c6 05 6c 12 23 f0 00 	movb   $0x0,0xf023126c
f01043db:	c6 05 6d 12 23 f0 8e 	movb   $0x8e,0xf023126d
f01043e2:	c1 e8 10             	shr    $0x10,%eax
f01043e5:	66 a3 6e 12 23 f0    	mov    %ax,0xf023126e
	SETGATE(idt[T_NMI], 0, GD_KT, nmi, 0);
f01043eb:	b8 e2 4c 10 f0       	mov    $0xf0104ce2,%eax
f01043f0:	66 a3 70 12 23 f0    	mov    %ax,0xf0231270
f01043f6:	66 c7 05 72 12 23 f0 	movw   $0x8,0xf0231272
f01043fd:	08 00 
f01043ff:	c6 05 74 12 23 f0 00 	movb   $0x0,0xf0231274
f0104406:	c6 05 75 12 23 f0 8e 	movb   $0x8e,0xf0231275
f010440d:	c1 e8 10             	shr    $0x10,%eax
f0104410:	66 a3 76 12 23 f0    	mov    %ax,0xf0231276
	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt, 3);
f0104416:	b8 e8 4c 10 f0       	mov    $0xf0104ce8,%eax
f010441b:	66 a3 78 12 23 f0    	mov    %ax,0xf0231278
f0104421:	66 c7 05 7a 12 23 f0 	movw   $0x8,0xf023127a
f0104428:	08 00 
f010442a:	c6 05 7c 12 23 f0 00 	movb   $0x0,0xf023127c
f0104431:	c6 05 7d 12 23 f0 ee 	movb   $0xee,0xf023127d
f0104438:	c1 e8 10             	shr    $0x10,%eax
f010443b:	66 a3 7e 12 23 f0    	mov    %ax,0xf023127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow, 0);
f0104441:	b8 ee 4c 10 f0       	mov    $0xf0104cee,%eax
f0104446:	66 a3 80 12 23 f0    	mov    %ax,0xf0231280
f010444c:	66 c7 05 82 12 23 f0 	movw   $0x8,0xf0231282
f0104453:	08 00 
f0104455:	c6 05 84 12 23 f0 00 	movb   $0x0,0xf0231284
f010445c:	c6 05 85 12 23 f0 8e 	movb   $0x8e,0xf0231285
f0104463:	c1 e8 10             	shr    $0x10,%eax
f0104466:	66 a3 86 12 23 f0    	mov    %ax,0xf0231286
	SETGATE(idt[T_BOUND], 0, GD_KT, bound, 0);
f010446c:	b8 f4 4c 10 f0       	mov    $0xf0104cf4,%eax
f0104471:	66 a3 88 12 23 f0    	mov    %ax,0xf0231288
f0104477:	66 c7 05 8a 12 23 f0 	movw   $0x8,0xf023128a
f010447e:	08 00 
f0104480:	c6 05 8c 12 23 f0 00 	movb   $0x0,0xf023128c
f0104487:	c6 05 8d 12 23 f0 8e 	movb   $0x8e,0xf023128d
f010448e:	c1 e8 10             	shr    $0x10,%eax
f0104491:	66 a3 8e 12 23 f0    	mov    %ax,0xf023128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illop, 0);
f0104497:	b8 fa 4c 10 f0       	mov    $0xf0104cfa,%eax
f010449c:	66 a3 90 12 23 f0    	mov    %ax,0xf0231290
f01044a2:	66 c7 05 92 12 23 f0 	movw   $0x8,0xf0231292
f01044a9:	08 00 
f01044ab:	c6 05 94 12 23 f0 00 	movb   $0x0,0xf0231294
f01044b2:	c6 05 95 12 23 f0 8e 	movb   $0x8e,0xf0231295
f01044b9:	c1 e8 10             	shr    $0x10,%eax
f01044bc:	66 a3 96 12 23 f0    	mov    %ax,0xf0231296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device, 0);
f01044c2:	b8 00 4d 10 f0       	mov    $0xf0104d00,%eax
f01044c7:	66 a3 98 12 23 f0    	mov    %ax,0xf0231298
f01044cd:	66 c7 05 9a 12 23 f0 	movw   $0x8,0xf023129a
f01044d4:	08 00 
f01044d6:	c6 05 9c 12 23 f0 00 	movb   $0x0,0xf023129c
f01044dd:	c6 05 9d 12 23 f0 8e 	movb   $0x8e,0xf023129d
f01044e4:	c1 e8 10             	shr    $0x10,%eax
f01044e7:	66 a3 9e 12 23 f0    	mov    %ax,0xf023129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt, 0);
f01044ed:	b8 06 4d 10 f0       	mov    $0xf0104d06,%eax
f01044f2:	66 a3 a0 12 23 f0    	mov    %ax,0xf02312a0
f01044f8:	66 c7 05 a2 12 23 f0 	movw   $0x8,0xf02312a2
f01044ff:	08 00 
f0104501:	c6 05 a4 12 23 f0 00 	movb   $0x0,0xf02312a4
f0104508:	c6 05 a5 12 23 f0 8e 	movb   $0x8e,0xf02312a5
f010450f:	c1 e8 10             	shr    $0x10,%eax
f0104512:	66 a3 a6 12 23 f0    	mov    %ax,0xf02312a6
	SETGATE(idt[T_TSS], 0, GD_KT, tss, 0);
f0104518:	b8 0a 4d 10 f0       	mov    $0xf0104d0a,%eax
f010451d:	66 a3 b0 12 23 f0    	mov    %ax,0xf02312b0
f0104523:	66 c7 05 b2 12 23 f0 	movw   $0x8,0xf02312b2
f010452a:	08 00 
f010452c:	c6 05 b4 12 23 f0 00 	movb   $0x0,0xf02312b4
f0104533:	c6 05 b5 12 23 f0 8e 	movb   $0x8e,0xf02312b5
f010453a:	c1 e8 10             	shr    $0x10,%eax
f010453d:	66 a3 b6 12 23 f0    	mov    %ax,0xf02312b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp, 0);
f0104543:	b8 0e 4d 10 f0       	mov    $0xf0104d0e,%eax
f0104548:	66 a3 b8 12 23 f0    	mov    %ax,0xf02312b8
f010454e:	66 c7 05 ba 12 23 f0 	movw   $0x8,0xf02312ba
f0104555:	08 00 
f0104557:	c6 05 bc 12 23 f0 00 	movb   $0x0,0xf02312bc
f010455e:	c6 05 bd 12 23 f0 8e 	movb   $0x8e,0xf02312bd
f0104565:	c1 e8 10             	shr    $0x10,%eax
f0104568:	66 a3 be 12 23 f0    	mov    %ax,0xf02312be
	SETGATE(idt[T_STACK], 0, GD_KT, stack, 0);
f010456e:	b8 12 4d 10 f0       	mov    $0xf0104d12,%eax
f0104573:	66 a3 c0 12 23 f0    	mov    %ax,0xf02312c0
f0104579:	66 c7 05 c2 12 23 f0 	movw   $0x8,0xf02312c2
f0104580:	08 00 
f0104582:	c6 05 c4 12 23 f0 00 	movb   $0x0,0xf02312c4
f0104589:	c6 05 c5 12 23 f0 8e 	movb   $0x8e,0xf02312c5
f0104590:	c1 e8 10             	shr    $0x10,%eax
f0104593:	66 a3 c6 12 23 f0    	mov    %ax,0xf02312c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt, 0);
f0104599:	b8 16 4d 10 f0       	mov    $0xf0104d16,%eax
f010459e:	66 a3 c8 12 23 f0    	mov    %ax,0xf02312c8
f01045a4:	66 c7 05 ca 12 23 f0 	movw   $0x8,0xf02312ca
f01045ab:	08 00 
f01045ad:	c6 05 cc 12 23 f0 00 	movb   $0x0,0xf02312cc
f01045b4:	c6 05 cd 12 23 f0 8e 	movb   $0x8e,0xf02312cd
f01045bb:	c1 e8 10             	shr    $0x10,%eax
f01045be:	66 a3 ce 12 23 f0    	mov    %ax,0xf02312ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt, 0);
f01045c4:	b8 1a 4d 10 f0       	mov    $0xf0104d1a,%eax
f01045c9:	66 a3 d0 12 23 f0    	mov    %ax,0xf02312d0
f01045cf:	66 c7 05 d2 12 23 f0 	movw   $0x8,0xf02312d2
f01045d6:	08 00 
f01045d8:	c6 05 d4 12 23 f0 00 	movb   $0x0,0xf02312d4
f01045df:	c6 05 d5 12 23 f0 8e 	movb   $0x8e,0xf02312d5
f01045e6:	c1 e8 10             	shr    $0x10,%eax
f01045e9:	66 a3 d6 12 23 f0    	mov    %ax,0xf02312d6
	SETGATE(idt[T_FPERR], 0, GD_KT, fperr, 0);
f01045ef:	b8 1e 4d 10 f0       	mov    $0xf0104d1e,%eax
f01045f4:	66 a3 e0 12 23 f0    	mov    %ax,0xf02312e0
f01045fa:	66 c7 05 e2 12 23 f0 	movw   $0x8,0xf02312e2
f0104601:	08 00 
f0104603:	c6 05 e4 12 23 f0 00 	movb   $0x0,0xf02312e4
f010460a:	c6 05 e5 12 23 f0 8e 	movb   $0x8e,0xf02312e5
f0104611:	c1 e8 10             	shr    $0x10,%eax
f0104614:	66 a3 e6 12 23 f0    	mov    %ax,0xf02312e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, align, 0);
f010461a:	b8 24 4d 10 f0       	mov    $0xf0104d24,%eax
f010461f:	66 a3 e8 12 23 f0    	mov    %ax,0xf02312e8
f0104625:	66 c7 05 ea 12 23 f0 	movw   $0x8,0xf02312ea
f010462c:	08 00 
f010462e:	c6 05 ec 12 23 f0 00 	movb   $0x0,0xf02312ec
f0104635:	c6 05 ed 12 23 f0 8e 	movb   $0x8e,0xf02312ed
f010463c:	c1 e8 10             	shr    $0x10,%eax
f010463f:	66 a3 ee 12 23 f0    	mov    %ax,0xf02312ee
	SETGATE(idt[T_MCHK], 0, GD_KT, mchk, 0);
f0104645:	b8 28 4d 10 f0       	mov    $0xf0104d28,%eax
f010464a:	66 a3 f0 12 23 f0    	mov    %ax,0xf02312f0
f0104650:	66 c7 05 f2 12 23 f0 	movw   $0x8,0xf02312f2
f0104657:	08 00 
f0104659:	c6 05 f4 12 23 f0 00 	movb   $0x0,0xf02312f4
f0104660:	c6 05 f5 12 23 f0 8e 	movb   $0x8e,0xf02312f5
f0104667:	c1 e8 10             	shr    $0x10,%eax
f010466a:	66 a3 f6 12 23 f0    	mov    %ax,0xf02312f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr, 0);
f0104670:	b8 2e 4d 10 f0       	mov    $0xf0104d2e,%eax
f0104675:	66 a3 f8 12 23 f0    	mov    %ax,0xf02312f8
f010467b:	66 c7 05 fa 12 23 f0 	movw   $0x8,0xf02312fa
f0104682:	08 00 
f0104684:	c6 05 fc 12 23 f0 00 	movb   $0x0,0xf02312fc
f010468b:	c6 05 fd 12 23 f0 8e 	movb   $0x8e,0xf02312fd
f0104692:	c1 e8 10             	shr    $0x10,%eax
f0104695:	66 a3 fe 12 23 f0    	mov    %ax,0xf02312fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trp_syscall, 3);
f010469b:	b8 34 4d 10 f0       	mov    $0xf0104d34,%eax
f01046a0:	66 a3 e0 13 23 f0    	mov    %ax,0xf02313e0
f01046a6:	66 c7 05 e2 13 23 f0 	movw   $0x8,0xf02313e2
f01046ad:	08 00 
f01046af:	c6 05 e4 13 23 f0 00 	movb   $0x0,0xf02313e4
f01046b6:	c6 05 e5 13 23 f0 ee 	movb   $0xee,0xf02313e5
f01046bd:	c1 e8 10             	shr    $0x10,%eax
f01046c0:	66 a3 e6 13 23 f0    	mov    %ax,0xf02313e6

	// Per-CPU setup 
	trap_init_percpu();
f01046c6:	e8 e5 fb ff ff       	call   f01042b0 <trap_init_percpu>
}
f01046cb:	c9                   	leave  
f01046cc:	c3                   	ret    

f01046cd <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01046cd:	55                   	push   %ebp
f01046ce:	89 e5                	mov    %esp,%ebp
f01046d0:	53                   	push   %ebx
f01046d1:	83 ec 14             	sub    $0x14,%esp
f01046d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01046d7:	8b 03                	mov    (%ebx),%eax
f01046d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046dd:	c7 04 24 f8 81 10 f0 	movl   $0xf01081f8,(%esp)
f01046e4:	e8 a2 fb ff ff       	call   f010428b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01046e9:	8b 43 04             	mov    0x4(%ebx),%eax
f01046ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f0:	c7 04 24 07 82 10 f0 	movl   $0xf0108207,(%esp)
f01046f7:	e8 8f fb ff ff       	call   f010428b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01046fc:	8b 43 08             	mov    0x8(%ebx),%eax
f01046ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104703:	c7 04 24 16 82 10 f0 	movl   $0xf0108216,(%esp)
f010470a:	e8 7c fb ff ff       	call   f010428b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010470f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104712:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104716:	c7 04 24 25 82 10 f0 	movl   $0xf0108225,(%esp)
f010471d:	e8 69 fb ff ff       	call   f010428b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104722:	8b 43 10             	mov    0x10(%ebx),%eax
f0104725:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104729:	c7 04 24 34 82 10 f0 	movl   $0xf0108234,(%esp)
f0104730:	e8 56 fb ff ff       	call   f010428b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104735:	8b 43 14             	mov    0x14(%ebx),%eax
f0104738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010473c:	c7 04 24 43 82 10 f0 	movl   $0xf0108243,(%esp)
f0104743:	e8 43 fb ff ff       	call   f010428b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104748:	8b 43 18             	mov    0x18(%ebx),%eax
f010474b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010474f:	c7 04 24 52 82 10 f0 	movl   $0xf0108252,(%esp)
f0104756:	e8 30 fb ff ff       	call   f010428b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010475b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010475e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104762:	c7 04 24 61 82 10 f0 	movl   $0xf0108261,(%esp)
f0104769:	e8 1d fb ff ff       	call   f010428b <cprintf>
}
f010476e:	83 c4 14             	add    $0x14,%esp
f0104771:	5b                   	pop    %ebx
f0104772:	5d                   	pop    %ebp
f0104773:	c3                   	ret    

f0104774 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104774:	55                   	push   %ebp
f0104775:	89 e5                	mov    %esp,%ebp
f0104777:	56                   	push   %esi
f0104778:	53                   	push   %ebx
f0104779:	83 ec 10             	sub    $0x10,%esp
f010477c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010477f:	e8 a5 1d 00 00       	call   f0106529 <cpunum>
f0104784:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010478c:	c7 04 24 c5 82 10 f0 	movl   $0xf01082c5,(%esp)
f0104793:	e8 f3 fa ff ff       	call   f010428b <cprintf>
	print_regs(&tf->tf_regs);
f0104798:	89 1c 24             	mov    %ebx,(%esp)
f010479b:	e8 2d ff ff ff       	call   f01046cd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01047a0:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01047a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047a8:	c7 04 24 e3 82 10 f0 	movl   $0xf01082e3,(%esp)
f01047af:	e8 d7 fa ff ff       	call   f010428b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01047b4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01047b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047bc:	c7 04 24 f6 82 10 f0 	movl   $0xf01082f6,(%esp)
f01047c3:	e8 c3 fa ff ff       	call   f010428b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01047c8:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01047cb:	83 f8 13             	cmp    $0x13,%eax
f01047ce:	77 09                	ja     f01047d9 <print_trapframe+0x65>
		return excnames[trapno];
f01047d0:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f01047d7:	eb 1f                	jmp    f01047f8 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01047d9:	83 f8 30             	cmp    $0x30,%eax
f01047dc:	74 15                	je     f01047f3 <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01047de:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01047e1:	83 fa 0f             	cmp    $0xf,%edx
f01047e4:	ba 7c 82 10 f0       	mov    $0xf010827c,%edx
f01047e9:	b9 8f 82 10 f0       	mov    $0xf010828f,%ecx
f01047ee:	0f 47 d1             	cmova  %ecx,%edx
f01047f1:	eb 05                	jmp    f01047f8 <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01047f3:	ba 70 82 10 f0       	mov    $0xf0108270,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01047f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104800:	c7 04 24 09 83 10 f0 	movl   $0xf0108309,(%esp)
f0104807:	e8 7f fa ff ff       	call   f010428b <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010480c:	3b 1d 60 1a 23 f0    	cmp    0xf0231a60,%ebx
f0104812:	75 19                	jne    f010482d <print_trapframe+0xb9>
f0104814:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104818:	75 13                	jne    f010482d <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010481a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010481d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104821:	c7 04 24 1b 83 10 f0 	movl   $0xf010831b,(%esp)
f0104828:	e8 5e fa ff ff       	call   f010428b <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010482d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104830:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104834:	c7 04 24 2a 83 10 f0 	movl   $0xf010832a,(%esp)
f010483b:	e8 4b fa ff ff       	call   f010428b <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104840:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104844:	75 51                	jne    f0104897 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104846:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104849:	89 c2                	mov    %eax,%edx
f010484b:	83 e2 01             	and    $0x1,%edx
f010484e:	ba 9e 82 10 f0       	mov    $0xf010829e,%edx
f0104853:	b9 a9 82 10 f0       	mov    $0xf01082a9,%ecx
f0104858:	0f 45 ca             	cmovne %edx,%ecx
f010485b:	89 c2                	mov    %eax,%edx
f010485d:	83 e2 02             	and    $0x2,%edx
f0104860:	ba b5 82 10 f0       	mov    $0xf01082b5,%edx
f0104865:	be bb 82 10 f0       	mov    $0xf01082bb,%esi
f010486a:	0f 44 d6             	cmove  %esi,%edx
f010486d:	83 e0 04             	and    $0x4,%eax
f0104870:	b8 c0 82 10 f0       	mov    $0xf01082c0,%eax
f0104875:	be 10 84 10 f0       	mov    $0xf0108410,%esi
f010487a:	0f 44 c6             	cmove  %esi,%eax
f010487d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104881:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104889:	c7 04 24 38 83 10 f0 	movl   $0xf0108338,(%esp)
f0104890:	e8 f6 f9 ff ff       	call   f010428b <cprintf>
f0104895:	eb 0c                	jmp    f01048a3 <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104897:	c7 04 24 92 6f 10 f0 	movl   $0xf0106f92,(%esp)
f010489e:	e8 e8 f9 ff ff       	call   f010428b <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01048a3:	8b 43 30             	mov    0x30(%ebx),%eax
f01048a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048aa:	c7 04 24 47 83 10 f0 	movl   $0xf0108347,(%esp)
f01048b1:	e8 d5 f9 ff ff       	call   f010428b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01048b6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 56 83 10 f0 	movl   $0xf0108356,(%esp)
f01048c5:	e8 c1 f9 ff ff       	call   f010428b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01048ca:	8b 43 38             	mov    0x38(%ebx),%eax
f01048cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048d1:	c7 04 24 69 83 10 f0 	movl   $0xf0108369,(%esp)
f01048d8:	e8 ae f9 ff ff       	call   f010428b <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01048dd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01048e1:	74 27                	je     f010490a <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01048e3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01048e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048ea:	c7 04 24 78 83 10 f0 	movl   $0xf0108378,(%esp)
f01048f1:	e8 95 f9 ff ff       	call   f010428b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01048f6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01048fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fe:	c7 04 24 87 83 10 f0 	movl   $0xf0108387,(%esp)
f0104905:	e8 81 f9 ff ff       	call   f010428b <cprintf>
	}
}
f010490a:	83 c4 10             	add    $0x10,%esp
f010490d:	5b                   	pop    %ebx
f010490e:	5e                   	pop    %esi
f010490f:	5d                   	pop    %ebp
f0104910:	c3                   	ret    

f0104911 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104911:	55                   	push   %ebp
f0104912:	89 e5                	mov    %esp,%ebp
f0104914:	57                   	push   %edi
f0104915:	56                   	push   %esi
f0104916:	53                   	push   %ebx
f0104917:	83 ec 2c             	sub    $0x2c,%esp
f010491a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010491d:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 1) == 0) {
f0104920:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0104924:	75 1c                	jne    f0104942 <page_fault_handler+0x31>
		panic("Page fault in kernel mode!");
f0104926:	c7 44 24 08 9a 83 10 	movl   $0xf010839a,0x8(%esp)
f010492d:	f0 
f010492e:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
f0104935:	00 
f0104936:	c7 04 24 b5 83 10 f0 	movl   $0xf01083b5,(%esp)
f010493d:	e8 fe b6 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if(curenv->env_pgfault_upcall) {
f0104942:	e8 e2 1b 00 00       	call   f0106529 <cpunum>
f0104947:	6b c0 74             	imul   $0x74,%eax,%eax
f010494a:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104950:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104954:	0f 84 e8 00 00 00    	je     f0104a42 <page_fault_handler+0x131>
		uint32_t *sp;
		if((UXSTACKTOP-PGSIZE) <= tf->tf_esp && tf->tf_esp <= (UXSTACKTOP-1)) {
f010495a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010495d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			sp = (uint32_t*)tf->tf_esp;
			sp --; //"push empty word"
f0104963:	83 e8 04             	sub    $0x4,%eax
f0104966:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010496c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104971:	0f 46 d0             	cmovbe %eax,%edx
f0104974:	89 d7                	mov    %edx,%edi
f0104976:	89 55 e0             	mov    %edx,-0x20(%ebp)
		} else {
			sp = (uint32_t*) UXSTACKTOP;
		}
		sp -= 13;
f0104979:	8d 42 cc             	lea    -0x34(%edx),%eax
f010497c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		user_mem_assert(curenv, (const void *)sp, 1, PTE_W | PTE_U);
f010497f:	e8 a5 1b 00 00       	call   f0106529 <cpunum>
f0104984:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010498b:	00 
f010498c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104993:	00 
f0104994:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104997:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010499b:	6b c0 74             	imul   $0x74,%eax,%eax
f010499e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01049a4:	89 04 24             	mov    %eax,(%esp)
f01049a7:	e8 0a ef ff ff       	call   f01038b6 <user_mem_assert>
		*sp = fault_va;
f01049ac:	89 77 cc             	mov    %esi,-0x34(%edi)
		*(sp+1) = tf->tf_err;
f01049af:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01049b2:	89 47 d0             	mov    %eax,-0x30(%edi)
		*((struct PushRegs *)(sp+2)) = tf->tf_regs;
f01049b5:	8d 7f d4             	lea    -0x2c(%edi),%edi
f01049b8:	89 de                	mov    %ebx,%esi
f01049ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01049bf:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01049c5:	74 03                	je     f01049ca <page_fault_handler+0xb9>
f01049c7:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01049c8:	b0 1f                	mov    $0x1f,%al
f01049ca:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01049d0:	74 05                	je     f01049d7 <page_fault_handler+0xc6>
f01049d2:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01049d4:	83 e8 02             	sub    $0x2,%eax
f01049d7:	89 c1                	mov    %eax,%ecx
f01049d9:	c1 e9 02             	shr    $0x2,%ecx
f01049dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01049de:	ba 00 00 00 00       	mov    $0x0,%edx
f01049e3:	a8 02                	test   $0x2,%al
f01049e5:	74 0b                	je     f01049f2 <page_fault_handler+0xe1>
f01049e7:	0f b7 16             	movzwl (%esi),%edx
f01049ea:	66 89 17             	mov    %dx,(%edi)
f01049ed:	ba 02 00 00 00       	mov    $0x2,%edx
f01049f2:	a8 01                	test   $0x1,%al
f01049f4:	74 07                	je     f01049fd <page_fault_handler+0xec>
f01049f6:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f01049fa:	88 04 17             	mov    %al,(%edi,%edx,1)
		*(sp+10) = tf->tf_eip;
f01049fd:	8b 43 30             	mov    0x30(%ebx),%eax
f0104a00:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104a03:	89 41 f4             	mov    %eax,-0xc(%ecx)
		*(sp+11) = tf->tf_eflags;
f0104a06:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a09:	89 41 f8             	mov    %eax,-0x8(%ecx)
		*(sp+12) = tf->tf_esp;
f0104a0c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a0f:	89 41 fc             	mov    %eax,-0x4(%ecx)
		
		tf->tf_esp = (uintptr_t) sp;
f0104a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a15:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104a18:	e8 0c 1b 00 00       	call   f0106529 <cpunum>
f0104a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a20:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104a26:	8b 40 64             	mov    0x64(%eax),%eax
f0104a29:	89 43 30             	mov    %eax,0x30(%ebx)

		env_run(curenv);
f0104a2c:	e8 f8 1a 00 00       	call   f0106529 <cpunum>
f0104a31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a34:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104a3a:	89 04 24             	mov    %eax,(%esp)
f0104a3d:	e8 04 f6 ff ff       	call   f0104046 <env_run>
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a42:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104a45:	e8 df 1a 00 00       	call   f0106529 <cpunum>
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a4a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104a4e:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104a52:	6b c0 74             	imul   $0x74,%eax,%eax
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	} else {
	// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a55:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104a5b:	8b 40 48             	mov    0x48(%eax),%eax
f0104a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a62:	c7 04 24 5c 85 10 f0 	movl   $0xf010855c,(%esp)
f0104a69:	e8 1d f8 ff ff       	call   f010428b <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104a6e:	89 1c 24             	mov    %ebx,(%esp)
f0104a71:	e8 fe fc ff ff       	call   f0104774 <print_trapframe>
		env_destroy(curenv);
f0104a76:	e8 ae 1a 00 00       	call   f0106529 <cpunum>
f0104a7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104a84:	89 04 24             	mov    %eax,(%esp)
f0104a87:	e8 19 f5 ff ff       	call   f0103fa5 <env_destroy>
	}
}
f0104a8c:	83 c4 2c             	add    $0x2c,%esp
f0104a8f:	5b                   	pop    %ebx
f0104a90:	5e                   	pop    %esi
f0104a91:	5f                   	pop    %edi
f0104a92:	5d                   	pop    %ebp
f0104a93:	c3                   	ret    

f0104a94 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104a94:	55                   	push   %ebp
f0104a95:	89 e5                	mov    %esp,%ebp
f0104a97:	57                   	push   %edi
f0104a98:	56                   	push   %esi
f0104a99:	83 ec 20             	sub    $0x20,%esp
f0104a9c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104a9f:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104aa0:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0104aa7:	74 01                	je     f0104aaa <trap+0x16>
		asm volatile("hlt");
f0104aa9:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104aaa:	e8 7a 1a 00 00       	call   f0106529 <cpunum>
f0104aaf:	6b d0 74             	imul   $0x74,%eax,%edx
f0104ab2:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104ab8:	b8 01 00 00 00       	mov    $0x1,%eax
f0104abd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104ac1:	83 f8 02             	cmp    $0x2,%eax
f0104ac4:	75 0c                	jne    f0104ad2 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104ac6:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104acd:	e8 d5 1c 00 00       	call   f01067a7 <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104ad2:	9c                   	pushf  
f0104ad3:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104ad4:	f6 c4 02             	test   $0x2,%ah
f0104ad7:	74 24                	je     f0104afd <trap+0x69>
f0104ad9:	c7 44 24 0c c1 83 10 	movl   $0xf01083c1,0xc(%esp)
f0104ae0:	f0 
f0104ae1:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0104ae8:	f0 
f0104ae9:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0104af0:	00 
f0104af1:	c7 04 24 b5 83 10 f0 	movl   $0xf01083b5,(%esp)
f0104af8:	e8 43 b5 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104afd:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104b01:	83 e0 03             	and    $0x3,%eax
f0104b04:	66 83 f8 03          	cmp    $0x3,%ax
f0104b08:	0f 85 a7 00 00 00    	jne    f0104bb5 <trap+0x121>
f0104b0e:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104b15:	e8 8d 1c 00 00       	call   f01067a7 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104b1a:	e8 0a 1a 00 00       	call   f0106529 <cpunum>
f0104b1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b22:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104b29:	75 24                	jne    f0104b4f <trap+0xbb>
f0104b2b:	c7 44 24 0c da 83 10 	movl   $0xf01083da,0xc(%esp)
f0104b32:	f0 
f0104b33:	c7 44 24 08 d3 7d 10 	movl   $0xf0107dd3,0x8(%esp)
f0104b3a:	f0 
f0104b3b:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0104b42:	00 
f0104b43:	c7 04 24 b5 83 10 f0 	movl   $0xf01083b5,(%esp)
f0104b4a:	e8 f1 b4 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104b4f:	e8 d5 19 00 00       	call   f0106529 <cpunum>
f0104b54:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b57:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104b5d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104b61:	75 2d                	jne    f0104b90 <trap+0xfc>
			env_free(curenv);
f0104b63:	e8 c1 19 00 00       	call   f0106529 <cpunum>
f0104b68:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104b71:	89 04 24             	mov    %eax,(%esp)
f0104b74:	e8 27 f2 ff ff       	call   f0103da0 <env_free>
			curenv = NULL;
f0104b79:	e8 ab 19 00 00       	call   f0106529 <cpunum>
f0104b7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b81:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0104b88:	00 00 00 
			sched_yield();
f0104b8b:	e8 92 02 00 00       	call   f0104e22 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104b90:	e8 94 19 00 00       	call   f0106529 <cpunum>
f0104b95:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b98:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104b9e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ba3:	89 c7                	mov    %eax,%edi
f0104ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104ba7:	e8 7d 19 00 00       	call   f0106529 <cpunum>
f0104bac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104baf:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104bb5:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104bbb:	8b 46 28             	mov    0x28(%esi),%eax
f0104bbe:	83 f8 27             	cmp    $0x27,%eax
f0104bc1:	75 19                	jne    f0104bdc <trap+0x148>
		cprintf("Spurious interrupt on irq 7\n");
f0104bc3:	c7 04 24 e1 83 10 f0 	movl   $0xf01083e1,(%esp)
f0104bca:	e8 bc f6 ff ff       	call   f010428b <cprintf>
		print_trapframe(tf);
f0104bcf:	89 34 24             	mov    %esi,(%esp)
f0104bd2:	e8 9d fb ff ff       	call   f0104774 <print_trapframe>
f0104bd7:	e9 b9 00 00 00       	jmp    f0104c95 <trap+0x201>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	switch(tf->tf_trapno) {
f0104bdc:	83 f8 03             	cmp    $0x3,%eax
f0104bdf:	90                   	nop
f0104be0:	74 2a                	je     f0104c0c <trap+0x178>
f0104be2:	83 f8 03             	cmp    $0x3,%eax
f0104be5:	77 0b                	ja     f0104bf2 <trap+0x15e>
f0104be7:	83 f8 01             	cmp    $0x1,%eax
f0104bea:	74 2a                	je     f0104c16 <trap+0x182>
f0104bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104bf0:	eb 62                	jmp    f0104c54 <trap+0x1c0>
f0104bf2:	83 f8 0e             	cmp    $0xe,%eax
f0104bf5:	74 0b                	je     f0104c02 <trap+0x16e>
f0104bf7:	83 f8 30             	cmp    $0x30,%eax
f0104bfa:	74 26                	je     f0104c22 <trap+0x18e>
f0104bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c00:	eb 52                	jmp    f0104c54 <trap+0x1c0>
		case T_PGFLT:
			page_fault_handler(tf);
f0104c02:	89 34 24             	mov    %esi,(%esp)
f0104c05:	e8 07 fd ff ff       	call   f0104911 <page_fault_handler>
f0104c0a:	eb 48                	jmp    f0104c54 <trap+0x1c0>
			break;
		case T_BRKPT:
			return monitor(tf);
f0104c0c:	89 34 24             	mov    %esi,(%esp)
f0104c0f:	e8 8e c1 ff ff       	call   f0100da2 <monitor>
f0104c14:	eb 7f                	jmp    f0104c95 <trap+0x201>
		case T_DEBUG:
			return monitor(tf);
f0104c16:	89 34 24             	mov    %esi,(%esp)
f0104c19:	e8 84 c1 ff ff       	call   f0100da2 <monitor>
f0104c1e:	66 90                	xchg   %ax,%ax
f0104c20:	eb 73                	jmp    f0104c95 <trap+0x201>
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f0104c22:	8b 46 04             	mov    0x4(%esi),%eax
f0104c25:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104c29:	8b 06                	mov    (%esi),%eax
f0104c2b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104c2f:	8b 46 10             	mov    0x10(%esi),%eax
f0104c32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c36:	8b 46 18             	mov    0x18(%esi),%eax
f0104c39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c3d:	8b 46 14             	mov    0x14(%esi),%eax
f0104c40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c44:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104c47:	89 04 24             	mov    %eax,(%esp)
f0104c4a:	e8 41 02 00 00       	call   f0104e90 <syscall>
f0104c4f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104c52:	eb 41                	jmp    f0104c95 <trap+0x201>
								tf->tf_regs.reg_esi);
			return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104c54:	89 34 24             	mov    %esi,(%esp)
f0104c57:	e8 18 fb ff ff       	call   f0104774 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104c5c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104c61:	75 1c                	jne    f0104c7f <trap+0x1eb>
		panic("unhandled trap in kernel");
f0104c63:	c7 44 24 08 fe 83 10 	movl   $0xf01083fe,0x8(%esp)
f0104c6a:	f0 
f0104c6b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0104c72:	00 
f0104c73:	c7 04 24 b5 83 10 f0 	movl   $0xf01083b5,(%esp)
f0104c7a:	e8 c1 b3 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104c7f:	e8 a5 18 00 00       	call   f0106529 <cpunum>
f0104c84:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c87:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104c8d:	89 04 24             	mov    %eax,(%esp)
f0104c90:	e8 10 f3 ff ff       	call   f0103fa5 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104c95:	e8 8f 18 00 00       	call   f0106529 <cpunum>
f0104c9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c9d:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104ca4:	74 2a                	je     f0104cd0 <trap+0x23c>
f0104ca6:	e8 7e 18 00 00       	call   f0106529 <cpunum>
f0104cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cae:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104cb4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104cb8:	75 16                	jne    f0104cd0 <trap+0x23c>
		env_run(curenv);
f0104cba:	e8 6a 18 00 00       	call   f0106529 <cpunum>
f0104cbf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cc2:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104cc8:	89 04 24             	mov    %eax,(%esp)
f0104ccb:	e8 76 f3 ff ff       	call   f0104046 <env_run>
	else
		sched_yield();
f0104cd0:	e8 4d 01 00 00       	call   f0104e22 <sched_yield>
f0104cd5:	90                   	nop

f0104cd6 <divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
*/
TRAPHANDLER_NOEC(divide, T_DIVIDE)
f0104cd6:	6a 00                	push   $0x0
f0104cd8:	6a 00                	push   $0x0
f0104cda:	eb 5e                	jmp    f0104d3a <_alltraps>

f0104cdc <debug>:
TRAPHANDLER_NOEC(debug, T_DEBUG)
f0104cdc:	6a 00                	push   $0x0
f0104cde:	6a 01                	push   $0x1
f0104ce0:	eb 58                	jmp    f0104d3a <_alltraps>

f0104ce2 <nmi>:
TRAPHANDLER_NOEC(nmi, T_NMI)
f0104ce2:	6a 00                	push   $0x0
f0104ce4:	6a 02                	push   $0x2
f0104ce6:	eb 52                	jmp    f0104d3a <_alltraps>

f0104ce8 <brkpt>:
TRAPHANDLER_NOEC(brkpt, T_BRKPT)
f0104ce8:	6a 00                	push   $0x0
f0104cea:	6a 03                	push   $0x3
f0104cec:	eb 4c                	jmp    f0104d3a <_alltraps>

f0104cee <oflow>:
TRAPHANDLER_NOEC(oflow, T_OFLOW)
f0104cee:	6a 00                	push   $0x0
f0104cf0:	6a 04                	push   $0x4
f0104cf2:	eb 46                	jmp    f0104d3a <_alltraps>

f0104cf4 <bound>:
TRAPHANDLER_NOEC(bound, T_BOUND)
f0104cf4:	6a 00                	push   $0x0
f0104cf6:	6a 05                	push   $0x5
f0104cf8:	eb 40                	jmp    f0104d3a <_alltraps>

f0104cfa <illop>:
TRAPHANDLER_NOEC(illop, T_ILLOP)
f0104cfa:	6a 00                	push   $0x0
f0104cfc:	6a 06                	push   $0x6
f0104cfe:	eb 3a                	jmp    f0104d3a <_alltraps>

f0104d00 <device>:
TRAPHANDLER_NOEC(device, T_DEVICE)
f0104d00:	6a 00                	push   $0x0
f0104d02:	6a 07                	push   $0x7
f0104d04:	eb 34                	jmp    f0104d3a <_alltraps>

f0104d06 <dblflt>:
TRAPHANDLER(dblflt, T_DBLFLT)
f0104d06:	6a 08                	push   $0x8
f0104d08:	eb 30                	jmp    f0104d3a <_alltraps>

f0104d0a <tss>:
// 9 is reserved
TRAPHANDLER(tss, T_TSS)
f0104d0a:	6a 0a                	push   $0xa
f0104d0c:	eb 2c                	jmp    f0104d3a <_alltraps>

f0104d0e <segnp>:
TRAPHANDLER(segnp, T_SEGNP)
f0104d0e:	6a 0b                	push   $0xb
f0104d10:	eb 28                	jmp    f0104d3a <_alltraps>

f0104d12 <stack>:
TRAPHANDLER(stack, T_STACK)
f0104d12:	6a 0c                	push   $0xc
f0104d14:	eb 24                	jmp    f0104d3a <_alltraps>

f0104d16 <gpflt>:
TRAPHANDLER(gpflt, T_GPFLT)
f0104d16:	6a 0d                	push   $0xd
f0104d18:	eb 20                	jmp    f0104d3a <_alltraps>

f0104d1a <pgflt>:
TRAPHANDLER(pgflt, T_PGFLT)
f0104d1a:	6a 0e                	push   $0xe
f0104d1c:	eb 1c                	jmp    f0104d3a <_alltraps>

f0104d1e <fperr>:
//15 is reserved
TRAPHANDLER_NOEC(fperr, T_FPERR)
f0104d1e:	6a 00                	push   $0x0
f0104d20:	6a 10                	push   $0x10
f0104d22:	eb 16                	jmp    f0104d3a <_alltraps>

f0104d24 <align>:
TRAPHANDLER(align, T_ALIGN)
f0104d24:	6a 11                	push   $0x11
f0104d26:	eb 12                	jmp    f0104d3a <_alltraps>

f0104d28 <mchk>:
TRAPHANDLER_NOEC(mchk, T_MCHK)
f0104d28:	6a 00                	push   $0x0
f0104d2a:	6a 12                	push   $0x12
f0104d2c:	eb 0c                	jmp    f0104d3a <_alltraps>

f0104d2e <simderr>:
TRAPHANDLER_NOEC(simderr, T_SIMDERR)
f0104d2e:	6a 00                	push   $0x0
f0104d30:	6a 13                	push   $0x13
f0104d32:	eb 06                	jmp    f0104d3a <_alltraps>

f0104d34 <trp_syscall>:
TRAPHANDLER_NOEC(trp_syscall, T_SYSCALL)
f0104d34:	6a 00                	push   $0x0
f0104d36:	6a 30                	push   $0x30
f0104d38:	eb 00                	jmp    f0104d3a <_alltraps>

f0104d3a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds //pushes with padding
f0104d3a:	1e                   	push   %ds
	pushl %es
f0104d3b:	06                   	push   %es
	pushal //push all registers
f0104d3c:	60                   	pusha  

	movl $GD_KD, %eax
f0104d3d:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %es
f0104d42:	8e c0                	mov    %eax,%es
	movl %eax, %ds
f0104d44:	8e d8                	mov    %eax,%ds
	pushl %esp
f0104d46:	54                   	push   %esp
	call trap
f0104d47:	e8 48 fd ff ff       	call   f0104a94 <trap>

f0104d4c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d4c:	55                   	push   %ebp
f0104d4d:	89 e5                	mov    %esp,%ebp
f0104d4f:	83 ec 18             	sub    $0x18,%esp
f0104d52:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d58:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104d5d:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104d60:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104d63:	83 f9 02             	cmp    $0x2,%ecx
f0104d66:	76 0f                	jbe    f0104d77 <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d68:	83 c0 01             	add    $0x1,%eax
f0104d6b:	83 c2 7c             	add    $0x7c,%edx
f0104d6e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104d73:	75 e8                	jne    f0104d5d <sched_halt+0x11>
f0104d75:	eb 07                	jmp    f0104d7e <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104d77:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104d7c:	75 1a                	jne    f0104d98 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104d7e:	c7 04 24 d0 85 10 f0 	movl   $0xf01085d0,(%esp)
f0104d85:	e8 01 f5 ff ff       	call   f010428b <cprintf>
		while (1)
			monitor(NULL);
f0104d8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104d91:	e8 0c c0 ff ff       	call   f0100da2 <monitor>
f0104d96:	eb f2                	jmp    f0104d8a <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104d98:	e8 8c 17 00 00       	call   f0106529 <cpunum>
f0104d9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da0:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0104da7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104daa:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104daf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104db4:	77 20                	ja     f0104dd6 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104db6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104dba:	c7 44 24 08 48 6c 10 	movl   $0xf0106c48,0x8(%esp)
f0104dc1:	f0 
f0104dc2:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f0104dc9:	00 
f0104dca:	c7 04 24 f9 85 10 f0 	movl   $0xf01085f9,(%esp)
f0104dd1:	e8 6a b2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104dd6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104ddb:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104dde:	e8 46 17 00 00       	call   f0106529 <cpunum>
f0104de3:	6b d0 74             	imul   $0x74,%eax,%edx
f0104de6:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104dec:	b8 02 00 00 00       	mov    $0x2,%eax
f0104df1:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104df5:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104dfc:	e8 52 1a 00 00       	call   f0106853 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104e01:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104e03:	e8 21 17 00 00       	call   f0106529 <cpunum>
f0104e08:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104e0b:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0104e11:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104e16:	89 c4                	mov    %eax,%esp
f0104e18:	6a 00                	push   $0x0
f0104e1a:	6a 00                	push   $0x0
f0104e1c:	fb                   	sti    
f0104e1d:	f4                   	hlt    
f0104e1e:	eb fd                	jmp    f0104e1d <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104e20:	c9                   	leave  
f0104e21:	c3                   	ret    

f0104e22 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104e22:	55                   	push   %ebp
f0104e23:	89 e5                	mov    %esp,%ebp
f0104e25:	83 ec 18             	sub    $0x18,%esp
f0104e28:	a1 48 12 23 f0       	mov    0xf0231248,%eax
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	for(int i = 0; i < NENV; i++) {
		if(envs[i].env_status == ENV_RUNNABLE) {
f0104e2d:	ba 00 04 00 00       	mov    $0x400,%edx
f0104e32:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104e36:	75 08                	jne    f0104e40 <sched_yield+0x1e>
			env_run(&envs[i]);
f0104e38:	89 04 24             	mov    %eax,(%esp)
f0104e3b:	e8 06 f2 ff ff       	call   f0104046 <env_run>
f0104e40:	83 c0 7c             	add    $0x7c,%eax
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	for(int i = 0; i < NENV; i++) {
f0104e43:	83 ea 01             	sub    $0x1,%edx
f0104e46:	75 ea                	jne    f0104e32 <sched_yield+0x10>
		if(envs[i].env_status == ENV_RUNNABLE) {
			env_run(&envs[i]);
		}
	}

	if(curenv && curenv->env_status == ENV_RUNNING) {
f0104e48:	e8 dc 16 00 00       	call   f0106529 <cpunum>
f0104e4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e50:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104e57:	74 2a                	je     f0104e83 <sched_yield+0x61>
f0104e59:	e8 cb 16 00 00       	call   f0106529 <cpunum>
f0104e5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e61:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104e67:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e6b:	75 16                	jne    f0104e83 <sched_yield+0x61>
		env_run(curenv);
f0104e6d:	e8 b7 16 00 00       	call   f0106529 <cpunum>
f0104e72:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e75:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104e7b:	89 04 24             	mov    %eax,(%esp)
f0104e7e:	e8 c3 f1 ff ff       	call   f0104046 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104e83:	e8 c4 fe ff ff       	call   f0104d4c <sched_halt>
}
f0104e88:	c9                   	leave  
f0104e89:	c3                   	ret    
f0104e8a:	66 90                	xchg   %ax,%ax
f0104e8c:	66 90                	xchg   %ax,%ax
f0104e8e:	66 90                	xchg   %ax,%ax

f0104e90 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104e90:	55                   	push   %ebp
f0104e91:	89 e5                	mov    %esp,%ebp
f0104e93:	57                   	push   %edi
f0104e94:	56                   	push   %esi
f0104e95:	53                   	push   %ebx
f0104e96:	83 ec 2c             	sub    $0x2c,%esp
f0104e99:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f0104e9f:	83 f8 0a             	cmp    $0xa,%eax
f0104ea2:	0f 87 ab 04 00 00    	ja     f0105353 <syscall+0x4c3>
f0104ea8:	ff 24 85 cc 88 10 f0 	jmp    *-0xfef7734(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104eaf:	e8 75 16 00 00       	call   f0106529 <cpunum>
f0104eb4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104ebb:	00 
f0104ebc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ec3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104ec7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eca:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104ed0:	89 04 24             	mov    %eax,(%esp)
f0104ed3:	e8 de e9 ff ff       	call   f01038b6 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104edb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104edf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ee3:	c7 04 24 06 86 10 f0 	movl   $0xf0108606,(%esp)
f0104eea:	e8 9c f3 ff ff       	call   f010428b <cprintf>
	// LAB 3: Your code here.

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f0104eef:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ef4:	e9 5f 04 00 00       	jmp    f0105358 <syscall+0x4c8>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104ef9:	e8 47 b7 ff ff       	call   f0100645 <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104efe:	66 90                	xchg   %ax,%ax
f0104f00:	e9 53 04 00 00       	jmp    f0105358 <syscall+0x4c8>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104f05:	e8 1f 16 00 00       	call   f0106529 <cpunum>
f0104f0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f0d:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104f13:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104f16:	e9 3d 04 00 00       	jmp    f0105358 <syscall+0x4c8>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104f1b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f22:	00 
f0104f23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f2d:	89 04 24             	mov    %eax,(%esp)
f0104f30:	e8 74 ea ff ff       	call   f01039a9 <envid2env>
		return r;
f0104f35:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104f37:	85 c0                	test   %eax,%eax
f0104f39:	78 6e                	js     f0104fa9 <syscall+0x119>
		return r;
	if (e == curenv)
f0104f3b:	e8 e9 15 00 00       	call   f0106529 <cpunum>
f0104f40:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f46:	39 90 28 20 23 f0    	cmp    %edx,-0xfdcdfd8(%eax)
f0104f4c:	75 23                	jne    f0104f71 <syscall+0xe1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104f4e:	e8 d6 15 00 00       	call   f0106529 <cpunum>
f0104f53:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f56:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104f5c:	8b 40 48             	mov    0x48(%eax),%eax
f0104f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f63:	c7 04 24 0b 86 10 f0 	movl   $0xf010860b,(%esp)
f0104f6a:	e8 1c f3 ff ff       	call   f010428b <cprintf>
f0104f6f:	eb 28                	jmp    f0104f99 <syscall+0x109>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104f71:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104f74:	e8 b0 15 00 00       	call   f0106529 <cpunum>
f0104f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104f7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f80:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104f86:	8b 40 48             	mov    0x48(%eax),%eax
f0104f89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f8d:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0104f94:	e8 f2 f2 ff ff       	call   f010428b <cprintf>
	env_destroy(e);
f0104f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f9c:	89 04 24             	mov    %eax,(%esp)
f0104f9f:	e8 01 f0 ff ff       	call   f0103fa5 <env_destroy>
	return 0;
f0104fa4:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
f0104fa9:	89 d0                	mov    %edx,%eax
f0104fab:	e9 a8 03 00 00       	jmp    f0105358 <syscall+0x4c8>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104fb0:	e8 6d fe ff ff       	call   f0104e22 <sched_yield>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *newenv;
	int ret = env_alloc(&newenv, curenv->env_id);
f0104fb5:	e8 6f 15 00 00       	call   f0106529 <cpunum>
f0104fba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fbd:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104fc3:	8b 40 48             	mov    0x48(%eax),%eax
f0104fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fcd:	89 04 24             	mov    %eax,(%esp)
f0104fd0:	e8 e5 ea ff ff       	call   f0103aba <env_alloc>
f0104fd5:	89 c3                	mov    %eax,%ebx

	if(ret < 0) {
f0104fd7:	85 c0                	test   %eax,%eax
f0104fd9:	79 17                	jns    f0104ff2 <syscall+0x162>
		// TODO: print more error codes in other places to avoid debugging nightmares
		cprintf("%e\n", ret);
f0104fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fdf:	c7 04 24 50 8b 10 f0 	movl   $0xf0108b50,(%esp)
f0104fe6:	e8 a0 f2 ff ff       	call   f010428b <cprintf>
		return ret;
f0104feb:	89 d8                	mov    %ebx,%eax
f0104fed:	e9 66 03 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	newenv->env_status = ENV_NOT_RUNNABLE;
f0104ff2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ff5:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	newenv->env_tf = curenv->env_tf;
f0104ffc:	e8 28 15 00 00       	call   f0106529 <cpunum>
f0105001:	6b c0 74             	imul   $0x74,%eax,%eax
f0105004:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f010500a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010500f:	89 df                	mov    %ebx,%edi
f0105011:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_regs.reg_eax = 0;
f0105013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105016:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f010501d:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
		case SYS_yield:
			sys_yield();
		case SYS_exofork:
			return sys_exofork();
f0105020:	e9 33 03 00 00       	jmp    f0105358 <syscall+0x4c8>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f0105025:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010502c:	00 
f010502d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105034:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105037:	89 04 24             	mov    %eax,(%esp)
f010503a:	e8 6a e9 ff ff       	call   f01039a9 <envid2env>
f010503f:	85 c0                	test   %eax,%eax
f0105041:	79 16                	jns    f0105059 <syscall+0x1c9>
		cprintf("Bad env passed to envid2env from env_set_status\n");
f0105043:	c7 04 24 5c 86 10 f0 	movl   $0xf010865c,(%esp)
f010504a:	e8 3c f2 ff ff       	call   f010428b <cprintf>
		return -E_BAD_ENV;
f010504f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105054:	e9 ff 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	if( (status!=ENV_RUNNABLE) && (status!=ENV_NOT_RUNNABLE) ) {
f0105059:	83 fb 04             	cmp    $0x4,%ebx
f010505c:	74 1b                	je     f0105079 <syscall+0x1e9>
f010505e:	83 fb 02             	cmp    $0x2,%ebx
f0105061:	74 16                	je     f0105079 <syscall+0x1e9>
		cprintf("Invalid status to env_set_status");
f0105063:	c7 04 24 90 86 10 f0 	movl   $0xf0108690,(%esp)
f010506a:	e8 1c f2 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f010506f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105074:	e9 df 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	target_env->env_status = status;
f0105079:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010507c:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f010507f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_yield:
			sys_yield();
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0105084:	e9 cf 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	if( ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & ~(PTE_AVAIL|PTE_W|PTE_U|PTE_P))) {
f0105089:	8b 45 14             	mov    0x14(%ebp),%eax
f010508c:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105091:	83 f8 05             	cmp    $0x5,%eax
f0105094:	74 16                	je     f01050ac <syscall+0x21c>
		cprintf("Invalid perms passed to sys_page_alloc\n");
f0105096:	c7 04 24 b4 86 10 f0 	movl   $0xf01086b4,(%esp)
f010509d:	e8 e9 f1 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f01050a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a7:	e9 ac 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	if( ((uintptr_t)va >= UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)) {
f01050ac:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01050b2:	77 0b                	ja     f01050bf <syscall+0x22f>
f01050b4:	89 d8                	mov    %ebx,%eax
f01050b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01050bb:	39 c3                	cmp    %eax,%ebx
f01050bd:	74 16                	je     f01050d5 <syscall+0x245>
		cprintf("Invalid va passed to sys_page_alloc\n");
f01050bf:	c7 04 24 dc 86 10 f0 	movl   $0xf01086dc,(%esp)
f01050c6:	e8 c0 f1 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f01050cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050d0:	e9 83 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f01050d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050dc:	00 
f01050dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050e7:	89 04 24             	mov    %eax,(%esp)
f01050ea:	e8 ba e8 ff ff       	call   f01039a9 <envid2env>
f01050ef:	85 c0                	test   %eax,%eax
f01050f1:	79 16                	jns    f0105109 <syscall+0x279>
		cprintf("Bad env passed to envid2env from sys_page_alloc\n");
f01050f3:	c7 04 24 04 87 10 f0 	movl   $0xf0108704,(%esp)
f01050fa:	e8 8c f1 ff ff       	call   f010428b <cprintf>
		return -E_BAD_ENV;
f01050ff:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105104:	e9 4f 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f0105109:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105110:	e8 64 c3 ff ff       	call   f0101479 <page_alloc>

	if(!pp || (page_insert(target_env->env_pgdir, pp, va, perm)<0) ) {
f0105115:	85 c0                	test   %eax,%eax
f0105117:	74 21                	je     f010513a <syscall+0x2aa>
f0105119:	8b 7d 14             	mov    0x14(%ebp),%edi
f010511c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105120:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010512b:	8b 40 60             	mov    0x60(%eax),%eax
f010512e:	89 04 24             	mov    %eax,(%esp)
f0105131:	e8 44 c6 ff ff       	call   f010177a <page_insert>
f0105136:	85 c0                	test   %eax,%eax
f0105138:	79 16                	jns    f0105150 <syscall+0x2c0>
		cprintf("No memory in sys_page_alloc\n");
f010513a:	c7 04 24 3e 86 10 f0 	movl   $0xf010863e,(%esp)
f0105141:	e8 45 f1 ff ff       	call   f010428b <cprintf>
		return -E_NO_MEM;
f0105146:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010514b:	e9 08 02 00 00       	jmp    f0105358 <syscall+0x4c8>
	}
	return 0;
f0105150:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
f0105155:	e9 fe 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	if( ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) || (perm & ~(PTE_AVAIL|PTE_W|PTE_U|PTE_P))) {
f010515a:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010515d:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105162:	83 f8 05             	cmp    $0x5,%eax
f0105165:	74 16                	je     f010517d <syscall+0x2ed>
		cprintf("Invalid perms passed to sys_page_med\n");
f0105167:	c7 04 24 38 87 10 f0 	movl   $0xf0108738,(%esp)
f010516e:	e8 18 f1 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f0105173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105178:	e9 db 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	if( ((uintptr_t)srcva >= UTOP) || (ROUNDDOWN((uintptr_t)srcva, PGSIZE) != (uintptr_t)srcva)) {
f010517d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105183:	77 0b                	ja     f0105190 <syscall+0x300>
f0105185:	89 d8                	mov    %ebx,%eax
f0105187:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010518c:	39 c3                	cmp    %eax,%ebx
f010518e:	74 16                	je     f01051a6 <syscall+0x316>
		cprintf("Invalid srcva passed to sys_page_map\n");
f0105190:	c7 04 24 60 87 10 f0 	movl   $0xf0108760,(%esp)
f0105197:	e8 ef f0 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f010519c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051a1:	e9 b2 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	if( ((uintptr_t)dstva >= UTOP) || (ROUNDDOWN((uintptr_t)dstva, PGSIZE) != (uintptr_t)dstva)) {
f01051a6:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01051ad:	77 0d                	ja     f01051bc <syscall+0x32c>
f01051af:	8b 45 18             	mov    0x18(%ebp),%eax
f01051b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01051b7:	39 45 18             	cmp    %eax,0x18(%ebp)
f01051ba:	74 16                	je     f01051d2 <syscall+0x342>
		cprintf("Invalid dstva passed to sys_page_map\n");
f01051bc:	c7 04 24 88 87 10 f0 	movl   $0xf0108788,(%esp)
f01051c3:	e8 c3 f0 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f01051c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051cd:	e9 86 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	}
	
	struct Env *srcenv, *dstenv;
	pte_t *src_pte;

	if((envid2env(srcenvid, &srcenv, 1) < 0) || (envid2env(dstenvid, &dstenv, 1) < 0) ) {
f01051d2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051d9:	00 
f01051da:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051e4:	89 04 24             	mov    %eax,(%esp)
f01051e7:	e8 bd e7 ff ff       	call   f01039a9 <envid2env>
f01051ec:	85 c0                	test   %eax,%eax
f01051ee:	78 1e                	js     f010520e <syscall+0x37e>
f01051f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051f7:	00 
f01051f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105202:	89 04 24             	mov    %eax,(%esp)
f0105205:	e8 9f e7 ff ff       	call   f01039a9 <envid2env>
f010520a:	85 c0                	test   %eax,%eax
f010520c:	79 16                	jns    f0105224 <syscall+0x394>
		cprintf("Bad env passed to envid2env from sys_page_map\n");
f010520e:	c7 04 24 b0 87 10 f0 	movl   $0xf01087b0,(%esp)
f0105215:	e8 71 f0 ff ff       	call   f010428b <cprintf>
		return -E_BAD_ENV;
f010521a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010521f:	e9 34 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	struct PageInfo* pp = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0105224:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105227:	89 44 24 08          	mov    %eax,0x8(%esp)
f010522b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010522f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105232:	8b 40 60             	mov    0x60(%eax),%eax
f0105235:	89 04 24             	mov    %eax,(%esp)
f0105238:	e8 46 c4 ff ff       	call   f0101683 <page_lookup>
	
	if(!pp) {
f010523d:	85 c0                	test   %eax,%eax
f010523f:	75 16                	jne    f0105257 <syscall+0x3c7>
		cprintf("srcva not mapped in sys_page_map\n");
f0105241:	c7 04 24 e0 87 10 f0 	movl   $0xf01087e0,(%esp)
f0105248:	e8 3e f0 ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f010524d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105252:	e9 01 01 00 00       	jmp    f0105358 <syscall+0x4c8>
	if( (!(*src_pte & PTE_W)) & (perm & PTE_W)) {
		cprintf("cannot set a read-only page to writable in sys_page_map\n");
		return -E_INVAL;
	}

	if(page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0) {
f0105257:	8b 75 1c             	mov    0x1c(%ebp),%esi
f010525a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010525e:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105261:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105265:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105269:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010526c:	8b 40 60             	mov    0x60(%eax),%eax
f010526f:	89 04 24             	mov    %eax,(%esp)
f0105272:	e8 03 c5 ff ff       	call   f010177a <page_insert>
f0105277:	85 c0                	test   %eax,%eax
f0105279:	79 16                	jns    f0105291 <syscall+0x401>
		cprintf("page_insert out of memory in sys_page_map\n");
f010527b:	c7 04 24 04 88 10 f0 	movl   $0xf0108804,(%esp)
f0105282:	e8 04 f0 ff ff       	call   f010428b <cprintf>
		return -E_NO_MEM;
f0105287:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010528c:	e9 c7 00 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	return 0;
f0105291:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
f0105296:	e9 bd 00 00 00       	jmp    f0105358 <syscall+0x4c8>
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f010529b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052a2:	00 
f01052a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052ad:	89 04 24             	mov    %eax,(%esp)
f01052b0:	e8 f4 e6 ff ff       	call   f01039a9 <envid2env>
f01052b5:	85 c0                	test   %eax,%eax
f01052b7:	79 16                	jns    f01052cf <syscall+0x43f>
		cprintf("Bad env passed to envid2env from sys_page_unmap\n");
f01052b9:	c7 04 24 30 88 10 f0 	movl   $0xf0108830,(%esp)
f01052c0:	e8 c6 ef ff ff       	call   f010428b <cprintf>
		return -E_BAD_ENV;
f01052c5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01052ca:	e9 89 00 00 00       	jmp    f0105358 <syscall+0x4c8>
	}

	if( ((uintptr_t)va >= UTOP) || (ROUNDDOWN((uintptr_t)va, PGSIZE) != (uintptr_t)va)) {
f01052cf:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01052d5:	77 0b                	ja     f01052e2 <syscall+0x452>
f01052d7:	89 d8                	mov    %ebx,%eax
f01052d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01052de:	39 c3                	cmp    %eax,%ebx
f01052e0:	74 13                	je     f01052f5 <syscall+0x465>
		cprintf("Invalid va passed to sys_page_unmap\n");
f01052e2:	c7 04 24 64 88 10 f0 	movl   $0xf0108864,(%esp)
f01052e9:	e8 9d ef ff ff       	call   f010428b <cprintf>
		return -E_INVAL;
f01052ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052f3:	eb 63                	jmp    f0105358 <syscall+0x4c8>
	}

	page_remove(target_env->env_pgdir, va);
f01052f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01052f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052fc:	8b 40 60             	mov    0x60(%eax),%eax
f01052ff:	89 04 24             	mov    %eax,(%esp)
f0105302:	e8 2a c4 ff ff       	call   f0101731 <page_remove>
	return 0;
f0105307:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *) a2, (int) a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *) a2);
f010530c:	eb 4a                	jmp    f0105358 <syscall+0x4c8>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *target_env;

	if(envid2env(envid, &target_env, 1) < 0) {
f010530e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105315:	00 
f0105316:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105319:	89 44 24 04          	mov    %eax,0x4(%esp)
f010531d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105320:	89 04 24             	mov    %eax,(%esp)
f0105323:	e8 81 e6 ff ff       	call   f01039a9 <envid2env>
f0105328:	85 c0                	test   %eax,%eax
f010532a:	79 1a                	jns    f0105346 <syscall+0x4b6>
		cprintf("Bad envid %d passed to envid2env from env_set_pgfault_upcall\n", envid);
f010532c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010532f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105333:	c7 04 24 8c 88 10 f0 	movl   $0xf010888c,(%esp)
f010533a:	e8 4c ef ff ff       	call   f010428b <cprintf>
		return -E_BAD_ENV;
f010533f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105344:	eb 12                	jmp    f0105358 <syscall+0x4c8>
	}

	target_env->env_pgfault_upcall = func;
f0105346:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105349:	89 58 64             	mov    %ebx,0x64(%eax)

	return 0;
f010534c:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *) a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);
f0105351:	eb 05                	jmp    f0105358 <syscall+0x4c8>
	default:
		return -E_INVAL;
f0105353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0105358:	83 c4 2c             	add    $0x2c,%esp
f010535b:	5b                   	pop    %ebx
f010535c:	5e                   	pop    %esi
f010535d:	5f                   	pop    %edi
f010535e:	5d                   	pop    %ebp
f010535f:	c3                   	ret    

f0105360 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105360:	55                   	push   %ebp
f0105361:	89 e5                	mov    %esp,%ebp
f0105363:	57                   	push   %edi
f0105364:	56                   	push   %esi
f0105365:	53                   	push   %ebx
f0105366:	83 ec 14             	sub    $0x14,%esp
f0105369:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010536c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010536f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105372:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105375:	8b 1a                	mov    (%edx),%ebx
f0105377:	8b 01                	mov    (%ecx),%eax
f0105379:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010537c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105383:	e9 88 00 00 00       	jmp    f0105410 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0105388:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010538b:	01 d8                	add    %ebx,%eax
f010538d:	89 c7                	mov    %eax,%edi
f010538f:	c1 ef 1f             	shr    $0x1f,%edi
f0105392:	01 c7                	add    %eax,%edi
f0105394:	d1 ff                	sar    %edi
f0105396:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105399:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010539c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010539f:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053a1:	eb 03                	jmp    f01053a6 <stab_binsearch+0x46>
			m--;
f01053a3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053a6:	39 c3                	cmp    %eax,%ebx
f01053a8:	7f 1f                	jg     f01053c9 <stab_binsearch+0x69>
f01053aa:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01053ae:	83 ea 0c             	sub    $0xc,%edx
f01053b1:	39 f1                	cmp    %esi,%ecx
f01053b3:	75 ee                	jne    f01053a3 <stab_binsearch+0x43>
f01053b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01053b8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01053bb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053be:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01053c2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053c5:	76 18                	jbe    f01053df <stab_binsearch+0x7f>
f01053c7:	eb 05                	jmp    f01053ce <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01053c9:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01053cc:	eb 42                	jmp    f0105410 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01053ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01053d1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01053d3:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01053d6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01053dd:	eb 31                	jmp    f0105410 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01053df:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053e2:	73 17                	jae    f01053fb <stab_binsearch+0x9b>
			*region_right = m - 1;
f01053e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01053e7:	83 e8 01             	sub    $0x1,%eax
f01053ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01053ed:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01053f0:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01053f2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01053f9:	eb 15                	jmp    f0105410 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01053fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053fe:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105401:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105403:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105407:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105409:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105410:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105413:	0f 8e 6f ff ff ff    	jle    f0105388 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105419:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010541d:	75 0f                	jne    f010542e <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010541f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105422:	8b 00                	mov    (%eax),%eax
f0105424:	83 e8 01             	sub    $0x1,%eax
f0105427:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010542a:	89 07                	mov    %eax,(%edi)
f010542c:	eb 2c                	jmp    f010545a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010542e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105431:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105436:	8b 0f                	mov    (%edi),%ecx
f0105438:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010543b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010543e:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105441:	eb 03                	jmp    f0105446 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105443:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105446:	39 c8                	cmp    %ecx,%eax
f0105448:	7e 0b                	jle    f0105455 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f010544a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010544e:	83 ea 0c             	sub    $0xc,%edx
f0105451:	39 f3                	cmp    %esi,%ebx
f0105453:	75 ee                	jne    f0105443 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105458:	89 07                	mov    %eax,(%edi)
	}
}
f010545a:	83 c4 14             	add    $0x14,%esp
f010545d:	5b                   	pop    %ebx
f010545e:	5e                   	pop    %esi
f010545f:	5f                   	pop    %edi
f0105460:	5d                   	pop    %ebp
f0105461:	c3                   	ret    

f0105462 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105462:	55                   	push   %ebp
f0105463:	89 e5                	mov    %esp,%ebp
f0105465:	57                   	push   %edi
f0105466:	56                   	push   %esi
f0105467:	53                   	push   %ebx
f0105468:	83 ec 4c             	sub    $0x4c,%esp
f010546b:	8b 75 08             	mov    0x8(%ebp),%esi
f010546e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105471:	c7 03 f8 88 10 f0    	movl   $0xf01088f8,(%ebx)
	info->eip_line = 0;
f0105477:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010547e:	c7 43 08 f8 88 10 f0 	movl   $0xf01088f8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105485:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010548c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010548f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105496:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010549c:	77 21                	ja     f01054bf <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010549e:	a1 00 00 20 00       	mov    0x200000,%eax
f01054a3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01054a6:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01054ab:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01054b1:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f01054b4:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01054ba:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01054bd:	eb 1a                	jmp    f01054d9 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01054bf:	c7 45 bc 62 6d 11 f0 	movl   $0xf0116d62,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01054c6:	c7 45 c0 99 35 11 f0 	movl   $0xf0113599,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01054cd:	b8 98 35 11 f0       	mov    $0xf0113598,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01054d2:	c7 45 c4 d4 8d 10 f0 	movl   $0xf0108dd4,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01054d9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01054dc:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f01054df:	0f 83 9d 01 00 00    	jae    f0105682 <debuginfo_eip+0x220>
f01054e5:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01054e9:	0f 85 9a 01 00 00    	jne    f0105689 <debuginfo_eip+0x227>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01054ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01054f6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01054f9:	29 f8                	sub    %edi,%eax
f01054fb:	c1 f8 02             	sar    $0x2,%eax
f01054fe:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105504:	83 e8 01             	sub    $0x1,%eax
f0105507:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010550a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010550e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105515:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105518:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010551b:	89 f8                	mov    %edi,%eax
f010551d:	e8 3e fe ff ff       	call   f0105360 <stab_binsearch>
	if (lfile == 0)
f0105522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105525:	85 c0                	test   %eax,%eax
f0105527:	0f 84 63 01 00 00    	je     f0105690 <debuginfo_eip+0x22e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010552d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105530:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105533:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105536:	89 74 24 04          	mov    %esi,0x4(%esp)
f010553a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105541:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105544:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105547:	89 f8                	mov    %edi,%eax
f0105549:	e8 12 fe ff ff       	call   f0105360 <stab_binsearch>

	if (lfun <= rfun) {
f010554e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105551:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105554:	39 c8                	cmp    %ecx,%eax
f0105556:	7f 32                	jg     f010558a <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105558:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010555b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010555e:	8d 3c 97             	lea    (%edi,%edx,4),%edi
f0105561:	8b 17                	mov    (%edi),%edx
f0105563:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105566:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105569:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010556c:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f010556f:	73 09                	jae    f010557a <debuginfo_eip+0x118>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105571:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105574:	03 55 c0             	add    -0x40(%ebp),%edx
f0105577:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010557a:	8b 57 08             	mov    0x8(%edi),%edx
f010557d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105580:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105582:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105585:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0105588:	eb 0f                	jmp    f0105599 <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010558a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010558d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105590:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105593:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105596:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105599:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01055a0:	00 
f01055a1:	8b 43 08             	mov    0x8(%ebx),%eax
f01055a4:	89 04 24             	mov    %eax,(%esp)
f01055a7:	e8 0f 09 00 00       	call   f0105ebb <strfind>
f01055ac:	2b 43 08             	sub    0x8(%ebx),%eax
f01055af:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01055b2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055b6:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01055bd:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01055c0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01055c3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01055c6:	89 f8                	mov    %edi,%eax
f01055c8:	e8 93 fd ff ff       	call   f0105360 <stab_binsearch>
	if (lline <= rline) {
f01055cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055d0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01055d3:	0f 8f be 00 00 00    	jg     f0105697 <debuginfo_eip+0x235>
		info->eip_line = stabs[lline].n_desc;
f01055d9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01055dc:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01055e1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055e7:	89 c6                	mov    %eax,%esi
f01055e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055ec:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01055ef:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01055f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055f5:	eb 06                	jmp    f01055fd <debuginfo_eip+0x19b>
f01055f7:	83 e8 01             	sub    $0x1,%eax
f01055fa:	83 ea 0c             	sub    $0xc,%edx
f01055fd:	89 c7                	mov    %eax,%edi
f01055ff:	39 c6                	cmp    %eax,%esi
f0105601:	7f 3c                	jg     f010563f <debuginfo_eip+0x1dd>
	       && stabs[lline].n_type != N_SOL
f0105603:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105607:	80 f9 84             	cmp    $0x84,%cl
f010560a:	75 08                	jne    f0105614 <debuginfo_eip+0x1b2>
f010560c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010560f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105612:	eb 11                	jmp    f0105625 <debuginfo_eip+0x1c3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105614:	80 f9 64             	cmp    $0x64,%cl
f0105617:	75 de                	jne    f01055f7 <debuginfo_eip+0x195>
f0105619:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010561d:	74 d8                	je     f01055f7 <debuginfo_eip+0x195>
f010561f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105622:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105625:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105628:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010562b:	8b 04 86             	mov    (%esi,%eax,4),%eax
f010562e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105631:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105634:	39 d0                	cmp    %edx,%eax
f0105636:	73 0a                	jae    f0105642 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105638:	03 45 c0             	add    -0x40(%ebp),%eax
f010563b:	89 03                	mov    %eax,(%ebx)
f010563d:	eb 03                	jmp    f0105642 <debuginfo_eip+0x1e0>
f010563f:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105642:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105645:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105648:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010564d:	39 f2                	cmp    %esi,%edx
f010564f:	7d 52                	jge    f01056a3 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
f0105651:	83 c2 01             	add    $0x1,%edx
f0105654:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105657:	89 d0                	mov    %edx,%eax
f0105659:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010565c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010565f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105662:	eb 04                	jmp    f0105668 <debuginfo_eip+0x206>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105664:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105668:	39 c6                	cmp    %eax,%esi
f010566a:	7e 32                	jle    f010569e <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010566c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105670:	83 c0 01             	add    $0x1,%eax
f0105673:	83 c2 0c             	add    $0xc,%edx
f0105676:	80 f9 a0             	cmp    $0xa0,%cl
f0105679:	74 e9                	je     f0105664 <debuginfo_eip+0x202>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010567b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105680:	eb 21                	jmp    f01056a3 <debuginfo_eip+0x241>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105687:	eb 1a                	jmp    f01056a3 <debuginfo_eip+0x241>
f0105689:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010568e:	eb 13                	jmp    f01056a3 <debuginfo_eip+0x241>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105690:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105695:	eb 0c                	jmp    f01056a3 <debuginfo_eip+0x241>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		// Couldn't find line stab!  
		return -1;
f0105697:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010569c:	eb 05                	jmp    f01056a3 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010569e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056a3:	83 c4 4c             	add    $0x4c,%esp
f01056a6:	5b                   	pop    %ebx
f01056a7:	5e                   	pop    %esi
f01056a8:	5f                   	pop    %edi
f01056a9:	5d                   	pop    %ebp
f01056aa:	c3                   	ret    
f01056ab:	66 90                	xchg   %ax,%ax
f01056ad:	66 90                	xchg   %ax,%ax
f01056af:	90                   	nop

f01056b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01056b0:	55                   	push   %ebp
f01056b1:	89 e5                	mov    %esp,%ebp
f01056b3:	57                   	push   %edi
f01056b4:	56                   	push   %esi
f01056b5:	53                   	push   %ebx
f01056b6:	83 ec 3c             	sub    $0x3c,%esp
f01056b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056bc:	89 d7                	mov    %edx,%edi
f01056be:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01056c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056c7:	89 c3                	mov    %eax,%ebx
f01056c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01056cc:	8b 45 10             	mov    0x10(%ebp),%eax
f01056cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01056d2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01056dd:	39 d9                	cmp    %ebx,%ecx
f01056df:	72 05                	jb     f01056e6 <printnum+0x36>
f01056e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01056e4:	77 69                	ja     f010574f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01056e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01056e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01056ed:	83 ee 01             	sub    $0x1,%esi
f01056f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01056f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056f8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01056fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105700:	89 c3                	mov    %eax,%ebx
f0105702:	89 d6                	mov    %edx,%esi
f0105704:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105707:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010570a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010570e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105712:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105715:	89 04 24             	mov    %eax,(%esp)
f0105718:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010571b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010571f:	e8 4c 12 00 00       	call   f0106970 <__udivdi3>
f0105724:	89 d9                	mov    %ebx,%ecx
f0105726:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010572a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010572e:	89 04 24             	mov    %eax,(%esp)
f0105731:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105735:	89 fa                	mov    %edi,%edx
f0105737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010573a:	e8 71 ff ff ff       	call   f01056b0 <printnum>
f010573f:	eb 1b                	jmp    f010575c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105741:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105745:	8b 45 18             	mov    0x18(%ebp),%eax
f0105748:	89 04 24             	mov    %eax,(%esp)
f010574b:	ff d3                	call   *%ebx
f010574d:	eb 03                	jmp    f0105752 <printnum+0xa2>
f010574f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105752:	83 ee 01             	sub    $0x1,%esi
f0105755:	85 f6                	test   %esi,%esi
f0105757:	7f e8                	jg     f0105741 <printnum+0x91>
f0105759:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010575c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105760:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105764:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105767:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010576a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010576e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105772:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105775:	89 04 24             	mov    %eax,(%esp)
f0105778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010577b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010577f:	e8 1c 13 00 00       	call   f0106aa0 <__umoddi3>
f0105784:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105788:	0f be 80 02 89 10 f0 	movsbl -0xfef76fe(%eax),%eax
f010578f:	89 04 24             	mov    %eax,(%esp)
f0105792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105795:	ff d0                	call   *%eax
}
f0105797:	83 c4 3c             	add    $0x3c,%esp
f010579a:	5b                   	pop    %ebx
f010579b:	5e                   	pop    %esi
f010579c:	5f                   	pop    %edi
f010579d:	5d                   	pop    %ebp
f010579e:	c3                   	ret    

f010579f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010579f:	55                   	push   %ebp
f01057a0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01057a2:	83 fa 01             	cmp    $0x1,%edx
f01057a5:	7e 0e                	jle    f01057b5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01057a7:	8b 10                	mov    (%eax),%edx
f01057a9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01057ac:	89 08                	mov    %ecx,(%eax)
f01057ae:	8b 02                	mov    (%edx),%eax
f01057b0:	8b 52 04             	mov    0x4(%edx),%edx
f01057b3:	eb 22                	jmp    f01057d7 <getuint+0x38>
	else if (lflag)
f01057b5:	85 d2                	test   %edx,%edx
f01057b7:	74 10                	je     f01057c9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01057b9:	8b 10                	mov    (%eax),%edx
f01057bb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057be:	89 08                	mov    %ecx,(%eax)
f01057c0:	8b 02                	mov    (%edx),%eax
f01057c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01057c7:	eb 0e                	jmp    f01057d7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01057c9:	8b 10                	mov    (%eax),%edx
f01057cb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057ce:	89 08                	mov    %ecx,(%eax)
f01057d0:	8b 02                	mov    (%edx),%eax
f01057d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01057d7:	5d                   	pop    %ebp
f01057d8:	c3                   	ret    

f01057d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01057d9:	55                   	push   %ebp
f01057da:	89 e5                	mov    %esp,%ebp
f01057dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01057df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01057e3:	8b 10                	mov    (%eax),%edx
f01057e5:	3b 50 04             	cmp    0x4(%eax),%edx
f01057e8:	73 0a                	jae    f01057f4 <sprintputch+0x1b>
		*b->buf++ = ch;
f01057ea:	8d 4a 01             	lea    0x1(%edx),%ecx
f01057ed:	89 08                	mov    %ecx,(%eax)
f01057ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f2:	88 02                	mov    %al,(%edx)
}
f01057f4:	5d                   	pop    %ebp
f01057f5:	c3                   	ret    

f01057f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01057f6:	55                   	push   %ebp
f01057f7:	89 e5                	mov    %esp,%ebp
f01057f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01057fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01057ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105803:	8b 45 10             	mov    0x10(%ebp),%eax
f0105806:	89 44 24 08          	mov    %eax,0x8(%esp)
f010580a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010580d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105811:	8b 45 08             	mov    0x8(%ebp),%eax
f0105814:	89 04 24             	mov    %eax,(%esp)
f0105817:	e8 02 00 00 00       	call   f010581e <vprintfmt>
	va_end(ap);
}
f010581c:	c9                   	leave  
f010581d:	c3                   	ret    

f010581e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010581e:	55                   	push   %ebp
f010581f:	89 e5                	mov    %esp,%ebp
f0105821:	57                   	push   %edi
f0105822:	56                   	push   %esi
f0105823:	53                   	push   %ebx
f0105824:	83 ec 3c             	sub    $0x3c,%esp
f0105827:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010582a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010582d:	eb 14                	jmp    f0105843 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010582f:	85 c0                	test   %eax,%eax
f0105831:	0f 84 b3 03 00 00    	je     f0105bea <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0105837:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010583b:	89 04 24             	mov    %eax,(%esp)
f010583e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105841:	89 f3                	mov    %esi,%ebx
f0105843:	8d 73 01             	lea    0x1(%ebx),%esi
f0105846:	0f b6 03             	movzbl (%ebx),%eax
f0105849:	83 f8 25             	cmp    $0x25,%eax
f010584c:	75 e1                	jne    f010582f <vprintfmt+0x11>
f010584e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105852:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105859:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105860:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105867:	ba 00 00 00 00       	mov    $0x0,%edx
f010586c:	eb 1d                	jmp    f010588b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010586e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105870:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105874:	eb 15                	jmp    f010588b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105876:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105878:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010587c:	eb 0d                	jmp    f010588b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010587e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105881:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105884:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010588b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010588e:	0f b6 0e             	movzbl (%esi),%ecx
f0105891:	0f b6 c1             	movzbl %cl,%eax
f0105894:	83 e9 23             	sub    $0x23,%ecx
f0105897:	80 f9 55             	cmp    $0x55,%cl
f010589a:	0f 87 2a 03 00 00    	ja     f0105bca <vprintfmt+0x3ac>
f01058a0:	0f b6 c9             	movzbl %cl,%ecx
f01058a3:	ff 24 8d c0 89 10 f0 	jmp    *-0xfef7640(,%ecx,4)
f01058aa:	89 de                	mov    %ebx,%esi
f01058ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01058b1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01058b4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01058b8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01058bb:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01058be:	83 fb 09             	cmp    $0x9,%ebx
f01058c1:	77 36                	ja     f01058f9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01058c3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01058c6:	eb e9                	jmp    f01058b1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01058c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01058cb:	8d 48 04             	lea    0x4(%eax),%ecx
f01058ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01058d1:	8b 00                	mov    (%eax),%eax
f01058d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058d6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01058d8:	eb 22                	jmp    f01058fc <vprintfmt+0xde>
f01058da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01058dd:	85 c9                	test   %ecx,%ecx
f01058df:	b8 00 00 00 00       	mov    $0x0,%eax
f01058e4:	0f 49 c1             	cmovns %ecx,%eax
f01058e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ea:	89 de                	mov    %ebx,%esi
f01058ec:	eb 9d                	jmp    f010588b <vprintfmt+0x6d>
f01058ee:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01058f0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01058f7:	eb 92                	jmp    f010588b <vprintfmt+0x6d>
f01058f9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f01058fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105900:	79 89                	jns    f010588b <vprintfmt+0x6d>
f0105902:	e9 77 ff ff ff       	jmp    f010587e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105907:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010590a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010590c:	e9 7a ff ff ff       	jmp    f010588b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105911:	8b 45 14             	mov    0x14(%ebp),%eax
f0105914:	8d 50 04             	lea    0x4(%eax),%edx
f0105917:	89 55 14             	mov    %edx,0x14(%ebp)
f010591a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010591e:	8b 00                	mov    (%eax),%eax
f0105920:	89 04 24             	mov    %eax,(%esp)
f0105923:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105926:	e9 18 ff ff ff       	jmp    f0105843 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010592b:	8b 45 14             	mov    0x14(%ebp),%eax
f010592e:	8d 50 04             	lea    0x4(%eax),%edx
f0105931:	89 55 14             	mov    %edx,0x14(%ebp)
f0105934:	8b 00                	mov    (%eax),%eax
f0105936:	99                   	cltd   
f0105937:	31 d0                	xor    %edx,%eax
f0105939:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010593b:	83 f8 08             	cmp    $0x8,%eax
f010593e:	7f 0b                	jg     f010594b <vprintfmt+0x12d>
f0105940:	8b 14 85 20 8b 10 f0 	mov    -0xfef74e0(,%eax,4),%edx
f0105947:	85 d2                	test   %edx,%edx
f0105949:	75 20                	jne    f010596b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010594b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010594f:	c7 44 24 08 1a 89 10 	movl   $0xf010891a,0x8(%esp)
f0105956:	f0 
f0105957:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010595b:	8b 45 08             	mov    0x8(%ebp),%eax
f010595e:	89 04 24             	mov    %eax,(%esp)
f0105961:	e8 90 fe ff ff       	call   f01057f6 <printfmt>
f0105966:	e9 d8 fe ff ff       	jmp    f0105843 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f010596b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010596f:	c7 44 24 08 e5 7d 10 	movl   $0xf0107de5,0x8(%esp)
f0105976:	f0 
f0105977:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010597b:	8b 45 08             	mov    0x8(%ebp),%eax
f010597e:	89 04 24             	mov    %eax,(%esp)
f0105981:	e8 70 fe ff ff       	call   f01057f6 <printfmt>
f0105986:	e9 b8 fe ff ff       	jmp    f0105843 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010598b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010598e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105991:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105994:	8b 45 14             	mov    0x14(%ebp),%eax
f0105997:	8d 50 04             	lea    0x4(%eax),%edx
f010599a:	89 55 14             	mov    %edx,0x14(%ebp)
f010599d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010599f:	85 f6                	test   %esi,%esi
f01059a1:	b8 13 89 10 f0       	mov    $0xf0108913,%eax
f01059a6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01059a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01059ad:	0f 84 97 00 00 00    	je     f0105a4a <vprintfmt+0x22c>
f01059b3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01059b7:	0f 8e 9b 00 00 00    	jle    f0105a58 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01059bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01059c1:	89 34 24             	mov    %esi,(%esp)
f01059c4:	e8 9f 03 00 00       	call   f0105d68 <strnlen>
f01059c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01059cc:	29 c2                	sub    %eax,%edx
f01059ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f01059d1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01059d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01059d8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01059db:	8b 75 08             	mov    0x8(%ebp),%esi
f01059de:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01059e1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059e3:	eb 0f                	jmp    f01059f4 <vprintfmt+0x1d6>
					putch(padc, putdat);
f01059e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059ec:	89 04 24             	mov    %eax,(%esp)
f01059ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059f1:	83 eb 01             	sub    $0x1,%ebx
f01059f4:	85 db                	test   %ebx,%ebx
f01059f6:	7f ed                	jg     f01059e5 <vprintfmt+0x1c7>
f01059f8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01059fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01059fe:	85 d2                	test   %edx,%edx
f0105a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a05:	0f 49 c2             	cmovns %edx,%eax
f0105a08:	29 c2                	sub    %eax,%edx
f0105a0a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105a0d:	89 d7                	mov    %edx,%edi
f0105a0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105a12:	eb 50                	jmp    f0105a64 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a18:	74 1e                	je     f0105a38 <vprintfmt+0x21a>
f0105a1a:	0f be d2             	movsbl %dl,%edx
f0105a1d:	83 ea 20             	sub    $0x20,%edx
f0105a20:	83 fa 5e             	cmp    $0x5e,%edx
f0105a23:	76 13                	jbe    f0105a38 <vprintfmt+0x21a>
					putch('?', putdat);
f0105a25:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105a33:	ff 55 08             	call   *0x8(%ebp)
f0105a36:	eb 0d                	jmp    f0105a45 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0105a38:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a3b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a3f:	89 04 24             	mov    %eax,(%esp)
f0105a42:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a45:	83 ef 01             	sub    $0x1,%edi
f0105a48:	eb 1a                	jmp    f0105a64 <vprintfmt+0x246>
f0105a4a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105a4d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105a50:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105a53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105a56:	eb 0c                	jmp    f0105a64 <vprintfmt+0x246>
f0105a58:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105a5b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105a5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105a61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105a64:	83 c6 01             	add    $0x1,%esi
f0105a67:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105a6b:	0f be c2             	movsbl %dl,%eax
f0105a6e:	85 c0                	test   %eax,%eax
f0105a70:	74 27                	je     f0105a99 <vprintfmt+0x27b>
f0105a72:	85 db                	test   %ebx,%ebx
f0105a74:	78 9e                	js     f0105a14 <vprintfmt+0x1f6>
f0105a76:	83 eb 01             	sub    $0x1,%ebx
f0105a79:	79 99                	jns    f0105a14 <vprintfmt+0x1f6>
f0105a7b:	89 f8                	mov    %edi,%eax
f0105a7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105a80:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a83:	89 c3                	mov    %eax,%ebx
f0105a85:	eb 1a                	jmp    f0105aa1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105a87:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105a92:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a94:	83 eb 01             	sub    $0x1,%ebx
f0105a97:	eb 08                	jmp    f0105aa1 <vprintfmt+0x283>
f0105a99:	89 fb                	mov    %edi,%ebx
f0105a9b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105aa1:	85 db                	test   %ebx,%ebx
f0105aa3:	7f e2                	jg     f0105a87 <vprintfmt+0x269>
f0105aa5:	89 75 08             	mov    %esi,0x8(%ebp)
f0105aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105aab:	e9 93 fd ff ff       	jmp    f0105843 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105ab0:	83 fa 01             	cmp    $0x1,%edx
f0105ab3:	7e 16                	jle    f0105acb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0105ab5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ab8:	8d 50 08             	lea    0x8(%eax),%edx
f0105abb:	89 55 14             	mov    %edx,0x14(%ebp)
f0105abe:	8b 50 04             	mov    0x4(%eax),%edx
f0105ac1:	8b 00                	mov    (%eax),%eax
f0105ac3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ac6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105ac9:	eb 32                	jmp    f0105afd <vprintfmt+0x2df>
	else if (lflag)
f0105acb:	85 d2                	test   %edx,%edx
f0105acd:	74 18                	je     f0105ae7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f0105acf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ad2:	8d 50 04             	lea    0x4(%eax),%edx
f0105ad5:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ad8:	8b 30                	mov    (%eax),%esi
f0105ada:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105add:	89 f0                	mov    %esi,%eax
f0105adf:	c1 f8 1f             	sar    $0x1f,%eax
f0105ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ae5:	eb 16                	jmp    f0105afd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0105ae7:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aea:	8d 50 04             	lea    0x4(%eax),%edx
f0105aed:	89 55 14             	mov    %edx,0x14(%ebp)
f0105af0:	8b 30                	mov    (%eax),%esi
f0105af2:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105af5:	89 f0                	mov    %esi,%eax
f0105af7:	c1 f8 1f             	sar    $0x1f,%eax
f0105afa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105afd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105b03:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105b08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b0c:	0f 89 80 00 00 00    	jns    f0105b92 <vprintfmt+0x374>
				putch('-', putdat);
f0105b12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b16:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105b1d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b26:	f7 d8                	neg    %eax
f0105b28:	83 d2 00             	adc    $0x0,%edx
f0105b2b:	f7 da                	neg    %edx
			}
			base = 10;
f0105b2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105b32:	eb 5e                	jmp    f0105b92 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105b34:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b37:	e8 63 fc ff ff       	call   f010579f <getuint>
			base = 10;
f0105b3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105b41:	eb 4f                	jmp    f0105b92 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105b43:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b46:	e8 54 fc ff ff       	call   f010579f <getuint>
			base = 8;
f0105b4b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105b50:	eb 40                	jmp    f0105b92 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f0105b52:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b56:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105b5d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105b60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105b6b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105b6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b71:	8d 50 04             	lea    0x4(%eax),%edx
f0105b74:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105b77:	8b 00                	mov    (%eax),%eax
f0105b79:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105b7e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105b83:	eb 0d                	jmp    f0105b92 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105b85:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b88:	e8 12 fc ff ff       	call   f010579f <getuint>
			base = 16;
f0105b8d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105b92:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105b96:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105b9a:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105b9d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ba1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ba5:	89 04 24             	mov    %eax,(%esp)
f0105ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105bac:	89 fa                	mov    %edi,%edx
f0105bae:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb1:	e8 fa fa ff ff       	call   f01056b0 <printnum>
			break;
f0105bb6:	e9 88 fc ff ff       	jmp    f0105843 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105bbb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bbf:	89 04 24             	mov    %eax,(%esp)
f0105bc2:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105bc5:	e9 79 fc ff ff       	jmp    f0105843 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105bca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105bce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105bd5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105bd8:	89 f3                	mov    %esi,%ebx
f0105bda:	eb 03                	jmp    f0105bdf <vprintfmt+0x3c1>
f0105bdc:	83 eb 01             	sub    $0x1,%ebx
f0105bdf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105be3:	75 f7                	jne    f0105bdc <vprintfmt+0x3be>
f0105be5:	e9 59 fc ff ff       	jmp    f0105843 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0105bea:	83 c4 3c             	add    $0x3c,%esp
f0105bed:	5b                   	pop    %ebx
f0105bee:	5e                   	pop    %esi
f0105bef:	5f                   	pop    %edi
f0105bf0:	5d                   	pop    %ebp
f0105bf1:	c3                   	ret    

f0105bf2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105bf2:	55                   	push   %ebp
f0105bf3:	89 e5                	mov    %esp,%ebp
f0105bf5:	83 ec 28             	sub    $0x28,%esp
f0105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105c01:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105c05:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105c0f:	85 c0                	test   %eax,%eax
f0105c11:	74 30                	je     f0105c43 <vsnprintf+0x51>
f0105c13:	85 d2                	test   %edx,%edx
f0105c15:	7e 2c                	jle    f0105c43 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105c17:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c1e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c25:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105c28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c2c:	c7 04 24 d9 57 10 f0 	movl   $0xf01057d9,(%esp)
f0105c33:	e8 e6 fb ff ff       	call   f010581e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c3b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105c41:	eb 05                	jmp    f0105c48 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105c43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105c48:	c9                   	leave  
f0105c49:	c3                   	ret    

f0105c4a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105c4a:	55                   	push   %ebp
f0105c4b:	89 e5                	mov    %esp,%ebp
f0105c4d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105c50:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105c53:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c57:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c5a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c65:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c68:	89 04 24             	mov    %eax,(%esp)
f0105c6b:	e8 82 ff ff ff       	call   f0105bf2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105c70:	c9                   	leave  
f0105c71:	c3                   	ret    
f0105c72:	66 90                	xchg   %ax,%ax
f0105c74:	66 90                	xchg   %ax,%ax
f0105c76:	66 90                	xchg   %ax,%ax
f0105c78:	66 90                	xchg   %ax,%ax
f0105c7a:	66 90                	xchg   %ax,%ax
f0105c7c:	66 90                	xchg   %ax,%ax
f0105c7e:	66 90                	xchg   %ax,%ax

f0105c80 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105c80:	55                   	push   %ebp
f0105c81:	89 e5                	mov    %esp,%ebp
f0105c83:	57                   	push   %edi
f0105c84:	56                   	push   %esi
f0105c85:	53                   	push   %ebx
f0105c86:	83 ec 1c             	sub    $0x1c,%esp
f0105c89:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105c8c:	85 c0                	test   %eax,%eax
f0105c8e:	74 10                	je     f0105ca0 <readline+0x20>
		cprintf("%s", prompt);
f0105c90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c94:	c7 04 24 e5 7d 10 f0 	movl   $0xf0107de5,(%esp)
f0105c9b:	e8 eb e5 ff ff       	call   f010428b <cprintf>

	i = 0;
	echoing = iscons(0);
f0105ca0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105ca7:	e8 0f ab ff ff       	call   f01007bb <iscons>
f0105cac:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105cae:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105cb3:	e8 f2 aa ff ff       	call   f01007aa <getchar>
f0105cb8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105cba:	85 c0                	test   %eax,%eax
f0105cbc:	79 17                	jns    f0105cd5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cc2:	c7 04 24 44 8b 10 f0 	movl   $0xf0108b44,(%esp)
f0105cc9:	e8 bd e5 ff ff       	call   f010428b <cprintf>
			return NULL;
f0105cce:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cd3:	eb 6d                	jmp    f0105d42 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105cd5:	83 f8 7f             	cmp    $0x7f,%eax
f0105cd8:	74 05                	je     f0105cdf <readline+0x5f>
f0105cda:	83 f8 08             	cmp    $0x8,%eax
f0105cdd:	75 19                	jne    f0105cf8 <readline+0x78>
f0105cdf:	85 f6                	test   %esi,%esi
f0105ce1:	7e 15                	jle    f0105cf8 <readline+0x78>
			if (echoing)
f0105ce3:	85 ff                	test   %edi,%edi
f0105ce5:	74 0c                	je     f0105cf3 <readline+0x73>
				cputchar('\b');
f0105ce7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105cee:	e8 a7 aa ff ff       	call   f010079a <cputchar>
			i--;
f0105cf3:	83 ee 01             	sub    $0x1,%esi
f0105cf6:	eb bb                	jmp    f0105cb3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105cf8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105cfe:	7f 1c                	jg     f0105d1c <readline+0x9c>
f0105d00:	83 fb 1f             	cmp    $0x1f,%ebx
f0105d03:	7e 17                	jle    f0105d1c <readline+0x9c>
			if (echoing)
f0105d05:	85 ff                	test   %edi,%edi
f0105d07:	74 08                	je     f0105d11 <readline+0x91>
				cputchar(c);
f0105d09:	89 1c 24             	mov    %ebx,(%esp)
f0105d0c:	e8 89 aa ff ff       	call   f010079a <cputchar>
			buf[i++] = c;
f0105d11:	88 9e 80 1a 23 f0    	mov    %bl,-0xfdce580(%esi)
f0105d17:	8d 76 01             	lea    0x1(%esi),%esi
f0105d1a:	eb 97                	jmp    f0105cb3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105d1c:	83 fb 0d             	cmp    $0xd,%ebx
f0105d1f:	74 05                	je     f0105d26 <readline+0xa6>
f0105d21:	83 fb 0a             	cmp    $0xa,%ebx
f0105d24:	75 8d                	jne    f0105cb3 <readline+0x33>
			if (echoing)
f0105d26:	85 ff                	test   %edi,%edi
f0105d28:	74 0c                	je     f0105d36 <readline+0xb6>
				cputchar('\n');
f0105d2a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105d31:	e8 64 aa ff ff       	call   f010079a <cputchar>
			buf[i] = 0;
f0105d36:	c6 86 80 1a 23 f0 00 	movb   $0x0,-0xfdce580(%esi)
			return buf;
f0105d3d:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
		}
	}
}
f0105d42:	83 c4 1c             	add    $0x1c,%esp
f0105d45:	5b                   	pop    %ebx
f0105d46:	5e                   	pop    %esi
f0105d47:	5f                   	pop    %edi
f0105d48:	5d                   	pop    %ebp
f0105d49:	c3                   	ret    
f0105d4a:	66 90                	xchg   %ax,%ax
f0105d4c:	66 90                	xchg   %ax,%ax
f0105d4e:	66 90                	xchg   %ax,%ax

f0105d50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105d50:	55                   	push   %ebp
f0105d51:	89 e5                	mov    %esp,%ebp
f0105d53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105d56:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d5b:	eb 03                	jmp    f0105d60 <strlen+0x10>
		n++;
f0105d5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105d60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105d64:	75 f7                	jne    f0105d5d <strlen+0xd>
		n++;
	return n;
}
f0105d66:	5d                   	pop    %ebp
f0105d67:	c3                   	ret    

f0105d68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105d68:	55                   	push   %ebp
f0105d69:	89 e5                	mov    %esp,%ebp
f0105d6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d71:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d76:	eb 03                	jmp    f0105d7b <strnlen+0x13>
		n++;
f0105d78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d7b:	39 d0                	cmp    %edx,%eax
f0105d7d:	74 06                	je     f0105d85 <strnlen+0x1d>
f0105d7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105d83:	75 f3                	jne    f0105d78 <strnlen+0x10>
		n++;
	return n;
}
f0105d85:	5d                   	pop    %ebp
f0105d86:	c3                   	ret    

f0105d87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105d87:	55                   	push   %ebp
f0105d88:	89 e5                	mov    %esp,%ebp
f0105d8a:	53                   	push   %ebx
f0105d8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105d91:	89 c2                	mov    %eax,%edx
f0105d93:	83 c2 01             	add    $0x1,%edx
f0105d96:	83 c1 01             	add    $0x1,%ecx
f0105d99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105d9d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105da0:	84 db                	test   %bl,%bl
f0105da2:	75 ef                	jne    f0105d93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105da4:	5b                   	pop    %ebx
f0105da5:	5d                   	pop    %ebp
f0105da6:	c3                   	ret    

f0105da7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105da7:	55                   	push   %ebp
f0105da8:	89 e5                	mov    %esp,%ebp
f0105daa:	53                   	push   %ebx
f0105dab:	83 ec 08             	sub    $0x8,%esp
f0105dae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105db1:	89 1c 24             	mov    %ebx,(%esp)
f0105db4:	e8 97 ff ff ff       	call   f0105d50 <strlen>
	strcpy(dst + len, src);
f0105db9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dbc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105dc0:	01 d8                	add    %ebx,%eax
f0105dc2:	89 04 24             	mov    %eax,(%esp)
f0105dc5:	e8 bd ff ff ff       	call   f0105d87 <strcpy>
	return dst;
}
f0105dca:	89 d8                	mov    %ebx,%eax
f0105dcc:	83 c4 08             	add    $0x8,%esp
f0105dcf:	5b                   	pop    %ebx
f0105dd0:	5d                   	pop    %ebp
f0105dd1:	c3                   	ret    

f0105dd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105dd2:	55                   	push   %ebp
f0105dd3:	89 e5                	mov    %esp,%ebp
f0105dd5:	56                   	push   %esi
f0105dd6:	53                   	push   %ebx
f0105dd7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ddd:	89 f3                	mov    %esi,%ebx
f0105ddf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105de2:	89 f2                	mov    %esi,%edx
f0105de4:	eb 0f                	jmp    f0105df5 <strncpy+0x23>
		*dst++ = *src;
f0105de6:	83 c2 01             	add    $0x1,%edx
f0105de9:	0f b6 01             	movzbl (%ecx),%eax
f0105dec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105def:	80 39 01             	cmpb   $0x1,(%ecx)
f0105df2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105df5:	39 da                	cmp    %ebx,%edx
f0105df7:	75 ed                	jne    f0105de6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105df9:	89 f0                	mov    %esi,%eax
f0105dfb:	5b                   	pop    %ebx
f0105dfc:	5e                   	pop    %esi
f0105dfd:	5d                   	pop    %ebp
f0105dfe:	c3                   	ret    

f0105dff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105dff:	55                   	push   %ebp
f0105e00:	89 e5                	mov    %esp,%ebp
f0105e02:	56                   	push   %esi
f0105e03:	53                   	push   %ebx
f0105e04:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e07:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105e0d:	89 f0                	mov    %esi,%eax
f0105e0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105e13:	85 c9                	test   %ecx,%ecx
f0105e15:	75 0b                	jne    f0105e22 <strlcpy+0x23>
f0105e17:	eb 1d                	jmp    f0105e36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105e19:	83 c0 01             	add    $0x1,%eax
f0105e1c:	83 c2 01             	add    $0x1,%edx
f0105e1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e22:	39 d8                	cmp    %ebx,%eax
f0105e24:	74 0b                	je     f0105e31 <strlcpy+0x32>
f0105e26:	0f b6 0a             	movzbl (%edx),%ecx
f0105e29:	84 c9                	test   %cl,%cl
f0105e2b:	75 ec                	jne    f0105e19 <strlcpy+0x1a>
f0105e2d:	89 c2                	mov    %eax,%edx
f0105e2f:	eb 02                	jmp    f0105e33 <strlcpy+0x34>
f0105e31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105e33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105e36:	29 f0                	sub    %esi,%eax
}
f0105e38:	5b                   	pop    %ebx
f0105e39:	5e                   	pop    %esi
f0105e3a:	5d                   	pop    %ebp
f0105e3b:	c3                   	ret    

f0105e3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105e3c:	55                   	push   %ebp
f0105e3d:	89 e5                	mov    %esp,%ebp
f0105e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105e45:	eb 06                	jmp    f0105e4d <strcmp+0x11>
		p++, q++;
f0105e47:	83 c1 01             	add    $0x1,%ecx
f0105e4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105e4d:	0f b6 01             	movzbl (%ecx),%eax
f0105e50:	84 c0                	test   %al,%al
f0105e52:	74 04                	je     f0105e58 <strcmp+0x1c>
f0105e54:	3a 02                	cmp    (%edx),%al
f0105e56:	74 ef                	je     f0105e47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e58:	0f b6 c0             	movzbl %al,%eax
f0105e5b:	0f b6 12             	movzbl (%edx),%edx
f0105e5e:	29 d0                	sub    %edx,%eax
}
f0105e60:	5d                   	pop    %ebp
f0105e61:	c3                   	ret    

f0105e62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105e62:	55                   	push   %ebp
f0105e63:	89 e5                	mov    %esp,%ebp
f0105e65:	53                   	push   %ebx
f0105e66:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e6c:	89 c3                	mov    %eax,%ebx
f0105e6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105e71:	eb 06                	jmp    f0105e79 <strncmp+0x17>
		n--, p++, q++;
f0105e73:	83 c0 01             	add    $0x1,%eax
f0105e76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e79:	39 d8                	cmp    %ebx,%eax
f0105e7b:	74 15                	je     f0105e92 <strncmp+0x30>
f0105e7d:	0f b6 08             	movzbl (%eax),%ecx
f0105e80:	84 c9                	test   %cl,%cl
f0105e82:	74 04                	je     f0105e88 <strncmp+0x26>
f0105e84:	3a 0a                	cmp    (%edx),%cl
f0105e86:	74 eb                	je     f0105e73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e88:	0f b6 00             	movzbl (%eax),%eax
f0105e8b:	0f b6 12             	movzbl (%edx),%edx
f0105e8e:	29 d0                	sub    %edx,%eax
f0105e90:	eb 05                	jmp    f0105e97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105e92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105e97:	5b                   	pop    %ebx
f0105e98:	5d                   	pop    %ebp
f0105e99:	c3                   	ret    

f0105e9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105e9a:	55                   	push   %ebp
f0105e9b:	89 e5                	mov    %esp,%ebp
f0105e9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ea0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ea4:	eb 07                	jmp    f0105ead <strchr+0x13>
		if (*s == c)
f0105ea6:	38 ca                	cmp    %cl,%dl
f0105ea8:	74 0f                	je     f0105eb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105eaa:	83 c0 01             	add    $0x1,%eax
f0105ead:	0f b6 10             	movzbl (%eax),%edx
f0105eb0:	84 d2                	test   %dl,%dl
f0105eb2:	75 f2                	jne    f0105ea6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105eb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105eb9:	5d                   	pop    %ebp
f0105eba:	c3                   	ret    

f0105ebb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105ebb:	55                   	push   %ebp
f0105ebc:	89 e5                	mov    %esp,%ebp
f0105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ec1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ec5:	eb 07                	jmp    f0105ece <strfind+0x13>
		if (*s == c)
f0105ec7:	38 ca                	cmp    %cl,%dl
f0105ec9:	74 0a                	je     f0105ed5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105ecb:	83 c0 01             	add    $0x1,%eax
f0105ece:	0f b6 10             	movzbl (%eax),%edx
f0105ed1:	84 d2                	test   %dl,%dl
f0105ed3:	75 f2                	jne    f0105ec7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105ed5:	5d                   	pop    %ebp
f0105ed6:	c3                   	ret    

f0105ed7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105ed7:	55                   	push   %ebp
f0105ed8:	89 e5                	mov    %esp,%ebp
f0105eda:	57                   	push   %edi
f0105edb:	56                   	push   %esi
f0105edc:	53                   	push   %ebx
f0105edd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ee0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ee3:	85 c9                	test   %ecx,%ecx
f0105ee5:	74 36                	je     f0105f1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105ee7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105eed:	75 28                	jne    f0105f17 <memset+0x40>
f0105eef:	f6 c1 03             	test   $0x3,%cl
f0105ef2:	75 23                	jne    f0105f17 <memset+0x40>
		c &= 0xFF;
f0105ef4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105ef8:	89 d3                	mov    %edx,%ebx
f0105efa:	c1 e3 08             	shl    $0x8,%ebx
f0105efd:	89 d6                	mov    %edx,%esi
f0105eff:	c1 e6 18             	shl    $0x18,%esi
f0105f02:	89 d0                	mov    %edx,%eax
f0105f04:	c1 e0 10             	shl    $0x10,%eax
f0105f07:	09 f0                	or     %esi,%eax
f0105f09:	09 c2                	or     %eax,%edx
f0105f0b:	89 d0                	mov    %edx,%eax
f0105f0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105f0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105f12:	fc                   	cld    
f0105f13:	f3 ab                	rep stos %eax,%es:(%edi)
f0105f15:	eb 06                	jmp    f0105f1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105f17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f1a:	fc                   	cld    
f0105f1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105f1d:	89 f8                	mov    %edi,%eax
f0105f1f:	5b                   	pop    %ebx
f0105f20:	5e                   	pop    %esi
f0105f21:	5f                   	pop    %edi
f0105f22:	5d                   	pop    %ebp
f0105f23:	c3                   	ret    

f0105f24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f24:	55                   	push   %ebp
f0105f25:	89 e5                	mov    %esp,%ebp
f0105f27:	57                   	push   %edi
f0105f28:	56                   	push   %esi
f0105f29:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105f32:	39 c6                	cmp    %eax,%esi
f0105f34:	73 35                	jae    f0105f6b <memmove+0x47>
f0105f36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105f39:	39 d0                	cmp    %edx,%eax
f0105f3b:	73 2e                	jae    f0105f6b <memmove+0x47>
		s += n;
		d += n;
f0105f3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105f40:	89 d6                	mov    %edx,%esi
f0105f42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f44:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105f4a:	75 13                	jne    f0105f5f <memmove+0x3b>
f0105f4c:	f6 c1 03             	test   $0x3,%cl
f0105f4f:	75 0e                	jne    f0105f5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105f51:	83 ef 04             	sub    $0x4,%edi
f0105f54:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105f57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105f5a:	fd                   	std    
f0105f5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f5d:	eb 09                	jmp    f0105f68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105f5f:	83 ef 01             	sub    $0x1,%edi
f0105f62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105f65:	fd                   	std    
f0105f66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105f68:	fc                   	cld    
f0105f69:	eb 1d                	jmp    f0105f88 <memmove+0x64>
f0105f6b:	89 f2                	mov    %esi,%edx
f0105f6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f6f:	f6 c2 03             	test   $0x3,%dl
f0105f72:	75 0f                	jne    f0105f83 <memmove+0x5f>
f0105f74:	f6 c1 03             	test   $0x3,%cl
f0105f77:	75 0a                	jne    f0105f83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105f79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105f7c:	89 c7                	mov    %eax,%edi
f0105f7e:	fc                   	cld    
f0105f7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f81:	eb 05                	jmp    f0105f88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105f83:	89 c7                	mov    %eax,%edi
f0105f85:	fc                   	cld    
f0105f86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105f88:	5e                   	pop    %esi
f0105f89:	5f                   	pop    %edi
f0105f8a:	5d                   	pop    %ebp
f0105f8b:	c3                   	ret    

f0105f8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105f8c:	55                   	push   %ebp
f0105f8d:	89 e5                	mov    %esp,%ebp
f0105f8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105f92:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f95:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fa0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa3:	89 04 24             	mov    %eax,(%esp)
f0105fa6:	e8 79 ff ff ff       	call   f0105f24 <memmove>
}
f0105fab:	c9                   	leave  
f0105fac:	c3                   	ret    

f0105fad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105fad:	55                   	push   %ebp
f0105fae:	89 e5                	mov    %esp,%ebp
f0105fb0:	56                   	push   %esi
f0105fb1:	53                   	push   %ebx
f0105fb2:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105fb8:	89 d6                	mov    %edx,%esi
f0105fba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105fbd:	eb 1a                	jmp    f0105fd9 <memcmp+0x2c>
		if (*s1 != *s2)
f0105fbf:	0f b6 02             	movzbl (%edx),%eax
f0105fc2:	0f b6 19             	movzbl (%ecx),%ebx
f0105fc5:	38 d8                	cmp    %bl,%al
f0105fc7:	74 0a                	je     f0105fd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105fc9:	0f b6 c0             	movzbl %al,%eax
f0105fcc:	0f b6 db             	movzbl %bl,%ebx
f0105fcf:	29 d8                	sub    %ebx,%eax
f0105fd1:	eb 0f                	jmp    f0105fe2 <memcmp+0x35>
		s1++, s2++;
f0105fd3:	83 c2 01             	add    $0x1,%edx
f0105fd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105fd9:	39 f2                	cmp    %esi,%edx
f0105fdb:	75 e2                	jne    f0105fbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105fdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105fe2:	5b                   	pop    %ebx
f0105fe3:	5e                   	pop    %esi
f0105fe4:	5d                   	pop    %ebp
f0105fe5:	c3                   	ret    

f0105fe6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105fe6:	55                   	push   %ebp
f0105fe7:	89 e5                	mov    %esp,%ebp
f0105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105fef:	89 c2                	mov    %eax,%edx
f0105ff1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105ff4:	eb 07                	jmp    f0105ffd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105ff6:	38 08                	cmp    %cl,(%eax)
f0105ff8:	74 07                	je     f0106001 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105ffa:	83 c0 01             	add    $0x1,%eax
f0105ffd:	39 d0                	cmp    %edx,%eax
f0105fff:	72 f5                	jb     f0105ff6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106001:	5d                   	pop    %ebp
f0106002:	c3                   	ret    

f0106003 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106003:	55                   	push   %ebp
f0106004:	89 e5                	mov    %esp,%ebp
f0106006:	57                   	push   %edi
f0106007:	56                   	push   %esi
f0106008:	53                   	push   %ebx
f0106009:	8b 55 08             	mov    0x8(%ebp),%edx
f010600c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010600f:	eb 03                	jmp    f0106014 <strtol+0x11>
		s++;
f0106011:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106014:	0f b6 0a             	movzbl (%edx),%ecx
f0106017:	80 f9 09             	cmp    $0x9,%cl
f010601a:	74 f5                	je     f0106011 <strtol+0xe>
f010601c:	80 f9 20             	cmp    $0x20,%cl
f010601f:	74 f0                	je     f0106011 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106021:	80 f9 2b             	cmp    $0x2b,%cl
f0106024:	75 0a                	jne    f0106030 <strtol+0x2d>
		s++;
f0106026:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106029:	bf 00 00 00 00       	mov    $0x0,%edi
f010602e:	eb 11                	jmp    f0106041 <strtol+0x3e>
f0106030:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106035:	80 f9 2d             	cmp    $0x2d,%cl
f0106038:	75 07                	jne    f0106041 <strtol+0x3e>
		s++, neg = 1;
f010603a:	8d 52 01             	lea    0x1(%edx),%edx
f010603d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106041:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0106046:	75 15                	jne    f010605d <strtol+0x5a>
f0106048:	80 3a 30             	cmpb   $0x30,(%edx)
f010604b:	75 10                	jne    f010605d <strtol+0x5a>
f010604d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106051:	75 0a                	jne    f010605d <strtol+0x5a>
		s += 2, base = 16;
f0106053:	83 c2 02             	add    $0x2,%edx
f0106056:	b8 10 00 00 00       	mov    $0x10,%eax
f010605b:	eb 10                	jmp    f010606d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010605d:	85 c0                	test   %eax,%eax
f010605f:	75 0c                	jne    f010606d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106061:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106063:	80 3a 30             	cmpb   $0x30,(%edx)
f0106066:	75 05                	jne    f010606d <strtol+0x6a>
		s++, base = 8;
f0106068:	83 c2 01             	add    $0x1,%edx
f010606b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010606d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106072:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106075:	0f b6 0a             	movzbl (%edx),%ecx
f0106078:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010607b:	89 f0                	mov    %esi,%eax
f010607d:	3c 09                	cmp    $0x9,%al
f010607f:	77 08                	ja     f0106089 <strtol+0x86>
			dig = *s - '0';
f0106081:	0f be c9             	movsbl %cl,%ecx
f0106084:	83 e9 30             	sub    $0x30,%ecx
f0106087:	eb 20                	jmp    f01060a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106089:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010608c:	89 f0                	mov    %esi,%eax
f010608e:	3c 19                	cmp    $0x19,%al
f0106090:	77 08                	ja     f010609a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106092:	0f be c9             	movsbl %cl,%ecx
f0106095:	83 e9 57             	sub    $0x57,%ecx
f0106098:	eb 0f                	jmp    f01060a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010609a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010609d:	89 f0                	mov    %esi,%eax
f010609f:	3c 19                	cmp    $0x19,%al
f01060a1:	77 16                	ja     f01060b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01060a3:	0f be c9             	movsbl %cl,%ecx
f01060a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01060a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01060ac:	7d 0f                	jge    f01060bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01060ae:	83 c2 01             	add    $0x1,%edx
f01060b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01060b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01060b7:	eb bc                	jmp    f0106075 <strtol+0x72>
f01060b9:	89 d8                	mov    %ebx,%eax
f01060bb:	eb 02                	jmp    f01060bf <strtol+0xbc>
f01060bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01060bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01060c3:	74 05                	je     f01060ca <strtol+0xc7>
		*endptr = (char *) s;
f01060c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01060c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01060ca:	f7 d8                	neg    %eax
f01060cc:	85 ff                	test   %edi,%edi
f01060ce:	0f 44 c3             	cmove  %ebx,%eax
}
f01060d1:	5b                   	pop    %ebx
f01060d2:	5e                   	pop    %esi
f01060d3:	5f                   	pop    %edi
f01060d4:	5d                   	pop    %ebp
f01060d5:	c3                   	ret    
f01060d6:	66 90                	xchg   %ax,%ax

f01060d8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01060d8:	fa                   	cli    

	xorw    %ax, %ax
f01060d9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01060db:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01060dd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01060df:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01060e1:	0f 01 16             	lgdtl  (%esi)
f01060e4:	74 70                	je     f0106156 <mpentry_end+0x4>
	movl    %cr0, %eax
f01060e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01060e9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01060ed:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01060f0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01060f6:	08 00                	or     %al,(%eax)

f01060f8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01060f8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01060fc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01060fe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106100:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106102:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106106:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106108:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010610a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010610f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106112:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106115:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010611a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010611d:	8b 25 84 1e 23 f0    	mov    0xf0231e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106123:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106128:	b8 e2 01 10 f0       	mov    $0xf01001e2,%eax
	call    *%eax
f010612d:	ff d0                	call   *%eax

f010612f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010612f:	eb fe                	jmp    f010612f <spin>
f0106131:	8d 76 00             	lea    0x0(%esi),%esi

f0106134 <gdt>:
	...
f010613c:	ff                   	(bad)  
f010613d:	ff 00                	incl   (%eax)
f010613f:	00 00                	add    %al,(%eax)
f0106141:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106148:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f010614c <gdtdesc>:
f010614c:	17                   	pop    %ss
f010614d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106152 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106152:	90                   	nop
f0106153:	66 90                	xchg   %ax,%ax
f0106155:	66 90                	xchg   %ax,%ax
f0106157:	66 90                	xchg   %ax,%ax
f0106159:	66 90                	xchg   %ax,%ax
f010615b:	66 90                	xchg   %ax,%ax
f010615d:	66 90                	xchg   %ax,%ax
f010615f:	90                   	nop

f0106160 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106160:	55                   	push   %ebp
f0106161:	89 e5                	mov    %esp,%ebp
f0106163:	56                   	push   %esi
f0106164:	53                   	push   %ebx
f0106165:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106168:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f010616e:	89 c3                	mov    %eax,%ebx
f0106170:	c1 eb 0c             	shr    $0xc,%ebx
f0106173:	39 cb                	cmp    %ecx,%ebx
f0106175:	72 20                	jb     f0106197 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106177:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010617b:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0106182:	f0 
f0106183:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010618a:	00 
f010618b:	c7 04 24 e1 8c 10 f0 	movl   $0xf0108ce1,(%esp)
f0106192:	e8 a9 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106197:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010619d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010619f:	89 c2                	mov    %eax,%edx
f01061a1:	c1 ea 0c             	shr    $0xc,%edx
f01061a4:	39 d1                	cmp    %edx,%ecx
f01061a6:	77 20                	ja     f01061c8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061ac:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01061b3:	f0 
f01061b4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01061bb:	00 
f01061bc:	c7 04 24 e1 8c 10 f0 	movl   $0xf0108ce1,(%esp)
f01061c3:	e8 78 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061c8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01061ce:	eb 36                	jmp    f0106206 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01061d0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01061d7:	00 
f01061d8:	c7 44 24 04 f1 8c 10 	movl   $0xf0108cf1,0x4(%esp)
f01061df:	f0 
f01061e0:	89 1c 24             	mov    %ebx,(%esp)
f01061e3:	e8 c5 fd ff ff       	call   f0105fad <memcmp>
f01061e8:	85 c0                	test   %eax,%eax
f01061ea:	75 17                	jne    f0106203 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061ec:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01061f1:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01061f5:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061f7:	83 c2 01             	add    $0x1,%edx
f01061fa:	83 fa 10             	cmp    $0x10,%edx
f01061fd:	75 f2                	jne    f01061f1 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01061ff:	84 c0                	test   %al,%al
f0106201:	74 0e                	je     f0106211 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106203:	83 c3 10             	add    $0x10,%ebx
f0106206:	39 f3                	cmp    %esi,%ebx
f0106208:	72 c6                	jb     f01061d0 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010620a:	b8 00 00 00 00       	mov    $0x0,%eax
f010620f:	eb 02                	jmp    f0106213 <mpsearch1+0xb3>
f0106211:	89 d8                	mov    %ebx,%eax
}
f0106213:	83 c4 10             	add    $0x10,%esp
f0106216:	5b                   	pop    %ebx
f0106217:	5e                   	pop    %esi
f0106218:	5d                   	pop    %ebp
f0106219:	c3                   	ret    

f010621a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010621a:	55                   	push   %ebp
f010621b:	89 e5                	mov    %esp,%ebp
f010621d:	57                   	push   %edi
f010621e:	56                   	push   %esi
f010621f:	53                   	push   %ebx
f0106220:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106223:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f010622a:	20 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010622d:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0106234:	75 24                	jne    f010625a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106236:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010623d:	00 
f010623e:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f0106245:	f0 
f0106246:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010624d:	00 
f010624e:	c7 04 24 e1 8c 10 f0 	movl   $0xf0108ce1,(%esp)
f0106255:	e8 e6 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010625a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106261:	85 c0                	test   %eax,%eax
f0106263:	74 16                	je     f010627b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106265:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106268:	ba 00 04 00 00       	mov    $0x400,%edx
f010626d:	e8 ee fe ff ff       	call   f0106160 <mpsearch1>
f0106272:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106275:	85 c0                	test   %eax,%eax
f0106277:	75 3c                	jne    f01062b5 <mp_init+0x9b>
f0106279:	eb 20                	jmp    f010629b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010627b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106282:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106285:	2d 00 04 00 00       	sub    $0x400,%eax
f010628a:	ba 00 04 00 00       	mov    $0x400,%edx
f010628f:	e8 cc fe ff ff       	call   f0106160 <mpsearch1>
f0106294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106297:	85 c0                	test   %eax,%eax
f0106299:	75 1a                	jne    f01062b5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010629b:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062a0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01062a5:	e8 b6 fe ff ff       	call   f0106160 <mpsearch1>
f01062aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01062ad:	85 c0                	test   %eax,%eax
f01062af:	0f 84 54 02 00 00    	je     f0106509 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01062b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062b8:	8b 70 04             	mov    0x4(%eax),%esi
f01062bb:	85 f6                	test   %esi,%esi
f01062bd:	74 06                	je     f01062c5 <mp_init+0xab>
f01062bf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01062c3:	74 11                	je     f01062d6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01062c5:	c7 04 24 54 8b 10 f0 	movl   $0xf0108b54,(%esp)
f01062cc:	e8 ba df ff ff       	call   f010428b <cprintf>
f01062d1:	e9 33 02 00 00       	jmp    f0106509 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062d6:	89 f0                	mov    %esi,%eax
f01062d8:	c1 e8 0c             	shr    $0xc,%eax
f01062db:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01062e1:	72 20                	jb     f0106303 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01062e7:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01062ee:	f0 
f01062ef:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01062f6:	00 
f01062f7:	c7 04 24 e1 8c 10 f0 	movl   $0xf0108ce1,(%esp)
f01062fe:	e8 3d 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106303:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106309:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106310:	00 
f0106311:	c7 44 24 04 f6 8c 10 	movl   $0xf0108cf6,0x4(%esp)
f0106318:	f0 
f0106319:	89 1c 24             	mov    %ebx,(%esp)
f010631c:	e8 8c fc ff ff       	call   f0105fad <memcmp>
f0106321:	85 c0                	test   %eax,%eax
f0106323:	74 11                	je     f0106336 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106325:	c7 04 24 84 8b 10 f0 	movl   $0xf0108b84,(%esp)
f010632c:	e8 5a df ff ff       	call   f010428b <cprintf>
f0106331:	e9 d3 01 00 00       	jmp    f0106509 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106336:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010633a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010633e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106341:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106346:	b8 00 00 00 00       	mov    $0x0,%eax
f010634b:	eb 0d                	jmp    f010635a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f010634d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106354:	f0 
f0106355:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106357:	83 c0 01             	add    $0x1,%eax
f010635a:	39 c7                	cmp    %eax,%edi
f010635c:	7f ef                	jg     f010634d <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010635e:	84 d2                	test   %dl,%dl
f0106360:	74 11                	je     f0106373 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106362:	c7 04 24 b8 8b 10 f0 	movl   $0xf0108bb8,(%esp)
f0106369:	e8 1d df ff ff       	call   f010428b <cprintf>
f010636e:	e9 96 01 00 00       	jmp    f0106509 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106373:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106377:	3c 04                	cmp    $0x4,%al
f0106379:	74 1f                	je     f010639a <mp_init+0x180>
f010637b:	3c 01                	cmp    $0x1,%al
f010637d:	8d 76 00             	lea    0x0(%esi),%esi
f0106380:	74 18                	je     f010639a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106382:	0f b6 c0             	movzbl %al,%eax
f0106385:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106389:	c7 04 24 dc 8b 10 f0 	movl   $0xf0108bdc,(%esp)
f0106390:	e8 f6 de ff ff       	call   f010428b <cprintf>
f0106395:	e9 6f 01 00 00       	jmp    f0106509 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010639a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010639e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01063a2:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01063a4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01063a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01063ae:	eb 09                	jmp    f01063b9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f01063b0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01063b4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063b6:	83 c0 01             	add    $0x1,%eax
f01063b9:	39 c6                	cmp    %eax,%esi
f01063bb:	7f f3                	jg     f01063b0 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01063bd:	02 53 2a             	add    0x2a(%ebx),%dl
f01063c0:	84 d2                	test   %dl,%dl
f01063c2:	74 11                	je     f01063d5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01063c4:	c7 04 24 fc 8b 10 f0 	movl   $0xf0108bfc,(%esp)
f01063cb:	e8 bb de ff ff       	call   f010428b <cprintf>
f01063d0:	e9 34 01 00 00       	jmp    f0106509 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01063d5:	85 db                	test   %ebx,%ebx
f01063d7:	0f 84 2c 01 00 00    	je     f0106509 <mp_init+0x2ef>
		return;
	ismp = 1;
f01063dd:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f01063e4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01063e7:	8b 43 24             	mov    0x24(%ebx),%eax
f01063ea:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01063ef:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01063f2:	be 00 00 00 00       	mov    $0x0,%esi
f01063f7:	e9 86 00 00 00       	jmp    f0106482 <mp_init+0x268>
		switch (*p) {
f01063fc:	0f b6 07             	movzbl (%edi),%eax
f01063ff:	84 c0                	test   %al,%al
f0106401:	74 06                	je     f0106409 <mp_init+0x1ef>
f0106403:	3c 04                	cmp    $0x4,%al
f0106405:	77 57                	ja     f010645e <mp_init+0x244>
f0106407:	eb 50                	jmp    f0106459 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106409:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010640d:	8d 76 00             	lea    0x0(%esi),%esi
f0106410:	74 11                	je     f0106423 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106412:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0106419:	05 20 20 23 f0       	add    $0xf0232020,%eax
f010641e:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0106423:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0106428:	83 f8 07             	cmp    $0x7,%eax
f010642b:	7f 13                	jg     f0106440 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010642d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106430:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0106436:	83 c0 01             	add    $0x1,%eax
f0106439:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
f010643e:	eb 14                	jmp    f0106454 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106440:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106444:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106448:	c7 04 24 2c 8c 10 f0 	movl   $0xf0108c2c,(%esp)
f010644f:	e8 37 de ff ff       	call   f010428b <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106454:	83 c7 14             	add    $0x14,%edi
			continue;
f0106457:	eb 26                	jmp    f010647f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106459:	83 c7 08             	add    $0x8,%edi
			continue;
f010645c:	eb 21                	jmp    f010647f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010645e:	0f b6 c0             	movzbl %al,%eax
f0106461:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106465:	c7 04 24 54 8c 10 f0 	movl   $0xf0108c54,(%esp)
f010646c:	e8 1a de ff ff       	call   f010428b <cprintf>
			ismp = 0;
f0106471:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0106478:	00 00 00 
			i = conf->entry;
f010647b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010647f:	83 c6 01             	add    $0x1,%esi
f0106482:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106486:	39 c6                	cmp    %eax,%esi
f0106488:	0f 82 6e ff ff ff    	jb     f01063fc <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010648e:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0106493:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010649a:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f01064a1:	75 22                	jne    f01064c5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01064a3:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f01064aa:	00 00 00 
		lapicaddr = 0;
f01064ad:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f01064b4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01064b7:	c7 04 24 74 8c 10 f0 	movl   $0xf0108c74,(%esp)
f01064be:	e8 c8 dd ff ff       	call   f010428b <cprintf>
		return;
f01064c3:	eb 44                	jmp    f0106509 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01064c5:	8b 15 c4 23 23 f0    	mov    0xf02323c4,%edx
f01064cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01064cf:	0f b6 00             	movzbl (%eax),%eax
f01064d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064d6:	c7 04 24 fb 8c 10 f0 	movl   $0xf0108cfb,(%esp)
f01064dd:	e8 a9 dd ff ff       	call   f010428b <cprintf>

	if (mp->imcrp) {
f01064e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064e5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01064e9:	74 1e                	je     f0106509 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01064eb:	c7 04 24 a0 8c 10 f0 	movl   $0xf0108ca0,(%esp)
f01064f2:	e8 94 dd ff ff       	call   f010428b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01064f7:	ba 22 00 00 00       	mov    $0x22,%edx
f01064fc:	b8 70 00 00 00       	mov    $0x70,%eax
f0106501:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106502:	b2 23                	mov    $0x23,%dl
f0106504:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106505:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106508:	ee                   	out    %al,(%dx)
	}
}
f0106509:	83 c4 2c             	add    $0x2c,%esp
f010650c:	5b                   	pop    %ebx
f010650d:	5e                   	pop    %esi
f010650e:	5f                   	pop    %edi
f010650f:	5d                   	pop    %ebp
f0106510:	c3                   	ret    

f0106511 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106511:	55                   	push   %ebp
f0106512:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106514:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f010651a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010651d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010651f:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0106524:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106527:	5d                   	pop    %ebp
f0106528:	c3                   	ret    

f0106529 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106529:	55                   	push   %ebp
f010652a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010652c:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0106531:	85 c0                	test   %eax,%eax
f0106533:	74 08                	je     f010653d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106535:	8b 40 20             	mov    0x20(%eax),%eax
f0106538:	c1 e8 18             	shr    $0x18,%eax
f010653b:	eb 05                	jmp    f0106542 <cpunum+0x19>
	return 0;
f010653d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106542:	5d                   	pop    %ebp
f0106543:	c3                   	ret    

f0106544 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106544:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f0106549:	85 c0                	test   %eax,%eax
f010654b:	0f 84 23 01 00 00    	je     f0106674 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106551:	55                   	push   %ebp
f0106552:	89 e5                	mov    %esp,%ebp
f0106554:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106557:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010655e:	00 
f010655f:	89 04 24             	mov    %eax,(%esp)
f0106562:	e8 82 b2 ff ff       	call   f01017e9 <mmio_map_region>
f0106567:	a3 04 30 27 f0       	mov    %eax,0xf0273004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010656c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106571:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106576:	e8 96 ff ff ff       	call   f0106511 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010657b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106580:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106585:	e8 87 ff ff ff       	call   f0106511 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010658a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010658f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106594:	e8 78 ff ff ff       	call   f0106511 <lapicw>
	lapicw(TICR, 10000000); 
f0106599:	ba 80 96 98 00       	mov    $0x989680,%edx
f010659e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01065a3:	e8 69 ff ff ff       	call   f0106511 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01065a8:	e8 7c ff ff ff       	call   f0106529 <cpunum>
f01065ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01065b0:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01065b5:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f01065bb:	74 0f                	je     f01065cc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01065bd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065c2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01065c7:	e8 45 ff ff ff       	call   f0106511 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01065cc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065d1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01065d6:	e8 36 ff ff ff       	call   f0106511 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01065db:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f01065e0:	8b 40 30             	mov    0x30(%eax),%eax
f01065e3:	c1 e8 10             	shr    $0x10,%eax
f01065e6:	3c 03                	cmp    $0x3,%al
f01065e8:	76 0f                	jbe    f01065f9 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01065ea:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065ef:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01065f4:	e8 18 ff ff ff       	call   f0106511 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01065f9:	ba 33 00 00 00       	mov    $0x33,%edx
f01065fe:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106603:	e8 09 ff ff ff       	call   f0106511 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106608:	ba 00 00 00 00       	mov    $0x0,%edx
f010660d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106612:	e8 fa fe ff ff       	call   f0106511 <lapicw>
	lapicw(ESR, 0);
f0106617:	ba 00 00 00 00       	mov    $0x0,%edx
f010661c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106621:	e8 eb fe ff ff       	call   f0106511 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106626:	ba 00 00 00 00       	mov    $0x0,%edx
f010662b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106630:	e8 dc fe ff ff       	call   f0106511 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106635:	ba 00 00 00 00       	mov    $0x0,%edx
f010663a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010663f:	e8 cd fe ff ff       	call   f0106511 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106644:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106649:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010664e:	e8 be fe ff ff       	call   f0106511 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106653:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0106659:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010665f:	f6 c4 10             	test   $0x10,%ah
f0106662:	75 f5                	jne    f0106659 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106664:	ba 00 00 00 00       	mov    $0x0,%edx
f0106669:	b8 20 00 00 00       	mov    $0x20,%eax
f010666e:	e8 9e fe ff ff       	call   f0106511 <lapicw>
}
f0106673:	c9                   	leave  
f0106674:	f3 c3                	repz ret 

f0106676 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106676:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f010667d:	74 13                	je     f0106692 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010667f:	55                   	push   %ebp
f0106680:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106682:	ba 00 00 00 00       	mov    $0x0,%edx
f0106687:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010668c:	e8 80 fe ff ff       	call   f0106511 <lapicw>
}
f0106691:	5d                   	pop    %ebp
f0106692:	f3 c3                	repz ret 

f0106694 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106694:	55                   	push   %ebp
f0106695:	89 e5                	mov    %esp,%ebp
f0106697:	56                   	push   %esi
f0106698:	53                   	push   %ebx
f0106699:	83 ec 10             	sub    $0x10,%esp
f010669c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010669f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01066a2:	ba 70 00 00 00       	mov    $0x70,%edx
f01066a7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01066ac:	ee                   	out    %al,(%dx)
f01066ad:	b2 71                	mov    $0x71,%dl
f01066af:	b8 0a 00 00 00       	mov    $0xa,%eax
f01066b4:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01066b5:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f01066bc:	75 24                	jne    f01066e2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066be:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01066c5:	00 
f01066c6:	c7 44 24 08 24 6c 10 	movl   $0xf0106c24,0x8(%esp)
f01066cd:	f0 
f01066ce:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01066d5:	00 
f01066d6:	c7 04 24 18 8d 10 f0 	movl   $0xf0108d18,(%esp)
f01066dd:	e8 5e 99 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01066e2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01066e9:	00 00 
	wrv[1] = addr >> 4;
f01066eb:	89 f0                	mov    %esi,%eax
f01066ed:	c1 e8 04             	shr    $0x4,%eax
f01066f0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01066f6:	c1 e3 18             	shl    $0x18,%ebx
f01066f9:	89 da                	mov    %ebx,%edx
f01066fb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106700:	e8 0c fe ff ff       	call   f0106511 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106705:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010670a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010670f:	e8 fd fd ff ff       	call   f0106511 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106714:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106719:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010671e:	e8 ee fd ff ff       	call   f0106511 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106723:	c1 ee 0c             	shr    $0xc,%esi
f0106726:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010672c:	89 da                	mov    %ebx,%edx
f010672e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106733:	e8 d9 fd ff ff       	call   f0106511 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106738:	89 f2                	mov    %esi,%edx
f010673a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010673f:	e8 cd fd ff ff       	call   f0106511 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106744:	89 da                	mov    %ebx,%edx
f0106746:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010674b:	e8 c1 fd ff ff       	call   f0106511 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106750:	89 f2                	mov    %esi,%edx
f0106752:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106757:	e8 b5 fd ff ff       	call   f0106511 <lapicw>
		microdelay(200);
	}
}
f010675c:	83 c4 10             	add    $0x10,%esp
f010675f:	5b                   	pop    %ebx
f0106760:	5e                   	pop    %esi
f0106761:	5d                   	pop    %ebp
f0106762:	c3                   	ret    

f0106763 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106763:	55                   	push   %ebp
f0106764:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106766:	8b 55 08             	mov    0x8(%ebp),%edx
f0106769:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010676f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106774:	e8 98 fd ff ff       	call   f0106511 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106779:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f010677f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106785:	f6 c4 10             	test   $0x10,%ah
f0106788:	75 f5                	jne    f010677f <lapic_ipi+0x1c>
		;
}
f010678a:	5d                   	pop    %ebp
f010678b:	c3                   	ret    

f010678c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010678c:	55                   	push   %ebp
f010678d:	89 e5                	mov    %esp,%ebp
f010678f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106792:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106798:	8b 55 0c             	mov    0xc(%ebp),%edx
f010679b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010679e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01067a5:	5d                   	pop    %ebp
f01067a6:	c3                   	ret    

f01067a7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01067a7:	55                   	push   %ebp
f01067a8:	89 e5                	mov    %esp,%ebp
f01067aa:	56                   	push   %esi
f01067ab:	53                   	push   %ebx
f01067ac:	83 ec 20             	sub    $0x20,%esp
f01067af:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01067b2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01067b5:	75 07                	jne    f01067be <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01067b7:	ba 01 00 00 00       	mov    $0x1,%edx
f01067bc:	eb 42                	jmp    f0106800 <spin_lock+0x59>
f01067be:	8b 73 08             	mov    0x8(%ebx),%esi
f01067c1:	e8 63 fd ff ff       	call   f0106529 <cpunum>
f01067c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01067c9:	05 20 20 23 f0       	add    $0xf0232020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01067ce:	39 c6                	cmp    %eax,%esi
f01067d0:	75 e5                	jne    f01067b7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01067d2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01067d5:	e8 4f fd ff ff       	call   f0106529 <cpunum>
f01067da:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01067de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067e2:	c7 44 24 08 28 8d 10 	movl   $0xf0108d28,0x8(%esp)
f01067e9:	f0 
f01067ea:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01067f1:	00 
f01067f2:	c7 04 24 8c 8d 10 f0 	movl   $0xf0108d8c,(%esp)
f01067f9:	e8 42 98 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01067fe:	f3 90                	pause  
f0106800:	89 d0                	mov    %edx,%eax
f0106802:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106805:	85 c0                	test   %eax,%eax
f0106807:	75 f5                	jne    f01067fe <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106809:	e8 1b fd ff ff       	call   f0106529 <cpunum>
f010680e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106811:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0106816:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106819:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010681c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010681e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106823:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106829:	76 12                	jbe    f010683d <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010682b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010682e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106831:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106833:	83 c0 01             	add    $0x1,%eax
f0106836:	83 f8 0a             	cmp    $0xa,%eax
f0106839:	75 e8                	jne    f0106823 <spin_lock+0x7c>
f010683b:	eb 0f                	jmp    f010684c <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010683d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106844:	83 c0 01             	add    $0x1,%eax
f0106847:	83 f8 09             	cmp    $0x9,%eax
f010684a:	7e f1                	jle    f010683d <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010684c:	83 c4 20             	add    $0x20,%esp
f010684f:	5b                   	pop    %ebx
f0106850:	5e                   	pop    %esi
f0106851:	5d                   	pop    %ebp
f0106852:	c3                   	ret    

f0106853 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106853:	55                   	push   %ebp
f0106854:	89 e5                	mov    %esp,%ebp
f0106856:	57                   	push   %edi
f0106857:	56                   	push   %esi
f0106858:	53                   	push   %ebx
f0106859:	83 ec 6c             	sub    $0x6c,%esp
f010685c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010685f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106862:	74 18                	je     f010687c <spin_unlock+0x29>
f0106864:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106867:	e8 bd fc ff ff       	call   f0106529 <cpunum>
f010686c:	6b c0 74             	imul   $0x74,%eax,%eax
f010686f:	05 20 20 23 f0       	add    $0xf0232020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106874:	39 c3                	cmp    %eax,%ebx
f0106876:	0f 84 ce 00 00 00    	je     f010694a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010687c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106883:	00 
f0106884:	8d 46 0c             	lea    0xc(%esi),%eax
f0106887:	89 44 24 04          	mov    %eax,0x4(%esp)
f010688b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010688e:	89 1c 24             	mov    %ebx,(%esp)
f0106891:	e8 8e f6 ff ff       	call   f0105f24 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106896:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106899:	0f b6 38             	movzbl (%eax),%edi
f010689c:	8b 76 04             	mov    0x4(%esi),%esi
f010689f:	e8 85 fc ff ff       	call   f0106529 <cpunum>
f01068a4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01068a8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01068ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068b0:	c7 04 24 54 8d 10 f0 	movl   $0xf0108d54,(%esp)
f01068b7:	e8 cf d9 ff ff       	call   f010428b <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01068bc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01068bf:	eb 65                	jmp    f0106926 <spin_unlock+0xd3>
f01068c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01068c5:	89 04 24             	mov    %eax,(%esp)
f01068c8:	e8 95 eb ff ff       	call   f0105462 <debuginfo_eip>
f01068cd:	85 c0                	test   %eax,%eax
f01068cf:	78 39                	js     f010690a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01068d1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01068d3:	89 c2                	mov    %eax,%edx
f01068d5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01068d8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01068dc:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01068df:	89 54 24 14          	mov    %edx,0x14(%esp)
f01068e3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01068e6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01068ea:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01068ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01068f1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f01068f4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01068f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068fc:	c7 04 24 9c 8d 10 f0 	movl   $0xf0108d9c,(%esp)
f0106903:	e8 83 d9 ff ff       	call   f010428b <cprintf>
f0106908:	eb 12                	jmp    f010691c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010690a:	8b 06                	mov    (%esi),%eax
f010690c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106910:	c7 04 24 b3 8d 10 f0 	movl   $0xf0108db3,(%esp)
f0106917:	e8 6f d9 ff ff       	call   f010428b <cprintf>
f010691c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010691f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106922:	39 c3                	cmp    %eax,%ebx
f0106924:	74 08                	je     f010692e <spin_unlock+0xdb>
f0106926:	89 de                	mov    %ebx,%esi
f0106928:	8b 03                	mov    (%ebx),%eax
f010692a:	85 c0                	test   %eax,%eax
f010692c:	75 93                	jne    f01068c1 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010692e:	c7 44 24 08 bb 8d 10 	movl   $0xf0108dbb,0x8(%esp)
f0106935:	f0 
f0106936:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010693d:	00 
f010693e:	c7 04 24 8c 8d 10 f0 	movl   $0xf0108d8c,(%esp)
f0106945:	e8 f6 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010694a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106951:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106958:	b8 00 00 00 00       	mov    $0x0,%eax
f010695d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106960:	83 c4 6c             	add    $0x6c,%esp
f0106963:	5b                   	pop    %ebx
f0106964:	5e                   	pop    %esi
f0106965:	5f                   	pop    %edi
f0106966:	5d                   	pop    %ebp
f0106967:	c3                   	ret    
f0106968:	66 90                	xchg   %ax,%ax
f010696a:	66 90                	xchg   %ax,%ax
f010696c:	66 90                	xchg   %ax,%ax
f010696e:	66 90                	xchg   %ax,%ax

f0106970 <__udivdi3>:
f0106970:	55                   	push   %ebp
f0106971:	57                   	push   %edi
f0106972:	56                   	push   %esi
f0106973:	83 ec 0c             	sub    $0xc,%esp
f0106976:	8b 44 24 28          	mov    0x28(%esp),%eax
f010697a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010697e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106982:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106986:	85 c0                	test   %eax,%eax
f0106988:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010698c:	89 ea                	mov    %ebp,%edx
f010698e:	89 0c 24             	mov    %ecx,(%esp)
f0106991:	75 2d                	jne    f01069c0 <__udivdi3+0x50>
f0106993:	39 e9                	cmp    %ebp,%ecx
f0106995:	77 61                	ja     f01069f8 <__udivdi3+0x88>
f0106997:	85 c9                	test   %ecx,%ecx
f0106999:	89 ce                	mov    %ecx,%esi
f010699b:	75 0b                	jne    f01069a8 <__udivdi3+0x38>
f010699d:	b8 01 00 00 00       	mov    $0x1,%eax
f01069a2:	31 d2                	xor    %edx,%edx
f01069a4:	f7 f1                	div    %ecx
f01069a6:	89 c6                	mov    %eax,%esi
f01069a8:	31 d2                	xor    %edx,%edx
f01069aa:	89 e8                	mov    %ebp,%eax
f01069ac:	f7 f6                	div    %esi
f01069ae:	89 c5                	mov    %eax,%ebp
f01069b0:	89 f8                	mov    %edi,%eax
f01069b2:	f7 f6                	div    %esi
f01069b4:	89 ea                	mov    %ebp,%edx
f01069b6:	83 c4 0c             	add    $0xc,%esp
f01069b9:	5e                   	pop    %esi
f01069ba:	5f                   	pop    %edi
f01069bb:	5d                   	pop    %ebp
f01069bc:	c3                   	ret    
f01069bd:	8d 76 00             	lea    0x0(%esi),%esi
f01069c0:	39 e8                	cmp    %ebp,%eax
f01069c2:	77 24                	ja     f01069e8 <__udivdi3+0x78>
f01069c4:	0f bd e8             	bsr    %eax,%ebp
f01069c7:	83 f5 1f             	xor    $0x1f,%ebp
f01069ca:	75 3c                	jne    f0106a08 <__udivdi3+0x98>
f01069cc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01069d0:	39 34 24             	cmp    %esi,(%esp)
f01069d3:	0f 86 9f 00 00 00    	jbe    f0106a78 <__udivdi3+0x108>
f01069d9:	39 d0                	cmp    %edx,%eax
f01069db:	0f 82 97 00 00 00    	jb     f0106a78 <__udivdi3+0x108>
f01069e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069e8:	31 d2                	xor    %edx,%edx
f01069ea:	31 c0                	xor    %eax,%eax
f01069ec:	83 c4 0c             	add    $0xc,%esp
f01069ef:	5e                   	pop    %esi
f01069f0:	5f                   	pop    %edi
f01069f1:	5d                   	pop    %ebp
f01069f2:	c3                   	ret    
f01069f3:	90                   	nop
f01069f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069f8:	89 f8                	mov    %edi,%eax
f01069fa:	f7 f1                	div    %ecx
f01069fc:	31 d2                	xor    %edx,%edx
f01069fe:	83 c4 0c             	add    $0xc,%esp
f0106a01:	5e                   	pop    %esi
f0106a02:	5f                   	pop    %edi
f0106a03:	5d                   	pop    %ebp
f0106a04:	c3                   	ret    
f0106a05:	8d 76 00             	lea    0x0(%esi),%esi
f0106a08:	89 e9                	mov    %ebp,%ecx
f0106a0a:	8b 3c 24             	mov    (%esp),%edi
f0106a0d:	d3 e0                	shl    %cl,%eax
f0106a0f:	89 c6                	mov    %eax,%esi
f0106a11:	b8 20 00 00 00       	mov    $0x20,%eax
f0106a16:	29 e8                	sub    %ebp,%eax
f0106a18:	89 c1                	mov    %eax,%ecx
f0106a1a:	d3 ef                	shr    %cl,%edi
f0106a1c:	89 e9                	mov    %ebp,%ecx
f0106a1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106a22:	8b 3c 24             	mov    (%esp),%edi
f0106a25:	09 74 24 08          	or     %esi,0x8(%esp)
f0106a29:	89 d6                	mov    %edx,%esi
f0106a2b:	d3 e7                	shl    %cl,%edi
f0106a2d:	89 c1                	mov    %eax,%ecx
f0106a2f:	89 3c 24             	mov    %edi,(%esp)
f0106a32:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106a36:	d3 ee                	shr    %cl,%esi
f0106a38:	89 e9                	mov    %ebp,%ecx
f0106a3a:	d3 e2                	shl    %cl,%edx
f0106a3c:	89 c1                	mov    %eax,%ecx
f0106a3e:	d3 ef                	shr    %cl,%edi
f0106a40:	09 d7                	or     %edx,%edi
f0106a42:	89 f2                	mov    %esi,%edx
f0106a44:	89 f8                	mov    %edi,%eax
f0106a46:	f7 74 24 08          	divl   0x8(%esp)
f0106a4a:	89 d6                	mov    %edx,%esi
f0106a4c:	89 c7                	mov    %eax,%edi
f0106a4e:	f7 24 24             	mull   (%esp)
f0106a51:	39 d6                	cmp    %edx,%esi
f0106a53:	89 14 24             	mov    %edx,(%esp)
f0106a56:	72 30                	jb     f0106a88 <__udivdi3+0x118>
f0106a58:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106a5c:	89 e9                	mov    %ebp,%ecx
f0106a5e:	d3 e2                	shl    %cl,%edx
f0106a60:	39 c2                	cmp    %eax,%edx
f0106a62:	73 05                	jae    f0106a69 <__udivdi3+0xf9>
f0106a64:	3b 34 24             	cmp    (%esp),%esi
f0106a67:	74 1f                	je     f0106a88 <__udivdi3+0x118>
f0106a69:	89 f8                	mov    %edi,%eax
f0106a6b:	31 d2                	xor    %edx,%edx
f0106a6d:	e9 7a ff ff ff       	jmp    f01069ec <__udivdi3+0x7c>
f0106a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a78:	31 d2                	xor    %edx,%edx
f0106a7a:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a7f:	e9 68 ff ff ff       	jmp    f01069ec <__udivdi3+0x7c>
f0106a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a88:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106a8b:	31 d2                	xor    %edx,%edx
f0106a8d:	83 c4 0c             	add    $0xc,%esp
f0106a90:	5e                   	pop    %esi
f0106a91:	5f                   	pop    %edi
f0106a92:	5d                   	pop    %ebp
f0106a93:	c3                   	ret    
f0106a94:	66 90                	xchg   %ax,%ax
f0106a96:	66 90                	xchg   %ax,%ax
f0106a98:	66 90                	xchg   %ax,%ax
f0106a9a:	66 90                	xchg   %ax,%ax
f0106a9c:	66 90                	xchg   %ax,%ax
f0106a9e:	66 90                	xchg   %ax,%ax

f0106aa0 <__umoddi3>:
f0106aa0:	55                   	push   %ebp
f0106aa1:	57                   	push   %edi
f0106aa2:	56                   	push   %esi
f0106aa3:	83 ec 14             	sub    $0x14,%esp
f0106aa6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106aaa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106aae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106ab2:	89 c7                	mov    %eax,%edi
f0106ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ab8:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106abc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106ac0:	89 34 24             	mov    %esi,(%esp)
f0106ac3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106ac7:	85 c0                	test   %eax,%eax
f0106ac9:	89 c2                	mov    %eax,%edx
f0106acb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106acf:	75 17                	jne    f0106ae8 <__umoddi3+0x48>
f0106ad1:	39 fe                	cmp    %edi,%esi
f0106ad3:	76 4b                	jbe    f0106b20 <__umoddi3+0x80>
f0106ad5:	89 c8                	mov    %ecx,%eax
f0106ad7:	89 fa                	mov    %edi,%edx
f0106ad9:	f7 f6                	div    %esi
f0106adb:	89 d0                	mov    %edx,%eax
f0106add:	31 d2                	xor    %edx,%edx
f0106adf:	83 c4 14             	add    $0x14,%esp
f0106ae2:	5e                   	pop    %esi
f0106ae3:	5f                   	pop    %edi
f0106ae4:	5d                   	pop    %ebp
f0106ae5:	c3                   	ret    
f0106ae6:	66 90                	xchg   %ax,%ax
f0106ae8:	39 f8                	cmp    %edi,%eax
f0106aea:	77 54                	ja     f0106b40 <__umoddi3+0xa0>
f0106aec:	0f bd e8             	bsr    %eax,%ebp
f0106aef:	83 f5 1f             	xor    $0x1f,%ebp
f0106af2:	75 5c                	jne    f0106b50 <__umoddi3+0xb0>
f0106af4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106af8:	39 3c 24             	cmp    %edi,(%esp)
f0106afb:	0f 87 e7 00 00 00    	ja     f0106be8 <__umoddi3+0x148>
f0106b01:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106b05:	29 f1                	sub    %esi,%ecx
f0106b07:	19 c7                	sbb    %eax,%edi
f0106b09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106b0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106b11:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106b15:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106b19:	83 c4 14             	add    $0x14,%esp
f0106b1c:	5e                   	pop    %esi
f0106b1d:	5f                   	pop    %edi
f0106b1e:	5d                   	pop    %ebp
f0106b1f:	c3                   	ret    
f0106b20:	85 f6                	test   %esi,%esi
f0106b22:	89 f5                	mov    %esi,%ebp
f0106b24:	75 0b                	jne    f0106b31 <__umoddi3+0x91>
f0106b26:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b2b:	31 d2                	xor    %edx,%edx
f0106b2d:	f7 f6                	div    %esi
f0106b2f:	89 c5                	mov    %eax,%ebp
f0106b31:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106b35:	31 d2                	xor    %edx,%edx
f0106b37:	f7 f5                	div    %ebp
f0106b39:	89 c8                	mov    %ecx,%eax
f0106b3b:	f7 f5                	div    %ebp
f0106b3d:	eb 9c                	jmp    f0106adb <__umoddi3+0x3b>
f0106b3f:	90                   	nop
f0106b40:	89 c8                	mov    %ecx,%eax
f0106b42:	89 fa                	mov    %edi,%edx
f0106b44:	83 c4 14             	add    $0x14,%esp
f0106b47:	5e                   	pop    %esi
f0106b48:	5f                   	pop    %edi
f0106b49:	5d                   	pop    %ebp
f0106b4a:	c3                   	ret    
f0106b4b:	90                   	nop
f0106b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b50:	8b 04 24             	mov    (%esp),%eax
f0106b53:	be 20 00 00 00       	mov    $0x20,%esi
f0106b58:	89 e9                	mov    %ebp,%ecx
f0106b5a:	29 ee                	sub    %ebp,%esi
f0106b5c:	d3 e2                	shl    %cl,%edx
f0106b5e:	89 f1                	mov    %esi,%ecx
f0106b60:	d3 e8                	shr    %cl,%eax
f0106b62:	89 e9                	mov    %ebp,%ecx
f0106b64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b68:	8b 04 24             	mov    (%esp),%eax
f0106b6b:	09 54 24 04          	or     %edx,0x4(%esp)
f0106b6f:	89 fa                	mov    %edi,%edx
f0106b71:	d3 e0                	shl    %cl,%eax
f0106b73:	89 f1                	mov    %esi,%ecx
f0106b75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106b79:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106b7d:	d3 ea                	shr    %cl,%edx
f0106b7f:	89 e9                	mov    %ebp,%ecx
f0106b81:	d3 e7                	shl    %cl,%edi
f0106b83:	89 f1                	mov    %esi,%ecx
f0106b85:	d3 e8                	shr    %cl,%eax
f0106b87:	89 e9                	mov    %ebp,%ecx
f0106b89:	09 f8                	or     %edi,%eax
f0106b8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106b8f:	f7 74 24 04          	divl   0x4(%esp)
f0106b93:	d3 e7                	shl    %cl,%edi
f0106b95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106b99:	89 d7                	mov    %edx,%edi
f0106b9b:	f7 64 24 08          	mull   0x8(%esp)
f0106b9f:	39 d7                	cmp    %edx,%edi
f0106ba1:	89 c1                	mov    %eax,%ecx
f0106ba3:	89 14 24             	mov    %edx,(%esp)
f0106ba6:	72 2c                	jb     f0106bd4 <__umoddi3+0x134>
f0106ba8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106bac:	72 22                	jb     f0106bd0 <__umoddi3+0x130>
f0106bae:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106bb2:	29 c8                	sub    %ecx,%eax
f0106bb4:	19 d7                	sbb    %edx,%edi
f0106bb6:	89 e9                	mov    %ebp,%ecx
f0106bb8:	89 fa                	mov    %edi,%edx
f0106bba:	d3 e8                	shr    %cl,%eax
f0106bbc:	89 f1                	mov    %esi,%ecx
f0106bbe:	d3 e2                	shl    %cl,%edx
f0106bc0:	89 e9                	mov    %ebp,%ecx
f0106bc2:	d3 ef                	shr    %cl,%edi
f0106bc4:	09 d0                	or     %edx,%eax
f0106bc6:	89 fa                	mov    %edi,%edx
f0106bc8:	83 c4 14             	add    $0x14,%esp
f0106bcb:	5e                   	pop    %esi
f0106bcc:	5f                   	pop    %edi
f0106bcd:	5d                   	pop    %ebp
f0106bce:	c3                   	ret    
f0106bcf:	90                   	nop
f0106bd0:	39 d7                	cmp    %edx,%edi
f0106bd2:	75 da                	jne    f0106bae <__umoddi3+0x10e>
f0106bd4:	8b 14 24             	mov    (%esp),%edx
f0106bd7:	89 c1                	mov    %eax,%ecx
f0106bd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106bdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106be1:	eb cb                	jmp    f0106bae <__umoddi3+0x10e>
f0106be3:	90                   	nop
f0106be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106be8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106bec:	0f 82 0f ff ff ff    	jb     f0106b01 <__umoddi3+0x61>
f0106bf2:	e9 1a ff ff ff       	jmp    f0106b11 <__umoddi3+0x71>
