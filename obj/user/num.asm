
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 95 01 00 00       	call   8001c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 30             	sub    $0x30,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	e9 84 00 00 00       	jmp    8000ca <num+0x97>
		if (bol) {
  800046:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004d:	74 27                	je     800076 <num+0x43>
			printf("%5d ", ++line);
  80004f:	a1 00 40 80 00       	mov    0x804000,%eax
  800054:	83 c0 01             	add    $0x1,%eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800067:	e8 b7 19 00 00       	call   801a23 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 e9 13 00 00       	call   801477 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 27                	je     8000ba <num+0x87>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009e:	c7 44 24 08 85 28 80 	movl   $0x802885,0x8(%esp)
  8000a5:	00 
  8000a6:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000ad:	00 
  8000ae:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  8000b5:	e8 6d 01 00 00       	call   800227 <_panic>
		if (c == '\n')
  8000ba:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000be:	75 0a                	jne    8000ca <num+0x97>
			bol = 1;
  8000c0:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c7:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d1:	00 
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	89 34 24             	mov    %esi,(%esp)
  8000d9:	e8 bc 12 00 00       	call   80139a <read>
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 8f 60 ff ff ff    	jg     800046 <num+0x13>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	79 27                	jns    800111 <num+0xde>
		panic("error reading %s: %e", s, n);
  8000ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f5:	c7 44 24 08 ab 28 80 	movl   $0x8028ab,0x8(%esp)
  8000fc:	00 
  8000fd:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  800104:	00 
  800105:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  80010c:	e8 16 01 00 00       	call   800227 <_panic>
}
  800111:	83 c4 30             	add    $0x30,%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <umain>:

void
umain(int argc, char **argv)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 2c             	sub    $0x2c,%esp
	int f, i;

	binaryname = "num";
  800121:	c7 05 04 30 80 00 c0 	movl   $0x8028c0,0x803004
  800128:	28 80 00 
	if (argc == 1)
  80012b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012f:	74 0d                	je     80013e <umain+0x26>
  800131:	8b 45 0c             	mov    0xc(%ebp),%eax
  800134:	8d 58 04             	lea    0x4(%eax),%ebx
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
  80013c:	eb 76                	jmp    8001b4 <umain+0x9c>
		num(0, "<stdin>");
  80013e:	c7 44 24 04 c4 28 80 	movl   $0x8028c4,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 e1 fe ff ff       	call   800033 <num>
  800152:	eb 65                	jmp    8001b9 <umain+0xa1>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800154:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800157:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80015e:	00 
  80015f:	8b 03                	mov    (%ebx),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 0a 17 00 00       	call   801873 <open>
  800169:	89 c6                	mov    %eax,%esi
			if (f < 0)
  80016b:	85 c0                	test   %eax,%eax
  80016d:	79 29                	jns    800198 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800176:	8b 00                	mov    (%eax),%eax
  800178:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017c:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80018b:	00 
  80018c:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  800193:	e8 8f 00 00 00       	call   800227 <_panic>
			else {
				num(f, argv[i]);
  800198:	8b 03                	mov    (%ebx),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	89 34 24             	mov    %esi,(%esp)
  8001a1:	e8 8d fe ff ff       	call   800033 <num>
				close(f);
  8001a6:	89 34 24             	mov    %esi,(%esp)
  8001a9:	e8 89 10 00 00       	call   801237 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001ae:	83 c7 01             	add    $0x1,%edi
  8001b1:	83 c3 04             	add    $0x4,%ebx
  8001b4:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b7:	7c 9b                	jl     800154 <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b9:	e8 50 00 00 00       	call   80020e <exit>
}
  8001be:	83 c4 2c             	add    $0x2c,%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 10             	sub    $0x10,%esp
  8001ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d4:	e8 4c 0b 00 00       	call   800d25 <sys_getenvid>
  8001d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e6:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	7e 07                	jle    8001f6 <libmain+0x30>
		binaryname = argv[0];
  8001ef:	8b 06                	mov    (%esi),%eax
  8001f1:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fa:	89 1c 24             	mov    %ebx,(%esp)
  8001fd:	e8 16 ff ff ff       	call   800118 <umain>

	// exit gracefully
	exit();
  800202:	e8 07 00 00 00       	call   80020e <exit>
}
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800214:	e8 51 10 00 00       	call   80126a <close_all>
	sys_env_destroy(0);
  800219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800220:	e8 ae 0a 00 00       	call   800cd3 <sys_env_destroy>
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80022f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800232:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800238:	e8 e8 0a 00 00       	call   800d25 <sys_getenvid>
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 54 24 10          	mov    %edx,0x10(%esp)
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	c7 04 24 e8 28 80 00 	movl   $0x8028e8,(%esp)
  80025a:	e8 c1 00 00 00       	call   800320 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 51 00 00 00       	call   8002bf <vcprintf>
	cprintf("\n");
  80026e:	c7 04 24 40 2d 80 00 	movl   $0x802d40,(%esp)
  800275:	e8 a6 00 00 00       	call   800320 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027a:	cc                   	int3   
  80027b:	eb fd                	jmp    80027a <_panic+0x53>

0080027d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	53                   	push   %ebx
  800281:	83 ec 14             	sub    $0x14,%esp
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800287:	8b 13                	mov    (%ebx),%edx
  800289:	8d 42 01             	lea    0x1(%edx),%eax
  80028c:	89 03                	mov    %eax,(%ebx)
  80028e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800291:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800295:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029a:	75 19                	jne    8002b5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80029c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a3:	00 
  8002a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 e7 09 00 00       	call   800c96 <sys_cputs>
		b->idx = 0;
  8002af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cf:	00 00 00 
	b.cnt = 0;
  8002d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f4:	c7 04 24 7d 02 80 00 	movl   $0x80027d,(%esp)
  8002fb:	e8 ae 01 00 00       	call   8004ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 7e 09 00 00       	call   800c96 <sys_cputs>

	return b.cnt;
}
  800318:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800326:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 87 ff ff ff       	call   8002bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    
  80033a:	66 90                	xchg   %ax,%ax
  80033c:	66 90                	xchg   %ax,%ax
  80033e:	66 90                	xchg   %ax,%ax

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 c3                	mov    %eax,%ebx
  800359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80036d:	39 d9                	cmp    %ebx,%ecx
  80036f:	72 05                	jb     800376 <printnum+0x36>
  800371:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800374:	77 69                	ja     8003df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800376:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800379:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80037d:	83 ee 01             	sub    $0x1,%esi
  800380:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800384:	89 44 24 08          	mov    %eax,0x8(%esp)
  800388:	8b 44 24 08          	mov    0x8(%esp),%eax
  80038c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800390:	89 c3                	mov    %eax,%ebx
  800392:	89 d6                	mov    %edx,%esi
  800394:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800397:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80039a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80039e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 3c 22 00 00       	call   8025f0 <__udivdi3>
  8003b4:	89 d9                	mov    %ebx,%ecx
  8003b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c5:	89 fa                	mov    %edi,%edx
  8003c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ca:	e8 71 ff ff ff       	call   800340 <printnum>
  8003cf:	eb 1b                	jmp    8003ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff d3                	call   *%ebx
  8003dd:	eb 03                	jmp    8003e2 <printnum+0xa2>
  8003df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e2:	83 ee 01             	sub    $0x1,%esi
  8003e5:	85 f6                	test   %esi,%esi
  8003e7:	7f e8                	jg     8003d1 <printnum+0x91>
  8003e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040f:	e8 0c 23 00 00       	call   802720 <__umoddi3>
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	0f be 80 0b 29 80 00 	movsbl 0x80290b(%eax),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800425:	ff d0                	call   *%eax
}
  800427:	83 c4 3c             	add    $0x3c,%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800432:	83 fa 01             	cmp    $0x1,%edx
  800435:	7e 0e                	jle    800445 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	8b 52 04             	mov    0x4(%edx),%edx
  800443:	eb 22                	jmp    800467 <getuint+0x38>
	else if (lflag)
  800445:	85 d2                	test   %edx,%edx
  800447:	74 10                	je     800459 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb 0e                	jmp    800467 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800473:	8b 10                	mov    (%eax),%edx
  800475:	3b 50 04             	cmp    0x4(%eax),%edx
  800478:	73 0a                	jae    800484 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	88 02                	mov    %al,(%edx)
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80048c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800493:	8b 45 10             	mov    0x10(%ebp),%eax
  800496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 02 00 00 00       	call   8004ae <vprintfmt>
	va_end(ap);
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	57                   	push   %edi
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 3c             	sub    $0x3c,%esp
  8004b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004bd:	eb 14                	jmp    8004d3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	0f 84 b3 03 00 00    	je     80087a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cb:	89 04 24             	mov    %eax,(%esp)
  8004ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d1:	89 f3                	mov    %esi,%ebx
  8004d3:	8d 73 01             	lea    0x1(%ebx),%esi
  8004d6:	0f b6 03             	movzbl (%ebx),%eax
  8004d9:	83 f8 25             	cmp    $0x25,%eax
  8004dc:	75 e1                	jne    8004bf <vprintfmt+0x11>
  8004de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004e9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004f0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fc:	eb 1d                	jmp    80051b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800500:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800504:	eb 15                	jmp    80051b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800508:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80050c:	eb 0d                	jmp    80051b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80050e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800511:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800514:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80051e:	0f b6 0e             	movzbl (%esi),%ecx
  800521:	0f b6 c1             	movzbl %cl,%eax
  800524:	83 e9 23             	sub    $0x23,%ecx
  800527:	80 f9 55             	cmp    $0x55,%cl
  80052a:	0f 87 2a 03 00 00    	ja     80085a <vprintfmt+0x3ac>
  800530:	0f b6 c9             	movzbl %cl,%ecx
  800533:	ff 24 8d 40 2a 80 00 	jmp    *0x802a40(,%ecx,4)
  80053a:	89 de                	mov    %ebx,%esi
  80053c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800541:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800544:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800548:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80054b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80054e:	83 fb 09             	cmp    $0x9,%ebx
  800551:	77 36                	ja     800589 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800553:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800556:	eb e9                	jmp    800541 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 48 04             	lea    0x4(%eax),%ecx
  80055e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800568:	eb 22                	jmp    80058c <vprintfmt+0xde>
  80056a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	0f 49 c1             	cmovns %ecx,%eax
  800577:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	89 de                	mov    %ebx,%esi
  80057c:	eb 9d                	jmp    80051b <vprintfmt+0x6d>
  80057e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800580:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800587:	eb 92                	jmp    80051b <vprintfmt+0x6d>
  800589:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80058c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800590:	79 89                	jns    80051b <vprintfmt+0x6d>
  800592:	e9 77 ff ff ff       	jmp    80050e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800597:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80059c:	e9 7a ff ff ff       	jmp    80051b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005b6:	e9 18 ff ff ff       	jmp    8004d3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	99                   	cltd   
  8005c7:	31 d0                	xor    %edx,%eax
  8005c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005cb:	83 f8 0f             	cmp    $0xf,%eax
  8005ce:	7f 0b                	jg     8005db <vprintfmt+0x12d>
  8005d0:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  8005d7:	85 d2                	test   %edx,%edx
  8005d9:	75 20                	jne    8005fb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005df:	c7 44 24 08 23 29 80 	movl   $0x802923,0x8(%esp)
  8005e6:	00 
  8005e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	e8 90 fe ff ff       	call   800486 <printfmt>
  8005f6:	e9 d8 fe ff ff       	jmp    8004d3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ff:	c7 44 24 08 d5 2c 80 	movl   $0x802cd5,0x8(%esp)
  800606:	00 
  800607:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	e8 70 fe ff ff       	call   800486 <printfmt>
  800616:	e9 b8 fe ff ff       	jmp    8004d3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80061e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800621:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80062f:	85 f6                	test   %esi,%esi
  800631:	b8 1c 29 80 00       	mov    $0x80291c,%eax
  800636:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800639:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80063d:	0f 84 97 00 00 00    	je     8006da <vprintfmt+0x22c>
  800643:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800647:	0f 8e 9b 00 00 00    	jle    8006e8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80064d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800651:	89 34 24             	mov    %esi,(%esp)
  800654:	e8 cf 02 00 00       	call   800928 <strnlen>
  800659:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80065c:	29 c2                	sub    %eax,%edx
  80065e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800661:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800665:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800668:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80066b:	8b 75 08             	mov    0x8(%ebp),%esi
  80066e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800671:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800673:	eb 0f                	jmp    800684 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800675:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800679:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800681:	83 eb 01             	sub    $0x1,%ebx
  800684:	85 db                	test   %ebx,%ebx
  800686:	7f ed                	jg     800675 <vprintfmt+0x1c7>
  800688:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80068b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80068e:	85 d2                	test   %edx,%edx
  800690:	b8 00 00 00 00       	mov    $0x0,%eax
  800695:	0f 49 c2             	cmovns %edx,%eax
  800698:	29 c2                	sub    %eax,%edx
  80069a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80069d:	89 d7                	mov    %edx,%edi
  80069f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006a2:	eb 50                	jmp    8006f4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a8:	74 1e                	je     8006c8 <vprintfmt+0x21a>
  8006aa:	0f be d2             	movsbl %dl,%edx
  8006ad:	83 ea 20             	sub    $0x20,%edx
  8006b0:	83 fa 5e             	cmp    $0x5e,%edx
  8006b3:	76 13                	jbe    8006c8 <vprintfmt+0x21a>
					putch('?', putdat);
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
  8006c6:	eb 0d                	jmp    8006d5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d5:	83 ef 01             	sub    $0x1,%edi
  8006d8:	eb 1a                	jmp    8006f4 <vprintfmt+0x246>
  8006da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006dd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006e0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e6:	eb 0c                	jmp    8006f4 <vprintfmt+0x246>
  8006e8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f4:	83 c6 01             	add    $0x1,%esi
  8006f7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8006fb:	0f be c2             	movsbl %dl,%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 27                	je     800729 <vprintfmt+0x27b>
  800702:	85 db                	test   %ebx,%ebx
  800704:	78 9e                	js     8006a4 <vprintfmt+0x1f6>
  800706:	83 eb 01             	sub    $0x1,%ebx
  800709:	79 99                	jns    8006a4 <vprintfmt+0x1f6>
  80070b:	89 f8                	mov    %edi,%eax
  80070d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800710:	8b 75 08             	mov    0x8(%ebp),%esi
  800713:	89 c3                	mov    %eax,%ebx
  800715:	eb 1a                	jmp    800731 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800717:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800722:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800724:	83 eb 01             	sub    $0x1,%ebx
  800727:	eb 08                	jmp    800731 <vprintfmt+0x283>
  800729:	89 fb                	mov    %edi,%ebx
  80072b:	8b 75 08             	mov    0x8(%ebp),%esi
  80072e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800731:	85 db                	test   %ebx,%ebx
  800733:	7f e2                	jg     800717 <vprintfmt+0x269>
  800735:	89 75 08             	mov    %esi,0x8(%ebp)
  800738:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80073b:	e9 93 fd ff ff       	jmp    8004d3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800740:	83 fa 01             	cmp    $0x1,%edx
  800743:	7e 16                	jle    80075b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8d 50 08             	lea    0x8(%eax),%edx
  80074b:	89 55 14             	mov    %edx,0x14(%ebp)
  80074e:	8b 50 04             	mov    0x4(%eax),%edx
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800756:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800759:	eb 32                	jmp    80078d <vprintfmt+0x2df>
	else if (lflag)
  80075b:	85 d2                	test   %edx,%edx
  80075d:	74 18                	je     800777 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 30                	mov    (%eax),%esi
  80076a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80076d:	89 f0                	mov    %esi,%eax
  80076f:	c1 f8 1f             	sar    $0x1f,%eax
  800772:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800775:	eb 16                	jmp    80078d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)
  800780:	8b 30                	mov    (%eax),%esi
  800782:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800785:	89 f0                	mov    %esi,%eax
  800787:	c1 f8 1f             	sar    $0x1f,%eax
  80078a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80078d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800790:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800793:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800798:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079c:	0f 89 80 00 00 00    	jns    800822 <vprintfmt+0x374>
				putch('-', putdat);
  8007a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ad:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b6:	f7 d8                	neg    %eax
  8007b8:	83 d2 00             	adc    $0x0,%edx
  8007bb:	f7 da                	neg    %edx
			}
			base = 10;
  8007bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007c2:	eb 5e                	jmp    800822 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c7:	e8 63 fc ff ff       	call   80042f <getuint>
			base = 10;
  8007cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007d1:	eb 4f                	jmp    800822 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	e8 54 fc ff ff       	call   80042f <getuint>
			base = 8;
  8007db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007e0:	eb 40                	jmp    800822 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8007e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800807:	8b 00                	mov    (%eax),%eax
  800809:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800813:	eb 0d                	jmp    800822 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800815:	8d 45 14             	lea    0x14(%ebp),%eax
  800818:	e8 12 fc ff ff       	call   80042f <getuint>
			base = 16;
  80081d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800822:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800826:	89 74 24 10          	mov    %esi,0x10(%esp)
  80082a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80082d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800831:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083c:	89 fa                	mov    %edi,%edx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	e8 fa fa ff ff       	call   800340 <printnum>
			break;
  800846:	e9 88 fc ff ff       	jmp    8004d3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
			break;
  800855:	e9 79 fc ff ff       	jmp    8004d3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	89 f3                	mov    %esi,%ebx
  80086a:	eb 03                	jmp    80086f <vprintfmt+0x3c1>
  80086c:	83 eb 01             	sub    $0x1,%ebx
  80086f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800873:	75 f7                	jne    80086c <vprintfmt+0x3be>
  800875:	e9 59 fc ff ff       	jmp    8004d3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80087a:	83 c4 3c             	add    $0x3c,%esp
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5f                   	pop    %edi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	83 ec 28             	sub    $0x28,%esp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800891:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800895:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800898:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	74 30                	je     8008d3 <vsnprintf+0x51>
  8008a3:	85 d2                	test   %edx,%edx
  8008a5:	7e 2c                	jle    8008d3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	c7 04 24 69 04 80 00 	movl   $0x800469,(%esp)
  8008c3:	e8 e6 fb ff ff       	call   8004ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d1:	eb 05                	jmp    8008d8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	e8 82 ff ff ff       	call   800882 <vsnprintf>
	va_end(ap);

	return rc;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    
  800902:	66 90                	xchg   %ax,%ax
  800904:	66 90                	xchg   %ax,%ax
  800906:	66 90                	xchg   %ax,%ax
  800908:	66 90                	xchg   %ax,%ax
  80090a:	66 90                	xchg   %ax,%ax
  80090c:	66 90                	xchg   %ax,%ax
  80090e:	66 90                	xchg   %ax,%ax

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strlen+0x10>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800920:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800924:	75 f7                	jne    80091d <strlen+0xd>
		n++;
	return n;
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	eb 03                	jmp    80093b <strnlen+0x13>
		n++;
  800938:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	74 06                	je     800945 <strnlen+0x1d>
  80093f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800943:	75 f3                	jne    800938 <strnlen+0x10>
		n++;
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800951:	89 c2                	mov    %eax,%edx
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800960:	84 db                	test   %bl,%bl
  800962:	75 ef                	jne    800953 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	89 1c 24             	mov    %ebx,(%esp)
  800974:	e8 97 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800980:	01 d8                	add    %ebx,%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 bd ff ff ff       	call   800947 <strcpy>
	return dst;
}
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	83 c4 08             	add    $0x8,%esp
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 75 08             	mov    0x8(%ebp),%esi
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099d:	89 f3                	mov    %esi,%ebx
  80099f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a2:	89 f2                	mov    %esi,%edx
  8009a4:	eb 0f                	jmp    8009b5 <strncpy+0x23>
		*dst++ = *src;
  8009a6:	83 c2 01             	add    $0x1,%edx
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009af:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b5:	39 da                	cmp    %ebx,%edx
  8009b7:	75 ed                	jne    8009a6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009cd:	89 f0                	mov    %esi,%eax
  8009cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	75 0b                	jne    8009e2 <strlcpy+0x23>
  8009d7:	eb 1d                	jmp    8009f6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e2:	39 d8                	cmp    %ebx,%eax
  8009e4:	74 0b                	je     8009f1 <strlcpy+0x32>
  8009e6:	0f b6 0a             	movzbl (%edx),%ecx
  8009e9:	84 c9                	test   %cl,%cl
  8009eb:	75 ec                	jne    8009d9 <strlcpy+0x1a>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	eb 02                	jmp    8009f3 <strlcpy+0x34>
  8009f1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009f3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f6:	29 f0                	sub    %esi,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a05:	eb 06                	jmp    800a0d <strcmp+0x11>
		p++, q++;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	84 c0                	test   %al,%al
  800a12:	74 04                	je     800a18 <strcmp+0x1c>
  800a14:	3a 02                	cmp    (%edx),%al
  800a16:	74 ef                	je     800a07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 c0             	movzbl %al,%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a31:	eb 06                	jmp    800a39 <strncmp+0x17>
		n--, p++, q++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a39:	39 d8                	cmp    %ebx,%eax
  800a3b:	74 15                	je     800a52 <strncmp+0x30>
  800a3d:	0f b6 08             	movzbl (%eax),%ecx
  800a40:	84 c9                	test   %cl,%cl
  800a42:	74 04                	je     800a48 <strncmp+0x26>
  800a44:	3a 0a                	cmp    (%edx),%cl
  800a46:	74 eb                	je     800a33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
  800a50:	eb 05                	jmp    800a57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a64:	eb 07                	jmp    800a6d <strchr+0x13>
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	74 0f                	je     800a79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f2                	jne    800a66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	eb 07                	jmp    800a8e <strfind+0x13>
		if (*s == c)
  800a87:	38 ca                	cmp    %cl,%dl
  800a89:	74 0a                	je     800a95 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	84 d2                	test   %dl,%dl
  800a93:	75 f2                	jne    800a87 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa3:	85 c9                	test   %ecx,%ecx
  800aa5:	74 36                	je     800add <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aad:	75 28                	jne    800ad7 <memset+0x40>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 23                	jne    800ad7 <memset+0x40>
		c &= 0xFF;
  800ab4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	c1 e3 08             	shl    $0x8,%ebx
  800abd:	89 d6                	mov    %edx,%esi
  800abf:	c1 e6 18             	shl    $0x18,%esi
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	c1 e0 10             	shl    $0x10,%eax
  800ac7:	09 f0                	or     %esi,%eax
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	89 d0                	mov    %edx,%eax
  800acd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad2:	fc                   	cld    
  800ad3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad5:	eb 06                	jmp    800add <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	fc                   	cld    
  800adb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800add:	89 f8                	mov    %edi,%eax
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af2:	39 c6                	cmp    %eax,%esi
  800af4:	73 35                	jae    800b2b <memmove+0x47>
  800af6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af9:	39 d0                	cmp    %edx,%eax
  800afb:	73 2e                	jae    800b2b <memmove+0x47>
		s += n;
		d += n;
  800afd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0a:	75 13                	jne    800b1f <memmove+0x3b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 0e                	jne    800b1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 09                	jmp    800b28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1f:	83 ef 01             	sub    $0x1,%edi
  800b22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b25:	fd                   	std    
  800b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b28:	fc                   	cld    
  800b29:	eb 1d                	jmp    800b48 <memmove+0x64>
  800b2b:	89 f2                	mov    %esi,%edx
  800b2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	f6 c2 03             	test   $0x3,%dl
  800b32:	75 0f                	jne    800b43 <memmove+0x5f>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0a                	jne    800b43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b39:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b3c:	89 c7                	mov    %eax,%edi
  800b3e:	fc                   	cld    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b41:	eb 05                	jmp    800b48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	fc                   	cld    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 79 ff ff ff       	call   800ae4 <memmove>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7d:	eb 1a                	jmp    800b99 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7f:	0f b6 02             	movzbl (%edx),%eax
  800b82:	0f b6 19             	movzbl (%ecx),%ebx
  800b85:	38 d8                	cmp    %bl,%al
  800b87:	74 0a                	je     800b93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b89:	0f b6 c0             	movzbl %al,%eax
  800b8c:	0f b6 db             	movzbl %bl,%ebx
  800b8f:	29 d8                	sub    %ebx,%eax
  800b91:	eb 0f                	jmp    800ba2 <memcmp+0x35>
		s1++, s2++;
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b99:	39 f2                	cmp    %esi,%edx
  800b9b:	75 e2                	jne    800b7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb4:	eb 07                	jmp    800bbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb6:	38 08                	cmp    %cl,(%eax)
  800bb8:	74 07                	je     800bc1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	72 f5                	jb     800bb6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcf:	eb 03                	jmp    800bd4 <strtol+0x11>
		s++;
  800bd1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd4:	0f b6 0a             	movzbl (%edx),%ecx
  800bd7:	80 f9 09             	cmp    $0x9,%cl
  800bda:	74 f5                	je     800bd1 <strtol+0xe>
  800bdc:	80 f9 20             	cmp    $0x20,%cl
  800bdf:	74 f0                	je     800bd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be1:	80 f9 2b             	cmp    $0x2b,%cl
  800be4:	75 0a                	jne    800bf0 <strtol+0x2d>
		s++;
  800be6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bee:	eb 11                	jmp    800c01 <strtol+0x3e>
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf5:	80 f9 2d             	cmp    $0x2d,%cl
  800bf8:	75 07                	jne    800c01 <strtol+0x3e>
		s++, neg = 1;
  800bfa:	8d 52 01             	lea    0x1(%edx),%edx
  800bfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c06:	75 15                	jne    800c1d <strtol+0x5a>
  800c08:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0b:	75 10                	jne    800c1d <strtol+0x5a>
  800c0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c11:	75 0a                	jne    800c1d <strtol+0x5a>
		s += 2, base = 16;
  800c13:	83 c2 02             	add    $0x2,%edx
  800c16:	b8 10 00 00 00       	mov    $0x10,%eax
  800c1b:	eb 10                	jmp    800c2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	75 0c                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c21:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c23:	80 3a 30             	cmpb   $0x30,(%edx)
  800c26:	75 05                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
  800c28:	83 c2 01             	add    $0x1,%edx
  800c2b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c35:	0f b6 0a             	movzbl (%edx),%ecx
  800c38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	3c 09                	cmp    $0x9,%al
  800c3f:	77 08                	ja     800c49 <strtol+0x86>
			dig = *s - '0';
  800c41:	0f be c9             	movsbl %cl,%ecx
  800c44:	83 e9 30             	sub    $0x30,%ecx
  800c47:	eb 20                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c4c:	89 f0                	mov    %esi,%eax
  800c4e:	3c 19                	cmp    $0x19,%al
  800c50:	77 08                	ja     800c5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c52:	0f be c9             	movsbl %cl,%ecx
  800c55:	83 e9 57             	sub    $0x57,%ecx
  800c58:	eb 0f                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	3c 19                	cmp    $0x19,%al
  800c61:	77 16                	ja     800c79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c63:	0f be c9             	movsbl %cl,%ecx
  800c66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c6c:	7d 0f                	jge    800c7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c77:	eb bc                	jmp    800c35 <strtol+0x72>
  800c79:	89 d8                	mov    %ebx,%eax
  800c7b:	eb 02                	jmp    800c7f <strtol+0xbc>
  800c7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c83:	74 05                	je     800c8a <strtol+0xc7>
		*endptr = (char *) s;
  800c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c8a:	f7 d8                	neg    %eax
  800c8c:	85 ff                	test   %edi,%edi
  800c8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	89 c7                	mov    %eax,%edi
  800cab:	89 c6                	mov    %eax,%esi
  800cad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 d7                	mov    %edx,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	89 cb                	mov    %ecx,%ebx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	89 ce                	mov    %ecx,%esi
  800cef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 28                	jle    800d1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d00:	00 
  800d01:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800d08:	00 
  800d09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d10:	00 
  800d11:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800d18:	e8 0a f5 ff ff       	call   800227 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1d:	83 c4 2c             	add    $0x2c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 02 00 00 00       	mov    $0x2,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_yield>:

void
sys_yield(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	b8 04 00 00 00       	mov    $0x4,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	89 f7                	mov    %esi,%edi
  800d81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800daa:	e8 78 f4 ff ff       	call   800227 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800dfd:	e8 25 f4 ff ff       	call   800227 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800e50:	e8 d2 f3 ff ff       	call   800227 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800ea3:	e8 7f f3 ff ff       	call   800227 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea8:	83 c4 2c             	add    $0x2c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebe:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 df                	mov    %ebx,%edi
  800ecb:	89 de                	mov    %ebx,%esi
  800ecd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	7e 28                	jle    800efb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eee:	00 
  800eef:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800ef6:	e8 2c f3 ff ff       	call   800227 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800efb:	83 c4 2c             	add    $0x2c,%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800f49:	e8 d9 f2 ff ff       	call   800227 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f4e:	83 c4 2c             	add    $0x2c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	be 00 00 00 00       	mov    $0x0,%esi
  800f61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8f:	89 cb                	mov    %ecx,%ebx
  800f91:	89 cf                	mov    %ecx,%edi
  800f93:	89 ce                	mov    %ecx,%esi
  800f95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	7e 28                	jle    800fc3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fa6:	00 
  800fa7:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800fae:	00 
  800faf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb6:	00 
  800fb7:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800fbe:	e8 64 f2 ff ff       	call   800227 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc3:	83 c4 2c             	add    $0x2c,%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fdb:	89 d1                	mov    %edx,%ecx
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	89 d6                	mov    %edx,%esi
  800fe3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 28                	jle    801035 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801011:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801018:	00 
  801019:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  801030:	e8 f2 f1 ff ff       	call   800227 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801035:	83 c4 2c             	add    $0x2c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
  801043:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	b8 10 00 00 00       	mov    $0x10,%eax
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	89 df                	mov    %ebx,%edi
  801058:	89 de                	mov    %ebx,%esi
  80105a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	7e 28                	jle    801088 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801060:	89 44 24 10          	mov    %eax,0x10(%esp)
  801064:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80106b:	00 
  80106c:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  801073:	00 
  801074:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  801083:	e8 9f f1 ff ff       	call   800227 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801088:	83 c4 2c             	add    $0x2c,%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	c1 ea 16             	shr    $0x16,%edx
  8010c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ce:	f6 c2 01             	test   $0x1,%dl
  8010d1:	74 11                	je     8010e4 <fd_alloc+0x2d>
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	75 09                	jne    8010ed <fd_alloc+0x36>
			*fd_store = fd;
  8010e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	eb 17                	jmp    801104 <fd_alloc+0x4d>
  8010ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f7:	75 c9                	jne    8010c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110c:	83 f8 1f             	cmp    $0x1f,%eax
  80110f:	77 36                	ja     801147 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801111:	c1 e0 0c             	shl    $0xc,%eax
  801114:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 16             	shr    $0x16,%edx
  80111e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 24                	je     80114e <fd_lookup+0x48>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 0c             	shr    $0xc,%edx
  80112f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 1a                	je     801155 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 02                	mov    %eax,(%edx)
	return 0;
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 13                	jmp    80115a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 0c                	jmp    80115a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801153:	eb 05                	jmp    80115a <fd_lookup+0x54>
  801155:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 18             	sub    $0x18,%esp
  801162:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801165:	ba 00 00 00 00       	mov    $0x0,%edx
  80116a:	eb 13                	jmp    80117f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80116c:	39 08                	cmp    %ecx,(%eax)
  80116e:	75 0c                	jne    80117c <dev_lookup+0x20>
			*dev = devtab[i];
  801170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801173:	89 01                	mov    %eax,(%ecx)
			return 0;
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
  80117a:	eb 38                	jmp    8011b4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117c:	83 c2 01             	add    $0x1,%edx
  80117f:	8b 04 95 a8 2c 80 00 	mov    0x802ca8(,%edx,4),%eax
  801186:	85 c0                	test   %eax,%eax
  801188:	75 e2                	jne    80116c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80118a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80118f:	8b 40 48             	mov    0x48(%eax),%eax
  801192:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119a:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  8011a1:	e8 7a f1 ff ff       	call   800320 <cprintf>
	*dev = 0;
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 20             	sub    $0x20,%esp
  8011be:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d4:	89 04 24             	mov    %eax,(%esp)
  8011d7:	e8 2a ff ff ff       	call   801106 <fd_lookup>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 05                	js     8011e5 <fd_close+0x2f>
	    || fd != fd2)
  8011e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e3:	74 0c                	je     8011f1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011e5:	84 db                	test   %bl,%bl
  8011e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ec:	0f 44 c2             	cmove  %edx,%eax
  8011ef:	eb 3f                	jmp    801230 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f8:	8b 06                	mov    (%esi),%eax
  8011fa:	89 04 24             	mov    %eax,(%esp)
  8011fd:	e8 5a ff ff ff       	call   80115c <dev_lookup>
  801202:	89 c3                	mov    %eax,%ebx
  801204:	85 c0                	test   %eax,%eax
  801206:	78 16                	js     80121e <fd_close+0x68>
		if (dev->dev_close)
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80120e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801213:	85 c0                	test   %eax,%eax
  801215:	74 07                	je     80121e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801217:	89 34 24             	mov    %esi,(%esp)
  80121a:	ff d0                	call   *%eax
  80121c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80121e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801229:	e8 dc fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80122e:	89 d8                	mov    %ebx,%eax
}
  801230:	83 c4 20             	add    $0x20,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	89 44 24 04          	mov    %eax,0x4(%esp)
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 b7 fe ff ff       	call   801106 <fd_lookup>
  80124f:	89 c2                	mov    %eax,%edx
  801251:	85 d2                	test   %edx,%edx
  801253:	78 13                	js     801268 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801255:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80125c:	00 
  80125d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801260:	89 04 24             	mov    %eax,(%esp)
  801263:	e8 4e ff ff ff       	call   8011b6 <fd_close>
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <close_all>:

void
close_all(void)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801276:	89 1c 24             	mov    %ebx,(%esp)
  801279:	e8 b9 ff ff ff       	call   801237 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80127e:	83 c3 01             	add    $0x1,%ebx
  801281:	83 fb 20             	cmp    $0x20,%ebx
  801284:	75 f0                	jne    801276 <close_all+0xc>
		close(i);
}
  801286:	83 c4 14             	add    $0x14,%esp
  801289:	5b                   	pop    %ebx
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801295:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	89 04 24             	mov    %eax,(%esp)
  8012a2:	e8 5f fe ff ff       	call   801106 <fd_lookup>
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	85 d2                	test   %edx,%edx
  8012ab:	0f 88 e1 00 00 00    	js     801392 <dup+0x106>
		return r;
	close(newfdnum);
  8012b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b4:	89 04 24             	mov    %eax,(%esp)
  8012b7:	e8 7b ff ff ff       	call   801237 <close>

	newfd = INDEX2FD(newfdnum);
  8012bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012bf:	c1 e3 0c             	shl    $0xc,%ebx
  8012c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cb:	89 04 24             	mov    %eax,(%esp)
  8012ce:	e8 cd fd ff ff       	call   8010a0 <fd2data>
  8012d3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012d5:	89 1c 24             	mov    %ebx,(%esp)
  8012d8:	e8 c3 fd ff ff       	call   8010a0 <fd2data>
  8012dd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012df:	89 f0                	mov    %esi,%eax
  8012e1:	c1 e8 16             	shr    $0x16,%eax
  8012e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012eb:	a8 01                	test   $0x1,%al
  8012ed:	74 43                	je     801332 <dup+0xa6>
  8012ef:	89 f0                	mov    %esi,%eax
  8012f1:	c1 e8 0c             	shr    $0xc,%eax
  8012f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 32                	je     801332 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801300:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801307:	25 07 0e 00 00       	and    $0xe07,%eax
  80130c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801310:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801314:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80131b:	00 
  80131c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801327:	e8 8b fa ff ff       	call   800db7 <sys_page_map>
  80132c:	89 c6                	mov    %eax,%esi
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 3e                	js     801370 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801335:	89 c2                	mov    %eax,%edx
  801337:	c1 ea 0c             	shr    $0xc,%edx
  80133a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801341:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801347:	89 54 24 10          	mov    %edx,0x10(%esp)
  80134b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80134f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801356:	00 
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801362:	e8 50 fa ff ff       	call   800db7 <sys_page_map>
  801367:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801369:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136c:	85 f6                	test   %esi,%esi
  80136e:	79 22                	jns    801392 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801370:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801374:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137b:	e8 8a fa ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801380:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138b:	e8 7a fa ff ff       	call   800e0a <sys_page_unmap>
	return r;
  801390:	89 f0                	mov    %esi,%eax
}
  801392:	83 c4 3c             	add    $0x3c,%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5f                   	pop    %edi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	53                   	push   %ebx
  80139e:	83 ec 24             	sub    $0x24,%esp
  8013a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ab:	89 1c 24             	mov    %ebx,(%esp)
  8013ae:	e8 53 fd ff ff       	call   801106 <fd_lookup>
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	85 d2                	test   %edx,%edx
  8013b7:	78 6d                	js     801426 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c3:	8b 00                	mov    (%eax),%eax
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	e8 8f fd ff ff       	call   80115c <dev_lookup>
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 55                	js     801426 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	8b 50 08             	mov    0x8(%eax),%edx
  8013d7:	83 e2 03             	and    $0x3,%edx
  8013da:	83 fa 01             	cmp    $0x1,%edx
  8013dd:	75 23                	jne    801402 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013df:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013e4:	8b 40 48             	mov    0x48(%eax),%eax
  8013e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	c7 04 24 6d 2c 80 00 	movl   $0x802c6d,(%esp)
  8013f6:	e8 25 ef ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  8013fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801400:	eb 24                	jmp    801426 <read+0x8c>
	}
	if (!dev->dev_read)
  801402:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801405:	8b 52 08             	mov    0x8(%edx),%edx
  801408:	85 d2                	test   %edx,%edx
  80140a:	74 15                	je     801421 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80140c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80140f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801413:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801416:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	ff d2                	call   *%edx
  80141f:	eb 05                	jmp    801426 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801421:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801426:	83 c4 24             	add    $0x24,%esp
  801429:	5b                   	pop    %ebx
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 1c             	sub    $0x1c,%esp
  801435:	8b 7d 08             	mov    0x8(%ebp),%edi
  801438:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801440:	eb 23                	jmp    801465 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801442:	89 f0                	mov    %esi,%eax
  801444:	29 d8                	sub    %ebx,%eax
  801446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144a:	89 d8                	mov    %ebx,%eax
  80144c:	03 45 0c             	add    0xc(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	89 3c 24             	mov    %edi,(%esp)
  801456:	e8 3f ff ff ff       	call   80139a <read>
		if (m < 0)
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 10                	js     80146f <readn+0x43>
			return m;
		if (m == 0)
  80145f:	85 c0                	test   %eax,%eax
  801461:	74 0a                	je     80146d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801463:	01 c3                	add    %eax,%ebx
  801465:	39 f3                	cmp    %esi,%ebx
  801467:	72 d9                	jb     801442 <readn+0x16>
  801469:	89 d8                	mov    %ebx,%eax
  80146b:	eb 02                	jmp    80146f <readn+0x43>
  80146d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80146f:	83 c4 1c             	add    $0x1c,%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 24             	sub    $0x24,%esp
  80147e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801481:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801484:	89 44 24 04          	mov    %eax,0x4(%esp)
  801488:	89 1c 24             	mov    %ebx,(%esp)
  80148b:	e8 76 fc ff ff       	call   801106 <fd_lookup>
  801490:	89 c2                	mov    %eax,%edx
  801492:	85 d2                	test   %edx,%edx
  801494:	78 68                	js     8014fe <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	8b 00                	mov    (%eax),%eax
  8014a2:	89 04 24             	mov    %eax,(%esp)
  8014a5:	e8 b2 fc ff ff       	call   80115c <dev_lookup>
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 50                	js     8014fe <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b5:	75 23                	jne    8014da <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014bc:	8b 40 48             	mov    0x48(%eax),%eax
  8014bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c7:	c7 04 24 89 2c 80 00 	movl   $0x802c89,(%esp)
  8014ce:	e8 4d ee ff ff       	call   800320 <cprintf>
		return -E_INVAL;
  8014d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d8:	eb 24                	jmp    8014fe <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 15                	je     8014f9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	ff d2                	call   *%edx
  8014f7:	eb 05                	jmp    8014fe <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014fe:	83 c4 24             	add    $0x24,%esp
  801501:	5b                   	pop    %ebx
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <seek>:

int
seek(int fdnum, off_t offset)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 ea fb ff ff       	call   801106 <fd_lookup>
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 0e                	js     80152e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801520:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801523:	8b 55 0c             	mov    0xc(%ebp),%edx
  801526:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801529:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 24             	sub    $0x24,%esp
  801537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801541:	89 1c 24             	mov    %ebx,(%esp)
  801544:	e8 bd fb ff ff       	call   801106 <fd_lookup>
  801549:	89 c2                	mov    %eax,%edx
  80154b:	85 d2                	test   %edx,%edx
  80154d:	78 61                	js     8015b0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	89 44 24 04          	mov    %eax,0x4(%esp)
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	8b 00                	mov    (%eax),%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 f9 fb ff ff       	call   80115c <dev_lookup>
  801563:	85 c0                	test   %eax,%eax
  801565:	78 49                	js     8015b0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156e:	75 23                	jne    801593 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801570:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801575:	8b 40 48             	mov    0x48(%eax),%eax
  801578:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80157c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801580:	c7 04 24 4c 2c 80 00 	movl   $0x802c4c,(%esp)
  801587:	e8 94 ed ff ff       	call   800320 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801591:	eb 1d                	jmp    8015b0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 52 18             	mov    0x18(%edx),%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 0e                	je     8015ab <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80159d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015a4:	89 04 24             	mov    %eax,(%esp)
  8015a7:	ff d2                	call   *%edx
  8015a9:	eb 05                	jmp    8015b0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b0:	83 c4 24             	add    $0x24,%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 24             	sub    $0x24,%esp
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	89 04 24             	mov    %eax,(%esp)
  8015cd:	e8 34 fb ff ff       	call   801106 <fd_lookup>
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	78 52                	js     80162a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e2:	8b 00                	mov    (%eax),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 70 fb ff ff       	call   80115c <dev_lookup>
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 3a                	js     80162a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f7:	74 2c                	je     801625 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801603:	00 00 00 
	stat->st_isdir = 0;
  801606:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160d:	00 00 00 
	stat->st_dev = dev;
  801610:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801616:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80161a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161d:	89 14 24             	mov    %edx,(%esp)
  801620:	ff 50 14             	call   *0x14(%eax)
  801623:	eb 05                	jmp    80162a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801625:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80162a:	83 c4 24             	add    $0x24,%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801638:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80163f:	00 
  801640:	8b 45 08             	mov    0x8(%ebp),%eax
  801643:	89 04 24             	mov    %eax,(%esp)
  801646:	e8 28 02 00 00       	call   801873 <open>
  80164b:	89 c3                	mov    %eax,%ebx
  80164d:	85 db                	test   %ebx,%ebx
  80164f:	78 1b                	js     80166c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801651:	8b 45 0c             	mov    0xc(%ebp),%eax
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	89 1c 24             	mov    %ebx,(%esp)
  80165b:	e8 56 ff ff ff       	call   8015b6 <fstat>
  801660:	89 c6                	mov    %eax,%esi
	close(fd);
  801662:	89 1c 24             	mov    %ebx,(%esp)
  801665:	e8 cd fb ff ff       	call   801237 <close>
	return r;
  80166a:	89 f0                	mov    %esi,%eax
}
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 10             	sub    $0x10,%esp
  80167b:	89 c6                	mov    %eax,%esi
  80167d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801686:	75 11                	jne    801699 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801688:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80168f:	e8 e1 0e 00 00       	call   802575 <ipc_find_env>
  801694:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801699:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016a0:	00 
  8016a1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016a8:	00 
  8016a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 50 0e 00 00       	call   80250a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c1:	00 
  8016c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cd:	e8 be 0d 00 00       	call   802490 <ipc_recv>
}
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016fc:	e8 72 ff ff ff       	call   801673 <fsipc>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	8b 40 0c             	mov    0xc(%eax),%eax
  80170f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	b8 06 00 00 00       	mov    $0x6,%eax
  80171e:	e8 50 ff ff ff       	call   801673 <fsipc>
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	53                   	push   %ebx
  801729:	83 ec 14             	sub    $0x14,%esp
  80172c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80173a:	ba 00 00 00 00       	mov    $0x0,%edx
  80173f:	b8 05 00 00 00       	mov    $0x5,%eax
  801744:	e8 2a ff ff ff       	call   801673 <fsipc>
  801749:	89 c2                	mov    %eax,%edx
  80174b:	85 d2                	test   %edx,%edx
  80174d:	78 2b                	js     80177a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80174f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801756:	00 
  801757:	89 1c 24             	mov    %ebx,(%esp)
  80175a:	e8 e8 f1 ff ff       	call   800947 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80175f:	a1 80 50 80 00       	mov    0x805080,%eax
  801764:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176a:	a1 84 50 80 00       	mov    0x805084,%eax
  80176f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177a:	83 c4 14             	add    $0x14,%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 18             	sub    $0x18,%esp
  801786:	8b 45 10             	mov    0x10(%ebp),%eax
  801789:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80178e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801793:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801796:	8b 55 08             	mov    0x8(%ebp),%edx
  801799:	8b 52 0c             	mov    0xc(%edx),%edx
  80179c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017a2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8017a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8017b9:	e8 26 f3 ff ff       	call   800ae4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c8:	e8 a6 fe ff ff       	call   801673 <fsipc>
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 10             	sub    $0x10,%esp
  8017d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f5:	e8 79 fe ff ff       	call   801673 <fsipc>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 6a                	js     80186a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801800:	39 c6                	cmp    %eax,%esi
  801802:	73 24                	jae    801828 <devfile_read+0x59>
  801804:	c7 44 24 0c bc 2c 80 	movl   $0x802cbc,0xc(%esp)
  80180b:	00 
  80180c:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  801813:	00 
  801814:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80181b:	00 
  80181c:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  801823:	e8 ff e9 ff ff       	call   800227 <_panic>
	assert(r <= PGSIZE);
  801828:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182d:	7e 24                	jle    801853 <devfile_read+0x84>
  80182f:	c7 44 24 0c e3 2c 80 	movl   $0x802ce3,0xc(%esp)
  801836:	00 
  801837:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  80183e:	00 
  80183f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801846:	00 
  801847:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  80184e:	e8 d4 e9 ff ff       	call   800227 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801853:	89 44 24 08          	mov    %eax,0x8(%esp)
  801857:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80185e:	00 
  80185f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 7a f2 ff ff       	call   800ae4 <memmove>
	return r;
}
  80186a:	89 d8                	mov    %ebx,%eax
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 24             	sub    $0x24,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187d:	89 1c 24             	mov    %ebx,(%esp)
  801880:	e8 8b f0 ff ff       	call   800910 <strlen>
  801885:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188a:	7f 60                	jg     8018ec <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 20 f8 ff ff       	call   8010b7 <fd_alloc>
  801897:	89 c2                	mov    %eax,%edx
  801899:	85 d2                	test   %edx,%edx
  80189b:	78 54                	js     8018f1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80189d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018a1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018a8:	e8 9a f0 ff ff       	call   800947 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bd:	e8 b1 fd ff ff       	call   801673 <fsipc>
  8018c2:	89 c3                	mov    %eax,%ebx
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	79 17                	jns    8018df <open+0x6c>
		fd_close(fd, 0);
  8018c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018cf:	00 
  8018d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 db f8 ff ff       	call   8011b6 <fd_close>
		return r;
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	eb 12                	jmp    8018f1 <open+0x7e>
	}

	return fd2num(fd);
  8018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	e8 a6 f7 ff ff       	call   801090 <fd2num>
  8018ea:	eb 05                	jmp    8018f1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ec:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018f1:	83 c4 24             	add    $0x24,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 08 00 00 00       	mov    $0x8,%eax
  801907:	e8 67 fd ff ff       	call   801673 <fsipc>
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 14             	sub    $0x14,%esp
  801915:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801917:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80191b:	7e 31                	jle    80194e <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80191d:	8b 40 04             	mov    0x4(%eax),%eax
  801920:	89 44 24 08          	mov    %eax,0x8(%esp)
  801924:	8d 43 10             	lea    0x10(%ebx),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	8b 03                	mov    (%ebx),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 42 fb ff ff       	call   801477 <write>
		if (result > 0)
  801935:	85 c0                	test   %eax,%eax
  801937:	7e 03                	jle    80193c <writebuf+0x2e>
			b->result += result;
  801939:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80193c:	39 43 04             	cmp    %eax,0x4(%ebx)
  80193f:	74 0d                	je     80194e <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801941:	85 c0                	test   %eax,%eax
  801943:	ba 00 00 00 00       	mov    $0x0,%edx
  801948:	0f 4f c2             	cmovg  %edx,%eax
  80194b:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80194e:	83 c4 14             	add    $0x14,%esp
  801951:	5b                   	pop    %ebx
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <putch>:

static void
putch(int ch, void *thunk)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80195e:	8b 53 04             	mov    0x4(%ebx),%edx
  801961:	8d 42 01             	lea    0x1(%edx),%eax
  801964:	89 43 04             	mov    %eax,0x4(%ebx)
  801967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196a:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80196e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801973:	75 0e                	jne    801983 <putch+0x2f>
		writebuf(b);
  801975:	89 d8                	mov    %ebx,%eax
  801977:	e8 92 ff ff ff       	call   80190e <writebuf>
		b->idx = 0;
  80197c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801983:	83 c4 04             	add    $0x4,%esp
  801986:	5b                   	pop    %ebx
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80199b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019a2:	00 00 00 
	b.result = 0;
  8019a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019ac:	00 00 00 
	b.error = 1;
  8019af:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019b6:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	c7 04 24 54 19 80 00 	movl   $0x801954,(%esp)
  8019d8:	e8 d1 ea ff ff       	call   8004ae <vprintfmt>
	if (b.idx > 0)
  8019dd:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019e4:	7e 0b                	jle    8019f1 <vfprintf+0x68>
		writebuf(&b);
  8019e6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ec:	e8 1d ff ff ff       	call   80190e <writebuf>

	return (b.result ? b.result : b.error);
  8019f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a08:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 68 ff ff ff       	call   801989 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <printf>:

int
printf(const char *fmt, ...)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a29:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a3e:	e8 46 ff ff ff       	call   801989 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    
  801a45:	66 90                	xchg   %ax,%ax
  801a47:	66 90                	xchg   %ax,%ax
  801a49:	66 90                	xchg   %ax,%ax
  801a4b:	66 90                	xchg   %ax,%ax
  801a4d:	66 90                	xchg   %ax,%ax
  801a4f:	90                   	nop

00801a50 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801a56:	c7 44 24 04 ef 2c 80 	movl   $0x802cef,0x4(%esp)
  801a5d:	00 
  801a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 de ee ff ff       	call   800947 <strcpy>
	return 0;
}
  801a69:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	53                   	push   %ebx
  801a74:	83 ec 14             	sub    $0x14,%esp
  801a77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a7a:	89 1c 24             	mov    %ebx,(%esp)
  801a7d:	e8 2b 0b 00 00       	call   8025ad <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a82:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a87:	83 f8 01             	cmp    $0x1,%eax
  801a8a:	75 0d                	jne    801a99 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801a8c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 29 03 00 00       	call   801dc0 <nsipc_close>
  801a97:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801a99:	89 d0                	mov    %edx,%eax
  801a9b:	83 c4 14             	add    $0x14,%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aa7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801aae:	00 
  801aaf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac3:	89 04 24             	mov    %eax,(%esp)
  801ac6:	e8 f0 03 00 00       	call   801ebb <nsipc_send>
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ad3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ada:	00 
  801adb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ade:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 40 0c             	mov    0xc(%eax),%eax
  801aef:	89 04 24             	mov    %eax,(%esp)
  801af2:	e8 44 03 00 00       	call   801e3b <nsipc_recv>
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b02:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 f8 f5 ff ff       	call   801106 <fd_lookup>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 17                	js     801b29 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801b1b:	39 08                	cmp    %ecx,(%eax)
  801b1d:	75 05                	jne    801b24 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b22:	eb 05                	jmp    801b29 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 20             	sub    $0x20,%esp
  801b33:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	89 04 24             	mov    %eax,(%esp)
  801b3b:	e8 77 f5 ff ff       	call   8010b7 <fd_alloc>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 21                	js     801b67 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b4d:	00 
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5c:	e8 02 f2 ff ff       	call   800d63 <sys_page_alloc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	79 0c                	jns    801b73 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801b67:	89 34 24             	mov    %esi,(%esp)
  801b6a:	e8 51 02 00 00       	call   801dc0 <nsipc_close>
		return r;
  801b6f:	89 d8                	mov    %ebx,%eax
  801b71:	eb 20                	jmp    801b93 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b73:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b81:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801b88:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801b8b:	89 14 24             	mov    %edx,(%esp)
  801b8e:	e8 fd f4 ff ff       	call   801090 <fd2num>
}
  801b93:	83 c4 20             	add    $0x20,%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	e8 51 ff ff ff       	call   801af9 <fd2sockid>
		return r;
  801ba8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 23                	js     801bd1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bae:	8b 55 10             	mov    0x10(%ebp),%edx
  801bb1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 45 01 00 00       	call   801d09 <nsipc_accept>
		return r;
  801bc4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 07                	js     801bd1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801bca:	e8 5c ff ff ff       	call   801b2b <alloc_sockfd>
  801bcf:	89 c1                	mov    %eax,%ecx
}
  801bd1:	89 c8                	mov    %ecx,%eax
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	e8 16 ff ff ff       	call   801af9 <fd2sockid>
  801be3:	89 c2                	mov    %eax,%edx
  801be5:	85 d2                	test   %edx,%edx
  801be7:	78 16                	js     801bff <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf7:	89 14 24             	mov    %edx,(%esp)
  801bfa:	e8 60 01 00 00       	call   801d5f <nsipc_bind>
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <shutdown>:

int
shutdown(int s, int how)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	e8 ea fe ff ff       	call   801af9 <fd2sockid>
  801c0f:	89 c2                	mov    %eax,%edx
  801c11:	85 d2                	test   %edx,%edx
  801c13:	78 0f                	js     801c24 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1c:	89 14 24             	mov    %edx,(%esp)
  801c1f:	e8 7a 01 00 00       	call   801d9e <nsipc_shutdown>
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	e8 c5 fe ff ff       	call   801af9 <fd2sockid>
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	85 d2                	test   %edx,%edx
  801c38:	78 16                	js     801c50 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801c3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c48:	89 14 24             	mov    %edx,(%esp)
  801c4b:	e8 8a 01 00 00       	call   801dda <nsipc_connect>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <listen>:

int
listen(int s, int backlog)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	e8 99 fe ff ff       	call   801af9 <fd2sockid>
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	85 d2                	test   %edx,%edx
  801c64:	78 0f                	js     801c75 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6d:	89 14 24             	mov    %edx,(%esp)
  801c70:	e8 a4 01 00 00       	call   801e19 <nsipc_listen>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	89 04 24             	mov    %eax,(%esp)
  801c91:	e8 98 02 00 00       	call   801f2e <nsipc_socket>
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	85 d2                	test   %edx,%edx
  801c9a:	78 05                	js     801ca1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801c9c:	e8 8a fe ff ff       	call   801b2b <alloc_sockfd>
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 14             	sub    $0x14,%esp
  801caa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cac:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801cb3:	75 11                	jne    801cc6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cbc:	e8 b4 08 00 00       	call   802575 <ipc_find_env>
  801cc1:	a3 08 40 80 00       	mov    %eax,0x804008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ccd:	00 
  801cce:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801cd5:	00 
  801cd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cda:	a1 08 40 80 00       	mov    0x804008,%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 23 08 00 00       	call   80250a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ce7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cee:	00 
  801cef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cf6:	00 
  801cf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfe:	e8 8d 07 00 00       	call   802490 <ipc_recv>
}
  801d03:	83 c4 14             	add    $0x14,%esp
  801d06:	5b                   	pop    %ebx
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 10             	sub    $0x10,%esp
  801d11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d1c:	8b 06                	mov    (%esi),%eax
  801d1e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d23:	b8 01 00 00 00       	mov    $0x1,%eax
  801d28:	e8 76 ff ff ff       	call   801ca3 <nsipc>
  801d2d:	89 c3                	mov    %eax,%ebx
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 23                	js     801d56 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d33:	a1 10 60 80 00       	mov    0x806010,%eax
  801d38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d43:	00 
  801d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d47:	89 04 24             	mov    %eax,(%esp)
  801d4a:	e8 95 ed ff ff       	call   800ae4 <memmove>
		*addrlen = ret->ret_addrlen;
  801d4f:	a1 10 60 80 00       	mov    0x806010,%eax
  801d54:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	53                   	push   %ebx
  801d63:	83 ec 14             	sub    $0x14,%esp
  801d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d83:	e8 5c ed ff ff       	call   800ae4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d88:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d8e:	b8 02 00 00 00       	mov    $0x2,%eax
  801d93:	e8 0b ff ff ff       	call   801ca3 <nsipc>
}
  801d98:	83 c4 14             	add    $0x14,%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801db4:	b8 03 00 00 00       	mov    $0x3,%eax
  801db9:	e8 e5 fe ff ff       	call   801ca3 <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_close>:

int
nsipc_close(int s)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dce:	b8 04 00 00 00       	mov    $0x4,%eax
  801dd3:	e8 cb fe ff ff       	call   801ca3 <nsipc>
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 14             	sub    $0x14,%esp
  801de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801dfe:	e8 e1 ec ff ff       	call   800ae4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e03:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e09:	b8 05 00 00 00       	mov    $0x5,%eax
  801e0e:	e8 90 fe ff ff       	call   801ca3 <nsipc>
}
  801e13:	83 c4 14             	add    $0x14,%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e2f:	b8 06 00 00 00       	mov    $0x6,%eax
  801e34:	e8 6a fe ff ff       	call   801ca3 <nsipc>
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 10             	sub    $0x10,%esp
  801e43:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e4e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e54:	8b 45 14             	mov    0x14(%ebp),%eax
  801e57:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e5c:	b8 07 00 00 00       	mov    $0x7,%eax
  801e61:	e8 3d fe ff ff       	call   801ca3 <nsipc>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 46                	js     801eb2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e6c:	39 f0                	cmp    %esi,%eax
  801e6e:	7f 07                	jg     801e77 <nsipc_recv+0x3c>
  801e70:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e75:	7e 24                	jle    801e9b <nsipc_recv+0x60>
  801e77:	c7 44 24 0c fb 2c 80 	movl   $0x802cfb,0xc(%esp)
  801e7e:	00 
  801e7f:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  801e86:	00 
  801e87:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801e8e:	00 
  801e8f:	c7 04 24 10 2d 80 00 	movl   $0x802d10,(%esp)
  801e96:	e8 8c e3 ff ff       	call   800227 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e9f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ea6:	00 
  801ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaa:	89 04 24             	mov    %eax,(%esp)
  801ead:	e8 32 ec ff ff       	call   800ae4 <memmove>
	}

	return r;
}
  801eb2:	89 d8                	mov    %ebx,%eax
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 14             	sub    $0x14,%esp
  801ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ecd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ed3:	7e 24                	jle    801ef9 <nsipc_send+0x3e>
  801ed5:	c7 44 24 0c 1c 2d 80 	movl   $0x802d1c,0xc(%esp)
  801edc:	00 
  801edd:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  801ee4:	00 
  801ee5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801eec:	00 
  801eed:	c7 04 24 10 2d 80 00 	movl   $0x802d10,(%esp)
  801ef4:	e8 2e e3 ff ff       	call   800227 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f04:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f0b:	e8 d4 eb ff ff       	call   800ae4 <memmove>
	nsipcbuf.send.req_size = size;
  801f10:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f16:	8b 45 14             	mov    0x14(%ebp),%eax
  801f19:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801f23:	e8 7b fd ff ff       	call   801ca3 <nsipc>
}
  801f28:	83 c4 14             	add    $0x14,%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f44:	8b 45 10             	mov    0x10(%ebp),%eax
  801f47:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f4c:	b8 09 00 00 00       	mov    $0x9,%eax
  801f51:	e8 4d fd ff ff       	call   801ca3 <nsipc>
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	83 ec 10             	sub    $0x10,%esp
  801f60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
  801f66:	89 04 24             	mov    %eax,(%esp)
  801f69:	e8 32 f1 ff ff       	call   8010a0 <fd2data>
  801f6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f70:	c7 44 24 04 28 2d 80 	movl   $0x802d28,0x4(%esp)
  801f77:	00 
  801f78:	89 1c 24             	mov    %ebx,(%esp)
  801f7b:	e8 c7 e9 ff ff       	call   800947 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f80:	8b 46 04             	mov    0x4(%esi),%eax
  801f83:	2b 06                	sub    (%esi),%eax
  801f85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f92:	00 00 00 
	stat->st_dev = &devpipe;
  801f95:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801f9c:	30 80 00 
	return 0;
}
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	83 ec 14             	sub    $0x14,%esp
  801fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc0:	e8 45 ee ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fc5:	89 1c 24             	mov    %ebx,(%esp)
  801fc8:	e8 d3 f0 ff ff       	call   8010a0 <fd2data>
  801fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd8:	e8 2d ee ff ff       	call   800e0a <sys_page_unmap>
}
  801fdd:	83 c4 14             	add    $0x14,%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	57                   	push   %edi
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 2c             	sub    $0x2c,%esp
  801fec:	89 c6                	mov    %eax,%esi
  801fee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ff1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ff6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ff9:	89 34 24             	mov    %esi,(%esp)
  801ffc:	e8 ac 05 00 00       	call   8025ad <pageref>
  802001:	89 c7                	mov    %eax,%edi
  802003:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802006:	89 04 24             	mov    %eax,(%esp)
  802009:	e8 9f 05 00 00       	call   8025ad <pageref>
  80200e:	39 c7                	cmp    %eax,%edi
  802010:	0f 94 c2             	sete   %dl
  802013:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802016:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  80201c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80201f:	39 fb                	cmp    %edi,%ebx
  802021:	74 21                	je     802044 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802023:	84 d2                	test   %dl,%dl
  802025:	74 ca                	je     801ff1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802027:	8b 51 58             	mov    0x58(%ecx),%edx
  80202a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802032:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802036:	c7 04 24 2f 2d 80 00 	movl   $0x802d2f,(%esp)
  80203d:	e8 de e2 ff ff       	call   800320 <cprintf>
  802042:	eb ad                	jmp    801ff1 <_pipeisclosed+0xe>
	}
}
  802044:	83 c4 2c             	add    $0x2c,%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	5f                   	pop    %edi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    

0080204c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	57                   	push   %edi
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	83 ec 1c             	sub    $0x1c,%esp
  802055:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802058:	89 34 24             	mov    %esi,(%esp)
  80205b:	e8 40 f0 ff ff       	call   8010a0 <fd2data>
  802060:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802062:	bf 00 00 00 00       	mov    $0x0,%edi
  802067:	eb 45                	jmp    8020ae <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802069:	89 da                	mov    %ebx,%edx
  80206b:	89 f0                	mov    %esi,%eax
  80206d:	e8 71 ff ff ff       	call   801fe3 <_pipeisclosed>
  802072:	85 c0                	test   %eax,%eax
  802074:	75 41                	jne    8020b7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802076:	e8 c9 ec ff ff       	call   800d44 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80207b:	8b 43 04             	mov    0x4(%ebx),%eax
  80207e:	8b 0b                	mov    (%ebx),%ecx
  802080:	8d 51 20             	lea    0x20(%ecx),%edx
  802083:	39 d0                	cmp    %edx,%eax
  802085:	73 e2                	jae    802069 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802087:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80208a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80208e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802091:	99                   	cltd   
  802092:	c1 ea 1b             	shr    $0x1b,%edx
  802095:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802098:	83 e1 1f             	and    $0x1f,%ecx
  80209b:	29 d1                	sub    %edx,%ecx
  80209d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8020a1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8020a5:	83 c0 01             	add    $0x1,%eax
  8020a8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ab:	83 c7 01             	add    $0x1,%edi
  8020ae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020b1:	75 c8                	jne    80207b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020b3:	89 f8                	mov    %edi,%eax
  8020b5:	eb 05                	jmp    8020bc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	57                   	push   %edi
  8020c8:	56                   	push   %esi
  8020c9:	53                   	push   %ebx
  8020ca:	83 ec 1c             	sub    $0x1c,%esp
  8020cd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020d0:	89 3c 24             	mov    %edi,(%esp)
  8020d3:	e8 c8 ef ff ff       	call   8010a0 <fd2data>
  8020d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020da:	be 00 00 00 00       	mov    $0x0,%esi
  8020df:	eb 3d                	jmp    80211e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020e1:	85 f6                	test   %esi,%esi
  8020e3:	74 04                	je     8020e9 <devpipe_read+0x25>
				return i;
  8020e5:	89 f0                	mov    %esi,%eax
  8020e7:	eb 43                	jmp    80212c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020e9:	89 da                	mov    %ebx,%edx
  8020eb:	89 f8                	mov    %edi,%eax
  8020ed:	e8 f1 fe ff ff       	call   801fe3 <_pipeisclosed>
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	75 31                	jne    802127 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020f6:	e8 49 ec ff ff       	call   800d44 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020fb:	8b 03                	mov    (%ebx),%eax
  8020fd:	3b 43 04             	cmp    0x4(%ebx),%eax
  802100:	74 df                	je     8020e1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802102:	99                   	cltd   
  802103:	c1 ea 1b             	shr    $0x1b,%edx
  802106:	01 d0                	add    %edx,%eax
  802108:	83 e0 1f             	and    $0x1f,%eax
  80210b:	29 d0                	sub    %edx,%eax
  80210d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802115:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802118:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80211b:	83 c6 01             	add    $0x1,%esi
  80211e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802121:	75 d8                	jne    8020fb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802123:	89 f0                	mov    %esi,%eax
  802125:	eb 05                	jmp    80212c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80213c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213f:	89 04 24             	mov    %eax,(%esp)
  802142:	e8 70 ef ff ff       	call   8010b7 <fd_alloc>
  802147:	89 c2                	mov    %eax,%edx
  802149:	85 d2                	test   %edx,%edx
  80214b:	0f 88 4d 01 00 00    	js     80229e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802151:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802158:	00 
  802159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802167:	e8 f7 eb ff ff       	call   800d63 <sys_page_alloc>
  80216c:	89 c2                	mov    %eax,%edx
  80216e:	85 d2                	test   %edx,%edx
  802170:	0f 88 28 01 00 00    	js     80229e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802176:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802179:	89 04 24             	mov    %eax,(%esp)
  80217c:	e8 36 ef ff ff       	call   8010b7 <fd_alloc>
  802181:	89 c3                	mov    %eax,%ebx
  802183:	85 c0                	test   %eax,%eax
  802185:	0f 88 fe 00 00 00    	js     802289 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802192:	00 
  802193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a1:	e8 bd eb ff ff       	call   800d63 <sys_page_alloc>
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	0f 88 d9 00 00 00    	js     802289 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b3:	89 04 24             	mov    %eax,(%esp)
  8021b6:	e8 e5 ee ff ff       	call   8010a0 <fd2data>
  8021bb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021c4:	00 
  8021c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d0:	e8 8e eb ff ff       	call   800d63 <sys_page_alloc>
  8021d5:	89 c3                	mov    %eax,%ebx
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	0f 88 97 00 00 00    	js     802276 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e2:	89 04 24             	mov    %eax,(%esp)
  8021e5:	e8 b6 ee ff ff       	call   8010a0 <fd2data>
  8021ea:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8021f1:	00 
  8021f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021fd:	00 
  8021fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  802202:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802209:	e8 a9 eb ff ff       	call   800db7 <sys_page_map>
  80220e:	89 c3                	mov    %eax,%ebx
  802210:	85 c0                	test   %eax,%eax
  802212:	78 52                	js     802266 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802214:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80221a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80221f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802222:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802229:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80222f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802232:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802237:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802241:	89 04 24             	mov    %eax,(%esp)
  802244:	e8 47 ee ff ff       	call   801090 <fd2num>
  802249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80224c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80224e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802251:	89 04 24             	mov    %eax,(%esp)
  802254:	e8 37 ee ff ff       	call   801090 <fd2num>
  802259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80225f:	b8 00 00 00 00       	mov    $0x0,%eax
  802264:	eb 38                	jmp    80229e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802271:	e8 94 eb ff ff       	call   800e0a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802284:	e8 81 eb ff ff       	call   800e0a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802297:	e8 6e eb ff ff       	call   800e0a <sys_page_unmap>
  80229c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80229e:	83 c4 30             	add    $0x30,%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    

008022a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	e8 49 ee ff ff       	call   801106 <fd_lookup>
  8022bd:	89 c2                	mov    %eax,%edx
  8022bf:	85 d2                	test   %edx,%edx
  8022c1:	78 15                	js     8022d8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c6:	89 04 24             	mov    %eax,(%esp)
  8022c9:	e8 d2 ed ff ff       	call   8010a0 <fd2data>
	return _pipeisclosed(fd, p);
  8022ce:	89 c2                	mov    %eax,%edx
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	e8 0b fd ff ff       	call   801fe3 <_pipeisclosed>
}
  8022d8:	c9                   	leave  
  8022d9:	c3                   	ret    
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022f0:	c7 44 24 04 47 2d 80 	movl   $0x802d47,0x4(%esp)
  8022f7:	00 
  8022f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fb:	89 04 24             	mov    %eax,(%esp)
  8022fe:	e8 44 e6 ff ff       	call   800947 <strcpy>
	return 0;
}
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	57                   	push   %edi
  80230e:	56                   	push   %esi
  80230f:	53                   	push   %ebx
  802310:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802316:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80231b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802321:	eb 31                	jmp    802354 <devcons_write+0x4a>
		m = n - tot;
  802323:	8b 75 10             	mov    0x10(%ebp),%esi
  802326:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802328:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80232b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802330:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802333:	89 74 24 08          	mov    %esi,0x8(%esp)
  802337:	03 45 0c             	add    0xc(%ebp),%eax
  80233a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233e:	89 3c 24             	mov    %edi,(%esp)
  802341:	e8 9e e7 ff ff       	call   800ae4 <memmove>
		sys_cputs(buf, m);
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	89 3c 24             	mov    %edi,(%esp)
  80234d:	e8 44 e9 ff ff       	call   800c96 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802352:	01 f3                	add    %esi,%ebx
  802354:	89 d8                	mov    %ebx,%eax
  802356:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802359:	72 c8                	jb     802323 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80235b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5f                   	pop    %edi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    

00802366 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80236c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802371:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802375:	75 07                	jne    80237e <devcons_read+0x18>
  802377:	eb 2a                	jmp    8023a3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802379:	e8 c6 e9 ff ff       	call   800d44 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80237e:	66 90                	xchg   %ax,%ax
  802380:	e8 2f e9 ff ff       	call   800cb4 <sys_cgetc>
  802385:	85 c0                	test   %eax,%eax
  802387:	74 f0                	je     802379 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802389:	85 c0                	test   %eax,%eax
  80238b:	78 16                	js     8023a3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80238d:	83 f8 04             	cmp    $0x4,%eax
  802390:	74 0c                	je     80239e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802392:	8b 55 0c             	mov    0xc(%ebp),%edx
  802395:	88 02                	mov    %al,(%edx)
	return 1;
  802397:	b8 01 00 00 00       	mov    $0x1,%eax
  80239c:	eb 05                	jmp    8023a3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80239e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8023ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ae:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8023b8:	00 
  8023b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023bc:	89 04 24             	mov    %eax,(%esp)
  8023bf:	e8 d2 e8 ff ff       	call   800c96 <sys_cputs>
}
  8023c4:	c9                   	leave  
  8023c5:	c3                   	ret    

008023c6 <getchar>:

int
getchar(void)
{
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023d3:	00 
  8023d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e2:	e8 b3 ef ff ff       	call   80139a <read>
	if (r < 0)
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	78 0f                	js     8023fa <getchar+0x34>
		return r;
	if (r < 1)
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	7e 06                	jle    8023f5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8023ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023f3:	eb 05                	jmp    8023fa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023fa:	c9                   	leave  
  8023fb:	c3                   	ret    

008023fc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802405:	89 44 24 04          	mov    %eax,0x4(%esp)
  802409:	8b 45 08             	mov    0x8(%ebp),%eax
  80240c:	89 04 24             	mov    %eax,(%esp)
  80240f:	e8 f2 ec ff ff       	call   801106 <fd_lookup>
  802414:	85 c0                	test   %eax,%eax
  802416:	78 11                	js     802429 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802418:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802421:	39 10                	cmp    %edx,(%eax)
  802423:	0f 94 c0             	sete   %al
  802426:	0f b6 c0             	movzbl %al,%eax
}
  802429:	c9                   	leave  
  80242a:	c3                   	ret    

0080242b <opencons>:

int
opencons(void)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802434:	89 04 24             	mov    %eax,(%esp)
  802437:	e8 7b ec ff ff       	call   8010b7 <fd_alloc>
		return r;
  80243c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 40                	js     802482 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802442:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802449:	00 
  80244a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802451:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802458:	e8 06 e9 ff ff       	call   800d63 <sys_page_alloc>
		return r;
  80245d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80245f:	85 c0                	test   %eax,%eax
  802461:	78 1f                	js     802482 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802463:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802471:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802478:	89 04 24             	mov    %eax,(%esp)
  80247b:	e8 10 ec ff ff       	call   801090 <fd2num>
  802480:	89 c2                	mov    %eax,%edx
}
  802482:	89 d0                	mov    %edx,%eax
  802484:	c9                   	leave  
  802485:	c3                   	ret    
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	56                   	push   %esi
  802494:	53                   	push   %ebx
  802495:	83 ec 10             	sub    $0x10,%esp
  802498:	8b 75 08             	mov    0x8(%ebp),%esi
  80249b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8024a1:	85 c0                	test   %eax,%eax
  8024a3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024a8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8024ab:	89 04 24             	mov    %eax,(%esp)
  8024ae:	e8 c6 ea ff ff       	call   800f79 <sys_ipc_recv>

	if(ret < 0) {
  8024b3:	85 c0                	test   %eax,%eax
  8024b5:	79 16                	jns    8024cd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8024b7:	85 f6                	test   %esi,%esi
  8024b9:	74 06                	je     8024c1 <ipc_recv+0x31>
  8024bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8024c1:	85 db                	test   %ebx,%ebx
  8024c3:	74 3e                	je     802503 <ipc_recv+0x73>
  8024c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024cb:	eb 36                	jmp    802503 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8024cd:	e8 53 e8 ff ff       	call   800d25 <sys_getenvid>
  8024d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024df:	a3 0c 40 80 00       	mov    %eax,0x80400c

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8024e4:	85 f6                	test   %esi,%esi
  8024e6:	74 05                	je     8024ed <ipc_recv+0x5d>
  8024e8:	8b 40 74             	mov    0x74(%eax),%eax
  8024eb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8024ed:	85 db                	test   %ebx,%ebx
  8024ef:	74 0a                	je     8024fb <ipc_recv+0x6b>
  8024f1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8024f6:	8b 40 78             	mov    0x78(%eax),%eax
  8024f9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8024fb:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802500:	8b 40 70             	mov    0x70(%eax),%eax
}
  802503:	83 c4 10             	add    $0x10,%esp
  802506:	5b                   	pop    %ebx
  802507:	5e                   	pop    %esi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    

0080250a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	57                   	push   %edi
  80250e:	56                   	push   %esi
  80250f:	53                   	push   %ebx
  802510:	83 ec 1c             	sub    $0x1c,%esp
  802513:	8b 7d 08             	mov    0x8(%ebp),%edi
  802516:	8b 75 0c             	mov    0xc(%ebp),%esi
  802519:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80251c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80251e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802523:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802526:	8b 45 14             	mov    0x14(%ebp),%eax
  802529:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802531:	89 74 24 04          	mov    %esi,0x4(%esp)
  802535:	89 3c 24             	mov    %edi,(%esp)
  802538:	e8 19 ea ff ff       	call   800f56 <sys_ipc_try_send>

		if(ret >= 0) break;
  80253d:	85 c0                	test   %eax,%eax
  80253f:	79 2c                	jns    80256d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802541:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802544:	74 20                	je     802566 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802546:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254a:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  802551:	00 
  802552:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802559:	00 
  80255a:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  802561:	e8 c1 dc ff ff       	call   800227 <_panic>
		}
		sys_yield();
  802566:	e8 d9 e7 ff ff       	call   800d44 <sys_yield>
	}
  80256b:	eb b9                	jmp    802526 <ipc_send+0x1c>
}
  80256d:	83 c4 1c             	add    $0x1c,%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80257b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802580:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802583:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802589:	8b 52 50             	mov    0x50(%edx),%edx
  80258c:	39 ca                	cmp    %ecx,%edx
  80258e:	75 0d                	jne    80259d <ipc_find_env+0x28>
			return envs[i].env_id;
  802590:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802593:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802598:	8b 40 40             	mov    0x40(%eax),%eax
  80259b:	eb 0e                	jmp    8025ab <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80259d:	83 c0 01             	add    $0x1,%eax
  8025a0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025a5:	75 d9                	jne    802580 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025a7:	66 b8 00 00          	mov    $0x0,%ax
}
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    

008025ad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b3:	89 d0                	mov    %edx,%eax
  8025b5:	c1 e8 16             	shr    $0x16,%eax
  8025b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025bf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025c4:	f6 c1 01             	test   $0x1,%cl
  8025c7:	74 1d                	je     8025e6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025c9:	c1 ea 0c             	shr    $0xc,%edx
  8025cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025d3:	f6 c2 01             	test   $0x1,%dl
  8025d6:	74 0e                	je     8025e6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025d8:	c1 ea 0c             	shr    $0xc,%edx
  8025db:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025e2:	ef 
  8025e3:	0f b7 c0             	movzwl %ax,%eax
}
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__udivdi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8025fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8025fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802602:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802606:	85 c0                	test   %eax,%eax
  802608:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80260c:	89 ea                	mov    %ebp,%edx
  80260e:	89 0c 24             	mov    %ecx,(%esp)
  802611:	75 2d                	jne    802640 <__udivdi3+0x50>
  802613:	39 e9                	cmp    %ebp,%ecx
  802615:	77 61                	ja     802678 <__udivdi3+0x88>
  802617:	85 c9                	test   %ecx,%ecx
  802619:	89 ce                	mov    %ecx,%esi
  80261b:	75 0b                	jne    802628 <__udivdi3+0x38>
  80261d:	b8 01 00 00 00       	mov    $0x1,%eax
  802622:	31 d2                	xor    %edx,%edx
  802624:	f7 f1                	div    %ecx
  802626:	89 c6                	mov    %eax,%esi
  802628:	31 d2                	xor    %edx,%edx
  80262a:	89 e8                	mov    %ebp,%eax
  80262c:	f7 f6                	div    %esi
  80262e:	89 c5                	mov    %eax,%ebp
  802630:	89 f8                	mov    %edi,%eax
  802632:	f7 f6                	div    %esi
  802634:	89 ea                	mov    %ebp,%edx
  802636:	83 c4 0c             	add    $0xc,%esp
  802639:	5e                   	pop    %esi
  80263a:	5f                   	pop    %edi
  80263b:	5d                   	pop    %ebp
  80263c:	c3                   	ret    
  80263d:	8d 76 00             	lea    0x0(%esi),%esi
  802640:	39 e8                	cmp    %ebp,%eax
  802642:	77 24                	ja     802668 <__udivdi3+0x78>
  802644:	0f bd e8             	bsr    %eax,%ebp
  802647:	83 f5 1f             	xor    $0x1f,%ebp
  80264a:	75 3c                	jne    802688 <__udivdi3+0x98>
  80264c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802650:	39 34 24             	cmp    %esi,(%esp)
  802653:	0f 86 9f 00 00 00    	jbe    8026f8 <__udivdi3+0x108>
  802659:	39 d0                	cmp    %edx,%eax
  80265b:	0f 82 97 00 00 00    	jb     8026f8 <__udivdi3+0x108>
  802661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802668:	31 d2                	xor    %edx,%edx
  80266a:	31 c0                	xor    %eax,%eax
  80266c:	83 c4 0c             	add    $0xc,%esp
  80266f:	5e                   	pop    %esi
  802670:	5f                   	pop    %edi
  802671:	5d                   	pop    %ebp
  802672:	c3                   	ret    
  802673:	90                   	nop
  802674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802678:	89 f8                	mov    %edi,%eax
  80267a:	f7 f1                	div    %ecx
  80267c:	31 d2                	xor    %edx,%edx
  80267e:	83 c4 0c             	add    $0xc,%esp
  802681:	5e                   	pop    %esi
  802682:	5f                   	pop    %edi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    
  802685:	8d 76 00             	lea    0x0(%esi),%esi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	8b 3c 24             	mov    (%esp),%edi
  80268d:	d3 e0                	shl    %cl,%eax
  80268f:	89 c6                	mov    %eax,%esi
  802691:	b8 20 00 00 00       	mov    $0x20,%eax
  802696:	29 e8                	sub    %ebp,%eax
  802698:	89 c1                	mov    %eax,%ecx
  80269a:	d3 ef                	shr    %cl,%edi
  80269c:	89 e9                	mov    %ebp,%ecx
  80269e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8026a2:	8b 3c 24             	mov    (%esp),%edi
  8026a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8026a9:	89 d6                	mov    %edx,%esi
  8026ab:	d3 e7                	shl    %cl,%edi
  8026ad:	89 c1                	mov    %eax,%ecx
  8026af:	89 3c 24             	mov    %edi,(%esp)
  8026b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026b6:	d3 ee                	shr    %cl,%esi
  8026b8:	89 e9                	mov    %ebp,%ecx
  8026ba:	d3 e2                	shl    %cl,%edx
  8026bc:	89 c1                	mov    %eax,%ecx
  8026be:	d3 ef                	shr    %cl,%edi
  8026c0:	09 d7                	or     %edx,%edi
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	89 f8                	mov    %edi,%eax
  8026c6:	f7 74 24 08          	divl   0x8(%esp)
  8026ca:	89 d6                	mov    %edx,%esi
  8026cc:	89 c7                	mov    %eax,%edi
  8026ce:	f7 24 24             	mull   (%esp)
  8026d1:	39 d6                	cmp    %edx,%esi
  8026d3:	89 14 24             	mov    %edx,(%esp)
  8026d6:	72 30                	jb     802708 <__udivdi3+0x118>
  8026d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026dc:	89 e9                	mov    %ebp,%ecx
  8026de:	d3 e2                	shl    %cl,%edx
  8026e0:	39 c2                	cmp    %eax,%edx
  8026e2:	73 05                	jae    8026e9 <__udivdi3+0xf9>
  8026e4:	3b 34 24             	cmp    (%esp),%esi
  8026e7:	74 1f                	je     802708 <__udivdi3+0x118>
  8026e9:	89 f8                	mov    %edi,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	e9 7a ff ff ff       	jmp    80266c <__udivdi3+0x7c>
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ff:	e9 68 ff ff ff       	jmp    80266c <__udivdi3+0x7c>
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	8d 47 ff             	lea    -0x1(%edi),%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	83 c4 0c             	add    $0xc,%esp
  802710:	5e                   	pop    %esi
  802711:	5f                   	pop    %edi
  802712:	5d                   	pop    %ebp
  802713:	c3                   	ret    
  802714:	66 90                	xchg   %ax,%ax
  802716:	66 90                	xchg   %ax,%ax
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__umoddi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	83 ec 14             	sub    $0x14,%esp
  802726:	8b 44 24 28          	mov    0x28(%esp),%eax
  80272a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80272e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802732:	89 c7                	mov    %eax,%edi
  802734:	89 44 24 04          	mov    %eax,0x4(%esp)
  802738:	8b 44 24 30          	mov    0x30(%esp),%eax
  80273c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802740:	89 34 24             	mov    %esi,(%esp)
  802743:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802747:	85 c0                	test   %eax,%eax
  802749:	89 c2                	mov    %eax,%edx
  80274b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80274f:	75 17                	jne    802768 <__umoddi3+0x48>
  802751:	39 fe                	cmp    %edi,%esi
  802753:	76 4b                	jbe    8027a0 <__umoddi3+0x80>
  802755:	89 c8                	mov    %ecx,%eax
  802757:	89 fa                	mov    %edi,%edx
  802759:	f7 f6                	div    %esi
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	31 d2                	xor    %edx,%edx
  80275f:	83 c4 14             	add    $0x14,%esp
  802762:	5e                   	pop    %esi
  802763:	5f                   	pop    %edi
  802764:	5d                   	pop    %ebp
  802765:	c3                   	ret    
  802766:	66 90                	xchg   %ax,%ax
  802768:	39 f8                	cmp    %edi,%eax
  80276a:	77 54                	ja     8027c0 <__umoddi3+0xa0>
  80276c:	0f bd e8             	bsr    %eax,%ebp
  80276f:	83 f5 1f             	xor    $0x1f,%ebp
  802772:	75 5c                	jne    8027d0 <__umoddi3+0xb0>
  802774:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802778:	39 3c 24             	cmp    %edi,(%esp)
  80277b:	0f 87 e7 00 00 00    	ja     802868 <__umoddi3+0x148>
  802781:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802785:	29 f1                	sub    %esi,%ecx
  802787:	19 c7                	sbb    %eax,%edi
  802789:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80278d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802791:	8b 44 24 08          	mov    0x8(%esp),%eax
  802795:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802799:	83 c4 14             	add    $0x14,%esp
  80279c:	5e                   	pop    %esi
  80279d:	5f                   	pop    %edi
  80279e:	5d                   	pop    %ebp
  80279f:	c3                   	ret    
  8027a0:	85 f6                	test   %esi,%esi
  8027a2:	89 f5                	mov    %esi,%ebp
  8027a4:	75 0b                	jne    8027b1 <__umoddi3+0x91>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f6                	div    %esi
  8027af:	89 c5                	mov    %eax,%ebp
  8027b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027b5:	31 d2                	xor    %edx,%edx
  8027b7:	f7 f5                	div    %ebp
  8027b9:	89 c8                	mov    %ecx,%eax
  8027bb:	f7 f5                	div    %ebp
  8027bd:	eb 9c                	jmp    80275b <__umoddi3+0x3b>
  8027bf:	90                   	nop
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 fa                	mov    %edi,%edx
  8027c4:	83 c4 14             	add    $0x14,%esp
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
  8027cb:	90                   	nop
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	8b 04 24             	mov    (%esp),%eax
  8027d3:	be 20 00 00 00       	mov    $0x20,%esi
  8027d8:	89 e9                	mov    %ebp,%ecx
  8027da:	29 ee                	sub    %ebp,%esi
  8027dc:	d3 e2                	shl    %cl,%edx
  8027de:	89 f1                	mov    %esi,%ecx
  8027e0:	d3 e8                	shr    %cl,%eax
  8027e2:	89 e9                	mov    %ebp,%ecx
  8027e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e8:	8b 04 24             	mov    (%esp),%eax
  8027eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8027ef:	89 fa                	mov    %edi,%edx
  8027f1:	d3 e0                	shl    %cl,%eax
  8027f3:	89 f1                	mov    %esi,%ecx
  8027f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8027fd:	d3 ea                	shr    %cl,%edx
  8027ff:	89 e9                	mov    %ebp,%ecx
  802801:	d3 e7                	shl    %cl,%edi
  802803:	89 f1                	mov    %esi,%ecx
  802805:	d3 e8                	shr    %cl,%eax
  802807:	89 e9                	mov    %ebp,%ecx
  802809:	09 f8                	or     %edi,%eax
  80280b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80280f:	f7 74 24 04          	divl   0x4(%esp)
  802813:	d3 e7                	shl    %cl,%edi
  802815:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802819:	89 d7                	mov    %edx,%edi
  80281b:	f7 64 24 08          	mull   0x8(%esp)
  80281f:	39 d7                	cmp    %edx,%edi
  802821:	89 c1                	mov    %eax,%ecx
  802823:	89 14 24             	mov    %edx,(%esp)
  802826:	72 2c                	jb     802854 <__umoddi3+0x134>
  802828:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80282c:	72 22                	jb     802850 <__umoddi3+0x130>
  80282e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802832:	29 c8                	sub    %ecx,%eax
  802834:	19 d7                	sbb    %edx,%edi
  802836:	89 e9                	mov    %ebp,%ecx
  802838:	89 fa                	mov    %edi,%edx
  80283a:	d3 e8                	shr    %cl,%eax
  80283c:	89 f1                	mov    %esi,%ecx
  80283e:	d3 e2                	shl    %cl,%edx
  802840:	89 e9                	mov    %ebp,%ecx
  802842:	d3 ef                	shr    %cl,%edi
  802844:	09 d0                	or     %edx,%eax
  802846:	89 fa                	mov    %edi,%edx
  802848:	83 c4 14             	add    $0x14,%esp
  80284b:	5e                   	pop    %esi
  80284c:	5f                   	pop    %edi
  80284d:	5d                   	pop    %ebp
  80284e:	c3                   	ret    
  80284f:	90                   	nop
  802850:	39 d7                	cmp    %edx,%edi
  802852:	75 da                	jne    80282e <__umoddi3+0x10e>
  802854:	8b 14 24             	mov    (%esp),%edx
  802857:	89 c1                	mov    %eax,%ecx
  802859:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80285d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802861:	eb cb                	jmp    80282e <__umoddi3+0x10e>
  802863:	90                   	nop
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80286c:	0f 82 0f ff ff ff    	jb     802781 <__umoddi3+0x61>
  802872:	e9 1a ff ff ff       	jmp    802791 <__umoddi3+0x71>
