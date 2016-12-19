
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 86 01 00 00       	call   8001b7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  800039:	a1 00 40 80 00       	mov    0x804000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800049:	e8 e9 08 00 00       	call   800937 <strcpy>
	exit();
  80004e:	e8 ac 01 00 00       	call   8001ff <exit>
}
  800053:	c9                   	leave  
  800054:	c3                   	ret    

00800055 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800055:	55                   	push   %ebp
  800056:	89 e5                	mov    %esp,%ebp
  800058:	53                   	push   %ebx
  800059:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800060:	74 05                	je     800067 <umain+0x12>
		childofspawn();
  800062:	e8 cc ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800067:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800076:	a0 
  800077:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007e:	e8 d0 0c 00 00       	call   800d53 <sys_page_alloc>
  800083:	85 c0                	test   %eax,%eax
  800085:	79 20                	jns    8000a7 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  8000a2:	e8 71 01 00 00       	call   800218 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a7:	e8 d8 10 00 00       	call   801184 <fork>
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	79 20                	jns    8000d2 <umain+0x7d>
		panic("fork: %e", r);
  8000b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b6:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8000bd:	00 
  8000be:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c5:	00 
  8000c6:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  8000cd:	e8 46 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	75 1a                	jne    8000f0 <umain+0x9b>
		strcpy(VA, msg);
  8000d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e6:	e8 4c 08 00 00       	call   800937 <strcpy>
		exit();
  8000eb:	e8 0f 01 00 00       	call   8001ff <exit>
	}
	wait(r);
  8000f0:	89 1c 24             	mov    %ebx,(%esp)
  8000f3:	e8 f2 29 00 00       	call   802aea <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800108:	e8 df 08 00 00       	call   8009ec <strcmp>
  80010d:	85 c0                	test   %eax,%eax
  80010f:	b8 60 31 80 00       	mov    $0x803160,%eax
  800114:	ba 66 31 80 00       	mov    $0x803166,%edx
  800119:	0f 45 c2             	cmovne %edx,%eax
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800127:	e8 e5 01 00 00       	call   800311 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 b7 31 80 	movl   $0x8031b7,0x8(%esp)
  80013b:	00 
  80013c:	c7 44 24 04 bc 31 80 	movl   $0x8031bc,0x4(%esp)
  800143:	00 
  800144:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80014b:	e8 97 20 00 00       	call   8021e7 <spawnl>
  800150:	85 c0                	test   %eax,%eax
  800152:	79 20                	jns    800174 <umain+0x11f>
		panic("spawn: %e", r);
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	c7 44 24 08 c9 31 80 	movl   $0x8031c9,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800167:	00 
  800168:	c7 04 24 7f 31 80 00 	movl   $0x80317f,(%esp)
  80016f:	e8 a4 00 00 00       	call   800218 <_panic>
	wait(r);
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 6e 29 00 00       	call   802aea <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017c:	a1 00 40 80 00       	mov    0x804000,%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018c:	e8 5b 08 00 00       	call   8009ec <strcmp>
  800191:	85 c0                	test   %eax,%eax
  800193:	b8 60 31 80 00       	mov    $0x803160,%eax
  800198:	ba 66 31 80 00       	mov    $0x803166,%edx
  80019d:	0f 45 c2             	cmovne %edx,%eax
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 d3 31 80 00 	movl   $0x8031d3,(%esp)
  8001ab:	e8 61 01 00 00       	call   800311 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b0:	cc                   	int3   

	breakpoint();
}
  8001b1:	83 c4 14             	add    $0x14,%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 10             	sub    $0x10,%esp
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c5:	e8 4b 0b 00 00       	call   800d15 <sys_getenvid>
  8001ca:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d7:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7e 07                	jle    8001e7 <libmain+0x30>
		binaryname = argv[0];
  8001e0:	8b 06                	mov    (%esi),%eax
  8001e2:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001eb:	89 1c 24             	mov    %ebx,(%esp)
  8001ee:	e8 62 fe ff ff       	call   800055 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 07 00 00 00       	call   8001ff <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800205:	e8 60 13 00 00       	call   80156a <close_all>
	sys_env_destroy(0);
  80020a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800211:	e8 ad 0a 00 00       	call   800cc3 <sys_env_destroy>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800220:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800223:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800229:	e8 e7 0a 00 00       	call   800d15 <sys_getenvid>
  80022e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800231:	89 54 24 10          	mov    %edx,0x10(%esp)
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80023c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  80024b:	e8 c1 00 00 00       	call   800311 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800254:	8b 45 10             	mov    0x10(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 51 00 00 00       	call   8002b0 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 bf 37 80 00 	movl   $0x8037bf,(%esp)
  800266:	e8 a6 00 00 00       	call   800311 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026b:	cc                   	int3   
  80026c:	eb fd                	jmp    80026b <_panic+0x53>

0080026e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	53                   	push   %ebx
  800272:	83 ec 14             	sub    $0x14,%esp
  800275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800278:	8b 13                	mov    (%ebx),%edx
  80027a:	8d 42 01             	lea    0x1(%edx),%eax
  80027d:	89 03                	mov    %eax,(%ebx)
  80027f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800282:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800286:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028b:	75 19                	jne    8002a6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80028d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800294:	00 
  800295:	8d 43 08             	lea    0x8(%ebx),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 e6 09 00 00       	call   800c86 <sys_cputs>
		b->idx = 0;
  8002a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c0:	00 00 00 
	b.cnt = 0;
  8002c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	c7 04 24 6e 02 80 00 	movl   $0x80026e,(%esp)
  8002ec:	e8 ad 01 00 00       	call   80049e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	e8 7d 09 00 00       	call   800c86 <sys_cputs>

	return b.cnt;
}
  800309:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800317:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 87 ff ff ff       	call   8002b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    
  80032b:	66 90                	xchg   %ax,%ax
  80032d:	66 90                	xchg   %ax,%ax
  80032f:	90                   	nop

00800330 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	89 c3                	mov    %eax,%ebx
  800349:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80034c:	8b 45 10             	mov    0x10(%ebp),%eax
  80034f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035d:	39 d9                	cmp    %ebx,%ecx
  80035f:	72 05                	jb     800366 <printnum+0x36>
  800361:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800364:	77 69                	ja     8003cf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800366:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800369:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80036d:	83 ee 01             	sub    $0x1,%esi
  800370:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	8b 44 24 08          	mov    0x8(%esp),%eax
  80037c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800380:	89 c3                	mov    %eax,%ebx
  800382:	89 d6                	mov    %edx,%esi
  800384:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800387:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80038a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80038e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	e8 2c 2b 00 00       	call   802ed0 <__udivdi3>
  8003a4:	89 d9                	mov    %ebx,%ecx
  8003a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b5:	89 fa                	mov    %edi,%edx
  8003b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ba:	e8 71 ff ff ff       	call   800330 <printnum>
  8003bf:	eb 1b                	jmp    8003dc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff d3                	call   *%ebx
  8003cd:	eb 03                	jmp    8003d2 <printnum+0xa2>
  8003cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d2:	83 ee 01             	sub    $0x1,%esi
  8003d5:	85 f6                	test   %esi,%esi
  8003d7:	7f e8                	jg     8003c1 <printnum+0x91>
  8003d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 fc 2b 00 00       	call   803000 <__umoddi3>
  800404:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800408:	0f be 80 3b 32 80 00 	movsbl 0x80323b(%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800415:	ff d0                	call   *%eax
}
  800417:	83 c4 3c             	add    $0x3c,%esp
  80041a:	5b                   	pop    %ebx
  80041b:	5e                   	pop    %esi
  80041c:	5f                   	pop    %edi
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800422:	83 fa 01             	cmp    $0x1,%edx
  800425:	7e 0e                	jle    800435 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800427:	8b 10                	mov    (%eax),%edx
  800429:	8d 4a 08             	lea    0x8(%edx),%ecx
  80042c:	89 08                	mov    %ecx,(%eax)
  80042e:	8b 02                	mov    (%edx),%eax
  800430:	8b 52 04             	mov    0x4(%edx),%edx
  800433:	eb 22                	jmp    800457 <getuint+0x38>
	else if (lflag)
  800435:	85 d2                	test   %edx,%edx
  800437:	74 10                	je     800449 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043e:	89 08                	mov    %ecx,(%eax)
  800440:	8b 02                	mov    (%edx),%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	eb 0e                	jmp    800457 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    

00800459 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800463:	8b 10                	mov    (%eax),%edx
  800465:	3b 50 04             	cmp    0x4(%eax),%edx
  800468:	73 0a                	jae    800474 <sprintputch+0x1b>
		*b->buf++ = ch;
  80046a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	88 02                	mov    %al,(%edx)
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80047c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800483:	8b 45 10             	mov    0x10(%ebp),%eax
  800486:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 02 00 00 00       	call   80049e <vprintfmt>
	va_end(ap);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    

0080049e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	57                   	push   %edi
  8004a2:	56                   	push   %esi
  8004a3:	53                   	push   %ebx
  8004a4:	83 ec 3c             	sub    $0x3c,%esp
  8004a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004ad:	eb 14                	jmp    8004c3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	0f 84 b3 03 00 00    	je     80086a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c1:	89 f3                	mov    %esi,%ebx
  8004c3:	8d 73 01             	lea    0x1(%ebx),%esi
  8004c6:	0f b6 03             	movzbl (%ebx),%eax
  8004c9:	83 f8 25             	cmp    $0x25,%eax
  8004cc:	75 e1                	jne    8004af <vprintfmt+0x11>
  8004ce:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004e0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ec:	eb 1d                	jmp    80050b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004f4:	eb 15                	jmp    80050b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800501:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800504:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80050e:	0f b6 0e             	movzbl (%esi),%ecx
  800511:	0f b6 c1             	movzbl %cl,%eax
  800514:	83 e9 23             	sub    $0x23,%ecx
  800517:	80 f9 55             	cmp    $0x55,%cl
  80051a:	0f 87 2a 03 00 00    	ja     80084a <vprintfmt+0x3ac>
  800520:	0f b6 c9             	movzbl %cl,%ecx
  800523:	ff 24 8d 80 33 80 00 	jmp    *0x803380(,%ecx,4)
  80052a:	89 de                	mov    %ebx,%esi
  80052c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800531:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800534:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800538:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80053b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80053e:	83 fb 09             	cmp    $0x9,%ebx
  800541:	77 36                	ja     800579 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800543:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800546:	eb e9                	jmp    800531 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 48 04             	lea    0x4(%eax),%ecx
  80054e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800558:	eb 22                	jmp    80057c <vprintfmt+0xde>
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	b8 00 00 00 00       	mov    $0x0,%eax
  800564:	0f 49 c1             	cmovns %ecx,%eax
  800567:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	89 de                	mov    %ebx,%esi
  80056c:	eb 9d                	jmp    80050b <vprintfmt+0x6d>
  80056e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800570:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800577:	eb 92                	jmp    80050b <vprintfmt+0x6d>
  800579:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80057c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800580:	79 89                	jns    80050b <vprintfmt+0x6d>
  800582:	e9 77 ff ff ff       	jmp    8004fe <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800587:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80058c:	e9 7a ff ff ff       	jmp    80050b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005a6:	e9 18 ff ff ff       	jmp    8004c3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	99                   	cltd   
  8005b7:	31 d0                	xor    %edx,%eax
  8005b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bb:	83 f8 0f             	cmp    $0xf,%eax
  8005be:	7f 0b                	jg     8005cb <vprintfmt+0x12d>
  8005c0:	8b 14 85 e0 34 80 00 	mov    0x8034e0(,%eax,4),%edx
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	75 20                	jne    8005eb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cf:	c7 44 24 08 53 32 80 	movl   $0x803253,0x8(%esp)
  8005d6:	00 
  8005d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005db:	8b 45 08             	mov    0x8(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 90 fe ff ff       	call   800476 <printfmt>
  8005e6:	e9 d8 fe ff ff       	jmp    8004c3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ef:	c7 44 24 08 8d 36 80 	movl   $0x80368d,0x8(%esp)
  8005f6:	00 
  8005f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	e8 70 fe ff ff       	call   800476 <printfmt>
  800606:	e9 b8 fe ff ff       	jmp    8004c3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80060e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800611:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80061f:	85 f6                	test   %esi,%esi
  800621:	b8 4c 32 80 00       	mov    $0x80324c,%eax
  800626:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800629:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80062d:	0f 84 97 00 00 00    	je     8006ca <vprintfmt+0x22c>
  800633:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800637:	0f 8e 9b 00 00 00    	jle    8006d8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800641:	89 34 24             	mov    %esi,(%esp)
  800644:	e8 cf 02 00 00       	call   800918 <strnlen>
  800649:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064c:	29 c2                	sub    %eax,%edx
  80064e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800651:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800655:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800658:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800661:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	eb 0f                	jmp    800674 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800665:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800669:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 eb 01             	sub    $0x1,%ebx
  800674:	85 db                	test   %ebx,%ebx
  800676:	7f ed                	jg     800665 <vprintfmt+0x1c7>
  800678:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80067b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80067e:	85 d2                	test   %edx,%edx
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
  800685:	0f 49 c2             	cmovns %edx,%eax
  800688:	29 c2                	sub    %eax,%edx
  80068a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068d:	89 d7                	mov    %edx,%edi
  80068f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800692:	eb 50                	jmp    8006e4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800694:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800698:	74 1e                	je     8006b8 <vprintfmt+0x21a>
  80069a:	0f be d2             	movsbl %dl,%edx
  80069d:	83 ea 20             	sub    $0x20,%edx
  8006a0:	83 fa 5e             	cmp    $0x5e,%edx
  8006a3:	76 13                	jbe    8006b8 <vprintfmt+0x21a>
					putch('?', putdat);
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	eb 0d                	jmp    8006c5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c5:	83 ef 01             	sub    $0x1,%edi
  8006c8:	eb 1a                	jmp    8006e4 <vprintfmt+0x246>
  8006ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006d0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006d6:	eb 0c                	jmp    8006e4 <vprintfmt+0x246>
  8006d8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006db:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006de:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e4:	83 c6 01             	add    $0x1,%esi
  8006e7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006eb:	0f be c2             	movsbl %dl,%eax
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	74 27                	je     800719 <vprintfmt+0x27b>
  8006f2:	85 db                	test   %ebx,%ebx
  8006f4:	78 9e                	js     800694 <vprintfmt+0x1f6>
  8006f6:	83 eb 01             	sub    $0x1,%ebx
  8006f9:	79 99                	jns    800694 <vprintfmt+0x1f6>
  8006fb:	89 f8                	mov    %edi,%eax
  8006fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	89 c3                	mov    %eax,%ebx
  800705:	eb 1a                	jmp    800721 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800707:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800712:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 08                	jmp    800721 <vprintfmt+0x283>
  800719:	89 fb                	mov    %edi,%ebx
  80071b:	8b 75 08             	mov    0x8(%ebp),%esi
  80071e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800721:	85 db                	test   %ebx,%ebx
  800723:	7f e2                	jg     800707 <vprintfmt+0x269>
  800725:	89 75 08             	mov    %esi,0x8(%ebp)
  800728:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80072b:	e9 93 fd ff ff       	jmp    8004c3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800730:	83 fa 01             	cmp    $0x1,%edx
  800733:	7e 16                	jle    80074b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8d 50 08             	lea    0x8(%eax),%edx
  80073b:	89 55 14             	mov    %edx,0x14(%ebp)
  80073e:	8b 50 04             	mov    0x4(%eax),%edx
  800741:	8b 00                	mov    (%eax),%eax
  800743:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800746:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800749:	eb 32                	jmp    80077d <vprintfmt+0x2df>
	else if (lflag)
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 18                	je     800767 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 04             	lea    0x4(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
  800758:	8b 30                	mov    (%eax),%esi
  80075a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80075d:	89 f0                	mov    %esi,%eax
  80075f:	c1 f8 1f             	sar    $0x1f,%eax
  800762:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800765:	eb 16                	jmp    80077d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 04             	lea    0x4(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)
  800770:	8b 30                	mov    (%eax),%esi
  800772:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800775:	89 f0                	mov    %esi,%eax
  800777:	c1 f8 1f             	sar    $0x1f,%eax
  80077a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800780:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800783:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800788:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80078c:	0f 89 80 00 00 00    	jns    800812 <vprintfmt+0x374>
				putch('-', putdat);
  800792:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800796:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80079d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a6:	f7 d8                	neg    %eax
  8007a8:	83 d2 00             	adc    $0x0,%edx
  8007ab:	f7 da                	neg    %edx
			}
			base = 10;
  8007ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b2:	eb 5e                	jmp    800812 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b7:	e8 63 fc ff ff       	call   80041f <getuint>
			base = 10;
  8007bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007c1:	eb 4f                	jmp    800812 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 54 fc ff ff       	call   80041f <getuint>
			base = 8;
  8007cb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007d0:	eb 40                	jmp    800812 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f7:	8b 00                	mov    (%eax),%eax
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800803:	eb 0d                	jmp    800812 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 12 fc ff ff       	call   80041f <getuint>
			base = 16;
  80080d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800812:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800816:	89 74 24 10          	mov    %esi,0x10(%esp)
  80081a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80081d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800821:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800825:	89 04 24             	mov    %eax,(%esp)
  800828:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082c:	89 fa                	mov    %edi,%edx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	e8 fa fa ff ff       	call   800330 <printnum>
			break;
  800836:	e9 88 fc ff ff       	jmp    8004c3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	ff 55 08             	call   *0x8(%ebp)
			break;
  800845:	e9 79 fc ff ff       	jmp    8004c3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800855:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800858:	89 f3                	mov    %esi,%ebx
  80085a:	eb 03                	jmp    80085f <vprintfmt+0x3c1>
  80085c:	83 eb 01             	sub    $0x1,%ebx
  80085f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800863:	75 f7                	jne    80085c <vprintfmt+0x3be>
  800865:	e9 59 fc ff ff       	jmp    8004c3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80086a:	83 c4 3c             	add    $0x3c,%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 28             	sub    $0x28,%esp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800881:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800885:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 30                	je     8008c3 <vsnprintf+0x51>
  800893:	85 d2                	test   %edx,%edx
  800895:	7e 2c                	jle    8008c3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 59 04 80 00 	movl   $0x800459,(%esp)
  8008b3:	e8 e6 fb ff ff       	call   80049e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	eb 05                	jmp    8008c8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 82 ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
  8008f2:	66 90                	xchg   %ax,%ax
  8008f4:	66 90                	xchg   %ax,%ax
  8008f6:	66 90                	xchg   %ax,%ax
  8008f8:	66 90                	xchg   %ax,%ax
  8008fa:	66 90                	xchg   %ax,%ax
  8008fc:	66 90                	xchg   %ax,%ax
  8008fe:	66 90                	xchg   %ax,%ax

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	eb 03                	jmp    800910 <strlen+0x10>
		n++;
  80090d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800910:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800914:	75 f7                	jne    80090d <strlen+0xd>
		n++;
	return n;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb 03                	jmp    80092b <strnlen+0x13>
		n++;
  800928:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	39 d0                	cmp    %edx,%eax
  80092d:	74 06                	je     800935 <strnlen+0x1d>
  80092f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800933:	75 f3                	jne    800928 <strnlen+0x10>
		n++;
	return n;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800941:	89 c2                	mov    %eax,%edx
  800943:	83 c2 01             	add    $0x1,%edx
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80094d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800950:	84 db                	test   %bl,%bl
  800952:	75 ef                	jne    800943 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800961:	89 1c 24             	mov    %ebx,(%esp)
  800964:	e8 97 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800970:	01 d8                	add    %ebx,%eax
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	e8 bd ff ff ff       	call   800937 <strcpy>
	return dst;
}
  80097a:	89 d8                	mov    %ebx,%eax
  80097c:	83 c4 08             	add    $0x8,%esp
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	89 f2                	mov    %esi,%edx
  800994:	eb 0f                	jmp    8009a5 <strncpy+0x23>
		*dst++ = *src;
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	39 da                	cmp    %ebx,%edx
  8009a7:	75 ed                	jne    800996 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bd:	89 f0                	mov    %esi,%eax
  8009bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	75 0b                	jne    8009d2 <strlcpy+0x23>
  8009c7:	eb 1d                	jmp    8009e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d2:	39 d8                	cmp    %ebx,%eax
  8009d4:	74 0b                	je     8009e1 <strlcpy+0x32>
  8009d6:	0f b6 0a             	movzbl (%edx),%ecx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	75 ec                	jne    8009c9 <strlcpy+0x1a>
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	eb 02                	jmp    8009e3 <strlcpy+0x34>
  8009e1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e6:	29 f0                	sub    %esi,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f5:	eb 06                	jmp    8009fd <strcmp+0x11>
		p++, q++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	84 c0                	test   %al,%al
  800a02:	74 04                	je     800a08 <strcmp+0x1c>
  800a04:	3a 02                	cmp    (%edx),%al
  800a06:	74 ef                	je     8009f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 c0             	movzbl %al,%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 c3                	mov    %eax,%ebx
  800a1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a21:	eb 06                	jmp    800a29 <strncmp+0x17>
		n--, p++, q++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a29:	39 d8                	cmp    %ebx,%eax
  800a2b:	74 15                	je     800a42 <strncmp+0x30>
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	84 c9                	test   %cl,%cl
  800a32:	74 04                	je     800a38 <strncmp+0x26>
  800a34:	3a 0a                	cmp    (%edx),%cl
  800a36:	74 eb                	je     800a23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
  800a40:	eb 05                	jmp    800a47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 07                	jmp    800a5d <strchr+0x13>
		if (*s == c)
  800a56:	38 ca                	cmp    %cl,%dl
  800a58:	74 0f                	je     800a69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	eb 07                	jmp    800a7e <strfind+0x13>
		if (*s == c)
  800a77:	38 ca                	cmp    %cl,%dl
  800a79:	74 0a                	je     800a85 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	74 36                	je     800acd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9d:	75 28                	jne    800ac7 <memset+0x40>
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	75 23                	jne    800ac7 <memset+0x40>
		c &= 0xFF;
  800aa4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	c1 e3 08             	shl    $0x8,%ebx
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	c1 e6 18             	shl    $0x18,%esi
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 10             	shl    $0x10,%eax
  800ab7:	09 f0                	or     %esi,%eax
  800ab9:	09 c2                	or     %eax,%edx
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac2:	fc                   	cld    
  800ac3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac5:	eb 06                	jmp    800acd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 35                	jae    800b1b <memmove+0x47>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 d0                	cmp    %edx,%eax
  800aeb:	73 2e                	jae    800b1b <memmove+0x47>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afa:	75 13                	jne    800b0f <memmove+0x3b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0e                	jne    800b0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b01:	83 ef 04             	sub    $0x4,%edi
  800b04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0d:	eb 09                	jmp    800b18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0f:	83 ef 01             	sub    $0x1,%edi
  800b12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b15:	fd                   	std    
  800b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b18:	fc                   	cld    
  800b19:	eb 1d                	jmp    800b38 <memmove+0x64>
  800b1b:	89 f2                	mov    %esi,%edx
  800b1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f6 c2 03             	test   $0x3,%dl
  800b22:	75 0f                	jne    800b33 <memmove+0x5f>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0a                	jne    800b33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb 05                	jmp    800b38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	fc                   	cld    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 79 ff ff ff       	call   800ad4 <memmove>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6d:	eb 1a                	jmp    800b89 <memcmp+0x2c>
		if (*s1 != *s2)
  800b6f:	0f b6 02             	movzbl (%edx),%eax
  800b72:	0f b6 19             	movzbl (%ecx),%ebx
  800b75:	38 d8                	cmp    %bl,%al
  800b77:	74 0a                	je     800b83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 0f                	jmp    800b92 <memcmp+0x35>
		s1++, s2++;
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b89:	39 f2                	cmp    %esi,%edx
  800b8b:	75 e2                	jne    800b6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba4:	eb 07                	jmp    800bad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba6:	38 08                	cmp    %cl,(%eax)
  800ba8:	74 07                	je     800bb1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	39 d0                	cmp    %edx,%eax
  800baf:	72 f5                	jb     800ba6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbf:	eb 03                	jmp    800bc4 <strtol+0x11>
		s++;
  800bc1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc4:	0f b6 0a             	movzbl (%edx),%ecx
  800bc7:	80 f9 09             	cmp    $0x9,%cl
  800bca:	74 f5                	je     800bc1 <strtol+0xe>
  800bcc:	80 f9 20             	cmp    $0x20,%cl
  800bcf:	74 f0                	je     800bc1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd1:	80 f9 2b             	cmp    $0x2b,%cl
  800bd4:	75 0a                	jne    800be0 <strtol+0x2d>
		s++;
  800bd6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bde:	eb 11                	jmp    800bf1 <strtol+0x3e>
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be5:	80 f9 2d             	cmp    $0x2d,%cl
  800be8:	75 07                	jne    800bf1 <strtol+0x3e>
		s++, neg = 1;
  800bea:	8d 52 01             	lea    0x1(%edx),%edx
  800bed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bf6:	75 15                	jne    800c0d <strtol+0x5a>
  800bf8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfb:	75 10                	jne    800c0d <strtol+0x5a>
  800bfd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c01:	75 0a                	jne    800c0d <strtol+0x5a>
		s += 2, base = 16;
  800c03:	83 c2 02             	add    $0x2,%edx
  800c06:	b8 10 00 00 00       	mov    $0x10,%eax
  800c0b:	eb 10                	jmp    800c1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	75 0c                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c13:	80 3a 30             	cmpb   $0x30,(%edx)
  800c16:	75 05                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
  800c18:	83 c2 01             	add    $0x1,%edx
  800c1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c25:	0f b6 0a             	movzbl (%edx),%ecx
  800c28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c2b:	89 f0                	mov    %esi,%eax
  800c2d:	3c 09                	cmp    $0x9,%al
  800c2f:	77 08                	ja     800c39 <strtol+0x86>
			dig = *s - '0';
  800c31:	0f be c9             	movsbl %cl,%ecx
  800c34:	83 e9 30             	sub    $0x30,%ecx
  800c37:	eb 20                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c3c:	89 f0                	mov    %esi,%eax
  800c3e:	3c 19                	cmp    $0x19,%al
  800c40:	77 08                	ja     800c4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 57             	sub    $0x57,%ecx
  800c48:	eb 0f                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c4d:	89 f0                	mov    %esi,%eax
  800c4f:	3c 19                	cmp    $0x19,%al
  800c51:	77 16                	ja     800c69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c53:	0f be c9             	movsbl %cl,%ecx
  800c56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c5c:	7d 0f                	jge    800c6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c67:	eb bc                	jmp    800c25 <strtol+0x72>
  800c69:	89 d8                	mov    %ebx,%eax
  800c6b:	eb 02                	jmp    800c6f <strtol+0xbc>
  800c6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 05                	je     800c7a <strtol+0xc7>
		*endptr = (char *) s;
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c7a:	f7 d8                	neg    %eax
  800c7c:	85 ff                	test   %edi,%edi
  800c7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	89 c6                	mov    %eax,%esi
  800c9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 cb                	mov    %ecx,%ebx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	89 ce                	mov    %ecx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800d08:	e8 0b f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 02 00 00 00       	mov    $0x2,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_yield>:

void
sys_yield(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d44:	89 d1                	mov    %edx,%ecx
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	89 d7                	mov    %edx,%edi
  800d4a:	89 d6                	mov    %edx,%esi
  800d4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	b8 04 00 00 00       	mov    $0x4,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	89 f7                	mov    %esi,%edi
  800d71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800d9a:	e8 79 f4 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9f:	83 c4 2c             	add    $0x2c,%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b8 05 00 00 00       	mov    $0x5,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800ded:	e8 26 f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800e40:	e8 d3 f3 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800e93:	e8 80 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e98:	83 c4 2c             	add    $0x2c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 28                	jle    800eeb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800ee6:	e8 2d f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eeb:	83 c4 2c             	add    $0x2c,%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 df                	mov    %ebx,%edi
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 28                	jle    800f3e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800f39:	e8 da f2 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f3e:	83 c4 2c             	add    $0x2c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	be 00 00 00 00       	mov    $0x0,%esi
  800f51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 cb                	mov    %ecx,%ebx
  800f81:	89 cf                	mov    %ecx,%edi
  800f83:	89 ce                	mov    %ecx,%esi
  800f85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 28                	jle    800fb3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f96:	00 
  800f97:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  800fae:	e8 65 f2 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb3:	83 c4 2c             	add    $0x2c,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fcb:	89 d1                	mov    %edx,%ecx
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	89 d7                	mov    %edx,%edi
  800fd1:	89 d6                	mov    %edx,%esi
  800fd3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 df                	mov    %ebx,%edi
  800ff5:	89 de                	mov    %ebx,%esi
  800ff7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	7e 28                	jle    801025 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801001:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801008:	00 
  801009:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  801020:	e8 f3 f1 ff ff       	call   800218 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801025:	83 c4 2c             	add    $0x2c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
  801033:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	b8 10 00 00 00       	mov    $0x10,%eax
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 df                	mov    %ebx,%edi
  801048:	89 de                	mov    %ebx,%esi
  80104a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	7e 28                	jle    801078 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801050:	89 44 24 10          	mov    %eax,0x10(%esp)
  801054:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 3f 35 80 	movl   $0x80353f,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  801073:	e8 a0 f1 ff ff       	call   800218 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801078:	83 c4 2c             	add    $0x2c,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 20             	sub    $0x20,%esp
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80108b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80108d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801091:	75 20                	jne    8010b3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801093:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801097:	c7 44 24 08 6a 35 80 	movl   $0x80356a,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010a6:	00 
  8010a7:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  8010ae:	e8 65 f1 ff ff       	call   800218 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  8010b3:	89 f0                	mov    %esi,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
  8010b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bf:	f6 c4 08             	test   $0x8,%ah
  8010c2:	75 1c                	jne    8010e0 <pgfault+0x60>
		panic("Not a COW page");
  8010c4:	c7 44 24 08 86 35 80 	movl   $0x803586,0x8(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8010d3:	00 
  8010d4:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  8010db:	e8 38 f1 ff ff       	call   800218 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  8010e0:	e8 30 fc ff ff       	call   800d15 <sys_getenvid>
  8010e5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  8010e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010f6:	00 
  8010f7:	89 04 24             	mov    %eax,(%esp)
  8010fa:	e8 54 fc ff ff       	call   800d53 <sys_page_alloc>
	if(r < 0) {
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 1c                	jns    80111f <pgfault+0x9f>
		panic("couldn't allocate page");
  801103:	c7 44 24 08 95 35 80 	movl   $0x803595,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801112:	00 
  801113:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  80111a:	e8 f9 f0 ff ff       	call   800218 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80111f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801125:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80112c:	00 
  80112d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801131:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801138:	e8 97 f9 ff ff       	call   800ad4 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80113d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801144:	00 
  801145:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80114d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801154:	00 
  801155:	89 1c 24             	mov    %ebx,(%esp)
  801158:	e8 4a fc ff ff       	call   800da7 <sys_page_map>
	if(r < 0) {
  80115d:	85 c0                	test   %eax,%eax
  80115f:	79 1c                	jns    80117d <pgfault+0xfd>
		panic("couldn't map page");
  801161:	c7 44 24 08 ac 35 80 	movl   $0x8035ac,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  801178:	e8 9b f0 ff ff       	call   800218 <_panic>
	}
}
  80117d:	83 c4 20             	add    $0x20,%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80118d:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  801194:	e8 5d 1b 00 00       	call   802cf6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801199:	b8 07 00 00 00       	mov    $0x7,%eax
  80119e:	cd 30                	int    $0x30
  8011a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8011a3:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  8011a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	75 21                	jne    8011d7 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011b6:	e8 5a fb ff ff       	call   800d15 <sys_getenvid>
  8011bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c8:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	e9 8d 01 00 00       	jmp    801364 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  8011d7:	89 f8                	mov    %edi,%eax
  8011d9:	c1 e8 16             	shr    $0x16,%eax
  8011dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	0f 84 02 01 00 00    	je     8012ed <fork+0x169>
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	c1 ea 0c             	shr    $0xc,%edx
  8011f0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	0f 84 ee 00 00 00    	je     8012ed <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  8011ff:	89 d6                	mov    %edx,%esi
  801201:	c1 e6 0c             	shl    $0xc,%esi
  801204:	89 f0                	mov    %esi,%eax
  801206:	c1 e8 16             	shr    $0x16,%eax
  801209:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	f6 c1 01             	test   $0x1,%cl
  801218:	0f 84 cc 00 00 00    	je     8012ea <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80121e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801225:	89 d8                	mov    %ebx,%eax
  801227:	25 07 0e 00 00       	and    $0xe07,%eax
  80122c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80122f:	89 d8                	mov    %ebx,%eax
  801231:	83 e0 01             	and    $0x1,%eax
  801234:	0f 84 b0 00 00 00    	je     8012ea <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80123a:	e8 d6 fa ff ff       	call   800d15 <sys_getenvid>
  80123f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801242:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801249:	74 28                	je     801273 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80124b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124e:	25 07 0e 00 00       	and    $0xe07,%eax
  801253:	89 44 24 10          	mov    %eax,0x10(%esp)
  801257:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80125b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80125e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801262:	89 74 24 04          	mov    %esi,0x4(%esp)
  801266:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 36 fb ff ff       	call   800da7 <sys_page_map>
  801271:	eb 77                	jmp    8012ea <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801273:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801279:	74 4e                	je     8012c9 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80127b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801283:	80 cc 08             	or     $0x8,%ah
  801286:	89 c3                	mov    %eax,%ebx
  801288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801290:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801293:	89 44 24 08          	mov    %eax,0x8(%esp)
  801297:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 01 fb ff ff       	call   800da7 <sys_page_map>
  8012a6:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8012a9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012bc:	89 0c 24             	mov    %ecx,(%esp)
  8012bf:	e8 e3 fa ff ff       	call   800da7 <sys_page_map>
  8012c4:	03 45 e0             	add    -0x20(%ebp),%eax
  8012c7:	eb 21                	jmp    8012ea <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  8012c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e2:	89 04 24             	mov    %eax,(%esp)
  8012e5:	e8 bd fa ff ff       	call   800da7 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  8012ea:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  8012ed:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012f3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  8012f9:	0f 85 d8 fe ff ff    	jne    8011d7 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  8012ff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80130e:	ee 
  80130f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801312:	89 34 24             	mov    %esi,(%esp)
  801315:	e8 39 fa ff ff       	call   800d53 <sys_page_alloc>
  80131a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80131d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80131f:	c7 44 24 04 43 2d 80 	movl   $0x802d43,0x4(%esp)
  801326:	00 
  801327:	89 34 24             	mov    %esi,(%esp)
  80132a:	e8 c4 fb ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
  80132f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801331:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801338:	00 
  801339:	89 34 24             	mov    %esi,(%esp)
  80133c:	e8 0c fb ff ff       	call   800e4d <sys_env_set_status>

	if(r<0) {
  801341:	01 d8                	add    %ebx,%eax
  801343:	79 1c                	jns    801361 <fork+0x1dd>
	 panic("fork failed!");
  801345:	c7 44 24 08 be 35 80 	movl   $0x8035be,0x8(%esp)
  80134c:	00 
  80134d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801354:	00 
  801355:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  80135c:	e8 b7 ee ff ff       	call   800218 <_panic>
	}

	return envid;
  801361:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801364:	83 c4 3c             	add    $0x3c,%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <sfork>:

// Challenge!
int
sfork(void)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801372:	c7 44 24 08 cb 35 80 	movl   $0x8035cb,0x8(%esp)
  801379:	00 
  80137a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801381:	00 
  801382:	c7 04 24 7b 35 80 00 	movl   $0x80357b,(%esp)
  801389:	e8 8a ee ff ff       	call   800218 <_panic>
  80138e:	66 90                	xchg   %ax,%ax

00801390 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	05 00 00 00 30       	add    $0x30000000,%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
}
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 16             	shr    $0x16,%edx
  8013c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 11                	je     8013e4 <fd_alloc+0x2d>
  8013d3:	89 c2                	mov    %eax,%edx
  8013d5:	c1 ea 0c             	shr    $0xc,%edx
  8013d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	75 09                	jne    8013ed <fd_alloc+0x36>
			*fd_store = fd;
  8013e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013eb:	eb 17                	jmp    801404 <fd_alloc+0x4d>
  8013ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f7:	75 c9                	jne    8013c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80140c:	83 f8 1f             	cmp    $0x1f,%eax
  80140f:	77 36                	ja     801447 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801411:	c1 e0 0c             	shl    $0xc,%eax
  801414:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 16             	shr    $0x16,%edx
  80141e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801425:	f6 c2 01             	test   $0x1,%dl
  801428:	74 24                	je     80144e <fd_lookup+0x48>
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	c1 ea 0c             	shr    $0xc,%edx
  80142f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	74 1a                	je     801455 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80143b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143e:	89 02                	mov    %eax,(%edx)
	return 0;
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
  801445:	eb 13                	jmp    80145a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144c:	eb 0c                	jmp    80145a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80144e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801453:	eb 05                	jmp    80145a <fd_lookup+0x54>
  801455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 18             	sub    $0x18,%esp
  801462:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	eb 13                	jmp    80147f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80146c:	39 08                	cmp    %ecx,(%eax)
  80146e:	75 0c                	jne    80147c <dev_lookup+0x20>
			*dev = devtab[i];
  801470:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801473:	89 01                	mov    %eax,(%ecx)
			return 0;
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	eb 38                	jmp    8014b4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80147c:	83 c2 01             	add    $0x1,%edx
  80147f:	8b 04 95 60 36 80 00 	mov    0x803660(,%edx,4),%eax
  801486:	85 c0                	test   %eax,%eax
  801488:	75 e2                	jne    80146c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80148a:	a1 08 50 80 00       	mov    0x805008,%eax
  80148f:	8b 40 48             	mov    0x48(%eax),%eax
  801492:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149a:	c7 04 24 e4 35 80 00 	movl   $0x8035e4,(%esp)
  8014a1:	e8 6b ee ff ff       	call   800311 <cprintf>
	*dev = 0;
  8014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 20             	sub    $0x20,%esp
  8014be:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014d1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d4:	89 04 24             	mov    %eax,(%esp)
  8014d7:	e8 2a ff ff ff       	call   801406 <fd_lookup>
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 05                	js     8014e5 <fd_close+0x2f>
	    || fd != fd2)
  8014e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014e3:	74 0c                	je     8014f1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014e5:	84 db                	test   %bl,%bl
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	0f 44 c2             	cmove  %edx,%eax
  8014ef:	eb 3f                	jmp    801530 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	8b 06                	mov    (%esi),%eax
  8014fa:	89 04 24             	mov    %eax,(%esp)
  8014fd:	e8 5a ff ff ff       	call   80145c <dev_lookup>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	85 c0                	test   %eax,%eax
  801506:	78 16                	js     80151e <fd_close+0x68>
		if (dev->dev_close)
  801508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80150e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801513:	85 c0                	test   %eax,%eax
  801515:	74 07                	je     80151e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801517:	89 34 24             	mov    %esi,(%esp)
  80151a:	ff d0                	call   *%eax
  80151c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80151e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801529:	e8 cc f8 ff ff       	call   800dfa <sys_page_unmap>
	return r;
  80152e:	89 d8                	mov    %ebx,%eax
}
  801530:	83 c4 20             	add    $0x20,%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	89 44 24 04          	mov    %eax,0x4(%esp)
  801544:	8b 45 08             	mov    0x8(%ebp),%eax
  801547:	89 04 24             	mov    %eax,(%esp)
  80154a:	e8 b7 fe ff ff       	call   801406 <fd_lookup>
  80154f:	89 c2                	mov    %eax,%edx
  801551:	85 d2                	test   %edx,%edx
  801553:	78 13                	js     801568 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801555:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80155c:	00 
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	89 04 24             	mov    %eax,(%esp)
  801563:	e8 4e ff ff ff       	call   8014b6 <fd_close>
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <close_all>:

void
close_all(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801571:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801576:	89 1c 24             	mov    %ebx,(%esp)
  801579:	e8 b9 ff ff ff       	call   801537 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80157e:	83 c3 01             	add    $0x1,%ebx
  801581:	83 fb 20             	cmp    $0x20,%ebx
  801584:	75 f0                	jne    801576 <close_all+0xc>
		close(i);
}
  801586:	83 c4 14             	add    $0x14,%esp
  801589:	5b                   	pop    %ebx
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	57                   	push   %edi
  801590:	56                   	push   %esi
  801591:	53                   	push   %ebx
  801592:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801595:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159c:	8b 45 08             	mov    0x8(%ebp),%eax
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 5f fe ff ff       	call   801406 <fd_lookup>
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	85 d2                	test   %edx,%edx
  8015ab:	0f 88 e1 00 00 00    	js     801692 <dup+0x106>
		return r;
	close(newfdnum);
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	89 04 24             	mov    %eax,(%esp)
  8015b7:	e8 7b ff ff ff       	call   801537 <close>

	newfd = INDEX2FD(newfdnum);
  8015bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015bf:	c1 e3 0c             	shl    $0xc,%ebx
  8015c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 cd fd ff ff       	call   8013a0 <fd2data>
  8015d3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015d5:	89 1c 24             	mov    %ebx,(%esp)
  8015d8:	e8 c3 fd ff ff       	call   8013a0 <fd2data>
  8015dd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015df:	89 f0                	mov    %esi,%eax
  8015e1:	c1 e8 16             	shr    $0x16,%eax
  8015e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015eb:	a8 01                	test   $0x1,%al
  8015ed:	74 43                	je     801632 <dup+0xa6>
  8015ef:	89 f0                	mov    %esi,%eax
  8015f1:	c1 e8 0c             	shr    $0xc,%eax
  8015f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015fb:	f6 c2 01             	test   $0x1,%dl
  8015fe:	74 32                	je     801632 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801600:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801607:	25 07 0e 00 00       	and    $0xe07,%eax
  80160c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801610:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801614:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80161b:	00 
  80161c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801627:	e8 7b f7 ff ff       	call   800da7 <sys_page_map>
  80162c:	89 c6                	mov    %eax,%esi
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 3e                	js     801670 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801635:	89 c2                	mov    %eax,%edx
  801637:	c1 ea 0c             	shr    $0xc,%edx
  80163a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801641:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801647:	89 54 24 10          	mov    %edx,0x10(%esp)
  80164b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80164f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801656:	00 
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801662:	e8 40 f7 ff ff       	call   800da7 <sys_page_map>
  801667:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801669:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166c:	85 f6                	test   %esi,%esi
  80166e:	79 22                	jns    801692 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167b:	e8 7a f7 ff ff       	call   800dfa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801680:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168b:	e8 6a f7 ff ff       	call   800dfa <sys_page_unmap>
	return r;
  801690:	89 f0                	mov    %esi,%eax
}
  801692:	83 c4 3c             	add    $0x3c,%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 24             	sub    $0x24,%esp
  8016a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	89 1c 24             	mov    %ebx,(%esp)
  8016ae:	e8 53 fd ff ff       	call   801406 <fd_lookup>
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	85 d2                	test   %edx,%edx
  8016b7:	78 6d                	js     801726 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	8b 00                	mov    (%eax),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 8f fd ff ff       	call   80145c <dev_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 55                	js     801726 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	8b 50 08             	mov    0x8(%eax),%edx
  8016d7:	83 e2 03             	and    $0x3,%edx
  8016da:	83 fa 01             	cmp    $0x1,%edx
  8016dd:	75 23                	jne    801702 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016df:	a1 08 50 80 00       	mov    0x805008,%eax
  8016e4:	8b 40 48             	mov    0x48(%eax),%eax
  8016e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ef:	c7 04 24 25 36 80 00 	movl   $0x803625,(%esp)
  8016f6:	e8 16 ec ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  8016fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801700:	eb 24                	jmp    801726 <read+0x8c>
	}
	if (!dev->dev_read)
  801702:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801705:	8b 52 08             	mov    0x8(%edx),%edx
  801708:	85 d2                	test   %edx,%edx
  80170a:	74 15                	je     801721 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80170c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80170f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801716:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	ff d2                	call   *%edx
  80171f:	eb 05                	jmp    801726 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801726:	83 c4 24             	add    $0x24,%esp
  801729:	5b                   	pop    %ebx
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	57                   	push   %edi
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	83 ec 1c             	sub    $0x1c,%esp
  801735:	8b 7d 08             	mov    0x8(%ebp),%edi
  801738:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80173b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801740:	eb 23                	jmp    801765 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801742:	89 f0                	mov    %esi,%eax
  801744:	29 d8                	sub    %ebx,%eax
  801746:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174a:	89 d8                	mov    %ebx,%eax
  80174c:	03 45 0c             	add    0xc(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	89 3c 24             	mov    %edi,(%esp)
  801756:	e8 3f ff ff ff       	call   80169a <read>
		if (m < 0)
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 10                	js     80176f <readn+0x43>
			return m;
		if (m == 0)
  80175f:	85 c0                	test   %eax,%eax
  801761:	74 0a                	je     80176d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801763:	01 c3                	add    %eax,%ebx
  801765:	39 f3                	cmp    %esi,%ebx
  801767:	72 d9                	jb     801742 <readn+0x16>
  801769:	89 d8                	mov    %ebx,%eax
  80176b:	eb 02                	jmp    80176f <readn+0x43>
  80176d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80176f:	83 c4 1c             	add    $0x1c,%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5f                   	pop    %edi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	53                   	push   %ebx
  80177b:	83 ec 24             	sub    $0x24,%esp
  80177e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801781:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801784:	89 44 24 04          	mov    %eax,0x4(%esp)
  801788:	89 1c 24             	mov    %ebx,(%esp)
  80178b:	e8 76 fc ff ff       	call   801406 <fd_lookup>
  801790:	89 c2                	mov    %eax,%edx
  801792:	85 d2                	test   %edx,%edx
  801794:	78 68                	js     8017fe <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801796:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	8b 00                	mov    (%eax),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 b2 fc ff ff       	call   80145c <dev_lookup>
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 50                	js     8017fe <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b5:	75 23                	jne    8017da <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b7:	a1 08 50 80 00       	mov    0x805008,%eax
  8017bc:	8b 40 48             	mov    0x48(%eax),%eax
  8017bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	c7 04 24 41 36 80 00 	movl   $0x803641,(%esp)
  8017ce:	e8 3e eb ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  8017d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d8:	eb 24                	jmp    8017fe <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e0:	85 d2                	test   %edx,%edx
  8017e2:	74 15                	je     8017f9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	ff d2                	call   *%edx
  8017f7:	eb 05                	jmp    8017fe <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017fe:	83 c4 24             	add    $0x24,%esp
  801801:	5b                   	pop    %ebx
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <seek>:

int
seek(int fdnum, off_t offset)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80180a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	89 04 24             	mov    %eax,(%esp)
  801817:	e8 ea fb ff ff       	call   801406 <fd_lookup>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 0e                	js     80182e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801820:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801823:	8b 55 0c             	mov    0xc(%ebp),%edx
  801826:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801829:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	53                   	push   %ebx
  801834:	83 ec 24             	sub    $0x24,%esp
  801837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	89 1c 24             	mov    %ebx,(%esp)
  801844:	e8 bd fb ff ff       	call   801406 <fd_lookup>
  801849:	89 c2                	mov    %eax,%edx
  80184b:	85 d2                	test   %edx,%edx
  80184d:	78 61                	js     8018b0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801852:	89 44 24 04          	mov    %eax,0x4(%esp)
  801856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801859:	8b 00                	mov    (%eax),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 f9 fb ff ff       	call   80145c <dev_lookup>
  801863:	85 c0                	test   %eax,%eax
  801865:	78 49                	js     8018b0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186e:	75 23                	jne    801893 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801870:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801875:	8b 40 48             	mov    0x48(%eax),%eax
  801878:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801880:	c7 04 24 04 36 80 00 	movl   $0x803604,(%esp)
  801887:	e8 85 ea ff ff       	call   800311 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80188c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801891:	eb 1d                	jmp    8018b0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801893:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801896:	8b 52 18             	mov    0x18(%edx),%edx
  801899:	85 d2                	test   %edx,%edx
  80189b:	74 0e                	je     8018ab <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80189d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018a4:	89 04 24             	mov    %eax,(%esp)
  8018a7:	ff d2                	call   *%edx
  8018a9:	eb 05                	jmp    8018b0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018b0:	83 c4 24             	add    $0x24,%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 24             	sub    $0x24,%esp
  8018bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	89 04 24             	mov    %eax,(%esp)
  8018cd:	e8 34 fb ff ff       	call   801406 <fd_lookup>
  8018d2:	89 c2                	mov    %eax,%edx
  8018d4:	85 d2                	test   %edx,%edx
  8018d6:	78 52                	js     80192a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	8b 00                	mov    (%eax),%eax
  8018e4:	89 04 24             	mov    %eax,(%esp)
  8018e7:	e8 70 fb ff ff       	call   80145c <dev_lookup>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 3a                	js     80192a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f7:	74 2c                	je     801925 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801903:	00 00 00 
	stat->st_isdir = 0;
  801906:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190d:	00 00 00 
	stat->st_dev = dev;
  801910:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801916:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80191d:	89 14 24             	mov    %edx,(%esp)
  801920:	ff 50 14             	call   *0x14(%eax)
  801923:	eb 05                	jmp    80192a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801925:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80192a:	83 c4 24             	add    $0x24,%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801938:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80193f:	00 
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 28 02 00 00       	call   801b73 <open>
  80194b:	89 c3                	mov    %eax,%ebx
  80194d:	85 db                	test   %ebx,%ebx
  80194f:	78 1b                	js     80196c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801951:	8b 45 0c             	mov    0xc(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 56 ff ff ff       	call   8018b6 <fstat>
  801960:	89 c6                	mov    %eax,%esi
	close(fd);
  801962:	89 1c 24             	mov    %ebx,(%esp)
  801965:	e8 cd fb ff ff       	call   801537 <close>
	return r;
  80196a:	89 f0                	mov    %esi,%eax
}
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	5b                   	pop    %ebx
  801970:	5e                   	pop    %esi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 10             	sub    $0x10,%esp
  80197b:	89 c6                	mov    %eax,%esi
  80197d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80197f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801986:	75 11                	jne    801999 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801988:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80198f:	e8 c1 14 00 00       	call   802e55 <ipc_find_env>
  801994:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801999:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019a0:	00 
  8019a1:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019a8:	00 
  8019a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ad:	a1 00 50 80 00       	mov    0x805000,%eax
  8019b2:	89 04 24             	mov    %eax,(%esp)
  8019b5:	e8 30 14 00 00       	call   802dea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019c1:	00 
  8019c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cd:	e8 9e 13 00 00       	call   802d70 <ipc_recv>
}
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	5b                   	pop    %ebx
  8019d6:	5e                   	pop    %esi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019fc:	e8 72 ff ff ff       	call   801973 <fsipc>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1e:	e8 50 ff ff ff       	call   801973 <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	53                   	push   %ebx
  801a29:	83 ec 14             	sub    $0x14,%esp
  801a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	8b 40 0c             	mov    0xc(%eax),%eax
  801a35:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a44:	e8 2a ff ff ff       	call   801973 <fsipc>
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	85 d2                	test   %edx,%edx
  801a4d:	78 2b                	js     801a7a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a4f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a56:	00 
  801a57:	89 1c 24             	mov    %ebx,(%esp)
  801a5a:	e8 d8 ee ff ff       	call   800937 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5f:	a1 80 60 80 00       	mov    0x806080,%eax
  801a64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a6a:	a1 84 60 80 00       	mov    0x806084,%eax
  801a6f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a7a:	83 c4 14             	add    $0x14,%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 18             	sub    $0x18,%esp
  801a86:	8b 45 10             	mov    0x10(%ebp),%eax
  801a89:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a8e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a93:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a96:	8b 55 08             	mov    0x8(%ebp),%edx
  801a99:	8b 52 0c             	mov    0xc(%edx),%edx
  801a9c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801aa2:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801ab9:	e8 16 f0 ff ff       	call   800ad4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801abe:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ac8:	e8 a6 fe ff ff       	call   801973 <fsipc>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 10             	sub    $0x10,%esp
  801ad7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ae5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801af0:	b8 03 00 00 00       	mov    $0x3,%eax
  801af5:	e8 79 fe ff ff       	call   801973 <fsipc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 6a                	js     801b6a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b00:	39 c6                	cmp    %eax,%esi
  801b02:	73 24                	jae    801b28 <devfile_read+0x59>
  801b04:	c7 44 24 0c 74 36 80 	movl   $0x803674,0xc(%esp)
  801b0b:	00 
  801b0c:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  801b13:	00 
  801b14:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b1b:	00 
  801b1c:	c7 04 24 90 36 80 00 	movl   $0x803690,(%esp)
  801b23:	e8 f0 e6 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801b28:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2d:	7e 24                	jle    801b53 <devfile_read+0x84>
  801b2f:	c7 44 24 0c 9b 36 80 	movl   $0x80369b,0xc(%esp)
  801b36:	00 
  801b37:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  801b3e:	00 
  801b3f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b46:	00 
  801b47:	c7 04 24 90 36 80 00 	movl   $0x803690,(%esp)
  801b4e:	e8 c5 e6 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b57:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b5e:	00 
  801b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b62:	89 04 24             	mov    %eax,(%esp)
  801b65:	e8 6a ef ff ff       	call   800ad4 <memmove>
	return r;
}
  801b6a:	89 d8                	mov    %ebx,%eax
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	83 ec 24             	sub    $0x24,%esp
  801b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b7d:	89 1c 24             	mov    %ebx,(%esp)
  801b80:	e8 7b ed ff ff       	call   800900 <strlen>
  801b85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b8a:	7f 60                	jg     801bec <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 20 f8 ff ff       	call   8013b7 <fd_alloc>
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	85 d2                	test   %edx,%edx
  801b9b:	78 54                	js     801bf1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba1:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ba8:	e8 8a ed ff ff       	call   800937 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbd:	e8 b1 fd ff ff       	call   801973 <fsipc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	79 17                	jns    801bdf <open+0x6c>
		fd_close(fd, 0);
  801bc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bcf:	00 
  801bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd3:	89 04 24             	mov    %eax,(%esp)
  801bd6:	e8 db f8 ff ff       	call   8014b6 <fd_close>
		return r;
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	eb 12                	jmp    801bf1 <open+0x7e>
	}

	return fd2num(fd);
  801bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be2:	89 04 24             	mov    %eax,(%esp)
  801be5:	e8 a6 f7 ff ff       	call   801390 <fd2num>
  801bea:	eb 05                	jmp    801bf1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bec:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf1:	83 c4 24             	add    $0x24,%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    

00801bf7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801c02:	b8 08 00 00 00       	mov    $0x8,%eax
  801c07:	e8 67 fd ff ff       	call   801973 <fsipc>
}
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c23:	00 
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 44 ff ff ff       	call   801b73 <open>
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 3e 05 00 00    	js     80217d <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c3f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801c46:	00 
  801c47:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	89 14 24             	mov    %edx,(%esp)
  801c54:	e8 d3 fa ff ff       	call   80172c <readn>
  801c59:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c5e:	75 0c                	jne    801c6c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801c60:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c67:	45 4c 46 
  801c6a:	74 36                	je     801ca2 <spawn+0x92>
		close(fd);
  801c6c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c72:	89 04 24             	mov    %eax,(%esp)
  801c75:	e8 bd f8 ff ff       	call   801537 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c7a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801c81:	46 
  801c82:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	c7 04 24 a7 36 80 00 	movl   $0x8036a7,(%esp)
  801c93:	e8 79 e6 ff ff       	call   800311 <cprintf>
		return -E_NOT_EXEC;
  801c98:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801c9d:	e9 3a 05 00 00       	jmp    8021dc <spawn+0x5cc>
  801ca2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ca7:	cd 30                	int    $0x30
  801ca9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801caf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 c8 04 00 00    	js     802185 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cbd:	89 c6                	mov    %eax,%esi
  801cbf:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cc5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cc8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cce:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cd4:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cdb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ce1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cec:	be 00 00 00 00       	mov    $0x0,%esi
  801cf1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cf4:	eb 0f                	jmp    801d05 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801cf6:	89 04 24             	mov    %eax,(%esp)
  801cf9:	e8 02 ec ff ff       	call   800900 <strlen>
  801cfe:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d02:	83 c3 01             	add    $0x1,%ebx
  801d05:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d0c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	75 e3                	jne    801cf6 <spawn+0xe6>
  801d13:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801d19:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d1f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d24:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d26:	89 fa                	mov    %edi,%edx
  801d28:	83 e2 fc             	and    $0xfffffffc,%edx
  801d2b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d32:	29 c2                	sub    %eax,%edx
  801d34:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d3a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d3d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d42:	0f 86 4d 04 00 00    	jbe    802195 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d48:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d4f:	00 
  801d50:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d57:	00 
  801d58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5f:	e8 ef ef ff ff       	call   800d53 <sys_page_alloc>
  801d64:	85 c0                	test   %eax,%eax
  801d66:	0f 88 70 04 00 00    	js     8021dc <spawn+0x5cc>
  801d6c:	be 00 00 00 00       	mov    $0x0,%esi
  801d71:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d7a:	eb 30                	jmp    801dac <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d7c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d82:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d88:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d8b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d92:	89 3c 24             	mov    %edi,(%esp)
  801d95:	e8 9d eb ff ff       	call   800937 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d9a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801d9d:	89 04 24             	mov    %eax,(%esp)
  801da0:	e8 5b eb ff ff       	call   800900 <strlen>
  801da5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801da9:	83 c6 01             	add    $0x1,%esi
  801dac:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801db2:	7f c8                	jg     801d7c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801db4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dba:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801dc0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dc7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dcd:	74 24                	je     801df3 <spawn+0x1e3>
  801dcf:	c7 44 24 0c 1c 37 80 	movl   $0x80371c,0xc(%esp)
  801dd6:	00 
  801dd7:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  801dde:	00 
  801ddf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801de6:	00 
  801de7:	c7 04 24 c1 36 80 00 	movl   $0x8036c1,(%esp)
  801dee:	e8 25 e4 ff ff       	call   800218 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801df3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801df9:	89 c8                	mov    %ecx,%eax
  801dfb:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e00:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801e03:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e09:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e0c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801e12:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e18:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801e1f:	00 
  801e20:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801e27:	ee 
  801e28:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e32:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e39:	00 
  801e3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e41:	e8 61 ef ff ff       	call   800da7 <sys_page_map>
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	0f 88 76 03 00 00    	js     8021c6 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e50:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e57:	00 
  801e58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5f:	e8 96 ef ff ff       	call   800dfa <sys_page_unmap>
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	85 c0                	test   %eax,%eax
  801e68:	0f 88 58 03 00 00    	js     8021c6 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e6e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e74:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e7b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e81:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e88:	00 00 00 
  801e8b:	e9 b6 01 00 00       	jmp    802046 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801e90:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e96:	83 38 01             	cmpl   $0x1,(%eax)
  801e99:	0f 85 99 01 00 00    	jne    802038 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e9f:	89 c2                	mov    %eax,%edx
  801ea1:	8b 40 18             	mov    0x18(%eax),%eax
  801ea4:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801ea7:	83 f8 01             	cmp    $0x1,%eax
  801eaa:	19 c0                	sbb    %eax,%eax
  801eac:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801eb2:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801eb9:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ec0:	89 d0                	mov    %edx,%eax
  801ec2:	8b 52 04             	mov    0x4(%edx),%edx
  801ec5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801ecb:	8b 50 10             	mov    0x10(%eax),%edx
  801ece:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801ed4:	8b 48 14             	mov    0x14(%eax),%ecx
  801ed7:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801edd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ee0:	89 f0                	mov    %esi,%eax
  801ee2:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ee7:	74 14                	je     801efd <spawn+0x2ed>
		va -= i;
  801ee9:	29 c6                	sub    %eax,%esi
		memsz += i;
  801eeb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801ef1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ef7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801efd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f02:	e9 23 01 00 00       	jmp    80202a <spawn+0x41a>
		if (i >= filesz) {
  801f07:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801f0d:	77 2b                	ja     801f3a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f0f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f23:	89 04 24             	mov    %eax,(%esp)
  801f26:	e8 28 ee ff ff       	call   800d53 <sys_page_alloc>
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	0f 89 eb 00 00 00    	jns    80201e <spawn+0x40e>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	e9 6c 02 00 00       	jmp    8021a6 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f3a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f41:	00 
  801f42:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f49:	00 
  801f4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f51:	e8 fd ed ff ff       	call   800d53 <sys_page_alloc>
  801f56:	85 c0                	test   %eax,%eax
  801f58:	0f 88 3e 02 00 00    	js     80219c <spawn+0x58c>
  801f5e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f64:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 8c f8 ff ff       	call   801804 <seek>
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	0f 88 20 02 00 00    	js     8021a0 <spawn+0x590>
  801f80:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801f86:	29 f9                	sub    %edi,%ecx
  801f88:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f8a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  801f90:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f95:	0f 47 c1             	cmova  %ecx,%eax
  801f98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f9c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fa3:	00 
  801fa4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801faa:	89 04 24             	mov    %eax,(%esp)
  801fad:	e8 7a f7 ff ff       	call   80172c <readn>
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	0f 88 ea 01 00 00    	js     8021a4 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fba:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fc4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801fc8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fce:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fd9:	00 
  801fda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe1:	e8 c1 ed ff ff       	call   800da7 <sys_page_map>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 20                	jns    80200a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801fea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fee:	c7 44 24 08 cd 36 80 	movl   $0x8036cd,0x8(%esp)
  801ff5:	00 
  801ff6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801ffd:	00 
  801ffe:	c7 04 24 c1 36 80 00 	movl   $0x8036c1,(%esp)
  802005:	e8 0e e2 ff ff       	call   800218 <_panic>
			sys_page_unmap(0, UTEMP);
  80200a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802011:	00 
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 dc ed ff ff       	call   800dfa <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80201e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802024:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80202a:	89 df                	mov    %ebx,%edi
  80202c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802032:	0f 87 cf fe ff ff    	ja     801f07 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802038:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80203f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802046:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80204d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802053:	0f 8c 37 fe ff ff    	jl     801e90 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802059:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80205f:	89 04 24             	mov    %eax,(%esp)
  802062:	e8 d0 f4 ff ff       	call   801537 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  802067:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  80206c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  802071:	89 d8                	mov    %ebx,%eax
  802073:	c1 e8 16             	shr    $0x16,%eax
  802076:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80207d:	85 c0                	test   %eax,%eax
  80207f:	74 4e                	je     8020cf <spawn+0x4bf>
  802081:	89 d8                	mov    %ebx,%eax
  802083:	c1 e8 0c             	shr    $0xc,%eax
  802086:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80208d:	85 d2                	test   %edx,%edx
  80208f:	74 3e                	je     8020cf <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  802091:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802098:	f6 c6 04             	test   $0x4,%dh
  80209b:	74 32                	je     8020cf <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  80209d:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  8020a4:	e8 6c ec ff ff       	call   800d15 <sys_getenvid>
  8020a9:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8020af:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8020b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020b7:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  8020bd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 da ec ff ff       	call   800da7 <sys_page_map>
  8020cd:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  8020cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020d5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8020db:	75 94                	jne    802071 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  8020dd:	85 f6                	test   %esi,%esi
  8020df:	79 1c                	jns    8020fd <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  8020e1:	c7 44 24 08 44 37 80 	movl   $0x803744,0x8(%esp)
  8020e8:	00 
  8020e9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  8020f0:	00 
  8020f1:	c7 04 24 c1 36 80 00 	movl   $0x8036c1,(%esp)
  8020f8:	e8 1b e1 ff ff       	call   800218 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020fd:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802104:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802107:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802117:	89 04 24             	mov    %eax,(%esp)
  80211a:	e8 81 ed ff ff       	call   800ea0 <sys_env_set_trapframe>
  80211f:	85 c0                	test   %eax,%eax
  802121:	79 20                	jns    802143 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  802123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802127:	c7 44 24 08 ea 36 80 	movl   $0x8036ea,0x8(%esp)
  80212e:	00 
  80212f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802136:	00 
  802137:	c7 04 24 c1 36 80 00 	movl   $0x8036c1,(%esp)
  80213e:	e8 d5 e0 ff ff       	call   800218 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802143:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80214a:	00 
  80214b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 f4 ec ff ff       	call   800e4d <sys_env_set_status>
  802159:	85 c0                	test   %eax,%eax
  80215b:	79 30                	jns    80218d <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  80215d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802161:	c7 44 24 08 04 37 80 	movl   $0x803704,0x8(%esp)
  802168:	00 
  802169:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802170:	00 
  802171:	c7 04 24 c1 36 80 00 	movl   $0x8036c1,(%esp)
  802178:	e8 9b e0 ff ff       	call   800218 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80217d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802183:	eb 57                	jmp    8021dc <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802185:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80218b:	eb 4f                	jmp    8021dc <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80218d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802193:	eb 47                	jmp    8021dc <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802195:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80219a:	eb 40                	jmp    8021dc <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80219c:	89 c3                	mov    %eax,%ebx
  80219e:	eb 06                	jmp    8021a6 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	eb 02                	jmp    8021a6 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8021a4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8021a6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 0f eb ff ff       	call   800cc3 <sys_env_destroy>
	close(fd);
  8021b4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 75 f3 ff ff       	call   801537 <close>
	return r;
  8021c2:	89 d8                	mov    %ebx,%eax
  8021c4:	eb 16                	jmp    8021dc <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021c6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021cd:	00 
  8021ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d5:	e8 20 ec ff ff       	call   800dfa <sys_page_unmap>
  8021da:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021dc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    

008021e7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	56                   	push   %esi
  8021eb:	53                   	push   %ebx
  8021ec:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021ef:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021f2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021f7:	eb 03                	jmp    8021fc <spawnl+0x15>
		argc++;
  8021f9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021fc:	83 c0 04             	add    $0x4,%eax
  8021ff:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802203:	75 f4                	jne    8021f9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802205:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80220c:	83 e0 f0             	and    $0xfffffff0,%eax
  80220f:	29 c4                	sub    %eax,%esp
  802211:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802215:	c1 e8 02             	shr    $0x2,%eax
  802218:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80221f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802224:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80222b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802232:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802233:	b8 00 00 00 00       	mov    $0x0,%eax
  802238:	eb 0a                	jmp    802244 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80223a:	83 c0 01             	add    $0x1,%eax
  80223d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802241:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802244:	39 d0                	cmp    %edx,%eax
  802246:	75 f2                	jne    80223a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802248:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224c:	8b 45 08             	mov    0x8(%ebp),%eax
  80224f:	89 04 24             	mov    %eax,(%esp)
  802252:	e8 b9 f9 ff ff       	call   801c10 <spawn>
}
  802257:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225a:	5b                   	pop    %ebx
  80225b:	5e                   	pop    %esi
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    
  80225e:	66 90                	xchg   %ax,%ax

00802260 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802266:	c7 44 24 04 6e 37 80 	movl   $0x80376e,0x4(%esp)
  80226d:	00 
  80226e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802271:	89 04 24             	mov    %eax,(%esp)
  802274:	e8 be e6 ff ff       	call   800937 <strcpy>
	return 0;
}
  802279:	b8 00 00 00 00       	mov    $0x0,%eax
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    

00802280 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	53                   	push   %ebx
  802284:	83 ec 14             	sub    $0x14,%esp
  802287:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80228a:	89 1c 24             	mov    %ebx,(%esp)
  80228d:	e8 fb 0b 00 00       	call   802e8d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802292:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802297:	83 f8 01             	cmp    $0x1,%eax
  80229a:	75 0d                	jne    8022a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80229c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80229f:	89 04 24             	mov    %eax,(%esp)
  8022a2:	e8 29 03 00 00       	call   8025d0 <nsipc_close>
  8022a7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8022a9:	89 d0                	mov    %edx,%eax
  8022ab:	83 c4 14             	add    $0x14,%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    

008022b1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8022b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022be:	00 
  8022bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8022c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 f0 03 00 00       	call   8026cb <nsipc_send>
}
  8022db:	c9                   	leave  
  8022dc:	c3                   	ret    

008022dd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022ea:	00 
  8022eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ff:	89 04 24             	mov    %eax,(%esp)
  802302:	e8 44 03 00 00       	call   80264b <nsipc_recv>
}
  802307:	c9                   	leave  
  802308:	c3                   	ret    

00802309 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80230f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802312:	89 54 24 04          	mov    %edx,0x4(%esp)
  802316:	89 04 24             	mov    %eax,(%esp)
  802319:	e8 e8 f0 ff ff       	call   801406 <fd_lookup>
  80231e:	85 c0                	test   %eax,%eax
  802320:	78 17                	js     802339 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802325:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  80232b:	39 08                	cmp    %ecx,(%eax)
  80232d:	75 05                	jne    802334 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80232f:	8b 40 0c             	mov    0xc(%eax),%eax
  802332:	eb 05                	jmp    802339 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802334:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802339:	c9                   	leave  
  80233a:	c3                   	ret    

0080233b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	56                   	push   %esi
  80233f:	53                   	push   %ebx
  802340:	83 ec 20             	sub    $0x20,%esp
  802343:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802348:	89 04 24             	mov    %eax,(%esp)
  80234b:	e8 67 f0 ff ff       	call   8013b7 <fd_alloc>
  802350:	89 c3                	mov    %eax,%ebx
  802352:	85 c0                	test   %eax,%eax
  802354:	78 21                	js     802377 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802356:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80235d:	00 
  80235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802361:	89 44 24 04          	mov    %eax,0x4(%esp)
  802365:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236c:	e8 e2 e9 ff ff       	call   800d53 <sys_page_alloc>
  802371:	89 c3                	mov    %eax,%ebx
  802373:	85 c0                	test   %eax,%eax
  802375:	79 0c                	jns    802383 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  802377:	89 34 24             	mov    %esi,(%esp)
  80237a:	e8 51 02 00 00       	call   8025d0 <nsipc_close>
		return r;
  80237f:	89 d8                	mov    %ebx,%eax
  802381:	eb 20                	jmp    8023a3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802383:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80238e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802391:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802398:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80239b:	89 14 24             	mov    %edx,(%esp)
  80239e:	e8 ed ef ff ff       	call   801390 <fd2num>
}
  8023a3:	83 c4 20             	add    $0x20,%esp
  8023a6:	5b                   	pop    %ebx
  8023a7:	5e                   	pop    %esi
  8023a8:	5d                   	pop    %ebp
  8023a9:	c3                   	ret    

008023aa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b3:	e8 51 ff ff ff       	call   802309 <fd2sockid>
		return r;
  8023b8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 23                	js     8023e1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023be:	8b 55 10             	mov    0x10(%ebp),%edx
  8023c1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023cc:	89 04 24             	mov    %eax,(%esp)
  8023cf:	e8 45 01 00 00       	call   802519 <nsipc_accept>
		return r;
  8023d4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	78 07                	js     8023e1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  8023da:	e8 5c ff ff ff       	call   80233b <alloc_sockfd>
  8023df:	89 c1                	mov    %eax,%ecx
}
  8023e1:	89 c8                	mov    %ecx,%eax
  8023e3:	c9                   	leave  
  8023e4:	c3                   	ret    

008023e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ee:	e8 16 ff ff ff       	call   802309 <fd2sockid>
  8023f3:	89 c2                	mov    %eax,%edx
  8023f5:	85 d2                	test   %edx,%edx
  8023f7:	78 16                	js     80240f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8023f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8023fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802400:	8b 45 0c             	mov    0xc(%ebp),%eax
  802403:	89 44 24 04          	mov    %eax,0x4(%esp)
  802407:	89 14 24             	mov    %edx,(%esp)
  80240a:	e8 60 01 00 00       	call   80256f <nsipc_bind>
}
  80240f:	c9                   	leave  
  802410:	c3                   	ret    

00802411 <shutdown>:

int
shutdown(int s, int how)
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802417:	8b 45 08             	mov    0x8(%ebp),%eax
  80241a:	e8 ea fe ff ff       	call   802309 <fd2sockid>
  80241f:	89 c2                	mov    %eax,%edx
  802421:	85 d2                	test   %edx,%edx
  802423:	78 0f                	js     802434 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802425:	8b 45 0c             	mov    0xc(%ebp),%eax
  802428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80242c:	89 14 24             	mov    %edx,(%esp)
  80242f:	e8 7a 01 00 00       	call   8025ae <nsipc_shutdown>
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	e8 c5 fe ff ff       	call   802309 <fd2sockid>
  802444:	89 c2                	mov    %eax,%edx
  802446:	85 d2                	test   %edx,%edx
  802448:	78 16                	js     802460 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80244a:	8b 45 10             	mov    0x10(%ebp),%eax
  80244d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802451:	8b 45 0c             	mov    0xc(%ebp),%eax
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	89 14 24             	mov    %edx,(%esp)
  80245b:	e8 8a 01 00 00       	call   8025ea <nsipc_connect>
}
  802460:	c9                   	leave  
  802461:	c3                   	ret    

00802462 <listen>:

int
listen(int s, int backlog)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	e8 99 fe ff ff       	call   802309 <fd2sockid>
  802470:	89 c2                	mov    %eax,%edx
  802472:	85 d2                	test   %edx,%edx
  802474:	78 0f                	js     802485 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802476:	8b 45 0c             	mov    0xc(%ebp),%eax
  802479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247d:	89 14 24             	mov    %edx,(%esp)
  802480:	e8 a4 01 00 00       	call   802629 <nsipc_listen>
}
  802485:	c9                   	leave  
  802486:	c3                   	ret    

00802487 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80248d:	8b 45 10             	mov    0x10(%ebp),%eax
  802490:	89 44 24 08          	mov    %eax,0x8(%esp)
  802494:	8b 45 0c             	mov    0xc(%ebp),%eax
  802497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
  80249e:	89 04 24             	mov    %eax,(%esp)
  8024a1:	e8 98 02 00 00       	call   80273e <nsipc_socket>
  8024a6:	89 c2                	mov    %eax,%edx
  8024a8:	85 d2                	test   %edx,%edx
  8024aa:	78 05                	js     8024b1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  8024ac:	e8 8a fe ff ff       	call   80233b <alloc_sockfd>
}
  8024b1:	c9                   	leave  
  8024b2:	c3                   	ret    

008024b3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8024b3:	55                   	push   %ebp
  8024b4:	89 e5                	mov    %esp,%ebp
  8024b6:	53                   	push   %ebx
  8024b7:	83 ec 14             	sub    $0x14,%esp
  8024ba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8024bc:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8024c3:	75 11                	jne    8024d6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8024cc:	e8 84 09 00 00       	call   802e55 <ipc_find_env>
  8024d1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8024d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8024dd:	00 
  8024de:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8024e5:	00 
  8024e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024ea:	a1 04 50 80 00       	mov    0x805004,%eax
  8024ef:	89 04 24             	mov    %eax,(%esp)
  8024f2:	e8 f3 08 00 00       	call   802dea <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8024f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024fe:	00 
  8024ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802506:	00 
  802507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250e:	e8 5d 08 00 00       	call   802d70 <ipc_recv>
}
  802513:	83 c4 14             	add    $0x14,%esp
  802516:	5b                   	pop    %ebx
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    

00802519 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	56                   	push   %esi
  80251d:	53                   	push   %ebx
  80251e:	83 ec 10             	sub    $0x10,%esp
  802521:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802524:	8b 45 08             	mov    0x8(%ebp),%eax
  802527:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80252c:	8b 06                	mov    (%esi),%eax
  80252e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802533:	b8 01 00 00 00       	mov    $0x1,%eax
  802538:	e8 76 ff ff ff       	call   8024b3 <nsipc>
  80253d:	89 c3                	mov    %eax,%ebx
  80253f:	85 c0                	test   %eax,%eax
  802541:	78 23                	js     802566 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802543:	a1 10 70 80 00       	mov    0x807010,%eax
  802548:	89 44 24 08          	mov    %eax,0x8(%esp)
  80254c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802553:	00 
  802554:	8b 45 0c             	mov    0xc(%ebp),%eax
  802557:	89 04 24             	mov    %eax,(%esp)
  80255a:	e8 75 e5 ff ff       	call   800ad4 <memmove>
		*addrlen = ret->ret_addrlen;
  80255f:	a1 10 70 80 00       	mov    0x807010,%eax
  802564:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802566:	89 d8                	mov    %ebx,%eax
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	5b                   	pop    %ebx
  80256c:	5e                   	pop    %esi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    

0080256f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	53                   	push   %ebx
  802573:	83 ec 14             	sub    $0x14,%esp
  802576:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802579:	8b 45 08             	mov    0x8(%ebp),%eax
  80257c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802581:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802585:	8b 45 0c             	mov    0xc(%ebp),%eax
  802588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80258c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802593:	e8 3c e5 ff ff       	call   800ad4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802598:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80259e:	b8 02 00 00 00       	mov    $0x2,%eax
  8025a3:	e8 0b ff ff ff       	call   8024b3 <nsipc>
}
  8025a8:	83 c4 14             	add    $0x14,%esp
  8025ab:	5b                   	pop    %ebx
  8025ac:	5d                   	pop    %ebp
  8025ad:	c3                   	ret    

008025ae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8025ae:	55                   	push   %ebp
  8025af:	89 e5                	mov    %esp,%ebp
  8025b1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8025b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8025bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bf:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8025c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8025c9:	e8 e5 fe ff ff       	call   8024b3 <nsipc>
}
  8025ce:	c9                   	leave  
  8025cf:	c3                   	ret    

008025d0 <nsipc_close>:

int
nsipc_close(int s)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025de:	b8 04 00 00 00       	mov    $0x4,%eax
  8025e3:	e8 cb fe ff ff       	call   8024b3 <nsipc>
}
  8025e8:	c9                   	leave  
  8025e9:	c3                   	ret    

008025ea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025ea:	55                   	push   %ebp
  8025eb:	89 e5                	mov    %esp,%ebp
  8025ed:	53                   	push   %ebx
  8025ee:	83 ec 14             	sub    $0x14,%esp
  8025f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8025f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8025fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802600:	8b 45 0c             	mov    0xc(%ebp),%eax
  802603:	89 44 24 04          	mov    %eax,0x4(%esp)
  802607:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80260e:	e8 c1 e4 ff ff       	call   800ad4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802613:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802619:	b8 05 00 00 00       	mov    $0x5,%eax
  80261e:	e8 90 fe ff ff       	call   8024b3 <nsipc>
}
  802623:	83 c4 14             	add    $0x14,%esp
  802626:	5b                   	pop    %ebx
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    

00802629 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80262f:	8b 45 08             	mov    0x8(%ebp),%eax
  802632:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80263a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80263f:	b8 06 00 00 00       	mov    $0x6,%eax
  802644:	e8 6a fe ff ff       	call   8024b3 <nsipc>
}
  802649:	c9                   	leave  
  80264a:	c3                   	ret    

0080264b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80264b:	55                   	push   %ebp
  80264c:	89 e5                	mov    %esp,%ebp
  80264e:	56                   	push   %esi
  80264f:	53                   	push   %ebx
  802650:	83 ec 10             	sub    $0x10,%esp
  802653:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802656:	8b 45 08             	mov    0x8(%ebp),%eax
  802659:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80265e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802664:	8b 45 14             	mov    0x14(%ebp),%eax
  802667:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80266c:	b8 07 00 00 00       	mov    $0x7,%eax
  802671:	e8 3d fe ff ff       	call   8024b3 <nsipc>
  802676:	89 c3                	mov    %eax,%ebx
  802678:	85 c0                	test   %eax,%eax
  80267a:	78 46                	js     8026c2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80267c:	39 f0                	cmp    %esi,%eax
  80267e:	7f 07                	jg     802687 <nsipc_recv+0x3c>
  802680:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802685:	7e 24                	jle    8026ab <nsipc_recv+0x60>
  802687:	c7 44 24 0c 7a 37 80 	movl   $0x80377a,0xc(%esp)
  80268e:	00 
  80268f:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  802696:	00 
  802697:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80269e:	00 
  80269f:	c7 04 24 8f 37 80 00 	movl   $0x80378f,(%esp)
  8026a6:	e8 6d db ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8026ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026af:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8026b6:	00 
  8026b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ba:	89 04 24             	mov    %eax,(%esp)
  8026bd:	e8 12 e4 ff ff       	call   800ad4 <memmove>
	}

	return r;
}
  8026c2:	89 d8                	mov    %ebx,%eax
  8026c4:	83 c4 10             	add    $0x10,%esp
  8026c7:	5b                   	pop    %ebx
  8026c8:	5e                   	pop    %esi
  8026c9:	5d                   	pop    %ebp
  8026ca:	c3                   	ret    

008026cb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8026cb:	55                   	push   %ebp
  8026cc:	89 e5                	mov    %esp,%ebp
  8026ce:	53                   	push   %ebx
  8026cf:	83 ec 14             	sub    $0x14,%esp
  8026d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8026d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026dd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026e3:	7e 24                	jle    802709 <nsipc_send+0x3e>
  8026e5:	c7 44 24 0c 9b 37 80 	movl   $0x80379b,0xc(%esp)
  8026ec:	00 
  8026ed:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  8026f4:	00 
  8026f5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8026fc:	00 
  8026fd:	c7 04 24 8f 37 80 00 	movl   $0x80378f,(%esp)
  802704:	e8 0f db ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80270d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802710:	89 44 24 04          	mov    %eax,0x4(%esp)
  802714:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80271b:	e8 b4 e3 ff ff       	call   800ad4 <memmove>
	nsipcbuf.send.req_size = size;
  802720:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802726:	8b 45 14             	mov    0x14(%ebp),%eax
  802729:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80272e:	b8 08 00 00 00       	mov    $0x8,%eax
  802733:	e8 7b fd ff ff       	call   8024b3 <nsipc>
}
  802738:	83 c4 14             	add    $0x14,%esp
  80273b:	5b                   	pop    %ebx
  80273c:	5d                   	pop    %ebp
  80273d:	c3                   	ret    

0080273e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80273e:	55                   	push   %ebp
  80273f:	89 e5                	mov    %esp,%ebp
  802741:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802744:	8b 45 08             	mov    0x8(%ebp),%eax
  802747:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80274c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80274f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802754:	8b 45 10             	mov    0x10(%ebp),%eax
  802757:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80275c:	b8 09 00 00 00       	mov    $0x9,%eax
  802761:	e8 4d fd ff ff       	call   8024b3 <nsipc>
}
  802766:	c9                   	leave  
  802767:	c3                   	ret    

00802768 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802768:	55                   	push   %ebp
  802769:	89 e5                	mov    %esp,%ebp
  80276b:	56                   	push   %esi
  80276c:	53                   	push   %ebx
  80276d:	83 ec 10             	sub    $0x10,%esp
  802770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802773:	8b 45 08             	mov    0x8(%ebp),%eax
  802776:	89 04 24             	mov    %eax,(%esp)
  802779:	e8 22 ec ff ff       	call   8013a0 <fd2data>
  80277e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802780:	c7 44 24 04 a7 37 80 	movl   $0x8037a7,0x4(%esp)
  802787:	00 
  802788:	89 1c 24             	mov    %ebx,(%esp)
  80278b:	e8 a7 e1 ff ff       	call   800937 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802790:	8b 46 04             	mov    0x4(%esi),%eax
  802793:	2b 06                	sub    (%esi),%eax
  802795:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80279b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8027a2:	00 00 00 
	stat->st_dev = &devpipe;
  8027a5:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  8027ac:	40 80 00 
	return 0;
}
  8027af:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b4:	83 c4 10             	add    $0x10,%esp
  8027b7:	5b                   	pop    %ebx
  8027b8:	5e                   	pop    %esi
  8027b9:	5d                   	pop    %ebp
  8027ba:	c3                   	ret    

008027bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8027bb:	55                   	push   %ebp
  8027bc:	89 e5                	mov    %esp,%ebp
  8027be:	53                   	push   %ebx
  8027bf:	83 ec 14             	sub    $0x14,%esp
  8027c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8027c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8027c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027d0:	e8 25 e6 ff ff       	call   800dfa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8027d5:	89 1c 24             	mov    %ebx,(%esp)
  8027d8:	e8 c3 eb ff ff       	call   8013a0 <fd2data>
  8027dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027e8:	e8 0d e6 ff ff       	call   800dfa <sys_page_unmap>
}
  8027ed:	83 c4 14             	add    $0x14,%esp
  8027f0:	5b                   	pop    %ebx
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    

008027f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8027f3:	55                   	push   %ebp
  8027f4:	89 e5                	mov    %esp,%ebp
  8027f6:	57                   	push   %edi
  8027f7:	56                   	push   %esi
  8027f8:	53                   	push   %ebx
  8027f9:	83 ec 2c             	sub    $0x2c,%esp
  8027fc:	89 c6                	mov    %eax,%esi
  8027fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802801:	a1 08 50 80 00       	mov    0x805008,%eax
  802806:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802809:	89 34 24             	mov    %esi,(%esp)
  80280c:	e8 7c 06 00 00       	call   802e8d <pageref>
  802811:	89 c7                	mov    %eax,%edi
  802813:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802816:	89 04 24             	mov    %eax,(%esp)
  802819:	e8 6f 06 00 00       	call   802e8d <pageref>
  80281e:	39 c7                	cmp    %eax,%edi
  802820:	0f 94 c2             	sete   %dl
  802823:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802826:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  80282c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80282f:	39 fb                	cmp    %edi,%ebx
  802831:	74 21                	je     802854 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802833:	84 d2                	test   %dl,%dl
  802835:	74 ca                	je     802801 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802837:	8b 51 58             	mov    0x58(%ecx),%edx
  80283a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80283e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802842:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802846:	c7 04 24 ae 37 80 00 	movl   $0x8037ae,(%esp)
  80284d:	e8 bf da ff ff       	call   800311 <cprintf>
  802852:	eb ad                	jmp    802801 <_pipeisclosed+0xe>
	}
}
  802854:	83 c4 2c             	add    $0x2c,%esp
  802857:	5b                   	pop    %ebx
  802858:	5e                   	pop    %esi
  802859:	5f                   	pop    %edi
  80285a:	5d                   	pop    %ebp
  80285b:	c3                   	ret    

0080285c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	57                   	push   %edi
  802860:	56                   	push   %esi
  802861:	53                   	push   %ebx
  802862:	83 ec 1c             	sub    $0x1c,%esp
  802865:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802868:	89 34 24             	mov    %esi,(%esp)
  80286b:	e8 30 eb ff ff       	call   8013a0 <fd2data>
  802870:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802872:	bf 00 00 00 00       	mov    $0x0,%edi
  802877:	eb 45                	jmp    8028be <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802879:	89 da                	mov    %ebx,%edx
  80287b:	89 f0                	mov    %esi,%eax
  80287d:	e8 71 ff ff ff       	call   8027f3 <_pipeisclosed>
  802882:	85 c0                	test   %eax,%eax
  802884:	75 41                	jne    8028c7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802886:	e8 a9 e4 ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80288b:	8b 43 04             	mov    0x4(%ebx),%eax
  80288e:	8b 0b                	mov    (%ebx),%ecx
  802890:	8d 51 20             	lea    0x20(%ecx),%edx
  802893:	39 d0                	cmp    %edx,%eax
  802895:	73 e2                	jae    802879 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80289a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80289e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8028a1:	99                   	cltd   
  8028a2:	c1 ea 1b             	shr    $0x1b,%edx
  8028a5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8028a8:	83 e1 1f             	and    $0x1f,%ecx
  8028ab:	29 d1                	sub    %edx,%ecx
  8028ad:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8028b1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8028b5:	83 c0 01             	add    $0x1,%eax
  8028b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028bb:	83 c7 01             	add    $0x1,%edi
  8028be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8028c1:	75 c8                	jne    80288b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8028c3:	89 f8                	mov    %edi,%eax
  8028c5:	eb 05                	jmp    8028cc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8028c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8028cc:	83 c4 1c             	add    $0x1c,%esp
  8028cf:	5b                   	pop    %ebx
  8028d0:	5e                   	pop    %esi
  8028d1:	5f                   	pop    %edi
  8028d2:	5d                   	pop    %ebp
  8028d3:	c3                   	ret    

008028d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8028d4:	55                   	push   %ebp
  8028d5:	89 e5                	mov    %esp,%ebp
  8028d7:	57                   	push   %edi
  8028d8:	56                   	push   %esi
  8028d9:	53                   	push   %ebx
  8028da:	83 ec 1c             	sub    $0x1c,%esp
  8028dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8028e0:	89 3c 24             	mov    %edi,(%esp)
  8028e3:	e8 b8 ea ff ff       	call   8013a0 <fd2data>
  8028e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028ea:	be 00 00 00 00       	mov    $0x0,%esi
  8028ef:	eb 3d                	jmp    80292e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8028f1:	85 f6                	test   %esi,%esi
  8028f3:	74 04                	je     8028f9 <devpipe_read+0x25>
				return i;
  8028f5:	89 f0                	mov    %esi,%eax
  8028f7:	eb 43                	jmp    80293c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8028f9:	89 da                	mov    %ebx,%edx
  8028fb:	89 f8                	mov    %edi,%eax
  8028fd:	e8 f1 fe ff ff       	call   8027f3 <_pipeisclosed>
  802902:	85 c0                	test   %eax,%eax
  802904:	75 31                	jne    802937 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802906:	e8 29 e4 ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80290b:	8b 03                	mov    (%ebx),%eax
  80290d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802910:	74 df                	je     8028f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802912:	99                   	cltd   
  802913:	c1 ea 1b             	shr    $0x1b,%edx
  802916:	01 d0                	add    %edx,%eax
  802918:	83 e0 1f             	and    $0x1f,%eax
  80291b:	29 d0                	sub    %edx,%eax
  80291d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802925:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802928:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80292b:	83 c6 01             	add    $0x1,%esi
  80292e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802931:	75 d8                	jne    80290b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802933:	89 f0                	mov    %esi,%eax
  802935:	eb 05                	jmp    80293c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802937:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80293c:	83 c4 1c             	add    $0x1c,%esp
  80293f:	5b                   	pop    %ebx
  802940:	5e                   	pop    %esi
  802941:	5f                   	pop    %edi
  802942:	5d                   	pop    %ebp
  802943:	c3                   	ret    

00802944 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802944:	55                   	push   %ebp
  802945:	89 e5                	mov    %esp,%ebp
  802947:	56                   	push   %esi
  802948:	53                   	push   %ebx
  802949:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80294c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80294f:	89 04 24             	mov    %eax,(%esp)
  802952:	e8 60 ea ff ff       	call   8013b7 <fd_alloc>
  802957:	89 c2                	mov    %eax,%edx
  802959:	85 d2                	test   %edx,%edx
  80295b:	0f 88 4d 01 00 00    	js     802aae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802961:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802968:	00 
  802969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802977:	e8 d7 e3 ff ff       	call   800d53 <sys_page_alloc>
  80297c:	89 c2                	mov    %eax,%edx
  80297e:	85 d2                	test   %edx,%edx
  802980:	0f 88 28 01 00 00    	js     802aae <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802986:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802989:	89 04 24             	mov    %eax,(%esp)
  80298c:	e8 26 ea ff ff       	call   8013b7 <fd_alloc>
  802991:	89 c3                	mov    %eax,%ebx
  802993:	85 c0                	test   %eax,%eax
  802995:	0f 88 fe 00 00 00    	js     802a99 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80299b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8029a2:	00 
  8029a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029b1:	e8 9d e3 ff ff       	call   800d53 <sys_page_alloc>
  8029b6:	89 c3                	mov    %eax,%ebx
  8029b8:	85 c0                	test   %eax,%eax
  8029ba:	0f 88 d9 00 00 00    	js     802a99 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8029c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029c3:	89 04 24             	mov    %eax,(%esp)
  8029c6:	e8 d5 e9 ff ff       	call   8013a0 <fd2data>
  8029cb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8029d4:	00 
  8029d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029e0:	e8 6e e3 ff ff       	call   800d53 <sys_page_alloc>
  8029e5:	89 c3                	mov    %eax,%ebx
  8029e7:	85 c0                	test   %eax,%eax
  8029e9:	0f 88 97 00 00 00    	js     802a86 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029f2:	89 04 24             	mov    %eax,(%esp)
  8029f5:	e8 a6 e9 ff ff       	call   8013a0 <fd2data>
  8029fa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802a01:	00 
  802a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802a0d:	00 
  802a0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a19:	e8 89 e3 ff ff       	call   800da7 <sys_page_map>
  802a1e:	89 c3                	mov    %eax,%ebx
  802a20:	85 c0                	test   %eax,%eax
  802a22:	78 52                	js     802a76 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802a24:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a2d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a32:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802a39:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a42:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a47:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a51:	89 04 24             	mov    %eax,(%esp)
  802a54:	e8 37 e9 ff ff       	call   801390 <fd2num>
  802a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a5c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a61:	89 04 24             	mov    %eax,(%esp)
  802a64:	e8 27 e9 ff ff       	call   801390 <fd2num>
  802a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a6c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a74:	eb 38                	jmp    802aae <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802a76:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a81:	e8 74 e3 ff ff       	call   800dfa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a94:	e8 61 e3 ff ff       	call   800dfa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802aa0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802aa7:	e8 4e e3 ff ff       	call   800dfa <sys_page_unmap>
  802aac:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802aae:	83 c4 30             	add    $0x30,%esp
  802ab1:	5b                   	pop    %ebx
  802ab2:	5e                   	pop    %esi
  802ab3:	5d                   	pop    %ebp
  802ab4:	c3                   	ret    

00802ab5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802ab5:	55                   	push   %ebp
  802ab6:	89 e5                	mov    %esp,%ebp
  802ab8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ac5:	89 04 24             	mov    %eax,(%esp)
  802ac8:	e8 39 e9 ff ff       	call   801406 <fd_lookup>
  802acd:	89 c2                	mov    %eax,%edx
  802acf:	85 d2                	test   %edx,%edx
  802ad1:	78 15                	js     802ae8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ad6:	89 04 24             	mov    %eax,(%esp)
  802ad9:	e8 c2 e8 ff ff       	call   8013a0 <fd2data>
	return _pipeisclosed(fd, p);
  802ade:	89 c2                	mov    %eax,%edx
  802ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ae3:	e8 0b fd ff ff       	call   8027f3 <_pipeisclosed>
}
  802ae8:	c9                   	leave  
  802ae9:	c3                   	ret    

00802aea <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802aea:	55                   	push   %ebp
  802aeb:	89 e5                	mov    %esp,%ebp
  802aed:	56                   	push   %esi
  802aee:	53                   	push   %ebx
  802aef:	83 ec 10             	sub    $0x10,%esp
  802af2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802af5:	85 f6                	test   %esi,%esi
  802af7:	75 24                	jne    802b1d <wait+0x33>
  802af9:	c7 44 24 0c c6 37 80 	movl   $0x8037c6,0xc(%esp)
  802b00:	00 
  802b01:	c7 44 24 08 7b 36 80 	movl   $0x80367b,0x8(%esp)
  802b08:	00 
  802b09:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802b10:	00 
  802b11:	c7 04 24 d1 37 80 00 	movl   $0x8037d1,(%esp)
  802b18:	e8 fb d6 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  802b1d:	89 f3                	mov    %esi,%ebx
  802b1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802b25:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802b28:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b2e:	eb 05                	jmp    802b35 <wait+0x4b>
		sys_yield();
  802b30:	e8 ff e1 ff ff       	call   800d34 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802b35:	8b 43 48             	mov    0x48(%ebx),%eax
  802b38:	39 f0                	cmp    %esi,%eax
  802b3a:	75 07                	jne    802b43 <wait+0x59>
  802b3c:	8b 43 54             	mov    0x54(%ebx),%eax
  802b3f:	85 c0                	test   %eax,%eax
  802b41:	75 ed                	jne    802b30 <wait+0x46>
		sys_yield();
}
  802b43:	83 c4 10             	add    $0x10,%esp
  802b46:	5b                   	pop    %ebx
  802b47:	5e                   	pop    %esi
  802b48:	5d                   	pop    %ebp
  802b49:	c3                   	ret    
  802b4a:	66 90                	xchg   %ax,%ax
  802b4c:	66 90                	xchg   %ax,%ax
  802b4e:	66 90                	xchg   %ax,%ax

00802b50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802b50:	55                   	push   %ebp
  802b51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
  802b58:	5d                   	pop    %ebp
  802b59:	c3                   	ret    

00802b5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802b5a:	55                   	push   %ebp
  802b5b:	89 e5                	mov    %esp,%ebp
  802b5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802b60:	c7 44 24 04 dc 37 80 	movl   $0x8037dc,0x4(%esp)
  802b67:	00 
  802b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b6b:	89 04 24             	mov    %eax,(%esp)
  802b6e:	e8 c4 dd ff ff       	call   800937 <strcpy>
	return 0;
}
  802b73:	b8 00 00 00 00       	mov    $0x0,%eax
  802b78:	c9                   	leave  
  802b79:	c3                   	ret    

00802b7a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b7a:	55                   	push   %ebp
  802b7b:	89 e5                	mov    %esp,%ebp
  802b7d:	57                   	push   %edi
  802b7e:	56                   	push   %esi
  802b7f:	53                   	push   %ebx
  802b80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b86:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802b8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b91:	eb 31                	jmp    802bc4 <devcons_write+0x4a>
		m = n - tot;
  802b93:	8b 75 10             	mov    0x10(%ebp),%esi
  802b96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802b98:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802b9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802ba0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802ba3:	89 74 24 08          	mov    %esi,0x8(%esp)
  802ba7:	03 45 0c             	add    0xc(%ebp),%eax
  802baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bae:	89 3c 24             	mov    %edi,(%esp)
  802bb1:	e8 1e df ff ff       	call   800ad4 <memmove>
		sys_cputs(buf, m);
  802bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bba:	89 3c 24             	mov    %edi,(%esp)
  802bbd:	e8 c4 e0 ff ff       	call   800c86 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802bc2:	01 f3                	add    %esi,%ebx
  802bc4:	89 d8                	mov    %ebx,%eax
  802bc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802bc9:	72 c8                	jb     802b93 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802bcb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802bd1:	5b                   	pop    %ebx
  802bd2:	5e                   	pop    %esi
  802bd3:	5f                   	pop    %edi
  802bd4:	5d                   	pop    %ebp
  802bd5:	c3                   	ret    

00802bd6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bd6:	55                   	push   %ebp
  802bd7:	89 e5                	mov    %esp,%ebp
  802bd9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802bdc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802be1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802be5:	75 07                	jne    802bee <devcons_read+0x18>
  802be7:	eb 2a                	jmp    802c13 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802be9:	e8 46 e1 ff ff       	call   800d34 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802bee:	66 90                	xchg   %ax,%ax
  802bf0:	e8 af e0 ff ff       	call   800ca4 <sys_cgetc>
  802bf5:	85 c0                	test   %eax,%eax
  802bf7:	74 f0                	je     802be9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802bf9:	85 c0                	test   %eax,%eax
  802bfb:	78 16                	js     802c13 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802bfd:	83 f8 04             	cmp    $0x4,%eax
  802c00:	74 0c                	je     802c0e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c05:	88 02                	mov    %al,(%edx)
	return 1;
  802c07:	b8 01 00 00 00       	mov    $0x1,%eax
  802c0c:	eb 05                	jmp    802c13 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802c0e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802c13:	c9                   	leave  
  802c14:	c3                   	ret    

00802c15 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802c15:	55                   	push   %ebp
  802c16:	89 e5                	mov    %esp,%ebp
  802c18:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  802c1e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802c21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802c28:	00 
  802c29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c2c:	89 04 24             	mov    %eax,(%esp)
  802c2f:	e8 52 e0 ff ff       	call   800c86 <sys_cputs>
}
  802c34:	c9                   	leave  
  802c35:	c3                   	ret    

00802c36 <getchar>:

int
getchar(void)
{
  802c36:	55                   	push   %ebp
  802c37:	89 e5                	mov    %esp,%ebp
  802c39:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802c3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802c43:	00 
  802c44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c52:	e8 43 ea ff ff       	call   80169a <read>
	if (r < 0)
  802c57:	85 c0                	test   %eax,%eax
  802c59:	78 0f                	js     802c6a <getchar+0x34>
		return r;
	if (r < 1)
  802c5b:	85 c0                	test   %eax,%eax
  802c5d:	7e 06                	jle    802c65 <getchar+0x2f>
		return -E_EOF;
	return c;
  802c5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802c63:	eb 05                	jmp    802c6a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802c65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802c6a:	c9                   	leave  
  802c6b:	c3                   	ret    

00802c6c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802c6c:	55                   	push   %ebp
  802c6d:	89 e5                	mov    %esp,%ebp
  802c6f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c79:	8b 45 08             	mov    0x8(%ebp),%eax
  802c7c:	89 04 24             	mov    %eax,(%esp)
  802c7f:	e8 82 e7 ff ff       	call   801406 <fd_lookup>
  802c84:	85 c0                	test   %eax,%eax
  802c86:	78 11                	js     802c99 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c8b:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802c91:	39 10                	cmp    %edx,(%eax)
  802c93:	0f 94 c0             	sete   %al
  802c96:	0f b6 c0             	movzbl %al,%eax
}
  802c99:	c9                   	leave  
  802c9a:	c3                   	ret    

00802c9b <opencons>:

int
opencons(void)
{
  802c9b:	55                   	push   %ebp
  802c9c:	89 e5                	mov    %esp,%ebp
  802c9e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802ca1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ca4:	89 04 24             	mov    %eax,(%esp)
  802ca7:	e8 0b e7 ff ff       	call   8013b7 <fd_alloc>
		return r;
  802cac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802cae:	85 c0                	test   %eax,%eax
  802cb0:	78 40                	js     802cf2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802cb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802cb9:	00 
  802cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cc8:	e8 86 e0 ff ff       	call   800d53 <sys_page_alloc>
		return r;
  802ccd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802ccf:	85 c0                	test   %eax,%eax
  802cd1:	78 1f                	js     802cf2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802cd3:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cdc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ce1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802ce8:	89 04 24             	mov    %eax,(%esp)
  802ceb:	e8 a0 e6 ff ff       	call   801390 <fd2num>
  802cf0:	89 c2                	mov    %eax,%edx
}
  802cf2:	89 d0                	mov    %edx,%eax
  802cf4:	c9                   	leave  
  802cf5:	c3                   	ret    

00802cf6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802cf6:	55                   	push   %ebp
  802cf7:	89 e5                	mov    %esp,%ebp
  802cf9:	53                   	push   %ebx
  802cfa:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802cfd:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802d04:	75 2f                	jne    802d35 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802d06:	e8 0a e0 ff ff       	call   800d15 <sys_getenvid>
  802d0b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802d0d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802d14:	00 
  802d15:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802d1c:	ee 
  802d1d:	89 04 24             	mov    %eax,(%esp)
  802d20:	e8 2e e0 ff ff       	call   800d53 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802d25:	c7 44 24 04 43 2d 80 	movl   $0x802d43,0x4(%esp)
  802d2c:	00 
  802d2d:	89 1c 24             	mov    %ebx,(%esp)
  802d30:	e8 be e1 ff ff       	call   800ef3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802d35:	8b 45 08             	mov    0x8(%ebp),%eax
  802d38:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802d3d:	83 c4 14             	add    $0x14,%esp
  802d40:	5b                   	pop    %ebx
  802d41:	5d                   	pop    %ebp
  802d42:	c3                   	ret    

00802d43 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802d43:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802d44:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802d49:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802d4b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802d4e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802d53:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802d57:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802d5b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802d5d:	83 c4 08             	add    $0x8,%esp
	popal
  802d60:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802d61:	83 c4 04             	add    $0x4,%esp
	popfl
  802d64:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802d65:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802d66:	c3                   	ret    
  802d67:	66 90                	xchg   %ax,%ax
  802d69:	66 90                	xchg   %ax,%ax
  802d6b:	66 90                	xchg   %ax,%ax
  802d6d:	66 90                	xchg   %ax,%ax
  802d6f:	90                   	nop

00802d70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802d70:	55                   	push   %ebp
  802d71:	89 e5                	mov    %esp,%ebp
  802d73:	56                   	push   %esi
  802d74:	53                   	push   %ebx
  802d75:	83 ec 10             	sub    $0x10,%esp
  802d78:	8b 75 08             	mov    0x8(%ebp),%esi
  802d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802d81:	85 c0                	test   %eax,%eax
  802d83:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802d88:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  802d8b:	89 04 24             	mov    %eax,(%esp)
  802d8e:	e8 d6 e1 ff ff       	call   800f69 <sys_ipc_recv>

	if(ret < 0) {
  802d93:	85 c0                	test   %eax,%eax
  802d95:	79 16                	jns    802dad <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802d97:	85 f6                	test   %esi,%esi
  802d99:	74 06                	je     802da1 <ipc_recv+0x31>
  802d9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802da1:	85 db                	test   %ebx,%ebx
  802da3:	74 3e                	je     802de3 <ipc_recv+0x73>
  802da5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802dab:	eb 36                	jmp    802de3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  802dad:	e8 63 df ff ff       	call   800d15 <sys_getenvid>
  802db2:	25 ff 03 00 00       	and    $0x3ff,%eax
  802db7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802dba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802dbf:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802dc4:	85 f6                	test   %esi,%esi
  802dc6:	74 05                	je     802dcd <ipc_recv+0x5d>
  802dc8:	8b 40 74             	mov    0x74(%eax),%eax
  802dcb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802dcd:	85 db                	test   %ebx,%ebx
  802dcf:	74 0a                	je     802ddb <ipc_recv+0x6b>
  802dd1:	a1 08 50 80 00       	mov    0x805008,%eax
  802dd6:	8b 40 78             	mov    0x78(%eax),%eax
  802dd9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802ddb:	a1 08 50 80 00       	mov    0x805008,%eax
  802de0:	8b 40 70             	mov    0x70(%eax),%eax
}
  802de3:	83 c4 10             	add    $0x10,%esp
  802de6:	5b                   	pop    %ebx
  802de7:	5e                   	pop    %esi
  802de8:	5d                   	pop    %ebp
  802de9:	c3                   	ret    

00802dea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802dea:	55                   	push   %ebp
  802deb:	89 e5                	mov    %esp,%ebp
  802ded:	57                   	push   %edi
  802dee:	56                   	push   %esi
  802def:	53                   	push   %ebx
  802df0:	83 ec 1c             	sub    $0x1c,%esp
  802df3:	8b 7d 08             	mov    0x8(%ebp),%edi
  802df6:	8b 75 0c             	mov    0xc(%ebp),%esi
  802df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  802dfc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  802dfe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802e03:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802e06:	8b 45 14             	mov    0x14(%ebp),%eax
  802e09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e11:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e15:	89 3c 24             	mov    %edi,(%esp)
  802e18:	e8 29 e1 ff ff       	call   800f46 <sys_ipc_try_send>

		if(ret >= 0) break;
  802e1d:	85 c0                	test   %eax,%eax
  802e1f:	79 2c                	jns    802e4d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802e21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e24:	74 20                	je     802e46 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802e26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e2a:	c7 44 24 08 e8 37 80 	movl   $0x8037e8,0x8(%esp)
  802e31:	00 
  802e32:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802e39:	00 
  802e3a:	c7 04 24 18 38 80 00 	movl   $0x803818,(%esp)
  802e41:	e8 d2 d3 ff ff       	call   800218 <_panic>
		}
		sys_yield();
  802e46:	e8 e9 de ff ff       	call   800d34 <sys_yield>
	}
  802e4b:	eb b9                	jmp    802e06 <ipc_send+0x1c>
}
  802e4d:	83 c4 1c             	add    $0x1c,%esp
  802e50:	5b                   	pop    %ebx
  802e51:	5e                   	pop    %esi
  802e52:	5f                   	pop    %edi
  802e53:	5d                   	pop    %ebp
  802e54:	c3                   	ret    

00802e55 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e55:	55                   	push   %ebp
  802e56:	89 e5                	mov    %esp,%ebp
  802e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802e5b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802e60:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802e63:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802e69:	8b 52 50             	mov    0x50(%edx),%edx
  802e6c:	39 ca                	cmp    %ecx,%edx
  802e6e:	75 0d                	jne    802e7d <ipc_find_env+0x28>
			return envs[i].env_id;
  802e70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e73:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802e78:	8b 40 40             	mov    0x40(%eax),%eax
  802e7b:	eb 0e                	jmp    802e8b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802e7d:	83 c0 01             	add    $0x1,%eax
  802e80:	3d 00 04 00 00       	cmp    $0x400,%eax
  802e85:	75 d9                	jne    802e60 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802e87:	66 b8 00 00          	mov    $0x0,%ax
}
  802e8b:	5d                   	pop    %ebp
  802e8c:	c3                   	ret    

00802e8d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802e8d:	55                   	push   %ebp
  802e8e:	89 e5                	mov    %esp,%ebp
  802e90:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802e93:	89 d0                	mov    %edx,%eax
  802e95:	c1 e8 16             	shr    $0x16,%eax
  802e98:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802e9f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ea4:	f6 c1 01             	test   $0x1,%cl
  802ea7:	74 1d                	je     802ec6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ea9:	c1 ea 0c             	shr    $0xc,%edx
  802eac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802eb3:	f6 c2 01             	test   $0x1,%dl
  802eb6:	74 0e                	je     802ec6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802eb8:	c1 ea 0c             	shr    $0xc,%edx
  802ebb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ec2:	ef 
  802ec3:	0f b7 c0             	movzwl %ax,%eax
}
  802ec6:	5d                   	pop    %ebp
  802ec7:	c3                   	ret    
  802ec8:	66 90                	xchg   %ax,%ax
  802eca:	66 90                	xchg   %ax,%ax
  802ecc:	66 90                	xchg   %ax,%ax
  802ece:	66 90                	xchg   %ax,%ax

00802ed0 <__udivdi3>:
  802ed0:	55                   	push   %ebp
  802ed1:	57                   	push   %edi
  802ed2:	56                   	push   %esi
  802ed3:	83 ec 0c             	sub    $0xc,%esp
  802ed6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802eda:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802ede:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802ee2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802ee6:	85 c0                	test   %eax,%eax
  802ee8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802eec:	89 ea                	mov    %ebp,%edx
  802eee:	89 0c 24             	mov    %ecx,(%esp)
  802ef1:	75 2d                	jne    802f20 <__udivdi3+0x50>
  802ef3:	39 e9                	cmp    %ebp,%ecx
  802ef5:	77 61                	ja     802f58 <__udivdi3+0x88>
  802ef7:	85 c9                	test   %ecx,%ecx
  802ef9:	89 ce                	mov    %ecx,%esi
  802efb:	75 0b                	jne    802f08 <__udivdi3+0x38>
  802efd:	b8 01 00 00 00       	mov    $0x1,%eax
  802f02:	31 d2                	xor    %edx,%edx
  802f04:	f7 f1                	div    %ecx
  802f06:	89 c6                	mov    %eax,%esi
  802f08:	31 d2                	xor    %edx,%edx
  802f0a:	89 e8                	mov    %ebp,%eax
  802f0c:	f7 f6                	div    %esi
  802f0e:	89 c5                	mov    %eax,%ebp
  802f10:	89 f8                	mov    %edi,%eax
  802f12:	f7 f6                	div    %esi
  802f14:	89 ea                	mov    %ebp,%edx
  802f16:	83 c4 0c             	add    $0xc,%esp
  802f19:	5e                   	pop    %esi
  802f1a:	5f                   	pop    %edi
  802f1b:	5d                   	pop    %ebp
  802f1c:	c3                   	ret    
  802f1d:	8d 76 00             	lea    0x0(%esi),%esi
  802f20:	39 e8                	cmp    %ebp,%eax
  802f22:	77 24                	ja     802f48 <__udivdi3+0x78>
  802f24:	0f bd e8             	bsr    %eax,%ebp
  802f27:	83 f5 1f             	xor    $0x1f,%ebp
  802f2a:	75 3c                	jne    802f68 <__udivdi3+0x98>
  802f2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802f30:	39 34 24             	cmp    %esi,(%esp)
  802f33:	0f 86 9f 00 00 00    	jbe    802fd8 <__udivdi3+0x108>
  802f39:	39 d0                	cmp    %edx,%eax
  802f3b:	0f 82 97 00 00 00    	jb     802fd8 <__udivdi3+0x108>
  802f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802f48:	31 d2                	xor    %edx,%edx
  802f4a:	31 c0                	xor    %eax,%eax
  802f4c:	83 c4 0c             	add    $0xc,%esp
  802f4f:	5e                   	pop    %esi
  802f50:	5f                   	pop    %edi
  802f51:	5d                   	pop    %ebp
  802f52:	c3                   	ret    
  802f53:	90                   	nop
  802f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f58:	89 f8                	mov    %edi,%eax
  802f5a:	f7 f1                	div    %ecx
  802f5c:	31 d2                	xor    %edx,%edx
  802f5e:	83 c4 0c             	add    $0xc,%esp
  802f61:	5e                   	pop    %esi
  802f62:	5f                   	pop    %edi
  802f63:	5d                   	pop    %ebp
  802f64:	c3                   	ret    
  802f65:	8d 76 00             	lea    0x0(%esi),%esi
  802f68:	89 e9                	mov    %ebp,%ecx
  802f6a:	8b 3c 24             	mov    (%esp),%edi
  802f6d:	d3 e0                	shl    %cl,%eax
  802f6f:	89 c6                	mov    %eax,%esi
  802f71:	b8 20 00 00 00       	mov    $0x20,%eax
  802f76:	29 e8                	sub    %ebp,%eax
  802f78:	89 c1                	mov    %eax,%ecx
  802f7a:	d3 ef                	shr    %cl,%edi
  802f7c:	89 e9                	mov    %ebp,%ecx
  802f7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802f82:	8b 3c 24             	mov    (%esp),%edi
  802f85:	09 74 24 08          	or     %esi,0x8(%esp)
  802f89:	89 d6                	mov    %edx,%esi
  802f8b:	d3 e7                	shl    %cl,%edi
  802f8d:	89 c1                	mov    %eax,%ecx
  802f8f:	89 3c 24             	mov    %edi,(%esp)
  802f92:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802f96:	d3 ee                	shr    %cl,%esi
  802f98:	89 e9                	mov    %ebp,%ecx
  802f9a:	d3 e2                	shl    %cl,%edx
  802f9c:	89 c1                	mov    %eax,%ecx
  802f9e:	d3 ef                	shr    %cl,%edi
  802fa0:	09 d7                	or     %edx,%edi
  802fa2:	89 f2                	mov    %esi,%edx
  802fa4:	89 f8                	mov    %edi,%eax
  802fa6:	f7 74 24 08          	divl   0x8(%esp)
  802faa:	89 d6                	mov    %edx,%esi
  802fac:	89 c7                	mov    %eax,%edi
  802fae:	f7 24 24             	mull   (%esp)
  802fb1:	39 d6                	cmp    %edx,%esi
  802fb3:	89 14 24             	mov    %edx,(%esp)
  802fb6:	72 30                	jb     802fe8 <__udivdi3+0x118>
  802fb8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802fbc:	89 e9                	mov    %ebp,%ecx
  802fbe:	d3 e2                	shl    %cl,%edx
  802fc0:	39 c2                	cmp    %eax,%edx
  802fc2:	73 05                	jae    802fc9 <__udivdi3+0xf9>
  802fc4:	3b 34 24             	cmp    (%esp),%esi
  802fc7:	74 1f                	je     802fe8 <__udivdi3+0x118>
  802fc9:	89 f8                	mov    %edi,%eax
  802fcb:	31 d2                	xor    %edx,%edx
  802fcd:	e9 7a ff ff ff       	jmp    802f4c <__udivdi3+0x7c>
  802fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802fd8:	31 d2                	xor    %edx,%edx
  802fda:	b8 01 00 00 00       	mov    $0x1,%eax
  802fdf:	e9 68 ff ff ff       	jmp    802f4c <__udivdi3+0x7c>
  802fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802fe8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802feb:	31 d2                	xor    %edx,%edx
  802fed:	83 c4 0c             	add    $0xc,%esp
  802ff0:	5e                   	pop    %esi
  802ff1:	5f                   	pop    %edi
  802ff2:	5d                   	pop    %ebp
  802ff3:	c3                   	ret    
  802ff4:	66 90                	xchg   %ax,%ax
  802ff6:	66 90                	xchg   %ax,%ax
  802ff8:	66 90                	xchg   %ax,%ax
  802ffa:	66 90                	xchg   %ax,%ax
  802ffc:	66 90                	xchg   %ax,%ax
  802ffe:	66 90                	xchg   %ax,%ax

00803000 <__umoddi3>:
  803000:	55                   	push   %ebp
  803001:	57                   	push   %edi
  803002:	56                   	push   %esi
  803003:	83 ec 14             	sub    $0x14,%esp
  803006:	8b 44 24 28          	mov    0x28(%esp),%eax
  80300a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80300e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803012:	89 c7                	mov    %eax,%edi
  803014:	89 44 24 04          	mov    %eax,0x4(%esp)
  803018:	8b 44 24 30          	mov    0x30(%esp),%eax
  80301c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803020:	89 34 24             	mov    %esi,(%esp)
  803023:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803027:	85 c0                	test   %eax,%eax
  803029:	89 c2                	mov    %eax,%edx
  80302b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80302f:	75 17                	jne    803048 <__umoddi3+0x48>
  803031:	39 fe                	cmp    %edi,%esi
  803033:	76 4b                	jbe    803080 <__umoddi3+0x80>
  803035:	89 c8                	mov    %ecx,%eax
  803037:	89 fa                	mov    %edi,%edx
  803039:	f7 f6                	div    %esi
  80303b:	89 d0                	mov    %edx,%eax
  80303d:	31 d2                	xor    %edx,%edx
  80303f:	83 c4 14             	add    $0x14,%esp
  803042:	5e                   	pop    %esi
  803043:	5f                   	pop    %edi
  803044:	5d                   	pop    %ebp
  803045:	c3                   	ret    
  803046:	66 90                	xchg   %ax,%ax
  803048:	39 f8                	cmp    %edi,%eax
  80304a:	77 54                	ja     8030a0 <__umoddi3+0xa0>
  80304c:	0f bd e8             	bsr    %eax,%ebp
  80304f:	83 f5 1f             	xor    $0x1f,%ebp
  803052:	75 5c                	jne    8030b0 <__umoddi3+0xb0>
  803054:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803058:	39 3c 24             	cmp    %edi,(%esp)
  80305b:	0f 87 e7 00 00 00    	ja     803148 <__umoddi3+0x148>
  803061:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803065:	29 f1                	sub    %esi,%ecx
  803067:	19 c7                	sbb    %eax,%edi
  803069:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80306d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803071:	8b 44 24 08          	mov    0x8(%esp),%eax
  803075:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803079:	83 c4 14             	add    $0x14,%esp
  80307c:	5e                   	pop    %esi
  80307d:	5f                   	pop    %edi
  80307e:	5d                   	pop    %ebp
  80307f:	c3                   	ret    
  803080:	85 f6                	test   %esi,%esi
  803082:	89 f5                	mov    %esi,%ebp
  803084:	75 0b                	jne    803091 <__umoddi3+0x91>
  803086:	b8 01 00 00 00       	mov    $0x1,%eax
  80308b:	31 d2                	xor    %edx,%edx
  80308d:	f7 f6                	div    %esi
  80308f:	89 c5                	mov    %eax,%ebp
  803091:	8b 44 24 04          	mov    0x4(%esp),%eax
  803095:	31 d2                	xor    %edx,%edx
  803097:	f7 f5                	div    %ebp
  803099:	89 c8                	mov    %ecx,%eax
  80309b:	f7 f5                	div    %ebp
  80309d:	eb 9c                	jmp    80303b <__umoddi3+0x3b>
  80309f:	90                   	nop
  8030a0:	89 c8                	mov    %ecx,%eax
  8030a2:	89 fa                	mov    %edi,%edx
  8030a4:	83 c4 14             	add    $0x14,%esp
  8030a7:	5e                   	pop    %esi
  8030a8:	5f                   	pop    %edi
  8030a9:	5d                   	pop    %ebp
  8030aa:	c3                   	ret    
  8030ab:	90                   	nop
  8030ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030b0:	8b 04 24             	mov    (%esp),%eax
  8030b3:	be 20 00 00 00       	mov    $0x20,%esi
  8030b8:	89 e9                	mov    %ebp,%ecx
  8030ba:	29 ee                	sub    %ebp,%esi
  8030bc:	d3 e2                	shl    %cl,%edx
  8030be:	89 f1                	mov    %esi,%ecx
  8030c0:	d3 e8                	shr    %cl,%eax
  8030c2:	89 e9                	mov    %ebp,%ecx
  8030c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030c8:	8b 04 24             	mov    (%esp),%eax
  8030cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8030cf:	89 fa                	mov    %edi,%edx
  8030d1:	d3 e0                	shl    %cl,%eax
  8030d3:	89 f1                	mov    %esi,%ecx
  8030d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8030d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8030dd:	d3 ea                	shr    %cl,%edx
  8030df:	89 e9                	mov    %ebp,%ecx
  8030e1:	d3 e7                	shl    %cl,%edi
  8030e3:	89 f1                	mov    %esi,%ecx
  8030e5:	d3 e8                	shr    %cl,%eax
  8030e7:	89 e9                	mov    %ebp,%ecx
  8030e9:	09 f8                	or     %edi,%eax
  8030eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8030ef:	f7 74 24 04          	divl   0x4(%esp)
  8030f3:	d3 e7                	shl    %cl,%edi
  8030f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8030f9:	89 d7                	mov    %edx,%edi
  8030fb:	f7 64 24 08          	mull   0x8(%esp)
  8030ff:	39 d7                	cmp    %edx,%edi
  803101:	89 c1                	mov    %eax,%ecx
  803103:	89 14 24             	mov    %edx,(%esp)
  803106:	72 2c                	jb     803134 <__umoddi3+0x134>
  803108:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80310c:	72 22                	jb     803130 <__umoddi3+0x130>
  80310e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803112:	29 c8                	sub    %ecx,%eax
  803114:	19 d7                	sbb    %edx,%edi
  803116:	89 e9                	mov    %ebp,%ecx
  803118:	89 fa                	mov    %edi,%edx
  80311a:	d3 e8                	shr    %cl,%eax
  80311c:	89 f1                	mov    %esi,%ecx
  80311e:	d3 e2                	shl    %cl,%edx
  803120:	89 e9                	mov    %ebp,%ecx
  803122:	d3 ef                	shr    %cl,%edi
  803124:	09 d0                	or     %edx,%eax
  803126:	89 fa                	mov    %edi,%edx
  803128:	83 c4 14             	add    $0x14,%esp
  80312b:	5e                   	pop    %esi
  80312c:	5f                   	pop    %edi
  80312d:	5d                   	pop    %ebp
  80312e:	c3                   	ret    
  80312f:	90                   	nop
  803130:	39 d7                	cmp    %edx,%edi
  803132:	75 da                	jne    80310e <__umoddi3+0x10e>
  803134:	8b 14 24             	mov    (%esp),%edx
  803137:	89 c1                	mov    %eax,%ecx
  803139:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80313d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803141:	eb cb                	jmp    80310e <__umoddi3+0x10e>
  803143:	90                   	nop
  803144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803148:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80314c:	0f 82 0f ff ff ff    	jb     803061 <__umoddi3+0x61>
  803152:	e9 1a ff ff ff       	jmp    803071 <__umoddi3+0x71>
