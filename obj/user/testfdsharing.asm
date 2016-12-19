
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 e8 01 00 00       	call   800219 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800043:	00 
  800044:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  80004b:	e8 83 1b 00 00       	call   801bd3 <open>
  800050:	89 c3                	mov    %eax,%ebx
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("open motd: %e", fd);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 85 2b 80 	movl   $0x802b85,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  800071:	e8 04 02 00 00       	call   80027a <_panic>
	seek(fd, 0);
  800076:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007d:	00 
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 de 17 00 00       	call   801864 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800086:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 20 52 80 	movl   $0x805220,0x4(%esp)
  800095:	00 
  800096:	89 1c 24             	mov    %ebx,(%esp)
  800099:	e8 ee 16 00 00       	call   80178c <readn>
  80009e:	89 c7                	mov    %eax,%edi
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	7f 20                	jg     8000c4 <umain+0x91>
		panic("readn: %e", n);
  8000a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a8:	c7 44 24 08 a8 2b 80 	movl   $0x802ba8,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b7:	00 
  8000b8:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8000bf:	e8 b6 01 00 00       	call   80027a <_panic>

	if ((r = fork()) < 0)
  8000c4:	e8 1b 11 00 00       	call   8011e4 <fork>
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	79 20                	jns    8000ef <umain+0xbc>
		panic("fork: %e", r);
  8000cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d3:	c7 44 24 08 b2 2b 80 	movl   $0x802bb2,0x8(%esp)
  8000da:	00 
  8000db:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e2:	00 
  8000e3:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8000ea:	e8 8b 01 00 00       	call   80027a <_panic>
	if (r == 0) {
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	0f 85 bd 00 00 00    	jne    8001b4 <umain+0x181>
		seek(fd, 0);
  8000f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fe:	00 
  8000ff:	89 1c 24             	mov    %ebx,(%esp)
  800102:	e8 5d 17 00 00       	call   801864 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800107:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  80010e:	e8 60 02 00 00       	call   800373 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800113:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  800122:	00 
  800123:	89 1c 24             	mov    %ebx,(%esp)
  800126:	e8 61 16 00 00       	call   80178c <readn>
  80012b:	39 f8                	cmp    %edi,%eax
  80012d:	74 24                	je     800153 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800137:	c7 44 24 08 34 2c 80 	movl   $0x802c34,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  80014e:	e8 27 01 00 00       	call   80027a <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 20 52 80 00 	movl   $0x805220,(%esp)
  800166:	e8 52 0a 00 00       	call   800bbd <memcmp>
  80016b:	85 c0                	test   %eax,%eax
  80016d:	74 1c                	je     80018b <umain+0x158>
			panic("read in parent got different bytes from read in child");
  80016f:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  800186:	e8 ef 00 00 00       	call   80027a <_panic>
		cprintf("read in child succeeded\n");
  80018b:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  800192:	e8 dc 01 00 00       	call   800373 <cprintf>
		seek(fd, 0);
  800197:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019e:	00 
  80019f:	89 1c 24             	mov    %ebx,(%esp)
  8001a2:	e8 bd 16 00 00       	call   801864 <seek>
		close(fd);
  8001a7:	89 1c 24             	mov    %ebx,(%esp)
  8001aa:	e8 e8 13 00 00       	call   801597 <close>
		exit();
  8001af:	e8 ad 00 00 00       	call   800261 <exit>
	}
	wait(r);
  8001b4:	89 34 24             	mov    %esi,(%esp)
  8001b7:	e8 3e 23 00 00       	call   8024fa <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  8001cb:	00 
  8001cc:	89 1c 24             	mov    %ebx,(%esp)
  8001cf:	e8 b8 15 00 00       	call   80178c <readn>
  8001d4:	39 f8                	cmp    %edi,%eax
  8001d6:	74 24                	je     8001fc <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e0:	c7 44 24 08 98 2c 80 	movl   $0x802c98,0x8(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8001f7:	e8 7e 00 00 00       	call   80027a <_panic>
	cprintf("read in parent succeeded\n");
  8001fc:	c7 04 24 d4 2b 80 00 	movl   $0x802bd4,(%esp)
  800203:	e8 6b 01 00 00       	call   800373 <cprintf>
	close(fd);
  800208:	89 1c 24             	mov    %ebx,(%esp)
  80020b:	e8 87 13 00 00       	call   801597 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800210:	cc                   	int3   

	breakpoint();
}
  800211:	83 c4 2c             	add    $0x2c,%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 10             	sub    $0x10,%esp
  800221:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800224:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800227:	e8 49 0b 00 00       	call   800d75 <sys_getenvid>
  80022c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800231:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800234:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800239:	a3 20 54 80 00       	mov    %eax,0x805420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7e 07                	jle    800249 <libmain+0x30>
		binaryname = argv[0];
  800242:	8b 06                	mov    (%esi),%eax
  800244:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800249:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024d:	89 1c 24             	mov    %ebx,(%esp)
  800250:	e8 de fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800255:	e8 07 00 00 00       	call   800261 <exit>
}
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800267:	e8 5e 13 00 00       	call   8015ca <close_all>
	sys_env_destroy(0);
  80026c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800273:	e8 ab 0a 00 00       	call   800d23 <sys_env_destroy>
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800282:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800285:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80028b:	e8 e5 0a 00 00       	call   800d75 <sys_getenvid>
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 54 24 10          	mov    %edx,0x10(%esp)
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a6:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  8002ad:	e8 c1 00 00 00       	call   800373 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 51 00 00 00       	call   800312 <vcprintf>
	cprintf("\n");
  8002c1:	c7 04 24 d2 2b 80 00 	movl   $0x802bd2,(%esp)
  8002c8:	e8 a6 00 00 00       	call   800373 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002cd:	cc                   	int3   
  8002ce:	eb fd                	jmp    8002cd <_panic+0x53>

008002d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 14             	sub    $0x14,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002da:	8b 13                	mov    (%ebx),%edx
  8002dc:	8d 42 01             	lea    0x1(%edx),%eax
  8002df:	89 03                	mov    %eax,(%ebx)
  8002e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ed:	75 19                	jne    800308 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002f6:	00 
  8002f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 e4 09 00 00       	call   800ce6 <sys_cputs>
		b->idx = 0;
  800302:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800308:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030c:	83 c4 14             	add    $0x14,%esp
  80030f:	5b                   	pop    %ebx
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80031b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800322:	00 00 00 
	b.cnt = 0;
  800325:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80032c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  80034e:	e8 ab 01 00 00       	call   8004fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 7b 09 00 00       	call   800ce6 <sys_cputs>

	return b.cnt;
}
  80036b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800379:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	e8 87 ff ff ff       	call   800312 <vcprintf>
	va_end(ap);

	return cnt;
}
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    
  80038d:	66 90                	xchg   %ax,%ax
  80038f:	90                   	nop

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	89 d7                	mov    %edx,%edi
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a7:	89 c3                	mov    %eax,%ebx
  8003a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8003af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003bd:	39 d9                	cmp    %ebx,%ecx
  8003bf:	72 05                	jb     8003c6 <printnum+0x36>
  8003c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003c4:	77 69                	ja     80042f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003cd:	83 ee 01             	sub    $0x1,%esi
  8003d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003e0:	89 c3                	mov    %eax,%ebx
  8003e2:	89 d6                	mov    %edx,%esi
  8003e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 dc 24 00 00       	call   8028e0 <__udivdi3>
  800404:	89 d9                	mov    %ebx,%ecx
  800406:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80040a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	89 54 24 04          	mov    %edx,0x4(%esp)
  800415:	89 fa                	mov    %edi,%edx
  800417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041a:	e8 71 ff ff ff       	call   800390 <printnum>
  80041f:	eb 1b                	jmp    80043c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800421:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800425:	8b 45 18             	mov    0x18(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff d3                	call   *%ebx
  80042d:	eb 03                	jmp    800432 <printnum+0xa2>
  80042f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800432:	83 ee 01             	sub    $0x1,%esi
  800435:	85 f6                	test   %esi,%esi
  800437:	7f e8                	jg     800421 <printnum+0x91>
  800439:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800447:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045f:	e8 ac 25 00 00       	call   802a10 <__umoddi3>
  800464:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800468:	0f be 80 eb 2c 80 00 	movsbl 0x802ceb(%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800475:	ff d0                	call   *%eax
}
  800477:	83 c4 3c             	add    $0x3c,%esp
  80047a:	5b                   	pop    %ebx
  80047b:	5e                   	pop    %esi
  80047c:	5f                   	pop    %edi
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800482:	83 fa 01             	cmp    $0x1,%edx
  800485:	7e 0e                	jle    800495 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800487:	8b 10                	mov    (%eax),%edx
  800489:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048c:	89 08                	mov    %ecx,(%eax)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	8b 52 04             	mov    0x4(%edx),%edx
  800493:	eb 22                	jmp    8004b7 <getuint+0x38>
	else if (lflag)
  800495:	85 d2                	test   %edx,%edx
  800497:	74 10                	je     8004a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800499:	8b 10                	mov    (%eax),%edx
  80049b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	eb 0e                	jmp    8004b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 0a                	jae    8004d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d2:	88 02                	mov    %al,(%edx)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 02 00 00 00       	call   8004fe <vprintfmt>
	va_end(ap);
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	53                   	push   %ebx
  800504:	83 ec 3c             	sub    $0x3c,%esp
  800507:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80050a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80050d:	eb 14                	jmp    800523 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050f:	85 c0                	test   %eax,%eax
  800511:	0f 84 b3 03 00 00    	je     8008ca <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800521:	89 f3                	mov    %esi,%ebx
  800523:	8d 73 01             	lea    0x1(%ebx),%esi
  800526:	0f b6 03             	movzbl (%ebx),%eax
  800529:	83 f8 25             	cmp    $0x25,%eax
  80052c:	75 e1                	jne    80050f <vprintfmt+0x11>
  80052e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800532:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800539:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800540:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800547:	ba 00 00 00 00       	mov    $0x0,%edx
  80054c:	eb 1d                	jmp    80056b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800550:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800554:	eb 15                	jmp    80056b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800558:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80055e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800561:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800564:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056e:	0f b6 0e             	movzbl (%esi),%ecx
  800571:	0f b6 c1             	movzbl %cl,%eax
  800574:	83 e9 23             	sub    $0x23,%ecx
  800577:	80 f9 55             	cmp    $0x55,%cl
  80057a:	0f 87 2a 03 00 00    	ja     8008aa <vprintfmt+0x3ac>
  800580:	0f b6 c9             	movzbl %cl,%ecx
  800583:	ff 24 8d 20 2e 80 00 	jmp    *0x802e20(,%ecx,4)
  80058a:	89 de                	mov    %ebx,%esi
  80058c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800591:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800594:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800598:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059e:	83 fb 09             	cmp    $0x9,%ebx
  8005a1:	77 36                	ja     8005d9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a6:	eb e9                	jmp    800591 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b8:	eb 22                	jmp    8005dc <vprintfmt+0xde>
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	85 c9                	test   %ecx,%ecx
  8005bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c4:	0f 49 c1             	cmovns %ecx,%eax
  8005c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	89 de                	mov    %ebx,%esi
  8005cc:	eb 9d                	jmp    80056b <vprintfmt+0x6d>
  8005ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005d7:	eb 92                	jmp    80056b <vprintfmt+0x6d>
  8005d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e0:	79 89                	jns    80056b <vprintfmt+0x6d>
  8005e2:	e9 77 ff ff ff       	jmp    80055e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ec:	e9 7a ff ff ff       	jmp    80056b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
			break;
  800606:	e9 18 ff ff ff       	jmp    800523 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	99                   	cltd   
  800617:	31 d0                	xor    %edx,%eax
  800619:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061b:	83 f8 0f             	cmp    $0xf,%eax
  80061e:	7f 0b                	jg     80062b <vprintfmt+0x12d>
  800620:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  800627:	85 d2                	test   %edx,%edx
  800629:	75 20                	jne    80064b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80062b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80062f:	c7 44 24 08 03 2d 80 	movl   $0x802d03,0x8(%esp)
  800636:	00 
  800637:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	e8 90 fe ff ff       	call   8004d6 <printfmt>
  800646:	e9 d8 fe ff ff       	jmp    800523 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80064b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064f:	c7 44 24 08 2d 31 80 	movl   $0x80312d,0x8(%esp)
  800656:	00 
  800657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	e8 70 fe ff ff       	call   8004d6 <printfmt>
  800666:	e9 b8 fe ff ff       	jmp    800523 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80066e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800671:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80067f:	85 f6                	test   %esi,%esi
  800681:	b8 fc 2c 80 00       	mov    $0x802cfc,%eax
  800686:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800689:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80068d:	0f 84 97 00 00 00    	je     80072a <vprintfmt+0x22c>
  800693:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800697:	0f 8e 9b 00 00 00    	jle    800738 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a1:	89 34 24             	mov    %esi,(%esp)
  8006a4:	e8 cf 02 00 00       	call   800978 <strnlen>
  8006a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ac:	29 c2                	sub    %eax,%edx
  8006ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006c1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	eb 0f                	jmp    8006d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 eb 01             	sub    $0x1,%ebx
  8006d4:	85 db                	test   %ebx,%ebx
  8006d6:	7f ed                	jg     8006c5 <vprintfmt+0x1c7>
  8006d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e5:	0f 49 c2             	cmovns %edx,%eax
  8006e8:	29 c2                	sub    %eax,%edx
  8006ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006ed:	89 d7                	mov    %edx,%edi
  8006ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f2:	eb 50                	jmp    800744 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f8:	74 1e                	je     800718 <vprintfmt+0x21a>
  8006fa:	0f be d2             	movsbl %dl,%edx
  8006fd:	83 ea 20             	sub    $0x20,%edx
  800700:	83 fa 5e             	cmp    $0x5e,%edx
  800703:	76 13                	jbe    800718 <vprintfmt+0x21a>
					putch('?', putdat);
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	eb 0d                	jmp    800725 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	eb 1a                	jmp    800744 <vprintfmt+0x246>
  80072a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80072d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800730:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800733:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800736:	eb 0c                	jmp    800744 <vprintfmt+0x246>
  800738:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80073b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80073e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800741:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800744:	83 c6 01             	add    $0x1,%esi
  800747:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80074b:	0f be c2             	movsbl %dl,%eax
  80074e:	85 c0                	test   %eax,%eax
  800750:	74 27                	je     800779 <vprintfmt+0x27b>
  800752:	85 db                	test   %ebx,%ebx
  800754:	78 9e                	js     8006f4 <vprintfmt+0x1f6>
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	79 99                	jns    8006f4 <vprintfmt+0x1f6>
  80075b:	89 f8                	mov    %edi,%eax
  80075d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	89 c3                	mov    %eax,%ebx
  800765:	eb 1a                	jmp    800781 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800767:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800772:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800774:	83 eb 01             	sub    $0x1,%ebx
  800777:	eb 08                	jmp    800781 <vprintfmt+0x283>
  800779:	89 fb                	mov    %edi,%ebx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800781:	85 db                	test   %ebx,%ebx
  800783:	7f e2                	jg     800767 <vprintfmt+0x269>
  800785:	89 75 08             	mov    %esi,0x8(%ebp)
  800788:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80078b:	e9 93 fd ff ff       	jmp    800523 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800790:	83 fa 01             	cmp    $0x1,%edx
  800793:	7e 16                	jle    8007ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 08             	lea    0x8(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	8b 50 04             	mov    0x4(%eax),%edx
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007a9:	eb 32                	jmp    8007dd <vprintfmt+0x2df>
	else if (lflag)
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 18                	je     8007c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 30                	mov    (%eax),%esi
  8007ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	c1 f8 1f             	sar    $0x1f,%eax
  8007c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c5:	eb 16                	jmp    8007dd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 30                	mov    (%eax),%esi
  8007d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	c1 f8 1f             	sar    $0x1f,%eax
  8007da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ec:	0f 89 80 00 00 00    	jns    800872 <vprintfmt+0x374>
				putch('-', putdat);
  8007f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800800:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800803:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800806:	f7 d8                	neg    %eax
  800808:	83 d2 00             	adc    $0x0,%edx
  80080b:	f7 da                	neg    %edx
			}
			base = 10;
  80080d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800812:	eb 5e                	jmp    800872 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
  800817:	e8 63 fc ff ff       	call   80047f <getuint>
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800821:	eb 4f                	jmp    800872 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 54 fc ff ff       	call   80047f <getuint>
			base = 8;
  80082b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800830:	eb 40                	jmp    800872 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80083d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800840:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800844:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80084b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8d 50 04             	lea    0x4(%eax),%edx
  800854:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800857:	8b 00                	mov    (%eax),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800863:	eb 0d                	jmp    800872 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 12 fc ff ff       	call   80047f <getuint>
			base = 16;
  80086d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800872:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800876:	89 74 24 10          	mov    %esi,0x10(%esp)
  80087a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80087d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800881:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088c:	89 fa                	mov    %edi,%edx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	e8 fa fa ff ff       	call   800390 <printnum>
			break;
  800896:	e9 88 fc ff ff       	jmp    800523 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a5:	e9 79 fc ff ff       	jmp    800523 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b8:	89 f3                	mov    %esi,%ebx
  8008ba:	eb 03                	jmp    8008bf <vprintfmt+0x3c1>
  8008bc:	83 eb 01             	sub    $0x1,%ebx
  8008bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c3:	75 f7                	jne    8008bc <vprintfmt+0x3be>
  8008c5:	e9 59 fc ff ff       	jmp    800523 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008ca:	83 c4 3c             	add    $0x3c,%esp
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	83 ec 28             	sub    $0x28,%esp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	74 30                	je     800923 <vsnprintf+0x51>
  8008f3:	85 d2                	test   %edx,%edx
  8008f5:	7e 2c                	jle    800923 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800901:	89 44 24 08          	mov    %eax,0x8(%esp)
  800905:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	c7 04 24 b9 04 80 00 	movl   $0x8004b9,(%esp)
  800913:	e8 e6 fb ff ff       	call   8004fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800918:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800921:	eb 05                	jmp    800928 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800923:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800930:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800937:	8b 45 10             	mov    0x10(%ebp),%eax
  80093a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 82 ff ff ff       	call   8008d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    
  800952:	66 90                	xchg   %ax,%ax
  800954:	66 90                	xchg   %ax,%ax
  800956:	66 90                	xchg   %ax,%ax
  800958:	66 90                	xchg   %ax,%ax
  80095a:	66 90                	xchg   %ax,%ax
  80095c:	66 90                	xchg   %ax,%ax
  80095e:	66 90                	xchg   %ax,%ax

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	eb 03                	jmp    800970 <strlen+0x10>
		n++;
  80096d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800970:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800974:	75 f7                	jne    80096d <strlen+0xd>
		n++;
	return n;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strnlen+0x13>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098b:	39 d0                	cmp    %edx,%eax
  80098d:	74 06                	je     800995 <strnlen+0x1d>
  80098f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800993:	75 f3                	jne    800988 <strnlen+0x10>
		n++;
	return n;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b0:	84 db                	test   %bl,%bl
  8009b2:	75 ef                	jne    8009a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c1:	89 1c 24             	mov    %ebx,(%esp)
  8009c4:	e8 97 ff ff ff       	call   800960 <strlen>
	strcpy(dst + len, src);
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d0:	01 d8                	add    %ebx,%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 bd ff ff ff       	call   800997 <strcpy>
	return dst;
}
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	83 c4 08             	add    $0x8,%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 0f                	jmp    800a05 <strncpy+0x23>
		*dst++ = *src;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800a02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a05:	39 da                	cmp    %ebx,%edx
  800a07:	75 ed                	jne    8009f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	75 0b                	jne    800a32 <strlcpy+0x23>
  800a27:	eb 1d                	jmp    800a46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	74 0b                	je     800a41 <strlcpy+0x32>
  800a36:	0f b6 0a             	movzbl (%edx),%ecx
  800a39:	84 c9                	test   %cl,%cl
  800a3b:	75 ec                	jne    800a29 <strlcpy+0x1a>
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	eb 02                	jmp    800a43 <strlcpy+0x34>
  800a41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a46:	29 f0                	sub    %esi,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a55:	eb 06                	jmp    800a5d <strcmp+0x11>
		p++, q++;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5d:	0f b6 01             	movzbl (%ecx),%eax
  800a60:	84 c0                	test   %al,%al
  800a62:	74 04                	je     800a68 <strcmp+0x1c>
  800a64:	3a 02                	cmp    (%edx),%al
  800a66:	74 ef                	je     800a57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 c0             	movzbl %al,%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strncmp+0x17>
		n--, p++, q++;
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a89:	39 d8                	cmp    %ebx,%eax
  800a8b:	74 15                	je     800aa2 <strncmp+0x30>
  800a8d:	0f b6 08             	movzbl (%eax),%ecx
  800a90:	84 c9                	test   %cl,%cl
  800a92:	74 04                	je     800a98 <strncmp+0x26>
  800a94:	3a 0a                	cmp    (%edx),%cl
  800a96:	74 eb                	je     800a83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 00             	movzbl (%eax),%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
  800aa0:	eb 05                	jmp    800aa7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab4:	eb 07                	jmp    800abd <strchr+0x13>
		if (*s == c)
  800ab6:	38 ca                	cmp    %cl,%dl
  800ab8:	74 0f                	je     800ac9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 f2                	jne    800ab6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	eb 07                	jmp    800ade <strfind+0x13>
		if (*s == c)
  800ad7:	38 ca                	cmp    %cl,%dl
  800ad9:	74 0a                	je     800ae5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	0f b6 10             	movzbl (%eax),%edx
  800ae1:	84 d2                	test   %dl,%dl
  800ae3:	75 f2                	jne    800ad7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af3:	85 c9                	test   %ecx,%ecx
  800af5:	74 36                	je     800b2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afd:	75 28                	jne    800b27 <memset+0x40>
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 23                	jne    800b27 <memset+0x40>
		c &= 0xFF;
  800b04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	c1 e3 08             	shl    $0x8,%ebx
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	c1 e6 18             	shl    $0x18,%esi
  800b12:	89 d0                	mov    %edx,%eax
  800b14:	c1 e0 10             	shl    $0x10,%eax
  800b17:	09 f0                	or     %esi,%eax
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b22:	fc                   	cld    
  800b23:	f3 ab                	rep stos %eax,%es:(%edi)
  800b25:	eb 06                	jmp    800b2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 35                	jae    800b7b <memmove+0x47>
  800b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 2e                	jae    800b7b <memmove+0x47>
		s += n;
		d += n;
  800b4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5a:	75 13                	jne    800b6f <memmove+0x3b>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0e                	jne    800b6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b61:	83 ef 04             	sub    $0x4,%edi
  800b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b6a:	fd                   	std    
  800b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6d:	eb 09                	jmp    800b78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b6f:	83 ef 01             	sub    $0x1,%edi
  800b72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b75:	fd                   	std    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b78:	fc                   	cld    
  800b79:	eb 1d                	jmp    800b98 <memmove+0x64>
  800b7b:	89 f2                	mov    %esi,%edx
  800b7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	f6 c2 03             	test   $0x3,%dl
  800b82:	75 0f                	jne    800b93 <memmove+0x5f>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0a                	jne    800b93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 05                	jmp    800b98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	e8 79 ff ff ff       	call   800b34 <memmove>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcd:	eb 1a                	jmp    800be9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bcf:	0f b6 02             	movzbl (%edx),%eax
  800bd2:	0f b6 19             	movzbl (%ecx),%ebx
  800bd5:	38 d8                	cmp    %bl,%al
  800bd7:	74 0a                	je     800be3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd9:	0f b6 c0             	movzbl %al,%eax
  800bdc:	0f b6 db             	movzbl %bl,%ebx
  800bdf:	29 d8                	sub    %ebx,%eax
  800be1:	eb 0f                	jmp    800bf2 <memcmp+0x35>
		s1++, s2++;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be9:	39 f2                	cmp    %esi,%edx
  800beb:	75 e2                	jne    800bcf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c04:	eb 07                	jmp    800c0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c06:	38 08                	cmp    %cl,(%eax)
  800c08:	74 07                	je     800c11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	72 f5                	jb     800c06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1f:	eb 03                	jmp    800c24 <strtol+0x11>
		s++;
  800c21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c24:	0f b6 0a             	movzbl (%edx),%ecx
  800c27:	80 f9 09             	cmp    $0x9,%cl
  800c2a:	74 f5                	je     800c21 <strtol+0xe>
  800c2c:	80 f9 20             	cmp    $0x20,%cl
  800c2f:	74 f0                	je     800c21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c31:	80 f9 2b             	cmp    $0x2b,%cl
  800c34:	75 0a                	jne    800c40 <strtol+0x2d>
		s++;
  800c36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3e:	eb 11                	jmp    800c51 <strtol+0x3e>
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c45:	80 f9 2d             	cmp    $0x2d,%cl
  800c48:	75 07                	jne    800c51 <strtol+0x3e>
		s++, neg = 1;
  800c4a:	8d 52 01             	lea    0x1(%edx),%edx
  800c4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c56:	75 15                	jne    800c6d <strtol+0x5a>
  800c58:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5b:	75 10                	jne    800c6d <strtol+0x5a>
  800c5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c61:	75 0a                	jne    800c6d <strtol+0x5a>
		s += 2, base = 16;
  800c63:	83 c2 02             	add    $0x2,%edx
  800c66:	b8 10 00 00 00       	mov    $0x10,%eax
  800c6b:	eb 10                	jmp    800c7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	75 0c                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	80 3a 30             	cmpb   $0x30,(%edx)
  800c76:	75 05                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
  800c78:	83 c2 01             	add    $0x1,%edx
  800c7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c85:	0f b6 0a             	movzbl (%edx),%ecx
  800c88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c8b:	89 f0                	mov    %esi,%eax
  800c8d:	3c 09                	cmp    $0x9,%al
  800c8f:	77 08                	ja     800c99 <strtol+0x86>
			dig = *s - '0';
  800c91:	0f be c9             	movsbl %cl,%ecx
  800c94:	83 e9 30             	sub    $0x30,%ecx
  800c97:	eb 20                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	3c 19                	cmp    $0x19,%al
  800ca0:	77 08                	ja     800caa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ca2:	0f be c9             	movsbl %cl,%ecx
  800ca5:	83 e9 57             	sub    $0x57,%ecx
  800ca8:	eb 0f                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800caa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	3c 19                	cmp    $0x19,%al
  800cb1:	77 16                	ja     800cc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cb3:	0f be c9             	movsbl %cl,%ecx
  800cb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cbc:	7d 0f                	jge    800ccd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cc7:	eb bc                	jmp    800c85 <strtol+0x72>
  800cc9:	89 d8                	mov    %ebx,%eax
  800ccb:	eb 02                	jmp    800ccf <strtol+0xbc>
  800ccd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ccf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd3:	74 05                	je     800cda <strtol+0xc7>
		*endptr = (char *) s;
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cda:	f7 d8                	neg    %eax
  800cdc:	85 ff                	test   %edi,%edi
  800cde:	0f 44 c3             	cmove  %ebx,%eax
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	89 c7                	mov    %eax,%edi
  800cfb:	89 c6                	mov    %eax,%esi
  800cfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 03 00 00 00       	mov    $0x3,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800d68:	e8 0d f5 ff ff       	call   80027a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 02 00 00 00       	mov    $0x2,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_yield>:

void
sys_yield(void)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da4:	89 d1                	mov    %edx,%ecx
  800da6:	89 d3                	mov    %edx,%ebx
  800da8:	89 d7                	mov    %edx,%edi
  800daa:	89 d6                	mov    %edx,%esi
  800dac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	be 00 00 00 00       	mov    $0x0,%esi
  800dc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	89 f7                	mov    %esi,%edi
  800dd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 28                	jle    800dff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800dea:	00 
  800deb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df2:	00 
  800df3:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800dfa:	e8 7b f4 ff ff       	call   80027a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dff:	83 c4 2c             	add    $0x2c,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	b8 05 00 00 00       	mov    $0x5,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e21:	8b 75 18             	mov    0x18(%ebp),%esi
  800e24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800e4d:	e8 28 f4 ff ff       	call   80027a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800ea0:	e8 d5 f3 ff ff       	call   80027a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea5:	83 c4 2c             	add    $0x2c,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800ef3:	e8 82 f3 ff ff       	call   80027a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef8:	83 c4 2c             	add    $0x2c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 df                	mov    %ebx,%edi
  800f1b:	89 de                	mov    %ebx,%esi
  800f1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7e 28                	jle    800f4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800f46:	e8 2f f3 ff ff       	call   80027a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f4b:	83 c4 2c             	add    $0x2c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 df                	mov    %ebx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 28                	jle    800f9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800f99:	e8 dc f2 ff ff       	call   80027a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f9e:	83 c4 2c             	add    $0x2c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	89 cb                	mov    %ecx,%ebx
  800fe1:	89 cf                	mov    %ecx,%edi
  800fe3:	89 ce                	mov    %ecx,%esi
  800fe5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 28                	jle    801013 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  80100e:	e8 67 f2 ff ff       	call   80027a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801013:	83 c4 2c             	add    $0x2c,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	b8 0e 00 00 00       	mov    $0xe,%eax
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 d7                	mov    %edx,%edi
  801031:	89 d6                	mov    %edx,%esi
  801033:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	bb 00 00 00 00       	mov    $0x0,%ebx
  801048:	b8 0f 00 00 00       	mov    $0xf,%eax
  80104d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801050:	8b 55 08             	mov    0x8(%ebp),%edx
  801053:	89 df                	mov    %ebx,%edi
  801055:	89 de                	mov    %ebx,%esi
  801057:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801080:	e8 f5 f1 ff ff       	call   80027a <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801085:	83 c4 2c             	add    $0x2c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109b:	b8 10 00 00 00       	mov    $0x10,%eax
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 df                	mov    %ebx,%edi
  8010a8:	89 de                	mov    %ebx,%esi
  8010aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  8010d3:	e8 a2 f1 ff ff       	call   80027a <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8010d8:	83 c4 2c             	add    $0x2c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 20             	sub    $0x20,%esp
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010eb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  8010ed:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010f1:	75 20                	jne    801113 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  8010f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010f7:	c7 44 24 08 0a 30 80 	movl   $0x80300a,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  80110e:	e8 67 f1 ff ff       	call   80027a <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801113:	89 f0                	mov    %esi,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
  801118:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111f:	f6 c4 08             	test   $0x8,%ah
  801122:	75 1c                	jne    801140 <pgfault+0x60>
		panic("Not a COW page");
  801124:	c7 44 24 08 26 30 80 	movl   $0x803026,0x8(%esp)
  80112b:	00 
  80112c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801133:	00 
  801134:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  80113b:	e8 3a f1 ff ff       	call   80027a <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801140:	e8 30 fc ff ff       	call   800d75 <sys_getenvid>
  801145:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801147:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801156:	00 
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 54 fc ff ff       	call   800db3 <sys_page_alloc>
	if(r < 0) {
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 1c                	jns    80117f <pgfault+0x9f>
		panic("couldn't allocate page");
  801163:	c7 44 24 08 35 30 80 	movl   $0x803035,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  80117a:	e8 fb f0 ff ff       	call   80027a <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80117f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801185:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80118c:	00 
  80118d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801191:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801198:	e8 97 f9 ff ff       	call   800b34 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80119d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011a4:	00 
  8011a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011b4:	00 
  8011b5:	89 1c 24             	mov    %ebx,(%esp)
  8011b8:	e8 4a fc ff ff       	call   800e07 <sys_page_map>
	if(r < 0) {
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	79 1c                	jns    8011dd <pgfault+0xfd>
		panic("couldn't map page");
  8011c1:	c7 44 24 08 4c 30 80 	movl   $0x80304c,0x8(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8011d0:	00 
  8011d1:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  8011d8:	e8 9d f0 ff ff       	call   80027a <_panic>
	}
}
  8011dd:	83 c4 20             	add    $0x20,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	57                   	push   %edi
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8011ed:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  8011f4:	e8 0d 15 00 00       	call   802706 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8011fe:	cd 30                	int    $0x30
  801200:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801203:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801206:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80120d:	bf 00 00 00 00       	mov    $0x0,%edi
  801212:	85 c0                	test   %eax,%eax
  801214:	75 21                	jne    801237 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801216:	e8 5a fb ff ff       	call   800d75 <sys_getenvid>
  80121b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801220:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801223:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801228:	a3 20 54 80 00       	mov    %eax,0x805420
		return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	e9 8d 01 00 00       	jmp    8013c4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801237:	89 f8                	mov    %edi,%eax
  801239:	c1 e8 16             	shr    $0x16,%eax
  80123c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801243:	85 c0                	test   %eax,%eax
  801245:	0f 84 02 01 00 00    	je     80134d <fork+0x169>
  80124b:	89 fa                	mov    %edi,%edx
  80124d:	c1 ea 0c             	shr    $0xc,%edx
  801250:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801257:	85 c0                	test   %eax,%eax
  801259:	0f 84 ee 00 00 00    	je     80134d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80125f:	89 d6                	mov    %edx,%esi
  801261:	c1 e6 0c             	shl    $0xc,%esi
  801264:	89 f0                	mov    %esi,%eax
  801266:	c1 e8 16             	shr    $0x16,%eax
  801269:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	f6 c1 01             	test   $0x1,%cl
  801278:	0f 84 cc 00 00 00    	je     80134a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80127e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801285:	89 d8                	mov    %ebx,%eax
  801287:	25 07 0e 00 00       	and    $0xe07,%eax
  80128c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80128f:	89 d8                	mov    %ebx,%eax
  801291:	83 e0 01             	and    $0x1,%eax
  801294:	0f 84 b0 00 00 00    	je     80134a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80129a:	e8 d6 fa ff ff       	call   800d75 <sys_getenvid>
  80129f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8012a2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8012a9:	74 28                	je     8012d3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8012ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c9:	89 04 24             	mov    %eax,(%esp)
  8012cc:	e8 36 fb ff ff       	call   800e07 <sys_page_map>
  8012d1:	eb 77                	jmp    80134a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8012d3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8012d9:	74 4e                	je     801329 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8012db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012de:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8012e3:	80 cc 08             	or     $0x8,%ah
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fe:	89 04 24             	mov    %eax,(%esp)
  801301:	e8 01 fb ff ff       	call   800e07 <sys_page_map>
  801306:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801309:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80130d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801311:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801314:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801318:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131c:	89 0c 24             	mov    %ecx,(%esp)
  80131f:	e8 e3 fa ff ff       	call   800e07 <sys_page_map>
  801324:	03 45 e0             	add    -0x20(%ebp),%eax
  801327:	eb 21                	jmp    80134a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801330:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801337:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80133f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	e8 bd fa ff ff       	call   800e07 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80134a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80134d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801353:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801359:	0f 85 d8 fe ff ff    	jne    801237 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80135f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801366:	00 
  801367:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80136e:	ee 
  80136f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801372:	89 34 24             	mov    %esi,(%esp)
  801375:	e8 39 fa ff ff       	call   800db3 <sys_page_alloc>
  80137a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80137d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80137f:	c7 44 24 04 53 27 80 	movl   $0x802753,0x4(%esp)
  801386:	00 
  801387:	89 34 24             	mov    %esi,(%esp)
  80138a:	e8 c4 fb ff ff       	call   800f53 <sys_env_set_pgfault_upcall>
  80138f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801391:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801398:	00 
  801399:	89 34 24             	mov    %esi,(%esp)
  80139c:	e8 0c fb ff ff       	call   800ead <sys_env_set_status>

	if(r<0) {
  8013a1:	01 d8                	add    %ebx,%eax
  8013a3:	79 1c                	jns    8013c1 <fork+0x1dd>
	 panic("fork failed!");
  8013a5:	c7 44 24 08 5e 30 80 	movl   $0x80305e,0x8(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8013b4:	00 
  8013b5:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  8013bc:	e8 b9 ee ff ff       	call   80027a <_panic>
	}

	return envid;
  8013c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8013c4:	83 c4 3c             	add    $0x3c,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <sfork>:

// Challenge!
int
sfork(void)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013d2:	c7 44 24 08 6b 30 80 	movl   $0x80306b,0x8(%esp)
  8013d9:	00 
  8013da:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8013e1:	00 
  8013e2:	c7 04 24 1b 30 80 00 	movl   $0x80301b,(%esp)
  8013e9:	e8 8c ee ff ff       	call   80027a <_panic>
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80140b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801422:	89 c2                	mov    %eax,%edx
  801424:	c1 ea 16             	shr    $0x16,%edx
  801427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142e:	f6 c2 01             	test   $0x1,%dl
  801431:	74 11                	je     801444 <fd_alloc+0x2d>
  801433:	89 c2                	mov    %eax,%edx
  801435:	c1 ea 0c             	shr    $0xc,%edx
  801438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	75 09                	jne    80144d <fd_alloc+0x36>
			*fd_store = fd;
  801444:	89 01                	mov    %eax,(%ecx)
			return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	eb 17                	jmp    801464 <fd_alloc+0x4d>
  80144d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801457:	75 c9                	jne    801422 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80145f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80146c:	83 f8 1f             	cmp    $0x1f,%eax
  80146f:	77 36                	ja     8014a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801471:	c1 e0 0c             	shl    $0xc,%eax
  801474:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801479:	89 c2                	mov    %eax,%edx
  80147b:	c1 ea 16             	shr    $0x16,%edx
  80147e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801485:	f6 c2 01             	test   $0x1,%dl
  801488:	74 24                	je     8014ae <fd_lookup+0x48>
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 ea 0c             	shr    $0xc,%edx
  80148f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801496:	f6 c2 01             	test   $0x1,%dl
  801499:	74 1a                	je     8014b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	89 02                	mov    %eax,(%edx)
	return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a5:	eb 13                	jmp    8014ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 0c                	jmp    8014ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b3:	eb 05                	jmp    8014ba <fd_lookup+0x54>
  8014b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
  8014c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	eb 13                	jmp    8014df <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8014cc:	39 08                	cmp    %ecx,(%eax)
  8014ce:	75 0c                	jne    8014dc <dev_lookup+0x20>
			*dev = devtab[i];
  8014d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	eb 38                	jmp    801514 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014dc:	83 c2 01             	add    $0x1,%edx
  8014df:	8b 04 95 00 31 80 00 	mov    0x803100(,%edx,4),%eax
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	75 e2                	jne    8014cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ea:	a1 20 54 80 00       	mov    0x805420,%eax
  8014ef:	8b 40 48             	mov    0x48(%eax),%eax
  8014f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	c7 04 24 84 30 80 00 	movl   $0x803084,(%esp)
  801501:	e8 6d ee ff ff       	call   800373 <cprintf>
	*dev = 0;
  801506:	8b 45 0c             	mov    0xc(%ebp),%eax
  801509:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 20             	sub    $0x20,%esp
  80151e:	8b 75 08             	mov    0x8(%ebp),%esi
  801521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801531:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 2a ff ff ff       	call   801466 <fd_lookup>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 05                	js     801545 <fd_close+0x2f>
	    || fd != fd2)
  801540:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801543:	74 0c                	je     801551 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801545:	84 db                	test   %bl,%bl
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	0f 44 c2             	cmove  %edx,%eax
  80154f:	eb 3f                	jmp    801590 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801551:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	8b 06                	mov    (%esi),%eax
  80155a:	89 04 24             	mov    %eax,(%esp)
  80155d:	e8 5a ff ff ff       	call   8014bc <dev_lookup>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 16                	js     80157e <fd_close+0x68>
		if (dev->dev_close)
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80156e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801573:	85 c0                	test   %eax,%eax
  801575:	74 07                	je     80157e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801577:	89 34 24             	mov    %esi,(%esp)
  80157a:	ff d0                	call   *%eax
  80157c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80157e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801582:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801589:	e8 cc f8 ff ff       	call   800e5a <sys_page_unmap>
	return r;
  80158e:	89 d8                	mov    %ebx,%eax
}
  801590:	83 c4 20             	add    $0x20,%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 b7 fe ff ff       	call   801466 <fd_lookup>
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	85 d2                	test   %edx,%edx
  8015b3:	78 13                	js     8015c8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015bc:	00 
  8015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 4e ff ff ff       	call   801516 <fd_close>
}
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <close_all>:

void
close_all(void)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d6:	89 1c 24             	mov    %ebx,(%esp)
  8015d9:	e8 b9 ff ff ff       	call   801597 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015de:	83 c3 01             	add    $0x1,%ebx
  8015e1:	83 fb 20             	cmp    $0x20,%ebx
  8015e4:	75 f0                	jne    8015d6 <close_all+0xc>
		close(i);
}
  8015e6:	83 c4 14             	add    $0x14,%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	57                   	push   %edi
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	89 04 24             	mov    %eax,(%esp)
  801602:	e8 5f fe ff ff       	call   801466 <fd_lookup>
  801607:	89 c2                	mov    %eax,%edx
  801609:	85 d2                	test   %edx,%edx
  80160b:	0f 88 e1 00 00 00    	js     8016f2 <dup+0x106>
		return r;
	close(newfdnum);
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	89 04 24             	mov    %eax,(%esp)
  801617:	e8 7b ff ff ff       	call   801597 <close>

	newfd = INDEX2FD(newfdnum);
  80161c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80161f:	c1 e3 0c             	shl    $0xc,%ebx
  801622:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162b:	89 04 24             	mov    %eax,(%esp)
  80162e:	e8 cd fd ff ff       	call   801400 <fd2data>
  801633:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801635:	89 1c 24             	mov    %ebx,(%esp)
  801638:	e8 c3 fd ff ff       	call   801400 <fd2data>
  80163d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80163f:	89 f0                	mov    %esi,%eax
  801641:	c1 e8 16             	shr    $0x16,%eax
  801644:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164b:	a8 01                	test   $0x1,%al
  80164d:	74 43                	je     801692 <dup+0xa6>
  80164f:	89 f0                	mov    %esi,%eax
  801651:	c1 e8 0c             	shr    $0xc,%eax
  801654:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80165b:	f6 c2 01             	test   $0x1,%dl
  80165e:	74 32                	je     801692 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801660:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801667:	25 07 0e 00 00       	and    $0xe07,%eax
  80166c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801670:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801674:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80167b:	00 
  80167c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801687:	e8 7b f7 ff ff       	call   800e07 <sys_page_map>
  80168c:	89 c6                	mov    %eax,%esi
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 3e                	js     8016d0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801695:	89 c2                	mov    %eax,%edx
  801697:	c1 ea 0c             	shr    $0xc,%edx
  80169a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b6:	00 
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c2:	e8 40 f7 ff ff       	call   800e07 <sys_page_map>
  8016c7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cc:	85 f6                	test   %esi,%esi
  8016ce:	79 22                	jns    8016f2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016db:	e8 7a f7 ff ff       	call   800e5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016eb:	e8 6a f7 ff ff       	call   800e5a <sys_page_unmap>
	return r;
  8016f0:	89 f0                	mov    %esi,%eax
}
  8016f2:	83 c4 3c             	add    $0x3c,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 24             	sub    $0x24,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	89 1c 24             	mov    %ebx,(%esp)
  80170e:	e8 53 fd ff ff       	call   801466 <fd_lookup>
  801713:	89 c2                	mov    %eax,%edx
  801715:	85 d2                	test   %edx,%edx
  801717:	78 6d                	js     801786 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	8b 00                	mov    (%eax),%eax
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	e8 8f fd ff ff       	call   8014bc <dev_lookup>
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 55                	js     801786 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	8b 50 08             	mov    0x8(%eax),%edx
  801737:	83 e2 03             	and    $0x3,%edx
  80173a:	83 fa 01             	cmp    $0x1,%edx
  80173d:	75 23                	jne    801762 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173f:	a1 20 54 80 00       	mov    0x805420,%eax
  801744:	8b 40 48             	mov    0x48(%eax),%eax
  801747:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80174b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174f:	c7 04 24 c5 30 80 00 	movl   $0x8030c5,(%esp)
  801756:	e8 18 ec ff ff       	call   800373 <cprintf>
		return -E_INVAL;
  80175b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801760:	eb 24                	jmp    801786 <read+0x8c>
	}
	if (!dev->dev_read)
  801762:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801765:	8b 52 08             	mov    0x8(%edx),%edx
  801768:	85 d2                	test   %edx,%edx
  80176a:	74 15                	je     801781 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80176c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801776:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	ff d2                	call   *%edx
  80177f:	eb 05                	jmp    801786 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801781:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801786:	83 c4 24             	add    $0x24,%esp
  801789:	5b                   	pop    %ebx
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	83 ec 1c             	sub    $0x1c,%esp
  801795:	8b 7d 08             	mov    0x8(%ebp),%edi
  801798:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a0:	eb 23                	jmp    8017c5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a2:	89 f0                	mov    %esi,%eax
  8017a4:	29 d8                	sub    %ebx,%eax
  8017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	03 45 0c             	add    0xc(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	89 3c 24             	mov    %edi,(%esp)
  8017b6:	e8 3f ff ff ff       	call   8016fa <read>
		if (m < 0)
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 10                	js     8017cf <readn+0x43>
			return m;
		if (m == 0)
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	74 0a                	je     8017cd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c3:	01 c3                	add    %eax,%ebx
  8017c5:	39 f3                	cmp    %esi,%ebx
  8017c7:	72 d9                	jb     8017a2 <readn+0x16>
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 02                	jmp    8017cf <readn+0x43>
  8017cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017cf:	83 c4 1c             	add    $0x1c,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5f                   	pop    %edi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 24             	sub    $0x24,%esp
  8017de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e8:	89 1c 24             	mov    %ebx,(%esp)
  8017eb:	e8 76 fc ff ff       	call   801466 <fd_lookup>
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	85 d2                	test   %edx,%edx
  8017f4:	78 68                	js     80185e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	8b 00                	mov    (%eax),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 b2 fc ff ff       	call   8014bc <dev_lookup>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 50                	js     80185e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801815:	75 23                	jne    80183a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801817:	a1 20 54 80 00       	mov    0x805420,%eax
  80181c:	8b 40 48             	mov    0x48(%eax),%eax
  80181f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	c7 04 24 e1 30 80 00 	movl   $0x8030e1,(%esp)
  80182e:	e8 40 eb ff ff       	call   800373 <cprintf>
		return -E_INVAL;
  801833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801838:	eb 24                	jmp    80185e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80183a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183d:	8b 52 0c             	mov    0xc(%edx),%edx
  801840:	85 d2                	test   %edx,%edx
  801842:	74 15                	je     801859 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801844:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801847:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	ff d2                	call   *%edx
  801857:	eb 05                	jmp    80185e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801859:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80185e:	83 c4 24             	add    $0x24,%esp
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <seek>:

int
seek(int fdnum, off_t offset)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80186d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	89 04 24             	mov    %eax,(%esp)
  801877:	e8 ea fb ff ff       	call   801466 <fd_lookup>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 0e                	js     80188e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801880:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801883:	8b 55 0c             	mov    0xc(%ebp),%edx
  801886:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	53                   	push   %ebx
  801894:	83 ec 24             	sub    $0x24,%esp
  801897:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	89 1c 24             	mov    %ebx,(%esp)
  8018a4:	e8 bd fb ff ff       	call   801466 <fd_lookup>
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	85 d2                	test   %edx,%edx
  8018ad:	78 61                	js     801910 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	8b 00                	mov    (%eax),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 f9 fb ff ff       	call   8014bc <dev_lookup>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 49                	js     801910 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ce:	75 23                	jne    8018f3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d0:	a1 20 54 80 00       	mov    0x805420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018d5:	8b 40 48             	mov    0x48(%eax),%eax
  8018d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e0:	c7 04 24 a4 30 80 00 	movl   $0x8030a4,(%esp)
  8018e7:	e8 87 ea ff ff       	call   800373 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f1:	eb 1d                	jmp    801910 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f6:	8b 52 18             	mov    0x18(%edx),%edx
  8018f9:	85 d2                	test   %edx,%edx
  8018fb:	74 0e                	je     80190b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801900:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	ff d2                	call   *%edx
  801909:	eb 05                	jmp    801910 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80190b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801910:	83 c4 24             	add    $0x24,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	53                   	push   %ebx
  80191a:	83 ec 24             	sub    $0x24,%esp
  80191d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801920:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801923:	89 44 24 04          	mov    %eax,0x4(%esp)
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	89 04 24             	mov    %eax,(%esp)
  80192d:	e8 34 fb ff ff       	call   801466 <fd_lookup>
  801932:	89 c2                	mov    %eax,%edx
  801934:	85 d2                	test   %edx,%edx
  801936:	78 52                	js     80198a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	8b 00                	mov    (%eax),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 70 fb ff ff       	call   8014bc <dev_lookup>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 3a                	js     80198a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801957:	74 2c                	je     801985 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801959:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80195c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801963:	00 00 00 
	stat->st_isdir = 0;
  801966:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196d:	00 00 00 
	stat->st_dev = dev;
  801970:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801976:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80197d:	89 14 24             	mov    %edx,(%esp)
  801980:	ff 50 14             	call   *0x14(%eax)
  801983:	eb 05                	jmp    80198a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80198a:	83 c4 24             	add    $0x24,%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801998:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80199f:	00 
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 28 02 00 00       	call   801bd3 <open>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	78 1b                	js     8019cc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	89 1c 24             	mov    %ebx,(%esp)
  8019bb:	e8 56 ff ff ff       	call   801916 <fstat>
  8019c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019c2:	89 1c 24             	mov    %ebx,(%esp)
  8019c5:	e8 cd fb ff ff       	call   801597 <close>
	return r;
  8019ca:	89 f0                	mov    %esi,%eax
}
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 10             	sub    $0x10,%esp
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019df:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019e6:	75 11                	jne    8019f9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ef:	e8 71 0e 00 00       	call   802865 <ipc_find_env>
  8019f4:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a00:	00 
  801a01:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a08:	00 
  801a09:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a0d:	a1 00 50 80 00       	mov    0x805000,%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 e0 0d 00 00       	call   8027fa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a21:	00 
  801a22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2d:	e8 4e 0d 00 00       	call   802780 <ipc_recv>
}
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	8b 40 0c             	mov    0xc(%eax),%eax
  801a45:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5c:	e8 72 ff ff ff       	call   8019d3 <fsipc>
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7e:	e8 50 ff ff ff       	call   8019d3 <fsipc>
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	53                   	push   %ebx
  801a89:	83 ec 14             	sub    $0x14,%esp
  801a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	8b 40 0c             	mov    0xc(%eax),%eax
  801a95:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9f:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa4:	e8 2a ff ff ff       	call   8019d3 <fsipc>
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	85 d2                	test   %edx,%edx
  801aad:	78 2b                	js     801ada <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aaf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ab6:	00 
  801ab7:	89 1c 24             	mov    %ebx,(%esp)
  801aba:	e8 d8 ee ff ff       	call   800997 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801abf:	a1 80 60 80 00       	mov    0x806080,%eax
  801ac4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aca:	a1 84 60 80 00       	mov    0x806084,%eax
  801acf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ada:	83 c4 14             	add    $0x14,%esp
  801add:	5b                   	pop    %ebx
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 18             	sub    $0x18,%esp
  801ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801af6:	8b 55 08             	mov    0x8(%ebp),%edx
  801af9:	8b 52 0c             	mov    0xc(%edx),%edx
  801afc:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b02:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b12:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801b19:	e8 16 f0 ff ff       	call   800b34 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 04 00 00 00       	mov    $0x4,%eax
  801b28:	e8 a6 fe ff ff       	call   8019d3 <fsipc>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 10             	sub    $0x10,%esp
  801b37:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b45:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b50:	b8 03 00 00 00       	mov    $0x3,%eax
  801b55:	e8 79 fe ff ff       	call   8019d3 <fsipc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 6a                	js     801bca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b60:	39 c6                	cmp    %eax,%esi
  801b62:	73 24                	jae    801b88 <devfile_read+0x59>
  801b64:	c7 44 24 0c 14 31 80 	movl   $0x803114,0xc(%esp)
  801b6b:	00 
  801b6c:	c7 44 24 08 1b 31 80 	movl   $0x80311b,0x8(%esp)
  801b73:	00 
  801b74:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b7b:	00 
  801b7c:	c7 04 24 30 31 80 00 	movl   $0x803130,(%esp)
  801b83:	e8 f2 e6 ff ff       	call   80027a <_panic>
	assert(r <= PGSIZE);
  801b88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b8d:	7e 24                	jle    801bb3 <devfile_read+0x84>
  801b8f:	c7 44 24 0c 3b 31 80 	movl   $0x80313b,0xc(%esp)
  801b96:	00 
  801b97:	c7 44 24 08 1b 31 80 	movl   $0x80311b,0x8(%esp)
  801b9e:	00 
  801b9f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ba6:	00 
  801ba7:	c7 04 24 30 31 80 00 	movl   $0x803130,(%esp)
  801bae:	e8 c7 e6 ff ff       	call   80027a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bbe:	00 
  801bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 6a ef ff ff       	call   800b34 <memmove>
	return r;
}
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 24             	sub    $0x24,%esp
  801bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bdd:	89 1c 24             	mov    %ebx,(%esp)
  801be0:	e8 7b ed ff ff       	call   800960 <strlen>
  801be5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bea:	7f 60                	jg     801c4c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 20 f8 ff ff       	call   801417 <fd_alloc>
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	85 d2                	test   %edx,%edx
  801bfb:	78 54                	js     801c51 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c01:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c08:	e8 8a ed ff ff       	call   800997 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c10:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c18:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1d:	e8 b1 fd ff ff       	call   8019d3 <fsipc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	85 c0                	test   %eax,%eax
  801c26:	79 17                	jns    801c3f <open+0x6c>
		fd_close(fd, 0);
  801c28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c2f:	00 
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	89 04 24             	mov    %eax,(%esp)
  801c36:	e8 db f8 ff ff       	call   801516 <fd_close>
		return r;
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	eb 12                	jmp    801c51 <open+0x7e>
	}

	return fd2num(fd);
  801c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 a6 f7 ff ff       	call   8013f0 <fd2num>
  801c4a:	eb 05                	jmp    801c51 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c4c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c51:	83 c4 24             	add    $0x24,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c62:	b8 08 00 00 00       	mov    $0x8,%eax
  801c67:	e8 67 fd ff ff       	call   8019d3 <fsipc>
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c76:	c7 44 24 04 47 31 80 	movl   $0x803147,0x4(%esp)
  801c7d:	00 
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 0e ed ff ff       	call   800997 <strcpy>
	return 0;
}
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	53                   	push   %ebx
  801c94:	83 ec 14             	sub    $0x14,%esp
  801c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c9a:	89 1c 24             	mov    %ebx,(%esp)
  801c9d:	e8 fb 0b 00 00       	call   80289d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ca7:	83 f8 01             	cmp    $0x1,%eax
  801caa:	75 0d                	jne    801cb9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801cac:	8b 43 0c             	mov    0xc(%ebx),%eax
  801caf:	89 04 24             	mov    %eax,(%esp)
  801cb2:	e8 29 03 00 00       	call   801fe0 <nsipc_close>
  801cb7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	83 c4 14             	add    $0x14,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cc7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cce:	00 
  801ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce3:	89 04 24             	mov    %eax,(%esp)
  801ce6:	e8 f0 03 00 00       	call   8020db <nsipc_send>
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cf3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cfa:	00 
  801cfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 44 03 00 00       	call   80205b <nsipc_recv>
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d22:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 38 f7 ff ff       	call   801466 <fd_lookup>
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 17                	js     801d49 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801d3b:	39 08                	cmp    %ecx,(%eax)
  801d3d:	75 05                	jne    801d44 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d42:	eb 05                	jmp    801d49 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 20             	sub    $0x20,%esp
  801d53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 b7 f6 ff ff       	call   801417 <fd_alloc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 21                	js     801d87 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d6d:	00 
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7c:	e8 32 f0 ff ff       	call   800db3 <sys_page_alloc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	79 0c                	jns    801d93 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801d87:	89 34 24             	mov    %esi,(%esp)
  801d8a:	e8 51 02 00 00       	call   801fe0 <nsipc_close>
		return r;
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	eb 20                	jmp    801db3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d93:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801da8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801dab:	89 14 24             	mov    %edx,(%esp)
  801dae:	e8 3d f6 ff ff       	call   8013f0 <fd2num>
}
  801db3:	83 c4 20             	add    $0x20,%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	e8 51 ff ff ff       	call   801d19 <fd2sockid>
		return r;
  801dc8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 23                	js     801df1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dce:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ddc:	89 04 24             	mov    %eax,(%esp)
  801ddf:	e8 45 01 00 00       	call   801f29 <nsipc_accept>
		return r;
  801de4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 07                	js     801df1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801dea:	e8 5c ff ff ff       	call   801d4b <alloc_sockfd>
  801def:	89 c1                	mov    %eax,%ecx
}
  801df1:	89 c8                	mov    %ecx,%eax
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	e8 16 ff ff ff       	call   801d19 <fd2sockid>
  801e03:	89 c2                	mov    %eax,%edx
  801e05:	85 d2                	test   %edx,%edx
  801e07:	78 16                	js     801e1f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801e09:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e17:	89 14 24             	mov    %edx,(%esp)
  801e1a:	e8 60 01 00 00       	call   801f7f <nsipc_bind>
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <shutdown>:

int
shutdown(int s, int how)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	e8 ea fe ff ff       	call   801d19 <fd2sockid>
  801e2f:	89 c2                	mov    %eax,%edx
  801e31:	85 d2                	test   %edx,%edx
  801e33:	78 0f                	js     801e44 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	89 14 24             	mov    %edx,(%esp)
  801e3f:	e8 7a 01 00 00       	call   801fbe <nsipc_shutdown>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	e8 c5 fe ff ff       	call   801d19 <fd2sockid>
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	85 d2                	test   %edx,%edx
  801e58:	78 16                	js     801e70 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801e5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e68:	89 14 24             	mov    %edx,(%esp)
  801e6b:	e8 8a 01 00 00       	call   801ffa <nsipc_connect>
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <listen>:

int
listen(int s, int backlog)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	e8 99 fe ff ff       	call   801d19 <fd2sockid>
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	85 d2                	test   %edx,%edx
  801e84:	78 0f                	js     801e95 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8d:	89 14 24             	mov    %edx,(%esp)
  801e90:	e8 a4 01 00 00       	call   802039 <nsipc_listen>
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	89 04 24             	mov    %eax,(%esp)
  801eb1:	e8 98 02 00 00       	call   80214e <nsipc_socket>
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	85 d2                	test   %edx,%edx
  801eba:	78 05                	js     801ec1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801ebc:	e8 8a fe ff ff       	call   801d4b <alloc_sockfd>
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 14             	sub    $0x14,%esp
  801eca:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ecc:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ed3:	75 11                	jne    801ee6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ed5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801edc:	e8 84 09 00 00       	call   802865 <ipc_find_env>
  801ee1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ee6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eed:	00 
  801eee:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801ef5:	00 
  801ef6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801efa:	a1 04 50 80 00       	mov    0x805004,%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 f3 08 00 00       	call   8027fa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f0e:	00 
  801f0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f16:	00 
  801f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1e:	e8 5d 08 00 00       	call   802780 <ipc_recv>
}
  801f23:	83 c4 14             	add    $0x14,%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 10             	sub    $0x10,%esp
  801f31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f3c:	8b 06                	mov    (%esi),%eax
  801f3e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f43:	b8 01 00 00 00       	mov    $0x1,%eax
  801f48:	e8 76 ff ff ff       	call   801ec3 <nsipc>
  801f4d:	89 c3                	mov    %eax,%ebx
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 23                	js     801f76 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f53:	a1 10 70 80 00       	mov    0x807010,%eax
  801f58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801f63:	00 
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	89 04 24             	mov    %eax,(%esp)
  801f6a:	e8 c5 eb ff ff       	call   800b34 <memmove>
		*addrlen = ret->ret_addrlen;
  801f6f:	a1 10 70 80 00       	mov    0x807010,%eax
  801f74:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	53                   	push   %ebx
  801f83:	83 ec 14             	sub    $0x14,%esp
  801f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fa3:	e8 8c eb ff ff       	call   800b34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fa8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801fae:	b8 02 00 00 00       	mov    $0x2,%eax
  801fb3:	e8 0b ff ff ff       	call   801ec3 <nsipc>
}
  801fb8:	83 c4 14             	add    $0x14,%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fd4:	b8 03 00 00 00       	mov    $0x3,%eax
  801fd9:	e8 e5 fe ff ff       	call   801ec3 <nsipc>
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <nsipc_close>:

int
nsipc_close(int s)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fee:	b8 04 00 00 00       	mov    $0x4,%eax
  801ff3:	e8 cb fe ff ff       	call   801ec3 <nsipc>
}
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 14             	sub    $0x14,%esp
  802001:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802004:	8b 45 08             	mov    0x8(%ebp),%eax
  802007:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80200c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802010:	8b 45 0c             	mov    0xc(%ebp),%eax
  802013:	89 44 24 04          	mov    %eax,0x4(%esp)
  802017:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80201e:	e8 11 eb ff ff       	call   800b34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802023:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802029:	b8 05 00 00 00       	mov    $0x5,%eax
  80202e:	e8 90 fe ff ff       	call   801ec3 <nsipc>
}
  802033:	83 c4 14             	add    $0x14,%esp
  802036:	5b                   	pop    %ebx
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80203f:	8b 45 08             	mov    0x8(%ebp),%eax
  802042:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80204f:	b8 06 00 00 00       	mov    $0x6,%eax
  802054:	e8 6a fe ff ff       	call   801ec3 <nsipc>
}
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 10             	sub    $0x10,%esp
  802063:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80206e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802074:	8b 45 14             	mov    0x14(%ebp),%eax
  802077:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80207c:	b8 07 00 00 00       	mov    $0x7,%eax
  802081:	e8 3d fe ff ff       	call   801ec3 <nsipc>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 46                	js     8020d2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80208c:	39 f0                	cmp    %esi,%eax
  80208e:	7f 07                	jg     802097 <nsipc_recv+0x3c>
  802090:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802095:	7e 24                	jle    8020bb <nsipc_recv+0x60>
  802097:	c7 44 24 0c 53 31 80 	movl   $0x803153,0xc(%esp)
  80209e:	00 
  80209f:	c7 44 24 08 1b 31 80 	movl   $0x80311b,0x8(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8020ae:	00 
  8020af:	c7 04 24 68 31 80 00 	movl   $0x803168,(%esp)
  8020b6:	e8 bf e1 ff ff       	call   80027a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020c6:	00 
  8020c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 62 ea ff ff       	call   800b34 <memmove>
	}

	return r;
}
  8020d2:	89 d8                	mov    %ebx,%eax
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	53                   	push   %ebx
  8020df:	83 ec 14             	sub    $0x14,%esp
  8020e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020ed:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020f3:	7e 24                	jle    802119 <nsipc_send+0x3e>
  8020f5:	c7 44 24 0c 74 31 80 	movl   $0x803174,0xc(%esp)
  8020fc:	00 
  8020fd:	c7 44 24 08 1b 31 80 	movl   $0x80311b,0x8(%esp)
  802104:	00 
  802105:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80210c:	00 
  80210d:	c7 04 24 68 31 80 00 	movl   $0x803168,(%esp)
  802114:	e8 61 e1 ff ff       	call   80027a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802120:	89 44 24 04          	mov    %eax,0x4(%esp)
  802124:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80212b:	e8 04 ea ff ff       	call   800b34 <memmove>
	nsipcbuf.send.req_size = size;
  802130:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802136:	8b 45 14             	mov    0x14(%ebp),%eax
  802139:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80213e:	b8 08 00 00 00       	mov    $0x8,%eax
  802143:	e8 7b fd ff ff       	call   801ec3 <nsipc>
}
  802148:	83 c4 14             	add    $0x14,%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802154:	8b 45 08             	mov    0x8(%ebp),%eax
  802157:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80215c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802164:	8b 45 10             	mov    0x10(%ebp),%eax
  802167:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80216c:	b8 09 00 00 00       	mov    $0x9,%eax
  802171:	e8 4d fd ff ff       	call   801ec3 <nsipc>
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	83 ec 10             	sub    $0x10,%esp
  802180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802183:	8b 45 08             	mov    0x8(%ebp),%eax
  802186:	89 04 24             	mov    %eax,(%esp)
  802189:	e8 72 f2 ff ff       	call   801400 <fd2data>
  80218e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802190:	c7 44 24 04 80 31 80 	movl   $0x803180,0x4(%esp)
  802197:	00 
  802198:	89 1c 24             	mov    %ebx,(%esp)
  80219b:	e8 f7 e7 ff ff       	call   800997 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021a0:	8b 46 04             	mov    0x4(%esi),%eax
  8021a3:	2b 06                	sub    (%esi),%eax
  8021a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021b2:	00 00 00 
	stat->st_dev = &devpipe;
  8021b5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8021bc:	40 80 00 
	return 0;
}
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	53                   	push   %ebx
  8021cf:	83 ec 14             	sub    $0x14,%esp
  8021d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e0:	e8 75 ec ff ff       	call   800e5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021e5:	89 1c 24             	mov    %ebx,(%esp)
  8021e8:	e8 13 f2 ff ff       	call   801400 <fd2data>
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f8:	e8 5d ec ff ff       	call   800e5a <sys_page_unmap>
}
  8021fd:	83 c4 14             	add    $0x14,%esp
  802200:	5b                   	pop    %ebx
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	57                   	push   %edi
  802207:	56                   	push   %esi
  802208:	53                   	push   %ebx
  802209:	83 ec 2c             	sub    $0x2c,%esp
  80220c:	89 c6                	mov    %eax,%esi
  80220e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802211:	a1 20 54 80 00       	mov    0x805420,%eax
  802216:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802219:	89 34 24             	mov    %esi,(%esp)
  80221c:	e8 7c 06 00 00       	call   80289d <pageref>
  802221:	89 c7                	mov    %eax,%edi
  802223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802226:	89 04 24             	mov    %eax,(%esp)
  802229:	e8 6f 06 00 00       	call   80289d <pageref>
  80222e:	39 c7                	cmp    %eax,%edi
  802230:	0f 94 c2             	sete   %dl
  802233:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802236:	8b 0d 20 54 80 00    	mov    0x805420,%ecx
  80223c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80223f:	39 fb                	cmp    %edi,%ebx
  802241:	74 21                	je     802264 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802243:	84 d2                	test   %dl,%dl
  802245:	74 ca                	je     802211 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802247:	8b 51 58             	mov    0x58(%ecx),%edx
  80224a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802252:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802256:	c7 04 24 87 31 80 00 	movl   $0x803187,(%esp)
  80225d:	e8 11 e1 ff ff       	call   800373 <cprintf>
  802262:	eb ad                	jmp    802211 <_pipeisclosed+0xe>
	}
}
  802264:	83 c4 2c             	add    $0x2c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    

0080226c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	57                   	push   %edi
  802270:	56                   	push   %esi
  802271:	53                   	push   %ebx
  802272:	83 ec 1c             	sub    $0x1c,%esp
  802275:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802278:	89 34 24             	mov    %esi,(%esp)
  80227b:	e8 80 f1 ff ff       	call   801400 <fd2data>
  802280:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802282:	bf 00 00 00 00       	mov    $0x0,%edi
  802287:	eb 45                	jmp    8022ce <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802289:	89 da                	mov    %ebx,%edx
  80228b:	89 f0                	mov    %esi,%eax
  80228d:	e8 71 ff ff ff       	call   802203 <_pipeisclosed>
  802292:	85 c0                	test   %eax,%eax
  802294:	75 41                	jne    8022d7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802296:	e8 f9 ea ff ff       	call   800d94 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80229b:	8b 43 04             	mov    0x4(%ebx),%eax
  80229e:	8b 0b                	mov    (%ebx),%ecx
  8022a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8022a3:	39 d0                	cmp    %edx,%eax
  8022a5:	73 e2                	jae    802289 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022b1:	99                   	cltd   
  8022b2:	c1 ea 1b             	shr    $0x1b,%edx
  8022b5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8022b8:	83 e1 1f             	and    $0x1f,%ecx
  8022bb:	29 d1                	sub    %edx,%ecx
  8022bd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8022c1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8022c5:	83 c0 01             	add    $0x1,%eax
  8022c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022cb:	83 c7 01             	add    $0x1,%edi
  8022ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022d1:	75 c8                	jne    80229b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022d3:	89 f8                	mov    %edi,%eax
  8022d5:	eb 05                	jmp    8022dc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022d7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	57                   	push   %edi
  8022e8:	56                   	push   %esi
  8022e9:	53                   	push   %ebx
  8022ea:	83 ec 1c             	sub    $0x1c,%esp
  8022ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022f0:	89 3c 24             	mov    %edi,(%esp)
  8022f3:	e8 08 f1 ff ff       	call   801400 <fd2data>
  8022f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fa:	be 00 00 00 00       	mov    $0x0,%esi
  8022ff:	eb 3d                	jmp    80233e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802301:	85 f6                	test   %esi,%esi
  802303:	74 04                	je     802309 <devpipe_read+0x25>
				return i;
  802305:	89 f0                	mov    %esi,%eax
  802307:	eb 43                	jmp    80234c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802309:	89 da                	mov    %ebx,%edx
  80230b:	89 f8                	mov    %edi,%eax
  80230d:	e8 f1 fe ff ff       	call   802203 <_pipeisclosed>
  802312:	85 c0                	test   %eax,%eax
  802314:	75 31                	jne    802347 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802316:	e8 79 ea ff ff       	call   800d94 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80231b:	8b 03                	mov    (%ebx),%eax
  80231d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802320:	74 df                	je     802301 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802322:	99                   	cltd   
  802323:	c1 ea 1b             	shr    $0x1b,%edx
  802326:	01 d0                	add    %edx,%eax
  802328:	83 e0 1f             	and    $0x1f,%eax
  80232b:	29 d0                	sub    %edx,%eax
  80232d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802335:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802338:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233b:	83 c6 01             	add    $0x1,%esi
  80233e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802341:	75 d8                	jne    80231b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802343:	89 f0                	mov    %esi,%eax
  802345:	eb 05                	jmp    80234c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802347:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    

00802354 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	56                   	push   %esi
  802358:	53                   	push   %ebx
  802359:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80235c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235f:	89 04 24             	mov    %eax,(%esp)
  802362:	e8 b0 f0 ff ff       	call   801417 <fd_alloc>
  802367:	89 c2                	mov    %eax,%edx
  802369:	85 d2                	test   %edx,%edx
  80236b:	0f 88 4d 01 00 00    	js     8024be <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802371:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802378:	00 
  802379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802387:	e8 27 ea ff ff       	call   800db3 <sys_page_alloc>
  80238c:	89 c2                	mov    %eax,%edx
  80238e:	85 d2                	test   %edx,%edx
  802390:	0f 88 28 01 00 00    	js     8024be <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802399:	89 04 24             	mov    %eax,(%esp)
  80239c:	e8 76 f0 ff ff       	call   801417 <fd_alloc>
  8023a1:	89 c3                	mov    %eax,%ebx
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	0f 88 fe 00 00 00    	js     8024a9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023b2:	00 
  8023b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c1:	e8 ed e9 ff ff       	call   800db3 <sys_page_alloc>
  8023c6:	89 c3                	mov    %eax,%ebx
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	0f 88 d9 00 00 00    	js     8024a9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d3:	89 04 24             	mov    %eax,(%esp)
  8023d6:	e8 25 f0 ff ff       	call   801400 <fd2data>
  8023db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023e4:	00 
  8023e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f0:	e8 be e9 ff ff       	call   800db3 <sys_page_alloc>
  8023f5:	89 c3                	mov    %eax,%ebx
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	0f 88 97 00 00 00    	js     802496 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802402:	89 04 24             	mov    %eax,(%esp)
  802405:	e8 f6 ef ff ff       	call   801400 <fd2data>
  80240a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802411:	00 
  802412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802416:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80241d:	00 
  80241e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802429:	e8 d9 e9 ff ff       	call   800e07 <sys_page_map>
  80242e:	89 c3                	mov    %eax,%ebx
  802430:	85 c0                	test   %eax,%eax
  802432:	78 52                	js     802486 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802434:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80243a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802442:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802449:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80244f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802452:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802457:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80245e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802461:	89 04 24             	mov    %eax,(%esp)
  802464:	e8 87 ef ff ff       	call   8013f0 <fd2num>
  802469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80246c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80246e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802471:	89 04 24             	mov    %eax,(%esp)
  802474:	e8 77 ef ff ff       	call   8013f0 <fd2num>
  802479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80247c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80247f:	b8 00 00 00 00       	mov    $0x0,%eax
  802484:	eb 38                	jmp    8024be <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802491:	e8 c4 e9 ff ff       	call   800e5a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a4:	e8 b1 e9 ff ff       	call   800e5a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b7:	e8 9e e9 ff ff       	call   800e5a <sys_page_unmap>
  8024bc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8024be:	83 c4 30             	add    $0x30,%esp
  8024c1:	5b                   	pop    %ebx
  8024c2:	5e                   	pop    %esi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d5:	89 04 24             	mov    %eax,(%esp)
  8024d8:	e8 89 ef ff ff       	call   801466 <fd_lookup>
  8024dd:	89 c2                	mov    %eax,%edx
  8024df:	85 d2                	test   %edx,%edx
  8024e1:	78 15                	js     8024f8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e6:	89 04 24             	mov    %eax,(%esp)
  8024e9:	e8 12 ef ff ff       	call   801400 <fd2data>
	return _pipeisclosed(fd, p);
  8024ee:	89 c2                	mov    %eax,%edx
  8024f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f3:	e8 0b fd ff ff       	call   802203 <_pipeisclosed>
}
  8024f8:	c9                   	leave  
  8024f9:	c3                   	ret    

008024fa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024fa:	55                   	push   %ebp
  8024fb:	89 e5                	mov    %esp,%ebp
  8024fd:	56                   	push   %esi
  8024fe:	53                   	push   %ebx
  8024ff:	83 ec 10             	sub    $0x10,%esp
  802502:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802505:	85 f6                	test   %esi,%esi
  802507:	75 24                	jne    80252d <wait+0x33>
  802509:	c7 44 24 0c 9f 31 80 	movl   $0x80319f,0xc(%esp)
  802510:	00 
  802511:	c7 44 24 08 1b 31 80 	movl   $0x80311b,0x8(%esp)
  802518:	00 
  802519:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802520:	00 
  802521:	c7 04 24 aa 31 80 00 	movl   $0x8031aa,(%esp)
  802528:	e8 4d dd ff ff       	call   80027a <_panic>
	e = &envs[ENVX(envid)];
  80252d:	89 f3                	mov    %esi,%ebx
  80252f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802535:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802538:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80253e:	eb 05                	jmp    802545 <wait+0x4b>
		sys_yield();
  802540:	e8 4f e8 ff ff       	call   800d94 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802545:	8b 43 48             	mov    0x48(%ebx),%eax
  802548:	39 f0                	cmp    %esi,%eax
  80254a:	75 07                	jne    802553 <wait+0x59>
  80254c:	8b 43 54             	mov    0x54(%ebx),%eax
  80254f:	85 c0                	test   %eax,%eax
  802551:	75 ed                	jne    802540 <wait+0x46>
		sys_yield();
}
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	5b                   	pop    %ebx
  802557:	5e                   	pop    %esi
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802563:	b8 00 00 00 00       	mov    $0x0,%eax
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802570:	c7 44 24 04 b5 31 80 	movl   $0x8031b5,0x4(%esp)
  802577:	00 
  802578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257b:	89 04 24             	mov    %eax,(%esp)
  80257e:	e8 14 e4 ff ff       	call   800997 <strcpy>
	return 0;
}
  802583:	b8 00 00 00 00       	mov    $0x0,%eax
  802588:	c9                   	leave  
  802589:	c3                   	ret    

0080258a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80258a:	55                   	push   %ebp
  80258b:	89 e5                	mov    %esp,%ebp
  80258d:	57                   	push   %edi
  80258e:	56                   	push   %esi
  80258f:	53                   	push   %ebx
  802590:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802596:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80259b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025a1:	eb 31                	jmp    8025d4 <devcons_write+0x4a>
		m = n - tot;
  8025a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8025a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025b7:	03 45 0c             	add    0xc(%ebp),%eax
  8025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025be:	89 3c 24             	mov    %edi,(%esp)
  8025c1:	e8 6e e5 ff ff       	call   800b34 <memmove>
		sys_cputs(buf, m);
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	89 3c 24             	mov    %edi,(%esp)
  8025cd:	e8 14 e7 ff ff       	call   800ce6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025d2:	01 f3                	add    %esi,%ebx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025d9:	72 c8                	jb     8025a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025e1:	5b                   	pop    %ebx
  8025e2:	5e                   	pop    %esi
  8025e3:	5f                   	pop    %edi
  8025e4:	5d                   	pop    %ebp
  8025e5:	c3                   	ret    

008025e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025e6:	55                   	push   %ebp
  8025e7:	89 e5                	mov    %esp,%ebp
  8025e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8025ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8025f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025f5:	75 07                	jne    8025fe <devcons_read+0x18>
  8025f7:	eb 2a                	jmp    802623 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025f9:	e8 96 e7 ff ff       	call   800d94 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025fe:	66 90                	xchg   %ax,%ax
  802600:	e8 ff e6 ff ff       	call   800d04 <sys_cgetc>
  802605:	85 c0                	test   %eax,%eax
  802607:	74 f0                	je     8025f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802609:	85 c0                	test   %eax,%eax
  80260b:	78 16                	js     802623 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80260d:	83 f8 04             	cmp    $0x4,%eax
  802610:	74 0c                	je     80261e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802612:	8b 55 0c             	mov    0xc(%ebp),%edx
  802615:	88 02                	mov    %al,(%edx)
	return 1;
  802617:	b8 01 00 00 00       	mov    $0x1,%eax
  80261c:	eb 05                	jmp    802623 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80261e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802623:	c9                   	leave  
  802624:	c3                   	ret    

00802625 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802625:	55                   	push   %ebp
  802626:	89 e5                	mov    %esp,%ebp
  802628:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80262b:	8b 45 08             	mov    0x8(%ebp),%eax
  80262e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802631:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802638:	00 
  802639:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80263c:	89 04 24             	mov    %eax,(%esp)
  80263f:	e8 a2 e6 ff ff       	call   800ce6 <sys_cputs>
}
  802644:	c9                   	leave  
  802645:	c3                   	ret    

00802646 <getchar>:

int
getchar(void)
{
  802646:	55                   	push   %ebp
  802647:	89 e5                	mov    %esp,%ebp
  802649:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80264c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802653:	00 
  802654:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802662:	e8 93 f0 ff ff       	call   8016fa <read>
	if (r < 0)
  802667:	85 c0                	test   %eax,%eax
  802669:	78 0f                	js     80267a <getchar+0x34>
		return r;
	if (r < 1)
  80266b:	85 c0                	test   %eax,%eax
  80266d:	7e 06                	jle    802675 <getchar+0x2f>
		return -E_EOF;
	return c;
  80266f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802673:	eb 05                	jmp    80267a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802675:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80267a:	c9                   	leave  
  80267b:	c3                   	ret    

0080267c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802685:	89 44 24 04          	mov    %eax,0x4(%esp)
  802689:	8b 45 08             	mov    0x8(%ebp),%eax
  80268c:	89 04 24             	mov    %eax,(%esp)
  80268f:	e8 d2 ed ff ff       	call   801466 <fd_lookup>
  802694:	85 c0                	test   %eax,%eax
  802696:	78 11                	js     8026a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026a1:	39 10                	cmp    %edx,(%eax)
  8026a3:	0f 94 c0             	sete   %al
  8026a6:	0f b6 c0             	movzbl %al,%eax
}
  8026a9:	c9                   	leave  
  8026aa:	c3                   	ret    

008026ab <opencons>:

int
opencons(void)
{
  8026ab:	55                   	push   %ebp
  8026ac:	89 e5                	mov    %esp,%ebp
  8026ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026b4:	89 04 24             	mov    %eax,(%esp)
  8026b7:	e8 5b ed ff ff       	call   801417 <fd_alloc>
		return r;
  8026bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026be:	85 c0                	test   %eax,%eax
  8026c0:	78 40                	js     802702 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026c9:	00 
  8026ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d8:	e8 d6 e6 ff ff       	call   800db3 <sys_page_alloc>
		return r;
  8026dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026df:	85 c0                	test   %eax,%eax
  8026e1:	78 1f                	js     802702 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026e3:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026f8:	89 04 24             	mov    %eax,(%esp)
  8026fb:	e8 f0 ec ff ff       	call   8013f0 <fd2num>
  802700:	89 c2                	mov    %eax,%edx
}
  802702:	89 d0                	mov    %edx,%eax
  802704:	c9                   	leave  
  802705:	c3                   	ret    

00802706 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802706:	55                   	push   %ebp
  802707:	89 e5                	mov    %esp,%ebp
  802709:	53                   	push   %ebx
  80270a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80270d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802714:	75 2f                	jne    802745 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802716:	e8 5a e6 ff ff       	call   800d75 <sys_getenvid>
  80271b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80271d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802724:	00 
  802725:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80272c:	ee 
  80272d:	89 04 24             	mov    %eax,(%esp)
  802730:	e8 7e e6 ff ff       	call   800db3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802735:	c7 44 24 04 53 27 80 	movl   $0x802753,0x4(%esp)
  80273c:	00 
  80273d:	89 1c 24             	mov    %ebx,(%esp)
  802740:	e8 0e e8 ff ff       	call   800f53 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802745:	8b 45 08             	mov    0x8(%ebp),%eax
  802748:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80274d:	83 c4 14             	add    $0x14,%esp
  802750:	5b                   	pop    %ebx
  802751:	5d                   	pop    %ebp
  802752:	c3                   	ret    

00802753 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802753:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802754:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802759:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80275b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  80275e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802763:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802767:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80276b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80276d:	83 c4 08             	add    $0x8,%esp
	popal
  802770:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802771:	83 c4 04             	add    $0x4,%esp
	popfl
  802774:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802775:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802776:	c3                   	ret    
  802777:	66 90                	xchg   %ax,%ax
  802779:	66 90                	xchg   %ax,%ax
  80277b:	66 90                	xchg   %ax,%ax
  80277d:	66 90                	xchg   %ax,%ax
  80277f:	90                   	nop

00802780 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802780:	55                   	push   %ebp
  802781:	89 e5                	mov    %esp,%ebp
  802783:	56                   	push   %esi
  802784:	53                   	push   %ebx
  802785:	83 ec 10             	sub    $0x10,%esp
  802788:	8b 75 08             	mov    0x8(%ebp),%esi
  80278b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80278e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802791:	85 c0                	test   %eax,%eax
  802793:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802798:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80279b:	89 04 24             	mov    %eax,(%esp)
  80279e:	e8 26 e8 ff ff       	call   800fc9 <sys_ipc_recv>

	if(ret < 0) {
  8027a3:	85 c0                	test   %eax,%eax
  8027a5:	79 16                	jns    8027bd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8027a7:	85 f6                	test   %esi,%esi
  8027a9:	74 06                	je     8027b1 <ipc_recv+0x31>
  8027ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8027b1:	85 db                	test   %ebx,%ebx
  8027b3:	74 3e                	je     8027f3 <ipc_recv+0x73>
  8027b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8027bb:	eb 36                	jmp    8027f3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8027bd:	e8 b3 e5 ff ff       	call   800d75 <sys_getenvid>
  8027c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8027c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027cf:	a3 20 54 80 00       	mov    %eax,0x805420

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8027d4:	85 f6                	test   %esi,%esi
  8027d6:	74 05                	je     8027dd <ipc_recv+0x5d>
  8027d8:	8b 40 74             	mov    0x74(%eax),%eax
  8027db:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8027dd:	85 db                	test   %ebx,%ebx
  8027df:	74 0a                	je     8027eb <ipc_recv+0x6b>
  8027e1:	a1 20 54 80 00       	mov    0x805420,%eax
  8027e6:	8b 40 78             	mov    0x78(%eax),%eax
  8027e9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8027eb:	a1 20 54 80 00       	mov    0x805420,%eax
  8027f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027f3:	83 c4 10             	add    $0x10,%esp
  8027f6:	5b                   	pop    %ebx
  8027f7:	5e                   	pop    %esi
  8027f8:	5d                   	pop    %ebp
  8027f9:	c3                   	ret    

008027fa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027fa:	55                   	push   %ebp
  8027fb:	89 e5                	mov    %esp,%ebp
  8027fd:	57                   	push   %edi
  8027fe:	56                   	push   %esi
  8027ff:	53                   	push   %ebx
  802800:	83 ec 1c             	sub    $0x1c,%esp
  802803:	8b 7d 08             	mov    0x8(%ebp),%edi
  802806:	8b 75 0c             	mov    0xc(%ebp),%esi
  802809:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80280c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80280e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802813:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802816:	8b 45 14             	mov    0x14(%ebp),%eax
  802819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80281d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802821:	89 74 24 04          	mov    %esi,0x4(%esp)
  802825:	89 3c 24             	mov    %edi,(%esp)
  802828:	e8 79 e7 ff ff       	call   800fa6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80282d:	85 c0                	test   %eax,%eax
  80282f:	79 2c                	jns    80285d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802831:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802834:	74 20                	je     802856 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802836:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80283a:	c7 44 24 08 c4 31 80 	movl   $0x8031c4,0x8(%esp)
  802841:	00 
  802842:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802849:	00 
  80284a:	c7 04 24 f4 31 80 00 	movl   $0x8031f4,(%esp)
  802851:	e8 24 da ff ff       	call   80027a <_panic>
		}
		sys_yield();
  802856:	e8 39 e5 ff ff       	call   800d94 <sys_yield>
	}
  80285b:	eb b9                	jmp    802816 <ipc_send+0x1c>
}
  80285d:	83 c4 1c             	add    $0x1c,%esp
  802860:	5b                   	pop    %ebx
  802861:	5e                   	pop    %esi
  802862:	5f                   	pop    %edi
  802863:	5d                   	pop    %ebp
  802864:	c3                   	ret    

00802865 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802865:	55                   	push   %ebp
  802866:	89 e5                	mov    %esp,%ebp
  802868:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80286b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802870:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802873:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802879:	8b 52 50             	mov    0x50(%edx),%edx
  80287c:	39 ca                	cmp    %ecx,%edx
  80287e:	75 0d                	jne    80288d <ipc_find_env+0x28>
			return envs[i].env_id;
  802880:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802883:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802888:	8b 40 40             	mov    0x40(%eax),%eax
  80288b:	eb 0e                	jmp    80289b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80288d:	83 c0 01             	add    $0x1,%eax
  802890:	3d 00 04 00 00       	cmp    $0x400,%eax
  802895:	75 d9                	jne    802870 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802897:	66 b8 00 00          	mov    $0x0,%ax
}
  80289b:	5d                   	pop    %ebp
  80289c:	c3                   	ret    

0080289d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80289d:	55                   	push   %ebp
  80289e:	89 e5                	mov    %esp,%ebp
  8028a0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028a3:	89 d0                	mov    %edx,%eax
  8028a5:	c1 e8 16             	shr    $0x16,%eax
  8028a8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028af:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028b4:	f6 c1 01             	test   $0x1,%cl
  8028b7:	74 1d                	je     8028d6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028b9:	c1 ea 0c             	shr    $0xc,%edx
  8028bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028c3:	f6 c2 01             	test   $0x1,%dl
  8028c6:	74 0e                	je     8028d6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028c8:	c1 ea 0c             	shr    $0xc,%edx
  8028cb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028d2:	ef 
  8028d3:	0f b7 c0             	movzwl %ax,%eax
}
  8028d6:	5d                   	pop    %ebp
  8028d7:	c3                   	ret    
  8028d8:	66 90                	xchg   %ax,%ax
  8028da:	66 90                	xchg   %ax,%ax
  8028dc:	66 90                	xchg   %ax,%ax
  8028de:	66 90                	xchg   %ax,%ax

008028e0 <__udivdi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	83 ec 0c             	sub    $0xc,%esp
  8028e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8028ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8028ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8028f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8028f6:	85 c0                	test   %eax,%eax
  8028f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028fc:	89 ea                	mov    %ebp,%edx
  8028fe:	89 0c 24             	mov    %ecx,(%esp)
  802901:	75 2d                	jne    802930 <__udivdi3+0x50>
  802903:	39 e9                	cmp    %ebp,%ecx
  802905:	77 61                	ja     802968 <__udivdi3+0x88>
  802907:	85 c9                	test   %ecx,%ecx
  802909:	89 ce                	mov    %ecx,%esi
  80290b:	75 0b                	jne    802918 <__udivdi3+0x38>
  80290d:	b8 01 00 00 00       	mov    $0x1,%eax
  802912:	31 d2                	xor    %edx,%edx
  802914:	f7 f1                	div    %ecx
  802916:	89 c6                	mov    %eax,%esi
  802918:	31 d2                	xor    %edx,%edx
  80291a:	89 e8                	mov    %ebp,%eax
  80291c:	f7 f6                	div    %esi
  80291e:	89 c5                	mov    %eax,%ebp
  802920:	89 f8                	mov    %edi,%eax
  802922:	f7 f6                	div    %esi
  802924:	89 ea                	mov    %ebp,%edx
  802926:	83 c4 0c             	add    $0xc,%esp
  802929:	5e                   	pop    %esi
  80292a:	5f                   	pop    %edi
  80292b:	5d                   	pop    %ebp
  80292c:	c3                   	ret    
  80292d:	8d 76 00             	lea    0x0(%esi),%esi
  802930:	39 e8                	cmp    %ebp,%eax
  802932:	77 24                	ja     802958 <__udivdi3+0x78>
  802934:	0f bd e8             	bsr    %eax,%ebp
  802937:	83 f5 1f             	xor    $0x1f,%ebp
  80293a:	75 3c                	jne    802978 <__udivdi3+0x98>
  80293c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802940:	39 34 24             	cmp    %esi,(%esp)
  802943:	0f 86 9f 00 00 00    	jbe    8029e8 <__udivdi3+0x108>
  802949:	39 d0                	cmp    %edx,%eax
  80294b:	0f 82 97 00 00 00    	jb     8029e8 <__udivdi3+0x108>
  802951:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802958:	31 d2                	xor    %edx,%edx
  80295a:	31 c0                	xor    %eax,%eax
  80295c:	83 c4 0c             	add    $0xc,%esp
  80295f:	5e                   	pop    %esi
  802960:	5f                   	pop    %edi
  802961:	5d                   	pop    %ebp
  802962:	c3                   	ret    
  802963:	90                   	nop
  802964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802968:	89 f8                	mov    %edi,%eax
  80296a:	f7 f1                	div    %ecx
  80296c:	31 d2                	xor    %edx,%edx
  80296e:	83 c4 0c             	add    $0xc,%esp
  802971:	5e                   	pop    %esi
  802972:	5f                   	pop    %edi
  802973:	5d                   	pop    %ebp
  802974:	c3                   	ret    
  802975:	8d 76 00             	lea    0x0(%esi),%esi
  802978:	89 e9                	mov    %ebp,%ecx
  80297a:	8b 3c 24             	mov    (%esp),%edi
  80297d:	d3 e0                	shl    %cl,%eax
  80297f:	89 c6                	mov    %eax,%esi
  802981:	b8 20 00 00 00       	mov    $0x20,%eax
  802986:	29 e8                	sub    %ebp,%eax
  802988:	89 c1                	mov    %eax,%ecx
  80298a:	d3 ef                	shr    %cl,%edi
  80298c:	89 e9                	mov    %ebp,%ecx
  80298e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802992:	8b 3c 24             	mov    (%esp),%edi
  802995:	09 74 24 08          	or     %esi,0x8(%esp)
  802999:	89 d6                	mov    %edx,%esi
  80299b:	d3 e7                	shl    %cl,%edi
  80299d:	89 c1                	mov    %eax,%ecx
  80299f:	89 3c 24             	mov    %edi,(%esp)
  8029a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029a6:	d3 ee                	shr    %cl,%esi
  8029a8:	89 e9                	mov    %ebp,%ecx
  8029aa:	d3 e2                	shl    %cl,%edx
  8029ac:	89 c1                	mov    %eax,%ecx
  8029ae:	d3 ef                	shr    %cl,%edi
  8029b0:	09 d7                	or     %edx,%edi
  8029b2:	89 f2                	mov    %esi,%edx
  8029b4:	89 f8                	mov    %edi,%eax
  8029b6:	f7 74 24 08          	divl   0x8(%esp)
  8029ba:	89 d6                	mov    %edx,%esi
  8029bc:	89 c7                	mov    %eax,%edi
  8029be:	f7 24 24             	mull   (%esp)
  8029c1:	39 d6                	cmp    %edx,%esi
  8029c3:	89 14 24             	mov    %edx,(%esp)
  8029c6:	72 30                	jb     8029f8 <__udivdi3+0x118>
  8029c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029cc:	89 e9                	mov    %ebp,%ecx
  8029ce:	d3 e2                	shl    %cl,%edx
  8029d0:	39 c2                	cmp    %eax,%edx
  8029d2:	73 05                	jae    8029d9 <__udivdi3+0xf9>
  8029d4:	3b 34 24             	cmp    (%esp),%esi
  8029d7:	74 1f                	je     8029f8 <__udivdi3+0x118>
  8029d9:	89 f8                	mov    %edi,%eax
  8029db:	31 d2                	xor    %edx,%edx
  8029dd:	e9 7a ff ff ff       	jmp    80295c <__udivdi3+0x7c>
  8029e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029e8:	31 d2                	xor    %edx,%edx
  8029ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ef:	e9 68 ff ff ff       	jmp    80295c <__udivdi3+0x7c>
  8029f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8029fb:	31 d2                	xor    %edx,%edx
  8029fd:	83 c4 0c             	add    $0xc,%esp
  802a00:	5e                   	pop    %esi
  802a01:	5f                   	pop    %edi
  802a02:	5d                   	pop    %ebp
  802a03:	c3                   	ret    
  802a04:	66 90                	xchg   %ax,%ax
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__umoddi3>:
  802a10:	55                   	push   %ebp
  802a11:	57                   	push   %edi
  802a12:	56                   	push   %esi
  802a13:	83 ec 14             	sub    $0x14,%esp
  802a16:	8b 44 24 28          	mov    0x28(%esp),%eax
  802a1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802a1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802a22:	89 c7                	mov    %eax,%edi
  802a24:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a28:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802a30:	89 34 24             	mov    %esi,(%esp)
  802a33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a37:	85 c0                	test   %eax,%eax
  802a39:	89 c2                	mov    %eax,%edx
  802a3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a3f:	75 17                	jne    802a58 <__umoddi3+0x48>
  802a41:	39 fe                	cmp    %edi,%esi
  802a43:	76 4b                	jbe    802a90 <__umoddi3+0x80>
  802a45:	89 c8                	mov    %ecx,%eax
  802a47:	89 fa                	mov    %edi,%edx
  802a49:	f7 f6                	div    %esi
  802a4b:	89 d0                	mov    %edx,%eax
  802a4d:	31 d2                	xor    %edx,%edx
  802a4f:	83 c4 14             	add    $0x14,%esp
  802a52:	5e                   	pop    %esi
  802a53:	5f                   	pop    %edi
  802a54:	5d                   	pop    %ebp
  802a55:	c3                   	ret    
  802a56:	66 90                	xchg   %ax,%ax
  802a58:	39 f8                	cmp    %edi,%eax
  802a5a:	77 54                	ja     802ab0 <__umoddi3+0xa0>
  802a5c:	0f bd e8             	bsr    %eax,%ebp
  802a5f:	83 f5 1f             	xor    $0x1f,%ebp
  802a62:	75 5c                	jne    802ac0 <__umoddi3+0xb0>
  802a64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a68:	39 3c 24             	cmp    %edi,(%esp)
  802a6b:	0f 87 e7 00 00 00    	ja     802b58 <__umoddi3+0x148>
  802a71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a75:	29 f1                	sub    %esi,%ecx
  802a77:	19 c7                	sbb    %eax,%edi
  802a79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a81:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a89:	83 c4 14             	add    $0x14,%esp
  802a8c:	5e                   	pop    %esi
  802a8d:	5f                   	pop    %edi
  802a8e:	5d                   	pop    %ebp
  802a8f:	c3                   	ret    
  802a90:	85 f6                	test   %esi,%esi
  802a92:	89 f5                	mov    %esi,%ebp
  802a94:	75 0b                	jne    802aa1 <__umoddi3+0x91>
  802a96:	b8 01 00 00 00       	mov    $0x1,%eax
  802a9b:	31 d2                	xor    %edx,%edx
  802a9d:	f7 f6                	div    %esi
  802a9f:	89 c5                	mov    %eax,%ebp
  802aa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802aa5:	31 d2                	xor    %edx,%edx
  802aa7:	f7 f5                	div    %ebp
  802aa9:	89 c8                	mov    %ecx,%eax
  802aab:	f7 f5                	div    %ebp
  802aad:	eb 9c                	jmp    802a4b <__umoddi3+0x3b>
  802aaf:	90                   	nop
  802ab0:	89 c8                	mov    %ecx,%eax
  802ab2:	89 fa                	mov    %edi,%edx
  802ab4:	83 c4 14             	add    $0x14,%esp
  802ab7:	5e                   	pop    %esi
  802ab8:	5f                   	pop    %edi
  802ab9:	5d                   	pop    %ebp
  802aba:	c3                   	ret    
  802abb:	90                   	nop
  802abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	8b 04 24             	mov    (%esp),%eax
  802ac3:	be 20 00 00 00       	mov    $0x20,%esi
  802ac8:	89 e9                	mov    %ebp,%ecx
  802aca:	29 ee                	sub    %ebp,%esi
  802acc:	d3 e2                	shl    %cl,%edx
  802ace:	89 f1                	mov    %esi,%ecx
  802ad0:	d3 e8                	shr    %cl,%eax
  802ad2:	89 e9                	mov    %ebp,%ecx
  802ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ad8:	8b 04 24             	mov    (%esp),%eax
  802adb:	09 54 24 04          	or     %edx,0x4(%esp)
  802adf:	89 fa                	mov    %edi,%edx
  802ae1:	d3 e0                	shl    %cl,%eax
  802ae3:	89 f1                	mov    %esi,%ecx
  802ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ae9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802aed:	d3 ea                	shr    %cl,%edx
  802aef:	89 e9                	mov    %ebp,%ecx
  802af1:	d3 e7                	shl    %cl,%edi
  802af3:	89 f1                	mov    %esi,%ecx
  802af5:	d3 e8                	shr    %cl,%eax
  802af7:	89 e9                	mov    %ebp,%ecx
  802af9:	09 f8                	or     %edi,%eax
  802afb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802aff:	f7 74 24 04          	divl   0x4(%esp)
  802b03:	d3 e7                	shl    %cl,%edi
  802b05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b09:	89 d7                	mov    %edx,%edi
  802b0b:	f7 64 24 08          	mull   0x8(%esp)
  802b0f:	39 d7                	cmp    %edx,%edi
  802b11:	89 c1                	mov    %eax,%ecx
  802b13:	89 14 24             	mov    %edx,(%esp)
  802b16:	72 2c                	jb     802b44 <__umoddi3+0x134>
  802b18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802b1c:	72 22                	jb     802b40 <__umoddi3+0x130>
  802b1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b22:	29 c8                	sub    %ecx,%eax
  802b24:	19 d7                	sbb    %edx,%edi
  802b26:	89 e9                	mov    %ebp,%ecx
  802b28:	89 fa                	mov    %edi,%edx
  802b2a:	d3 e8                	shr    %cl,%eax
  802b2c:	89 f1                	mov    %esi,%ecx
  802b2e:	d3 e2                	shl    %cl,%edx
  802b30:	89 e9                	mov    %ebp,%ecx
  802b32:	d3 ef                	shr    %cl,%edi
  802b34:	09 d0                	or     %edx,%eax
  802b36:	89 fa                	mov    %edi,%edx
  802b38:	83 c4 14             	add    $0x14,%esp
  802b3b:	5e                   	pop    %esi
  802b3c:	5f                   	pop    %edi
  802b3d:	5d                   	pop    %ebp
  802b3e:	c3                   	ret    
  802b3f:	90                   	nop
  802b40:	39 d7                	cmp    %edx,%edi
  802b42:	75 da                	jne    802b1e <__umoddi3+0x10e>
  802b44:	8b 14 24             	mov    (%esp),%edx
  802b47:	89 c1                	mov    %eax,%ecx
  802b49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802b4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802b51:	eb cb                	jmp    802b1e <__umoddi3+0x10e>
  802b53:	90                   	nop
  802b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802b5c:	0f 82 0f ff ff ff    	jb     802a71 <__umoddi3+0x61>
  802b62:	e9 1a ff ff ff       	jmp    802a81 <__umoddi3+0x71>
