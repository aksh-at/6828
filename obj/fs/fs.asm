
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 c1 1b 00 00       	call   801bf2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800084:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	0f b6 c3             	movzbl %bl,%eax
  8000ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000af:	c7 04 24 00 42 80 00 	movl   $0x804200,(%esp)
  8000b6:	e8 91 1c 00 00       	call   801d4c <cprintf>
	return (x < 1000);
}
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	83 c4 14             	add    $0x14,%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 18             	sub    $0x18,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 1c                	jbe    8000ed <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d1:	c7 44 24 08 17 42 80 	movl   $0x804217,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  8000e8:	e8 66 1b 00 00       	call   801c53 <_panic>
	diskno = d;
  8000ed:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 1c             	sub    $0x1c,%esp
  8000fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800103:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800106:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80010c:	76 24                	jbe    800132 <ide_read+0x3e>
  80010e:	c7 44 24 0c 30 42 80 	movl   $0x804230,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  80012d:	e8 21 1b 00 00       	call   801c53 <_panic>

	ide_wait_ready(0);
  800132:	b8 00 00 00 00       	mov    $0x0,%eax
  800137:	e8 f7 fe ff ff       	call   800033 <ide_wait_ready>
  80013c:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800141:	89 f0                	mov    %esi,%eax
  800143:	ee                   	out    %al,(%dx)
  800144:	b2 f3                	mov    $0xf3,%dl
  800146:	89 f8                	mov    %edi,%eax
  800148:	ee                   	out    %al,(%dx)
  800149:	89 f8                	mov    %edi,%eax
  80014b:	0f b6 c4             	movzbl %ah,%eax
  80014e:	b2 f4                	mov    $0xf4,%dl
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 10             	shr    $0x10,%eax
  800156:	b2 f5                	mov    $0xf5,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800159:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800160:	83 e0 01             	and    $0x1,%eax
  800163:	c1 e0 04             	shl    $0x4,%eax
  800166:	83 c8 e0             	or     $0xffffffe0,%eax
  800169:	c1 ef 18             	shr    $0x18,%edi
  80016c:	83 e7 0f             	and    $0xf,%edi
  80016f:	09 f8                	or     %edi,%eax
  800171:	b2 f6                	mov    $0xf6,%dl
  800173:	ee                   	out    %al,(%dx)
  800174:	b2 f7                	mov    $0xf7,%dl
  800176:	b8 20 00 00 00       	mov    $0x20,%eax
  80017b:	ee                   	out    %al,(%dx)
  80017c:	c1 e6 09             	shl    $0x9,%esi
  80017f:	01 de                	add    %ebx,%esi
  800181:	eb 23                	jmp    8001a6 <ide_read+0xb2>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800183:	b8 01 00 00 00       	mov    $0x1,%eax
  800188:	e8 a6 fe ff ff       	call   800033 <ide_wait_ready>
  80018d:	85 c0                	test   %eax,%eax
  80018f:	78 1e                	js     8001af <ide_read+0xbb>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  800191:	89 df                	mov    %ebx,%edi
  800193:	b9 80 00 00 00       	mov    $0x80,%ecx
  800198:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019d:	fc                   	cld    
  80019e:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001a0:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001a6:	39 f3                	cmp    %esi,%ebx
  8001a8:	75 d9                	jne    800183 <ide_read+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001af:	83 c4 1c             	add    $0x1c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 1c             	sub    $0x1c,%esp
  8001c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c6:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c9:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001cf:	76 24                	jbe    8001f5 <ide_write+0x3e>
  8001d1:	c7 44 24 0c 30 42 80 	movl   $0x804230,0xc(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  8001f0:	e8 5e 1a 00 00       	call   801c53 <_panic>

	ide_wait_ready(0);
  8001f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fa:	e8 34 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ff:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	ee                   	out    %al,(%dx)
  800207:	b2 f3                	mov    $0xf3,%dl
  800209:	89 f0                	mov    %esi,%eax
  80020b:	ee                   	out    %al,(%dx)
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	0f b6 c4             	movzbl %ah,%eax
  800211:	b2 f4                	mov    $0xf4,%dl
  800213:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800214:	89 f0                	mov    %esi,%eax
  800216:	c1 e8 10             	shr    $0x10,%eax
  800219:	b2 f5                	mov    $0xf5,%dl
  80021b:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800223:	83 e0 01             	and    $0x1,%eax
  800226:	c1 e0 04             	shl    $0x4,%eax
  800229:	83 c8 e0             	or     $0xffffffe0,%eax
  80022c:	c1 ee 18             	shr    $0x18,%esi
  80022f:	83 e6 0f             	and    $0xf,%esi
  800232:	09 f0                	or     %esi,%eax
  800234:	b2 f6                	mov    $0xf6,%dl
  800236:	ee                   	out    %al,(%dx)
  800237:	b2 f7                	mov    $0xf7,%dl
  800239:	b8 30 00 00 00       	mov    $0x30,%eax
  80023e:	ee                   	out    %al,(%dx)
  80023f:	c1 e7 09             	shl    $0x9,%edi
  800242:	01 df                	add    %ebx,%edi
  800244:	eb 23                	jmp    800269 <ide_write+0xb2>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800246:	b8 01 00 00 00       	mov    $0x1,%eax
  80024b:	e8 e3 fd ff ff       	call   800033 <ide_wait_ready>
  800250:	85 c0                	test   %eax,%eax
  800252:	78 1e                	js     800272 <ide_write+0xbb>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800254:	89 de                	mov    %ebx,%esi
  800256:	b9 80 00 00 00       	mov    $0x80,%ecx
  80025b:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800260:	fc                   	cld    
  800261:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800263:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800269:	39 fb                	cmp    %edi,%ebx
  80026b:	75 d9                	jne    800246 <ide_write+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	83 c4 1c             	add    $0x1c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800286:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800288:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028e:	89 c6                	mov    %eax,%esi
  800290:	c1 ee 0c             	shr    $0xc,%esi
	int r = 0;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800293:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800298:	76 2e                	jbe    8002c8 <bc_pgfault+0x4e>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80029a:	8b 42 04             	mov    0x4(%edx),%eax
  80029d:	89 44 24 14          	mov    %eax,0x14(%esp)
  8002a1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002a5:	8b 42 28             	mov    0x28(%edx),%eax
  8002a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ac:	c7 44 24 08 54 42 80 	movl   $0x804254,0x8(%esp)
  8002b3:	00 
  8002b4:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8002bb:	00 
  8002bc:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8002c3:	e8 8b 19 00 00       	call   801c53 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	74 25                	je     8002f6 <bc_pgfault+0x7c>
  8002d1:	3b 70 04             	cmp    0x4(%eax),%esi
  8002d4:	72 20                	jb     8002f6 <bc_pgfault+0x7c>
		panic("reading non-existent block %08x\n", blockno);
  8002d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002da:	c7 44 24 08 84 42 80 	movl   $0x804284,0x8(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8002e9:	00 
  8002ea:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8002f1:	e8 5d 19 00 00       	call   801c53 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void*)ROUNDDOWN((uint32_t) addr, BLKSIZE);
  8002f6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8002fc:	e8 54 24 00 00       	call   802755 <sys_getenvid>
	uint32_t secno = ((uint32_t)addr - DISKMAP) / SECTSIZE;

	r += sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P);
  800301:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800308:	00 
  800309:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800314:	e8 7a 24 00 00       	call   802793 <sys_page_alloc>
  800319:	89 c7                	mov    %eax,%edi
	r += ide_read(secno, addr,  BLKSECTS);
  80031b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800322:	00 
  800323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void*)ROUNDDOWN((uint32_t) addr, BLKSIZE);
	envid_t envid = sys_getenvid();
	uint32_t secno = ((uint32_t)addr - DISKMAP) / SECTSIZE;
  800327:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80032d:	c1 e8 09             	shr    $0x9,%eax

	r += sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P);
	r += ide_read(secno, addr,  BLKSECTS);
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 bc fd ff ff       	call   8000f4 <ide_read>

	if(r < 0) {
  800338:	01 c7                	add    %eax,%edi
  80033a:	79 1c                	jns    800358 <bc_pgfault+0xde>
		panic("couldn't allocate or read to page in bc_pgfault\n");
  80033c:	c7 44 24 08 a8 42 80 	movl   $0x8042a8,0x8(%esp)
  800343:	00 
  800344:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80034b:	00 
  80034c:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800353:	e8 fb 18 00 00       	call   801c53 <_panic>
	}

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800358:	89 d8                	mov    %ebx,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
  80035d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800364:	25 07 0e 00 00       	and    $0xe07,%eax
  800369:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800371:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800378:	00 
  800379:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800384:	e8 5e 24 00 00       	call   8027e7 <sys_page_map>
  800389:	85 c0                	test   %eax,%eax
  80038b:	79 20                	jns    8003ad <bc_pgfault+0x133>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80038d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800391:	c7 44 24 08 dc 42 80 	movl   $0x8042dc,0x8(%esp)
  800398:	00 
  800399:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8003a0:	00 
  8003a1:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8003a8:	e8 a6 18 00 00       	call   801c53 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003ad:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  8003b4:	74 2c                	je     8003e2 <bc_pgfault+0x168>
  8003b6:	89 34 24             	mov    %esi,(%esp)
  8003b9:	e8 24 04 00 00       	call   8007e2 <block_is_free>
  8003be:	84 c0                	test   %al,%al
  8003c0:	74 20                	je     8003e2 <bc_pgfault+0x168>
		panic("reading free block %08x\n", blockno);
  8003c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c6:	c7 44 24 08 70 43 80 	movl   $0x804370,0x8(%esp)
  8003cd:	00 
  8003ce:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8003d5:	00 
  8003d6:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8003dd:	e8 71 18 00 00       	call   801c53 <_panic>
}
  8003e2:	83 c4 2c             	add    $0x2c,%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5f                   	pop    %edi
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <diskaddr>:

#include "fs.h" 
// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 18             	sub    $0x18,%esp
  8003f0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	74 0f                	je     800406 <diskaddr+0x1c>
  8003f7:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003fd:	85 d2                	test   %edx,%edx
  8003ff:	74 25                	je     800426 <diskaddr+0x3c>
  800401:	3b 42 04             	cmp    0x4(%edx),%eax
  800404:	72 20                	jb     800426 <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  800406:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040a:	c7 44 24 08 fc 42 80 	movl   $0x8042fc,0x8(%esp)
  800411:	00 
  800412:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
  800419:	00 
  80041a:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800421:	e8 2d 18 00 00       	call   801c53 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800426:	05 00 00 01 00       	add    $0x10000,%eax
  80042b:	c1 e0 0c             	shl    $0xc,%eax
} 
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <va_is_mapped>:
// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800436:	89 d0                	mov    %edx,%eax
  800438:	c1 e8 16             	shr    $0x16,%eax
  80043b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800442:	b8 00 00 00 00       	mov    $0x0,%eax
  800447:	f6 c1 01             	test   $0x1,%cl
  80044a:	74 0d                	je     800459 <va_is_mapped+0x29>
  80044c:	c1 ea 0c             	shr    $0xc,%edx
  80044f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800456:	83 e0 01             	and    $0x1,%eax
  800459:	83 e0 01             	and    $0x1,%eax
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	c1 e8 0c             	shr    $0xc,%eax
  800467:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80046e:	c1 e8 06             	shr    $0x6,%eax
  800471:	83 e0 01             	and    $0x1,%eax
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <va_is_recently_accessed>:

bool
va_is_recently_accessed(void *va) {
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
	bool ret = (uvpt[PGNUM(va)] & PTE_A) != 0;
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	c1 e8 0c             	shr    $0xc,%eax
  80047f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800486:	c1 e8 05             	shr    $0x5,%eax
  800489:	83 e0 01             	and    $0x1,%eax
	return ret;
}
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    

0080048e <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	53                   	push   %ebx
  800492:	83 ec 24             	sub    $0x24,%esp
  800495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r = 0;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800498:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80049e:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004a3:	76 20                	jbe    8004c5 <flush_block+0x37>
		panic("flush_block of bad va %08x", addr);
  8004a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004a9:	c7 44 24 08 89 43 80 	movl   $0x804389,0x8(%esp)
  8004b0:	00 
  8004b1:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  8004b8:	00 
  8004b9:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8004c0:	e8 8e 17 00 00       	call   801c53 <_panic>

	// LAB 5: Your code here.
	addr = (void*)ROUNDDOWN((uint32_t) addr, BLKSIZE);
  8004c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t secno = ((uint32_t)addr - DISKMAP) / SECTSIZE;

	if(va_is_mapped(addr) && va_is_dirty(addr)) {
  8004cb:	89 1c 24             	mov    %ebx,(%esp)
  8004ce:	e8 5d ff ff ff       	call   800430 <va_is_mapped>
  8004d3:	84 c0                	test   %al,%al
  8004d5:	0f 84 a6 00 00 00    	je     800581 <flush_block+0xf3>
  8004db:	89 1c 24             	mov    %ebx,(%esp)
  8004de:	e8 7b ff ff ff       	call   80045e <va_is_dirty>
  8004e3:	84 c0                	test   %al,%al
  8004e5:	0f 84 96 00 00 00    	je     800581 <flush_block+0xf3>

		if((r = ide_write(secno, addr, BLKSECTS)) < 0) 
  8004eb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004f2:	00 
  8004f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	addr = (void*)ROUNDDOWN((uint32_t) addr, BLKSIZE);
	uint32_t secno = ((uint32_t)addr - DISKMAP) / SECTSIZE;
  8004f7:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8004fd:	c1 e8 09             	shr    $0x9,%eax

	if(va_is_mapped(addr) && va_is_dirty(addr)) {

		if((r = ide_write(secno, addr, BLKSECTS)) < 0) 
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 af fc ff ff       	call   8001b7 <ide_write>
  800508:	85 c0                	test   %eax,%eax
  80050a:	79 20                	jns    80052c <flush_block+0x9e>
			panic("in flush_block, ide_write: %e", r);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 a4 43 80 	movl   $0x8043a4,0x8(%esp)
  800517:	00 
  800518:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  80051f:	00 
  800520:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800527:	e8 27 17 00 00       	call   801c53 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80052c:	89 d8                	mov    %ebx,%eax
  80052e:	c1 e8 0c             	shr    $0xc,%eax
  800531:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800538:	25 07 0e 00 00       	and    $0xe07,%eax
  80053d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800541:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800545:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80054c:	00 
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800558:	e8 8a 22 00 00       	call   8027e7 <sys_page_map>
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 20                	jns    800581 <flush_block+0xf3>
			panic("in flush_block, sys_page_map: %e", r);
  800561:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800565:	c7 44 24 08 20 43 80 	movl   $0x804320,0x8(%esp)
  80056c:	00 
  80056d:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  800574:	00 
  800575:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  80057c:	e8 d2 16 00 00       	call   801c53 <_panic>
	}
}
  800581:	83 c4 24             	add    $0x24,%esp
  800584:	5b                   	pop    %ebx
  800585:	5d                   	pop    %ebp
  800586:	c3                   	ret    

00800587 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	81 ec 28 02 00 00    	sub    $0x228,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800590:	c7 04 24 7a 02 80 00 	movl   $0x80027a,(%esp)
  800597:	e8 24 25 00 00       	call   802ac0 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80059c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a3:	e8 42 fe ff ff       	call   8003ea <diskaddr>
  8005a8:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005af:	00 
  8005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	e8 52 1f 00 00       	call   802514 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005c9:	e8 1c fe ff ff       	call   8003ea <diskaddr>
  8005ce:	c7 44 24 04 c2 43 80 	movl   $0x8043c2,0x4(%esp)
  8005d5:	00 
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	e8 99 1d 00 00       	call   802377 <strcpy>
	flush_block(diskaddr(1));
  8005de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005e5:	e8 00 fe ff ff       	call   8003ea <diskaddr>
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 9c fe ff ff       	call   80048e <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f9:	e8 ec fd ff ff       	call   8003ea <diskaddr>
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	e8 2a fe ff ff       	call   800430 <va_is_mapped>
  800606:	84 c0                	test   %al,%al
  800608:	75 24                	jne    80062e <bc_init+0xa7>
  80060a:	c7 44 24 0c e4 43 80 	movl   $0x8043e4,0xc(%esp)
  800611:	00 
  800612:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800619:	00 
  80061a:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  800621:	00 
  800622:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800629:	e8 25 16 00 00       	call   801c53 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80062e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800635:	e8 b0 fd ff ff       	call   8003ea <diskaddr>
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	e8 1c fe ff ff       	call   80045e <va_is_dirty>
  800642:	84 c0                	test   %al,%al
  800644:	74 24                	je     80066a <bc_init+0xe3>
  800646:	c7 44 24 0c c9 43 80 	movl   $0x8043c9,0xc(%esp)
  80064d:	00 
  80064e:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800655:	00 
  800656:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80065d:	00 
  80065e:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800665:	e8 e9 15 00 00       	call   801c53 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80066a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800671:	e8 74 fd ff ff       	call   8003ea <diskaddr>
  800676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800681:	e8 b4 21 00 00       	call   80283a <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80068d:	e8 58 fd ff ff       	call   8003ea <diskaddr>
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	e8 96 fd ff ff       	call   800430 <va_is_mapped>
  80069a:	84 c0                	test   %al,%al
  80069c:	74 24                	je     8006c2 <bc_init+0x13b>
  80069e:	c7 44 24 0c e3 43 80 	movl   $0x8043e3,0xc(%esp)
  8006a5:	00 
  8006a6:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8006ad:	00 
  8006ae:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8006b5:	00 
  8006b6:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  8006bd:	e8 91 15 00 00       	call   801c53 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c9:	e8 1c fd ff ff       	call   8003ea <diskaddr>
  8006ce:	c7 44 24 04 c2 43 80 	movl   $0x8043c2,0x4(%esp)
  8006d5:	00 
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	e8 4e 1d 00 00       	call   80242c <strcmp>
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	74 24                	je     800706 <bc_init+0x17f>
  8006e2:	c7 44 24 0c 44 43 80 	movl   $0x804344,0xc(%esp)
  8006e9:	00 
  8006ea:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8006f1:	00 
  8006f2:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8006f9:	00 
  8006fa:	c7 04 24 68 43 80 00 	movl   $0x804368,(%esp)
  800701:	e8 4d 15 00 00       	call   801c53 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800706:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80070d:	e8 d8 fc ff ff       	call   8003ea <diskaddr>
  800712:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800719:	00 
  80071a:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800720:	89 54 24 04          	mov    %edx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	e8 e8 1d 00 00       	call   802514 <memmove>
	flush_block(diskaddr(1));
  80072c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800733:	e8 b2 fc ff ff       	call   8003ea <diskaddr>
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	e8 4e fd ff ff       	call   80048e <flush_block>

	cprintf("block cache is good\n");
  800740:	c7 04 24 fe 43 80 00 	movl   $0x8043fe,(%esp)
  800747:	e8 00 16 00 00       	call   801d4c <cprintf>

	//if((evicts++)%1000 == 0) 
	//free_old_blocks();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80074c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800753:	e8 92 fc ff ff       	call   8003ea <diskaddr>
  800758:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80075f:	00 
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	e8 a2 1d 00 00       	call   802514 <memmove>
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    
  800774:	66 90                	xchg   %ax,%ax
  800776:	66 90                	xchg   %ax,%ax
  800778:	66 90                	xchg   %ax,%ax
  80077a:	66 90                	xchg   %ax,%ax
  80077c:	66 90                	xchg   %ax,%ax
  80077e:	66 90                	xchg   %ax,%ax

00800780 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800786:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80078b:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800791:	74 1c                	je     8007af <check_super+0x2f>
		panic("bad file system magic number");
  800793:	c7 44 24 08 13 44 80 	movl   $0x804413,0x8(%esp)
  80079a:	00 
  80079b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8007a2:	00 
  8007a3:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  8007aa:	e8 a4 14 00 00       	call   801c53 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007af:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007b6:	76 1c                	jbe    8007d4 <check_super+0x54>
		panic("file system is too large");
  8007b8:	c7 44 24 08 38 44 80 	movl   $0x804438,0x8(%esp)
  8007bf:	00 
  8007c0:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8007c7:	00 
  8007c8:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  8007cf:	e8 7f 14 00 00       	call   801c53 <_panic>

	cprintf("superblock is good\n");
  8007d4:	c7 04 24 51 44 80 00 	movl   $0x804451,(%esp)
  8007db:	e8 6c 15 00 00       	call   801d4c <cprintf>
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007e8:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	74 22                	je     800814 <block_is_free+0x32>
		return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8007f7:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8007fa:	76 1d                	jbe    800819 <block_is_free+0x37>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007fc:	b8 01 00 00 00       	mov    $0x1,%eax
  800801:	d3 e0                	shl    %cl,%eax
  800803:	c1 e9 05             	shr    $0x5,%ecx
  800806:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80080c:	85 04 8a             	test   %eax,(%edx,%ecx,4)
		return 1;
  80080f:	0f 95 c0             	setne  %al
  800812:	eb 05                	jmp    800819 <block_is_free+0x37>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 14             	sub    $0x14,%esp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	75 1c                	jne    800845 <free_block+0x2a>
		panic("attempt to free zero block");
  800829:	c7 44 24 08 65 44 80 	movl   $0x804465,0x8(%esp)
  800830:	00 
  800831:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800838:	00 
  800839:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  800840:	e8 0e 14 00 00       	call   801c53 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800845:	89 ca                	mov    %ecx,%edx
  800847:	c1 ea 05             	shr    $0x5,%edx
  80084a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80084f:	bb 01 00 00 00       	mov    $0x1,%ebx
  800854:	d3 e3                	shl    %cl,%ebx
  800856:	09 1c 90             	or     %ebx,(%eax,%edx,4)
}
  800859:	83 c4 14             	add    $0x14,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	83 ec 1c             	sub    $0x1c,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	for(uint32_t i = 0; i < (super->s_nblocks/32); i++) { //works only if super->s_blocks is a multiple of 32
  800868:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80086d:	8b 40 04             	mov    0x4(%eax),%eax
  800870:	c1 e8 05             	shr    $0x5,%eax
  800873:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800876:	8b 3d 08 a0 80 00    	mov    0x80a008,%edi
  80087c:	be 00 00 00 00       	mov    $0x0,%esi
		for(int j = 0; j < 32; j++) {
			if(bitmap[i] & (1<<j)) {
  800881:	ba 01 00 00 00       	mov    $0x1,%edx
alloc_block(void)
{
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	for(uint32_t i = 0; i < (super->s_nblocks/32); i++) { //works only if super->s_blocks is a multiple of 32
  800886:	eb 3b                	jmp    8008c3 <alloc_block+0x64>
		for(int j = 0; j < 32; j++) {
			if(bitmap[i] & (1<<j)) {
  800888:	89 d3                	mov    %edx,%ebx
  80088a:	d3 e3                	shl    %cl,%ebx
  80088c:	85 c3                	test   %eax,%ebx
  80088e:	74 25                	je     8008b5 <alloc_block+0x56>
  800890:	89 cf                	mov    %ecx,%edi
  800892:	89 d9                	mov    %ebx,%ecx
  800894:	89 fb                	mov    %edi,%ebx
				bitmap[i] &= ~(1<<j);
  800896:	f7 d1                	not    %ecx
  800898:	21 c8                	and    %ecx,%eax
  80089a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80089d:	89 07                	mov    %eax,(%edi)
				flush_block(bitmap);
  80089f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	e8 e2 fb ff ff       	call   80048e <flush_block>
				return i*32+j;
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	c1 e0 05             	shl    $0x5,%eax
  8008b1:	01 d8                	add    %ebx,%eax
  8008b3:	eb 24                	jmp    8008d9 <alloc_block+0x7a>
{
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	for(uint32_t i = 0; i < (super->s_nblocks/32); i++) { //works only if super->s_blocks is a multiple of 32
		for(int j = 0; j < 32; j++) {
  8008b5:	83 c1 01             	add    $0x1,%ecx
  8008b8:	83 f9 20             	cmp    $0x20,%ecx
  8008bb:	75 cb                	jne    800888 <alloc_block+0x29>
alloc_block(void)
{
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	for(uint32_t i = 0; i < (super->s_nblocks/32); i++) { //works only if super->s_blocks is a multiple of 32
  8008bd:	83 c6 01             	add    $0x1,%esi
  8008c0:	83 c7 04             	add    $0x4,%edi
  8008c3:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  8008c6:	74 0c                	je     8008d4 <alloc_block+0x75>
		for(int j = 0; j < 32; j++) {
			if(bitmap[i] & (1<<j)) {
  8008c8:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008cb:	8b 07                	mov    (%edi),%eax
  8008cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d2:	eb b4                	jmp    800888 <alloc_block+0x29>
				return i*32+j;
			}
		}
	}

	return -E_NO_DISK;
  8008d4:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008d9:	83 c4 1c             	add    $0x1c,%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	57                   	push   %edi
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	83 ec 0c             	sub    $0xc,%esp
  8008ea:	89 c6                	mov    %eax,%esi
  8008ec:	89 d3                	mov    %edx,%ebx
  8008ee:	89 cf                	mov    %ecx,%edi
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 5: Your code here.
	if(filebno < NDIRECT) {
  8008f3:	83 fa 09             	cmp    $0x9,%edx
  8008f6:	77 10                	ja     800908 <file_block_walk+0x27>
		*ppdiskbno = &f->f_direct[filebno];
  8008f8:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  8008ff:	89 01                	mov    %eax,(%ecx)
		addr = addr + (filebno - NDIRECT);
		*ppdiskbno = addr;
	} else {
		return -E_INVAL;
	}
	return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	eb 52                	jmp    80095a <file_block_walk+0x79>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	if(filebno < NDIRECT) {
		*ppdiskbno = &f->f_direct[filebno];
	} else if (filebno < (NDIRECT + NINDIRECT)) {
  800908:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80090e:	77 37                	ja     800947 <file_block_walk+0x66>
		if(f->f_indirect == 0) {
  800910:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800917:	75 13                	jne    80092c <file_block_walk+0x4b>
			if(alloc) {
  800919:	84 c0                	test   %al,%al
  80091b:	74 31                	je     80094e <file_block_walk+0x6d>
				int bno;
				if((bno = alloc_block()) < 0) return -E_NO_DISK;
  80091d:	e8 3d ff ff ff       	call   80085f <alloc_block>
  800922:	85 c0                	test   %eax,%eax
  800924:	78 2f                	js     800955 <file_block_walk+0x74>
				f->f_indirect = bno;
  800926:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			} else {
				return -E_NOT_FOUND;
			}
		}
		uint32_t* addr = (uint32_t*)(DISKMAP + (f->f_indirect * BLKSIZE));
  80092c:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800932:	05 00 00 01 00       	add    $0x10000,%eax
  800937:	c1 e0 0c             	shl    $0xc,%eax
		addr = addr + (filebno - NDIRECT);
  80093a:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80093e:	89 07                	mov    %eax,(%edi)
		*ppdiskbno = addr;
	} else {
		return -E_INVAL;
	}
	return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb 13                	jmp    80095a <file_block_walk+0x79>
		}
		uint32_t* addr = (uint32_t*)(DISKMAP + (f->f_indirect * BLKSIZE));
		addr = addr + (filebno - NDIRECT);
		*ppdiskbno = addr;
	} else {
		return -E_INVAL;
  800947:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80094c:	eb 0c                	jmp    80095a <file_block_walk+0x79>
			if(alloc) {
				int bno;
				if((bno = alloc_block()) < 0) return -E_NO_DISK;
				f->f_indirect = bno;
			} else {
				return -E_NOT_FOUND;
  80094e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800953:	eb 05                	jmp    80095a <file_block_walk+0x79>
		*ppdiskbno = &f->f_direct[filebno];
	} else if (filebno < (NDIRECT + NINDIRECT)) {
		if(f->f_indirect == 0) {
			if(alloc) {
				int bno;
				if((bno = alloc_block()) < 0) return -E_NO_DISK;
  800955:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*ppdiskbno = addr;
	} else {
		return -E_INVAL;
	}
	return 0;
}
  80095a:	83 c4 0c             	add    $0xc,%esp
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80096a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80096f:	8b 70 04             	mov    0x4(%eax),%esi
  800972:	bb 00 00 00 00       	mov    $0x0,%ebx
  800977:	eb 36                	jmp    8009af <check_bitmap+0x4d>
  800979:	8d 43 02             	lea    0x2(%ebx),%eax
		assert(!block_is_free(2+i));
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	e8 5e fe ff ff       	call   8007e2 <block_is_free>
  800984:	84 c0                	test   %al,%al
  800986:	74 24                	je     8009ac <check_bitmap+0x4a>
  800988:	c7 44 24 0c 80 44 80 	movl   $0x804480,0xc(%esp)
  80098f:	00 
  800990:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800997:	00 
  800998:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  80099f:	00 
  8009a0:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  8009a7:	e8 a7 12 00 00       	call   801c53 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009ac:	83 c3 01             	add    $0x1,%ebx
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	c1 e0 0f             	shl    $0xf,%eax
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	77 c1                	ja     800979 <check_bitmap+0x17>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009bf:	e8 1e fe ff ff       	call   8007e2 <block_is_free>
  8009c4:	84 c0                	test   %al,%al
  8009c6:	74 24                	je     8009ec <check_bitmap+0x8a>
  8009c8:	c7 44 24 0c 94 44 80 	movl   $0x804494,0xc(%esp)
  8009cf:	00 
  8009d0:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8009d7:	00 
  8009d8:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8009df:	00 
  8009e0:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  8009e7:	e8 67 12 00 00       	call   801c53 <_panic>
	assert(!block_is_free(1));
  8009ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009f3:	e8 ea fd ff ff       	call   8007e2 <block_is_free>
  8009f8:	84 c0                	test   %al,%al
  8009fa:	74 24                	je     800a20 <check_bitmap+0xbe>
  8009fc:	c7 44 24 0c a6 44 80 	movl   $0x8044a6,0xc(%esp)
  800a03:	00 
  800a04:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800a0b:	00 
  800a0c:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  800a13:	00 
  800a14:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  800a1b:	e8 33 12 00 00       	call   801c53 <_panic>

	cprintf("bitmap is good\n");
  800a20:	c7 04 24 b8 44 80 00 	movl   $0x8044b8,(%esp)
  800a27:	e8 20 13 00 00       	call   801d4c <cprintf>
}
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a39:	e8 21 f6 ff ff       	call   80005f <ide_probe_disk1>
  800a3e:	84 c0                	test   %al,%al
  800a40:	74 0e                	je     800a50 <fs_init+0x1d>
		ide_set_disk(1);
  800a42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a49:	e8 75 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a4e:	eb 0c                	jmp    800a5c <fs_init+0x29>
	else
		ide_set_disk(0);
  800a50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a57:	e8 67 f6 ff ff       	call   8000c3 <ide_set_disk>
	bc_init();
  800a5c:	e8 26 fb ff ff       	call   800587 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a68:	e8 7d f9 ff ff       	call   8003ea <diskaddr>
  800a6d:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800a72:	e8 09 fd ff ff       	call   800780 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a7e:	e8 67 f9 ff ff       	call   8003ea <diskaddr>
  800a83:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800a88:	e8 d5 fe ff ff       	call   800962 <check_bitmap>
	
}
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 24             	sub    $0x24,%esp
	uint32_t *ppdiskbno;
	int r;
	if((r = file_block_walk(f, filebno, &ppdiskbno, true)) < 0 ) {
  800a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	e8 36 fe ff ff       	call   8008e1 <file_block_walk>
  800aab:	89 c3                	mov    %eax,%ebx
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	79 14                	jns    800ac5 <file_get_block+0x36>
       cprintf("file_block_walk failed in file_get_block: %e", r);
  800ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab5:	c7 04 24 04 45 80 00 	movl   $0x804504,(%esp)
  800abc:	e8 8b 12 00 00       	call   801d4c <cprintf>
	   return r;
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	eb 35                	jmp    800afa <file_get_block+0x6b>
	}

	if(*ppdiskbno == 0) {
  800ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac8:	83 38 00             	cmpl   $0x0,(%eax)
  800acb:	75 0e                	jne    800adb <file_get_block+0x4c>
		int bno; 
		if((bno = alloc_block()) < 0) return -E_NO_DISK;
  800acd:	e8 8d fd ff ff       	call   80085f <alloc_block>
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	78 1f                	js     800af5 <file_get_block+0x66>
		*ppdiskbno = bno;
  800ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad9:	89 02                	mov    %eax,(%edx)
	}

	*blk = (char*)(DISKMAP + (*ppdiskbno * BLKSIZE));
  800adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ade:	8b 10                	mov    (%eax),%edx
  800ae0:	81 c2 00 00 01 00    	add    $0x10000,%edx
  800ae6:	c1 e2 0c             	shl    $0xc,%edx
  800ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  800aec:	89 10                	mov    %edx,(%eax)
	return 0;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	eb 05                	jmp    800afa <file_get_block+0x6b>
	   return r;
	}

	if(*ppdiskbno == 0) {
		int bno; 
		if((bno = alloc_block()) < 0) return -E_NO_DISK;
  800af5:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*ppdiskbno = bno;
	}

	*blk = (char*)(DISKMAP + (*ppdiskbno * BLKSIZE));
	return 0;
}
  800afa:	83 c4 24             	add    $0x24,%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800b0c:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800b12:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
  800b18:	eb 03                	jmp    800b1d <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b1a:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b1d:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b20:	74 f8                	je     800b1a <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b22:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800b28:	83 c1 08             	add    $0x8,%ecx
  800b2b:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800b31:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b38:	8b 8d 44 ff ff ff    	mov    -0xbc(%ebp),%ecx
  800b3e:	85 c9                	test   %ecx,%ecx
  800b40:	74 06                	je     800b48 <walk_path+0x48>
		*pdir = 0;
  800b42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b48:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b4e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b59:	e9 71 01 00 00       	jmp    800ccf <walk_path+0x1cf>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b5e:	83 c7 01             	add    $0x1,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b61:	0f b6 17             	movzbl (%edi),%edx
  800b64:	84 d2                	test   %dl,%dl
  800b66:	74 05                	je     800b6d <walk_path+0x6d>
  800b68:	80 fa 2f             	cmp    $0x2f,%dl
  800b6b:	75 f1                	jne    800b5e <walk_path+0x5e>
			path++;
		if (path - p >= MAXNAMELEN)
  800b6d:	89 fb                	mov    %edi,%ebx
  800b6f:	29 c3                	sub    %eax,%ebx
  800b71:	83 fb 7f             	cmp    $0x7f,%ebx
  800b74:	0f 8f 82 01 00 00    	jg     800cfc <walk_path+0x1fc>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b82:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	e8 84 19 00 00       	call   802514 <memmove>
		name[path - p] = '\0';
  800b90:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b97:	00 
  800b98:	eb 03                	jmp    800b9d <walk_path+0x9d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b9a:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b9d:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800ba0:	74 f8                	je     800b9a <walk_path+0x9a>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800ba2:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800ba8:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800baf:	0f 85 4e 01 00 00    	jne    800d03 <walk_path+0x203>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bb5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bbb:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bc0:	74 24                	je     800be6 <walk_path+0xe6>
  800bc2:	c7 44 24 0c c8 44 80 	movl   $0x8044c8,0xc(%esp)
  800bc9:	00 
  800bca:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800bd1:	00 
  800bd2:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  800bd9:	00 
  800bda:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  800be1:	e8 6d 10 00 00       	call   801c53 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800be6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bec:	85 c0                	test   %eax,%eax
  800bee:	0f 48 c2             	cmovs  %edx,%eax
  800bf1:	c1 f8 0c             	sar    $0xc,%eax
  800bf4:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	for (i = 0; i < nblock; i++) {
  800bfa:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800c01:	00 00 00 
  800c04:	89 bd 48 ff ff ff    	mov    %edi,-0xb8(%ebp)
  800c0a:	eb 61                	jmp    800c6d <walk_path+0x16d>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c0c:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c12:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c16:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c20:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 61 fe ff ff       	call   800a8f <file_get_block>
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	0f 88 ea 00 00 00    	js     800d20 <walk_path+0x220>
  800c36:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
			return r;
		f = (struct File*) blk;
  800c3c:	be 10 00 00 00       	mov    $0x10,%esi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c41:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4b:	89 1c 24             	mov    %ebx,(%esp)
  800c4e:	e8 d9 17 00 00       	call   80242c <strcmp>
  800c53:	85 c0                	test   %eax,%eax
  800c55:	0f 84 af 00 00 00    	je     800d0a <walk_path+0x20a>
  800c5b:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c61:	83 ee 01             	sub    $0x1,%esi
  800c64:	75 db                	jne    800c41 <walk_path+0x141>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c66:	83 85 54 ff ff ff 01 	addl   $0x1,-0xac(%ebp)
  800c6d:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c73:	39 85 4c ff ff ff    	cmp    %eax,-0xb4(%ebp)
  800c79:	75 91                	jne    800c0c <walk_path+0x10c>
  800c7b:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c81:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c86:	80 3f 00             	cmpb   $0x0,(%edi)
  800c89:	0f 85 a0 00 00 00    	jne    800d2f <walk_path+0x22f>
				if (pdir)
  800c8f:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800c95:	85 c0                	test   %eax,%eax
  800c97:	74 08                	je     800ca1 <walk_path+0x1a1>
					*pdir = dir;
  800c99:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c9f:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ca1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ca5:	74 15                	je     800cbc <walk_path+0x1bc>
					strcpy(lastelem, name);
  800ca7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800cad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	89 04 24             	mov    %eax,(%esp)
  800cb7:	e8 bb 16 00 00       	call   802377 <strcpy>
				*pf = 0;
  800cbc:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cc8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ccd:	eb 60                	jmp    800d2f <walk_path+0x22f>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800ccf:	80 38 00             	cmpb   $0x0,(%eax)
  800cd2:	74 07                	je     800cdb <walk_path+0x1db>
  800cd4:	89 c7                	mov    %eax,%edi
  800cd6:	e9 86 fe ff ff       	jmp    800b61 <walk_path+0x61>
			}
			return r;
		}
	}

	if (pdir)
  800cdb:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 02                	je     800ce7 <walk_path+0x1e7>
		*pdir = dir;
  800ce5:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ce7:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ced:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800cf3:	89 08                	mov    %ecx,(%eax)
	return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	eb 33                	jmp    800d2f <walk_path+0x22f>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800cfc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d01:	eb 2c                	jmp    800d2f <walk_path+0x22f>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800d03:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d08:	eb 25                	jmp    800d2f <walk_path+0x22f>
  800d0a:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
  800d10:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d16:	89 9d 50 ff ff ff    	mov    %ebx,-0xb0(%ebp)
  800d1c:	89 f8                	mov    %edi,%eax
  800d1e:	eb af                	jmp    800ccf <walk_path+0x1cf>
  800d20:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d26:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d29:	0f 84 52 ff ff ff    	je     800c81 <walk_path+0x181>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d2f:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	e8 a9 fd ff ff       	call   800b00 <walk_path>
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 3c             	sub    $0x3c,%esp
  800d62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d65:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
		return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d76:	39 d1                	cmp    %edx,%ecx
  800d78:	0f 8e 83 00 00 00    	jle    800e01 <file_read+0xa8>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d7e:	29 d1                	sub    %edx,%ecx
  800d80:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d83:	0f 47 4d 10          	cmova  0x10(%ebp),%ecx
  800d87:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d8a:	89 d3                	mov    %edx,%ebx
  800d8c:	01 ca                	add    %ecx,%edx
  800d8e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800d91:	eb 64                	jmp    800df7 <file_read+0x9e>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9a:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800da0:	85 db                	test   %ebx,%ebx
  800da2:	0f 49 c3             	cmovns %ebx,%eax
  800da5:	c1 f8 0c             	sar    $0xc,%eax
  800da8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	89 04 24             	mov    %eax,(%esp)
  800db2:	e8 d8 fc ff ff       	call   800a8f <file_get_block>
  800db7:	85 c0                	test   %eax,%eax
  800db9:	78 46                	js     800e01 <file_read+0xa8>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dbb:	89 da                	mov    %ebx,%edx
  800dbd:	c1 fa 1f             	sar    $0x1f,%edx
  800dc0:	c1 ea 14             	shr    $0x14,%edx
  800dc3:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800dc6:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dcb:	29 d0                	sub    %edx,%eax
  800dcd:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800dd2:	29 c1                	sub    %eax,%ecx
  800dd4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dd7:	29 f2                	sub    %esi,%edx
  800dd9:	39 d1                	cmp    %edx,%ecx
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800de0:	89 74 24 08          	mov    %esi,0x8(%esp)
  800de4:	03 45 e4             	add    -0x1c(%ebp),%eax
  800de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800deb:	89 3c 24             	mov    %edi,(%esp)
  800dee:	e8 21 17 00 00       	call   802514 <memmove>
		pos += bn;
  800df3:	01 f3                	add    %esi,%ebx
		buf += bn;
  800df5:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800dfc:	72 95                	jb     800d93 <file_read+0x3a>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800dfe:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e01:	83 c4 3c             	add    $0x3c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 2c             	sub    $0x2c,%esp
  800e12:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e15:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e1b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e1e:	0f 8e 9a 00 00 00    	jle    800ebe <file_set_size+0xb5>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e24:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e2a:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e2f:	0f 49 f8             	cmovns %eax,%edi
  800e32:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e38:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800e3e:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e43:	0f 48 c2             	cmovs  %edx,%eax
  800e46:	c1 f8 0c             	sar    $0xc,%eax
  800e49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e4c:	89 c3                	mov    %eax,%ebx
  800e4e:	eb 34                	jmp    800e84 <file_set_size+0x7b>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e57:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e5a:	89 da                	mov    %ebx,%edx
  800e5c:	89 f0                	mov    %esi,%eax
  800e5e:	e8 7e fa ff ff       	call   8008e1 <file_block_walk>
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 45                	js     800eac <file_set_size+0xa3>
		return r;
	if (*ptr) {
  800e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e6a:	8b 00                	mov    (%eax),%eax
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	74 11                	je     800e81 <file_set_size+0x78>
		free_block(*ptr);
  800e70:	89 04 24             	mov    %eax,(%esp)
  800e73:	e8 a3 f9 ff ff       	call   80081b <free_block>
		*ptr = 0;
  800e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e81:	83 c3 01             	add    $0x1,%ebx
  800e84:	39 df                	cmp    %ebx,%edi
  800e86:	77 c8                	ja     800e50 <file_set_size+0x47>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e88:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e8c:	77 30                	ja     800ebe <file_set_size+0xb5>
  800e8e:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e94:	85 c0                	test   %eax,%eax
  800e96:	74 26                	je     800ebe <file_set_size+0xb5>
		free_block(f->f_indirect);
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	e8 7b f9 ff ff       	call   80081b <free_block>
		f->f_indirect = 0;
  800ea0:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800ea7:	00 00 00 
  800eaa:	eb 12                	jmp    800ebe <file_set_size+0xb5>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800eac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb0:	c7 04 24 e5 44 80 00 	movl   $0x8044e5,(%esp)
  800eb7:	e8 90 0e 00 00       	call   801d4c <cprintf>
  800ebc:	eb c3                	jmp    800e81 <file_set_size+0x78>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800ec7:	89 34 24             	mov    %esi,(%esp)
  800eca:	e8 bf f5 ff ff       	call   80048e <flush_block>
	return 0;
}
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	83 c4 2c             	add    $0x2c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 2c             	sub    $0x2c,%esp
  800ee5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ee8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800eeb:	89 d8                	mov    %ebx,%eax
  800eed:	03 45 10             	add    0x10(%ebp),%eax
  800ef0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800efc:	76 7c                	jbe    800f7a <file_write+0x9e>
		if ((r = file_set_size(f, offset + count)) < 0)
  800efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	89 04 24             	mov    %eax,(%esp)
  800f0b:	e8 f9 fe ff ff       	call   800e09 <file_set_size>
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 66                	jns    800f7a <file_write+0x9e>
  800f14:	eb 6e                	jmp    800f84 <file_write+0xa8>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1d:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f23:	85 db                	test   %ebx,%ebx
  800f25:	0f 49 c3             	cmovns %ebx,%eax
  800f28:	c1 f8 0c             	sar    $0xc,%eax
  800f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	89 04 24             	mov    %eax,(%esp)
  800f35:	e8 55 fb ff ff       	call   800a8f <file_get_block>
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 46                	js     800f84 <file_write+0xa8>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f3e:	89 da                	mov    %ebx,%edx
  800f40:	c1 fa 1f             	sar    $0x1f,%edx
  800f43:	c1 ea 14             	shr    $0x14,%edx
  800f46:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800f49:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f4e:	29 d0                	sub    %edx,%eax
  800f50:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f55:	29 c1                	sub    %eax,%ecx
  800f57:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f5a:	29 f2                	sub    %esi,%edx
  800f5c:	39 d1                	cmp    %edx,%ecx
  800f5e:	89 d6                	mov    %edx,%esi
  800f60:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f63:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f6b:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f6e:	89 04 24             	mov    %eax,(%esp)
  800f71:	e8 9e 15 00 00       	call   802514 <memmove>
		pos += bn;
  800f76:	01 f3                	add    %esi,%ebx
		buf += bn;
  800f78:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800f7f:	77 95                	ja     800f16 <file_write+0x3a>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f81:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f84:	83 c4 2c             	add    $0x2c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 20             	sub    $0x20,%esp
  800f94:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9c:	eb 37                	jmp    800fd5 <file_flush+0x49>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fa8:	89 da                	mov    %ebx,%edx
  800faa:	89 f0                	mov    %esi,%eax
  800fac:	e8 30 f9 ff ff       	call   8008e1 <file_block_walk>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 1d                	js     800fd2 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	74 16                	je     800fd2 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fbc:	8b 00                	mov    (%eax),%eax
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	74 10                	je     800fd2 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	e8 20 f4 ff ff       	call   8003ea <diskaddr>
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	e8 bc f4 ff ff       	call   80048e <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fd2:	83 c3 01             	add    $0x1,%ebx
  800fd5:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fdb:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800fe1:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fe7:	85 c9                	test   %ecx,%ecx
  800fe9:	0f 49 c1             	cmovns %ecx,%eax
  800fec:	c1 f8 0c             	sar    $0xc,%eax
  800fef:	39 c3                	cmp    %eax,%ebx
  800ff1:	7c ab                	jl     800f9e <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800ff3:	89 34 24             	mov    %esi,(%esp)
  800ff6:	e8 93 f4 ff ff       	call   80048e <flush_block>
	if (f->f_indirect)
  800ffb:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801001:	85 c0                	test   %eax,%eax
  801003:	74 10                	je     801015 <file_flush+0x89>
		flush_block(diskaddr(f->f_indirect));
  801005:	89 04 24             	mov    %eax,(%esp)
  801008:	e8 dd f3 ff ff       	call   8003ea <diskaddr>
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 79 f4 ff ff       	call   80048e <flush_block>
}
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801028:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80102e:	89 04 24             	mov    %eax,(%esp)
  801031:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801037:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	e8 bb fa ff ff       	call   800b00 <walk_path>
  801045:	89 c2                	mov    %eax,%edx
  801047:	85 c0                	test   %eax,%eax
  801049:	0f 84 e0 00 00 00    	je     80112f <file_create+0x113>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80104f:	83 fa f5             	cmp    $0xfffffff5,%edx
  801052:	0f 85 1b 01 00 00    	jne    801173 <file_create+0x157>
  801058:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80105e:	85 f6                	test   %esi,%esi
  801060:	0f 84 d0 00 00 00    	je     801136 <file_create+0x11a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801066:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  80106c:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801071:	74 24                	je     801097 <file_create+0x7b>
  801073:	c7 44 24 0c c8 44 80 	movl   $0x8044c8,0xc(%esp)
  80107a:	00 
  80107b:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801082:	00 
  801083:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 30 44 80 00 	movl   $0x804430,(%esp)
  801092:	e8 bc 0b 00 00       	call   801c53 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801097:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80109d:	85 c0                	test   %eax,%eax
  80109f:	0f 48 c2             	cmovs  %edx,%eax
  8010a2:	c1 f8 0c             	sar    $0xc,%eax
  8010a5:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8010ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010b0:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8010b6:	eb 3d                	jmp    8010f5 <file_create+0xd9>
  8010b8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c0:	89 34 24             	mov    %esi,(%esp)
  8010c3:	e8 c7 f9 ff ff       	call   800a8f <file_get_block>
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	0f 88 a3 00 00 00    	js     801173 <file_create+0x157>
  8010d0:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			return r;
		f = (struct File*) blk;
  8010d6:	ba 10 00 00 00       	mov    $0x10,%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010db:	80 38 00             	cmpb   $0x0,(%eax)
  8010de:	75 08                	jne    8010e8 <file_create+0xcc>
				*file = &f[j];
  8010e0:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010e6:	eb 55                	jmp    80113d <file_create+0x121>
  8010e8:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010ed:	83 ea 01             	sub    $0x1,%edx
  8010f0:	75 e9                	jne    8010db <file_create+0xbf>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010f2:	83 c3 01             	add    $0x1,%ebx
  8010f5:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8010fb:	75 bb                	jne    8010b8 <file_create+0x9c>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010fd:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801104:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801107:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80110d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801111:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801115:	89 34 24             	mov    %esi,(%esp)
  801118:	e8 72 f9 ff ff       	call   800a8f <file_get_block>
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 52                	js     801173 <file_create+0x157>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801121:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801127:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80112d:	eb 0e                	jmp    80113d <file_create+0x121>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80112f:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801134:	eb 3d                	jmp    801173 <file_create+0x157>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801136:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80113b:	eb 36                	jmp    801173 <file_create+0x157>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80113d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801143:	89 44 24 04          	mov    %eax,0x4(%esp)
  801147:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  80114d:	89 04 24             	mov    %eax,(%esp)
  801150:	e8 22 12 00 00       	call   802377 <strcpy>
	*pf = f;
  801155:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80115b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115e:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801160:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801166:	89 04 24             	mov    %eax,(%esp)
  801169:	e8 1e fe ff ff       	call   800f8c <file_flush>
	return 0;
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801173:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	53                   	push   %ebx
  801182:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801185:	bb 01 00 00 00       	mov    $0x1,%ebx
  80118a:	eb 13                	jmp    80119f <fs_sync+0x21>
		flush_block(diskaddr(i));
  80118c:	89 1c 24             	mov    %ebx,(%esp)
  80118f:	e8 56 f2 ff ff       	call   8003ea <diskaddr>
  801194:	89 04 24             	mov    %eax,(%esp)
  801197:	e8 f2 f2 ff ff       	call   80048e <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80119c:	83 c3 01             	add    $0x1,%ebx
  80119f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8011a4:	3b 58 04             	cmp    0x4(%eax),%ebx
  8011a7:	72 e3                	jb     80118c <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8011a9:	83 c4 14             	add    $0x14,%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    
  8011af:	90                   	nop

008011b0 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011b6:	e8 c3 ff ff ff       	call   80117e <fs_sync>
	return 0;
}
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8011ca:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011d4:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011d6:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011d9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011df:	83 c0 01             	add    $0x1,%eax
  8011e2:	83 c2 10             	add    $0x10,%edx
  8011e5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ea:	75 e8                	jne    8011d4 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 10             	sub    $0x10,%esp
  8011f6:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fe:	89 d8                	mov    %ebx,%eax
  801200:	c1 e0 04             	shl    $0x4,%eax
		switch (pageref(opentab[i].o_fd)) {
  801203:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 cd 22 00 00       	call   8034de <pageref>
  801211:	85 c0                	test   %eax,%eax
  801213:	74 0d                	je     801222 <openfile_alloc+0x34>
  801215:	83 f8 01             	cmp    $0x1,%eax
  801218:	74 31                	je     80124b <openfile_alloc+0x5d>
  80121a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801220:	eb 62                	jmp    801284 <openfile_alloc+0x96>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801222:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801229:	00 
  80122a:	89 d8                	mov    %ebx,%eax
  80122c:	c1 e0 04             	shl    $0x4,%eax
  80122f:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801235:	89 44 24 04          	mov    %eax,0x4(%esp)
  801239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801240:	e8 4e 15 00 00       	call   802793 <sys_page_alloc>
  801245:	89 c2                	mov    %eax,%edx
  801247:	85 d2                	test   %edx,%edx
  801249:	78 4d                	js     801298 <openfile_alloc+0xaa>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80124b:	c1 e3 04             	shl    $0x4,%ebx
  80124e:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801254:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80125b:	04 00 00 
			*o = &opentab[i];
  80125e:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801260:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80126f:	00 
  801270:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 49 12 00 00       	call   8024c7 <memset>
			return (*o)->o_fileid;
  80127e:	8b 06                	mov    (%esi),%eax
  801280:	8b 00                	mov    (%eax),%eax
  801282:	eb 14                	jmp    801298 <openfile_alloc+0xaa>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801284:	83 c3 01             	add    $0x1,%ebx
  801287:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80128d:	0f 85 6b ff ff ff    	jne    8011fe <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801293:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 1c             	sub    $0x1c,%esp
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8012ab:	89 de                	mov    %ebx,%esi
  8012ad:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8012b3:	c1 e6 04             	shl    $0x4,%esi
  8012b6:	8d be 60 50 80 00    	lea    0x805060(%esi),%edi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012bc:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  8012c2:	89 04 24             	mov    %eax,(%esp)
  8012c5:	e8 14 22 00 00       	call   8034de <pageref>
  8012ca:	83 f8 01             	cmp    $0x1,%eax
  8012cd:	7e 14                	jle    8012e3 <openfile_lookup+0x44>
  8012cf:	39 9e 60 50 80 00    	cmp    %ebx,0x805060(%esi)
  8012d5:	75 13                	jne    8012ea <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  8012d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8012da:	89 38                	mov    %edi,(%eax)
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e1:	eb 0c                	jmp    8012ef <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb 05                	jmp    8012ef <openfile_lookup+0x50>
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012ef:	83 c4 1c             	add    $0x1c,%esp
  8012f2:	5b                   	pop    %ebx
  8012f3:	5e                   	pop    %esi
  8012f4:	5f                   	pop    %edi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 24             	sub    $0x24,%esp
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	89 44 24 08          	mov    %eax,0x8(%esp)
  801308:	8b 03                	mov    (%ebx),%eax
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	89 04 24             	mov    %eax,(%esp)
  801314:	e8 86 ff ff ff       	call   80129f <openfile_lookup>
  801319:	89 c2                	mov    %eax,%edx
  80131b:	85 d2                	test   %edx,%edx
  80131d:	78 15                	js     801334 <serve_set_size+0x3d>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  80131f:	8b 43 04             	mov    0x4(%ebx),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	8b 40 04             	mov    0x4(%eax),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 d5 fa ff ff       	call   800e09 <file_set_size>
}
  801334:	83 c4 24             	add    $0x24,%esp
  801337:	5b                   	pop    %ebx
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 24             	sub    $0x24,%esp
  801341:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134b:	8b 03                	mov    (%ebx),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	89 04 24             	mov    %eax,(%esp)
  801357:	e8 43 ff ff ff       	call   80129f <openfile_lookup>
		return r;
  80135c:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 34                	js     801396 <serve_read+0x5c>
		return r;

	if((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) >= 0) {
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	8b 50 0c             	mov    0xc(%eax),%edx
  801368:	8b 52 04             	mov    0x4(%edx),%edx
  80136b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136f:	8b 53 04             	mov    0x4(%ebx),%edx
  801372:	89 54 24 08          	mov    %edx,0x8(%esp)
  801376:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80137a:	8b 40 04             	mov    0x4(%eax),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 d4 f9 ff ff       	call   800d59 <file_read>
		o->o_fd->fd_offset += r;
	}

	return r;
  801385:	89 c2                	mov    %eax,%edx
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) >= 0) {
  801387:	85 c0                	test   %eax,%eax
  801389:	78 0b                	js     801396 <serve_read+0x5c>
		o->o_fd->fd_offset += r;
  80138b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138e:	8b 52 0c             	mov    0xc(%edx),%edx
  801391:	01 42 04             	add    %eax,0x4(%edx)
	}

	return r;
  801394:	89 c2                	mov    %eax,%edx
}
  801396:	89 d0                	mov    %edx,%eax
  801398:	83 c4 24             	add    $0x24,%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 24             	sub    $0x24,%esp
  8013a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013af:	8b 03                	mov    (%ebx),%eax
  8013b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b8:	89 04 24             	mov    %eax,(%esp)
  8013bb:	e8 df fe ff ff       	call   80129f <openfile_lookup>
		return r;
  8013c0:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 37                	js     8013fd <serve_write+0x5f>
		return r;

	if((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) >= 0) {
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	8b 50 0c             	mov    0xc(%eax),%edx
  8013cc:	8b 52 04             	mov    0x4(%edx),%edx
  8013cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013d3:	8b 53 04             	mov    0x4(%ebx),%edx
  8013d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013da:	83 c3 08             	add    $0x8,%ebx
  8013dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e1:	8b 40 04             	mov    0x4(%eax),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 f0 fa ff ff       	call   800edc <file_write>
		o->o_fd->fd_offset += r;
	}

	return r;
  8013ec:	89 c2                	mov    %eax,%edx
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) >= 0) {
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 0b                	js     8013fd <serve_write+0x5f>
		o->o_fd->fd_offset += r;
  8013f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f8:	01 42 04             	add    %eax,0x4(%edx)
	}

	return r;
  8013fb:	89 c2                	mov    %eax,%edx
}
  8013fd:	89 d0                	mov    %edx,%eax
  8013ff:	83 c4 24             	add    $0x24,%esp
  801402:	5b                   	pop    %ebx
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 24             	sub    $0x24,%esp
  80140c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80140f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801412:	89 44 24 08          	mov    %eax,0x8(%esp)
  801416:	8b 03                	mov    (%ebx),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 78 fe ff ff       	call   80129f <openfile_lookup>
  801427:	89 c2                	mov    %eax,%edx
  801429:	85 d2                	test   %edx,%edx
  80142b:	78 3f                	js     80146c <serve_stat+0x67>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801430:	8b 40 04             	mov    0x4(%eax),%eax
  801433:	89 44 24 04          	mov    %eax,0x4(%esp)
  801437:	89 1c 24             	mov    %ebx,(%esp)
  80143a:	e8 38 0f 00 00       	call   802377 <strcpy>
	ret->ret_size = o->o_file->f_size;
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	8b 50 04             	mov    0x4(%eax),%edx
  801445:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  80144b:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801451:	8b 40 04             	mov    0x4(%eax),%eax
  801454:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80145b:	0f 94 c0             	sete   %al
  80145e:	0f b6 c0             	movzbl %al,%eax
  801461:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146c:	83 c4 24             	add    $0x24,%esp
  80146f:	5b                   	pop    %ebx
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	8b 00                	mov    (%eax),%eax
  801484:	89 44 24 04          	mov    %eax,0x4(%esp)
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	89 04 24             	mov    %eax,(%esp)
  80148e:	e8 0c fe ff ff       	call   80129f <openfile_lookup>
  801493:	89 c2                	mov    %eax,%edx
  801495:	85 d2                	test   %edx,%edx
  801497:	78 13                	js     8014ac <serve_flush+0x3a>
		return r;
	file_flush(o->o_file);
  801499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149c:	8b 40 04             	mov    0x4(%eax),%eax
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 e5 fa ff ff       	call   800f8c <file_flush>
	return 0;
  8014a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	81 ec 24 04 00 00    	sub    $0x424,%esp
  8014b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8014bb:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  8014c2:	00 
  8014c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014cd:	89 04 24             	mov    %eax,(%esp)
  8014d0:	e8 3f 10 00 00       	call   802514 <memmove>
	path[MAXPATHLEN-1] = 0;
  8014d5:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8014d9:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 07 fd ff ff       	call   8011ee <openfile_alloc>
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	0f 88 f2 00 00 00    	js     8015e1 <serve_open+0x133>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8014ef:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8014f6:	74 34                	je     80152c <serve_open+0x7e>
		if ((r = file_create(path, &f)) < 0) {
  8014f8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801502:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801508:	89 04 24             	mov    %eax,(%esp)
  80150b:	e8 0c fb ff ff       	call   80101c <file_create>
  801510:	89 c2                	mov    %eax,%edx
  801512:	85 c0                	test   %eax,%eax
  801514:	79 36                	jns    80154c <serve_open+0x9e>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801516:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80151d:	0f 85 be 00 00 00    	jne    8015e1 <serve_open+0x133>
  801523:	83 fa f3             	cmp    $0xfffffff3,%edx
  801526:	0f 85 b5 00 00 00    	jne    8015e1 <serve_open+0x133>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80152c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801532:	89 44 24 04          	mov    %eax,0x4(%esp)
  801536:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 f6 f7 ff ff       	call   800d3a <file_open>
  801544:	85 c0                	test   %eax,%eax
  801546:	0f 88 95 00 00 00    	js     8015e1 <serve_open+0x133>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80154c:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801553:	74 1a                	je     80156f <serve_open+0xc1>
		if ((r = file_set_size(f, 0)) < 0) {
  801555:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80155c:	00 
  80155d:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	e8 9e f8 ff ff       	call   800e09 <file_set_size>
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 72                	js     8015e1 <serve_open+0x133>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80156f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801575:	89 44 24 04          	mov    %eax,0x4(%esp)
  801579:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	e8 b3 f7 ff ff       	call   800d3a <file_open>
  801587:	85 c0                	test   %eax,%eax
  801589:	78 56                	js     8015e1 <serve_open+0x133>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80158b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801591:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801597:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80159a:	8b 50 0c             	mov    0xc(%eax),%edx
  80159d:	8b 08                	mov    (%eax),%ecx
  80159f:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015a2:	8b 50 0c             	mov    0xc(%eax),%edx
  8015a5:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  8015ab:	83 e1 03             	and    $0x3,%ecx
  8015ae:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8015b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b4:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8015ba:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8015bc:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015c2:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015c8:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8015cb:	8b 50 0c             	mov    0xc(%eax),%edx
  8015ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d1:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8015d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d6:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e1:	81 c4 24 04 00 00    	add    $0x424,%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015f2:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8015f5:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8015f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801603:	a1 44 50 80 00       	mov    0x805044,%eax
  801608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160c:	89 34 24             	mov    %esi,(%esp)
  80160f:	e8 2c 15 00 00       	call   802b40 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801614:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801618:	75 15                	jne    80162f <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  80161a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	c7 04 24 34 45 80 00 	movl   $0x804534,(%esp)
  801628:	e8 1f 07 00 00       	call   801d4c <cprintf>
				whom);
			continue; // just leave it hanging...
  80162d:	eb c9                	jmp    8015f8 <serve+0xe>
		}

		pg = NULL;
  80162f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801636:	83 f8 01             	cmp    $0x1,%eax
  801639:	75 21                	jne    80165c <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80163b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80163f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801642:	89 44 24 08          	mov    %eax,0x8(%esp)
  801646:	a1 44 50 80 00       	mov    0x805044,%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 54 fe ff ff       	call   8014ae <serve_open>
  80165a:	eb 3f                	jmp    80169b <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  80165c:	83 f8 08             	cmp    $0x8,%eax
  80165f:	77 1e                	ja     80167f <serve+0x95>
  801661:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801668:	85 d2                	test   %edx,%edx
  80166a:	74 13                	je     80167f <serve+0x95>
			r = handlers[req](whom, fsreq);
  80166c:	a1 44 50 80 00       	mov    0x805044,%eax
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	89 04 24             	mov    %eax,(%esp)
  80167b:	ff d2                	call   *%edx
  80167d:	eb 1c                	jmp    80169b <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80167f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801682:	89 54 24 08          	mov    %edx,0x8(%esp)
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	c7 04 24 64 45 80 00 	movl   $0x804564,(%esp)
  801691:	e8 b6 06 00 00       	call   801d4c <cprintf>
			r = -E_INVAL;
  801696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80169b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80169e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8016a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 02 15 00 00       	call   802bba <ipc_send>
		sys_page_unmap(0, fsreq);
  8016b8:	a1 44 50 80 00       	mov    0x805044,%eax
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c8:	e8 6d 11 00 00       	call   80283a <sys_page_unmap>
  8016cd:	e9 26 ff ff ff       	jmp    8015f8 <serve+0xe>

008016d2 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8016d8:	c7 05 60 90 80 00 87 	movl   $0x804587,0x809060
  8016df:	45 80 00 
	cprintf("FS is running\n");
  8016e2:	c7 04 24 8a 45 80 00 	movl   $0x80458a,(%esp)
  8016e9:	e8 5e 06 00 00       	call   801d4c <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8016ee:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8016f3:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8016f8:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8016fa:	c7 04 24 99 45 80 00 	movl   $0x804599,(%esp)
  801701:	e8 46 06 00 00       	call   801d4c <cprintf>

	serve_init();
  801706:	e8 b7 fa ff ff       	call   8011c2 <serve_init>
	fs_init();
  80170b:	e8 23 f3 ff ff       	call   800a33 <fs_init>
	serve();
  801710:	e8 d5 fe ff ff       	call   8015ea <serve>

00801715 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80171c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801723:	00 
  801724:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80172b:	00 
  80172c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801733:	e8 5b 10 00 00       	call   802793 <sys_page_alloc>
  801738:	85 c0                	test   %eax,%eax
  80173a:	79 20                	jns    80175c <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80173c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801740:	c7 44 24 08 a8 45 80 	movl   $0x8045a8,0x8(%esp)
  801747:	00 
  801748:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80174f:	00 
  801750:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801757:	e8 f7 04 00 00       	call   801c53 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80175c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801763:	00 
  801764:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176d:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801774:	e8 9b 0d 00 00       	call   802514 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801779:	e8 e1 f0 ff ff       	call   80085f <alloc_block>
  80177e:	85 c0                	test   %eax,%eax
  801780:	79 20                	jns    8017a2 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801786:	c7 44 24 08 c5 45 80 	movl   $0x8045c5,0x8(%esp)
  80178d:	00 
  80178e:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  801795:	00 
  801796:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  80179d:	e8 b1 04 00 00       	call   801c53 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8017a2:	8d 58 1f             	lea    0x1f(%eax),%ebx
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	0f 49 d8             	cmovns %eax,%ebx
  8017aa:	c1 fb 05             	sar    $0x5,%ebx
  8017ad:	99                   	cltd   
  8017ae:	c1 ea 1b             	shr    $0x1b,%edx
  8017b1:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8017b4:	83 e1 1f             	and    $0x1f,%ecx
  8017b7:	29 d1                	sub    %edx,%ecx
  8017b9:	ba 01 00 00 00       	mov    $0x1,%edx
  8017be:	d3 e2                	shl    %cl,%edx
  8017c0:	85 14 9d 00 10 00 00 	test   %edx,0x1000(,%ebx,4)
  8017c7:	75 24                	jne    8017ed <fs_test+0xd8>
  8017c9:	c7 44 24 0c d5 45 80 	movl   $0x8045d5,0xc(%esp)
  8017d0:	00 
  8017d1:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8017d8:	00 
  8017d9:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  8017e0:	00 
  8017e1:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  8017e8:	e8 66 04 00 00       	call   801c53 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017ed:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8017f2:	85 14 98             	test   %edx,(%eax,%ebx,4)
  8017f5:	74 24                	je     80181b <fs_test+0x106>
  8017f7:	c7 44 24 0c 50 47 80 	movl   $0x804750,0xc(%esp)
  8017fe:	00 
  8017ff:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801806:	00 
  801807:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  80180e:	00 
  80180f:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801816:	e8 38 04 00 00       	call   801c53 <_panic>
	cprintf("alloc_block is good\n");
  80181b:	c7 04 24 f0 45 80 00 	movl   $0x8045f0,(%esp)
  801822:	e8 25 05 00 00       	call   801d4c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	c7 04 24 05 46 80 00 	movl   $0x804605,(%esp)
  801835:	e8 00 f5 ff ff       	call   800d3a <file_open>
  80183a:	85 c0                	test   %eax,%eax
  80183c:	79 25                	jns    801863 <fs_test+0x14e>
  80183e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801841:	74 40                	je     801883 <fs_test+0x16e>
		panic("file_open /not-found: %e", r);
  801843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801847:	c7 44 24 08 10 46 80 	movl   $0x804610,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  80185e:	e8 f0 03 00 00       	call   801c53 <_panic>
	else if (r == 0)
  801863:	85 c0                	test   %eax,%eax
  801865:	75 1c                	jne    801883 <fs_test+0x16e>
		panic("file_open /not-found succeeded!");
  801867:	c7 44 24 08 70 47 80 	movl   $0x804770,0x8(%esp)
  80186e:	00 
  80186f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801876:	00 
  801877:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  80187e:	e8 d0 03 00 00       	call   801c53 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188a:	c7 04 24 29 46 80 00 	movl   $0x804629,(%esp)
  801891:	e8 a4 f4 ff ff       	call   800d3a <file_open>
  801896:	85 c0                	test   %eax,%eax
  801898:	79 20                	jns    8018ba <fs_test+0x1a5>
		panic("file_open /newmotd: %e", r);
  80189a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80189e:	c7 44 24 08 32 46 80 	movl   $0x804632,0x8(%esp)
  8018a5:	00 
  8018a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018ad:	00 
  8018ae:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  8018b5:	e8 99 03 00 00       	call   801c53 <_panic>
	cprintf("file_open is good\n");
  8018ba:	c7 04 24 49 46 80 00 	movl   $0x804649,(%esp)
  8018c1:	e8 86 04 00 00       	call   801d4c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8018c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018d4:	00 
  8018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d8:	89 04 24             	mov    %eax,(%esp)
  8018db:	e8 af f1 ff ff       	call   800a8f <file_get_block>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	79 20                	jns    801904 <fs_test+0x1ef>
		panic("file_get_block: %e", r);
  8018e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e8:	c7 44 24 08 5c 46 80 	movl   $0x80465c,0x8(%esp)
  8018ef:	00 
  8018f0:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8018f7:	00 
  8018f8:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  8018ff:	e8 4f 03 00 00       	call   801c53 <_panic>
	if (strcmp(blk, msg) != 0)
  801904:	c7 44 24 04 90 47 80 	movl   $0x804790,0x4(%esp)
  80190b:	00 
  80190c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 15 0b 00 00       	call   80242c <strcmp>
  801917:	85 c0                	test   %eax,%eax
  801919:	74 1c                	je     801937 <fs_test+0x222>
		panic("file_get_block returned wrong data");
  80191b:	c7 44 24 08 b8 47 80 	movl   $0x8047b8,0x8(%esp)
  801922:	00 
  801923:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80192a:	00 
  80192b:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801932:	e8 1c 03 00 00       	call   801c53 <_panic>
	cprintf("file_get_block is good\n");
  801937:	c7 04 24 6f 46 80 00 	movl   $0x80466f,(%esp)
  80193e:	e8 09 04 00 00       	call   801d4c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	0f b6 10             	movzbl (%eax),%edx
  801949:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80194b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194e:	c1 e8 0c             	shr    $0xc,%eax
  801951:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801958:	a8 40                	test   $0x40,%al
  80195a:	75 24                	jne    801980 <fs_test+0x26b>
  80195c:	c7 44 24 0c 88 46 80 	movl   $0x804688,0xc(%esp)
  801963:	00 
  801964:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  80196b:	00 
  80196c:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801973:	00 
  801974:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  80197b:	e8 d3 02 00 00       	call   801c53 <_panic>
	file_flush(f);
  801980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 01 f6 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80198b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198e:	c1 e8 0c             	shr    $0xc,%eax
  801991:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801998:	a8 40                	test   $0x40,%al
  80199a:	74 24                	je     8019c0 <fs_test+0x2ab>
  80199c:	c7 44 24 0c 87 46 80 	movl   $0x804687,0xc(%esp)
  8019a3:	00 
  8019a4:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8019ab:	00 
  8019ac:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8019b3:	00 
  8019b4:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  8019bb:	e8 93 02 00 00       	call   801c53 <_panic>
	cprintf("file_flush is good\n");
  8019c0:	c7 04 24 a3 46 80 00 	movl   $0x8046a3,(%esp)
  8019c7:	e8 80 03 00 00       	call   801d4c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8019cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019d3:	00 
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	89 04 24             	mov    %eax,(%esp)
  8019da:	e8 2a f4 ff ff       	call   800e09 <file_set_size>
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	79 20                	jns    801a03 <fs_test+0x2ee>
		panic("file_set_size: %e", r);
  8019e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e7:	c7 44 24 08 b7 46 80 	movl   $0x8046b7,0x8(%esp)
  8019ee:	00 
  8019ef:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8019f6:	00 
  8019f7:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  8019fe:	e8 50 02 00 00       	call   801c53 <_panic>
	assert(f->f_direct[0] == 0);
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801a0d:	74 24                	je     801a33 <fs_test+0x31e>
  801a0f:	c7 44 24 0c c9 46 80 	movl   $0x8046c9,0xc(%esp)
  801a16:	00 
  801a17:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801a1e:	00 
  801a1f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801a26:	00 
  801a27:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801a2e:	e8 20 02 00 00       	call   801c53 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a33:	c1 e8 0c             	shr    $0xc,%eax
  801a36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a3d:	a8 40                	test   $0x40,%al
  801a3f:	74 24                	je     801a65 <fs_test+0x350>
  801a41:	c7 44 24 0c dd 46 80 	movl   $0x8046dd,0xc(%esp)
  801a48:	00 
  801a49:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801a50:	00 
  801a51:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801a58:	00 
  801a59:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801a60:	e8 ee 01 00 00       	call   801c53 <_panic>
	cprintf("file_truncate is good\n");
  801a65:	c7 04 24 f7 46 80 00 	movl   $0x8046f7,(%esp)
  801a6c:	e8 db 02 00 00       	call   801d4c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801a71:	c7 04 24 90 47 80 00 	movl   $0x804790,(%esp)
  801a78:	e8 c3 08 00 00       	call   802340 <strlen>
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 7d f3 ff ff       	call   800e09 <file_set_size>
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	79 20                	jns    801ab0 <fs_test+0x39b>
		panic("file_set_size 2: %e", r);
  801a90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a94:	c7 44 24 08 0e 47 80 	movl   $0x80470e,0x8(%esp)
  801a9b:	00 
  801a9c:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801aa3:	00 
  801aa4:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801aab:	e8 a3 01 00 00       	call   801c53 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab3:	89 c2                	mov    %eax,%edx
  801ab5:	c1 ea 0c             	shr    $0xc,%edx
  801ab8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801abf:	f6 c2 40             	test   $0x40,%dl
  801ac2:	74 24                	je     801ae8 <fs_test+0x3d3>
  801ac4:	c7 44 24 0c dd 46 80 	movl   $0x8046dd,0xc(%esp)
  801acb:	00 
  801acc:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801ad3:	00 
  801ad4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801adb:	00 
  801adc:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801ae3:	e8 6b 01 00 00       	call   801c53 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801ae8:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801aeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801af6:	00 
  801af7:	89 04 24             	mov    %eax,(%esp)
  801afa:	e8 90 ef ff ff       	call   800a8f <file_get_block>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	79 20                	jns    801b23 <fs_test+0x40e>
		panic("file_get_block 2: %e", r);
  801b03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b07:	c7 44 24 08 22 47 80 	movl   $0x804722,0x8(%esp)
  801b0e:	00 
  801b0f:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801b16:	00 
  801b17:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801b1e:	e8 30 01 00 00       	call   801c53 <_panic>
	strcpy(blk, msg);
  801b23:	c7 44 24 04 90 47 80 	movl   $0x804790,0x4(%esp)
  801b2a:	00 
  801b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 41 08 00 00       	call   802377 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b39:	c1 e8 0c             	shr    $0xc,%eax
  801b3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b43:	a8 40                	test   $0x40,%al
  801b45:	75 24                	jne    801b6b <fs_test+0x456>
  801b47:	c7 44 24 0c 88 46 80 	movl   $0x804688,0xc(%esp)
  801b4e:	00 
  801b4f:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801b56:	00 
  801b57:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801b5e:	00 
  801b5f:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801b66:	e8 e8 00 00 00       	call   801c53 <_panic>
	file_flush(f);
  801b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 16 f4 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	c1 e8 0c             	shr    $0xc,%eax
  801b7c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b83:	a8 40                	test   $0x40,%al
  801b85:	74 24                	je     801bab <fs_test+0x496>
  801b87:	c7 44 24 0c 87 46 80 	movl   $0x804687,0xc(%esp)
  801b8e:	00 
  801b8f:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801b96:	00 
  801b97:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801b9e:	00 
  801b9f:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801ba6:	e8 a8 00 00 00       	call   801c53 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bae:	c1 e8 0c             	shr    $0xc,%eax
  801bb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bb8:	a8 40                	test   $0x40,%al
  801bba:	74 24                	je     801be0 <fs_test+0x4cb>
  801bbc:	c7 44 24 0c dd 46 80 	movl   $0x8046dd,0xc(%esp)
  801bc3:	00 
  801bc4:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801bcb:	00 
  801bcc:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801bd3:	00 
  801bd4:	c7 04 24 bb 45 80 00 	movl   $0x8045bb,(%esp)
  801bdb:	e8 73 00 00 00       	call   801c53 <_panic>
	cprintf("file rewrite is good\n");
  801be0:	c7 04 24 37 47 80 00 	movl   $0x804737,(%esp)
  801be7:	e8 60 01 00 00       	call   801d4c <cprintf>
}
  801bec:	83 c4 24             	add    $0x24,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 10             	sub    $0x10,%esp
  801bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bfd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  801c00:	e8 50 0b 00 00       	call   802755 <sys_getenvid>
  801c05:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c0a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c0d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c12:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c17:	85 db                	test   %ebx,%ebx
  801c19:	7e 07                	jle    801c22 <libmain+0x30>
		binaryname = argv[0];
  801c1b:	8b 06                	mov    (%esi),%eax
  801c1d:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c22:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c26:	89 1c 24             	mov    %ebx,(%esp)
  801c29:	e8 a4 fa ff ff       	call   8016d2 <umain>

	// exit gracefully
	exit();
  801c2e:	e8 07 00 00 00       	call   801c3a <exit>
}
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801c40:	e8 f5 11 00 00       	call   802e3a <close_all>
	sys_env_destroy(0);
  801c45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4c:	e8 b2 0a 00 00       	call   802703 <sys_env_destroy>
}
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c5b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c5e:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801c64:	e8 ec 0a 00 00       	call   802755 <sys_getenvid>
  801c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c70:	8b 55 08             	mov    0x8(%ebp),%edx
  801c73:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c77:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7f:	c7 04 24 e8 47 80 00 	movl   $0x8047e8,(%esp)
  801c86:	e8 c1 00 00 00       	call   801d4c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 51 00 00 00       	call   801ceb <vcprintf>
	cprintf("\n");
  801c9a:	c7 04 24 c7 43 80 00 	movl   $0x8043c7,(%esp)
  801ca1:	e8 a6 00 00 00       	call   801d4c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ca6:	cc                   	int3   
  801ca7:	eb fd                	jmp    801ca6 <_panic+0x53>

00801ca9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 14             	sub    $0x14,%esp
  801cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801cb3:	8b 13                	mov    (%ebx),%edx
  801cb5:	8d 42 01             	lea    0x1(%edx),%eax
  801cb8:	89 03                	mov    %eax,(%ebx)
  801cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801cc1:	3d ff 00 00 00       	cmp    $0xff,%eax
  801cc6:	75 19                	jne    801ce1 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801cc8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801ccf:	00 
  801cd0:	8d 43 08             	lea    0x8(%ebx),%eax
  801cd3:	89 04 24             	mov    %eax,(%esp)
  801cd6:	e8 eb 09 00 00       	call   8026c6 <sys_cputs>
		b->idx = 0;
  801cdb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801ce1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801ce5:	83 c4 14             	add    $0x14,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801cf4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cfb:	00 00 00 
	b.cnt = 0;
  801cfe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d05:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d16:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	c7 04 24 a9 1c 80 00 	movl   $0x801ca9,(%esp)
  801d27:	e8 b2 01 00 00       	call   801ede <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d2c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 82 09 00 00       	call   8026c6 <sys_cputs>

	return b.cnt;
}
  801d44:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d52:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 87 ff ff ff       	call   801ceb <vcprintf>
	va_end(ap);

	return cnt;
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	57                   	push   %edi
  801d74:	56                   	push   %esi
  801d75:	53                   	push   %ebx
  801d76:	83 ec 3c             	sub    $0x3c,%esp
  801d79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d7c:	89 d7                	mov    %edx,%edi
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801d8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d97:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d9a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801d9d:	39 d9                	cmp    %ebx,%ecx
  801d9f:	72 05                	jb     801da6 <printnum+0x36>
  801da1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801da4:	77 69                	ja     801e0f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801da6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801da9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801dad:	83 ee 01             	sub    $0x1,%esi
  801db0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801db4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db8:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dbc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	89 d6                	mov    %edx,%esi
  801dc4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801dc7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801dca:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddf:	e8 7c 21 00 00       	call   803f60 <__udivdi3>
  801de4:	89 d9                	mov    %ebx,%ecx
  801de6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dee:	89 04 24             	mov    %eax,(%esp)
  801df1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df5:	89 fa                	mov    %edi,%edx
  801df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dfa:	e8 71 ff ff ff       	call   801d70 <printnum>
  801dff:	eb 1b                	jmp    801e1c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801e01:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e05:	8b 45 18             	mov    0x18(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	ff d3                	call   *%ebx
  801e0d:	eb 03                	jmp    801e12 <printnum+0xa2>
  801e0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e12:	83 ee 01             	sub    $0x1,%esi
  801e15:	85 f6                	test   %esi,%esi
  801e17:	7f e8                	jg     801e01 <printnum+0x91>
  801e19:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e20:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e24:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e27:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e35:	89 04 24             	mov    %eax,(%esp)
  801e38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3f:	e8 4c 22 00 00       	call   804090 <__umoddi3>
  801e44:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e48:	0f be 80 0b 48 80 00 	movsbl 0x80480b(%eax),%eax
  801e4f:	89 04 24             	mov    %eax,(%esp)
  801e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e55:	ff d0                	call   *%eax
}
  801e57:	83 c4 3c             	add    $0x3c,%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e62:	83 fa 01             	cmp    $0x1,%edx
  801e65:	7e 0e                	jle    801e75 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e67:	8b 10                	mov    (%eax),%edx
  801e69:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e6c:	89 08                	mov    %ecx,(%eax)
  801e6e:	8b 02                	mov    (%edx),%eax
  801e70:	8b 52 04             	mov    0x4(%edx),%edx
  801e73:	eb 22                	jmp    801e97 <getuint+0x38>
	else if (lflag)
  801e75:	85 d2                	test   %edx,%edx
  801e77:	74 10                	je     801e89 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e79:	8b 10                	mov    (%eax),%edx
  801e7b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e7e:	89 08                	mov    %ecx,(%eax)
  801e80:	8b 02                	mov    (%edx),%eax
  801e82:	ba 00 00 00 00       	mov    $0x0,%edx
  801e87:	eb 0e                	jmp    801e97 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801e89:	8b 10                	mov    (%eax),%edx
  801e8b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e8e:	89 08                	mov    %ecx,(%eax)
  801e90:	8b 02                	mov    (%edx),%eax
  801e92:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e9f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ea3:	8b 10                	mov    (%eax),%edx
  801ea5:	3b 50 04             	cmp    0x4(%eax),%edx
  801ea8:	73 0a                	jae    801eb4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801eaa:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ead:	89 08                	mov    %ecx,(%eax)
  801eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb2:	88 02                	mov    %al,(%edx)
}
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801ebc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ebf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ec3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	89 04 24             	mov    %eax,(%esp)
  801ed7:	e8 02 00 00 00       	call   801ede <vprintfmt>
	va_end(ap);
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 3c             	sub    $0x3c,%esp
  801ee7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eed:	eb 14                	jmp    801f03 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	0f 84 b3 03 00 00    	je     8022aa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  801ef7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801efb:	89 04 24             	mov    %eax,(%esp)
  801efe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801f01:	89 f3                	mov    %esi,%ebx
  801f03:	8d 73 01             	lea    0x1(%ebx),%esi
  801f06:	0f b6 03             	movzbl (%ebx),%eax
  801f09:	83 f8 25             	cmp    $0x25,%eax
  801f0c:	75 e1                	jne    801eef <vprintfmt+0x11>
  801f0e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801f12:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801f19:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801f20:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801f27:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2c:	eb 1d                	jmp    801f4b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f2e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801f30:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801f34:	eb 15                	jmp    801f4b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f36:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801f38:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801f3c:	eb 0d                	jmp    801f4b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801f3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f41:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f44:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f4b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801f4e:	0f b6 0e             	movzbl (%esi),%ecx
  801f51:	0f b6 c1             	movzbl %cl,%eax
  801f54:	83 e9 23             	sub    $0x23,%ecx
  801f57:	80 f9 55             	cmp    $0x55,%cl
  801f5a:	0f 87 2a 03 00 00    	ja     80228a <vprintfmt+0x3ac>
  801f60:	0f b6 c9             	movzbl %cl,%ecx
  801f63:	ff 24 8d 40 49 80 00 	jmp    *0x804940(,%ecx,4)
  801f6a:	89 de                	mov    %ebx,%esi
  801f6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f71:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801f74:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801f78:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801f7b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801f7e:	83 fb 09             	cmp    $0x9,%ebx
  801f81:	77 36                	ja     801fb9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801f83:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801f86:	eb e9                	jmp    801f71 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801f88:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8b:	8d 48 04             	lea    0x4(%eax),%ecx
  801f8e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801f91:	8b 00                	mov    (%eax),%eax
  801f93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f96:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801f98:	eb 22                	jmp    801fbc <vprintfmt+0xde>
  801f9a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f9d:	85 c9                	test   %ecx,%ecx
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	0f 49 c1             	cmovns %ecx,%eax
  801fa7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801faa:	89 de                	mov    %ebx,%esi
  801fac:	eb 9d                	jmp    801f4b <vprintfmt+0x6d>
  801fae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801fb0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801fb7:	eb 92                	jmp    801f4b <vprintfmt+0x6d>
  801fb9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801fbc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801fc0:	79 89                	jns    801f4b <vprintfmt+0x6d>
  801fc2:	e9 77 ff ff ff       	jmp    801f3e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801fc7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fca:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801fcc:	e9 7a ff ff ff       	jmp    801f4b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801fd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd4:	8d 50 04             	lea    0x4(%eax),%edx
  801fd7:	89 55 14             	mov    %edx,0x14(%ebp)
  801fda:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fde:	8b 00                	mov    (%eax),%eax
  801fe0:	89 04 24             	mov    %eax,(%esp)
  801fe3:	ff 55 08             	call   *0x8(%ebp)
			break;
  801fe6:	e9 18 ff ff ff       	jmp    801f03 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801feb:	8b 45 14             	mov    0x14(%ebp),%eax
  801fee:	8d 50 04             	lea    0x4(%eax),%edx
  801ff1:	89 55 14             	mov    %edx,0x14(%ebp)
  801ff4:	8b 00                	mov    (%eax),%eax
  801ff6:	99                   	cltd   
  801ff7:	31 d0                	xor    %edx,%eax
  801ff9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ffb:	83 f8 0f             	cmp    $0xf,%eax
  801ffe:	7f 0b                	jg     80200b <vprintfmt+0x12d>
  802000:	8b 14 85 a0 4a 80 00 	mov    0x804aa0(,%eax,4),%edx
  802007:	85 d2                	test   %edx,%edx
  802009:	75 20                	jne    80202b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80200b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200f:	c7 44 24 08 23 48 80 	movl   $0x804823,0x8(%esp)
  802016:	00 
  802017:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	89 04 24             	mov    %eax,(%esp)
  802021:	e8 90 fe ff ff       	call   801eb6 <printfmt>
  802026:	e9 d8 fe ff ff       	jmp    801f03 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80202b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80202f:	c7 44 24 08 4f 42 80 	movl   $0x80424f,0x8(%esp)
  802036:	00 
  802037:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	89 04 24             	mov    %eax,(%esp)
  802041:	e8 70 fe ff ff       	call   801eb6 <printfmt>
  802046:	e9 b8 fe ff ff       	jmp    801f03 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80204b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80204e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802051:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  802054:	8b 45 14             	mov    0x14(%ebp),%eax
  802057:	8d 50 04             	lea    0x4(%eax),%edx
  80205a:	89 55 14             	mov    %edx,0x14(%ebp)
  80205d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80205f:	85 f6                	test   %esi,%esi
  802061:	b8 1c 48 80 00       	mov    $0x80481c,%eax
  802066:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  802069:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80206d:	0f 84 97 00 00 00    	je     80210a <vprintfmt+0x22c>
  802073:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  802077:	0f 8e 9b 00 00 00    	jle    802118 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80207d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802081:	89 34 24             	mov    %esi,(%esp)
  802084:	e8 cf 02 00 00       	call   802358 <strnlen>
  802089:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80208c:	29 c2                	sub    %eax,%edx
  80208e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  802091:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  802095:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802098:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80209b:	8b 75 08             	mov    0x8(%ebp),%esi
  80209e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8020a1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8020a3:	eb 0f                	jmp    8020b4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8020a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	85 db                	test   %ebx,%ebx
  8020b6:	7f ed                	jg     8020a5 <vprintfmt+0x1c7>
  8020b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8020bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8020be:	85 d2                	test   %edx,%edx
  8020c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c5:	0f 49 c2             	cmovns %edx,%eax
  8020c8:	29 c2                	sub    %eax,%edx
  8020ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8020cd:	89 d7                	mov    %edx,%edi
  8020cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8020d2:	eb 50                	jmp    802124 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8020d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8020d8:	74 1e                	je     8020f8 <vprintfmt+0x21a>
  8020da:	0f be d2             	movsbl %dl,%edx
  8020dd:	83 ea 20             	sub    $0x20,%edx
  8020e0:	83 fa 5e             	cmp    $0x5e,%edx
  8020e3:	76 13                	jbe    8020f8 <vprintfmt+0x21a>
					putch('?', putdat);
  8020e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8020f3:	ff 55 08             	call   *0x8(%ebp)
  8020f6:	eb 0d                	jmp    802105 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8020f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020ff:	89 04 24             	mov    %eax,(%esp)
  802102:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802105:	83 ef 01             	sub    $0x1,%edi
  802108:	eb 1a                	jmp    802124 <vprintfmt+0x246>
  80210a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80210d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  802110:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802113:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802116:	eb 0c                	jmp    802124 <vprintfmt+0x246>
  802118:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80211b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80211e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802121:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802124:	83 c6 01             	add    $0x1,%esi
  802127:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80212b:	0f be c2             	movsbl %dl,%eax
  80212e:	85 c0                	test   %eax,%eax
  802130:	74 27                	je     802159 <vprintfmt+0x27b>
  802132:	85 db                	test   %ebx,%ebx
  802134:	78 9e                	js     8020d4 <vprintfmt+0x1f6>
  802136:	83 eb 01             	sub    $0x1,%ebx
  802139:	79 99                	jns    8020d4 <vprintfmt+0x1f6>
  80213b:	89 f8                	mov    %edi,%eax
  80213d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802140:	8b 75 08             	mov    0x8(%ebp),%esi
  802143:	89 c3                	mov    %eax,%ebx
  802145:	eb 1a                	jmp    802161 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802147:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80214b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802152:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802154:	83 eb 01             	sub    $0x1,%ebx
  802157:	eb 08                	jmp    802161 <vprintfmt+0x283>
  802159:	89 fb                	mov    %edi,%ebx
  80215b:	8b 75 08             	mov    0x8(%ebp),%esi
  80215e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802161:	85 db                	test   %ebx,%ebx
  802163:	7f e2                	jg     802147 <vprintfmt+0x269>
  802165:	89 75 08             	mov    %esi,0x8(%ebp)
  802168:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80216b:	e9 93 fd ff ff       	jmp    801f03 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802170:	83 fa 01             	cmp    $0x1,%edx
  802173:	7e 16                	jle    80218b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  802175:	8b 45 14             	mov    0x14(%ebp),%eax
  802178:	8d 50 08             	lea    0x8(%eax),%edx
  80217b:	89 55 14             	mov    %edx,0x14(%ebp)
  80217e:	8b 50 04             	mov    0x4(%eax),%edx
  802181:	8b 00                	mov    (%eax),%eax
  802183:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802186:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802189:	eb 32                	jmp    8021bd <vprintfmt+0x2df>
	else if (lflag)
  80218b:	85 d2                	test   %edx,%edx
  80218d:	74 18                	je     8021a7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80218f:	8b 45 14             	mov    0x14(%ebp),%eax
  802192:	8d 50 04             	lea    0x4(%eax),%edx
  802195:	89 55 14             	mov    %edx,0x14(%ebp)
  802198:	8b 30                	mov    (%eax),%esi
  80219a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80219d:	89 f0                	mov    %esi,%eax
  80219f:	c1 f8 1f             	sar    $0x1f,%eax
  8021a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021a5:	eb 16                	jmp    8021bd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8021a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8021aa:	8d 50 04             	lea    0x4(%eax),%edx
  8021ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8021b0:	8b 30                	mov    (%eax),%esi
  8021b2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	c1 f8 1f             	sar    $0x1f,%eax
  8021ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8021bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8021c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8021c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8021cc:	0f 89 80 00 00 00    	jns    802252 <vprintfmt+0x374>
				putch('-', putdat);
  8021d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8021dd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8021e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8021e6:	f7 d8                	neg    %eax
  8021e8:	83 d2 00             	adc    $0x0,%edx
  8021eb:	f7 da                	neg    %edx
			}
			base = 10;
  8021ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8021f2:	eb 5e                	jmp    802252 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8021f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8021f7:	e8 63 fc ff ff       	call   801e5f <getuint>
			base = 10;
  8021fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802201:	eb 4f                	jmp    802252 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  802203:	8d 45 14             	lea    0x14(%ebp),%eax
  802206:	e8 54 fc ff ff       	call   801e5f <getuint>
			base = 8;
  80220b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802210:	eb 40                	jmp    802252 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  802212:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802216:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80221d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802220:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802224:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80222b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80222e:	8b 45 14             	mov    0x14(%ebp),%eax
  802231:	8d 50 04             	lea    0x4(%eax),%edx
  802234:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802237:	8b 00                	mov    (%eax),%eax
  802239:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80223e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  802243:	eb 0d                	jmp    802252 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802245:	8d 45 14             	lea    0x14(%ebp),%eax
  802248:	e8 12 fc ff ff       	call   801e5f <getuint>
			base = 16;
  80224d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802252:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  802256:	89 74 24 10          	mov    %esi,0x10(%esp)
  80225a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80225d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802261:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802265:	89 04 24             	mov    %eax,(%esp)
  802268:	89 54 24 04          	mov    %edx,0x4(%esp)
  80226c:	89 fa                	mov    %edi,%edx
  80226e:	8b 45 08             	mov    0x8(%ebp),%eax
  802271:	e8 fa fa ff ff       	call   801d70 <printnum>
			break;
  802276:	e9 88 fc ff ff       	jmp    801f03 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80227b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80227f:	89 04 24             	mov    %eax,(%esp)
  802282:	ff 55 08             	call   *0x8(%ebp)
			break;
  802285:	e9 79 fc ff ff       	jmp    801f03 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80228a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80228e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802295:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802298:	89 f3                	mov    %esi,%ebx
  80229a:	eb 03                	jmp    80229f <vprintfmt+0x3c1>
  80229c:	83 eb 01             	sub    $0x1,%ebx
  80229f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8022a3:	75 f7                	jne    80229c <vprintfmt+0x3be>
  8022a5:	e9 59 fc ff ff       	jmp    801f03 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8022aa:	83 c4 3c             	add    $0x3c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    

008022b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 28             	sub    $0x28,%esp
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8022be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8022c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	74 30                	je     802303 <vsnprintf+0x51>
  8022d3:	85 d2                	test   %edx,%edx
  8022d5:	7e 2c                	jle    802303 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8022d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8022da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022de:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ec:	c7 04 24 99 1e 80 00 	movl   $0x801e99,(%esp)
  8022f3:	e8 e6 fb ff ff       	call   801ede <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8022f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802301:	eb 05                	jmp    802308 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802310:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802313:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802317:	8b 45 10             	mov    0x10(%ebp),%eax
  80231a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80231e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802321:	89 44 24 04          	mov    %eax,0x4(%esp)
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	89 04 24             	mov    %eax,(%esp)
  80232b:	e8 82 ff ff ff       	call   8022b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
  80234b:	eb 03                	jmp    802350 <strlen+0x10>
		n++;
  80234d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802350:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802354:	75 f7                	jne    80234d <strlen+0xd>
		n++;
	return n;
}
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    

00802358 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80235e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802361:	b8 00 00 00 00       	mov    $0x0,%eax
  802366:	eb 03                	jmp    80236b <strnlen+0x13>
		n++;
  802368:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80236b:	39 d0                	cmp    %edx,%eax
  80236d:	74 06                	je     802375 <strnlen+0x1d>
  80236f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  802373:	75 f3                	jne    802368 <strnlen+0x10>
		n++;
	return n;
}
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	53                   	push   %ebx
  80237b:	8b 45 08             	mov    0x8(%ebp),%eax
  80237e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802381:	89 c2                	mov    %eax,%edx
  802383:	83 c2 01             	add    $0x1,%edx
  802386:	83 c1 01             	add    $0x1,%ecx
  802389:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80238d:	88 5a ff             	mov    %bl,-0x1(%edx)
  802390:	84 db                	test   %bl,%bl
  802392:	75 ef                	jne    802383 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802394:	5b                   	pop    %ebx
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    

00802397 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	53                   	push   %ebx
  80239b:	83 ec 08             	sub    $0x8,%esp
  80239e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8023a1:	89 1c 24             	mov    %ebx,(%esp)
  8023a4:	e8 97 ff ff ff       	call   802340 <strlen>
	strcpy(dst + len, src);
  8023a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023b0:	01 d8                	add    %ebx,%eax
  8023b2:	89 04 24             	mov    %eax,(%esp)
  8023b5:	e8 bd ff ff ff       	call   802377 <strcpy>
	return dst;
}
  8023ba:	89 d8                	mov    %ebx,%eax
  8023bc:	83 c4 08             	add    $0x8,%esp
  8023bf:	5b                   	pop    %ebx
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	56                   	push   %esi
  8023c6:	53                   	push   %ebx
  8023c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8023ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023cd:	89 f3                	mov    %esi,%ebx
  8023cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	eb 0f                	jmp    8023e5 <strncpy+0x23>
		*dst++ = *src;
  8023d6:	83 c2 01             	add    $0x1,%edx
  8023d9:	0f b6 01             	movzbl (%ecx),%eax
  8023dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8023df:	80 39 01             	cmpb   $0x1,(%ecx)
  8023e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8023e5:	39 da                	cmp    %ebx,%edx
  8023e7:	75 ed                	jne    8023d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8023e9:	89 f0                	mov    %esi,%eax
  8023eb:	5b                   	pop    %ebx
  8023ec:	5e                   	pop    %esi
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    

008023ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8023fd:	89 f0                	mov    %esi,%eax
  8023ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802403:	85 c9                	test   %ecx,%ecx
  802405:	75 0b                	jne    802412 <strlcpy+0x23>
  802407:	eb 1d                	jmp    802426 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802409:	83 c0 01             	add    $0x1,%eax
  80240c:	83 c2 01             	add    $0x1,%edx
  80240f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802412:	39 d8                	cmp    %ebx,%eax
  802414:	74 0b                	je     802421 <strlcpy+0x32>
  802416:	0f b6 0a             	movzbl (%edx),%ecx
  802419:	84 c9                	test   %cl,%cl
  80241b:	75 ec                	jne    802409 <strlcpy+0x1a>
  80241d:	89 c2                	mov    %eax,%edx
  80241f:	eb 02                	jmp    802423 <strlcpy+0x34>
  802421:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  802423:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802426:	29 f0                	sub    %esi,%eax
}
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    

0080242c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802432:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802435:	eb 06                	jmp    80243d <strcmp+0x11>
		p++, q++;
  802437:	83 c1 01             	add    $0x1,%ecx
  80243a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80243d:	0f b6 01             	movzbl (%ecx),%eax
  802440:	84 c0                	test   %al,%al
  802442:	74 04                	je     802448 <strcmp+0x1c>
  802444:	3a 02                	cmp    (%edx),%al
  802446:	74 ef                	je     802437 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802448:	0f b6 c0             	movzbl %al,%eax
  80244b:	0f b6 12             	movzbl (%edx),%edx
  80244e:	29 d0                	sub    %edx,%eax
}
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    

00802452 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	53                   	push   %ebx
  802456:	8b 45 08             	mov    0x8(%ebp),%eax
  802459:	8b 55 0c             	mov    0xc(%ebp),%edx
  80245c:	89 c3                	mov    %eax,%ebx
  80245e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802461:	eb 06                	jmp    802469 <strncmp+0x17>
		n--, p++, q++;
  802463:	83 c0 01             	add    $0x1,%eax
  802466:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802469:	39 d8                	cmp    %ebx,%eax
  80246b:	74 15                	je     802482 <strncmp+0x30>
  80246d:	0f b6 08             	movzbl (%eax),%ecx
  802470:	84 c9                	test   %cl,%cl
  802472:	74 04                	je     802478 <strncmp+0x26>
  802474:	3a 0a                	cmp    (%edx),%cl
  802476:	74 eb                	je     802463 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802478:	0f b6 00             	movzbl (%eax),%eax
  80247b:	0f b6 12             	movzbl (%edx),%edx
  80247e:	29 d0                	sub    %edx,%eax
  802480:	eb 05                	jmp    802487 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802482:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802487:	5b                   	pop    %ebx
  802488:	5d                   	pop    %ebp
  802489:	c3                   	ret    

0080248a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80248a:	55                   	push   %ebp
  80248b:	89 e5                	mov    %esp,%ebp
  80248d:	8b 45 08             	mov    0x8(%ebp),%eax
  802490:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802494:	eb 07                	jmp    80249d <strchr+0x13>
		if (*s == c)
  802496:	38 ca                	cmp    %cl,%dl
  802498:	74 0f                	je     8024a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80249a:	83 c0 01             	add    $0x1,%eax
  80249d:	0f b6 10             	movzbl (%eax),%edx
  8024a0:	84 d2                	test   %dl,%dl
  8024a2:	75 f2                	jne    802496 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8024a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8024b5:	eb 07                	jmp    8024be <strfind+0x13>
		if (*s == c)
  8024b7:	38 ca                	cmp    %cl,%dl
  8024b9:	74 0a                	je     8024c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8024bb:	83 c0 01             	add    $0x1,%eax
  8024be:	0f b6 10             	movzbl (%eax),%edx
  8024c1:	84 d2                	test   %dl,%dl
  8024c3:	75 f2                	jne    8024b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8024c5:	5d                   	pop    %ebp
  8024c6:	c3                   	ret    

008024c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8024c7:	55                   	push   %ebp
  8024c8:	89 e5                	mov    %esp,%ebp
  8024ca:	57                   	push   %edi
  8024cb:	56                   	push   %esi
  8024cc:	53                   	push   %ebx
  8024cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8024d3:	85 c9                	test   %ecx,%ecx
  8024d5:	74 36                	je     80250d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8024d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8024dd:	75 28                	jne    802507 <memset+0x40>
  8024df:	f6 c1 03             	test   $0x3,%cl
  8024e2:	75 23                	jne    802507 <memset+0x40>
		c &= 0xFF;
  8024e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8024e8:	89 d3                	mov    %edx,%ebx
  8024ea:	c1 e3 08             	shl    $0x8,%ebx
  8024ed:	89 d6                	mov    %edx,%esi
  8024ef:	c1 e6 18             	shl    $0x18,%esi
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	c1 e0 10             	shl    $0x10,%eax
  8024f7:	09 f0                	or     %esi,%eax
  8024f9:	09 c2                	or     %eax,%edx
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8024ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802502:	fc                   	cld    
  802503:	f3 ab                	rep stos %eax,%es:(%edi)
  802505:	eb 06                	jmp    80250d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250a:	fc                   	cld    
  80250b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80250d:	89 f8                	mov    %edi,%eax
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    

00802514 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	57                   	push   %edi
  802518:	56                   	push   %esi
  802519:	8b 45 08             	mov    0x8(%ebp),%eax
  80251c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80251f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802522:	39 c6                	cmp    %eax,%esi
  802524:	73 35                	jae    80255b <memmove+0x47>
  802526:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802529:	39 d0                	cmp    %edx,%eax
  80252b:	73 2e                	jae    80255b <memmove+0x47>
		s += n;
		d += n;
  80252d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802530:	89 d6                	mov    %edx,%esi
  802532:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802534:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80253a:	75 13                	jne    80254f <memmove+0x3b>
  80253c:	f6 c1 03             	test   $0x3,%cl
  80253f:	75 0e                	jne    80254f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802541:	83 ef 04             	sub    $0x4,%edi
  802544:	8d 72 fc             	lea    -0x4(%edx),%esi
  802547:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80254a:	fd                   	std    
  80254b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80254d:	eb 09                	jmp    802558 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80254f:	83 ef 01             	sub    $0x1,%edi
  802552:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802555:	fd                   	std    
  802556:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802558:	fc                   	cld    
  802559:	eb 1d                	jmp    802578 <memmove+0x64>
  80255b:	89 f2                	mov    %esi,%edx
  80255d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80255f:	f6 c2 03             	test   $0x3,%dl
  802562:	75 0f                	jne    802573 <memmove+0x5f>
  802564:	f6 c1 03             	test   $0x3,%cl
  802567:	75 0a                	jne    802573 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802569:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80256c:	89 c7                	mov    %eax,%edi
  80256e:	fc                   	cld    
  80256f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802571:	eb 05                	jmp    802578 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802573:	89 c7                	mov    %eax,%edi
  802575:	fc                   	cld    
  802576:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802578:	5e                   	pop    %esi
  802579:	5f                   	pop    %edi
  80257a:	5d                   	pop    %ebp
  80257b:	c3                   	ret    

0080257c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
  80257f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802582:	8b 45 10             	mov    0x10(%ebp),%eax
  802585:	89 44 24 08          	mov    %eax,0x8(%esp)
  802589:	8b 45 0c             	mov    0xc(%ebp),%eax
  80258c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802590:	8b 45 08             	mov    0x8(%ebp),%eax
  802593:	89 04 24             	mov    %eax,(%esp)
  802596:	e8 79 ff ff ff       	call   802514 <memmove>
}
  80259b:	c9                   	leave  
  80259c:	c3                   	ret    

0080259d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	56                   	push   %esi
  8025a1:	53                   	push   %ebx
  8025a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a8:	89 d6                	mov    %edx,%esi
  8025aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8025ad:	eb 1a                	jmp    8025c9 <memcmp+0x2c>
		if (*s1 != *s2)
  8025af:	0f b6 02             	movzbl (%edx),%eax
  8025b2:	0f b6 19             	movzbl (%ecx),%ebx
  8025b5:	38 d8                	cmp    %bl,%al
  8025b7:	74 0a                	je     8025c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8025b9:	0f b6 c0             	movzbl %al,%eax
  8025bc:	0f b6 db             	movzbl %bl,%ebx
  8025bf:	29 d8                	sub    %ebx,%eax
  8025c1:	eb 0f                	jmp    8025d2 <memcmp+0x35>
		s1++, s2++;
  8025c3:	83 c2 01             	add    $0x1,%edx
  8025c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8025c9:	39 f2                	cmp    %esi,%edx
  8025cb:	75 e2                	jne    8025af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8025cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d2:	5b                   	pop    %ebx
  8025d3:	5e                   	pop    %esi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    

008025d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8025df:	89 c2                	mov    %eax,%edx
  8025e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8025e4:	eb 07                	jmp    8025ed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8025e6:	38 08                	cmp    %cl,(%eax)
  8025e8:	74 07                	je     8025f1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8025ea:	83 c0 01             	add    $0x1,%eax
  8025ed:	39 d0                	cmp    %edx,%eax
  8025ef:	72 f5                	jb     8025e6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8025f1:	5d                   	pop    %ebp
  8025f2:	c3                   	ret    

008025f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8025f3:	55                   	push   %ebp
  8025f4:	89 e5                	mov    %esp,%ebp
  8025f6:	57                   	push   %edi
  8025f7:	56                   	push   %esi
  8025f8:	53                   	push   %ebx
  8025f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8025fc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8025ff:	eb 03                	jmp    802604 <strtol+0x11>
		s++;
  802601:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802604:	0f b6 0a             	movzbl (%edx),%ecx
  802607:	80 f9 09             	cmp    $0x9,%cl
  80260a:	74 f5                	je     802601 <strtol+0xe>
  80260c:	80 f9 20             	cmp    $0x20,%cl
  80260f:	74 f0                	je     802601 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802611:	80 f9 2b             	cmp    $0x2b,%cl
  802614:	75 0a                	jne    802620 <strtol+0x2d>
		s++;
  802616:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802619:	bf 00 00 00 00       	mov    $0x0,%edi
  80261e:	eb 11                	jmp    802631 <strtol+0x3e>
  802620:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802625:	80 f9 2d             	cmp    $0x2d,%cl
  802628:	75 07                	jne    802631 <strtol+0x3e>
		s++, neg = 1;
  80262a:	8d 52 01             	lea    0x1(%edx),%edx
  80262d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802631:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802636:	75 15                	jne    80264d <strtol+0x5a>
  802638:	80 3a 30             	cmpb   $0x30,(%edx)
  80263b:	75 10                	jne    80264d <strtol+0x5a>
  80263d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802641:	75 0a                	jne    80264d <strtol+0x5a>
		s += 2, base = 16;
  802643:	83 c2 02             	add    $0x2,%edx
  802646:	b8 10 00 00 00       	mov    $0x10,%eax
  80264b:	eb 10                	jmp    80265d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80264d:	85 c0                	test   %eax,%eax
  80264f:	75 0c                	jne    80265d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802651:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802653:	80 3a 30             	cmpb   $0x30,(%edx)
  802656:	75 05                	jne    80265d <strtol+0x6a>
		s++, base = 8;
  802658:	83 c2 01             	add    $0x1,%edx
  80265b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80265d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802662:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802665:	0f b6 0a             	movzbl (%edx),%ecx
  802668:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80266b:	89 f0                	mov    %esi,%eax
  80266d:	3c 09                	cmp    $0x9,%al
  80266f:	77 08                	ja     802679 <strtol+0x86>
			dig = *s - '0';
  802671:	0f be c9             	movsbl %cl,%ecx
  802674:	83 e9 30             	sub    $0x30,%ecx
  802677:	eb 20                	jmp    802699 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  802679:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80267c:	89 f0                	mov    %esi,%eax
  80267e:	3c 19                	cmp    $0x19,%al
  802680:	77 08                	ja     80268a <strtol+0x97>
			dig = *s - 'a' + 10;
  802682:	0f be c9             	movsbl %cl,%ecx
  802685:	83 e9 57             	sub    $0x57,%ecx
  802688:	eb 0f                	jmp    802699 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80268a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80268d:	89 f0                	mov    %esi,%eax
  80268f:	3c 19                	cmp    $0x19,%al
  802691:	77 16                	ja     8026a9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  802693:	0f be c9             	movsbl %cl,%ecx
  802696:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802699:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80269c:	7d 0f                	jge    8026ad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80269e:	83 c2 01             	add    $0x1,%edx
  8026a1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8026a5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8026a7:	eb bc                	jmp    802665 <strtol+0x72>
  8026a9:	89 d8                	mov    %ebx,%eax
  8026ab:	eb 02                	jmp    8026af <strtol+0xbc>
  8026ad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8026af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8026b3:	74 05                	je     8026ba <strtol+0xc7>
		*endptr = (char *) s;
  8026b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026b8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8026ba:	f7 d8                	neg    %eax
  8026bc:	85 ff                	test   %edi,%edi
  8026be:	0f 44 c3             	cmove  %ebx,%eax
}
  8026c1:	5b                   	pop    %ebx
  8026c2:	5e                   	pop    %esi
  8026c3:	5f                   	pop    %edi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	57                   	push   %edi
  8026ca:	56                   	push   %esi
  8026cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8026d7:	89 c3                	mov    %eax,%ebx
  8026d9:	89 c7                	mov    %eax,%edi
  8026db:	89 c6                	mov    %eax,%esi
  8026dd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8026df:	5b                   	pop    %ebx
  8026e0:	5e                   	pop    %esi
  8026e1:	5f                   	pop    %edi
  8026e2:	5d                   	pop    %ebp
  8026e3:	c3                   	ret    

008026e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8026e4:	55                   	push   %ebp
  8026e5:	89 e5                	mov    %esp,%ebp
  8026e7:	57                   	push   %edi
  8026e8:	56                   	push   %esi
  8026e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8026ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f4:	89 d1                	mov    %edx,%ecx
  8026f6:	89 d3                	mov    %edx,%ebx
  8026f8:	89 d7                	mov    %edx,%edi
  8026fa:	89 d6                	mov    %edx,%esi
  8026fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8026fe:	5b                   	pop    %ebx
  8026ff:	5e                   	pop    %esi
  802700:	5f                   	pop    %edi
  802701:	5d                   	pop    %ebp
  802702:	c3                   	ret    

00802703 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802703:	55                   	push   %ebp
  802704:	89 e5                	mov    %esp,%ebp
  802706:	57                   	push   %edi
  802707:	56                   	push   %esi
  802708:	53                   	push   %ebx
  802709:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80270c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802711:	b8 03 00 00 00       	mov    $0x3,%eax
  802716:	8b 55 08             	mov    0x8(%ebp),%edx
  802719:	89 cb                	mov    %ecx,%ebx
  80271b:	89 cf                	mov    %ecx,%edi
  80271d:	89 ce                	mov    %ecx,%esi
  80271f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802721:	85 c0                	test   %eax,%eax
  802723:	7e 28                	jle    80274d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802725:	89 44 24 10          	mov    %eax,0x10(%esp)
  802729:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802730:	00 
  802731:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802738:	00 
  802739:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802740:	00 
  802741:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802748:	e8 06 f5 ff ff       	call   801c53 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80274d:	83 c4 2c             	add    $0x2c,%esp
  802750:	5b                   	pop    %ebx
  802751:	5e                   	pop    %esi
  802752:	5f                   	pop    %edi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    

00802755 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	57                   	push   %edi
  802759:	56                   	push   %esi
  80275a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80275b:	ba 00 00 00 00       	mov    $0x0,%edx
  802760:	b8 02 00 00 00       	mov    $0x2,%eax
  802765:	89 d1                	mov    %edx,%ecx
  802767:	89 d3                	mov    %edx,%ebx
  802769:	89 d7                	mov    %edx,%edi
  80276b:	89 d6                	mov    %edx,%esi
  80276d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    

00802774 <sys_yield>:

void
sys_yield(void)
{
  802774:	55                   	push   %ebp
  802775:	89 e5                	mov    %esp,%ebp
  802777:	57                   	push   %edi
  802778:	56                   	push   %esi
  802779:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80277a:	ba 00 00 00 00       	mov    $0x0,%edx
  80277f:	b8 0b 00 00 00       	mov    $0xb,%eax
  802784:	89 d1                	mov    %edx,%ecx
  802786:	89 d3                	mov    %edx,%ebx
  802788:	89 d7                	mov    %edx,%edi
  80278a:	89 d6                	mov    %edx,%esi
  80278c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80278e:	5b                   	pop    %ebx
  80278f:	5e                   	pop    %esi
  802790:	5f                   	pop    %edi
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    

00802793 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802793:	55                   	push   %ebp
  802794:	89 e5                	mov    %esp,%ebp
  802796:	57                   	push   %edi
  802797:	56                   	push   %esi
  802798:	53                   	push   %ebx
  802799:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80279c:	be 00 00 00 00       	mov    $0x0,%esi
  8027a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8027a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027af:	89 f7                	mov    %esi,%edi
  8027b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027b3:	85 c0                	test   %eax,%eax
  8027b5:	7e 28                	jle    8027df <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027bb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8027c2:	00 
  8027c3:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  8027ca:	00 
  8027cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8027d2:	00 
  8027d3:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  8027da:	e8 74 f4 ff ff       	call   801c53 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8027df:	83 c4 2c             	add    $0x2c,%esp
  8027e2:	5b                   	pop    %ebx
  8027e3:	5e                   	pop    %esi
  8027e4:	5f                   	pop    %edi
  8027e5:	5d                   	pop    %ebp
  8027e6:	c3                   	ret    

008027e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8027e7:	55                   	push   %ebp
  8027e8:	89 e5                	mov    %esp,%ebp
  8027ea:	57                   	push   %edi
  8027eb:	56                   	push   %esi
  8027ec:	53                   	push   %ebx
  8027ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8027f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8027fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  802801:	8b 75 18             	mov    0x18(%ebp),%esi
  802804:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802806:	85 c0                	test   %eax,%eax
  802808:	7e 28                	jle    802832 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80280a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80280e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802815:	00 
  802816:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  80281d:	00 
  80281e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802825:	00 
  802826:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  80282d:	e8 21 f4 ff ff       	call   801c53 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802832:	83 c4 2c             	add    $0x2c,%esp
  802835:	5b                   	pop    %ebx
  802836:	5e                   	pop    %esi
  802837:	5f                   	pop    %edi
  802838:	5d                   	pop    %ebp
  802839:	c3                   	ret    

0080283a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80283a:	55                   	push   %ebp
  80283b:	89 e5                	mov    %esp,%ebp
  80283d:	57                   	push   %edi
  80283e:	56                   	push   %esi
  80283f:	53                   	push   %ebx
  802840:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802843:	bb 00 00 00 00       	mov    $0x0,%ebx
  802848:	b8 06 00 00 00       	mov    $0x6,%eax
  80284d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802850:	8b 55 08             	mov    0x8(%ebp),%edx
  802853:	89 df                	mov    %ebx,%edi
  802855:	89 de                	mov    %ebx,%esi
  802857:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802859:	85 c0                	test   %eax,%eax
  80285b:	7e 28                	jle    802885 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80285d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802861:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802868:	00 
  802869:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802870:	00 
  802871:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802878:	00 
  802879:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802880:	e8 ce f3 ff ff       	call   801c53 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802885:	83 c4 2c             	add    $0x2c,%esp
  802888:	5b                   	pop    %ebx
  802889:	5e                   	pop    %esi
  80288a:	5f                   	pop    %edi
  80288b:	5d                   	pop    %ebp
  80288c:	c3                   	ret    

0080288d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80288d:	55                   	push   %ebp
  80288e:	89 e5                	mov    %esp,%ebp
  802890:	57                   	push   %edi
  802891:	56                   	push   %esi
  802892:	53                   	push   %ebx
  802893:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802896:	bb 00 00 00 00       	mov    $0x0,%ebx
  80289b:	b8 08 00 00 00       	mov    $0x8,%eax
  8028a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8028a6:	89 df                	mov    %ebx,%edi
  8028a8:	89 de                	mov    %ebx,%esi
  8028aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028ac:	85 c0                	test   %eax,%eax
  8028ae:	7e 28                	jle    8028d8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8028bb:	00 
  8028bc:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  8028c3:	00 
  8028c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028cb:	00 
  8028cc:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  8028d3:	e8 7b f3 ff ff       	call   801c53 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8028d8:	83 c4 2c             	add    $0x2c,%esp
  8028db:	5b                   	pop    %ebx
  8028dc:	5e                   	pop    %esi
  8028dd:	5f                   	pop    %edi
  8028de:	5d                   	pop    %ebp
  8028df:	c3                   	ret    

008028e0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	57                   	push   %edi
  8028e4:	56                   	push   %esi
  8028e5:	53                   	push   %ebx
  8028e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8028f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8028f9:	89 df                	mov    %ebx,%edi
  8028fb:	89 de                	mov    %ebx,%esi
  8028fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028ff:	85 c0                	test   %eax,%eax
  802901:	7e 28                	jle    80292b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802903:	89 44 24 10          	mov    %eax,0x10(%esp)
  802907:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80290e:	00 
  80290f:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802916:	00 
  802917:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80291e:	00 
  80291f:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802926:	e8 28 f3 ff ff       	call   801c53 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80292b:	83 c4 2c             	add    $0x2c,%esp
  80292e:	5b                   	pop    %ebx
  80292f:	5e                   	pop    %esi
  802930:	5f                   	pop    %edi
  802931:	5d                   	pop    %ebp
  802932:	c3                   	ret    

00802933 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802933:	55                   	push   %ebp
  802934:	89 e5                	mov    %esp,%ebp
  802936:	57                   	push   %edi
  802937:	56                   	push   %esi
  802938:	53                   	push   %ebx
  802939:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80293c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802941:	b8 0a 00 00 00       	mov    $0xa,%eax
  802946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802949:	8b 55 08             	mov    0x8(%ebp),%edx
  80294c:	89 df                	mov    %ebx,%edi
  80294e:	89 de                	mov    %ebx,%esi
  802950:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802952:	85 c0                	test   %eax,%eax
  802954:	7e 28                	jle    80297e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802956:	89 44 24 10          	mov    %eax,0x10(%esp)
  80295a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802961:	00 
  802962:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802969:	00 
  80296a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802971:	00 
  802972:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802979:	e8 d5 f2 ff ff       	call   801c53 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80297e:	83 c4 2c             	add    $0x2c,%esp
  802981:	5b                   	pop    %ebx
  802982:	5e                   	pop    %esi
  802983:	5f                   	pop    %edi
  802984:	5d                   	pop    %ebp
  802985:	c3                   	ret    

00802986 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802986:	55                   	push   %ebp
  802987:	89 e5                	mov    %esp,%ebp
  802989:	57                   	push   %edi
  80298a:	56                   	push   %esi
  80298b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80298c:	be 00 00 00 00       	mov    $0x0,%esi
  802991:	b8 0c 00 00 00       	mov    $0xc,%eax
  802996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802999:	8b 55 08             	mov    0x8(%ebp),%edx
  80299c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80299f:	8b 7d 14             	mov    0x14(%ebp),%edi
  8029a2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8029a4:	5b                   	pop    %ebx
  8029a5:	5e                   	pop    %esi
  8029a6:	5f                   	pop    %edi
  8029a7:	5d                   	pop    %ebp
  8029a8:	c3                   	ret    

008029a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8029a9:	55                   	push   %ebp
  8029aa:	89 e5                	mov    %esp,%ebp
  8029ac:	57                   	push   %edi
  8029ad:	56                   	push   %esi
  8029ae:	53                   	push   %ebx
  8029af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8029b7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8029bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8029bf:	89 cb                	mov    %ecx,%ebx
  8029c1:	89 cf                	mov    %ecx,%edi
  8029c3:	89 ce                	mov    %ecx,%esi
  8029c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8029c7:	85 c0                	test   %eax,%eax
  8029c9:	7e 28                	jle    8029f3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029cf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8029d6:	00 
  8029d7:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  8029de:	00 
  8029df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029e6:	00 
  8029e7:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  8029ee:	e8 60 f2 ff ff       	call   801c53 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8029f3:	83 c4 2c             	add    $0x2c,%esp
  8029f6:	5b                   	pop    %ebx
  8029f7:	5e                   	pop    %esi
  8029f8:	5f                   	pop    %edi
  8029f9:	5d                   	pop    %ebp
  8029fa:	c3                   	ret    

008029fb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8029fb:	55                   	push   %ebp
  8029fc:	89 e5                	mov    %esp,%ebp
  8029fe:	57                   	push   %edi
  8029ff:	56                   	push   %esi
  802a00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a01:	ba 00 00 00 00       	mov    $0x0,%edx
  802a06:	b8 0e 00 00 00       	mov    $0xe,%eax
  802a0b:	89 d1                	mov    %edx,%ecx
  802a0d:	89 d3                	mov    %edx,%ebx
  802a0f:	89 d7                	mov    %edx,%edi
  802a11:	89 d6                	mov    %edx,%esi
  802a13:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  802a15:	5b                   	pop    %ebx
  802a16:	5e                   	pop    %esi
  802a17:	5f                   	pop    %edi
  802a18:	5d                   	pop    %ebp
  802a19:	c3                   	ret    

00802a1a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  802a1a:	55                   	push   %ebp
  802a1b:	89 e5                	mov    %esp,%ebp
  802a1d:	57                   	push   %edi
  802a1e:	56                   	push   %esi
  802a1f:	53                   	push   %ebx
  802a20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a23:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a28:	b8 0f 00 00 00       	mov    $0xf,%eax
  802a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a30:	8b 55 08             	mov    0x8(%ebp),%edx
  802a33:	89 df                	mov    %ebx,%edi
  802a35:	89 de                	mov    %ebx,%esi
  802a37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a39:	85 c0                	test   %eax,%eax
  802a3b:	7e 28                	jle    802a65 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a41:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  802a48:	00 
  802a49:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802a50:	00 
  802a51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a58:	00 
  802a59:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802a60:	e8 ee f1 ff ff       	call   801c53 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  802a65:	83 c4 2c             	add    $0x2c,%esp
  802a68:	5b                   	pop    %ebx
  802a69:	5e                   	pop    %esi
  802a6a:	5f                   	pop    %edi
  802a6b:	5d                   	pop    %ebp
  802a6c:	c3                   	ret    

00802a6d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  802a6d:	55                   	push   %ebp
  802a6e:	89 e5                	mov    %esp,%ebp
  802a70:	57                   	push   %edi
  802a71:	56                   	push   %esi
  802a72:	53                   	push   %ebx
  802a73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a76:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a7b:	b8 10 00 00 00       	mov    $0x10,%eax
  802a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a83:	8b 55 08             	mov    0x8(%ebp),%edx
  802a86:	89 df                	mov    %ebx,%edi
  802a88:	89 de                	mov    %ebx,%esi
  802a8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a8c:	85 c0                	test   %eax,%eax
  802a8e:	7e 28                	jle    802ab8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a90:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a94:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  802a9b:	00 
  802a9c:	c7 44 24 08 ff 4a 80 	movl   $0x804aff,0x8(%esp)
  802aa3:	00 
  802aa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802aab:	00 
  802aac:	c7 04 24 1c 4b 80 00 	movl   $0x804b1c,(%esp)
  802ab3:	e8 9b f1 ff ff       	call   801c53 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  802ab8:	83 c4 2c             	add    $0x2c,%esp
  802abb:	5b                   	pop    %ebx
  802abc:	5e                   	pop    %esi
  802abd:	5f                   	pop    %edi
  802abe:	5d                   	pop    %ebp
  802abf:	c3                   	ret    

00802ac0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ac0:	55                   	push   %ebp
  802ac1:	89 e5                	mov    %esp,%ebp
  802ac3:	53                   	push   %ebx
  802ac4:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ac7:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802ace:	75 2f                	jne    802aff <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802ad0:	e8 80 fc ff ff       	call   802755 <sys_getenvid>
  802ad5:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802ad7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802ade:	00 
  802adf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802ae6:	ee 
  802ae7:	89 04 24             	mov    %eax,(%esp)
  802aea:	e8 a4 fc ff ff       	call   802793 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802aef:	c7 44 24 04 0d 2b 80 	movl   $0x802b0d,0x4(%esp)
  802af6:	00 
  802af7:	89 1c 24             	mov    %ebx,(%esp)
  802afa:	e8 34 fe ff ff       	call   802933 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802aff:	8b 45 08             	mov    0x8(%ebp),%eax
  802b02:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802b07:	83 c4 14             	add    $0x14,%esp
  802b0a:	5b                   	pop    %ebx
  802b0b:	5d                   	pop    %ebp
  802b0c:	c3                   	ret    

00802b0d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b0d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b0e:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802b13:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b15:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802b18:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802b1d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802b21:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802b25:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802b27:	83 c4 08             	add    $0x8,%esp
	popal
  802b2a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802b2b:	83 c4 04             	add    $0x4,%esp
	popfl
  802b2e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802b2f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802b30:	c3                   	ret    
  802b31:	66 90                	xchg   %ax,%ax
  802b33:	66 90                	xchg   %ax,%ax
  802b35:	66 90                	xchg   %ax,%ax
  802b37:	66 90                	xchg   %ax,%ax
  802b39:	66 90                	xchg   %ax,%ax
  802b3b:	66 90                	xchg   %ax,%ax
  802b3d:	66 90                	xchg   %ax,%ax
  802b3f:	90                   	nop

00802b40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b40:	55                   	push   %ebp
  802b41:	89 e5                	mov    %esp,%ebp
  802b43:	56                   	push   %esi
  802b44:	53                   	push   %ebx
  802b45:	83 ec 10             	sub    $0x10,%esp
  802b48:	8b 75 08             	mov    0x8(%ebp),%esi
  802b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802b51:	85 c0                	test   %eax,%eax
  802b53:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802b58:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  802b5b:	89 04 24             	mov    %eax,(%esp)
  802b5e:	e8 46 fe ff ff       	call   8029a9 <sys_ipc_recv>

	if(ret < 0) {
  802b63:	85 c0                	test   %eax,%eax
  802b65:	79 16                	jns    802b7d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802b67:	85 f6                	test   %esi,%esi
  802b69:	74 06                	je     802b71 <ipc_recv+0x31>
  802b6b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802b71:	85 db                	test   %ebx,%ebx
  802b73:	74 3e                	je     802bb3 <ipc_recv+0x73>
  802b75:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802b7b:	eb 36                	jmp    802bb3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  802b7d:	e8 d3 fb ff ff       	call   802755 <sys_getenvid>
  802b82:	25 ff 03 00 00       	and    $0x3ff,%eax
  802b87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802b8f:	a3 10 a0 80 00       	mov    %eax,0x80a010

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802b94:	85 f6                	test   %esi,%esi
  802b96:	74 05                	je     802b9d <ipc_recv+0x5d>
  802b98:	8b 40 74             	mov    0x74(%eax),%eax
  802b9b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802b9d:	85 db                	test   %ebx,%ebx
  802b9f:	74 0a                	je     802bab <ipc_recv+0x6b>
  802ba1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802ba6:	8b 40 78             	mov    0x78(%eax),%eax
  802ba9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802bab:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  802bb3:	83 c4 10             	add    $0x10,%esp
  802bb6:	5b                   	pop    %ebx
  802bb7:	5e                   	pop    %esi
  802bb8:	5d                   	pop    %ebp
  802bb9:	c3                   	ret    

00802bba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802bba:	55                   	push   %ebp
  802bbb:	89 e5                	mov    %esp,%ebp
  802bbd:	57                   	push   %edi
  802bbe:	56                   	push   %esi
  802bbf:	53                   	push   %ebx
  802bc0:	83 ec 1c             	sub    $0x1c,%esp
  802bc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  802bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  802bcc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  802bce:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802bd3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802bd6:	8b 45 14             	mov    0x14(%ebp),%eax
  802bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bdd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802be1:	89 74 24 04          	mov    %esi,0x4(%esp)
  802be5:	89 3c 24             	mov    %edi,(%esp)
  802be8:	e8 99 fd ff ff       	call   802986 <sys_ipc_try_send>

		if(ret >= 0) break;
  802bed:	85 c0                	test   %eax,%eax
  802bef:	79 2c                	jns    802c1d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802bf1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802bf4:	74 20                	je     802c16 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bfa:	c7 44 24 08 2c 4b 80 	movl   $0x804b2c,0x8(%esp)
  802c01:	00 
  802c02:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802c09:	00 
  802c0a:	c7 04 24 5c 4b 80 00 	movl   $0x804b5c,(%esp)
  802c11:	e8 3d f0 ff ff       	call   801c53 <_panic>
		}
		sys_yield();
  802c16:	e8 59 fb ff ff       	call   802774 <sys_yield>
	}
  802c1b:	eb b9                	jmp    802bd6 <ipc_send+0x1c>
}
  802c1d:	83 c4 1c             	add    $0x1c,%esp
  802c20:	5b                   	pop    %ebx
  802c21:	5e                   	pop    %esi
  802c22:	5f                   	pop    %edi
  802c23:	5d                   	pop    %ebp
  802c24:	c3                   	ret    

00802c25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c25:	55                   	push   %ebp
  802c26:	89 e5                	mov    %esp,%ebp
  802c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802c2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c30:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802c33:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c39:	8b 52 50             	mov    0x50(%edx),%edx
  802c3c:	39 ca                	cmp    %ecx,%edx
  802c3e:	75 0d                	jne    802c4d <ipc_find_env+0x28>
			return envs[i].env_id;
  802c40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c43:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802c48:	8b 40 40             	mov    0x40(%eax),%eax
  802c4b:	eb 0e                	jmp    802c5b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c4d:	83 c0 01             	add    $0x1,%eax
  802c50:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c55:	75 d9                	jne    802c30 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c57:	66 b8 00 00          	mov    $0x0,%ax
}
  802c5b:	5d                   	pop    %ebp
  802c5c:	c3                   	ret    
  802c5d:	66 90                	xchg   %ax,%ax
  802c5f:	90                   	nop

00802c60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802c60:	55                   	push   %ebp
  802c61:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802c63:	8b 45 08             	mov    0x8(%ebp),%eax
  802c66:	05 00 00 00 30       	add    $0x30000000,%eax
  802c6b:	c1 e8 0c             	shr    $0xc,%eax
}
  802c6e:	5d                   	pop    %ebp
  802c6f:	c3                   	ret    

00802c70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802c70:	55                   	push   %ebp
  802c71:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802c73:	8b 45 08             	mov    0x8(%ebp),%eax
  802c76:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  802c7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802c80:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802c85:	5d                   	pop    %ebp
  802c86:	c3                   	ret    

00802c87 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802c87:	55                   	push   %ebp
  802c88:	89 e5                	mov    %esp,%ebp
  802c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c8d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802c92:	89 c2                	mov    %eax,%edx
  802c94:	c1 ea 16             	shr    $0x16,%edx
  802c97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c9e:	f6 c2 01             	test   $0x1,%dl
  802ca1:	74 11                	je     802cb4 <fd_alloc+0x2d>
  802ca3:	89 c2                	mov    %eax,%edx
  802ca5:	c1 ea 0c             	shr    $0xc,%edx
  802ca8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802caf:	f6 c2 01             	test   $0x1,%dl
  802cb2:	75 09                	jne    802cbd <fd_alloc+0x36>
			*fd_store = fd;
  802cb4:	89 01                	mov    %eax,(%ecx)
			return 0;
  802cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  802cbb:	eb 17                	jmp    802cd4 <fd_alloc+0x4d>
  802cbd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802cc2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802cc7:	75 c9                	jne    802c92 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802cc9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802ccf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802cd4:	5d                   	pop    %ebp
  802cd5:	c3                   	ret    

00802cd6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802cd6:	55                   	push   %ebp
  802cd7:	89 e5                	mov    %esp,%ebp
  802cd9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802cdc:	83 f8 1f             	cmp    $0x1f,%eax
  802cdf:	77 36                	ja     802d17 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802ce1:	c1 e0 0c             	shl    $0xc,%eax
  802ce4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802ce9:	89 c2                	mov    %eax,%edx
  802ceb:	c1 ea 16             	shr    $0x16,%edx
  802cee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cf5:	f6 c2 01             	test   $0x1,%dl
  802cf8:	74 24                	je     802d1e <fd_lookup+0x48>
  802cfa:	89 c2                	mov    %eax,%edx
  802cfc:	c1 ea 0c             	shr    $0xc,%edx
  802cff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802d06:	f6 c2 01             	test   $0x1,%dl
  802d09:	74 1a                	je     802d25 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d0e:	89 02                	mov    %eax,(%edx)
	return 0;
  802d10:	b8 00 00 00 00       	mov    $0x0,%eax
  802d15:	eb 13                	jmp    802d2a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d1c:	eb 0c                	jmp    802d2a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d23:	eb 05                	jmp    802d2a <fd_lookup+0x54>
  802d25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802d2a:	5d                   	pop    %ebp
  802d2b:	c3                   	ret    

00802d2c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802d2c:	55                   	push   %ebp
  802d2d:	89 e5                	mov    %esp,%ebp
  802d2f:	83 ec 18             	sub    $0x18,%esp
  802d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  802d35:	ba 00 00 00 00       	mov    $0x0,%edx
  802d3a:	eb 13                	jmp    802d4f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  802d3c:	39 08                	cmp    %ecx,(%eax)
  802d3e:	75 0c                	jne    802d4c <dev_lookup+0x20>
			*dev = devtab[i];
  802d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d43:	89 01                	mov    %eax,(%ecx)
			return 0;
  802d45:	b8 00 00 00 00       	mov    $0x0,%eax
  802d4a:	eb 38                	jmp    802d84 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802d4c:	83 c2 01             	add    $0x1,%edx
  802d4f:	8b 04 95 e8 4b 80 00 	mov    0x804be8(,%edx,4),%eax
  802d56:	85 c0                	test   %eax,%eax
  802d58:	75 e2                	jne    802d3c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802d5a:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802d5f:	8b 40 48             	mov    0x48(%eax),%eax
  802d62:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d6a:	c7 04 24 68 4b 80 00 	movl   $0x804b68,(%esp)
  802d71:	e8 d6 ef ff ff       	call   801d4c <cprintf>
	*dev = 0;
  802d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802d7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802d84:	c9                   	leave  
  802d85:	c3                   	ret    

00802d86 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802d86:	55                   	push   %ebp
  802d87:	89 e5                	mov    %esp,%ebp
  802d89:	56                   	push   %esi
  802d8a:	53                   	push   %ebx
  802d8b:	83 ec 20             	sub    $0x20,%esp
  802d8e:	8b 75 08             	mov    0x8(%ebp),%esi
  802d91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d97:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802d9b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802da1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802da4:	89 04 24             	mov    %eax,(%esp)
  802da7:	e8 2a ff ff ff       	call   802cd6 <fd_lookup>
  802dac:	85 c0                	test   %eax,%eax
  802dae:	78 05                	js     802db5 <fd_close+0x2f>
	    || fd != fd2)
  802db0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802db3:	74 0c                	je     802dc1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  802db5:	84 db                	test   %bl,%bl
  802db7:	ba 00 00 00 00       	mov    $0x0,%edx
  802dbc:	0f 44 c2             	cmove  %edx,%eax
  802dbf:	eb 3f                	jmp    802e00 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dc8:	8b 06                	mov    (%esi),%eax
  802dca:	89 04 24             	mov    %eax,(%esp)
  802dcd:	e8 5a ff ff ff       	call   802d2c <dev_lookup>
  802dd2:	89 c3                	mov    %eax,%ebx
  802dd4:	85 c0                	test   %eax,%eax
  802dd6:	78 16                	js     802dee <fd_close+0x68>
		if (dev->dev_close)
  802dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ddb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802dde:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802de3:	85 c0                	test   %eax,%eax
  802de5:	74 07                	je     802dee <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  802de7:	89 34 24             	mov    %esi,(%esp)
  802dea:	ff d0                	call   *%eax
  802dec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802dee:	89 74 24 04          	mov    %esi,0x4(%esp)
  802df2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802df9:	e8 3c fa ff ff       	call   80283a <sys_page_unmap>
	return r;
  802dfe:	89 d8                	mov    %ebx,%eax
}
  802e00:	83 c4 20             	add    $0x20,%esp
  802e03:	5b                   	pop    %ebx
  802e04:	5e                   	pop    %esi
  802e05:	5d                   	pop    %ebp
  802e06:	c3                   	ret    

00802e07 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802e07:	55                   	push   %ebp
  802e08:	89 e5                	mov    %esp,%ebp
  802e0a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e14:	8b 45 08             	mov    0x8(%ebp),%eax
  802e17:	89 04 24             	mov    %eax,(%esp)
  802e1a:	e8 b7 fe ff ff       	call   802cd6 <fd_lookup>
  802e1f:	89 c2                	mov    %eax,%edx
  802e21:	85 d2                	test   %edx,%edx
  802e23:	78 13                	js     802e38 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  802e25:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e2c:	00 
  802e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e30:	89 04 24             	mov    %eax,(%esp)
  802e33:	e8 4e ff ff ff       	call   802d86 <fd_close>
}
  802e38:	c9                   	leave  
  802e39:	c3                   	ret    

00802e3a <close_all>:

void
close_all(void)
{
  802e3a:	55                   	push   %ebp
  802e3b:	89 e5                	mov    %esp,%ebp
  802e3d:	53                   	push   %ebx
  802e3e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802e41:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802e46:	89 1c 24             	mov    %ebx,(%esp)
  802e49:	e8 b9 ff ff ff       	call   802e07 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802e4e:	83 c3 01             	add    $0x1,%ebx
  802e51:	83 fb 20             	cmp    $0x20,%ebx
  802e54:	75 f0                	jne    802e46 <close_all+0xc>
		close(i);
}
  802e56:	83 c4 14             	add    $0x14,%esp
  802e59:	5b                   	pop    %ebx
  802e5a:	5d                   	pop    %ebp
  802e5b:	c3                   	ret    

00802e5c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802e5c:	55                   	push   %ebp
  802e5d:	89 e5                	mov    %esp,%ebp
  802e5f:	57                   	push   %edi
  802e60:	56                   	push   %esi
  802e61:	53                   	push   %ebx
  802e62:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802e65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e6f:	89 04 24             	mov    %eax,(%esp)
  802e72:	e8 5f fe ff ff       	call   802cd6 <fd_lookup>
  802e77:	89 c2                	mov    %eax,%edx
  802e79:	85 d2                	test   %edx,%edx
  802e7b:	0f 88 e1 00 00 00    	js     802f62 <dup+0x106>
		return r;
	close(newfdnum);
  802e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e84:	89 04 24             	mov    %eax,(%esp)
  802e87:	e8 7b ff ff ff       	call   802e07 <close>

	newfd = INDEX2FD(newfdnum);
  802e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802e8f:	c1 e3 0c             	shl    $0xc,%ebx
  802e92:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e9b:	89 04 24             	mov    %eax,(%esp)
  802e9e:	e8 cd fd ff ff       	call   802c70 <fd2data>
  802ea3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  802ea5:	89 1c 24             	mov    %ebx,(%esp)
  802ea8:	e8 c3 fd ff ff       	call   802c70 <fd2data>
  802ead:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802eaf:	89 f0                	mov    %esi,%eax
  802eb1:	c1 e8 16             	shr    $0x16,%eax
  802eb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ebb:	a8 01                	test   $0x1,%al
  802ebd:	74 43                	je     802f02 <dup+0xa6>
  802ebf:	89 f0                	mov    %esi,%eax
  802ec1:	c1 e8 0c             	shr    $0xc,%eax
  802ec4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802ecb:	f6 c2 01             	test   $0x1,%dl
  802ece:	74 32                	je     802f02 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ed0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ed7:	25 07 0e 00 00       	and    $0xe07,%eax
  802edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ee0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ee4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802eeb:	00 
  802eec:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ef0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ef7:	e8 eb f8 ff ff       	call   8027e7 <sys_page_map>
  802efc:	89 c6                	mov    %eax,%esi
  802efe:	85 c0                	test   %eax,%eax
  802f00:	78 3e                	js     802f40 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f05:	89 c2                	mov    %eax,%edx
  802f07:	c1 ea 0c             	shr    $0xc,%edx
  802f0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802f11:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802f17:	89 54 24 10          	mov    %edx,0x10(%esp)
  802f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802f1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f26:	00 
  802f27:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f32:	e8 b0 f8 ff ff       	call   8027e7 <sys_page_map>
  802f37:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  802f39:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f3c:	85 f6                	test   %esi,%esi
  802f3e:	79 22                	jns    802f62 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802f40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f4b:	e8 ea f8 ff ff       	call   80283a <sys_page_unmap>
	sys_page_unmap(0, nva);
  802f50:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802f54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f5b:	e8 da f8 ff ff       	call   80283a <sys_page_unmap>
	return r;
  802f60:	89 f0                	mov    %esi,%eax
}
  802f62:	83 c4 3c             	add    $0x3c,%esp
  802f65:	5b                   	pop    %ebx
  802f66:	5e                   	pop    %esi
  802f67:	5f                   	pop    %edi
  802f68:	5d                   	pop    %ebp
  802f69:	c3                   	ret    

00802f6a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802f6a:	55                   	push   %ebp
  802f6b:	89 e5                	mov    %esp,%ebp
  802f6d:	53                   	push   %ebx
  802f6e:	83 ec 24             	sub    $0x24,%esp
  802f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f7b:	89 1c 24             	mov    %ebx,(%esp)
  802f7e:	e8 53 fd ff ff       	call   802cd6 <fd_lookup>
  802f83:	89 c2                	mov    %eax,%edx
  802f85:	85 d2                	test   %edx,%edx
  802f87:	78 6d                	js     802ff6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f93:	8b 00                	mov    (%eax),%eax
  802f95:	89 04 24             	mov    %eax,(%esp)
  802f98:	e8 8f fd ff ff       	call   802d2c <dev_lookup>
  802f9d:	85 c0                	test   %eax,%eax
  802f9f:	78 55                	js     802ff6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fa4:	8b 50 08             	mov    0x8(%eax),%edx
  802fa7:	83 e2 03             	and    $0x3,%edx
  802faa:	83 fa 01             	cmp    $0x1,%edx
  802fad:	75 23                	jne    802fd2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802faf:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802fb4:	8b 40 48             	mov    0x48(%eax),%eax
  802fb7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fbf:	c7 04 24 ac 4b 80 00 	movl   $0x804bac,(%esp)
  802fc6:	e8 81 ed ff ff       	call   801d4c <cprintf>
		return -E_INVAL;
  802fcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802fd0:	eb 24                	jmp    802ff6 <read+0x8c>
	}
	if (!dev->dev_read)
  802fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fd5:	8b 52 08             	mov    0x8(%edx),%edx
  802fd8:	85 d2                	test   %edx,%edx
  802fda:	74 15                	je     802ff1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802fdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802fdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802fe6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802fea:	89 04 24             	mov    %eax,(%esp)
  802fed:	ff d2                	call   *%edx
  802fef:	eb 05                	jmp    802ff6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802ff1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802ff6:	83 c4 24             	add    $0x24,%esp
  802ff9:	5b                   	pop    %ebx
  802ffa:	5d                   	pop    %ebp
  802ffb:	c3                   	ret    

00802ffc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802ffc:	55                   	push   %ebp
  802ffd:	89 e5                	mov    %esp,%ebp
  802fff:	57                   	push   %edi
  803000:	56                   	push   %esi
  803001:	53                   	push   %ebx
  803002:	83 ec 1c             	sub    $0x1c,%esp
  803005:	8b 7d 08             	mov    0x8(%ebp),%edi
  803008:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80300b:	bb 00 00 00 00       	mov    $0x0,%ebx
  803010:	eb 23                	jmp    803035 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  803012:	89 f0                	mov    %esi,%eax
  803014:	29 d8                	sub    %ebx,%eax
  803016:	89 44 24 08          	mov    %eax,0x8(%esp)
  80301a:	89 d8                	mov    %ebx,%eax
  80301c:	03 45 0c             	add    0xc(%ebp),%eax
  80301f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803023:	89 3c 24             	mov    %edi,(%esp)
  803026:	e8 3f ff ff ff       	call   802f6a <read>
		if (m < 0)
  80302b:	85 c0                	test   %eax,%eax
  80302d:	78 10                	js     80303f <readn+0x43>
			return m;
		if (m == 0)
  80302f:	85 c0                	test   %eax,%eax
  803031:	74 0a                	je     80303d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803033:	01 c3                	add    %eax,%ebx
  803035:	39 f3                	cmp    %esi,%ebx
  803037:	72 d9                	jb     803012 <readn+0x16>
  803039:	89 d8                	mov    %ebx,%eax
  80303b:	eb 02                	jmp    80303f <readn+0x43>
  80303d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80303f:	83 c4 1c             	add    $0x1c,%esp
  803042:	5b                   	pop    %ebx
  803043:	5e                   	pop    %esi
  803044:	5f                   	pop    %edi
  803045:	5d                   	pop    %ebp
  803046:	c3                   	ret    

00803047 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803047:	55                   	push   %ebp
  803048:	89 e5                	mov    %esp,%ebp
  80304a:	53                   	push   %ebx
  80304b:	83 ec 24             	sub    $0x24,%esp
  80304e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803051:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803054:	89 44 24 04          	mov    %eax,0x4(%esp)
  803058:	89 1c 24             	mov    %ebx,(%esp)
  80305b:	e8 76 fc ff ff       	call   802cd6 <fd_lookup>
  803060:	89 c2                	mov    %eax,%edx
  803062:	85 d2                	test   %edx,%edx
  803064:	78 68                	js     8030ce <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80306d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803070:	8b 00                	mov    (%eax),%eax
  803072:	89 04 24             	mov    %eax,(%esp)
  803075:	e8 b2 fc ff ff       	call   802d2c <dev_lookup>
  80307a:	85 c0                	test   %eax,%eax
  80307c:	78 50                	js     8030ce <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80307e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803081:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803085:	75 23                	jne    8030aa <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  803087:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80308c:	8b 40 48             	mov    0x48(%eax),%eax
  80308f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803093:	89 44 24 04          	mov    %eax,0x4(%esp)
  803097:	c7 04 24 c8 4b 80 00 	movl   $0x804bc8,(%esp)
  80309e:	e8 a9 ec ff ff       	call   801d4c <cprintf>
		return -E_INVAL;
  8030a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8030a8:	eb 24                	jmp    8030ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8030aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8030b0:	85 d2                	test   %edx,%edx
  8030b2:	74 15                	je     8030c9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8030b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8030b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8030c2:	89 04 24             	mov    %eax,(%esp)
  8030c5:	ff d2                	call   *%edx
  8030c7:	eb 05                	jmp    8030ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8030c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8030ce:	83 c4 24             	add    $0x24,%esp
  8030d1:	5b                   	pop    %ebx
  8030d2:	5d                   	pop    %ebp
  8030d3:	c3                   	ret    

008030d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8030d4:	55                   	push   %ebp
  8030d5:	89 e5                	mov    %esp,%ebp
  8030d7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8030dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e4:	89 04 24             	mov    %eax,(%esp)
  8030e7:	e8 ea fb ff ff       	call   802cd6 <fd_lookup>
  8030ec:	85 c0                	test   %eax,%eax
  8030ee:	78 0e                	js     8030fe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8030f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8030f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8030f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030fe:	c9                   	leave  
  8030ff:	c3                   	ret    

00803100 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803100:	55                   	push   %ebp
  803101:	89 e5                	mov    %esp,%ebp
  803103:	53                   	push   %ebx
  803104:	83 ec 24             	sub    $0x24,%esp
  803107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80310a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80310d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803111:	89 1c 24             	mov    %ebx,(%esp)
  803114:	e8 bd fb ff ff       	call   802cd6 <fd_lookup>
  803119:	89 c2                	mov    %eax,%edx
  80311b:	85 d2                	test   %edx,%edx
  80311d:	78 61                	js     803180 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80311f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803122:	89 44 24 04          	mov    %eax,0x4(%esp)
  803126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803129:	8b 00                	mov    (%eax),%eax
  80312b:	89 04 24             	mov    %eax,(%esp)
  80312e:	e8 f9 fb ff ff       	call   802d2c <dev_lookup>
  803133:	85 c0                	test   %eax,%eax
  803135:	78 49                	js     803180 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80313a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80313e:	75 23                	jne    803163 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803140:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  803145:	8b 40 48             	mov    0x48(%eax),%eax
  803148:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80314c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803150:	c7 04 24 88 4b 80 00 	movl   $0x804b88,(%esp)
  803157:	e8 f0 eb ff ff       	call   801d4c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80315c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803161:	eb 1d                	jmp    803180 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  803163:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803166:	8b 52 18             	mov    0x18(%edx),%edx
  803169:	85 d2                	test   %edx,%edx
  80316b:	74 0e                	je     80317b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80316d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803170:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803174:	89 04 24             	mov    %eax,(%esp)
  803177:	ff d2                	call   *%edx
  803179:	eb 05                	jmp    803180 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80317b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  803180:	83 c4 24             	add    $0x24,%esp
  803183:	5b                   	pop    %ebx
  803184:	5d                   	pop    %ebp
  803185:	c3                   	ret    

00803186 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  803186:	55                   	push   %ebp
  803187:	89 e5                	mov    %esp,%ebp
  803189:	53                   	push   %ebx
  80318a:	83 ec 24             	sub    $0x24,%esp
  80318d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803190:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803193:	89 44 24 04          	mov    %eax,0x4(%esp)
  803197:	8b 45 08             	mov    0x8(%ebp),%eax
  80319a:	89 04 24             	mov    %eax,(%esp)
  80319d:	e8 34 fb ff ff       	call   802cd6 <fd_lookup>
  8031a2:	89 c2                	mov    %eax,%edx
  8031a4:	85 d2                	test   %edx,%edx
  8031a6:	78 52                	js     8031fa <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8031a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031b2:	8b 00                	mov    (%eax),%eax
  8031b4:	89 04 24             	mov    %eax,(%esp)
  8031b7:	e8 70 fb ff ff       	call   802d2c <dev_lookup>
  8031bc:	85 c0                	test   %eax,%eax
  8031be:	78 3a                	js     8031fa <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8031c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8031c7:	74 2c                	je     8031f5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8031c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8031cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8031d3:	00 00 00 
	stat->st_isdir = 0;
  8031d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8031dd:	00 00 00 
	stat->st_dev = dev;
  8031e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8031e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8031ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8031ed:	89 14 24             	mov    %edx,(%esp)
  8031f0:	ff 50 14             	call   *0x14(%eax)
  8031f3:	eb 05                	jmp    8031fa <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8031f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8031fa:	83 c4 24             	add    $0x24,%esp
  8031fd:	5b                   	pop    %ebx
  8031fe:	5d                   	pop    %ebp
  8031ff:	c3                   	ret    

00803200 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803200:	55                   	push   %ebp
  803201:	89 e5                	mov    %esp,%ebp
  803203:	56                   	push   %esi
  803204:	53                   	push   %ebx
  803205:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  803208:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80320f:	00 
  803210:	8b 45 08             	mov    0x8(%ebp),%eax
  803213:	89 04 24             	mov    %eax,(%esp)
  803216:	e8 28 02 00 00       	call   803443 <open>
  80321b:	89 c3                	mov    %eax,%ebx
  80321d:	85 db                	test   %ebx,%ebx
  80321f:	78 1b                	js     80323c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803221:	8b 45 0c             	mov    0xc(%ebp),%eax
  803224:	89 44 24 04          	mov    %eax,0x4(%esp)
  803228:	89 1c 24             	mov    %ebx,(%esp)
  80322b:	e8 56 ff ff ff       	call   803186 <fstat>
  803230:	89 c6                	mov    %eax,%esi
	close(fd);
  803232:	89 1c 24             	mov    %ebx,(%esp)
  803235:	e8 cd fb ff ff       	call   802e07 <close>
	return r;
  80323a:	89 f0                	mov    %esi,%eax
}
  80323c:	83 c4 10             	add    $0x10,%esp
  80323f:	5b                   	pop    %ebx
  803240:	5e                   	pop    %esi
  803241:	5d                   	pop    %ebp
  803242:	c3                   	ret    

00803243 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803243:	55                   	push   %ebp
  803244:	89 e5                	mov    %esp,%ebp
  803246:	56                   	push   %esi
  803247:	53                   	push   %ebx
  803248:	83 ec 10             	sub    $0x10,%esp
  80324b:	89 c6                	mov    %eax,%esi
  80324d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80324f:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803256:	75 11                	jne    803269 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803258:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80325f:	e8 c1 f9 ff ff       	call   802c25 <ipc_find_env>
  803264:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803269:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803270:	00 
  803271:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  803278:	00 
  803279:	89 74 24 04          	mov    %esi,0x4(%esp)
  80327d:	a1 00 a0 80 00       	mov    0x80a000,%eax
  803282:	89 04 24             	mov    %eax,(%esp)
  803285:	e8 30 f9 ff ff       	call   802bba <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80328a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803291:	00 
  803292:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80329d:	e8 9e f8 ff ff       	call   802b40 <ipc_recv>
}
  8032a2:	83 c4 10             	add    $0x10,%esp
  8032a5:	5b                   	pop    %ebx
  8032a6:	5e                   	pop    %esi
  8032a7:	5d                   	pop    %ebp
  8032a8:	c3                   	ret    

008032a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8032a9:	55                   	push   %ebp
  8032aa:	89 e5                	mov    %esp,%ebp
  8032ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8032af:	8b 45 08             	mov    0x8(%ebp),%eax
  8032b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8032b5:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8032ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032bd:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8032c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8032c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8032cc:	e8 72 ff ff ff       	call   803243 <fsipc>
}
  8032d1:	c9                   	leave  
  8032d2:	c3                   	ret    

008032d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8032d3:	55                   	push   %ebp
  8032d4:	89 e5                	mov    %esp,%ebp
  8032d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8032d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8032dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8032df:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8032e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8032e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8032ee:	e8 50 ff ff ff       	call   803243 <fsipc>
}
  8032f3:	c9                   	leave  
  8032f4:	c3                   	ret    

008032f5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8032f5:	55                   	push   %ebp
  8032f6:	89 e5                	mov    %esp,%ebp
  8032f8:	53                   	push   %ebx
  8032f9:	83 ec 14             	sub    $0x14,%esp
  8032fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8032ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803302:	8b 40 0c             	mov    0xc(%eax),%eax
  803305:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80330a:	ba 00 00 00 00       	mov    $0x0,%edx
  80330f:	b8 05 00 00 00       	mov    $0x5,%eax
  803314:	e8 2a ff ff ff       	call   803243 <fsipc>
  803319:	89 c2                	mov    %eax,%edx
  80331b:	85 d2                	test   %edx,%edx
  80331d:	78 2b                	js     80334a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80331f:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803326:	00 
  803327:	89 1c 24             	mov    %ebx,(%esp)
  80332a:	e8 48 f0 ff ff       	call   802377 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80332f:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803334:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80333a:	a1 84 b0 80 00       	mov    0x80b084,%eax
  80333f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803345:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80334a:	83 c4 14             	add    $0x14,%esp
  80334d:	5b                   	pop    %ebx
  80334e:	5d                   	pop    %ebp
  80334f:	c3                   	ret    

00803350 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803350:	55                   	push   %ebp
  803351:	89 e5                	mov    %esp,%ebp
  803353:	83 ec 18             	sub    $0x18,%esp
  803356:	8b 45 10             	mov    0x10(%ebp),%eax
  803359:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80335e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  803363:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803366:	8b 55 08             	mov    0x8(%ebp),%edx
  803369:	8b 52 0c             	mov    0xc(%edx),%edx
  80336c:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  803372:	a3 04 b0 80 00       	mov    %eax,0x80b004

	memmove(fsipcbuf.write.req_buf, buf, n);
  803377:	89 44 24 08          	mov    %eax,0x8(%esp)
  80337b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80337e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803382:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  803389:	e8 86 f1 ff ff       	call   802514 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80338e:	ba 00 00 00 00       	mov    $0x0,%edx
  803393:	b8 04 00 00 00       	mov    $0x4,%eax
  803398:	e8 a6 fe ff ff       	call   803243 <fsipc>
}
  80339d:	c9                   	leave  
  80339e:	c3                   	ret    

0080339f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80339f:	55                   	push   %ebp
  8033a0:	89 e5                	mov    %esp,%ebp
  8033a2:	56                   	push   %esi
  8033a3:	53                   	push   %ebx
  8033a4:	83 ec 10             	sub    $0x10,%esp
  8033a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8033aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8033b0:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8033b5:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8033bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8033c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8033c5:	e8 79 fe ff ff       	call   803243 <fsipc>
  8033ca:	89 c3                	mov    %eax,%ebx
  8033cc:	85 c0                	test   %eax,%eax
  8033ce:	78 6a                	js     80343a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8033d0:	39 c6                	cmp    %eax,%esi
  8033d2:	73 24                	jae    8033f8 <devfile_read+0x59>
  8033d4:	c7 44 24 0c fc 4b 80 	movl   $0x804bfc,0xc(%esp)
  8033db:	00 
  8033dc:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8033e3:	00 
  8033e4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8033eb:	00 
  8033ec:	c7 04 24 03 4c 80 00 	movl   $0x804c03,(%esp)
  8033f3:	e8 5b e8 ff ff       	call   801c53 <_panic>
	assert(r <= PGSIZE);
  8033f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8033fd:	7e 24                	jle    803423 <devfile_read+0x84>
  8033ff:	c7 44 24 0c 0e 4c 80 	movl   $0x804c0e,0xc(%esp)
  803406:	00 
  803407:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  80340e:	00 
  80340f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  803416:	00 
  803417:	c7 04 24 03 4c 80 00 	movl   $0x804c03,(%esp)
  80341e:	e8 30 e8 ff ff       	call   801c53 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803423:	89 44 24 08          	mov    %eax,0x8(%esp)
  803427:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80342e:	00 
  80342f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803432:	89 04 24             	mov    %eax,(%esp)
  803435:	e8 da f0 ff ff       	call   802514 <memmove>
	return r;
}
  80343a:	89 d8                	mov    %ebx,%eax
  80343c:	83 c4 10             	add    $0x10,%esp
  80343f:	5b                   	pop    %ebx
  803440:	5e                   	pop    %esi
  803441:	5d                   	pop    %ebp
  803442:	c3                   	ret    

00803443 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803443:	55                   	push   %ebp
  803444:	89 e5                	mov    %esp,%ebp
  803446:	53                   	push   %ebx
  803447:	83 ec 24             	sub    $0x24,%esp
  80344a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80344d:	89 1c 24             	mov    %ebx,(%esp)
  803450:	e8 eb ee ff ff       	call   802340 <strlen>
  803455:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80345a:	7f 60                	jg     8034bc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80345c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80345f:	89 04 24             	mov    %eax,(%esp)
  803462:	e8 20 f8 ff ff       	call   802c87 <fd_alloc>
  803467:	89 c2                	mov    %eax,%edx
  803469:	85 d2                	test   %edx,%edx
  80346b:	78 54                	js     8034c1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80346d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803471:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803478:	e8 fa ee ff ff       	call   802377 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80347d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803480:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803488:	b8 01 00 00 00       	mov    $0x1,%eax
  80348d:	e8 b1 fd ff ff       	call   803243 <fsipc>
  803492:	89 c3                	mov    %eax,%ebx
  803494:	85 c0                	test   %eax,%eax
  803496:	79 17                	jns    8034af <open+0x6c>
		fd_close(fd, 0);
  803498:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80349f:	00 
  8034a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034a3:	89 04 24             	mov    %eax,(%esp)
  8034a6:	e8 db f8 ff ff       	call   802d86 <fd_close>
		return r;
  8034ab:	89 d8                	mov    %ebx,%eax
  8034ad:	eb 12                	jmp    8034c1 <open+0x7e>
	}

	return fd2num(fd);
  8034af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034b2:	89 04 24             	mov    %eax,(%esp)
  8034b5:	e8 a6 f7 ff ff       	call   802c60 <fd2num>
  8034ba:	eb 05                	jmp    8034c1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8034bc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8034c1:	83 c4 24             	add    $0x24,%esp
  8034c4:	5b                   	pop    %ebx
  8034c5:	5d                   	pop    %ebp
  8034c6:	c3                   	ret    

008034c7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8034c7:	55                   	push   %ebp
  8034c8:	89 e5                	mov    %esp,%ebp
  8034ca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8034cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8034d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8034d7:	e8 67 fd ff ff       	call   803243 <fsipc>
}
  8034dc:	c9                   	leave  
  8034dd:	c3                   	ret    

008034de <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034de:	55                   	push   %ebp
  8034df:	89 e5                	mov    %esp,%ebp
  8034e1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034e4:	89 d0                	mov    %edx,%eax
  8034e6:	c1 e8 16             	shr    $0x16,%eax
  8034e9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8034f0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034f5:	f6 c1 01             	test   $0x1,%cl
  8034f8:	74 1d                	je     803517 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8034fa:	c1 ea 0c             	shr    $0xc,%edx
  8034fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803504:	f6 c2 01             	test   $0x1,%dl
  803507:	74 0e                	je     803517 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803509:	c1 ea 0c             	shr    $0xc,%edx
  80350c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803513:	ef 
  803514:	0f b7 c0             	movzwl %ax,%eax
}
  803517:	5d                   	pop    %ebp
  803518:	c3                   	ret    
  803519:	66 90                	xchg   %ax,%ax
  80351b:	66 90                	xchg   %ax,%ax
  80351d:	66 90                	xchg   %ax,%ax
  80351f:	90                   	nop

00803520 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803520:	55                   	push   %ebp
  803521:	89 e5                	mov    %esp,%ebp
  803523:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  803526:	c7 44 24 04 1a 4c 80 	movl   $0x804c1a,0x4(%esp)
  80352d:	00 
  80352e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803531:	89 04 24             	mov    %eax,(%esp)
  803534:	e8 3e ee ff ff       	call   802377 <strcpy>
	return 0;
}
  803539:	b8 00 00 00 00       	mov    $0x0,%eax
  80353e:	c9                   	leave  
  80353f:	c3                   	ret    

00803540 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803540:	55                   	push   %ebp
  803541:	89 e5                	mov    %esp,%ebp
  803543:	53                   	push   %ebx
  803544:	83 ec 14             	sub    $0x14,%esp
  803547:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80354a:	89 1c 24             	mov    %ebx,(%esp)
  80354d:	e8 8c ff ff ff       	call   8034de <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803552:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  803557:	83 f8 01             	cmp    $0x1,%eax
  80355a:	75 0d                	jne    803569 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80355c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80355f:	89 04 24             	mov    %eax,(%esp)
  803562:	e8 29 03 00 00       	call   803890 <nsipc_close>
  803567:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  803569:	89 d0                	mov    %edx,%eax
  80356b:	83 c4 14             	add    $0x14,%esp
  80356e:	5b                   	pop    %ebx
  80356f:	5d                   	pop    %ebp
  803570:	c3                   	ret    

00803571 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803571:	55                   	push   %ebp
  803572:	89 e5                	mov    %esp,%ebp
  803574:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803577:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80357e:	00 
  80357f:	8b 45 10             	mov    0x10(%ebp),%eax
  803582:	89 44 24 08          	mov    %eax,0x8(%esp)
  803586:	8b 45 0c             	mov    0xc(%ebp),%eax
  803589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80358d:	8b 45 08             	mov    0x8(%ebp),%eax
  803590:	8b 40 0c             	mov    0xc(%eax),%eax
  803593:	89 04 24             	mov    %eax,(%esp)
  803596:	e8 f0 03 00 00       	call   80398b <nsipc_send>
}
  80359b:	c9                   	leave  
  80359c:	c3                   	ret    

0080359d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80359d:	55                   	push   %ebp
  80359e:	89 e5                	mov    %esp,%ebp
  8035a0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8035a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8035aa:	00 
  8035ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8035ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8035bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8035bf:	89 04 24             	mov    %eax,(%esp)
  8035c2:	e8 44 03 00 00       	call   80390b <nsipc_recv>
}
  8035c7:	c9                   	leave  
  8035c8:	c3                   	ret    

008035c9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8035c9:	55                   	push   %ebp
  8035ca:	89 e5                	mov    %esp,%ebp
  8035cc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8035cf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8035d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8035d6:	89 04 24             	mov    %eax,(%esp)
  8035d9:	e8 f8 f6 ff ff       	call   802cd6 <fd_lookup>
  8035de:	85 c0                	test   %eax,%eax
  8035e0:	78 17                	js     8035f9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8035e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e5:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  8035eb:	39 08                	cmp    %ecx,(%eax)
  8035ed:	75 05                	jne    8035f4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8035ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8035f2:	eb 05                	jmp    8035f9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8035f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8035f9:	c9                   	leave  
  8035fa:	c3                   	ret    

008035fb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8035fb:	55                   	push   %ebp
  8035fc:	89 e5                	mov    %esp,%ebp
  8035fe:	56                   	push   %esi
  8035ff:	53                   	push   %ebx
  803600:	83 ec 20             	sub    $0x20,%esp
  803603:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803608:	89 04 24             	mov    %eax,(%esp)
  80360b:	e8 77 f6 ff ff       	call   802c87 <fd_alloc>
  803610:	89 c3                	mov    %eax,%ebx
  803612:	85 c0                	test   %eax,%eax
  803614:	78 21                	js     803637 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803616:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80361d:	00 
  80361e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803621:	89 44 24 04          	mov    %eax,0x4(%esp)
  803625:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80362c:	e8 62 f1 ff ff       	call   802793 <sys_page_alloc>
  803631:	89 c3                	mov    %eax,%ebx
  803633:	85 c0                	test   %eax,%eax
  803635:	79 0c                	jns    803643 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  803637:	89 34 24             	mov    %esi,(%esp)
  80363a:	e8 51 02 00 00       	call   803890 <nsipc_close>
		return r;
  80363f:	89 d8                	mov    %ebx,%eax
  803641:	eb 20                	jmp    803663 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803643:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80364c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80364e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803651:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  803658:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80365b:	89 14 24             	mov    %edx,(%esp)
  80365e:	e8 fd f5 ff ff       	call   802c60 <fd2num>
}
  803663:	83 c4 20             	add    $0x20,%esp
  803666:	5b                   	pop    %ebx
  803667:	5e                   	pop    %esi
  803668:	5d                   	pop    %ebp
  803669:	c3                   	ret    

0080366a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80366a:	55                   	push   %ebp
  80366b:	89 e5                	mov    %esp,%ebp
  80366d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803670:	8b 45 08             	mov    0x8(%ebp),%eax
  803673:	e8 51 ff ff ff       	call   8035c9 <fd2sockid>
		return r;
  803678:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80367a:	85 c0                	test   %eax,%eax
  80367c:	78 23                	js     8036a1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80367e:	8b 55 10             	mov    0x10(%ebp),%edx
  803681:	89 54 24 08          	mov    %edx,0x8(%esp)
  803685:	8b 55 0c             	mov    0xc(%ebp),%edx
  803688:	89 54 24 04          	mov    %edx,0x4(%esp)
  80368c:	89 04 24             	mov    %eax,(%esp)
  80368f:	e8 45 01 00 00       	call   8037d9 <nsipc_accept>
		return r;
  803694:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803696:	85 c0                	test   %eax,%eax
  803698:	78 07                	js     8036a1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80369a:	e8 5c ff ff ff       	call   8035fb <alloc_sockfd>
  80369f:	89 c1                	mov    %eax,%ecx
}
  8036a1:	89 c8                	mov    %ecx,%eax
  8036a3:	c9                   	leave  
  8036a4:	c3                   	ret    

008036a5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8036a5:	55                   	push   %ebp
  8036a6:	89 e5                	mov    %esp,%ebp
  8036a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8036ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ae:	e8 16 ff ff ff       	call   8035c9 <fd2sockid>
  8036b3:	89 c2                	mov    %eax,%edx
  8036b5:	85 d2                	test   %edx,%edx
  8036b7:	78 16                	js     8036cf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8036b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8036bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036c7:	89 14 24             	mov    %edx,(%esp)
  8036ca:	e8 60 01 00 00       	call   80382f <nsipc_bind>
}
  8036cf:	c9                   	leave  
  8036d0:	c3                   	ret    

008036d1 <shutdown>:

int
shutdown(int s, int how)
{
  8036d1:	55                   	push   %ebp
  8036d2:	89 e5                	mov    %esp,%ebp
  8036d4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8036d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8036da:	e8 ea fe ff ff       	call   8035c9 <fd2sockid>
  8036df:	89 c2                	mov    %eax,%edx
  8036e1:	85 d2                	test   %edx,%edx
  8036e3:	78 0f                	js     8036f4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8036e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036ec:	89 14 24             	mov    %edx,(%esp)
  8036ef:	e8 7a 01 00 00       	call   80386e <nsipc_shutdown>
}
  8036f4:	c9                   	leave  
  8036f5:	c3                   	ret    

008036f6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8036f6:	55                   	push   %ebp
  8036f7:	89 e5                	mov    %esp,%ebp
  8036f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8036fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ff:	e8 c5 fe ff ff       	call   8035c9 <fd2sockid>
  803704:	89 c2                	mov    %eax,%edx
  803706:	85 d2                	test   %edx,%edx
  803708:	78 16                	js     803720 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80370a:	8b 45 10             	mov    0x10(%ebp),%eax
  80370d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803711:	8b 45 0c             	mov    0xc(%ebp),%eax
  803714:	89 44 24 04          	mov    %eax,0x4(%esp)
  803718:	89 14 24             	mov    %edx,(%esp)
  80371b:	e8 8a 01 00 00       	call   8038aa <nsipc_connect>
}
  803720:	c9                   	leave  
  803721:	c3                   	ret    

00803722 <listen>:

int
listen(int s, int backlog)
{
  803722:	55                   	push   %ebp
  803723:	89 e5                	mov    %esp,%ebp
  803725:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803728:	8b 45 08             	mov    0x8(%ebp),%eax
  80372b:	e8 99 fe ff ff       	call   8035c9 <fd2sockid>
  803730:	89 c2                	mov    %eax,%edx
  803732:	85 d2                	test   %edx,%edx
  803734:	78 0f                	js     803745 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  803736:	8b 45 0c             	mov    0xc(%ebp),%eax
  803739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80373d:	89 14 24             	mov    %edx,(%esp)
  803740:	e8 a4 01 00 00       	call   8038e9 <nsipc_listen>
}
  803745:	c9                   	leave  
  803746:	c3                   	ret    

00803747 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803747:	55                   	push   %ebp
  803748:	89 e5                	mov    %esp,%ebp
  80374a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80374d:	8b 45 10             	mov    0x10(%ebp),%eax
  803750:	89 44 24 08          	mov    %eax,0x8(%esp)
  803754:	8b 45 0c             	mov    0xc(%ebp),%eax
  803757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80375b:	8b 45 08             	mov    0x8(%ebp),%eax
  80375e:	89 04 24             	mov    %eax,(%esp)
  803761:	e8 98 02 00 00       	call   8039fe <nsipc_socket>
  803766:	89 c2                	mov    %eax,%edx
  803768:	85 d2                	test   %edx,%edx
  80376a:	78 05                	js     803771 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80376c:	e8 8a fe ff ff       	call   8035fb <alloc_sockfd>
}
  803771:	c9                   	leave  
  803772:	c3                   	ret    

00803773 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803773:	55                   	push   %ebp
  803774:	89 e5                	mov    %esp,%ebp
  803776:	53                   	push   %ebx
  803777:	83 ec 14             	sub    $0x14,%esp
  80377a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80377c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803783:	75 11                	jne    803796 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803785:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80378c:	e8 94 f4 ff ff       	call   802c25 <ipc_find_env>
  803791:	a3 04 a0 80 00       	mov    %eax,0x80a004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803796:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80379d:	00 
  80379e:	c7 44 24 08 00 c0 80 	movl   $0x80c000,0x8(%esp)
  8037a5:	00 
  8037a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8037aa:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8037af:	89 04 24             	mov    %eax,(%esp)
  8037b2:	e8 03 f4 ff ff       	call   802bba <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8037b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8037be:	00 
  8037bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8037c6:	00 
  8037c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037ce:	e8 6d f3 ff ff       	call   802b40 <ipc_recv>
}
  8037d3:	83 c4 14             	add    $0x14,%esp
  8037d6:	5b                   	pop    %ebx
  8037d7:	5d                   	pop    %ebp
  8037d8:	c3                   	ret    

008037d9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8037d9:	55                   	push   %ebp
  8037da:	89 e5                	mov    %esp,%ebp
  8037dc:	56                   	push   %esi
  8037dd:	53                   	push   %ebx
  8037de:	83 ec 10             	sub    $0x10,%esp
  8037e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8037e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8037e7:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8037ec:	8b 06                	mov    (%esi),%eax
  8037ee:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8037f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8037f8:	e8 76 ff ff ff       	call   803773 <nsipc>
  8037fd:	89 c3                	mov    %eax,%ebx
  8037ff:	85 c0                	test   %eax,%eax
  803801:	78 23                	js     803826 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803803:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80380c:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  803813:	00 
  803814:	8b 45 0c             	mov    0xc(%ebp),%eax
  803817:	89 04 24             	mov    %eax,(%esp)
  80381a:	e8 f5 ec ff ff       	call   802514 <memmove>
		*addrlen = ret->ret_addrlen;
  80381f:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803824:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  803826:	89 d8                	mov    %ebx,%eax
  803828:	83 c4 10             	add    $0x10,%esp
  80382b:	5b                   	pop    %ebx
  80382c:	5e                   	pop    %esi
  80382d:	5d                   	pop    %ebp
  80382e:	c3                   	ret    

0080382f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80382f:	55                   	push   %ebp
  803830:	89 e5                	mov    %esp,%ebp
  803832:	53                   	push   %ebx
  803833:	83 ec 14             	sub    $0x14,%esp
  803836:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803839:	8b 45 08             	mov    0x8(%ebp),%eax
  80383c:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803841:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803845:	8b 45 0c             	mov    0xc(%ebp),%eax
  803848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80384c:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  803853:	e8 bc ec ff ff       	call   802514 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803858:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  80385e:	b8 02 00 00 00       	mov    $0x2,%eax
  803863:	e8 0b ff ff ff       	call   803773 <nsipc>
}
  803868:	83 c4 14             	add    $0x14,%esp
  80386b:	5b                   	pop    %ebx
  80386c:	5d                   	pop    %ebp
  80386d:	c3                   	ret    

0080386e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80386e:	55                   	push   %ebp
  80386f:	89 e5                	mov    %esp,%ebp
  803871:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803874:	8b 45 08             	mov    0x8(%ebp),%eax
  803877:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  80387c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80387f:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803884:	b8 03 00 00 00       	mov    $0x3,%eax
  803889:	e8 e5 fe ff ff       	call   803773 <nsipc>
}
  80388e:	c9                   	leave  
  80388f:	c3                   	ret    

00803890 <nsipc_close>:

int
nsipc_close(int s)
{
  803890:	55                   	push   %ebp
  803891:	89 e5                	mov    %esp,%ebp
  803893:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803896:	8b 45 08             	mov    0x8(%ebp),%eax
  803899:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80389e:	b8 04 00 00 00       	mov    $0x4,%eax
  8038a3:	e8 cb fe ff ff       	call   803773 <nsipc>
}
  8038a8:	c9                   	leave  
  8038a9:	c3                   	ret    

008038aa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8038aa:	55                   	push   %ebp
  8038ab:	89 e5                	mov    %esp,%ebp
  8038ad:	53                   	push   %ebx
  8038ae:	83 ec 14             	sub    $0x14,%esp
  8038b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8038b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8038b7:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8038bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8038c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038c7:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  8038ce:	e8 41 ec ff ff       	call   802514 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8038d3:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  8038d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8038de:	e8 90 fe ff ff       	call   803773 <nsipc>
}
  8038e3:	83 c4 14             	add    $0x14,%esp
  8038e6:	5b                   	pop    %ebx
  8038e7:	5d                   	pop    %ebp
  8038e8:	c3                   	ret    

008038e9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8038e9:	55                   	push   %ebp
  8038ea:	89 e5                	mov    %esp,%ebp
  8038ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8038ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8038f2:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8038f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038fa:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8038ff:	b8 06 00 00 00       	mov    $0x6,%eax
  803904:	e8 6a fe ff ff       	call   803773 <nsipc>
}
  803909:	c9                   	leave  
  80390a:	c3                   	ret    

0080390b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80390b:	55                   	push   %ebp
  80390c:	89 e5                	mov    %esp,%ebp
  80390e:	56                   	push   %esi
  80390f:	53                   	push   %ebx
  803910:	83 ec 10             	sub    $0x10,%esp
  803913:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803916:	8b 45 08             	mov    0x8(%ebp),%eax
  803919:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80391e:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803924:	8b 45 14             	mov    0x14(%ebp),%eax
  803927:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80392c:	b8 07 00 00 00       	mov    $0x7,%eax
  803931:	e8 3d fe ff ff       	call   803773 <nsipc>
  803936:	89 c3                	mov    %eax,%ebx
  803938:	85 c0                	test   %eax,%eax
  80393a:	78 46                	js     803982 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80393c:	39 f0                	cmp    %esi,%eax
  80393e:	7f 07                	jg     803947 <nsipc_recv+0x3c>
  803940:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803945:	7e 24                	jle    80396b <nsipc_recv+0x60>
  803947:	c7 44 24 0c 26 4c 80 	movl   $0x804c26,0xc(%esp)
  80394e:	00 
  80394f:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  803956:	00 
  803957:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80395e:	00 
  80395f:	c7 04 24 3b 4c 80 00 	movl   $0x804c3b,(%esp)
  803966:	e8 e8 e2 ff ff       	call   801c53 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80396b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80396f:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  803976:	00 
  803977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80397a:	89 04 24             	mov    %eax,(%esp)
  80397d:	e8 92 eb ff ff       	call   802514 <memmove>
	}

	return r;
}
  803982:	89 d8                	mov    %ebx,%eax
  803984:	83 c4 10             	add    $0x10,%esp
  803987:	5b                   	pop    %ebx
  803988:	5e                   	pop    %esi
  803989:	5d                   	pop    %ebp
  80398a:	c3                   	ret    

0080398b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80398b:	55                   	push   %ebp
  80398c:	89 e5                	mov    %esp,%ebp
  80398e:	53                   	push   %ebx
  80398f:	83 ec 14             	sub    $0x14,%esp
  803992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803995:	8b 45 08             	mov    0x8(%ebp),%eax
  803998:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  80399d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8039a3:	7e 24                	jle    8039c9 <nsipc_send+0x3e>
  8039a5:	c7 44 24 0c 47 4c 80 	movl   $0x804c47,0xc(%esp)
  8039ac:	00 
  8039ad:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8039b4:	00 
  8039b5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8039bc:	00 
  8039bd:	c7 04 24 3b 4c 80 00 	movl   $0x804c3b,(%esp)
  8039c4:	e8 8a e2 ff ff       	call   801c53 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8039c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8039cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039d4:	c7 04 24 0c c0 80 00 	movl   $0x80c00c,(%esp)
  8039db:	e8 34 eb ff ff       	call   802514 <memmove>
	nsipcbuf.send.req_size = size;
  8039e0:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8039e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8039e9:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8039ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8039f3:	e8 7b fd ff ff       	call   803773 <nsipc>
}
  8039f8:	83 c4 14             	add    $0x14,%esp
  8039fb:	5b                   	pop    %ebx
  8039fc:	5d                   	pop    %ebp
  8039fd:	c3                   	ret    

008039fe <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8039fe:	55                   	push   %ebp
  8039ff:	89 e5                	mov    %esp,%ebp
  803a01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803a04:	8b 45 08             	mov    0x8(%ebp),%eax
  803a07:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  803a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a0f:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  803a14:	8b 45 10             	mov    0x10(%ebp),%eax
  803a17:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  803a1c:	b8 09 00 00 00       	mov    $0x9,%eax
  803a21:	e8 4d fd ff ff       	call   803773 <nsipc>
}
  803a26:	c9                   	leave  
  803a27:	c3                   	ret    

00803a28 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803a28:	55                   	push   %ebp
  803a29:	89 e5                	mov    %esp,%ebp
  803a2b:	56                   	push   %esi
  803a2c:	53                   	push   %ebx
  803a2d:	83 ec 10             	sub    $0x10,%esp
  803a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803a33:	8b 45 08             	mov    0x8(%ebp),%eax
  803a36:	89 04 24             	mov    %eax,(%esp)
  803a39:	e8 32 f2 ff ff       	call   802c70 <fd2data>
  803a3e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803a40:	c7 44 24 04 53 4c 80 	movl   $0x804c53,0x4(%esp)
  803a47:	00 
  803a48:	89 1c 24             	mov    %ebx,(%esp)
  803a4b:	e8 27 e9 ff ff       	call   802377 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803a50:	8b 46 04             	mov    0x4(%esi),%eax
  803a53:	2b 06                	sub    (%esi),%eax
  803a55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803a5b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803a62:	00 00 00 
	stat->st_dev = &devpipe;
  803a65:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  803a6c:	90 80 00 
	return 0;
}
  803a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  803a74:	83 c4 10             	add    $0x10,%esp
  803a77:	5b                   	pop    %ebx
  803a78:	5e                   	pop    %esi
  803a79:	5d                   	pop    %ebp
  803a7a:	c3                   	ret    

00803a7b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803a7b:	55                   	push   %ebp
  803a7c:	89 e5                	mov    %esp,%ebp
  803a7e:	53                   	push   %ebx
  803a7f:	83 ec 14             	sub    $0x14,%esp
  803a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803a85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803a89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803a90:	e8 a5 ed ff ff       	call   80283a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803a95:	89 1c 24             	mov    %ebx,(%esp)
  803a98:	e8 d3 f1 ff ff       	call   802c70 <fd2data>
  803a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803aa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803aa8:	e8 8d ed ff ff       	call   80283a <sys_page_unmap>
}
  803aad:	83 c4 14             	add    $0x14,%esp
  803ab0:	5b                   	pop    %ebx
  803ab1:	5d                   	pop    %ebp
  803ab2:	c3                   	ret    

00803ab3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803ab3:	55                   	push   %ebp
  803ab4:	89 e5                	mov    %esp,%ebp
  803ab6:	57                   	push   %edi
  803ab7:	56                   	push   %esi
  803ab8:	53                   	push   %ebx
  803ab9:	83 ec 2c             	sub    $0x2c,%esp
  803abc:	89 c6                	mov    %eax,%esi
  803abe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803ac1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803ac6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803ac9:	89 34 24             	mov    %esi,(%esp)
  803acc:	e8 0d fa ff ff       	call   8034de <pageref>
  803ad1:	89 c7                	mov    %eax,%edi
  803ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803ad6:	89 04 24             	mov    %eax,(%esp)
  803ad9:	e8 00 fa ff ff       	call   8034de <pageref>
  803ade:	39 c7                	cmp    %eax,%edi
  803ae0:	0f 94 c2             	sete   %dl
  803ae3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  803ae6:	8b 0d 10 a0 80 00    	mov    0x80a010,%ecx
  803aec:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  803aef:	39 fb                	cmp    %edi,%ebx
  803af1:	74 21                	je     803b14 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803af3:	84 d2                	test   %dl,%dl
  803af5:	74 ca                	je     803ac1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803af7:	8b 51 58             	mov    0x58(%ecx),%edx
  803afa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803afe:	89 54 24 08          	mov    %edx,0x8(%esp)
  803b02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803b06:	c7 04 24 5a 4c 80 00 	movl   $0x804c5a,(%esp)
  803b0d:	e8 3a e2 ff ff       	call   801d4c <cprintf>
  803b12:	eb ad                	jmp    803ac1 <_pipeisclosed+0xe>
	}
}
  803b14:	83 c4 2c             	add    $0x2c,%esp
  803b17:	5b                   	pop    %ebx
  803b18:	5e                   	pop    %esi
  803b19:	5f                   	pop    %edi
  803b1a:	5d                   	pop    %ebp
  803b1b:	c3                   	ret    

00803b1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803b1c:	55                   	push   %ebp
  803b1d:	89 e5                	mov    %esp,%ebp
  803b1f:	57                   	push   %edi
  803b20:	56                   	push   %esi
  803b21:	53                   	push   %ebx
  803b22:	83 ec 1c             	sub    $0x1c,%esp
  803b25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803b28:	89 34 24             	mov    %esi,(%esp)
  803b2b:	e8 40 f1 ff ff       	call   802c70 <fd2data>
  803b30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803b32:	bf 00 00 00 00       	mov    $0x0,%edi
  803b37:	eb 45                	jmp    803b7e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803b39:	89 da                	mov    %ebx,%edx
  803b3b:	89 f0                	mov    %esi,%eax
  803b3d:	e8 71 ff ff ff       	call   803ab3 <_pipeisclosed>
  803b42:	85 c0                	test   %eax,%eax
  803b44:	75 41                	jne    803b87 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803b46:	e8 29 ec ff ff       	call   802774 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803b4b:	8b 43 04             	mov    0x4(%ebx),%eax
  803b4e:	8b 0b                	mov    (%ebx),%ecx
  803b50:	8d 51 20             	lea    0x20(%ecx),%edx
  803b53:	39 d0                	cmp    %edx,%eax
  803b55:	73 e2                	jae    803b39 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803b5a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803b5e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803b61:	99                   	cltd   
  803b62:	c1 ea 1b             	shr    $0x1b,%edx
  803b65:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  803b68:	83 e1 1f             	and    $0x1f,%ecx
  803b6b:	29 d1                	sub    %edx,%ecx
  803b6d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  803b71:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  803b75:	83 c0 01             	add    $0x1,%eax
  803b78:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803b7b:	83 c7 01             	add    $0x1,%edi
  803b7e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803b81:	75 c8                	jne    803b4b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803b83:	89 f8                	mov    %edi,%eax
  803b85:	eb 05                	jmp    803b8c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803b87:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803b8c:	83 c4 1c             	add    $0x1c,%esp
  803b8f:	5b                   	pop    %ebx
  803b90:	5e                   	pop    %esi
  803b91:	5f                   	pop    %edi
  803b92:	5d                   	pop    %ebp
  803b93:	c3                   	ret    

00803b94 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803b94:	55                   	push   %ebp
  803b95:	89 e5                	mov    %esp,%ebp
  803b97:	57                   	push   %edi
  803b98:	56                   	push   %esi
  803b99:	53                   	push   %ebx
  803b9a:	83 ec 1c             	sub    $0x1c,%esp
  803b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803ba0:	89 3c 24             	mov    %edi,(%esp)
  803ba3:	e8 c8 f0 ff ff       	call   802c70 <fd2data>
  803ba8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803baa:	be 00 00 00 00       	mov    $0x0,%esi
  803baf:	eb 3d                	jmp    803bee <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803bb1:	85 f6                	test   %esi,%esi
  803bb3:	74 04                	je     803bb9 <devpipe_read+0x25>
				return i;
  803bb5:	89 f0                	mov    %esi,%eax
  803bb7:	eb 43                	jmp    803bfc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803bb9:	89 da                	mov    %ebx,%edx
  803bbb:	89 f8                	mov    %edi,%eax
  803bbd:	e8 f1 fe ff ff       	call   803ab3 <_pipeisclosed>
  803bc2:	85 c0                	test   %eax,%eax
  803bc4:	75 31                	jne    803bf7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803bc6:	e8 a9 eb ff ff       	call   802774 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803bcb:	8b 03                	mov    (%ebx),%eax
  803bcd:	3b 43 04             	cmp    0x4(%ebx),%eax
  803bd0:	74 df                	je     803bb1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803bd2:	99                   	cltd   
  803bd3:	c1 ea 1b             	shr    $0x1b,%edx
  803bd6:	01 d0                	add    %edx,%eax
  803bd8:	83 e0 1f             	and    $0x1f,%eax
  803bdb:	29 d0                	sub    %edx,%eax
  803bdd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803be5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803be8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803beb:	83 c6 01             	add    $0x1,%esi
  803bee:	3b 75 10             	cmp    0x10(%ebp),%esi
  803bf1:	75 d8                	jne    803bcb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803bf3:	89 f0                	mov    %esi,%eax
  803bf5:	eb 05                	jmp    803bfc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803bf7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803bfc:	83 c4 1c             	add    $0x1c,%esp
  803bff:	5b                   	pop    %ebx
  803c00:	5e                   	pop    %esi
  803c01:	5f                   	pop    %edi
  803c02:	5d                   	pop    %ebp
  803c03:	c3                   	ret    

00803c04 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803c04:	55                   	push   %ebp
  803c05:	89 e5                	mov    %esp,%ebp
  803c07:	56                   	push   %esi
  803c08:	53                   	push   %ebx
  803c09:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803c0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803c0f:	89 04 24             	mov    %eax,(%esp)
  803c12:	e8 70 f0 ff ff       	call   802c87 <fd_alloc>
  803c17:	89 c2                	mov    %eax,%edx
  803c19:	85 d2                	test   %edx,%edx
  803c1b:	0f 88 4d 01 00 00    	js     803d6e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803c21:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803c28:	00 
  803c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c37:	e8 57 eb ff ff       	call   802793 <sys_page_alloc>
  803c3c:	89 c2                	mov    %eax,%edx
  803c3e:	85 d2                	test   %edx,%edx
  803c40:	0f 88 28 01 00 00    	js     803d6e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803c46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803c49:	89 04 24             	mov    %eax,(%esp)
  803c4c:	e8 36 f0 ff ff       	call   802c87 <fd_alloc>
  803c51:	89 c3                	mov    %eax,%ebx
  803c53:	85 c0                	test   %eax,%eax
  803c55:	0f 88 fe 00 00 00    	js     803d59 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803c5b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803c62:	00 
  803c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c71:	e8 1d eb ff ff       	call   802793 <sys_page_alloc>
  803c76:	89 c3                	mov    %eax,%ebx
  803c78:	85 c0                	test   %eax,%eax
  803c7a:	0f 88 d9 00 00 00    	js     803d59 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c83:	89 04 24             	mov    %eax,(%esp)
  803c86:	e8 e5 ef ff ff       	call   802c70 <fd2data>
  803c8b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803c8d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803c94:	00 
  803c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803ca0:	e8 ee ea ff ff       	call   802793 <sys_page_alloc>
  803ca5:	89 c3                	mov    %eax,%ebx
  803ca7:	85 c0                	test   %eax,%eax
  803ca9:	0f 88 97 00 00 00    	js     803d46 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803cb2:	89 04 24             	mov    %eax,(%esp)
  803cb5:	e8 b6 ef ff ff       	call   802c70 <fd2data>
  803cba:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803cc1:	00 
  803cc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803cc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803ccd:	00 
  803cce:	89 74 24 04          	mov    %esi,0x4(%esp)
  803cd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803cd9:	e8 09 eb ff ff       	call   8027e7 <sys_page_map>
  803cde:	89 c3                	mov    %eax,%ebx
  803ce0:	85 c0                	test   %eax,%eax
  803ce2:	78 52                	js     803d36 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803ce4:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803ced:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803cf2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803cf9:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803d02:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803d07:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803d11:	89 04 24             	mov    %eax,(%esp)
  803d14:	e8 47 ef ff ff       	call   802c60 <fd2num>
  803d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803d1c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803d21:	89 04 24             	mov    %eax,(%esp)
  803d24:	e8 37 ef ff ff       	call   802c60 <fd2num>
  803d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803d2c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  803d34:	eb 38                	jmp    803d6e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  803d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d41:	e8 f4 ea ff ff       	call   80283a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d54:	e8 e1 ea ff ff       	call   80283a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d67:	e8 ce ea ff ff       	call   80283a <sys_page_unmap>
  803d6c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  803d6e:	83 c4 30             	add    $0x30,%esp
  803d71:	5b                   	pop    %ebx
  803d72:	5e                   	pop    %esi
  803d73:	5d                   	pop    %ebp
  803d74:	c3                   	ret    

00803d75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803d75:	55                   	push   %ebp
  803d76:	89 e5                	mov    %esp,%ebp
  803d78:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803d7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d82:	8b 45 08             	mov    0x8(%ebp),%eax
  803d85:	89 04 24             	mov    %eax,(%esp)
  803d88:	e8 49 ef ff ff       	call   802cd6 <fd_lookup>
  803d8d:	89 c2                	mov    %eax,%edx
  803d8f:	85 d2                	test   %edx,%edx
  803d91:	78 15                	js     803da8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803d96:	89 04 24             	mov    %eax,(%esp)
  803d99:	e8 d2 ee ff ff       	call   802c70 <fd2data>
	return _pipeisclosed(fd, p);
  803d9e:	89 c2                	mov    %eax,%edx
  803da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803da3:	e8 0b fd ff ff       	call   803ab3 <_pipeisclosed>
}
  803da8:	c9                   	leave  
  803da9:	c3                   	ret    
  803daa:	66 90                	xchg   %ax,%ax
  803dac:	66 90                	xchg   %ax,%ax
  803dae:	66 90                	xchg   %ax,%ax

00803db0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803db0:	55                   	push   %ebp
  803db1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803db3:	b8 00 00 00 00       	mov    $0x0,%eax
  803db8:	5d                   	pop    %ebp
  803db9:	c3                   	ret    

00803dba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803dba:	55                   	push   %ebp
  803dbb:	89 e5                	mov    %esp,%ebp
  803dbd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803dc0:	c7 44 24 04 72 4c 80 	movl   $0x804c72,0x4(%esp)
  803dc7:	00 
  803dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  803dcb:	89 04 24             	mov    %eax,(%esp)
  803dce:	e8 a4 e5 ff ff       	call   802377 <strcpy>
	return 0;
}
  803dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  803dd8:	c9                   	leave  
  803dd9:	c3                   	ret    

00803dda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803dda:	55                   	push   %ebp
  803ddb:	89 e5                	mov    %esp,%ebp
  803ddd:	57                   	push   %edi
  803dde:	56                   	push   %esi
  803ddf:	53                   	push   %ebx
  803de0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803de6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803deb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803df1:	eb 31                	jmp    803e24 <devcons_write+0x4a>
		m = n - tot;
  803df3:	8b 75 10             	mov    0x10(%ebp),%esi
  803df6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803df8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803dfb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803e00:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803e03:	89 74 24 08          	mov    %esi,0x8(%esp)
  803e07:	03 45 0c             	add    0xc(%ebp),%eax
  803e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e0e:	89 3c 24             	mov    %edi,(%esp)
  803e11:	e8 fe e6 ff ff       	call   802514 <memmove>
		sys_cputs(buf, m);
  803e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  803e1a:	89 3c 24             	mov    %edi,(%esp)
  803e1d:	e8 a4 e8 ff ff       	call   8026c6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e22:	01 f3                	add    %esi,%ebx
  803e24:	89 d8                	mov    %ebx,%eax
  803e26:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803e29:	72 c8                	jb     803df3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803e2b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803e31:	5b                   	pop    %ebx
  803e32:	5e                   	pop    %esi
  803e33:	5f                   	pop    %edi
  803e34:	5d                   	pop    %ebp
  803e35:	c3                   	ret    

00803e36 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803e36:	55                   	push   %ebp
  803e37:	89 e5                	mov    %esp,%ebp
  803e39:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  803e3c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  803e41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803e45:	75 07                	jne    803e4e <devcons_read+0x18>
  803e47:	eb 2a                	jmp    803e73 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803e49:	e8 26 e9 ff ff       	call   802774 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803e4e:	66 90                	xchg   %ax,%ax
  803e50:	e8 8f e8 ff ff       	call   8026e4 <sys_cgetc>
  803e55:	85 c0                	test   %eax,%eax
  803e57:	74 f0                	je     803e49 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803e59:	85 c0                	test   %eax,%eax
  803e5b:	78 16                	js     803e73 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803e5d:	83 f8 04             	cmp    $0x4,%eax
  803e60:	74 0c                	je     803e6e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  803e62:	8b 55 0c             	mov    0xc(%ebp),%edx
  803e65:	88 02                	mov    %al,(%edx)
	return 1;
  803e67:	b8 01 00 00 00       	mov    $0x1,%eax
  803e6c:	eb 05                	jmp    803e73 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803e6e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803e73:	c9                   	leave  
  803e74:	c3                   	ret    

00803e75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803e75:	55                   	push   %ebp
  803e76:	89 e5                	mov    %esp,%ebp
  803e78:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  803e7e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803e81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803e88:	00 
  803e89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803e8c:	89 04 24             	mov    %eax,(%esp)
  803e8f:	e8 32 e8 ff ff       	call   8026c6 <sys_cputs>
}
  803e94:	c9                   	leave  
  803e95:	c3                   	ret    

00803e96 <getchar>:

int
getchar(void)
{
  803e96:	55                   	push   %ebp
  803e97:	89 e5                	mov    %esp,%ebp
  803e99:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803e9c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803ea3:	00 
  803ea4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  803eab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803eb2:	e8 b3 f0 ff ff       	call   802f6a <read>
	if (r < 0)
  803eb7:	85 c0                	test   %eax,%eax
  803eb9:	78 0f                	js     803eca <getchar+0x34>
		return r;
	if (r < 1)
  803ebb:	85 c0                	test   %eax,%eax
  803ebd:	7e 06                	jle    803ec5 <getchar+0x2f>
		return -E_EOF;
	return c;
  803ebf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803ec3:	eb 05                	jmp    803eca <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803ec5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803eca:	c9                   	leave  
  803ecb:	c3                   	ret    

00803ecc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803ecc:	55                   	push   %ebp
  803ecd:	89 e5                	mov    %esp,%ebp
  803ecf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  803ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  803edc:	89 04 24             	mov    %eax,(%esp)
  803edf:	e8 f2 ed ff ff       	call   802cd6 <fd_lookup>
  803ee4:	85 c0                	test   %eax,%eax
  803ee6:	78 11                	js     803ef9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803eeb:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803ef1:	39 10                	cmp    %edx,(%eax)
  803ef3:	0f 94 c0             	sete   %al
  803ef6:	0f b6 c0             	movzbl %al,%eax
}
  803ef9:	c9                   	leave  
  803efa:	c3                   	ret    

00803efb <opencons>:

int
opencons(void)
{
  803efb:	55                   	push   %ebp
  803efc:	89 e5                	mov    %esp,%ebp
  803efe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803f04:	89 04 24             	mov    %eax,(%esp)
  803f07:	e8 7b ed ff ff       	call   802c87 <fd_alloc>
		return r;
  803f0c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803f0e:	85 c0                	test   %eax,%eax
  803f10:	78 40                	js     803f52 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803f12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803f19:	00 
  803f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f28:	e8 66 e8 ff ff       	call   802793 <sys_page_alloc>
		return r;
  803f2d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803f2f:	85 c0                	test   %eax,%eax
  803f31:	78 1f                	js     803f52 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803f33:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f3c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f41:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803f48:	89 04 24             	mov    %eax,(%esp)
  803f4b:	e8 10 ed ff ff       	call   802c60 <fd2num>
  803f50:	89 c2                	mov    %eax,%edx
}
  803f52:	89 d0                	mov    %edx,%eax
  803f54:	c9                   	leave  
  803f55:	c3                   	ret    
  803f56:	66 90                	xchg   %ax,%ax
  803f58:	66 90                	xchg   %ax,%ax
  803f5a:	66 90                	xchg   %ax,%ax
  803f5c:	66 90                	xchg   %ax,%ax
  803f5e:	66 90                	xchg   %ax,%ax

00803f60 <__udivdi3>:
  803f60:	55                   	push   %ebp
  803f61:	57                   	push   %edi
  803f62:	56                   	push   %esi
  803f63:	83 ec 0c             	sub    $0xc,%esp
  803f66:	8b 44 24 28          	mov    0x28(%esp),%eax
  803f6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  803f6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  803f72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803f76:	85 c0                	test   %eax,%eax
  803f78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  803f7c:	89 ea                	mov    %ebp,%edx
  803f7e:	89 0c 24             	mov    %ecx,(%esp)
  803f81:	75 2d                	jne    803fb0 <__udivdi3+0x50>
  803f83:	39 e9                	cmp    %ebp,%ecx
  803f85:	77 61                	ja     803fe8 <__udivdi3+0x88>
  803f87:	85 c9                	test   %ecx,%ecx
  803f89:	89 ce                	mov    %ecx,%esi
  803f8b:	75 0b                	jne    803f98 <__udivdi3+0x38>
  803f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  803f92:	31 d2                	xor    %edx,%edx
  803f94:	f7 f1                	div    %ecx
  803f96:	89 c6                	mov    %eax,%esi
  803f98:	31 d2                	xor    %edx,%edx
  803f9a:	89 e8                	mov    %ebp,%eax
  803f9c:	f7 f6                	div    %esi
  803f9e:	89 c5                	mov    %eax,%ebp
  803fa0:	89 f8                	mov    %edi,%eax
  803fa2:	f7 f6                	div    %esi
  803fa4:	89 ea                	mov    %ebp,%edx
  803fa6:	83 c4 0c             	add    $0xc,%esp
  803fa9:	5e                   	pop    %esi
  803faa:	5f                   	pop    %edi
  803fab:	5d                   	pop    %ebp
  803fac:	c3                   	ret    
  803fad:	8d 76 00             	lea    0x0(%esi),%esi
  803fb0:	39 e8                	cmp    %ebp,%eax
  803fb2:	77 24                	ja     803fd8 <__udivdi3+0x78>
  803fb4:	0f bd e8             	bsr    %eax,%ebp
  803fb7:	83 f5 1f             	xor    $0x1f,%ebp
  803fba:	75 3c                	jne    803ff8 <__udivdi3+0x98>
  803fbc:	8b 74 24 04          	mov    0x4(%esp),%esi
  803fc0:	39 34 24             	cmp    %esi,(%esp)
  803fc3:	0f 86 9f 00 00 00    	jbe    804068 <__udivdi3+0x108>
  803fc9:	39 d0                	cmp    %edx,%eax
  803fcb:	0f 82 97 00 00 00    	jb     804068 <__udivdi3+0x108>
  803fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803fd8:	31 d2                	xor    %edx,%edx
  803fda:	31 c0                	xor    %eax,%eax
  803fdc:	83 c4 0c             	add    $0xc,%esp
  803fdf:	5e                   	pop    %esi
  803fe0:	5f                   	pop    %edi
  803fe1:	5d                   	pop    %ebp
  803fe2:	c3                   	ret    
  803fe3:	90                   	nop
  803fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803fe8:	89 f8                	mov    %edi,%eax
  803fea:	f7 f1                	div    %ecx
  803fec:	31 d2                	xor    %edx,%edx
  803fee:	83 c4 0c             	add    $0xc,%esp
  803ff1:	5e                   	pop    %esi
  803ff2:	5f                   	pop    %edi
  803ff3:	5d                   	pop    %ebp
  803ff4:	c3                   	ret    
  803ff5:	8d 76 00             	lea    0x0(%esi),%esi
  803ff8:	89 e9                	mov    %ebp,%ecx
  803ffa:	8b 3c 24             	mov    (%esp),%edi
  803ffd:	d3 e0                	shl    %cl,%eax
  803fff:	89 c6                	mov    %eax,%esi
  804001:	b8 20 00 00 00       	mov    $0x20,%eax
  804006:	29 e8                	sub    %ebp,%eax
  804008:	89 c1                	mov    %eax,%ecx
  80400a:	d3 ef                	shr    %cl,%edi
  80400c:	89 e9                	mov    %ebp,%ecx
  80400e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  804012:	8b 3c 24             	mov    (%esp),%edi
  804015:	09 74 24 08          	or     %esi,0x8(%esp)
  804019:	89 d6                	mov    %edx,%esi
  80401b:	d3 e7                	shl    %cl,%edi
  80401d:	89 c1                	mov    %eax,%ecx
  80401f:	89 3c 24             	mov    %edi,(%esp)
  804022:	8b 7c 24 04          	mov    0x4(%esp),%edi
  804026:	d3 ee                	shr    %cl,%esi
  804028:	89 e9                	mov    %ebp,%ecx
  80402a:	d3 e2                	shl    %cl,%edx
  80402c:	89 c1                	mov    %eax,%ecx
  80402e:	d3 ef                	shr    %cl,%edi
  804030:	09 d7                	or     %edx,%edi
  804032:	89 f2                	mov    %esi,%edx
  804034:	89 f8                	mov    %edi,%eax
  804036:	f7 74 24 08          	divl   0x8(%esp)
  80403a:	89 d6                	mov    %edx,%esi
  80403c:	89 c7                	mov    %eax,%edi
  80403e:	f7 24 24             	mull   (%esp)
  804041:	39 d6                	cmp    %edx,%esi
  804043:	89 14 24             	mov    %edx,(%esp)
  804046:	72 30                	jb     804078 <__udivdi3+0x118>
  804048:	8b 54 24 04          	mov    0x4(%esp),%edx
  80404c:	89 e9                	mov    %ebp,%ecx
  80404e:	d3 e2                	shl    %cl,%edx
  804050:	39 c2                	cmp    %eax,%edx
  804052:	73 05                	jae    804059 <__udivdi3+0xf9>
  804054:	3b 34 24             	cmp    (%esp),%esi
  804057:	74 1f                	je     804078 <__udivdi3+0x118>
  804059:	89 f8                	mov    %edi,%eax
  80405b:	31 d2                	xor    %edx,%edx
  80405d:	e9 7a ff ff ff       	jmp    803fdc <__udivdi3+0x7c>
  804062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  804068:	31 d2                	xor    %edx,%edx
  80406a:	b8 01 00 00 00       	mov    $0x1,%eax
  80406f:	e9 68 ff ff ff       	jmp    803fdc <__udivdi3+0x7c>
  804074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804078:	8d 47 ff             	lea    -0x1(%edi),%eax
  80407b:	31 d2                	xor    %edx,%edx
  80407d:	83 c4 0c             	add    $0xc,%esp
  804080:	5e                   	pop    %esi
  804081:	5f                   	pop    %edi
  804082:	5d                   	pop    %ebp
  804083:	c3                   	ret    
  804084:	66 90                	xchg   %ax,%ax
  804086:	66 90                	xchg   %ax,%ax
  804088:	66 90                	xchg   %ax,%ax
  80408a:	66 90                	xchg   %ax,%ax
  80408c:	66 90                	xchg   %ax,%ax
  80408e:	66 90                	xchg   %ax,%ax

00804090 <__umoddi3>:
  804090:	55                   	push   %ebp
  804091:	57                   	push   %edi
  804092:	56                   	push   %esi
  804093:	83 ec 14             	sub    $0x14,%esp
  804096:	8b 44 24 28          	mov    0x28(%esp),%eax
  80409a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80409e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8040a2:	89 c7                	mov    %eax,%edi
  8040a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8040a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8040ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8040b0:	89 34 24             	mov    %esi,(%esp)
  8040b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8040b7:	85 c0                	test   %eax,%eax
  8040b9:	89 c2                	mov    %eax,%edx
  8040bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8040bf:	75 17                	jne    8040d8 <__umoddi3+0x48>
  8040c1:	39 fe                	cmp    %edi,%esi
  8040c3:	76 4b                	jbe    804110 <__umoddi3+0x80>
  8040c5:	89 c8                	mov    %ecx,%eax
  8040c7:	89 fa                	mov    %edi,%edx
  8040c9:	f7 f6                	div    %esi
  8040cb:	89 d0                	mov    %edx,%eax
  8040cd:	31 d2                	xor    %edx,%edx
  8040cf:	83 c4 14             	add    $0x14,%esp
  8040d2:	5e                   	pop    %esi
  8040d3:	5f                   	pop    %edi
  8040d4:	5d                   	pop    %ebp
  8040d5:	c3                   	ret    
  8040d6:	66 90                	xchg   %ax,%ax
  8040d8:	39 f8                	cmp    %edi,%eax
  8040da:	77 54                	ja     804130 <__umoddi3+0xa0>
  8040dc:	0f bd e8             	bsr    %eax,%ebp
  8040df:	83 f5 1f             	xor    $0x1f,%ebp
  8040e2:	75 5c                	jne    804140 <__umoddi3+0xb0>
  8040e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8040e8:	39 3c 24             	cmp    %edi,(%esp)
  8040eb:	0f 87 e7 00 00 00    	ja     8041d8 <__umoddi3+0x148>
  8040f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8040f5:	29 f1                	sub    %esi,%ecx
  8040f7:	19 c7                	sbb    %eax,%edi
  8040f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8040fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  804101:	8b 44 24 08          	mov    0x8(%esp),%eax
  804105:	8b 54 24 0c          	mov    0xc(%esp),%edx
  804109:	83 c4 14             	add    $0x14,%esp
  80410c:	5e                   	pop    %esi
  80410d:	5f                   	pop    %edi
  80410e:	5d                   	pop    %ebp
  80410f:	c3                   	ret    
  804110:	85 f6                	test   %esi,%esi
  804112:	89 f5                	mov    %esi,%ebp
  804114:	75 0b                	jne    804121 <__umoddi3+0x91>
  804116:	b8 01 00 00 00       	mov    $0x1,%eax
  80411b:	31 d2                	xor    %edx,%edx
  80411d:	f7 f6                	div    %esi
  80411f:	89 c5                	mov    %eax,%ebp
  804121:	8b 44 24 04          	mov    0x4(%esp),%eax
  804125:	31 d2                	xor    %edx,%edx
  804127:	f7 f5                	div    %ebp
  804129:	89 c8                	mov    %ecx,%eax
  80412b:	f7 f5                	div    %ebp
  80412d:	eb 9c                	jmp    8040cb <__umoddi3+0x3b>
  80412f:	90                   	nop
  804130:	89 c8                	mov    %ecx,%eax
  804132:	89 fa                	mov    %edi,%edx
  804134:	83 c4 14             	add    $0x14,%esp
  804137:	5e                   	pop    %esi
  804138:	5f                   	pop    %edi
  804139:	5d                   	pop    %ebp
  80413a:	c3                   	ret    
  80413b:	90                   	nop
  80413c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804140:	8b 04 24             	mov    (%esp),%eax
  804143:	be 20 00 00 00       	mov    $0x20,%esi
  804148:	89 e9                	mov    %ebp,%ecx
  80414a:	29 ee                	sub    %ebp,%esi
  80414c:	d3 e2                	shl    %cl,%edx
  80414e:	89 f1                	mov    %esi,%ecx
  804150:	d3 e8                	shr    %cl,%eax
  804152:	89 e9                	mov    %ebp,%ecx
  804154:	89 44 24 04          	mov    %eax,0x4(%esp)
  804158:	8b 04 24             	mov    (%esp),%eax
  80415b:	09 54 24 04          	or     %edx,0x4(%esp)
  80415f:	89 fa                	mov    %edi,%edx
  804161:	d3 e0                	shl    %cl,%eax
  804163:	89 f1                	mov    %esi,%ecx
  804165:	89 44 24 08          	mov    %eax,0x8(%esp)
  804169:	8b 44 24 10          	mov    0x10(%esp),%eax
  80416d:	d3 ea                	shr    %cl,%edx
  80416f:	89 e9                	mov    %ebp,%ecx
  804171:	d3 e7                	shl    %cl,%edi
  804173:	89 f1                	mov    %esi,%ecx
  804175:	d3 e8                	shr    %cl,%eax
  804177:	89 e9                	mov    %ebp,%ecx
  804179:	09 f8                	or     %edi,%eax
  80417b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80417f:	f7 74 24 04          	divl   0x4(%esp)
  804183:	d3 e7                	shl    %cl,%edi
  804185:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  804189:	89 d7                	mov    %edx,%edi
  80418b:	f7 64 24 08          	mull   0x8(%esp)
  80418f:	39 d7                	cmp    %edx,%edi
  804191:	89 c1                	mov    %eax,%ecx
  804193:	89 14 24             	mov    %edx,(%esp)
  804196:	72 2c                	jb     8041c4 <__umoddi3+0x134>
  804198:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80419c:	72 22                	jb     8041c0 <__umoddi3+0x130>
  80419e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8041a2:	29 c8                	sub    %ecx,%eax
  8041a4:	19 d7                	sbb    %edx,%edi
  8041a6:	89 e9                	mov    %ebp,%ecx
  8041a8:	89 fa                	mov    %edi,%edx
  8041aa:	d3 e8                	shr    %cl,%eax
  8041ac:	89 f1                	mov    %esi,%ecx
  8041ae:	d3 e2                	shl    %cl,%edx
  8041b0:	89 e9                	mov    %ebp,%ecx
  8041b2:	d3 ef                	shr    %cl,%edi
  8041b4:	09 d0                	or     %edx,%eax
  8041b6:	89 fa                	mov    %edi,%edx
  8041b8:	83 c4 14             	add    $0x14,%esp
  8041bb:	5e                   	pop    %esi
  8041bc:	5f                   	pop    %edi
  8041bd:	5d                   	pop    %ebp
  8041be:	c3                   	ret    
  8041bf:	90                   	nop
  8041c0:	39 d7                	cmp    %edx,%edi
  8041c2:	75 da                	jne    80419e <__umoddi3+0x10e>
  8041c4:	8b 14 24             	mov    (%esp),%edx
  8041c7:	89 c1                	mov    %eax,%ecx
  8041c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8041cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8041d1:	eb cb                	jmp    80419e <__umoddi3+0x10e>
  8041d3:	90                   	nop
  8041d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8041d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8041dc:	0f 82 0f ff ff ff    	jb     8040f1 <__umoddi3+0x61>
  8041e2:	e9 1a ff ff ff       	jmp    804101 <__umoddi3+0x71>
